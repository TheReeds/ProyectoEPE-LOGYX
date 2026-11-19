-- =====================================================================
-- V15 — Auditoría del operador (F05) y lectura de solicitudes por quien ofertó (F15).
--  * Índices de audit_log para el visor del operador (paginado por fecha, filtros por organización, actor y acción).
--  * Política de lectura mínima: un transportista sigue viendo la solicitud en la que ofertó aunque se adjudique a otro
--    o se cancele (antes solo veía PUBLISHED o las adjudicadas a él, y la solicitud desaparecía de "Mis ofertas").
--  * Índice parcial de ofertas pendientes por solicitud (posición y mejor oferta sin recorrer toda la tabla).
-- No cambia datos ni quita políticas.
-- =====================================================================

CREATE INDEX ix_audit_occurred ON audit_log (occurred_at DESC, id DESC);
CREATE INDEX ix_audit_org ON audit_log (organization_id, occurred_at DESC);
CREATE INDEX ix_audit_actor ON audit_log (actor_profile_id, occurred_at DESC);
CREATE INDEX ix_audit_action ON audit_log (action, occurred_at DESC);

-- F15. Solo lectura, solo para el transportista que tiene una oferta propia en esa solicitud (cualquier estado,
-- incluida la retirada o rechazada). No da acceso a las ofertas ajenas (bids_carrier sigue limitando a las suyas) ni a
-- ningún dato del envío o del ganador: las columnas de la solicitud ya eran visibles mientras estuvo publicada.
CREATE POLICY requests_bidder_read ON shipment_requests FOR SELECT TO logyx_app
    USING (app_org_type() = 'CARRIER'
           AND id IN (SELECT b.request_id FROM bids b WHERE b.carrier_org_id = app_org()));

CREATE INDEX ix_bids_request_pending ON bids (request_id, amount) WHERE status = 'PENDING';
