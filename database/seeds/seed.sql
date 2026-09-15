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
