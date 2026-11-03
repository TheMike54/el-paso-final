# Un cambio de sala fallido no avisaba y dejaba la pantalla en negro

- **Síntoma:** si la escena de destino no se podía cambiar, la puerta, la estación, la muerte y la cinemática no lo
  notaban: nadie aclaraba la pantalla ni devolvía el control. Lo encontró la auditoría leyendo el código; no se
  reprodujo en el juego.
- **Causa:** las cuatro cambiaban con `change_scene_to_file.call_deferred(...)` (la muerte, sin diferir), y una
  llamada diferida descarta el `Error` que devuelve el cambio (`classes/class_scenetree.rst:609`). Además, cada una
  tenía su propia cuenta de ticks y su propia forma de escribir la llegada.
- **Arreglo:** el `Fundido` es el único dueño del cambio. Ya en negro difiere su propio método `_cambiar`, que llama a
  `Fundido.ir_a_sala`: comprueba que la escena existe y se carga, escribe la llegada en las estáticas de `Sala`, llama
  a `change_scene_to_packed` y, si devuelve un error, lo imprime (`ERROR:`) y vuelve a dejar vacías las estáticas.
  Entonces el `Fundido` aclara la pantalla y emite `cambio_fallido`, porque `en_negro` ya salió antes del cambio
  diferido. Lo que pasa con cada uno: tras una puerta, el jugador recupera el control por su tope y la puerta vuelve a
  servir; tras una estación, que ya emitió `viaje_hecho`, la `Estacion` limpia `destino` y llama a
  `dejar_de_hablar` (el jugador de una estación no tiene tope); la muerte recarga la sala actual o la del banco, que ya
  se comprobó que existen. La cinemática usa `Fundido.ir_a_sala` desde su propio método diferido.
- **Lo cubre:** `herramientas/guiones/nucleo/transicion.guion` (un cambio a la vez, sin cambio con el jugador muerto),
  `nucleo/cambio_de_sala`, `nucleo/fundido_puerta`, `nucleo/estaciones` y `contenido/cinematica_celda`. El camino del
  error no tiene guion: imprime `ERROR:`, que hace fallar cualquier guion.
