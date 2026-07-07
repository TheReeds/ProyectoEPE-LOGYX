# E2 — Scripts de Base de Datos
> Competencias CE0222 (DDL + DML) · CE0223 (Procedimientos, Funciones y Triggers)  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Motor: PostgreSQL 16  
> Versión: 1.0 · Junio 2026

---

## 1. Estructura de Scripts

Los scripts se organizan en archivos Flyway nombrados con el prefijo `V{n}__descripcion.sql`:

| Archivo | Contenido |
|---------|-----------|
| `V1__extensions.sql` | Habilitar extensiones PostgreSQL |
| `V2__enums.sql` | Tipos enumerados |
| `V3__ddl_core.sql` | Tablas principales (organizaciones, perfiles, vehículos) |
| `V4__ddl_operations.sql` | Tablas operacionales (solicitudes, subastas, envíos) |
| `V5__ddl_support.sql` | Tablas de soporte (documentos, notificaciones, auditoría) |
| `V6__indexes.sql` | Índices de rendimiento |
| `V7__functions.sql` | Funciones SQL |
| `V8__triggers.sql` | Triggers |
| `V9__seed.sql` | Datos iniciales (DML) |

---

## 2. CE0222 — DDL: Scripts de Creación de Estructura

### V1__extensions.sql

```sql
-- ============================================================
-- LOGYX · V1 · Extensiones
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";     -- Generación de UUIDs v4
CREATE EXTENSION IF NOT EXISTS "postgis";        -- Funciones geoespaciales
CREATE EXTENSION IF NOT EXISTS "pg_trgm";        -- Búsqueda de texto aproximado
```

---

### V2__enums.sql

```sql
-- ============================================================
-- LOGYX · V2 · Tipos Enumerados
-- ============================================================

CREATE TYPE org_type AS ENUM (
    'pyme', 'carrier', 'operator', 'admin'
);

CREATE TYPE profile_role AS ENUM (
    'admin', 'ops', 'viewer', 'driver'
);

CREATE TYPE vehicle_type AS ENUM (
    'truck_small', 'truck_medium', 'truck_large',
    'van', 'platform', 'refrigerated', 'tanker'
);

CREATE TYPE vehicle_status AS ENUM (
    'available', 'in_route', 'maintenance'
);

CREATE TYPE driver_status AS ENUM (
    'available', 'on_duty', 'off_duty'
);

CREATE TYPE cargo_type AS ENUM (
    'general', 'fragile', 'perishable',
    'hazardous', 'bulk', 'oversized'
);

CREATE TYPE request_status AS ENUM (
    'open', 'auction_open', 'matched',
    'in_transit', 'delivered', 'cancelled'
);

CREATE TYPE auction_status AS ENUM (
    'open', 'closed', 'cancelled'
);

CREATE TYPE bid_status AS ENUM (
    'pending', 'accepted', 'rejected', 'expired'
);

CREATE TYPE counter_offer_status AS ENUM (
    'pending', 'accepted', 'rejected', 'expired'
);

CREATE TYPE trip_status AS ENUM (
    'open', 'filling', 'closed', 'completed', 'cancelled'
);

CREATE TYPE booking_status AS ENUM (
    'confirmed', 'cancelled'
);

CREATE TYPE shipment_status AS ENUM (
    'pending', 'picked_up', 'in_transit',
    'delivered', 'issue', 'cancelled'
);

CREATE TYPE escrow_status AS ENUM (
    'held', 'released', 'disputed', 'refunded'
);

CREATE TYPE stop_status AS ENUM (
    'pending', 'in_route', 'arrived', 'delivered', 'issue'
);

CREATE TYPE document_type AS ENUM (
    'service_order', 'remission_guide', 'receipt',
    'delivery_photo', 'signature', 'other'
);

CREATE TYPE notification_type AS ENUM (
    'new_bid', 'bid_accepted', 'bid_rejected',
    'shipment_status_change', 'new_review', 'new_message',
    'counter_offer', 'incident_reported', 'incident_resolved',
    'smart_load_suggestion', 'return_load_available',
    'sla_warning', 'trip_booking'
);

CREATE TYPE incident_category AS ENUM (
    'cargo_damage', 'delay', 'lost_cargo',
    'wrong_delivery', 'driver_conduct', 'other'
);

CREATE TYPE incident_status AS ENUM (
    'open', 'in_review', 'resolved', 'closed'
);

CREATE TYPE suggestion_status AS ENUM (
    'pending', 'accepted', 'rejected', 'expired'
);
```

---

### V3__ddl_core.sql

```sql
-- ============================================================
-- LOGYX · V3 · Tablas del dominio central
-- ============================================================

-- -----------------------------------------------------------
-- Organizaciones
-- -----------------------------------------------------------
CREATE TABLE organizations (
    id              UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(200)  NOT NULL,
    ruc             VARCHAR(11)   NOT NULL,
    type            org_type      NOT NULL,
    verified        BOOLEAN       NOT NULL DEFAULT FALSE,
    verified_at     TIMESTAMP,
    trust_score     INTEGER       NOT NULL DEFAULT 75
                    CHECK (trust_score BETWEEN 0 AND 100),
    created_at      TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_organizations_ruc UNIQUE (ruc)
);

COMMENT ON TABLE organizations IS 'Entidad legal registrada en LOGYX (PYME, Transportista, Operador).';

-- -----------------------------------------------------------
-- Perfiles de usuario
-- -----------------------------------------------------------
CREATE TABLE profiles (
    id              UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID          NOT NULL
                    REFERENCES organizations(id) ON DELETE CASCADE,
    full_name       VARCHAR(200)  NOT NULL,
    phone           VARCHAR(15),
    email           VARCHAR(255)  NOT NULL,
    password_hash   VARCHAR(255),
    role            profile_role  NOT NULL DEFAULT 'ops',
    created_at      TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_profiles_email UNIQUE (email)
);

COMMENT ON TABLE profiles IS 'Usuario individual perteneciente a una organización.';

-- -----------------------------------------------------------
-- Vehículos
-- -----------------------------------------------------------
CREATE TABLE vehicles (
    id                  UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    carrier_org_id      UUID          NOT NULL
                        REFERENCES organizations(id) ON DELETE CASCADE,
    plate               VARCHAR(10)   NOT NULL,
    vehicle_type        vehicle_type  NOT NULL,
    max_weight_kg       DECIMAL(10,2) NOT NULL CHECK (max_weight_kg > 0),
    max_volume_m3       DECIMAL(8,2),
    current_weight_kg   DECIMAL(10,2) NOT NULL DEFAULT 0
                        CHECK (current_weight_kg >= 0),
    status              vehicle_status NOT NULL DEFAULT 'available',
    created_at          TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_vehicles_plate UNIQUE (plate),
    CONSTRAINT chk_vehicles_capacity
        CHECK (current_weight_kg <= max_weight_kg)
);

COMMENT ON TABLE vehicles IS 'Vehículo de carga registrado por una empresa transportista.';

-- -----------------------------------------------------------
-- Conductores
-- -----------------------------------------------------------
CREATE TABLE drivers (
    id                  UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    carrier_org_id      UUID          NOT NULL
                        REFERENCES organizations(id) ON DELETE CASCADE,
    full_name           VARCHAR(200)  NOT NULL,
    dni                 VARCHAR(8)    NOT NULL,
    license_number      VARCHAR(20)   NOT NULL,
    phone               VARCHAR(15)   NOT NULL,
    current_vehicle_id  UUID
                        REFERENCES vehicles(id) ON DELETE SET NULL,
    status              driver_status NOT NULL DEFAULT 'available',

    CONSTRAINT uq_drivers_dni UNIQUE (dni),
    CONSTRAINT uq_drivers_license UNIQUE (license_number)
);

COMMENT ON TABLE drivers IS 'Conductor vinculado a una empresa transportista.';

-- -----------------------------------------------------------
-- Scores de reputación (inicializado al registrarse)
-- -----------------------------------------------------------
CREATE TABLE reputation_scores (
    org_id                  UUID          PRIMARY KEY
                            REFERENCES organizations(id) ON DELETE CASCADE,
    delivery_success_rate   DECIMAL(5,2)  NOT NULL DEFAULT 100.0,
    avg_delay_minutes       DECIMAL(8,2)  NOT NULL DEFAULT 0.0,
    cargo_damage_rate       DECIMAL(5,2)  NOT NULL DEFAULT 0.0,
    cancellation_rate       DECIMAL(5,2)  NOT NULL DEFAULT 0.0,
    avg_rating              DECIMAL(4,2)  NOT NULL DEFAULT 4.0,
    composite_score         INTEGER       NOT NULL DEFAULT 75
                            CHECK (composite_score BETWEEN 0 AND 100),
    total_reviews           INTEGER       NOT NULL DEFAULT 0,
    updated_at              TIMESTAMP     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE reputation_scores IS 'Score de reputación compuesto actualizado por triggers tras cada review.';
```

---

### V4__ddl_operations.sql

```sql
-- ============================================================
-- LOGYX · V4 · Tablas operacionales
-- ============================================================

-- -----------------------------------------------------------
-- Solicitudes de envío
-- -----------------------------------------------------------
CREATE TABLE shipment_requests (
    id                  UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_org_id    UUID          NOT NULL
                        REFERENCES organizations(id),
    origin_address      VARCHAR(500)  NOT NULL,
    origin_lat          DECIMAL(10,7) NOT NULL,
    origin_lng          DECIMAL(10,7) NOT NULL,
    destination_address VARCHAR(500)  NOT NULL,
    destination_lat     DECIMAL(10,7) NOT NULL,
    destination_lng     DECIMAL(10,7) NOT NULL,
    weight_kg           DECIMAL(10,2) NOT NULL CHECK (weight_kg > 0),
    cargo_type          cargo_type    NOT NULL,
    cargo_description   TEXT,
    required_date       DATE          NOT NULL,
    status              request_status NOT NULL DEFAULT 'open',
    suggested_price     DECIMAL(10,2),
    price_floor         DECIMAL(10,2)
                        GENERATED ALWAYS AS (suggested_price * 0.75) STORED,
    created_at          TIMESTAMP     NOT NULL DEFAULT NOW()
);

COMMENT ON COLUMN shipment_requests.price_floor IS 'Calculado automáticamente: 75% del precio sugerido. Mínimo permitido en subastas.';

-- -----------------------------------------------------------
-- Subastas inversas
-- -----------------------------------------------------------
CREATE TABLE auctions (
    id          UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id  UUID            NOT NULL UNIQUE
                REFERENCES shipment_requests(id),
    opens_at    TIMESTAMP       NOT NULL DEFAULT NOW(),
    closes_at   TIMESTAMP       NOT NULL
                DEFAULT (NOW() + INTERVAL '20 minutes'),
    max_bids    INTEGER         NOT NULL DEFAULT 5,
    status      auction_status  NOT NULL DEFAULT 'open',

    CONSTRAINT chk_auctions_dates CHECK (closes_at > opens_at),
    CONSTRAINT chk_auctions_max_bids CHECK (max_bids > 0)
);

-- -----------------------------------------------------------
-- Ofertas de transportistas
-- -----------------------------------------------------------
CREATE TABLE bids (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    auction_id      UUID        NOT NULL
                    REFERENCES auctions(id),
    carrier_org_id  UUID        NOT NULL
                    REFERENCES organizations(id),
    vehicle_id      UUID        NOT NULL
                    REFERENCES vehicles(id),
    amount          DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    notes           TEXT,
    status          bid_status  NOT NULL DEFAULT 'pending',
    submitted_at    TIMESTAMP   NOT NULL DEFAULT NOW(),
    expires_at      TIMESTAMP   NOT NULL
                    DEFAULT (NOW() + INTERVAL '48 hours'),

    CONSTRAINT uq_bids_auction_carrier UNIQUE (auction_id, carrier_org_id)
);

COMMENT ON CONSTRAINT uq_bids_auction_carrier ON bids
    IS 'Un transportista solo puede tener una oferta activa por subasta.';

-- -----------------------------------------------------------
-- Contra-ofertas (negociación bidireccional)
-- -----------------------------------------------------------
CREATE TABLE counter_offers (
    id                  UUID                  PRIMARY KEY DEFAULT uuid_generate_v4(),
    bid_id              UUID                  NOT NULL
                        REFERENCES bids(id),
    offered_by_org_id   UUID                  NOT NULL
                        REFERENCES organizations(id),
    amount              DECIMAL(10,2)         NOT NULL CHECK (amount > 0),
    message             TEXT,
    status              counter_offer_status  NOT NULL DEFAULT 'pending',
    created_at          TIMESTAMP             NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------
-- Viajes publicados por transportistas (supply-side)
-- -----------------------------------------------------------
CREATE TABLE carrier_trips (
    id                      UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    carrier_org_id          UUID          NOT NULL
                            REFERENCES organizations(id),
    vehicle_id              UUID          NOT NULL
                            REFERENCES vehicles(id),
    origin_address          VARCHAR(500)  NOT NULL,
    origin_lat              DECIMAL(10,7) NOT NULL,
    origin_lng              DECIMAL(10,7) NOT NULL,
    destination_address     VARCHAR(500)  NOT NULL,
    destination_lat         DECIMAL(10,7) NOT NULL,
    destination_lng         DECIMAL(10,7) NOT NULL,
    departure_at            TIMESTAMP     NOT NULL,
    available_weight_kg     DECIMAL(10,2) NOT NULL CHECK (available_weight_kg > 0),
    available_volume_m3     DECIMAL(8,2),
    price_per_kg            DECIMAL(8,2)  NOT NULL CHECK (price_per_kg > 0),
    status                  trip_status   NOT NULL DEFAULT 'open',
    created_at              TIMESTAMP     NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------
-- Reservas en viajes publicados
-- -----------------------------------------------------------
CREATE TABLE trip_bookings (
    id                  UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id             UUID            NOT NULL
                        REFERENCES carrier_trips(id),
    requester_org_id    UUID            NOT NULL
                        REFERENCES organizations(id),
    request_id          UUID            NOT NULL
                        REFERENCES shipment_requests(id),
    booked_weight_kg    DECIMAL(10,2)   NOT NULL CHECK (booked_weight_kg > 0),
    status              booking_status  NOT NULL DEFAULT 'confirmed',
    created_at          TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------
-- Mensajes del chat de negociación
-- -----------------------------------------------------------
CREATE TABLE messages (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id      UUID        NOT NULL
                    REFERENCES shipment_requests(id),
    carrier_org_id  UUID        NOT NULL
                    REFERENCES organizations(id),
    sender_org_id   UUID        NOT NULL
                    REFERENCES organizations(id),
    body            TEXT        NOT NULL,
    proposed_price  DECIMAL(10,2),
    is_system       BOOLEAN     NOT NULL DEFAULT FALSE,
    is_blocked      BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP   NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------
-- Envíos
-- -----------------------------------------------------------
CREATE TABLE shipments (
    id              UUID              PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id      UUID              NOT NULL
                    REFERENCES shipment_requests(id),
    bid_id          UUID              NOT NULL
                    REFERENCES bids(id),
    carrier_org_id  UUID              NOT NULL
                    REFERENCES organizations(id),
    vehicle_id      UUID              NOT NULL
                    REFERENCES vehicles(id),
    driver_id       UUID
                    REFERENCES drivers(id),
    tracking_code   VARCHAR(12)       NOT NULL,
    status          shipment_status   NOT NULL DEFAULT 'pending',
    escrow_status   escrow_status     NOT NULL DEFAULT 'held',
    started_at      TIMESTAMP,
    delivered_at    TIMESTAMP,
    created_at      TIMESTAMP         NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_shipments_tracking UNIQUE (tracking_code)
);

-- -----------------------------------------------------------
-- Paradas del envío
-- -----------------------------------------------------------
CREATE TABLE shipment_stops (
    id              UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_id     UUID          NOT NULL
                    REFERENCES shipments(id) ON DELETE CASCADE,
    request_id      UUID
                    REFERENCES shipment_requests(id),
    sequence        INTEGER       NOT NULL CHECK (sequence > 0),
    location        VARCHAR(500)  NOT NULL,
    lat             DECIMAL(10,7) NOT NULL,
    lng             DECIMAL(10,7) NOT NULL,
    eta             TIMESTAMP,
    actual_arrival  TIMESTAMP,
    status          stop_status   NOT NULL DEFAULT 'pending',
    photo_url       VARCHAR(1000),
    signature_url   VARCHAR(1000),
    cargo_weight_kg DECIMAL(10,2) NOT NULL DEFAULT 0,

    CONSTRAINT uq_stops_shipment_sequence UNIQUE (shipment_id, sequence)
);

-- -----------------------------------------------------------
-- Calificaciones post-entrega
-- -----------------------------------------------------------
CREATE TABLE reviews (
    id                  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_id         UUID        NOT NULL
                        REFERENCES shipments(id),
    reviewer_org_id     UUID        NOT NULL
                        REFERENCES organizations(id),
    reviewed_org_id     UUID        NOT NULL
                        REFERENCES organizations(id),
    rating              SMALLINT    NOT NULL
                        CHECK (rating BETWEEN 1 AND 5),
    punctuality         SMALLINT
                        CHECK (punctuality BETWEEN 1 AND 5),
    comment             TEXT,
    delivery_success    BOOLEAN     NOT NULL DEFAULT TRUE,
    delay_minutes       INTEGER     NOT NULL DEFAULT 0,
    cargo_damage        BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMP   NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_reviews_shipment_reviewer
        UNIQUE (shipment_id, reviewer_org_id)
);

-- -----------------------------------------------------------
-- Cálculos de costo
-- -----------------------------------------------------------
CREATE TABLE cost_calculations (
    id                      UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id              UUID          NOT NULL
                            REFERENCES shipment_requests(id),
    distance_km             DECIMAL(8,2)  NOT NULL,
    duration_min            DECIMAL(8,2)  NOT NULL,
    toll_cost               DECIMAL(10,2) NOT NULL DEFAULT 0,
    fuel_cost               DECIMAL(10,2) NOT NULL,
    base_transport_cost     DECIMAL(10,2) NOT NULL,
    handling_fee            DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_estimate          DECIMAL(10,2) NOT NULL
                            GENERATED ALWAYS AS (
                                toll_cost + fuel_cost +
                                base_transport_cost + handling_fee
                            ) STORED,
    calculated_at           TIMESTAMP     NOT NULL DEFAULT NOW()
);
```

---

### V5__ddl_support.sql

```sql
-- ============================================================
-- LOGYX · V5 · Tablas de soporte
-- ============================================================

-- -----------------------------------------------------------
-- Documentos adjuntos a envíos
-- -----------------------------------------------------------
CREATE TABLE documents (
    id              UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_id     UUID            NOT NULL
                    REFERENCES shipments(id) ON DELETE CASCADE,
    stop_id         UUID
                    REFERENCES shipment_stops(id),
    type            document_type   NOT NULL,
    file_url        VARCHAR(1000)   NOT NULL,
    file_size_bytes BIGINT,
    uploaded_by     UUID            NOT NULL
                    REFERENCES profiles(id),
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------
-- Notificaciones in-app
-- -----------------------------------------------------------
CREATE TABLE notifications (
    id          UUID                PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id      UUID                NOT NULL
                REFERENCES organizations(id) ON DELETE CASCADE,
    type        notification_type   NOT NULL,
    title       VARCHAR(200)        NOT NULL,
    body        TEXT                NOT NULL,
    related_id  UUID,
    read        BOOLEAN             NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP           NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------
-- Incidencias
-- -----------------------------------------------------------
CREATE TABLE incidents (
    id                  UUID                PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_id         UUID                NOT NULL
                        REFERENCES shipments(id),
    reported_by_org_id  UUID                NOT NULL
                        REFERENCES organizations(id),
    category            incident_category   NOT NULL,
    description         TEXT                NOT NULL,
    status              incident_status     NOT NULL DEFAULT 'open',
    resolution_notes    TEXT,
    created_at          TIMESTAMP           NOT NULL DEFAULT NOW(),
    resolved_at         TIMESTAMP
);

-- -----------------------------------------------------------
-- Comentarios en incidencias
-- -----------------------------------------------------------
CREATE TABLE incident_comments (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    incident_id     UUID        NOT NULL
                    REFERENCES incidents(id) ON DELETE CASCADE,
    author_org_id   UUID        NOT NULL
                    REFERENCES organizations(id),
    body            TEXT        NOT NULL,
    created_at      TIMESTAMP   NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------
-- Sugerencias Smart Load Planner
-- -----------------------------------------------------------
CREATE TABLE smart_load_suggestions (
    id                  UUID                PRIMARY KEY DEFAULT uuid_generate_v4(),
    carrier_org_id      UUID                NOT NULL
                        REFERENCES organizations(id),
    vehicle_id          UUID                NOT NULL
                        REFERENCES vehicles(id),
    request_ids         UUID[]              NOT NULL,
    combined_income     DECIMAL(10,2)       NOT NULL,
    occupancy_pct       DECIMAL(5,2)        NOT NULL
                        CHECK (occupancy_pct BETWEEN 0 AND 100),
    route_plan          JSONB               NOT NULL,
    status              suggestion_status   NOT NULL DEFAULT 'pending',
    created_at          TIMESTAMP           NOT NULL DEFAULT NOW(),
    expires_at          TIMESTAMP           NOT NULL
                        DEFAULT (NOW() + INTERVAL '4 hours')
);

-- -----------------------------------------------------------
-- Log de auditoría
-- -----------------------------------------------------------
CREATE TABLE audit_log (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name      VARCHAR(100) NOT NULL,
    action          VARCHAR(10)  NOT NULL,
    record_id       UUID         NOT NULL,
    performed_by    UUID
                    REFERENCES profiles(id),
    old_values      JSONB,
    new_values      JSONB,
    performed_at    TIMESTAMP    NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE audit_log IS 'Registro inmutable de cambios de estado en tablas críticas.';
```

---

### V6__indexes.sql

```sql
-- ============================================================
-- LOGYX · V6 · Índices de rendimiento
-- ============================================================

-- shipment_requests: búsquedas del marketplace
CREATE INDEX idx_requests_status_date
    ON shipment_requests(status, required_date);

CREATE INDEX idx_requests_org
    ON shipment_requests(requester_org_id);

CREATE INDEX idx_requests_origin_geo
    ON shipment_requests(origin_lat, origin_lng);

CREATE INDEX idx_requests_destination_geo
    ON shipment_requests(destination_lat, destination_lng);

-- bids: consultas por subasta y transportista
CREATE INDEX idx_bids_auction_status
    ON bids(auction_id, status);

CREATE INDEX idx_bids_carrier_status
    ON bids(carrier_org_id, status);

-- shipments: tracking y gestión de envíos
CREATE UNIQUE INDEX idx_shipments_tracking_code
    ON shipments(tracking_code);

CREATE INDEX idx_shipments_carrier_status
    ON shipments(carrier_org_id, status);

CREATE INDEX idx_shipments_request
    ON shipments(request_id);

-- notifications: feed de notificaciones no leídas
CREATE INDEX idx_notifications_org_unread
    ON notifications(org_id, read, created_at DESC)
    WHERE read = FALSE;

-- messages: hilo de negociación
CREATE INDEX idx_messages_thread
    ON messages(request_id, carrier_org_id, created_at);

-- reviews: calificaciones de una organización
CREATE INDEX idx_reviews_reviewed_org
    ON reviews(reviewed_org_id, created_at DESC);

-- carrier_trips: viajes disponibles
CREATE INDEX idx_trips_status_departure
    ON carrier_trips(status, departure_at)
    WHERE status IN ('open', 'filling');

CREATE INDEX idx_trips_origin_geo
    ON carrier_trips(origin_lat, origin_lng);

-- incidents: gestión del panel operador
CREATE INDEX idx_incidents_shipment
    ON incidents(shipment_id);

CREATE INDEX idx_incidents_status
    ON incidents(status, created_at DESC);

-- audit_log: trazabilidad por registro
CREATE INDEX idx_audit_table_record
    ON audit_log(table_name, record_id, performed_at DESC);
```

---

## 3. CE0222 — DML: Datos Iniciales (Seed)

### V9__seed.sql

```sql
-- ============================================================
-- LOGYX · V9 · Seed data para desarrollo y pruebas
-- ============================================================

-- -----------------------------------------------------------
-- Organizaciones de prueba
-- -----------------------------------------------------------
INSERT INTO organizations (id, name, ruc, type, verified, verified_at, trust_score)
VALUES
    ('00000000-0000-0000-0001-000000000001',
     'LOGYX Operaciones S.A.C.',    '20601234561', 'operator', TRUE, NOW(), 100),

    ('00000000-0000-0000-0002-000000000001',
     'Textiles Arequipa S.R.L.',    '20453219876', 'pyme',     TRUE, NOW(), 78),

    ('00000000-0000-0000-0002-000000000002',
     'Distribuidora Sur Andino E.I.R.L.', '20512387654', 'pyme', TRUE, NOW(), 82),

    ('00000000-0000-0000-0003-000000000001',
     'Transportes Colca Express S.A.C.',  '20387654321', 'carrier', TRUE, NOW(), 88),

    ('00000000-0000-0000-0003-000000000002',
     'Logística Sierra Norte S.R.L.',     '20478912345', 'carrier', TRUE, NOW(), 75);

-- -----------------------------------------------------------
-- Perfiles de usuario
-- -----------------------------------------------------------
INSERT INTO profiles (id, organization_id, full_name, email, password_hash, role)
VALUES
    ('00000000-0000-0000-0011-000000000001',
     '00000000-0000-0000-0001-000000000001',
     'Jorge Gutiérrez Miranda',
     'jorge@logyx.pe',
     -- Hash bcrypt de 'Logyx2024!', cost=12
     '$2a$12$examplehashoperatorkjkjkjkjkjkjkjkjkjkjkjkjkjkjkj',
     'admin'),

    ('00000000-0000-0000-0011-000000000002',
     '00000000-0000-0000-0002-000000000001',
     'María Torres Quispe',
     'maria.torres@textilesarequipa.pe',
     '$2a$12$examplehashpyme1kjkjkjkjkjkjkjkjkjkjkjkjkjkjkjkjk',
     'admin'),

    ('00000000-0000-0000-0011-000000000003',
     '00000000-0000-0000-0003-000000000001',
     'Carlos Mamani Flores',
     'carlos@colcaexpress.pe',
     '$2a$12$examplehashcarrierkjkjkjkjkjkjkjkjkjkjkjkjkjkjkjk',
     'admin');

-- -----------------------------------------------------------
-- Vehículos de prueba
-- -----------------------------------------------------------
INSERT INTO vehicles (id, carrier_org_id, plate, vehicle_type, max_weight_kg, max_volume_m3, status)
VALUES
    ('00000000-0000-0000-0021-000000000001',
     '00000000-0000-0000-0003-000000000001',
     'A3T-456', 'truck_large', 15000, 60, 'available'),

    ('00000000-0000-0000-0021-000000000002',
     '00000000-0000-0000-0003-000000000001',
     'B7M-123', 'truck_medium', 8000, 35, 'available'),

    ('00000000-0000-0000-0021-000000000003',
     '00000000-0000-0000-0003-000000000002',
     'C2K-789', 'van', 1400, 8, 'available');

-- -----------------------------------------------------------
-- Conductores de prueba
-- -----------------------------------------------------------
INSERT INTO drivers (id, carrier_org_id, full_name, dni, license_number, phone, status)
VALUES
    ('00000000-0000-0000-0031-000000000001',
     '00000000-0000-0000-0003-000000000001',
     'Juan Pablo Ramos', '43218765', 'Q-III-123456', '987654321', 'available'),

    ('00000000-0000-0000-0031-000000000002',
     '00000000-0000-0000-0003-000000000001',
     'Pedro Huanca Quispe', '65432187', 'Q-II-789012', '976543210', 'available');

-- -----------------------------------------------------------
-- Scores de reputación iniciales
-- -----------------------------------------------------------
INSERT INTO reputation_scores (org_id, composite_score)
SELECT id, trust_score
FROM organizations
ON CONFLICT (org_id) DO NOTHING;

-- -----------------------------------------------------------
-- Solicitud de prueba
-- -----------------------------------------------------------
INSERT INTO shipment_requests
    (id, requester_org_id, origin_address, origin_lat, origin_lng,
     destination_address, destination_lat, destination_lng,
     weight_kg, cargo_type, cargo_description, required_date, status, suggested_price)
VALUES
    ('00000000-0000-0000-0041-000000000001',
     '00000000-0000-0000-0002-000000000001',
     'Av. La Marina 1200, Lima',     -12.0731, -77.0826,
     'Calle Mercaderes 120, Arequipa', -16.3989, -71.5370,
     3500.00, 'general',
     '500 rollos de tela denim embalados en palets',
     CURRENT_DATE + 3,
     'auction_open', 2800.00);

-- -----------------------------------------------------------
-- Subasta de prueba
-- -----------------------------------------------------------
INSERT INTO auctions (id, request_id, closes_at, max_bids, status)
VALUES
    ('00000000-0000-0000-0051-000000000001',
     '00000000-0000-0000-0041-000000000001',
     NOW() + INTERVAL '15 minutes',
     5, 'open');

-- -----------------------------------------------------------
-- Cálculo de costo de prueba
-- -----------------------------------------------------------
INSERT INTO cost_calculations
    (request_id, distance_km, duration_min, toll_cost, fuel_cost,
     base_transport_cost, handling_fee)
VALUES
    ('00000000-0000-0000-0041-000000000001',
     1014.5, 780.0, 85.00, 650.00, 1800.00, 265.00);
```

---

## 4. CE0223 — Funciones SQL

### V7__functions.sql

```sql
-- ============================================================
-- LOGYX · V7 · Funciones del sistema
-- ============================================================

-- -----------------------------------------------------------
-- fn_generate_tracking_code()
-- Genera código de tracking único en formato LGX-XXXXX
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_generate_tracking_code()
RETURNS VARCHAR AS $$
DECLARE
    v_code   VARCHAR(12);
    v_exists BOOLEAN;
BEGIN
    LOOP
        v_code := 'LGX-' ||
                  UPPER(SUBSTRING(md5(random()::TEXT), 1, 7));

        SELECT EXISTS (
            SELECT 1 FROM shipments WHERE tracking_code = v_code
        ) INTO v_exists;

        EXIT WHEN NOT v_exists;
    END LOOP;
    RETURN v_code;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------
-- fn_calculate_bayesian_rating(p_org_id UUID)
-- Retorna el rating promedio bayesiano de una organización.
-- Fórmula: (C × m + Σ_ratings) / (C + n)
--   C = 10 (peso del prior), m = 4.0 (prior global), n = total reviews
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_calculate_bayesian_rating(p_org_id UUID)
RETURNS DECIMAL AS $$
DECLARE
    v_prior_weight   CONSTANT DECIMAL := 10.0;
    v_prior_mean     CONSTANT DECIMAL := 4.0;
    v_sum_ratings    DECIMAL;
    v_count          INTEGER;
BEGIN
    SELECT
        COALESCE(SUM(rating), 0),
        COUNT(*)
    INTO v_sum_ratings, v_count
    FROM reviews
    WHERE reviewed_org_id = p_org_id;

    RETURN ROUND(
        (v_prior_weight * v_prior_mean + v_sum_ratings) /
        (v_prior_weight + v_count),
        2
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- -----------------------------------------------------------
-- fn_calculate_composite_score(p_org_id UUID)
-- Recalcula el score compuesto de reputación (0-100) usando
-- pesos del Reputation Graph:
--   Éxito entrega   25%
--   Puntualidad     25% (inversamente proporcional al delay)
--   Daño de carga   15% (inverso)
--   Cancelaciones   15% (inverso)
--   Rating promedio 20%
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_calculate_composite_score(p_org_id UUID)
RETURNS INTEGER AS $$
DECLARE
    r            reputation_scores%ROWTYPE;
    v_punctuality DECIMAL;
    v_score      DECIMAL;
BEGIN
    SELECT * INTO r
    FROM reputation_scores
    WHERE org_id = p_org_id;

    IF NOT FOUND THEN
        RETURN 75;
    END IF;

    -- Puntualidad: 100 si delay=0, decrece con el delay (máx 480 min = 0)
    v_punctuality := GREATEST(0, 100.0 - (r.avg_delay_minutes / 4.8));

    v_score :=
        (r.delivery_success_rate         * 0.25) +
        (v_punctuality                   * 0.25) +
        ((100.0 - r.cargo_damage_rate)   * 0.15) +
        ((100.0 - r.cancellation_rate)   * 0.15) +
        ((r.avg_rating / 5.0 * 100.0)   * 0.20);

    RETURN ROUND(LEAST(100, GREATEST(0, v_score)));
END;
$$ LANGUAGE plpgsql STABLE;

-- -----------------------------------------------------------
-- fn_close_expired_auctions()
-- Cierra subastas cuyo closes_at ya pasó.
-- Invocada por el Quarkus Scheduler cada 5 minutos.
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_close_expired_auctions()
RETURNS INTEGER AS $$
DECLARE
    v_closed INTEGER;
BEGIN
    UPDATE auctions
    SET status = 'closed'
    WHERE status = 'open'
      AND closes_at < NOW();

    GET DIAGNOSTICS v_closed = ROW_COUNT;
    RETURN v_closed;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------
-- fn_check_vehicle_capacity(p_vehicle_id UUID, p_add_weight DECIMAL)
-- Retorna TRUE si el vehículo puede aceptar el peso adicional
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_vehicle_capacity(
    p_vehicle_id UUID,
    p_add_weight  DECIMAL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_available DECIMAL;
BEGIN
    SELECT (max_weight_kg - current_weight_kg)
    INTO v_available
    FROM vehicles
    WHERE id = p_vehicle_id;

    RETURN FOUND AND v_available >= p_add_weight;
END;
$$ LANGUAGE plpgsql STABLE;

-- -----------------------------------------------------------
-- fn_contains_contact_info(p_text TEXT)
-- Detecta si el texto contiene números de teléfono (9 dígitos),
-- correos electrónicos o handles de redes sociales.
-- Retorna TRUE si el texto DEBE ser bloqueado.
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_contains_contact_info(p_text TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Teléfonos peruanos: 9 dígitos consecutivos
    IF p_text ~ '\m9[0-9]{8}\M' THEN RETURN TRUE; END IF;
    -- Emails
    IF p_text ~* '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' THEN RETURN TRUE; END IF;
    -- Handles de redes (@usuario, wa.me, WhatsApp)
    IF p_text ~* '(@[a-z0-9_]{3,}|wa\.me|whatsapp|telegram|tiktok|instagram)' THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

---

## 5. CE0223 — Triggers

### V8__triggers.sql

```sql
-- ============================================================
-- LOGYX · V8 · Triggers
-- ============================================================

-- -----------------------------------------------------------
-- TRIGGER: Actualizar reputation_scores al insertar review
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_update_reputation_on_review()
RETURNS TRIGGER AS $$
DECLARE
    v_org_id UUID := NEW.reviewed_org_id;
    v_success_rate   DECIMAL;
    v_avg_delay      DECIMAL;
    v_damage_rate    DECIMAL;
    v_cancel_rate    DECIMAL;
    v_count          INTEGER;
    v_composite      INTEGER;
BEGIN
    -- Recalcular métricas desde todos los reviews de la organización
    SELECT
        ROUND(100.0 * SUM(CASE WHEN delivery_success THEN 1 ELSE 0 END)::DECIMAL / COUNT(*), 2),
        ROUND(AVG(delay_minutes), 2),
        ROUND(100.0 * SUM(CASE WHEN cargo_damage THEN 1 ELSE 0 END)::DECIMAL / COUNT(*), 2),
        COUNT(*)
    INTO v_success_rate, v_avg_delay, v_damage_rate, v_count
    FROM reviews
    WHERE reviewed_org_id = v_org_id;

    -- Tasa de cancelación: bids aceptadas que terminaron canceladas
    SELECT ROUND(
        100.0 * COUNT(CASE WHEN s.status = 'cancelled' THEN 1 END)::DECIMAL /
        NULLIF(COUNT(*), 0), 2
    )
    INTO v_cancel_rate
    FROM bids b
    JOIN shipments s ON s.bid_id = b.id
    WHERE b.carrier_org_id = v_org_id;

    -- Score compuesto
    v_composite := fn_calculate_composite_score(v_org_id);

    -- Upsert en reputation_scores
    INSERT INTO reputation_scores
        (org_id, delivery_success_rate, avg_delay_minutes,
         cargo_damage_rate, cancellation_rate, avg_rating,
         composite_score, total_reviews, updated_at)
    VALUES
        (v_org_id,
         COALESCE(v_success_rate, 100),
         COALESCE(v_avg_delay, 0),
         COALESCE(v_damage_rate, 0),
         COALESCE(v_cancel_rate, 0),
         fn_calculate_bayesian_rating(v_org_id),
         v_composite,
         v_count,
         NOW())
    ON CONFLICT (org_id) DO UPDATE SET
        delivery_success_rate   = EXCLUDED.delivery_success_rate,
        avg_delay_minutes       = EXCLUDED.avg_delay_minutes,
        cargo_damage_rate       = EXCLUDED.cargo_damage_rate,
        cancellation_rate       = EXCLUDED.cancellation_rate,
        avg_rating              = EXCLUDED.avg_rating,
        composite_score         = EXCLUDED.composite_score,
        total_reviews           = EXCLUDED.total_reviews,
        updated_at              = NOW();

    -- Propagar composite_score a organizations.trust_score
    UPDATE organizations
    SET trust_score = v_composite
    WHERE id = v_org_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_reputation_on_review
    AFTER INSERT ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_update_reputation_on_review();

-- -----------------------------------------------------------
-- TRIGGER: Inicializar reputation_scores al registrar organización
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_init_reputation_on_org_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO reputation_scores (org_id)
    VALUES (NEW.id)
    ON CONFLICT DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_init_reputation_on_org
    AFTER INSERT ON organizations
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_init_reputation_on_org_insert();

-- -----------------------------------------------------------
-- TRIGGER: Bloquear mensajes con información de contacto
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_moderate_message()
RETURNS TRIGGER AS $$
BEGIN
    IF fn_contains_contact_info(NEW.body) THEN
        NEW.is_blocked := TRUE;
        NEW.body := '[Mensaje bloqueado: el sistema detectó información de contacto directa.]';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_moderate_message
    BEFORE INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_moderate_message();

-- -----------------------------------------------------------
-- TRIGGER: Generar tracking code al crear shipment
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_set_tracking_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tracking_code IS NULL OR NEW.tracking_code = '' THEN
        NEW.tracking_code := fn_generate_tracking_code();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_tracking_code
    BEFORE INSERT ON shipments
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_set_tracking_code();

-- -----------------------------------------------------------
-- TRIGGER: Actualizar capacidad del vehículo al crear shipment
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_lock_vehicle_capacity_on_shipment()
RETURNS TRIGGER AS $$
DECLARE
    v_weight DECIMAL;
BEGIN
    -- Obtener el peso de la solicitud
    SELECT weight_kg INTO v_weight
    FROM shipment_requests
    WHERE id = NEW.request_id;

    -- Verificar y actualizar capacidad
    UPDATE vehicles
    SET
        current_weight_kg = current_weight_kg + v_weight,
        status = CASE
                    WHEN (max_weight_kg - current_weight_kg - v_weight) < 500
                    THEN 'in_route'
                    ELSE status
                 END
    WHERE id = NEW.vehicle_id
      AND (max_weight_kg - current_weight_kg) >= v_weight;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'LOGYX-CAP-001: El vehículo no tiene capacidad suficiente para esta carga.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_lock_vehicle_capacity_on_shipment
    BEFORE INSERT ON shipments
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_lock_vehicle_capacity_on_shipment();

-- -----------------------------------------------------------
-- TRIGGER: Liberar capacidad del vehículo al entregar o cancelar
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_release_vehicle_capacity_on_delivery()
RETURNS TRIGGER AS $$
DECLARE
    v_weight DECIMAL;
BEGIN
    -- Solo actuar cuando el estado pasa a 'delivered' o 'cancelled'
    IF NEW.status NOT IN ('delivered', 'cancelled') THEN
        RETURN NEW;
    END IF;
    IF OLD.status = NEW.status THEN
        RETURN NEW;
    END IF;

    SELECT weight_kg INTO v_weight
    FROM shipment_requests
    WHERE id = NEW.request_id;

    UPDATE vehicles
    SET
        current_weight_kg = GREATEST(0, current_weight_kg - v_weight),
        status = CASE
                    WHEN (current_weight_kg - v_weight) <= 0 THEN 'available'
                    ELSE status
                 END
    WHERE id = NEW.vehicle_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_release_vehicle_capacity_on_delivery
    AFTER UPDATE OF status ON shipments
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_release_vehicle_capacity_on_delivery();

-- -----------------------------------------------------------
-- TRIGGER: Cerrar subasta al llegar a max_bids
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_close_auction_on_max_bids()
RETURNS TRIGGER AS $$
DECLARE
    v_bid_count INTEGER;
    v_max_bids  INTEGER;
BEGIN
    SELECT COUNT(*), a.max_bids
    INTO v_bid_count, v_max_bids
    FROM bids b
    JOIN auctions a ON a.id = b.auction_id
    WHERE b.auction_id = NEW.auction_id
      AND b.status = 'pending'
    GROUP BY a.max_bids;

    IF v_bid_count >= v_max_bids THEN
        UPDATE auctions
        SET status = 'closed'
        WHERE id = NEW.auction_id
          AND status = 'open';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_close_auction_on_max_bids
    AFTER INSERT ON bids
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_close_auction_on_max_bids();

-- -----------------------------------------------------------
-- TRIGGER: Auditoría automática en tablas críticas
-- -----------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_audit_log()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log
        (table_name, action, record_id, old_values, new_values, performed_at)
    VALUES (
        TG_TABLE_NAME,
        TG_OP,
        CASE TG_OP WHEN 'DELETE' THEN OLD.id ELSE NEW.id END,
        CASE TG_OP WHEN 'INSERT' THEN NULL
                   ELSE to_jsonb(OLD) END,
        CASE TG_OP WHEN 'DELETE' THEN NULL
                   ELSE to_jsonb(NEW) END,
        NOW()
    );
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Aplicar auditoría a tablas críticas
CREATE TRIGGER trg_audit_shipments
    AFTER INSERT OR UPDATE OR DELETE ON shipments
    FOR EACH ROW EXECUTE FUNCTION trg_fn_audit_log();

CREATE TRIGGER trg_audit_bids
    AFTER INSERT OR UPDATE OR DELETE ON bids
    FOR EACH ROW EXECUTE FUNCTION trg_fn_audit_log();

CREATE TRIGGER trg_audit_auctions
    AFTER INSERT OR UPDATE OR DELETE ON auctions
    FOR EACH ROW EXECUTE FUNCTION trg_fn_audit_log();

CREATE TRIGGER trg_audit_incidents
    AFTER INSERT OR UPDATE OR DELETE ON incidents
    FOR EACH ROW EXECUTE FUNCTION trg_fn_audit_log();
```

---

## 6. Resumen de Objetos de Base de Datos

| Tipo | Cantidad | Nombres |
|------|----------|---------|
| **Extensiones** | 3 | uuid-ossp, postgis, pg_trgm |
| **Tipos ENUM** | 15 | org_type, profile_role, vehicle_type, vehicle_status, driver_status, cargo_type, request_status, auction_status, bid_status, counter_offer_status, trip_status, booking_status, shipment_status, escrow_status, stop_status + 4 más |
| **Tablas** | 22 | Ver E2_ModeloDatos.md |
| **Índices** | 14 | Ver sección V6 |
| **Funciones** | 6 | fn_generate_tracking_code, fn_calculate_bayesian_rating, fn_calculate_composite_score, fn_close_expired_auctions, fn_check_vehicle_capacity, fn_contains_contact_info |
| **Triggers** | 8 | trg_update_reputation_on_review, trg_init_reputation_on_org, trg_moderate_message, trg_set_tracking_code, trg_lock_vehicle_capacity_on_shipment, trg_release_vehicle_capacity_on_delivery, trg_close_auction_on_max_bids, trg_audit_\* |

---

*LOGYX · E2 Scripts de Base de Datos · Competencias CE0222–CE0223 · Versión 1.0 · Junio 2026*
