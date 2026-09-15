-- Seed base para PetCare (esquema real de petcare-services)
-- Use bcrypt para generar contraseñas reales antes de cargar este script.
-- Ejemplo:
--   bcrypt.hashpw('Admin123!', 10)
--   bcrypt.hashpw('Owner123!', 10)
--   bcrypt.hashpw('Caregiver123!', 10)
--
-- Nota sobre roles: el tipo rol_usuario solo acepta 'administrador', 'propietario' y
-- 'gestor' a nivel de base de datos. El backend (RoleUtil) traduce 'gestor' <-> 'cuidador'
-- para la API y la app; a nivel de fila siempre se guarda 'gestor'.

INSERT INTO usuarios (username, email, password_hash, rol, rol_confirmado, nombre, apellido, telefono, is_active)
VALUES
    ('admin', 'admin@petcare.local', '$2a$10$0g8QdJb9r5lYg4R7tYgS6uYjTnBRmZ2R7UqR9m6VZcBw9k3bW1c7K', 'administrador', true, 'Administrador', 'Sistema', '5550000001', TRUE),
    ('owner_demo', 'owner@petcare.local', '$2a$10$Q6B8d0k6ZZJ9g4C7g9mF0uB2yP2h6VGQ0mE0gH2m8PMFQ4dJjL2w2', 'propietario', true, 'Ana', 'López', '5550000002', TRUE),
    ('caregiver_demo', 'caregiver@petcare.local', '$2a$10$CZ6wTt3z1dAaYQz7n9wNgOTzgQ5u6x7M7Xf7QHc3Euv0c9dP0sQ3e', 'gestor', true, 'Luis', 'García', '5550000003', TRUE)
ON CONFLICT (email) DO NOTHING;

INSERT INTO pets (owner_id, name, species, breed, size, age, weight, description)
VALUES
    ((SELECT id FROM usuarios WHERE email = 'owner@petcare.local'), 'Coco', 'Dog', 'Labrador', 'Mediano', 4, 18.50, 'Muy sociable y activo'),
    ((SELECT id FROM usuarios WHERE email = 'owner@petcare.local'), 'Milo', 'Cat', 'Siamés', 'Pequeño', 2, 4.20, 'Juguetón y tranquilo')
ON CONFLICT DO NOTHING;

-- 3 = Paseo (ver el mapeo de tipos de servicio en la app móvil: 1 Alojamiento, 2 Guardería,
-- 3 Paseo, 4 Taxi, 5 Peluquería, 6 Visitante; no hay tabla service_types, es un id simple).
INSERT INTO offered_services (caregiver_id, service_type_id, title, description, price, is_available)
VALUES
    ((SELECT id FROM usuarios WHERE email = 'caregiver@petcare.local'), 3, 'Paseos por el parque', 'Paseos de 30-60 minutos, disponible entre semana.', 150.00, TRUE)
ON CONFLICT DO NOTHING;

-- service_requests.id NO es autoincremental (columna integer, id generado por la app), por
-- lo que hay que asignarlo explícitamente. 1001 se elige fuera del rango que usa la app en
-- desarrollo para evitar colisiones.
INSERT INTO service_requests (id, owner_id, pet_id, service_type_id, title, description, requested_date, status, source_type)
VALUES
    (
        1001,
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        (SELECT id FROM pets WHERE name = 'Coco' LIMIT 1),
        3,
        'Paseo nocturno',
        'Necesito un paseo para Coco por la tarde.',
        to_char(NOW() + INTERVAL '2 days', 'DD/MM/YYYY'),
        'PENDING',
        'OPEN'
    )
ON CONFLICT (id) DO NOTHING;

INSERT INTO service_applications (service_request_id, caregiver_id, offered_service_id, initiated_by, status)
VALUES
    (
        1001,
        (SELECT id FROM usuarios WHERE email = 'caregiver@petcare.local'),
        (SELECT id FROM offered_services WHERE title = 'Paseos por el parque' LIMIT 1),
        'CAREGIVER',
        'PENDING'
    )
ON CONFLICT (service_request_id, caregiver_id) DO NOTHING;

-- UNIQUE(service_request_id, rated_by_role): cada lado del servicio califica una sola vez.
INSERT INTO ratings (service_request_id, caregiver_id, owner_id, rated_by_role, score, comment)
VALUES
    (
        1001,
        (SELECT id FROM usuarios WHERE email = 'caregiver@petcare.local'),
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        'OWNER',
        4.5,
        'Excelente paseo, muy puntual con Coco.'
    ),
    (
        1001,
        (SELECT id FROM usuarios WHERE email = 'caregiver@petcare.local'),
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        'CAREGIVER',
        5.0,
        'Coco es un perro muy tranquilo, un placer pasearlo.'
    )
ON CONFLICT (service_request_id, rated_by_role) DO NOTHING;

INSERT INTO chat_messages (service_request_id, sender_id, receiver_id, message, is_read, image_url)
VALUES
    (
        1001,
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        (SELECT id FROM usuarios WHERE email = 'caregiver@petcare.local'),
        'Hola, ¿a qué hora puedes pasear a Coco hoy?',
        TRUE,
        NULL
    ),
    (
        1001,
        (SELECT id FROM usuarios WHERE email = 'caregiver@petcare.local'),
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        'Puedo pasar a las 4pm, ¿te parece bien?',
        FALSE,
        NULL
    ),
    (
        1001,
        (SELECT id FROM usuarios WHERE email = 'caregiver@petcare.local'),
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        'Aquí va una foto de Coco disfrutando el paseo.',
        FALSE,
        'https://petcare.local/api/chat/imagen/demo-coco-paseo.jpg'
    )
ON CONFLICT DO NOTHING;

-- Emergencia de ejemplo (migración 011): reportada por el propietario durante el servicio
-- 1001 en curso.
INSERT INTO emergencias (service_request_id, reported_by, tipo, descripcion)
VALUES
    (
        1001,
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        'MASCOTA_PERDIDA',
        'Coco se soltó de la correa cerca del parque, seguimos buscándolo.'
    )
ON CONFLICT DO NOTHING;

-- Reacción en tiempo real de ejemplo (migración 012): el propietario reacciona mientras
-- el servicio 1001 está en curso.
INSERT INTO valoraciones_tiempo_real (service_request_id, usuario_id, tipo_reaccion)
VALUES
    (
        1001,
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        'CORAZON'
    )
ON CONFLICT DO NOTHING;

-- OTP de ejemplo para verificar el correo del propietario (ya vencido, es solo demo).
INSERT INTO verificaciones (email, otp, fecha_expiracion, usado)
VALUES
    ('owner@petcare.local', '123456', NOW() + INTERVAL '5 minutes', FALSE)
ON CONFLICT DO NOTHING;

-- CHECK (cuidador_id IS NOT NULL OR mascota_id IS NOT NULL): un favorito de cuidador y
-- otro de mascota para el mismo propietario.
INSERT INTO favoritos (usuario_id, cuidador_id, mascota_id)
VALUES
    (
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        (SELECT id FROM usuarios WHERE email = 'caregiver@petcare.local'),
        NULL
    ),
    (
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        NULL,
        (SELECT id FROM pets WHERE name = 'Milo' LIMIT 1)
    )
ON CONFLICT DO NOTHING;

INSERT INTO notas_usuario (propietario_id, objetivo_id, nota)
VALUES
    (
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        (SELECT id FROM usuarios WHERE email = 'caregiver@petcare.local'),
        'Muy puntual, se le puede confiar la llave de la casa.'
    )
ON CONFLICT DO NOTHING;

INSERT INTO busquedas_guardadas (usuario_id, nombre, filtros_json)
VALUES
    (
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        'Paseadores cerca de mi casa',
        '{"tipo": "paseo", "radioKm": 5}'::jsonb
    )
ON CONFLICT DO NOTHING;

-- token_sesion es un valor de ejemplo, no un JWT real.
INSERT INTO sesiones (usuario_id, token_sesion, ip_address, user_agent)
VALUES
    (
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        'demo-token-sesion-owner-0001',
        '192.168.1.10',
        'PetCare-Android/1.0'
    )
ON CONFLICT (token_sesion) DO NOTHING;

-- logs_auditoria (migración 009): aún sin escritores en la aplicación, solo esquema.
INSERT INTO logs_auditoria (usuario_id, accion, detalles, ip)
VALUES
    (
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        'login',
        '{"metodo": "password"}'::jsonb,
        '192.168.1.10'
    ),
    (
        (SELECT id FROM usuarios WHERE email = 'owner@petcare.local'),
        'actualizacion_perfil',
        '{"campo": "telefono"}'::jsonb,
        '192.168.1.10'
    )
ON CONFLICT DO NOTHING;
