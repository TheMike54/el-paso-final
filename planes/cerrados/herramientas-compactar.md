CERRADO

# Herramientas: proteger el contexto al compactar

Rama `chore/compactar`, que sale de `feature/nucleo-entrada-acciones` (`f302dc6`): el hook se lee de la rama
actual, así que va en la base de las ramas del núcleo; la siguiente (`jugador-movimiento`) sale de esta. Plan y
entrada `hook-al-compactar` aprobados el 06-oct-2026.

## Qué entra

- Hook `SessionStart` con `"matcher": "compact"` en `.claude/settings.json`, junto al `PreToolUse` que ya existe
  y con el mismo patrón (`powershell.exe` y `${CLAUDE_PROJECT_DIR}`). Corre `.claude/hooks/al-compactar.ps1`.
- `al-compactar.ps1` (ASCII, igual en 5.1 y 7) imprime la rama actual, `git status --short`, `ESTADO.md`
  completo, la lista de `planes/activos/` y la línea «Vuelve a leer el CLAUDE.md y el funciones.json del bloque
  en curso». Siempre sale con 0: un fallo del hook no debe frenar la sesión.
- `CLAUDE.md` raíz: «Al compactar» conserva solo lo que vive en el chat; «Cómo se trabaja» gana la regla de
  escribir las decisiones en el plan o en `ESTADO.md` antes de seguir.
- `herramientas/CLAUDE.md`: fila del hook nuevo en «Piezas».
- `herramientas/funciones.json`: entrada nueva `hook-al-compactar` (la aprueba la persona).

## Decisiones

- Los acentos de `ESTADO.md` se imprimen limpios en 5.1: `Get-Content -Encoding UTF8` y
  `[Console]::OutputEncoding` en UTF-8 sin BOM. Probado el 06-oct-2026 en `powershell.exe` y `pwsh`: la salida
  trae `c3 ba` para «ú» y no lleva BOM. No hace falta el respaldo de imprimir solo las rutas.
- La raíz del repo se toma de `$PSScriptRoot`, no del directorio de trabajo: el hook no depende de dónde se
  lance.
- Rama, `ESTADO.md` y planes salen del hook; el `CLAUDE.md` ya no los pide conservar.
- `git status --short` va después de la rama (decidido el 06-oct-2026, tras la prueba de disparo): los cambios
  sin commit no se deducen de `ESTADO.md`. Esa sección se comprueba con la corrida a mano, sin otro `/compact`.

## Hitos

1. `al-compactar.ps1`. Comprobación: corrido a mano en 5.1 y en 7 imprime la rama, `git status --short`,
   `ESTADO.md` con acentos correctos, los planes y la línea final, con salida 0; también con el árbol limpio y
   `planes/activos/` vacío. Hecho el 06-oct-2026: las dos salidas son idénticas, sin BOM, con «ú» en `c3 ba`; en
   un repo desechable imprime `(sin cambios)` y `(ninguno)`.
2. `settings.json`, los dos `CLAUDE.md` y la entrada de `funciones.json`. Comprobación:
   `.\herramientas\validar.ps1` imprime `OK  VALIDACION ... fallos=0` y `settings.json` es JSON válido. Hecho.
3. Revisión del `revisor` (toca `.claude/` y hooks). Aprobado dos veces el 06-oct-2026: sin `git status` y con él.
4. Prueba de disparo, la hace la persona tras reiniciar la sesión: `/compact` y preguntar qué dio el hook.
   Hecha el 06-oct-2026: llegaron la rama, `ESTADO.md` con acentos y la ruta del plan sin haberlos leído.
   Con eso, `"pasa": true`.
