-- Play Store Ready Updates

-- 1. Favoritos
CREATE TABLE favoritos (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    cuidador_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    mascota_id INTEGER REFERENCES pets(id) ON DELETE CASCADE,
    fecha_agregado TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_favorito_cuidador UNIQUE(usuario_id, cuidador_id),
    CONSTRAINT unique_favorito_mascota UNIQUE(usuario_id, mascota_id),
    CHECK (cuidador_id IS NOT NULL OR mascota_id IS NOT NULL)
);

-- 2. Notas de usuario (privadas)
CREATE TABLE notas_usuario (
    id SERIAL PRIMARY KEY,
    propietario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    objetivo_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE, -- El cuidador sobre el que se escribe la nota
    nota TEXT NOT NULL,
    fecha_creacion TIMESTAMPTZ DEFAULT NOW(),
    fecha_actualizacion TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Búsquedas guardadas
CREATE TABLE busquedas_guardadas (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre TEXT NOT NULL,
    filtros_json JSONB NOT NULL,
    fecha_creacion TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Actualizaciones en usuarios
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS two_factor_enabled BOOLEAN DEFAULT FALSE;
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS two_factor_secret VARCHAR(255);
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS fecha_ultimo_cambio_password TIMESTAMPTZ;
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS bloqueado_hasta TIMESTAMPTZ;

-- 5. Actualizaciones en service_requests
ALTER TABLE service_requests ADD COLUMN IF NOT EXISTS motivo_cancelacion TEXT;
ALTER TABLE service_requests ADD COLUMN IF NOT EXISTS fecha_expiracion TIMESTAMPTZ;

-- 6. Actualizaciones en calificaciones
ALTER TABLE ratings ADD COLUMN IF NOT EXISTS respuesta_calificacion TEXT;

-- 7. Índices de rendimiento
CREATE INDEX IF NOT EXISTS idx_service_requests_lat_lng ON service_requests(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_service_requests_fecha_creacion ON service_requests(created_at);
CREATE INDEX IF NOT EXISTS idx_favoritos_usuario ON favoritos(usuario_id);
