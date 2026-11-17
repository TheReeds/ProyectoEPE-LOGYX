-- =====================================================================
-- V5 — Documentos y evidencia de entrega (fotos, firma, guía de remisión...).
-- El archivo vive en el almacenamiento (DocumentStorage: disco local en el
-- MVP, S3/MinIO después); aquí solo los metadatos y la clave de almacenamiento.
-- =====================================================================

CREATE TABLE documents (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipment_id         UUID         NOT NULL REFERENCES shipments (id),
    stop_id             UUID         REFERENCES shipment_stops (id),
    requester_org_id    UUID         NOT NULL REFERENCES organizations (id),
    carrier_org_id      UUID         NOT NULL REFERENCES organizations (id),
    type                VARCHAR(20)  NOT NULL CHECK (type IN ('SERVICE_ORDER', 'REMISSION_GUIDE', 'RECEIPT',
                                                             'DELIVERY_PHOTO', 'SIGNATURE', 'OTHER')),
    file_name           VARCHAR(255) NOT NULL,
    content_type        VARCHAR(100) NOT NULL,
    file_size_bytes     BIGINT       NOT NULL CHECK (file_size_bytes > 0),
    sha256              VARCHAR(64)  NOT NULL,
    storage_key         VARCHAR(500) NOT NULL UNIQUE,
    uploaded_by         UUID         NOT NULL REFERENCES profiles (id),
    uploaded_by_org_id  UUID         NOT NULL REFERENCES organizations (id),
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CHECK (uploaded_by_org_id IN (requester_org_id, carrier_org_id))
);
CREATE INDEX ix_documents_shipment ON documents (shipment_id, created_at);
CREATE INDEX ix_documents_stop ON documents (stop_id, type) WHERE stop_id IS NOT NULL;

-- ---------- RLS: solo las partes del envío (RF47); el operador lee ----------
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY documents_parties_read ON documents FOR SELECT TO logyx_app
    USING (app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY documents_parties_insert ON documents FOR INSERT TO logyx_app
    WITH CHECK (uploaded_by_org_id = app_org() AND app_org() IN (requester_org_id, carrier_org_id));
CREATE POLICY documents_operator ON documents FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
-- La evidencia es inmutable
REVOKE UPDATE, DELETE ON documents FROM logyx_app;
