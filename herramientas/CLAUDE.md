# Herramientas

Validador, puerto de depuración, guiones, revisión del entorno y hooks: lo que comprueba el juego sin abrirlo a mano.

## Piezas: lo que no se deduce del código
| Pieza | Contrato |
|---|---|
| `validar.ps1` + `validar.tscn` | La lógica vive en `validar.gd`; el `.ps1` y el CI solo corren la escena y revisan la salida. Carga cada `.gd`, `.tscn` y `.tres` y revisa cada `funciones.json`: campos `id`, `que`, `comprobacion` y `pasa`, ids sin repetir y, con `"pasa": true`, que exista cada archivo de la comprobación (varias rutas separadas por `;`) salvo que empiece con `manual:`. Pasa solo si aparece `VALIDACION archivos=N fallos=0` y ninguna línea `SCRIPT ERROR`, `ERROR:` o `FALLO`. Los `AVISO` no hacen fallar: `docs/validador.md`, «Avisos del validador». El `.ps1` revisa además que `ESTADO.md` no pase de 60 líneas |
| `puerto_depuracion.gd` | No es autoload: lo carga el arranque del núcleo solo en builds de depuración. Modo guion (`--guion=`): compara el resultado con el `.esperado`, imprime `GUION OK` o `GUION FALLA` y sale con 0 o 1. Sin ese argumento no hace nada |
| `guiones/<bloque>/<nombre>.guion` y `.esperado` | Entradas por cuadro y estado esperado al final, más, con líneas `en <cuadro>`, en cuadros intermedios. Formato, claves y condiciones de fallo en `docs/guiones.md` |
| `correr-guiones.ps1` | Mismo criterio que el paso «Input scripts» del CI; en serie, porque las pruebas comparten archivos de `user://`. Si cambia el criterio del CI, cambia este en el mismo PR. Un candado (`.godot/correr-guiones.lock`) impide dos corridas a la vez; la segunda sale con 3, que no es pasado ni fallado: esperar a que termine la otra y repetir |
| `revisar-enlaces.ps1` | Revisa enlaces Markdown locales (relativos al documento) y rutas de archivo entre comillas invertidas (relativas al documento o a la raiz), sin `.godot/`, `build/`, metadatos de git ni el historial (`docs/errores/`, `planes/cerrados/`). Omite URLs, bloques de codigo, plantillas con huecos o comodines, nombres sin carpeta, citas de la documentación de Godot, rutas de `.godot/` y tres rutas opcionales fijas en el script. Solo imprime rotos y `ENLACES revisados=N rotos=M`; sale con 1 si hay rotos |
| `generar-tablas.ps1` | Genera `docs/manual/tablas-generadas.md` desde las escenas de `nucleo/` y `contenido/`, los autoloads de `project.godot` y las declaraciones del bus Eventos. Crea la carpeta si falta; salida determinista en UTF-8, sin ejecutar Godot |
| `reporte-entrega.ps1` | Consulta PR fusionados mediante `gh api --method GET --paginate`, sin git ni escrituras a GitHub. Repo predeterminado `TheMike54/el-paso-final`, configurable con `-Repositorio owner/repo`. Escribe `docs/entrega-2.md` con numero, titulo y fecha UTC; si falla la consulta no reemplaza el reporte |
| `pruebas/` | Pruebas de código: cada `sala_*.tscn` sin jugador con su `prueba_*.gd`, y `prueba_base.gd`; además la herramienta de medición de rendimiento (`medicion.*`, cómo se corre en `docs/pruebas.md`, «Medición de rendimiento») y `capturar_sala.*` (la corre `capturar.ps1`). Solo las corre su guion o la persona a mano; no salen en la zona de pruebas ni viajan en el paquete de publicación. Lo jugable (zona, salas, `zonas/`, `fichas/`, `comportamientos/`, `arte/`) sigue en `salas/` |
| `arreglar-uids.ps1` | Pone el uid de cada `ext_resource` (y el de la cabecera, si falta) en escenas y recursos escritos a mano. Importa antes, para que los destinos nuevos ya tengan uid. Pasa solo si imprime `UIDS ... errores=0` |
| `mutar.ps1` | Una mutación: cambia un texto único de un archivo (`-Archivo`, `-Buscar`, `-Poner`), corre el caso (`-Guiones a,b` con los nombres de `correr-guiones.ps1`, o `-Validar`) y deja el archivo como estaba aunque falle o se interrumpa. Antes corre el caso sin mutar: si ya falla, `INVALIDA`. Última línea `MUTACION resultado=... restaurado=SI arbol=IGUAL`. Sale con 0 solo si el caso detectó la mutación (`MATADA`) y el archivo volvió; `SOBREVIVE` (sale 1) es que el caso no prueba lo que dice. Se niega si hay un Godot vivo o si otra mutación tiene `.godot/mutar.lock`; un candado viejo indica qué copiar desde `.godot/mutar-respaldo.orig`. Si `correr-guiones.ps1` sale con 3, `INVALIDA`: esperar y repetir |
| `reemplazar.ps1` | Reemplazos de texto en varios archivos (`-Archivos` con comodines, `-Buscar`/`-Poner` o `-Pares`, `-Regex`). Sin `-Aplicar` solo muestra líneas y conteo por pareja. Con `-Aplicar -Esperado N` copia los archivos a `.godot/reemplazar-respaldo/`, escribe y relee cada uno; si una escritura (aunque sea a medias) o la relectura falla, devuelve todos: todo o nada. Una pareja sin coincidencias cancela todo. Última línea `REEMPLAZO archivos=A cambios=N aplicado=SI verificado=SI`; `aplicado=PARCIAL` (sale 3) es que un archivo no volvió y su copia sigue en esa carpeta, que bloquea el siguiente `-Aplicar` hasta restaurarla. Para uno o dos sitios de un archivo basta Edit |
| `githooks/commit-msg` | Rechaza mensajes de commit con líneas de coautoría de asistentes; lo activa `verificar-entorno.ps1` |
| `.claude/hooks/al-compactar.ps1` | Hook `SessionStart` (`compact`): qué reinyecta, en su cabecera. Siempre sale con 0 |
| `verificar-entorno.ps1` | Comprueba Godot 4.7.2, `GODOT_PATH`, versión de Claude Code, identidad de git, hook de git y archivos locales ignorados, y avisa (sin fallar) si `GODOT_DOCS` no apunta a la documentación de Godot 4.7 o si falta `adb` |
| `instalar-apk.ps1` + `telefono-comun.ps1` | Exporta el preset pedido (`-Preset`, por nombre), instala con `adb -s` en el `-Telefono` y comprueba que es el APK nuevo (fecha del APK contra el último cambio y `lastUpdateTime` del teléfono). Sin `-Telefono` solo sigue con un teléfono conectado. `-BorrarPartidas` borra `partida_*` y `prueba_*` de `files/` (apagado por omisión). Corre `gradlew --stop` al final. Pasa solo si imprime `INSTALAR-APK OK`; deja `INSTALADO ...` por teléfono y la anota en `instalaciones.log`, dentro de `build/` |
| `capturar.ps1` | Capturas de una sala (`-Sala`) en 3 resoluciones (por omisión 1280x720, 1920x1080 y 2560x1440), con ventana, vía `pruebas/capturar_sala.tscn`. Falla si una imagen no mide lo pedido. Pasa solo si imprime `CAPTURAR OK`; las imágenes quedan en `build\capturas\` |
| `medir-fps.ps1` | Mide FPS en un teléfono con el protocolo de su cabecera (foco, ajustes, `logcat` a archivo, temperatura). Requiere el APK de «Desarrollo» instalado. Pasa solo si imprime `MEDIR-FPS OK`; el resultado va a `build\fps-<serie>-<fecha>.txt` |

## Reglas
- El puerto solo tiene el modo guion (`--guion=`): no abre conexiones ni recibe órdenes. Si algún día las acepta,
  solo de una lista fija y escribiendo solo dentro de `user://`.
- Los guiones siguen `docs/guiones.md`: comprueban lo que importa, con tolerancia.
- Un error puesto a propósito en un `.gd` debe hacer fallar `validar.ps1` (se prueba con `mutar.ps1 -Validar`); si no
  falla, el validador está mal.
- Las reglas del validador sobre escenas viven en `docs/validador.md` (la lista completa), `docs/sala.md`,
  `docs/contrato.md` («Paquete de publicación»), `docs/arte-y-rendimiento.md` («Recursos») y `mapa/CLAUDE.md` (índice de
  salas). Cada una tiene su entrada en `funciones.json` (casi todas `validador-*`): se busca por el id. Una regla
  nueva va a `docs/validador.md` y a su entrada, no aquí.
- Los `.ps1`, además de lo que dice el raíz: sin `$ErrorActionPreference = 'Stop'` alrededor de un ejecutable.
- El detalle de `validar.ps1` va a `.godot/validar.log`.
- El CI (`ci.yml`, job `validar`) corre la misma validación que `validar.ps1` y además todos los guiones, los mensajes
  de commit, los archivos locales, `revisar-enlaces.ps1` y que `generar-tablas.ps1` no cambie su archivo: si cambia la
  validación de uno, cambia la del otro en el mismo PR. La publicación va aparte, en `release.yml`
  (`docs/guias/publicar.md`).
- El hook `.claude/hooks/sin-commit.ps1` es más estricto que la regla escrita: también frena `git revert`,
  `cherry-pick`, `am`, `reset --hard` y `clean` sin `-n`. Si bloquea una de esas órdenes, no es un fallo del hook.
  La batería de los dos hooks (`sin-commit.ps1` y `al-compactar.ps1`) es `herramientas/probar-sin-commit.ps1`.
- Una corrida de Godot a la vez: guiones, `validar.ps1`, mutaciones, mediciones y exportaciones comparten `user://` y
  `.godot/`. `correr-guiones.ps1` y `mutar.ps1` tienen candado (si `correr-guiones.ps1` sale con 3, esperar y
  repetir); los demás no, así que antes de lanzar uno se comprueba que no queda otro vivo (`Get-Process Godot*`).
  Mientras corre una batería no se editan `nucleo/`, `interfaz/`, `contenido/` ni `herramientas/`; si se editó, la
  batería se repite entera sobre el estado final.
- Las mutaciones se hacen con `mutar.ps1`, no a mano ni con `sed` sobre el archivo real. Un caso nuevo se da por bueno
  cuando una mutación que rompe justo lo que dice probar lo hace fallar (`MATADA`). La mutación cambia el
  comportamiento, no la sintaxis ni la constante con la que compara la prueba (el script avisa si el fallo parece de
  sintaxis). Si `SOBREVIVE`, se corrige el caso, no la mutación. En la evidencia van las mutaciones corridas y cuántas
  murieron. Con `arbol=CAMBIADO` o `restaurado=NO`, mirar `git status` antes de seguir.
- Un script que clasifica la salida de otro usa coincidencia exacta, anclada y con mayúsculas (`-cmatch '^GUION OK'`):
  `-match` ignora mayúsculas y `fallos=0` coincide con `FALLO`. Pasa solo si aparece la línea de éxito esperada, no
  por ausencia de errores. Si falta la línea de resumen o su conteo no es el pedido, el resultado es inválido: ni
  pasado ni fallado.
- Los reemplazos en varios archivos o con varias parejas van con `reemplazar.ps1`: primero la vista previa, después
  `-Aplicar -Esperado N`. No se informa «N de N» sin que el script haya releído los archivos. En PowerShell, una
  función auxiliar no se llama `R` ni con otro nombre corto: choca con un alias y falla en silencio.
