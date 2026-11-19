# E4 — Informe de Auditoría Técnica y Plan de Evolución
> Competencia CE0244 · Evaluación estructurada + Plan de mejora continua  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Versión: 2.0 (auditoría del sistema construido) · Noviembre 2026 · Versión original 1.0, junio 2026

!!! info "De auditoría de diseño a auditoría del sistema"
    La v1.0 (junio 2026) era una auditoría **pre-construcción** sobre el diseño inicial; sus hallazgos (triggers de capacidad, `price_floor` generado, Redis para rate limiting, WebSocket) correspondían a un diseño que cambió (ver [Cambios respecto al diseño inicial](../cambios-diseno-inicial.md)). Esta v2.0 audita el **sistema implementado** con evidencia verificable en el repositorio.

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Tipo de auditoría** | Auditoría técnica interna del sistema construido (estado al 2026-11-10) |
| **Estándar de calidad aplicado** | ISO/IEC 25010 (Calidad del producto de software) |
| **Dimensiones evaluadas** | Funcionalidad · Rendimiento · Seguridad · Mantenibilidad · Portabilidad (+ Usabilidad y Fiabilidad) |
| **Evidencia** | Código, migraciones V1–V24, contrato OpenAPI, 564 pruebas backend, ≈ 252 e2e, ≈ 545 pruebas Android, workflows de CI, `docs/STATUS.md`, `docs/security.md` |
| **Auditores** | Equipo OnCargo (autoevaluación; la revisión por pares la cubre `ModuleBoundariesTest` y el chequeo de contrato en CI) |

---

## 2. Dimensiones ISO/IEC 25010 Evaluadas

### 2.1 Funcionalidad y Corrección

| Característica | Criterio de evaluación | Estado | Evidencia |
|---------------|----------------------|--------|-----------|
| **Completitud funcional** | RF01–RF67 implementados | **51 completos, 13 parciales, 3 no implementados** (RF06, RF50, RF59) | Columna de estado del [SRS](../entregable-1/srs.md) |
| **Reglas de negocio** | RN01–RN12 | **12 de 12 implementadas** con política de dominio y prueba | `docs/domain/business-rules.md` |
| **Corrección** | Salidas correctas ante entradas válidas e inválidas | Verificado: errores de negocio con código `LOGYX-XXX-NNN` y campo (`field`) | 564 pruebas backend, e2e de errores inline |
| **Coherencia web/móvil** | Mismo contrato, mismo comportamiento | Verificado: ambos clientes consumen el mismo OpenAPI; Android cubre sus flujos con pruebas | `docs/api/openapi.yaml` (210 rutas, 242 operaciones, 435 schemas) |
| **Trazabilidad RF → código** | Cada RF mapea a módulo | Verificado | [SRS §11](../entregable-1/srs.md) |

**Hallazgos de funcionalidad:**

| ID | Hallazgo | Severidad | Módulo | Estado |
|----|---------|-----------|--------|--------|
| HLZ-101 | Distancia por Haversine × 1.35, no por carretera real: el precio sugerido y el piso RN03 eran aproximados | Media | pricing | **Cerrado en backend (ADR-0008):** `RoadDistanceProvider` usa km por carretera (dataset OSRM precalculado). Residual: ciudades del catálogo solamente (sin direcciones arbitrarias) y mapas web/Android aún sin la ruta |
| HLZ-102 | Código de tracking `LGX-XXXXX`, ETA y estado `ISSUE` del envío no implementados (RF34, RF35, RF53) | Baja | shipment | Abierto; RN11 cubierto con bloqueo de paradas |
| HLZ-103 | La resolución de una incidencia no fija el estado final del envío (RF55 parcial) | Media | incident | **Cerrado (V13):** el operador fija `shipment_outcome` al resolver |
| HLZ-104 | Trust Score solo bayesiano sobre calificaciones; métricas compuestas RF42/RF43 pendientes | Baja | reputation | Abierto |
| HLZ-105 | Sin notificaciones por email/push (RF50); las in-app y en vivo funcionan | Media | notification | **Parcial (V24):** correo según preferencias construido; falta el proveedor SMTP en el VPS; push pendiente |
| HLZ-106 | Sin listado consolidado de documentos (RF48) y sin Smart Load en el panel del operador (RF59) | Baja | documents, operator | **Parcial:** la API del listado consolidado de documentos (RF48) ya existe, falta su pantalla; sigue sin Smart Load en el panel del operador (RF59) |

### 2.2 Rendimiento y Eficiencia

| Aspecto | Medida de diseño | Estado de verificación |
|---|---|---|
| Índices | Compuestos y **parciales** por organización/estado (ver [Modelo de Datos §5](../entregable-2/modelo-datos.md#5-indices-principales)) | Implementado |
| Pools | 8 conexiones privilegiadas + 20 de la app por instancia; `CONNECTION LIMIT 50` | Implementado |
| Tiempo real | SSE con payload mínimo; el cliente refresca por REST; una conexión SSE por pestaña (proxy de Astro); latido 20 s | Implementado y probado (`RealtimeStreamFlowTest`) |
| Outbox | Despacho inmediato + job de respaldo cada 5 s, `SKIP LOCKED` para réplicas | Implementado y probado (`OutboxTest`) |
| RNF01/RNF02 (p95 < 2 s, marketplace < 1.5 s) | Sin mediciones | **Pendiente:** no hay pruebas de carga ni métricas de producción |

### 2.3 Seguridad

| Control | Evidencia | Estado |
|---|---|---|
| Aislamiento por organización (doble barrera: JWT + RLS) | `RowLevelSecurityTest` (8) | Implementado |
| Mínimo privilegio de BD (`logyx_api` vs `logyx_owner`) | `DatabasePrivilegesTest` (SQLSTATE 42501) | Implementado |
| Autenticación JWT RSA 8 h + cookie `httpOnly` en la web | `application.properties`, `lib/session.ts` | Implementado (sin refresh token) |
| Rate limiting y bloqueo por email | `AuthRateLimitFlowTest`, `RateLimiterTest` | Implementado, **por instancia** |
| Cabeceras de seguridad, CSP, CSRF (`checkOrigin`), HSTS en prod | `docs/security.md` | Implementado |
| Archivos: firma binaria, 10 MB, claves de servidor | `DocumentUploadPolicyTest` | Implementado |
| Privacidad: consentimiento y `/privacidad`, logs sin datos personales | `AuthDtos.RegisterRequest`, `docs/security.md` | Implementado |

**Hallazgos de seguridad (riesgos residuales declarados):**

| ID | Hallazgo | Severidad | Estado | Plan |
|----|---------|-----------|--------|------|
| SEC-101 | `set_config('app.org_id', …)` podría suplantar organización ante una inyección SQL dentro de una transacción de usuario (ADR-0006) | Media | Residual aceptado; mitigado con JPA parametrizado | Firmar el contexto con HMAC verificado por las políticas |
| SEC-102 | CSP con `script-src 'unsafe-inline'` (scripts de hidratación de Astro) | Media | Abierto | Nonces/hashes |
| SEC-103 | Rate limiting en memoria: con N réplicas el límite efectivo es ×N; sin CAPTCHA ni MFA | Media | Abierto | Mover contadores a Redis/BD al escalar |
| SEC-104 | Documentos sin antivirus ni URLs firmadas; claves JWT y credenciales con rotación manual | Baja | Abierto | ClamAV / URLs firmadas / gestor de secretos |
| SEC-105 | Eventos del outbox en `FAILED` sin alerta automática | Baja | Abierto | Alerta sobre `FAILED` |
| SEC-106 | El stack trace de un error 500 puede incluir valores de una restricción SQL | Baja | Abierto | Filtro de errores de producción |

> Los hallazgos SEC-004 de la v1.0 (sin límite de intentos de login) y HLZ-003 (`price_floor` nulo) **quedaron resueltos por construcción**: el rate limiting existe y el piso se calcula siempre en el dominio (`PriceFloorPolicy`) al publicar.

### 2.4 Mantenibilidad

| Característica | Evidencia |
|---|---|
| Modularidad | 23 módulos de negocio hexagonales con la misma forma (`domain/application/infrastructure`) |
| Reutilización y límites | `ModuleBoundariesTest` falla si el dominio importa Quarkus/JPA o si un módulo importa la `infrastructure` de otro |
| Analizabilidad | Una carpeta por feature en web y Android; guías `AGENTS.md` por componente; ADR numerados |
| Modificabilidad | Cambios aditivos de contrato con `CHANGELOG`; el comparador de OpenAPI bloquea cambios incompatibles |
| Capacidad de prueba | Dominio puro con pruebas unitarias; políticas con nombre por regla |

### 2.5 Portabilidad y Despliegue

| Aspecto | Evidencia |
|---|---|
| Contenedores | `backend/Dockerfile`, `web/Dockerfile`, `infra/docker-compose.yml` verificado con login web real |
| Configuración | Variables de entorno (`DB_*`, `JWT_*`, `LOGYX_S3_*`, `API_URL`, `COOKIE_SECURE`) |
| Intercambiabilidad | Almacenamiento local / S3-compatible (R2, MinIO) tras un puerto; distancia tras un puerto |
| Plataformas | Web (Chromium verificado), Android 10+ (`minSdk` 29); iOS planificado |

### 2.6 Usabilidad y Fiabilidad (adicionales)

- **Usabilidad:** sistema de diseño propio (tokens, componentes, microcopy en `docs/design/`), modo claro/oscuro, **WCAG 2.1 AA verificado con axe** en e2e, errores inline por campo, fuente 1.3x probada en Android.
- **Fiabilidad:** transacciones ACID, outbox con reintentos, reanudación SSE y polling de respaldo, cola persistente de evidencia en Android con reintento automático.

---

## 3. Métricas del Sistema

### 3.1 Métricas de calidad de código (al 2026-11-19, commit `848ba00`)

| Métrica | Valor | Fuente |
|---------|-------|--------|
| Líneas Java (backend, `src/main`) / archivos | ≈ 43,100 / 672 (al 10-nov: ≈ 14,900 / 303) | conteo del repositorio |
| Líneas de pruebas backend | ≈ 15,100 (128 clases, 564 casos) | ídem |
| Líneas web (TS/TSX/Astro, sin el cliente generado) / líneas e2e | ≈ 27,600 / ≈ 6,900 (≈ 252 tests en 42 specs) | ídem |
| Líneas Kotlin (Android, `src/main`) / pruebas | ≈ 25,400 / ≈ 10,100 (≈ 545 tests) | ídem |
| Migraciones / tablas / políticas RLS | 24 / 57 / 150 | `db/migration` aplicado en PostgreSQL 16 |
| Contrato | 210 rutas, 242 operaciones, 435 schemas | `docs/api/openapi.json` |
| Cobertura de líneas | No medida | pendiente (JaCoCo) |
| Cumplimiento de límites hexagonales | 100 % (verificado en cada build) | `ModuleBoundariesTest` |

### 3.2 Métricas de negocio (KPIs del MVP)

No hay operación real todavía: el sistema se probó con datos de demostración. Los KPI de Gestión TI (OP1–OP6: 80 PYMEs, NPS ≥ 45, SLA de oferta en 24 h, contratación < 60 min) se medirán tras el piloto; el sistema ya registra los datos para calcularlos (`audit_log`, `shipment_requests`, `bids`, `/operator/metrics`).

---

## 4. Plan de Mejora y Evolución

### Fase 1 — Antes del piloto

| Acción | Cierra | Esfuerzo |
|---|---|---|
| Despliegue continuo a staging y publicación de imágenes | EP-16 | Medio |
| Medir cobertura (JaCoCo) y pruebas de carga contra RNF01/RNF02 | Brecha de calidad | Medio |
| CSP con nonces; alertas del outbox en `FAILED` | SEC-102, SEC-105 | Bajo |
| Dibujar la ruta por carretera en los mapas web y Android (el backend ya la sirve en `GET /api/v1/routes`, ADR-0008) | HLZ-101 (residual) | Bajo |
| Aprovisionar el VPS Hostinger (Caddy, UFW, fail2ban), conectar Cloudflare R2 y activar los respaldos diarios con prueba de restauración | Brecha de operación | Medio |

### Fase 2 — Evolución del producto

| Acción | Cierra |
|---|---|
| Email y push (adaptadores sobre el outbox) | HLZ-105, RF50 |
| Verificación SUNAT del RUC | RF04 |
| Estado final del envío al resolver incidencias; métricas compuestas del Trust Score | HLZ-103, HLZ-104 |
| Rate limiting distribuido, firma del contexto RLS, antivirus y URLs firmadas | SEC-101, SEC-103, SEC-104 |
| App iOS (SwiftUI) con `core:model`/`core:network` vía KMP | RNF13 |

### Fase 3 — Escala y expansión

Extraer módulos con carga (pricing, matching) como servicios, reevaluar aislamiento por tenant si se ofrece marca blanca (ADR-0001), pagos/escrow con pasarela PCI-DSS, y modelos predictivos de precio y ETA.

---

## 5. Conclusiones de la Auditoría

1. **El sistema cumple el núcleo funcional del SRS:** las 12 reglas de negocio y el flujo completo publicar → ofertar → aceptar → ejecutar → evidenciar → calificar están implementados y probados de extremo a extremo.
2. **La mayor fortaleza es la seguridad de datos**: RLS con mínimo privilegio verificada contra PostgreSQL real, algo que el diseño inicial no tenía implementado.
3. **Las brechas son de integración externa y de operación** (rutas por carretera en los mapas, SUNAT, email, aprovisionamiento del VPS y despliegue continuo, cobertura y carga), no del núcleo; están acotadas tras puertos y adaptadores y tienen plan.
4. **Las desviaciones del diseño inicial** (Astro, Kotlin, una app por roles, RLS en lugar de multitenancy, estilo bloqueante) mejoraron mantenibilidad y verificabilidad y están justificadas por ADR.

---

*OnCargo · E4 Auditoría Técnica · Competencia CE0244 · Versión 2.0 · Noviembre 2026*
