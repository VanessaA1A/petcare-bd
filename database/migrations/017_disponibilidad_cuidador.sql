-- Bloque 9 (calendario): disponibilidad recurrente semanal del cuidador. GET /api/calendario
-- devolvia "disponibilidad" siempre vacio porque este concepto no existia todavia -- ver el
-- comentario en CalendarioService.kt.

CREATE TABLE IF NOT EXISTS disponibilidad_cuidador (
    id SERIAL PRIMARY KEY,
    cuidador_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    dia_semana INTEGER NOT NULL CHECK (dia_semana >= 0 AND dia_semana <= 6),
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (hora_inicio < hora_fin)
);

CREATE INDEX IF NOT EXISTS idx_disponibilidad_cuidador_cuidador_id ON disponibilidad_cuidador(cuidador_id, dia_semana);
