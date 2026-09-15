-- Bitacora de auditoria: registra acciones relevantes de los usuarios (login, cambios de
-- datos sensibles, etc.) para trazabilidad. No hay codigo de aplicacion que escriba en
-- esta tabla todavia - se agrega el esquema primero segun lo solicitado; conectarla a
-- eventos reales es trabajo futuro.

CREATE TABLE IF NOT EXISTS logs_auditoria (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
    accion VARCHAR(100) NOT NULL,
    detalles JSONB,
    ip VARCHAR(45),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_logs_usuario ON logs_auditoria(usuario_id);
CREATE INDEX IF NOT EXISTS idx_logs_fecha ON logs_auditoria(fecha);
