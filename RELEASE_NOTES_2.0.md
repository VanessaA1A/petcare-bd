# PetCare v2.0 — Release Notes

Resumen de las migraciones agregadas sobre el esquema base, repartidas en los Bloques 4 al 12.
Excluye explícitamente monetización, membresías, planes premium y organizaciones
(veterinarias/tiendas/adopción) — no se agregó ninguna tabla relacionada.

## Bloque 7 — Etiquetas por calificación
- `013_add_badge_usuarios.sql`: `usuarios.badge`, calculado por el backend a partir de
  servicios completados, calificación promedio y cancelaciones.

## Bloque 8 — Foto antes/después de un servicio
- `014_add_evidencias_servicio.sql`: tabla `evidencias_servicio` (tipo ANTES/DESPUES, imagen,
  nota y ubicación opcionales).

## Bloque 11 — Expediente médico de la mascota
- `015_add_expediente_medico.sql`: tabla `expediente_medico` (vacunas, desparasitación,
  alergias, medicamentos, cirugías, peso, notas).

## Bloque 12 — Alerta de mascota perdida
- `016_add_alertas_perdida.sql`: tablas `alertas_perdida` y `avistamientos`.

## Notas de implementación
- Los Bloques 9 (calendario) y 10 (llamadas telefónicas) no requirieron cambios de esquema:
  reutilizan datos ya existentes (`service_requests`/`service_applications` y `usuarios.telefono`).
- Las tablas nuevas usan `pets_id` como columna FK hacia `pets` — el nombre real de la tabla de
  mascotas en este esquema, no "mascotas" (decisión confirmada por el usuario, ver
  [MIGRATIONS.md](MIGRATIONS.md)).
- Donde el DDL exacto no venía especificado en el prompt original (`emergencias`,
  `valoraciones_tiempo_real`, Bloque 3), se diseñó siguiendo las convenciones ya usadas en el
  esquema — ver la nota de procedencia en [MIGRATIONS.md](MIGRATIONS.md).
- Ver también `RELEASE_NOTES_2.0.md` en `petcare-services` y `PetCareApp` para el detalle de
  backend y app móvil de cada bloque.
