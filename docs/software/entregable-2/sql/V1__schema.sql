-- =====================================================================
-- LOGYX — Esquema base (MVP)
-- Modelo de aislamiento: una sola BD / un solo schema, datos "org-scoped".
-- Ver docs/adr/0001-aislamiento-por-organizacion.md
-- Los enums se guardan como VARCHAR + CHECK (no ENUM nativo) para que
-- agregar un valor sea una migración trivial y Hibernate los mapee directo.
-- =====================================================================

-- ---------- Organizaciones y usuarios ----------
CREATE TABLE organizations (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type               VARCHAR(16)  NOT NULL CHECK (type IN ('PYME', 'CARRIER', 'OPERATOR')),
    legal_name         VARCHAR(200) NOT NULL,
    ruc                CHAR(11)     NOT NULL UNIQUE,
    ruc_verification   VARCHAR(16)  NOT NULL DEFAULT 'NONE'
                       CHECK (ruc_verification IN ('NONE', 'CHECKSUM', 'SUNAT')),
    city               VARCHAR(80),
    phone              VARCHAR(20),
    created_at         TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE profiles (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id      UUID         NOT NULL REFERENCES organizations (id),
    email                VARCHAR(254) NOT NULL,
    password_hash        VARCHAR(100) NOT NULL,
    full_name            VARCHAR(150) NOT NULL,
    role                 VARCHAR(16)  NOT NULL CHECK (role IN ('ADMIN', 'OPS', 'VIEWER', 'DRIVER')),
    active               BOOLEAN      NOT NULL DEFAULT TRUE,
    -- Ley N° 29733, Art. 13 (RNF18): sin consentimiento no hay cuenta
    consent_accepted_at  TIMESTAMPTZ  NOT NULL,
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX ux_profiles_email ON profiles (lower(email));
CREATE INDEX ix_profiles_org ON profiles (organization_id);

-- ---------- Flota ----------
CREATE TABLE vehicles (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id  UUID          NOT NULL REFERENCES organizations (id),
    plate            VARCHAR(10)   NOT NULL UNIQUE,
    type             VARCHAR(16)   NOT NULL CHECK (type IN ('VAN', 'TRUCK_SMALL', 'TRUCK_MEDIUM', 'TRUCK_LARGE',
                                                            'PLATFORM', 'REFRIGERATED', 'TANKER')),
    max_weight_kg    NUMERIC(10,2) NOT NULL CHECK (max_weight_kg > 0),
    max_volume_m3    NUMERIC(8,2)  CHECK (max_volume_m3 > 0),
    status           VARCHAR(16)   NOT NULL DEFAULT 'AVAILABLE'
                     CHECK (status IN ('AVAILABLE', 'IN_ROUTE', 'MAINTENANCE')),
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX ix_vehicles_org ON vehicles (organization_id);

CREATE TABLE drivers (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id  UUID        NOT NULL REFERENCES organizations (id),
    profile_id       UUID        NOT NULL UNIQUE REFERENCES profiles (id),
    license_number   VARCHAR(20) NOT NULL,
    status           VARCHAR(16) NOT NULL DEFAULT 'AVAILABLE'
                     CHECK (status IN ('AVAILABLE', 'ON_DUTY', 'OFF_DUTY')),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_drivers_org ON drivers (organization_id);

-- ---------- Marketplace ----------
CREATE TABLE shipment_requests (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_org_id        UUID          NOT NULL REFERENCES organizations (id),
    created_by              UUID          NOT NULL REFERENCES profiles (id),
    origin_city             VARCHAR(40)   NOT NULL,
    origin_address          VARCHAR(200)  NOT NULL,
    destination_city        VARCHAR(40)   NOT NULL,
    destination_address     VARCHAR(200)  NOT NULL,
    cargo_type              VARCHAR(16)   NOT NULL CHECK (cargo_type IN ('GENERAL', 'FRAGILE', 'PERISHABLE',
                                                                         'HAZARDOUS', 'BULK', 'OVERSIZED')),
    cargo_description       VARCHAR(300)  NOT NULL,
    weight_kg               NUMERIC(10,2) NOT NULL CHECK (weight_kg > 0),
    volume_m3               NUMERIC(8,2)  CHECK (volume_m3 > 0),
    pickup_date             DATE          NOT NULL,
    distance_km             NUMERIC(8,2)  NOT NULL,
    suggested_price         NUMERIC(12,2) NOT NULL,
    price_floor             NUMERIC(12,2) NOT NULL,
    status                  VARCHAR(16)   NOT NULL DEFAULT 'PUBLISHED'
                            CHECK (status IN ('PUBLISHED', 'MATCHED', 'CANCELLED')),
    -- Denormalizado a propósito: permite a RLS decidir visibilidad sin
    -- consultar otra tabla protegida (evita recursión entre políticas).
    assigned_carrier_org_id UUID          REFERENCES organizations (id),
    created_at              TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CHECK (origin_city <> destination_city),
    CHECK (price_floor <= suggested_price)
);
CREATE INDEX ix_requests_requester ON shipment_requests (requester_org_id, created_at DESC);
CREATE INDEX ix_requests_status ON shipment_requests (status, pickup_date);

CREATE TABLE auctions (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id    UUID        NOT NULL UNIQUE REFERENCES shipment_requests (id),
    opens_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    closes_at     TIMESTAMPTZ NOT NULL,
    max_bids      INT         NOT NULL DEFAULT 5,
    status        VARCHAR(16) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'CLOSED', 'CANCELLED')),
    close_reason  VARCHAR(16) CHECK (close_reason IN ('TIMEOUT', 'MAX_BIDS', 'ACCEPTED', 'CANCELLED')),
    closed_at     TIMESTAMPTZ
);
CREATE INDEX ix_auctions_open ON auctions (closes_at) WHERE status = 'OPEN';

CREATE TABLE bids (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auction_id        UUID          NOT NULL REFERENCES auctions (id),
    request_id        UUID          NOT NULL REFERENCES shipment_requests (id),
    requester_org_id  UUID          NOT NULL REFERENCES organizations (id),
    carrier_org_id    UUID          NOT NULL REFERENCES organizations (id),
    vehicle_id        UUID          NOT NULL REFERENCES vehicles (id),
    amount            NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    notes             VARCHAR(300),
    status            VARCHAR(16)   NOT NULL DEFAULT 'PENDING'
                      CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED')),
    created_at        TIMESTAMPTZ   NOT NULL DEFAULT now(),
    UNIQUE (auction_id, carrier_org_id)
);
CREATE INDEX ix_bids_request ON bids (request_id, amount);
CREATE INDEX ix_bids_carrier ON bids (carrier_org_id, created_at DESC);

-- ---------- Ejecución ----------
CREATE TABLE shipments (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id        UUID          NOT NULL UNIQUE REFERENCES shipment_requests (id),
    bid_id            UUID          NOT NULL UNIQUE REFERENCES bids (id),
    requester_org_id  UUID          NOT NULL REFERENCES organizations (id),
    carrier_org_id    UUID          NOT NULL REFERENCES organizations (id),
    vehicle_id        UUID          NOT NULL REFERENCES vehicles (id),
    driver_id         UUID          REFERENCES drivers (id),
    agreed_price      NUMERIC(12,2) NOT NULL,
    -- Copias para que la PYME vea placa y conductor sin leer la flota privada
    vehicle_plate     VARCHAR(10)   NOT NULL,
    driver_name       VARCHAR(150),
    status            VARCHAR(16)   NOT NULL DEFAULT 'PENDING'
                      CHECK (status IN ('PENDING', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED')),
    created_at        TIMESTAMPTZ   NOT NULL DEFAULT now(),
    delivered_at      TIMESTAMPTZ
);
CREATE INDEX ix_shipments_requester ON shipments (requester_org_id, created_at DESC);
CREATE INDEX ix_shipments_carrier ON shipments (carrier_org_id, created_at DESC);
CREATE INDEX ix_shipments_driver ON shipments (driver_id) WHERE driver_id IS NOT NULL;

CREATE TABLE shipment_stops (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id       UUID         NOT NULL REFERENCES shipments (id),
    requester_org_id  UUID         NOT NULL REFERENCES organizations (id),
    carrier_org_id    UUID         NOT NULL REFERENCES organizations (id),
    sequence          INT          NOT NULL CHECK (sequence > 0),
    type              VARCHAR(16)  NOT NULL CHECK (type IN ('PICKUP', 'DELIVERY')),
    city              VARCHAR(40)  NOT NULL,
    address           VARCHAR(200) NOT NULL,
    status            VARCHAR(16)  NOT NULL DEFAULT 'PENDING'
                      CHECK (status IN ('PENDING', 'ARRIVED', 'COMPLETED')),
    arrived_at        TIMESTAMPTZ,
    completed_at      TIMESTAMPTZ,
    UNIQUE (shipment_id, sequence)
);

-- ---------- Auditoría (Ley N° 29733, Reglamento Art. 39) ----------
CREATE TABLE audit_log (
    id               BIGSERIAL PRIMARY KEY,
    occurred_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    actor_profile_id UUID,
    organization_id  UUID,
    action           VARCHAR(60)  NOT NULL,
    entity           VARCHAR(60)  NOT NULL,
    entity_id        UUID,
    detail           VARCHAR(500)
);
CREATE INDEX ix_audit_entity ON audit_log (entity, entity_id);
