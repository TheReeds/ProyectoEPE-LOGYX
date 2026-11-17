-- =====================================================================
-- LOGYX — Row-Level Security (defensa en profundidad)
--
-- Cada transacción iniciada por un usuario autenticado ejecuta:
--     SELECT set_config('app.org_id', '<uuid>', true),
--            set_config('app.org_type', 'PYME|CARRIER|OPERATOR', true);
--     SET LOCAL ROLE logyx_app;
-- (ver pe.logyx.shared.tenancy.TenantSessionBinder)
--
-- logyx_app es un rol NOLOGIN sin BYPASSRLS: mientras esté activo, PostgreSQL
-- aplica las políticas de abajo aunque el código olvide un WHERE.
-- Las operaciones de sistema (login, registro, scheduler) no cambian de rol
-- y corren como dueño del esquema. Ver docs/adr/0001.
-- =====================================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'logyx_app') THEN
        CREATE ROLE logyx_app NOLOGIN NOBYPASSRLS;
    END IF;
    -- El usuario de conexión debe poder hacer SET ROLE logyx_app.
    EXECUTE format('GRANT logyx_app TO %I', current_user);
END
$$;

GRANT USAGE ON SCHEMA public TO logyx_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO logyx_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO logyx_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO logyx_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO logyx_app;

-- Flyway no debe ser tocado por la aplicación.
REVOKE ALL ON TABLE flyway_schema_history FROM logyx_app;

-- Helpers: leen el contexto de la transacción (NULL si no hay).
CREATE OR REPLACE FUNCTION app_org() RETURNS UUID
    LANGUAGE sql STABLE AS
$$ SELECT nullif(current_setting('app.org_id', true), '')::uuid $$;

CREATE OR REPLACE FUNCTION app_org_type() RETURNS TEXT
    LANGUAGE sql STABLE AS
$$ SELECT nullif(current_setting('app.org_type', true), '') $$;

-- ---------- Organizaciones: perfil público legible, solo la propia editable ----------
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
CREATE POLICY orgs_read ON organizations FOR SELECT TO logyx_app USING (true);
CREATE POLICY orgs_update_own ON organizations FOR UPDATE TO logyx_app
    USING (id = app_org()) WITH CHECK (id = app_org());

-- ---------- Usuarios: cada organización ve solo a su gente ----------
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY profiles_own_org ON profiles FOR ALL TO logyx_app
    USING (organization_id = app_org())
    WITH CHECK (organization_id = app_org());
CREATE POLICY profiles_operator ON profiles FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');

-- ---------- Flota: privada de cada transportista ----------
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
CREATE POLICY vehicles_owner ON vehicles FOR ALL TO logyx_app
    USING (organization_id = app_org())
    WITH CHECK (organization_id = app_org());
CREATE POLICY vehicles_operator ON vehicles FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');

ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
CREATE POLICY drivers_owner ON drivers FOR ALL TO logyx_app
    USING (organization_id = app_org())
    WITH CHECK (organization_id = app_org());
CREATE POLICY drivers_operator ON drivers FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');

-- ---------- Solicitudes: la PYME dueña ve todo; los transportistas solo
-- el marketplace público y las que se les adjudicaron ----------
ALTER TABLE shipment_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY requests_owner ON shipment_requests FOR ALL TO logyx_app
    USING (requester_org_id = app_org())
    WITH CHECK (requester_org_id = app_org());
CREATE POLICY requests_marketplace ON shipment_requests FOR SELECT TO logyx_app
    USING (app_org_type() = 'CARRIER'
           AND (status = 'PUBLISHED' OR assigned_carrier_org_id = app_org()));
CREATE POLICY requests_operator ON shipment_requests FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');

-- ---------- Ofertas: el transportista ve las suyas; la PYME las de sus
-- solicitudes. Un transportista NUNCA ve el monto de otro. ----------
ALTER TABLE bids ENABLE ROW LEVEL SECURITY;
CREATE POLICY bids_carrier ON bids FOR ALL TO logyx_app
    USING (carrier_org_id = app_org())
    WITH CHECK (carrier_org_id = app_org());
CREATE POLICY bids_requester_read ON bids FOR SELECT TO logyx_app
    USING (requester_org_id = app_org());
CREATE POLICY bids_requester_update ON bids FOR UPDATE TO logyx_app
    USING (requester_org_id = app_org())
    WITH CHECK (requester_org_id = app_org());
CREATE POLICY bids_operator ON bids FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');

-- ---------- Envíos y paradas: solo las dos partes del contrato ----------
ALTER TABLE shipments ENABLE ROW LEVEL SECURITY;
CREATE POLICY shipments_parties ON shipments FOR ALL TO logyx_app
    USING (requester_org_id = app_org() OR carrier_org_id = app_org())
    WITH CHECK (requester_org_id = app_org() OR carrier_org_id = app_org());
CREATE POLICY shipments_operator ON shipments FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');

ALTER TABLE shipment_stops ENABLE ROW LEVEL SECURITY;
CREATE POLICY stops_parties ON shipment_stops FOR ALL TO logyx_app
    USING (requester_org_id = app_org() OR carrier_org_id = app_org())
    WITH CHECK (requester_org_id = app_org() OR carrier_org_id = app_org());
CREATE POLICY stops_operator ON shipment_stops FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');

-- ---------- Auditoría: cada organización escribe y lee su propio rastro;
-- el operador lee todo. (El SELECT propio también lo exige INSERT ... RETURNING.)
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY audit_insert ON audit_log FOR INSERT TO logyx_app
    WITH CHECK (organization_id = app_org());
CREATE POLICY audit_own_read ON audit_log FOR SELECT TO logyx_app
    USING (organization_id = app_org());
CREATE POLICY audit_operator ON audit_log FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
REVOKE UPDATE, DELETE ON audit_log FROM logyx_app;
