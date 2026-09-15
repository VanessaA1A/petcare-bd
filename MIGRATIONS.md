# Migraciones y rollback

Este repositorio refleja el esquema real de `petcare-services`. Hay dos formas de levantar
la base de datos, según el escenario:

## 1. Base nueva (desarrollo, CI, QA)

Aplica el esquema completo de una sola vez:

```bash
psql -U postgres -d postgres -c "CREATE DATABASE petcare;"
psql -U postgres -d petcare -f database/schema.sql
psql -U postgres -d petcare -f database/seeds/seed.sql   # opcional, datos de ejemplo
```

`database/schema.sql` ya incluye todo lo agregado por las migraciones 002-008 (ver más
abajo) — no hace falta aplicarlas por separado en este caso.

## 2. Base existente (aplicar solo lo nuevo)

Si ya tienes una base de datos con datos que no quieres perder (por ejemplo, restaurada
desde un dump anterior a la migración 006), aplica únicamente los archivos de
`database/migrations/` que falten, en orden numérico:

```bash
for f in database/migrations/0*.sql; do
  psql -U postgres -d petcare -f "$f"
done
```

Todas las migraciones usan `ADD COLUMN IF NOT EXISTS` / `CREATE TABLE IF NOT EXISTS` (o,
en el caso de 006, tablas nuevas que no existían antes), así que son seguras de re-aplicar
sobre una base que ya tiene algunas de ellas.

| Migración | Qué agrega |
| --- | --- |
| `002_add_rol_confirmado.sql` | `usuarios.rol_confirmado` — bloquea cambiar de rol una vez elegido |
| `003_add_ubicacion_usuarios.sql` | `usuarios.latitud/longitud/direccion_texto` |
| `004_add_chat_messages.sql` | Tabla `chat_messages` (chat interno por solicitud) |
| `005_add_verificaciones.sql` | Tabla `verificaciones` (OTP por correo) |
| `006_play_store_ready_updates.sql` | Tablas `favoritos`, `notas_usuario`, `busquedas_guardadas`; columnas 2FA y bloqueo en `usuarios`; `motivo_cancelacion`/`fecha_expiracion` en `service_requests`; `respuesta_calificacion` en `ratings` |
| `007_add_fcm_token.sql` | `usuarios.fcm_token` (notificaciones push) |
| `008_add_no_molestar.sql` | `usuarios.no_molestar` |

No hay una migración `001`: `database/schema.sql` cumple ese rol de línea base (es el
esquema completo desde cero, no un delta).

## Rollback

No hay scripts de rollback automatizados — las migraciones aplicadas aquí son aditivas
(agregan columnas/tablas) y no se han necesitado reversiones en producción todavía. Si
necesitas revertir una migración puntual:

- **Columna agregada** (`ADD COLUMN`): `ALTER TABLE <tabla> DROP COLUMN IF EXISTS <columna>;`
- **Tabla nueva** (`CREATE TABLE`): `DROP TABLE IF EXISTS <tabla> CASCADE;` — revisa primero
  si algo depende de ella (`favoritos`, `chat_messages`, etc. tienen FKs hacia `usuarios`/`pets`,
  pero nada les apunta a ellas, así que son seguras de borrar de forma aislada).

Antes de un rollback en una base con datos reales, respalda primero:

```bash
pg_dump -U postgres -d petcare -f backup_antes_de_rollback.sql
```

## Sincronizar este repo con petcare-services

Cuando `petcare-services` agregue una migración nueva:

1. Copia el archivo nuevo a `database/migrations/` aquí.
2. Aplica el mismo cambio a `database/schema.sql` (la línea base completa), igual que se
   hizo en `petcare-services/migrations/schema.sql`.
3. Si agrega una tabla/columna usada por los seeds, actualiza `database/seeds/seed.sql`.
4. Actualiza la tabla de entidades en `README.md` si cambia la forma de alguna tabla.

## Verificación

`database/schema.sql` y `database/seeds/seed.sql` deben poder aplicarse sin errores contra
un Postgres 15 limpio (`docker run --rm -e POSTGRES_PASSWORD=postgres -p 5432:5432
postgres:15-alpine`, luego los dos `psql -f` de arriba). Repite esta prueba después de
cualquier cambio de esquema.
