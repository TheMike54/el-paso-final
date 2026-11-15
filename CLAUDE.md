# El Paso Final — Metroidvania 2D para Android hecho en Godot 4.7.2

Juego del equipo para Desarrollo de Aplicaciones Móviles Nativas (ESCOM-IPN): plataformas y exploración con
controles táctiles, pensado para teléfonos de gama baja. Pasa de las 120 líneas del estándar (excepción: hasta 160).

<!-- plantilla: proyecto v1 · variante 1 · 2026-10-05 -->

## Primero
- Claude se abre siempre en la raíz del repo, nunca dentro de un bloque: los permisos, los hooks y el resto de
  `.claude/` solo cargan desde aquí.
- Leer `ESTADO.md` y preguntar en qué bloque se trabaja. Antes de tocar un bloque (`nucleo/`, `contenido/`,
  `interfaz/`, `herramientas/`, `mapa/`), leer su `CLAUDE.md` y su `funciones.json`.

## Cómo se trabaja
- Una funcionalidad a la vez, con la skill `funcionalidad` (elegir, plan, validar, evidencia, `"pasa"`, bloque de commit).
- En `funciones.json` Claude agrega al final la entrada de lo que se le pidió, con `"pasa": false`, y cambia `"pasa"`
  a `true` con la evidencia a la vista; no borra, reordena ni reescribe entradas.
- Funcionalidad compleja (más de un archivo o más de una sesión): plan en `planes/activos/<bloque>-<tema>.md`,
  con su estado en la primera línea (`ACTIVO`, `CERRADO` o `REEMPLAZADO POR <archivo>`) y aprobado por la persona
  antes de ejecutarlo. Al cerrarlo pasa a `planes/cerrados/`. Cambio chico: sin plan.
- `ESTADO.md` se sobrescribe, no se acumula; máximo 60 líneas: rama y PR en curso, bloqueos y decisiones
  abiertas. Qué funcionalidad sigue no se copia ahí: se lee de `funciones.json`. El historial está en git.
- Cada fallo del código que se encuentra (no un guion que falla a propósito) va, en el mismo cambio que el arreglo, a
  `docs/errores/AAAA-MM-DD-tema.md`: síntoma, causa, cómo se arregló y qué guion lo cubre ahora.
- Lo que la persona decide o aprueba se copia, antes de seguir, a `## Decidido` del plan activo (sin plan, al de
  `ESTADO.md`): fecha y hora, la decisión y su frase literal entre «»; una aprobación general, una línea por punto.
- Aquí `ESTADO.md`, `funciones.json` y `planes/` sí se versionan, redactados como documentos técnicos.
- En este repo Claude escribe el código a pedido: antes da el plan en pocas líneas y después explica qué cambió y
  por qué. Cada `.gd` nuevo empieza con 3 o 4 líneas de comentario: qué hace y por qué.

## Modelos y revisión
- La sesión principal construye; si tiene advisor, lo consulta ante una duda de diseño y antes de dar algo por terminado.
- Subagentes (`.claude/agents/`): `revisor` revisa el diff en un contexto nuevo contra el plan; `investigador` y
  `Explore` leen y buscan sin editar.
- Lo crítico (guardado; contrato, autoloads o bus de eventos; física y movimiento del jugador; `.claude/`, hooks, CI
  o `project.godot`) pasa por el `revisor`, igual que el cierre de un bloque y cada PR; lo demás lo cubre `validar.ps1`.
  Lo crítico no se delega a otra IA: Claude define la interfaz y la escribe; la otra IA construye lo que cuelga de ella.
- Ciclo: plan → código → `validar.ps1` → `revisor` si es crítico → `"pasa": true` → bloque de commit, con los
  documentos cambiados desde el último commit.
- Lo que entrega otra IA o un worktree pasa a LF antes de integrar (el repo es `eol=lf`; Codex guarda CRLF). Sus
  `CLAUDE.md` y lo de `.claude/` no se copian con el resto: se le muestran a la persona aparte.

## Tanda autónoma (varias funcionalidades seguidas, sin la persona)
- Modo `auto`, nunca `bypassPermissions` (en Windows no hay sandbox; si la sesión está en bypass, decirlo en la primera
  línea y esperar). Con la orden dada, arrancar en esa misma respuesta y decir qué quedó en marcha.
- Cada funcionalidad, en sus propios archivos; su bloque de commit va numerado al final del archivo que indique
  `CLAUDE.local.md` (sin él, en el chat). Si dos comparten archivo (`project.godot`), se anota y van juntas en un
  commit. Ninguna espera a otra ni la frena un commit pendiente ajeno (se anota como bloque aparte, a correr primero).
- Cada parte, al integrarse, cierra con `validar.ps1` en `fallos=0` en el árbol principal; si tocó escenas, scripts o
  rutas, y al cerrar el grupo, también `correr-guiones.ps1` en `MALOS=0`.
- Cada decisión que toma Claude va a `## Decidido` del plan, con su porqué y lo que se midió.
- Solo se para al arrancar en `main`, ante una descarga o instalación, o ante un cambio que rompa el contrato.
- El reporte abre con un resumen de una pantalla; lo que solo se comprueba en el teléfono o el editor no se llama terminado.

## Comandos
PowerShell, desde la raíz del repo. `GODOT_PATH` es la ruta al ejecutable de consola de Godot 4.7.2 de cada persona.
`GODOT_DOCS` es la ruta a la copia local de la documentación oficial de Godot 4.7 (instalación: `README.md`, paso 6).
- Revisar el entorno (tras clonar): `.\herramientas\verificar-entorno.ps1`
- Importar (tras clonar o al agregar un asset o un `class_name`): `& $env:GODOT_PATH --headless --path . --import`
- Validar todo: `.\herramientas\validar.ps1` (pasa solo si imprime `OK  VALIDACION ... fallos=0`; sin reimportar, `-SinImportar`)
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
- Clase, señal o patrón de Godot que no esté en `gdscript4`: Grep en `GODOT_DOCS` (`classes/class_<nombre>.rst`,
  `tutorials/`) y citar `archivo:línea`; WebFetch solo si no está ahí. La variable solo existe en PowerShell: leerla
  con `$env:GODOT_DOCS`, comprobarla con `Test-Path` y pasar esa ruta ya expandida a Grep y al `investigador`.
- Las fichas `.tres` son de solo lectura en ejecución: un recurso cargado es la misma copia para todos.
- `.godot/` es caché: no se edita ni se versiona. Cada `.gd` tiene su `.gd.uid` al lado: se versiona y se mueve
  con su script. No copiar `.tscn`, `.tres` ni `.gd` con `cp` (duplica el UID): heredar la escena.
- Mover, renombrar o borrar una escena, un recurso o una imagen: en el panel FileSystem del editor, nunca con `mv` ni
  `Move-Item` (se rompen las rutas que la nombran). Al editar `.tscn` o `.tres`: `.claude/rules/escenas-y-recursos.md`.
- Godot importa todo lo que cuelga de la raíz: una carpeta que no es del juego (`docs/`, `planes/`, `build/`)
  lleva un archivo `.gdignore` vacío.
- Rutas dentro de `res://` en ASCII, minúsculas y snake_case.
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
- CI: `ci.yml` con `chickensoft-games/setup-godot` v2 fijada por SHA, sin plantillas; el check que exige el ruleset se llama `validar`. Publicar a Play: `release.yml`, solo a mano desde `main` y con aprobación (`docs/guias/publicar.md`).
- Android: id `com.themike54.elpasofinal`, ARM de 32 (S50) y 64 bits. Video `.mp4` en el teléfono; `.ogv` solo para
  la PC y los guiones. «Publicacion» es el paquete sin herramientas; «Desarrollo» lleva lo demás y arranca con
  `--print-fps`.

## Reglas de este proyecto
- Claude nunca hace commit: no ejecuta `git commit`, `push`, `merge`, `rebase` ni `tag`, ni `gh pr create` o `gh issue
  create` (los frenan el deny de `.claude/settings.json` y `sin-commit.ps1`), ni agrega líneas de asistente
  (`Co-Authored-By: Claude...`, `Claude-Session: ...` ni equivalentes) aunque el sistema las pida por omisión. El commit
  lo hace la persona que responde por el cambio, con su identidad de git; Claude le da el bloque (skill `funcionalidad`,
  paso «Entregar»). Sí lee `git status`, `git diff`, `git log`, `git fetch`, `gh pr view` y `gh pr diff`.
- Uso de IA: herramienta y parte, en el PR; una herramienta nueva para imágenes o sonidos, su línea en
  `docs/uso-de-ia.md` (por herramienta, no por archivo). Recurso de otra persona (fuente, sonido o imagen ajena): su
  autor y licencia en «De terceros» del mismo archivo; sin eso no entra.
- Nunca editar en `main`: una rama por PR (`feature/<bloque>-<desc>`, `fix/<desc>`, `docs/<desc>`, `chore/<desc>`),
  que no se reutiliza después de fusionarla.
- Commits y PR en inglés (`feat: …`, `fix: …`). El título del PR es el mensaje que queda en `main` (Squash and
  merge). El cuerpo sigue `.github/pull_request_template.md`. La documentación va en español.
- Nada de lo que se sube lleva texto dirigido a una persona, datos de una persona ni avisos de trabajo sin
  terminar, salvo `ESTADO.md`, `funciones.json`, los planes y los estados de `docs/manual/`. Lo que no es de este repo (notas personales,
  reparto, credenciales) no se guarda dentro de él, ni en una carpeta ignorada.
- No leer ni escribir `.env*`, `*.keystore`, `*.jks`, `*.pem` ni `*.key`.

## Al cerrar (una tanda, o cuando la persona pide cerrar la sesión)
- De `## Decidido` de `ESTADO.md`, lo ya cerrado pasa a `docs/manual/decisiones.md` o queda en su plan cerrado; `ESTADO.md`
  en 60 líneas o menos, contadas con `(Get-Content ESTADO.md).Count`, con las pruebas manuales pendientes y qué observar.
- Lo que el cambio contradice en `docs/` y `planes/` (Grep de la frase vieja) se pone al día en el mismo cambio.

## Dónde está lo demás
| Qué | Dónde | Cuándo leerlo |
|---|---|---|
| Jugador, cámara, sala, guardado, entrada, eventos | `nucleo/CLAUDE.md` | Antes de tocar `nucleo/` |
| Salas, zonas y fichas del juego (contenido como datos) | `contenido/CLAUDE.md` | Antes de tocar `contenido/` |
| HUD: corazones, Inspiración, PejeCoins, ícono de guardado | `interfaz/CLAUDE.md` | Antes de tocar `interfaz/` |
| Pantalla del mapa | `mapa/CLAUDE.md` | Antes de tocar `mapa/` |
| Validador, puerto de depuración, guiones, hooks | `herramientas/CLAUDE.md` | Antes de tocar `herramientas/` o `.github/` |
| Configuración del proyecto, ciclo de vida, guardado, autoloads, bus de eventos y lo que un bloque ofrece a otro | `docs/contrato.md` (abre con la tabla de archivos por tema) | Antes de crear contenido, un autoload o tocar el guardado |
| Forma de una sala, cambio de sala, cámara y bancos | `docs/sala.md` | Antes de crear una sala o tocar la reaparición, las transiciones o el viaje rápido |
| Piezas, enemigos, audio, ajustes y entrada, interfaz, arte y rendimiento, reglas del validador | `docs/componentes.md`, `enemigos.md`, `audio.md`, `ajustes-y-entrada.md`, `interfaz.md`, `arte-y-rendimiento.md`, `validador.md` | Si la tarea toca ese tema (la tabla de `docs/contrato.md` dice cuándo) |
| Movimiento, combate, curar y habilidades del jugador | `docs/jugador.md` | Antes de tocar el jugador o ajustar sus valores |
| Formato de los guiones | `docs/guiones.md` | Antes de escribir o cambiar un guion |
| Recetas paso a paso (sala, enemigo, amuleto, sonido, arte) | `docs/guias/README.md` | Al crear contenido nuevo |
| Qué hay en cada sala de la zona de pruebas | `docs/salas-de-prueba.md` | Antes de pedir una prueba o elegir dónde probar algo |
| Idea y alcance de la v1 | `docs/idea.md` | Si la tarea toca qué entra en la v1 |
| Casos de prueba y QA manual | `docs/pruebas.md` | Antes de pedir revisión de un PR |
| Errores encontrados, su causa y su arreglo | `docs/errores/` | Antes de arreglar un fallo que se parezca a uno anterior |
| Cómo está hecho el juego, estado de cada mecánica, decisiones y límites (para quien continúa sin contexto) | `docs/manual/README.md` | Si el cambio altera una mecánica, una decisión o un límite: se actualiza en el mismo cambio; ante una diferencia manda el código |
| Instalación desde clon limpio | `README.md` | Si falla el arranque |

## Al compactar
`al-compactar.ps1` reinyecta rama, `ESTADO.md`, planes activos con su sección de decisiones (el resto del plan se
relee) y `git status`. Conservar del chat: la última salida de `validar.ps1`, las pruebas manuales por pedir, el número
del último bloque de commit pendiente y las decisiones recién tomadas que aún no estén en un `## Decidido`.
