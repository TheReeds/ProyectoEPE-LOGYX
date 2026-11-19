-- =====================================================================
-- V13 — Huecos de flujo de la revisión 2026-11-16 (docs/reviews/2026-11-16-flow-gaps.md).
--  * F04/F05 (RN01): verificación de organizaciones por el operador, separada del dígito verificador del RUC.
--  * F08 (RF26): el transportista retira su oferta (WITHDRAWN); contra-ofertas del transportista.
--  * F06/F11/F12: cancelación de envíos con motivo, cambio de vehículo, grupos de carga consolidada.
--  * F13 (RF55): estado final del envío al resolver una incidencia.
--  * F07/F16: avisos de subasta cerrada y solicitud cancelada; republicar.
-- Solo agrega columnas, valores permitidos y políticas: no se reescriben datos de negocio salvo el
-- estado de verificación inicial (ver más abajo).
-- =====================================================================

-- ---------- Organizaciones: verificación (RN01, RF08) ----------
-- ruc_verification (NONE/CHECKSUM/SUNAT) sigue diciendo qué tan validado está el RUC. verification_status es la
-- decisión de la plataforma: solo VERIFIED habilita publicar, ofertar y publicar viajes (si
-- logyx.verification.required) y da el sello "Verificado". SUSPENDED bloquea siempre.
ALTER TABLE organizations ADD COLUMN verification_status VARCHAR(16) NOT NULL DEFAULT 'PENDING'
    CHECK (verification_status IN ('PENDING', 'VERIFIED', 'REJECTED', 'SUSPENDED'));
ALTER TABLE organizations ADD COLUMN verification_note       VARCHAR(500);
ALTER TABLE organizations ADD COLUMN verification_updated_at TIMESTAMPTZ;
ALTER TABLE organizations ADD COLUMN verification_updated_by UUID REFERENCES profiles (id);
-- Los operadores los crea LOGYX: quedan verificados. El resto queda PENDING hasta que el operador decida
-- (cambio deliberado: antes el sello salía solo del dígito verificador, F04).
UPDATE organizations SET verification_status = 'VERIFIED', verification_updated_at = now() WHERE type = 'OPERATOR';
CREATE INDEX ix_organizations_verification ON organizations (verification_status, created_at);

-- El operador decide la verificación de cualquier organización (con RLS, sin SystemTx; ADR-0004).
CREATE POLICY orgs_operator_update ON organizations FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');

-- orgs_update_own deja a cada organización editar su fila: las columnas de verificación (y el nivel del RUC)
-- solo las cambia el operador o la plataforma (dueño del esquema, SystemTx).
CREATE OR REPLACE FUNCTION organizations_guard_verification() RETURNS trigger
    LANGUAGE plpgsql AS
$$
BEGIN
    IF current_user = 'logyx_app' AND coalesce(app_org_type(), '') <> 'OPERATOR'
       AND (NEW.verification_status IS DISTINCT FROM OLD.verification_status
            OR NEW.verification_note IS DISTINCT FROM OLD.verification_note
            OR NEW.verification_updated_at IS DISTINCT FROM OLD.verification_updated_at
            OR NEW.verification_updated_by IS DISTINCT FROM OLD.verification_updated_by
            OR NEW.ruc_verification IS DISTINCT FROM OLD.ruc_verification) THEN
        RAISE EXCEPTION 'solo el operador cambia la verificación de una organización'
            USING ERRCODE = 'insufficient_privilege';
    END IF;
    RETURN NEW;
END
$$;
CREATE TRIGGER trg_organizations_guard_verification BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION organizations_guard_verification();

-- ---------- Ofertas: retiro (F08) y grupo de carga consolidada (F12) ----------
ALTER TABLE bids DROP CONSTRAINT bids_status_check;
ALTER TABLE bids ADD CONSTRAINT bids_status_check
    CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'WITHDRAWN'));
-- Sugerencia Smart Load (o viaje publicado) que agrupa ofertas/envíos en un mismo vehículo.
ALTER TABLE bids ADD COLUMN load_group_id UUID;

-- ---------- Solicitudes: motivo de cancelación y republicación (F06, F07, F16) ----------
ALTER TABLE shipment_requests ADD COLUMN cancel_reason      VARCHAR(500);
ALTER TABLE shipment_requests ADD COLUMN republished_from   UUID REFERENCES shipment_requests (id);

-- ---------- Envíos: cancelación con motivo, cambio de vehículo, carga consolidada (F06, F11, F12) ----------
ALTER TABLE shipments ADD COLUMN cancel_reason        VARCHAR(500);
ALTER TABLE shipments ADD COLUMN cancelled_at         TIMESTAMPTZ;
ALTER TABLE shipments ADD COLUMN cancelled_by_org_id  UUID REFERENCES organizations (id);
ALTER TABLE shipments ADD COLUMN load_group_id        UUID;
CREATE INDEX ix_shipments_vehicle_active ON shipments (vehicle_id) WHERE status IN ('PENDING', 'IN_TRANSIT');
CREATE INDEX ix_shipments_driver_active ON shipments (driver_id)
    WHERE driver_id IS NOT NULL AND status IN ('PENDING', 'IN_TRANSIT');

-- El operador cancela un envío o fija su estado final al resolver una incidencia (RF55): actualiza el envío y sus
-- paradas, y libera el vehículo y el conductor. Solo UPDATE, limitado al tipo OPERATOR (como V9).
CREATE POLICY shipments_operator_update ON shipments FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');
CREATE POLICY stops_operator_update ON shipment_stops FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');
CREATE POLICY vehicles_operator_update ON vehicles FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');
CREATE POLICY drivers_operator_update ON drivers FOR UPDATE TO logyx_app
    USING (app_org_type() = 'OPERATOR') WITH CHECK (app_org_type() = 'OPERATOR');

-- ---------- Incidencias: estado final del envío al resolver (RF55, F13) ----------
ALTER TABLE incidents ADD COLUMN shipment_outcome VARCHAR(16)
    CHECK (shipment_outcome IN ('RESUME', 'DELIVERED', 'CANCELLED'));

-- ---------- Notificaciones nuevas ----------
ALTER TABLE notifications DROP CONSTRAINT notifications_type_check;
ALTER TABLE notifications ADD CONSTRAINT notifications_type_check
    CHECK (type IN ('NEW_BID', 'BID_ACCEPTED', 'BID_REJECTED', 'COUNTER_OFFER', 'NEW_MESSAGE',
                    'SHIPMENT_STATUS_CHANGE', 'INCIDENT_REPORTED', 'INCIDENT_RESOLVED', 'NEW_REVIEW',
                    'TRIP_BOOKING_REQUESTED', 'TRIP_BOOKING_CONFIRMED', 'TRIP_BOOKING_REJECTED',
                    'TRIP_BOOKING_CANCELLED', 'TRIP_CANCELLED', 'SMART_LOAD_SUGGESTED', 'SMART_LOAD_ACCEPTED',
                    'AUCTION_CLOSED', 'REQUEST_CANCELLED', 'SHIPMENT_CANCELLED', 'BID_WITHDRAWN',
                    'ORGANIZATION_VERIFICATION'));
ALTER TABLE notifications DROP CONSTRAINT notifications_related_type_check;
ALTER TABLE notifications ADD CONSTRAINT notifications_related_type_check
    CHECK (related_type IN ('REQUEST', 'BID', 'COUNTER_OFFER', 'SHIPMENT', 'INCIDENT', 'REVIEW', 'TRIP', 'SMART_LOAD',
                            'ORGANIZATION'));
