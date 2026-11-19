-- =====================================================================
-- V22 — Ola 2, zona T (oferta / transportista). Reservada para T (P usa V21, X usa V23; dev admite out-of-order).
--  * 2.3 saved_searches (búsquedas guardadas, privadas de cada persona) y saved_search_alerts (bitácora del límite por
--    hora y de la idempotencia del aviso; solo la usa el sistema).
--  * 2.4 fleet_documents (SOAT, revisión técnica, MTC… de vehículos; licencia y DNI de conductores) con vencimiento y
--    archivo; fleet_document_notices (qué avisos de 30/7/0 días ya se enviaron); vehicles.equipment y
--    vehicles.accepted_cargo_types (restringen la matriz RN02, nunca la amplían); drivers.license_category,
--    license_expires_at y dni; bids.soat_valid_until / inspection_valid_until (sellos que ve la PYME, copiados al ofertar
--    porque la flota es privada del transportista).
--  * 2.8 bids.improved_count / improved_at y bid_revisions (historial de mejoras, solo del transportista dueño);
--    lane_price_stats (mediana adjudicada por ruta y tipo, últimos 90 días, solo con k >= 5 y >= 3 transportistas).
--  * Notificaciones: tipos NEW_LOAD_MATCH, FLEET_DOCUMENT_EXPIRING y BID_IMPROVED; categorías ALERTS y FLEET; destinos
--    VEHICLE y DRIVER. Se AGREGAN a las listas de los CHECK existentes (leyéndolas de la BD) para no pisar lo que
--    agreguen las migraciones paralelas de P y X.
-- Solo agrega tablas, vistas y columnas con valor por omisión: no reescribe datos de negocio.
-- =====================================================================

-- ---------- Ayuda: agrega valores a un CHECK (col IN (...)) sin conocer los que otras migraciones ya sumaron ----------
-- Lee los literales vigentes de la definición (sea cual sea la forma en que PostgreSQL la vuelque tras otro ALTER),
-- suma los nuevos y vuelve a crear el CHECK con la forma simple (col IN (...)).
CREATE FUNCTION pg_temp.t22_add_check_values(tbl regclass, cname text, col text, vals text[]) RETURNS void
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
    FROM regexp_matches(def, '''([^'']+)''::character varying', 'g') WITH ORDINALITY AS t(m, ord);
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

SELECT pg_temp.t22_add_check_values('notifications', 'notifications_type_check', 'type',
                                    ARRAY['NEW_LOAD_MATCH', 'FLEET_DOCUMENT_EXPIRING', 'BID_IMPROVED']);
SELECT pg_temp.t22_add_check_values('notifications', 'notifications_related_type_check', 'related_type',
                                    ARRAY['VEHICLE', 'DRIVER']);
SELECT pg_temp.t22_add_check_values('notification_preferences', 'notification_preferences_category_check', 'category',
                                    ARRAY['ALERTS', 'FLEET']);
DROP FUNCTION pg_temp.t22_add_check_values(regclass, text, text, text[]);

-- ---------- 2.3 Búsquedas guardadas ----------
CREATE TABLE saved_searches (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id  UUID          NOT NULL REFERENCES organizations (id),
    profile_id       UUID          NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
    name             VARCHAR(80)   NOT NULL,
    origin_city      VARCHAR(40),
    destination_city VARCHAR(40),
    cargo_type       VARCHAR(16),
    pickup_from      DATE,
    pickup_to        DATE,
    max_weight_kg    NUMERIC(10,2) CHECK (max_weight_kg IS NULL OR max_weight_kg > 0),
    vehicle_id       UUID          REFERENCES vehicles (id) ON DELETE SET NULL,
    active           BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CHECK (pickup_from IS NULL OR pickup_to IS NULL OR pickup_from <= pickup_to)
);
CREATE INDEX ix_saved_searches_profile ON saved_searches (profile_id, created_at DESC);
-- El matching al publicar filtra por origen: se indexa solo lo que está activo.
CREATE INDEX ix_saved_searches_active_origin ON saved_searches (origin_city) WHERE active;

ALTER TABLE saved_searches ENABLE ROW LEVEL SECURITY;
-- Cada persona ve y edita solo las suyas (como las preferencias de aviso).
CREATE POLICY saved_searches_own ON saved_searches FOR ALL TO logyx_app
    USING (profile_id = app_profile() AND organization_id = app_org())
    WITH CHECK (profile_id = app_profile() AND organization_id = app_org());

-- Bitácora del aviso: una fila por (búsqueda, solicitud). Sirve de límite por hora y de idempotencia. Solo el sistema la
-- lee y escribe (SystemTx, dueño del esquema): RLS activa sin ninguna política para logyx_app.
CREATE TABLE saved_search_alerts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    search_id   UUID        NOT NULL REFERENCES saved_searches (id) ON DELETE CASCADE,
    request_id  UUID        NOT NULL REFERENCES shipment_requests (id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (search_id, request_id)
);
CREATE INDEX ix_saved_search_alerts_recent ON saved_search_alerts (search_id, created_at DESC);
ALTER TABLE saved_search_alerts ENABLE ROW LEVEL SECURITY;

-- ---------- 2.4 Documentos de flota ----------
ALTER TABLE vehicles ADD COLUMN equipment VARCHAR(200) NOT NULL DEFAULT '';
ALTER TABLE vehicles ADD COLUMN accepted_cargo_types VARCHAR(200) NOT NULL DEFAULT '';
ALTER TABLE drivers ADD COLUMN license_category VARCHAR(10);
ALTER TABLE drivers ADD COLUMN license_expires_at DATE;
ALTER TABLE drivers ADD COLUMN dni VARCHAR(12);

CREATE TABLE fleet_documents (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id  UUID         NOT NULL REFERENCES organizations (id),
    owner_type       VARCHAR(8)   NOT NULL CHECK (owner_type IN ('VEHICLE', 'DRIVER')),
    vehicle_id       UUID         REFERENCES vehicles (id),
    driver_id        UUID         REFERENCES drivers (id),
    doc_type         VARCHAR(24)  NOT NULL CHECK (doc_type IN ('SOAT', 'TECHNICAL_INSPECTION', 'PROPERTY_CARD',
                                                               'INSURANCE_POLICY', 'MTC_PERMIT', 'DRIVER_LICENSE', 'DNI')),
    number           VARCHAR(40),
    expires_at       DATE,
    file_name        VARCHAR(255) NOT NULL,
    content_type     VARCHAR(100) NOT NULL,
    file_size_bytes  BIGINT       NOT NULL CHECK (file_size_bytes > 0),
    sha256           VARCHAR(64)  NOT NULL,
    storage_key      VARCHAR(500) NOT NULL UNIQUE,
    uploaded_by      UUID         REFERENCES profiles (id) DEFAULT app_profile(),
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    -- Un documento nuevo del mismo tipo reemplaza al anterior: el viejo queda en el historial con esta marca.
    superseded_at    TIMESTAMPTZ,
    CHECK ((owner_type = 'VEHICLE' AND vehicle_id IS NOT NULL AND driver_id IS NULL)
        OR (owner_type = 'DRIVER' AND driver_id IS NOT NULL AND vehicle_id IS NULL))
);
CREATE INDEX ix_fleet_documents_vehicle ON fleet_documents (vehicle_id, doc_type, created_at DESC) WHERE vehicle_id IS NOT NULL;
CREATE INDEX ix_fleet_documents_driver ON fleet_documents (driver_id, doc_type, created_at DESC) WHERE driver_id IS NOT NULL;
CREATE INDEX ix_fleet_documents_expiry ON fleet_documents (expires_at) WHERE superseded_at IS NULL AND expires_at IS NOT NULL;

ALTER TABLE fleet_documents ENABLE ROW LEVEL SECURITY;
-- Privados del transportista (RLS del roadmap 2.4); la PYME solo ve los sellos derivados, copiados en la oferta.
CREATE POLICY fleet_documents_owner ON fleet_documents FOR ALL TO logyx_app
    USING (organization_id = app_org()) WITH CHECK (organization_id = app_org());
CREATE POLICY fleet_documents_operator ON fleet_documents FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
-- Inmutables salvo la marca de reemplazo (como la evidencia, V5).
REVOKE UPDATE, DELETE ON fleet_documents FROM logyx_app;
GRANT UPDATE (superseded_at) ON fleet_documents TO logyx_app;

-- Qué aviso de vencimiento ya salió (30 y 7 días antes, y el día en que vence). Solo el sistema.
CREATE TABLE fleet_document_notices (
    document_id  UUID        NOT NULL REFERENCES fleet_documents (id) ON DELETE CASCADE,
    threshold    INT         NOT NULL CHECK (threshold IN (30, 7, 0)),
    sent_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (document_id, threshold)
);
ALTER TABLE fleet_document_notices ENABLE ROW LEVEL SECURITY;

-- ---------- Sellos de la oferta (la PYME no lee la flota) y mejora de oferta (2.8) ----------
ALTER TABLE bids ADD COLUMN soat_valid_until DATE;
ALTER TABLE bids ADD COLUMN inspection_valid_until DATE;
ALTER TABLE bids ADD COLUMN improved_count INT NOT NULL DEFAULT 0;
ALTER TABLE bids ADD COLUMN improved_at TIMESTAMPTZ;

CREATE TABLE bid_revisions (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bid_id               UUID          NOT NULL REFERENCES bids (id) ON DELETE CASCADE,
    carrier_org_id       UUID          NOT NULL REFERENCES organizations (id),
    previous_amount      NUMERIC(12,2) NOT NULL,
    new_amount           NUMERIC(12,2) NOT NULL,
    previous_vehicle_id  UUID          NOT NULL REFERENCES vehicles (id),
    new_vehicle_id       UUID          NOT NULL REFERENCES vehicles (id),
    previous_plate       VARCHAR(10)   NOT NULL,
    new_plate            VARCHAR(10)   NOT NULL,
    created_by           UUID          REFERENCES profiles (id) DEFAULT app_profile(),
    created_at           TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX ix_bid_revisions_bid ON bid_revisions (bid_id, created_at);
ALTER TABLE bid_revisions ENABLE ROW LEVEL SECURITY;
-- El historial es del transportista que ofertó; la PYME solo ve la marca «mejorada» (bids.improved_count).
CREATE POLICY bid_revisions_carrier ON bid_revisions FOR ALL TO logyx_app
    USING (carrier_org_id = app_org()) WITH CHECK (carrier_org_id = app_org());
CREATE POLICY bid_revisions_operator ON bid_revisions FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
REVOKE UPDATE, DELETE ON bid_revisions FROM logyx_app;

-- ---------- 2.8 Historial de precios por ruta (agregado y anonimizado) ----------
-- Precio adjudicado (con IGV, como las ofertas) de los envíos de los últimos 90 días por ruta y tipo de carga.
-- La vista corre con los privilegios de su dueño (lee todas las organizaciones) y por eso SOLO expone agregados de
-- grupos con al menos 5 envíos de al menos 3 transportistas distintos: nunca un monto individual. Los valores se
-- redondean a S/ 5. Es una vista simple (siempre al día); si el volumen lo pide, pasa a materializada con un job.
CREATE VIEW lane_price_stats AS
SELECT r.origin_city,
       r.destination_city,
       r.cargo_type,
       count(*)::int                                                                        AS samples,
       count(DISTINCT s.carrier_org_id)::int                                                AS carriers,
       (round(percentile_cont(0.5)  WITHIN GROUP (ORDER BY s.agreed_price)::numeric / 5) * 5)::numeric(12,2) AS median_price,
       (round(percentile_cont(0.25) WITHIN GROUP (ORDER BY s.agreed_price)::numeric / 5) * 5)::numeric(12,2) AS low_price,
       (round(percentile_cont(0.75) WITHIN GROUP (ORDER BY s.agreed_price)::numeric / 5) * 5)::numeric(12,2) AS high_price
FROM shipments s
JOIN shipment_requests r ON r.id = s.request_id
WHERE s.status <> 'CANCELLED' AND s.created_at >= now() - interval '90 days'
GROUP BY r.origin_city, r.destination_city, r.cargo_type
HAVING count(*) >= 5 AND count(DISTINCT s.carrier_org_id) >= 3;
GRANT SELECT ON lane_price_stats TO logyx_app;
