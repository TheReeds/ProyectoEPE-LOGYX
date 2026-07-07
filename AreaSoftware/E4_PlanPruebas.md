# E4 — Plan de Pruebas y Suite Automatizada
> Competencia CE0241 · Pruebas unitarias, de integración y funcionales  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Versión: 1.0 · Junio 2026

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Framework de pruebas (backend)** | JUnit 5 + Quarkus Test + Mockito + RestAssured |
| **Framework de pruebas (frontend web)** | Jasmine + Karma (unit) · Cypress (E2E) |
| **Framework de pruebas (Flutter)** | flutter_test (unit + widget) · integration_test |
| **Base de datos de pruebas** | PostgreSQL 16 en Docker (Testcontainers) — ver nota de implementación abajo |
| **Cobertura objetivo** | ≥ 70% en módulos de negocio críticos |
| **Integración** | GitHub Actions (ver E4_CICD.md) |

> **Nota de implementación (agregada 2026-07-06):** los módulos ya construidos (Auth, Organizations,
> Profiles, Vehicles, Drivers, Marketplace, Auctions, Bids, Pricing) **no usan Testcontainers ni
> Mockito `@InjectMock`** como se planificó aquí. Se optó por `@QuarkusTest` contra el Postgres y
> Redis reales de `docker-compose.yml` (los mismos contenedores de desarrollo, sin mocks de
> repositorio), con fixtures de datos "find-or-create" por UUID fijo en cada `@BeforeEach` y
> `@TestSecurity`/`@JwtSecurity` para simular el JWT. Los tests reales viven junto a cada módulo:
> `src/test/java/pe/logyx/{auth,organization,profile,vehicle,driver,marketplace,auction,bid,pricing}/`.
> Los casos TC-XXX de este documento describen la intención/cobertura correctamente, pero el código
> Java de ejemplo (estilo `Uni<T>`, `Profile.builder()`, `@InjectMock`) no corresponde a cómo se
> escribió el código real — ver los archivos `*ResourceTest.java` de cada paquete para la versión
> vigente.

---

## 2. Tipos de Pruebas

### 2.1 Pruebas Unitarias
Validan lógica aislada de servicios sin dependencias externas. Usan Mockito para inyecciones.

### 2.2 Pruebas de Integración
Validan el stack completo (API → Servicio → Repositorio → BD real via Testcontainers).

### 2.3 Pruebas Funcionales / E2E
Validan flujos completos desde la perspectiva del usuario (Cypress en web, integration_test en Flutter).

---

## 3. Casos de Prueba — Backend (JUnit 5 + Quarkus Test)

### 3.1 Módulo AUTH

```java
// AuthServiceTest.java
@QuarkusTest
class AuthServiceTest {

    @Inject AuthService authService;
    @InjectMock ProfileRepository profileRepo;

    @Test
    @DisplayName("TC-AUTH-01: Login exitoso retorna par de tokens")
    void loginSuccessReturnsTokenPair() {
        Profile mockProfile = Profile.builder()
            .email("test@logyx.pe")
            .passwordHash(BCrypt.hashpw("Password1!", BCrypt.gensalt(12)))
            .role(ProfileRole.ADMIN)
            .build();

        when(profileRepo.findByEmail("test@logyx.pe"))
            .thenReturn(Uni.createFrom().item(mockProfile));

        TokenPair result = authService
            .authenticate("test@logyx.pe", "Password1!")
            .await().indefinitely();

        assertNotNull(result.accessToken());
        assertNotNull(result.refreshToken());
        assertTrue(result.accessToken().split("\\.").length == 3); // formato JWT
    }

    @Test
    @DisplayName("TC-AUTH-02: Login con contraseña incorrecta lanza UnauthorizedException")
    void loginWrongPasswordThrows() {
        Profile mockProfile = Profile.builder()
            .email("test@logyx.pe")
            .passwordHash(BCrypt.hashpw("OtraPass", BCrypt.gensalt(12)))
            .build();

        when(profileRepo.findByEmail("test@logyx.pe"))
            .thenReturn(Uni.createFrom().item(mockProfile));

        assertThrows(UnauthorizedException.class, () ->
            authService.authenticate("test@logyx.pe", "Password1!")
                .await().indefinitely()
        );
    }

    @Test
    @DisplayName("TC-AUTH-03: Login con usuario inexistente lanza UnauthorizedException")
    void loginUnknownEmailThrows() {
        when(profileRepo.findByEmail(anyString()))
            .thenReturn(Uni.createFrom().nullItem());

        assertThrows(UnauthorizedException.class, () ->
            authService.authenticate("noexiste@logyx.pe", "Pass")
                .await().indefinitely()
        );
    }
}
```

### 3.2 Módulo AUCTION

```java
// AuctionServiceTest.java
@QuarkusTest
class AuctionServiceTest {

    @Inject AuctionService auctionService;
    @InjectMock AuctionRepository auctionRepo;
    @InjectMock BidRepository bidRepo;
    @InjectMock VehicleRepository vehicleRepo;

    @Test
    @DisplayName("TC-AUC-01: Oferta válida se persiste correctamente")
    void validBidIsPersisted() {
        UUID auctionId = UUID.randomUUID();
        UUID carrierId  = UUID.randomUUID();
        UUID vehicleId  = UUID.randomUUID();

        Auction auction = buildOpenAuction(auctionId, new BigDecimal("2800.00")); // price_floor=2100
        Vehicle vehicle = buildVehicle(vehicleId, new BigDecimal("15000"), BigDecimal.ZERO);

        when(auctionRepo.findById(auctionId)).thenReturn(Uni.createFrom().item(auction));
        when(vehicleRepo.findById(vehicleId)).thenReturn(Uni.createFrom().item(vehicle));
        when(bidRepo.persist(any())).thenAnswer(inv -> Uni.createFrom().item(inv.getArgument(0)));

        PlaceBidRequest req = new PlaceBidRequest(vehicleId, new BigDecimal("2500.00"), "Disponible mañana");

        Bid result = auctionService.placeBid(auctionId, req, carrierId)
            .await().indefinitely();

        assertEquals(new BigDecimal("2500.00"), result.amount);
        assertEquals(BidStatus.PENDING, result.status);
    }

    @Test
    @DisplayName("TC-AUC-02: Oferta por debajo del price_floor lanza BusinessException")
    void bidBelowPriceFloorThrows() {
        UUID auctionId = UUID.randomUUID();
        Auction auction = buildOpenAuction(auctionId, new BigDecimal("2800.00")); // floor=2100

        when(auctionRepo.findById(auctionId)).thenReturn(Uni.createFrom().item(auction));
        when(vehicleRepo.findById(any())).thenReturn(Uni.createFrom().item(buildVehicle(
            UUID.randomUUID(), new BigDecimal("15000"), BigDecimal.ZERO)));

        PlaceBidRequest req = new PlaceBidRequest(UUID.randomUUID(), new BigDecimal("1500.00"), "");

        BusinessException ex = assertThrows(BusinessException.class, () ->
            auctionService.placeBid(auctionId, req, UUID.randomUUID())
                .await().indefinitely()
        );
        assertTrue(ex.getMessage().contains("LOGYX-BID-001"));
    }

    @Test
    @DisplayName("TC-AUC-03: Oferta rechazada si vehículo no tiene capacidad")
    void bidRejectedWhenVehicleAtCapacity() {
        UUID auctionId = UUID.randomUUID();
        Auction auction = buildOpenAuction(auctionId, new BigDecimal("2800.00"));
        // Vehículo al 100% de capacidad
        Vehicle vehicle = buildVehicle(UUID.randomUUID(),
            new BigDecimal("8000"), new BigDecimal("8000"));

        when(auctionRepo.findById(auctionId)).thenReturn(Uni.createFrom().item(auction));
        when(vehicleRepo.findById(any())).thenReturn(Uni.createFrom().item(vehicle));

        PlaceBidRequest req = new PlaceBidRequest(vehicle.id, new BigDecimal("2500.00"), "");

        assertThrows(BusinessException.class, () ->
            auctionService.placeBid(auctionId, req, UUID.randomUUID())
                .await().indefinitely()
        );
    }

    @Test
    @DisplayName("TC-AUC-04: No se puede ofertar en subasta cerrada")
    void cannotBidOnClosedAuction() {
        UUID auctionId = UUID.randomUUID();
        Auction auction = buildOpenAuction(auctionId, new BigDecimal("2800.00"));
        auction.status = AuctionStatus.CLOSED;

        when(auctionRepo.findById(auctionId)).thenReturn(Uni.createFrom().item(auction));

        assertThrows(BusinessException.class, () ->
            auctionService.placeBid(auctionId,
                new PlaceBidRequest(UUID.randomUUID(), new BigDecimal("2500.00"), ""),
                UUID.randomUUID())
                .await().indefinitely()
        );
    }
}
```

### 3.3 Módulo PRICING

```java
// PricingServiceTest.java
@QuarkusTest
class PricingServiceTest {

    @Inject PricingService pricingService;
    @InjectMock OpenRouteServiceClient orsClient;

    @Test
    @DisplayName("TC-PRICE-01: Cálculo correcto para carga general Lima-Arequipa")
    void correctCalculationGeneralCargoLimaArequipa() {
        OrsRoute mockRoute = new OrsRoute(
            new BigDecimal("1014500"),   // 1014.5 km en metros
            new BigDecimal("46800")      // 780 min en segundos
        );
        when(orsClient.getRoute(anyDouble(), anyDouble(), anyDouble(), anyDouble()))
            .thenReturn(Uni.createFrom().item(mockRoute));

        ShipmentRequest req = ShipmentRequest.builder()
            .weightKg(new BigDecimal("3500"))
            .cargoType(CargoType.GENERAL)
            .originLat(-12.0731).originLng(-77.0826)
            .destinationLat(-16.3989).destinationLng(-71.5370)
            .build();

        CostCalculation result = pricingService.calculate(req).await().indefinitely();

        assertTrue(result.distanceKm.compareTo(new BigDecimal("1014")) > 0);
        assertTrue(result.totalEstimate.compareTo(BigDecimal.ZERO) > 0);
        // Verificar que el total es la suma de los componentes
        BigDecimal expectedTotal = result.fuelCost
            .add(result.baseTransportCost)
            .add(result.tollCost)
            .add(result.handlingFee);
        assertEquals(0, result.totalEstimate.compareTo(expectedTotal));
    }

    @Test
    @DisplayName("TC-PRICE-02: Carga frágil aplica multiplicador 1.30")
    void fragileCargoPriceMultiplierApplied() {
        OrsRoute route = new OrsRoute(new BigDecimal("500000"), new BigDecimal("18000"));
        when(orsClient.getRoute(anyDouble(), anyDouble(), anyDouble(), anyDouble()))
            .thenReturn(Uni.createFrom().item(route));

        ShipmentRequest general = buildRequest(new BigDecimal("1000"), CargoType.GENERAL);
        ShipmentRequest fragile = buildRequest(new BigDecimal("1000"), CargoType.FRAGILE);

        CostCalculation calcGeneral = pricingService.calculate(general).await().indefinitely();
        CostCalculation calcFragile = pricingService.calculate(fragile).await().indefinitely();

        BigDecimal ratio = calcFragile.baseTransportCost
            .divide(calcGeneral.baseTransportCost, 2, HALF_UP);

        assertEquals(0, ratio.compareTo(new BigDecimal("1.30")));
    }
}
```

### 3.4 Módulo MODERATION (función fn_contains_contact_info)

```java
// MessageModerationServiceTest.java
@QuarkusTest
class MessageModerationServiceTest {

    @Inject MessageModerationService moderator;

    @ParameterizedTest
    @DisplayName("TC-MOD-01: Detecta teléfonos peruanos de 9 dígitos")
    @ValueSource(strings = {
        "Llámame al 987654321",
        "Mi cel es 912345678 para coordinar",
        "987123456 precio mejor afuera"
    })
    void detectsPeruvianPhoneNumbers(String text) {
        assertTrue(moderator.containsContactInfo(text),
            "Debería detectar número de teléfono en: " + text);
    }

    @ParameterizedTest
    @DisplayName("TC-MOD-02: Detecta emails")
    @ValueSource(strings = {
        "Escríbeme a carlos@transportes.com",
        "correo: juan.perez@gmail.com para cotizar"
    })
    void detectsEmails(String text) {
        assertTrue(moderator.containsContactInfo(text));
    }

    @ParameterizedTest
    @DisplayName("TC-MOD-03: No bloquea mensajes legítimos")
    @ValueSource(strings = {
        "Puedo salir mañana con 3 toneladas",
        "El precio incluye peajes en la ruta",
        "Tengo disponibilidad para el 5 de julio"
    })
    void doesNotBlockLegitimateMessages(String text) {
        assertFalse(moderator.containsContactInfo(text));
    }
}
```

### 3.5 Pruebas de Integración — API REST

```java
// ShipmentRequestResourceIT.java
@QuarkusIntegrationTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class ShipmentRequestResourceIT {

    static String accessToken;
    static UUID createdRequestId;

    @BeforeAll
    static void login() {
        accessToken = given()
            .contentType(ContentType.JSON)
            .body("""{"email":"maria.torres@textilesarequipa.pe","password":"Test1234!"}""")
            .when().post("/api/v1/auth/login")
            .then().statusCode(200)
            .extract().path("data.accessToken");
    }

    @Test @Order(1)
    @DisplayName("TC-IT-01: PYME puede publicar solicitud de carga")
    void pymeCanPublishShipmentRequest() {
        String requestBody = """
            {
              "originAddress": "Av. La Marina 1200, Lima",
              "originLat": -12.0731, "originLng": -77.0826,
              "destinationAddress": "Mercaderes 120, Arequipa",
              "destinationLat": -16.3989, "destinationLng": -71.5370,
              "weightKg": 2000,
              "cargoType": "general",
              "requiredDate": "2026-07-15"
            }
            """;

        createdRequestId = given()
            .header("Authorization", "Bearer " + accessToken)
            .contentType(ContentType.JSON)
            .body(requestBody)
            .when().post("/api/v1/shipment-requests")
            .then()
            .statusCode(201)
            .body("data.status", equalTo("open"))
            .body("data.suggestedPrice", notNullValue())
            .extract().path("data.id");

        assertNotNull(createdRequestId);
    }

    @Test @Order(2)
    @DisplayName("TC-IT-02: La solicitud aparece en el marketplace")
    void requestAppearsInMarketplace() {
        given()
            .header("Authorization", "Bearer " + accessToken)
            .when().get("/api/v1/shipment-requests?status=open")
            .then()
            .statusCode(200)
            .body("data", hasSize(greaterThanOrEqualTo(1)));
    }

    @Test @Order(3)
    @DisplayName("TC-IT-03: Solicitud sin token retorna 401")
    void unauthenticatedRequestReturns401() {
        given()
            .when().get("/api/v1/shipment-requests")
            .then().statusCode(401);
    }
}
```

---

## 4. Casos de Prueba — Flutter (flutter_test)

```dart
// auction_service_test.dart
void main() {
  group('AuctionService', () {
    late AuctionService service;
    late MockApiService mockApi;

    setUp(() {
      mockApi  = MockApiService();
      service  = AuctionService(api: mockApi);
    });

    test('TC-FL-01: placeBid retorna Bid al recibir 201', () async {
      when(mockApi.post(any, any, any)).thenAnswer((_) async => {
        'id': 'bid-uuid',
        'amount': 2500.0,
        'status': 'pending',
      });

      final bid = await service.placeBid(
        auctionId: 'auction-uuid',
        vehicleId: 'vehicle-uuid',
        amount: 2500.0,
        notes: 'Disponible hoy',
      );

      expect(bid.amount, equals(2500.0));
      expect(bid.status, equals('pending'));
    });

    test('TC-FL-02: Error 400 por precio bajo lanza BusinessException', () async {
      when(mockApi.post(any, any, any))
          .thenThrow(ApiException(statusCode: 400, code: 'LOGYX-BID-001'));

      expect(
        () => service.placeBid(
          auctionId: 'auction-uuid',
          vehicleId: 'vehicle-uuid',
          amount: 500.0,
          notes: '',
        ),
        throwsA(isA<BusinessException>()),
      );
    });
  });
}
```

```dart
// delivery_confirm_widget_test.dart
void main() {
  testWidgets('TC-FL-03: DeliveryConfirmScreen muestra botones de foto y firma',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DeliveryConfirmScreen(
          stopId: 'stop-uuid',
          location: 'Av. Test 123',
        ),
      ),
    );

    expect(find.text('Tomar foto'), findsOneWidget);
    expect(find.text('Capturar firma'), findsOneWidget);
    expect(find.text('Confirmar entrega'), findsOneWidget);
  });

  testWidgets('TC-FL-04: No se puede confirmar sin foto y firma',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: DeliveryConfirmScreen(stopId: 'x', location: 'y')),
    );

    await tester.tap(find.text('Confirmar entrega'));
    await tester.pump();

    expect(find.text('Debes tomar la foto y capturar la firma'), findsOneWidget);
  });
}
```

---

## 5. Casos de Prueba E2E — Cypress (Web)

```javascript
// cypress/e2e/pyme_publish_request.cy.js

describe('PYME: Publicar solicitud de carga', () => {
  beforeEach(() => {
    cy.login('maria.torres@textilesarequipa.pe', 'Test1234!');
  });

  it('TC-E2E-01: PYME publica solicitud y ve cotización estimada', () => {
    cy.visit('/pyme/requests/new');

    // Paso 1: origen y destino
    cy.get('[data-cy=origin-address]').type('Av. La Marina 1200, Lima');
    cy.get('[data-cy=destination-address]').type('Mercaderes 120, Arequipa');
    cy.get('[data-cy=next-step]').click();

    // Paso 2: carga
    cy.get('[data-cy=weight-kg]').type('2000');
    cy.get('[data-cy=cargo-type]').select('general');
    cy.get('[data-cy=required-date]').type('2026-07-15');
    cy.get('[data-cy=next-step]').click();

    // Paso 3: cotización
    cy.get('[data-cy=estimated-price]').should('be.visible');
    cy.get('[data-cy=distance-km]').should('contain.text', 'km');
    cy.get('[data-cy=confirm-publish]').click();

    // Verificar redirección a lista de solicitudes
    cy.url().should('include', '/pyme/requests');
    cy.get('[data-cy=request-status-badge]').first().should('contain', 'open');
  });

  it('TC-E2E-02: Carrier ve solicitud en marketplace y hace oferta', () => {
    cy.loginAs('carlos@colcaexpress.pe', 'Test1234!');
    cy.visit('/carrier/marketplace');

    cy.get('[data-cy=bid-button]').first().click();
    cy.get('[data-cy=bid-amount]').type('2400');
    cy.get('[data-cy=bid-vehicle]').select('A3T-456');
    cy.get('[data-cy=submit-bid]').click();

    cy.get('[data-cy=success-toast]').should('contain', 'Oferta enviada');
  });
});
```

---

## 6. Tabla de Casos de Prueba (Resumen)

| ID | Funcionalidad | Tipo | Resultado esperado | Estado |
|----|---------------|------|--------------------|--------|
| TC-AUTH-01 | Login correcto | Unit | TokenPair no nulo | Pendiente |
| TC-AUTH-02 | Login contraseña incorrecta | Unit | UnauthorizedException | Pendiente |
| TC-AUTH-03 | Login usuario inexistente | Unit | UnauthorizedException | Pendiente |
| TC-AUC-01 | Oferta válida | Unit | Bid persistida | Pendiente |
| TC-AUC-02 | Oferta bajo price_floor | Unit | BusinessException LOGYX-BID-001 | Pendiente |
| TC-AUC-03 | Oferta vehículo sin capacidad | Unit | BusinessException LOGYX-CAP-001 | Pendiente |
| TC-AUC-04 | Oferta en subasta cerrada | Unit | BusinessException LOGYX-AUC-001 | Pendiente |
| TC-PRICE-01 | Cálculo Lima-Arequipa general | Unit | Total > 0, suma coherente | Pendiente |
| TC-PRICE-02 | Multiplicador carga frágil | Unit | ratio = 1.30 | Pendiente |
| TC-MOD-01 | Detección teléfonos | Unit | containsContactInfo = true | Pendiente |
| TC-MOD-02 | Detección emails | Unit | containsContactInfo = true | Pendiente |
| TC-MOD-03 | Mensajes legítimos | Unit | containsContactInfo = false | Pendiente |
| TC-IT-01 | Publicar solicitud (API) | Integración | HTTP 201, status='open' | Pendiente |
| TC-IT-02 | Solicitud en marketplace | Integración | Lista no vacía | Pendiente |
| TC-IT-03 | Sin token retorna 401 | Integración | HTTP 401 | Pendiente |
| TC-FL-01 | placeBid Flutter OK | Unit Flutter | Bid retornada | Pendiente |
| TC-FL-02 | Error 400 Flutter | Unit Flutter | BusinessException | Pendiente |
| TC-FL-03 | UI confirmar entrega | Widget | Botones visibles | Pendiente |
| TC-FL-04 | Confirmar sin evidencia | Widget | Mensaje de error visible | Pendiente |
| TC-E2E-01 | PYME publica solicitud | E2E Cypress | Solicitud aparece en lista | Pendiente |
| TC-E2E-02 | Carrier hace oferta | E2E Cypress | Toast de confirmación | Pendiente |

---

## 7. Cobertura de Pruebas

| Módulo | Pruebas unitarias | Pruebas de integración | Cobertura estimada |
|--------|-----------------|----------------------|-------------------|
| auth | 3 casos | 2 vía IT | ~80% |
| auction | 4 casos | 1 vía IT | ~75% |
| pricing | 2 casos | — | ~70% |
| negotiation (moderation) | 3 casos | — | ~70% |
| tracking | — | Pendiente | ~50% |
| reputation | — | Pendiente | ~50% |
| fleet | — | Pendiente | ~40% |
| **Total estimado** | | | **≥ 65%** |

---

*LOGYX · E4 Plan de Pruebas · Competencia CE0241 · Versión 1.0 · Junio 2026*
