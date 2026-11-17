-- =====================================================================
-- V3 — Aditiva. Denormaliza tipo y placa del vehículo en las ofertas.
-- La flota es privada del transportista (vehicles_owner) y la PYME no
-- puede leerla; copiar los datos al ofertar (igual que shipments.vehicle_plate)
-- evita abrir una excepción en RLS o usar SystemTx en cada listado de ofertas.
-- Las políticas de bids no cambian: las columnas nuevas heredan su visibilidad
-- (el transportista ve las suyas, la PYME las de sus solicitudes).
-- =====================================================================
ALTER TABLE bids ADD COLUMN vehicle_type  VARCHAR(16);
ALTER TABLE bids ADD COLUMN vehicle_plate VARCHAR(10);

-- Backfill: la migración corre como dueño del esquema (sin RLS).
UPDATE bids b
   SET vehicle_type = v.type, vehicle_plate = v.plate
  FROM vehicles v
 WHERE v.id = b.vehicle_id;

ALTER TABLE bids ALTER COLUMN vehicle_type  SET NOT NULL;
ALTER TABLE bids ALTER COLUMN vehicle_plate SET NOT NULL;
ALTER TABLE bids ADD CONSTRAINT ck_bids_vehicle_type
    CHECK (vehicle_type IN ('VAN', 'TRUCK_SMALL', 'TRUCK_MEDIUM', 'TRUCK_LARGE',
                            'PLATFORM', 'REFRIGERATED', 'TANKER'));
