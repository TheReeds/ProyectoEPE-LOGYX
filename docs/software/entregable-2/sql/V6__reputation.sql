-- =====================================================================
-- V6 — Reputación: calificaciones post-entrega y Trust Score (RN06, RN09).
-- La reputación es pública en el marketplace (RF44): reviews y
-- reputation_scores se leen entre organizaciones. reputation_scores solo
-- lo escribe el recálculo de plataforma (SystemTx), nunca un usuario.
-- =====================================================================

CREATE TABLE reviews (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id          UUID          NOT NULL REFERENCES shipments (id),
    requester_org_id     UUID          NOT NULL REFERENCES organizations (id),
    carrier_org_id       UUID          NOT NULL REFERENCES organizations (id),
    reviewer_org_id      UUID          NOT NULL REFERENCES organizations (id),
    reviewed_org_id      UUID          NOT NULL REFERENCES organizations (id),
    reviewer_profile_id  UUID          REFERENCES profiles (id),
    direction            VARCHAR(20)   NOT NULL CHECK (direction IN ('PYME_TO_CARRIER', 'CARRIER_TO_PYME')),
    punctuality          SMALLINT      NOT NULL CHECK (punctuality BETWEEN 1 AND 5),
    cargo_condition      SMALLINT      NOT NULL CHECK (cargo_condition BETWEEN 1 AND 5),
    communication        SMALLINT      NOT NULL CHECK (communication BETWEEN 1 AND 5),
    -- Promedio de las tres dimensiones
    rating               NUMERIC(3,2)  NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment              VARCHAR(1000),
    created_at           TIMESTAMPTZ   NOT NULL DEFAULT now(),
    UNIQUE (shipment_id, reviewer_org_id),
    CHECK (reviewer_org_id <> reviewed_org_id),
    CHECK (reviewer_org_id IN (requester_org_id, carrier_org_id)),
    CHECK (reviewed_org_id IN (requester_org_id, carrier_org_id))
);
CREATE INDEX ix_reviews_reviewed ON reviews (reviewed_org_id, created_at DESC);

CREATE TABLE reputation_scores (
    org_id               UUID PRIMARY KEY REFERENCES organizations (id),
    total_reviews        INT           NOT NULL DEFAULT 0,
    avg_rating           NUMERIC(4,2),
    avg_punctuality      NUMERIC(4,2),
    avg_cargo_condition  NUMERIC(4,2),
    avg_communication    NUMERIC(4,2),
    -- Trust Score bayesiano 0–100 anclado al prior 75 (RN09)
    trust_score          NUMERIC(5,2)  NOT NULL DEFAULT 75 CHECK (trust_score BETWEEN 0 AND 100),
    updated_at           TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- ---------- RLS ----------
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY reviews_public_read ON reviews FOR SELECT TO logyx_app USING (true);
CREATE POLICY reviews_party_insert ON reviews FOR INSERT TO logyx_app
    WITH CHECK (reviewer_org_id = app_org() AND app_org() IN (requester_org_id, carrier_org_id));
REVOKE UPDATE, DELETE ON reviews FROM logyx_app;

ALTER TABLE reputation_scores ENABLE ROW LEVEL SECURITY;
CREATE POLICY reputation_public_read ON reputation_scores FOR SELECT TO logyx_app USING (true);
-- Sin políticas de escritura: el recálculo corre en SystemTx (rol dueño).
REVOKE INSERT, UPDATE, DELETE ON reputation_scores FROM logyx_app;
