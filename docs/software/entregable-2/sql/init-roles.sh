#!/usr/bin/env bash
# =====================================================================
# LOGYX — roles de PostgreSQL con mínimo privilegio (ADR-0006).
# Lo ejecuta la imagen oficial de postgres en el primer arranque (docker-entrypoint-initdb.d), como superusuario.
# En una BD gestionada (RDS, Cloud SQL…) lo corre el DBA una vez con psql y las mismas variables.
#
#   logyx_owner  LOGIN, dueño de la BD y del esquema. Lo usan Flyway y SystemTx (datasource por defecto).
#                No es superusuario ni tiene BYPASSRLS: salta RLS solo por ser dueño de las tablas.
#   logyx_app    NOLOGIN, sin BYPASSRLS. Las políticas RLS son "TO logyx_app".
#   logyx_api    LOGIN, miembro SOLO de logyx_app (datasource "app" de Hibernate). No puede SET ROLE a otro rol.
#
# Variables: LOGYX_DB (logyx), LOGYX_OWNER_PASSWORD, LOGYX_APP_PASSWORD (obligatorias).
# =====================================================================
set -euo pipefail
: "${LOGYX_OWNER_PASSWORD:?Falta LOGYX_OWNER_PASSWORD}"
: "${LOGYX_APP_PASSWORD:?Falta LOGYX_APP_PASSWORD}"
DB="${LOGYX_DB:-${POSTGRES_DB:-logyx}}"

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER:-postgres}" --dbname postgres \
     -v owner_pw="$LOGYX_OWNER_PASSWORD" -v app_pw="$LOGYX_APP_PASSWORD" -v db="$DB" <<'SQL'
SELECT format('CREATE ROLE logyx_owner LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS PASSWORD %L', :'owner_pw')
 WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'logyx_owner') \gexec
SELECT 'CREATE ROLE logyx_app NOLOGIN NOSUPERUSER NOBYPASSRLS'
 WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'logyx_app') \gexec
SELECT format('CREATE ROLE logyx_api LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS PASSWORD %L', :'app_pw')
 WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'logyx_api') \gexec
ALTER ROLE logyx_owner PASSWORD :'owner_pw';
ALTER ROLE logyx_api PASSWORD :'app_pw';
-- V2 ejecuta "GRANT logyx_app TO current_user": en PG16 el dueño necesita ADMIN OPTION sobre logyx_app.
GRANT logyx_app TO logyx_owner WITH ADMIN OPTION;
GRANT logyx_app TO logyx_api;
-- Conexiones solo de los roles de LOGYX; límite de conexiones del usuario de la app.
ALTER ROLE logyx_api CONNECTION LIMIT 50;
SELECT format('CREATE DATABASE %I OWNER logyx_owner', :'db')
 WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'db') \gexec
SELECT format('ALTER DATABASE %I OWNER TO logyx_owner', :'db') \gexec
SELECT format('REVOKE ALL ON DATABASE %I FROM PUBLIC', :'db') \gexec
SELECT format('GRANT CONNECT ON DATABASE %I TO logyx_api', :'db') \gexec
SQL

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER:-postgres}" --dbname "$DB" <<'SQL'
-- Solo el dueño crea objetos en public; el resto de privilegios los da V2 (GRANT/DEFAULT PRIVILEGES a logyx_app).
ALTER SCHEMA public OWNER TO logyx_owner;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO logyx_app;
SQL
echo "Roles de LOGYX listos en la BD $DB (logyx_owner, logyx_app, logyx_api)"
