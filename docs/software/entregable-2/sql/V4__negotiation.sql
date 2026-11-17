-- =====================================================================
-- V4 — Negociación: chat por (solicitud, transportista) y contra-ofertas.
-- Ambas tablas denormalizan requester_org_id y carrier_org_id para que RLS
-- decida sin consultar otras tablas protegidas (ADR-0001).
-- =====================================================================

CREATE TABLE messages (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id         UUID          NOT NULL REFERENCES shipment_requests (id),
    requester_org_id   UUID          NOT NULL REFERENCES organizations (id),
    carrier_org_id     UUID          NOT NULL REFERENCES organizations (id),
    sender_org_id      UUID          NOT NULL REFERENCES organizations (id),
    sender_profile_id  UUID          REFERENCES profiles (id),
    body               VARCHAR(1000) NOT NULL,
    -- Monto asociado cuando el mensaje es el aviso de una contra-oferta
    proposed_price     NUMERIC(12,2),
    -- TRUE si lo generó el sistema (contra-ofertas), no una persona
    is_system          BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at         TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CHECK (sender_org_id IN (requester_org_id, carrier_org_id))
);
CREATE INDEX ix_messages_thread ON messages (request_id, carrier_org_id, created_at DESC, id DESC);

CREATE TABLE counter_offers (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bid_id                 UUID          NOT NULL REFERENCES bids (id),
    request_id             UUID          NOT NULL REFERENCES shipment_requests (id),
    requester_org_id       UUID          NOT NULL REFERENCES organizations (id),
    carrier_org_id         UUID          NOT NULL REFERENCES organizations (id),
    offered_by_org_id      UUID          NOT NULL REFERENCES organizations (id),
    offered_by_profile_id  UUID          REFERENCES profiles (id),
    previous_amount        NUMERIC(12,2) NOT NULL,
    amount                 NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    message                VARCHAR(500),
    status                 VARCHAR(16)   NOT NULL DEFAULT 'PENDING'
                           CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED')),
    created_at             TIMESTAMPTZ   NOT NULL DEFAULT now(),
    responded_at           TIMESTAMPTZ,
    CHECK (offered_by_org_id IN (requester_org_id, carrier_org_id))
);
CREATE INDEX ix_counter_offers_bid ON counter_offers (bid_id, created_at DESC);
-- Una sola contra-oferta vigente por oferta
CREATE UNIQUE INDEX ux_counter_offers_pending ON counter_offers (bid_id) WHERE status = 'PENDING';

-- ---------- RLS: solo las dos partes del hilo; el operador lee ----------
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY messages_parties_read ON messages FOR SELECT TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY messages_parties_insert ON messages FOR INSERT TO logyx_app
    WITH CHECK (sender_org_id = app_org() AND app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY messages_operator ON messages FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
-- El historial es inmutable (auditoría de la negociación)
REVOKE UPDATE, DELETE ON messages FROM logyx_app;

ALTER TABLE counter_offers ENABLE ROW LEVEL SECURITY;
CREATE POLICY counter_offers_parties_read ON counter_offers FOR SELECT TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY counter_offers_parties_insert ON counter_offers FOR INSERT TO logyx_app
    WITH CHECK (offered_by_org_id = app_org() AND app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY counter_offers_parties_update ON counter_offers FOR UPDATE TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id))
    WITH CHECK (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY counter_offers_operator ON counter_offers FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
REVOKE DELETE ON counter_offers FROM logyx_app;
