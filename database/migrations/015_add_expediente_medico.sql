-- Bloque 11 (expediente medico de la mascota): historial medico editable solo por el dueno;
-- el cuidador puede verlo (solo lectura) durante un servicio activo. fecha_proxima alimenta
-- las alertas de vacunas proximas (cron diario en el backend).
--
-- Nota: la tabla de mascotas en este esquema se llama "pets" (no "mascotas"); por decision
-- del usuario se mantiene ese nombre y las tablas nuevas usan "pets_id" como FK.

CREATE TABLE IF NOT EXISTS expediente_medico (
    id SERIAL PRIMARY KEY,
    pets_id INTEGER REFERENCES pets(id) ON DELETE CASCADE,
    tipo VARCHAR(30) NOT NULL CHECK (tipo IN ('VACUNA', 'DESPARASITACION', 'ALERGIA', 'MEDICAMENTO', 'CIRUGIA', 'PESO', 'NOTA')),
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha DATE NOT NULL,
    fecha_proxima DATE,
    veterinario_nombre VARCHAR(150),
    veterinario_telefono VARCHAR(20),
    imagen_carnet_url TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_expediente_medico_pets_id ON expediente_medico(pets_id);
CREATE INDEX IF NOT EXISTS idx_expediente_medico_fecha_proxima ON expediente_medico(fecha_proxima);
