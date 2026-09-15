-- Modo "No molestar" para cuidadores (silencia notificaciones push)

ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS no_molestar BOOLEAN DEFAULT FALSE;
