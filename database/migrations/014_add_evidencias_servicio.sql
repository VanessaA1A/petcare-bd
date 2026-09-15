-- Bloque 8 (foto obligatoria antes/despues): evidencia fotografica de un servicio, tomada
-- por el cuidador al iniciar (ANTES) y al terminar (DESPUES). Sin internet, el cambio de
-- estado se permite igual y la foto se sube al reconectar (ver backend/app).

CREATE TABLE IF NOT EXISTS evidencias_servicio (
    id SERIAL PRIMARY KEY,
    solicitud_id INTEGER REFERENCES service_requests(id) ON DELETE CASCADE,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('ANTES', 'DESPUES')),
    imagen_url TEXT NOT NULL,
    nota TEXT,
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_evidencias_servicio_solicitud_id ON evidencias_servicio(solicitud_id);
