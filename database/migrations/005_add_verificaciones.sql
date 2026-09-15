-- Verificacion de identidad por OTP (codigo de un solo uso enviado al correo).

CREATE TABLE IF NOT EXISTS verificaciones (
  id serial PRIMARY KEY,
  email text NOT NULL,
  otp text NOT NULL,
  fecha_expiracion timestamptz NOT NULL,
  usado boolean NOT NULL DEFAULT false,
  creado_en timestamptz DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_verificaciones_email ON verificaciones(email);
