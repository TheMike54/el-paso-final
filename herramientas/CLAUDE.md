# Herramientas

Lo que permite comprobar el juego sin abrirlo a mano: validador, puerto de depuración, guiones, revisión del
entorno y hooks.

## Primero
Leer `funciones.json` de esta carpeta.

## Piezas: lo que no se deduce del código
| Pieza | Contrato |
|---|---|
| `validar.ps1` + `validar.tscn` | La lógica vive en `validar.gd`; el `.ps1` y el CI solo corren la escena y revisan la salida. Carga cada `.gd`, `.tscn` y `.tres` y revisa cada `funciones.json`: campos `id`, `que`, `comprobacion` y `pasa`, ids sin repetir y, con `"pasa": true`, que exista cada archivo de la comprobación (varias rutas separadas por `;`) salvo que empiece con `manual:`. Pasa solo si aparece `VALIDACION archivos=N fallos=0` y ninguna línea `SCRIPT ERROR`, `ERROR:` o `FALLO` |
| `puerto_depuracion.gd` | No es autoload: lo carga el arranque del núcleo solo en builds de depuración. Modo guion (`--guion=`): compara el resultado con el `.esperado`, imprime `GUION OK` o `GUION FALLA` y sale con 0 o 1. Sin ese argumento no hace nada |
| `guiones/<bloque>/<nombre>.guion` y `.esperado` | Entradas por cuadro y estado esperado al final, más, con líneas `en <cuadro>`, en cuadros intermedios. Formato, claves y condiciones de fallo en `docs/guiones.md` |
| `correr-guiones.ps1` | Corre todos los guiones (o los de `-Guiones`, sin extensión) con el mismo criterio que el paso «Input scripts» del CI: bien si la salida tiene `GUION OK` y ninguna `SCRIPT ERROR` ni `ERROR:`. Imprime solo los malos y `RESUMEN total=N OK=N MALOS=N`; sale con 0 solo si `MALOS=0`. En serie: las pruebas comparten archivos de `user://`. Si cambia el criterio del CI, cambia este en el mismo PR |
| `pruebas/` | Pruebas de código: cada `sala_*.tscn` sin jugador con su `prueba_*.gd`, y `prueba_base.gd`. Solo las corre su guion; no salen en la zona de pruebas ni viajan en el paquete de publicación. Lo jugable (zona, salas, `zonas/`, `fichas/`, `comportamientos/`, `arte/`) sigue en `salas/` |
| `githooks/commit-msg` | Rechaza mensajes de commit con líneas de coautoría de asistentes; lo activa `verificar-entorno.ps1` |
| `.claude/hooks/al-compactar.ps1` | Hook `SessionStart` con matcher `compact` (qué reinyecta: «Al compactar» del `CLAUDE.md` raíz); además pide releer el `CLAUDE.md` y el `funciones.json` del bloque. Siempre sale con 0 |
| `verificar-entorno.ps1` | Comprueba Godot 4.7.2, `GODOT_PATH`, versión de Claude Code, identidad de git, hook de git y archivos locales ignorados, y avisa (sin fallar) si `GODOT_DOCS` no apunta a la documentación de Godot 4.7 o si falta `adb` |

## Reglas
- El puerto solo tiene el modo guion (`--guion=`): no abre conexiones ni recibe órdenes. Si algún día las acepta,
  solo de una lista fija y escribiendo solo dentro de `user://`.
- Los guiones siguen `docs/guiones.md`: comprueban lo que importa, con tolerancia.
- Un error puesto a propósito en un `.gd` debe hacer fallar `validar.ps1`; si no falla, el validador está mal.
- Reglas del validador sobre escenas, además de compilar. La regla completa vive en el contrato; aquí solo dónde
  está y qué entrada de `funciones.json` la cubre:

  | Qué revisa | Regla | Entrada |
  |---|---|---|
  | Salas, puertas, bancos, ids, `Npc`, `RetoPreguntas`, `Tienda`, `Estacion`, `AvisoAccion`, `botones_por_ensenar`, muros, palancas, portones, habilidades | `docs/contrato.md`, «Sala» (lista completa) | `validador-tienda`, `validador-estaciones`, `validador-avisos`, `validador-avisos-id`, `validador-botones-por-ensenar`, `validador-muros-palancas`, `validador-habilidades` |
  | Pared detrás de cada puerta del borde izquierdo o derecho | `docs/contrato.md`, «Cambio de sala» | `validador-pared-tras-puerta` |
  | Presupuesto de decoración, capas translúcidas, texturas de 2048 px, importación del arte del mundo (`CARPETAS_ARTE_MUNDO`, `ALFA_EN_VRAM`) | `docs/contrato.md`, «Recursos» | `validador-presupuesto`, `validador-capas-translucidas`, `validador-texturas`, `validador-importacion` |
  | Un `DanoContacto` con `peligro` dentro de algo que se mueve falla: lo que se mueve solo golpea | Aquí | `validador-peligro-movil` |
  | Cada `BolsaPreguntas` sin fallos | Aquí | `validador-bolsa-mochila` |
  | Índice de salas del mapa al día | `mapa/CLAUDE.md` | `mapa-indice` (`mapa/funciones.json`) |
  | `GRUPOS` y `OCULTAS` de `herramientas/salas/zona_pruebas.gd` nombran escenas que existen; cada sala de `GRUPOS` tiene su línea en `SALAS`, y `SALAS` no nombra salas fuera de `GRUPOS` | Aquí | `validador-zona-pruebas`, `zona-pruebas-siete-categorias` |
  | Nada fuera de `herramientas/pruebas/` (ni `project.godot`) nombra algo de dentro por ruta o por uid: no viaja en el paquete de publicación | `docs/contrato.md`, «Paquete de publicación» | `validador-pruebas-aparte` |
- Los `.ps1`, además de lo que dice el raíz: sin `$ErrorActionPreference = 'Stop'` alrededor de un ejecutable.
- El detalle de `validar.ps1` va a `.godot/validar.log`.
- El CI corre la misma validación que `validar.ps1` y además todos los guiones, los mensajes de commit y los
  archivos locales: si cambia la validación de uno, cambia la del otro en el mismo PR.
- El hook `.claude/hooks/sin-commit.ps1` es más estricto que la regla escrita: también frena `git revert`,
  `cherry-pick`, `am`, `reset --hard` y `clean` sin `-n`. Si bloquea una de esas órdenes, no es un fallo del hook.
  Su batería de órdenes simuladas es `herramientas/probar-sin-commit.ps1`.
