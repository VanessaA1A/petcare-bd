-- PetCare Database Schema
-- PostgreSQL 15+
-- Fuente de verdad: sincronizado desde petcare-services/migrations/schema.sql
-- (el esquema real que usan las entidades JPA del backend, con ddl-auto: validate).
-- No editar a mano sin reflejar el mismo cambio en petcare-services; ver MIGRATIONS.md.

DROP TABLE IF EXISTS logs_auditoria CASCADE;
DROP TABLE IF EXISTS verificaciones CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS favoritos CASCADE;
DROP TABLE IF EXISTS notas_usuario CASCADE;
DROP TABLE IF EXISTS busquedas_guardadas CASCADE;
DROP TABLE IF EXISTS password_recovery CASCADE;
DROP TABLE IF EXISTS actividades CASCADE;
DROP TABLE IF EXISTS sesiones CASCADE;
DROP TABLE IF EXISTS pets CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TYPE IF EXISTS rol_usuario;

CREATE TYPE rol_usuario AS ENUM ('administrador', 'propietario', 'gestor');

CREATE TABLE usuarios (
  id serial PRIMARY KEY,
  username text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  rol rol_usuario NOT NULL DEFAULT 'gestor',
  rol_confirmado boolean NOT NULL DEFAULT false,
  latitud double precision,
  longitud double precision,
  direccion_texto text,
  nombre text,
  apellido text,
  telefono text,
  foto_perfil_filename text,
  foto_perfil_url text,
  created_at timestamptz DEFAULT NOW(),
  last_login timestamptz,
  is_active boolean DEFAULT true,
  reset_token text,
  reset_token_expires timestamptz,
  fcm_token text,
  no_molestar boolean DEFAULT false,
  two_factor_enabled boolean DEFAULT false,
  two_factor_secret varchar(255),
  fecha_ultimo_cambio_password timestamptz,
  bloqueado_hasta timestamptz
);

CREATE TABLE sesiones (
  id serial PRIMARY KEY,
  usuario_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  token_sesion text UNIQUE NOT NULL,
  fecha_inicio timestamptz DEFAULT NOW(),
  ip_address text,
  user_agent text,
  fecha_fin timestamptz,
  logout_explicito boolean DEFAULT false
);

CREATE TABLE actividades (
  id serial PRIMARY KEY,
  sesion_id integer REFERENCES sesiones(id) ON DELETE CASCADE,
  usuario_id integer REFERENCES usuarios(id) ON DELETE CASCADE,
  tipo_actividad text,
  descripcion text,
  ip_address text,
  fecha_hora timestamptz DEFAULT NOW()
);

CREATE TABLE password_recovery (
  id serial PRIMARY KEY,
  user_id integer REFERENCES usuarios(id) ON DELETE CASCADE,
  token text,
  created_at timestamptz DEFAULT NOW()
);

CREATE TABLE pets (
  id serial PRIMARY KEY,
  owner_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  name text NOT NULL,
  species text,
  breed text NOT NULL,
  size text NOT NULL,
  age integer,
  weight numeric(5,2),
  description text,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pets_owner_id ON pets(owner_id);


CREATE TABLE offered_services (
  id serial PRIMARY KEY,
  caregiver_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  service_type_id integer NOT NULL,
  title text NOT NULL,
  description text,
  price numeric(10,2) NOT NULL,
  is_available boolean NOT NULL DEFAULT true,
  latitude double precision,
  longitude double precision,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_offered_services_caregiver_id ON offered_services(caregiver_id);
CREATE INDEX IF NOT EXISTS idx_offered_services_available ON offered_services(is_available);

CREATE TABLE service_requests (
  id integer PRIMARY KEY,
  owner_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  pet_id integer NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
  pet_ids text,
  service_type_id integer NOT NULL,
  title text NOT NULL,
  description text,
  requested_date text,
  start_time text,
  end_time text,
  status text NOT NULL DEFAULT 'PENDING',
  offered_service_id integer REFERENCES offered_services(id) ON DELETE SET NULL,
  source_type text NOT NULL DEFAULT 'OPEN',
  latitude double precision,
  longitude double precision,
  motivo_cancelacion text,
  fecha_expiracion timestamptz,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_service_requests_owner_id ON service_requests(owner_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_status ON service_requests(status);
CREATE INDEX IF NOT EXISTS idx_service_requests_lat_lng ON service_requests(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_service_requests_fecha_creacion ON service_requests(created_at);

CREATE TABLE service_applications (
  id serial PRIMARY KEY,
  service_request_id integer NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
  caregiver_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  offered_service_id integer REFERENCES offered_services(id) ON DELETE SET NULL,
  initiated_by text NOT NULL DEFAULT 'CAREGIVER',
  status text NOT NULL DEFAULT 'PENDING',
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW(),
  UNIQUE(service_request_id, caregiver_id)
);

CREATE INDEX IF NOT EXISTS idx_service_applications_caregiver_id ON service_applications(caregiver_id);
CREATE INDEX IF NOT EXISTS idx_service_applications_request_id ON service_applications(service_request_id);


CREATE TABLE ratings (
  id serial PRIMARY KEY,
  service_request_id integer NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
  caregiver_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  owner_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  rated_by_role text NOT NULL DEFAULT 'OWNER',
  score numeric(2,1) NOT NULL,
  comment text,
  respuesta_calificacion text,
  created_at timestamptz DEFAULT NOW(),
  UNIQUE(service_request_id, rated_by_role)
);

CREATE INDEX IF NOT EXISTS idx_ratings_caregiver_id ON ratings(caregiver_id);
CREATE INDEX IF NOT EXISTS idx_ratings_owner_id ON ratings(owner_id);

CREATE TABLE chat_messages (
  id serial PRIMARY KEY,
  service_request_id integer NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
  sender_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  receiver_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  message text NOT NULL,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_service_request_id ON chat_messages(service_request_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_receiver_id ON chat_messages(receiver_id);

CREATE TABLE verificaciones (
  id serial PRIMARY KEY,
  email text NOT NULL,
  otp text NOT NULL,
  fecha_expiracion timestamptz NOT NULL,
  usado boolean NOT NULL DEFAULT false,
  creado_en timestamptz DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_verificaciones_email ON verificaciones(email);

CREATE TABLE favoritos (
  id serial PRIMARY KEY,
  usuario_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  cuidador_id integer REFERENCES usuarios(id) ON DELETE CASCADE,
  mascota_id integer REFERENCES pets(id) ON DELETE CASCADE,
  fecha_agregado timestamptz DEFAULT NOW(),
  CONSTRAINT unique_favorito_cuidador UNIQUE(usuario_id, cuidador_id),
  CONSTRAINT unique_favorito_mascota UNIQUE(usuario_id, mascota_id),
  CHECK (cuidador_id IS NOT NULL OR mascota_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_favoritos_usuario ON favoritos(usuario_id);

CREATE TABLE notas_usuario (
  id serial PRIMARY KEY,
  propietario_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  objetivo_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  nota text NOT NULL,
  fecha_creacion timestamptz DEFAULT NOW(),
  fecha_actualizacion timestamptz DEFAULT NOW()
);

CREATE TABLE busquedas_guardadas (
  id serial PRIMARY KEY,
  usuario_id integer NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  nombre text NOT NULL,
  filtros_json jsonb NOT NULL,
  fecha_creacion timestamptz DEFAULT NOW()
);

CREATE TABLE logs_auditoria (
  id serial PRIMARY KEY,
  usuario_id integer REFERENCES usuarios(id) ON DELETE SET NULL,
  accion varchar(100) NOT NULL,
  detalles jsonb,
  ip varchar(45),
  fecha timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_logs_usuario ON logs_auditoria(usuario_id);
CREATE INDEX IF NOT EXISTS idx_logs_fecha ON logs_auditoria(fecha);
