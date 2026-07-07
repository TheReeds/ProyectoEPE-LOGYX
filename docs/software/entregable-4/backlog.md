# E4 — Backlog, Historias de Usuario y Sprints
> Competencia CE0243 · Gestión ágil del desarrollo  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Versión: 1.0 · Junio 2026

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Metodología** | Scrum (adaptado a equipo de 3 personas) |
| **Duración de Sprint** | 2 semanas |
| **Total de sprints planificados** | 8 sprints (16 semanas ≈ 4 meses de desarrollo) |
| **Herramienta de backlog** | GitHub Projects (Kanban board) *(agregar link)* |
| **Definition of Done** | Código commiteado + tests escritos + CI pasando + documentación actualizada |

---

## 2. Actores y Roles

| Actor | Rol en el sistema |
|-------|-------------------|
| PYME | Publica cargas, negocia, da seguimiento |
| Transportista (Carrier) | Oferta cargas, publica viajes, gestiona flota |
| Conductor (Driver) | Ejecuta la ruta, confirma entregas |
| Operador | Supervisa, asigna manualmente, resuelve incidencias |

---

## 3. Épicas del Producto

*Nota de trazabilidad: esta tabla es el **backlog de ejecución**, actualizado durante los sprints. El cronograma **base (baseline)** planificado antes del inicio del proyecto se documenta en Gestión TI, Entregable 3, secciones 3.3 (Gestión del Cronograma) y 3.6.4 (evidencia de configuración en Azure DevOps); las variaciones puntuales entre ambos (p. ej. EP-03, EP-04, EP-06, EP-10) reflejan la re-priorización normal de Scrum durante la ejecución frente al plan predictivo inicial.*

| ID | Épica | Sprint(s) |
|----|-------|-----------|
| EP-01 | Autenticación y gestión de organizaciones | S1 |
| EP-02 | Marketplace y subasta inversa | S2–S3 |
| EP-03 | Publicación de viajes (supply-side) | S3 |
| EP-04 | Negociación bidireccional y chat | S3–S4 |
| EP-05 | Motor de costos y rutas | S2 |
| EP-06 | Tracking multi-parada | S4–S5 |
| EP-07 | App del conductor (Driver) | S5 |
| EP-08 | Sistema de reputación y calificaciones | S5–S6 |
| EP-09 | Gestión documental | S6 |
| EP-10 | Notificaciones y alertas | S4 |
| EP-11 | Gestión de incidencias | S6 |
| EP-12 | Panel del operador | S6–S7 |
| EP-13 | Smart Load Planner | S7 |
| EP-14 | Cargas de retorno | S7 |
| EP-15 | Gestión de flota | S2 |
| EP-16 | Despliegue y CI/CD | S1 + S8 |

---

## 4. Product Backlog — Historias de Usuario

### EP-01: Autenticación

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-001 | **Como** usuario nuevo, **quiero** registrarme con mi email y RUC de empresa, **para** acceder al sistema | RUC validado con 11 dígitos · Contraseña mínimo 8 chars · Email único en el sistema · Score de reputación inicializado en 75 | Alta | 5 |
| HU-002 | **Como** usuario registrado, **quiero** iniciar sesión con email y contraseña, **para** acceder a mi cuenta | JWT emitido con expiración 1h · Refresh token 7d · 401 si credenciales incorrectas | Alta | 3 |
| HU-003 | **Como** usuario, **quiero** iniciar sesión con Google, **para** no recordar otra contraseña | OAuth2 con cuenta Google · Perfil creado si es primera vez | Media | 5 |
| HU-004 | **Como** admin de organización, **quiero** gestionar los roles de mi equipo, **para** dar acceso adecuado a cada persona | Roles: admin, ops, viewer, driver · Solo admin puede cambiar roles | Media | 3 |

### EP-02: Marketplace y Subasta

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-010 | **Como** PYME, **quiero** publicar una solicitud de carga con origen, destino y peso, **para** recibir cotizaciones | Cálculo de precio sugerido y price_floor automático · Subasta abierta 20 min o 5 ofertas | Alta | 8 |
| HU-011 | **Como** transportista, **quiero** ver el marketplace de cargas disponibles filtrado por mi ruta habitual, **para** encontrar cargas compatibles con mis viajes | Lista rankeada por DistanceFit + Reputation · Filtros por ruta, peso, fecha | Alta | 8 |
| HU-012 | **Como** transportista, **quiero** enviar una oferta con mi precio y vehículo seleccionado, **para** competir por la carga | Precio ≥ price_floor · Vehículo con capacidad disponible · Un bid por subasta | Alta | 5 |
| HU-013 | **Como** PYME, **quiero** ver las ofertas recibidas con el Trust Score del transportista, **para** tomar una decisión informada | Nombre del carrier ofuscado hasta aceptar · Trust Score y badge visible · Botones Aceptar/Negociar/Rechazar | Alta | 5 |
| HU-014 | **Como** PYME, **quiero** aceptar una oferta, **para** contratar el servicio y generar el envío | Shipment creado con tracking code · Bid → ACCEPTED · Otros bids → REJECTED · Notificación al carrier | Alta | 5 |

### EP-03: Publicación de Viajes (Supply-side)

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-020 | **Como** transportista, **quiero** publicar un viaje con fecha y capacidad disponible, **para** que PYMEs puedan reservar espacio | Fecha de salida futura · Capacidad en kg y m³ · Precio por kg definido | Alta | 5 |
| HU-021 | **Como** PYME, **quiero** ver viajes disponibles que pasen cerca de mi origen y destino, **para** unirme en el último momento | Lista filtrada por ruta compatible · Capacidad disponible visible | Alta | 5 |
| HU-022 | **Como** PYME, **quiero** reservar espacio en un viaje disponible, **para** asegurar el servicio sin pasar por subasta | Capacidad actualizada en vehículo · Notificación al carrier | Alta | 3 |

### EP-04: Negociación Bidireccional

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-030 | **Como** PYME o transportista, **quiero** enviar mensajes en un hilo privado por solicitud, **para** negociar condiciones del servicio | Hilo separado por (solicitud × carrier) · WebSocket en tiempo real | Alta | 8 |
| HU-031 | **Como** PYME, **quiero** proponer un contra-precio en el chat, **para** negociar sin salir de la plataforma | Campo de precio en el mensaje · Botón "Aceptar precio" para el otro actor | Alta | 5 |
| HU-032 | **Como** sistema, **quiero** bloquear automáticamente mensajes con teléfonos, emails o handles de redes, **para** evitar la desintermediación | Regex detecta 9 dígitos, @handles, emails · Mensaje reemplazado con aviso | Alta | 3 |

### EP-05: Motor de Costos

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-040 | **Como** PYME, **quiero** ver un desglose de costos (flete, combustible, peajes, manipuleo) antes de publicar la solicitud, **para** establecer un presupuesto realista | Integración con ORS para distancia real · Desglose visible en paso 3 del formulario | Alta | 8 |
| HU-041 | **Como** PYME, **quiero** acceder al cotizador sin publicar una solicitud, **para** evaluar rutas antes de comprometerse | Formulario separado con origen, destino, peso, tipo de carga | Media | 3 |

### EP-06: Tracking Multi-Parada

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-050 | **Como** PYME, **quiero** ver el estado de mi envío en tiempo real con un mapa y timeline, **para** saber dónde está mi carga | Estados: pending → picked_up → in_transit → delivered · Mapa con ruta | Alta | 8 |
| HU-051 | **Como** PYME, **quiero** ver el estado de cada parada del envío con ETA y foto de evidencia, **para** confirmar entregas parciales | ETA por parada · Foto de entrega visible post-confirmación | Alta | 5 |
| HU-052 | **Como** carrier, **quiero** asignar un conductor a un envío, **para** que el driver pueda ejecutar la ruta desde su app | Selector de conductores activos · Notificación push al conductor | Alta | 3 |

### EP-07: App del Conductor

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-060 | **Como** conductor, **quiero** ver la lista de paradas ordenadas de mi ruta activa, **para** saber dónde ir en cada momento | Paradas ordenadas por sequence · ETA de cada una · Estado actual | Alta | 5 |
| HU-061 | **Como** conductor, **quiero** confirmar la entrega tomando una foto y la firma del receptor, **para** acreditar la entrega | Upload de foto a MinIO · Captura de firma en pantalla · Estado de parada → delivered | Alta | 8 |
| HU-062 | **Como** conductor, **quiero** que la app funcione sin conexión a internet guardando la ruta en caché, **para** operar en zonas sin señal | Ruta cacheada en SQLite (Drift) · Estados actualizados offline · Sincronización al recuperar conexión | Alta | 8 |
| HU-063 | **Como** conductor, **quiero** reportar una incidencia desde la app, **para** comunicar un problema al operador inmediatamente | Categorías de incidencia · Foto del problema · Estado del envío bloqueado hasta resolución | Alta | 5 |

### EP-08: Reputación

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-070 | **Como** PYME, **quiero** calificar al transportista después de cada entrega, **para** contribuir a la transparencia del sistema | Calificación 1-5 estrellas · Calificación de puntualidad · Comentario opcional | Alta | 5 |
| HU-071 | **Como** transportista, **quiero** calificar a la PYME después de cada envío, **para** registrar su comportamiento como cliente | Mismos campos de calificación | Alta | 3 |
| HU-072 | **Como** cualquier usuario, **quiero** ver el Trust Score y las métricas de reputación de un actor antes de contratar, **para** tomar decisiones informadas | Score compuesto 0-100 · Desglose: tasa éxito, puntualidad, cancela., rating | Alta | 5 |

### EP-09: Documentos

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-080 | **Como** PYME o transportista, **quiero** descargar los documentos de mis envíos (órdenes, guías, recibos), **para** mantener mis registros | Lista filtrable por tipo y envío · URL presignada con expiración 7d | Media | 3 |
| HU-081 | **Como** conductor, **quiero** que las fotos y firmas de entrega se generen como documentos del envío, **para** tener trazabilidad legal | Tipo delivery_photo y signature automáticamente | Alta | 3 |

### EP-10: Notificaciones

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-090 | **Como** usuario, **quiero** recibir notificaciones in-app cuando haya novedades importantes, **para** no perder actualizaciones | Feed de notificaciones ordenado · Badge con contador de no leídas · Marcar como leída | Alta | 5 |
| HU-091 | **Como** PYME, **quiero** recibir notificación cuando llegue una nueva oferta para mi solicitud, **para** responder rápidamente | Notificación tipo new_bid · Enlace directo al panel de ofertas | Alta | 3 |

### EP-11: Incidencias

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-100 | **Como** PYME, **quiero** reportar una incidencia en mi envío, **para** solicitar intervención del operador | Categorías predefinidas · Estado del envío cambia a 'issue' · Hilo de comentarios | Alta | 5 |
| HU-101 | **Como** operador, **quiero** gestionar y resolver incidencias abiertas, **para** garantizar la calidad del servicio | Lista de incidencias por prioridad · Actualizar estado · Agregar notas de resolución | Alta | 5 |

### EP-12: Panel del Operador

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-110 | **Como** operador, **quiero** ver las solicitudes que llevan más de 24h sin ofertas, **para** intervenir manualmente | Lista priorizada por tiempo · Badge de urgencia | Alta | 5 |
| HU-111 | **Como** operador, **quiero** asignar manualmente un transportista a una solicitud sin ofertas, **para** garantizar el SLA | Selector de carriers disponibles con Trust Score · Precio definible | Alta | 5 |

### EP-13 y EP-14: Smart Load y Retorno

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-120 | **Como** transportista, **quiero** recibir sugerencias de combinaciones de carga compatibles con mi vehículo, **para** maximizar ingresos | Scheduler cada 30 min · Combinaciones con >60% ocupación · Notificación con ingreso estimado | Media | 13 |
| HU-121 | **Como** transportista, **quiero** ver cargas disponibles cerca de mi destino final, **para** no regresar vacío | Cargas dentro de 80 km del destino · Ordenadas por compatibilidad | Media | 8 |

### EP-15: Gestión de Flota

| ID | Historia de Usuario | Criterios de Aceptación | Prioridad | Puntos |
|----|---------------------|------------------------|-----------|--------|
| HU-130 | **Como** transportista, **quiero** registrar mis vehículos con placa, tipo y capacidad, **para** poder ofertar cargas | Datos de vehículo validados · Placa única en el sistema | Alta | 3 |
| HU-131 | **Como** transportista, **quiero** registrar mis conductores con DNI y licencia, **para** asignarlos a envíos | DNI único · Número de licencia único | Alta | 3 |

---

## 5. Planificación de Sprints

### Sprint 1 — Infraestructura y Auth (Semanas 1–2)

**Objetivo:** Tener el proyecto configurado, CI/CD corriendo y autenticación funcional.

| HU | Descripción | Responsable | Estado |
|----|-------------|-------------|--------|
| — | Setup repositorio GitHub + ramas + protecciones | Jorge | Pendiente |
| — | Docker Compose completo (PG, Redis, MinIO, backend) | Alex | Pendiente |
| — | GitHub Actions CI básico (build + test) | Fabrizio | Pendiente |
| — | Flyway migrations V1–V3 | Alex | Pendiente |
| HU-001 | Registro de organización | Jorge | Pendiente |
| HU-002 | Login con JWT | Jorge | Pendiente |
| HU-004 | RBAC por rol | Fabrizio | Pendiente |

**Velocidad objetivo:** 30 puntos

---

### Sprint 2 — Motor de costos, Flota y Marketplace base (Semanas 3–4)

**Objetivo:** PYME puede publicar solicitud con cotización. Carrier puede ver solicitudes.

| HU | Descripción | Responsable | Estado |
|----|-------------|-------------|--------|
| HU-040 | Motor de costos + integración ORS | Jorge | Pendiente |
| HU-041 | Cotizador standalone | Jorge | Pendiente |
| HU-130 | Registro de vehículos | Alex | Pendiente |
| HU-131 | Registro de conductores | Alex | Pendiente |
| HU-010 | Publicar solicitud (frontend Angular) | Fabrizio | Pendiente |
| HU-011 | Marketplace para carrier | Fabrizio | Pendiente |

**Velocidad objetivo:** 35 puntos

---

### Sprint 3 — Subasta inversa y Viajes disponibles (Semanas 5–6)

**Objetivo:** El ciclo completo de subasta (oferta → aceptación → envío creado).

| HU | Descripción | Responsable | Estado |
|----|-------------|-------------|--------|
| HU-012 | Enviar oferta (carrier) | Jorge | Pendiente |
| HU-013 | Ver y gestionar ofertas (PYME) | Jorge | Pendiente |
| HU-014 | Aceptar oferta + crear envío | Jorge | Pendiente |
| HU-020 | Publicar viaje disponible | Alex | Pendiente |
| HU-021 | Ver viajes (PYME) | Alex | Pendiente |
| HU-022 | Reservar espacio en viaje | Alex | Pendiente |
| HU-090 | Notificaciones in-app (base) | Fabrizio | Pendiente |

**Velocidad objetivo:** 37 puntos

---

### Sprint 4 — Chat, Negociación y Notificaciones (Semanas 7–8)

**Objetivo:** Negociación en tiempo real funcionando.

| HU | Descripción | Responsable | Estado |
|----|-------------|-------------|--------|
| HU-030 | Chat en tiempo real (WebSocket) | Jorge | Pendiente |
| HU-031 | Contra-oferta en chat | Jorge | Pendiente |
| HU-032 | Moderación de mensajes | Alex | Pendiente |
| HU-091 | Notificación de nueva oferta | Fabrizio | Pendiente |
| — | Flyway migrations V4–V6 | Alex | Pendiente |

**Velocidad objetivo:** 32 puntos

---

### Sprint 5 — Tracking y App Driver (Semanas 9–10)

**Objetivo:** El conductor puede ejecutar una ruta completa desde la app.

| HU | Descripción | Responsable | Estado |
|----|-------------|-------------|--------|
| HU-050 | Tracking en tiempo real (Angular + Flutter) | Fabrizio | Pendiente |
| HU-051 | Detalle de paradas con ETA y fotos | Fabrizio | Pendiente |
| HU-052 | Asignación de conductor a envío | Jorge | Pendiente |
| HU-060 | Lista de paradas (Driver app) | Alex | Pendiente |
| HU-061 | Confirmar entrega foto+firma | Alex | Pendiente |
| HU-062 | Modo offline (Driver app) | Alex | Pendiente |

**Velocidad objetivo:** 37 puntos

---

### Sprint 6 — Reputación, Incidencias y Documentos (Semanas 11–12)

**Objetivo:** Sistema completo de calidad post-servicio.

| HU | Descripción | Responsable | Estado |
|----|-------------|-------------|--------|
| HU-070 | Calificación post-entrega (PYME) | Jorge | Pendiente |
| HU-071 | Calificación post-entrega (Carrier) | Jorge | Pendiente |
| HU-072 | Pantalla de reputación pública | Fabrizio | Pendiente |
| HU-063 | Reporte de incidencia (Driver) | Alex | Pendiente |
| HU-100 | Reporte de incidencia (PYME/Carrier) | Alex | Pendiente |
| HU-101 | Gestión de incidencias (Operador) | Fabrizio | Pendiente |
| HU-080 | Descarga de documentos | Alex | Pendiente |
| HU-081 | Documentos automáticos por entrega | Alex | Pendiente |

**Velocidad objetivo:** 39 puntos

---

### Sprint 7 — Panel Operador, Smart Load y Retorno (Semanas 13–14)

**Objetivo:** Herramientas avanzadas para optimización logística.

| HU | Descripción | Responsable | Estado |
|----|-------------|-------------|--------|
| HU-110 | Solicitudes en riesgo SLA | Jorge | Pendiente |
| HU-111 | Asignación manual por operador | Jorge | Pendiente |
| HU-120 | Smart Load Planner (scheduler) | Alex | Pendiente |
| HU-121 | Cargas de retorno | Alex | Pendiente |
| — | Flyway migrations V7–V9 | Alex | Pendiente |
| — | Panel general de envíos (Operador) | Fabrizio | Pendiente |

**Velocidad objetivo:** 44 puntos

---

### Sprint 8 — Pruebas, Hardening y Deploy (Semanas 15–16)

**Objetivo:** Sistema validado, seguro y desplegado en producción.

| Tarea | Responsable | Estado |
|-------|-------------|--------|
| Suite de tests completa (JUnit + Cypress + flutter_test) | Jorge + Fabrizio | Pendiente |
| Cobertura ≥ 70% en módulos críticos | Jorge | Pendiente |
| Pipeline CI/CD completo con deploy staging | Alex | Pendiente |
| Revisión de seguridad (OWASP + roles BD) | Alex | Pendiente |
| Informe de auditoría (E4_Auditoria.md) | Fabrizio | Pendiente |
| E5 Sustentación — preparación pitch + demo | Todos | Pendiente |
| Deploy producción | Jorge | Pendiente |

**Velocidad objetivo:** 40 puntos

---

## 6. Velocidad y Burndown del Equipo

| Sprint | Puntos planificados | Puntos completados | Velocidad real |
|--------|--------------------|--------------------|----------------|
| S1 | 30 | — | Pendiente |
| S2 | 35 | — | Pendiente |
| S3 | 37 | — | Pendiente |
| S4 | 32 | — | Pendiente |
| S5 | 37 | — | Pendiente |
| S6 | 39 | — | Pendiente |
| S7 | 44 | — | Pendiente |
| S8 | 40 | — | Pendiente |
| **Total** | **294** | — | — |

---

## 7. Evidencia de Sprints

| Item | Estado |
|------|--------|
| GitHub Projects con tablero Kanban | Pendiente — agregar link |
| Capturas del tablero al final de cada sprint | Pendiente |
| Commits con conventional commits messages | Pendiente |
| Pull Requests mergeados con CI pasando | Pendiente |
| Sprint retrospectives (breves, en GitHub Discussions) | Pendiente |

---

*LOGYX · E4 Backlog y Sprints · Competencia CE0243 · Versión 1.0 · Junio 2026*
