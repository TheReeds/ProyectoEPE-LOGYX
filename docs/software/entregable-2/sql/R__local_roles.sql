-- =====================================================================
-- SOLO dev/test (quarkus.flyway.locations de %dev/%test). Emula el usuario de conexión de producción:
-- logyx_api es LOGIN, miembro solo de logyx_app, sin ser dueño ni BYPASSRLS (ADR-0006).
-- En producción lo crea infra/db/init-roles.sh con una contraseña secreta.
-- =====================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'logyx_api') THEN
        CREATE ROLE logyx_api LOGIN PASSWORD 'logyx_api'
            NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS INHERIT;
    END IF;
END
$$;
GRANT logyx_app TO logyx_api;
