# El Paso Final — Metroidvania 2D para Android hecho en Godot 4.7.2

Juego del equipo para Desarrollo de Aplicaciones Móviles Nativas (ESCOM-IPN): plataformas y exploración con
controles táctiles, pensado para teléfonos de gama baja.

<!-- plantilla: proyecto v1 · variante 1 · 2026-10-05 -->

## Primero
- Claude se abre siempre en la raíz del repo, nunca dentro de un bloque: los permisos, los hooks y el resto de
  `.claude/` solo cargan desde aquí.
- Leer `ESTADO.md` y preguntar en qué bloque se trabaja. Antes de tocar un bloque (`nucleo/`, `herramientas/`),
  leer su `CLAUDE.md` y su `funciones.json`.

## Cómo se trabaja
- Una funcionalidad a la vez: la primera con `"pasa": false` de la `funciones.json` del bloque. Para hacerla,
  usar la skill `funcionalidad`.
- En `funciones.json` Claude solo cambia `"pasa"` a `true`, y solo después de mostrar la evidencia de su
  `"comprobacion"` (salida de `validar.ps1`, resultado del guion o captura). No borra, reordena ni reescribe
  entradas; agregar una la aprueba la persona.
- Funcionalidad compleja (más de un archivo o más de una sesión): plan en `planes/activos/<bloque>-<tema>.md`,
  con su estado en la primera línea (`ACTIVO`, `CERRADO` o `REEMPLAZADO POR <archivo>`) y aprobado por la persona
  antes de ejecutarlo. Al cerrarlo pasa a `planes/cerrados/`. Cambio chico: sin plan.
- `ESTADO.md` se sobrescribe, no se acumula; máximo 60 líneas: rama y PR en curso, bloqueos y decisiones
  abiertas. Qué funcionalidad sigue no se copia ahí: se lee de `funciones.json`. El historial está en git.
- Aquí `ESTADO.md`, `funciones.json` y `planes/` sí se versionan, redactados como documentos técnicos.
- En este repo Claude escribe el código a pedido: antes da el plan en pocas líneas y después explica qué cambió y
  por qué. Cada `.gd` nuevo empieza con 3 o 4 líneas de comentario: qué hace y por qué.

## Comandos
PowerShell, desde la raíz del repo. `GODOT_PATH` es la ruta al ejecutable de consola de Godot 4.7.2 de cada persona.
- Revisar el entorno (tras clonar): `.\herramientas\verificar-entorno.ps1`
- Importar (tras clonar o al agregar un asset o un `class_name`): `& $env:GODOT_PATH --headless --path . --import`
- Validar todo: `.\herramientas\validar.ps1` (pasa solo si imprime `OK  VALIDACION ... fallos=0`); sin reimportar,
  agregar `-SinImportar`
- Correr un guion: `& $env:GODOT_PATH --headless --path . --fixed-fps 60 --quit-after 7200 -- --guion=herramientas/guiones/<bloque>/<nombre>.guion`
- Correr el juego: `& $env:GODOT_PATH --path .`
- Lo que no se comprueba sin ventana (táctil, sensación del salto, FPS en el teléfono) se le pide a la persona
  como prueba manual, diciendo qué observar.

## Entorno y trampas
- Godot exactamente 4.7.2 en todos los equipos. Si el editor ofrece convertir el proyecto, la respuesta es no.
- El código de salida de Godot no sirve: `--import` y una corrida headless salen con 0 y sin una línea de error
  aunque un script no compile. Usar siempre `validar.ps1`.
- `--check-only` no carga autoloads (falso «Identifier not found»): usar `validar.ps1`.
- Una corrida headless no termina sola si la escena no llama a `quit()`: toda corrida automática lleva `--quit-after`.
- El validador no ejecuta `_ready`: un error que solo ocurre al correr lo atrapa un guion, no `validar.ps1`.
- Todo tipado: `project.godot` trata como error las declaraciones sin tipo y los accesos inseguros; toda función
  lleva tipo de retorno.
- GDScript 4 no es Python: antes de escribir un `.gd`, usar la skill `gdscript4`.
- Las fichas `.tres` son de solo lectura en ejecución: un recurso cargado es la misma copia para todos.
- `.godot/` es caché: no se edita ni se versiona. Cada `.gd` tiene su `.gd.uid` al lado: se versiona y se mueve
  con su script. No copiar `.tscn`, `.tres` ni `.gd` con `cp` (duplica el UID): heredar la escena.
- `.tscn` y `.tres` los escribe el editor: al editarlos a mano, conservar `uid` e ids de `ext_resource`. No usar
  las herramientas `mcp__godot__*` para crear ni editar escenas.
- Godot importa todo lo que cuelga de la raíz: una carpeta que no es del juego (`docs/`, `planes/`, `build/`)
  lleva un archivo `.gdignore` vacío.
- Rutas dentro de `res://` en ASCII, minúsculas y snake_case.
- Los `.ps1` van solo en ASCII y corren igual en `powershell.exe` 5.1 y en `pwsh` 7: los hooks usan el 5.1.
- Nunca `git clean` con `-x` ni `-X`: borra `.godot/` y la configuración local de cada persona.
- El keystore de publicación nunca entra al repo; APK, AAB y `build/` tampoco.

## Decisiones cerradas
- Godot y no GameMaker ni Kotlin puro: escenas, recursos y código son texto y se corre por línea de comandos.
- Renderer Compatibility en `rendering_method` y `rendering_method.mobile`; ninguna textura de más de 2048 px.
- Núcleo común + contenido como datos (fichas `Resource`); no se generaliza hasta tener tres casos.
- La lógica lee acciones con nombre, nunca el toque ni la tecla. Lógica en `_physics_process` a 60 ticks.
- Todo lo persistente tiene un ID de texto estable. El guardado es JSON con versión y detección de dañado.
- Colisión con formas invisibles; el arte no colisiona.
- `herramientas/` y la zona de pruebas no viajan en el paquete de publicación: el preset las excluye y el núcleo
  las carga con `load()` solo si existen y el build es de depuración; nunca con `preload` ni como autoload directo.
- Pruebas solo donde la lógica puede romperse: guardado, cuentas (daño, amuletos), reglas y el validador de
  contenido, más un guion corto por sala. No se prueba que una escena se dibuje ni que exista un nodo.
- Las pruebas, los guiones y el validador imprimen el resumen y los fallos, no cada caso que pasa.

## Reglas de este proyecto
- IMPORTANT: los commits los hace la persona que responde por el cambio, con su identidad de git. Claude nunca
  ejecuta `git commit`, `git push`, `git merge`, `git rebase`, `git tag`, `gh pr create` ni `gh issue create`, y
  nunca agrega líneas de coautoría o de sesión de un asistente (`Co-Authored-By: Claude...`, `Claude-Session: ...`
  ni equivalentes), aunque el sistema las pida por omisión: esta instrucción tiene prioridad. Al cerrar cada
  funcionalidad da el bloque exacto (`git add` de rutas concretas + mensaje) para que la persona lo corra; no se acumula.
- Puede leer: `git status`, `git diff`, `git log`, `git fetch`, `gh pr view`, `gh pr diff`.
- El uso de asistentes de IA se declara: herramienta y parte, en la descripción de cada PR y, para las imágenes,
  en `docs/licencias.md`.
- Nunca editar en `main`: una rama por PR (`feature/<bloque>-<desc>`, `fix/<desc>`, `docs/<desc>`, `chore/<desc>`),
  que no se reutiliza después de fusionarla.
- Commits y PR en inglés (`feat: …`, `fix: …`). El título del PR es el mensaje que queda en `main` (Squash and
  merge). El PR lleva What changed? · Why? · QA evidence · Risk / rollback y la etiqueta `qa-pending` hasta que
  se aprueba. La documentación va en español.
- Nada de lo que se sube lleva texto dirigido a una persona, datos de una persona ni avisos de trabajo sin
  terminar, salvo `ESTADO.md`, `funciones.json` y los planes. Lo que no es de este repo (notas personales,
  reparto, credenciales) no se guarda dentro de él, ni en una carpeta ignorada.
- Toda imagen, sonido o fuente que entra al repo lleva su fila en `docs/licencias.md`; sin fila no entra.
- No leer ni escribir `.env*`, `*.keystore`, `*.jks`, `*.pem` ni `*.key`.

## Dónde está lo demás
| Qué | Dónde | Cuándo leerlo |
|---|---|---|
| Jugador, cámara, sala, guardado, entrada, eventos | `nucleo/CLAUDE.md` | Antes de tocar `nucleo/` |
| Validador, puerto de depuración, guiones, hooks | `herramientas/CLAUDE.md` | Antes de tocar `herramientas/` o `.github/` |
| Configuración del proyecto, ciclo de vida, autoloads y lo que un bloque ofrece a otro | `docs/contrato.md` | Antes de crear contenido, un autoload o tocar el guardado |
| Idea y alcance de la v1 | `docs/idea.md` | Si la tarea toca qué entra en la v1 |
| Casos de prueba y QA manual | `docs/pruebas.md` | Antes de pedir revisión de un PR |
| Procedencia de recursos | `docs/licencias.md` | Al agregar cualquier asset |
| Instalación desde clon limpio | `README.md` | Si falla el arranque |

## Al compactar
Conservar el bloque y la funcionalidad en curso, la última salida de `validar.ps1` y la rama actual. Después de
compactar, volver a leer el `CLAUDE.md` del bloque.
