-- =====================================================================
-- V21 — Zona P del roadmap v2 (Ola 2): demanda / PYME.
--  * request_templates / request_schedules / request_schedule_runs (2.1): plantillas de solicitud, su programación
--    semanal o quincenal y el registro de cada ocurrencia (publicada, borrador, fallida, saltada). Un job publica en
--    nombre de la organización bajo un tenant sintético (ADR-0013): app.org_id queda fijado, la RLS sigue activa.
--  * carrier_preferences (2.9): transportistas preferidos o bloqueados por cada PYME. Un bloqueado no ve las
--    solicitudes de esa PYME (requests_marketplace) ni puede ofertar (bids_not_blocked). La comprobación va en
--    app_is_blocked_by(), SECURITY DEFINER: el transportista no puede leer la tabla de la PYME y así tampoco se entera.
--  * bid_backups (2.9): las ofertas que RN05 rechaza al adjudicar quedan de respaldo para adjudicar a la segunda
--    oferta si el envío se cancela en las 24 h siguientes. El transportista solo ve su fila cuando se le pide confirmar.
--  * shipments.request_id: ya no es UNIQUE a secas; es único entre los envíos NO cancelados. Una solicitud puede tener
--    un envío cancelado y otro nuevo (adjudicado a la segunda oferta).
-- Aditiva salvo el último punto (relaja una unicidad; no quita datos).
-- =====================================================================

-- ---------- Ayuda: agrega valores a un CHECK (col IN (...)) sin conocer los que otras migraciones ya sumaron ----------
-- (misma ayuda que V22 y V23, con nombre propio: pg_temp vive toda la sesión de Flyway y dos funciones iguales chocan; las migraciones paralelas de T y X agregan sus propios tipos de aviso al mismo CHECK).
CREATE FUNCTION pg_temp.p21_add_check_values(tbl regclass, cname text, vals text[]) RETURNS void
    LANGUAGE plpgsql AS
$$
DECLARE
    def text;
    v   text;
BEGIN
    SELECT pg_get_constraintdef(oid) INTO def FROM pg_constraint WHERE conrelid = tbl AND conname = cname;
    IF def IS NULL THEN
        RAISE EXCEPTION 'No existe el CHECK % en %', cname, tbl;
    END IF;
    FOREACH v IN ARRAY vals LOOP
        IF position(quote_literal(v) IN def) = 0 THEN
            def := regexp_replace(def, '\]\)::text\[\]', ', ' || quote_literal(v) || '::character varying])::text[]');
        END IF;
    END LOOP;
    EXECUTE format('ALTER TABLE %s DROP CONSTRAINT %I', tbl, cname);
    EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I %s', tbl, cname, def);
END
$$;

-- ---------- Avisos nuevos ----------
-- TEMPLATE_RUN: una plantilla programada publicó, dejó un borrador o falló (2.1). REQUEST_INVITATION: invitación a ofertar
-- (2.9). BACKUP_REQUESTED / BACKUP_RESPONDED: segunda oferta (2.9). Destino TEMPLATE: la plantilla (borrador o fallo).
SELECT pg_temp.p21_add_check_values('notifications', 'notifications_type_check',
                                ARRAY['TEMPLATE_RUN', 'REQUEST_INVITATION', 'BACKUP_REQUESTED', 'BACKUP_RESPONDED']);
SELECT pg_temp.p21_add_check_values('notifications', 'notifications_related_type_check', ARRAY['TEMPLATE']);
DROP FUNCTION pg_temp.p21_add_check_values(regclass, text, text[]);

-- ---------- Plantillas ----------
CREATE TABLE request_templates (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id         UUID          NOT NULL REFERENCES organizations (id),
    created_by              UUID          NOT NULL REFERENCES profiles (id),
    name                    VARCHAR(80)   NOT NULL,
    origin_city             VARCHAR(40)   NOT NULL,
    origin_address          VARCHAR(200)  NOT NULL,
    destination_city        VARCHAR(40)   NOT NULL,
    destination_address     VARCHAR(200)  NOT NULL,
    cargo_type              VARCHAR(16)   NOT NULL CHECK (cargo_type IN ('GENERAL', 'FRAGILE', 'PERISHABLE',
                                                                         'HAZARDOUS', 'BULK', 'OVERSIZED')),
    cargo_description       VARCHAR(300)  NOT NULL,
    weight_kg               NUMERIC(10,2) NOT NULL CHECK (weight_kg > 0),
    volume_m3               NUMERIC(8,2)  CHECK (volume_m3 > 0),
    customer_reference      VARCHAR(40),
    declared_value          NUMERIC(14,2) CHECK (declared_value > 0),
    pickup_contact_name     VARCHAR(120),
    pickup_contact_phone    VARCHAR(20),
    pickup_window_from      TIME,
    pickup_window_to        TIME,
    pickup_instructions     VARCHAR(300),
    delivery_contact_name   VARCHAR(120),
    delivery_contact_phone  VARCHAR(20),
    delivery_window_from    TIME,
    delivery_window_to      TIME,
    delivery_instructions   VARCHAR(300),
    origin_place_id         UUID REFERENCES saved_places (id),
    destination_place_id    UUID REFERENCES saved_places (id),
    -- Avisa a los transportistas preferidos cada vez que se publique desde esta plantilla (2.9).
    invite_preferred        BOOLEAN       NOT NULL DEFAULT FALSE,
    archived_at             TIMESTAMPTZ,
    last_published_at       TIMESTAMPTZ,
    created_at              TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CHECK (origin_city <> destination_city)
);
CREATE INDEX ix_templates_org ON request_templates (organization_id, archived_at, last_published_at DESC NULLS LAST, name);
CREATE UNIQUE INDEX ux_templates_org_name ON request_templates (organization_id, lower(name)) WHERE archived_at IS NULL;

ALTER TABLE request_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY templates_select ON request_templates FOR SELECT TO logyx_app USING (organization_id = app_org());
CREATE POLICY templates_insert ON request_templates FOR INSERT TO logyx_app WITH CHECK (organization_id = app_org());
CREATE POLICY templates_update ON request_templates FOR UPDATE TO logyx_app
    USING (organization_id = app_org()) WITH CHECK (organization_id = app_org());
CREATE POLICY templates_operator ON request_templates FOR SELECT TO logyx_app USING (app_org_type() = 'OPERATOR');
-- Sin DELETE: las plantillas se archivan.

-- ---------- Programación (una por plantilla) ----------
CREATE TABLE request_schedules (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id    UUID        NOT NULL REFERENCES organizations (id),
    template_id        UUID        NOT NULL UNIQUE REFERENCES request_templates (id),
    frequency          VARCHAR(10) NOT NULL CHECK (frequency IN ('WEEKLY', 'BIWEEKLY')),
    -- ISO: 1 = lunes … 7 = domingo. Día de la semana del RECOJO.
    pickup_weekday     SMALLINT    NOT NULL CHECK (pickup_weekday BETWEEN 1 AND 7),
    -- Con cuántos días de anticipación al recojo se publica (0 = el mismo día).
    lead_days          SMALLINT    NOT NULL DEFAULT 2 CHECK (lead_days BETWEEN 0 AND 14),
    ends_on            DATE,
    skip_holidays      BOOLEAN     NOT NULL DEFAULT TRUE,
    -- PUBLISH publica sola; DRAFT deja un borrador que la persona confirma.
    mode               VARCHAR(8)  NOT NULL DEFAULT 'PUBLISH' CHECK (mode IN ('PUBLISH', 'DRAFT')),
    paused             BOOLEAN     NOT NULL DEFAULT FALSE,
    next_pickup_date   DATE        NOT NULL,
    next_run_at        TIMESTAMPTZ NOT NULL,
    last_run_at        TIMESTAMPTZ,
    -- Fallos seguidos: a los 3 se pausa sola (no se reintenta en bucle).
    failures           SMALLINT    NOT NULL DEFAULT 0,
    finished_at        TIMESTAMPTZ,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_schedules_due ON request_schedules (next_run_at) WHERE NOT paused AND finished_at IS NULL;
CREATE INDEX ix_schedules_org ON request_schedules (organization_id);

ALTER TABLE request_schedules ENABLE ROW LEVEL SECURITY;
CREATE POLICY schedules_select ON request_schedules FOR SELECT TO logyx_app USING (organization_id = app_org());
CREATE POLICY schedules_insert ON request_schedules FOR INSERT TO logyx_app WITH CHECK (organization_id = app_org());
CREATE POLICY schedules_update ON request_schedules FOR UPDATE TO logyx_app
    USING (organization_id = app_org()) WITH CHECK (organization_id = app_org());
CREATE POLICY schedules_delete ON request_schedules FOR DELETE TO logyx_app USING (organization_id = app_org());
CREATE POLICY schedules_operator ON request_schedules FOR SELECT TO logyx_app USING (app_org_type() = 'OPERATOR');

-- ---------- Ocurrencias de la programación ----------
CREATE TABLE request_schedule_runs (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id  UUID        NOT NULL REFERENCES organizations (id),
    schedule_id      UUID        NOT NULL REFERENCES request_schedules (id) ON DELETE CASCADE,
    template_id      UUID        NOT NULL REFERENCES request_templates (id),
    pickup_date      DATE        NOT NULL,
    status           VARCHAR(10) NOT NULL CHECK (status IN ('PUBLISHED', 'DRAFT', 'FAILED', 'SKIPPED', 'DISCARDED')),
    request_id       UUID        REFERENCES shipment_requests (id),
    error_code       VARCHAR(24),
    error_message    VARCHAR(300),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    resolved_at      TIMESTAMPTZ,
    -- Una sola ocurrencia por día de recojo: un reintento del job no duplica la solicitud.
    UNIQUE (schedule_id, pickup_date)
);
CREATE INDEX ix_runs_org ON request_schedule_runs (organization_id, created_at DESC);
CREATE INDEX ix_runs_template ON request_schedule_runs (template_id, created_at DESC);

ALTER TABLE request_schedule_runs ENABLE ROW LEVEL SECURITY;
CREATE POLICY runs_select ON request_schedule_runs FOR SELECT TO logyx_app USING (organization_id = app_org());
CREATE POLICY runs_insert ON request_schedule_runs FOR INSERT TO logyx_app WITH CHECK (organization_id = app_org());
CREATE POLICY runs_update ON request_schedule_runs FOR UPDATE TO logyx_app
    USING (organization_id = app_org()) WITH CHECK (organization_id = app_org());
CREATE POLICY runs_operator ON request_schedule_runs FOR SELECT TO logyx_app USING (app_org_type() = 'OPERATOR');

-- ---------- Transportistas preferidos o bloqueados ----------
CREATE TABLE carrier_preferences (
    requester_org_id  UUID        NOT NULL REFERENCES organizations (id),
    carrier_org_id    UUID        NOT NULL REFERENCES organizations (id),
    kind              VARCHAR(10) NOT NULL CHECK (kind IN ('PREFERRED', 'BLOCKED')),
    created_by        UUID        REFERENCES profiles (id),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (requester_org_id, carrier_org_id),
    CHECK (requester_org_id <> carrier_org_id)
);
CREATE INDEX ix_prefs_carrier ON carrier_preferences (carrier_org_id, requester_org_id) WHERE kind = 'BLOCKED';

ALTER TABLE carrier_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY prefs_owner ON carrier_preferences FOR ALL TO logyx_app
    USING (requester_org_id = app_org() AND app_org_type() = 'PYME')
    WITH CHECK (requester_org_id = app_org() AND app_org_type() = 'PYME');
CREATE POLICY prefs_operator ON carrier_preferences FOR SELECT TO logyx_app USING (app_org_type() = 'OPERATOR');

-- ¿La PYME dada bloqueó a la organización de la transacción? SECURITY DEFINER: el transportista no lee
-- carrier_preferences (es de la PYME), pero las políticas de solicitudes y ofertas necesitan esta sola respuesta.
-- No expone nada más: devuelve un booleano para el par (PYME, mi organización).
CREATE OR REPLACE FUNCTION app_is_blocked_by(requester UUID) RETURNS BOOLEAN
    LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS
$$ SELECT EXISTS (SELECT 1 FROM carrier_preferences p
                  WHERE p.requester_org_id = requester AND p.carrier_org_id = app_org() AND p.kind = 'BLOCKED') $$;
REVOKE ALL ON FUNCTION app_is_blocked_by(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app_is_blocked_by(UUID) TO logyx_app;

-- Un bloqueado no ve las solicitudes publicadas de esa PYME. Sigue viendo las ya adjudicadas a él
-- (assigned_carrier_org_id) y, por requests_bidder_read, aquellas en las que ya había ofertado.
DROP POLICY requests_marketplace ON shipment_requests;
CREATE POLICY requests_marketplace ON shipment_requests FOR SELECT TO logyx_app
    USING (app_org_type() = 'CARRIER'
           AND ((status = 'PUBLISHED' AND NOT app_is_blocked_by(requester_org_id))
                OR assigned_carrier_org_id = app_org()));

-- Y tampoco puede ofertar (defensa en profundidad: la aplicación ya no le muestra la solicitud).
CREATE POLICY bids_not_blocked ON bids AS RESTRICTIVE FOR INSERT TO logyx_app
    WITH CHECK (NOT app_is_blocked_by(requester_org_id));

-- ---------- Ofertas de respaldo (segunda oferta) ----------
CREATE TABLE bid_backups (
    bid_id            UUID PRIMARY KEY REFERENCES bids (id),
    request_id        UUID        NOT NULL REFERENCES shipment_requests (id),
    requester_org_id  UUID        NOT NULL REFERENCES organizations (id),
    carrier_org_id    UUID        NOT NULL REFERENCES organizations (id),
    -- Posición entre las ofertas rechazadas al adjudicar (1 = la mejor de las restantes).
    rank              SMALLINT    NOT NULL CHECK (rank >= 1),
    -- AVAILABLE: guardada; REQUESTED: la PYME pidió confirmar; CONFIRMED / DECLINED: respuesta del transportista;
    -- USED: se adjudicó a esta oferta.
    state             VARCHAR(10) NOT NULL DEFAULT 'AVAILABLE'
                      CHECK (state IN ('AVAILABLE', 'REQUESTED', 'CONFIRMED', 'DECLINED', 'USED')),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    requested_at      TIMESTAMPTZ,
    responded_at      TIMESTAMPTZ,
    used_at           TIMESTAMPTZ
);
CREATE INDEX ix_backups_request ON bid_backups (request_id, rank);
CREATE INDEX ix_backups_carrier ON bid_backups (carrier_org_id, state);

ALTER TABLE bid_backups ENABLE ROW LEVEL SECURITY;
CREATE POLICY backups_requester ON bid_backups FOR ALL TO logyx_app
    USING (requester_org_id = app_org()) WITH CHECK (requester_org_id = app_org());
-- El transportista solo la ve cuando la PYME le pide confirmar (así no sabe que quedó de respaldo antes) y solo
-- responde (CONFIRMED / DECLINED); nada más de la fila es editable por él.
CREATE POLICY backups_carrier_read ON bid_backups FOR SELECT TO logyx_app
    USING (carrier_org_id = app_org() AND state <> 'AVAILABLE');
CREATE POLICY backups_carrier_respond ON bid_backups FOR UPDATE TO logyx_app
    USING (carrier_org_id = app_org() AND state = 'REQUESTED')
    WITH CHECK (carrier_org_id = app_org() AND state IN ('CONFIRMED', 'DECLINED'));
-- La asignación manual del operador (RN10) también rechaza al resto: deja sus respaldos.
CREATE POLICY backups_operator_insert ON bid_backups FOR INSERT TO logyx_app WITH CHECK (app_org_type() = 'OPERATOR');
CREATE POLICY backups_operator_read ON bid_backups FOR SELECT TO logyx_app USING (app_org_type() = 'OPERATOR');
-- Solo cambian estado y fechas; la oferta, la posición y las partes quedan fijas.
REVOKE UPDATE, DELETE ON bid_backups FROM logyx_app;
GRANT UPDATE (state, requested_at, responded_at, used_at) ON bid_backups TO logyx_app;

-- ---------- Un envío cancelado y otro nuevo para la misma solicitud ----------
ALTER TABLE shipments DROP CONSTRAINT IF EXISTS shipments_request_id_key;
CREATE UNIQUE INDEX ux_shipments_request_active ON shipments (request_id) WHERE status <> 'CANCELLED';
