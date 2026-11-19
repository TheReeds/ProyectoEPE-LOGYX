# E2 — Seguridad de Base de Datos
> Competencia CE0224 · Usuarios, Roles, Backup, Auditoría y Optimización  
> Proyecto: OnCargo — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Motor: PostgreSQL 16  
> Versión: 2.0 (alineada con ADR-0001 y ADR-0006) · Noviembre 2026 · Versión original 1.0, junio 2026

!!! success "Row-Level Security: IMPLEMENTADO"
    La v1.0 de este documento incluía la nota *"RLS no implementado en el MVP"*. Esa nota **quedó superada**: RLS está implementada y probada desde la migración `V2__row_level_security.sql` (extendida en V4–V24; 150 políticas en 56 tablas) y el modelo de roles se rehízo con mínimo privilegio real (ADR-0006). Los roles `logyx_analytics`, `logyx_readonly` y `logyx_dba` de la v1.0 eran un diseño que no se construyó; el sistema real usa tres roles. Las secciones de backup, cifrado y ajuste de rendimiento se conservan como **plan operativo de producción** y se marcan como tales.

---

## 1. Modelo de Usuarios y Roles de Base de Datos

OnCargo aplica el principio de **mínimo privilegio** con tres roles (`infra/db/init-roles.sh`; en dev/test `db/local-roles/R__local_roles.sql`):

| Rol | Atributos | Quién lo usa | Permisos |
|---|---|---|---|
| `logyx_owner` | LOGIN, dueño de la BD y del esquema; **sin** `SUPERUSER` ni `BYPASSRLS` | Flyway (migraciones) y `SystemTx` (datasource por defecto, pool chico: 8) | Crea objetos; salta RLS solo por ser dueño de las tablas |
| `logyx_app` | NOLOGIN, `NOBYPASSRLS` | Nadie se conecta con él: `SET LOCAL ROLE logyx_app` en cada transacción de usuario | `SELECT/INSERT/UPDATE/DELETE` sobre las tablas **sujeto a RLS**; `REVOKE` explícitos (p. ej. sin `UPDATE/DELETE` en `audit_log`, `documents`, `reviews`; sin `INSERT` en `notifications`) |
| `logyx_api` | LOGIN, `INHERIT`, miembro **solo** de `logyx_app`, `CONNECTION LIMIT 50` | La aplicación (datasource `app`, pool: 20) | Lo de `logyx_app`; no es dueño de nada, no puede `SET ROLE` a otro rol ni `ALTER`/`DROP POLICY` |

### 1.1 Dos datasources, un enrutador

Hibernate usa la multitenencia `DATABASE` **solo como enrutador** (`shared/tenancy/DataSourceRouting`): el *tenant* `app` (por omisión, conexión `logyx_api`) y el *tenant* `system` (conexión `logyx_owner`), que se activa solo dentro de `SystemTx.call(...)`. Cada uso de `SystemTx` va comentado con su justificación (login, registro, jobs de cierre de subastas, outbox, seed dev, unicidad global de placa/email).

**Fail-closed:** una transacción sin JWT y fuera de `SystemTx` corre como `logyx_api` sin `app.org_id`, por lo que las políticas no devuelven ninguna fila.

### 1.2 Separación por entorno

| Entorno | Roles | Credenciales |
|---|---|---|
| dev / test | `logyx_api` creado por `R__local_roles.sql` (contraseña de desarrollo); Dev Services levanta PostgreSQL | Fijas, no sensibles |
| contenedores / prod | `init-roles.sh` con `LOGYX_OWNER_PASSWORD` y `LOGYX_APP_PASSWORD` | Por variables de entorno (`DB_ADMIN_*`, `DB_APP_*`); nunca en el repositorio (`infra/.env` ignorado) |

---

## 2. Seguridad de Datos

### 2.1 Cifrado y credenciales

| Capa | Mecanismo |
|------|-----------|
| Contraseñas de usuario | Hash bcrypt (`BcryptPasswordHasher`); la BD solo guarda `password_hash` |
| Claves JWT | Par RSA montado como secreto (`infra/scripts/gen-jwt-keys.sh` → `infra/secrets/`, ignorado por git) |
| Disco y backups | Cifrado de volumen y de backups: **plan de producción** (§3) |
| Archivos | Bucket privado S3-compatible (Cloudflare R2 en producción, MinIO en staging); SSE-S3 opcional (`LOGYX_S3_SSE=true`; R2 ya cifra en reposo: verificar al integrar) |

### 2.2 Cifrado en tránsito

PostgreSQL (y MinIO en staging) no se exponen fuera de la red interna del compose; TLS se termina en un proxy delante de la web y la API (HSTS en prod). Para una BD gestionada se exige `sslmode=require` en `DB_URL`.

### 2.3 Row-Level Security (RLS) — implementada

**Mecanismo.** Al iniciar cada transacción de un usuario autenticado, `TenantSessionBinder` ejecuta:

```sql
SELECT set_config('app.org_id', '<uuid de la org del JWT>', true),
       set_config('app.org_type', 'PYME|CARRIER|OPERATOR', true);
SET LOCAL ROLE logyx_app;
```

Las funciones `app_org()` y `app_org_type()` leen ese contexto; las políticas (`CREATE POLICY ... TO logyx_app`) deciden por fila. Si el código de aplicación olvida un `WHERE`, la base igual filtra.

**Matriz de visibilidad (resumen de las 62 políticas de V1–V12; hoy son 150 en V1–V24, con el mismo patrón por organización):**

| Tabla | Quién lee | Quién escribe |
|---|---|---|
| `organizations` | Todos (perfil público) | Solo la propia org (`orgs_update_own`) |
| `profiles`, `vehicles`, `drivers` | Su organización; operador en lectura | Su organización |
| `shipment_requests` | La PYME dueña; transportistas: `PUBLISHED` y las adjudicadas a ellos; operador | La PYME dueña; operador solo `UPDATE` (V9, asignación) |
| `bids` | El transportista las suyas; la PYME las de sus solicitudes; **un transportista nunca ve el monto de otro**; operador | Transportista (`bids_carrier`), PYME (aceptar/rechazar), operador solo con `assigned_by_operator = true` |
| `shipments`, `shipment_stops` | Las dos partes del contrato; operador | Las dos partes; operador `INSERT` (asignación manual) |
| `messages`, `counter_offers`, `documents`, `incidents`, `incident_comments` | Las dos partes (+ operador) | Las partes, con `CHECK` de pertenencia al par |
| `reviews`, `reputation_scores` | Públicas | `reviews`: parte del envío (sin `UPDATE/DELETE`); `reputation_scores`: **nadie** vía RLS, solo el recálculo en `SystemTx` |
| `notifications` | La org destinataria | `UPDATE` (marcar leída) propia; **sin `INSERT`** para la app: solo `NotificationPublisher` en `SystemTx` |
| `carrier_trips`, `trip_bookings`, `smart_load_*` | Dueño; PYME ve viajes `OPEN/FILLING` y los que reservó | Dueño / PYME que reserva |
| `outbox_events` | Nadie (la app no lee) | Solo `INSERT` con `actor_org_id = app_org()` |
| `realtime_events` | Su org, o difusión a su tipo de org | Nadie vía RLS (proyección en `SystemTx`) |
| `audit_log` | Su organización; operador todo | Solo `INSERT` propio; sin `UPDATE/DELETE` |

Ejemplos reales:

```sql
CREATE POLICY bids_carrier ON bids FOR ALL TO logyx_app
    USING (carrier_org_id = app_org()) WITH CHECK (carrier_org_id = app_org());
CREATE POLICY bids_requester_read ON bids FOR SELECT TO logyx_app
    USING (requester_org_id = app_org());
CREATE POLICY requests_marketplace ON shipment_requests FOR SELECT TO logyx_app
    USING (app_org_type() = 'CARRIER' AND (status = 'PUBLISHED' OR assigned_carrier_org_id = app_org()));
```

El texto completo de todas las políticas está en [Scripts SQL](scripts.md#v2__row_level_securitysql).

**Operador con RLS, no con `SystemTx` (ADR-0004).** La asignación manual (RN10) corre como el operador y V9 agrega políticas acotadas a `app_org_type() = 'OPERATOR'`; así la acción queda auditada con la organización operadora.

**Verificación.** `RowLevelSecurityTest` (aislamiento entre organizaciones directamente contra PostgreSQL), `DatabasePrivilegesTest` (`RESET ROLE`, `SET ROLE`, `ALTER`, `DROP POLICY` fallan con SQLSTATE 42501), `OutboxTest` y `RealtimeStreamFlowTest` (aislamiento del tiempo real).

**Riesgo residual (documentado en ADR-0006).** Con una inyección SQL dentro de una transacción de usuario, `set_config('app.org_id', …)` permitiría suplantar a otra organización dentro de lo que `logyx_app` puede hacer. Mitigación: consultas parametrizadas (JPA) y revisión; evolución prevista: firmar el contexto (HMAC en el GUC verificado por las políticas).

---

## 3. Estrategia de Backup (plan de producción en el VPS)

!!! warning "Plan de producción; en el VPS de pruebas ya hay respaldo diario cifrado (v2.2)"
    Desde el 19-nov-2026 el VPS ejecuta `infra/vps/backup.sh` cada día: `pg_dump -Fc`, documentos de MinIO y secretos, cifrados con age, con 14 días de retención local y una prueba de restauración con conteos (ver [Implementación de Datacenter, 2.2–2.3](../../infraestructura/semestre-2/implementacion-datacenter.md)). Lo que sigue pendiente de este plan es la **copia en R2** y la retención de 30 días. En producción, los respaldos se guardarán **fuera del servidor**, en **Cloudflare R2** (bucket `oncargo-backups`), de modo que la pérdida del VPS no destruye las copias. Diseño completo en [Planificación de Seguridad](../../infraestructura/semestre-1/planificacion-seguridad.md) (POL-03).


### 3.1 Tipos de Backup

| Tipo | Frecuencia | Retención | Herramienta |
|------|-----------|-----------|-------------|
| **Backup completo (full dump)** | Diario (02:00, hora de Lima) | 30 días (regla de ciclo de vida de R2) | `pg_dump -Fc` cifrado, hacia R2 |
| **Dump previo a un despliegue con migraciones** | Antes de cada despliegue mayor | 90 días | `pg_dump -Fc` manual |
| **Archivado de WAL (opcional, para RPO < 24 h)** | Continuo | 7 días de WAL | pgBackRest o WAL-G hacia R2 (no se activa en el MVP) |
| **Documentos** | Continuo | Sin expiración (evidencia contractual) | Cloudflare R2 (`oncargo-documents`) |
| **Snapshot del VPS** | Antes de cambios de sistema operativo, si el plan lo permite | Último | Panel de Hostinger |

### 3.2 Scripts de Backup

```bash
#!/bin/bash
# /opt/oncargo/scripts/backup_daily.sh
# Ejecutado por cron (TZ=America/Lima): 0 2 * * * /opt/oncargo/scripts/backup_daily.sh

set -euo pipefail

DB_NAME="logyx"                      # nombre técnico de la BD (se conserva tras el rebrand)
DB_USER="logyx_owner"                # dueño: puede leer todo para el dump
BACKUP_DIR="/var/backups/oncargo"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/oncargo_full_${DATE}.dump"
ENCRYPT_KEY="${ONCARGO_BACKUP_ENCRYPTION_KEY}"
R2_ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"

# 1. Dump en formato custom (comprimido, restaurable parcialmente), desde el contenedor db
docker compose -f /opt/oncargo/infra/docker-compose.yml exec -T db pg_dump \
    --username="${DB_USER}" \
    --format=custom --compress=9 \
    "${DB_NAME}" > "${BACKUP_FILE}"

# 2. Cifrar y eliminar el archivo sin cifrar
openssl enc -aes-256-cbc -pbkdf2 -k "${ENCRYPT_KEY}" \
    -in "${BACKUP_FILE}" -out "${BACKUP_FILE}.enc"
rm "${BACKUP_FILE}"

# 3. Subir a Cloudflare R2 (API S3) con un token que solo puede escribir en oncargo-backups
aws s3 cp "${BACKUP_FILE}.enc" \
    "s3://oncargo-backups/db/$(date +%Y/%m/)" \
    --endpoint-url "${R2_ENDPOINT}"

# 4. Eliminar copias locales de más de 7 días (la retención de 30 días la aplica R2)
find "${BACKUP_DIR}" -name "*.enc" -mtime +7 -delete

echo "[$(date)] Backup completado: ${BACKUP_FILE}.enc"
```

### 3.3 Procedimiento de Restauración

```bash
# Paso 1: descargar y descifrar el respaldo elegido
aws s3 cp "s3://oncargo-backups/db/2026/11/oncargo_full_20261116_020000.dump.enc" . \
    --endpoint-url "${R2_ENDPOINT}"

openssl enc -aes-256-cbc -pbkdf2 -d \
    -k "${ONCARGO_BACKUP_ENCRYPTION_KEY}" \
    -in oncargo_full_20261116_020000.dump.enc \
    -out oncargo_full_20261116_020000.dump

# Paso 2: restaurar sobre una base nueva (en un entorno local o en el VPS nuevo)
createdb --username=postgres logyx_restored

pg_restore \
    --username=postgres \
    --dbname=logyx_restored \
    --no-owner --no-acl --jobs=2 \
    oncargo_full_20261116_020000.dump

# Paso 3: los roles logyx_owner / logyx_app / logyx_api los crea infra/db/init-roles.sh
# antes de restaurar; luego se reasignan los GRANT y las políticas RLS (vienen en el dump).
echo "Restauración completada. Verificar: SELECT COUNT(*) FROM shipments;"
```

### 3.4 Prueba de Backups (RTO / RPO)

| Métrica | Objetivo | Procedimiento de verificación |
|---------|---------|-------------------------------|
| **RPO** (máx. pérdida de datos) | 24 h con el dump diario (< 1 hora solo si se activa el archivado de WAL) | Dump diario; WAL a R2 opcional |
| **RTO** (tiempo de recuperación) | 2–4 horas (nuevo VPS + restauración) | Prueba mensual de restauración en un entorno local |
| **Verificación de integridad** | Mensual | Restaurar en un entorno local, ejecutar consultas de validación |

```sql
-- Script de validación post-restauración
DO $$
DECLARE
    v_orgs     INTEGER;
    v_ships    INTEGER;
    v_reviews  INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_orgs    FROM organizations;
    SELECT COUNT(*) INTO v_ships   FROM shipments;
    SELECT COUNT(*) INTO v_reviews FROM reviews;

    ASSERT v_orgs > 0,     'ERROR: organizations vacía — restauración fallida';
    ASSERT v_ships >= 0,   'ERROR: shipments inaccesible';
    ASSERT v_reviews >= 0, 'ERROR: reviews inaccesible';

    RAISE NOTICE 'Validación OK — orgs: %, shipments: %, reviews: %',
        v_orgs, v_ships, v_reviews;
END $$;
```

---

## 4. Auditoría de Base de Datos

### 4.1 Mecanismo real

La auditoría se registra **desde la aplicación** (no con *triggers*): cada caso de uso crítico llama a `audit.record(profileId, orgId, acción, entidad, entityId, detalle)` dentro de su transacción, y la fila se inserta en `audit_log` bajo RLS (`audit_insert` exige `organization_id = app_org()`).

| Acción registrada | Origen |
|---|---|
| `REGISTER` (con "consentimiento Ley 29733 aceptado"), `OPERATOR_PROVISIONED`, `DRIVER_CREATED` | identity, fleet |
| `REQUEST_PUBLISHED`, oferta colocada / aceptada | marketplace |
| `DRIVER_ASSIGNED`, `SHIPMENT_DELIVERED`, `DOCUMENT_UPLOADED` | shipment, documents |
| `INCIDENT_REPORTED`, `INCIDENT_<estado>` | incident |
| `COUNTER_OFFER_PROPOSED`, `COUNTER_OFFER_ACCEPTED`, `REVIEW_SUBMITTED` | negotiation, reputation |
| `TRIP_PUBLISHED`, `TRIP_CLOSED` | trip |

Complementan la trazabilidad el **outbox** (`outbox_events`: quién originó cada evento, `actor_org_id`) y los avisos al usuario. `audit_log` es **inmutable**: `REVOKE UPDATE, DELETE ON audit_log FROM logyx_app` en V2.

### 4.2 Consultas de auditoría

```sql
-- Historial de acciones sobre un envío (como el operador, que lee todo el rastro)
SELECT occurred_at, action, organization_id, detail
FROM audit_log
WHERE entity = 'shipment' AND entity_id = :shipment_id
ORDER BY occurred_at;

-- Registros de consentimiento (Ley N° 29733)
SELECT occurred_at, organization_id FROM audit_log WHERE action = 'REGISTER';
```

### 4.3 Pendientes de auditoría

Sin *triggers* de auditoría a nivel de tabla (cambios hechos con acceso directo a la BD no quedan en `audit_log`), sin archivado por retención del log y sin alerta automática de eventos del outbox en `FAILED` (se revisa a mano).

---

## 5. Optimización y Rendimiento

### 5.1 Estrategia de indexación

Los índices reales (ver [Modelo de Datos §5](modelo-datos.md#5-indices-principales)) priorizan las consultas por organización y estado, con muchos **índices parciales**: subastas abiertas por cierre (`ix_auctions_open`), no leídas (`ix_notifications_unread`), viajes abiertos (`ix_trips_open`), outbox pendiente (`outbox_events_pending`) y los únicos parciales que codifican reglas (`ux_incidents_active`, `ux_counter_offers_pending`). No se usa PostGIS: la cercanía entre ciudades la calcula el dominio (`CityProximityPolicy`).

### 5.2 Concurrencia y consultas críticas

- **Cierre de subasta:** el job (`CloseExpiredAuctionsUseCase`) usa `ix_auctions_open`; la oferta bloquea la fila de subasta para que MAX_BIDS sea exacto bajo concurrencia.
- **Outbox:** `FOR UPDATE SKIP LOCKED` permite varias réplicas despachando sin duplicar.
- **Trust Score:** recálculo con `SELECT … FOR UPDATE` de la fila de `reputation_scores`.
- **Marketplace:** la política `requests_marketplace` y `ix_requests_status (status, pickup_date)` sostienen el listado de cargas.
- **Chat:** paginación por cursor sobre `ix_messages_thread`.

### 5.3 Configuración de PostgreSQL para Producción (plan)

```ini
# postgresql.conf — parámetros de rendimiento para el servidor de producción
# (ajustados para 8GB RAM, 4 vCPU)

# Memoria
shared_buffers        = 2GB          # 25% de RAM total
effective_cache_size  = 6GB          # estimado de cache OS disponible
work_mem              = 64MB         # por operación de sorting
maintenance_work_mem  = 512MB        # para VACUUM, CREATE INDEX

# WAL y checkpoints
wal_buffers           = 64MB
checkpoint_completion_target = 0.9
max_wal_size          = 2GB

# Conexiones
max_connections       = 100          # combinado con PgBouncer en producción
pool_mode             = transaction  # PgBouncer en modo transacción

# Autovacuum
autovacuum            = on
autovacuum_vacuum_scale_factor  = 0.05   # vacuumar si el 5% de filas cambió
autovacuum_analyze_scale_factor = 0.02

# Logging para análisis de queries lentos
log_min_duration_statement = 500     # loguear queries > 500ms
log_statement = 'ddl'               # loguear solo DDL en prod (no DML)
```

### 5.4 Pool de conexiones

El backend ya limita sus pools (8 conexiones del datasource privilegiado + 20 del datasource `app` por instancia) y `logyx_api` tiene `CONNECTION LIMIT 50`. Con PgBouncer en modo *transaction* el `LISTEN` del tiempo real necesita una conexión directa al datasource `app` (ADR-0007). Plan de referencia:

```ini
# pgbouncer.ini
[databases]
logyx = host=db port=5432 dbname=logyx

[pgbouncer]
pool_mode        = transaction
max_client_conn  = 200
default_pool_size = 20
min_pool_size    = 5
reserve_pool_size = 5
reserve_pool_timeout = 3
server_idle_timeout = 600
```

---

## 6. Resumen de la Arquitectura de Seguridad

| Capa | Control implementado |
|------|---------------------|
| **Red** | PostgreSQL (y MinIO en staging) solo en la red interna del compose; sin puertos públicos. En producción: Cloudflare (WAF/DDoS) → UFW (80/443 solo desde Cloudflare) → Caddy → redes Docker |
| **Transporte** | TLS en el proxy; HSTS en prod |
| **Autenticación** | JWT RSA; contraseñas con bcrypt; rate limiting de login/registro |
| **Autorización** | RBAC en la API + **RLS por organización** + mínimo privilegio (`logyx_api`) |
| **Datos en reposo** | Documentos y respaldos en Cloudflare R2 (cifrado en reposo del proveedor); respaldos cifrados antes de subirlos; cifrado del volumen de la BD: a decidir (plan de producción) |
| **Auditoría** | `audit_log` inmutable desde la aplicación + outbox |
| **Disponibilidad** | Outbox con reintentos; réplicas de la API soportadas; RPO/RTO: plan de producción |

---

## 7. Cumplimiento Normativo (Ley N° 29733 y PCI-DSS)

Las obligaciones identificadas en el análisis de Gobierno de TI bajo COBIT 2019 (Gestión TI, Entregable 1, sección 1.7, y Entregable 3, sección 3.7) se satisfacen a nivel de datos con los siguientes controles:

| Obligación (Ley N° 29733) | Control a nivel de base de datos / backend |
|---|---|
| Consentimiento informado para tratamiento de datos (Art. 13) | **Implementado:** `profiles.consent_accepted_at TIMESTAMPTZ NOT NULL`; el registro exige aceptación (`@AssertTrue` en `RegisterRequest`) y la audita (RNF18) |
| Política de privacidad visible (Art. 18) | **Implementado:** página pública `/privacidad` (RNF17) |
| Registro de actividades de tratamiento (Art. 39, Reglamento) | `audit_log` inmutable con usuario, organización, acción y entidad |
| Medidas de seguridad técnicas (Art. 39, Reglamento) | **Implementado:** RLS por organización, mínimo privilegio, bcrypt, rate limiting, logs sin datos personales; cifrado de disco y TLS: plan de producción |
| Notificación de brechas a la ANPD en ≤ 72 horas | Procedimiento documental en Gestión TI (Entregable 3, §3.7); sin alerta automática |
| Designación de responsable del tratamiento | Documental (Gestión TI, Entregable 3, §3.7) |

**PCI-DSS.** OnCargo no almacena datos de tarjeta ni procesa pagos; el dato nunca llega al sistema (RNF20).

---

*OnCargo · E2 Seguridad de Base de Datos · Competencia CE0224 · Versión 2.0 · Noviembre 2026*
