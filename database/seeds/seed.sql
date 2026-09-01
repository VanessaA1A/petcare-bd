-- Seed base para PetCare
-- Use bcrypt para generar contraseñas reales antes de cargar este script.
-- Ejemplo:
--   bcrypt.hashpw('Admin123!', 10)
--   bcrypt.hashpw('Owner123!', 10)
--   bcrypt.hashpw('Caregiver123!', 10)

INSERT INTO usuarios (username, email, password_hash, rol, nombre, apellido, telefono, is_active)
VALUES
    ('admin', 'admin@petcare.local', '$2a$10$0g8QdJb9r5lYg4R7tYgS6uYjTnBRmZ2R7UqR9m6VZcBw9k3bW1c7K', 'administrador', 'Administrador', 'Sistema', '5550000001', TRUE),
    ('owner_demo', 'owner@petcare.local', '$2a$10$Q6B8d0k6ZZJ9g4C7g9mF0uB2yP2h6VGQ0mE0gH2m8PMFQ4dJjL2w2', 'propietario', 'Ana', 'López', '5550000002', TRUE),
    ('caregiver_demo', 'caregiver@petcare.local', '$2a$10$CZ6wTt3z1dAaYQz7n9wNgOTzgQ5u6x7M7Xf7QHc3Euv0c9dP0sQ3e', 'cuidador', 'Luis', 'García', '5550000003', TRUE)
ON CONFLICT (email) DO NOTHING;

INSERT INTO mascotas (owner_id, nombre, especie, raza, edad, peso, descripcion)
VALUES
    ((SELECT id FROM usuarios WHERE email = 'owner@petcare.local'), 'Coco', 'Perro', 'Labrador', 4, 18.50, 'Muy sociable y activo'),
    ((SELECT id FROM usuarios WHERE email = 'owner@petcare.local'), 'Milo', 'Gato', 'Siamés', 2, 4.20, 'Juguetón y tranquilo')
ON CONFLICT DO NOTHING;

INSERT INTO solicitudes_servicio (propietario_id, titulo, descripcion, estado, fecha_creacion, fecha_inicio, fecha_fin, precio_estimado)
VALUES
    ((SELECT id FROM usuarios WHERE email = 'owner@petcare.local'), 'Paseo nocturno', 'Necesito un paseo para Coco por la tarde.', 'pendiente', NOW(), NOW() + INTERVAL '1 day', NOW() + INTERVAL '2 days', 250.00),
    ((SELECT id FROM usuarios WHERE email = 'owner@petcare.local'), 'Cuidado de gato', 'Requiere atención por 3 horas durante el fin de semana.', 'pendiente', NOW(), NOW() + INTERVAL '3 days', NOW() + INTERVAL '4 days', 400.00)
ON CONFLICT DO NOTHING;
