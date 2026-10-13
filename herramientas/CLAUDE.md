# Herramientas

Lo que permite comprobar el juego sin abrirlo a mano: validador, puerto de depuración, guiones, revisión del
entorno y hooks. El preset de publicación excluye esta carpeta: nada del juego puede depender de ella.

## Primero
Leer `funciones.json` de esta carpeta: la primera funcionalidad con `"pasa": false` es la que sigue.

## Piezas: lo que no se deduce del código
| Pieza | Contrato |
|---|---|
| `validar.ps1` + `validar.tscn` | La lógica vive en `validar.gd`; el `.ps1` y el CI solo corren la escena y revisan la salida. Pasa solo si aparece `VALIDACION archivos=N fallos=0` y ninguna línea `SCRIPT ERROR`, `ERROR:` o `FALLO` |
| `puerto_depuracion.gd` | No es autoload: lo carga el arranque del núcleo solo en builds de depuración. Modo guion (`--guion=`): compara el resultado con el `.esperado`, imprime `GUION OK` o `GUION FALLA` y sale con 0 o 1. Modo en vivo (`--puerto=`): escucha solo en 127.0.0.1 |
| `guiones/<bloque>/<nombre>.guion` y `.esperado` | Líneas `cuadro acción press|release` y una línea `fin <cuadro>` |
| `githooks/commit-msg` | Rechaza mensajes de commit con líneas de coautoría de asistentes; lo activa `verificar-entorno.ps1` |
| `verificar-entorno.ps1` | Comprueba Godot 4.7.2, `GODOT_PATH`, versión de Claude Code, identidad de git, hook de git y archivos locales ignorados |

## Reglas
- El puerto acepta solo órdenes de una lista fija; nunca ejecuta GDScript recibido y solo escribe capturas
  dentro de `user://`.
- Un guion falla (salida distinta de 0) si su archivo no existe, si nombra una acción que no está en el
  `InputMap` o si el resultado no coincide.
- Un guion comprueba lo que importa (posición con tolerancia, sala, banderas), no todos los decimales.
- Todo guion corre con `--fixed-fps 60` y toda corrida automática con `--quit-after`.
- Un error puesto a propósito en un `.gd` debe hacer fallar `validar.ps1`; si no falla, el validador está mal.
- Los `.ps1`: solo ASCII, sin `$ErrorActionPreference = 'Stop'` alrededor de un ejecutable, probados en
  `powershell.exe` 5.1 y en `pwsh` 7.
- Salida corta: resumen y fallos; el detalle va a `.godot/validar.log`.
- El CI y `validar.ps1` comprueban lo mismo: si cambia uno, cambia el otro en el mismo PR.
- El hook `.claude/hooks/sin-commit.ps1` es más estricto que la regla escrita: también frena `git revert`,
  `cherry-pick`, `am`, `reset --hard` y `clean` sin `-n`. Si bloquea una de esas órdenes, no es un fallo del hook.
  Su batería de órdenes simuladas es `herramientas/probar-sin-commit.ps1`.
