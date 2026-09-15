-- Boton de emergencia: el dueno o el cuidador reportan una emergencia durante un
-- servicio en curso (service_requests.status = 'ACCEPTED'). El backend notifica por
-- FCM al dueno, al cuidador asignado y a los usuarios con rol = 'administrador'.

CREATE TABLE IF NOT EXISTS emergencias (
  id SERIAL PRIMARY KEY,
  service_request_id INTEGER NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
  reported_by INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo TEXT NOT NULL CHECK (tipo IN ('MEDICA', 'ACCIDENTE', 'MASCOTA_PERDIDA', 'OTRO')),
  descripcion TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_emergencias_service_request_id ON emergencias(service_request_id);
