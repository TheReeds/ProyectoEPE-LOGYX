# E3 — Sistema Desarrollado
> Competencias CE0231 (Implementación) · CE0232 (Integración) · CE0233 (Arquitectura) · CE0234 (Despliegue)  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Versión: 1.0 · Junio 2026

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Tipo de sistema** | Sistema web empresarial con extensión móvil |
| **Plataformas** | Web (Angular 18) · Mobile iOS/Android (Flutter 3) |
| **Componentes principales** | LOGYX Business Web · LOGYX Business App · LOGYX Driver App · LOGYX Operator Panel |
| **Backend** | Quarkus 3.x (Java 21), monolito modular reactivo |
| **Base de datos** | PostgreSQL 16 + PostGIS |
| **Repositorio** | *(agregar URL de GitHub aquí)* |
| **Estado actual** | Fase de implementación — documentación técnica pre-código |

---

## 2. CE0233 — Arquitectura Implementada

### 2.1 Tipo y Justificación

LOGYX implementa un **monolito modular reactivo** como primera arquitectura. La justificación está documentada en el ADR-001 (E1_Arquitectura.md). Los módulos internos están desacoplados mediante interfaces de Java y pueden extraerse como microservicios en una fase posterior sin cambiar los contratos de API.

### 2.2 Estructura del Backend (Quarkus)

```
logyx-backend/
├── src/main/java/pe/logyx/
│   ├── common/
│   │   ├── exception/       # Excepciones personalizadas + ExceptionMapper JAX-RS
│   │   ├── security/        # JWT filter, RolesAllowed, contexto de org actual
│   │   └── util/            # Helpers de conversión, validación
│   ├── module/
│   │   ├── auth/            # AuthResource, AuthService, ProfileRepository
│   │   ├── shipment/        # ShipmentRequestResource, ShipmentRequestService
│   │   ├── auction/         # AuctionResource, AuctionService, BidRepository
│   │   ├── negotiation/     # MessageResource, CounterOfferService
│   │   ├── trip/            # CarrierTripResource, TripBookingService
│   │   ├── pricing/         # PricingService (Motor de costos)
│   │   ├── routing/         # OpenRouteService client (REST client MicroProfile)
│   │   ├── matching/        # MatchingService (ranker de cargas)
│   │   ├── smartload/       # SmartLoadPlannerJob (Quarkus Scheduler)
│   │   ├── tracking/        # ShipmentResource, ShipmentStopService
│   │   ├── reputation/      # ReputationService, ReviewResource
│   │   ├── fleet/           # VehicleResource, DriverResource
│   │   ├── document/        # DocumentResource, MinIOStorageService
│   │   ├── notification/    # NotificationService, WebSocketBroadcaster
│   │   ├── incident/        # IncidentResource, IncidentService
│   │   └── operator/        # OperatorDashboardResource
│   └── infrastructure/
│       ├── config/          # application.properties, datasource config
│       └── persistence/     # Panache entities base, UUIDConverter
├── src/main/resources/
│   ├── application.properties
│   └── db/migration/        # Scripts Flyway V1__...V9__
└── src/test/               # Tests unitarios e integración
```

### 2.3 Estructura del Frontend Web (Angular)

```
logyx-web/
├── src/app/
│   ├── core/
│   │   ├── auth/            # AuthService, JwtInterceptor, AuthGuard
│   │   ├── models/          # Interfaces TypeScript de todas las entidades
│   │   └── services/        # BaseApiService, NotificationService
│   ├── features/
│   │   ├── auth/            # LoginComponent, RegisterComponent
│   │   ├── pyme/
│   │   │   ├── dashboard/   # PymeDashboardComponent
│   │   │   ├── requests/    # ShipmentRequestListComponent, NewRequestComponent
│   │   │   ├── tracking/    # ShipmentTrackingComponent, StopDetailComponent
│   │   │   └── reputation/  # ReputationComponent
│   │   ├── carrier/
│   │   │   ├── dashboard/   # CarrierDashboardComponent
│   │   │   ├── marketplace/ # MarketplaceComponent, BidFormComponent
│   │   │   ├── trips/       # CarrierTripComponent
│   │   │   └── fleet/       # FleetManagementComponent
│   │   └── operator/
│   │       ├── dashboard/   # OperatorDashboardComponent
│   │       └── incidents/   # IncidentManagementComponent
│   ├── shared/
│   │   ├── components/      # TrustScoreBadge, StatusBadge, MapComponent
│   │   └── pipes/           # CurrencyPeruPipe, DateLocalePipe
│   └── app-routing.module.ts
```

### 2.4 Estructura de Apps Móviles (Flutter)

```
logyx-mobile/
├── shared_domain/           # Modelos, constantes y servicios compartidos
│   ├── lib/
│   │   ├── models/          # Dart classes de todas las entidades
│   │   ├── services/        # ApiService base, SecureStorageService
│   │   └── constants/       # Colores, rutas, constantes de API
├── logyx_business/          # App PYME + Transportista (Flutter)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── pyme/
│   │   │   ├── carrier/
│   │   │   └── chat/        # Chat de negociación (WebSocket)
│   │   └── router.dart      # GoRouter con RBAC por rol
├── logyx_driver/            # App Conductor (Flutter)
│   ├── lib/
│   │   ├── features/
│   │   │   ├── route/       # Lista de paradas
│   │   │   ├── delivery/    # Confirmar entrega (foto + firma)
│   │   │   └── offline/     # Cache local con Drift (SQLite)
│   │   └── main.dart
└── logyx_operator/          # Panel Operador (Flutter Web / Android tablet)
    └── lib/
        ├── features/
        │   ├── dashboard/
        │   └── incidents/
        └── main.dart
```

---

## 3. CE0231 — Funcionalidades Implementadas

### 3.1 Tabla de Funcionalidades por Módulo

| ID | Funcionalidad | Req. asociado | Módulo backend | Componente frontend |
|----|---------------|---------------|----------------|---------------------|
| F01 | Registro y login (email + Google OAuth) | RF01–RF06 | `auth` | LoginComponent |
| F02 | RBAC por rol (PYME/Carrier/Driver/Operator) | RF07–RF08 | `security` (transversal) | AuthGuard + RoleDirective |
| F03 | Publicar solicitud de carga | RF09, RF11–RF14 | `marketplace` | NewRequestComponent |
| F04 | Motor de costos (cálculo automático) | RF10 | `pricing` | CotizadorComponent |
| F05 | Subasta inversa (apertura + cierre temporal/máx. bids) | RF15–RF18 | `auction` | MarketplaceComponent |
| F06 | Envío y gestión de ofertas | RF19–RF20 | `bid` | BidFormComponent |
| F07 | Publicar viaje disponible (supply-side) | RF21–RF22 | `trip` | CarrierTripComponent |
| F08 | Reserva de espacio en viaje | RF23–RF24 | `trip` | TripBookingComponent |
| F09 | Chat de negociación bidireccional | RF25, RF29 | `chat` | ChatComponent (WebSocket) |
| F10 | Contra-ofertas desde el chat | RF26–RF28 | `counteroffer` | ChatComponent (mismo componente que F09) |
| F11 | Smart Load Planner (scheduler) | RF30–RF33 | `smartload` | SmartLoadSuggestionsComponent |
| F12 | Tracking en tiempo real + actualizaciones | RF34–RF37 | `shipment` + `tracking` | ShipmentTrackingComponent |
| F13 | Confirmación de entrega (foto + firma) | RF38–RF39 | `tracking` + `document` | DeliveryConfirmComponent (Driver) |
| F14 | Sistema de calificaciones + reputación | RF40–RF45 | `review` | ReputationComponent |
| F15 | Gestión documental (upload + download) | RF46–RF48 | `document` | DocumentsComponent |
| F16 | Notificaciones in-app + email | RF49–RF51 | `notification` | NotificationFeedComponent |
| F17 | Gestión de incidencias | RF52–RF55 | `incident` | IncidentManagementComponent |
| F18 | Panel del operador (asignación manual + SLA) | RF56–RF60 | `admin` | OperatorDashboardComponent |
| F19 | Cargas de retorno (sugerencia automática) | RF61–RF63 | `returnload` | ReturnLoadComponent |
| F20 | Gestión de flota (vehículos + conductores) | RF64–RF67 | `vehicle` + `driver` | FleetManagementComponent |

> **Nota (corregido 2026-07-06):** esta tabla tenía varios rangos de RF y nombres de paquete
> desalineados con `E1_SRS.md` §7.1 y con la numeración/paquetes reales de `ROADMAP.md` del
> backend (p.ej. F04 decía `RF12–RF14` cuando el motor de costos es solo RF10; F06/F14/F18/F19/F20
> usaban nombres de paquete `auction`/`reputation`/`operator`/`matching`/`fleet` que nunca se
> usaron — los paquetes reales son `bid`, `review`, `admin`, `returnload`, `vehicle`+`driver`).
> Se corrigió para que coincida con `ROADMAP.md` (fuente de verdad de paquetes/módulos del
> backend) y con la trazabilidad RF de `E1_SRS.md` §11.

### 3.2 Implementación de Módulos Clave

> **Nota sobre estos ejemplos de código (agregada 2026-07-06):** los fragmentos de esta
> sección se escribieron en la fase de diseño con un estilo reactivo (Mutiny `Uni<T>`/`Multi<T>`,
> patrón `builder()`, enums en mayúsculas) que **no coincide** con cómo se terminó implementando
> el backend real. El código que sí está en `Proyecto/Backend/logyx-backend/src/main/java/pe/logyx/`
> usa servicios `@ApplicationScoped` con métodos **bloqueantes** (`@Transactional public XxxResponse
> xxx(...)`), Panache repositories síncronos, DTOs como `record`, entidades con campos públicos
> asignados directo (sin builder), y enums en minúscula (`general`, `fragile`...) para calzar con
> los tipos `ENUM` nativos de Postgres. Los módulos AUTH, AUCTION y PRICING de abajo **ya existen**
> con esa otra forma — ver `pe.logyx.auth.application.AuthService`, `pe.logyx.bid.application.BidService`
> (el "AuctionService.placeBid" de aquí terminó viviendo en el módulo `bid`, no en `auction` — ver
> nota de implementación del Módulo 8 en `ROADMAP.md`) y `pe.logyx.pricing.application.PricingService`
> para la versión real y actualizada. El Smart Load Planner Job de abajo sigue siendo solo diseño
> (Módulo 15 aún no implementado) — cuando se construya, seguirá el mismo estilo bloqueante que el
> resto del backend, no el reactivo mostrado aquí. Se deja el código original tal cual (no se
> reescribió línea por línea) porque reescribirlo entero se desactualizaría de nuevo apenas avance
> el desarrollo — para el código vigente, la fuente de verdad es siempre el repositorio, no este
> documento.

#### Módulo AUTH — Autenticación y autorización

```java
// AuthResource.java
@Path("/api/v1/auth")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class AuthResource {

    @Inject AuthService authService;

    @POST @Path("/login")
    public Uni<LoginResponse> login(@Valid LoginRequest req) {
        return authService.authenticate(req.email(), req.password())
            .map(TokenPair::toResponse);
    }

    @POST @Path("/register")
    public Uni<Response> register(@Valid RegisterRequest req) {
        return authService.registerOrganization(req)
            .map(org -> Response.status(201).entity(org).build());
    }

    @POST @Path("/refresh")
    @Authenticated
    public Uni<TokenPair> refresh(@Context SecurityContext ctx) {
        return authService.refreshToken(ctx.getUserPrincipal().getName());
    }
}
```

```java
// AuthService.java (fragmento)
@ApplicationScoped
public class AuthService {

    @Inject ProfileRepository profileRepo;
    @Inject JwtService jwtService;

    public Uni<TokenPair> authenticate(String email, String password) {
        return profileRepo.findByEmail(email)
            .onItem().ifNull().failWith(new UnauthorizedException("Credenciales inválidas"))
            .chain(profile -> {
                if (!BCrypt.checkpw(password, profile.passwordHash)) {
                    return Uni.createFrom().failure(new UnauthorizedException("Credenciales inválidas"));
                }
                return Uni.createFrom().item(jwtService.generateTokenPair(profile));
            });
    }
}
```

#### Módulo AUCTION — Subasta inversa

```java
// AuctionService.java (fragmento)
@ApplicationScoped
public class AuctionService {

    @Inject AuctionRepository auctionRepo;
    @Inject BidRepository bidRepo;
    @Inject NotificationService notificationService;
    @Inject VehicleRepository vehicleRepo;

    public Uni<Bid> placeBid(UUID auctionId, PlaceBidRequest req, UUID carrierOrgId) {
        return auctionRepo.findById(auctionId)
            .onItem().ifNull().failWith(new NotFoundException("Subasta no encontrada"))
            .chain(auction -> {
                if (auction.status != AuctionStatus.OPEN) {
                    return Uni.createFrom().failure(
                        new BusinessException("LOGYX-AUC-001: La subasta no está abierta"));
                }
                if (auction.closesAt.isBefore(Instant.now())) {
                    return Uni.createFrom().failure(
                        new BusinessException("LOGYX-AUC-002: La subasta ya venció"));
                }
                return validateAndCreateBid(auction, req, carrierOrgId);
            });
    }

    private Uni<Bid> validateAndCreateBid(Auction auction, PlaceBidRequest req, UUID carrierOrgId) {
        return vehicleRepo.findById(req.vehicleId())
            .chain(vehicle -> {
                // Verificar precio mínimo (price_floor)
                BigDecimal priceFloor = auction.request.priceFloor;
                if (req.amount().compareTo(priceFloor) < 0) {
                    return Uni.createFrom().failure(
                        new BusinessException("LOGYX-BID-001: La oferta no puede ser menor al precio mínimo de " + priceFloor));
                }
                // Verificar capacidad del vehículo
                BigDecimal requestedWeight = auction.request.weightKg;
                if (vehicle.currentWeightKg.add(requestedWeight).compareTo(vehicle.maxWeightKg) > 0) {
                    return Uni.createFrom().failure(
                        new BusinessException("LOGYX-CAP-001: El vehículo no tiene capacidad suficiente"));
                }
                Bid bid = Bid.create(auction, carrierOrgId, vehicle, req.amount(), req.notes());
                return bidRepo.persist(bid)
                    .invoke(() -> notificationService.notifyNewBid(auction.request.requesterOrgId, bid));
            });
    }
}
```

#### Módulo PRICING — Motor de costos

```java
// PricingService.java
@ApplicationScoped
public class PricingService {

    @Inject OpenRouteServiceClient orsClient;

    // Multiplicadores por tipo de carga
    private static final Map<CargoType, BigDecimal> CARGO_MULTIPLIER = Map.of(
        CargoType.GENERAL,    new BigDecimal("1.00"),
        CargoType.FRAGILE,    new BigDecimal("1.30"),
        CargoType.PERISHABLE, new BigDecimal("1.25"),
        CargoType.HAZARDOUS,  new BigDecimal("1.50"),
        CargoType.BULK,       new BigDecimal("0.95"),
        CargoType.OVERSIZED,  new BigDecimal("1.40")
    );

    private static final BigDecimal FUEL_COST_PER_KM  = new BigDecimal("0.65"); // S/ por km
    private static final BigDecimal RATE_PER_KM_PER_TON = new BigDecimal("0.80");

    public Uni<CostCalculation> calculate(ShipmentRequest request) {
        return orsClient.getRoute(
                request.originLat, request.originLng,
                request.destinationLat, request.destinationLng)
            .map(route -> buildCalculation(request, route));
    }

    private CostCalculation buildCalculation(ShipmentRequest req, OrsRoute route) {
        BigDecimal distanceKm   = route.distanceMeters().divide(BigDecimal.valueOf(1000), 2, HALF_UP);
        BigDecimal durationMin  = route.durationSeconds().divide(BigDecimal.valueOf(60), 2, HALF_UP);
        BigDecimal tons         = req.weightKg.divide(BigDecimal.valueOf(1000), 4, HALF_UP);
        BigDecimal fuelCost     = distanceKm.multiply(FUEL_COST_PER_KM);
        BigDecimal baseTransport= distanceKm.multiply(tons).multiply(RATE_PER_KM_PER_TON)
                                    .multiply(CARGO_MULTIPLIER.get(req.cargoType));
        BigDecimal tollCost     = estimateTolls(distanceKm);
        BigDecimal handlingFee  = baseTransport.multiply(new BigDecimal("0.05"));

        return CostCalculation.builder()
            .requestId(req.id).distanceKm(distanceKm).durationMin(durationMin)
            .fuelCost(fuelCost).baseTransportCost(baseTransport)
            .tollCost(tollCost).handlingFee(handlingFee).build();
    }

    private BigDecimal estimateTolls(BigDecimal distanceKm) {
        // Corredor Lima-Arequipa: aproximadamente 1 peaje cada 120 km, S/ 12 c/u
        int estimatedTolls = distanceKm.divide(BigDecimal.valueOf(120), 0, CEILING).intValue();
        return BigDecimal.valueOf(estimatedTolls * 12);
    }
}
```

#### Smart Load Planner Job

```java
// SmartLoadPlannerJob.java
@ApplicationScoped
public class SmartLoadPlannerJob {

    @Inject ShipmentRequestRepository requestRepo;
    @Inject VehicleRepository vehicleRepo;
    @Inject SmartLoadSuggestionRepository suggestionRepo;
    @Inject NotificationService notificationService;

    // Ejecutar cada 30 minutos
    @Scheduled(every = "30m", identity = "smart-load-planner")
    void run() {
        findAndSuggestCompatibleLoads()
            .subscribe().with(
                count -> Log.infof("SmartLoadPlanner: %d sugerencias generadas", count),
                err   -> Log.errorf("SmartLoadPlanner falló: %s", err.getMessage())
            );
    }

    Uni<Integer> findAndSuggestCompatibleLoads() {
        return vehicleRepo.findAllAvailable()
            .onItem().transformToMulti(vehicle -> Multi.createFrom().iterable(List.of(vehicle)))
            .onItem().transformToUniAndConcatenate(vehicle ->
                requestRepo.findCompatibleFor(vehicle, 50.0, 80.0, 24)
                    .chain(requests -> createSuggestionIfWorthwhile(vehicle, requests))
            )
            .collect().asList()
            .map(suggestions -> (int) suggestions.stream().filter(s -> s != null).count());
    }

    private Uni<SmartLoadSuggestion> createSuggestionIfWorthwhile(
            Vehicle vehicle, List<ShipmentRequest> requests) {
        if (requests.size() < 2) return Uni.createFrom().nullItem();

        BigDecimal combinedWeight = requests.stream()
            .map(r -> r.weightKg).reduce(BigDecimal.ZERO, BigDecimal::add);

        if (combinedWeight.compareTo(vehicle.maxWeightKg) > 0)
            return Uni.createFrom().nullItem();

        BigDecimal occupancyPct = combinedWeight
            .divide(vehicle.maxWeightKg, 2, HALF_UP)
            .multiply(BigDecimal.valueOf(100));

        // Solo sugerir si la ocupación supera el 60%
        if (occupancyPct.compareTo(BigDecimal.valueOf(60)) < 0)
            return Uni.createFrom().nullItem();

        SmartLoadSuggestion suggestion = SmartLoadSuggestion.create(vehicle, requests, occupancyPct);
        return suggestionRepo.persist(suggestion)
            .invoke(() -> notificationService.notifySmartLoadSuggestion(
                vehicle.carrierOrgId, suggestion));
    }
}
```

---

## 4. CE0232 — Integración del Sistema

### 4.1 Integración Frontend Web ↔ Backend

El frontend Angular se comunica con el backend mediante:

- **REST HTTP/JSON** para operaciones CRUD estándar (solicitudes, ofertas, flota)
- **WebSocket** para el chat de negociación en tiempo real
- **Server-Sent Events (SSE)** para actualizaciones de estado de envío

```typescript
// api.service.ts — servicio base Angular
@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly BASE_URL = environment.apiUrl; // https://api.logyx.pe/api/v1

  constructor(private http: HttpClient) {}

  get<T>(path: string): Observable<T> {
    return this.http.get<T>(`${this.BASE_URL}${path}`);
  }

  post<T>(path: string, body: unknown): Observable<T> {
    return this.http.post<T>(`${this.BASE_URL}${path}`, body);
  }
}

// jwt.interceptor.ts — inyecta el token en cada request
@Injectable()
export class JwtInterceptor implements HttpInterceptor {
  constructor(private auth: AuthService) {}

  intercept(req: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    const token = this.auth.getAccessToken();
    if (token) {
      req = req.clone({ setHeaders: { Authorization: `Bearer ${token}` } });
    }
    return next.handle(req);
  }
}
```

### 4.2 Integración App Móvil ↔ Backend

Las apps Flutter usan el paquete `dio` con interceptor JWT y `flutter_secure_storage` para persistir tokens:

```dart
// api_service.dart — Flutter
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ));
    _dio.interceptors.add(JwtInterceptor());
  }

  Future<T> get<T>(String path, T Function(dynamic) fromJson) async {
    final response = await _dio.get(path);
    return fromJson(response.data);
  }

  Future<T> post<T>(String path, Map<String, dynamic> body,
      T Function(dynamic) fromJson) async {
    final response = await _dio.post(path, data: body);
    return fromJson(response.data);
  }
}

// offline_cache.dart — Drift (SQLite) para modo offline del Driver
@DriftDatabase(tables: [CachedStops, CachedShipments])
class OfflineDatabase extends _$OfflineDatabase {
  OfflineDatabase() : super(_openConnection());

  Future<void> cacheShipment(Shipment shipment) async {
    await into(cachedShipments).insertOnConflictUpdate(
      CachedShipmentsCompanion.insert(
        id: shipment.id,
        trackingCode: shipment.trackingCode,
        cachedAt: DateTime.now(),
        payload: jsonEncode(shipment.toJson()),
      ),
    );
  }
}
```

### 4.3 Integración Backend ↔ Base de Datos

```java
// ShipmentRequestRepository.java (Panache)
@ApplicationScoped
public class ShipmentRequestRepository
        implements PanacheRepositoryBase<ShipmentRequest, UUID> {

    public Uni<List<ShipmentRequest>> findOpenByOriginProximity(
            double lat, double lng, double radiusKm) {

        String sql = """
            SELECT sr.* FROM shipment_requests sr
            WHERE sr.status = 'open'
              AND sr.required_date >= CURRENT_DATE
              AND (
                6371 * acos(
                  cos(radians(:lat)) * cos(radians(sr.origin_lat))
                  * cos(radians(sr.origin_lng) - radians(:lng))
                  + sin(radians(:lat)) * sin(radians(sr.origin_lat))
                )
              ) <= :radius
            ORDER BY sr.required_date ASC
            LIMIT 50
            """;

        return getSession()
            .chain(session -> session.createNativeQuery(sql, ShipmentRequest.class)
                .setParameter("lat", lat)
                .setParameter("lng", lng)
                .setParameter("radius", radiusKm)
                .getResultList());
    }

    public Uni<List<ShipmentRequest>> findCompatibleFor(
            Vehicle vehicle, double originRadiusKm,
            double destRadiusKm, int windowHours) {
        // Consulta para Smart Load Planner
        return find("""
            status = 'open'
            AND required_date BETWEEN :minDate AND :maxDate
            AND weight_kg <= :availableWeight
            """,
            Parameters.with("minDate", LocalDate.now())
                      .and("maxDate", LocalDate.now().plusDays(3))
                      .and("availableWeight",
                           vehicle.maxWeightKg.subtract(vehicle.currentWeightKg)))
            .list();
    }
}
```

### 4.4 Chat en Tiempo Real (WebSocket + Redis Pub/Sub)

```java
// NegotiationWebSocket.java
@ServerEndpoint("/ws/negotiation/{requestId}/{carrierId}")
@ApplicationScoped
public class NegotiationWebSocket {

    @Inject RedisClient redis;
    @Inject MessageRepository messageRepo;
    @Inject MessageModerationService moderator;

    private final Map<String, Session> sessions = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session,
                       @PathParam("requestId") String requestId,
                       @PathParam("carrierId") String carrierId) {
        sessions.put(session.getId(), session);
    }

    @OnMessage
    public Uni<Void> onMessage(String rawMessage, Session session,
                               @PathParam("requestId") String requestId,
                               @PathParam("carrierId") String carrierId) {

        IncomingMessage msg = Json.decodeValue(rawMessage, IncomingMessage.class);

        // Moderar antes de guardar
        boolean blocked = moderator.containsContactInfo(msg.body());
        String body = blocked ? "[Mensaje bloqueado por el sistema]" : msg.body();

        return messageRepo.persist(
                Message.create(UUID.fromString(requestId),
                               UUID.fromString(carrierId),
                               msg.senderOrgId(), body, msg.proposedPrice(), blocked))
            .invoke(saved -> {
                // Publicar en Redis para otros nodos del cluster
                redis.publish("chat:" + requestId + ":" + carrierId,
                              Json.encode(saved));
            })
            .replaceWithVoid();
    }
}
```

---

## 5. APIs y Servicios

### 5.1 Endpoints Principales

| Método | Endpoint | Descripción | Rol requerido |
|--------|----------|-------------|---------------|
| POST | `/api/v1/auth/login` | Login con email/contraseña | Público |
| POST | `/api/v1/auth/register` | Registro de organización | Público |
| GET | `/api/v1/shipment-requests` | Listar solicitudes (marketplace) | carrier |
| POST | `/api/v1/shipment-requests` | Publicar nueva solicitud | pyme |
| GET | `/api/v1/shipment-requests/{id}` | Detalle de solicitud | pyme, carrier |
| POST | `/api/v1/auctions/{id}/bids` | Enviar oferta | carrier |
| POST | `/api/v1/bids/{id}/accept` | Aceptar oferta | pyme |
| POST | `/api/v1/carrier-trips` | Publicar viaje disponible | carrier |
| GET | `/api/v1/carrier-trips` | Listar viajes disponibles | pyme |
| POST | `/api/v1/carrier-trips/{id}/bookings` | Reservar espacio en viaje | pyme |
| GET | `/api/v1/shipments/{id}` | Tracking del envío | pyme, carrier, driver |
| PATCH | `/api/v1/shipments/{id}/stops/{stopId}` | Actualizar estado de parada | driver |
| POST | `/api/v1/shipments/{id}/stops/{stopId}/delivery` | Confirmar entrega (foto+firma) | driver |
| GET | `/api/v1/reviews/{orgId}` | Reputación de una organización | Autenticado |
| POST | `/api/v1/reviews` | Crear calificación post-entrega | pyme, carrier |
| GET | `/api/v1/vehicles` | Mis vehículos | carrier |
| POST | `/api/v1/vehicles` | Registrar vehículo | carrier |
| GET | `/api/v1/notifications` | Notificaciones no leídas | Autenticado |
| POST | `/api/v1/incidents` | Reportar incidencia | pyme, carrier, driver |
| GET | `/api/v1/operator/sla-alerts` | Solicitudes en riesgo | operator |
| POST | `/api/v1/operator/assign` | Asignar carrier manualmente | operator |
| POST | `/api/v1/pricing/calculate` | Calcular costo estimado | pyme |
| GET | `/api/v1/smart-load/suggestions` | Sugerencias Smart Load | carrier |

### 5.2 Contrato de Respuesta Base

```json
// Respuesta exitosa estándar
{
  "data": { ... },
  "meta": {
    "timestamp": "2026-06-29T15:00:00Z",
    "requestId": "req-uuid"
  }
}

// Respuesta de error estándar
{
  "error": {
    "code": "LOGYX-AUC-001",
    "message": "La subasta no está abierta",
    "field": null
  },
  "meta": {
    "timestamp": "2026-06-29T15:00:00Z",
    "requestId": "req-uuid"
  }
}
```

### 5.3 Seguridad de la API

```java
// SecurityConfig.java — RBAC con anotaciones
@Path("/api/v1/operator")
@RolesAllowed({"operator", "admin"})
public class OperatorDashboardResource {
    // Solo accesible para operadores y admins
}

// JwtAuthFilter.java — validación del token
@Provider
@Priority(Priorities.AUTHENTICATION)
public class JwtAuthFilter implements ContainerRequestFilter {

    @Inject JwtService jwtService;

    @Override
    public void filter(ContainerRequestContext ctx) {
        String authHeader = ctx.getHeaderString(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            ctx.abortWith(Response.status(401).build());
            return;
        }
        String token = authHeader.substring(7);
        try {
            JwtClaims claims = jwtService.validate(token);
            // Inyectar org_id en contexto PostgreSQL para RLS
            ctx.setProperty("orgId", claims.orgId());
        } catch (JwtException e) {
            ctx.abortWith(Response.status(401).build());
        }
    }
}
```

---

## 6. Integración de Servicios Externos

### 6.1 OpenRouteService (ORS) — Cálculo de rutas

```java
// OpenRouteServiceClient.java (MicroProfile REST Client)
@RegisterRestClient(configKey = "ors-api")
@Path("/v2/directions/driving-hgv")
public interface OpenRouteServiceClient {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    Uni<OrsResponse> getRoute(
        @QueryParam("api_key") @RestClientDefault("${ors.api.key}") String apiKey,
        @QueryParam("start")   String start,  // "lng,lat"
        @QueryParam("end")     String end     // "lng,lat"
    );
}

// application.properties
quarkus.rest-client.ors-api.url=https://api.openrouteservice.org
ors.api.key=${ORS_API_KEY}
```

### 6.2 MinIO — Almacenamiento de documentos

```java
// MinIOStorageService.java
@ApplicationScoped
public class MinIOStorageService {

    @Inject MinioClient minioClient;

    @ConfigProperty(name = "minio.bucket") String bucket;

    public Uni<String> uploadDeliveryPhoto(UUID shipmentId, UUID stopId,
                                            InputStream imageStream, String contentType) {
        String objectKey = String.format("deliveries/%s/%s/photo.jpg", shipmentId, stopId);
        return Uni.createFrom().completionStage(
            CompletableFuture.supplyAsync(() -> {
                minioClient.putObject(PutObjectArgs.builder()
                    .bucket(bucket).object(objectKey)
                    .stream(imageStream, -1, 10_485_760)
                    .contentType(contentType).build());
                return generatePresignedUrl(objectKey);
            })
        );
    }

    private String generatePresignedUrl(String objectKey) {
        return minioClient.getPresignedObjectUrl(GetPresignedObjectUrlArgs.builder()
            .method(Method.GET).bucket(bucket).object(objectKey)
            .expiry(7, TimeUnit.DAYS).build());
    }
}
```

### 6.3 Redis — Caché y Pub/Sub

```java
// application.properties
quarkus.redis.hosts=redis://localhost:6379

// RedisNotificationPublisher.java — publicar actualizaciones de estado
@ApplicationScoped
public class RedisNotificationPublisher {

    @Inject ReactiveRedisClient redis;

    public Uni<Void> publishShipmentUpdate(UUID shipmentId, ShipmentStatus newStatus) {
        String channel = "shipment-updates:" + shipmentId;
        String payload = Json.encode(Map.of(
            "shipmentId", shipmentId,
            "status", newStatus,
            "timestamp", Instant.now()
        ));
        return redis.publish(channel, payload).replaceWithVoid();
    }
}
```

---

## 7. CE0234 — Despliegue del Sistema

### 7.1 Docker Compose (Desarrollo local)

```yaml
# docker-compose.yml
version: '3.9'

services:
  postgres:
    image: postgis/postgis:16-3.4
    environment:
      POSTGRES_DB: logyx_db
      POSTGRES_USER: logyx_dba_user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U logyx_dba_user -d logyx_db"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_ROOT_USER}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD}
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data

  backend:
    build:
      context: ./logyx-backend
      dockerfile: src/main/docker/Dockerfile.jvm
    environment:
      QUARKUS_DATASOURCE_JDBC_URL: jdbc:postgresql://postgres:5432/logyx_db
      QUARKUS_DATASOURCE_USERNAME: logyx_app_user
      QUARKUS_DATASOURCE_PASSWORD: ${APP_DB_PASSWORD}
      QUARKUS_REDIS_HOSTS: redis://redis:6379
      MINIO_ENDPOINT: http://minio:9000
      JWT_SECRET: ${JWT_SECRET}
      ORS_API_KEY: ${ORS_API_KEY}
    ports:
      - "8080:8080"
    depends_on:
      postgres:
        condition: service_healthy

  web:
    build:
      context: ./logyx-web
      dockerfile: Dockerfile
    ports:
      - "4200:80"
    environment:
      API_URL: http://backend:8080

volumes:
  postgres_data:
  redis_data:
  minio_data:
```

### 7.2 Dockerfile Backend (Quarkus JVM)

```dockerfile
# logyx-backend/src/main/docker/Dockerfile.jvm
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app
COPY --chown=1001:root target/quarkus-app/lib/                  /app/lib/
COPY --chown=1001:root target/quarkus-app/*.jar                 /app/
COPY --chown=1001:root target/quarkus-app/app/                  /app/app/
COPY --chown=1001:root target/quarkus-app/quarkus/              /app/quarkus/

EXPOSE 8080
USER 1001

ENTRYPOINT ["java", \
  "-Djava.util.logging.manager=org.jboss.logmanager.LogManager", \
  "-jar", "/app/quarkus-run.jar"]
```

### 7.3 Instrucciones de Ejecución Local

```bash
# 1. Clonar el repositorio
git clone https://github.com/[org]/logyx.git
cd logyx

# 2. Copiar variables de entorno
cp .env.example .env
# Editar .env con credenciales locales

# 3. Levantar infraestructura
docker-compose up -d postgres redis minio

# 4. Iniciar backend en modo dev (hot reload)
cd logyx-backend
./mvnw quarkus:dev

# 5. Iniciar web en modo dev
cd ../logyx-web
npm install && ng serve

# 6. El backend estará en: http://localhost:8080
# 7. El frontend estará en: http://localhost:4200
# 8. Swagger UI: http://localhost:8080/q/swagger-ui
```

### 7.4 Variables de Entorno Requeridas

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `POSTGRES_PASSWORD` | Password del superusuario PostgreSQL | `dev_secret_123` |
| `APP_DB_PASSWORD` | Password del usuario de aplicación | `app_secret_456` |
| `JWT_SECRET` | Secreto para firmar JWT (mín. 256 bits) | `<cadena aleatoria 64 chars>` |
| `ORS_API_KEY` | API key de OpenRouteService | `5b3ce3...` |
| `MINIO_ROOT_USER` | Usuario admin MinIO | `logyx_admin` |
| `MINIO_ROOT_PASSWORD` | Password admin MinIO | `minio_secret` |
| `GOOGLE_CLIENT_ID` | Client ID para Google OAuth | `xxx.apps.googleusercontent.com` |

---

## 8. Evidencia Técnica

| Item | Estado | Referencia |
|------|--------|------------|
| Repositorio GitHub con código fuente | Pendiente — URL por agregar | — |
| Capturas del sistema en ejecución | Pendiente — agregar screenshots | — |
| URL del sistema en staging | Pendiente — agregar URL | — |
| Swagger UI / OpenAPI spec | Disponible en `/q/swagger-ui` local | — |
| Docker Compose funcionando | Verificar con `docker-compose ps` | Ver sección 7.3 |

---

## 9. Coherencia del Sistema

| Fuente | Relación con E3 |
|--------|----------------|
| **E1 SRS** (RF01–RF67) | Cada funcionalidad F01–F20 mapea directamente a un rango de RF. Ver tabla sección 3.1. |
| **E1 Arquitectura** (ADR-001 a ADR-005) | La arquitectura implementada respeta los 5 ADRs: monolito modular, Quarkus, 3 apps Flutter, PostgreSQL+PostGIS, ORS. |
| **E1 UML** (diagramas de clase) | Las 18 clases del diagrama UML corresponden 1:1 con las entities Panache del backend. |
| **E2 Modelo de datos** (22 tablas) | Los repositorios Panache consultan las mismas 22 tablas definidas en E2_ModeloDatos.md. |
| **E2 Scripts** (triggers y funciones) | Los triggers activan lógica de negocio automáticamente: `trg_moderate_message` antes de `MessageRepository.persist()`, `trg_lock_vehicle_capacity_on_shipment` antes de `ShipmentRepository.persist()`. |

---

*LOGYX · E3 Sistema Desarrollado · Competencias CE0231–CE0234 · Versión 1.0 · Junio 2026*
