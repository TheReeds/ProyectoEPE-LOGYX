-- =====================================================================
-- V16 — Zona D del roadmap v2 (Ola 1): avisos por persona, preferencias de aviso y autoría.
--  * app_profile(): perfil del usuario de la transacción (TenantSessionBinder fija app.profile_id junto a app.org_id).
--  * notifications pasa de "por organización" a "por persona": cada fila tiene su profile_id y su propio read_at.
--    Un aviso para "toda la organización" se expande al generarse en una fila por persona activa (sin conductores)
--    según sus preferencias (NotificationPublisher). Las filas anteriores a V16 se expanden aquí a cada persona activa
--    de la organización, conservando si ya estaban leídas.
--    mine = el aviso es de algo que esa persona creó (su solicitud, su oferta): marca «Tuyo» y filtro «Solo míos».
--    RLS: solo el destinatario lee y marca (org_id = app_org() AND profile_id = app_profile()); logyx_app solo puede
--    actualizar read_at (privilegio por columna) y sigue sin INSERT ni DELETE (ADR-0004).
--  * notification_preferences: qué categorías de aviso recibe cada persona y por qué canal (in-app, correo). Sin fila =
--    valores por defecto del dominio (NotificationPreferencePolicy). RLS por persona.
--  * Tipo de aviso nuevo ACCESS_REQUESTED (un Lector pide acceso a los ADMIN) y destino USER (la persona que lo pidió).
--  * bids.created_by: quién de la organización ofertó (autoría). Lo rellena la BD con app_profile() (DEFAULT), así
--    ningún caso de uso cambia; NULL en ofertas previas y en las creadas por el sistema.
--  * realtime_events_read: un evento dirigido a una persona (user_id) ya no lo lee el resto de su organización.
-- =====================================================================

CREATE OR REPLACE FUNCTION app_profile() RETURNS UUID
    LANGUAGE sql STABLE AS
$$ SELECT nullif(current_setting('app.profile_id', true), '')::uuid $$;

-- ---------- notifications por persona ----------
ALTER TABLE notifications ADD COLUMN profile_id UUID REFERENCES profiles (id) ON DELETE CASCADE;
ALTER TABLE notifications ADD COLUMN mine BOOLEAN NOT NULL DEFAULT FALSE;

-- Expande cada aviso previo a las personas activas de su organización (sin conductores). La primera persona conserva
-- el id original (enlaces ya entregados por tiempo real); las demás reciben uno nuevo.
WITH targets AS (
    SELECT n.id AS nid, p.id AS pid,
           row_number() OVER (PARTITION BY n.id ORDER BY (p.role = 'ADMIN') DESC, p.created_at, p.id) AS rn
    FROM notifications n
    JOIN profiles p ON p.organization_id = n.org_id AND p.active AND p.role <> 'DRIVER' AND NOT p.invitation_pending
    WHERE n.profile_id IS NULL
)
INSERT INTO notifications (id, org_id, profile_id, type, title, body, related_type, related_id, read_at, created_at)
SELECT gen_random_uuid(), n.org_id, t.pid, n.type, n.title, n.body, n.related_type, n.related_id, n.read_at, n.created_at
FROM targets t JOIN notifications n ON n.id = t.nid
WHERE t.rn > 1;

UPDATE notifications n SET profile_id = t.pid
FROM (SELECT DISTINCT ON (n2.id) n2.id AS nid, p.id AS pid
      FROM notifications n2
      JOIN profiles p ON p.organization_id = n2.org_id AND p.active AND p.role <> 'DRIVER' AND NOT p.invitation_pending
      WHERE n2.profile_id IS NULL
      ORDER BY n2.id, (p.role = 'ADMIN') DESC, p.created_at, p.id) t
WHERE n.id = t.nid;

-- Avisos de organizaciones sin ninguna persona activa: no tienen a quién llegar.
DELETE FROM notifications WHERE profile_id IS NULL;
ALTER TABLE notifications ALTER COLUMN profile_id SET NOT NULL;

DROP INDEX IF EXISTS ix_notifications_org;
DROP INDEX IF EXISTS ix_notifications_unread;
CREATE INDEX ix_notifications_profile ON notifications (profile_id, created_at DESC, id);
CREATE INDEX ix_notifications_profile_unread ON notifications (profile_id) WHERE read_at IS NULL;
CREATE INDEX ix_notifications_org ON notifications (org_id, created_at DESC);

ALTER TABLE notifications DROP CONSTRAINT notifications_type_check;
ALTER TABLE notifications ADD CONSTRAINT notifications_type_check
    CHECK (type IN ('NEW_BID', 'BID_ACCEPTED', 'BID_REJECTED', 'COUNTER_OFFER', 'NEW_MESSAGE',
                    'SHIPMENT_STATUS_CHANGE', 'INCIDENT_REPORTED', 'INCIDENT_RESOLVED', 'NEW_REVIEW',
                    'TRIP_BOOKING_REQUESTED', 'TRIP_BOOKING_CONFIRMED', 'TRIP_BOOKING_REJECTED',
                    'TRIP_BOOKING_CANCELLED', 'TRIP_CANCELLED', 'SMART_LOAD_SUGGESTED', 'SMART_LOAD_ACCEPTED',
                    'AUCTION_CLOSED', 'REQUEST_CANCELLED', 'SHIPMENT_CANCELLED', 'BID_WITHDRAWN',
                    'ORGANIZATION_VERIFICATION', 'ACCESS_REQUESTED'));
ALTER TABLE notifications DROP CONSTRAINT notifications_related_type_check;
ALTER TABLE notifications ADD CONSTRAINT notifications_related_type_check
    CHECK (related_type IN ('REQUEST', 'BID', 'COUNTER_OFFER', 'SHIPMENT', 'INCIDENT', 'REVIEW', 'TRIP', 'SMART_LOAD',
                            'ORGANIZATION', 'USER'));

DROP POLICY notifications_own_read ON notifications;
DROP POLICY notifications_own_update ON notifications;
CREATE POLICY notifications_own_read ON notifications FOR SELECT TO logyx_app
    USING (org_id = app_org() AND profile_id = app_profile());
CREATE POLICY notifications_own_update ON notifications FOR UPDATE TO logyx_app
    USING (org_id = app_org() AND profile_id = app_profile())
    WITH CHECK (org_id = app_org() AND profile_id = app_profile());
-- Solo marcar como leído: ningún otro dato del aviso es editable por el usuario.
REVOKE INSERT, UPDATE, DELETE ON notifications FROM logyx_app;
GRANT UPDATE (read_at) ON notifications TO logyx_app;

-- ---------- Preferencias de aviso por persona ----------
CREATE TABLE notification_preferences (
    profile_id  UUID         NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
    org_id      UUID         NOT NULL REFERENCES organizations (id),
    category    VARCHAR(24)  NOT NULL CHECK (category IN ('BIDS', 'AWARDS', 'REQUESTS', 'NEGOTIATION', 'SHIPMENTS',
                                                          'INCIDENTS', 'REVIEWS', 'TRIPS', 'SMART_LOAD', 'ACCOUNT')),
    in_app      BOOLEAN      NOT NULL,
    email       BOOLEAN      NOT NULL,
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    PRIMARY KEY (profile_id, category)
);
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY notification_preferences_own ON notification_preferences FOR ALL TO logyx_app
    USING (profile_id = app_profile() AND org_id = app_org())
    WITH CHECK (profile_id = app_profile() AND org_id = app_org());
REVOKE DELETE ON notification_preferences FROM logyx_app;

-- ---------- Autoría de las ofertas ----------
ALTER TABLE bids ADD COLUMN created_by UUID REFERENCES profiles (id) DEFAULT app_profile();
CREATE INDEX ix_bids_created_by ON bids (created_by) WHERE created_by IS NOT NULL;

-- ---------- Tiempo real: lo dirigido a una persona solo lo lee esa persona ----------
DROP POLICY realtime_events_read ON realtime_events;
CREATE POLICY realtime_events_read ON realtime_events FOR SELECT TO logyx_app
    USING ((org_id = app_org() AND (user_id IS NULL OR user_id = app_profile()))
           OR (org_id IS NULL AND org_type = app_org_type()));
