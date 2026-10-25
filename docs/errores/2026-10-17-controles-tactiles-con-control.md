# Los botones táctiles volvían a aparecer en cada sala aunque se jugara con el control

- **Síntoma:** en el teléfono con un control conectado, los botones táctiles se ocultaban al usar el control, pero
  volvían a dibujarse encima del juego al cruzar cada puerta, al reaparecer y al cargar una partida, hasta el
  siguiente botón del control. Lo encontró la auditoría del código (E3), no una partida.
- **Causa:** cada sala crea sus propios `ControlesTactiles`, y su `_ready` hacía
  `visible = DisplayServer.is_touchscreen_available()`: solo miraba si hay pantalla táctil, no qué se usó al último.
  La regla de ocultarse con el control vivía solo en `procesar`, por evento, y los controles nuevos nacían sin
  recordarla.
- **Arreglo:** la regla quedó en una función, `ControlesTactiles.deben_verse(tactil, con_control)`: se ven con
  pantalla táctil y con el dedo como último uso. El `_ready` la llama con `DisplayServer.is_touchscreen_available()`
  y `UltimaEntrada.con_control`; `procesar` la usa al cambiar de entrada jugando (un toque muestra, una acción del
  juego con tecla o control oculta). Nacer ocultos no suelta los dedos heredados de la sala anterior. Con el dedo y
  en la PC sin pantalla táctil nada cambia.
- **Lo cubre:** `herramientas/guiones/nucleo/controles_tactiles.guion` (`herramientas/pruebas/prueba_tactil.gd`, caso
  «con el control como ultimo uso, al entrar a una sala no se ven»; el caso anterior, con el dedo, comprueba que sí
  se ven).
