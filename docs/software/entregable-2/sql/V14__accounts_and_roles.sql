-- =====================================================================
-- V14 — Cuentas, contraseñas y roles (docs/reviews/2026-11-16-flow-gaps.md F02, F03, F20, F24, F31, F55; ADR-0009).
--  * Revocación de sesiones con JWT: profiles.session_version (claim "sv" del token).
--  * Invitaciones de usuarios de la organización y último acceso.
--  * Tokens de un solo uso para restablecer/definir contraseña (password_tokens) y refresh tokens rotativos del
--    conductor/móvil (refresh_tokens). Solo los toca la plataforma (SystemTx): logyx_app no tiene privilegios.
--  * Dirección opcional de la organización (perfil editable, F20).
-- Solo agrega columnas y tablas: no reescribe datos.
-- =====================================================================

-- ---------- Usuarios ----------
-- Sube al cambiar/restablecer la contraseña, cambiar el rol, desactivar o "cerrar sesión en todos los dispositivos":
-- los JWT con otro "sv" dejan de valer (pe.logyx.identity.infrastructure.security.AccountAccessFilter).
ALTER TABLE profiles ADD COLUMN session_version     INT         NOT NULL DEFAULT 0;
ALTER TABLE profiles ADD COLUMN last_login_at       TIMESTAMPTZ;
ALTER TABLE profiles ADD COLUMN password_changed_at TIMESTAMPTZ;
-- Invitado por un ADMIN que aún no definió su contraseña (la de la fila es aleatoria e inutilizable).
ALTER TABLE profiles ADD COLUMN invitation_pending  BOOLEAN     NOT NULL DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN invited_by          UUID        REFERENCES profiles (id);
-- Regla "al menos un ADMIN activo por organización" (lo consulta OrganizationUserService con la fila de la
-- organización bloqueada).
CREATE INDEX ix_profiles_org_role ON profiles (organization_id, role) WHERE active;

-- ---------- Organización: dirección fiscal/comercial opcional (no es pública) ----------
ALTER TABLE organizations ADD COLUMN address VARCHAR(200);

-- ---------- Tokens de contraseña (restablecer e invitación) ----------
-- En la BD solo va el SHA-256 (hex) del token; el token en claro solo viaja en el enlace del correo.
CREATE TABLE password_tokens (
    id          UUID PRIMARY KEY,
    profile_id  UUID        NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
    purpose     VARCHAR(16) NOT NULL CHECK (purpose IN ('RESET', 'INVITE')),
    token_hash  CHAR(64)    NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    used_at     TIMESTAMPTZ,
    -- Pedir uno nuevo (o usar otro) invalida los anteriores sin usar.
    revoked_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX ux_password_tokens_hash ON password_tokens (token_hash);
CREATE INDEX ix_password_tokens_profile ON password_tokens (profile_id) WHERE used_at IS NULL AND revoked_at IS NULL;
CREATE INDEX ix_password_tokens_expires ON password_tokens (expires_at);

-- ---------- Refresh tokens rotativos (opt-in, conductor/móvil, F24) ----------
-- Una familia = un inicio de sesión. Cada uso rota el token (el anterior queda used_at); reutilizar uno ya usado
-- revoca toda la familia (detección de robo). family_expires_at es absoluto: la rotación no lo extiende.
CREATE TABLE refresh_tokens (
    id                UUID PRIMARY KEY,
    family_id         UUID        NOT NULL,
    profile_id        UUID        NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
    token_hash        CHAR(64)    NOT NULL,
    session_version   INT         NOT NULL,
    family_expires_at TIMESTAMPTZ NOT NULL,
    used_at           TIMESTAMPTZ,
    revoked_at        TIMESTAMPTZ,
    user_agent        VARCHAR(200),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX ux_refresh_tokens_hash ON refresh_tokens (token_hash);
CREATE INDEX ix_refresh_tokens_family ON refresh_tokens (family_id);
CREATE INDEX ix_refresh_tokens_profile ON refresh_tokens (profile_id) WHERE revoked_at IS NULL;
CREATE INDEX ix_refresh_tokens_expires ON refresh_tokens (family_expires_at);

-- ---------- Aislamiento ----------
-- Credenciales de la plataforma: logyx_app no las lee ni escribe nunca (ni siquiera las de su organización).
-- RLS activada SIN políticas para logyx_app (deniega todo) y, además, sin privilegios: V2 da por defecto
-- SELECT/INSERT/UPDATE/DELETE a toda tabla nueva, se revocan explícitamente.
-- Sin FORCE ROW LEVEL SECURITY a propósito: logyx_owner (dueño, sin BYPASSRLS; ADR-0006) es quien las usa vía
-- SystemTx, y con FORCE quedaría sujeto a RLS sin política propia (no vería nada). Ver ADR-0009.
ALTER TABLE password_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE refresh_tokens ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE password_tokens FROM logyx_app;
REVOKE ALL ON TABLE refresh_tokens FROM logyx_app;
