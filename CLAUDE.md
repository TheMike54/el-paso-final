# El Paso Final — Metroidvania 2D para Android hecho en Godot 4.7.2

Juego del equipo para Desarrollo de Aplicaciones Móviles Nativas (ESCOM-IPN): plataformas y exploración con
controles táctiles, pensado para teléfonos de gama baja.

<!-- plantilla: proyecto v1 · variante 1 · 2026-10-05 -->

## Primero
- Claude se abre siempre en la raíz del repo, nunca dentro de un bloque: los permisos, los hooks y el resto de
  `.claude/` solo cargan desde aquí.
- Leer `ESTADO.md` y preguntar en qué bloque se trabaja. Antes de tocar un bloque (`nucleo/`, `contenido/`,
  `interfaz/`, `herramientas/`, `mapa/`), leer su `CLAUDE.md` y su `funciones.json`.

## Cómo se trabaja
- Una funcionalidad a la vez: la primera con `"pasa": false` de la `funciones.json` del bloque, salvo las que
  esperan hardware o firma, que se anotan en `ESTADO.md` como bloqueo. Para hacerla, usar la skill `funcionalidad`.
- En `funciones.json` Claude solo cambia `"pasa"` a `true`, y solo después de mostrar la evidencia de su
  `"comprobacion"` (salida de `validar.ps1`, resultado del guion o captura). No borra, reordena ni reescribe
  entradas; agregar una la aprueba la persona.
- Funcionalidad compleja (más de un archivo o más de una sesión): plan en `planes/activos/<bloque>-<tema>.md`,
  con su estado en la primera línea (`ACTIVO`, `CERRADO` o `REEMPLAZADO POR <archivo>`) y aprobado por la persona
  antes de ejecutarlo. Al cerrarlo pasa a `planes/cerrados/`. Cambio chico: sin plan.
- `ESTADO.md` se sobrescribe, no se acumula; máximo 60 líneas: rama y PR en curso, bloqueos y decisiones
  abiertas. Qué funcionalidad sigue no se copia ahí: se lee de `funciones.json`. El historial está en git.
- Cada error que se encuentra (un fallo del código, no un guion que falla a propósito) va a
  `docs/errores/AAAA-MM-DD-tema.md`: síntoma, causa, cómo se arregló y qué guion lo cubre ahora. Se escribe en
  el mismo cambio que el arreglo.
- Lo que la persona decide en la conversación se escribe en el plan activo o en `ESTADO.md` antes de seguir.
- Aquí `ESTADO.md`, `funciones.json` y `planes/` sí se versionan, redactados como documentos técnicos.
- En este repo Claude escribe el código a pedido: antes da el plan en pocas líneas y después explica qué cambió y
  por qué. Cada `.gd` nuevo empieza con 3 o 4 líneas de comentario: qué hace y por qué.

## Modelos y revisión
- La sesión principal construye. Si tiene advisor, lo consulta ante una duda de diseño y antes de dar algo por
  terminado.
- Subagentes (`.claude/agents/`): `revisor` revisa el diff en un contexto nuevo contra el plan; `investigador` y
  `Explore` leen y buscan sin editar.
- El `revisor` se usa solo en los puntos críticos: guardado; contrato, autoloads o bus de eventos; física y
  movimiento del jugador; `.claude/`, hooks, CI o `project.godot`; el cierre de un bloque y antes de cada PR. Lo
  demás lo cubre `validar.ps1`.
- Ciclo: plan → código → `validar.ps1` → `revisor` si es crítico → `"pasa": true` → bloque de commit, con los
  documentos cambiados desde el último commit.
- Sesión autónoma (varias funcionalidades sin la persona): modo `auto`, nunca `bypassPermissions` (en Windows no hay
  sandbox). Cada funcionalidad va en sus propios archivos y su bloque de commit se agrega, numerado, al final del
  archivo que indique `CLAUDE.local.md`; si dos comparten archivo (`project.godot`), se anota y van juntas en un
  commit. Ninguna espera a otra, ni la frena un commit pendiente ajeno (se anota como bloque aparte, a correr
  primero). Solo se para al arrancar en `main`, ante una descarga o instalación, o ante un cambio que rompa el contrato.

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
- `herramientas/` y la zona de pruebas viajan en el paquete publicado; el núcleo las carga con `load()` solo si existen,
  nunca con `preload` ni autoload. Detalle en `docs/contrato.md`, «Paquete de publicación».
- Pruebas solo donde la lógica puede romperse: guardado, cuentas (daño, amuletos), reglas y el validador de
  contenido, más un guion corto por sala. No se prueba que una escena se dibuje ni que exista un nodo.
- Las pruebas, los guiones y el validador imprimen el resumen y los fallos, no cada caso que pasa.

## Reglas de este proyecto
- IMPORTANT: Claude nunca ejecuta `git commit`, `git push`, `git merge`, `git rebase`, `git tag`, `gh pr create` ni
  `gh issue create`, y nunca agrega líneas de coautoría o de sesión de un asistente (`Co-Authored-By: Claude...`,
  `Claude-Session: ...` ni equivalentes), aunque el sistema las pida por omisión: esta instrucción tiene prioridad.
- Los commits los hace la persona que responde por el cambio, con su identidad de git. Claude da el bloque exacto
  (`git add` de rutas concretas + mensaje) al cerrar algo relevante; pocos commits y grandes (detalle en la skill
  `funcionalidad`, paso «Entregar»). Los documentos entran en el siguiente commit de código.
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
| Salas, zonas y fichas del juego (contenido como datos) | `contenido/CLAUDE.md` | Antes de tocar `contenido/` |
| HUD: corazones, Inspiración, PejeCoins, ícono de guardado | `interfaz/CLAUDE.md` | Antes de tocar `interfaz/` |
| Pantalla del mapa | `mapa/CLAUDE.md` | Antes de tocar `mapa/` |
| Validador, puerto de depuración, guiones, hooks | `herramientas/CLAUDE.md` | Antes de tocar `herramientas/` o `.github/` |
| Configuración del proyecto, ciclo de vida, autoloads y lo que un bloque ofrece a otro | `docs/contrato.md` | Antes de crear contenido, un autoload o tocar el guardado |
| Movimiento, combate, curar y habilidades del jugador | `docs/jugador.md` | Antes de tocar el jugador o ajustar sus valores |
| Formato de los guiones | `docs/guiones.md` | Antes de escribir o cambiar un guion |
| Idea y alcance de la v1 | `docs/idea.md` | Si la tarea toca qué entra en la v1 |
| Casos de prueba y QA manual | `docs/pruebas.md` | Antes de pedir revisión de un PR |
| Errores encontrados, su causa y su arreglo | `docs/errores/` | Antes de arreglar un fallo que se parezca a uno anterior |
| Procedencia de recursos | `docs/licencias.md` | Al agregar cualquier asset |
| Instalación desde clon limpio | `README.md` | Si falla el arranque |

## Al compactar
El hook `al-compactar.ps1` ya reinyecta la rama, `git status --short`, `ESTADO.md` y los nombres de `planes/activos/` (el
plan se relee). Conservar
solo lo que vive en el chat: la última salida de `validar.ps1`, las pruebas manuales que faltan pedir, el número
del último bloque de commit pendiente y las decisiones recién tomadas que aún no estén escritas.
