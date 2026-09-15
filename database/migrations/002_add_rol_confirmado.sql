-- Agrega el bloqueo de "un solo rol por cuenta": una vez que el usuario confirma
-- su rol (propietario o cuidador) en la pantalla de seleccion, no se puede cambiar.
-- Los usuarios existentes ya tienen un rol en uso, asi que se marcan como confirmados;
-- las cuentas nuevas nacen sin confirmar hasta que eligen en RoleSectionScreen.

ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS rol_confirmado boolean NOT NULL DEFAULT true;
ALTER TABLE usuarios ALTER COLUMN rol_confirmado SET DEFAULT false;
