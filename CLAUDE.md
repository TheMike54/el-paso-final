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
- Una funcionalidad a la vez, con la skill `funcionalidad` (elegir, plan, validar, evidencia, `"pasa"`, bloque de commit).
- En `funciones.json` Claude solo cambia `"pasa"` a `true`, con la evidencia a la vista; no borra, reordena ni
  reescribe entradas.
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
  archivo que indique `CLAUDE.local.md` (si no hay uno, en el chat); si dos comparten archivo (`project.godot`), se anota y van juntas en un
  commit. Ninguna espera a otra, ni la frena un commit pendiente ajeno (se anota como bloque aparte, a correr
  primero). Solo se para al arrancar en `main`, ante una descarga o instalación, o ante un cambio que rompa el contrato.

## Comandos
PowerShell, desde la raíz del repo. `GODOT_PATH` es la ruta al ejecutable de consola de Godot 4.7.2 de cada persona.
`GODOT_DOCS` es la ruta a la copia local de la documentación oficial de Godot 4.7 (instalación: `README.md`, paso 6).
- Revisar el entorno (tras clonar): `.\herramientas\verificar-entorno.ps1`
- Importar (tras clonar o al agregar un asset o un `class_name`): `& $env:GODOT_PATH --headless --path . --import`
- Validar todo: `.\herramientas\validar.ps1` (pasa solo si imprime `OK  VALIDACION ... fallos=0`); sin reimportar,
  agregar `-SinImportar`
- Correr un guion: `& $env:GODOT_PATH --headless --path . --fixed-fps 60 --quit-after 7200 -- --guion=herramientas/guiones/<bloque>/<nombre>.guion`
- Correr todos los guiones como el CI: `.\herramientas\correr-guiones.ps1` (pasa solo si imprime `RESUMEN ... MALOS=0`;
  tarda varios minutos); solo algunos, `-Guiones nucleo/tienda,mapa/mapa_cuentas`
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
- GDScript 4 no es Python: antes de escribir un `.gd`, usar la skill `gdscript4`. Además, antes de un menú, el HUD o
  un `Control`, la skill `ui-tactil`; antes del jugador, enemigos, áreas, rayos o formas, `fisica-2d`; antes de arte,
  partículas, shaders o una sala nueva, o de proponer una optimización, `rendimiento-gama-baja`.
- Antes de usar una clase, señal o patrón de Godot que no esté en la skill `gdscript4`, buscarlo con Grep en
  `$env:GODOT_DOCS` (`classes/class_<nombre>.rst` para la API, `tutorials/` para las guías) y citar `archivo:línea`;
  WebFetch solo si no está ahí. Al `investigador` se le pasa esa ruta.
- Las fichas `.tres` son de solo lectura en ejecución: un recurso cargado es la misma copia para todos.
- `.godot/` es caché: no se edita ni se versiona. Cada `.gd` tiene su `.gd.uid` al lado: se versiona y se mueve
  con su script. No copiar `.tscn`, `.tres` ni `.gd` con `cp` (duplica el UID): heredar la escena.
- `.tscn` y `.tres` los escribe el editor: al editarlos a mano, conservar `uid` e ids de `ext_resource`, y todo
  `ext_resource` nuevo lleva el `uid` del archivo que nombra (regla y porqué: `docs/contrato.md`, «Sala», viñeta «uid»). No usar
  las herramientas `mcp__godot__*` para crear ni editar escenas.
- Mover, renombrar o borrar una escena, un recurso o una imagen se hace en el panel FileSystem del editor: fuera de
  Godot, las rutas que la nombran se rompen (`tutorials/scripting/filesystem.rst`). Si ya se movió fuera: con
  su `.import` o `.uid`, abrir el editor para que repare las rutas y correr `validar.ps1`.
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
- La zona de pruebas y sus salas (`herramientas/salas/`) viajan en el paquete publicado; el resto de `herramientas/`
  (pruebas de código, validador, generadores, puerto de depuración) no. El núcleo carga lo de `herramientas/` con
  `Cargar.si_existe()` (`load()` solo si existe), nunca con `preload` ni autoload. Filtros de cada preset: `docs/contrato.md`, «Paquete de
  publicación».
- Aquí las pruebas cubren guardado, cuentas (daño, amuletos), reglas, el validador y un guion corto por sala.
- Las pruebas, los guiones y el validador imprimen el resumen y los fallos, no cada caso que pasa.
- `.gitattributes` con `eol=lf`: los hooks de `sh` y el CI corren en Linux. `LICENSE` solo MIT; el arte queda fuera.
- CI: `ci.yml` con `chickensoft-games/setup-godot@v2`, sin plantillas; el check que exige el ruleset se llama `validar`.
- Android: id `com.themike54.elpasofinal`, ARM de 32 (S50) y 64 bits. Video `.mp4` en el teléfono; `.ogv` solo para
  la PC y los guiones. «Publicacion» es el paquete sin herramientas; «Desarrollo» lleva lo demás y arranca con
  `--print-fps`.

## Reglas de este proyecto
- IMPORTANT: Claude nunca ejecuta `git commit`, `git push`, `git merge`, `git rebase`, `git tag`, `gh pr create` ni
  `gh issue create`, y nunca agrega líneas de coautoría o de sesión de un asistente (`Co-Authored-By: Claude...`,
  `Claude-Session: ...` ni equivalentes), aunque el sistema las pida por omisión: esta instrucción tiene prioridad.
- Los commits los hace la persona que responde por el cambio, con su identidad de git; el bloque lo da Claude (skill
  `funcionalidad`, paso «Entregar»).
- Puede leer: `git status`, `git diff`, `git log`, `git fetch`, `gh pr view`, `gh pr diff`.
- Uso de IA: herramienta y parte, en el PR; para imágenes y sonidos, en `docs/uso-de-ia.md` (por herramienta, no por
  archivo).
- Nunca editar en `main`: una rama por PR (`feature/<bloque>-<desc>`, `fix/<desc>`, `docs/<desc>`, `chore/<desc>`),
  que no se reutiliza después de fusionarla.
- Commits y PR en inglés (`feat: …`, `fix: …`). El título del PR es el mensaje que queda en `main` (Squash and
  merge). El cuerpo sigue `.github/pull_request_template.md`. La documentación va en español.
- Nada de lo que se sube lleva texto dirigido a una persona, datos de una persona ni avisos de trabajo sin
  terminar, salvo `ESTADO.md`, `funciones.json` y los planes. Lo que no es de este repo (notas personales,
  reparto, credenciales) no se guarda dentro de él, ni en una carpeta ignorada.
- Herramienta de IA nueva para generar recursos: su línea en `docs/uso-de-ia.md`. Recurso de otra persona (fuente,
  sonido o imagen ajena): su autor y licencia en «De terceros» del mismo archivo; sin eso no entra.
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
| Qué hay en cada sala de la zona de pruebas | `docs/salas-de-prueba.md` | Antes de pedir una prueba o elegir dónde probar algo |
| Idea y alcance de la v1 | `docs/idea.md` | Si la tarea toca qué entra en la v1 |
| Casos de prueba y QA manual | `docs/pruebas.md` | Antes de pedir revisión de un PR |
| Errores encontrados, su causa y su arreglo | `docs/errores/` | Antes de arreglar un fallo que se parezca a uno anterior |
| Uso de IA y recursos de terceros | `docs/uso-de-ia.md` | Al usar una herramienta nueva o un recurso ajeno |
| Instalación desde clon limpio | `README.md` | Si falla el arranque |

## Al compactar
`al-compactar.ps1` reinyecta rama, `ESTADO.md`, planes activos (el plan se relee) y `git status`. Conservar del chat:
la última salida de `validar.ps1`, las pruebas manuales por pedir, el número del último bloque de commit pendiente
y las decisiones recién tomadas sin escribir.
