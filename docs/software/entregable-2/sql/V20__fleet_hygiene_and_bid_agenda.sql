-- =====================================================================
-- V20 — Higiene de flota y agenda de ofertas (ola 1, agente C). Reservada para C (B usa V19; dev admite out-of-order).
--  * vehicles.archived_at (roadmap 1.12): un vehículo vendido o dado de baja se archiva (no se borra: los envíos
--    históricos lo referencian) y deja de aparecer en las listas y de ofertar. NULL = activo.
--  * Licencia única DENTRO de la organización (LOGYX-FLT-005). Antes de crear el índice se renombran los duplicados
--    existentes (el más antiguo conserva el número; los demás reciben un sufijo con su id) para que la migración
--    no falle en bases de desarrollo con datos de prueba repetidos.
--  * ix_bids_vehicle_pending: la agenda del vehículo (ofertas pendientes solapadas, RN02 por fecha) consulta las
--    ofertas PENDING por vehículo.
-- Solo agrega una columna nullable y dos índices: no reescribe datos de negocio.
-- =====================================================================

ALTER TABLE vehicles ADD COLUMN archived_at TIMESTAMPTZ;

UPDATE drivers d
   SET license_number = left(d.license_number, 13) || '-' || left(d.id::text, 6)
  FROM (SELECT id, row_number() OVER (PARTITION BY organization_id, upper(license_number)
                                      ORDER BY created_at, id) AS rn
          FROM drivers) x
 WHERE d.id = x.id AND x.rn > 1;

CREATE UNIQUE INDEX ux_drivers_org_license ON drivers (organization_id, upper(license_number));

CREATE INDEX ix_bids_vehicle_pending ON bids (vehicle_id) WHERE status = 'PENDING';
