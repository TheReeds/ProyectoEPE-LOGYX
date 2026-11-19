# E2 — Scripts de Base de Datos
> Competencias CE0222 (DDL + DML) · CE0223 (Procedimientos, Funciones y Triggers)  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Motor: PostgreSQL 16  
> Versión: 2.1 (scripts reales V1–V24; la v2.0 cubría V1–V12) · Noviembre 2026 · Versión original 1.0, junio 2026

!!! info "Scripts reales"
    Los scripts de la v1.0 (enums nativos, PostGIS, funciones y *triggers* de negocio, semilla SQL) eran un diseño previo. Esta versión muestra los **scripts que ejecuta realmente el sistema**: las veinticuatro migraciones Flyway del repositorio (V1–V12 se muestran incrustadas abajo; V13–V24 están en la carpeta `sql/`) (`backend/src/main/resources/db/migration/`), copiadas aquí como *snapshot* en `docs/software/entregable-2/sql/` e incrustadas desde el archivo, de modo que el texto mostrado es el SQL real y no una transcripción. La fuente vigente es siempre el repositorio del sistema.

---

## 1. Estructura de Scripts

| Archivo | Contenido |
|---------|-----------|
| `V1__schema.sql` | DDL base: organizaciones, usuarios, flota, solicitudes, subastas, ofertas, envíos, paradas, auditoría |
| `V2__row_level_security.sql` | Rol `logyx_app`, funciones `app_org()`/`app_org_type()`, `GRANT`s, RLS y políticas |
| `V3__contract_additions.sql` | Denormalización `bids.vehicle_type/vehicle_plate` con *backfill* |
| `V4__negotiation.sql` | Mensajes y contraofertas |
| `V5__documents.sql` | Documentos (metadatos; el archivo va a MinIO por la API S3, en el VPS y en staging local) |
| `V6__reputation.sql` | Calificaciones y Trust Score |
| `V7__incident.sql` | Incidencias y comentarios |
| `V8__notification.sql` | Notificaciones |
| `V9__operator.sql` | Escrituras acotadas del operador (RN10) |
| `V10__trip.sql` | Viajes, reservas, Smart Load |
| `V11__outbox.sql` | Outbox transaccional |
| `V12__realtime.sql` | Proyección de tiempo real + trigger `NOTIFY` |
| `V13__flow_gaps.sql` | Huecos de flujo de la revisión del 16-nov: verificación de organizaciones por el operador, retiro de ofertas, cancelación con motivo, estado final del envío al resolver una incidencia (RF55), republicar |
| `V14__accounts_and_roles.sql` | Tokens de contraseña y *refresh*, versión de sesión, roles ADMIN/OPS/VIEWER (ADR-0009) |
| `V15__audit_and_bidder_read.sql` | Auditoría paginada del operador y lectura de la posición del ofertante |
| `V16__per_person_notifications.sql` | Avisos por persona (`app_profile()`), preferencias por categoría y canal, autoría |
| `V17__request_details_places_search.sql` | Libreta de direcciones, claves de idempotencia, detalle de la solicitud, búsqueda |
| `V18__system_parameters_commission_terms.sql` | Parámetros del sistema con historial, comisión y aceptación de términos (ADR-0010) |
| `V19__stop_contacts_tracking_links.sql` | Contactos por parada y enlaces públicos de seguimiento (ADR-0011) |
| `V20__fleet_hygiene_and_bid_agenda.sql` | Archivado de flota, licencia única y agenda del vehículo para RN02 por fecha |
| `V21__templates_preferences_backup_offers.sql` | Plantillas y cargas recurrentes, preferidos/bloqueados y segunda oferta (ADR-0013) |
| `V22__carrier_alerts_fleet_docs_bid_improvement.sql` | Búsquedas guardadas y alertas, documentos de flota con vencimiento, historial de ofertas, vista `lane_price_stats` |
| `V23__execution_adjustments_incidents_operator360.sql` | Ajustes del envío y precio final (ADR-0012), incidencias v2, cambio de RUC y guardas de integridad |
| `V24__finance_settings_mail_preferences.sql` | Cobros sin pasarela, tarifario, calendario, cola de correo y preferencias (ADR-0014) |
| `R__local_roles.sql` | **Solo dev/test:** crea `logyx_api` (en producción lo hace `init-roles.sh`) |
| `init-roles.sh` | **Producción:** crea `logyx_owner`, `logyx_app`, `logyx_api` y la BD |

Flyway corre al arrancar (`quarkus.flyway.migrate-at-start=true`) con el datasource privilegiado (`logyx_owner`); en dev/test agrega la ubicación `db/local-roles`.

---

## 2. CE0222 — DDL: Creación de Estructura

### V1__schema.sql — esquema base

```sql
--8<-- "docs/software/entregable-2/sql/V1__schema.sql"
```

### V3__contract_additions.sql — migración aditiva con *backfill*

```sql
--8<-- "docs/software/entregable-2/sql/V3__contract_additions.sql"
```

### V11__outbox.sql — outbox transaccional

```sql
--8<-- "docs/software/entregable-2/sql/V11__outbox.sql"
```

Las demás tablas siguen el mismo patrón (UUID, `VARCHAR + CHECK`, claves foráneas, columnas de organización denormalizadas, índices parciales); su definición completa está en los archivos `V4`–`V10` y se resume en el [Modelo de Datos](modelo-datos.md).

---

## 3. CE0222 — DML: Datos Iniciales

Las migraciones **no insertan datos**: en producción la base arranca vacía y las cuentas se crean desde `/registro`; las cuentas de operador las crea OnCargo (no hay registro público para ese rol). Los datos de demostración se generan **por código**, solo en el perfil `dev`: `pe.logyx.devdata.DemoDataSeeder` (anotado `@IfBuildProfile("dev")`, idempotente) invoca los **casos de uso reales** autenticado como cada usuario demo, de modo que el seed respeta las reglas de negocio y corre bajo RLS exactamente como una llamada HTTP. Crea organizaciones, flota, solicitudes y subastas, un envío entregado con evidencia, calificaciones, una incidencia, chats y contraofertas, viajes publicados y una sugerencia Smart Load, con las cuentas `pyme@logyx.pe`, `carrier@logyx.pe`, `carrier2@logyx.pe`, `driver@logyx.pe` y `operator@logyx.pe`.

---

## 4. CE0223 — Funciones, Triggers y lógica en la base

Decisión de diseño: **las reglas de negocio (RN01–RN12) viven en el dominio Java** (políticas con nombre, probadas con JUnit), no en *triggers* ni procedimientos; reduce el acoplamiento al motor y facilita las pruebas. En la base de datos quedan solo los objetos que expresan seguridad o mensajería:

### Funciones de contexto (V2)

```sql
CREATE OR REPLACE FUNCTION app_org() RETURNS UUID
    LANGUAGE sql STABLE AS
$$ SELECT nullif(current_setting('app.org_id', true), '')::uuid $$;

CREATE OR REPLACE FUNCTION app_org_type() RETURNS TEXT
    LANGUAGE sql STABLE AS
$$ SELECT nullif(current_setting('app.org_type', true), '') $$;
```

`app_org()` devuelve la organización del usuario autenticado (fijada por `TenantSessionBinder` con `set_config('app.org_id', …, true)` al iniciar la transacción) o `NULL` si no hay contexto, en cuyo caso **ninguna política devuelve filas** (fail-closed). También la usa `outbox_events.actor_org_id DEFAULT app_org()`.

### Trigger de tiempo real (V12)

```sql
--8<-- "docs/software/entregable-2/sql/V12__realtime.sql"
```

El trigger `realtime_events_notify` emite `pg_notify('logyx_realtime', seq)` al confirmarse la transacción; cada instancia de la API tiene un hilo `LISTEN` que lee la fila real por `seq` (un NOTIFY forjado no inventa eventos).

### Reglas codificadas como restricciones

| Regla | Mecanismo en la BD |
|---|---|
| Una oferta por transportista y subasta | `UNIQUE (auction_id, carrier_org_id)` |
| Un envío por solicitud y por oferta | `UNIQUE` en `shipments.request_id` y `shipments.bid_id` |
| Una incidencia activa por envío (RN11) | índice único parcial `ux_incidents_active` |
| Una contraoferta pendiente por oferta | índice único parcial `ux_counter_offers_pending` |
| Una calificación por parte (RN06) | `UNIQUE (shipment_id, reviewer_org_id)` |
| Capacidad confirmada ≤ capacidad (RN12) | `CHECK (confirmed_weight_kg <= capacity_kg)` |
| Orden de paradas (RN08) | `UNIQUE (shipment_id, sequence)` (la secuencia la valida `StopSequencePolicy`) |
| Evidencia y auditoría inmutables | `REVOKE UPDATE, DELETE` sobre `documents`, `reviews`, `audit_log` |

---

## 5. Roles y permisos (scripts)

### V2__row_level_security.sql

```sql
--8<-- "docs/software/entregable-2/sql/V2__row_level_security.sql"
```

### infra/db/init-roles.sh (producción)

```bash
--8<-- "docs/software/entregable-2/sql/init-roles.sh"
```

### R__local_roles.sql (solo dev/test)

```sql
--8<-- "docs/software/entregable-2/sql/R__local_roles.sql"
```

---

## 6. Resumen de Objetos de Base de Datos

| Tipo | Cantidad | Detalle |
|------|----------|---------|
| **Migraciones** | 24 (+ 1 repetible local) | V1–V24 |
| **Tablas** | 57 (56 con RLS activada) | Ver [Modelo de Datos](modelo-datos.md) |
| **Enums nativos** | 0 | `VARCHAR + CHECK` |
| **Extensiones** | 0 | `gen_random_uuid()` nativo |
| **Índices** | 183 (86 únicos y 40 parciales, incluidas las claves primarias) | `pg_indexes` tras aplicar V1–V24 |
| **Funciones** | 9 | `app_org()`, `app_org_type()`, `app_profile()`, `app_driver_id()`, `app_is_blocked_by()`, `realtime_events_notify()` y tres guardas de integridad (`organizations_guard_verification`, `profiles_guard_operator_suspension`, `shipment_settlements_guard`) |
| **Triggers** | 4 | `realtime_events_notify` y los tres de las guardas anteriores |
| **Roles** | 3 | `logyx_owner`, `logyx_app`, `logyx_api` |
| **Políticas RLS** | 150 | `pg_policies` tras aplicar V1–V24 |
| **Vistas** | 1 | `lane_price_stats` (estadísticas de precio por ruta) |
| **Claves foráneas / `CHECK`** | 178 / 131 | `pg_constraint` |

*Conteo del 19-nov-2026: las 24 migraciones se aplicaron en un PostgreSQL 16 limpio con los tres roles de `infra/db/init-roles.sh` y se consultó el catálogo del sistema.*

---

*OnCargo · E2 Scripts de Base de Datos · Competencias CE0222–CE0223 · Versión 2.1 · Noviembre 2026*
