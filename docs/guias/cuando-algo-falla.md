# Cuando algo falla

**Para qué sirve:** orden corto para diagnosticar los fallos más comunes del proyecto antes de pedir ayuda.
**Antes de empezar:** leer `CLAUDE.md`, «Entorno y trampas», y tener a mano `docs/errores/` (cada error ya
resuelto: síntoma, causa, arreglo y guion que lo cubre).

1. Tener a mano la salida de `.\herramientas\validar.ps1`. Pasa solo si imprime `OK  VALIDACION ... fallos=0`; si
   no, imprime las primeras 20 líneas de error y la ruta del log (`.godot\validar.log`). El código de salida de
   Godot no sirve para decidirlo (`CLAUDE.md`, «Entorno y trampas»).
2. Buscar en `docs/errores/` un fallo parecido (Grep del mensaje o del nombre de la pieza) antes de arreglar.
3. Elegir la rama que corresponde.

## Árbol

| Síntoma | Qué mirar |
|---|---|
| `validar.ps1` termina en `FALLA` con líneas `FALLO ...` | Cada línea nombra el archivo y la regla. La regla vive en `docs/contrato.md` y su entrada `validador-*`, en `herramientas/funciones.json`. Corregir y repetir con `-SinImportar` si no cambió ningún asset |
| `validar.ps1` dice «la escena validadora no imprimio su resumen» | El validador no corrió completo, normalmente porque un script no compila. Leer `.godot\validar.log` y buscar `SCRIPT ERROR` |
| `Parse Error` que Godot no refleja en el código de salida | `--import` y una corrida headless salen con 0 aunque un script no compile; solo `validar.ps1` lo atrapa. Reglas de tipado y diferencias con Python: skill `gdscript4` |
| «Identifier not found» con `--check-only` | `--check-only` no carga autoloads; usar `validar.ps1` |
| Un error que solo ocurre al correr, con `validar.ps1` en `fallos=0` | El validador no ejecuta `_ready`: lo atrapa un guion. Correr el de la sala (`docs/guiones.md`) |
| Un guion sale `MALO` sin líneas de error y con «no termino antes de --quit-after» | No imprimió `GUION OK` dentro de `--quit-after 7200`. Repetirlo solo: `.\herramientas\correr-guiones.ps1 -Guiones <bloque>/<nombre>`. Si la corrida se detiene siempre, revisar que la escena llame a `quit()`; toda corrida automática lleva `--quit-after` |
| Un guion falla con `GUION FALLA ...: en <cuadro> ...` | El estado no coincidió con el `.esperado`; formato y cuadros en `docs/guiones.md` |
| `uid` duplicado, o `validar.ps1` dice que un `ext_resource` no lleva `uid=` o no es el de su destino | Los `.tscn`, `.tres` y `.gd` no se copian con `cp`: duplica el UID; se hereda la escena. La regla de `uid` y cómo se toman del disco: `docs/contrato.md`, «Sala», viñeta «uid» |
| Una escena, recurso o imagen se movió o borró fuera de Godot y las rutas se rompieron | Si se movió con su `.import` o `.uid`, abrir el editor para que repare las rutas y correr `validar.ps1`. Mover, renombrar y borrar se hace desde el panel FileSystem (`CLAUDE.md`, «Entorno y trampas») |
| Una imagen nueva no se ve o no tiene `.import` | Importar: `& $env:GODOT_PATH --headless --path . --import` y volver a validar |
| Comportamiento raro tras cambiar de rama o de versión | `.godot/` es caché: no se edita ni se versiona, y nunca se borra con `git clean -x` ni `-X` (`CLAUDE.md`, «Entorno y trampas»). Reimportar con el comando de arriba |
| El editor ofrece convertir el proyecto | Responder que no; la versión exacta de Godot es la que fija `README.md`, «Entorno» |
| No arranca nada | `.\herramientas\verificar-entorno.ps1` debe terminar con `ENTORNO OK` (`README.md`, «Ejecutar desde un clon limpio») |

## Cuando es un error nuevo
1. Arreglarlo en una rama, no en `main` (`CLAUDE.md`, «Reglas de este proyecto»).
2. Escribir `docs/errores/AAAA-MM-DD-tema.md` en el mismo cambio: síntoma, causa, arreglo y el guion que lo cubre
   ahora (`CLAUDE.md`, «Cómo se trabaja»). Un fallo del código lleva su guion; un guion que falla a propósito no
   es un error y no se registra en `docs/errores/`.
3. Los commits los hace la persona que responde por el cambio (skill `funcionalidad`, paso «Entregar»).

## Si algo falla
- Ninguna fila del árbol coincide: guardar la salida completa de `validar.ps1` y el log indicado, y consultar
  `CLAUDE.md`, «Entorno y trampas», y `docs/errores/` antes de preguntar.
