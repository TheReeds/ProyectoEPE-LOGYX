-- =====================================================================
-- V23 — Ola 2, zona X (ejecución y operación). Reservada para X (P usa V21, T usa V22; dev admite out-of-order).
--  * 2.5 Evidencia del recojo y registro por la oficina:
--      documents.type suma PICKUP_PHOTO (foto de la carga en el recojo; solo el conductor asignado, como la de entrega).
--      shipment_stops: loaded_weight_kg (peso medido al recoger), received_by_name / received_by_doc (quien recibe la
--      entrega), arrival_office_reason / completion_office_reason (la oficina del transportista registró ese paso con
--      motivo: «celular sin batería»; NULL = lo registró el conductor).
--      shipments.pickup_photo_required / pickup_weight_required: lo que la PYME exige en el recojo (por omisión, nada:
--      los envíos y clientes existentes siguen igual).
--  * 2.6 shipment_adjustments: ajustes del precio (peso real, estadía, peajes, maniobras) que propone el transportista
--      y decide la PYME (o el operador si pasan las horas de respuesta). Precio final = acordado + aceptados.
--  * 2.7 Incidencias v2: categorías nuevas, severidad, si congela (blocking, RN11), monto reclamado, responsable del
--      operador, vencimiento (SLA por severidad), retiro, reapertura, ubicación y hora del reporte (botón «Emergencia»
--      sin señal), vínculo con un ajuste; comentarios internos (solo el operador) y adjuntos del alta.
--  * 2.15 Operador 360: suspensión de un usuario por el operador (columna propia: el ADMIN no la levanta), sucesora por
--      cambio de RUC (predecessor_id), historial de cambios de razón social o RUC con su documento, huella del registro
--      (SHA-256 de la IP) para las señales de fraude.
--  * Notificaciones: tipos ADJUSTMENT_PROPOSED, ADJUSTMENT_DECIDED, ADJUSTMENT_ESCALATED e INCIDENT_ASSIGNED. Se
--    AGREGAN a los CHECK existentes leyéndolos de la BD (mismo método que V22) para no pisar lo de P y T.
-- Aditiva: columnas con valor por omisión o nulas, tablas nuevas y políticas. Solo reescribe `incidents.blocking` de
-- las DELAY existentes (pasan a informativas, F21) y su vencimiento.
-- =====================================================================

-- ---------- Ayuda: agrega valores a un CHECK (col IN (...)) sin conocer los que otras migraciones ya sumaron ----------
-- Nombre propio (x23_): pg_temp vive toda la sesión de Flyway y dos funciones iguales de V21/V22/V23 chocarían. Se borra al final.
CREATE FUNCTION pg_temp.x23_add_check_values(tbl regclass, cname text, vals text[]) RETURNS void
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

SELECT pg_temp.x23_add_check_values('notifications', 'notifications_type_check',
                                ARRAY['ADJUSTMENT_PROPOSED', 'ADJUSTMENT_DECIDED', 'ADJUSTMENT_ESCALATED',
                                      'INCIDENT_ASSIGNED']);

-- =====================================================================
-- 2.5 Evidencia del recojo y registro por la oficina
-- =====================================================================
SELECT pg_temp.x23_add_check_values('documents', 'documents_type_check', ARRAY['PICKUP_PHOTO']);

ALTER TABLE shipment_stops ADD COLUMN loaded_weight_kg          NUMERIC(10,2) CHECK (loaded_weight_kg > 0);
ALTER TABLE shipment_stops ADD COLUMN received_by_name          VARCHAR(120);
ALTER TABLE shipment_stops ADD COLUMN received_by_doc           VARCHAR(20);
ALTER TABLE shipment_stops ADD COLUMN arrival_office_reason     VARCHAR(300);
ALTER TABLE shipment_stops ADD COLUMN completion_office_reason  VARCHAR(300);

ALTER TABLE shipments ADD COLUMN pickup_photo_required  BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE shipments ADD COLUMN pickup_weight_required BOOLEAN NOT NULL DEFAULT FALSE;

-- =====================================================================
-- 2.6 Ajustes del envío
-- =====================================================================
CREATE TABLE shipment_adjustments (
    id                     UUID PRIMARY KEY,
    shipment_id            UUID          NOT NULL REFERENCES shipments (id),
    -- Parada a la que se refiere (estadía en un recojo o una entrega); NULL = todo el envío.
    stop_id                UUID          REFERENCES shipment_stops (id),
    requester_org_id       UUID          NOT NULL REFERENCES organizations (id),
    carrier_org_id         UUID          NOT NULL REFERENCES organizations (id),
    type                   VARCHAR(16)   NOT NULL CHECK (type IN ('WEIGHT_DIFF', 'DETENTION', 'TOLL', 'HANDLING', 'OTHER')),
    -- Monto con IGV (como el precio adjudicado). Negativo = descuento (p. ej. pesó menos de lo declarado).
    amount                 NUMERIC(12,2) NOT NULL CHECK (amount <> 0),
    note                   VARCHAR(500),
    evidence_document_id   UUID          REFERENCES documents (id),
    status                 VARCHAR(12)   NOT NULL DEFAULT 'PENDING'
                           CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'WITHDRAWN')),
    proposed_by_org_id     UUID          NOT NULL REFERENCES organizations (id),
    proposed_by_profile_id UUID          REFERENCES profiles (id),
    created_at             TIMESTAMPTZ   NOT NULL DEFAULT now(),
    -- Hasta cuándo responde la PYME (parámetro adjustment_response_hours); luego decide el operador.
    respond_by             TIMESTAMPTZ   NOT NULL,
    escalated_at           TIMESTAMPTZ,
    decided_at             TIMESTAMPTZ,
    decided_by_profile_id  UUID          REFERENCES profiles (id),
    decided_by_org_id      UUID          REFERENCES organizations (id),
    decision_note          VARCHAR(500),
    CHECK (proposed_by_org_id = carrier_org_id)
);
CREATE INDEX ix_adjustments_shipment ON shipment_adjustments (shipment_id, created_at);
CREATE INDEX ix_adjustments_pending ON shipment_adjustments (respond_by) WHERE status = 'PENDING';

ALTER TABLE shipment_adjustments ENABLE ROW LEVEL SECURITY;
-- Las dos partes leen; el transportista propone (y retira); la PYME decide. El operador lee y decide los escalados.
CREATE POLICY adjustments_parties_read ON shipment_adjustments FOR SELECT TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY adjustments_carrier_insert ON shipment_adjustments FOR INSERT TO logyx_app
    WITH CHECK (carrier_org_id = app_org() AND proposed_by_org_id = app_org() AND status = 'PENDING'
                AND EXISTS (SELECT 1 FROM shipments s
                            WHERE s.id = shipment_adjustments.shipment_id AND s.carrier_org_id = app_org()
                              AND s.requester_org_id = shipment_adjustments.requester_org_id));
CREATE POLICY adjustments_parties_update ON shipment_adjustments FOR UPDATE TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id))
    WITH CHECK (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY adjustments_operator_read ON shipment_adjustments FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
CREATE POLICY adjustments_operator_update ON shipment_adjustments FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');
-- Un conductor solo ve los ajustes de sus envíos (su organización ve todos).
CREATE POLICY adjustments_driver_scope ON shipment_adjustments AS RESTRICTIVE FOR ALL TO logyx_app
    USING ((SELECT app_driver_id()) IS NULL
           OR EXISTS (SELECT 1 FROM shipments s
                      WHERE s.id = shipment_adjustments.shipment_id AND s.driver_id = (SELECT app_driver_id())))
    WITH CHECK ((SELECT app_driver_id()) IS NULL
           OR EXISTS (SELECT 1 FROM shipments s
                      WHERE s.id = shipment_adjustments.shipment_id AND s.driver_id = (SELECT app_driver_id())));
REVOKE DELETE ON shipment_adjustments FROM logyx_app;
-- Solo cambian estado y decisión: tipo, monto, partes y propuesta quedan fijos.
REVOKE UPDATE ON shipment_adjustments FROM logyx_app;
GRANT UPDATE (status, escalated_at, decided_at, decided_by_profile_id, decided_by_org_id, decision_note)
    ON shipment_adjustments TO logyx_app;

-- =====================================================================
-- 2.7 Incidencias v2
-- =====================================================================
SELECT pg_temp.x23_add_check_values('incidents', 'incidents_category_check',
                                ARRAY['PICKUP_NO_SHOW', 'SHIPPER_NO_SHOW', 'BREAKDOWN', 'ACCIDENT', 'THEFT',
                                      'ROAD_BLOCKED', 'PARTIAL_DELIVERY', 'PAYMENT_DISPUTE']);

ALTER TABLE incidents ADD COLUMN severity            VARCHAR(10)   NOT NULL DEFAULT 'MEDIUM'
    CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'));
-- true = congela el avance de paradas mientras está activa (RN11); false = informativa (F21).
ALTER TABLE incidents ADD COLUMN blocking            BOOLEAN       NOT NULL DEFAULT TRUE;
ALTER TABLE incidents ADD COLUMN claimed_amount      NUMERIC(12,2) CHECK (claimed_amount > 0);
ALTER TABLE incidents ADD COLUMN assignee_profile_id UUID          REFERENCES profiles (id);
ALTER TABLE incidents ADD COLUMN due_at              TIMESTAMPTZ;
ALTER TABLE incidents ADD COLUMN withdrawn_at        TIMESTAMPTZ;
ALTER TABLE incidents ADD COLUMN reopened_at         TIMESTAMPTZ;
ALTER TABLE incidents ADD COLUMN reopen_count        INT           NOT NULL DEFAULT 0 CHECK (reopen_count >= 0);
ALTER TABLE incidents ADD COLUMN latitude            NUMERIC(9,6)  CHECK (latitude BETWEEN -90 AND 90);
ALTER TABLE incidents ADD COLUMN longitude           NUMERIC(9,6)  CHECK (longitude BETWEEN -180 AND 180);
-- Hora en que ocurrió según el dispositivo (reporte encolado sin señal); NULL = la del alta.
ALTER TABLE incidents ADD COLUMN occurred_at         TIMESTAMPTZ;
ALTER TABLE incidents ADD COLUMN adjustment_id       UUID          REFERENCES shipment_adjustments (id);

UPDATE incidents SET blocking = FALSE WHERE category = 'DELAY';
UPDATE incidents SET due_at = created_at + interval '24 hours' WHERE due_at IS NULL;
ALTER TABLE incidents ALTER COLUMN due_at SET NOT NULL;

-- Antes: una activa por envío. Ahora: una activa que congela por envío y una activa por categoría.
DROP INDEX ux_incidents_active;
CREATE UNIQUE INDEX ux_incidents_active_blocking ON incidents (shipment_id)
    WHERE blocking AND status IN ('OPEN', 'IN_REVIEW');
CREATE UNIQUE INDEX ux_incidents_active_category ON incidents (shipment_id, category)
    WHERE status IN ('OPEN', 'IN_REVIEW');
CREATE INDEX ix_incidents_due ON incidents (due_at) WHERE status IN ('OPEN', 'IN_REVIEW');
CREATE INDEX ix_incidents_assignee ON incidents (assignee_profile_id) WHERE assignee_profile_id IS NOT NULL;

-- Quien reportó puede retirar una informativa activa: solo pasarla a CLOSED con la marca de retiro. Nada más.
CREATE POLICY incidents_reporter_update ON incidents FOR UPDATE TO logyx_app
    USING (reported_by_org_id = app_org() AND NOT blocking AND status IN ('OPEN', 'IN_REVIEW'))
    WITH CHECK (reported_by_org_id = app_org() AND NOT blocking AND status = 'CLOSED' AND withdrawn_at IS NOT NULL);

-- Comentarios internos: solo el operador los escribe y los lee.
ALTER TABLE incident_comments ADD COLUMN internal BOOLEAN NOT NULL DEFAULT FALSE;
DROP POLICY incident_comments_read ON incident_comments;
CREATE POLICY incident_comments_read ON incident_comments FOR SELECT TO logyx_app
    USING ((app_org() IN (requester_org_id, carrier_org_id) AND NOT internal) OR app_org_type() = 'OPERATOR');
DROP POLICY incident_comments_insert ON incident_comments;
CREATE POLICY incident_comments_insert ON incident_comments FOR INSERT TO logyx_app
    WITH CHECK (author_org_id = app_org()
                AND ((app_org() IN (requester_org_id, carrier_org_id) AND NOT internal)
                     OR app_org_type() = 'OPERATOR'));

-- Adjuntos del alta: documentos del mismo envío que la parte subió antes de reportar.
CREATE TABLE incident_attachments (
    incident_id       UUID        NOT NULL REFERENCES incidents (id),
    document_id       UUID        NOT NULL REFERENCES documents (id),
    requester_org_id  UUID        NOT NULL REFERENCES organizations (id),
    carrier_org_id    UUID        NOT NULL REFERENCES organizations (id),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (incident_id, document_id)
);
ALTER TABLE incident_attachments ENABLE ROW LEVEL SECURITY;
CREATE POLICY incident_attachments_parties ON incident_attachments FOR SELECT TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY incident_attachments_insert ON incident_attachments FOR INSERT TO logyx_app
    WITH CHECK (app_org() IN (requester_org_id, carrier_org_id)
                AND EXISTS (SELECT 1 FROM incidents i
                            WHERE i.id = incident_attachments.incident_id
                              AND i.requester_org_id = incident_attachments.requester_org_id
                              AND i.carrier_org_id = incident_attachments.carrier_org_id)
                AND EXISTS (SELECT 1 FROM documents d, incidents i
                            WHERE d.id = incident_attachments.document_id AND i.id = incident_attachments.incident_id
                              AND d.shipment_id = i.shipment_id));
CREATE POLICY incident_attachments_operator ON incident_attachments FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
REVOKE UPDATE, DELETE ON incident_attachments FROM logyx_app;

-- =====================================================================
-- 2.15 Operador 360, fraude y cuentas
-- =====================================================================
-- Suspensión de un usuario por el operador: su ADMIN no la levanta (LOGYX-USR-007).
ALTER TABLE profiles ADD COLUMN operator_suspended_at      TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN operator_suspension_reason VARCHAR(300);

CREATE POLICY profiles_operator_update ON profiles FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');

-- El operador solo toca el estado de un usuario de OTRA organización; las organizaciones no tocan la suspensión.
CREATE FUNCTION profiles_guard_operator_suspension() RETURNS trigger
    LANGUAGE plpgsql AS
$$
DECLARE
    t text := nullif(current_setting('app.org_type', true), '');
    o uuid := nullif(current_setting('app.org_id', true), '')::uuid;
BEGIN
    IF t IS NULL THEN
        RETURN NEW;                       -- plataforma (SystemTx): sin restricciones
    END IF;
    IF t = 'OPERATOR' AND OLD.organization_id IS DISTINCT FROM o THEN
        IF (NEW.organization_id, NEW.email, NEW.password_hash, NEW.full_name, NEW.role, NEW.consent_accepted_at,
            NEW.invitation_pending, NEW.invited_by, NEW.password_changed_at, NEW.last_login_at)
           IS DISTINCT FROM
           (OLD.organization_id, OLD.email, OLD.password_hash, OLD.full_name, OLD.role, OLD.consent_accepted_at,
            OLD.invitation_pending, OLD.invited_by, OLD.password_changed_at, OLD.last_login_at) THEN
            RAISE EXCEPTION 'El operador solo cambia el estado de un usuario' USING ERRCODE = '42501';
        END IF;
        RETURN NEW;
    END IF;
    IF (NEW.operator_suspended_at, NEW.operator_suspension_reason)
       IS DISTINCT FROM (OLD.operator_suspended_at, OLD.operator_suspension_reason) THEN
        RAISE EXCEPTION 'Solo el operador suspende o reactiva por su cuenta' USING ERRCODE = '42501';
    END IF;
    RETURN NEW;
END
$$;
CREATE TRIGGER profiles_guard_operator_suspension BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION profiles_guard_operator_suspension();

-- Sucesora por cambio de RUC (hereda la reputación con la aprobación del operador) y huella del registro.
ALTER TABLE organizations ADD COLUMN predecessor_id UUID REFERENCES organizations (id);
ALTER TABLE organizations ADD COLUMN signup_ip_hash VARCHAR(64);
CREATE INDEX ix_organizations_signup_ip ON organizations (signup_ip_hash) WHERE signup_ip_hash IS NOT NULL;
CREATE INDEX ix_organizations_predecessor ON organizations (predecessor_id) WHERE predecessor_id IS NOT NULL;

CREATE TABLE organization_legal_changes (
    id                     UUID PRIMARY KEY,
    organization_id        UUID         NOT NULL REFERENCES organizations (id),
    successor_id           UUID         REFERENCES organizations (id),
    old_legal_name         VARCHAR(200) NOT NULL,
    new_legal_name         VARCHAR(200) NOT NULL,
    old_ruc                VARCHAR(11)  NOT NULL,
    new_ruc                VARCHAR(11)  NOT NULL,
    reason                 VARCHAR(300) NOT NULL,
    document_key           VARCHAR(500) NOT NULL UNIQUE,
    document_name          VARCHAR(255) NOT NULL,
    document_content_type  VARCHAR(100) NOT NULL,
    document_size_bytes    BIGINT       NOT NULL CHECK (document_size_bytes > 0),
    document_sha256        VARCHAR(64)  NOT NULL,
    created_by             UUID         REFERENCES profiles (id),
    created_at             TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX ix_legal_changes_org ON organization_legal_changes (organization_id, created_at DESC);
ALTER TABLE organization_legal_changes ENABLE ROW LEVEL SECURITY;
CREATE POLICY legal_changes_operator_read ON organization_legal_changes FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
CREATE POLICY legal_changes_operator_insert ON organization_legal_changes FOR INSERT TO logyx_app
    WITH CHECK (app_org_type() = 'OPERATOR');
REVOKE UPDATE, DELETE ON organization_legal_changes FROM logyx_app;

-- Señales de fraude: búsquedas por placa normalizada, licencia y teléfono entre organizaciones.
CREATE INDEX ix_drivers_license_norm ON drivers (upper(regexp_replace(license_number, '[^A-Za-z0-9]', '', 'g')));
CREATE INDEX ix_organizations_phone ON organizations (regexp_replace(phone, '[^0-9]', '', 'g')) WHERE phone IS NOT NULL;

DROP FUNCTION pg_temp.x23_add_check_values(regclass, text, text[]);
