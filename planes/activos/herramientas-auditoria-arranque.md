ACTIVO (escrito el 2-nov-2026, aprobado por la persona ese día; lo cierra el PR #11)

# Auditoría final de documentación antes de abrir Las Raíces

Objetivo: que la documentación del repo diga lo mismo que el código antes de que empiecen las tarjetas de Las Raíces.

## Alcance

- `docs/`, `docs/guias/`, `docs/manual/`, `README.md`, `ESTADO.md`, `planes/activos/`, `funciones.json`, `docs/uso-de-ia.md` y
  `docs/pruebas.md`, contra el código.
- Fuera: `docs/errores/` y `planes/cerrados/`, que son historial.
- `CLAUDE.md`, skills, hooks y settings no se tocan aquí: sus cambios son propuestas por aprobar.

## Método

Cada lote lo leyeron dos lectores de proveedores distintos. Cada hallazgo se comprobó contra el archivo y lo verificó otro modelo
antes de aplicarse. No se reescriben entradas de `funciones.json`: lo que no coincide queda anotado para decidirlo.

## Hitos

1. Los hallazgos verificados quedan aplicados en los documentos.
2. `.\herramientas\validar.ps1` imprime `OK  VALIDACION ... fallos=0`.
3. `.\herramientas\revisar-enlaces.ps1` imprime `rotos=0`.
