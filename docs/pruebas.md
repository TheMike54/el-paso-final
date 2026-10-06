# Pruebas y QA

Se prueba donde la lógica puede romperse (guardado, cuentas, reglas, validador de contenido), más un guion
corto por sala. No se prueba que una escena se dibuje ni que exista un nodo. Toda salida es corta: resumen y
fallos.

## Automáticas

Los comandos son de PowerShell, desde la raíz del repositorio. El validador y los guiones corren también en el
CI (job `validar`); la batería del hook corre solo en local.

| Qué | Comando | Pasa si |
|---|---|---|
| Validador: carga cada script, escena y recurso, y revisa cada `funciones.json` | `.\herramientas\validar.ps1` | Imprime `OK  VALIDACION archivos=N fallos=0` |
| Guion de una sala | `& $env:GODOT_PATH --headless --path . --fixed-fps 60 --quit-after 7200 -- --guion=<ruta>` | Imprime `GUION OK` y sale con 0 |
| Hook que impide al asistente publicar o reescribir el historial | `.\herramientas\probar-sin-commit.ps1` | Imprime `PRUEBAS sin-commit total=N fallos=0` |

El validador no ejecuta `_ready`: un error que solo ocurre al correr lo atrapa un guion.

### Guiones

| Guion | Qué comprueba |
|---|---|
| `herramientas/guiones/nucleo/caja.guion` | La caja gris camina 30 px a la izquierda, 300 px a la derecha y salta: en el cuadro 100 está en `x=470`, en el aire, en la escena `nucleo/caja_gris.tscn` |

El formato de los guiones está en `docs/contrato.md`.

## Revisión de un PR

Quien revisa reproduce la validación en su equipo y deja al menos un comentario con la salida:

1. Traer la rama del PR: `git fetch origin` y `git switch <rama>`.
2. `.\herramientas\verificar-entorno.ps1`: debe terminar con `ENTORNO OK`.
3. `.\herramientas\validar.ps1`: debe imprimir `OK  VALIDACION ... fallos=0`.
4. Los guiones que el PR agrega o cambia: cada uno debe imprimir `GUION OK`.
5. Los casos manuales que el PR indique en su sección de evidencia de QA.

## Casos manuales

Lo que no se comprueba sin ventana o sin teléfono. Cada ejecución anota fecha, equipo y resultado.

| Caso | Pasos | Resultado esperado | Última ejecución |
|---|---|---|---|
| Caja gris en ventana | `& $env:GODOT_PATH --path .`; A y D; W | Se ve una caja gris sobre un suelo oscuro; camina hacia los dos lados y salta | Sin ejecución con A, D y W. Con el teclado anterior (flechas y Z): 06-oct-2026, Windows 11, Godot 4.7.2, pasa |
| Botón Atrás | En el teléfono, tocar Atrás durante el juego | La app no se cierra | Sin ejecución |
| Apps recientes | Mandar la app al fondo y volver | El juego sigue donde estaba | Sin ejecución |
| Rotación | Girar el teléfono 180° | La imagen gira y sigue horizontal | Sin ejecución |
