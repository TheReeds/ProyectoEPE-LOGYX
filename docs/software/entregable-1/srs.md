# E1 — Especificación de Requerimientos del Sistema (SRS)
> Estándar: IEEE 29148 · Competencia CE0211  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Institución: Universidad Peruana Unión · Ingeniería de Sistemas  
> Versión: 1.1 (revisada con el sistema implementado) · Noviembre 2026 · Versión original 1.0, junio 2026

!!! info "Estado de la especificación frente al sistema construido"
    Los requerimientos (RF, RNF, RN) se conservan tal como se especificaron en la v1.0; en la v1.1 cada uno lleva una columna de **estado y módulo de código** que indica si quedó implementado, parcial o fuera del MVP. Resumen: de los 67 RF, **51 están implementados, 13 parciales** y **3 no implementados** (RF06 Google OAuth, RF50 email, RF59 Smart Load en el panel del operador); **RN01–RN12 implementadas en su totalidad**. Las restricciones técnicas RT02 y RT03 cambiaron (Astro y Kotlin/Compose); ver [Cambios respecto al diseño inicial](../cambios-diseno-inicial.md) y los ADR de [Arquitectura](arquitectura.md). La fuente de verdad del estado de cada módulo es `docs/STATUS.md` del repositorio del sistema.

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Nombre del sistema** | OnCargo |
| **Tipo** | Sistema empresarial web con extensión móvil |
| **Tipo de entregable** | EPE — Evaluación del Perfil de Egreso |
| **Curso / Línea** | Ingeniería de Software |
| **Equipo** | Jorge Gutiérrez Miranda, Fabrizio Sanchez Saravia, Alex Coila Jarita |
| **Versión del documento** | 1.1 (v1.0 de junio 2026 revisada contra el sistema construido) |
| **Fecha** | Noviembre 2026 |

---

## 2. Descripción del Problema

### 2.1 Situación Actual

Las pequeñas y medianas empresas (PYMEs) en el Perú gestionan su logística de carga mediante canales informales: llamadas telefónicas, grupos de WhatsApp, hojas de cálculo y acuerdos verbales con transportistas. No existe un mecanismo estandarizado, trazable ni seguro para contratar transporte de carga en corredores interprovinciales.

En el corredor Lima–Sierra Sur (Lima–Arequipa–Juliaca–Puno), uno de los más activos del país, esta problemática es especialmente crítica: las PYMEs no conocen el precio justo de mercado antes de negociar, no tienen forma de verificar la confiabilidad de un transportista antes de entregarle mercancía, y los transportistas regresan con sus vehículos vacíos después de cada entrega, elevando el costo logístico para todos.

### 2.2 Problema Identificado

La fragmentación del ecosistema logístico PYME genera cinco problemas estructurales:

| # | Problema | Manifestación |
|---|----------|--------------|
| P1 | Opacidad de precios | Las PYMEs no conocen el precio de mercado; negocian sin referencia |
| P2 | Falta de confianza verificable | No existe historial ni reputación accesible de transportistas |
| P3 | Baja utilización de flota | Los vehículos retornan vacíos el 40–70% del tiempo |
| P4 | Ineficiencia operativa | Coordinación por WhatsApp genera errores, reprocesos y pérdida de documentos |
| P5 | Poder de negociación desigual | Las PYMEs individualmente obtienen tarifas hasta 60% más altas que una empresa grande |

### 2.3 Impacto en el Negocio

- Sobrecosto logístico del 20–60% respecto a empresas de mayor escala
- Pérdida de mercancía o daños sin mecanismo de reclamación estructurado
- Incumplimientos de plazo sin trazabilidad ni penalización efectiva
- Imposibilidad de planificar costos logísticos con anticipación

---

## 3. Contexto del Sistema

### 3.1 Organización / Entorno

OnCargo opera en el mercado logístico B2B del Perú, con foco inicial en el corredor Lima–Sierra Sur. El sistema digital reemplaza la coordinación informal (WhatsApp, llamadas) con un marketplace estructurado que conecta PYMEs demandantes de transporte con empresas transportistas, bajo supervisión de operadores logísticos.

### 3.2 Usuarios del Sistema

| Actor | Descripción | Canal de acceso |
|-------|-------------|----------------|
| **PYME** | Empresa que necesita contratar transporte de carga | Web (Astro) + app Android (Kotlin) |
| **Empresa Transportista** | Empresa con flota de vehículos que oferta servicios | Web (Astro) + app Android (Kotlin) |
| **Conductor (Driver)** | Persona que ejecuta físicamente la ruta | App Android (modo conductor) |
| **Operador OnCargo** | Supervisor interno con acceso global al sistema | Web (Astro) |
| **Administrador** | Gestión de la plataforma, configuración y moderación | Web (Astro) |

### 3.3 Condiciones de Operación

- Conectividad variable: la app móvil del conductor debe funcionar con conexión intermitente (caché local)
- Dispositivos heterogéneos: Android 10+ para la app móvil
- Operación 24/7: las subastas y el tracking no tienen horario de corte
- Volumen inicial: 50–200 usuarios activos en los primeros 6 meses

---

## 4. Stakeholders

| Stakeholder | Rol | Necesidad Principal |
|-------------|-----|---------------------|
| PYMEs del corredor Lima–Sierra Sur | Usuario principal (demanda) | Contratar transporte confiable a precio justo |
| Empresas transportistas | Usuario principal (oferta) | Maximizar la ocupación de su flota |
| Conductores | Usuario ejecutor | Ver su ruta asignada y actualizar estados fácilmente |
| Operador OnCargo | Supervisor interno | Garantizar SLA y resolver incidencias |
| Dirección del proyecto (equipo) | Desarrolladores / founders | Sistema funcional, escalable y evaluable |
| Jurado EPE | Evaluador académico | Sistema coherente, documentado y demostrable |
| SUNAT (externo) | Ente de validación | Verificación de RUC de empresas registradas |

---

## 5. Objetivo del Sistema

### 5.1 Objetivo General

Desarrollar una plataforma digital B2B que conecte PYMEs y empresas transportistas mediante un sistema de subastas inversas, negociación bidireccional, planificación inteligente de carga y reputación verificable, reduciendo los costos logísticos y la informalidad en el corredor Lima–Sierra Sur del Perú.

### 5.2 Objetivos Específicos

| ID | Objetivo Específico |
|----|---------------------|
| OE01 | Implementar un sistema de registro y verificación de identidad para PYMEs, transportistas y conductores con validación de RUC contra SUNAT |
| OE02 | Desarrollar un marketplace con subasta inversa temporizada donde los transportistas compiten en precio por las solicitudes de carga publicadas |
| OE03 | Implementar un módulo de negociación bidireccional con chat y contra-ofertas entre PYME y transportista |
| OE04 | Construir un motor de costos logísticos que sugiera precios de referencia basados en distancia, peso, tipo de carga y demanda histórica |
| OE05 | Implementar un sistema de tracking multi-parada con actualización de estados desde la app del conductor |
| OE06 | Desarrollar un sistema de reputación compuesto multidimensional (puntualidad, éxito, daños, cancelaciones) |
| OE07 | Implementar un Smart Load Planner que sugiera combinaciones compatibles de cargas para un mismo vehículo y ruta |
| OE08 | Construir un panel de operador con métricas en tiempo real, asignación manual y gestión de incidencias |
| OE09 | Desplegar el sistema en entorno cloud con pipeline CI/CD funcional |

---

## 6. Alcance del Sistema

### 6.1 Incluido en el EPE (alcance de implementación)

- Módulo de autenticación y registro multi-rol
- Verificación de RUC (checksum Módulo 11 + consulta SUNAT)
- Marketplace con subasta inversa y tiempo límite
- Publicación de viajes disponibles por transportistas (supply-side)
- Negociación bidireccional: chat por solicitud + contra-oferta
- Motor de costos basado en reglas (distancia + tarifa por tipo de carga; en el sistema real, distancia por carretera precalculada con OSRM sobre OpenStreetMap, ADR-0008; ORS descartado)
- Gestión de flota y conductores por empresa transportista
- Tracking multi-parada con estados por parada
- App del conductor (vista simplificada: ruta, estados, fotos, firma)
- Sistema de reputación multidimensional (score compuesto)
- Gestión documental por envío (upload/download)
- Notificaciones in-app y email
- Panel del Operador (métricas, asignación manual, incidencias)
- Smart Load Planner básico (compatibilidad por ruta, fecha y capacidad)
- Return Load Marketplace (matching básico por destino)
- Filtro de mensajes anti-contacto (regex)
- Perfiles públicos verificados con badges

!!! note "Estado de implementación del alcance"
    Quedaron fuera del software construido (aunque dentro del alcance planificado): consulta SUNAT, email, inicio de sesión con Google y el filtro de Smart Load en el panel del operador. Ver el estado por requerimiento en la sección 7.

### 6.2 No incluido en el EPE (fases futuras documentadas)

- Route Optimization Engine VRP/TSP (algoritmos de ruteo avanzados)
- Dynamic Pricing Engine con Machine Learning
- Demand Prediction / ETA con modelos predictivos
- Escrow / pagos reales integrados (Culqi, Stripe)
- Red Cooperativa Logística con contratos de volumen
- Fraud Detection con ML
- NLP en moderación de mensajes
- Dispatch Automation
- Servicios financieros (factoring, capital de trabajo)
- Expansión a logística internacional

---

## 7. Requerimientos del Sistema (SRS)

### 7.1 Requerimientos Funcionales

#### Módulo AUTH — Autenticación y Registro

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF01 | El sistema debe permitir el registro de una organización de tipo PYME con nombre, RUC y datos del representante legal | PYME | Implementado · identity · `AuthService.register` |
| RF02 | El sistema debe permitir el registro de una organización de tipo Transportista con nombre, RUC, datos de flota y representante | Transportista | Implementado · identity · registro de organización CARRIER (la flota se da de alta luego en `fleet`) |
| RF03 | El sistema debe permitir el registro de un Conductor vinculado a una empresa transportista, con nombre y número de licencia | Transportista | Implementado · fleet · `drivers` (el transportista crea al conductor) |
| RF04 | El sistema debe validar el RUC ingresado mediante el algoritmo de verificación Módulo 11 y consultar su estado activo en SUNAT | PYME / Transportista | Parcial · identity · `RucValidator` (Módulo 11, verificación `CHECKSUM`); consulta SUNAT pendiente |
| RF05 | El sistema debe permitir inicio de sesión con email y contraseña | Todos | Implementado · identity · `POST /auth/login` (JWT RSA, 8 h) |
| RF06 | El sistema debe permitir inicio de sesión con cuenta Google (OAuth 2.0) | Todos | No implementado · Fuera del MVP: solo email y contraseña |
| RF07 | El sistema debe proteger todas las rutas según el rol del usuario autenticado (RBAC) | Sistema | Implementado · `@RolesAllowed`, middleware web y navegación por rol en Android |
| RF08 | El sistema debe asignar un badge "Verificado" a las organizaciones que completan el proceso de validación de RUC | Sistema | Implementado · `organizations.ruc_verification` + `VerifiedBadge` |

#### Módulo SHIPMENT — Solicitudes de Carga

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF09 | La PYME debe poder crear una solicitud de carga especificando: origen, destino, peso (kg), tipo de carga, fecha requerida y descripción | PYME | Implementado · marketplace · `PublishRequestUseCase` |
| RF10 | Al crear la solicitud, el sistema debe calcular y mostrar un precio de referencia de mercado basado en distancia real por carretera, peso, tipo de carga y tarifas históricas del corredor | Sistema | Parcial · pricing · `TariffCalculator`; distancia por carretera (`RoadDistanceProvider` sobre `RoutePlanner`, dataset OSRM precalculado, ADR-0008); ORS descartado |
| RF11 | La PYME debe poder ver el listado de sus solicitudes activas con estado actual y contador de ofertas recibidas | PYME | Implementado · marketplace · `GET /shipment-requests/mine` |
| RF12 | La PYME debe poder ver el detalle de una solicitud, incluyendo todas las ofertas recibidas con precio, datos del transportista y su score de reputación | PYME | Implementado · marketplace + reputation · `BidView` con Trust Score |
| RF13 | La PYME debe poder aceptar una oferta, lo que genera automáticamente un contrato de envío con código de tracking | PYME | Implementado · marketplace · `AcceptBidUseCase` crea el envío (se identifica por su id; sin formato LGX) |
| RF14 | La PYME debe poder rechazar una oferta individual | PYME | Parcial · Rechazo implícito (RN05) y de contraofertas; sin endpoint de rechazo individual |

#### Módulo AUCTION — Subasta Inversa

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF15 | Al publicarse una solicitud de carga, el sistema debe abrir automáticamente una subasta con tiempo límite configurable (default: 20 minutos) o hasta recibir N ofertas (default: 5) | Sistema | Implementado · marketplace · `Auction`, `AuctionScheduler` |
| RF16 | El transportista debe ver en el marketplace las solicitudes de carga activas filtradas y rankeadas según compatibilidad con su perfil (zona, capacidad, historial de ruta) | Transportista | Parcial · Feed con filtros y chips (Mi vehículo, Mejor pago, Cerca de mí); sin score de matching |
| RF17 | El transportista debe poder enviar una oferta a una subasta activa indicando: precio ofertado, vehículo asignado y notas adicionales | Transportista | Implementado · marketplace · `PlaceBidUseCase` |
| RF18 | El sistema debe cerrar automáticamente la subasta al cumplirse el tiempo o el número máximo de ofertas, notificando a la PYME | Sistema | Implementado · `CloseExpiredAuctionsUseCase` + cierre por MAX_BIDS |
| RF19 | El sistema no debe permitir que un transportista oferte un precio inferior al precio mínimo viable calculado por el motor de precios (price floor) | Sistema | Implementado · RN03 · `BidEligibilityPolicy.ensureAboveFloor` |
| RF20 | El sistema no debe permitir que un transportista oferte si su capacidad disponible real es insuficiente para la carga solicitada | Sistema | Implementado · RN02 · `BidEligibilityPolicy.ensureVehicleEligible` |

#### Módulo TRIP — Viajes Disponibles (Supply-Side)

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF21 | El transportista debe poder publicar un viaje disponible especificando: ruta (origen-destino-paradas), fecha de salida, capacidad disponible (kg/m³) y precio por kg | Transportista | Parcial · trip · `TripService.publish`; sin paradas intermedias ni volumen m³ |
| RF22 | La PYME debe poder explorar los viajes disponibles publicados y reservar espacio en uno de ellos indicando el peso y tipo de su carga | PYME | Implementado · trip · `BookingService.book` |
| RF23 | El sistema debe validar que el peso reservado no exceda la capacidad disponible del viaje en el momento de la reserva | Sistema | Implementado · trip · `TripCapacityPolicy.ensureFits` |
| RF24 | El transportista debe poder ver todas las cargas reservadas en su viaje con detalle de cada una | Transportista | Implementado · trip · `GET /trips/{id}/bookings` |

#### Módulo NEGOTIATION — Negociación Bidireccional

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF25 | El sistema debe proveer un hilo de chat por cada par (solicitud + transportista), visible para ambas partes | PYME / Transportista | Implementado · negotiation · hilos por (solicitud, transportista) |
| RF26 | El transportista debe poder enviar una contra-oferta desde el chat indicando el precio propuesto | Transportista | Implementado · negotiation · `CounterOffer.propose` |
| RF27 | La PYME debe poder enviar una contra-oferta al transportista indicando el precio que está dispuesta a pagar | PYME | Implementado · negotiation · `POST /bids/{id}/counter-offers` |
| RF28 | Cualquiera de las dos partes debe poder aceptar la contra-oferta vigente, actualizando el precio de la oferta automáticamente | PYME / Transportista | Implementado · negotiation · `/counter-offers/{id}/accept` |
| RF29 | El sistema debe detectar y bloquear mensajes que contengan información de contacto (teléfonos, emails, handles de redes sociales) en el chat | Sistema | Implementado · RN07 · `ContactInfoPolicy` |

#### Módulo SMART LOAD PLANNER — Planificación de Carga

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF30 | El sistema debe detectar automáticamente solicitudes de carga compatibles entre sí por criterios de: origen similar (radio 50 km), destino similar (radio 80 km), fechas compatibles (±24h) y peso combinado dentro de la capacidad de un vehículo disponible | Sistema | Implementado · trip · `SmartLoadPlanner` (orígenes ≤ 50 km, destinos ≤ 80 km, ±1 día, ocupación ≥ 60 %) |
| RF31 | El sistema debe mostrar al transportista las combinaciones de carga compatibles como sugerencias de Smart Load Plan, indicando ingreso combinado estimado, porcentaje de ocupación y ruta optimizada | Transportista | Implementado · trip · `smart_load_suggestions`, `GET /smart-loads` |
| RF32 | El transportista debe poder aceptar un Smart Load Plan, lo que genera automáticamente un envío multi-parada con las cargas incluidas | Transportista | Implementado · trip · `SmartLoadService.accept` |
| RF33 | Al ser incluidas en un Smart Load Plan, las PYMEs involucradas deben recibir una notificación indicando que su carga fue agrupada con otras | Sistema | Implementado · notification · observer de `SmartLoadAccepted` |

#### Módulo TRACKING — Seguimiento y Estados

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF34 | Al aceptarse una oferta, el sistema debe generar un código de tracking único para el envío (formato: LGX-XXXXX) | Sistema | Parcial · El envío tiene id único; no se implementó el formato LGX-XXXXX |
| RF35 | El sistema debe permitir registrar múltiples paradas ordenadas para un envío, cada una con: ubicación, ETA estimado y estado | Sistema | Parcial · shipment · `shipment_stops` ordenadas y con estado; sin ETA |
| RF36 | El conductor debe poder actualizar el estado de cada parada desde la app Driver (en_camino, recogido, entregado) | Conductor | Implementado · shipment · `TrackStopsUseCase` (arrive / complete), RN08 |
| RF37 | El conductor debe poder subir fotografías de la entrega y capturar la firma digital del receptor desde la app | Conductor | Implementado · documents + shipment · foto obligatoria (`LOGYX-TRK-006`); firma opcional en Android |
| RF38 | La PYME debe poder ver en tiempo real el estado actual de su envío y el histórico de cambios de estado | PYME | Implementado · Seguimiento web/Android con actualización por SSE (ADR-0007) |
| RF39 | El sistema debe mostrar en mapa la ruta del envío con las paradas marcadas y el estado de cada una | PYME / Operador | Implementado · MapLibre (OpenFreeMap) con paradas; ruta por carretera pendiente |

#### Módulo REPUTATION — Reputación y Confianza

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF40 | Al completarse una entrega, la PYME debe poder calificar al transportista en dos dimensiones: puntualidad (1–5) y calidad del servicio (1–5), con comentario opcional | PYME | Implementado · reputation · `ReviewService.submit` |
| RF41 | Al completarse una entrega, el transportista debe poder calificar a la PYME en: exactitud de información declarada (peso/tipo de carga) y comportamiento como cliente | Transportista | Implementado · reputation · calificación PYME ← transportista |
| RF42 | El sistema debe calcular automáticamente un Trust Score compuesto para transportistas con 5 métricas: tasa de entregas exitosas (25%), puntualidad (25%), tasa de cancelación (15%), índice de incidentes (15%) y rating promedio (20%) | Sistema | Parcial · RN09: Trust Score bayesiano; métricas compuestas de cancelación/incidentes pendientes |
| RF43 | El sistema debe calcular automáticamente un Trust Score para PYMEs con métricas: cumplimiento de pago (30%), exactitud de carga declarada (25%), tasa de cancelación (20%), tiempo de respuesta (15%) y rating (10%) | Sistema | Parcial · RN09: Trust Score bayesiano; métricas de pago/respuesta pendientes |
| RF44 | El perfil de reputación de cada organización debe ser visible públicamente en el marketplace, mostrando el score compuesto, métricas individuales y badges obtenidos | Todos | Implementado · `GET /organizations/{id}/reputation`, `TrustScore` |
| RF45 | El sistema solo debe habilitar el formulario de calificación si existe evidencia verificada de entrega (al menos una foto + confirmación de estado) | Sistema | Implementado · RN06 · `ReviewEligibilityPolicy` |

#### Módulo DOCUMENTS — Gestión Documental

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF46 | Los participantes de un envío deben poder subir documentos asociados (orden de servicio, guía de remisión, comprobante, evidencia fotográfica) | PYME / Transportista | Implementado · documents · upload multipart jpg/png/pdf ≤ 10 MB (ADR-0005) |
| RF47 | Los documentos deben estar clasificados por tipo y accesibles solo para los participantes del envío | Sistema | Implementado · RLS de `documents` (partes del envío + operador) |
| RF48 | La PYME debe poder ver un listado consolidado de todos los documentos de sus envíos | PYME | Parcial · Pestaña de documentos por envío; sin listado consolidado global |

#### Módulo NOTIFICATIONS — Notificaciones

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF49 | El sistema debe enviar notificaciones in-app ante los siguientes eventos: nueva oferta recibida, oferta aceptada/rechazada, cambio de estado del envío, nueva calificación, nuevo mensaje en chat, incidencia reportada/resuelta | Sistema | Implementado · notification · ADR-0004 |
| RF50 | El sistema debe enviar notificaciones por email para eventos críticos: oferta aceptada, envío creado, entrega confirmada | Sistema | No implementado · Email pendiente (el outbox ya lo permite) |
| RF51 | La PYME debe poder ver un centro de notificaciones con historial y marcar como leídas | PYME | Implementado · notification · `/notificaciones`, `read-all` |

#### Módulo INCIDENTS — Incidencias y Disputas

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF52 | Cualquier participante de un envío debe poder reportar una incidencia especificando categoría (carga dañada, retraso, extravío, otro) y descripción | PYME / Transportista / Conductor | Implementado · incident · `IncidentService` |
| RF53 | El sistema debe cambiar automáticamente el estado del envío a "con incidencia" al reportarse una incidencia | Sistema | Parcial · RN11 se implementa como bloqueo de paradas (`hasActiveIncident`); sin estado `ISSUE` del envío |
| RF54 | Los participantes y el operador deben poder añadir comentarios al hilo de la incidencia | PYME / Transportista / Operador | Implementado · incident · `incident_comments` |
| RF55 | El operador debe poder resolver la incidencia indicando el estado final del envío (reencauzado, entregado, cancelado) | Operador | Parcial · El operador resuelve, pero no fija el estado final del envío |

#### Módulo OPERATOR — Panel del Operador

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF56 | El operador debe ver un dashboard con métricas en tiempo real: solicitudes abiertas, en riesgo (SLA > 24h sin ofertas), en tránsito, entregadas | Operador | Implementado · operator · `GET /operator/metrics` |
| RF57 | El operador debe ver una lista priorizada de solicitudes que llevan más de 24 horas sin recibir ofertas | Operador | Implementado · operator · `GET /operator/sla-alerts` |
| RF58 | El operador debe poder asignar manualmente un transportista a una solicitud sin ofertas, generando la oferta y el contrato de envío | Operador | Implementado · RN10 · `ManualAssignmentUseCase` |
| RF59 | El operador debe ver las oportunidades de Smart Load Planner detectadas por el sistema | Operador | No implementado · La política RLS `smart_operator` (V10) ya permite la lectura al operador; faltan endpoint y pantalla |
| RF60 | El operador debe poder ver y gestionar todas las incidencias abiertas del sistema | Operador | Implementado · operator · `/operador/incidencias` (web) |

#### Módulo RETURN LOAD — Cargas de Retorno

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF61 | Al confirmarse la entrega final de un transportista, el sistema debe detectar solicitudes de carga abiertas con origen geográficamente cercano (radio 30 km) al destino recién completado | Sistema | Implementado · trip · `ReturnLoadPolicy` (radio 50 km), `GET /return-loads` a demanda |
| RF62 | El sistema debe notificar al transportista las oportunidades de carga de retorno detectadas, rankeadas por compatibilidad y distancia al punto de recojo | Transportista | Parcial · Lista ordenada por cercanía; aviso por evento pendiente |
| RF63 | El transportista debe poder hacer una oferta desde la pantalla de retornos sin necesidad de ir al marketplace | Transportista | Implementado · `BidSheet` desde `/retornos` y `ReturnLoads` (Android) |

#### Módulo FLEET — Gestión de Flota

| ID | Descripción | Actor | Estado · Módulo (código) |
|----|-------------|-------|---|
| RF64 | El transportista debe poder registrar sus vehículos con: placa, tipo, capacidad máxima (kg/m³), tipo de carga que acepta y estado (disponible/en ruta/mantenimiento) | Transportista | Implementado · fleet · `vehicles` |
| RF65 | El transportista debe poder registrar conductores vinculados a su empresa con: nombre, DNI y número de licencia | Transportista | Implementado · fleet · `drivers` |
| RF66 | El transportista debe poder asignar un conductor y vehículo específico a un envío aceptado | Transportista | Implementado · shipment · `AssignDriverUseCase` |
| RF67 | El sistema debe impedir que un transportista oferte en cargas que superen la capacidad disponible real de sus vehículos activos | Sistema | Implementado · RN02 |

---

### 7.2 Requerimientos No Funcionales

| ID | Tipo | Descripción | Estado en el sistema real |
|----|------|-------------|---|
| RNF01 | **Rendimiento** | El sistema debe responder en menos de 2 segundos para el 95% de las solicitudes bajo carga normal (hasta 200 usuarios concurrentes) | Cumplido por diseño; no medido con carga (pruebas de carga pendientes) |
| RNF02 | **Rendimiento** | Las consultas al marketplace deben retornar resultados en menos de 1.5 segundos incluyendo el cálculo del score de matching | Cumplido por diseño; sin score de matching (RF16) |
| RNF03 | **Disponibilidad** | El sistema debe tener una disponibilidad mínima del 99% mensual | Pendiente de despliegue en producción (compose local verificado) |
| RNF04 | **Seguridad** | Todas las comunicaciones deben usar HTTPS/TLS 1.3 | TLS lo termina el proxy; HSTS en prod (`docs/security.md`); el compose local es http |
| RNF05 | **Seguridad** | La autenticación debe implementarse con JWT (access token 1h + refresh token 7 días) | Modificado: JWT RSA con TTL 8 h (`logyx.jwt.ttl`), sin refresh token |
| RNF06 | **Seguridad** | El control de acceso debe implementarse con RBAC a nivel de endpoint y a nivel de datos | Implementado: RBAC (`@RolesAllowed`) y RLS por organización (ADR-0001) |
| RNF07 | **Seguridad** | Las contraseñas deben almacenarse con hash bcrypt (factor de costo mínimo 12) | Implementado: hash bcrypt (`BcryptPasswordHasher`) y rate limiting de login/registro (`LOGYX-AUTH-429`) |
| RNF08 | **Usabilidad** | La app móvil debe ser operable en dispositivos Android 10+ con pantallas desde 5" | Implementado: Android `minSdk` 29 (Android 10) |
| RNF09 | **Usabilidad** | El tiempo máximo para completar la acción "publicar solicitud de carga" no debe superar 3 minutos para un usuario nuevo | Verificado en e2e (publicar solicitud con cotización en vivo) |
| RNF10 | **Escalabilidad** | La arquitectura debe soportar despliegue en contenedores Docker y permitir escalado horizontal del backend | Implementado: imágenes Docker de backend y web, `infra/docker-compose.yml`; réplicas con outbox `SKIP LOCKED` y fan-out por `LISTEN/NOTIFY` |
| RNF11 | **Mantenibilidad** | El backend debe seguir arquitectura de monolito modular con límites de módulo claros, permitiendo extracción futura a microservicios | Implementado y vigilado por `ModuleBoundariesTest` |
| RNF12 | **Compatibilidad web** | La aplicación web debe funcionar correctamente en Chrome 120+, Firefox 120+ y Edge 120+ | Implementado: Playwright sobre Chromium; no verificado en Firefox/Edge |
| RNF13 | **Compatibilidad móvil** | La app mobile debe funcionar en Android 10+ e iOS 16+ | Android 10+ implementado; iOS (SwiftUI) planificado |
| RNF14 | **Integridad de datos** | La base de datos debe implementar integridad referencial completa con claves foráneas y constraints | Implementado: FKs, `CHECK` y `UNIQUE` en V1–V12 |
| RNF15 | **Trazabilidad** | Todas las acciones de negocio críticas (aceptar oferta, cambiar estado, resolver incidencia) deben quedar registradas con timestamp y usuario responsable | Implementado: `audit_log` y outbox transaccional |
| RNF16 | **Disponibilidad offline** | La app del conductor debe mantener en caché la ruta asignada y permitir actualización de estados sin conexión, sincronizando al recuperar conectividad | Parcial: cola persistente de evidencia con reintento automático en Android (`EvidenceRepository`); sin caché offline de la ruta |
| RNF17 | **Cumplimiento normativo** | El sistema debe exponer una política de privacidad pública y visible en app y web, conforme al Art. 18 de la Ley N° 29733, antes del primer registro de usuario real | Implementado: `/privacidad` en la web |
| RNF18 | **Cumplimiento normativo** | El flujo de onboarding debe incluir un paso de consentimiento informado y explícito para el tratamiento de datos personales, conforme al Art. 13 de la Ley N° 29733 | Implementado: `consent_accepted_at` obligatorio (`@AssertTrue` en el registro) |
| RNF19 | **Cumplimiento normativo** | El sistema debe mantener un registro interno de actividades de tratamiento de datos y un procedimiento operativo de notificación de brechas a la ANPD en un plazo máximo de 72 horas, conforme al Art. 39 del Reglamento de la Ley N° 29733 | Parcial: `audit_log` y `docs/security.md`; procedimiento de notificación de brechas solo documental |
| RNF20 | **Cumplimiento normativo (pagos)** | El sistema no debe almacenar datos de tarjeta en ningún momento; el procesamiento de pagos se delega íntegramente a una pasarela certificada PCI-DSS (tokenización delegada) | Cumplido: el sistema no maneja pagos ni tarjetas |
| RNF21 | **Seguridad / privacidad** *(añadido en la implementación)* | El aislamiento de datos entre organizaciones debe garantizarse con dos barreras: filtros de aplicación por la organización del JWT y Row-Level Security en PostgreSQL (ADR-0001); el cliente nunca envía `organizationId` | Implementado: `TenantContext`, `TenantSessionBinder`, políticas de V2–V12, `RowLevelSecurityTest` |
| RNF22 | **Seguridad** *(añadido)* | La aplicación debe conectarse a la base de datos con el mínimo privilegio: usuario `logyx_api` sin dueño, sin `BYPASSRLS` y sin poder escalar; las operaciones de plataforma usan un datasource privilegiado separado y explícito (`SystemTx`) (ADR-0006) | Implementado: `DatabasePrivilegesTest` (SQLSTATE 42501) |
| RNF23 | **Seguridad** *(añadido)* | Login y registro deben tener rate limiting (50 intentos/15 min por IP, bloqueo tras 10 fallos por email) y las respuestas deben incluir cabeceras de seguridad (CSP, HSTS en prod, `X-Frame-Options`, `nosniff`) | Implementado: `AuthRateLimits`, middleware de Astro; el límite es por instancia |
| RNF24 | **Fiabilidad** *(añadido)* | Los avisos y recálculos disparados por eventos de dominio no deben perderse entre el commit y su entrega (outbox transaccional con reintentos) (ADR-0006) | Implementado: `outbox_events` (V11), `OutboxTest` |
| RNF25 | **Tiempo real** *(añadido)* | Los clientes deben recibir cambios relevantes sin recargar, con aislamiento por organización/usuario y reanudación tras desconexión (SSE) (ADR-0007) | Implementado: `GET /api/v1/events/stream`, `RealtimeStreamFlowTest` |

*Origen: RNF17–RNF20 derivan del análisis de Gobierno de TI bajo COBIT 2019 (Gestión TI, Entregable 1, sección 1.7) y de la sección de Cumplimiento Normativo del Plan de Gestión del Proyecto (Gestión TI, Entregable 3, sección 3.7).*

---

### 7.3 Reglas de Negocio

| ID | Regla | Estado · Dónde se implementa |
|----|-------|---|
| RN01 | Una solicitud de carga solo puede ser creada por organizaciones de tipo PYME con RUC verificado | Implementado · `marketplace/domain/model/ShipmentRequest.ensureRequesterCanPublish`; RUC por Módulo 11 en `identity/domain/RucValidator` |
| RN02 | Un transportista solo puede ofertar si tiene al menos un vehículo registrado con capacidad suficiente para la carga | Implementado · `marketplace/domain/BidEligibilityPolicy.ensureVehicleEligible` |
| RN03 | Una oferta no puede tener un precio inferior al 75% del precio sugerido por el motor de costos (price floor) | Implementado · `pricing/domain/PriceFloorPolicy` + `BidEligibilityPolicy.ensureAboveFloor` |
| RN04 | Una subasta se cierra automáticamente al cumplirse el tiempo límite (20 min) O al recibir el número máximo de ofertas (5), lo que ocurra primero | Implementado · `marketplace/domain/AuctionClosingPolicy`, `CloseExpiredAuctionsUseCase`, `AuctionScheduler` |
| RN05 | Al aceptarse una oferta, todas las demás ofertas de la misma solicitud quedan en estado rechazado automáticamente | Implementado · `marketplace/application/AcceptBidUseCase` |
| RN06 | Una calificación solo puede dejarse si existe al menos una foto de evidencia y la confirmación del estado "entregado" | Implementado · `reputation/domain/ReviewEligibilityPolicy` y `shipment/domain/DeliveryEvidencePolicy` |
| RN07 | El sistema bloquea automáticamente mensajes de chat que contengan patrones de números de teléfono (9 dígitos consecutivos), emails o URLs externas | Implementado · `negotiation/domain/ContactInfoPolicy` (teléfonos con separadores, +51, emails, URLs, `@usuario`) |
| RN08 | Un conductor no puede actualizar el estado de una parada fuera del orden secuencial definido | Implementado · `shipment/domain/StopSequencePolicy` |
| RN09 | El Trust Score se recalcula tras cada calificación usando el método Bayesiano anclado a un prior de 75/100 | Implementado · `reputation/domain/TrustScoreCalculator`: score = (C·m + Σxᵢ)/(C + n), m = 75, C = 5 |
| RN10 | El Operador puede asignar un transportista manualmente solo a solicitudes con más de 24 horas sin ofertas (SLA vencido) | Implementado · `marketplace/domain/ManualAssignmentPolicy` + `operator` (V9) |
| RN11 | Una incidencia activa retiene el cambio de estado del envío hasta ser resuelta por el Operador | Implementado · `incident/domain/IncidentStatusPolicy`; `TrackStopsUseCase` rechaza con `LOGYX-TRK-005` |
| RN12 | Un transportista no puede publicar un viaje disponible con capacidad mayor a la flota declarada y verificada | Implementado · `trip/domain/TripCapacityPolicy` |

---

### 7.4 Restricciones Técnicas

| ID | Restricción (v1.0, diseño inicial) | Restricción vigente (sistema real) |
|----|-----------|-----------|
| RT01 | El backend debe implementarse con Quarkus (Java/Kotlin) | **Sin cambio.** Quarkus 3.40, Java 21, estilo bloqueante con arquitectura hexagonal por módulo (ADR-0002) |
| RT02 | El frontend web debe implementarse con Angular 18+ | **Modificada (ADR-0003):** Astro 7 en modo SSR (adapter Node), Tailwind 4 e islas React con primitivas shadcn/ui |
| RT03 | Las aplicaciones móviles deben implementarse con Flutter | **Modificada (ADR-0003):** una app Android nativa en Kotlin + Jetpack Compose con navegación por rol; app iOS en SwiftUI **planificada** (fase posterior, reutilizando `core:model`/`core:network` vía KMP) |
| RT04 | La base de datos debe ser PostgreSQL 16 | **Sin cambio.** Migraciones con Flyway (V1–V12) |
| RT05 | El cálculo de distancias y rutas debe usar la API de OpenRouteService | **Modificada (ADR-0008):** precálculo OSM/OSRM versionado en el repositorio (módulo `routing`). Implementado en el backend: `pricing` usa `RoadDistanceProvider` (km por carretera, tras el puerto `DistanceProvider`), `trip` (retornos y Smart Load) usa los mismos km y existe `GET /api/v1/routes`. Pendiente: dibujar la ruta en los mapas de web y Android. OpenRouteService descartado. Mapas con MapLibre GL y teselas OpenFreeMap (sin API key) |
| RT06 | El sistema debe desplegarse en contenedores Docker | **Sin cambio.** `backend/Dockerfile`, `web/Dockerfile`, `infra/docker-compose.yml` (PostgreSQL, backend, web; MinIO solo en staging local). Destino de producción: **VPS Hostinger KVM 2** con Caddy y Cloudflare, documentos en Cloudflare R2 (sustituye al diseño en AWS; ver [Cambios respecto al diseño inicial](../cambios-diseno-inicial.md#7-rebrand-oncargo-y-migracion-a-hostinger)) |
| RT07 | El repositorio debe estar en GitHub con pipeline CI/CD mediante GitHub Actions | **Sin cambio.** Workflows `backend`, `web`, `android`, `contract` y `e2e` |

---

## 8. Prototipos

Los prototipos navegables se desarrollaron en Figma (ver [Prototipos](prototipos.md)). El sistema construido sigue su inventario de pantallas, con un sistema de diseño propio (`docs/design/DESIGN.md`) y capturas reales en [Arquitectura Frontend](../entregable-3/arquitectura-frontend.md).

**Flujos principales (todos implementados y cubiertos por pruebas e2e en la web):**
- Registro y onboarding por rol (con consentimiento Ley 29733)
- PYME: crear solicitud, ver subasta, negociar, aceptar, tracking
- Transportista: marketplace, ofertar, recibir aceptación, asignar conductor
- Conductor: viaje activo, avanzar paradas, subir evidencia
- Operador: panel, asignación manual, gestión de incidencias (solo web)

---

## 9. Arquitectura del Sistema

Ver [Arquitectura (IEEE 42010 / C4)](arquitectura.md).

**Resumen:** monolito modular Quarkus con arquitectura hexagonal por módulo; web Astro SSR con islas React; una app Android nativa (Kotlin/Compose); PostgreSQL 16 con Row-Level Security; MinIO/S3 para documentos; contrato OpenAPI como fuente de verdad. Los cambios respecto del diseño inicial están justificados en [Cambios respecto al diseño inicial](../cambios-diseno-inicial.md).

---

## 10. Modelado del Sistema (UML)

Ver [Modelado UML](uml.md) para los diagramas de casos de uso, clases, secuencia y estados alineados con el código.

---

## 11. Trazabilidad de Requerimientos

| Requerimiento | Módulo del backend (`pe.logyx.*`) | Web (Astro) | Android |
|--------------|-------------------|---------------------|---------|
| RF01–RF08 | `identity` | `features/auth`, `/login`, `/registro` | `:feature:auth` |
| RF09–RF14 | `marketplace`, `pricing` | `features/requests`, `/pyme/solicitudes` | `:feature:requests` |
| RF15–RF20 | `marketplace` | `features/marketplace`, `/transportista` | `:feature:loads` |
| RF21–RF24 | `trip` | `/viajes`, `/pyme/viajes` | `:feature:trips` |
| RF25–RF29 | `negotiation` | `features/negotiation` | `:feature:negotiation` |
| RF30–RF33 | `trip` (`SmartLoadPlanner`) | `/smart-load` | `:feature:trips` |
| RF34–RF39 | `shipment` | `features/shipments`, `/conductor` | `:feature:shipments`, `:feature:driver` |
| RF40–RF45 | `reputation` | `features/reputation`, `/organizaciones/[id]` | `:feature:reputation` |
| RF46–RF48 | `documents` | `features/documents` | `:feature:documents` |
| RF49–RF51 | `notification`, `realtime` | `features/notifications` | `:feature:notifications` |
| RF52–RF55 | `incident` | `features/incidents` | `:feature:incidents` |
| RF56–RF60 | `operator` | `features/operator`, `/operador` | (no aplica: el operador usa solo web) |
| RF61–RF63 | `trip` (`ReturnLoadPolicy`) | `/retornos` | `:feature:trips` |
| RF64–RF67 | `fleet` | `features/fleet`, `/transportista/flota` | `:feature:shipments` (asignación) |

---

## 12. Validación con Stakeholders

| Método | Descripción | Estado |
|--------|-------------|--------|
| Análisis de literatura | Revisión de modelos de marketplace logístico (Uber Freight, InDrive, Flexport) | Completado |
| Entrevistas a transportistas | Entrevistas con transportistas del corredor Lima–Puno sobre flujo actual de trabajo | Pendiente |
| Entrevistas a PYMEs | Entrevistas a empresas con envíos regulares sobre puntos de dolor logísticos | Pendiente |
| Revisión de prototipo | Sesión de validación de prototipos Figma con usuarios potenciales | Pendiente |
| Revisión académica | Validación del SRS con docente / jurado del programa | Pendiente |

---

*OnCargo · E1 Especificación de Requerimientos del Sistema · SRS IEEE 29148 · Versión 1.1 · Noviembre 2026*
