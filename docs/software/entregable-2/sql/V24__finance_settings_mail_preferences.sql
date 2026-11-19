-- =====================================================================
-- V24 — Ola 2, zona F (finanzas, configuración y correo). Roadmap v2: 2.11, 2.12, 2.14, 2.2 (resto) y 2.17 (resto).
--  * 2.14 tariff_versions (tarifario versionado con vigencia; la versión 1 son las constantes que tenía el motor de
--    costos), shipment_requests.tariff_version (qué versión usó la cotización guardada) y calendar_days (feriados y
--    paros editables por el operador; siembra los feriados nacionales 2026–2028 que hoy calcula PeruHolidays).
--  * 2.12 shipment_settlements (estado de cobro por envío: PENDING_INVOICE → INVOICED → PAID → CONFIRMED, DISPUTED;
--    comisión de OnCargo PENDING / COLLECTED / NOT_APPLICABLE), settlement_history (pasos del cobro, lo ven las partes),
--    commission_collections (cobros de comisión que registra el operador; la PYME no los ve), settlement_notices
--    (recordatorios ya enviados, solo sistema) y carrier_payout_accounts (datos de cobro del transportista, número
--    cifrado en la aplicación con AES-GCM; la PYME los lee solo si tiene un envío con él).
--  * 2.2 user_preferences (correo activo, inmediato o resumen diario, horario de silencio; por persona),
--    notification_email_queue (correos diferidos por silencio o resumen; solo sistema), organization_preferences
--    (ciudades, rutas y tipos de carga de interés, precio mínimo por km, horario de recojo y plazo de pago) y
--    org_route_alerts (idempotencia de las alertas implícitas por rutas de interés; solo sistema).
--  * 2.17 terms_acceptances: se aceptan también al aceptar una invitación (INVITATION) y al cambiar la versión (UPDATE);
--    la propia persona inserta su aceptación bajo RLS.
--  * Avisos PAYMENT_DUE, SETTLEMENT_UPDATED y COMMISSION_COLLECTED (categoría PAYMENTS); documentos PAYMENT_PROOF y
--    CARRIER_INVOICE. Se AGREGAN a los CHECK vigentes leyéndolos de la BD (mismo método que V22).
-- Aditiva: tablas nuevas, columnas nulas y siembras. No reescribe datos de negocio.
-- =====================================================================

-- ---------- Ayuda: agrega valores a un CHECK (col IN (...)) sin conocer los que otras migraciones ya sumaron ----------
-- Nombre propio (f24_): pg_temp vive toda la sesión de Flyway y otra función con el mismo nombre chocaría. Se borra al final.
CREATE FUNCTION pg_temp.f24_add_check_values(tbl regclass, cname text, col text, vals text[]) RETURNS void
    LANGUAGE plpgsql AS
$$
DECLARE
    def   text;
    items text[];
    v     text;
BEGIN
    SELECT pg_get_constraintdef(oid) INTO def FROM pg_constraint WHERE conrelid = tbl AND conname = cname;
    IF def IS NULL THEN
        RAISE EXCEPTION 'No existe el CHECK % en %', cname, tbl;
    END IF;
    SELECT coalesce(array_agg(m[1] ORDER BY ord), ARRAY[]::text[]) INTO items
    FROM regexp_matches(def, '''([^'']+)''::(?:character varying|text)', 'g') WITH ORDINALITY AS t(m, ord);
    FOREACH v IN ARRAY vals LOOP
        IF NOT (v = ANY (items)) THEN
            items := items || v;
        END IF;
    END LOOP;
    EXECUTE format('ALTER TABLE %s DROP CONSTRAINT %I', tbl, cname);
    EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I CHECK (%I IN (%s))', tbl, cname, col,
                   (SELECT string_agg(quote_literal(i), ', ') FROM unnest(items) i));
END
$$;

SELECT pg_temp.f24_add_check_values('notifications', 'notifications_type_check', 'type',
                                    ARRAY['PAYMENT_DUE', 'SETTLEMENT_UPDATED', 'COMMISSION_COLLECTED']);
SELECT pg_temp.f24_add_check_values('notification_preferences', 'notification_preferences_category_check', 'category',
                                    ARRAY['PAYMENTS']);
SELECT pg_temp.f24_add_check_values('documents', 'documents_type_check', 'type',
                                    ARRAY['PAYMENT_PROOF', 'CARRIER_INVOICE']);
SELECT pg_temp.f24_add_check_values('terms_acceptances', 'terms_acceptances_source_check', 'source',
                                    ARRAY['INVITATION', 'UPDATE']);

-- =====================================================================
-- 2.14 Tarifario versionado
-- =====================================================================
-- sugerido = base + km × combustible + km × t × tarifa_t_km × multiplicador(tipo) + ⌈km / cada⌉ × peaje + manipuleo
-- La vigente es la de mayor versión con effective_from <= now() y sin anular. Una versión futura queda programada y se
-- puede anular antes de que rija (cancelled_at). Sin UPDATE de los valores: un cambio es una versión nueva.
CREATE TABLE tariff_versions (
    version            INT           PRIMARY KEY CHECK (version >= 1),
    base_fee           NUMERIC(10,2) NOT NULL CHECK (base_fee >= 0),
    fuel_per_km        NUMERIC(8,4)  NOT NULL CHECK (fuel_per_km >= 0),
    rate_per_km_ton    NUMERIC(8,4)  NOT NULL CHECK (rate_per_km_ton >= 0),
    toll_every_km      NUMERIC(8,2)  NOT NULL CHECK (toll_every_km > 0),
    toll_price         NUMERIC(8,2)  NOT NULL CHECK (toll_price >= 0),
    handling_rate      NUMERIC(6,4)  NOT NULL CHECK (handling_rate >= 0 AND handling_rate <= 1),
    -- {"GENERAL":"1.00","FRAGILE":"1.30",...}: un multiplicador por cada CargoType (lo valida la aplicación).
    cargo_multipliers  JSONB         NOT NULL,
    effective_from     TIMESTAMPTZ   NOT NULL,
    reason             VARCHAR(300)  NOT NULL,
    created_by         UUID          REFERENCES profiles (id),
    created_at         TIMESTAMPTZ   NOT NULL DEFAULT now(),
    cancelled_at       TIMESTAMPTZ,
    cancelled_by       UUID          REFERENCES profiles (id)
);
CREATE INDEX ix_tariff_effective ON tariff_versions (effective_from DESC) WHERE cancelled_at IS NULL;

INSERT INTO tariff_versions (version, base_fee, fuel_per_km, rate_per_km_ton, toll_every_km, toll_price, handling_rate,
                             cargo_multipliers, effective_from, reason)
VALUES (1, 0, 0.65, 0.80, 120, 12, 0.05,
        '{"GENERAL":"1.00","FRAGILE":"1.30","PERISHABLE":"1.25","HAZARDOUS":"1.50","BULK":"0.95","OVERSIZED":"1.40"}',
        TIMESTAMPTZ '2026-01-01 00:00:00-05', 'Tarifa inicial: constantes del motor de costos (E3 §3.2)');

ALTER TABLE tariff_versions ENABLE ROW LEVEL SECURITY;
-- Cualquiera con sesión lee (la PYME ve con qué tarifa se cotizó); solo el operador crea o anula.
CREATE POLICY tariff_read ON tariff_versions FOR SELECT TO logyx_app USING (true);
CREATE POLICY tariff_operator_insert ON tariff_versions FOR INSERT TO logyx_app
    WITH CHECK (app_org_type() = 'OPERATOR');
CREATE POLICY tariff_operator_update ON tariff_versions FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');
REVOKE UPDATE, DELETE ON tariff_versions FROM logyx_app;
GRANT UPDATE (cancelled_at, cancelled_by) ON tariff_versions TO logyx_app;

-- Versión del tarifario con la que se calculó el sugerido y el piso guardados (NULL = anterior a V24 = versión 1).
ALTER TABLE shipment_requests ADD COLUMN tariff_version INT REFERENCES tariff_versions (version);

-- =====================================================================
-- 2.14 Calendario de feriados y paros
-- =====================================================================
CREATE TABLE calendar_days (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    day              DATE         NOT NULL,
    kind             VARCHAR(12)  NOT NULL CHECK (kind IN ('HOLIDAY', 'STRIKE', 'OTHER')),
    name             VARCHAR(120) NOT NULL,
    -- NULL = todo el país; si no, las ciudades del catálogo afectadas (p. ej. un paro regional).
    cities           TEXT[],
    -- true = las cargas recurrentes que saltan feriados no se publican para recoger ese día (2.1).
    skip_recurrence  BOOLEAN      NOT NULL DEFAULT TRUE,
    note             VARCHAR(300),
    created_by       UUID         REFERENCES profiles (id),
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    UNIQUE (day, kind, name)
);
CREATE INDEX ix_calendar_days_day ON calendar_days (day);

INSERT INTO calendar_days (day, kind, name)
SELECT make_date(y, m, d), 'HOLIDAY', n
FROM generate_series(2026, 2028) AS y
CROSS JOIN (VALUES (1, 1, 'Año Nuevo'), (5, 1, 'Día del Trabajo'), (6, 29, 'San Pedro y San Pablo'),
                   (7, 23, 'Día de la Fuerza Aérea'), (7, 28, 'Fiestas Patrias'), (7, 29, 'Fiestas Patrias'),
                   (8, 6, 'Batalla de Junín'), (8, 30, 'Santa Rosa de Lima'), (10, 8, 'Combate de Angamos'),
                   (11, 1, 'Todos los Santos'), (12, 8, 'Inmaculada Concepción'), (12, 9, 'Batalla de Ayacucho'),
                   (12, 25, 'Navidad')) AS f(m, d, n);
-- Jueves y Viernes Santo (Pascua: 5 abr 2026, 28 mar 2027, 16 abr 2028).
INSERT INTO calendar_days (day, kind, name) VALUES
    (DATE '2026-04-02', 'HOLIDAY', 'Jueves Santo'), (DATE '2026-04-03', 'HOLIDAY', 'Viernes Santo'),
    (DATE '2027-03-25', 'HOLIDAY', 'Jueves Santo'), (DATE '2027-03-26', 'HOLIDAY', 'Viernes Santo'),
    (DATE '2028-04-13', 'HOLIDAY', 'Jueves Santo'), (DATE '2028-04-14', 'HOLIDAY', 'Viernes Santo');

ALTER TABLE calendar_days ENABLE ROW LEVEL SECURITY;
CREATE POLICY calendar_read ON calendar_days FOR SELECT TO logyx_app USING (true);
CREATE POLICY calendar_operator_write ON calendar_days FOR ALL TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');

-- =====================================================================
-- 2.12 Cobros sin pasarela
-- =====================================================================
-- Cobros de comisión que OnCargo recibe del transportista (transferencia o Yape/Plin a la cuenta de OnCargo). Los
-- registra el operador; el transportista ve los suyos. La PYME nunca ve la comisión (ADR-0010).
CREATE TABLE commission_collections (
    id                 UUID PRIMARY KEY,
    carrier_org_id     UUID          NOT NULL REFERENCES organizations (id),
    amount             NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    method             VARCHAR(12)   NOT NULL CHECK (method IN ('TRANSFER', 'DEPOSIT', 'YAPE', 'PLIN', 'CASH', 'OTHER')),
    operation_number   VARCHAR(40)   NOT NULL,
    paid_on            DATE          NOT NULL,
    note               VARCHAR(500),
    shipments_count    INT           NOT NULL CHECK (shipments_count > 0),
    recorded_by        UUID          NOT NULL REFERENCES profiles (id),
    recorded_by_org_id UUID          NOT NULL REFERENCES organizations (id),
    created_at         TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX ix_commission_collections_carrier ON commission_collections (carrier_org_id, created_at DESC);

ALTER TABLE commission_collections ENABLE ROW LEVEL SECURITY;
CREATE POLICY commission_collections_carrier_read ON commission_collections FOR SELECT TO logyx_app
    USING (carrier_org_id = app_org());
CREATE POLICY commission_collections_operator ON commission_collections FOR ALL TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');
REVOKE UPDATE, DELETE ON commission_collections FROM logyx_app;

-- Una fila por envío entregado. La crea el primer paso del cobro (bajo RLS de la parte que actúa) o el barrido diario
-- (sistema). Mientras no exista, el envío entregado se muestra como PENDING_INVOICE con vencimiento = entrega + plazo.
CREATE TABLE shipment_settlements (
    shipment_id              UUID PRIMARY KEY REFERENCES shipments (id),
    requester_org_id         UUID          NOT NULL REFERENCES organizations (id),
    carrier_org_id           UUID          NOT NULL REFERENCES organizations (id),
    status                   VARCHAR(16)   NOT NULL DEFAULT 'PENDING_INVOICE'
                             CHECK (status IN ('PENDING_INVOICE', 'INVOICED', 'PAID', 'CONFIRMED', 'DISPUTED')),
    -- Plazo de pago: entrega + organization_preferences.payment_terms_days de la PYME (o el de la configuración).
    due_on                   DATE          NOT NULL,
    -- Comprobante que emite el transportista (su factura o boleta; la electrónica SUNAT es Ola 3).
    invoice_number           VARCHAR(40),
    invoice_issued_on        DATE,
    invoice_document_id      UUID          REFERENCES documents (id),
    invoiced_amount          NUMERIC(12,2) CHECK (invoiced_amount > 0),
    invoiced_at              TIMESTAMPTZ,
    invoiced_by              UUID          REFERENCES profiles (id),
    -- Pago de la PYME fuera de la plataforma.
    payment_method           VARCHAR(12)   CHECK (payment_method IN ('TRANSFER', 'DEPOSIT', 'YAPE', 'PLIN', 'CASH', 'OTHER')),
    payment_operation        VARCHAR(40),
    paid_on                  DATE,
    paid_amount              NUMERIC(12,2) CHECK (paid_amount > 0),
    payment_document_id      UUID          REFERENCES documents (id),
    paid_at                  TIMESTAMPTZ,
    paid_by                  UUID          REFERENCES profiles (id),
    confirmed_at             TIMESTAMPTZ,
    confirmed_by             UUID          REFERENCES profiles (id),
    disputed_at              TIMESTAMPTZ,
    disputed_by_org_id       UUID          REFERENCES organizations (id),
    dispute_reason           VARCHAR(500),
    status_before_dispute    VARCHAR(16),
    -- Comisión de OnCargo (solo transportista y operador la leen en la API; aquí la fila es de las dos partes, por eso
    -- el monto no se guarda: se calcula con la tasa del envío y su precio final).
    commission_status        VARCHAR(16)   NOT NULL DEFAULT 'PENDING'
                             CHECK (commission_status IN ('PENDING', 'COLLECTED', 'NOT_APPLICABLE')),
    commission_collection_id UUID          REFERENCES commission_collections (id),
    created_at               TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at               TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CHECK (status <> 'DISPUTED' OR (dispute_reason IS NOT NULL AND status_before_dispute IS NOT NULL)),
    CHECK (commission_status <> 'COLLECTED' OR commission_collection_id IS NOT NULL)
);
CREATE INDEX ix_settlements_requester ON shipment_settlements (requester_org_id, status, due_on);
CREATE INDEX ix_settlements_carrier ON shipment_settlements (carrier_org_id, status, due_on);
CREATE INDEX ix_settlements_commission ON shipment_settlements (carrier_org_id) WHERE commission_status = 'PENDING';

ALTER TABLE shipment_settlements ENABLE ROW LEVEL SECURITY;
CREATE POLICY settlements_parties_read ON shipment_settlements FOR SELECT TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY settlements_parties_insert ON shipment_settlements FOR INSERT TO logyx_app
    WITH CHECK (app_org() IN (requester_org_id, carrier_org_id)
                AND EXISTS (SELECT 1 FROM shipments s
                            WHERE s.id = shipment_settlements.shipment_id AND s.status = 'DELIVERED'
                              AND s.requester_org_id = shipment_settlements.requester_org_id
                              AND s.carrier_org_id = shipment_settlements.carrier_org_id));
CREATE POLICY settlements_parties_update ON shipment_settlements FOR UPDATE TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id))
    WITH CHECK (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY settlements_operator ON shipment_settlements FOR ALL TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');
-- Un conductor no ve cobros.
CREATE POLICY settlements_no_driver ON shipment_settlements AS RESTRICTIVE FOR ALL TO logyx_app
    USING ((SELECT app_driver_id()) IS NULL) WITH CHECK ((SELECT app_driver_id()) IS NULL);
REVOKE DELETE ON shipment_settlements FROM logyx_app;

-- Las partes no tocan la comisión ni las partes del envío (lo demás lo ordena la aplicación por estado y lado).
CREATE OR REPLACE FUNCTION shipment_settlements_guard() RETURNS trigger
    LANGUAGE plpgsql AS
$$
BEGIN
    IF current_user = 'logyx_app' AND coalesce(app_org_type(), '') <> 'OPERATOR'
       AND (NEW.commission_status IS DISTINCT FROM OLD.commission_status
            OR NEW.commission_collection_id IS DISTINCT FROM OLD.commission_collection_id
            OR NEW.requester_org_id IS DISTINCT FROM OLD.requester_org_id
            OR NEW.carrier_org_id IS DISTINCT FROM OLD.carrier_org_id
            OR NEW.shipment_id IS DISTINCT FROM OLD.shipment_id) THEN
        RAISE EXCEPTION 'solo el operador registra el cobro de la comisión'
            USING ERRCODE = 'insufficient_privilege';
    END IF;
    RETURN NEW;
END
$$;
CREATE TRIGGER trg_shipment_settlements_guard BEFORE UPDATE ON shipment_settlements
    FOR EACH ROW EXECUTE FUNCTION shipment_settlements_guard();

-- Pasos del cobro (lo que ven las dos partes). La comisión no se registra aquí.
CREATE TABLE settlement_history (
    id                BIGSERIAL PRIMARY KEY,
    shipment_id       UUID         NOT NULL REFERENCES shipment_settlements (shipment_id),
    requester_org_id  UUID         NOT NULL REFERENCES organizations (id),
    carrier_org_id    UUID         NOT NULL REFERENCES organizations (id),
    from_status       VARCHAR(16),
    to_status         VARCHAR(16)  NOT NULL,
    actor_profile_id  UUID         REFERENCES profiles (id),
    actor_org_id      UUID         REFERENCES organizations (id),
    note              VARCHAR(500),
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX ix_settlement_history_shipment ON settlement_history (shipment_id, created_at);

ALTER TABLE settlement_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY settlement_history_parties_read ON settlement_history FOR SELECT TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY settlement_history_parties_insert ON settlement_history FOR INSERT TO logyx_app
    WITH CHECK (actor_org_id = app_org() AND app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY settlement_history_operator ON settlement_history FOR ALL TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR' AND actor_org_id = app_org());
CREATE POLICY settlement_history_no_driver ON settlement_history AS RESTRICTIVE FOR ALL TO logyx_app
    USING ((SELECT app_driver_id()) IS NULL) WITH CHECK ((SELECT app_driver_id()) IS NULL);
REVOKE UPDATE, DELETE ON settlement_history FROM logyx_app;

-- Recordatorios ya enviados (idempotencia del barrido diario). Solo sistema.
CREATE TABLE settlement_notices (
    shipment_id  UUID        NOT NULL REFERENCES shipments (id),
    kind         VARCHAR(16) NOT NULL CHECK (kind IN ('DUE_SOON', 'DUE_TODAY', 'OVERDUE')),
    sent_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (shipment_id, kind)
);
ALTER TABLE settlement_notices ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON settlement_notices FROM logyx_app;

-- Datos de cobro del transportista (banco + CCI, Yape o Plin). El número va cifrado por la aplicación (AES-GCM,
-- logyx.settlement.payout-key); la BD solo ve bytes y los 4 últimos dígitos.
CREATE TABLE carrier_payout_accounts (
    id               UUID PRIMARY KEY,
    carrier_org_id   UUID          NOT NULL REFERENCES organizations (id),
    kind             VARCHAR(8)    NOT NULL CHECK (kind IN ('BANK', 'YAPE', 'PLIN')),
    bank_name        VARCHAR(60),
    holder_name      VARCHAR(150)  NOT NULL,
    number_enc       BYTEA         NOT NULL,
    number_last4     VARCHAR(4)    NOT NULL,
    is_primary       BOOLEAN       NOT NULL DEFAULT FALSE,
    archived_at      TIMESTAMPTZ,
    created_by       UUID          REFERENCES profiles (id),
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CHECK (kind <> 'BANK' OR bank_name IS NOT NULL)
);
CREATE INDEX ix_payout_accounts_carrier ON carrier_payout_accounts (carrier_org_id) WHERE archived_at IS NULL;

ALTER TABLE carrier_payout_accounts ENABLE ROW LEVEL SECURITY;
CREATE POLICY payout_carrier_own ON carrier_payout_accounts FOR ALL TO logyx_app
    USING (carrier_org_id = app_org() AND app_org_type() = 'CARRIER')
    WITH CHECK (carrier_org_id = app_org() AND app_org_type() = 'CARRIER');
-- La PYME solo los ve si tiene un envío (no cancelado) con ese transportista.
CREATE POLICY payout_pyme_read ON carrier_payout_accounts FOR SELECT TO logyx_app
    USING (archived_at IS NULL AND EXISTS (SELECT 1 FROM shipments s
                   WHERE s.carrier_org_id = carrier_payout_accounts.carrier_org_id
                     AND s.requester_org_id = app_org() AND s.status <> 'CANCELLED'));
CREATE POLICY payout_operator_read ON carrier_payout_accounts FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
CREATE POLICY payout_no_driver ON carrier_payout_accounts AS RESTRICTIVE FOR ALL TO logyx_app
    USING ((SELECT app_driver_id()) IS NULL) WITH CHECK ((SELECT app_driver_id()) IS NULL);
REVOKE DELETE ON carrier_payout_accounts FROM logyx_app;

-- =====================================================================
-- 2.2 Preferencias de la persona y correo
-- =====================================================================
CREATE TABLE user_preferences (
    profile_id       UUID        PRIMARY KEY REFERENCES profiles (id) ON DELETE CASCADE,
    org_id           UUID        NOT NULL REFERENCES organizations (id),
    -- false = ningún correo de avisos (lo apaga la persona o el enlace de baja sin login).
    email_enabled    BOOLEAN     NOT NULL DEFAULT TRUE,
    -- IMMEDIATE = cada aviso por correo al momento; DAILY = un resumen al día a digest_hour (hora de Lima).
    email_mode       VARCHAR(12) NOT NULL DEFAULT 'IMMEDIATE' CHECK (email_mode IN ('IMMEDIATE', 'DAILY')),
    digest_hour      SMALLINT    NOT NULL DEFAULT 7 CHECK (digest_hour BETWEEN 0 AND 23),
    -- Horario de silencio (hora de Lima; puede cruzar la medianoche). Los correos se guardan hasta quiet_to.
    quiet_from       TIME,
    quiet_to         TIME,
    unsubscribed_at  TIMESTAMPTZ,
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK ((quiet_from IS NULL) = (quiet_to IS NULL)),
    CHECK (quiet_from IS NULL OR quiet_from <> quiet_to)
);
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_preferences_own ON user_preferences FOR ALL TO logyx_app
    USING (profile_id = app_profile() AND org_id = app_org())
    WITH CHECK (profile_id = app_profile() AND org_id = app_org());
REVOKE DELETE ON user_preferences FROM logyx_app;

-- Correos de aviso diferidos (silencio o resumen). Solo sistema: el destinatario se resuelve al enviar.
CREATE TABLE notification_email_queue (
    id           UUID PRIMARY KEY,
    profile_id   UUID          NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
    org_id       UUID          NOT NULL REFERENCES organizations (id),
    category     VARCHAR(24)   NOT NULL,
    title        VARCHAR(200)  NOT NULL,
    body         VARCHAR(1000) NOT NULL,
    reason       VARCHAR(8)    NOT NULL CHECK (reason IN ('QUIET', 'DIGEST')),
    send_after   TIMESTAMPTZ   NOT NULL,
    sent_at      TIMESTAMPTZ,
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX ix_email_queue_due ON notification_email_queue (send_after) WHERE sent_at IS NULL;
CREATE INDEX ix_email_queue_profile ON notification_email_queue (profile_id) WHERE sent_at IS NULL;
ALTER TABLE notification_email_queue ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON notification_email_queue FROM logyx_app;

-- =====================================================================
-- 2.2 Preferencias de la organización
-- =====================================================================
CREATE TABLE organization_preferences (
    organization_id      UUID          PRIMARY KEY REFERENCES organizations (id),
    -- Ciudades del catálogo y rutas de interés ([{"origin":"LIMA","destination":"JULIACA"}]) y tipos de carga.
    cities               TEXT[]        NOT NULL DEFAULT '{}',
    routes               JSONB         NOT NULL DEFAULT '[]',
    cargo_types          TEXT[]        NOT NULL DEFAULT '{}',
    -- Transportista: alertas implícitas por sus rutas de interés y precio mínimo por km que le interesa.
    route_alerts         BOOLEAN       NOT NULL DEFAULT TRUE,
    min_price_per_km     NUMERIC(8,2)  CHECK (min_price_per_km > 0),
    -- PYME: horario de recojo por defecto y plazo de pago a sus transportistas (2.12).
    default_pickup_from  TIME,
    default_pickup_to    TIME,
    payment_terms_days   SMALLINT      CHECK (payment_terms_days BETWEEN 0 AND 120),
    updated_by           UUID          REFERENCES profiles (id),
    updated_at           TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CHECK ((default_pickup_from IS NULL) = (default_pickup_to IS NULL)),
    CHECK (default_pickup_from IS NULL OR default_pickup_from < default_pickup_to)
);
ALTER TABLE organization_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY org_preferences_own ON organization_preferences FOR ALL TO logyx_app
    USING (organization_id = app_org()) WITH CHECK (organization_id = app_org());
CREATE POLICY org_preferences_operator_read ON organization_preferences FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
REVOKE DELETE ON organization_preferences FROM logyx_app;

-- Alertas implícitas ya enviadas (una por organización y carga; también limita por hora). Solo sistema.
CREATE TABLE org_route_alerts (
    organization_id  UUID        NOT NULL REFERENCES organizations (id),
    request_id       UUID        NOT NULL REFERENCES shipment_requests (id),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (organization_id, request_id)
);
CREATE INDEX ix_org_route_alerts_recent ON org_route_alerts (organization_id, created_at DESC);
ALTER TABLE org_route_alerts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON org_route_alerts FROM logyx_app;

-- =====================================================================
-- 2.17 Términos: la persona acepta la versión nueva o la de su invitación
-- =====================================================================
CREATE POLICY terms_own_insert ON terms_acceptances FOR INSERT TO logyx_app
    WITH CHECK (profile_id = app_profile() AND organization_id = app_org() AND source = 'UPDATE');
GRANT INSERT ON terms_acceptances TO logyx_app;

DROP FUNCTION pg_temp.f24_add_check_values(regclass, text, text, text[]);
