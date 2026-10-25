# Cerrar el marco con LB sostenido mostraba el mapa rápido

- **Síntoma:** con el control, sostener LB (L1) con el marco de menús abierto y cerrarlo con B mostraba el mapa
  rápido en cuanto el juego volvía a andar, sin haber pulsado LB con el juego andando. Pasaba igual al cerrar la
  Pausa con `mapa_rapido` sostenido. Lo encontró la auditoría del código, no una partida.
- **Causa:**
  - LB dispara a la vez `mapa_rapido` y `pagina_anterior` (el mismo `button_index` en el `InputMap`): dentro del
    marco, LB es cambiar de página.
  - `PantallaMapa._physics_process` decidía con `Input.is_action_pressed(&"mapa_rapido") and not get_tree().paused`:
    solo miraba si la acción estaba pulsada en ese tick, no cuándo empezó. Al cerrar el marco o la Pausa con LB aún
    abajo, el primer tick sin pausa ya contaba como «mantener el mapa rápido».
- **Arreglo:** `PantallaMapa._armado` en `mapa/pantalla_mapa.gd`. Se arma solo en el tick en que `mapa_rapido` se
  pulsa (`is_action_just_pressed`) con el juego andando, y se desarma al soltarla o con el juego detenido. El mapa
  rápido se muestra mientras esté armado.
  - Depende de que `PantallaMapa` (prioridad de física 0) corra antes que el marco y la Pausa
    (`MarcoMenus.PRIORIDAD_FISICA`, 100): en el tick en que cierran, el mapa aún ve el juego detenido y se desarma.
  - La sala crea una `PantallaMapa` nueva en cada sala. Para que cruzar una puerta con LB sostenido siga mostrando el
    mapa, como antes, `_ready` arma con `is_action_pressed(&"mapa_rapido") and not get_tree().paused`. No reabre el
    fallo: con el marco o la Pausa abiertos el juego está detenido y la sala no cambia.
- **Lo cubre:** `herramientas/guiones/nucleo/marco.guion` (`prueba_marco.gd`):
  - «cerrar el marco con LB sostenido no muestra el mapa rapido»;
  - «con el mapa rapido, mapa abre el marco en Mapa y cerrarlo sin soltar LB no lo muestra»;
  - «cerrar la Pausa con mapa_rapido sostenido no muestra el mapa rapido»;
  - «tras soltar, volver a pulsar mapa_rapido si muestra el mapa rapido»;
  - «una PantallaMapa nueva, como al cruzar una puerta, con mapa_rapido sostenido lo sigue mostrando».

  Con la línea de antes fallan los tres primeros; sin el armado en `_ready`, el último. El mapa rápido de siempre
  lo sigue cubriendo `herramientas/guiones/mapa/mapa_cuentas.guion`.
