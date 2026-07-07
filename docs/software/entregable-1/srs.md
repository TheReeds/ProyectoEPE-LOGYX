# E1 — Especificación de Requerimientos del Sistema (SRS)
> Estándar: IEEE 29148 · Competencia CE0211  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Institución: Universidad Peruana Unión · Ingeniería de Sistemas  
> Versión: 1.0 · Junio 2026

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Nombre del sistema** | LOGYX |
| **Tipo** | Sistema empresarial web con extensión móvil |
| **Tipo de entregable** | EPE — Evaluación del Perfil de Egreso |
| **Curso / Línea** | Ingeniería de Software |
| **Equipo** | Jorge Gutiérrez Miranda, Fabrizio Sanchez Saravia, Alex Coila Jarita |
| **Versión del documento** | 1.0 |
| **Fecha** | Junio 2026 |

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

LOGYX opera en el mercado logístico B2B del Perú, con foco inicial en el corredor Lima–Sierra Sur. El sistema digital reemplaza la coordinación informal (WhatsApp, llamadas) con un marketplace estructurado que conecta PYMEs demandantes de transporte con empresas transportistas, bajo supervisión de operadores logísticos.

### 3.2 Usuarios del Sistema

| Actor | Descripción | Canal de acceso |
|-------|-------------|----------------|
| **PYME** | Empresa que necesita contratar transporte de carga | Web (Angular) + Mobile (Flutter) |
| **Empresa Transportista** | Empresa con flota de vehículos que oferta servicios | Web (Angular) + Mobile (Flutter) |
| **Conductor (Driver)** | Persona que ejecuta físicamente la ruta | Mobile app dedicada (Flutter) |
| **Operador LOGYX** | Supervisor interno con acceso global al sistema | Web (Angular) |
| **Administrador** | Gestión de la plataforma, configuración y moderación | Web (Angular) |

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
| Operador LOGYX | Supervisor interno | Garantizar SLA y resolver incidencias |
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
- Motor de costos basado en reglas (distancia ORS + tarifa por tipo de carga)
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

| ID | Descripción | Actor |
|----|-------------|-------|
| RF01 | El sistema debe permitir el registro de una organización de tipo PYME con nombre, RUC y datos del representante legal | PYME |
| RF02 | El sistema debe permitir el registro de una organización de tipo Transportista con nombre, RUC, datos de flota y representante | Transportista |
| RF03 | El sistema debe permitir el registro de un Conductor vinculado a una empresa transportista, con nombre y número de licencia | Transportista |
| RF04 | El sistema debe validar el RUC ingresado mediante el algoritmo de verificación Módulo 11 y consultar su estado activo en SUNAT | PYME / Transportista |
| RF05 | El sistema debe permitir inicio de sesión con email y contraseña | Todos |
| RF06 | El sistema debe permitir inicio de sesión con cuenta Google (OAuth 2.0) | Todos |
| RF07 | El sistema debe proteger todas las rutas según el rol del usuario autenticado (RBAC) | Sistema |
| RF08 | El sistema debe asignar un badge "Verificado" a las organizaciones que completan el proceso de validación de RUC | Sistema |

#### Módulo SHIPMENT — Solicitudes de Carga

| ID | Descripción | Actor |
|----|-------------|-------|
| RF09 | La PYME debe poder crear una solicitud de carga especificando: origen, destino, peso (kg), tipo de carga, fecha requerida y descripción | PYME |
| RF10 | Al crear la solicitud, el sistema debe calcular y mostrar un precio de referencia de mercado basado en distancia real (ORS), peso, tipo de carga y tarifas históricas del corredor | Sistema |
| RF11 | La PYME debe poder ver el listado de sus solicitudes activas con estado actual y contador de ofertas recibidas | PYME |
| RF12 | La PYME debe poder ver el detalle de una solicitud, incluyendo todas las ofertas recibidas con precio, datos del transportista y su score de reputación | PYME |
| RF13 | La PYME debe poder aceptar una oferta, lo que genera automáticamente un contrato de envío con código de tracking | PYME |
| RF14 | La PYME debe poder rechazar una oferta individual | PYME |

#### Módulo AUCTION — Subasta Inversa

| ID | Descripción | Actor |
|----|-------------|-------|
| RF15 | Al publicarse una solicitud de carga, el sistema debe abrir automáticamente una subasta con tiempo límite configurable (default: 20 minutos) o hasta recibir N ofertas (default: 5) | Sistema |
| RF16 | El transportista debe ver en el marketplace las solicitudes de carga activas filtradas y rankeadas según compatibilidad con su perfil (zona, capacidad, historial de ruta) | Transportista |
| RF17 | El transportista debe poder enviar una oferta a una subasta activa indicando: precio ofertado, vehículo asignado y notas adicionales | Transportista |
| RF18 | El sistema debe cerrar automáticamente la subasta al cumplirse el tiempo o el número máximo de ofertas, notificando a la PYME | Sistema |
| RF19 | El sistema no debe permitir que un transportista oferte un precio inferior al precio mínimo viable calculado por el motor de precios (price floor) | Sistema |
| RF20 | El sistema no debe permitir que un transportista oferte si su capacidad disponible real es insuficiente para la carga solicitada | Sistema |

#### Módulo TRIP — Viajes Disponibles (Supply-Side)

| ID | Descripción | Actor |
|----|-------------|-------|
| RF21 | El transportista debe poder publicar un viaje disponible especificando: ruta (origen-destino-paradas), fecha de salida, capacidad disponible (kg/m³) y precio por kg | Transportista |
| RF22 | La PYME debe poder explorar los viajes disponibles publicados y reservar espacio en uno de ellos indicando el peso y tipo de su carga | PYME |
| RF23 | El sistema debe validar que el peso reservado no exceda la capacidad disponible del viaje en el momento de la reserva | Sistema |
| RF24 | El transportista debe poder ver todas las cargas reservadas en su viaje con detalle de cada una | Transportista |

#### Módulo NEGOTIATION — Negociación Bidireccional

| ID | Descripción | Actor |
|----|-------------|-------|
| RF25 | El sistema debe proveer un hilo de chat por cada par (solicitud + transportista), visible para ambas partes | PYME / Transportista |
| RF26 | El transportista debe poder enviar una contra-oferta desde el chat indicando el precio propuesto | Transportista |
| RF27 | La PYME debe poder enviar una contra-oferta al transportista indicando el precio que está dispuesta a pagar | PYME |
| RF28 | Cualquiera de las dos partes debe poder aceptar la contra-oferta vigente, actualizando el precio de la oferta automáticamente | PYME / Transportista |
| RF29 | El sistema debe detectar y bloquear mensajes que contengan información de contacto (teléfonos, emails, handles de redes sociales) en el chat | Sistema |

#### Módulo SMART LOAD PLANNER — Planificación de Carga

| ID | Descripción | Actor |
|----|-------------|-------|
| RF30 | El sistema debe detectar automáticamente solicitudes de carga compatibles entre sí por criterios de: origen similar (radio 50 km), destino similar (radio 80 km), fechas compatibles (±24h) y peso combinado dentro de la capacidad de un vehículo disponible | Sistema |
| RF31 | El sistema debe mostrar al transportista las combinaciones de carga compatibles como sugerencias de Smart Load Plan, indicando ingreso combinado estimado, porcentaje de ocupación y ruta optimizada | Transportista |
| RF32 | El transportista debe poder aceptar un Smart Load Plan, lo que genera automáticamente un envío multi-parada con las cargas incluidas | Transportista |
| RF33 | Al ser incluidas en un Smart Load Plan, las PYMEs involucradas deben recibir una notificación indicando que su carga fue agrupada con otras | Sistema |

#### Módulo TRACKING — Seguimiento y Estados

| ID | Descripción | Actor |
|----|-------------|-------|
| RF34 | Al aceptarse una oferta, el sistema debe generar un código de tracking único para el envío (formato: LGX-XXXXX) | Sistema |
| RF35 | El sistema debe permitir registrar múltiples paradas ordenadas para un envío, cada una con: ubicación, ETA estimado y estado | Sistema |
| RF36 | El conductor debe poder actualizar el estado de cada parada desde la app Driver (en_camino, recogido, entregado) | Conductor |
| RF37 | El conductor debe poder subir fotografías de la entrega y capturar la firma digital del receptor desde la app | Conductor |
| RF38 | La PYME debe poder ver en tiempo real el estado actual de su envío y el histórico de cambios de estado | PYME |
| RF39 | El sistema debe mostrar en mapa la ruta del envío con las paradas marcadas y el estado de cada una | PYME / Operador |

#### Módulo REPUTATION — Reputación y Confianza

| ID | Descripción | Actor |
|----|-------------|-------|
| RF40 | Al completarse una entrega, la PYME debe poder calificar al transportista en dos dimensiones: puntualidad (1–5) y calidad del servicio (1–5), con comentario opcional | PYME |
| RF41 | Al completarse una entrega, el transportista debe poder calificar a la PYME en: exactitud de información declarada (peso/tipo de carga) y comportamiento como cliente | Transportista |
| RF42 | El sistema debe calcular automáticamente un Trust Score compuesto para transportistas con 5 métricas: tasa de entregas exitosas (25%), puntualidad (25%), tasa de cancelación (15%), índice de incidentes (15%) y rating promedio (20%) | Sistema |
| RF43 | El sistema debe calcular automáticamente un Trust Score para PYMEs con métricas: cumplimiento de pago (30%), exactitud de carga declarada (25%), tasa de cancelación (20%), tiempo de respuesta (15%) y rating (10%) | Sistema |
| RF44 | El perfil de reputación de cada organización debe ser visible públicamente en el marketplace, mostrando el score compuesto, métricas individuales y badges obtenidos | Todos |
| RF45 | El sistema solo debe habilitar el formulario de calificación si existe evidencia verificada de entrega (al menos una foto + confirmación de estado) | Sistema |

#### Módulo DOCUMENTS — Gestión Documental

| ID | Descripción | Actor |
|----|-------------|-------|
| RF46 | Los participantes de un envío deben poder subir documentos asociados (orden de servicio, guía de remisión, comprobante, evidencia fotográfica) | PYME / Transportista |
| RF47 | Los documentos deben estar clasificados por tipo y accesibles solo para los participantes del envío | Sistema |
| RF48 | La PYME debe poder ver un listado consolidado de todos los documentos de sus envíos | PYME |

#### Módulo NOTIFICATIONS — Notificaciones

| ID | Descripción | Actor |
|----|-------------|-------|
| RF49 | El sistema debe enviar notificaciones in-app ante los siguientes eventos: nueva oferta recibida, oferta aceptada/rechazada, cambio de estado del envío, nueva calificación, nuevo mensaje en chat, incidencia reportada/resuelta | Sistema |
| RF50 | El sistema debe enviar notificaciones por email para eventos críticos: oferta aceptada, envío creado, entrega confirmada | Sistema |
| RF51 | La PYME debe poder ver un centro de notificaciones con historial y marcar como leídas | PYME |

#### Módulo INCIDENTS — Incidencias y Disputas

| ID | Descripción | Actor |
|----|-------------|-------|
| RF52 | Cualquier participante de un envío debe poder reportar una incidencia especificando categoría (carga dañada, retraso, extravío, otro) y descripción | PYME / Transportista / Conductor |
| RF53 | El sistema debe cambiar automáticamente el estado del envío a "con incidencia" al reportarse una incidencia | Sistema |
| RF54 | Los participantes y el operador deben poder añadir comentarios al hilo de la incidencia | PYME / Transportista / Operador |
| RF55 | El operador debe poder resolver la incidencia indicando el estado final del envío (reencauzado, entregado, cancelado) | Operador |

#### Módulo OPERATOR — Panel del Operador

| ID | Descripción | Actor |
|----|-------------|-------|
| RF56 | El operador debe ver un dashboard con métricas en tiempo real: solicitudes abiertas, en riesgo (SLA > 24h sin ofertas), en tránsito, entregadas | Operador |
| RF57 | El operador debe ver una lista priorizada de solicitudes que llevan más de 24 horas sin recibir ofertas | Operador |
| RF58 | El operador debe poder asignar manualmente un transportista a una solicitud sin ofertas, generando la oferta y el contrato de envío | Operador |
| RF59 | El operador debe ver las oportunidades de Smart Load Planner detectadas por el sistema | Operador |
| RF60 | El operador debe poder ver y gestionar todas las incidencias abiertas del sistema | Operador |

#### Módulo RETURN LOAD — Cargas de Retorno

| ID | Descripción | Actor |
|----|-------------|-------|
| RF61 | Al confirmarse la entrega final de un transportista, el sistema debe detectar solicitudes de carga abiertas con origen geográficamente cercano (radio 30 km) al destino recién completado | Sistema |
| RF62 | El sistema debe notificar al transportista las oportunidades de carga de retorno detectadas, rankeadas por compatibilidad y distancia al punto de recojo | Transportista |
| RF63 | El transportista debe poder hacer una oferta desde la pantalla de retornos sin necesidad de ir al marketplace | Transportista |

#### Módulo FLEET — Gestión de Flota

| ID | Descripción | Actor |
|----|-------------|-------|
| RF64 | El transportista debe poder registrar sus vehículos con: placa, tipo, capacidad máxima (kg/m³), tipo de carga que acepta y estado (disponible/en ruta/mantenimiento) | Transportista |
| RF65 | El transportista debe poder registrar conductores vinculados a su empresa con: nombre, DNI y número de licencia | Transportista |
| RF66 | El transportista debe poder asignar un conductor y vehículo específico a un envío aceptado | Transportista |
| RF67 | El sistema debe impedir que un transportista oferte en cargas que superen la capacidad disponible real de sus vehículos activos | Sistema |

---

### 7.2 Requerimientos No Funcionales

| ID | Tipo | Descripción |
|----|------|-------------|
| RNF01 | **Rendimiento** | El sistema debe responder en menos de 2 segundos para el 95% de las solicitudes bajo carga normal (hasta 200 usuarios concurrentes) |
| RNF02 | **Rendimiento** | Las consultas al marketplace deben retornar resultados en menos de 1.5 segundos incluyendo el cálculo del score de matching |
| RNF03 | **Disponibilidad** | El sistema debe tener una disponibilidad mínima del 99% mensual |
| RNF04 | **Seguridad** | Todas las comunicaciones deben usar HTTPS/TLS 1.3 |
| RNF05 | **Seguridad** | La autenticación debe implementarse con JWT (access token 1h + refresh token 7 días) |
| RNF06 | **Seguridad** | El control de acceso debe implementarse con RBAC a nivel de endpoint y a nivel de datos |
| RNF07 | **Seguridad** | Las contraseñas deben almacenarse con hash bcrypt (factor de costo mínimo 12) |
| RNF08 | **Usabilidad** | La app móvil debe ser operable en dispositivos Android 10+ con pantallas desde 5" |
| RNF09 | **Usabilidad** | El tiempo máximo para completar la acción "publicar solicitud de carga" no debe superar 3 minutos para un usuario nuevo |
| RNF10 | **Escalabilidad** | La arquitectura debe soportar despliegue en contenedores Docker y permitir escalado horizontal del backend |
| RNF11 | **Mantenibilidad** | El backend debe seguir arquitectura de monolito modular con límites de módulo claros, permitiendo extracción futura a microservicios |
| RNF12 | **Compatibilidad web** | La aplicación web debe funcionar correctamente en Chrome 120+, Firefox 120+ y Edge 120+ |
| RNF13 | **Compatibilidad móvil** | La app mobile debe funcionar en Android 10+ e iOS 16+ |
| RNF14 | **Integridad de datos** | La base de datos debe implementar integridad referencial completa con claves foráneas y constraints |
| RNF15 | **Trazabilidad** | Todas las acciones de negocio críticas (aceptar oferta, cambiar estado, resolver incidencia) deben quedar registradas con timestamp y usuario responsable |
| RNF16 | **Disponibilidad offline** | La app del conductor debe mantener en caché la ruta asignada y permitir actualización de estados sin conexión, sincronizando al recuperar conectividad |

---

### 7.3 Reglas de Negocio

| ID | Regla |
|----|-------|
| RN01 | Una solicitud de carga solo puede ser creada por organizaciones de tipo PYME con RUC verificado |
| RN02 | Un transportista solo puede ofertar si tiene al menos un vehículo registrado con capacidad suficiente para la carga |
| RN03 | Una oferta no puede tener un precio inferior al 75% del precio sugerido por el motor de costos (price floor) |
| RN04 | Una subasta se cierra automáticamente al cumplirse el tiempo límite (20 min) O al recibir el número máximo de ofertas (5), lo que ocurra primero |
| RN05 | Al aceptarse una oferta, todas las demás ofertas de la misma solicitud quedan en estado rechazado automáticamente |
| RN06 | Una calificación solo puede dejarse si existe al menos una foto de evidencia y la confirmación del estado "entregado" |
| RN07 | El sistema bloquea automáticamente mensajes de chat que contengan patrones de números de teléfono (9 dígitos consecutivos), emails o URLs externas |
| RN08 | Un conductor no puede actualizar el estado de una parada fuera del orden secuencial definido |
| RN09 | El Trust Score se recalcula tras cada calificación usando el método Bayesiano anclado a un prior de 75/100 |
| RN10 | El Operador puede asignar un transportista manualmente solo a solicitudes con más de 24 horas sin ofertas (SLA vencido) |
| RN11 | Una incidencia activa retiene el cambio de estado del envío hasta ser resuelta por el Operador |
| RN12 | Un transportista no puede publicar un viaje disponible con capacidad mayor a la flota declarada y verificada |

---

### 7.4 Restricciones Técnicas

| ID | Restricción |
|----|-------------|
| RT01 | El backend debe implementarse con Quarkus (Java/Kotlin) |
| RT02 | El frontend web debe implementarse con Angular 18+ |
| RT03 | Las aplicaciones móviles deben implementarse con Flutter |
| RT04 | La base de datos debe ser PostgreSQL 16 |
| RT05 | El cálculo de distancias y rutas debe usar la API de OpenRouteService |
| RT06 | El sistema debe desplegarse en contenedores Docker |
| RT07 | El repositorio debe estar en GitHub con pipeline CI/CD mediante GitHub Actions |

---

## 8. Prototipos

Los prototipos navegables se desarrollan en Figma. Ver documento `E1_Prototipos.md` para el inventario completo de pantallas, flujos y decisiones de UX.

**Flujos principales a prototipar:**
- Flujo de registro y onboarding por rol
- Flujo PYME: crear solicitud → ver subasta → negociar → aceptar → tracking
- Flujo Transportista: ver marketplace → ofertar → recibir aceptación → ejecutar ruta
- Flujo Conductor: ver ruta → actualizar parada → subir evidencia
- Flujo Operador: dashboard → asignación manual → gestión de incidencias

---

## 9. Arquitectura del Sistema

Ver documento `E1_Arquitectura.md` para la descripción completa con diagramas C4.

**Resumen:** Monolito modular con Quarkus (backend), Angular (web), Flutter (mobile × 3 apps) y PostgreSQL. Cada módulo tiene límites de dominio claros para facilitar la migración futura a microservicios.

---

## 10. Modelado del Sistema (UML)

Ver documento `E1_UML.md` para los diagramas completos de casos de uso, clases y secuencia.

---

## 11. Trazabilidad de Requerimientos

| Requerimiento | Módulo del Sistema | Componente Principal |
|--------------|-------------------|---------------------|
| RF01–RF08 | AUTH | `auth-module` (Quarkus) + Login/Register (Angular/Flutter) |
| RF09–RF14 | SHIPMENT | `shipment-module` + ShipmentView (Angular/Flutter) |
| RF15–RF20 | AUCTION | `auction-module` + MarketplaceView |
| RF21–RF24 | TRIP | `trip-module` + TripPublishView |
| RF25–RF29 | NEGOTIATION | `negotiation-module` + ChatView |
| RF30–RF33 | SMART LOAD PLANNER | `routing-module` + LoadPlannerView |
| RF34–RF39 | TRACKING | `shipment-module` + TrackingView (Flutter Driver) |
| RF40–RF45 | REPUTATION | `reputation-module` + ProfileView |
| RF46–RF48 | DOCUMENTS | `documents-module` + DocumentsView |
| RF49–RF51 | NOTIFICATIONS | `notification-module` + NotificationCenter |
| RF52–RF55 | INCIDENTS | `incident-module` + IncidentPanel |
| RF56–RF60 | OPERATOR | `shipment-module` (operator policies) + OperatorDashboard |
| RF61–RF63 | RETURN LOAD | `routing-module` + ReturnLoadView |
| RF64–RF67 | FLEET | `carrier-module` + FleetManagement |

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

*LOGYX · E1 Especificación de Requerimientos del Sistema · SRS IEEE 29148 · Versión 1.0 · Junio 2026*
