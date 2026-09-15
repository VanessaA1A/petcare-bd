-- Chat interno entre propietario y cuidador, ligado a una solicitud de servicio.

CREATE TABLE IF NOT EXISTS chat_messages (
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
