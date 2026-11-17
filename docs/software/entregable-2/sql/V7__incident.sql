-- =====================================================================
-- V7 — Incidencias sobre envíos y su hilo de comentarios (RN11).
-- Una incidencia OPEN o IN_REVIEW es "activa": congela el avance de paradas
-- hasta que el operador la resuelva. Máximo una activa por envío.
-- =====================================================================

CREATE TABLE incidents (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id             UUID          NOT NULL REFERENCES shipments (id),
    requester_org_id        UUID          NOT NULL REFERENCES organizations (id),
    carrier_org_id          UUID          NOT NULL REFERENCES organizations (id),
    reported_by_org_id      UUID          NOT NULL REFERENCES organizations (id),
    reported_by_profile_id  UUID          REFERENCES profiles (id),
    category                VARCHAR(20)   NOT NULL CHECK (category IN ('CARGO_DAMAGE', 'DELAY', 'LOST_CARGO',
                                                                       'WRONG_DELIVERY', 'DRIVER_CONDUCT', 'OTHER')),
    description             VARCHAR(2000) NOT NULL,
    status                  VARCHAR(16)   NOT NULL DEFAULT 'OPEN'
                            CHECK (status IN ('OPEN', 'IN_REVIEW', 'RESOLVED', 'CLOSED')),
    resolution_notes        VARCHAR(2000),
    created_at              TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ   NOT NULL DEFAULT now(),
    resolved_at             TIMESTAMPTZ,
    CHECK (reported_by_org_id IN (requester_org_id, carrier_org_id))
);
CREATE INDEX ix_incidents_shipment ON incidents (shipment_id, created_at DESC);
CREATE INDEX ix_incidents_status ON incidents (status, created_at);
CREATE UNIQUE INDEX ux_incidents_active ON incidents (shipment_id) WHERE status IN ('OPEN', 'IN_REVIEW');

CREATE TABLE incident_comments (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id        UUID          NOT NULL REFERENCES incidents (id),
    requester_org_id   UUID          NOT NULL REFERENCES organizations (id),
    carrier_org_id     UUID          NOT NULL REFERENCES organizations (id),
    author_org_id      UUID          NOT NULL REFERENCES organizations (id),
    author_profile_id  UUID          REFERENCES profiles (id),
    body               VARCHAR(2000) NOT NULL,
    created_at         TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX ix_incident_comments ON incident_comments (incident_id, created_at);

-- ---------- RLS: partes del envío reportan y comentan; solo el operador cambia el estado ----------
ALTER TABLE incidents ENABLE ROW LEVEL SECURITY;
CREATE POLICY incidents_parties_read ON incidents FOR SELECT TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY incidents_parties_insert ON incidents FOR INSERT TO logyx_app
    WITH CHECK (reported_by_org_id = app_org() AND app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY incidents_operator_read ON incidents FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
CREATE POLICY incidents_operator_update ON incidents FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');
REVOKE DELETE ON incidents FROM logyx_app;

ALTER TABLE incident_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY incident_comments_read ON incident_comments FOR SELECT TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id) OR app_org_type() = 'OPERATOR');
CREATE POLICY incident_comments_insert ON incident_comments FOR INSERT TO logyx_app
    WITH CHECK (author_org_id = app_org()
                AND (app_org() IN (requester_org_id, carrier_org_id) OR app_org_type() = 'OPERATOR'));
REVOKE UPDATE, DELETE ON incident_comments FROM logyx_app;
