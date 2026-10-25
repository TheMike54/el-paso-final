# Guiones de entrada

Formato y reglas de los guiones (`herramientas/guiones/`). Es parte de `docs/contrato.md` (mismas reglas: se
actualiza en el mismo cambio que el puerto de depuración) y se separó por largo.

Un guion reproduce entradas por cuadro de física y compara el estado con un archivo de valores esperados. Lo
corre el puerto de depuración (`herramientas/puerto_depuracion.gd`), en local y en el CI:

```powershell
& $env:GODOT_PATH --headless --path . --fixed-fps 60 --quit-after 7200 -- --guion=herramientas/guiones/<bloque>/<nombre>.guion
```

Para correr varios desde el repo, como el CI: `.\herramientas\correr-guiones.ps1` corre todos y
`.\herramientas\correr-guiones.ps1 -Guiones nucleo/tienda,mapa/mapa_cuentas` solo esos (ruta bajo
`herramientas/guiones/`, sin extensión). Usa `GODOT_PATH`, corre desde cualquier carpeta, imprime solo los que fallan
con sus líneas `FALLO`, `GUION FALLA`, `SCRIPT ERROR` o `ERROR:` y termina con `RESUMEN total=N OK=N MALOS=N`; sale
con 0 solo si `MALOS=0`. Un guion está bien con el criterio del CI: su salida tiene `GUION OK` y ninguna línea
`SCRIPT ERROR` ni `ERROR:`. Corre en serie porque las pruebas comparten archivos de `user://` (por ejemplo
`Partida.RUTA_PRUEBAS` y `ajustes.json`).

- `<nombre>.guion`: líneas `<cuadro> <acción> press|release` y una línea `fin <cuadro>`. Los cuadros de las
  entradas van de 1 a `fin` menos 1.
- Línea opcional `escena <ruta res://>`: el puerto cambia a esa escena al empezar y el cuadro 1 es el primer
  cuadro de física con ella ya cargada. Sin la línea, el guion corre sobre la escena principal. Una ruta que no
  existe hace fallar el guion.
- Medido el 06-oct-2026: una acción que el jugador lee como sostenida (caminar) se nota en el estado del cuadro
  N+1; una que lee como recién presionada (`saltar`), en el del cuadro N+2. Los cuadros de un guion se miden con
  una corrida, no se calculan.
- `<nombre>.esperado`, junto al guion: líneas `<clave> <valor> [tolerancia]`.

  | Clave | Valor | Se compara |
  |---|---|---|
  | `x`, `y` | Posición global del nodo del grupo `jugador`, en píxeles | Con tolerancia; 0,5 si no se indica |
  | `en_suelo` | `true` o `false` | Exacto |
  | `escena` | Ruta `res://` de la escena actual | Exacto |
  | `valor <nodo> <propiedad>` | Valor de una propiedad de un nodo; admite subpropiedades (`position:x`) | Un número, con tolerancia (0,5 si no se indica); otro valor, por su texto |
  | `senal <nodo> <señal>` | Cuántas veces se emitió la señal desde el cuadro 1 | Exacto |

  `<nodo>` es una ruta relativa a la escena actual (`.` es su raíz, `Jugador` el jugador que crea la sala) o
  absoluta (`/root/<autoload>`). El puerto se conecta a las señales en el cuadro 1: un nodo o una señal que no
  existen hacen fallar el guion. Como las líneas se parten por espacios, `valor` no compara valores cuyo texto
  lleva espacios (un `Rect2`, un `Vector2`): se usa una subpropiedad (`position:x`).

- Línea opcional `en <cuadro> <línea>` en el `.esperado`: `<línea>` es cualquiera de las de la tabla, con su
  tolerancia si la tiene, y se compara al empezar ese cuadro en lugar de en `fin`, antes de las entradas de ese
  cuadro (como `fin`). Sirve para ver un estado intermedio que el final no distingue: en
  `nucleo/jugador_curar_atacar.esperado`, el ataque encendido justo antes de empezar la curación. El cuadro va de 1
  a `fin` menos 1; fuera de eso, o con una `<línea>` que no se entiende, el guion falla al cargar. Si no coincide,
  el guion termina en ese cuadro y el motivo lleva delante el cuadro:
  `GUION FALLA <ruta>: en 172 valor Jugador curando esperado=true obtenido=false`. Una `senal` en una línea `en`
  cuenta las emisiones desde el cuadro 1 hasta ese cuadro, y comparte la cuenta con las otras líneas de la misma
  señal.

- En los dos archivos se ignoran las líneas vacías y las que empiezan con `#`.
- El estado se lee al empezar el cuadro `fin` (y, para las líneas `en`, al empezar su cuadro). El puerto sigue
  contando cuadros con el juego en pausa.
- `Input.action_press` del puerto cambia el estado de la acción pero no genera un evento: lo que debe responder a
  un guion lee la acción (`Input.is_action_just_pressed`), no `_input` ni `_unhandled_input`.
- Resultado: una línea `GUION OK <ruta> cuadro=<n>` y salida 0, o `GUION FALLA <ruta>: <motivo>` y salida 1.
  Falla si el guion o su `.esperado` no existen, si una línea no es válida, si una acción no está en el
  `InputMap` o si el estado no coincide.
- Un guion comprueba lo que importa (llegó, está en el suelo, cambió de sala) con tolerancia; no todos los
  decimales.
- Lo que tiene muchos casos de lógica va en una escena de prueba de `herramientas/pruebas/` (una `sala_*.tscn` con
  su `prueba_<nombre>.gd`; no viajan en el paquete de publicación) que hereda por ruta
  `herramientas/pruebas/prueba_base.gd`: cuenta con `_caso(nombre, bien)`, imprime solo los fallos y
  `_resumen()`, y su guion lee `valor . casos` y `valor . fallos`. La base trae además estos ayudantes:
  - `_esperar(ticks)`: espera ticks de física.
  - `_presionar(accion)`: presiona una acción dos ticks y la suelta, como un toque corto.
  - `_acciones_del_boton(boton)`: las acciones del `InputMap` que dispara un botón del control (B es `volver` y
    `curar`; LB, `mapa_rapido` y `pagina_anterior`), leídas del `InputMap`.
  - `_sostener_boton(boton, sostener)`: presiona o suelta a la vez todas las acciones de ese botón.
  - `_presionar_boton(boton)`: como `_presionar`, con todas las acciones del botón en los mismos ticks.
  - `_procesados_antes_que(jugador, extra)`: nombres de las pantallas encima (`MarcoMenus.GRUPO`) y de los nodos de
    `extra` que no corren en la física después del jugador (`process_physics_priority`).
  - `_b_cierra(que, jugador, abrir, abierta)`: comprueba que B, tocado y mantenido, cierra lo que abre `abrir` sin
    contar un toque del botón de poderes ni empezar a curar.
  - `_iconos(raiz)` e `_iconos_en(iconos, visibles)`: los `IconoBoton` bajo un nodo y si todos están a la vista (u
    ocultos).
  - `_usar(con_control)`: anota el último dispositivo (control o toque) y espera a que los íconos lo vean.
  - `_escribir(ruta, texto)`: escribe un archivo de texto.
  - `_aislar_partida(ruta)`: recuerda la ruta de guardado de `Partida`, la cambia a `ruta` (por omisión
    `Partida.RUTA_PRUEBAS`) y reinicia la partida. No borra el archivo antes: la prueba que necesita empezar sin él
    lo borra ella.
  - `_restaurar_partida()`: lo deshace al final: reinicia la partida, devuelve la ruta de antes y borra el archivo
    de prueba y su `.tmp`.

  `prueba_control.gd`, `prueba_vista.gd` y `prueba_foco.gd` no heredan de ella.
