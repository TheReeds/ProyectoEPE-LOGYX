# E1 — Modelado Técnico UML
> Competencia CE0214 · Diagramas estructurales y de comportamiento  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Herramienta: Mermaid (exportar a imagen para entrega formal)  
> Versión: 1.0 · Junio 2026

---

## 1. Diagrama de Casos de Uso

### 1.1 Sistema Completo — Vista General

```mermaid
graph LR
  subgraph Sistema LOGYX
    UC1[Registrarse y verificar RUC]
    UC2[Iniciar sesión]
    UC3[Publicar solicitud de carga]
    UC4[Ver subasta y recibir ofertas]
    UC5[Negociar precio]
    UC6[Aceptar oferta]
    UC7[Ver tracking del envío]
    UC8[Calificar contraparte]
    UC9[Gestionar documentos]
    UC10[Reportar incidencia]

    UC11[Ver marketplace de cargas]
    UC12[Ofertar en subasta]
    UC13[Publicar viaje disponible]
    UC14[Ver Smart Load Plan]
    UC15[Ver cargas de retorno]
    UC16[Actualizar estado del envío]
    UC17[Subir evidencia de entrega]

    UC18[Ver dashboard global]
    UC19[Asignar carrier manualmente]
    UC20[Gestionar incidencias]

    UC21[Ver ruta asignada]
    UC22[Actualizar parada]
    UC23[Capturar firma y foto]
  end

  PYME((PYME)) --> UC1
  PYME --> UC2
  PYME --> UC3
  PYME --> UC4
  PYME --> UC5
  PYME --> UC6
  PYME --> UC7
  PYME --> UC8
  PYME --> UC9
  PYME --> UC10

  Carrier((Transportista)) --> UC1
  Carrier --> UC2
  Carrier --> UC11
  Carrier --> UC12
  Carrier --> UC13
  Carrier --> UC14
  Carrier --> UC15
  Carrier --> UC5
  Carrier --> UC8
  Carrier --> UC9

  Driver((Conductor)) --> UC2
  Driver --> UC21
  Driver --> UC22
  Driver --> UC23
  Driver --> UC10

  Operator((Operador)) --> UC18
  Operator --> UC19
  Operator --> UC20
  Operator --> UC16
```

---

### 1.2 Casos de Uso — Módulo Marketplace y Subastas (detalle)

```mermaid
graph LR
  subgraph Marketplace y Subastas
    A[Publicar solicitud de carga]
    B[Sistema calcula precio sugerido]
    C[Sistema abre subasta automática]
    D[Ver solicitudes en marketplace]
    E[Ofertar en subasta]
    F[Validar price floor]
    G[Validar capacidad disponible]
    H[Ver ranking de ofertas]
    I[Negociar con contra-oferta]
    J[Aceptar oferta]
    K[Sistema cierra subasta y notifica]
  end

  PYME((PYME)) --> A
  A -.include.-> B
  A -.include.-> C
  D -.include.-> F
  D -.include.-> G
  Carrier((Transportista)) --> D
  Carrier --> E
  E -.include.-> F
  E -.include.-> G
  PYME --> H
  PYME --> I
  Carrier --> I
  PYME --> J
  J -.include.-> K
```

---

### 1.3 Casos de Uso — Módulo Tracking y Driver (detalle)

```mermaid
graph LR
  subgraph Tracking y Ejecución
    T1[Ver ruta asignada]
    T2[Navegar a parada]
    T3[Marcar estado de parada]
    T4[Tomar foto de entrega]
    T5[Capturar firma digital]
    T6[Reportar incidencia en ruta]
    T7[Ver tracking en mapa]
    T8[Ver historial de estados]
  end

  Driver((Conductor)) --> T1
  Driver --> T2
  Driver --> T3
  T3 -.include.-> T4
  T3 -.include.-> T5
  Driver --> T6
  PYME((PYME)) --> T7
  PYME --> T8
  Operator((Operador)) --> T7
  Operator --> T8
```

---

## 2. Diagrama de Clases (Alto Nivel)

```mermaid
classDiagram
  class Organization {
    +UUID id
    +String name
    +String ruc
    +OrgType type
    +Boolean verified
    +LocalDateTime verifiedAt
    +Integer trustScore
    +LocalDateTime createdAt
    +verify() void
    +calculateTrustScore() Integer
  }

  class Profile {
    +UUID id
    +UUID organizationId
    +String fullName
    +String phone
    +ProfileRole role
    +LocalDateTime createdAt
  }

  class Vehicle {
    +UUID id
    +UUID carrierOrgId
    +String plate
    +VehicleType vehicleType
    +Double maxWeightKg
    +Double maxVolumeM3
    +Double currentWeightKg
    +VehicleStatus status
    +Double availableCapacity()
  }

  class Driver {
    +UUID id
    +UUID carrierOrgId
    +String fullName
    +String licenseNumber
    +UUID currentVehicleId
    +DriverStatus status
  }

  class ShipmentRequest {
    +UUID id
    +UUID requesterOrgId
    +String originAddress
    +Double originLat
    +Double originLng
    +String destinationAddress
    +Double destinationLat
    +Double destinationLng
    +Double weightKg
    +CargoType cargoType
    +LocalDate requiredDate
    +RequestStatus status
    +Double suggestedPrice
    +LocalDateTime createdAt
    +open() void
    +match() void
  }

  class Auction {
    +UUID id
    +UUID requestId
    +LocalDateTime opensAt
    +LocalDateTime closesAt
    +Integer maxBids
    +AuctionStatus status
    +close() void
    +isExpired() Boolean
  }

  class Bid {
    +UUID id
    +UUID auctionId
    +UUID carrierOrgId
    +UUID vehicleId
    +Double amount
    +String notes
    +BidStatus status
    +LocalDateTime submittedAt
    +accept() void
    +reject() void
    +validatePriceFloor(Double minPrice) Boolean
  }

  class CounterOffer {
    +UUID id
    +UUID bidId
    +UUID offeredByOrgId
    +Double amount
    +String message
    +CounterOfferStatus status
    +LocalDateTime createdAt
    +accept() void
  }

  class CarrierTrip {
    +UUID id
    +UUID carrierOrgId
    +UUID vehicleId
    +String originAddress
    +String destinationAddress
    +LocalDateTime departureAt
    +Double availableWeightKg
    +Double pricePerKg
    +TripStatus status
    +addBooking(TripBooking) void
    +remainingCapacity() Double
  }

  class Shipment {
    +UUID id
    +UUID requestId
    +UUID bidId
    +UUID carrierOrgId
    +UUID vehicleId
    +UUID driverId
    +String trackingCode
    +ShipmentStatus status
    +LocalDateTime startedAt
    +LocalDateTime deliveredAt
    +advanceStatus(ShipmentStatus) void
    +generateTrackingCode() String
  }

  class ShipmentStop {
    +UUID id
    +UUID shipmentId
    +Integer sequence
    +String location
    +Double lat
    +Double lng
    +LocalDateTime eta
    +LocalDateTime actualArrival
    +StopStatus status
    +UUID requestId
    +confirm(String photoUrl, String signatureUrl) void
  }

  class Message {
    +UUID id
    +UUID requestId
    +UUID carrierOrgId
    +UUID senderOrgId
    +String body
    +Double proposedPrice
    +LocalDateTime createdAt
    +containsContactInfo() Boolean
  }

  class Review {
    +UUID id
    +UUID shipmentId
    +UUID reviewerOrgId
    +UUID reviewedOrgId
    +Integer rating
    +Integer punctuality
    +String comment
    +Boolean deliverySuccess
    +Integer delayMinutes
    +LocalDateTime createdAt
  }

  class ReputationScore {
    +UUID orgId
    +Double deliverySuccessRate
    +Double avgDelayMinutes
    +Double cargoDamageRate
    +Double cancellationRate
    +Double avgRating
    +Integer compositeScore
    +LocalDateTime updatedAt
    +recalculate() void
  }

  class Document {
    +UUID id
    +UUID shipmentId
    +UUID stopId
    +DocumentType type
    +String fileUrl
    +UUID uploadedBy
    +LocalDateTime createdAt
  }

  class Notification {
    +UUID id
    +UUID orgId
    +NotificationType type
    +String title
    +String body
    +UUID relatedId
    +Boolean read
    +LocalDateTime createdAt
    +markAsRead() void
  }

  class Incident {
    +UUID id
    +UUID shipmentId
    +UUID reportedByOrgId
    +IncidentCategory category
    +String description
    +IncidentStatus status
    +LocalDateTime createdAt
    +resolve(ShipmentStatus finalStatus) void
  }

  class CostCalculation {
    +UUID id
    +UUID requestId
    +Double distanceKm
    +Double durationMin
    +Double tollCost
    +Double fuelCost
    +Double baseTransportCost
    +Double totalEstimate
    +LocalDateTime calculatedAt
  }

  Organization "1" --> "*" Profile : tiene
  Organization "1" --> "*" Vehicle : posee
  Organization "1" --> "*" Driver : emplea
  Organization "1" --> "*" ShipmentRequest : crea
  Organization "1" --> "*" CarrierTrip : publica
  Organization "1" --> "1" ReputationScore : tiene
  ShipmentRequest "1" --> "1" Auction : genera
  ShipmentRequest "1" --> "1" CostCalculation : tiene
  Auction "1" --> "*" Bid : recibe
  Bid "1" --> "*" CounterOffer : genera
  Bid "1" --> "0..1" Shipment : origina
  Shipment "1" --> "*" ShipmentStop : tiene
  Shipment "1" --> "*" Document : contiene
  Shipment "1" --> "0..1" Incident : puede tener
  Shipment "1" --> "0..2" Review : genera
  ShipmentRequest "1" --> "*" Message : tiene hilo
  Incident "1" --> "*" Message : tiene hilo
  Review "*" --> "1" ReputationScore : actualiza
```

---

## 3. Diagramas de Secuencia

### 3.1 Flujo: PYME publica solicitud y se abre la subasta

```mermaid
sequenceDiagram
  actor PYME
  participant Web as Angular Web
  participant API as Quarkus API
  participant Pricing as pricing-module
  participant ORS as OpenRouteService
  participant DB as PostgreSQL
  participant Notif as notification-module
  participant Carrier as Transportista

  PYME->>Web: Completa formulario de solicitud
  Web->>API: POST /api/shipments/requests
  API->>ORS: GET /directions?origin=Lima&dest=Juliaca
  ORS-->>API: {distance_km: 1294, duration_min: 1245, geometry: [...]}
  API->>Pricing: calculateSuggestedPrice(distance, weight, cargoType)
  Pricing-->>API: {suggestedPrice: 1200, priceFloor: 900}
  API->>DB: INSERT shipment_request (status='open', suggested_price=1200)
  API->>DB: INSERT auction (closes_at=NOW()+20min, max_bids=5, status='open')
  API->>DB: INSERT cost_calculation (distance=1294, fuel=180, tolls=120, total=1200)
  API-->>Web: 201 {requestId, suggestedPrice: 1200, auctionId, closesAt}
  Web-->>PYME: Muestra solicitud creada con precio referencial y subasta activa

  API->>Notif: notifyCompatibleCarriers(requestId, route)
  Notif->>DB: Query carriers con zonas compatibles
  Notif-->>Carrier: Push/Email: "Nueva carga Lima→Juliaca · 2 ton · S/ 1,200 ref."
```

---

### 3.2 Flujo: Transportista oferta y PYME acepta

```mermaid
sequenceDiagram
  actor Carrier as Transportista
  actor PYME
  participant App as Flutter Business
  participant API as Quarkus API
  participant Auction as auction-module
  participant DB as PostgreSQL
  participant Notif as notification-module

  Carrier->>App: Ve marketplace, selecciona solicitud
  App->>API: GET /api/marketplace (filtrado por perfil del carrier)
  API-->>App: Lista rankeada de solicitudes abiertas con score de matching

  Carrier->>App: Envía oferta: S/ 1,100, vehículo ABC-123
  App->>API: POST /api/auctions/{auctionId}/bids
  API->>Auction: validateBid(price=1100, vehicleId, requestWeight)
  Auction->>DB: Query vehicle capacity vs request weight
  Auction-->>API: valid (1100 >= priceFloor 900, capacity OK)
  API->>DB: INSERT bid (amount=1100, status='pending')
  API->>Notif: notifyPyme(requestId, "Nueva oferta: S/ 1,100")
  Notif-->>PYME: Notificación in-app: "Carrier A ofertó S/ 1,100"

  PYME->>App: Ve detalle de solicitud con ofertas
  App->>API: GET /api/shipments/requests/{id}/bids
  API-->>App: [{carrier, amount:1100, trustScore:94, punctuality:97%}, ...]
  PYME->>App: Acepta oferta de Carrier A
  App->>API: POST /api/bids/{bidId}/accept

  API->>DB: UPDATE bid SET status='accepted' WHERE id=bidId
  API->>DB: UPDATE bids SET status='rejected' WHERE auctionId=X AND id!=bidId
  API->>DB: UPDATE auction SET status='closed'
  API->>DB: UPDATE shipment_request SET status='matched'
  API->>DB: INSERT shipment (tracking_code='LGX-48291', status='pending')
  API->>Notif: notifyCarrier(carrierId, "Tu oferta fue aceptada · LGX-48291")
  API-->>App: 200 {shipmentId, trackingCode: 'LGX-48291'}
  App-->>PYME: Muestra tracking code y estado del envío
```

---

### 3.3 Flujo: Conductor actualiza estado de parada

```mermaid
sequenceDiagram
  actor Driver as Conductor
  participant DriverApp as Flutter Driver
  participant API as Quarkus API
  participant DB as PostgreSQL
  participant Storage as MinIO/S3
  participant Notif as notification-module
  actor PYME

  Driver->>DriverApp: Abre app, ve ruta asignada
  DriverApp->>API: GET /api/driver/shipments/active
  API->>DB: Query shipment con stops asignadas al driver
  API-->>DriverApp: {shipment, stops: [{seq:1, location, eta, status}, ...]}

  Driver->>DriverApp: Llega a parada 1 (Arequipa), marca "Entregado"
  DriverApp->>DriverApp: Solicita foto de entrega
  Driver->>DriverApp: Toma foto con cámara
  Driver->>DriverApp: Captura firma del receptor
  DriverApp->>API: POST /api/driver/stops/{stopId}/confirm
  Note over DriverApp,API: {photo: base64, signature: base64, status: 'delivered'}

  API->>Storage: Upload photo → "shipments/{id}/stop1_evidence.jpg"
  Storage-->>API: {fileUrl: "https://..."}
  API->>Storage: Upload signature → "shipments/{id}/stop1_signature.png"
  Storage-->>API: {fileUrl: "https://..."}
  API->>DB: UPDATE shipment_stop SET status='delivered', actual_arrival=NOW()
  API->>DB: INSERT document (shipment_id, type='evidence', file_url=...)
  API->>Notif: notifyPyme(requestId_parcela, "Tu carga fue entregada en Arequipa")
  API-->>DriverApp: 200 OK
  Notif-->>PYME: Notificación: "Carga entregada en Arequipa · 14:32"
```

---

### 3.4 Flujo: Negociación bidireccional con contra-oferta

```mermaid
sequenceDiagram
  actor PYME
  actor Carrier as Transportista
  participant API as Quarkus API
  participant Neg as negotiation-module
  participant DB as PostgreSQL
  participant WS as WebSocket / Redis Pub-Sub

  Carrier->>API: POST /api/messages (requestId, body="Puedo hacerlo por S/ 1,150")
  API->>Neg: moderateMessage(body)
  Neg-->>API: {ok: true, noContactInfo: true}
  API->>DB: INSERT message (sender=carrier, body="Puedo hacerlo por S/ 1,150")
  API->>WS: PUBLISH "chat:{requestId}:{carrierId}" → PYME
  WS-->>PYME: Mensaje recibido en tiempo real

  PYME->>API: POST /api/messages (body="Te pago máximo S/ 1,000", proposed_price=1000)
  API->>Neg: moderateMessage(body)
  Neg-->>API: ok
  API->>DB: INSERT message (sender=pyme, proposed_price=1000)
  API->>WS: PUBLISH → Carrier
  WS-->>Carrier: Counter-offer de PYME: S/ 1,000

  Carrier->>API: POST /api/messages (body="Acepto en S/ 1,080", proposed_price=1080)
  API->>DB: INSERT message (sender=carrier, proposed_price=1080)
  API->>WS: PUBLISH → PYME

  PYME->>API: POST /api/counter-offers/{bidId}/accept (accepted_price=1080)
  API->>DB: UPDATE bid SET amount=1080
  API->>DB: INSERT message (sender=system, body="Precio acordado: S/ 1,080")
  API-->>PYME: 200 OK - Precio actualizado
```

---

### 3.5 Flujo: Smart Load Planner sugiere combinación de cargas

```mermaid
sequenceDiagram
  participant Scheduler as Quarkus Scheduler
  participant Routing as routing-module
  participant DB as PostgreSQL
  participant Notif as notification-module
  actor Carrier as Transportista

  Scheduler->>Routing: findCompatibleLoads() [cada 30 min]
  Routing->>DB: SELECT open requests WHERE required_date BETWEEN NOW() AND NOW()+48h
  DB-->>Routing: [RequestA: Lima→Puno 2t, RequestB: Lima→Juliaca 1t, RequestC: Lima→Puno 1.2t]

  Routing->>Routing: clusterByRoute(requests, radius=50km origin, 80km dest)
  Routing->>Routing: filterByCapacity(cluster, vehicle.maxWeight=8t)
  Routing-->>Routing: Compatible: [A+C] Lima→Puno (3.2t), candidato vehículo XYZ-789

  Routing->>DB: INSERT smart_load_suggestion (requests=[A,C], vehicle=XYZ, route, combinedIncome=2800)
  Routing->>Notif: notifyCarrier(carrierId, "Smart Load: 2 cargas compatibles Lima→Puno · S/ 2,800")
  Notif-->>Carrier: Notificación: "Puedes tomar 2 cargas · 3.2 ton · S/ 2,800 · 80% capacidad"

  Carrier->>DB: GET /api/smart-load/suggestions
  DB-->>Carrier: [{requests:[A,C], vehicle, route, income:2800, occupancy:80%}]
  Carrier->>DB: POST /api/smart-load/{suggestionId}/accept
  DB->>DB: INSERT shipment_multi (stops=[Lima, Puno x2], tracking='LGX-48292')
  DB->>Notif: notify PYME_A + PYME_C "Tu carga fue incluida en ruta compartida"
```

---

## 4. Diagrama de Estados — Ciclo de Vida del Envío

```mermaid
stateDiagram-v2
  [*] --> open : PYME publica solicitud

  open --> auction_open : Sistema abre subasta
  auction_open --> matched : PYME acepta oferta
  auction_open --> cancelled : Subasta vence sin ofertas (operador interviene)

  matched --> pending : Contrato generado y tracking code asignado
  pending --> picked_up : Conductor confirma recogida en punto de origen
  picked_up --> in_transit : Primer tramo iniciado
  in_transit --> in_transit : Paradas intermedias completadas
  in_transit --> delivered : Última parada confirmada con evidencia
  in_transit --> issue : Se reporta incidencia

  issue --> in_transit : Operador resuelve y reencauza
  issue --> delivered : Operador confirma entrega pese a incidencia
  issue --> cancelled : Operador cancela por incidencia grave

  delivered --> [*]
  cancelled --> [*]
```

---

## 5. Diagrama de Componentes — Aplicación Angular

```mermaid
graph TD
  subgraph Angular Web App
    CoreModule[Core Module\n- AuthGuard\n- RoleGuard\n- AuthInterceptor\n- AuthService]
    SharedModule[Shared Module\n- Components UI\n- Pipes\n- Directives]

    subgraph Features
      AuthFeature[auth/\n- login\n- register\n- onboarding]
      MarketplaceFeature[marketplace/\n- listado cargas\n- filtros\n- oferta inline]
      ShipmentsFeature[shipments/\n- mis solicitudes\n- detalle\n- nueva solicitud\n- tracking]
      NegotiationFeature[negotiation/\n- chat RT\n- contra-oferta]
      FleetFeature[fleet/\n- vehículos\n- conductores]
      ReputationFeature[reputation/\n- perfil score\n- historial reviews]
      OperatorFeature[operator/\n- dashboard\n- asignación\n- incidencias]
      ReturnsFeature[returns/\n- cargas retorno\n- oferta directa]
    end
  end

  CoreModule --> AuthFeature
  CoreModule --> MarketplaceFeature
  CoreModule --> ShipmentsFeature
  SharedModule --> MarketplaceFeature
  SharedModule --> ShipmentsFeature
  SharedModule --> OperatorFeature
```

---

*LOGYX · E1 Modelado Técnico UML · Competencia CE0214 · Versión 1.0 · Junio 2026*
