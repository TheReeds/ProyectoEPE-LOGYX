# E4 — Informe de Auditoría Técnica y Plan de Evolución
> Competencia CE0244 · Evaluación estructurada + Plan de mejora continua  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Versión: 1.0 · Junio 2026

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Tipo de auditoría** | Auditoría técnica interna (pre-lanzamiento) |
| **Estándar de calidad aplicado** | ISO/IEC 25010 (Calidad del producto de software) |
| **Dimensiones evaluadas** | Funcionalidad · Rendimiento · Seguridad · Mantenibilidad · Portabilidad |
| **Período de evaluación** | Junio 2026 |
| **Auditores** | Equipo LOGYX (autoevaluación con revisión externa) |

---

## 2. Dimensiones ISO/IEC 25010 Evaluadas

### 2.1 Funcionalidad y Corrección

| Característica | Criterio de evaluación | Estado | Hallazgos |
|---------------|----------------------|--------|-----------|
| **Completitud funcional** | RF01–RF67 implementados | Pendiente evaluación | — |
| **Corrección** | Outputs correctos para inputs válidos | Pendiente evaluación | — |
| **Coherencia** | Comportamiento consistente entre web y mobile | Pendiente evaluación | — |
| **Trazabilidad RF → Código** | Cada RF mapea a un endpoint o módulo | Verificado en E3 | OK |

**Hallazgos identificados en diseño:**

| ID | Hallazgo | Severidad | Módulo | Estado |
|----|---------|-----------|--------|--------|
| HLZ-001 | El trigger `trg_lock_vehicle_capacity_on_shipment` asume que `weight_kg` existe en la solicitud al momento de crear el envío. Si la solicitud fue modificada después de la subasta, puede haber inconsistencia. | Media | auction / tracking | ⬜ Pendiente — ver nota |
| HLZ-002 | El Smart Load Planner ejecuta cada 30 min pero no tiene mecanismo de deduplicación: si una sugerencia no fue respondida, podría generarse otra igual. | Baja | smartload | ⬜ Pendiente (Módulo 15 aún no implementado) |
| HLZ-003 | El campo `price_floor` es `GENERATED ALWAYS AS (suggested_price * 0.75)`. Si `suggested_price` es NULL (antes de calcular costos), `price_floor` también es NULL y la subasta podría abrirse sin precio mínimo. | Alta | auction / pricing | ✅ **Corregido (2026-07-06)** |

> **Corrección aplicada — HLZ-003 (2026-07-06):** este hallazgo estuvo activo en código desde
> Sprint 2 hasta ahora — `ShipmentRequestService.create()` tomaba `suggestedPrice` directo del
> body del cliente (la PYME), sin invocar nunca al motor de precios (Módulo 11, que en ese
> momento ni existía). Se corrigió inyectando `PricingService` en `ShipmentRequestService`:
> `create()` calcula `suggestedPrice` siempre con `PricingService.calculate(...).totalEstimate()`
> a partir de origen/destino/peso/tipo de carga (ya obligatorios en el DTO), y el campo
> `suggestedPrice` se eliminó de `CreateShipmentRequestRequest`/`UpdateShipmentRequestRequest` —
> ya no es posible que `suggested_price` llegue NULL ni que el cliente lo fije directamente. Como
> efecto, la subasta ahora se abre siempre e incondicionalmente al publicar (antes dependía de que
> el cliente enviara el campo), lo cual además corrige de paso una lectura literal más estricta de
> RF15. Ver detalle en `ROADMAP.md`, Módulo 6.
>
> **Nota sobre HLZ-001:** sigue sin corregirse (no se cachea `weight_kg` en `auctions`). El riesgo
> es menor de lo que parece porque `ShipmentRequest.assertEditable()` solo permite `PATCH` mientras
> `status='open'`, y desde la corrección de HLZ-003 toda solicitud pasa a `auction_open` de forma
> inmediata e incondicional al crearse — en la práctica ya no queda ventana para editar `weightKg`
> con una subasta abierta usando el flujo normal de creación. Se mantiene el hallazgo abierto por
> disciplina (no se verificó exhaustivamente que no haya otro camino de código que reabra ese
> estado), pero el escenario que lo originaba dejó de ser alcanzable en el flujo estándar.

**Plan de corrección:**

| ID | Corrección propuesta | Sprint |
|----|---------------------|--------|
| HLZ-001 | Cachear `weight_kg` al momento de crear la subasta (snapshot en tabla auctions) | S3 |
| HLZ-002 | Agregar constraint `UNIQUE (carrier_org_id, vehicle_id, request_ids)` en `smart_load_suggestions` y verificar antes de insertar | S7 |
| HLZ-003 | ~~Bloquear apertura de subasta si `suggested_price IS NULL`. Forzar cálculo de costos antes de publicar solicitud.~~ ✅ Corregido 2026-07-06 (ver arriba) | S2 (aplicado fuera de sprint) |

---

### 2.2 Rendimiento y Eficiencia

| Característica | Objetivo | Medición | Estado |
|---------------|---------|----------|--------|
| **Tiempo de respuesta API (95th pct)** | < 2.0 s | k6 load test | Pendiente |
| **Tiempo marketplace (listado cargas)** | < 1.5 s | k6 load test | Pendiente |
| **Throughput bajo carga** | ≥ 100 req/s | k6 load test | Pendiente |
| **Disponibilidad** | ≥ 99.0% | Uptime monitor | Pendiente |
| **Tiempo de respuesta chat (WebSocket)** | < 200 ms | Test manual | Pendiente |

**Plan de prueba de carga con k6:**

```javascript
// k6-load-test.js — Prueba de carga básica para el marketplace
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 50  },   // Ramp-up a 50 usuarios
    { duration: '3m', target: 100 },   // Sostener 100 usuarios
    { duration: '1m', target: 0   },   // Ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],   // 95% de requests < 2s
    http_req_failed:   ['rate<0.01'],    // < 1% de errores
  },
};

export default function () {
  const token = __ENV.TEST_TOKEN;

  // Simular PYME revisando el marketplace (carga más frecuente)
  const res = http.get(
    `${__ENV.BASE_URL}/api/v1/shipment-requests?status=open`,
    { headers: { Authorization: `Bearer ${token}` } }
  );

  check(res, {
    'status es 200':         (r) => r.status === 200,
    'respuesta en < 2s':     (r) => r.timings.duration < 2000,
    'lista no está vacía':   (r) => JSON.parse(r.body).data.length >= 0,
  });

  sleep(1);
}
```

**Optimizaciones previstas:**

| Optimización | Impacto esperado | Sprint |
|-------------|-----------------|--------|
| Índice compuesto `(status, required_date)` en `shipment_requests` | -40% tiempo del marketplace | S1 (ya incluido en V6) |
| Caché Redis para el ranking del marketplace (TTL: 60s) | -60% carga en BD en horas pico | S7 |
| PgBouncer en modo transaction (pool 20 conexiones) | Soportar 200 conexiones concurrentes | S8 |
| Índice parcial `WHERE status IN ('open','filling')` en `carrier_trips` | -70% tiempo de búsqueda de viajes | S1 (ya incluido en V6) |

---

### 2.3 Seguridad

| Característica | Control implementado | Estado | Verificación |
|---------------|---------------------|--------|-------------|
| **Autenticación** | JWT HS256, expiración 1h | Implementado en diseño | TC-AUTH-01 a 03 |
| **Autorización** | RBAC con @RolesAllowed + RLS PostgreSQL | RBAC ✅ implementado (`SecurityContext`, verificado en ROADMAP.md módulo por módulo) · RLS ⬜ no implementado (ver SEC-005) | Prueba manual por rol |
| **Cifrado contraseñas** | bcrypt cost=12 | Implementado en diseño | Verificar hash en BD |
| **Protección XSS** | Angular escapa por defecto | Framework | — |
| **Protección SQL injection** | Panache usa parámetros preparados | Framework | — |
| **TLS en tránsito** | TLS 1.3 (configurado en Nginx) | Diseñado | SSL Labs test |
| **Validación de entrada** | @Valid en todos los DTOs | Pendiente implementar | — |
| **Escaneo de dependencias** | OWASP Dependency Check (semanal) | Diseñado en CI | — |
| **Moderación de mensajes** | fn_contains_contact_info (trigger) | Implementado en diseño | TC-MOD-01 a 03 |
| **Auditoría de BD** | Trigger audit_log en tablas críticas | Parcial: 4/6 tablas (`shipments`, `bids`, `auctions`, `incidents`) — faltan `organizations`/`profiles` (ver SEC-006) | Verificar logs |

**Hallazgos de seguridad identificados:**

| ID | Hallazgo | Severidad | Recomendación |
|----|---------|-----------|---------------|
| SEC-001 | El endpoint `POST /api/v1/auth/register` no tiene rate limiting. Un atacante puede registrar miles de organizaciones falsas. | Alta | Implementar rate limiting (Quarkus Fault Tolerance: @RateLimited) |
| SEC-002 | Las URLs presignadas de MinIO (7 días) son muy largas para documentos sensibles. | Media | Reducir expiración a 24h y regenerar si el usuario vuelve a pedir |
| SEC-003 | El campo `org_type` puede ser cambiado manualmente en la BD. Un carrier podría convertirse en operator. | Media | Agregar trigger que audite y bloquee cambios de `org_type` después del onboarding |
| SEC-004 | No hay límite de intentos fallidos de login (brute force). | Alta | Implementar bloqueo temporal (5 intentos → 15 min de espera) con Redis |
| SEC-005 *(agregado 2026-07-06, verificado contra el código)* | Row-Level Security (`E2_Seguridad.md` sección 2.3) está completamente diseñado pero no implementado: ninguna migración habilita RLS ni crea las políticas `rls_*`, y el backend nunca ejecuta `SET app.current_org_id`. Hoy el único control de acceso por organización es a nivel de aplicación (filtros en repository/service) — si algún endpoint futuro olvida ese filtro, no hay defensa en profundidad a nivel de BD. | Media | Implementar las políticas RLS de `E2_Seguridad.md` §2.3 antes de producción, o documentar explícitamente que se acepta el riesgo mientras el filtro de aplicación sea la única defensa |
| SEC-006 *(agregado 2026-07-06, verificado contra `V8__triggers.sql`)* | De las 6 tablas que `E2_Seguridad.md` §4.1 documenta como auditadas, solo 4 tienen trigger real (`trg_audit_shipments/bids/auctions/incidents`). Cambios de `organizations.verified` y `profiles.role` — ambos catalogados como "críticos" en el mismo documento y cubiertos por RNF15 — no quedan en `audit_log`. | Media | Agregar `trg_audit_organizations` y `trg_audit_profiles` (mismo patrón que los 4 existentes) |

**Plan de mitigación:**

| ID | Corrección | Sprint |
|----|-----------|--------|
| SEC-001 | `@RateLimited(value = 10, window = 1, windowUnit = MINUTES)` en AuthResource | S1 |
| SEC-002 | Cambiar expiración de URLs a 24h en MinIOStorageService | S6 |
| SEC-003 | Trigger `trg_prevent_org_type_change` | S1 |
| SEC-004 | Redis counter + TTL para intentos fallidos por email | S2 |
| SEC-005 | Implementar políticas RLS de `E2_Seguridad.md` §2.3 (`shipment_requests`, `messages`) + `SET app.current_org_id` por request | S6 (junto con hardening pre-producción) |
| SEC-006 | Agregar `trg_audit_organizations` y `trg_audit_profiles` en una nueva migración | S1 (bajo costo, mismo patrón ya existente) |

---

### 2.4 Mantenibilidad

| Característica | Evaluación | Estado |
|---------------|-----------|--------|
| **Modularidad** | 14 módulos independientes en Quarkus | Correcto |
| **Documentación de código** | Javadoc en clases de servicio, anotaciones @DisplayName en tests | Pendiente |
| **Convenciones** | Conventional Commits + Checkstyle | Definido en CI |
| **Cobertura de pruebas** | Objetivo ≥ 70% | Pendiente |
| **Deuda técnica conocida** | Ver tabla de deuda técnica | — |

**Deuda técnica identificada:**

| ID | Deuda | Prioridad | Sprint de resolución |
|----|-------|-----------|---------------------|
| DT-001 | El `MatchingEngine` (ranking de cargas para carrier) tiene la lógica de puntuación hardcodeada en el servicio. Debería ser configurable por el operador. | Media | S7 |
| DT-002 | Los multiplicadores de cargo_type en PricingService son constantes en código. Deberían estar en una tabla de configuración. | Baja | S8 (backlog) |
| DT-003 | Los módulos `notification` y `tracking` están acoplados directamente. Deberían comunicarse mediante eventos internos (CDI Events en Quarkus). | Media | S6 |
| DT-004 | No hay paginación implementada en el endpoint de marketplace. Con muchas solicitudes, la respuesta puede volverse lenta. | Alta | S3 |

---

### 2.5 Portabilidad y Despliegue

| Característica | Estado | Detalle |
|---------------|--------|---------|
| **Containerización** | Docker + Docker Compose | Definido en E3_Sistema.md |
| **Independencia de infraestructura** | MinIO (S3-compatible) en dev → S3 en prod | Storage intercambiable por config |
| **Scripts de migración** | Flyway V1–V9 | Reproducible en cualquier PG 16 |
| **Variables de entorno** | Todas en `.env` (nunca en código) | Definido en E3 sección 7.4 |
| **Compatibilidad Android** | Android 10+ (API 29) | Definido en RNF-07 (E1_SRS.md) |
| **Compatibilidad iOS** | iOS 16+ | Definido en RNF-15 (E1_SRS.md) |
| **Compatibilidad web** | Chrome, Firefox, Edge 120+ | Definido en RNF-10 (E1_SRS.md) |

---

## 3. Métricas del Sistema

### 3.1 Métricas de Calidad de Código

| Métrica | Herramienta | Objetivo | Valor actual |
|---------|------------|---------|--------------|
| Cobertura de pruebas (backend) | JaCoCo | ≥ 70% | Pendiente |
| Cobertura de pruebas (Flutter) | flutter_test coverage | ≥ 60% | Pendiente |
| Complejidad ciclomática promedio | PMD / SonarLint | < 10 | Pendiente |
| Duplicación de código | SonarLint | < 3% | Pendiente |
| Deuda técnica estimada | SonarLint | < 2 días | Pendiente |
| Vulnerabilidades conocidas (OWASP) | Dependency Check | 0 críticas | Pendiente |

### 3.2 Métricas de Rendimiento en Producción

| Métrica | Objetivo | Herramienta de medición |
|---------|---------|------------------------|
| Uptime mensual | ≥ 99.0% | UptimeRobot / Grafana |
| P95 tiempo de respuesta | < 2.0 s | k6 + Grafana |
| Error rate (HTTP 5xx) | < 0.5% | Nginx logs / Grafana |
| Mensajes de chat entregados en < 300ms | ≥ 99% | WebSocket ping metrics |

### 3.3 Métricas de Negocio (KPIs del MVP)

| Métrica | Objetivo mes 1 | Objetivo mes 3 |
|---------|---------------|----------------|
| Organizaciones registradas | ≥ 20 | ≥ 100 |
| Solicitudes publicadas | ≥ 50 | ≥ 300 |
| Ofertas enviadas | ≥ 150 | ≥ 900 |
| Tasa de match (solicitud → envío) | ≥ 60% | ≥ 75% |
| NPS del sistema | — | ≥ 40 |

---

## 4. Plan de Mejora y Evolución

### Fase 1 — Correcciones pre-lanzamiento (Sprint 8)

| Mejora | Descripción | Responsable |
|--------|-------------|-------------|
| ~~Corrección HLZ-003~~ | ~~Bloquear subasta si no hay precio calculado~~ ✅ Corregido 2026-07-06 (sección 2.1) | Jorge |
| Mitigación SEC-001 y SEC-004 | Rate limiting y bloqueo de brute force | Fabrizio |
| Corrección DT-004 | Paginación en marketplace | Jorge |
| Implementar SonarLint en CI | Calidad de código automatizada | Alex |

### Fase 2 — Evolución del producto (meses 5–8)

| Mejora | Justificación | Prioridad |
|--------|--------------|-----------|
| Escrow de pagos con Culqi/PayU | Completar ciclo económico dentro de la plataforma | Alta |
| Google OAuth completo | Reducir fricción de registro | Alta |
| Push notifications (FCM) | Mejorar tiempo de respuesta a ofertas | Alta |
| Lazy extraction de módulos a microservicios | `smartload` y `pricing` son candidatos para escalar independientemente | Media |
| ML para pricing dinámico | Reemplazar reglas fijas con modelo predictivo (historial de precios) | Baja |
| Rastreo GPS en tiempo real | Integrar posición del conductor cada 30s en mapa de tracking | Media |
| Red Cooperativa de PYMEs | Módulo de grupos PYME que negocian como bloque | Baja |

### Fase 3 — Escala y expansión (año 2)

| Iniciativa | Descripción |
|-----------|-------------|
| Expansión geográfica | Añadir corredores: Lima-Cusco, Lima-Trujillo, Lima-Iquitos |
| Marketplace de seguros | Integrar seguro de carga dentro de la plataforma |
| API pública para ERPs | Permitir que los sistemas de gestión de PYMEs publiquen cargas automáticamente |
| Dashboard de analítica avanzada | Business intelligence para carriers (ocupación, rentabilidad por ruta) |

---

## 5. Conclusiones de la Auditoría

| Área | Calificación | Resumen |
|------|-------------|---------|
| **Funcionalidad** | ★★★★☆ | 67 de 67 RF documentados y trazados. 3 hallazgos de diseño identificados y con plan de corrección. |
| **Rendimiento** | ★★★☆☆ | Índices definidos, configuración de PG optimizada, pruebas de carga pendientes de ejecutar. |
| **Seguridad** | ★★★☆☆ | Base sólida (JWT, bcrypt, TLS, RLS). 4 hallazgos identificados con plan de mitigación en S1–S6. |
| **Mantenibilidad** | ★★★★☆ | Arquitectura modular, CI/CD con Conventional Commits, cobertura de pruebas pendiente de alcanzar objetivo. |
| **Portabilidad** | ★★★★★ | Docker + Flyway + variables de entorno garantizan reproducibilidad completa. |

**Veredicto:** El sistema LOGYX está correctamente concebido y arquitecturado para su desarrollo. Los hallazgos identificados son abordables dentro del plan de sprints. No existen bloqueadores críticos para el lanzamiento del MVP.

---

*LOGYX · E4 Auditoría Técnica · Competencia CE0244 · Versión 1.0 · Junio 2026*
