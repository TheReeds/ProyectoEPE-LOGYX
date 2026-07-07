# E2 — Modelo de Base de Datos
> Competencia CE0221 · Modelo ER + Lógico + Diccionario de Datos  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Motor: PostgreSQL 16  
> Versión: 1.0 · Junio 2026

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Motor de base de datos** | PostgreSQL 16 con extensión PostGIS |
| **Paradigma** | Relacional normalizado (3FN) |
| **Total de tablas** | 22 tablas principales |
| **Extensiones usadas** | `uuid-ossp` (generación de UUIDs), `postgis` (geoespacial), `pg_trgm` (búsqueda de texto) |
| **Herramienta de migración** | Flyway |

---

## 2. Diagrama Entidad-Relación (ER)

```mermaid
erDiagram
  organizations {
    uuid id PK
    varchar name
    varchar ruc UK
    org_type type
    boolean verified
    timestamp verified_at
    integer trust_score
    timestamp created_at
  }

  profiles {
    uuid id PK
    uuid organization_id FK
    varchar full_name
    varchar phone
    varchar email UK
    varchar password_hash
    profile_role role
    timestamp consent_accepted_at
    timestamp created_at
  }

  vehicles {
    uuid id PK
    uuid carrier_org_id FK
    varchar plate UK
    vehicle_type vehicle_type
    decimal max_weight_kg
    decimal max_volume_m3
    decimal current_weight_kg
    vehicle_status status
    timestamp created_at
  }

  drivers {
    uuid id PK
    uuid carrier_org_id FK
    varchar full_name
    varchar dni UK
    varchar license_number UK
    varchar phone
    uuid current_vehicle_id FK
    driver_status status
  }

  shipment_requests {
    uuid id PK
    uuid requester_org_id FK
    varchar origin_address
    decimal origin_lat
    decimal origin_lng
    varchar destination_address
    decimal destination_lat
    decimal destination_lng
    decimal weight_kg
    cargo_type cargo_type
    date required_date
    request_status status
    decimal suggested_price
    decimal price_floor
    timestamp created_at
  }

  auctions {
    uuid id PK
    uuid request_id FK
    timestamp opens_at
    timestamp closes_at
    integer max_bids
    auction_status status
  }

  bids {
    uuid id PK
    uuid auction_id FK
    uuid carrier_org_id FK
    uuid vehicle_id FK
    decimal amount
    text notes
    bid_status status
    timestamp submitted_at
    timestamp expires_at
  }

  counter_offers {
    uuid id PK
    uuid bid_id FK
    uuid offered_by_org_id FK
    decimal amount
    text message
    counter_offer_status status
    timestamp created_at
  }

  carrier_trips {
    uuid id PK
    uuid carrier_org_id FK
    uuid vehicle_id FK
    varchar origin_address
    decimal origin_lat
    decimal origin_lng
    varchar destination_address
    decimal destination_lat
    decimal destination_lng
    timestamp departure_at
    decimal available_weight_kg
    decimal available_volume_m3
    decimal price_per_kg
    trip_status status
    timestamp created_at
  }

  trip_bookings {
    uuid id PK
    uuid trip_id FK
    uuid requester_org_id FK
    uuid request_id FK
    decimal booked_weight_kg
    booking_status status
    timestamp created_at
  }

  messages {
    uuid id PK
    uuid request_id FK
    uuid carrier_org_id FK
    uuid sender_org_id FK
    text body
    decimal proposed_price
    boolean is_system
    boolean is_blocked
    timestamp created_at
  }

  shipments {
    uuid id PK
    uuid request_id FK
    uuid bid_id FK
    uuid carrier_org_id FK
    uuid vehicle_id FK
    uuid driver_id FK
    varchar tracking_code UK
    shipment_status status
    escrow_status escrow_status
    timestamp started_at
    timestamp delivered_at
    timestamp created_at
  }

  shipment_stops {
    uuid id PK
    uuid shipment_id FK
    uuid request_id FK
    integer sequence
    varchar location
    decimal lat
    decimal lng
    timestamp eta
    timestamp actual_arrival
    stop_status status
    varchar photo_url
    varchar signature_url
    decimal cargo_weight_kg
  }

  reviews {
    uuid id PK
    uuid shipment_id FK
    uuid reviewer_org_id FK
    uuid reviewed_org_id FK
    smallint rating
    smallint punctuality
    text comment
    boolean delivery_success
    integer delay_minutes
    boolean cargo_damage
    timestamp created_at
  }

  reputation_scores {
    uuid org_id PK FK
    decimal delivery_success_rate
    decimal avg_delay_minutes
    decimal cargo_damage_rate
    decimal cancellation_rate
    decimal avg_rating
    integer composite_score
    integer total_reviews
    timestamp updated_at
  }

  documents {
    uuid id PK
    uuid shipment_id FK
    uuid stop_id FK
    document_type type
    varchar file_url
    bigint file_size_bytes
    uuid uploaded_by FK
    timestamp created_at
  }

  notifications {
    uuid id PK
    uuid org_id FK
    notification_type type
    varchar title
    text body
    uuid related_id
    boolean read
    timestamp created_at
  }

  incidents {
    uuid id PK
    uuid shipment_id FK
    uuid reported_by_org_id FK
    incident_category category
    text description
    incident_status status
    varchar resolution_notes
    timestamp created_at
    timestamp resolved_at
  }

  incident_comments {
    uuid id PK
    uuid incident_id FK
    uuid author_org_id FK
    text body
    timestamp created_at
  }

  cost_calculations {
    uuid id PK
    uuid request_id FK
    decimal distance_km
    decimal duration_min
    decimal toll_cost
    decimal fuel_cost
    decimal base_transport_cost
    decimal handling_fee
    decimal total_estimate
    timestamp calculated_at
  }

  smart_load_suggestions {
    uuid id PK
    uuid carrier_org_id FK
    uuid vehicle_id FK
    uuid[] request_ids
    decimal combined_income
    decimal occupancy_pct
    jsonb route_plan
    suggestion_status status
    timestamp created_at
    timestamp expires_at
  }

  audit_log {
    uuid id PK
    varchar table_name
    varchar action
    uuid record_id
    uuid performed_by FK
    jsonb old_values
    jsonb new_values
    timestamp performed_at
  }

  organizations ||--o{ profiles : "tiene"
  organizations ||--o{ vehicles : "posee"
  organizations ||--o{ drivers : "emplea"
  organizations ||--o{ shipment_requests : "crea"
  organizations ||--o{ carrier_trips : "publica"
  organizations ||--|| reputation_scores : "tiene"
  vehicles ||--o{ drivers : "asignado a"
  shipment_requests ||--|| auctions : "genera"
  shipment_requests ||--|| cost_calculations : "tiene"
  shipment_requests ||--o{ messages : "tiene hilo"
  shipment_requests ||--o{ trip_bookings : "puede tener"
  auctions ||--o{ bids : "recibe"
  bids ||--o{ counter_offers : "genera"
  bids ||--o| shipments : "origina"
  carrier_trips ||--o{ trip_bookings : "tiene"
  shipments ||--o{ shipment_stops : "tiene"
  shipments ||--o{ documents : "contiene"
  shipments ||--o| incidents : "puede tener"
  shipments ||--o{ reviews : "genera"
  incidents ||--o{ incident_comments : "tiene"
  reviews }o--|| reputation_scores : "actualiza"
```

---

## 3. Modelo Lógico — Tablas y Tipos

### Tipos Enumerados (ENUMs)

```sql
-- Tipo de organización
CREATE TYPE org_type AS ENUM ('pyme', 'carrier', 'operator', 'admin');

-- Rol dentro de una organización
CREATE TYPE profile_role AS ENUM ('admin', 'ops', 'viewer', 'driver');

-- Tipo de vehículo
CREATE TYPE vehicle_type AS ENUM (
  'truck_small',    -- camión pequeño < 3 ton
  'truck_medium',   -- camión mediano 3–8 ton
  'truck_large',    -- camión grande 8–20 ton
  'van',            -- furgoneta < 1.5 ton
  'platform',       -- plataforma / cama baja
  'refrigerated',   -- carga refrigerada
  'tanker'          -- cisterna
);

-- Estado del vehículo
CREATE TYPE vehicle_status AS ENUM ('available', 'in_route', 'maintenance');

-- Estado del conductor
CREATE TYPE driver_status AS ENUM ('available', 'on_duty', 'off_duty');

-- Tipo de carga
CREATE TYPE cargo_type AS ENUM (
  'general',        -- carga general
  'fragile',        -- frágil
  'perishable',     -- perecedero
  'hazardous',      -- materiales peligrosos
  'bulk',           -- granel
  'oversized'       -- sobredimensionado
);

-- Estado de la solicitud de carga
CREATE TYPE request_status AS ENUM (
  'open',           -- publicada, esperando ofertas
  'auction_open',   -- subasta activa
  'matched',        -- oferta aceptada
  'in_transit',     -- en ejecución
  'delivered',      -- entregado
  'cancelled'       -- cancelado
);

-- Estado de la subasta
CREATE TYPE auction_status AS ENUM ('open', 'closed', 'cancelled');

-- Estado de la oferta
CREATE TYPE bid_status AS ENUM ('pending', 'accepted', 'rejected', 'expired');

-- Estado de la contra-oferta
CREATE TYPE counter_offer_status AS ENUM ('pending', 'accepted', 'rejected', 'expired');

-- Estado del viaje publicado por carrier
CREATE TYPE trip_status AS ENUM ('open', 'filling', 'closed', 'completed', 'cancelled');

-- Estado de reserva en viaje
CREATE TYPE booking_status AS ENUM ('confirmed', 'cancelled');

-- Estado del envío
CREATE TYPE shipment_status AS ENUM (
  'pending',        -- contrato generado, pendiente recogida
  'picked_up',      -- carga recogida en origen
  'in_transit',     -- en tránsito (puede tener paradas)
  'delivered',      -- entregado completamente
  'issue',          -- incidencia activa
  'cancelled'
);

-- Estado del escrow
CREATE TYPE escrow_status AS ENUM ('held', 'released', 'disputed', 'refunded');

-- Estado de parada
CREATE TYPE stop_status AS ENUM ('pending', 'in_route', 'arrived', 'delivered', 'issue');

-- Tipo de documento
CREATE TYPE document_type AS ENUM (
  'service_order',  -- orden de servicio
  'remission_guide',-- guía de remisión
  'receipt',        -- comprobante de pago
  'delivery_photo', -- foto de evidencia de entrega
  'signature',      -- firma digital
  'other'
);

-- Tipo de notificación
CREATE TYPE notification_type AS ENUM (
  'new_bid',
  'bid_accepted',
  'bid_rejected',
  'shipment_status_change',
  'new_review',
  'new_message',
  'counter_offer',
  'incident_reported',
  'incident_resolved',
  'smart_load_suggestion',
  'return_load_available',
  'sla_warning',
  'trip_booking'
);

-- Categoría de incidencia
CREATE TYPE incident_category AS ENUM (
  'cargo_damage',   -- carga dañada
  'delay',          -- retraso significativo
  'lost_cargo',     -- extravío
  'wrong_delivery', -- entrega incorrecta
  'driver_conduct', -- conducta del conductor
  'other'
);

-- Estado de incidencia
CREATE TYPE incident_status AS ENUM ('open', 'in_review', 'resolved', 'closed');

-- Estado de sugerencia Smart Load
CREATE TYPE suggestion_status AS ENUM ('pending', 'accepted', 'rejected', 'expired');
```

---

## 4. Diccionario de Datos

### Tabla: `organizations`
> Representa cualquier organización registrada: PYME, Transportista, Operador o Admin.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único, generado automáticamente |
| `name` | VARCHAR(200) | NO | — | Nombre comercial o razón social |
| `ruc` | VARCHAR(11) | NO | UK | RUC peruano (11 dígitos). Único en el sistema. |
| `type` | org_type | NO | — | Tipo de organización (pyme, carrier, operator, admin) |
| `verified` | BOOLEAN | NO | — | TRUE si el RUC fue validado contra SUNAT |
| `verified_at` | TIMESTAMP | SÍ | — | Fecha y hora de la verificación |
| `trust_score` | INTEGER | NO | — | Score de confianza compuesto (0–100). Default: 75 |
| `created_at` | TIMESTAMP | NO | — | Fecha de registro. Default: NOW() |

---

### Tabla: `profiles`
> Usuario individual vinculado a una organización.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `organization_id` | UUID | NO | FK → organizations | Organización a la que pertenece |
| `full_name` | VARCHAR(200) | NO | — | Nombre completo del usuario |
| `phone` | VARCHAR(15) | SÍ | — | Teléfono de contacto |
| `email` | VARCHAR(255) | NO | UK | Email de acceso al sistema |
| `password_hash` | VARCHAR(255) | SÍ | — | Hash bcrypt de la contraseña (NULL si usa OAuth) |
| `role` | profile_role | NO | — | Rol del usuario dentro de su organización |
| `consent_accepted_at` | TIMESTAMP | SÍ | — | Fecha de aceptación del consentimiento informado de tratamiento de datos (Ley N° 29733, Art. 13); NULL bloquea la activación completa de la cuenta (RNF18, SRS sección 7.2) |
| `created_at` | TIMESTAMP | NO | — | Fecha de registro |

---

### Tabla: `vehicles`
> Vehículo perteneciente a una empresa transportista.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `carrier_org_id` | UUID | NO | FK → organizations | Empresa propietaria (type='carrier') |
| `plate` | VARCHAR(10) | NO | UK | Placa del vehículo |
| `vehicle_type` | vehicle_type | NO | — | Tipo de vehículo |
| `max_weight_kg` | DECIMAL(10,2) | NO | — | Capacidad máxima de carga en kg |
| `max_volume_m3` | DECIMAL(8,2) | SÍ | — | Capacidad máxima en m³ |
| `current_weight_kg` | DECIMAL(10,2) | NO | — | Peso actualmente comprometido. Default: 0 |
| `status` | vehicle_status | NO | — | Estado actual del vehículo |
| `created_at` | TIMESTAMP | NO | — | Fecha de registro |

**Constraint:** `CHECK (current_weight_kg <= max_weight_kg)`

---

### Tabla: `drivers`
> Conductor vinculado a una empresa transportista.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `carrier_org_id` | UUID | NO | FK → organizations | Empresa empleadora |
| `full_name` | VARCHAR(200) | NO | — | Nombre completo |
| `dni` | VARCHAR(8) | NO | UK | DNI peruano (8 dígitos) |
| `license_number` | VARCHAR(20) | NO | UK | Número de licencia de conducir |
| `phone` | VARCHAR(15) | NO | — | Teléfono de contacto |
| `current_vehicle_id` | UUID | SÍ | FK → vehicles | Vehículo actualmente asignado |
| `status` | driver_status | NO | — | Estado del conductor |

---

### Tabla: `shipment_requests`
> Solicitud de transporte de carga publicada por una PYME.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `requester_org_id` | UUID | NO | FK → organizations | PYME que publica la solicitud |
| `origin_address` | VARCHAR(500) | NO | — | Dirección de origen (texto libre) |
| `origin_lat` | DECIMAL(10,7) | NO | — | Latitud del origen |
| `origin_lng` | DECIMAL(10,7) | NO | — | Longitud del origen |
| `destination_address` | VARCHAR(500) | NO | — | Dirección de destino |
| `destination_lat` | DECIMAL(10,7) | NO | — | Latitud del destino |
| `destination_lng` | DECIMAL(10,7) | NO | — | Longitud del destino |
| `weight_kg` | DECIMAL(10,2) | NO | — | Peso de la carga en kg |
| `cargo_type` | cargo_type | NO | — | Tipo de carga |
| `cargo_description` | TEXT | SÍ | — | Descripción adicional de la carga |
| `required_date` | DATE | NO | — | Fecha en que se necesita la entrega |
| `status` | request_status | NO | — | Estado actual de la solicitud |
| `suggested_price` | DECIMAL(10,2) | SÍ | — | Precio de referencia calculado por el motor de costos |
| `price_floor` | DECIMAL(10,2) | SÍ | — | Precio mínimo permitido (75% del sugerido) |
| `created_at` | TIMESTAMP | NO | — | Fecha de publicación |

---

### Tabla: `auctions`
> Subasta inversa asociada a una solicitud de carga.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `request_id` | UUID | NO | FK → shipment_requests | Solicitud asociada |
| `opens_at` | TIMESTAMP | NO | — | Momento en que se abrió la subasta |
| `closes_at` | TIMESTAMP | NO | — | Cierre programado (opens_at + 20 min por defecto) |
| `max_bids` | INTEGER | NO | — | Máximo de ofertas permitidas. Default: 5 |
| `status` | auction_status | NO | — | Estado de la subasta |

---

### Tabla: `bids`
> Oferta de un transportista en una subasta.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `auction_id` | UUID | NO | FK → auctions | Subasta en la que se oferta |
| `carrier_org_id` | UUID | NO | FK → organizations | Empresa transportista que oferta |
| `vehicle_id` | UUID | NO | FK → vehicles | Vehículo propuesto para el servicio |
| `amount` | DECIMAL(10,2) | NO | — | Precio ofertado en soles |
| `notes` | TEXT | SÍ | — | Notas adicionales del transportista |
| `status` | bid_status | NO | — | Estado de la oferta |
| `submitted_at` | TIMESTAMP | NO | — | Momento de envío de la oferta |
| `expires_at` | TIMESTAMP | NO | — | Vencimiento de la oferta (48h por defecto) |

**Constraint:** `UNIQUE (auction_id, carrier_org_id)` — Un carrier solo puede tener una oferta activa por subasta.

---

### Tabla: `counter_offers`
> Contra-oferta generada en el proceso de negociación bidireccional.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `bid_id` | UUID | NO | FK → bids | Oferta sobre la que se negocia |
| `offered_by_org_id` | UUID | NO | FK → organizations | Organización que propone el nuevo precio |
| `amount` | DECIMAL(10,2) | NO | — | Precio propuesto en la contra-oferta |
| `message` | TEXT | SÍ | — | Mensaje que acompaña la contra-oferta |
| `status` | counter_offer_status | NO | — | Estado de la contra-oferta |
| `created_at` | TIMESTAMP | NO | — | Momento de creación |

---

### Tabla: `carrier_trips`
> Viaje publicado por un transportista con capacidad disponible (supply-side listing).

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `carrier_org_id` | UUID | NO | FK → organizations | Empresa transportista |
| `vehicle_id` | UUID | NO | FK → vehicles | Vehículo asignado al viaje |
| `origin_address` | VARCHAR(500) | NO | — | Punto de partida |
| `origin_lat` | DECIMAL(10,7) | NO | — | Latitud del origen |
| `origin_lng` | DECIMAL(10,7) | NO | — | Longitud del origen |
| `destination_address` | VARCHAR(500) | NO | — | Destino final |
| `destination_lat` | DECIMAL(10,7) | NO | — | Latitud del destino |
| `destination_lng` | DECIMAL(10,7) | NO | — | Longitud del destino |
| `departure_at` | TIMESTAMP | NO | — | Fecha y hora de salida |
| `available_weight_kg` | DECIMAL(10,2) | NO | — | Capacidad disponible en kg |
| `available_volume_m3` | DECIMAL(8,2) | SÍ | — | Capacidad disponible en m³ |
| `price_per_kg` | DECIMAL(8,2) | NO | — | Precio por kg de carga |
| `status` | trip_status | NO | — | Estado del viaje |
| `created_at` | TIMESTAMP | NO | — | Fecha de publicación |

---

### Tabla: `trip_bookings`
> Reserva de espacio en un viaje disponible publicado por un transportista.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `trip_id` | UUID | NO | FK → carrier_trips | Viaje reservado |
| `requester_org_id` | UUID | NO | FK → organizations | PYME que reserva el espacio |
| `request_id` | UUID | NO | FK → shipment_requests | Solicitud de carga asociada |
| `booked_weight_kg` | DECIMAL(10,2) | NO | — | Peso reservado en kg |
| `status` | booking_status | NO | — | Estado de la reserva |
| `created_at` | TIMESTAMP | NO | — | Fecha de la reserva |

---

### Tabla: `messages`
> Mensaje en el hilo de chat de negociación entre una PYME y un transportista.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `request_id` | UUID | NO | FK → shipment_requests | Solicitud a la que pertenece el hilo |
| `carrier_org_id` | UUID | NO | FK → organizations | Transportista del hilo |
| `sender_org_id` | UUID | NO | FK → organizations | Organización que envía el mensaje |
| `body` | TEXT | NO | — | Contenido del mensaje |
| `proposed_price` | DECIMAL(10,2) | SÍ | — | Precio propuesto si el mensaje es una contra-oferta |
| `is_system` | BOOLEAN | NO | — | TRUE si es mensaje automático del sistema |
| `is_blocked` | BOOLEAN | NO | — | TRUE si fue bloqueado por contener info de contacto |
| `created_at` | TIMESTAMP | NO | — | Timestamp del mensaje |

---

### Tabla: `shipments`
> Envío activo generado al aceptar una oferta.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `request_id` | UUID | NO | FK → shipment_requests | Solicitud original |
| `bid_id` | UUID | NO | FK → bids | Oferta que originó el envío |
| `carrier_org_id` | UUID | NO | FK → organizations | Transportista asignado |
| `vehicle_id` | UUID | NO | FK → vehicles | Vehículo asignado |
| `driver_id` | UUID | SÍ | FK → drivers | Conductor asignado (asignado por el carrier) |
| `tracking_code` | VARCHAR(12) | NO | UK | Código de tracking (formato: LGX-XXXXX) |
| `status` | shipment_status | NO | — | Estado actual del envío |
| `escrow_status` | escrow_status | NO | — | Estado del pago en escrow |
| `started_at` | TIMESTAMP | SÍ | — | Momento en que el conductor recogió la carga |
| `delivered_at` | TIMESTAMP | SÍ | — | Momento de la entrega final confirmada |
| `created_at` | TIMESTAMP | NO | — | Momento de creación del envío |

---

### Tabla: `shipment_stops`
> Parada individual dentro de un envío multi-destino.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `shipment_id` | UUID | NO | FK → shipments | Envío al que pertenece |
| `request_id` | UUID | SÍ | FK → shipment_requests | Solicitud de la PYME a entregar en esta parada |
| `sequence` | INTEGER | NO | — | Orden de la parada (1, 2, 3...) |
| `location` | VARCHAR(500) | NO | — | Dirección de la parada |
| `lat` | DECIMAL(10,7) | NO | — | Latitud |
| `lng` | DECIMAL(10,7) | NO | — | Longitud |
| `eta` | TIMESTAMP | SÍ | — | Hora estimada de llegada |
| `actual_arrival` | TIMESTAMP | SÍ | — | Hora real de llegada |
| `status` | stop_status | NO | — | Estado de esta parada |
| `photo_url` | VARCHAR(500) | SÍ | — | URL de la foto de evidencia |
| `signature_url` | VARCHAR(500) | SÍ | — | URL de la firma digital del receptor |
| `cargo_weight_kg` | DECIMAL(10,2) | NO | — | Peso de la carga entregada en esta parada |

---

### Tabla: `reviews`
> Calificación post-entrega entre los participantes de un envío.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `shipment_id` | UUID | NO | FK → shipments | Envío calificado |
| `reviewer_org_id` | UUID | NO | FK → organizations | Organización que califica |
| `reviewed_org_id` | UUID | NO | FK → organizations | Organización calificada |
| `rating` | SMALLINT | NO | — | Calificación general (1–5) |
| `punctuality` | SMALLINT | SÍ | — | Calificación de puntualidad (1–5) |
| `comment` | TEXT | SÍ | — | Comentario adicional |
| `delivery_success` | BOOLEAN | NO | — | TRUE si la entrega fue exitosa |
| `delay_minutes` | INTEGER | NO | — | Minutos de retraso respecto al ETA. Default: 0 |
| `cargo_damage` | BOOLEAN | NO | — | TRUE si se reportó daño en la carga |
| `created_at` | TIMESTAMP | NO | — | Fecha de la calificación |

**Constraint:** `UNIQUE (shipment_id, reviewer_org_id)` — Un participante solo califica una vez por envío.  
**Constraint:** `CHECK (rating BETWEEN 1 AND 5)`

---

### Tabla: `reputation_scores`
> Score de reputación compuesto, calculado y mantenido por triggers.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `org_id` | UUID | NO | PK/FK → organizations | Organización evaluada |
| `delivery_success_rate` | DECIMAL(5,2) | NO | — | % de entregas sin incidencia (0–100) |
| `avg_delay_minutes` | DECIMAL(8,2) | NO | — | Retraso promedio en minutos |
| `cargo_damage_rate` | DECIMAL(5,2) | NO | — | % de entregas con daño en carga (0–100) |
| `cancellation_rate` | DECIMAL(5,2) | NO | — | % de aceptaciones que se cancelaron (0–100) |
| `avg_rating` | DECIMAL(4,2) | NO | — | Rating promedio (Bayesiano, 0–5) |
| `composite_score` | INTEGER | NO | — | Score compuesto (0–100). Default: 75 |
| `total_reviews` | INTEGER | NO | — | Total de calificaciones recibidas. Default: 0 |
| `updated_at` | TIMESTAMP | NO | — | Última actualización |

---

### Tabla: `documents`
> Archivo asociado a un envío (orden, guía, foto, firma).

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `shipment_id` | UUID | NO | FK → shipments | Envío al que pertenece |
| `stop_id` | UUID | SÍ | FK → shipment_stops | Parada específica (si aplica) |
| `type` | document_type | NO | — | Tipo de documento |
| `file_url` | VARCHAR(1000) | NO | — | URL firmada del archivo en storage |
| `file_size_bytes` | BIGINT | SÍ | — | Tamaño del archivo |
| `uploaded_by` | UUID | NO | FK → profiles | Usuario que subió el archivo |
| `created_at` | TIMESTAMP | NO | — | Fecha de subida |

---

### Tabla: `notifications`
> Notificación in-app para un usuario de una organización.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `org_id` | UUID | NO | FK → organizations | Organización destinataria |
| `type` | notification_type | NO | — | Tipo de evento que generó la notificación |
| `title` | VARCHAR(200) | NO | — | Título de la notificación |
| `body` | TEXT | NO | — | Cuerpo del mensaje |
| `related_id` | UUID | SÍ | — | ID del recurso relacionado (envío, oferta, etc.) |
| `read` | BOOLEAN | NO | — | TRUE si fue leída. Default: FALSE |
| `created_at` | TIMESTAMP | NO | — | Timestamp |

---

### Tabla: `incidents`
> Incidencia reportada durante o después de un envío.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `shipment_id` | UUID | NO | FK → shipments | Envío con incidencia |
| `reported_by_org_id` | UUID | NO | FK → organizations | Quién reportó la incidencia |
| `category` | incident_category | NO | — | Categoría de la incidencia |
| `description` | TEXT | NO | — | Descripción detallada |
| `status` | incident_status | NO | — | Estado actual |
| `resolution_notes` | TEXT | SÍ | — | Notas de la resolución (llenado por el operador) |
| `created_at` | TIMESTAMP | NO | — | Fecha del reporte |
| `resolved_at` | TIMESTAMP | SÍ | — | Fecha de resolución |

---

### Tabla: `incident_comments`
> Comentario en el hilo de una incidencia.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `incident_id` | UUID | NO | FK → incidents | Incidencia a la que pertenece |
| `author_org_id` | UUID | NO | FK → organizations | Organización que comenta |
| `body` | TEXT | NO | — | Contenido del comentario |
| `created_at` | TIMESTAMP | NO | — | Timestamp |

---

### Tabla: `cost_calculations`
> Registro del cálculo de costo logístico para una solicitud.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `request_id` | UUID | NO | FK → shipment_requests | Solicitud asociada |
| `distance_km` | DECIMAL(8,2) | NO | — | Distancia por carretera real (ORS) |
| `duration_min` | DECIMAL(8,2) | NO | — | Tiempo estimado de viaje en minutos |
| `toll_cost` | DECIMAL(10,2) | NO | — | Estimado de peajes |
| `fuel_cost` | DECIMAL(10,2) | NO | — | Estimado de combustible |
| `base_transport_cost` | DECIMAL(10,2) | NO | — | Tarifa base de transporte |
| `handling_fee` | DECIMAL(10,2) | NO | — | Tarifa de manipuleo |
| `total_estimate` | DECIMAL(10,2) | NO | — | Total estimado (suma de todos los componentes) |
| `calculated_at` | TIMESTAMP | NO | — | Momento del cálculo |

---

### Tabla: `smart_load_suggestions`
> Sugerencia de combinación de cargas generada por el Smart Load Planner.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `carrier_org_id` | UUID | NO | FK → organizations | Transportista al que se sugiere |
| `vehicle_id` | UUID | NO | FK → vehicles | Vehículo propuesto |
| `request_ids` | UUID[] | NO | — | Array de IDs de solicitudes compatibles |
| `combined_income` | DECIMAL(10,2) | NO | — | Ingreso combinado estimado |
| `occupancy_pct` | DECIMAL(5,2) | NO | — | % de ocupación del vehículo |
| `route_plan` | JSONB | NO | — | Plan de ruta con paradas ordenadas |
| `status` | suggestion_status | NO | — | Estado de la sugerencia |
| `created_at` | TIMESTAMP | NO | — | Momento de generación |
| `expires_at` | TIMESTAMP | NO | — | Vencimiento de la sugerencia (4h por defecto) |

---

### Tabla: `audit_log`
> Registro de auditoría de acciones críticas del sistema.

| Columna | Tipo | Nulo | PK/FK/UK | Descripción |
|---------|------|------|-----------|-------------|
| `id` | UUID | NO | PK | Identificador único |
| `table_name` | VARCHAR(100) | NO | — | Nombre de la tabla afectada |
| `action` | VARCHAR(10) | NO | — | Tipo de acción: INSERT, UPDATE, DELETE |
| `record_id` | UUID | NO | — | ID del registro afectado |
| `performed_by` | UUID | SÍ | FK → profiles | Usuario que realizó la acción (NULL si es sistema) |
| `old_values` | JSONB | SÍ | — | Valores anteriores al cambio |
| `new_values` | JSONB | SÍ | — | Valores nuevos tras el cambio |
| `performed_at` | TIMESTAMP | NO | — | Timestamp de la acción |

---

## 5. Índices Principales

| Tabla | Columna(s) | Tipo | Propósito |
|-------|-----------|------|-----------|
| `shipment_requests` | `(status, required_date)` | B-tree | Filtrar solicitudes abiertas por fecha |
| `shipment_requests` | `(origin_lat, origin_lng)` | B-tree | Búsqueda geoespacial de cargas cercanas |
| `shipment_requests` | `requester_org_id` | B-tree | Mis solicitudes por organización |
| `bids` | `(auction_id, status)` | B-tree | Ofertas por subasta |
| `bids` | `(carrier_org_id, status)` | B-tree | Mis ofertas como carrier |
| `shipments` | `tracking_code` | B-tree único | Búsqueda por tracking code |
| `shipments` | `(carrier_org_id, status)` | B-tree | Mis envíos como carrier |
| `notifications` | `(org_id, read, created_at)` | B-tree | Notificaciones no leídas por org |
| `messages` | `(request_id, carrier_org_id)` | B-tree | Hilo de chat |
| `reviews` | `reviewed_org_id` | B-tree | Reseñas de un actor |
| `carrier_trips` | `(status, departure_at)` | B-tree | Viajes disponibles próximos |
| `carrier_trips` | `(origin_lat, origin_lng)` | B-tree | Viajes cercanos al origen |
| `audit_log` | `(table_name, record_id)` | B-tree | Historial de auditoría por registro |

---

## 6. Consistencia con el Sistema

| Componente del sistema | Tabla(s) que soporta |
|------------------------|---------------------|
| Auth y registro multi-rol | `organizations`, `profiles` |
| Marketplace + Subasta inversa | `shipment_requests`, `auctions`, `bids` |
| Publicación de viajes (supply-side) | `carrier_trips`, `trip_bookings` |
| Negociación bidireccional | `messages`, `counter_offers` |
| Motor de costos | `cost_calculations` |
| Smart Load Planner | `smart_load_suggestions` |
| Tracking multi-parada | `shipments`, `shipment_stops` |
| Sistema de reputación | `reviews`, `reputation_scores` |
| Gestión documental | `documents` |
| Notificaciones | `notifications` |
| Incidencias y disputas | `incidents`, `incident_comments` |
| Panel del Operador | Consultas sobre todas las tablas (rol operator) |
| Cargas de retorno | Consultas sobre `shipment_requests` + `shipments` |
| Gestión de flota | `vehicles`, `drivers` |
| Auditoría | `audit_log` |

---

*LOGYX · E2 Modelo de Base de Datos · Competencia CE0221 · Versión 1.0 · Junio 2026*
