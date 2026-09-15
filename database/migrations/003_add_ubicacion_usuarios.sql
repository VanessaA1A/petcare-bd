-- Ubicacion registrada del usuario (propietario o cuidador), usada para
-- calcular cercania con solicitudes y ofertas de servicio.

ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS latitud double precision;
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS longitud double precision;
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS direccion_texto text;

CREATE INDEX IF NOT EXISTS idx_usuarios_ubicacion ON usuarios(latitud, longitud);
