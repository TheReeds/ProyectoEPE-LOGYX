-- =====================================================================
-- V19 — Zona B del roadmap v2 (Ola 1): envíos, seguimiento público y conductor con mala señal.
--  * shipment_stops: contacto, ventana horaria e instrucciones de cada parada (RN07 post-adjudicación, roadmap 1.3).
--    Se copian de la solicitud al adjudicar (CreateShipmentUseCase). Respaldo de los envíos existentes desde sus
--    solicitudes. Las ven solo las partes, el conductor asignado y el operador.
--  * shipment_stops.arrived_recorded_at / completed_recorded_at (roadmap 1.11): hora del SERVIDOR en que llegó el
--    evento. arrived_at / completed_at pasan a ser la hora en que ocurrió (la del dispositivo, acotada por
--    StopEventTimePolicy). Respaldo: iguales a la hora existente.
--  * stops_driver_scope (RESTRICTIVA): un conductor solo lee y toca las paradas de los envíos que tiene asignados,
--    aunque su organización (el transportista) vea todas. Antes lo hacía solo la aplicación.
--  * shipment_share_links (roadmap 1.6, ADR-0011): enlaces públicos de seguimiento. El token (128 bits) NUNCA se
--    guarda: solo su SHA-256 (token_hash) y 4 caracteres para reconocerlo (token_hint). La PYME dueña del envío los
--    lee, crea y revoca (solo la columna revoked_at); el operador los lee. Las visitas (views, last_viewed_at) las
--    registra la plataforma (SystemTx) al resolver el enlace público. Sin DELETE.
-- Aditiva: solo agrega columnas nullable, una tabla y políticas.
-- =====================================================================

-- ---------- Paradas: contacto, ventana e instrucciones ----------
ALTER TABLE shipment_stops ADD COLUMN contact_name   VARCHAR(120);
ALTER TABLE shipment_stops ADD COLUMN contact_phone  VARCHAR(20);
ALTER TABLE shipment_stops ADD COLUMN window_from    TIME;
ALTER TABLE shipment_stops ADD COLUMN window_to      TIME;
ALTER TABLE shipment_stops ADD COLUMN instructions   VARCHAR(300);

UPDATE shipment_stops st
   SET contact_name = r.pickup_contact_name, contact_phone = r.pickup_contact_phone,
       window_from = r.pickup_window_from, window_to = r.pickup_window_to, instructions = r.pickup_instructions
  FROM shipments s JOIN shipment_requests r ON r.id = s.request_id
 WHERE st.shipment_id = s.id AND st.type = 'PICKUP' AND st.sequence = 1;

UPDATE shipment_stops st
   SET contact_name = r.delivery_contact_name, contact_phone = r.delivery_contact_phone,
       window_from = r.delivery_window_from, window_to = r.delivery_window_to, instructions = r.delivery_instructions
  FROM shipments s JOIN shipment_requests r ON r.id = s.request_id
 WHERE st.shipment_id = s.id AND st.type = 'DELIVERY'
   AND st.sequence = (SELECT max(x.sequence) FROM shipment_stops x WHERE x.shipment_id = st.shipment_id);

-- ---------- Paradas: hora del servidor junto a la hora del evento ----------
ALTER TABLE shipment_stops ADD COLUMN arrived_recorded_at   TIMESTAMPTZ;
ALTER TABLE shipment_stops ADD COLUMN completed_recorded_at TIMESTAMPTZ;
UPDATE shipment_stops SET arrived_recorded_at = arrived_at WHERE arrived_at IS NOT NULL;
UPDATE shipment_stops SET completed_recorded_at = completed_at WHERE completed_at IS NOT NULL;

-- ---------- Paradas: el conductor solo ve las de sus envíos ----------
-- app_driver_id(): id del conductor de la persona de la transacción (NULL si no es conductor). Lee drivers bajo la
-- RLS de quien llama (drivers_owner: su organización), así una PYME o el operador obtienen NULL.
CREATE OR REPLACE FUNCTION app_driver_id() RETURNS UUID
    LANGUAGE sql STABLE AS
$$ SELECT d.id FROM drivers d WHERE d.profile_id = app_profile() $$;

CREATE POLICY stops_driver_scope ON shipment_stops AS RESTRICTIVE FOR ALL TO logyx_app
    USING ((SELECT app_driver_id()) IS NULL
           OR EXISTS (SELECT 1 FROM shipments s
                      WHERE s.id = shipment_stops.shipment_id AND s.driver_id = (SELECT app_driver_id())))
    WITH CHECK ((SELECT app_driver_id()) IS NULL
           OR EXISTS (SELECT 1 FROM shipments s
                      WHERE s.id = shipment_stops.shipment_id AND s.driver_id = (SELECT app_driver_id())));

-- ---------- Enlaces públicos de seguimiento ----------
CREATE TABLE shipment_share_links (
    id                UUID PRIMARY KEY,
    shipment_id       UUID         NOT NULL REFERENCES shipments (id),
    requester_org_id  UUID         NOT NULL REFERENCES organizations (id),
    -- SHA-256 en hexadecimal del token (base64url de 16 bytes aleatorios). El token no se guarda.
    token_hash        CHAR(64)     NOT NULL UNIQUE,
    token_hint        VARCHAR(4)   NOT NULL,
    created_by        UUID         REFERENCES profiles (id),
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    -- Caducidad elegida al crear (NULL = sin fecha propia). Además vence 7 días después de cerrarse el envío.
    expires_at        TIMESTAMPTZ,
    revoked_at        TIMESTAMPTZ,
    revoked_by        UUID         REFERENCES profiles (id),
    last_viewed_at    TIMESTAMPTZ,
    views             INT          NOT NULL DEFAULT 0 CHECK (views >= 0)
);
CREATE INDEX ix_share_links_shipment ON shipment_share_links (shipment_id, created_at DESC);

ALTER TABLE shipment_share_links ENABLE ROW LEVEL SECURITY;
CREATE POLICY share_links_owner_read ON shipment_share_links FOR SELECT TO logyx_app
    USING (requester_org_id = app_org() AND app_org_type() = 'PYME');
CREATE POLICY share_links_owner_insert ON shipment_share_links FOR INSERT TO logyx_app
    WITH CHECK (requester_org_id = app_org() AND app_org_type() = 'PYME'
                AND EXISTS (SELECT 1 FROM shipments s
                            WHERE s.id = shipment_share_links.shipment_id AND s.requester_org_id = app_org()));
CREATE POLICY share_links_owner_revoke ON shipment_share_links FOR UPDATE TO logyx_app
    USING (requester_org_id = app_org() AND app_org_type() = 'PYME')
    WITH CHECK (requester_org_id = app_org() AND app_org_type() = 'PYME');
CREATE POLICY share_links_operator_read ON shipment_share_links FOR SELECT TO logyx_app
    USING (app_org_type() = 'OPERATOR');
-- Solo se revoca: ningún otro dato del enlace es editable por el usuario (las visitas las cuenta la plataforma).
REVOKE UPDATE, DELETE ON shipment_share_links FROM logyx_app;
GRANT UPDATE (revoked_at, revoked_by) ON shipment_share_links TO logyx_app;

-- ---------- Listado de envíos filtrado en el servidor (roadmap 1.5) ----------
CREATE INDEX ix_shipments_requester_status ON shipments (requester_org_id, status, created_at DESC);
CREATE INDEX ix_shipments_carrier_status ON shipments (carrier_org_id, status, created_at DESC);
