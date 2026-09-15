-- Chat con fotos: permite adjuntar una imagen a un mensaje de chat. La URL la sirve
-- el backend en GET /api/chat/imagen/{filename}, mismo patron que foto_perfil_url.

ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS image_url TEXT;
