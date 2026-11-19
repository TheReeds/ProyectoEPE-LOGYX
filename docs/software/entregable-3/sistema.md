# E3 — Sistema Desarrollado
> Competencias CE0231 (Implementación) · CE0232 (Integración) · CE0233 (Arquitectura) · CE0234 (Despliegue)  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Versión: 2.0 (sistema construido) · Noviembre 2026 · Versión original 1.0, junio 2026

!!! info "Documento reescrito sobre el código real"
    La v1.0 se escribió antes del código y contenía ejemplos de un diseño que no se construyó (Angular, Flutter, Redis, WebSocket, ORS) y un despliegue en AWS. La v2.0 describe el sistema **implementado** y todos los fragmentos de código son extractos breves del repositorio `logyx` (rutas indicadas). Los cambios de diseño están justificados en [Cambios respecto al diseño inicial](../cambios-diseno-inicial.md), que incluye el rebrand a OnCargo y la migración del despliegue a un VPS Hostinger.

!!! note "Capturas previas al rebrand"
    Las capturas de pantalla de este entregable (`entregable-3/img/`) se tomaron **antes del rebrand**: la interfaz muestra la marca LOGYX. No se regeneraron; la funcionalidad es la misma. Ver [la nota correspondiente](../cambios-diseno-inicial.md#5-capturas-de-pantalla-previas-al-rebrand).

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Tipo de sistema** | Marketplace B2B de fletes con web, app móvil Android y API |
| **Plataformas** | Web (Astro 7 SSR) · Android nativo (Kotlin + Compose) · iOS (SwiftUI) planificado |
| **Componentes** | `backend/` (API Quarkus) · `web/` · `android/` · `ios/` (README) · `infra/` · `docs/` |
| **Backend** | Quarkus 3.40, Java 21, monolito modular hexagonal, 23 módulos de negocio + núcleo `shared` |
| **Base de datos** | PostgreSQL 16 con RLS, 57 tablas y 150 políticas, migraciones Flyway V1–V24 |
| **Contrato** | `docs/api/openapi.yaml` generado por el backend (210 rutas, 242 operaciones, 435 schemas al 19-nov-2026) |
| **Roles** | PYME, Transportista, Conductor, Operador OnCargo (solo web) |
| **Estado** | Sistema funcional probado de extremo a extremo; despliegue por contenedores verificado localmente |
| **Dimensión** | ≈ 43,100 líneas Java (672 archivos), ≈ 27,600 de web (sin el cliente generado), ≈ 25,400 de Kotlin (sin pruebas) |

---

## 2. CE0233 — Arquitectura Implementada

### 2.1 Tipo y Justificación

OnCargo es un **monolito modular con arquitectura hexagonal por módulo** (ADR-0002). Cada capacidad de negocio es un paquete con `domain` (reglas puras), `application` (casos de uso transaccionales) e `infrastructure` (adaptadores). Un módulo usa a otro solo por su `application`; `ModuleBoundariesTest` lo verifica en cada build. Esto permite extraer módulos con carga a servicios sin reescribir el dominio. Ver [Arquitectura](../entregable-1/arquitectura.md).

### 2.2 Estructura del Backend (Quarkus)

```
backend/src/main/java/pe/logyx/
├── identity/      registro, login, organizaciones, usuarios (consentimiento Ley 29733)
├── fleet/         vehículos y conductores
├── catalog/       ciudades y tipos de carga (vocabulario compartido)
├── pricing/       motor de costos por reglas: TariffCalculator, PriceFloorPolicy (RN03), DistanceProvider
├── marketplace/   solicitudes, subasta inversa, ofertas, aceptación, asignación manual
├── shipment/      envíos, paradas, app del conductor, tracking
├── negotiation/   chat (RN07) y contraofertas
├── documents/     evidencia y documentos; puerto DocumentStorage (local | S3-compatible: R2, MinIO)
├── reputation/    calificaciones (RN06) y Trust Score bayesiano (RN09)
├── incident/      incidencias y comentarios (RN11)
├── notification/  centro de notificaciones alimentado por el outbox
├── operator/      alertas SLA, métricas, asignación manual (RN10)
├── trip/          viajes publicados (RN12), reservas, cargas de retorno, Smart Load
├── dashboard/     resumen por rol
├── realtime/      stream SSE y proyección por destinatario (ADR-0007)
├── devdata/       seed demo (solo perfil dev)
└── shared/        {data,meta}, errores LOGYX-XXX-NNN, tenancy/RLS (TenantContext, SystemTx), outbox, auditoría
    └── <modulo>/{domain, application, infrastructure}
```

Fragmento real de un caso de uso (`marketplace/application/AcceptBidUseCase`, RN05): la PYME acepta una oferta; en una sola transacción se cierra la subasta, se rechazan las demás ofertas, se adjudica la solicitud, se crea el envío y se publica el evento.

```java
@Transactional(Transactional.TxType.MANDATORY)
public AcceptOutcome award(ShipmentRequest r, Bid bid, String auditAction) {
    Auction a = auctions.findByRequest(r.id()).orElseThrow();
    a.closeIfOpen(Auction.CloseReason.ACCEPTED, OffsetDateTime.now());
    auctions.save(a);

    bid.accept();
    bids.save(bid);
    List<Bid> others = bids.listPendingByRequest(r.id()).stream()
            .filter(o -> !o.id().equals(bid.id())).toList();
    others.forEach(o -> { o.reject(); bids.save(o); });

    r.matchTo(bid.carrierOrgId());
    requests.save(r);
    UUID shipmentId = shipments.createFromAcceptedBid(/* ... */);
    audit.record(tenant.profileId(), tenant.orgId(), auditAction, "bid", bid.id(), /* ... */);
    bidAccepted.fire(new BidAccepted(/* ... */));   // evento -> outbox -> avisos y tiempo real
    return new AcceptOutcome(shipmentId, /* ... */);
}
```

### 2.3 Estructura del Frontend Web (Astro)

```
web/src/
├── pages/                 rutas finas por rol: /pyme, /transportista, /operador, /conductor, /login, /registro, /privacidad…
├── features/<feature>/    server.ts (llamadas a la API) · actions.ts (Astro Actions) · components/ (islas React)
├── components/{ui, domain, layout, dev}   biblioteca de diseño (shadcn/ui sobre Radix), StatusPill/RouteLine/KpiTile, AppShell
├── lib/{api, session.ts, realtime.ts, actions.ts, format.ts}
├── middleware.ts          sesión, control por rol, cabeceras de seguridad/CSP
└── styles/global.css      tokens de diseño (claro y oscuro)
```

Detalle en [Arquitectura Frontend](arquitectura-frontend.md).

### 2.4 Estructura de la App Android (Kotlin / Compose)

```
android/
├── app/                   Activity, Application (Koin), navegación raíz por rol
├── core/model/            Kotlin/JVM puro: DTOs @Serializable del contrato y reglas de cliente
├── core/network/          Kotlin/JVM puro: Ktor + LogyxApi + cliente SSE
├── core/data/             repositorios, sesión (DataStore), cola de evidencia
├── core/designsystem/     tema OnCargo, componentes Compose, mapa MapLibre
└── feature/{auth, loads, requests, shipments, driver, negotiation, reputation, documents, incidents, notifications, trips}
```

Un feature nunca depende de otro feature; `:app` cablea la navegación. Detalle en [Arquitectura Frontend §5](arquitectura-frontend.md#5-android-kotlin-jetpack-compose-multi-modulo).

---

## 3. CE0231 — Funcionalidades Implementadas

### 3.1 Tabla de Funcionalidades por Módulo

| Módulo | Funcionalidad | RF / RN | Web | Android | Estado |
|---|---|---|---|---|---|
| `identity` | Registro multi-rol con RUC (Módulo 11), consentimiento, login JWT, rate limiting | RF01–RF05, RF07–RF08, RN01, RNF18 | Sí | Login | Implementado (sin Google, sin SUNAT) |
| `fleet` | Vehículos, conductores, asignación | RF03, RF64–RF67 | Sí | Asignar conductor | Implementado |
| `pricing` | Cotización en vivo, piso del 75 % | RF10, RN03 | Sí | Oferta | Implementado (distancia por carretera, ADR-0008) |
| `marketplace` | Publicar, subasta inversa 20 min / 5 ofertas, ofertar, aceptar, cancelar | RF09–RF20, RN01–RN05 | Sí | Sí | Implementado |
| `negotiation` | Chat con bloqueo de contacto, contraoferta bidireccional | RF25–RF29, RN07 | Sí | Sí | Implementado |
| `shipment` | Envíos, paradas secuenciales, conductor | RF34–RF39, RN08 | Sí (mapa) | Sí (modo conductor) | Implementado (sin ETA ni código LGX) |
| `documents` | Foto de entrega, firma, guías; R2/S3 (MinIO en staging) | RF37, RF46–RF47 | Sí | Sí (cola persistente) | Implementado |
| `reputation` | Calificaciones, Trust Score, perfil público | RF40–RF41, RF44–RF45, RN06, RN09 | Sí | Sí | Implementado (score bayesiano) |
| `incident` | Reportar, comentar, resolver; congela el envío | RF52–RF55, RN11 | Sí | Sí | Implementado (RF53/55 parciales) |
| `notification` + `realtime` | Avisos in-app y SSE en vivo | RF49, RF51, RNF25 | Sí | Sí | Implementado (sin email) |
| `operator` | Métricas, alertas SLA, asignación manual, listados | RF56–RF58, RF60, RN10 | Sí | No (solo web) | Implementado (sin Smart Load) |
| `trip` | Viajes publicados, reservas, retornos, Smart Load | RF21–RF24, RF30–RF33, RF61–RF63, RN12 | Sí | Sí | Implementado |
| `dashboard` | Resumen por rol | — | Sí | Sí | Implementado |

### 3.2 Implementación de Módulos Clave

#### Reglas de negocio como políticas de dominio

Cada regla es una clase pura con nombre, lo que permite probarla sin base de datos (`PriceFloorPolicyTest`) y localizarla (tabla en `docs/domain/business-rules.md`). Ejemplo, RN03 (`pricing/domain/PriceFloorPolicy`):

```java
public BigDecimal floorFor(BigDecimal suggestedPrice) {
    return suggestedPrice.multiply(ratio).setScale(2, RoundingMode.HALF_UP);   // ratio = logyx.pricing.floor-ratio (0.75)
}
public boolean accepts(BigDecimal amount, BigDecimal floor) {
    return amount.compareTo(floor) >= 0;
}
```

#### Motor de costos (PRICING)

`TariffCalculator` calcula el precio sugerido por reglas (distancia, peso, tipo de carga); la distancia sale del puerto `DistanceProvider`, implementado por `RoadDistanceProvider`, que delega en `RoutePlanner` (módulo `routing`, dataset OSRM precalculado de OpenStreetMap; ADR-0008). Antes se usaba `HaversineDistanceProvider` (Haversine × 1.35), ya retirado, y **OpenRouteService quedó descartado**. El precio y el piso se guardan en la solicitud (`distance_km`, `suggested_price`, `price_floor`), así el cliente nunca los fija.

#### Subasta inversa (AUCTION)

Al publicar se abre una subasta (`logyx.auction.duration=PT20M`, `logyx.auction.max-bids=5`). `PlaceBidUseCase` valida RN02/RN03 con `BidEligibilityPolicy` y cierra por MAX_BIDS; `AuctionScheduler` cierra por TIMEOUT. En dev la duración es de 72 h para no vencer durante las demos.

#### Aislamiento (RLS) y transacciones

`TenantSessionBinder` fija la organización al iniciar cada transacción de usuario, y a partir de allí PostgreSQL aplica las políticas:

```java
em.createNativeQuery("SELECT set_config('app.org_id', ?1, true), set_config('app.org_type', ?2, true)")
        .setParameter(1, org.get().toString()).setParameter(2, ctx.orgType().name()).getSingleResult();
em.createNativeQuery("SET LOCAL ROLE logyx_app").executeUpdate();
```

Lo que corre sin usuario (login, registro, jobs, outbox) entra por `SystemTx`, sobre el datasource privilegiado, con cada uso comentado.

#### Smart Load y cargas de retorno

`SmartLoadPlanner` agrupa solicitudes compatibles (orígenes ≤ 50 km, destinos ≤ 80 km, ±1 día, ocupación ≥ 60 %) y `ReturnLoadPolicy` sugiere cargas con origen a ≤ 50 km del destino del envío (el SRS decía 30 km; el par real más cercano del corredor, Juliaca–Puno, está a 44 km). Un job (`TripScheduler`) genera sugerencias y también pueden pedirse a demanda.

---

## 4. CE0232 — Integración del Sistema

### 4.1 Contrato OpenAPI como fuente de verdad

El backend **genera** `docs/api/openapi.yaml` (y `.json`) en cada build (`./mvnw package`). Web y Android consumen ese contrato:

- **Web:** `npm run gen:api` (`openapi-typescript`) genera `src/lib/api/schema.d.ts`; el cliente tipado `openapi-fetch` valida las llamadas en compilación (`astro check`).
- **Android:** los DTOs `@Serializable` de `core:model` siguen el contrato y `DtoParsingTest`/`Phase*ParsingTest` los validan con JSON de ejemplo.
- **CI:** `backend.yml` falla si el contrato versionado difiere del generado; `contract.yml` falla ante cambios incompatibles (ver [CI/CD](../entregable-4/cicd.md)).

Fragmento real del cliente web (`web/src/lib/api/client.ts`): desenvuelve `{ data, meta }` y normaliza los errores `LOGYX-XXX-NNN` a mensajes en español:

```ts
export async function unwrap<T>(p: Promise<Result<T>>): Promise<T> {
  // ...
  if (res.error !== undefined || !res.response.ok) {
    const e = (res.error ?? {}) as { error?: { code?: string; message?: string; field?: string | null } };
    throw new ApiError(res.response.status, e.error?.code ?? `HTTP-${res.response.status}`, e.error?.message ?? /* ... */, e.error?.field);
  }
  return (res.data as Envelope<T>).data as T;
}
```

### 4.2 Integración Web ↔ Backend

La web es **SSR**: solo el servidor de Astro habla con la API (`API_URL`). El JWT vive en la cookie `logyx_session` (`httpOnly`, `SameSite=Lax`, `Secure` en prod) y nunca llega al JS del navegador. Las mutaciones desde islas React pasan por **Astro Actions** (`features/<f>/actions.ts`), que validan con Zod y llaman a la API con el token de la sesión. `middleware.ts` protege rutas por rol (PYME → `/pyme`, CARRIER → `/transportista`, OPERATOR → `/operador`, DRIVER → `/conductor`), redirige a `/login?expired=1` ante un 401 y agrega CSP y cabeceras de seguridad en producción. Las descargas de documentos pasan por el proxy `/documentos/[id]` y el stream en vivo por `/eventos`.

### 4.3 Integración App Android ↔ Backend

`:core:network` implementa `LogyxApi` con Ktor/OkHttp: `Authorization: Bearer`, desenvuelve `{data, meta}` y mapea errores a `ApiException` con el mensaje en español de la API. La sesión se guarda en DataStore (`:core:data`); un 401 en cualquier llamada cierra sesión. El emulador llama a `http://10.0.2.2:8080` (solo debug permite HTTP en claro; release usa `https://api.logyx.pe`). La evidencia de entrega se comprime a JPEG ≤ 2 MB, se guarda en una cola persistente y se sube con reintento automático.

### 4.4 Integración Backend ↔ Base de Datos

Hibernate ORM Panache con repositorios que implementan los puertos `port/out`; los modelos de dominio son independientes de las entidades JPA (`toDomain()`/`apply()`). Dos datasources (ADR-0006): `app` = `logyx_api` (RLS) para todo y el predeterminado = `logyx_owner` solo para Flyway y `SystemTx`; Hibernate usa la multitenencia `DATABASE` solo como enrutador entre ambos. Flyway migra al arrancar.

### 4.5 Tiempo real (SSE) en lugar de WebSocket + Redis

El diseño inicial usaba WebSocket y Redis Pub/Sub; el sistema real usa **SSE alimentado por el outbox** (ADR-0007):

```
caso de uso --(misma tx)--> outbox_events --despacho--> RealtimeProjector --> realtime_events (1 fila por destinatario)
        trigger pg_notify('logyx_realtime', seq) --> PgRealtimeListener (cada réplica) --> RealtimeHub --> SSE
```

- Endpoint `GET /api/v1/events/stream` (roles PYME/CARRIER/DRIVER/OPERATOR), latido de 20 s, máximo 5 conexiones por usuario (`LOGYX-RTM-001`), reanudación con `Last-Event-ID` bajo RLS, `stream.expired` al vencer el JWT.
- 18 tipos de evento con payload mínimo (ids/estados; nunca montos, nombres ni textos de chat).
- **Web:** `lib/realtime.ts` mantiene una `EventSource` por pestaña contra el proxy `/eventos` y `useLiveRefresh` refresca por REST, con polling lento solo si no está en vivo; el topbar muestra "En vivo".
- **Android:** `RealtimeClient` en `:core:network` (reconexión exponencial + `Last-Event-ID`) y `liveLoop()` por ViewModel, solo con la app en primer plano.

---

## 5. APIs y Servicios

### 5.1 Endpoints Principales

Prefijo `/api/v1` (cuarenta y tantos recursos agrupados; lista completa en `docs/api/openapi.yaml`):

| Grupo | Endpoints representativos |
|---|---|
| Autenticación | `POST /auth/register`, `POST /auth/login`, `GET /auth/me` |
| Catálogo y precios | `GET /catalog/cities`, `GET /catalog/cargo-types`, `POST /pricing/calculate` |
| Flota | `GET/POST /vehicles`, `PATCH /vehicles/{id}/status`, `GET/POST /drivers` |
| Marketplace | `POST /shipment-requests`, `GET /shipment-requests` (marketplace), `GET /shipment-requests/mine`, `GET /shipment-requests/{id}`, `POST /shipment-requests/{id}/bids`, `POST /shipment-requests/{id}/cancel`, `GET /shipment-requests/my-bids`, `POST /bids/{id}/accept` |
| Negociación | `GET/POST /shipment-requests/{id}/threads/{carrierOrgId}/messages`, `POST /bids/{id}/counter-offers`, `POST /counter-offers/{id}/accept|reject` |
| Envíos | `GET /shipments`, `GET /shipments/{id}`, `PUT /shipments/{id}/driver`, `POST /shipments/{id}/stops/{stopId}/arrive|complete`, `GET /driver/shipments/active` |
| Documentos | `POST /shipments/{id}/documents` (multipart), `GET /shipments/{id}/documents`, `GET /documents`, `GET /documents/{id}/file` |
| Reputación | `POST /shipments/{id}/reviews`, `GET /organizations/{id}/reputation` |
| Incidencias | `POST /shipments/{id}/incidents`, `GET /incidents`, `POST /incidents/{id}/comments`, `POST /incidents/{id}/status` |
| Notificaciones | `GET /notifications`, `GET /notifications/unread-count`, `POST /notifications/{id}/read`, `POST /notifications/read-all` |
| Operador | `GET /operator/metrics`, `GET /operator/sla-alerts`, `GET /operator/requests/{id}/candidates`, `POST /operator/requests/{id}/assign` |
| Viajes | `GET/POST /trips`, `GET /trips/mine`, `POST /trips/{id}/bookings`, `POST /trip-bookings/{id}/confirm|reject|cancel`, `GET /return-loads`, `GET /smart-loads`, `POST /smart-loads/generate`, `POST /smart-loads/{id}/accept|reject` |
| Tiempo real | `GET /events/stream` (SSE) |

### 5.2 Contrato de Respuesta Base

Éxito: `{ "data": …, "meta": { … } }`; paginación con `meta.page/size/total` (o `meta.nextCursor` en el chat). Error:

```json
{ "error": { "code": "LOGYX-BID-001", "message": "La oferta no puede ser menor al precio mínimo de S/ 1,350.00 (RN03)", "field": "amount" },
  "meta": { … } }
```

Los montos en mensajes usan el formato `S/ 1,850.00` (`shared/domain/Money`). Códigos por módulo: `LOGYX-NEG-*`, `LOGYX-TRK-*` (p. ej. `-005` incidencia activa, `-006` falta foto), `LOGYX-TRP-*`, `LOGYX-RTM-001`, `LOGYX-AUTH-429`.

### 5.3 Seguridad de la API

| Mecanismo | Implementación |
|---|---|
| Autenticación | JWT RSA (`logyx.jwt.ttl=PT8H`), claims `org_id`, `org_type`, `role`; grupos `PYME`, `CARRIER`, `DRIVER`, `OPERATOR` |
| Autorización | `@RolesAllowed` + organización solo desde el JWT (`TenantContext`) + RLS |
| Rate limiting | Login 50/15 min por IP y bloqueo tras 10 fallos por email; registro 10/15 min (`LOGYX-AUTH-429`, `Retry-After`) |
| Cabeceras | `nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy`, `Cache-Control: no-store` en `/api/*`, HSTS en prod |
| CORS | Desactivado en prod (la web es SSR y Android no usa CORS) |
| Documentación | Swagger UI solo en dev (`/q/swagger-ui`) |

---

## 6. Integración de Servicios Externos

| Servicio | Estado | Detalle |
|---|---|---|
| **MapLibre GL + OpenFreeMap** | **Integrado** | Teselas sin API key (estilos *positron* y *dark*); en web `TrackingMap` y en Android `RouteMap`; el worker de MapLibre se sirve desde `public/maplibre/` y la CSP permite `tiles.openfreemap.org` |
| **Cloudflare R2 / MinIO (API S3)** | **Integrado (adaptador); R2 pendiente de conectar en el VPS** | `S3DocumentStorage` (AWS SDK v2, `path-style` para MinIO, SSE-S3 opcional); `logyx.documents.storage=local|s3`; test con MinIO real (Testcontainers). En producción el endpoint apunta a Cloudflare R2 (`LOGYX_S3_ENDPOINT`); MinIO queda para staging local. Verificar con R2 el estilo de direcciones y que el cifrado en reposo (gestionado por R2) reemplace a `LOGYX_S3_SSE` |
| **Rutas por carretera (ADR-0008)** | **Backend implementado (fases 1 y 2); faltan los mapas web y Android** | Módulo `routing` con matriz y geometrías precalculadas de OpenStreetMap vía OSRM (`scripts/routing/build_routes.py`), sin red en ejecución. `pricing` usa `RoadDistanceProvider` (km por carretera); retornos y Smart Load usan los mismos km; `GET /api/v1/routes` devuelve km, minutos, polyline y atribución OSM. Un tramo sin dato vial cae a línea recta × 1.35 marcado `estimated`. Pendiente: dibujar la ruta en los mapas web y Android. OpenRouteService quedó descartado |
| **SUNAT (verificación de RUC)** | **Pendiente** | Hoy solo Módulo 11 (`ruc_verification = CHECKSUM`) |
| **Email / push** | **Pendiente** | El outbox ya permite agregar un observador de envío |
| **Redis** | **No se usa** | Reemplazado por outbox + `LISTEN/NOTIFY` (ADR-0006/0007); el rate limiting es en memoria por instancia |
| **Google OAuth** | **No se implementó** | Solo email y contraseña |

---

## 7. CE0234 — Despliegue del Sistema

### 7.1 Docker Compose y despliegue en el VPS

**Producción** se despliega en un **VPS Hostinger KVM 2** (2 vCPU, 8 GB RAM, 100 GB NVMe, Brasil) con este mismo Docker Compose, **Caddy** como proxy con HTTPS automático y **Cloudflare** (DNS/CDN/WAF) para `oncargo.tech` (web) y `api.oncargo.tech` (API para Android); los documentos y los respaldos `pg_dump` van a **Cloudflare R2**. El diseño completo (topología, firewall, backups, runbooks) está en el [área de Infraestructura](../../infraestructura/index.md); el aprovisionamiento del VPS y el servicio Caddy están **pendientes de ejecutar**, mientras el compose y las imágenes ya existen y se verificaron localmente.

`infra/docker-compose.yml` (staging local) levanta cuatro servicios; solo web y API se publican en `127.0.0.1`:

| Servicio | Imagen | Notas |
|---|---|---|
| `db` | `postgres:16-alpine` | `init-roles.sh` crea `logyx_owner`, `logyx_app`, `logyx_api` y la BD; volumen `pgdata`; solo red interna |
| `minio` | `chainguard/minio` (fijada por digest) | bucket privado; solo red interna; **solo staging local** (en producción lo reemplaza Cloudflare R2) |
| `backend` | `backend/Dockerfile` | multi-stage Maven → JRE 21 Alpine, usuario 10001, *healthcheck* `/q/health/ready`; Flyway migra al arrancar |
| `web` | `web/Dockerfile` | Astro standalone en `node:22-alpine`, usuario `node`, `API_URL=http://backend:8080` |

### 7.2 Dockerfile del backend

```dockerfile
FROM eclipse-temurin:21-jdk-alpine AS build
# ... ./mvnw -B -q -DskipTests package -Dquarkus.smallrye-openapi.store-schema-directory=target/openapi
FROM eclipse-temurin:21-jre-alpine
RUN addgroup -S -g 10001 logyx && adduser -S -D -H -u 10001 -G logyx logyx
COPY --from=build --chown=10001:10001 /src/target/quarkus-app/ /app/
USER 10001:10001
HEALTHCHECK CMD wget -qO- http://127.0.0.1:8080/q/health/ready >/dev/null || exit 1
ENTRYPOINT ["java", "-jar", "/app/quarkus-run.jar"]
```

### 7.3 Instrucciones de Ejecución

**Desarrollo** (Docker solo para PostgreSQL vía Dev Services):

```bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
cd backend && ./mvnw quarkus:dev            # API :8080, Swagger en /q/swagger-ui, datos demo
cd web && npm install && npm run dev        # Web :4321 (API_URL=http://localhost:8080)
cd android && ./gradlew installDebug        # emulador: API en http://10.0.2.2:8080
```

**Contenedores:**

```bash
cp infra/.env.example infra/.env            # cambiar TODAS las contraseñas
infra/scripts/gen-jwt-keys.sh               # par RSA del JWT en infra/secrets/ (no se versiona)
docker compose -f infra/docker-compose.yml --env-file infra/.env build backend
docker compose -f infra/docker-compose.yml --env-file infra/.env build web
docker compose -f infra/docker-compose.yml --env-file infra/.env up -d
# Web http://localhost:8580 · API http://localhost:8680/q/health/ready
```

Cuentas demo del perfil dev: `pyme@logyx.pe`, `carrier@logyx.pe`, `carrier2@logyx.pe`, `driver@logyx.pe`, `operator@logyx.pe` (contraseña `Logyx2026!`). El compose no trae datos demo: se registra una cuenta desde `/registro`.

### 7.4 Variables de Entorno (backend, prod)

| Variable | Uso |
|---|---|
| `DB_URL` | JDBC de la BD (ambos datasources) |
| `DB_ADMIN_USER` / `DB_ADMIN_PASSWORD` | `logyx_owner`: Flyway y `SystemTx` |
| `DB_APP_USER` / `DB_APP_PASSWORD` | `logyx_api`: Hibernate (todo lo demás) |
| `JWT_PUBLIC_KEY` / `JWT_PRIVATE_KEY` | rutas a los PEM (compose: `/run/secrets/jwt_*`) |
| `LOGYX_DOCUMENTS_STORAGE` | `local` o `s3` (+ `LOGYX_S3_*`; en producción `LOGYX_S3_ENDPOINT` apunta a R2) |
| `CORS_ENABLED` / `CORS_ORIGINS` | CORS desactivado por omisión en prod |
| `TRUSTED_PROXIES` | redes desde las que se acepta `X-Forwarded-For` |
| Web: `API_URL`, `COOKIE_SECURE`, `HSTS` | URL de la API y comportamiento de la cookie/HSTS |

### 7.5 CI

Cinco workflows de GitHub Actions (`backend`, `web`, `android`, `contract`, `e2e`) más Dependabot: ver [CI/CD](../entregable-4/cicd.md).

---

## 8. Evidencia Técnica

| Item | Estado | Referencia |
|------|--------|------------|
| Código fuente (monorepo `logyx`) | Disponible | `backend/`, `web/`, `android/`, `infra/` |
| Capturas del sistema en ejecución | **Incluidas** | [Arquitectura Frontend §6](arquitectura-frontend.md#6-capturas-de-pantalla-del-sistema-real) |
| Contrato OpenAPI | Versionado | `docs/api/openapi.yaml`, historial en `docs/api/CHANGELOG.md` |
| Swagger UI | Solo en dev | `/q/swagger-ui` |
| Docker Compose | Verificado localmente con login web real | `infra/README.md` |
| Estado por módulo | Mantenido | `docs/STATUS.md` |

---

## 9. Coherencia del Sistema

| Fuente | Relación con E3 |
|--------|----------------|
| **E1 SRS** (RF01–RF67) | Cada módulo implementa un rango de RF; el SRS v1.1 indica el estado y el código de cada RF/RN. Ver §3.1 |
| **E1 Arquitectura** (ADR 0001–0008) | La arquitectura implementada es la documentada en la v2.0: hexagonal modular, Astro, Kotlin, RLS, outbox, SSE |
| **E1 UML** | Las clases del diagrama de dominio corresponden a los modelos de `*/domain/model` |
| **E2 Modelo de datos** (57 tablas) | Los repositorios Panache consultan las tablas creadas por V1–V24 |
| **E2 Scripts** | Las migraciones Flyway mostradas en E2 son las que ejecuta el sistema; la lógica de negocio vive en el dominio, no en triggers |
| **E4** | Pruebas, CI/CD y auditoría documentan la verificación de este sistema |

---

*OnCargo · E3 Sistema Desarrollado · Competencias CE0231–CE0234 · Versión 2.0 · Noviembre 2026*
