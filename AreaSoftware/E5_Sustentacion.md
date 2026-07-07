# E5 — Sustentación del Sistema
> Competencia CE0217 · Video Pitch + Defensa Técnica ante Jurado  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Versión: 1.0 · Junio 2026

---

## 1. Información General

| Campo | Detalle |
|-------|---------|
| **Duración del video pitch** | 3–5 minutos |
| **Duración de la sustentación** | 20–30 minutos (demo + preguntas) |
| **Formato de demo** | Sistema en ejecución en vivo (staging + apps móviles) |
| **Link al video pitch** | *(agregar URL de YouTube / Drive aquí)* |
| **Fecha de sustentación** | *(agregar fecha)* |

---

## 2. Video Pitch

### 2.1 Estructura del Video (3–5 minutos)

| Segmento | Duración | Contenido |
|----------|---------|-----------|
| **Gancho** | 20 seg | Dato impactante: "El 65% de las PYMEs en el corredor Lima-Arequipa pierde al menos un envío al mes por coordinación deficiente." |
| **El problema** | 45 seg | Mostrar la realidad actual: PYMEs coordinan por WhatsApp, no saben el precio justo, no tienen trazabilidad. Los transportistas regresan vacíos. |
| **La solución** | 60 seg | LOGYX: plataforma que conecta PYMEs y transportistas con subasta inversa, negociación, Smart Load y tracking en tiempo real. |
| **Demo rápida** | 90 seg | Captura de pantalla del flujo: PYME publica → Carrier oferta → PYME acepta → Driver entrega → calificación. |
| **El valor** | 30 seg | Para la PYME: ahorro del 15-25% en costos. Para el carrier: más viajes llenos, menos retornos vacíos. Para el ecosistema: formalización del sector. |
| **El equipo** | 20 seg | Presentar brevemente a los 3 integrantes y sus roles. |
| **Cierre** | 15 seg | "LOGYX: La logística colaborativa para el Perú que crece." |

### 2.2 Guión del Pitch

**[GANCHO]**
> "¿Sabías que en el corredor Lima-Arequipa-Juliaca existen más de 8,000 PYMEs que mueven mercancía cada semana? Y la mayoría lo hace coordinando por WhatsApp, a precio de remate, sin saber si su carga llegó. Nosotros decidimos cambiar eso."

**[EL PROBLEMA]**
> "Hoy, una PYME que necesita transportar mercancía tiene que llamar a diez transportistas diferentes, negociar por teléfono sin saber si el precio es justo, y rezar para que la carga llegue. Del otro lado, el transportista sale a Lima y vuelve con el camión vacío porque no tiene forma de conseguir carga de retorno. El resultado: dinero que se pierde en ambos lados."

**[LA SOLUCIÓN]**
> "LOGYX es el sistema operativo logístico para PYMEs. Funciona como una plataforma bidireccional: las PYMEs publican sus cargas y reciben ofertas competitivas en minutos, los transportistas ven cargas disponibles en su ruta y ofertan el precio justo. Tenemos subasta inversa como InDrive, negociación bidireccional, motor de costos basado en rutas reales, y tracking en tiempo real con confirmación de entrega foto y firma. Además, nuestro Smart Load Planner detecta automáticamente cargas compatibles y sugiere al transportista cómo llenar su camión al máximo."

**[DEMO]**
> *(Mostrar capturas o demo en vivo del flujo completo: PYME publica → cotización → subasta → carrier oferta → acepta → tracking → entrega confirmada)*

**[EL VALOR]**
> "Para la PYME: reducción de hasta 25% en costos de flete por la presión competitiva de la subasta. Para el transportista: 30% más de viajes productivos gracias a las cargas de retorno y el Smart Load. Para el corredor: formalización del sector con reputación verificable, documentación digital y trazabilidad completa."

**[EL EQUIPO]**
> "Somos Jorge, Fabrizio y Alex. Ingeniería de Sistemas, Universidad Peruana Unión. Construimos LOGYX en Quarkus, Angular y Flutter, con PostgreSQL y PostGIS para toda la lógica geoespacial."

**[CIERRE]**
> "LOGYX: La logística colaborativa que el Perú necesita."

---

## 3. Demostración del Sistema

### 3.1 Casos de Uso a Demostrar

| ID | Caso | Actor | Duración estimada |
|----|------|-------|------------------|
| CU-DEMO-01 | PYME publica solicitud de carga y ve cotización | PYME | 3 min |
| CU-DEMO-02 | Carrier ve marketplace y envía oferta | Carrier | 2 min |
| CU-DEMO-03 | PYME acepta oferta y se crea el envío | PYME | 2 min |
| CU-DEMO-04 | Driver confirma entrega (foto + firma) | Driver (app móvil) | 3 min |
| CU-DEMO-05 | PYME sigue el estado del envío en tiempo real | PYME | 2 min |
| CU-DEMO-06 | Sistema de reputación post-entrega | PYME + Carrier | 2 min |
| CU-DEMO-07 | Operador resuelve incidencia | Operador | 2 min |
| CU-DEMO-08 | Smart Load Planner sugiere combinación | Carrier | 2 min |

### 3.2 Flujo de Demostración

```
Paso 1: Login como PYME (maria.torres@textilesarequipa.pe)
   → Mostrar dashboard con KPIs

Paso 2: Nueva solicitud de carga
   → Origen: Lima / Destino: Arequipa
   → Peso: 3,500 kg / Tipo: general
   → Mostrar cotización calculada: ~S/ 2,800
   → Publicar solicitud

Paso 3: Cambiar a cuenta Carrier (carlos@colcaexpress.pe)
   → Mostrar marketplace con la solicitud recién publicada
   → Enviar oferta: S/ 2,400 con vehículo A3T-456

Paso 4: Volver a PYME
   → Notificación: "Nueva oferta recibida"
   → Ver panel de ofertas con Trust Score del carrier
   → Aceptar la oferta

Paso 5: Mostrar app Driver (Juan Pablo Ramos)
   → Envío aparece en "Mi Ruta"
   → Simular llegada a parada
   → Tomar foto + capturar firma
   → Confirmar entrega

Paso 6: Volver a PYME web
   → Estado del envío → Delivered
   → Calificar al transportista: 5 estrellas

Paso 7: Panel del Operador
   → Mostrar dashboard con métricas globales
   → Mostrar gestión de incidencias
```

### 3.3 Preparación del entorno para la demo

> **Nota (verificado 2026-07-06):** este guion asume tres cosas que hoy no existen en el
> repositorio: el dominio `staging.logyx.pe` (no hay entorno de staging desplegado), el usuario
> de BD `logyx_dba_user` (ver `E2_Seguridad.md` §1.3/1.4 — el modelo de usuarios de mínimo
> privilegio está documentado pero no implementado; hoy solo existe el usuario único `logyx_app`
> de `docker-compose.yml`) y el script `scripts/demo_seed.sql` (no existe en el repo — el único
> seed real es la migración `V9__seed.sql`, y sus contraseñas son placeholders que no sirven para
> login, según la nota al final de `ROADMAP.md`). Antes de usar este guion literalmente para la
> sustentación, hay que: (1) decidir y desplegar un entorno real de demo, (2) crear el script de
> seed de demo, y (3) ajustar el usuario de BD al que realmente exista en ese entorno.

```bash
# Antes de la sustentación, ejecutar:

# 1. Verificar que staging está activo
curl -f https://staging.logyx.pe/q/health/live

# 2. Limpiar datos de prueba anteriores (si aplica)
psql -U logyx_dba_user -d logyx_db \
  -c "DELETE FROM shipment_requests WHERE created_at > NOW() - INTERVAL '1 day';"

# 3. Seed de datos de demo frescos
psql -U logyx_dba_user -d logyx_db -f scripts/demo_seed.sql

# 4. Verificar que las apps móviles están en el dispositivo de demo
# LOGYX Driver instalado en el teléfono de prueba

# 5. Abrir en paralelo:
#   - Browser Tab 1: Web como PYME (logyx.pe login PYME)
#   - Browser Tab 2: Web como Carrier (logyx.pe login Carrier)
#   - Browser Tab 3: Web como Operator (logyx.pe login Operator)
#   - Teléfono: App Driver
```

---

## 4. Explicación Técnica

### 4.1 Arquitectura

**Tipo:** Monolito modular reactivo  
**Justificación:** Arquitectura adecuada para un MVP con equipo pequeño. Los 14 módulos están desacoplados internamente y pueden extraerse a microservicios en etapas futuras sin cambiar los contratos de API. Ver ADR-001 en E1_Arquitectura.md.

**Componentes principales:**

| Componente | Tecnología | Rol |
|-----------|-----------|-----|
| Backend API | Quarkus 3 + Java 21 | Lógica de negocio, REST API, WebSocket |
| Frontend Web | Angular 18 | Interfaces PYME, Carrier, Operator |
| App PYME/Carrier | Flutter 3 | Versión móvil del Business app |
| App Driver | Flutter 3 (offline-first) | Ejecución de rutas, confirmación de entregas |
| Base de datos | PostgreSQL 16 + PostGIS | Persistencia + lógica geoespacial |
| Caché + PubSub | Redis 7 | Chat en tiempo real, caché de marketplace |
| Storage | MinIO (dev) / S3 (prod) | Fotos y documentos de entrega |
| Rutas | OpenRouteService API | Distancias y duraciones reales por carretera |

### 4.2 Decisiones Técnicas Clave

| Decisión | Tecnología elegida | Por qué / Por qué no la alternativa |
|---------|-------------------|------------------------------------|
| Backend | **Quarkus** | Startup ultra-rápido, Mutiny para async reactivo, excelente para contenedores. (Alternativa descartada: Spring Boot — más pesado, startup más lento) |
| 3 apps móviles separadas | **Flutter** | Misma codebase para iOS y Android. Apps separadas por UX radicalmente diferente entre PYME, Driver y Operator. |
| Base de datos | **PostgreSQL + PostGIS** | Relacional con soporte geoespacial nativo. (Alternativa descartada: MongoDB — ACID necesario para transacciones logísticas) |
| Rutas | **OpenRouteService** | API gratuita (~2K req/día), suficiente para el MVP. (Alternativa descartada: Google Maps Platform — costo por uso en producción) |
| Arquitectura | **Monolito modular** | Equipo de 3 personas, 8 meses. Microservicios añadirían complejidad operacional innecesaria en esta etapa. |

### 4.3 Integración del Sistema

```
[Angular / Flutter] 
    ↓ HTTP/REST + JWT
[Quarkus API Gateway]
    ↓
[14 Módulos Quarkus]
    ├── → PostgreSQL 16 (via Panache / Hibernate Reactive)
    ├── → Redis 7 (via Quarkus Redis Client)
    ├── → MinIO (via MinIO SDK)
    └── → OpenRouteService (via MicroProfile REST Client)
    
[Quarkus WebSocket]
    ↔ [Angular / Flutter] (chat en tiempo real)
    
[Quarkus Scheduler]
    → SmartLoadPlannerJob (cada 30 min)
    → AuctionCloseJob (cada 5 min)
```

### 4.4 Calidad del Sistema

| Área | Control implementado |
|------|---------------------|
| **Pruebas** | JUnit 5 (backend), flutter_test (mobile), Cypress E2E (web). Ver E4_PlanPruebas.md. |
| **CI/CD** | GitHub Actions: lint → test → build → deploy staging en cada merge a main. Ver E4_CICD.md. |
| **Seguridad** | JWT, bcrypt cost=12, TLS 1.3, RLS en PostgreSQL, OWASP Dependency Check semanal. Ver E4_Auditoria.md. |
| **Auditoría** | Trigger automático de auditoría en tablas críticas (shipments, bids, auctions, incidents). |
| **Estándar** | ISO/IEC 25010: funcionalidad, rendimiento, seguridad, mantenibilidad, portabilidad evaluadas. |

---

## 5. Banco de Preguntas y Respuestas para el Jurado

### Sobre Requerimientos

**¿Por qué elegir subasta inversa en lugar de precio fijo?**
> El modelo de precio fijo no refleja la realidad del mercado logístico peruano, donde los precios varían enormemente según disponibilidad, distancia y tipo de carga. La subasta inversa (como InDrive en transporte de personas) crea competencia real entre carriers, beneficiando a la PYME con el mejor precio. El price_floor del 75% protege al carrier de una carrera al fondo.

**¿Cómo garantizan que el precio sea justo para el transportista?**
> Tres mecanismos: (1) Price floor automático al 75% del precio sugerido, que el sistema calcula con distancias reales de ORS + costos de combustible actuales. (2) Loyalty tiers: carriers frecuentes pagan menos comisión (7% → 2%). (3) Smart Load Planner: el sistema sugiere combinaciones de carga que aumentan la rentabilidad por viaje.

### Sobre Datos

**¿Cómo se calcula el Trust Score?**
> Es un score compuesto de 0 a 100, calculado automáticamente por la función `fn_calculate_composite_score()` cada vez que llega una calificación. Pondera: tasa de éxito en entregas (25%), puntualidad (25%), daño de carga (15%), cancellations (15%), rating promedio bayesiano (20%). El prior bayesiano ancla a 75/100 para evitar que carriers nuevos con pocas calificaciones queden descalificados.

**¿Cómo evitan la desintermediación (que acuerden por fuera)?**
> Cuatro mecanismos: (1) Chat moderado: trigger en BD bloquea teléfonos, emails y handles antes de guardar el mensaje. (2) Nombre del carrier ofuscado hasta aceptar. (3) Insurance Moat: el seguro de carga solo aplica dentro de la plataforma. (4) Reputación: el score solo crece dentro de LOGYX, perderlo tiene un costo real de negocio.

**¿Por qué usan triggers en la BD y no solo lógica en el backend?**
> Los triggers garantizan consistencia incluso si el backend tiene un bug, se llama directamente a la BD (por migración o script), o en el futuro se añaden otros backends. La capacidad del vehículo (`trg_lock_vehicle_capacity`) y la moderación de mensajes (`trg_moderate_message`) son invariantes de negocio que deben ser inviolables a nivel de datos.

### Sobre Implementación

**¿Por qué Quarkus y no Spring Boot?**
> Spring Boot tiene un startup de ~3-8 segundos. Quarkus arranca en ~300ms en modo JVM y ~50ms en modo nativo. En un entorno cloud donde los contenedores escalan rápido, esto hace diferencia. Además, el modelo reactivo de Mutiny en Quarkus nos permite manejar muchas conexiones concurrentes (WebSocket del chat + SSE de tracking) sin bloquear threads.

**¿Cómo funciona el modo offline de la app del conductor?**
> Usamos Drift (SQLite en Flutter) para cachear la ruta completa con sus paradas cuando el conductor inicia el viaje. Los cambios de estado (parada entregada, foto capturada) se guardan en SQLite localmente con un flag `syncPending: true`. Un servicio de background en la app revisa la conexión cada 30 segundos y sube los cambios pendientes cuando hay señal.

**¿Cómo manejan la concurrencia en las subastas?**
> Dos mecanismos: (1) La constraint `UNIQUE (auction_id, carrier_org_id)` en `bids` garantiza que un carrier no envíe dos ofertas simultáneas para la misma subasta. (2) El trigger `trg_close_auction_on_max_bids` cierra la subasta cuando se alcanza `max_bids`, pero usa `WHERE status = 'open'` con lock implícito de PostgreSQL, evitando la condición de carrera.

### Sobre Calidad

**¿Qué pasa si el sistema cae durante un envío activo?**
> La app del Driver cachea la ruta offline. El backend tiene health checks (`/q/health/live`) y Docker reinicia el contenedor automáticamente. Las migraciones Flyway garantizan que al reiniciar la BD tiene el estado correcto. El objetivo de disponibilidad es 99%, con RPO < 1h (WAL archiving) y RTO < 2h (según nuestros objetivos de E4_Auditoria.md).

**¿Cómo escalarán cuando tengan más usuarios?**
> El monolito está diseñado para escalar horizontalmente: los contenedores no guardan estado (JWT + Redis para sesiones, MinIO para archivos). Al escalar a múltiples instancias, Redis actúa como bus de Pub/Sub para el WebSocket del chat. Para escala mayor: PgBouncer reduce la presión de conexiones a PostgreSQL. Los módulos `smartload` y `pricing` son los primeros candidatos a extraer como microservicios independientes.

---

## 6. Evidencia

| Item | Estado |
|------|--------|
| Video pitch (3–5 min) | Pendiente — agregar link |
| Diapositivas de sustentación | Pendiente |
| URL del sistema en staging para demo | Pendiente |
| APK del Driver App para demo | Pendiente |
| Certificado de CI/CD passing | Pendiente — screenshot de GitHub Actions |

---

*LOGYX · E5 Sustentación · Competencia CE0217 · Versión 1.0 · Junio 2026*
