# E1 — Prototipos Navegables
> Competencia CE0212 · Diseño de interfaces y flujos de usuario  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Herramienta: Figma  
> Versión: 1.0 · Junio 2026

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Herramienta** | Figma |
| **Link al prototipo** | *(agregar URL de Figma aquí)* |
| **Plataformas cubiertas** | Web (Angular) · Mobile iOS/Android (Flutter) |
| **Apps prototipadas** | LOGYX Business (PYME + Transportista) · LOGYX Driver · LOGYX Operator |
| **Estado** | Pendiente de diseño en Figma — estructura definida en este documento |

---

## 2. Inventario de Pantallas

### 2.1 Flujo de Autenticación (compartido entre todas las apps)

| ID | Pantalla | Actor | Descripción |
|----|----------|-------|-------------|
| AUTH-01 | Splash / Landing | Todos | Logo LOGYX, botones "Iniciar sesión" y "Registrarse" |
| AUTH-02 | Login | Todos | Email + contraseña, botón Google OAuth, link "¿Olvidaste tu contraseña?" |
| AUTH-03 | Registro — Paso 1 | Todos | Datos de cuenta: email, contraseña, confirmar contraseña |
| AUTH-04 | Registro — Paso 2 | PYME / Transportista | Datos de empresa: nombre, RUC (con validación en tiempo real), tipo de organización |
| AUTH-05 | Registro — Paso 2B | Conductor | Datos personales: nombre, DNI, número de licencia, empresa a la que pertenece |
| AUTH-06 | Verificación de email | Todos | Pantalla de espera con instrucción de revisar correo |
| AUTH-07 | Onboarding PYME | PYME | Bienvenida, resumen de pasos para empezar a publicar cargas |
| AUTH-08 | Onboarding Transportista | Transportista | Bienvenida, prompt para completar perfil de flota |

---

### 2.2 LOGYX Business — PYME

#### Dashboard y navegación

| ID | Pantalla | Descripción |
|----|----------|-------------|
| PYME-01 | Dashboard PYME | KPIs: envíos activos, en tránsito, entregados, gasto del mes. Actividad reciente. |
| PYME-02 | Sidebar / Nav | Items: Inicio, Mis Solicitudes, Marketplace, Cotizador, Documentos, Reputación, Notificaciones |

#### Gestión de solicitudes

| ID | Pantalla | Descripción |
|----|----------|-------------|
| PYME-03 | Mis Solicitudes | Lista de solicitudes con estado (badge), contador de ofertas, acceso al detalle |
| PYME-04 | Nueva Solicitud — Paso 1 | Origen (selector de ciudad + campo de dirección exacta), Destino |
| PYME-05 | Nueva Solicitud — Paso 2 | Peso (kg), tipo de carga (selector), descripción, fecha requerida |
| PYME-06 | Nueva Solicitud — Paso 3 | Preview del costo estimado con desglose: distancia, flete base, peajes, combustible. Confirmar publicación. |
| PYME-07 | Detalle de Solicitud | Mapa de ruta, estado actual, contador de subasta (tiempo restante), lista de ofertas recibidas |
| PYME-08 | Panel de Ofertas | Card por oferta: precio, nombre carrier (ofuscado hasta aceptar), Trust Score, badge verificado, botones "Aceptar" / "Negociar" / "Rechazar" |
| PYME-09 | Chat de Negociación | Hilo de mensajes con el transportista, campo de precio para contra-oferta, botón "Aceptar precio" |
| PYME-10 | Confirmación de Aceptación | Modal: resumen del trato (carrier, precio, vehículo), botón "Confirmar y contratar" |

#### Tracking

| ID | Pantalla | Descripción |
|----|----------|-------------|
| PYME-11 | Tracking del Envío | Mapa con ruta y paradas. Timeline de estados: pending → picked_up → in_transit → delivered. Código de tracking visible. |
| PYME-12 | Detalle de Parada | Estado de cada parada, ETA, foto de evidencia (visible tras entrega), firma del receptor |
| PYME-13 | Incidencia en Envío | Panel para reportar incidencia: categoría (selector), descripción, adjuntar foto. Estado de la resolución. |
| PYME-14 | Calificación Post-Entrega | Formulario: estrellas puntualidad (1–5), estrellas calidad del servicio (1–5), comentario opcional |

#### Herramientas

| ID | Pantalla | Descripción |
|----|----------|-------------|
| PYME-15 | Cotizador de Costos | Campos: origen, destino, peso, tipo de carga. Resultado: desglose de costo estimado + mapa de ruta con distancia y tiempo. |
| PYME-16 | Documentos | Lista de todos los documentos de la organización. Filtros por tipo y envío. Botón de descarga. |
| PYME-17 | Mi Reputación | Trust Score compuesto, métricas individuales (Payment Compliance, Payload Accuracy, etc.), historial de reseñas recibidas |
| PYME-18 | Notificaciones | Lista de notificaciones con ícono por tipo, timestamp, botón "Marcar todas como leídas" |

---

### 2.3 LOGYX Business — Transportista

#### Dashboard y navegación

| ID | Pantalla | Descripción |
|----|----------|-------------|
| CARR-01 | Dashboard Transportista | KPIs: envíos activos, ingresos del mes, tasa de ocupación de flota, calificación promedio |
| CARR-02 | Nav | Items: Inicio, Marketplace, Mis Envíos, Mi Flota, Viajes Disponibles, Retornos, Reputación, Notificaciones |

#### Marketplace y subastas

| ID | Pantalla | Descripción |
|----|----------|-------------|
| CARR-03 | Marketplace | Lista de solicitudes de carga rankeadas por compatibilidad. Filtros: ruta, peso, fecha. Badges de urgencia y precio. |
| CARR-04 | Detalle de Solicitud (Carrier) | Info de la carga (origen, destino, peso, tipo), precio sugerido, timer de subasta, botón "Hacer oferta" |
| CARR-05 | Formulario de Oferta | Precio a ofertar (con indicador respecto al mercado), selector de vehículo, notas, botón "Ofertar" |
| CARR-06 | Mis Ofertas Pendientes | Lista de ofertas enviadas con estado (pendiente, aceptada, rechazada), acceso al chat de negociación |
| CARR-07 | Chat de Negociación (Carrier) | Mismo layout que PYME-09 pero desde la perspectiva del transportista |

#### Publicación de viajes

| ID | Pantalla | Descripción |
|----|----------|-------------|
| CARR-08 | Publicar Viaje Disponible | Ruta (origen + paradas + destino), fecha y hora de salida, capacidad disponible (kg/m³), precio por kg |
| CARR-09 | Mis Viajes Publicados | Lista de viajes con ocupación actual / capacidad total. Cargas reservadas por cada PYME. |

#### Operaciones

| ID | Pantalla | Descripción |
|----|----------|-------------|
| CARR-10 | Mis Envíos (Carrier) | Lista de envíos asignados con estado y cliente (nombre ofuscado hasta aceptar) |
| CARR-11 | Smart Load Suggestions | Lista de combinaciones de carga sugeridas: ingreso combinado, % de ocupación, ruta propuesta, botón "Aceptar plan" |
| CARR-12 | Cargas de Retorno | Lista de cargas cercanas al destino final: distancia al recojo, compatibilidad (%), botón "Ofertar" |

#### Flota

| ID | Pantalla | Descripción |
|----|----------|-------------|
| CARR-13 | Mi Flota | Lista de vehículos con estado (disponible / en ruta / mantenimiento) y capacidad disponible |
| CARR-14 | Agregar / Editar Vehículo | Placa, tipo de vehículo, capacidad (kg, m³), tipos de carga aceptados, foto del vehículo |
| CARR-15 | Mis Conductores | Lista de conductores vinculados con estado y vehículo asignado |
| CARR-16 | Agregar Conductor | Nombre, DNI, número de licencia, teléfono |

---

### 2.4 LOGYX Driver (App del Conductor)

| ID | Pantalla | Descripción |
|----|----------|-------------|
| DRV-01 | Inicio / Mi Ruta | Resumen del viaje activo: origen, paradas, destino. Estado general. |
| DRV-02 | Lista de Paradas | Paradas ordenadas con estado (pendiente / en camino / entregado) y ETA de cada una |
| DRV-03 | Detalle de Parada | Dirección exacta, nombre del receptor, carga a entregar (kg, descripción), botón "Llegué" |
| DRV-04 | Confirmar Entrega | Paso 1: Tomar foto de la carga entregada. Paso 2: Capturar firma del receptor. Paso 3: Confirmar. |
| DRV-05 | Reportar Incidencia | Categoría (selector), descripción, foto del problema, enviar reporte |
| DRV-06 | Mapa de Navegación | Mapa con ruta completa, parada actual resaltada, botón "Iniciar navegación" (abre Google Maps / Waze) |
| DRV-07 | Sin Conexión | Pantalla de modo offline: muestra ruta cacheada, permite actualizar estados localmente, icono de sincronización pendiente |

---

### 2.5 LOGYX Operator (Panel del Operador)

| ID | Pantalla | Descripción |
|----|----------|-------------|
| OP-01 | Dashboard Operador | Métricas en tiempo real: solicitudes abiertas, en riesgo (SLA), en tránsito, entregadas. Gráficos de tendencia. |
| OP-02 | Solicitudes en Riesgo | Lista priorizada de solicitudes con más de 24h sin ofertas. Badges de urgencia por tiempo. |
| OP-03 | Asignación Manual | Modal: selector de transportista disponible (con Trust Score y capacidad), precio a asignar, confirmar. |
| OP-04 | Smart Load Opportunities | Lista de grupos de carga detectados por el algoritmo. Botón "Proponer a transportista". |
| OP-05 | Gestión de Incidencias | Lista de incidencias abiertas con prioridad, categoría y tiempo transcurrido. Botón "Resolver". |
| OP-06 | Resolución de Incidencia | Detalle de la incidencia, hilo de comentarios, selector de estado final del envío, botón "Confirmar resolución". |
| OP-07 | Vista Global de Envíos | Tabla de todos los envíos activos con filtros por estado, carrier, fecha y corredor. |

---

## 3. Flujos de Usuario (User Flows)

### Flujo 1 — PYME: Contratar transporte (happy path)

```
AUTH-01 → AUTH-02 → (onboarding) → PYME-01
→ PYME-03 → PYME-04 → PYME-05 → PYME-06 (solicitud publicada)
→ PYME-07 (subasta activa, esperar ofertas)
→ PYME-08 (ver oferta recibida)
→ PYME-09 (negociar si es necesario)
→ PYME-10 (confirmar contratación)
→ PYME-11 (seguimiento en tiempo real)
→ PYME-14 (calificar tras entrega)
```

### Flujo 2 — Transportista: Ofertar y ejecutar

```
AUTH-01 → AUTH-02 → AUTH-08 (onboarding) → CARR-13 (configurar flota)
→ CARR-01 → CARR-03 (explorar marketplace)
→ CARR-04 (ver solicitud) → CARR-05 (enviar oferta)
→ (notificación: oferta aceptada) → CARR-10 (ver envío asignado)
→ DRV-02 (conductor ejecuta ruta)
→ DRV-04 (confirmar entregas por parada)
→ (calificación recibida de la PYME)
```

### Flujo 3 — Conductor: Ejecutar ruta

```
(Login con credenciales del conductor)
→ DRV-01 (ver viaje activo)
→ DRV-06 (abrir mapa de navegación)
→ DRV-02 → DRV-03 (llegar a parada)
→ DRV-04 (foto + firma → confirmar entrega)
→ (repetir por cada parada)
→ DRV-01 (ruta completada)
```

### Flujo 4 — Operador: Gestionar solicitud en riesgo

```
OP-01 (dashboard — alerta SLA)
→ OP-02 (ver solicitudes en riesgo)
→ OP-03 (asignar carrier manualmente)
→ OP-07 (monitorear el envío creado)
```

### Flujo 5 — Transportista: Publicar viaje disponible

```
CARR-01 → CARR-08 (publicar viaje)
→ CARR-09 (ver reservas que lleguen de PYMEs)
→ CARR-10 (gestionar el viaje con múltiples cargas)
→ DRV-02 (conductor ejecuta multi-parada)
```

---

## 4. Principios de Diseño UX

| Principio | Aplicación en LOGYX |
|-----------|---------------------|
| **Información progresiva** | Solo se revelan datos sensibles (nombre exacto, dirección, RUC completo) después de que se formaliza el contrato |
| **Claridad del estado** | Cada solicitud, oferta y envío siempre muestra su estado con color y badge claro (verde = completado, amarillo = en proceso, rojo = en riesgo) |
| **Confianza visible** | Trust Score y badges siempre acompañan al perfil del carrier en el marketplace y en las ofertas |
| **Reducción de fricción** | El cotizador precalcula el precio antes de publicar; el formulario de oferta sugiere el precio de mercado |
| **Feedback inmediato** | Toasts/alerts de confirmación en cada acción importante (oferta enviada, oferta aceptada, estado actualizado) |
| **Separación por rol** | Tres apps distintas: la PYME/Carrier no ven las pantallas del conductor, el conductor no ve el marketplace |
| **Offline-first en Driver** | La app del conductor cachea la ruta y permite actualizaciones sin conexión |

---

## 5. Paleta de Colores y Tipografía (lineamientos para Figma)

| Elemento | Especificación |
|----------|---------------|
| **Color primario** | Azul oscuro #1A3A5C (confianza, profesionalismo) |
| **Color secundario** | Naranja #F5820A (acción, urgencia, CTAs principales) |
| **Color de éxito** | Verde #2ECC71 |
| **Color de alerta** | Amarillo #F39C12 |
| **Color de error** | Rojo #E74C3C |
| **Fondo** | Gris claro #F7F8FA |
| **Texto principal** | #1A1A2E |
| **Tipografía principal** | Inter (web) / Roboto (mobile) |
| **Tipografía tamaños** | H1: 28px, H2: 22px, Body: 16px, Caption: 12px |

---

## 6. Evidencia Requerida

| Item | Estado |
|------|--------|
| Diseño en Figma — Flujo Auth | Pendiente |
| Diseño en Figma — PYME (pantallas PYME-01 a PYME-18) | Pendiente |
| Diseño en Figma — Transportista (CARR-01 a CARR-16) | Pendiente |
| Diseño en Figma — Driver App (DRV-01 a DRV-07) | Pendiente |
| Diseño en Figma — Operator (OP-01 a OP-07) | Pendiente |
| Prototipo navegable con conexiones entre pantallas | Pendiente |
| Validación con usuario real (feedback documentado) | Pendiente |
| Link público de Figma actualizado en este documento | Pendiente |

---

*LOGYX · E1 Prototipos Navegables · Competencia CE0212 · Versión 1.0 · Junio 2026*
