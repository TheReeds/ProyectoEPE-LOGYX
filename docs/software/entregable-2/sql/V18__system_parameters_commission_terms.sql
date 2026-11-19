-- =====================================================================
-- V18 — Parámetros de sistema editables por el operador, comisión y aceptación de términos (ola 1, agente E).
--  * system_parameters: valor VIGENTE de cada parámetro que el operador cambió (comisión, SLA de asignación manual,
--    umbrales de incidencias). Sin fila = rige el valor por omisión de la configuración (application.properties), así
--    los entornos que fijan p. ej. logyx.operator.sla=PT0S siguen funcionando.
--  * system_parameter_history: una fila por cambio (versión, valor anterior y nuevo, motivo, quién y cuándo). Solo se
--    inserta: nadie la actualiza ni la borra.
--  * shipments.commission_rate: tasa de comisión vigente al adjudicar (decisión del dueño, 2026-11-17). La rellena
--    AcceptBidUseCase (agente C) con pricing.application.CommissionService.currentRate(); NULL = envío anterior a la
--    comisión. Un cambio futuro del parámetro no altera los envíos ya creados.
--  * terms_acceptances: aceptación de los Términos y condiciones al registrarse (versión + fecha), como el
--    consentimiento de la Ley 29733 (profiles.consent_accepted_at). Una fila por aceptación: al cambiar la versión se
--    vuelve a pedir y se agrega otra.
-- Solo agrega tablas y una columna nullable: no reescribe datos.
-- =====================================================================

-- ---------- Parámetros de sistema ----------
CREATE TABLE system_parameters (
    param_key   VARCHAR(60)  PRIMARY KEY,
    -- Texto canónico; el tipo, las unidades y los límites los define pe.logyx.shared.config.ParameterDefinition.
    param_value VARCHAR(40)  NOT NULL,
    version     INT          NOT NULL CHECK (version >= 1),
    reason      VARCHAR(300) NOT NULL,
    updated_by  UUID         REFERENCES profiles (id),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE system_parameter_history (
    id             BIGSERIAL PRIMARY KEY,
    param_key      VARCHAR(60)  NOT NULL,
    version        INT          NOT NULL CHECK (version >= 1),
    previous_value VARCHAR(40),
    new_value      VARCHAR(40)  NOT NULL,
    reason         VARCHAR(300) NOT NULL,
    changed_by     UUID         REFERENCES profiles (id),
    changed_by_org UUID         REFERENCES organizations (id),
    changed_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    UNIQUE (param_key, version)
);
CREATE INDEX ix_param_history_key ON system_parameter_history (param_key, version DESC);
CREATE INDEX ix_param_history_at ON system_parameter_history (changed_at DESC, id DESC);

ALTER TABLE system_parameters ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_parameter_history ENABLE ROW LEVEL SECURITY;

-- Cualquier usuario autenticado puede leer los valores vigentes (la comisión y los SLA no son secretos; los casos de uso
-- de otros módulos los leen dentro de su transacción). Sin organización (fail-closed) no se ve nada. Solo el operador
-- escribe, y el historial solo admite INSERT del operador.
CREATE POLICY params_read ON system_parameters FOR SELECT TO logyx_app
    USING (app_org() IS NOT NULL);
CREATE POLICY params_operator_insert ON system_parameters FOR INSERT TO logyx_app
    WITH CHECK (app_org_type() = 'OPERATOR');
CREATE POLICY params_operator_update ON system_parameters FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');
REVOKE DELETE ON system_parameters FROM logyx_app;

CREATE POLICY param_history_operator_read ON system_parameter_history FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
CREATE POLICY param_history_operator_insert ON system_parameter_history FOR INSERT TO logyx_app
    WITH CHECK (app_org_type() = 'OPERATOR' AND changed_by_org = app_org());
REVOKE UPDATE, DELETE ON system_parameter_history FROM logyx_app;

-- ---------- Comisión guardada en el envío ----------
ALTER TABLE shipments ADD COLUMN commission_rate NUMERIC(5,4)
    CHECK (commission_rate IS NULL OR (commission_rate >= 0 AND commission_rate <= 1));

-- ---------- Aceptación de términos y condiciones ----------
CREATE TABLE terms_acceptances (
    id              UUID PRIMARY KEY,
    profile_id      UUID        NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
    organization_id UUID        NOT NULL REFERENCES organizations (id),
    terms_version   VARCHAR(40) NOT NULL,
    accepted_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    source          VARCHAR(20) NOT NULL DEFAULT 'REGISTER' CHECK (source IN ('REGISTER'))
);
CREATE INDEX ix_terms_profile ON terms_acceptances (profile_id, accepted_at DESC);
CREATE INDEX ix_terms_org ON terms_acceptances (organization_id);

ALTER TABLE terms_acceptances ENABLE ROW LEVEL SECURITY;
-- Cada organización ve las suyas; el operador, todas. La fila la escribe el registro (SystemTx, sin usuario aún):
-- logyx_app no inserta, actualiza ni borra.
CREATE POLICY terms_own_read ON terms_acceptances FOR SELECT TO logyx_app
    USING (organization_id = app_org());
CREATE POLICY terms_operator_read ON terms_acceptances FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
REVOKE INSERT, UPDATE, DELETE ON terms_acceptances FROM logyx_app;
