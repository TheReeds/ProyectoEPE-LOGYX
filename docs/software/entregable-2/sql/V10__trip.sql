-- =====================================================================
-- V10 — Fase 4: viajes publicados (supply-side, RN12), reservas de espacio,
-- sugerencias del Smart Load Planner (OE07) y avisos nuevos.
--
-- Decisiones frente al modelo de datos del entregable 2:
--  * carrier_trips usa ciudades del corredor (origin_city/destination_city) en lugar de dirección + lat/lng, y una
--    tarifa (pricing_mode + rate) en lugar de solo price_per_kg. confirmed_weight_kg está denormalizado para que la
--    PYME vea la capacidad restante sin leer reservas ajenas (RLS) y sin SystemTx.
--  * trip_bookings.request_id/shipment_id son NULL hasta que el transportista confirma: al confirmar se crea la
--    solicitud adjudicada + el envío (ver marketplace DirectContractUseCase).
--  * smart_load_suggestions guarda los ítems en una tabla hija (en lugar de uuid[] + jsonb) y el plan de ruta se
--    deriva de los ítems (pickup_order/delivery_order).
-- =====================================================================

CREATE TABLE carrier_trips (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    carrier_org_id      UUID          NOT NULL REFERENCES organizations (id),
    vehicle_id          UUID          NOT NULL REFERENCES vehicles (id),
    -- Copias: la flota es privada del transportista (vehicles_owner); la PYME ve tipo y placa del viaje.
    vehicle_type        VARCHAR(16)   NOT NULL,
    vehicle_plate       VARCHAR(10)   NOT NULL,
    origin_city         VARCHAR(40)   NOT NULL,
    destination_city    VARCHAR(40)   NOT NULL,
    departure_at        TIMESTAMPTZ   NOT NULL,
    capacity_kg         NUMERIC(10,2) NOT NULL CHECK (capacity_kg > 0),
    confirmed_weight_kg NUMERIC(10,2) NOT NULL DEFAULT 0,
    pricing_mode        VARCHAR(16)   NOT NULL CHECK (pricing_mode IN ('PER_KG', 'PER_TRIP')),
    rate                NUMERIC(12,2) NOT NULL CHECK (rate > 0),
    notes               VARCHAR(300),
    status              VARCHAR(16)   NOT NULL DEFAULT 'OPEN'
                        CHECK (status IN ('OPEN', 'FILLING', 'CLOSED', 'COMPLETED', 'CANCELLED')),
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CHECK (origin_city <> destination_city),
    CHECK (confirmed_weight_kg >= 0 AND confirmed_weight_kg <= capacity_kg)
);
CREATE INDEX ix_trips_carrier ON carrier_trips (carrier_org_id, departure_at DESC);
CREATE INDEX ix_trips_open ON carrier_trips (departure_at) WHERE status IN ('OPEN', 'FILLING');

CREATE TABLE trip_bookings (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id           UUID          NOT NULL REFERENCES carrier_trips (id),
    -- Denormalizados para RLS y para listar sin leer el viaje (que la PYME solo ve si está abierto o lo reservó).
    requester_org_id  UUID          NOT NULL REFERENCES organizations (id),
    carrier_org_id    UUID          NOT NULL REFERENCES organizations (id),
    requested_by      UUID          NOT NULL REFERENCES profiles (id),
    origin_city       VARCHAR(40)   NOT NULL,
    destination_city  VARCHAR(40)   NOT NULL,
    departure_at      TIMESTAMPTZ   NOT NULL,
    weight_kg         NUMERIC(10,2) NOT NULL CHECK (weight_kg > 0),
    cargo_type        VARCHAR(16)   NOT NULL CHECK (cargo_type IN ('GENERAL', 'FRAGILE', 'PERISHABLE',
                                                                   'HAZARDOUS', 'BULK', 'OVERSIZED')),
    cargo_description VARCHAR(300)  NOT NULL,
    pickup_address    VARCHAR(200)  NOT NULL,
    delivery_address  VARCHAR(200)  NOT NULL,
    price             NUMERIC(12,2) NOT NULL CHECK (price > 0),
    status            VARCHAR(16)   NOT NULL DEFAULT 'PENDING'
                      CHECK (status IN ('PENDING', 'CONFIRMED', 'REJECTED', 'CANCELLED')),
    decision_note     VARCHAR(300),
    request_id        UUID          REFERENCES shipment_requests (id),
    shipment_id       UUID          REFERENCES shipments (id),
    created_at        TIMESTAMPTZ   NOT NULL DEFAULT now(),
    decided_at        TIMESTAMPTZ
);
CREATE INDEX ix_bookings_trip ON trip_bookings (trip_id, created_at);
CREATE INDEX ix_bookings_requester ON trip_bookings (requester_org_id, created_at DESC);

CREATE TABLE smart_load_suggestions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    carrier_org_id  UUID          NOT NULL REFERENCES organizations (id),
    vehicle_id      UUID          NOT NULL REFERENCES vehicles (id),
    vehicle_type    VARCHAR(16)   NOT NULL,
    vehicle_plate   VARCHAR(10)   NOT NULL,
    capacity_kg     NUMERIC(10,2) NOT NULL,
    total_weight_kg NUMERIC(10,2) NOT NULL,
    combined_income NUMERIC(12,2) NOT NULL,
    occupancy_pct   NUMERIC(5,2)  NOT NULL,
    status          VARCHAR(16)   NOT NULL DEFAULT 'PENDING'
                    CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED')),
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT now(),
    expires_at      TIMESTAMPTZ   NOT NULL,
    decided_at      TIMESTAMPTZ
);
CREATE INDEX ix_smart_carrier ON smart_load_suggestions (carrier_org_id, created_at DESC);

CREATE TABLE smart_load_items (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    suggestion_id    UUID          NOT NULL REFERENCES smart_load_suggestions (id),
    carrier_org_id   UUID          NOT NULL REFERENCES organizations (id),
    request_id       UUID          NOT NULL REFERENCES shipment_requests (id),
    requester_org_id UUID          NOT NULL REFERENCES organizations (id),
    origin_city      VARCHAR(40)   NOT NULL,
    destination_city VARCHAR(40)   NOT NULL,
    weight_kg        NUMERIC(10,2) NOT NULL,
    income           NUMERIC(12,2) NOT NULL,
    pickup_date      DATE          NOT NULL,
    pickup_order     INT           NOT NULL,
    delivery_order   INT           NOT NULL
);
CREATE INDEX ix_smart_items ON smart_load_items (suggestion_id);

-- Avisos nuevos (se amplían las listas permitidas de V8).
ALTER TABLE notifications DROP CONSTRAINT notifications_type_check;
ALTER TABLE notifications ADD CONSTRAINT notifications_type_check
    CHECK (type IN ('NEW_BID', 'BID_ACCEPTED', 'BID_REJECTED', 'COUNTER_OFFER', 'NEW_MESSAGE',
                    'SHIPMENT_STATUS_CHANGE', 'INCIDENT_REPORTED', 'INCIDENT_RESOLVED', 'NEW_REVIEW',
                    'TRIP_BOOKING_REQUESTED', 'TRIP_BOOKING_CONFIRMED', 'TRIP_BOOKING_REJECTED',
                    'TRIP_BOOKING_CANCELLED', 'TRIP_CANCELLED', 'SMART_LOAD_SUGGESTED', 'SMART_LOAD_ACCEPTED'));
ALTER TABLE notifications DROP CONSTRAINT notifications_related_type_check;
ALTER TABLE notifications ADD CONSTRAINT notifications_related_type_check
    CHECK (related_type IN ('REQUEST', 'BID', 'COUNTER_OFFER', 'SHIPMENT', 'INCIDENT', 'REVIEW', 'TRIP', 'SMART_LOAD'));

-- ---------- RLS ----------
ALTER TABLE carrier_trips ENABLE ROW LEVEL SECURITY;
CREATE POLICY trips_owner ON carrier_trips FOR ALL TO logyx_app
    USING (carrier_org_id = app_org())
    WITH CHECK (carrier_org_id = app_org() AND app_org_type() = 'CARRIER');
-- Listado público de viajes con espacio: lo ven las PYMEs (no otros transportistas).
CREATE POLICY trips_listing ON carrier_trips FOR SELECT TO logyx_app
    USING (app_org_type() = 'PYME' AND status IN ('OPEN', 'FILLING'));
-- La PYME que reservó sigue viendo el viaje aunque ya se haya cerrado (las políticas de trip_bookings solo usan
-- columnas denormalizadas, no hay recursión).
CREATE POLICY trips_booker ON carrier_trips FOR SELECT TO logyx_app
    USING (id IN (SELECT trip_id FROM trip_bookings WHERE requester_org_id = app_org()));
CREATE POLICY trips_operator ON carrier_trips FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');

ALTER TABLE trip_bookings ENABLE ROW LEVEL SECURITY;
CREATE POLICY bookings_parties_read ON trip_bookings FOR SELECT TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY bookings_requester_insert ON trip_bookings FOR INSERT TO logyx_app
    WITH CHECK (requester_org_id = app_org() AND app_org_type() = 'PYME');
CREATE POLICY bookings_parties_update ON trip_bookings FOR UPDATE TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id))
    WITH CHECK (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY bookings_operator ON trip_bookings FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
REVOKE DELETE ON trip_bookings FROM logyx_app;

ALTER TABLE smart_load_suggestions ENABLE ROW LEVEL SECURITY;
CREATE POLICY smart_owner ON smart_load_suggestions FOR ALL TO logyx_app
    USING (carrier_org_id = app_org())
    WITH CHECK (carrier_org_id = app_org() AND app_org_type() = 'CARRIER');
CREATE POLICY smart_operator ON smart_load_suggestions FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');   -- RF59

ALTER TABLE smart_load_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY smart_items_owner ON smart_load_items FOR ALL TO logyx_app
    USING (carrier_org_id = app_org())
    WITH CHECK (carrier_org_id = app_org());
CREATE POLICY smart_items_operator ON smart_load_items FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
