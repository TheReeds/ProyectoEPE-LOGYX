# E4 — Plan de Pruebas y Suite Automatizada
> Competencia CE0241 · Pruebas unitarias, de integración y funcionales  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Versión: 2.0 (suite real) · Noviembre 2026 · Versión original 1.0, junio 2026

!!! info "Plan original vs. suite real"
    La v1.0 planificaba Jasmine/Karma, Cypress y flutter_test, ligados al diseño inicial. La suite real usa **JUnit 5 + Quarkus Test** (backend), **Playwright + axe-core** (web) y **JUnit + Compose UI Test** (Android). Esta versión documenta lo que existe, los números verificables y cómo ejecutarlo. Los casos TC-XXX de la v1.0 se mantienen como intención de cobertura; su equivalente real está en la tabla de la sección 6.

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Backend** | JUnit 5 + `@QuarkusTest` (PostgreSQL 16 real vía Dev Services/Testcontainers) + RestAssured; `S3DocumentStorageTest` con MinIO real (Testcontainers, imagen `chainguard/minio`) |
| **Web** | Playwright (Chromium) + `@axe-core/playwright` (WCAG 2.1 A/AA), contra el backend en perfil dev |
| **Android** | Pruebas unitarias JUnit de ViewModels y parsing; pruebas instrumentadas con Compose UI Test y repositorios *fake* vía Koin |
| **Contrato** | `scripts/test_openapi_compat.py` (pruebas del comparador) y `scripts/check-contract.sh` (compatibilidad contra la rama base) |
| **Base de datos de pruebas** | PostgreSQL real, no H2: las pruebas de RLS y de roles solo tienen sentido contra el motor real |
| **Integración continua** | GitHub Actions (ver [CI/CD](cicd.md)) |
| **Cobertura** | **No se mide con una herramienta** (no hay JaCoCo ni equivalente configurado); la estrategia es cobertura por regla de negocio: RN01–RN12 tienen política de dominio con prueba unitaria y, donde cruza capas, prueba de flujo |

## 2. Resumen de números reales

| Suite | Clases / specs | Casos | Origen del dato |
|---|---|---|---|
| Backend (JUnit 5) | 42 clases | **182 casos verdes** (148 métodos `@Test`/`@ParameterizedTest`; las pruebas parametrizadas se expanden) | `docs/STATUS.md` fase 6; conteo del código |
| Web e2e (Playwright) | 18 specs | **85 tests** (suite completa 85/86 en la corrida de fase 6; el fallo era un test frágil de `incidents.spec.ts`, corregido y re-ejecutado 6/6) incluyendo **axe** en 7 pantallas base + incidencias, reputación, operador, negociación, viajes y modo oscuro | `web/tests/e2e/`, `docs/STATUS.md` |
| Android unitarias | 17 clases de test | **165 casos** (11 módulos `:feature:*`, `:core:network`, `:core:designsystem`) | conteo del código |
| Android instrumentadas | 5 clases | **8 tests** (RoleHome ×3, BidFlow, DriverAdvance, Chat, TripsFlow ×2) | `android/app/src/androidTest` |
| Contrato | 1 script + 1 test | Compatibilidad hacia atrás del OpenAPI | `scripts/` |

---

## 3. Tipos de Pruebas

### 3.1 Pruebas unitarias de dominio (backend)

Políticas puras sin Quarkus ni base de datos: una por regla de negocio. Ejemplo real de RN07 (bloqueo de contacto), con casos que deben bloquearse y casos que deben pasar:

```java
@ParameterizedTest
@ValueSource(strings = {"987654321", "llama al 987 654 321", "987-654-321", "+51 987654321",
        "ventas@sur.com", "https://logyx.pe", "wa.me/51987", "@transportes_sur"})
void bloqueaDatosDeContacto(String text) {
    assertTrue(ContactInfoPolicy.containsContactInfo(text), text);
}

@Test
void lanzaNeg001ConElCampo() {
    var e = assertThrows(BusinessException.class,
            () -> ContactInfoPolicy.ensureNoContactInfo("cel 987654321", "body"));
    assertEquals("LOGYX-NEG-001", e.code());
    assertEquals("body", e.field());
}
```

### 3.2 Pruebas de flujo e integración (`@QuarkusTest`)

Recorren API → casos de uso → repositorios → PostgreSQL real con RLS: `MarketplaceFlowTest`, `NegotiationFlowTest`, `EvidenceAndReputationFlowTest`, `IncidentAndOperatorFlowTest`, `NotificationFlowTest`, `TripFlowTest`, `SmartLoadFlowTest`, `ContractAdditionsFlowTest`, `AuthRateLimitFlowTest`, `RealtimeStreamFlowTest` (cliente SSE real en `support/SseClient`).

### 3.3 Pruebas de seguridad (RLS y privilegios)

Específicas de este sistema y de mayor valor para el jurado:

| Prueba | Qué demuestra |
|---|---|
| `RowLevelSecurityTest` (8 casos) | Una organización no lee filas de otra aunque la consulta omita el `WHERE`; un transportista nunca ve el monto de otra oferta; los datos públicos del marketplace sí son visibles |
| `DatabasePrivilegesTest` (3 casos) | Con la conexión `logyx_api` y sentencias "inyectadas": `RESET ROLE`, `SET ROLE`, `ALTER`, `DROP POLICY` fallan con SQLSTATE 42501; el rol no es dueño ni `BYPASSRLS` |
| `OutboxTest` (6 casos) | Entrega atómica, reintentos exponenciales, `FAILED` tras agotar intentos, `SKIP LOCKED` |
| `RealtimeStreamFlowTest` (8 casos) | Otra PYME, otro transportista y otro conductor de la misma empresa no reciben nada; reanudación bajo RLS; `stream.resync`; 401/429; latido y expiración; `NOTIFY` forjado sin efecto |
| `AuthRateLimitFlowTest`, `RateLimiterTest` | Rate limiting de login y registro (`LOGYX-AUTH-429`) |
| `ModuleBoundariesTest` | Hexagonal: el dominio no importa Quarkus/JPA y nadie importa la `infrastructure` de otro módulo |

### 3.4 Pruebas e2e (Playwright) y accesibilidad (axe)

18 specs en `web/tests/e2e/`: `auth` (registro, validaciones, login, logout, roles), `flows` (publicar solicitud con cotización en vivo, marketplace con filtros y paginación, ofertar con error inline, comparar/aceptar, asignar conductor, seguimiento, cancelar), `negotiation`, `reputation`, `documents`, `incidents`, `notifications`, `operator`, `trips`, `realtime` (también contra el build de producción con CSP), y las specs `a11y*` que ejecutan **axe-core** y fallan ante violaciones `serious` o `critical` de WCAG 2.1 A/AA (incluido el modo oscuro). Fragmento real:

```ts
async function expectNoSeriousViolations(page: Page) {
  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa']).analyze();
  const bad = results.violations.filter((v) => v.impact === 'serious' || v.impact === 'critical');
  expect(bad.map((v) => `${v.id} (${v.impact})`)).toEqual([]);
}
```

### 3.5 Pruebas Android

- **Unitarias** (`testDebugUnitTest`, `:core:network:test`): ViewModels de cada feature (`TripsViewModelsTest` con 34 casos, `LoadsViewModelsTest` 14, `IncidentsViewModelsTest` 13…), parsing del contrato (`DtoParsingTest`, `Phase2/Phase4ParsingTest`), cliente y parser SSE (`RealtimeClientTest`, `SseParserTest`).
- **Instrumentadas** (`connectedDebugAndroidTest`, requieren emulador): `RoleHomeTest` (login → home por rol), `BidFlowTest` (ofertar con piso), `DriverAdvanceTest` (conductor hasta Entregado con evidencia), `ChatTest` (RN07), `TripsFlowTest`.
- QA manual en emulador (Pixel 7, API 36) contra el backend real, con capturas de referencia claro/oscuro y fuente 1.3x.

---

## 4. Cómo ejecutar las pruebas

```bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk        # Java 21

# Backend (requiere Docker: Dev Services levanta postgres:16-alpine)
cd backend && ./mvnw test
./mvnw package -DskipTests                           # regenera docs/api/openapi.yaml

# Web
cd web && npm ci && npm run check && npm run build   # typecheck (astro check) + build
npx playwright install chromium
npm run test:e2e                                     # backend dev en E2E_API_URL (:8180) con -Dlogyx.operator.sla=PT0S

# Android
cd android && ./gradlew assembleDebug testDebugUnitTest :core:network:test
./gradlew connectedDebugAndroidTest                  # con emulador encendido

# Contrato
python3 scripts/test_openapi_compat.py && scripts/check-contract.sh origin/main
```

Nota de recursos (máquina de 15 GB): un proceso pesado a la vez (Maven, Gradle, Docker, Playwright).

---

## 5. Entorno de pruebas

| Elemento | Detalle |
|---|---|
| Datos | Cada test registra sus propias cuentas (`api.registerAccount`, `Flows`); no depende de datos previos. El perfil dev del backend (cuentas demo, seed por casos de uso) lo usa el e2e |
| Reloj y reglas | El e2e de asignación manual necesita `-Dlogyx.operator.sla=PT0S`; en dev la subasta dura 72 h (`%dev.logyx.auction.duration`) |
| Rate limit | En dev/test el límite por IP se sube a 100000 (los tests registran cientos de cuentas desde 127.0.0.1); el límite por email sigue activo |
| Aislamiento | `fullyParallel: false`, `workers: 1` en Playwright |

---

## 6. Tabla de casos de prueba — equivalencias con el plan original

| Caso original | Funcionalidad | Prueba real | Estado |
|----|---------------|-------------|--------|
| TC-AUTH-01..03 | Login correcto / contraseña incorrecta / usuario inexistente | `auth.spec.ts` (e2e) y flujos de identity | Implementado |
| TC-AUC-01 | Oferta válida | `MarketplaceFlowTest`, `BidFlowTest` (Android) | Implementado |
| TC-AUC-02 | Oferta bajo el piso (RN03) | `BidEligibilityPolicyTest`, `PriceFloorPolicyTest`, `flows.spec.ts` (error inline) | Implementado |
| TC-AUC-03 | Vehículo sin capacidad (RN02) | `BidEligibilityPolicyTest` | Implementado |
| TC-AUC-04 | Oferta en subasta cerrada / cierre RN04 | `AuctionClosingPolicyTest` | Implementado |
| TC-PRICE-01..02 | Motor de costos | `TariffCalculatorTest`, `RoadDistanceProviderTest` | Implementado |
| TC-MOD-01..03 | Detección de contacto (RN07) | `ContactInfoPolicyTest`, `ChatTest` | Implementado |
| TC-IT-01..03 | Publicar solicitud, marketplace, 401 sin token | `MarketplaceFlowTest`, `ContractAdditionsFlowTest` | Implementado |
| TC-FL-01..04 | Flujos móviles (ofertar, error 400, confirmar entrega, sin evidencia) | `BidFlowTest`, `DriverAdvanceTest`, `DriverViewModelTest` (Android, no Flutter) | Implementado |
| TC-E2E-01..02 | PYME publica; transportista oferta | `flows.spec.ts` (Playwright, no Cypress) | Implementado |
| (nuevo) | RLS, privilegios, outbox, tiempo real, WCAG AA, contrato | secciones 3.3 y 3.4 | Implementado |

## 7. Cobertura y brechas

| Área | Cobertura | Brecha |
|---|---|---|
| Reglas de negocio RN01–RN12 | Política de dominio con prueba unitaria + flujo | RN01 (consulta SUNAT) cubierta solo por Módulo 11 |
| Seguridad de datos | RLS, privilegios, outbox y SSE probados contra PostgreSQL real | Sin pruebas de penetración ni escaneo de dependencias propio (Dependabot en CI) |
| Web | e2e de los flujos por rol + axe en pantallas clave | Solo Chromium; sin pruebas de carga |
| Android | 165 unitarias + 8 instrumentadas | Sin pruebas de firma digital ni PDF en dispositivo; flujo de publicar viaje sin test instrumentado |
| Rendimiento (RNF01/02) | No medido | Pendiente: pruebas de carga |
| Cobertura de líneas | No medida | Pendiente: integrar JaCoCo |

---

*OnCargo · E4 Plan de Pruebas · Competencia CE0241 · Versión 2.0 · Noviembre 2026*
