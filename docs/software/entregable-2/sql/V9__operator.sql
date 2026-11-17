-- =====================================================================
-- V9 — Operador LOGYX: asignación manual (RN10).
-- Las políticas *_operator de V2 solo dan lectura. La asignación manual
-- crea la oferta "en nombre" del transportista, adjudica la solicitud y
-- genera el envío, igual que AcceptBidUseCase pero actuando el operador:
-- se agregan políticas de escritura limitadas al tipo OPERATOR (con RLS
-- activo, sin SystemTx). Ver docs/adr/0004.
-- =====================================================================

-- Marca de trazabilidad: la oferta la registró el operador (RN10), no el transportista.
ALTER TABLE bids ADD COLUMN assigned_by_operator BOOLEAN NOT NULL DEFAULT FALSE;

CREATE POLICY bids_operator_insert ON bids FOR INSERT TO logyx_app
    WITH CHECK (app_org_type() = 'OPERATOR' AND assigned_by_operator);
CREATE POLICY bids_operator_update ON bids FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');

CREATE POLICY requests_operator_update ON shipment_requests FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');

CREATE POLICY shipments_operator_insert ON shipments FOR INSERT TO logyx_app
    WITH CHECK (app_org_type() = 'OPERATOR');
CREATE POLICY stops_operator_insert ON shipment_stops FOR INSERT TO logyx_app
    WITH CHECK (app_org_type() = 'OPERATOR');
