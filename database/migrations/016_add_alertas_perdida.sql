-- Bloque 12 (alerta de mascota perdida): el dueno activa una alerta con ubicacion; el backend
-- notifica por push a usuarios cercanos (1/5/10 km). Cualquier usuario puede reportar un
-- avistamiento. Las alertas se cierran automaticamente a los 7 dias (job en el backend).
--
-- Nota: el prompt original decia "mascota_id REFERENCES mascotas(id)", pero la tabla real de
-- mascotas en este esquema se llama "pets" (ver database/schema.sql) - se referencia pets(id).

CREATE TABLE IF NOT EXISTS alertas_perdida (
    id SERIAL PRIMARY KEY,
    mascota_id INTEGER REFERENCES pets(id),
    usuario_id INTEGER REFERENCES usuarios(id),
    descripcion TEXT,
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),
    direccion_texto VARCHAR(255),
    estado VARCHAR(20) DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA', 'ENCONTRADA', 'CERRADA')),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre TIMESTAMP
);

CREATE TABLE IF NOT EXISTS avistamientos (
    id SERIAL PRIMARY KEY,
    alerta_id INTEGER REFERENCES alertas_perdida(id) ON DELETE CASCADE,
    usuario_id INTEGER REFERENCES usuarios(id),
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),
    comentario TEXT,
    imagen_url TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_alertas_perdida_mascota_id ON alertas_perdida(mascota_id);
CREATE INDEX IF NOT EXISTS idx_alertas_perdida_usuario_id ON alertas_perdida(usuario_id);
CREATE INDEX IF NOT EXISTS idx_alertas_perdida_estado ON alertas_perdida(estado);
CREATE INDEX IF NOT EXISTS idx_avistamientos_alerta_id ON avistamientos(alerta_id);
