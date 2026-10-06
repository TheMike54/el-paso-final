# Estado

Se sobrescribe; máximo 60 líneas. Rama y PR en curso, bloqueos y decisiones abiertas. El historial está en git.

## Ahora

- Etapa: preparación del repositorio, antes del primer código del núcleo.
- Rama: `feature/herramientas-puerto-guion` (pasos 5 y 6, teclado y subagentes), local y apilada sobre
  `chore/setup`; se sube cuando el PR #1 esté fusionado. El paso 8 va en su propia rama, `chore/android-export`,
  que sale de esta.
- PR en curso: #1, de `chore/setup` a `main`, con los checks en verde.
- Bloqueos: el PR #1 necesita la aprobación de un integrante distinto de quien lo abre.

## Preparación del repositorio

| # | Paso | Condición de salida | Estado |
|---|---|---|---|
| 1 | Repositorio, `project.godot`, licencia y README | En un clon nuevo, `--import` deja `git status --porcelain` vacío | Cumplida el 06-oct-2026 en un clon de GitHub (`2a73fbc`) |
| 2 | Configuración de Claude Code y de git, los `CLAUDE.md` y las skills (rama `chore/setup`) | El asistente no puede hacer `git commit` ni `git -C . commit`; git rechaza un commit con atribución de un asistente | Cumplida: las dos órdenes quedan bloqueadas en PowerShell y en Git Bash; `probar-sin-commit.ps1` da 64 de 64 en 5.1 y en 7 |
| 3 | Validador: `validar.gd`, `validar.tscn`, `validar.ps1` | Un `.gd` roto o un recurso faltante dan salida 1; el árbol limpio da 0 en PowerShell 5.1 y 7; con el validador roto termina solo y falla | Cumplida en una copia del proyecto |
| 4 | GitHub: etiqueta, plantillas, CODEOWNERS, workflows, ajustes y primer PR | El PR sale en rojo con un `.gd` roto y en verde al quitarlo; `qa-pending` se pone al abrir y se quita al aprobar; después, ruleset activo y push directo a `main` rechazado | En curso. Visto el 06-oct-2026: `validar` en verde en el PR #1 y en rojo en el PR #2 (mismo árbol más un `.gd` roto); `qa-pending` puesta al abrir. Falta: aprobación, fusión, ruleset y push directo rechazado |
| 5 | Puerto de depuración y primer guion (segundo PR) | `GUION OK` en 3 corridas; guion o acción inexistente dan salida 1; el paquete de publicación arranca sin el puerto | Cumplida en local el 06-oct-2026: `GUION OK` en 3 corridas, también con el teclado nuevo; guion inexistente, acción inexistente y estado distinto dan salida 1; el paquete arranca con `puerto=false`. Falta ver el guion en el CI |
| 6 | Documentos: `docs/contrato.md`, `licencias.md`, `pruebas.md`, `idea.md` y los dos `funciones.json` (segundo PR) | El validador acepta los dos JSON; todo lo que citan los `CLAUDE.md` existe | Cumplida en local el 06-oct-2026: `OK  VALIDACION archivos=8 fallos=0`; una entrada con `"pasa": true` sin su archivo, un JSON ilegible, un campo faltante y un id repetido dan salida 1 |
| 7 | Clon limpio y las tres máquinas | Solo con el README pasan `verificar-entorno.ps1` y `validar.ps1` en cada máquina | En curso: pasa en un clon nuevo en una máquina (06-oct-2026). Faltan las otras dos, con el PR #1 ya fusionado |
| 8 | Android (tercer PR): preset, APK de depuración, instalación con `adb` | La caja gris corre en el teléfono de prueba; modelo, Android, RAM y FPS en `docs/pruebas.md` | En curso: el APK de depuración sale por línea de comandos con el preset «Desarrollo» (26,95 MB, `arm64-v8a`, firmado). Falta instalarlo y medir en el teléfono |

El núcleo empieza al cerrar el paso 7. El paso 8 puede correr en paralelo.

## Decisiones técnicas

- `.gitattributes` con `* text=auto eol=lf`: los hooks de git son scripts de `sh` y el CI corre en Linux.
- `.gitignore` usa `build/*` y `!build/.gdignore`: ignorar `build/` entero dejaría fuera el `.gdignore`.
- `LICENSE` lleva solo el texto MIT estándar para que GitHub lo reconozca; el arte queda fuera (README).
- El rojo del CI se comprueba en un PR borrador aparte que se cierra sin fusionar: el commit roto no queda en
  el PR que se evalúa.
- `ci.yml` usa `chickensoft-games/setup-godot@v2` sin plantillas de exportación; el check obligatorio del
  ruleset se llama `validar` porque el job no lleva `name:`.
- La escena principal es la caja gris, dibujada por código: el paquete necesita una escena principal y ningún
  recurso gráfico entra antes de tener su registro de procedencia.
- El puerto de depuración solo tiene modo guion; el modo en vivo por TCP se agrega cuando un guion no alcance.
- El `.esperado` compara con tolerancia (0,5 px por omisión) y el guion de la caja revisa el estado en el aire:
  un salto que no ocurre hace fallar el guion sin atarlo a cada ajuste del salto.
- Teclado inicial: A y D para moverse y W para saltar, como teclas físicas. El guion no cambió: usa acciones.
- `import_etc2_astc=true`: sin esa clave Godot rechaza la exportación a Android. Va en el segundo PR porque
  comparte `project.godot` con el cambio de teclado.
- Paso 8: dos presets de Android con el id `com.themike54.elpasofinal`. «Publicacion» excluye `herramientas/*` y
  `*funciones.json` (Godot exporta los JSON como recursos). «Desarrollo» lleva todo y arranca con `--print-fps`
  para leer los FPS con `adb logcat`. La sección de opciones de un preset no puede ir vacía: Godot imprime `ERROR:`.
- Subagentes en `.claude/agents/`: `revisor` en un contexto nuevo solo en los puntos críticos del `CLAUDE.md`
  raíz; `investigador` y `Explore` en un modelo más barato, sin editar.

## Decisiones abiertas

- Ícono del proyecto: no hay. La exportación imprime `ERROR: No project icon specified` y genera el APK igual.
