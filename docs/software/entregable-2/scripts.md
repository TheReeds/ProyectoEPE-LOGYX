# E2 — Scripts de Base de Datos
> Competencias CE0222 (DDL + DML) · CE0223 (Procedimientos, Funciones y Triggers)  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Motor: PostgreSQL 16  
> Versión: 2.0 (scripts reales V1–V12) · Noviembre 2026 · Versión original 1.0, junio 2026

!!! info "Scripts reales"
    Los scripts de la v1.0 (enums nativos, PostGIS, funciones y *triggers* de negocio, semilla SQL) eran un diseño previo. Esta versión muestra los **scripts que ejecuta realmente el sistema**: las doce migraciones Flyway del repositorio (`backend/src/main/resources/db/migration/`), copiadas aquí como *snapshot* en `docs/software/entregable-2/sql/` e incrustadas desde el archivo, de modo que el texto mostrado es el SQL real y no una transcripción. La fuente vigente es siempre el repositorio del sistema.

---

## 1. Estructura de Scripts

| Archivo | Contenido |
|---------|-----------|
| `V1__schema.sql` | DDL base: organizaciones, usuarios, flota, solicitudes, subastas, ofertas, envíos, paradas, auditoría |
| `V2__row_level_security.sql` | Rol `logyx_app`, funciones `app_org()`/`app_org_type()`, `GRANT`s, RLS y políticas |
| `V3__contract_additions.sql` | Denormalización `bids.vehicle_type/vehicle_plate` con *backfill* |
| `V4__negotiation.sql` | Mensajes y contraofertas |
| `V5__documents.sql` | Documentos (metadatos; el archivo va a Cloudflare R2 en producción, MinIO en staging local) |
| `V6__reputation.sql` | Calificaciones y Trust Score |
| `V7__incident.sql` | Incidencias y comentarios |
| `V8__notification.sql` | Notificaciones |
| `V9__operator.sql` | Escrituras acotadas del operador (RN10) |
| `V10__trip.sql` | Viajes, reservas, Smart Load |
| `V11__outbox.sql` | Outbox transaccional |
| `V12__realtime.sql` | Proyección de tiempo real + trigger `NOTIFY` |
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
| **Migraciones** | 12 (+ 1 repetible local) | V1–V12 |
| **Tablas** | 24 | Ver [Modelo de Datos](modelo-datos.md) |
| **Enums nativos** | 0 | `VARCHAR + CHECK` |
| **Extensiones** | 0 | `gen_random_uuid()` nativo |
| **Índices** | 36 (12 únicos o parciales) | `CREATE INDEX` en V1–V12 |
| **Funciones** | 3 | `app_org()`, `app_org_type()`, `realtime_events_notify()` |
| **Triggers** | 1 | `realtime_events_notify` |
| **Roles** | 3 | `logyx_owner`, `logyx_app`, `logyx_api` |
| **Políticas RLS** | 62 | `CREATE POLICY` en V2 y V4–V12 |

---

*OnCargo · E2 Scripts de Base de Datos · Competencias CE0222–CE0223 · Versión 2.0 · Noviembre 2026*
