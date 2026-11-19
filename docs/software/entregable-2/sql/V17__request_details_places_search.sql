-- =====================================================================
-- V17 — Zona A del roadmap v2 (Ola 1): solicitudes de la PYME.
--  * shipment_requests: código legible (OC-XXXXX, único, con respaldo para las existentes), referencia propia de la
--    PYME, valor declarado (decisión legal: opcional), y contacto / ventana horaria / instrucciones de recojo y entrega.
--    Estos datos son privados: solo los ve la PYME dueña, el operador y, tras adjudicar, el transportista adjudicado
--    (lo hace cumplir la aplicación; no hay política nueva porque viajan en filas ya protegidas).
--  * saved_places: libreta de direcciones y almacenes frecuentes por organización (RLS, sin DELETE: se archiva).
--  * idempotency_keys: clave de idempotencia de las escrituras (hoy POST /shipment-requests), 24 h por organización.
--  * Índices de búsqueda por código y referencia.
-- Aditiva: no quita ni renombra nada.
-- =====================================================================

-- ---------- shipment_requests ----------
ALTER TABLE shipment_requests ADD COLUMN code                    VARCHAR(12);
ALTER TABLE shipment_requests ADD COLUMN customer_reference      VARCHAR(40);
ALTER TABLE shipment_requests ADD COLUMN declared_value          NUMERIC(14,2) CHECK (declared_value > 0);
ALTER TABLE shipment_requests ADD COLUMN pickup_contact_name     VARCHAR(120);
ALTER TABLE shipment_requests ADD COLUMN pickup_contact_phone    VARCHAR(20);
ALTER TABLE shipment_requests ADD COLUMN pickup_window_from      TIME;
ALTER TABLE shipment_requests ADD COLUMN pickup_window_to        TIME;
ALTER TABLE shipment_requests ADD COLUMN pickup_instructions     VARCHAR(300);
ALTER TABLE shipment_requests ADD COLUMN delivery_contact_name   VARCHAR(120);
ALTER TABLE shipment_requests ADD COLUMN delivery_contact_phone  VARCHAR(20);
ALTER TABLE shipment_requests ADD COLUMN delivery_window_from    TIME;
ALTER TABLE shipment_requests ADD COLUMN delivery_window_to      TIME;
ALTER TABLE shipment_requests ADD COLUMN delivery_instructions   VARCHAR(300);

-- Respaldo de las solicitudes existentes. Mismo alfabeto que el dominio (RequestCode): sin 0, 1, I, L, O ni U.
DO $$
DECLARE
    r        RECORD;
    c        TEXT;
    alphabet CONSTANT TEXT := '23456789ABCDEFGHJKMNPQRSTVWXYZ';
BEGIN
    FOR r IN SELECT id FROM shipment_requests WHERE code IS NULL ORDER BY created_at LOOP
        LOOP
            c := 'OC-' || (SELECT string_agg(substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1), '')
                           FROM generate_series(1, 5));
            EXIT WHEN NOT EXISTS (SELECT 1 FROM shipment_requests WHERE code = c);
        END LOOP;
        UPDATE shipment_requests SET code = c WHERE id = r.id;
    END LOOP;
END $$;

ALTER TABLE shipment_requests ALTER COLUMN code SET NOT NULL;
CREATE UNIQUE INDEX ux_requests_code ON shipment_requests (code);
-- Búsqueda por prefijo sin distinguir mayúsculas (Ctrl+K, filtro q).
CREATE INDEX ix_requests_code_lower ON shipment_requests (lower(code) text_pattern_ops);
CREATE INDEX ix_requests_reference_lower ON shipment_requests (requester_org_id, lower(customer_reference) text_pattern_ops)
    WHERE customer_reference IS NOT NULL;
-- "Ya publicaste una igual hoy": misma ruta, tipo y peso de la misma organización, las más recientes primero.
CREATE INDEX ix_requests_similar ON shipment_requests (requester_org_id, origin_city, destination_city, created_at DESC);

-- ---------- saved_places ----------
CREATE TABLE saved_places (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id  UUID         NOT NULL REFERENCES organizations (id),
    label            VARCHAR(80)  NOT NULL,
    city             VARCHAR(40)  NOT NULL,
    address          VARCHAR(200) NOT NULL,
    contact_name     VARCHAR(120),
    contact_phone    VARCHAR(20),
    -- Texto libre para mostrar ("Lun–Vie 8:00–17:00") y ventana por omisión para precargar la solicitud.
    opening_hours    VARCHAR(120),
    window_from      TIME,
    window_to        TIME,
    instructions     VARCHAR(300),
    kind             VARCHAR(16)  NOT NULL DEFAULT 'BOTH' CHECK (kind IN ('PICKUP', 'DELIVERY', 'BOTH')),
    archived_at      TIMESTAMPTZ,
    last_used_at     TIMESTAMPTZ,
    created_by       UUID         NOT NULL REFERENCES profiles (id),
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX ix_places_org ON saved_places (organization_id, archived_at, last_used_at DESC NULLS LAST, label);

ALTER TABLE saved_places ENABLE ROW LEVEL SECURITY;
CREATE POLICY places_select ON saved_places FOR SELECT TO logyx_app USING (organization_id = app_org());
CREATE POLICY places_insert ON saved_places FOR INSERT TO logyx_app WITH CHECK (organization_id = app_org());
CREATE POLICY places_update ON saved_places FOR UPDATE TO logyx_app
    USING (organization_id = app_org()) WITH CHECK (organization_id = app_org());
-- Sin política de DELETE: las direcciones se archivan.

-- ---------- idempotency_keys ----------
CREATE TABLE idempotency_keys (
    organization_id  UUID         NOT NULL REFERENCES organizations (id),
    scope            VARCHAR(40)  NOT NULL,
    key              VARCHAR(80)  NOT NULL,
    resource_id      UUID         NOT NULL,
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    PRIMARY KEY (organization_id, scope, key)
);
CREATE INDEX ix_idempotency_created ON idempotency_keys (created_at);

ALTER TABLE idempotency_keys ENABLE ROW LEVEL SECURITY;
CREATE POLICY idem_select ON idempotency_keys FOR SELECT TO logyx_app USING (organization_id = app_org());
CREATE POLICY idem_insert ON idempotency_keys FOR INSERT TO logyx_app WITH CHECK (organization_id = app_org());
-- Una clave vencida (> 24 h) se descarta para poder reutilizarla.
CREATE POLICY idem_delete ON idempotency_keys FOR DELETE TO logyx_app USING (organization_id = app_org());
