# E5 — Sustentación del Sistema
> Competencia CE0217 · Video Pitch + Defensa Técnica ante Jurado  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Versión: 2.0 (alineada con el sistema construido) · Noviembre 2026 · Versión original 1.0, junio 2026

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Duración del video pitch** | 3–5 minutos |
| **Duración de la sustentación** | 20–30 minutos (demo + preguntas) |
| **Formato de demo** | Sistema en ejecución en vivo: web Astro + app Android (emulador o dispositivo) contra el backend con datos demo |
| **Link al video pitch** | *(agregar URL de YouTube / Drive aquí)* |
| **Fecha de sustentación** | *(agregar fecha)* |

---

## 2. Video Pitch

### 2.1 Estructura del Video (3–5 minutos)

| Segmento | Duración | Contenido |
|----------|---------|-----------|
| **Gancho** | 20 seg | Dato impactante: "El 65% de las PYMEs en el corredor Lima-Arequipa pierde al menos un envío al mes por coordinación deficiente." |
| **El problema** | 45 seg | Mostrar la realidad actual: PYMEs coordinan por WhatsApp, no saben el precio justo, no tienen trazabilidad. Los transportistas regresan vacíos. |
| **La solución** | 60 seg | OnCargo: plataforma que conecta PYMEs y transportistas con subasta inversa, negociación, Smart Load y tracking en tiempo real. |
| **Demo rápida** | 90 seg | Captura de pantalla del flujo: PYME publica → Carrier oferta → PYME acepta → Driver entrega → calificación. |
| **El valor** | 30 seg | Para la PYME: ahorro del 15-25% en costos. Para el carrier: más viajes llenos, menos retornos vacíos. Para el ecosistema: formalización del sector. |
| **El equipo** | 20 seg | Presentar brevemente a los 3 integrantes y sus roles. |
| **Cierre** | 15 seg | "OnCargo: La logística colaborativa para el Perú que crece." |

### 2.2 Guión del Pitch

**[GANCHO]**
> "¿Sabías que en el corredor Lima-Arequipa-Juliaca existen más de 8,000 PYMEs que mueven mercancía cada semana? Y la mayoría lo hace coordinando por WhatsApp, a precio de remate, sin saber si su carga llegó. Nosotros decidimos cambiar eso."

**[EL PROBLEMA]**
> "Hoy, una PYME que necesita transportar mercancía tiene que llamar a diez transportistas diferentes, negociar por teléfono sin saber si el precio es justo, y rezar para que la carga llegue. Del otro lado, el transportista sale a Lima y vuelve con el camión vacío porque no tiene forma de conseguir carga de retorno. El resultado: dinero que se pierde en ambos lados."

**[LA SOLUCIÓN]**
> "OnCargo es el sistema operativo logístico para PYMEs. Funciona como una plataforma bidireccional: las PYMEs publican sus cargas y reciben ofertas competitivas en minutos, los transportistas ven cargas disponibles en su ruta y ofertan el precio justo. Tenemos subasta inversa como InDrive, negociación bidireccional, motor de costos basado en rutas reales, y seguimiento en vivo con confirmación de entrega por foto. Además, nuestro Smart Load Planner detecta automáticamente cargas compatibles y sugiere al transportista cómo llenar su camión al máximo."

**[DEMO]**
> *(Mostrar capturas o demo en vivo del flujo completo: PYME publica → cotización → subasta → carrier oferta → acepta → tracking → entrega confirmada)*

**[EL VALOR]**
> "Para la PYME: reducción de hasta 25% en costos de flete por la presión competitiva de la subasta. Para el transportista: 30% más de viajes productivos gracias a las cargas de retorno y el Smart Load. Para el corredor: formalización del sector con reputación verificable, documentación digital y trazabilidad completa."

**[EL EQUIPO]**
> "Somos Jorge, Fabrizio y Alex. Ingeniería de Sistemas, Universidad Peruana Unión. Construimos OnCargo con un backend Quarkus en arquitectura hexagonal, una web en Astro, una app Android nativa en Kotlin y PostgreSQL con seguridad a nivel de fila: cada empresa solo ve sus propios datos, y eso lo garantiza la base de datos, no solo el código."

**[CIERRE]**
> "OnCargo: La logística colaborativa que el Perú necesita."

---

## 3. Demostración del Sistema

### 3.1 Casos de Uso a Demostrar

| ID | Caso | Actor | Duración estimada |
|----|------|-------|------------------|
| CU-DEMO-01 | PYME publica solicitud de carga y ve cotización | PYME | 3 min |
| CU-DEMO-02 | Carrier ve marketplace y envía oferta | Carrier | 2 min |
| CU-DEMO-03 | PYME acepta oferta y se crea el envío | PYME | 2 min |
| CU-DEMO-04 | Conductor confirma entrega con foto (firma opcional) | Conductor (app Android) | 3 min |
| CU-DEMO-05 | PYME sigue el estado del envío en tiempo real | PYME | 2 min |
| CU-DEMO-06 | Sistema de reputación post-entrega | PYME + Carrier | 2 min |
| CU-DEMO-07 | Operador resuelve incidencia | Operador (web) | 2 min |
| CU-DEMO-08 | Smart Load Planner sugiere combinación | Carrier | 2 min |
| CU-DEMO-09 | Aislamiento: otra organización no ve las ofertas ni los envíos (RLS) | Carrier 2 | 2 min |

### 3.2 Flujo de Demostración

Cuentas demo del perfil `dev` (contraseña común `Logyx2026!`): `pyme@logyx.pe`, `carrier@logyx.pe`, `carrier2@logyx.pe`, `driver@logyx.pe`, `operator@logyx.pe`.

```
Paso 1: Login como PYME (pyme@logyx.pe) en la web (:4321)
   → Panel con KPIs y reservas activas

Paso 2: Nueva solicitud de carga
   → Origen Lima / Destino Arequipa, 3,500 kg, tipo general
   → Cotización en vivo (precio sugerido y piso del 75 %)
   → Publicar: se abre la subasta (20 min / 5 ofertas)

Paso 3: Cambiar a Carrier (carrier@logyx.pe) — web o app Android
   → Marketplace con filtros; la solicitud aparece en vivo (SSE)
   → Ofertar un monto: bajo el piso muestra el error inline (RN03); sobre el piso se acepta

Paso 4: Volver a PYME
   → El panel de ofertas se actualiza sin recargar; Trust Score del transportista
   → Probar el chat: un teléfono en el mensaje se bloquea (RN07)
   → Aceptar la oferta (RN05: las demás se rechazan)

Paso 5: Carrier asigna conductor; app Android como conductor (driver@logyx.pe)
   → "Mi viaje": parada de recojo → llegada → entrega
   → Completar la entrega exige foto (LOGYX-TRK-006)

Paso 6: PYME web → seguimiento en el mapa; estado "Entregado"; calificar (RN06)

Paso 7: Operador (operator@logyx.pe) → métricas, alertas SLA, incidencias

Paso 8: Aislamiento (RLS): con carrier2@logyx.pe no aparecen las ofertas ni los envíos de carrier@
```

### 3.3 Preparación del entorno para la demo

Entorno local, sin dependencias externas (Docker solo para PostgreSQL vía Dev Services):

```bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
# 1. Backend con datos demo (API :8080; subastas de 72 h en dev para no vencer durante la demo)
cd backend && ./mvnw quarkus:dev -Dquarkus.http.host-validation.require-localhost=false
# 2. Web (:4321)
cd web && npm install && npm run dev
# 3. App Android (emulador -> API en 10.0.2.2:8080)
cd android && ./gradlew installDebug
# 4. Abrir en paralelo: pestaña PYME, pestaña Carrier, pestaña Operador y el emulador con el Driver
```

Para mostrar el despliegue por contenedores (sin datos demo): `docker compose -f infra/docker-compose.yml --env-file infra/.env up -d` (web :8580, API :8680; ver `infra/README.md`). El e2e de asignación manual del operador necesita `-Dlogyx.operator.sla=PT0S`.

---

## 4. Explicación Técnica

### 4.1 Arquitectura

**Tipo:** Monolito modular con arquitectura hexagonal por módulo (estilo bloqueante). **Justificación:** adecuado para un MVP con equipo de 3 personas; los 16 módulos están desacoplados (el dominio no importa Quarkus/JPA y nadie importa la infraestructura de otro módulo; lo verifica `ModuleBoundariesTest`) y los de mayor carga pueden extraerse a servicios. Ver [Arquitectura](../entregable-1/arquitectura.md) y los ADR 0001–0007.

**Componentes principales:**

| Componente | Tecnología | Rol |
|-----------|-----------|-----|
| Backend API | Quarkus 3.40 + Java 21 | Reglas de negocio, REST `/api/v1`, SSE, OpenAPI |
| Web | Astro 7 SSR + islas React + Tailwind 4 | Interfaces PYME, transportista y operador; sesión en cookie httpOnly |
| App móvil | Android nativo (Kotlin + Compose) | Transportista, PYME y conductor, una app con navegación por rol |
| Base de datos | PostgreSQL 16 con RLS | Persistencia y aislamiento por organización |
| Almacenamiento | Cloudflare R2 (API S3; MinIO en staging local) | Fotos y documentos de entrega (descarga solo vía API) |
| Mapas | MapLibre GL + OpenFreeMap | Teselas sin API key |
| Distancias | Km por carretera precalculados con OSRM sobre OpenStreetMap (ADR-0008); `GET /api/v1/routes` | Precio sugerido y piso, retornos y Smart Load |

### 4.2 Decisiones Técnicas Clave (ver también [Cambios respecto al diseño inicial](../cambios-diseno-inicial.md))

| Decisión | Elegido | Por qué / Alternativa descartada |
|---------|---------|------------------------------------|
| Aislamiento de datos | **Una BD + organización por fila + RLS** (ADR-0001) | OnCargo es un marketplace: el flujo cruza organizaciones. BD/esquema por tenant o `@TenantId` romperían la visibilidad controlada. Doble barrera: JWT + PostgreSQL RLS |
| Mínimo privilegio | `logyx_api` sin dueño, `SystemTx` explícito (ADR-0006) | La conexión como dueño permitiría `RESET ROLE` ante una inyección SQL; ahora falla con 42501 |
| Estilo del backend | **Bloqueante + hexagonal** (ADR-0002) | Más simple de probar y razonar que Mutiny/reactivo; suficiente para la carga del MVP; hilos de petición con transacciones claras para RLS |
| Web | **Astro SSR + islas React** (ADR-0003) | Menos JS al navegador, el token nunca llega al JS, componentes de shadcn/ui conocidos. Angular descartado |
| Móvil | **Una app Android nativa Kotlin/Compose** (ADR-0003) | Una sola app con flujos por rol; `core:model`/`core:network` en Kotlin puro listos para KMP/iOS. Flutter y tres apps descartadas |
| Eventos y avisos | **Outbox transaccional** (ADR-0004/0006) | No se pierden avisos entre commit y entrega; reemplaza Redis Pub/Sub |
| Tiempo real | **SSE alimentado por el outbox** (ADR-0007) | Unidireccional, atraviesa proxies, reanuda con `Last-Event-ID`; reemplaza WebSocket + Redis |
| Documentos | **Puerto `DocumentStorage`** (ADR-0005) | Local en dev, S3-compatible en prod (Cloudflare R2), sin cambiar el contrato |
| Contrato | **OpenAPI generado por el backend** | Web y Android lo consumen; la CI bloquea cambios incompatibles |

### 4.3 Integración del Sistema

```
[Navegador] --HTTPS--> [Astro SSR (Node)] --REST + Bearer JWT--> [API Quarkus]
[App Android] ---------------REST + SSE + Bearer JWT-----------> [API Quarkus]
[API Quarkus] --logyx_api (RLS)--> [PostgreSQL 16]   --logyx_owner--> (Flyway, SystemTx)
[API Quarkus] --AWS SDK v2--> [Cloudflare R2 (API S3)]
[PostgreSQL] --LISTEN/NOTIFY--> [PgRealtimeListener] --> [RealtimeHub] --SSE--> clientes
[Schedulers] AuctionScheduler (cierre de subastas), TripScheduler (Smart Load, reservas), Outbox (cada 5 s)
```

### 4.4 Calidad del Sistema

| Área | Control implementado |
|------|---------------------|
| **Pruebas** | 182 casos backend (JUnit 5 + PostgreSQL real), 85 e2e Playwright con axe, 165 unitarias + 8 instrumentadas Android. Ver [Plan de Pruebas](../entregable-4/plan-pruebas.md) |
| **CI/CD** | GitHub Actions: `backend`, `web`, `android`, `contract` y `e2e` nocturno. Ver [CI/CD](../entregable-4/cicd.md) |
| **Seguridad** | JWT RSA, bcrypt, RLS + mínimo privilegio, rate limiting, CSP/HSTS, `docs/security.md` |
| **Auditoría** | `audit_log` inmutable desde la aplicación + outbox. Ver [Auditoría](../entregable-4/auditoria.md) |
| **Estándar** | ISO/IEC 25010 |

---

## 5. Banco de Preguntas y Respuestas para el Jurado

### Sobre el cambio de diseño

**¿Por qué el software real no usa Angular, Flutter ni tres apps como dice el diseño del EPE?**
> Porque el diseño inicial se revisó al construir y cada cambio quedó registrado en un ADR. Astro entrega menos JavaScript, mantiene el token en el servidor y se integra con islas React; Kotlin/Compose nativo dio mejor acceso a cámara, SSE y mapas en una sola app con flujos por rol, y deja `core:model`/`core:network` listos para compartir con iOS. Está explicado en [Cambios respecto al diseño inicial](../cambios-diseno-inicial.md).

**¿Por qué no es multitenant?**
> Evaluamos BD por tenant, esquema por tenant y `@TenantId` de Hibernate (ADR-0001). Todos asumen que los datos de un tenant nunca se cruzan con los de otro, y un marketplace funciona precisamente al revés: una PYME publica, varios transportistas ven y ofertan, uno ejecuta. Elegimos una sola base con organización en cada fila privada, doble barrera (filtro por el JWT + Row-Level Security) y datos públicos por política explícita. Si OnCargo se vendiera como marca blanca a cooperativas, se reevaluaría un esquema por cooperativa.

**¿Cómo demuestran que el aislamiento funciona?**
> Con `RowLevelSecurityTest` (una consulta sin `WHERE` solo devuelve filas de la propia organización), `DatabasePrivilegesTest` (con la conexión de la app, `RESET ROLE`, `ALTER` o `DROP POLICY` fallan con 42501) y `RealtimeStreamFlowTest` (otra PYME, otro transportista y otro conductor no reciben eventos). En la demo: Carrier 2 no ve las ofertas de Carrier 1.

### Sobre Requerimientos

**¿Por qué elegir subasta inversa en lugar de precio fijo?**
> El modelo de precio fijo no refleja la realidad del mercado logístico peruano, donde los precios varían según disponibilidad, distancia y tipo de carga. La subasta inversa crea competencia real entre transportistas, beneficiando a la PYME. El piso del 75 % (RN03) protege al transportista de una carrera al fondo.

**¿Cómo garantizan que el precio sea justo para el transportista?**
> (1) Piso automático del 75 % del precio sugerido por el motor de costos (con distancia por carretera precalculada, ADR-0008), validado en el dominio y en la contraoferta. (2) Smart Load Planner y cargas de retorno aumentan la ocupación. (3) La negociación bidireccional permite ajustar el precio dentro del piso.

### Sobre Datos

**¿Cómo se calcula el Trust Score?**
> Es bayesiano (RN09): `score = (C·m + Σ xᵢ) / (C + n)` con prior m = 75 y peso C = 5, donde `xᵢ = (rating − 1) × 25`. Se recalcula tras cada calificación en `ReputationRecalculator`, con bloqueo de la fila. El prior evita que un transportista nuevo con pocas calificaciones quede descalificado. Las métricas compuestas (cancelación, pago) del SRS están pendientes.

**¿Cómo evitan la desintermediación (que acuerden por fuera)?**
> El chat bloquea teléfonos (con espacios, puntos, guiones o +51), emails, URLs y `@usuario` (RN07, `ContactInfoPolicy`) tanto en mensajes como en contraofertas, y solo se pueden calificar envíos completados dentro de la plataforma (RN06). El nombre y datos de contacto no se exponen antes de la aceptación.

**¿Por qué las reglas están en el dominio Java y no en triggers?**
> Las políticas con nombre (`PriceFloorPolicy`, `StopSequencePolicy`, …) son código puro con pruebas unitarias, independientes del motor. En la base dejamos lo que expresa seguridad e integridad: claves, `CHECK`, índices únicos parciales y RLS. Un único trigger (`realtime_events_notify`) sirve la mensajería.

### Sobre Implementación

**¿Por qué Quarkus y no Spring Boot?**
> Arranque rápido y bajo consumo en contenedores, integración nativa con OpenAPI, JWT, Flyway y Dev Services (PostgreSQL real en desarrollo y pruebas sin configuración). Usamos el estilo bloqueante porque hace explícita la transacción por petición, que es la que activa RLS.

**¿Cómo funciona el tiempo real y qué pasa si se cae la conexión?**
> SSE (`/api/v1/events/stream`) alimentado por el outbox: cada evento se proyecta en `realtime_events` con su destinatario explícito y un trigger avisa por `LISTEN/NOTIFY` a todas las réplicas. Los eventos son avisos con payload mínimo: el cliente vuelve a pedir por REST lo que muestra. Si se corta, el cliente reconecta con `Last-Event-ID` y el servidor reenvía lo perdido bajo RLS (o `stream.resync` si fueron más de 500); además hay un polling lento de respaldo.

**¿Cómo funciona la evidencia de entrega y el modo sin conexión del conductor?**
> La entrega solo se completa con una foto previa (`DELIVERY_PHOTO`, validada por firma binaria). En Android, la evidencia entra a una cola persistente (`EvidenceRepository`) que reintenta automáticamente cada 20 s; la firma es opcional. No hay caché offline de la ruta completa (queda como mejora).

**¿Cómo manejan la concurrencia en las subastas?**
> `UNIQUE (auction_id, carrier_org_id)` impide ofertas duplicadas; `PlaceBidUseCase` carga la subasta con bloqueo, de modo que el cierre por 5 ofertas (RN04) es exacto bajo concurrencia, y el job de cierre usa el índice parcial `ix_auctions_open`.

### Sobre Calidad

**¿Qué pasa si el sistema cae durante un envío activo?**
> El estado vive en PostgreSQL con transacciones ACID; las migraciones Flyway corren al arrancar y el contenedor tiene *healthcheck* (`/q/health/ready`). El outbox reintenta con espera exponencial los avisos que no se entregaron, de modo que no se pierden. Los objetivos de disponibilidad (99 %, RPO/RTO) son un plan de producción, aún no medido.

**¿Cómo escalarán cuando tengan más usuarios?**
> El backend no guarda estado de sesión (JWT), admite varias réplicas contra la misma BD (outbox con `SKIP LOCKED`, fan-out de SSE por `LISTEN/NOTIFY`) y los archivos van a Cloudflare R2. Hoy el despliegue de producción es un único VPS (Hostinger KVM 2): escala verticalmente y, después, separando la base de datos. Limitaciones conocidas: el rate limiting es por instancia y cada réplica mantiene una conexión de BD para el `LISTEN`. Con PgBouncer, el `LISTEN` necesita conexión directa. Los módulos `pricing` y `trip` son los primeros candidatos a extraer.

**¿Por qué dejaron AWS por un VPS de Hostinger, y qué riesgo asumen?**
> Por costo y simplicidad. El diseño en AWS costaba unos USD 333 al mes; el sistema real corre en cuatro contenedores y un VPS Hostinger KVM 2 (2 vCPU, 8 GB, 100 GB NVMe, Brasil) cuesta unos USD 14 al mes con Cloudflare (DNS/CDN/WAF) y R2 (documentos y respaldos). El riesgo es un único dominio de falla: lo mitigamos con respaldos diarios cifrados fuera del proveedor (R2), un runbook de reconstrucción (RTO de 2–4 h, RPO de 24 h) y escalado vertical; si el negocio exigiera 99.9 %, el siguiente paso es un segundo nodo con réplica de PostgreSQL. El impacto financiero está recalculado en el Business Case (VAN base S/ 429,952, payback en el mes 5).

**¿Por qué el producto se llama OnCargo si el repositorio dice LOGYX?**
> El producto se renombró a OnCargo (dominio `oncargo.tech`). El nombre técnico `logyx` (paquetes, base de datos, códigos de error, repositorio) se conserva a propósito para no romper contratos, migraciones ni la identidad de la app Android; el renombre técnico queda planificado.

**¿Qué quedó pendiente?**
> Mostrar la ruta por carretera en los mapas web y Android (ADR-0008), SUNAT, email/push, Google OAuth, formato de tracking LGX y ETA, métricas compuestas del Trust Score, app iOS, despliegue continuo, medición de cobertura y pruebas de carga. Están listados en [Auditoría](../entregable-4/auditoria.md) con su plan.

---

## 6. Evidencia

| Item | Estado |
|------|--------|
| Video pitch (3–5 min) | Pendiente — agregar link |
| Diapositivas de sustentación | [Presentación del proyecto](../../presentacion.html) |
| Sistema para demo | Local (backend dev + web + emulador Android) o contenedores (`infra/`) |
| APK de la app Android | Se genera con `./gradlew assembleDebug` |
| Capturas del sistema real | [Arquitectura Frontend §6](../entregable-3/arquitectura-frontend.md#6-capturas-de-pantalla-del-sistema-real) |
| Ejecuciones de CI | Pendiente — screenshot de GitHub Actions |

---

*OnCargo · E5 Sustentación · Competencia CE0217 · Versión 2.0 · Noviembre 2026*
