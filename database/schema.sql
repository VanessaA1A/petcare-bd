-- PetCare Database Schema
-- PostgreSQL 15+
-- Objetivo: definir un modelo relacional coherente, en español y listo para producción.

BEGIN;

DROP TYPE IF EXISTS rol_usuario CASCADE;
DROP TABLE IF EXISTS mensajes_chat CASCADE;
DROP TABLE IF EXISTS calificaciones CASCADE;
DROP TABLE IF EXISTS aplicaciones_servicio CASCADE;
DROP TABLE IF EXISTS ofertas_servicio CASCADE;
DROP TABLE IF EXISTS solicitudes_servicio CASCADE;
DROP TABLE IF EXISTS recuperacion_contraseña CASCADE;
DROP TABLE IF EXISTS sesiones CASCADE;
DROP TABLE IF EXISTS mascotas CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

CREATE TYPE rol_usuario AS ENUM ('propietario', 'cuidador', 'administrador');

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    rol rol_usuario NOT NULL DEFAULT 'propietario',
    rol_confirmado BOOLEAN NOT NULL DEFAULT FALSE,
    latitud DECIMAL(10,8),
    longitud DECIMAL(11,8),
    direccion_texto VARCHAR(255),
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    telefono VARCHAR(30),
    foto_perfil_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login TIMESTAMPTZ,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    reset_token TEXT,
    reset_token_expires TIMESTAMPTZ
);

CREATE TABLE mascotas (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre VARCHAR(120) NOT NULL,
    especie VARCHAR(80),
    raza VARCHAR(120),
    edad INTEGER,
    peso NUMERIC(5,2),
    descripcion TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sesiones (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    token_sesion TEXT NOT NULL UNIQUE,
    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ip_address TEXT,
    user_agent TEXT,
    fecha_fin TIMESTAMPTZ,
    logout_explicito BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE solicitudes_servicio (
    id SERIAL PRIMARY KEY,
    propietario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    cuidador_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT NOT NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_inicio TIMESTAMPTZ,
    fecha_fin TIMESTAMPTZ,
    precio_estimado NUMERIC(10,2) DEFAULT 0
);

CREATE TABLE ofertas_servicio (
    id SERIAL PRIMARY KEY,
    solicitud_id INTEGER NOT NULL REFERENCES solicitudes_servicio(id) ON DELETE CASCADE,
    cuidador_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    precio_ofertado NUMERIC(10,2) NOT NULL,
    mensaje TEXT,
    estado VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE aplicaciones_servicio (
    id SERIAL PRIMARY KEY,
    solicitud_id INTEGER NOT NULL REFERENCES solicitudes_servicio(id) ON DELETE CASCADE,
    cuidador_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    estado VARCHAR(30) NOT NULL DEFAULT 'pendiente',
    mensaje TEXT,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE calificaciones (
    id SERIAL PRIMARY KEY,
    emisor_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    receptor_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    solicitud_id INTEGER REFERENCES solicitudes_servicio(id) ON DELETE SET NULL,
    puntuacion INTEGER NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE mensajes_chat (
    id SERIAL PRIMARY KEY,
    solicitud_id INTEGER NOT NULL REFERENCES solicitudes_servicio(id) ON DELETE CASCADE,
    emisor_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    receptor_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    mensaje TEXT NOT NULL,
    leido BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE recuperacion_contraseña (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    expiracion TIMESTAMPTZ NOT NULL,
    usado BOOLEAN NOT NULL DEFAULT FALSE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_rol ON usuarios(rol);
CREATE INDEX idx_usuarios_ubicacion ON usuarios(latitud, longitud);
CREATE INDEX idx_solicitudes_estado ON solicitudes_servicio(estado);
CREATE INDEX idx_solicitudes_fecha_creacion ON solicitudes_servicio(fecha_creacion);
CREATE INDEX idx_mascotas_owner_id ON mascotas(owner_id);
CREATE INDEX idx_sesiones_usuario_id ON sesiones(usuario_id);
CREATE INDEX idx_ofertas_solicitud_id ON ofertas_servicio(solicitud_id);
CREATE INDEX idx_aplicaciones_solicitud_id ON aplicaciones_servicio(solicitud_id);
CREATE INDEX idx_calificaciones_receptor_id ON calificaciones(receptor_id);
CREATE INDEX idx_mensajes_chat_solicitud_id ON mensajes_chat(solicitud_id);
CREATE INDEX idx_mensajes_chat_receptor_id ON mensajes_chat(receptor_id);

COMMIT;
