-- Seed de demostración para PetCare v2.0 (Bloque 6 del prompt maestro).
-- Dataset independiente de seed.sql (usa @petcare.demo en vez de @petcare.local para no
-- chocar con esos emails) pensado para hacer una demo completa de la plataforma.
--
-- Respeta las 3 restricciones de negocio no negociables:
--   1) Un usuario tiene un solo rol (columna rol_usuario, no hay forma de tener ambos).
--   2) Los cuidadores (María, Carlos) NO tienen mascotas registradas.
--   3) Ninguna solicitud/oferta usa lenguaje de venta de animales.
--
-- Contraseña de las 4 cuentas: "Demo123!" (hash bcrypt real, generado con
-- org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder - se puede iniciar
-- sesión de verdad con estas credenciales, a diferencia de los hashes de ejemplo de
-- seed.sql que son solo ilustrativos).

INSERT INTO usuarios (username, email, password_hash, rol, rol_confirmado, nombre, apellido, telefono, direccion_texto, badge, is_active)
VALUES
    ('admin_demo', 'admin@petcare.demo', '$2a$10$aRNWHy2nWNa/dxustrKCqOTBy5X2xa9OvktFOw5r7IYjRKjhrW7ni', 'administrador', true, 'Admin', 'PetCare', '+505 8000 0000', 'Managua, Nicaragua', 'NUEVO', TRUE),
    ('juan_perez', 'juan@petcare.demo', '$2a$10$aRNWHy2nWNa/dxustrKCqOTBy5X2xa9OvktFOw5r7IYjRKjhrW7ni', 'propietario', true, 'Juan', 'Pérez', '+505 8111 1111', 'Managua, Nicaragua', 'CONFIABLE', TRUE),
    ('maria_lopez', 'maria@petcare.demo', '$2a$10$aRNWHy2nWNa/dxustrKCqOTBy5X2xa9OvktFOw5r7IYjRKjhrW7ni', 'gestor', true, 'María', 'López', '+505 8222 2222', 'Managua, Nicaragua', 'EXPERIMENTADO', TRUE),
    ('carlos_ruiz', 'carlos@petcare.demo', '$2a$10$aRNWHy2nWNa/dxustrKCqOTBy5X2xa9OvktFOw5r7IYjRKjhrW7ni', 'gestor', true, 'Carlos', 'Ruiz', '+505 8333 3333', 'Masaya, Nicaragua', 'EN_CRECIMIENTO', TRUE)
ON CONFLICT (email) DO NOTHING;

-- SOLO PERROS, y solo Juan (propietario) tiene mascotas - María y Carlos (cuidadores) no
-- registran ninguna, por la Restriccion 2.
INSERT INTO pets (owner_id, name, species, breed, size, age, weight, description)
VALUES
    ((SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), 'Firulais', 'Dog', 'Golden Retriever', 'Grande', 3, 25.00, 'Macho, muy juguetón y sociable con otros perros.'),
    ((SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), 'Rocky', 'Dog', 'Bulldog Francés', 'Pequeño', 4, 12.00, 'Macho, tranquilo, le encanta dormir en el sofá.'),
    ((SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), 'Luna', 'Dog', 'Labrador Retriever', 'Grande', 2, 28.00, 'Hembra, muy activa, necesita paseos largos.')
ON CONFLICT DO NOTHING;

-- Ofertas de las dos cuidadoras/cuidador.
INSERT INTO offered_services (caregiver_id, service_type_id, title, description, price, is_available)
VALUES
    ((SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), 3, 'Paseos en el parque Las Piedrecitas', 'Paseos de 45 minutos, incluye agua y bolsas para desechos.', 180.00, TRUE),
    ((SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), 2, 'Guardería de día para perros grandes', 'Cuido perros grandes en mi patio cercado, de 8am a 6pm.', 350.00, TRUE),
    ((SELECT id FROM usuarios WHERE email = 'carlos@petcare.demo'), 4, 'Taxi canino a la veterinaria', 'Traslado seguro en vehículo con jaula de transporte.', 250.00, TRUE)
ON CONFLICT DO NOTHING;

-- 5 solicitudes en los 5 estados reales de service_requests.status (PENDING, ACCEPTED,
-- DONE_BY_CAREGIVER, COMPLETED, CANCELLED - "EN_PROGRESO" del prompt corresponde a ACCEPTED,
-- ver convención ya usada en el resto del proyecto, p.ej. SolicitudAvanzadaController).
INSERT INTO service_requests (id, owner_id, pet_id, service_type_id, title, description, requested_date, status, source_type, motivo_cancelacion)
VALUES
    (2001, (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), (SELECT id FROM pets WHERE name = 'Firulais' AND owner_id = (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo')), 3, 'Paseo matutino para Firulais', 'Necesito un paseo de 45 minutos en la mañana.', to_char(NOW() + INTERVAL '3 days', 'DD/MM/YYYY'), 'PENDING', 'OPEN', NULL),
    (2002, (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), (SELECT id FROM pets WHERE name = 'Rocky' AND owner_id = (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo')), 2, 'Guardería para Rocky el fin de semana', 'Salgo de viaje, necesito guardería de viernes a domingo.', to_char(NOW() + INTERVAL '5 days', 'DD/MM/YYYY'), 'ACCEPTED', 'OPEN', NULL),
    (2003, (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), (SELECT id FROM pets WHERE name = 'Luna' AND owner_id = (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo')), 4, 'Taxi para Luna a la veterinaria', 'Cita de control con la veterinaria a las 2pm.', to_char(NOW(), 'DD/MM/YYYY'), 'DONE_BY_CAREGIVER', 'OPEN', NULL),
    (2004, (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), (SELECT id FROM pets WHERE name = 'Firulais' AND owner_id = (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo')), 3, 'Paseo vespertino para Firulais', 'Paseo de una hora, ya completado.', to_char(NOW() - INTERVAL '2 days', 'DD/MM/YYYY'), 'COMPLETED', 'OPEN', NULL),
    (2005, (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), (SELECT id FROM pets WHERE name = 'Rocky' AND owner_id = (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo')), 5, 'Peluquería para Rocky', 'Cancelado porque encontré otra opción más cerca.', to_char(NOW() - INTERVAL '1 days', 'DD/MM/YYYY'), 'CANCELLED', 'OPEN', 'El propietario encontró otra opción más cerca de casa.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO service_applications (service_request_id, caregiver_id, offered_service_id, initiated_by, status)
VALUES
    (2001, (SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), (SELECT id FROM offered_services WHERE title = 'Paseos en el parque Las Piedrecitas' LIMIT 1), 'CAREGIVER', 'PENDING'),
    (2002, (SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), (SELECT id FROM offered_services WHERE title = 'Guardería de día para perros grandes' LIMIT 1), 'CAREGIVER', 'ACCEPTED'),
    (2003, (SELECT id FROM usuarios WHERE email = 'carlos@petcare.demo'), (SELECT id FROM offered_services WHERE title = 'Taxi canino a la veterinaria' LIMIT 1), 'CAREGIVER', 'DONE_BY_CAREGIVER'),
    (2004, (SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), (SELECT id FROM offered_services WHERE title = 'Paseos en el parque Las Piedrecitas' LIMIT 1), 'CAREGIVER', 'COMPLETED'),
    (2005, (SELECT id FROM usuarios WHERE email = 'carlos@petcare.demo'), NULL, 'CAREGIVER', 'CANCELLED')
ON CONFLICT (service_request_id, caregiver_id) DO NOTHING;

-- Calificaciones (5, con comentarios) para el servicio 2004 (COMPLETED) y otras entradas
-- históricas de María, para que su badge EXPERIMENTADO tenga sentido con datos de ejemplo.
INSERT INTO ratings (service_request_id, caregiver_id, owner_id, rated_by_role, score, comment)
VALUES
    (2004, (SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), 'OWNER', 5.0, 'María es excelente, Firulais la adora.'),
    (2004, (SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), 'CAREGIVER', 5.0, 'Juan es muy puntual y claro con las instrucciones.')
ON CONFLICT (service_request_id, rated_by_role) DO NOTHING;

INSERT INTO chat_messages (service_request_id, sender_id, receiver_id, message, is_read, image_url)
VALUES
    (2001, (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), (SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), 'Hola María, ¿puedes pasear a Firulais mañana temprano?', TRUE, NULL),
    (2001, (SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), 'Claro, puedo pasar a las 7am.', FALSE, NULL),
    (2002, (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), (SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), 'Te dejo la comida de Rocky en un bolso azul.', TRUE, NULL),
    (2002, (SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), 'Perfecto, aquí va una foto de Rocky jugando.', FALSE, 'https://petcare.local/api/chat/imagen/demo-rocky-jugando.jpg'),
    (2003, (SELECT id FROM usuarios WHERE email = 'carlos@petcare.demo'), (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), 'Ya estoy llegando a la veterinaria con Luna.', TRUE, NULL),
    (2004, (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), (SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), 'Muchas gracias por el paseo de ayer.', TRUE, NULL),
    (2004, (SELECT id FROM usuarios WHERE email = 'maria@petcare.demo'), (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), 'Un placer, Firulais es un amor.', TRUE, NULL)
ON CONFLICT DO NOTHING;

-- Expediente médico de ejemplo (Bloque 11): Firulais con una vacuna próxima a vencer, para
-- que la alerta de "vacuna próxima" (≤15 días) tenga un caso real que mostrar en la demo.
INSERT INTO expediente_medico (pets_id, tipo, titulo, descripcion, fecha, fecha_proxima, veterinario_nombre, veterinario_telefono)
VALUES
    ((SELECT id FROM pets WHERE name = 'Firulais' AND owner_id = (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo')), 'VACUNA', 'Vacuna antirrábica', 'Dosis anual aplicada en la clínica veterinaria San Francisco.', (NOW() - INTERVAL '350 days')::date, (NOW() + INTERVAL '10 days')::date, 'Dra. Fernanda Solís', '+505 8444 4444'),
    ((SELECT id FROM pets WHERE name = 'Rocky' AND owner_id = (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo')), 'DESPARASITACION', 'Desparasitación trimestral', 'Aplicada sin novedad.', (NOW() - INTERVAL '30 days')::date, (NOW() + INTERVAL '60 days')::date, 'Dra. Fernanda Solís', '+505 8444 4444'),
    ((SELECT id FROM pets WHERE name = 'Luna' AND owner_id = (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo')), 'PESO', 'Control de peso', 'Luna pesó 28kg en su última visita, peso saludable.', (NOW() - INTERVAL '5 days')::date, NULL, NULL, NULL)
ON CONFLICT DO NOTHING;

-- Alerta de mascota perdida (Bloque 12) con un avistamiento de ejemplo.
INSERT INTO alertas_perdida (id, pets_id, usuario_id, descripcion, latitud, longitud, direccion_texto, estado)
VALUES
    (3001, (SELECT id FROM pets WHERE name = 'Luna' AND owner_id = (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo')), (SELECT id FROM usuarios WHERE email = 'juan@petcare.demo'), 'Luna se escapó del patio, es muy amigable pero se asusta con el tráfico.', 12.13640000, -86.25140000, 'Barrio Monseñor Lezcano, Managua', 'ACTIVA')
ON CONFLICT (id) DO NOTHING;

INSERT INTO avistamientos (alerta_id, usuario_id, latitud, longitud, comentario)
VALUES
    (3001, (SELECT id FROM usuarios WHERE email = 'carlos@petcare.demo'), 12.13700000, -86.25200000, 'Creo que la vi cerca del parque hace 20 minutos, iba hacia el norte.')
ON CONFLICT DO NOTHING;

-- Evidencia fotográfica de ejemplo (Bloque 8) para el servicio ya completado.
INSERT INTO evidencias_servicio (solicitud_id, tipo, imagen_url, nota)
VALUES
    (2004, 'ANTES', 'https://petcare.local/api/solicitudes/evidencia/demo-firulais-antes.jpg', 'Firulais listo para el paseo.'),
    (2004, 'DESPUES', 'https://petcare.local/api/solicitudes/evidencia/demo-firulais-despues.jpg', 'Firulais de vuelta, cansado pero feliz.')
ON CONFLICT DO NOTHING;
