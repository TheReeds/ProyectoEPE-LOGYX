# Arquitectura Frontend — OnCargo (Web Astro y Android Compose)
> Astro 7 (SSR) · React 19 islands · Tailwind 4 · shadcn/ui · Kotlin · Jetpack Compose  
> Versión: 2.0 (reescrita sobre el sistema real) · Noviembre 2026 · Reemplaza la guía de Angular 22 + PrimeNG de la v1.0

!!! info "Cambio de pila"
    La v1.0 documentaba una SPA Angular 22 con PrimeNG y signal forms. El frontend real se construyó con **Astro SSR + islas React** (web) y **una app Android nativa en Compose** (ADR-0003); la justificación está en [Cambios respecto al diseño inicial](../cambios-diseno-inicial.md). Esta guía describe lo implementado; la guía operativa viva para el equipo está en `web/AGENTS.md`, `android/AGENTS.md` y `docs/design/DESIGN.md` del repositorio del sistema.

---

## 1. Stack y versiones

### Web (`web/`)

| Paquete | Versión | Uso |
|---------|---------|-----|
| `astro` + `@astrojs/node` | 7.4 / 11.1 | SSR (modo standalone) |
| `@astrojs/react`, `react`, `react-dom` | 7.1 / 19.3 | islas interactivas |
| `tailwindcss` + `@tailwindcss/vite` | 4.3 | estilos con tokens en `@theme` |
| Radix UI (`dialog`, `select`, `popover`, `tabs`, `tooltip`, …) | 1.x–2.x | primitivas accesibles de shadcn/ui |
| `cmdk`, `react-day-picker` 10 + `date-fns`, `sonner` | — | Combobox, DatePicker, toasts |
| `maplibre-gl` | 6.17 | mapas (teselas OpenFreeMap) |
| `openapi-fetch` + `openapi-typescript` | 0.17 / 7.13 | cliente tipado desde el contrato |
| `lucide-react` / `@lucide/astro`, Geist (fontsource) | — | iconos y tipografía |
| `@playwright/test`, `@axe-core/playwright` | 1.65 / 4.14 | e2e y accesibilidad |

### Android (`android/`)

| Componente | Versión |
|---|---|
| Kotlin / AGP / Gradle | 2.4.21 / 9.5.1 / 9.8.2 |
| Compose BOM / Material 3 | 2026.09.00 |
| Ktor (OkHttp) / kotlinx.serialization | 3.6.1 |
| Koin | 4.2.2 |
| MapLibre Android | 13.7.1 |
| `compileSdk` / `targetSdk` / `minSdk` | 37 / 36 / 29 |

**Comandos:**

```bash
# Web
cd web && npm install
npm run dev                  # http://localhost:4321 (API_URL=http://localhost:8080)
npm run check && npm run build
npm run gen:api              # regenera src/lib/api/schema.d.ts desde docs/api/openapi.yaml
npm run test:e2e             # Playwright + axe

# Android
cd android && ./gradlew assembleDebug testDebugUnitTest :core:network:test
./gradlew installDebug       # emulador -> API en http://10.0.2.2:8080
```

---

## 2. Web: Astro SSR + islas React

### 2.1 Principios

1. **Renderizado en servidor.** Las páginas `.astro` leen la sesión, cargan datos en el frontmatter con funciones de `features/*/server.ts` y entregan HTML; solo las partes interactivas se hidratan (islas con `client:load` o `client:only="react"` para mapas).
2. **Solo el servidor habla con la API.** El JWT vive en la cookie `logyx_session` (`httpOnly`, `SameSite=Lax`, `Secure` en prod); nunca llega al JavaScript del navegador. El navegador no llama a la API (por eso CORS está desactivado en producción).
3. **Mutaciones por Astro Actions.** Las islas llaman `actions.<feature>.<accion>(input)`; la acción valida con Zod, toma el token de la sesión y llama a la API; el error llega ya en español.
4. **El contrato manda.** Los tipos se generan del OpenAPI; si el backend cambia, `npm run check` rompe en compilación.
5. **Una carpeta por feature**, con la misma forma en todas.

### 2.2 Estructura

```
web/src/
├── pages/                 # rutas finas por rol
│   ├── index, login, registro, privacidad, conductor, logout, eventos (proxy SSE)
│   ├── pyme/              # panel, solicitudes/{index,nueva,[id]}, envíos, viajes, reservas
│   ├── transportista/     # marketplace, ofertas, flota, envíos, viajes, retornos, smart-load
│   ├── operador/          # panel, incidencias, solicitudes, envíos (solo OPERATOR)
│   └── notificaciones, incidencias, organizaciones/[id], documentos/[id] (proxy de archivos), dev/ui (solo dev)
├── features/<feature>/    # auth, catalog, requests, shipments, marketplace, fleet, dashboard,
│   ├── server.ts          #   negotiation, reputation, documents, incidents, notifications, operator, trips…
│   ├── actions.ts         #   Astro Actions (mutaciones)
│   └── components/        #   islas React de la feature
├── components/
│   ├── ui/                # biblioteca compartida (shadcn/ui + Radix): button, field, select, combobox,
│   │                      #   date-picker, confirm-dialog, toaster, dialog, sheet, tabs, table, pagination…
│   ├── domain/            # StatusPill, RouteLine, KpiTile, EmptyState, Countdown, VerifiedBadge, TrustScore
│   └── layout/            # AppShell (sidebar + topbar por rol), PageHeader, LiveIndicator
├── layouts/               # Base.astro (Toaster + ConfirmHost), Public.astro
├── lib/
│   ├── api/               # schema.d.ts (GENERADO), client.ts (openapi-fetch + unwrap + ApiError)
│   ├── session.ts         # cookie httpOnly, claims del JWT, homeFor(rol)
│   ├── realtime.ts        # EventSource único por pestaña, useLiveRefresh
│   └── format.ts          # S/ 1,850.00 · 28 nov · 08:00 · etiquetas de enums
├── middleware.ts          # protección por rol, 401 a /login, CSP y cabeceras en prod
└── styles/global.css      # tokens de DESIGN.md en @theme de Tailwind
```

### 2.3 Patrón de una pantalla (extracto real)

Cliente de API tipado (`lib/api/client.ts`): una función `unwrap` desenvuelve `{ data }` o lanza `ApiError(status, code, message, field)`:

```ts
const data = await unwrap(apiFor(token).GET('/api/v1/vehicles'));
```

Pasos para agregar una pantalla: (1) `features/<f>/server.ts` con las llamadas; (2) `actions.ts` con `defineAction({ accept: 'json', input: z.object(...), handler })` registrado en `src/actions/index.ts`; (3) islas en `features/<f>/components/*.tsx`; (4) página `.astro` con `<AppShell>` + `<PageHeader>`; (5) enlace en `NAV` de `AppShell` y revisión del `middleware`; (6) estados vacío/carga/error en español y `npm run check && npm run build`.

### 2.4 Estado, formularios y errores

No hay un store global: el estado de servidor se vuelve a pedir (SSR o Astro Actions) y el estado de UI es local a cada isla. Los errores de negocio traen `field` y se muestran **bajo el campo** (`Field` con `role="alert"`); el resto, como toast (`sonner`). Los formularios llevan `method="post"` para que, si se envían antes de hidratar, las credenciales no acaben en la URL.

### 2.5 Tiempo real en la web

`lib/realtime.ts` abre **una sola `EventSource` por pestaña** contra `/eventos`, el proxy autenticado de Astro hacia `GET /api/v1/events/stream` (cookie → Bearer; el JWT no sale del servidor). Los eventos son avisos con payload mínimo; el hook `useLiveRefresh({ types, match, refresh, fallbackMs })` vuelve a pedir los datos por Astro Action al llegar el evento, al reconectar, y con un polling de respaldo lento solo si no hay conexión. El topbar muestra "En vivo / Reconectando…". Cubre campana de notificaciones, chat y contraofertas, detalle de solicitud (ofertas y subasta sin recargar), marketplace, mis ofertas, envíos y tracking, conductor, incidencias, operador, reservas y Smart Load.

### 2.6 Seguridad del frontend

Cabeceras y CSP (`default-src 'self'`, `frame-ancestors 'none'`, `connect-src 'self'` + OpenFreeMap) en `middleware.ts` en producción; `security.checkOrigin` de Astro contra CSRF; React escapa por defecto. Residual: `script-src 'unsafe-inline'` por los scripts de hidratación de Astro (a futuro, nonces).

---

## 3. Sistema de diseño

Documentado en `docs/design/DESIGN.md` y `docs/design/CONTENT.md`; dirección: *70 % Modern Industrial Tech + 30 % Friendly Mobility*. **Web = negocio** (tablas, filtros, comparación, tracking con mapa); **móvil = transportista y conductor** (tarjetas ricas, precio destacado, acciones grandes).

### 3.1 Tokens

| Token | Hex (claro) | Uso |
|---|---|---|
| `ink-900` | `#0E1726` | Texto principal |
| `ink-700` / `ink-500` | `#334155` / `#5B6B7F` | Texto secundario / terciario (AA) |
| `steel-100` / `steel-200` | `#EEF2F6` / `#E2E8F0` | Fondo de app / bordes |
| `petrol-700` | `#0B4F6C` | Primario, links, ruta en mapa |
| `emerald-500` / `emerald-700` | `#10B981` / variante AA | **Dinero y oportunidad**: precios, "Ofertar", éxito |
| `amber-500` / `red-600` | `#F59E0B` / `#DC2626` | Por cerrar, pendiente / incidencia, error |

**Modo oscuro** (implementado, WCAG AA con tabla de contrastes en DESIGN.md): `html[data-theme=dark]` redefine los mismos tokens; selector Claro/Oscuro/Sistema persistente y script anti-parpadeo compatible con la CSP. **Tipografía:** Geist Sans (UI) y Geist Mono (placas, km, toneladas, montos en tabla), números tabulares. Formatos: `S/ 1,850.00`, `28 nov · 08:00` (zona America/Lima).

### 3.2 Componentes

- **Primitivas** (`components/ui`, estilo shadcn/ui sobre Radix MIT): `Select`/`Combobox`/`MultiSelect`, `DatePicker`/`DateRangePicker`, `MoneyInput`/`NumberInput`, `ConfirmDialog` (`confirm()` devuelve `Promise<boolean>`), toasts, `Dialog`, `Sheet`, `Tabs`, `Tooltip`, `Table` + `Pagination`, `Skeleton`, `FileDropzone`, `StarRating`… Regla: nada de `<select>` nativo, `<input type=date>` ni `window.confirm/alert`.
- **Dominio** (`components/domain`): `StatusPill` (un color y etiqueta por estado), `RouteLine` (`Lima ──── 1,010 km ────▶ Juliaca`), `KpiTile` (máx. 4 por fila), `EmptyState` con camión, `Countdown`, `VerifiedBadge`, `TrustScore`.
- **Layout:** `AppShell` con sidebar por rol, `PageHeader`, enlace "Saltar al contenido", navegación colapsable en tablet/móvil.
- **Catálogo vivo** en `/dev/ui` (solo dev), con capturas más abajo.

### 3.3 Accesibilidad

Todo input con `Label`/`Field`, errores con `role="alert"`, foco visible, contraste AA en ambos temas, roles ARIA en tabs/mapa/listas. **Verificación automatizada con axe-core** (WCAG 2.1 A/AA) en e2e: falla ante violaciones `serious`/`critical` (specs `a11y*`, incluida la variante oscura).

---

## 4. Rutas y navegación por rol

| Rol | Aterriza en | Secciones |
|---|---|---|
| PYME | `/pyme` | Panel · Solicitudes (nueva, detalle con comparación de ofertas) · Envíos y tracking · Viajes · Reservas |
| Transportista | `/transportista/marketplace` | Marketplace · Mis ofertas · Flota · Envíos · Tu actividad · Viajes · Retornos · Smart Load |
| Conductor | `/conductor` | Viaje activo: siguiente parada, botón único, evidencia |
| Operador | `/operador` | Métricas · Alertas SLA · Asignación manual · Incidencias · Solicitudes y envíos (solo lectura) |

`middleware.ts` redirige por rol (el conductor solo ve `/conductor`), envía a `/login?expired=1` ante un 401 y deja públicas `/`, `/login`, `/registro` y `/privacidad` (Ley N° 29733).

---

## 5. Android (Kotlin, Jetpack Compose, multi-módulo)

### 5.1 Módulos y dependencias

```
:app                  Activity, Application (Koin), navegación raíz por rol, BuildConfig → AppConfig
:core:model           Kotlin/JVM PURO. DTOs @Serializable del contrato y reglas de cliente
:core:network         Kotlin/JVM PURO. Ktor (OkHttp) + LogyxApi tipado, {data,meta}, SSE, ApiException
:core:data            Repositorios (interfaz + Default*), sesión (DataStore), cola de evidencia
:core:designsystem    Tema OnCargo, Geist, componentes Compose, mapa MapLibre
:feature:auth · loads · requests · shipments · driver · negotiation · reputation · documents · incidents · trips · notifications
```

Reglas de dependencia: `core:model` y `core:network` **no dependen de Android ni de Compose** (se convertirán a Kotlin Multiplatform para la app SwiftUI); `core:data → core:network → core:model`; `feature:* → core:designsystem + core:data`; **un feature nunca depende de otro**: la navegación entre features la cablea `:app` mediante callbacks.

### 5.2 Patrón de una feature (UDF)

`XxxViewModel` expone `StateFlow<XxxUiState>` (data class inmutable con `loading`, `error`, datos y `message: UiMessage?`) y métodos de intención. `XxxRoute` (`koinViewModel()` + `collectAsStateWithLifecycle`) llama a `XxxScreen(state, callbacks)`, **sin estado y sin ViewModel** (previsualizable y testeable). Siempre se cubren los estados de carga, vacío (`EmptyState`) y error (`ErrorState` con "Reintentar"), con pull-to-refresh. Los mensajes de la API se muestran tal cual (`Throwable.userMessage()`).

### 5.3 Navegación por rol y sesión

`AuthRepository.state` (`Loading | LoggedOut | LoggedIn(user)`) decide la pantalla: `role == DRIVER` → modo conductor; `CARRIER` → transportista (Home "Tu actividad", feed de cargas, ofertas, envíos, viajes); `PYME` → solicitudes, viajes y reservas; el operador ve un aviso "usa la web". Un 401 en cualquier llamada cierra sesión.

### 5.4 Sistema de diseño Compose

`LogyxTheme` mapea los tokens de DESIGN.md a Material 3 (claro y oscuro) con extras (`money`, `moneyStrong`, `moneyText`, `warning*`, `route`). Componentes `Logyx*`: botones, `LogyxTextField`, `MoneyField`, `LogyxDropdown`, `LogyxCombobox`, selectores de fecha y hora es-PE, `LogyxConfirmDialog`, `LogyxBottomSheet`, `AlertBanner`, `SegmentedControl`, y los de dominio `LoadCard`, `RouteLine`, `StatusPill`, `StopTimeline`, `KpiTile`, `PriceTag`, `AuctionCountdown`, `RouteMap`, `LiveIndicator`. Regla: los features **no usan controles Material crudos**; si falta un componente se crea en `:core:designsystem` con `@Preview` y entrada en el catálogo (debug). Textos en `strings.xml` por módulo.

### 5.5 Particularidades

- **Evidencia de entrega:** `EvidenceRepository` comprime a JPEG ≤ 2 MB, guarda en una cola persistente (`filesDir/evidence`) y sube con reintento automático cada 20 s; "Entregado" solo se habilita con ≥ 1 foto subida (RN06). La captura usa `TakePicture` (sin permiso `CAMERA`) y la firma es opcional.
- **Tiempo real:** `RealtimeClient` (reconexión exponencial + `Last-Event-ID`) y `liveLoop()` por ViewModel, solo en primer plano; sin push con la app cerrada.
- **Seguridad:** HTTP en claro permitido solo en debug (`network_security_config` de debug); release exige HTTPS.

---

## 6. Capturas de pantalla del sistema real

Capturas tomadas del sistema en ejecución (`web/docs/screenshots/` y `android/docs/screenshots/` del repositorio, copiadas a este sitio).

### 6.1 Web

| | |
|---|---|
| ![Página de inicio](img/web/landing.png) | ![Inicio de sesión](img/web/login.png) |
| *Landing pública* | *Inicio de sesión* |
| ![Panel de la PYME](img/web/pyme-panel.png) | ![Panel de la PYME en modo oscuro](img/web/pyme-panel-dark.png) |
| *Panel PYME (claro)* | *Panel PYME (modo oscuro AA)* |
| ![Nueva solicitud con cotización en vivo](img/web/pyme-nueva-solicitud.png) | ![Detalle de solicitud con ofertas](img/web/pyme-detalle-solicitud.png) |
| *Nueva solicitud con cotización en vivo (RN03)* | *Detalle: subasta y comparación de ofertas* |
| ![Marketplace del transportista](img/web/transportista-marketplace.png) | ![Error de oferta bajo el piso](img/web/transportista-ofertar-error.png) |
| *Marketplace del transportista (filtros, tabla de cargas)* | *Oferta bajo el piso: error inline (RN03)* |
| ![Negociación: panel de hilos y contraoferta](img/web/negociacion-panel-pyme.png) | ![Seguimiento del envío en mapa](img/web/pyme-tracking.png) |
| *Negociación: chat y contraofertas (RN07)* | *Tracking: lista, mapa y timeline* |
| ![Vista del conductor en web](img/web/conductor.png) | ![Evidencia de entrega y documentos](img/web/documentos-evidencia.png) |
| *Página web del conductor (resumen; el trabajo se hace en la app Android)* | *Documentos y evidencia del envío* |
| ![Detalle de incidencia](img/web/incidencias-detalle.png) | ![Panel del operador](img/web/operador-panel.png) |
| *Incidencia con comentarios (RN11)* | *Panel del operador: métricas y alertas SLA* |
| ![Perfil público con Trust Score](img/web/reputacion-perfil-transportista.png) | ![Publicar viaje](img/web/viajes-publicar.png) |
| *Perfil público con Trust Score (RN09)* | *Publicar viaje (RN12)* |
| ![Popover de notificaciones](img/web/notificaciones-popover.png) | ![Catálogo de componentes](img/web/dev-ui-catalogo.png) |
| *Campana de notificaciones en vivo* | *Catálogo vivo del sistema de diseño (`/dev/ui`)* |

### 6.2 Android

| | | |
|---|---|---|
| ![Login Android](img/android/light-login.png) | ![Home del transportista](img/android/light-carrier-home.png) | ![Feed de cargas](img/android/light-carrier-feed.png) |
| *Login* | *Home "Tu actividad"* | *Feed de cargas (LoadCard)* |
| ![Detalle de carga con mapa](img/android/light-load-detail.png) | ![Modo conductor](img/android/light-driver-trip.png) | ![Evidencia de entrega](img/android/light-driver-evidence.png) |
| *Detalle con mapa y oferta* | *Modo conductor (botón único)* | *Evidencia: foto obligatoria* |
| ![Solicitudes de la PYME](img/android/light-pyme-requests.png) | ![Chat con teléfono bloqueado](img/android/light-chat-blocked.png) | ![Feed en modo oscuro](img/android/dark-carrier-feed.png) |
| *Solicitudes de la PYME* | *Chat: contacto bloqueado (RN07)* | *Feed en modo oscuro* |
| ![Publicar viaje](img/android/trips-publish-form.png) | | |
| *Publicar viaje (RN12)* | | |

---

## 7. Pruebas del frontend

Web: Playwright (18 specs, 85 tests) con axe en pantallas clave; Android: 165 pruebas unitarias de ViewModels y parsing, más 8 instrumentadas con Compose UI Test. Detalle en [Plan de Pruebas](../entregable-4/plan-pruebas.md).

---

*OnCargo · E3 Arquitectura Frontend · Versión 2.0 · Noviembre 2026*
