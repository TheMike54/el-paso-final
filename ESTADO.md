# Estado

Se sobrescribe; máximo 60 líneas. Rama y PR en curso, bloqueos y decisiones abiertas. El historial está en git.

## Ahora

- Etapa: preparación del repositorio, antes del primer código del núcleo.
- Rama: `chore/setup` (pasos 2 a 4). PR en curso: #1, de `chore/setup` a `main`, con los tres checks en verde.
- Bloqueos: ninguno. El primer PR necesita la aprobación de un integrante distinto de quien lo abre.

## Preparación del repositorio

| # | Paso | Condición de salida | Estado |
|---|---|---|---|
| 1 | Repositorio, `project.godot`, licencia y README | En un clon nuevo, `--import` deja `git status --porcelain` vacío | Cumplida el 06-oct-2026 en un clon de GitHub (`2a73fbc`) |
| 2 | Configuración de Claude Code y de git, los `CLAUDE.md` y las skills (rama `chore/setup`) | El asistente no puede hacer `git commit` ni `git -C . commit`; git rechaza un commit con atribución de un asistente | Cumplida: las dos órdenes quedan bloqueadas en PowerShell y en Git Bash; `probar-sin-commit.ps1` da 64 de 64 en 5.1 y en 7 |
| 3 | Validador: `validar.gd`, `validar.tscn`, `validar.ps1` | Un `.gd` roto o un recurso faltante dan salida 1; el árbol limpio da 0 en PowerShell 5.1 y 7; con el validador roto termina solo y falla | Cumplida en una copia del proyecto; árbol limpio: `OK  VALIDACION archivos=2 fallos=0` en 5.1 y en 7 |
| 4 | GitHub: etiqueta, plantillas, CODEOWNERS, workflows, ajustes y primer PR | El PR sale en rojo con un `.gd` roto y en verde al quitarlo; `qa-pending` se pone al abrir y se quita al aprobar; después, ruleset activo y push directo a `main` rechazado | En curso. Visto el 06-oct-2026: `validar` en verde en el PR #1 y en rojo en el PR #2 (mismo árbol más un `.gd` roto); `qa-pending` puesta al abrir. Falta: aprobación, fusión, ruleset y push directo rechazado |
| 5 | Puerto de depuración y primer guion (segundo PR) | `GUION OK` en 3 corridas; guion o acción inexistente dan salida 1; el paquete de publicación arranca sin el puerto | Sin empezar |
| 6 | Documentos: `docs/contrato.md`, `licencias.md`, `pruebas.md`, `idea.md` y los dos `funciones.json` (segundo PR) | El validador acepta los dos JSON; todo lo que citan los `CLAUDE.md` existe | Sin empezar |
| 7 | Clon limpio y las tres máquinas | Solo con el README pasan `verificar-entorno.ps1` y `validar.ps1` en cada máquina | Sin empezar |
| 8 | Android (tercer PR): preset, APK de depuración, instalación con `adb` | La caja gris corre en el teléfono de prueba; modelo, Android, RAM y FPS en `docs/pruebas.md` | Sin empezar |

El núcleo empieza al cerrar el paso 7. El paso 8 puede correr en paralelo.

## Decisiones técnicas

- `.gitattributes` con `* text=auto eol=lf`: los hooks de git son scripts de `sh` y el CI corre en Linux; con
  `core.autocrlf=true` de Git para Windows, sin esta línea git convierte los finales de línea.
- `.gitignore` usa `build/*` y `!build/.gdignore`: ignorar `build/` entero dejaría fuera el `.gdignore` que
  impide a Godot importar lo exportado.
- `LICENSE` lleva solo el texto MIT estándar para que GitHub lo reconozca; que el arte no entra en esa licencia
  se dice en el README.
- `project.godot`: orientación `4` (`DisplayServer.SCREEN_SENSOR_LANDSCAPE`, valor leído de Godot 4.7.2), base
  1280×720 con `canvas_items` + `expand`, `quit_on_go_back=false`, Compatibility en las dos claves del renderer
  y las cuatro advertencias de tipado como error.
- El rojo del CI se comprueba en un PR borrador aparte (`chore/ci-check`, con un `.gd` roto) que se cierra sin
  fusionar: el commit roto no queda en el PR que se evalúa, y el verde previo de `chore/setup` separa un fallo
  de la infraestructura del fallo puesto a propósito.
- `ci.yml` usa `chickensoft-games/setup-godot@v2` sin plantillas de exportación; el check obligatorio del
  ruleset se llama `validar` porque el job no lleva `name:`.
- Sin escena principal ni icono hasta el paso 5: no entra ningún recurso gráfico antes de tener su registro de
  procedencia.

## Decisiones abiertas

Ninguna.
