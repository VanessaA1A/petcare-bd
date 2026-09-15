-- Notificaciones push (Firebase Cloud Messaging)

ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS fcm_token TEXT;
