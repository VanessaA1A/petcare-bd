-- Bloque 7 (etiquetas por calificacion): badge calculado a partir del historial de servicios
-- completados, calificacion promedio y cancelaciones. Se recalcula automaticamente al
-- completar un servicio, cancelarlo o recibir una calificacion (ver BadgeService en el backend).
--
-- Niveles: NUEVO (0-2 servicios), EN_CRECIMIENTO (3-9, prom >= 3.5), CONFIABLE (10-29, prom >= 4.0),
-- EXPERIMENTADO (30-59, prom >= 4.5), ELITE (60+, prom >= 4.8, 0 cancelaciones),
-- EN_OBSERVACION (prom < 3.0 o > 3 cancelaciones).

ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS badge VARCHAR(30) NOT NULL DEFAULT 'NUEVO';
