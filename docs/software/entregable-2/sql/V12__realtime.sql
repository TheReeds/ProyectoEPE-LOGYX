-- =====================================================================
-- LOGYX — Tiempo real por SSE (ADR-0007)
--
-- realtime_events es una PROYECCIÓN del outbox (ADR-0006): pe.logyx.realtime.application.RealtimeProjector observa
-- cada evento @Outboxed y escribe una fila por destinatario, en la MISMA transacción de sistema del despacho (o se
-- proyecta y se marca DONE, o nada). Cada fila lleva un payload mínimo (ids + tipo + datos no sensibles) y su
-- destinatario explícito:
--   - org_id            → los usuarios de esa organización (no los conductores);
--   - org_id + user_id  → solo ese usuario (el conductor del envío);
--   - org_type sin org  → difusión a todas las organizaciones de ese tipo (p. ej. conteo de ofertas a transportistas).
-- El trigger avisa por LISTEN/NOTIFY (canal logyx_realtime, payload = seq) a todas las instancias de la API al
-- confirmarse la transacción; cada instancia lee las filas por seq y las entrega a sus conexiones SSE locales.
-- La reanudación (Last-Event-ID = seq) se lee como el usuario, bajo RLS.
-- =====================================================================
CREATE TABLE realtime_events (
    seq          BIGSERIAL    PRIMARY KEY,
    event_type   VARCHAR(60)  NOT NULL,
    org_id       UUID         REFERENCES organizations (id) ON DELETE CASCADE,
    org_type     VARCHAR(20)  CHECK (org_type IN ('PYME', 'CARRIER', 'OPERATOR')),
    user_id      UUID,
    payload      JSONB        NOT NULL,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CHECK (org_id IS NOT NULL OR (org_type IS NOT NULL AND user_id IS NULL))
);
CREATE INDEX ix_realtime_events_org ON realtime_events (org_id, seq) WHERE org_id IS NOT NULL;
CREATE INDEX ix_realtime_events_broadcast ON realtime_events (org_type, seq) WHERE org_id IS NULL;
CREATE INDEX ix_realtime_events_created ON realtime_events (created_at);

-- Lectura (reanudación) solo de lo dirigido a la propia organización o a su tipo de organización. logyx_app no
-- inserta, modifica ni borra: solo el despacho del outbox (SystemTx) escribe.
ALTER TABLE realtime_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE realtime_events FROM logyx_app;
GRANT SELECT ON TABLE realtime_events TO logyx_app;
REVOKE ALL ON SEQUENCE realtime_events_seq_seq FROM logyx_app;
CREATE POLICY realtime_events_read ON realtime_events FOR SELECT TO logyx_app
    USING (org_id = app_org() OR (org_id IS NULL AND org_type = app_org_type()));

-- Fan-out entre instancias: NOTIFY se entrega al confirmar la transacción (nunca lo revertido).
CREATE FUNCTION realtime_events_notify() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    PERFORM pg_notify('logyx_realtime', NEW.seq::text);
    RETURN NULL;
END
$$;
CREATE TRIGGER realtime_events_notify AFTER INSERT ON realtime_events
    FOR EACH ROW EXECUTE FUNCTION realtime_events_notify();
