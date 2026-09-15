-- Valoracion en tiempo real: reaccion rapida (corazon/estrella/pulgar) que el dueno
-- envia mientras el servicio esta en curso, independiente de la calificacion final
-- que ya existe en la tabla "ratings" al terminar el servicio.

CREATE TABLE IF NOT EXISTS valoraciones_tiempo_real (
  id SERIAL PRIMARY KEY,
  service_request_id INTEGER NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo_reaccion TEXT NOT NULL CHECK (tipo_reaccion IN ('CORAZON', 'ESTRELLA', 'PULGAR')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_valoraciones_tiempo_real_service_request_id ON valoraciones_tiempo_real(service_request_id);
