-- =====================================================================
-- V8 — Notificaciones in-app por organización (RF49/RF51).
-- Se generan por eventos de dominio y casi siempre van a OTRA organización
-- que la que actúa, así que se insertan en contexto de sistema (SystemTx,
-- ver ADR-0004): logyx_app NO tiene política de INSERT. Cada organización
-- lee y marca como leídas solo las suyas.
-- =====================================================================

CREATE TABLE notifications (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id        UUID          NOT NULL REFERENCES organizations (id),
    type          VARCHAR(32)   NOT NULL CHECK (type IN ('NEW_BID', 'BID_ACCEPTED', 'BID_REJECTED', 'COUNTER_OFFER',
                                                         'NEW_MESSAGE', 'SHIPMENT_STATUS_CHANGE', 'INCIDENT_REPORTED',
                                                         'INCIDENT_RESOLVED', 'NEW_REVIEW')),
    title         VARCHAR(200)  NOT NULL,
    body          VARCHAR(1000) NOT NULL,
    related_type  VARCHAR(20)   CHECK (related_type IN ('REQUEST', 'BID', 'COUNTER_OFFER', 'SHIPMENT',
                                                        'INCIDENT', 'REVIEW')),
    related_id    UUID,
    read_at       TIMESTAMPTZ,
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT now()
);
CREATE INDEX ix_notifications_org ON notifications (org_id, created_at DESC);
CREATE INDEX ix_notifications_unread ON notifications (org_id) WHERE read_at IS NULL;

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY notifications_own_read ON notifications FOR SELECT TO logyx_app
    USING (org_id = app_org());
CREATE POLICY notifications_own_update ON notifications FOR UPDATE TO logyx_app
    USING (org_id = app_org()) WITH CHECK (org_id = app_org());
REVOKE INSERT, DELETE ON notifications FROM logyx_app;
