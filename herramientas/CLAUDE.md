# Herramientas

Validador, puerto de depuración, guiones, revisión del entorno y hooks: lo que comprueba el juego sin abrirlo a mano.

## Piezas: lo que no se deduce del código
| Pieza | Contrato |
|---|---|
| `validar.ps1` + `validar.tscn` | La lógica vive en `validar.gd`; el `.ps1` y el CI solo corren la escena y revisan la salida. Carga cada `.gd`, `.tscn` y `.tres` y revisa cada `funciones.json`: campos `id`, `que`, `comprobacion` y `pasa`, ids sin repetir y, con `"pasa": true`, que exista cada archivo de la comprobación (varias rutas separadas por `;`) salvo que empiece con `manual:`. Pasa solo si aparece `VALIDACION archivos=N fallos=0` y ninguna línea `SCRIPT ERROR`, `ERROR:` o `FALLO`. Los `AVISO` no hacen fallar: `docs/contrato.md`, «Avisos del validador» |
| `puerto_depuracion.gd` | No es autoload: lo carga el arranque del núcleo solo en builds de depuración. Modo guion (`--guion=`): compara el resultado con el `.esperado`, imprime `GUION OK` o `GUION FALLA` y sale con 0 o 1. Sin ese argumento no hace nada |
| `guiones/<bloque>/<nombre>.guion` y `.esperado` | Entradas por cuadro y estado esperado al final, más, con líneas `en <cuadro>`, en cuadros intermedios. Formato, claves y condiciones de fallo en `docs/guiones.md` |
| `correr-guiones.ps1` | Mismo criterio que el paso «Input scripts» del CI; en serie, porque las pruebas comparten archivos de `user://`. Si cambia el criterio del CI, cambia este en el mismo PR |
| `pruebas/` | Pruebas de código: cada `sala_*.tscn` sin jugador con su `prueba_*.gd`, y `prueba_base.gd`; además la herramienta de medición de rendimiento (`medicion.*`, cómo se corre en `docs/pruebas.md`, «Medición de rendimiento»). Solo las corre su guion o la persona a mano; no salen en la zona de pruebas ni viajan en el paquete de publicación. Lo jugable (zona, salas, `zonas/`, `fichas/`, `comportamientos/`, `arte/`) sigue en `salas/` |
| `arreglar-uids.ps1` | Pone el uid de cada `ext_resource` (y el de la cabecera, si falta) en escenas y recursos escritos a mano. Importa antes, para que los destinos nuevos ya tengan uid. Pasa solo si imprime `UIDS ... errores=0` |
| `githooks/commit-msg` | Rechaza mensajes de commit con líneas de coautoría de asistentes; lo activa `verificar-entorno.ps1` |
| `.claude/hooks/al-compactar.ps1` | Hook `SessionStart` (`compact`): qué reinyecta, en su cabecera. Siempre sale con 0 |
| `verificar-entorno.ps1` | Comprueba Godot 4.7.2, `GODOT_PATH`, versión de Claude Code, identidad de git, hook de git y archivos locales ignorados, y avisa (sin fallar) si `GODOT_DOCS` no apunta a la documentación de Godot 4.7 o si falta `adb` |

## Reglas
- El puerto solo tiene el modo guion (`--guion=`): no abre conexiones ni recibe órdenes. Si algún día las acepta,
  solo de una lista fija y escribiendo solo dentro de `user://`.
- Los guiones siguen `docs/guiones.md`: comprueban lo que importa, con tolerancia.
- Un error puesto a propósito en un `.gd` debe hacer fallar `validar.ps1`; si no falla, el validador está mal.
- Las reglas del validador sobre escenas viven en `docs/contrato.md` («Sala», «Recursos», «Paquete de publicación») y
  en `mapa/CLAUDE.md` (índice de salas). Cada una tiene su entrada en `funciones.json` (casi todas `validador-*`):
  se busca por el id. Una regla nueva va al contrato y a su entrada, no aquí.
- Los `.ps1`, además de lo que dice el raíz: sin `$ErrorActionPreference = 'Stop'` alrededor de un ejecutable.
- El detalle de `validar.ps1` va a `.godot/validar.log`.
- El CI corre la misma validación que `validar.ps1` y además todos los guiones, los mensajes de commit y los
  archivos locales: si cambia la validación de uno, cambia la del otro en el mismo PR.
- El hook `.claude/hooks/sin-commit.ps1` es más estricto que la regla escrita: también frena `git revert`,
  `cherry-pick`, `am`, `reset --hard` y `clean` sin `-n`. Si bloquea una de esas órdenes, no es un fallo del hook.
  Su batería de órdenes simuladas es `herramientas/probar-sin-commit.ps1`.
