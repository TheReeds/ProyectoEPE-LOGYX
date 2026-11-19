# Cambios respecto al diseño inicial

> Área de Software · Documento transversal a E1–E5  
> Versión: 2.0 (rebrand OnCargo y migración a Hostinger) · Noviembre 2026 · Versión 1.0: cambios de software

Los documentos de especificación y diseño del EPE (SRS, Arquitectura, UML, Modelo de datos, v1.0 de junio 2026) se escribieron **antes de construir el sistema**. Al implementarlo, varias decisiones se revisaron con evidencia y quedaron registradas como ocho ADR numerados (`docs/adr/0001` a `0008` del repositorio del sistema). En noviembre de 2026 se sumaron dos cambios transversales: el **rebrand de LOGYX a OnCargo** y la **migración de la infraestructura de AWS a un VPS Hostinger** (ver la [sección 7](#7-rebrand-oncargo-y-migracion-a-hostinger)). Esta página reúne **qué cambió, por qué y qué efecto tuvo**, para que cualquier lector (incluido el jurado) pueda reconciliar el diseño inicial con el sistema real.

!!! success "Idea central"
    No se cambió el problema ni los requerimientos: las doce reglas de negocio RN01–RN12 están implementadas y el flujo completo funciona. Se cambió **cómo** se construyó, y cada cambio mejora verificabilidad, seguridad o mantenibilidad y está documentado.

## 1. Resumen de cambios

| # | Diseño inicial (v1.0) | Sistema real | ADR | Efecto en la documentación |
|---|---|---|---|---|
| 1 | Frontend web en **Angular 18+** (RT02) | **Astro 7 SSR** + islas React + shadcn/ui + Tailwind 4 | 0003 | SRS RT02, Arquitectura, Arquitectura Frontend |
| 2 | **Tres apps Flutter** (Business, Driver, Operator) (RT03, ADR-03) | **Una app Android nativa Kotlin/Compose** con navegación por rol; el operador usa solo la web; iOS (SwiftUI) planificado | 0003 | SRS RT03, Prototipos, Arquitectura Frontend |
| 3 | Aislamiento solo por filtros de aplicación; RLS "no implementado"; modelo de 4 roles de BD | **Aislamiento por organización + RLS implementado**, mínimo privilegio (`logyx_api`/`logyx_owner`/`logyx_app`); multitenancy evaluado y **descartado** | 0001, 0006 | Seguridad BD, Arquitectura §3, SRS RNF21–RNF22 |
| 4 | Backend **reactivo** (Mutiny, Hibernate Reactive), monolito modular | Monolito modular **bloqueante con arquitectura hexagonal** por módulo, vigilada por `ModuleBoundariesTest` | 0002 | Arquitectura, Sistema |
| 5 | Chat y notificaciones por **WebSocket + Redis Pub/Sub** | **Outbox transaccional + SSE** (`realtime_events`, `LISTEN/NOTIFY`); sin Redis | 0004, 0006, 0007 | Sistema §4.5, Arquitectura |
| 6 | Reglas de negocio y auditoría en **triggers y funciones** de BD; PostGIS; ENUM nativos; 22 tablas | Reglas en **políticas de dominio** (Java puro); `VARCHAR + CHECK`; sin PostGIS; **57 tablas** (migraciones V1–V24; 24 al cierre de la fase 6 con V12) | 0002 | Modelo de Datos, Scripts SQL |
| 7 | Documentos en MinIO con SDK | Puerto `DocumentStorage` con adaptadores local y **S3-compatible** (MinIO en staging local y en el VPS; **Cloudflare R2** como opción futura); validación por firma binaria | 0005, 0006 | Sistema §6 |
| 8 | Rutas con **OpenRouteService** (RT05) | **Distancia por carretera** tras el puerto `DistanceProvider` (ADR-0008: precálculo OSM/OSRM versionado, módulo `routing`, `RoadDistanceProvider` en pricing, `GET /api/v1/routes`; ORS descartado); falta dibujar la ruta en los mapas MapLibre + OpenFreeMap | 0008 | SRS RT05, Sistema §6 |
| 9 | Pruebas con JUnit/Mockito, **Cypress**, flutter_test | JUnit 5 + PostgreSQL real, **Playwright + axe**, pruebas Android | — | Plan de Pruebas |
| 10 | Un `ci.yml` con deploy a staging | **Cinco workflows** (backend, web, android, contract, e2e) + chequeo de compatibilidad del contrato OpenAPI | — | CI/CD |
| 11 | JWT 1 h + refresh 7 días, Google OAuth | JWT RSA de 8 h, sin refresh ni Google | — | SRS RNF05, RF06 |
| 12 | Contrato de API descrito en documentos | **OpenAPI generado por el backend = fuente de verdad** consumida por web (cliente tipado) y Android | — | Sistema §4.1 |
| 13 | Producto llamado **LOGYX** | Producto llamado **OnCargo** (dominio `oncargo.tech`); el nombre técnico `logyx` se conserva en código, BD, repo y rutas | — | Toda la documentación (sección 7) |
| 14 | Infraestructura en **AWS** (VPC multi-AZ, EC2, RDS, ElastiCache, S3, CloudFront; ~USD 333/mes) | **VPS Hostinger KVM 2** con Docker Compose y Caddy; Cloudflare (DNS/CDN/WAF); **Cloudflare R2**; ~USD 14/mes | — | Área de Infraestructura y Gestión de TI (sección 7) |
| 15 | Costos y Business Case calculados sobre AWS (VAN base S/ 406,806) | Recalculados sobre el VPS (VAN base S/ 429,952), con tipo de cambio explícito S/ 3.45 | — | Business Case, Costos (sección 7) |

## 2. Justificación de cada cambio

### 2.1 Angular → Astro (ADR-0003)

**Motivo.** Una plataforma de negocio con páginas por rol, tablas y formularios se beneficia del renderizado en servidor: menos JavaScript en el navegador, mejor tiempo de primera carga y, sobre todo, **el JWT nunca llega al JS** (cookie `httpOnly`; solo el servidor de Astro habla con la API). Las partes realmente interactivas (comparación de ofertas, chat, mapas, formularios con cotización en vivo) son islas React con primitivas shadcn/ui (código propio sobre Radix, MIT).  
**Efecto.** Menor superficie de ataque (XSS no puede robar el token), cliente tipado generado del contrato y una biblioteca de componentes propia con accesibilidad AA verificada por axe.  
**Costo.** El equipo tuvo que adoptar un modelo mental SSR + islas (trampas documentadas en `web/AGENTS.md`).

### 2.2 Flutter × 3 → una app Android nativa (ADR-0003)

**Motivo.** El diseño separaba tres apps por UX; en la práctica, el transportista, la PYME y el conductor comparten casi toda la capa de datos, y el operador necesita pantallas densas que son naturales en web. Se construyó **una app con flujos por rol** (se puede dividir en *flavors* después). Kotlin/Compose nativo da acceso directo a cámara, mapas y SSE en primer plano, y permite que `core:model` y `core:network` sean Kotlin puro para convertirse en Kotlin Multiplatform cuando se haga la app SwiftUI de iOS.  
**Efecto.** Menos código duplicado, un solo pipeline de pruebas (165 unitarias + 8 instrumentadas) y una ruta clara a iOS.  
**Costo.** iOS queda como fase posterior; el RNF13 (iOS 16+) se cumple solo en Android por ahora. El panel del operador es solo web (se perdió el prototipo "Operator móvil").

### 2.3 Multitenancy → aislamiento por organización + RLS (ADR-0001, ADR-0006)

**Pregunta.** ¿OnCargo debe ser multitenant (BD por tenant, esquema por tenant o discriminador `@TenantId`)?  
**Decisión.** No. OnCargo es un **marketplace**: su flujo central cruza organizaciones (una PYME publica, varios transportistas ofertan, uno ejecuta). Los modelos de multitenancy asumen que los datos de un tenant nunca se cruzan con otro; aplicarlos rompería el marketplace. Se eligió una sola BD con datos *org-scoped*, **doble barrera** (filtros por la organización del JWT + PostgreSQL Row-Level Security) y datos públicos por política explícita. Se agregó **mínimo privilegio**: la aplicación se conecta como `logyx_api`, que no puede escalar privilegios, y lo que corre sin usuario entra por `SystemTx` de forma explícita (fail-closed).  
**Evidencia.** `RowLevelSecurityTest`, `DatabasePrivilegesTest`, `RealtimeStreamFlowTest`.  
**Reevaluación.** Si OnCargo se vendiera como marca blanca a cooperativas, se evaluaría un esquema por cooperativa. Ver [Arquitectura §3](entregable-1/arquitectura.md#3-evaluacion-de-multitenancy-y-decision-de-aislamiento).

### 2.4 Reactivo → bloqueante hexagonal (ADR-0002)

**Motivo.** RLS exige que cada transacción de usuario fije su contexto (`set_config` + `SET LOCAL ROLE`) sobre la misma conexión; con un modelo bloqueante, la transacción por petición es explícita y simple de razonar. La carga esperada del MVP no requiere Mutiny. La arquitectura hexagonal pone las reglas en clases de dominio sin Quarkus ni JPA, probables como unidad, y descubribles: para trabajar en "ofertas" se abre `marketplace/` y nada más.  
**Alternativas descartadas.** Clean Architecture con capas globales (dispersa cada feature) y microservicios desde el inicio (costo operativo injustificado para 3 personas).  
**Efecto.** 23 módulos de negocio (más el núcleo `shared`) con la misma forma, límites verificados automáticamente y extracción futura sin reescribir el dominio.

### 2.5 WebSocket + Redis → outbox + SSE (ADR-0004, 0006, 0007)

**Motivo.** Los avisos no pueden perderse entre el *commit* y el observador, y el tiempo real debe respetar el aislamiento. Un **outbox transaccional** garantiza entrega al menos una vez con reintentos; el tiempo real se alimenta de él con **SSE** (unidireccional, atraviesa proxies, reanuda con `Last-Event-ID`) y una proyección con **destinatario explícito por fila**, con `LISTEN/NOTIFY` para varias réplicas. No se necesitó infraestructura nueva (ni Redis).  
**Efecto.** Aislamiento demostrable en tres capas y menos piezas operativas. **Costo:** el rate limiting, que el diseño inicial ponía en Redis, quedó en memoria por instancia (riesgo documentado).

### 2.6 Lógica en la BD → lógica en el dominio

**Motivo.** Las reglas (RN01–RN12) son más fáciles de probar y mantener como políticas Java con nombre que como *triggers*. En la BD se dejó lo que expresa integridad y seguridad: claves, `CHECK`, índices únicos parciales (p. ej. una sola incidencia activa por envío) y RLS. Se simplificó el modelo (sin PostGIS, sin ENUM nativos): la cercanía entre ciudades la calcula `CityProximityPolicy`.

### 2.7 Otros ajustes menores

- **Radio de retornos:** 50 km en lugar de 30 km, porque en el corredor el par de ciudades cercano real (Juliaca–Puno) está a 44 km.
- **Trust Score:** se implementó el método bayesiano (prior 75, peso 5) sobre las calificaciones; las métricas compuestas del SRS (cancelación, pago) quedaron pendientes.
- **RN11:** se implementó como bloqueo de paradas con una incidencia activa, sin agregar un estado `ISSUE` al envío (habría cambiado el enum del contrato).

## 3. Qué NO cambió

El problema y los actores; las cuatro familias de usuarios; la arquitectura de software (Quarkus hexagonal, Astro SSR, Android nativo, PostgreSQL con RLS); PostgreSQL 16 como base única; Quarkus como framework del backend (RT01); contenedores y CI con GitHub Actions (RT06, RT07); el estilo de **monolito modular migrable** (ADR-01 original); la subasta inversa de 20 minutos o 5 ofertas; las reglas RN01–RN12; y el cumplimiento de la Ley N° 29733 (consentimiento y política de privacidad).

## 4. Trazabilidad: dónde se refleja cada cambio

| Documento | Estado |
|---|---|
| [SRS](entregable-1/srs.md) | v1.1: columna de estado/módulo por RF, RNF y RN; RT02/RT03/RT05 actualizadas; RNF21–RNF25 nuevas |
| [Arquitectura](entregable-1/arquitectura.md) | v2.0: ADR 0001–0007, C4 actualizado, evaluación de multitenancy |
| [UML](entregable-1/uml.md) | v2.0: diagramas desde el código real |
| [Modelo de Datos](entregable-2/modelo-datos.md), [Scripts](entregable-2/scripts.md), [Seguridad](entregable-2/seguridad.md) | v2.0: migraciones V1–V12 y RLS implementado; cifras actualizadas a V1–V24 (19-nov-2026) |
| [Sistema](entregable-3/sistema.md), [Arquitectura Frontend](entregable-3/arquitectura-frontend.md) | v2.0: sistema real con capturas |
| [Plan de Pruebas](entregable-4/plan-pruebas.md), [CI/CD](entregable-4/cicd.md), [Auditoría](entregable-4/auditoria.md) | v2.0: suite y workflows reales |
| [Backlog](entregable-4/backlog.md) | v1.1: plan de sprints conservado + sección de trazabilidad |
| [Prototipos](entregable-1/prototipos.md) | Nota de alineación (el inventario de pantallas diseñadas se conserva); el prototipo de Figma conserva la marca LOGYX |
| [Infraestructura](../infraestructura/index.md) (diseño de red, seguridad, datacenter; implementación) | v2.0: rediseñada sobre VPS Hostinger + Cloudflare + R2 (sección 7) |
| [Business Case](../gestion-ti/entregable-2-business-case.md), [Costos](../gestion-ti/entregable-3/costos.md), [Project Charter](../gestion-ti/entregable-3/project-charter.md) | v2.0: costos, VAN, TIR y payback recalculados (sección 7) |

Los documentos de Gestión de TI de diagnóstico, cronograma y procesos no se reescriben (solo cambió el nombre del producto); los de costos y el Business Case sí se recalcularon por el cambio de infraestructura.

## 5. Capturas de pantalla previas al rebrand

Las capturas de `entregable-3/img/` (ver [Sistema Implementado](entregable-3/sistema.md)) se tomaron **antes del rebrand**: la interfaz que muestran lleva la marca **LOGYX** (logotipo y textos). No se regeneraron a propósito, porque documentan el estado verificado del sistema en la fecha de captura y la funcionalidad no cambió. El monorepo ya incorpora la marca OnCargo (logotipos, favicon y ícono de la app Android; ver `docs/brand.md` del repositorio del sistema), de modo que una captura nueva mostraría OnCargo. Lo mismo ocurre con el prototipo navegable de Figma (`LOGYX-PROTOTIPOS`).

## 6. Rutas por carretera (ADR-0008)

La distancia del precio (RN03) y los mapas usaban la línea recta × 1.35 entre ciudades, con errores de −52 % a +21 % frente a la carretera real (p. ej. Cusco–Ayacucho: 334 km estimados contra 699 km reales). El **ADR-0008** (aceptado el 16-nov-2026) decide un enfoque híbrido: **ahora**, un **precálculo offline versionado** de la matriz de distancias y geometrías entre las 11 ciudades del catálogo con OSRM sobre datos de OpenStreetMap (módulo `routing`, dataset en el repositorio, sin red en ejecución, sin claves ni costo); **después**, un motor propio (OSRM o Valhalla) para direcciones arbitrarias. OpenRouteService (RT05) quedó descartado por depender de un servicio externo con cuota y sin SLA. Estado: el **backend está completo (fases 1 y 2)**: módulo `routing` con optimizador de paradas Held-Karp; `pricing` usa `RoadDistanceProvider` (los precios sugeridos y pisos RN03 de las solicitudes nuevas salen de km por carretera; Lima → Cusco +42 %, Lima → Ica −17 %); retornos y Smart Load usan los mismos km; y existe `GET /api/v1/routes?stops=…[&optimize=true]` con polyline y atribución OSM. **Falta solo dibujar la ruta en los mapas de web y Android.** Los datos derivados de OpenStreetMap se atribuyen conforme a la licencia ODbL.

## 7. Rebrand OnCargo y migración a Hostinger

En noviembre de 2026 se hicieron dos cambios transversales, sin cambiar los requerimientos ni la arquitectura de software: el producto pasó de llamarse **LOGYX** a **OnCargo**, y el despliegue pasó de un diseño en **AWS** a un **VPS Hostinger**.

### 7.1 Rebrand: LOGYX → OnCargo

| Aspecto | Antes | Después |
|---|---|---|
| Nombre del producto | LOGYX | **OnCargo** (escritura: O y C mayúsculas, sin espacio) |
| Dominio | `logyx.pe` (diseño inicial, cuentas demo) | **`oncargo.tech`** (web) y **`api.oncargo.tech`** (API para Android) |
| Sitio de documentación | "LOGYX — Documentación EPE" | "OnCargo — Documentación EPE", con logotipo, favicon y paleta de marca |
| Identidad visual | Sin logotipo definido | Logotipos en `docs/assets/img/` (copiados de `media/logos/` del monorepo) |

**Qué conserva el nombre técnico `logyx` (a propósito).** Siguiendo `docs/brand.md` del monorepo: nombre del repositorio y de la URL de GitHub Pages (`ProyectoEPE-LOGYX`), carpetas y rutas de archivos, paquetes `pe.logyx.*` y `applicationId` de Android, códigos de error `LOGYX-XXX-NNN`, roles y nombres de base de datos (`logyx_owner`, `logyx_app`, `logyx_api`, BD `logyx`), variables `LOGYX_*`, clases `Logyx*`, cuentas demo `*@logyx.pe` y la cookie `logyx_session`. Renombrarlos tocaría cientos de archivos, rompería contratos de API y migraciones, y cambiaría la identidad de la app Android. Queda como propuesta futura (renombre técnico coordinado).

### 7.2 Infraestructura: AWS → VPS Hostinger

| Componente | Antes (diseño v1.0, AWS) | Diseño v2.0 | Desplegado (v2.1, `infra/vps/`) |
|---|---|---|---|
| Cómputo | EC2 `t3.medium` × 2–12 con Auto Scaling, ECS Fargate para jobs | **VPS Hostinger KVM 2**: 2 vCPU, 8 GB RAM, 100 GB NVMe, datacenter en Brasil; jobs dentro del backend | Igual: KVM 2 con Ubuntu 24.04, 96 GB utilizables (región a confirmar en el panel) |
| Orquestación | ECS/EC2, Terraform | **Docker Compose** (`infra/docker-compose.yml`) | Docker Compose con `infra/vps/compose.yml` (5 servicios); despliegue con `infra/vps/deploy.sh` |
| Proxy / TLS | ALB + ACM + CloudFront | **Caddy** con HTTPS automático (Let's Encrypt) | Igual (Caddy 2.10, HTTP/3) |
| Base de datos | RDS PostgreSQL Multi-AZ | **PostgreSQL 16** en contenedor (RLS), sin puertos publicados | Igual |
| Caché / tiempo real | ElastiCache Redis | Sin Redis: SSE sobre outbox (ADR-0007) | Igual |
| Documentos | S3 (o MinIO) | **Cloudflare R2** (API compatible con S3; el adaptador `S3DocumentStorage` no cambia) | **MinIO** en el VPS (R2 queda para producción) |
| Backups | Snapshots de RDS, S3 versionado | **`pg_dump` diario cifrado hacia R2**, retención de 30 días | **Sin respaldos automáticos** (pendiente; procedimiento manual documentado) |
| DNS / CDN / WAF | Route 53, CloudFront, AWS WAF | **Cloudflare** (plan gratuito), dominio `oncargo.tech` | DNS en el panel de Hostinger, directo a la IP del VPS; sin CDN ni WAF |
| Seguridad y monitoreo | IAM, KMS, GuardDuty, Wazuh, CloudWatch | UFW + fail2ban, tokens de mínimo privilegio, Cloudflare WAF, monitoreo externo de disponibilidad | UFW + fail2ban, SSH solo con clave, `unattended-upgrades`, healthchecks de Docker; sin monitoreo externo |
| Disponibilidad de diseño | Tier III equivalente (Multi-AZ, ~99.99%) | Tier I equivalente en el origen (~99.5% estimado; RTO 2–4 h, RPO 24 h) | Tier I; RPO no garantizado mientras no haya respaldos |
| Costo mensual de referencia | ~USD 333 (≈ S/ 1,149) | **≈ USD 14 (≈ S/ 47)**: USD 8.99 del VPS en promoción con prepago de 24 meses (renueva a USD 14.99), dominio, R2 estimado | ≈ USD 13 (VPS + dominio; R2 no se usa) |

**Razones.**

1. **Costo.** El diseño en AWS costaba unas 24 veces más que el conjunto VPS + dominio + R2 para un MVP que, según el Business Case, genera ~10,830 operaciones en 24 meses. Un precio fijo y bajo elimina la variabilidad de la facturación por uso, que es difícil de predecir para un equipo de tres estudiantes.
2. **Simplicidad.** El sistema real corre en cuatro contenedores (proxy, web, backend, base de datos). Un VPS con Docker Compose reproduce exactamente el `infra/docker-compose.yml` del monorepo; no hacen falta VPC, subredes, balanceadores, Terraform ni una decena de servicios gestionados. Menos piezas significan menos superficie de configuración y menos conocimiento específico de un proveedor.
3. **Ajuste al sistema real.** El sistema no usa Redis, ni WebSocket, ni funciones serverless; los jobs son internos del backend; y la carga estimada (50–100 req/s en el pico) cabe en 2 vCPU y 8 GB con más de la mitad de la memoria libre.
4. **Portabilidad.** La imagen y el compose no dependen del proveedor: mudar a otro VPS (o volver a una nube) es un cambio de máquina, no de arquitectura.

**Qué se pierde.** La **redundancia**: un único nodo es un único dominio de falla (equivalente Tier I), sin *failover* automático ni escalado horizontal automático. Se mitiga, según el diseño, con respaldos diarios fuera del proveedor (R2; **aún no implementados**), un runbook de reconstrucción y escalado vertical; si el negocio exigiera 99.9% o RPO de minutos, el camino es un segundo nodo y réplica de PostgreSQL (ver [Diseño de Centro de Datos](../infraestructura/semestre-1/diseno-datacenter.md), sección 4.4). Además, el equipo asume la operación del sistema operativo y los parches.

**Estado de la implementación (actualizado, noviembre 2026).** El VPS está **aprovisionado y en operación como entorno de pruebas** (commit `cad2b77` del monorepo, carpeta `infra/vps/`): `compose.yml` con Caddy, web, backend, PostgreSQL y MinIO; `Caddyfile` con HTTPS automático y la página de descarga del APK; `bootstrap.sh` (secretos generados en el servidor) y `deploy.sh` (despliegue por `git archive` con vuelta atrás). El host tiene UFW, fail2ban, SSH solo con clave y `unattended-upgrades`. **No se desplegaron** Cloudflare, R2, los respaldos automáticos ni el monitoreo externo; el área de Infraestructura (versión 2.1) los marca como mejoras y documenta la configuración real.

### 7.3 Efecto en Gestión de TI (cifras financieras)

Tipo de cambio explícito: **S/ 3.45 por USD** (SUNAT venta 06-11-2026: S/ 3.452; BCRP interbancario ≈ S/ 3.43). Con los mismos ingresos, horizonte (24 meses) y tasa (18% anual) del Business Case, solo cambian los costos de infraestructura. Los cálculos completos, con fórmulas y análisis de sensibilidad, están en [E2 — Business Case](../gestion-ti/entregable-2-business-case.md) y [3.4 Costos](../gestion-ti/entregable-3/costos.md).

| Cifra | Antes (AWS) | Después (VPS Hostinger) |
|---|---|---|
| Inversión inicial | S/ 20,966 | S/ 20,992 |
| Costo operativo mensual | S/ 2,000 | S/ 858 |
| TCO a 24 meses | S/ 68,966 | S/ 41,585 |
| VAN base / conservador | S/ 406,806 / S/ 172,629 | S/ 429,952 / S/ 195,774 |
| TIR mensual base / conservador | 30.1% / 18.2% | 33.0% / 21.2% |
| Payback base / conservador | mes 6 / mes 9 | mes 5 / mes 7 |

!!! note "Qué es estimación"
    El costo mensual de AWS (USD 333) proviene del Anexo A de la versión 1.0 y los "otros costos operativos" de S/ 851 se obtienen por diferencia respecto de los S/ 2,000 originales; el consumo de R2 es estimado. El precio promocional de Hostinger y la tarifa del dominio pueden cambiar; la renovación del VPS (USD 14.99/mes) cae fuera del horizonte de 24 meses.

### 7.4 Documentos afectados

Todas las páginas de Software, Gestión de TI e Infraestructura reemplazan el nombre LOGYX por OnCargo; el área de **Infraestructura** (semestres 1 y 2) fue **rediseñada** sobre el VPS; el **Business Case**, los **Costos** y el **Project Charter** se recalcularon; y la web `presentacion.html` refleja la nueva marca, el stack y los costos. Las carpetas de respaldo `AreaSoftware/`, `AreaGestionTI/` y `AreaInfraestructura/` permanecen **congeladas** con la versión original (LOGYX, AWS).

