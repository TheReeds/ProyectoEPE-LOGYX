# E1 — Modelado Técnico UML
> Competencia CE0214 · Diagramas estructurales y de comportamiento  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Herramienta: Mermaid  
> Versión: 2.0 (alineada con el código) · Noviembre 2026 · Versión original 1.0, junio 2026

!!! info "Alineación con el sistema construido"
    Los diagramas de la v1.0 se rehicieron a partir del código del backend (`pe.logyx.*`), de las migraciones Flyway V1–V12 y del contrato OpenAPI (corte de la fase 6; el sistema llegó luego a V24, con los módulos nuevos descritos en la [Arquitectura](arquitectura.md)). Los nombres de clases, estados y endpoints son los reales. Lo que el diseño inicial planteaba y no se construyó (Google OAuth, ORS, email, código `LGX-XXXXX`, estado de envío `ISSUE`) ya no aparece, o se marca como pendiente.

---

## 1. Diagramas de Casos de Uso

### 1.1 Sistema completo por actor

```mermaid
graph LR
  PYME((PYME))
  CAR((Transportista))
  DRV((Conductor))
  OPE((Operador))

  subgraph OnCargo["Sistema OnCargo (casos de uso implementados)"]
    A1[Registrarse con consentimiento Ley 29733]
    A2[Iniciar sesión]
    A3[Publicar solicitud con cotización en vivo]
    A4[Comparar ofertas y aceptar]
    A5[Negociar: chat y contraoferta]
    A6[Seguir el envío en mapa y en vivo]
    A7[Calificar al transportista]
    A8[Reportar incidencia]
    A9[Buscar viajes y reservar espacio]

    B1[Ver marketplace con filtros]
    B2[Ofertar a la subasta]
    B3[Gestionar flota y conductores]
    B4[Asignar conductor al envío]
    B5[Publicar viaje y confirmar reservas]
    B6[Cargas de retorno]
    B7[Aceptar sugerencia Smart Load]

    C1[Ver viaje activo]
    C2[Marcar llegada y completar parada]
    C3[Subir foto de entrega y firma]

    D1[Ver métricas y alertas SLA]
    D2[Asignar transportista manualmente RN10]
    D3[Gestionar incidencias]
  end

  PYME --- A1 & A2 & A3 & A4 & A5 & A6 & A7 & A8 & A9
  CAR --- A1 & A2 & A5 & A8 & B1 & B2 & B3 & B4 & B5 & B6 & B7
  DRV --- A2 & C1 & C2 & C3 & A8
  OPE --- A2 & D1 & D2 & D3
```

Ver notificaciones, documentos del envío y el perfil público de reputación son casos de uso transversales (PYME, transportista y operador). El conductor solo usa la app Android o la página `/conductor` de la web; el operador usa solo la web.

### 1.2 Casos de uso — Marketplace y subastas (detalle)

| Caso de uso | Actor | Precondiciones | Reglas | Módulo |
|---|---|---|---|---|
| Publicar solicitud | PYME | RUC verificado | RN01, cotización RN03 | `marketplace.PublishRequestUseCase` |
| Ofertar | Transportista | Subasta abierta, vehículo propio con capacidad | RN02, RN03, RN04 | `marketplace.PlaceBidUseCase` |
| Cierre automático | Sistema | 20 min o 5 ofertas | RN04 | `CloseExpiredAuctionsUseCase`, `AuctionScheduler` |
| Aceptar oferta | PYME | Oferta `PENDING` | RN05 | `marketplace.AcceptBidUseCase` |
| Contraofertar | PYME / Transportista | Oferta pendiente; mensaje sin contacto | RN07, RN03 (≥ piso) | `negotiation.NegotiationService` |
| Asignación manual | Operador | Solicitud sin ofertas ≥ 24 h | RN10 | `marketplace.ManualAssignmentUseCase` |

### 1.3 Casos de uso — Ejecución y evidencia (detalle)

| Caso de uso | Actor | Reglas | Módulo |
|---|---|---|---|
| Asignar conductor | Transportista | conductor de su organización | `shipment.AssignDriverUseCase` |
| Marcar llegada / completar parada | Conductor | RN08 (orden), RN11 (sin incidencia activa), foto obligatoria en la entrega (`LOGYX-TRK-006`) | `shipment.TrackStopsUseCase` |
| Subir evidencia | Conductor / partes | firma binaria jpg/png/pdf, ≤ 10 MB | `documents` |
| Reportar incidencia | Partes y conductor | RN11 | `incident.IncidentService` |
| Resolver incidencia | Operador | notas de resolución obligatorias | `incident.IncidentStatusPolicy` |
| Calificar | PYME / transportista | RN06 (entregado + foto) | `reputation.ReviewService` |

---

## 2. Diagrama de Clases (dominio real)

### 2.1 Organizaciones, flota y marketplace

```mermaid
classDiagram
  class Organization {
    UUID id
    OrgType type [PYME, CARRIER, OPERATOR]
    String legalName
    String ruc
    RucVerification rucVerification [NONE, CHECKSUM, SUNAT]
    String city
  }
  class Profile {
    UUID id
    UUID organizationId
    String email
    String fullName
    Role role [ADMIN, OPS, VIEWER, DRIVER]
    boolean active
    Instant consentAcceptedAt
  }
  class Vehicle {
    UUID id
    UUID organizationId
    String plate
    Type type
    BigDecimal maxWeightKg
    Status status [AVAILABLE, IN_ROUTE, MAINTENANCE]
  }
  class Driver {
    UUID id
    UUID organizationId
    UUID profileId
    String licenseNumber
    Status status
  }
  class ShipmentRequest {
    UUID id
    UUID requesterOrgId
    Cargo cargo
    Pricing pricing [distanceKm, suggestedPrice, priceFloor]
    Status status [PUBLISHED, MATCHED, CANCELLED]
    UUID assignedCarrierOrgId
    publish()
    matchTo(carrierOrgId)
    cancel()
  }
  class Auction {
    UUID id
    UUID requestId
    OffsetDateTime closesAt
    int maxBids
    Status status [OPEN, CLOSED, CANCELLED]
    CloseReason closeReason
    acceptsBids(now)
    close(reason, now)
  }
  class Bid {
    UUID id
    UUID auctionId
    UUID carrierOrgId
    UUID vehicleId
    BigDecimal amount
    Status status [PENDING, ACCEPTED, REJECTED]
    boolean assignedByOperator
    place()
    accept()
    reject()
    reviseAmount(newAmount)
  }
  Organization "1" --> "*" Profile
  Organization "1" --> "*" Vehicle : CARRIER
  Organization "1" --> "*" Driver : CARRIER
  Driver "1" --> "1" Profile
  Organization "1" --> "*" ShipmentRequest : PYME
  ShipmentRequest "1" --> "1" Auction
  Auction "1" --> "*" Bid
  Bid "*" --> "1" Vehicle
  Bid "*" --> "1" Organization : carrier
```

### 2.2 Ejecución, confianza y comunicación

```mermaid
classDiagram
  class Shipment {
    UUID id
    UUID requestId
    UUID bidId
    UUID requesterOrgId
    UUID carrierOrgId
    UUID vehicleId
    UUID driverId
    BigDecimal agreedPrice
    String vehiclePlate
    String driverName
    Status status [PENDING, IN_TRANSIT, DELIVERED, CANCELLED]
  }
  class ShipmentStop {
    UUID id
    int sequence
    Type type [PICKUP, DELIVERY]
    Status status [PENDING, ARRIVED, COMPLETED]
    arrive(now)
    complete(now)
  }
  class Document {
    UUID id
    UUID shipmentId
    UUID stopId
    DocumentType type [SERVICE_ORDER, REMISSION_GUIDE, RECEIPT, DELIVERY_PHOTO, SIGNATURE...]
    String storageKey
    String sha256
  }
  class Incident {
    UUID id
    UUID shipmentId
    Category category
    IncidentStatus status [OPEN, IN_REVIEW, RESOLVED, CLOSED]
    isActive()
  }
  class IncidentComment
  class Review {
    UUID id
    Direction direction [PYME_TO_CARRIER, CARRIER_TO_PYME]
    int punctuality
    int cargoCondition
    int communication
    BigDecimal rating
  }
  class ReputationScore {
    UUID organizationId
    BigDecimal trustScore [prior 75]
  }
  class Message {
    UUID requestId
    UUID carrierOrgId
    String body
  }
  class CounterOffer {
    UUID bidId
    BigDecimal amount
    Status status [PENDING, ACCEPTED, REJECTED, EXPIRED]
    propose()
  }
  class Notification {
    UUID orgId
    NotificationType type
    Instant readAt
  }
  Shipment "1" --> "2..*" ShipmentStop
  Shipment "1" --> "*" Document
  Shipment "1" --> "*" Incident
  Incident "1" --> "*" IncidentComment
  Shipment "1" --> "0..2" Review
  Review ..> ReputationScore : recalcula
  Message ..> CounterOffer : misma negociación
  Notification ..> Shipment : relacionada
```

### 2.3 Viajes publicados, reservas y Smart Load

```mermaid
classDiagram
  class CarrierTrip {
    UUID id
    UUID carrierOrgId
    UUID vehicleId
    String originCity
    String destinationCity
    OffsetDateTime departureAt
    BigDecimal capacityKg
    BigDecimal confirmedWeightKg
    PricingMode pricingMode [PER_KG, PER_TRIP]
    Status status [OPEN, FILLING, CLOSED, COMPLETED, CANCELLED]
  }
  class TripBooking {
    UUID id
    UUID tripId
    UUID requesterOrgId
    BigDecimal weightKg
    BigDecimal price
    Status status [PENDING, CONFIRMED, REJECTED, CANCELLED]
    UUID requestId
    UUID shipmentId
  }
  class SmartLoadSuggestion {
    UUID id
    UUID carrierOrgId
    BigDecimal combinedIncome
    BigDecimal occupancyPct
    Status status [PENDING, ACCEPTED, REJECTED, EXPIRED]
  }
  class SmartLoadItem {
    UUID requestId
    int pickupOrder
    int deliveryOrder
  }
  CarrierTrip "1" --> "*" TripBooking
  SmartLoadSuggestion "1" --> "2..*" SmartLoadItem
  TripBooking ..> Shipment : al confirmar (DirectContractUseCase)
  SmartLoadItem ..> ShipmentRequest
```

Las reglas de negocio viven en clases de dominio sin estado (políticas): `PriceFloorPolicy` (RN03), `BidEligibilityPolicy` (RN02/RN03), `AuctionClosingPolicy` (RN04), `StopSequencePolicy` (RN08), `TrustScoreCalculator` (RN09), `ManualAssignmentPolicy` (RN10), `IncidentStatusPolicy` (RN11), `TripCapacityPolicy` (RN12), `ContactInfoPolicy` (RN07) y `ReviewEligibilityPolicy` (RN06).

---

## 3. Diagramas de Secuencia

### 3.1 Flujo principal: publicar → ofertar → aceptar → envío → entrega con evidencia

```mermaid
sequenceDiagram
  actor PYME
  actor CAR as Transportista
  actor DRV as Conductor
  participant API as API Quarkus
  participant DB as PostgreSQL (RLS)
  participant OB as Outbox / realtime_events
  participant S3 as MinIO (API S3)

  PYME->>API: POST /pricing/calculate (cotización en vivo)
  API-->>PYME: distancia por carretera (RoadDistanceProvider), precio sugerido, piso 75 %
  PYME->>API: POST /shipment-requests
  Note over API: RN01 RUC verificado · PublishRequestUseCase
  API->>DB: INSERT shipment_requests (PUBLISHED) + auctions (OPEN, 20 min, 5 ofertas)

  CAR->>API: POST /shipment-requests/{id}/bids
  Note over API: RN02 vehículo propio con capacidad · RN03 monto ≥ piso
  API->>DB: INSERT bids (PENDING)
  API->>OB: BidPlaced (misma transacción)
  OB-->>PYME: SSE bid.placed + notificación NEW_BID

  alt 5 ofertas o vencen 20 min (RN04)
    API->>DB: auction CLOSED (MAX_BIDS / TIMEOUT)
  end

  PYME->>API: POST /bids/{id}/accept
  Note over API: AcceptBidUseCase · RN05
  API->>DB: bid ACCEPTED, resto REJECTED, request MATCHED
  API->>DB: INSERT shipments (PENDING) + shipment_stops (PICKUP, DELIVERY)
  API->>OB: BidAccepted -> aviso al transportista

  CAR->>API: PUT /shipments/{id}/driver
  DRV->>API: POST /shipments/{id}/stops/{stopId}/arrive
  Note over API: RN08 orden secuencial · RN11 sin incidencia activa
  API->>DB: shipment IN_TRANSIT (primera llegada)
  DRV->>API: POST /shipments/{id}/documents (DELIVERY_PHOTO, multipart)
  API->>S3: put(shipments/{id}/{docId}.jpg), SHA-256
  DRV->>API: POST /shipments/{id}/stops/{stopId}/complete
  Note over API: DeliveryEvidencePolicy: exige foto (LOGYX-TRK-006)
  API->>DB: parada COMPLETED, y si es la última: shipment DELIVERED
  API->>OB: ShipmentStatusChanged -> SSE shipment.* a PYME y transportista

  PYME->>API: POST /shipments/{id}/reviews
  Note over API: RN06 entregado + foto
  API->>OB: ReviewSubmitted -> ReputationRecalculator (RN09)
```

### 3.2 Flujo: negociación con contraoferta y bloqueo de contacto (RN07)

```mermaid
sequenceDiagram
  actor PYME
  actor CAR as Transportista
  participant API as API Quarkus
  participant DB as PostgreSQL

  CAR->>API: POST /shipment-requests/{id}/threads/{org}/messages "llámame al 987 654 321"
  API-->>CAR: 400 LOGYX-NEG-001 (field body) - RN07 ContactInfoPolicy
  CAR->>API: mensaje sin datos de contacto
  API->>DB: INSERT messages
  PYME->>API: POST /bids/{id}/counter-offers {amount, message}
  Note over API: CounterOffer.propose: monto ≥ piso (RN03), una pendiente por oferta
  API->>DB: INSERT counter_offers (PENDING)
  CAR->>API: POST /counter-offers/{id}/accept
  API->>DB: counter PENDING a ACCEPTED y bid.reviseAmount(amount)
```

### 3.3 Flujo: tiempo real (outbox → SSE)

```mermaid
sequenceDiagram
  participant UC as Caso de uso (transacción)
  participant OB as outbox_events
  participant DSP as OutboxDispatcher (SystemTx)
  participant PRJ as RealtimeProjector
  participant RT as realtime_events
  participant LST as PgRealtimeListener (LISTEN)
  participant HUB as RealtimeHub
  participant CLI as Cliente SSE (web/Android)

  UC->>OB: INSERT evento (misma transacción de negocio)
  UC-->>DSP: commit -> despacho inmediato (y job cada 5 s)
  DSP->>PRJ: @Outboxed -> proyecta una fila por destinatario
  PRJ->>RT: INSERT (org / usuario / difusión por tipo)
  RT-->>LST: pg_notify('logyx_realtime', seq) al confirmar
  LST->>HUB: seq
  HUB->>RT: lee la fila real (SystemTx)
  HUB-->>CLI: event (solo si cumple RealtimeAudiencePolicy)
  CLI->>CLI: refresca por REST (aviso, no dato)
```

### 3.4 Flujo: reserva de espacio en un viaje publicado

```mermaid
sequenceDiagram
  actor CAR as Transportista
  actor PYME
  participant API as API Quarkus
  participant DB as PostgreSQL

  CAR->>API: POST /trips (RN12 capacidad ≤ maxWeightKg del vehículo)
  PYME->>API: POST /trips/{id}/bookings {weightKg, cargo...}
  Note over API: BookingService.book: TripCapacityPolicy.ensureFits
  API->>DB: INSERT trip_bookings (PENDING)
  CAR->>API: POST /trip-bookings/{id}/confirm
  Note over API: DirectContractUseCase
  API->>DB: request MATCHED + bid + shipment, trip FILLING o CLOSED
```

---

## 4. Diagramas de Estados

### 4.1 Solicitud y subasta

```mermaid
stateDiagram-v2
  [*] --> PUBLISHED : PYME publica (RN01)
  PUBLISHED --> MATCHED : PYME acepta oferta / contraoferta / asignación del operador
  PUBLISHED --> CANCELLED : PYME cancela
  MATCHED --> [*]
  CANCELLED --> [*]

  state "Subasta" as SUB {
    [*] --> OPEN
    OPEN --> CLOSED : TIMEOUT (20 min) o MAX_BIDS (5)
    OPEN --> CLOSED : ACCEPTED
    OPEN --> CANCELLED : solicitud cancelada
  }
```

Una oferta (`Bid`) pasa de `PENDING` a `ACCEPTED` o `REJECTED` (RN05).

### 4.2 Envío y parada

```mermaid
stateDiagram-v2
  [*] --> PENDING : oferta aceptada, paradas planificadas
  PENDING --> IN_TRANSIT : conductor marca la primera llegada
  IN_TRANSIT --> DELIVERED : última parada completada con foto (RN06)
  PENDING --> CANCELLED
  DELIVERED --> [*]
  CANCELLED --> [*]
  note right of IN_TRANSIT
    Con una incidencia OPEN o IN_REVIEW el estado
    no avanza (RN11, LOGYX-TRK-005). No existe
    un estado ISSUE: se expone ShipmentView.hasActiveIncident.
  end note
```

```mermaid
stateDiagram-v2
  [*] --> PENDING
  PENDING --> ARRIVED : arrive (RN08, solo la siguiente en orden)
  ARRIVED --> COMPLETED : complete (entrega exige DELIVERY_PHOTO)
  COMPLETED --> [*]
```

### 4.3 Incidencia, reserva y sugerencia

```mermaid
stateDiagram-v2
  [*] --> OPEN : parte o conductor reporta
  OPEN --> IN_REVIEW : operador
  OPEN --> RESOLVED : operador (notas obligatorias)
  IN_REVIEW --> RESOLVED
  OPEN --> CLOSED : descartada
  IN_REVIEW --> CLOSED
  RESOLVED --> CLOSED
  CLOSED --> [*]
```

```mermaid
stateDiagram-v2
  [*] --> PENDING : PYME reserva
  PENDING --> CONFIRMED : transportista confirma (crea envío)
  PENDING --> REJECTED : transportista rechaza o BookingSweeper
  PENDING --> CANCELLED : PYME cancela / viaje cancelado
  CONFIRMED --> CANCELLED : PYME cancela
```

Los viajes (`CarrierTrip`) recorren `OPEN → FILLING → CLOSED → COMPLETED` o `CANCELLED`; las sugerencias Smart Load, `PENDING → ACCEPTED | REJECTED | EXPIRED`.

---

## 5. Diagrama de Componentes — Web (Astro) y Android

```mermaid
graph TD
  subgraph Web["Web Astro SSR"]
    MW["middleware.ts<br/>sesión, rol, 401 a /login"]
    PG["pages/ (rutas finas por rol)"]
    FT["features/*/server.ts + actions.ts"]
    UI["components/{ui, domain, layout}<br/>islas React"]
    LIB["lib/{api (openapi-fetch), session, realtime}"]
    PX["proxies: /eventos (SSE), /documentos"]
  end
  subgraph Android["Android multi-módulo"]
    APP[":app (navegación por rol, Koin)"]
    FEA[":feature:* (Screen + ViewModel + UiState)"]
    DATA[":core:data (repositorios, sesión DataStore)"]
    NET[":core:network (Ktor, DTOs, SSE)"]
    MOD[":core:model (Kotlin puro)"]
    DS[":core:designsystem (Compose)"]
  end
  MW --> PG --> FT --> LIB
  PG --> UI
  LIB -->|OpenAPI| API[("API Quarkus")]
  PX --> API
  APP --> FEA --> DATA --> NET --> API
  NET --> MOD
  FEA --> DS
```

Detalle de ambos clientes en [Arquitectura Frontend](../entregable-3/arquitectura-frontend.md).

---

*OnCargo · E1 Modelado Técnico UML · Competencia CE0214 · Versión 2.0 · Noviembre 2026*
