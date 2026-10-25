# Cerrar un menú con A hacía saltar al jugador

- **Síntoma:** con el control, pulsar y soltar A (Cruz) en el mismo cuadro sobre un botón de un menú que detiene el
  juego (Continuar de la pausa, el No del cobro de una `Estacion`, Volver del marco) cerraba el menú y el jugador
  saltaba en el primer tick con el juego andando. Cayendo, la misma pulsación saltaba con el coyote o quedaba en la
  cola del salto. Lo reportó la persona el 20-oct-2026.
- **Causa:**
  - A dispara a la vez `ui_accept` y `saltar` (el mismo `button_index` en el `InputMap`).
  - Un `Button` con foco se pulsa con `ui_accept` al despachar el evento, y con su modo por omisión emite `pressed`
    al soltar. Los eventos se despachan al empezar el cuadro, antes del tick de física y fuera de él. El botón quita
    la pausa (`get_tree().paused = false`) ahí mismo.
  - En el tick de física de ese mismo cuadro el jugador ya no está detenido y `Input.is_action_just_pressed(&"saltar")`
    es verdadero: la pulsación es de ese tick, aunque A ya se haya soltado.
  - `MarcoMenus.PRIORIDAD_FISICA` (`docs/errores/2026-10-17-cerrar-con-b-cura.md`) no lo cubre: ordena los
    `_physics_process`, y aquí el menú se cierra antes de que empiece el tick.
  - Medido con la prueba (prints temporales): los eventos mandados en el `_process` del cuadro 35 se despachan al
    empezar el 36 (`get_process_frames()` 36, `Engine.is_in_physics_frame()` falso, `saltar` recién pulsada y ya
    suelta); el tick de física que sigue, el primero sin pausa (`get_physics_frames()` 37 dentro de él), la lee como
    recién pulsada y el jugador sube 95,6 px.
- **Arreglo:** en `nucleo/jugador.gd`, `_notification` anota `_saltar_del_menu` cuando llega
  `NOTIFICATION_UNPAUSED` fuera de la física; `_saltar_pulsado()` reemplaza a
  `Input.is_action_just_pressed(&"saltar")` en `_avanzar_contadores` y en el congelado, y el banco no se levanta con
  esa pulsación. La marca se borra al final del `_physics_process` siguiente: una pulsación nueva en el tick de
  después sí salta. Un menú que se cierra leyendo una acción en su `_physics_process` (B, `pausa`) lo hace dentro de
  la física y no la pone. La regla quedó en `docs/jugador.md` («Cerrar un menú con A») y en «Marco de menús» de
  `docs/contrato.md`.
- **Hueco que encontró la revisión (120 FPS):** la primera versión del arreglo solo ponía la marca si, al llegar
  `NOTIFICATION_UNPAUSED`, `Input.is_action_just_pressed(&"saltar")` era verdadero. Fuera de la física eso compara con
  el cuadro de render: si A baja en un cuadro y sube en el siguiente sin un tick de física entre los dos (pasa con la
  opción de 120 FPS, dos cuadros por tick), al soltarse (cuando el botón quita la pausa) `saltar` ya no es recién
  pulsada para el cuadro, pero el tick siguiente sí la lee así, porque es la primera desde la bajada. La marca no se
  ponía y el jugador saltaba. Corrección: la marca se pone en todo `NOTIFICATION_UNPAUSED` fuera de la física, sin
  mirar `saltar`; todos los `get_tree().paused = false` de `nucleo/` son menús (`pausa`, `marco_menus`,
  `cobro_estacion`, `menu_tienda`, `menu_estaciones`), y la marca dura un tick.
- **Lo cubre:** `herramientas/guiones/nucleo/salto_tras_menu.guion` (`prueba_salto_tras_menu.gd`), con eventos de
  verdad (`Input.parse_input_event`, A apretado y soltado en el mismo cuadro):
  - «A en Continuar cierra la pausa sin saltar»;
  - «A en el No del cobro lo cierra sin saltar»;
  - «A en Volver del marco lo cierra sin saltar»;
  - «A al cerrar la pausa en el aire no salta al aterrizar»;
  - «A al cerrar la pausa sentado no lo levanta»;
  - «saltar pulsado en el tick siguiente al cierre si salta»;
  - «A apretado y soltado en dos cuadros sin tick entre medio cierra la pausa sin saltar»: baja la física a 30 ticks
    por segundo con `--fixed-fps 60` (un tick cada dos cuadros), manda la bajada y la subida en dos cuadros seguidos y
    comprueba con `Engine.get_physics_frames()` que no hubo tick entre las dos; luego restaura los ticks.

  Con el `jugador.gd` de antes fallan los cinco primeros (sube 95,6 y 95,5 px; sentado, se levanta). Con la condición
  de la primera versión (`and Input.is_action_just_pressed(&"saltar")`) falla solo el séptimo (sube 113,1 px: el
  primer tick va a 30 por segundo). La pulsación con
  un control real sigue siendo la prueba manual «Control conectado» de `docs/pruebas.md`.
