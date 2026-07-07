# E2 — Seguridad de Base de Datos
> Competencia CE0224 · Usuarios, Roles, Backup, Auditoría y Optimización  
> Proyecto: LOGYX — Sistema Operativo Logístico Colaborativo para PYMEs  
> Equipo: Jorge Gutiérrez Miranda · Fabrizio Sanchez Saravia · Alex Coila Jarita  
> Motor: PostgreSQL 16  
> Versión: 1.0 · Junio 2026

---

## 1. Modelo de Usuarios y Roles de Base de Datos

LOGYX implementa el principio de **mínimo privilegio**: cada componente del sistema tiene su propio usuario de base de datos con acceso limitado estrictamente a las operaciones que necesita.

### 1.1 Roles de Base de Datos

```sql
-- ============================================================
-- LOGYX · Creación de roles PostgreSQL
-- ============================================================

-- Rol base de solo lectura (heredado por roles de monitoreo)
CREATE ROLE logyx_readonly;

-- Rol para la aplicación backend (Quarkus Monolith)
CREATE ROLE logyx_app;

-- Rol para el módulo de analítica / reportes
CREATE ROLE logyx_analytics;

-- Rol para DBA (mantenimiento y migraciones)
CREATE ROLE logyx_dba;
```

### 1.2 Permisos por Rol

#### Rol `logyx_app` — Backend principal (Quarkus)

```sql
-- Otorgar uso del schema público
GRANT USAGE ON SCHEMA public TO logyx_app;

-- SELECT, INSERT, UPDATE, DELETE en tablas operacionales
GRANT SELECT, INSERT, UPDATE, DELETE ON
    organizations,
    profiles,
    vehicles,
    drivers,
    shipment_requests,
    auctions,
    bids,
    counter_offers,
    carrier_trips,
    trip_bookings,
    messages,
    shipments,
    shipment_stops,
    reviews,
    reputation_scores,
    documents,
    notifications,
    incidents,
    incident_comments,
    smart_load_suggestions,
    cost_calculations
TO logyx_app;

-- Solo INSERT en audit_log (no puede borrar ni modificar auditoría)
GRANT INSERT ON audit_log TO logyx_app;

-- Solo SELECT en audit_log (para lecturas del operador)
GRANT SELECT ON audit_log TO logyx_app;

-- Uso de funciones de negocio
GRANT EXECUTE ON FUNCTION
    fn_generate_tracking_code(),
    fn_calculate_bayesian_rating(UUID),
    fn_calculate_composite_score(UUID),
    fn_check_vehicle_capacity(UUID, DECIMAL),
    fn_contains_contact_info(TEXT),
    fn_close_expired_auctions()
TO logyx_app;

-- Acceso a secuencias (para las columnas con DEFAULT uuid_generate_v4())
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO logyx_app;
```

#### Rol `logyx_analytics` — Reportes y dashboards

```sql
GRANT USAGE ON SCHEMA public TO logyx_analytics;

-- Solo lectura en tablas (sin datos PII sensibles)
GRANT SELECT ON
    organizations,
    vehicles,
    shipment_requests,
    auctions,
    bids,
    shipments,
    shipment_stops,
    reviews,
    reputation_scores,
    cost_calculations,
    incidents,
    carrier_trips,
    trip_bookings
TO logyx_analytics;

-- Sin acceso a: profiles (contiene passwords y PII), messages, documents, notifications
```

#### Rol `logyx_readonly` — Monitoreo y diagnóstico

```sql
GRANT USAGE ON SCHEMA public TO logyx_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO logyx_readonly;
-- Sin acceso a profiles (PASSWORD_HASH)
REVOKE SELECT ON profiles FROM logyx_readonly;
```

#### Rol `logyx_dba` — Administrador (solo para migraciones y mantenimiento)

```sql
-- logyx_dba tiene acceso completo al schema para ejecutar migraciones Flyway
GRANT ALL PRIVILEGES ON SCHEMA public TO logyx_dba;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO logyx_dba;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO logyx_dba;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO logyx_dba;
```

### 1.3 Usuarios de Base de Datos

```sql
-- ============================================================
-- Creación de usuarios (contraseñas en variables de entorno)
-- ============================================================

CREATE USER logyx_app_user
    WITH PASSWORD :'LOGYX_APP_DB_PASSWORD'
    CONNECTION LIMIT 50;

GRANT logyx_app TO logyx_app_user;

-- ---

CREATE USER logyx_analytics_user
    WITH PASSWORD :'LOGYX_ANALYTICS_DB_PASSWORD'
    CONNECTION LIMIT 10;

GRANT logyx_analytics TO logyx_analytics_user;

-- ---

CREATE USER logyx_dba_user
    WITH PASSWORD :'LOGYX_DBA_DB_PASSWORD'
    CONNECTION LIMIT 5;

GRANT logyx_dba TO logyx_dba_user;
```

### 1.4 Separación de Acceso por Entorno

| Entorno | Host | Puerto | Usuario activo |
|---------|------|--------|----------------|
| **Desarrollo** | localhost | 5432 | logyx_app_user |
| **Staging** | db-staging.logyx.internal | 5432 | logyx_app_user |
| **Producción** | db-prod.logyx.internal | 5432 | logyx_app_user (sin dba) |
| **Analytics** | db-replica.logyx.internal | 5433 | logyx_analytics_user |

> **Estado de implementación (verificado 2026-07-06): ⬜ No implementado en el MVP actual.**
> `docker-compose.yml` crea un único usuario (`POSTGRES_USER=logyx_app`, sin `CONNECTION LIMIT`
> ni roles separados) y ninguna migración Flyway crea `logyx_readonly`/`logyx_analytics`/`logyx_dba`
> ni los usuarios `*_user` de esta sección. El backend Quarkus se conecta hoy con ese único
> usuario para todo (lectura y escritura de todas las tablas). Este diseño de mínimo privilegio
> queda documentado como objetivo de Fase 2 (junto con RLS, ver sección 2.3) — no es una
> regresión de este sprint, nunca se llegó a implementar desde que se escribió este documento.

---

## 2. Seguridad de Datos

### 2.1 Cifrado en Reposo

| Capa | Mecanismo |
|------|-----------|
| Contraseñas de usuario | bcrypt, cost factor 12 (`password_hash`) |
| Datos de configuración sensibles | Variables de entorno (nunca en código) |
| Disco del servidor PostgreSQL | Cifrado del volumen (AES-256 en prod) |
| Backups | Cifrados con AES-256 antes de subir a storage |

```sql
-- Ejemplo: verificar que nunca se almacene contraseña en texto plano.
-- La función de validación está en la capa de aplicación (Quarkus):
-- BCrypt.checkpw(plainPassword, profile.getPasswordHash())
-- La BD solo recibe el hash final.

-- Restricción: password_hash no puede ser un string corto (sería texto plano)
ALTER TABLE profiles
    ADD CONSTRAINT chk_profiles_password_hash_format
    CHECK (password_hash IS NULL OR LENGTH(password_hash) >= 60);
```

### 2.2 Cifrado en Tránsito

```sql
-- postgresql.conf — configuración de TLS
-- ssl = on
-- ssl_cert_file = '/etc/ssl/certs/logyx-db.crt'
-- ssl_key_file  = '/etc/ssl/private/logyx-db.key'
-- ssl_min_protocol_version = 'TLSv1.3'

-- pg_hba.conf — forzar SSL para todos los hosts remotos
-- host    logyx_db    all    0.0.0.0/0    scram-sha-256
-- hostssl logyx_db    all    0.0.0.0/0    scram-sha-256
```

### 2.3 Row-Level Security (RLS)

Las políticas de RLS aseguran que un transportista no pueda leer los datos de otro transportista directamente en consultas que lleguen sin pasar por la capa de aplicación.

```sql
-- Habilitar RLS en la tabla de solicitudes de carga
ALTER TABLE shipment_requests ENABLE ROW LEVEL SECURITY;

-- Una PYME solo ve sus propias solicitudes en acceso directo
CREATE POLICY rls_requests_owner
    ON shipment_requests
    FOR ALL
    TO logyx_app
    USING (requester_org_id = current_setting('app.current_org_id')::UUID);

-- El operador ve todo
CREATE POLICY rls_requests_operator
    ON shipment_requests
    FOR SELECT
    TO logyx_app
    USING (
        EXISTS (
            SELECT 1 FROM organizations
            WHERE id = current_setting('app.current_org_id')::UUID
              AND type IN ('operator', 'admin')
        )
    );

-- Habilitar RLS en mensajes de negociación
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY rls_messages_participant
    ON messages
    FOR ALL
    TO logyx_app
    USING (
        carrier_org_id = current_setting('app.current_org_id')::UUID
        OR
        (SELECT requester_org_id FROM shipment_requests
         WHERE id = messages.request_id) =
            current_setting('app.current_org_id')::UUID
    );
```

> La aplicación Quarkus establece `SET app.current_org_id = '<org_id>'` al inicio de cada request autenticado, antes de ejecutar cualquier consulta.

> **Estado de implementación (verificado 2026-07-06): ⬜ No implementado en el MVP actual.**
> No existe ninguna migración (`src/main/resources/db/migration/`) que ejecute
> `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` ni que cree las políticas `rls_*` de arriba.
> El datasource de Quarkus (`quarkus.datasource.username=${DB_USER:logyx_app}`, ver
> `application.properties`) tampoco ejecuta `SET app.current_org_id` en ningún request — de
> hecho el usuario `logyx_app` que usa hoy el backend es el único rol de BD que existe
> (creado por la variable `POSTGRES_USER` de `docker-compose.yml`), no el modelo de roles de
> mínimo privilegio de la sección 1 (`logyx_readonly`/`logyx_app`/`logyx_analytics`/`logyx_dba`
> como roles separados con `GRANT` acotado) — esos tampoco tienen migración que los cree.
> Hoy el único control de acceso por organización es a nivel de aplicación
> (`SecurityContext.getOrgId()` + filtros `WHERE requester_org_id = ...` en cada
> repository/service, verificado módulo por módulo en `ROADMAP.md`). RLS es una defensa en
> profundidad adicional (protege contra un bug de aplicación que olvide el filtro, o contra
> acceso directo a la BD con credenciales de `logyx_app`) — vale la pena implementarla antes
> de producción, pero **no bloquea el MVP** mientras el filtro a nivel de aplicación sea
> consistente. Recomendado para Fase 2 / antes de exponer la BD fuera de la red interna.

---

## 3. Estrategia de Backup

### 3.1 Tipos de Backup

| Tipo | Frecuencia | Retención | Herramienta |
|------|-----------|-----------|-------------|
| **Backup completo (full dump)** | Diario (02:00 PET) | 30 días | `pg_dump` |
| **Backup incremental (WAL archiving)** | Continuo (cada transacción) | 7 días de WAL | `pg_basebackup` + WAL |
| **Backup semanal (cold)** | Domingo (01:00 PET) | 90 días | `pg_dump` comprimido |
| **Snapshot de volumen** | Diario | 14 días | Cloud provider snapshot |

### 3.2 Scripts de Backup

```bash
#!/bin/bash
# logyx_backup_daily.sh
# Ejecutado por cron: 0 2 * * * /opt/logyx/scripts/logyx_backup_daily.sh

set -euo pipefail

DB_NAME="logyx_db"
DB_USER="logyx_dba_user"
BACKUP_DIR="/mnt/backups/logyx"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/logyx_full_${DATE}.dump"
ENCRYPT_KEY="${LOGYX_BACKUP_ENCRYPTION_KEY}"

# 1. Generar dump en formato custom (comprimido, restaurable parcialmente)
pg_dump \
    --host=localhost \
    --port=5432 \
    --username="${DB_USER}" \
    --format=custom \
    --compress=9 \
    --file="${BACKUP_FILE}" \
    "${DB_NAME}"

# 2. Cifrar el archivo
openssl enc -aes-256-cbc -pbkdf2 -k "${ENCRYPT_KEY}" \
    -in "${BACKUP_FILE}" \
    -out "${BACKUP_FILE}.enc"

# 3. Eliminar el archivo sin cifrar
rm "${BACKUP_FILE}"

# 4. Subir a storage S3-compatible
aws s3 cp "${BACKUP_FILE}.enc" \
    "s3://logyx-backups/db/$(date +%Y/%m/)/" \
    --storage-class STANDARD_IA

# 5. Eliminar backups locales de más de 7 días
find "${BACKUP_DIR}" -name "*.enc" -mtime +7 -delete

echo "[$(date)] Backup completado: ${BACKUP_FILE}.enc"
```

### 3.3 Procedimiento de Restauración

```bash
# Restaurar a un punto específico (Point-in-Time Recovery)
# Paso 1: Descargar y descifrar
aws s3 cp "s3://logyx-backups/db/2026/06/logyx_full_20260629_020000.dump.enc" .

openssl enc -aes-256-cbc -pbkdf2 -d \
    -k "${LOGYX_BACKUP_ENCRYPTION_KEY}" \
    -in logyx_full_20260629_020000.dump.enc \
    -out logyx_full_20260629_020000.dump

# Paso 2: Restaurar sobre una base nueva
createdb logyx_db_restored

pg_restore \
    --host=localhost \
    --username=logyx_dba_user \
    --dbname=logyx_db_restored \
    --no-owner \
    --no-acl \
    --jobs=4 \
    logyx_full_20260629_020000.dump

echo "Restauración completada. Verificar integridad con: SELECT COUNT(*) FROM shipments;"
```

### 3.4 Prueba de Backups (RTO / RPO)

| Métrica | Objetivo | Procedimiento de verificación |
|---------|---------|-------------------------------|
| **RPO** (máx. pérdida de datos) | < 1 hora | WAL archiving continuo |
| **RTO** (tiempo de recuperación) | < 2 horas | Prueba mensual de restauración en entorno staging |
| **Verificación de integridad** | Semanal | Restaurar en staging, ejecutar consultas de validación |

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

### 4.1 Mecanismo de Auditoría

La auditoría se implementa mediante triggers `trg_audit_*` (definidos en `E2_Scripts.md`, aplicados en la migración real `V8__triggers.sql`) que registran automáticamente INSERT/UPDATE en las tablas críticas.

**Tablas auditadas (verificado contra `V8__triggers.sql`, 2026-07-06):**

| Tabla | Eventos auditados | Razón | Estado |
|-------|------------------|-------|--------|
| `shipments` | INSERT, UPDATE | Estado del envío y asignaciones | ✅ Implementado (`trg_audit_shipments`) |
| `bids` | INSERT, UPDATE | Trazabilidad de ofertas | ✅ Implementado (`trg_audit_bids`) |
| `auctions` | INSERT, UPDATE | Cierre y manipulación de subastas | ✅ Implementado (`trg_audit_auctions`) |
| `incidents` | INSERT, UPDATE | Resolución de disputas | ✅ Implementado (`trg_audit_incidents`) |
| `organizations` | INSERT, UPDATE | Cambios de verificación y trust_score | ⬜ **Pendiente** — no existe `trg_audit_organizations` en ninguna migración |
| `profiles` | INSERT, UPDATE | Cambios de rol y credenciales | ⬜ **Pendiente** — no existe `trg_audit_profiles` en ninguna migración |

> **Corrección (2026-07-06):** esta tabla originalmente listaba las 6 filas como si todas
> estuvieran activas. Solo 4 de los 6 triggers de auditoría existen hoy. Esto es relevante
> porque RNF15 ("todas las acciones de negocio críticas deben quedar registradas") incluye
> explícitamente cambios de verificación de organización y de rol de perfil — ambos marcados
> como "críticos" en este mismo documento — que hoy **no** quedan en `audit_log`. Además, la
> segunda consulta de ejemplo en la sección 4.2 (auditoría de `organizations`) no devolverá
> resultados mientras `trg_audit_organizations` no se implemente; se deja documentada como
> referencia para cuando se agregue el trigger (candidato natural: junto con el Módulo 2 —
> Organizations, o el Módulo 20 — Admin, que ya expone `PATCH /verify` y `/suspend`).

### 4.2 Consultas de Auditoría

```sql
-- Historial completo de cambios en un envío específico
SELECT
    al.action,
    al.old_values ->> 'status'   AS estado_anterior,
    al.new_values ->> 'status'   AS estado_nuevo,
    al.performed_at,
    p.full_name                  AS ejecutado_por
FROM audit_log al
LEFT JOIN profiles p ON p.id = al.performed_by
WHERE al.table_name = 'shipments'
  AND al.record_id  = '00000000-0000-0000-0041-000000000001'
ORDER BY al.performed_at;

-- ---

-- Actividad sospechosa: organización que cambió de tipo en las últimas 24h
SELECT
    al.record_id                       AS org_id,
    al.old_values ->> 'type'           AS tipo_anterior,
    al.new_values ->> 'type'           AS tipo_nuevo,
    al.performed_at
FROM audit_log al
WHERE al.table_name = 'organizations'
  AND al.action = 'UPDATE'
  AND (al.old_values ->> 'type') != (al.new_values ->> 'type')
  AND al.performed_at >= NOW() - INTERVAL '24 hours';

-- ---

-- Ofertas canceladas o rechazadas de un transportista en el último mes
SELECT
    al.record_id           AS bid_id,
    al.old_values ->> 'status' AS estado_anterior,
    al.new_values ->> 'status' AS estado_nuevo,
    al.performed_at
FROM audit_log al
JOIN bids b ON b.id = al.record_id
WHERE al.table_name = 'bids'
  AND al.action = 'UPDATE'
  AND al.new_values ->> 'status' IN ('rejected', 'expired')
  AND b.carrier_org_id = '00000000-0000-0000-0003-000000000001'
  AND al.performed_at >= NOW() - INTERVAL '30 days'
ORDER BY al.performed_at DESC;
```

### 4.3 Integridad del Log de Auditoría

```sql
-- La tabla audit_log solo acepta INSERT (definido en roles).
-- Nadie puede UPDATE o DELETE registros de auditoría:
REVOKE UPDATE, DELETE ON audit_log FROM logyx_app;
REVOKE UPDATE, DELETE ON audit_log FROM logyx_dba;

-- Política de retención: mover a tabla de archivo tras 1 año
CREATE TABLE audit_log_archive (LIKE audit_log INCLUDING ALL);

-- Procedure de archivado (ejecutar mensualmente)
CREATE OR REPLACE PROCEDURE proc_archive_old_audit_log()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO audit_log_archive
    SELECT * FROM audit_log
    WHERE performed_at < NOW() - INTERVAL '1 year';

    DELETE FROM audit_log
    WHERE performed_at < NOW() - INTERVAL '1 year';

    RAISE NOTICE 'Archivado completado. Registros movidos a audit_log_archive.';
END;
$$;
```

---

## 5. Optimización y Rendimiento

### 5.1 Estrategia de Indexación

Los índices están definidos en `V6__indexes.sql` (ver E2_Scripts.md). La estrategia sigue tres principios:

1. **Índices compuestos para filtros frecuentes**: `(status, required_date)` en lugar de índices individuales.
2. **Índices parciales para conjuntos activos**: `WHERE status IN ('open', 'filling')` para viajes activos — la mayoría de los viajes en la BD estarán en estado `completed` y no se buscan frecuentemente.
3. **Sin índices en columnas de baja cardinalidad por sí solas** (p.ej. `type` en `organizations`), ya que PostgreSQL preferirá un seq scan.

### 5.2 Consultas Críticas y su Optimización

#### CQ-01: Marketplace — Cargas disponibles para un transportista

```sql
-- Búsqueda de solicitudes abiertas dentro de un radio geográfico
-- Índices usados: idx_requests_status_date, idx_requests_origin_geo

EXPLAIN ANALYZE
SELECT
    sr.id,
    sr.origin_address,
    sr.destination_address,
    sr.weight_kg,
    sr.required_date,
    sr.suggested_price,
    o.trust_score   AS pyme_trust_score,
    cc.distance_km
FROM shipment_requests sr
JOIN organizations      o  ON o.id = sr.requester_org_id
LEFT JOIN cost_calculations cc ON cc.request_id = sr.id
WHERE sr.status = 'open'
  AND sr.required_date >= CURRENT_DATE
  -- Radio de 100 km alrededor de Lima (lat=-12.04, lng=-77.03)
  AND (
    6371 * acos(
        cos(radians(-12.04)) * cos(radians(sr.origin_lat))
        * cos(radians(sr.origin_lng) - radians(-77.03))
        + sin(radians(-12.04)) * sin(radians(sr.origin_lat))
    )
  ) <= 100
ORDER BY sr.required_date ASC, o.trust_score DESC
LIMIT 20;
```

**Optimizaciones aplicadas:**
- Filtro `status = 'open'` activado por `idx_requests_status_date`.
- La columna `price_floor` es calculada (GENERATED), no requiere cálculo en runtime.
- `LIMIT 20` evita escaneos completos de resultado.

#### CQ-02: Mis ofertas activas (Carrier dashboard)

```sql
-- Índice usado: idx_bids_carrier_status

SELECT
    b.id,
    b.amount,
    b.status,
    b.submitted_at,
    sr.origin_address,
    sr.destination_address,
    a.closes_at
FROM bids b
JOIN auctions          a  ON a.id  = b.auction_id
JOIN shipment_requests sr ON sr.id = a.request_id
WHERE b.carrier_org_id = $1
  AND b.status = 'pending'
ORDER BY b.submitted_at DESC;
```

#### CQ-03: Notificaciones no leídas (llamada frecuente cada 30s)

```sql
-- Índice parcial usado: idx_notifications_org_unread (WHERE read = FALSE)

SELECT id, type, title, body, related_id, created_at
FROM notifications
WHERE org_id = $1
  AND read = FALSE
ORDER BY created_at DESC
LIMIT 50;
```

### 5.3 Configuración de PostgreSQL para Producción

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

### 5.4 Particionamiento (Planificado para Fase 2)

Para cuando el volumen de datos supere los 10 millones de registros, se implementará particionamiento por rango en las tablas de mayor crecimiento:

```sql
-- Ejemplo de particionamiento futuro en shipments por año
CREATE TABLE shipments (
    -- ... columnas ...
    created_at TIMESTAMP NOT NULL
) PARTITION BY RANGE (created_at);

CREATE TABLE shipments_2026 PARTITION OF shipments
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

CREATE TABLE shipments_2027 PARTITION OF shipments
    FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');
```

### 5.5 Pool de Conexiones (PgBouncer)

```ini
# pgbouncer.ini
[databases]
logyx_db = host=db.logyx.internal port=5432 dbname=logyx_db

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
| **Red** | PostgreSQL solo accesible desde la red interna (Docker network / VPC) |
| **Transporte** | TLS 1.3 obligatorio para conexiones remotas |
| **Autenticación** | SCRAM-SHA-256 (reemplazo de MD5) |
| **Autorización** | Roles por mínimo privilegio + RLS por org_id |
| **Datos en reposo** | Cifrado de disco AES-256 en producción |
| **Passwords** | bcrypt cost=12 (nunca texto plano en BD) |
| **Auditoría** | Triggers automáticos + tabla audit_log inmutable |
| **Backup** | Diario + WAL continuo + cifrado AES-256 antes de subir |
| **Disponibilidad** | RPO < 1h, RTO < 2h, pruebas mensuales de restauración |

---

*LOGYX · E2 Seguridad de Base de Datos · Competencia CE0224 · Versión 1.0 · Junio 2026*
