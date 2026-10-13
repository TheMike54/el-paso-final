# Herramientas

Lo que permite comprobar el juego sin abrirlo a mano: validador, puerto de depuración, guiones, revisión del
entorno y hooks. La carpeta viaja en el paquete de publicación (la zona de pruebas, con el modo desarrollador), pero
nada del juego puede depender de ella; el puerto de depuración solo corre en builds de depuración (detalle en
`docs/contrato.md`, «Paquete de publicación»).

## Primero
Leer `funciones.json` de esta carpeta: la primera funcionalidad con `"pasa": false` es la que sigue.

## Piezas: lo que no se deduce del código
| Pieza | Contrato |
|---|---|
| `validar.ps1` + `validar.tscn` | La lógica vive en `validar.gd`; el `.ps1` y el CI solo corren la escena y revisan la salida. Carga cada `.gd`, `.tscn` y `.tres` y revisa cada `funciones.json`: campos `id`, `que`, `comprobacion` y `pasa`, ids sin repetir y, con `"pasa": true`, que exista cada archivo de la comprobación (varias rutas separadas por `;`) salvo que empiece con `manual:`. Pasa solo si aparece `VALIDACION archivos=N fallos=0` y ninguna línea `SCRIPT ERROR`, `ERROR:` o `FALLO` |
| `puerto_depuracion.gd` | No es autoload: lo carga el arranque del núcleo solo en builds de depuración. Modo guion (`--guion=`): compara el resultado con el `.esperado`, imprime `GUION OK` o `GUION FALLA` y sale con 0 o 1. Sin ese argumento no hace nada |
| `guiones/<bloque>/<nombre>.guion` y `.esperado` | Entradas por cuadro y estado esperado al final. Formato, claves y condiciones de fallo en `docs/guiones.md` |
| `githooks/commit-msg` | Rechaza mensajes de commit con líneas de coautoría de asistentes; lo activa `verificar-entorno.ps1` |
| `.claude/hooks/al-compactar.ps1` | Hook `SessionStart` con matcher `compact`: imprime la rama, `git status --short`, `ESTADO.md` y la lista de `planes/activos/`, y pide releer el `CLAUDE.md` y el `funciones.json` del bloque. Siempre sale con 0 |
| `verificar-entorno.ps1` | Comprueba Godot 4.7.2, `GODOT_PATH`, versión de Claude Code, identidad de git, hook de git y archivos locales ignorados |

## Reglas
- El puerto acepta solo órdenes de una lista fija; nunca ejecuta GDScript recibido y solo escribe capturas
  dentro de `user://`.
- Los guiones siguen `docs/guiones.md`: comprueban lo que importa, con tolerancia; toda corrida automática lleva
  `--fixed-fps 60` y `--quit-after`.
- Un error puesto a propósito en un `.gd` debe hacer fallar `validar.ps1`; si no falla, el validador está mal.
- Reglas del validador sobre escenas, además de compilar: las de cada sala, completas en `docs/contrato.md`,
  «Sala»; en cualquier escena, un `DanoContacto` con `peligro` dentro de algo que se mueve falla (lo que se mueve solo golpea;
  entrada `validador-peligro-movil`); cada sala respeta el presupuesto de decoración (cifras en `docs/contrato.md`,
  «Recursos»; entrada `validador-presupuesto`); el índice de salas del mapa está al día (entrada
  `mapa-indice` de `mapa/funciones.json`); las tablas de la zona de pruebas (`GRUPOS` y `OCULTAS` de
  `salas/zona_pruebas.gd`) solo nombran escenas que existen (entrada `validador-zona-pruebas`).
- Los `.ps1`: solo ASCII, sin `$ErrorActionPreference = 'Stop'` alrededor de un ejecutable, probados en
  `powershell.exe` 5.1 y en `pwsh` 7.
- Salida corta: resumen y fallos; el detalle va a `.godot/validar.log`.
- El CI y `validar.ps1` comprueban lo mismo: si cambia uno, cambia el otro en el mismo PR.
- El hook `.claude/hooks/sin-commit.ps1` es más estricto que la regla escrita: también frena `git revert`,
  `cherry-pick`, `am`, `reset --hard` y `clean` sin `-n`. Si bloquea una de esas órdenes, no es un fallo del hook.
  Su batería de órdenes simuladas es `herramientas/probar-sin-commit.ps1`.
