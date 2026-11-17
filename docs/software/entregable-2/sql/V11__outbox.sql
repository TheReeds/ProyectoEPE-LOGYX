-- =====================================================================
-- LOGYX — Outbox transaccional de eventos de dominio (ADR-0004 → ADR-0006)
--
-- pe.logyx.shared.outbox.OutboxRecorder inserta cada evento en la MISMA transacción del caso de uso;
-- OutboxDispatcher (SystemTx, FOR UPDATE SKIP LOCKED) lo entrega a los consumidores y lo marca DONE en la
-- transacción que crea las notificaciones. Los DONE se conservan unos días: la fase de tiempo real (SSE)
-- reanudará desde `seq` (Last-Event-ID).
-- =====================================================================
CREATE TABLE outbox_events (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seq           BIGSERIAL     NOT NULL UNIQUE,
    event_type    VARCHAR(200)  NOT NULL,
    payload       JSONB         NOT NULL,
    -- organización que originó el evento (contexto RLS de la transacción); NULL en operaciones de sistema
    actor_org_id  UUID          DEFAULT app_org(),
    status        VARCHAR(10)   NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'DONE', 'FAILED')),
    attempts      INT           NOT NULL DEFAULT 0,
    available_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT now(),
    processed_at  TIMESTAMPTZ,
    last_error    VARCHAR(1000)
);
CREATE INDEX outbox_events_pending ON outbox_events (seq) WHERE status = 'PENDING';
CREATE INDEX outbox_events_done ON outbox_events (processed_at) WHERE status = 'DONE';

-- logyx_app solo puede encolar eventos a nombre de su propia organización, nunca leer/modificar/borrar el outbox.
ALTER TABLE outbox_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE outbox_events FROM logyx_app;
GRANT INSERT ON TABLE outbox_events TO logyx_app;
CREATE POLICY outbox_events_insert ON outbox_events FOR INSERT TO logyx_app
    WITH CHECK (actor_org_id = app_org() AND status = 'PENDING' AND attempts = 0 AND processed_at IS NULL);
