# Cerrar la tienda o la estación con B contaba como pulsar Curar

- **Síntoma:** con el control, cerrar el menú de una `Tienda` o de una `Estacion` con B (Círculo) le llegaba al
  jugador en el mismo tick: sumaba un toque del botón de poderes (`Jugador.toques_poder` de 0 a 1) y, con B
  mantenido, empezaba a curarse. Lo encontró la auditoría del código, no una partida.
- **Causa:**
  - B dispara a la vez `volver` y `curar` (el mismo `button_index` en el `InputMap`).
  - Los dos menús cuelgan de su `Tienda` o `Estacion`, que en el `.tscn` de la sala van antes del `Jugador` (lo agrega
    `Sala._ready` al final). Con la misma prioridad de física, el menú corría primero en ese tick.
  - La pausa se mira nodo por nodo al procesar: el menú leía `volver`, quitaba la pausa, y el jugador, que venía
    después, ya no estaba detenido y leía `curar` recién pulsado.
  - La `Pausa` y el `MarcoMenus` no fallaban solo porque la sala los agrega después del jugador: dependían del orden
    de `add_child`.
- **Arreglo:** `MarcoMenus.PRIORIDAD_FISICA` (100) en el `_ready` de `MarcoMenus`, `Pausa`, `MenuTienda` y
  `MenuEstaciones`. El número más bajo corre primero (`classes/class_node.rst:1607`), así que los menús que quitan la
  pausa corren siempre después del jugador (0), cuelguen donde cuelguen. La regla quedó en `docs/contrato.md`,
  «Marco de menús».
- **Lo cubre:**
  - `herramientas/guiones/nucleo/tienda.guion` (`prueba_tienda.gd`): «con la tienda abierta, las pantallas encima y
    la Pausa van despues del jugador», y «B cierra ... sin contar un toque del boton de poderes» y «B mantenido al
    cerrar ... no empieza a curar» para la tienda, la pausa y el marco.
  - `herramientas/guiones/nucleo/estaciones.guion` (`prueba_estaciones.gd`): el caso de orden y los dos de B con el
    menú de estaciones.
  - `herramientas/guiones/nucleo/marco.guion` (`prueba_marco.gd`): «el marco y la Pausa van despues del jugador».
