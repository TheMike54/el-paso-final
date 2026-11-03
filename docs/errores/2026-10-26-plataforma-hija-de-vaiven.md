# La plataforma avanzaba y el jugador se quedaba

- **Síntoma:** una plataforma armada como un nodo `Vaiven` con un `AnimatableBody2D` hijo iba y venía, pero el
  jugador parado encima no se movía con ella: se quedaba en su sitio hasta que la plataforma se le salía de debajo y
  caía. Visto el 26-oct-2026.
- **Causa:** el `Vaiven` mueve su propia `position`; el cuerpo hijo cambia de lugar solo porque cambia su padre. El
  motor estima la velocidad de un `AnimatableBody2D` cuando el cuerpo mismo se mueve, y con esa velocidad empuja y
  lleva a lo que toca (`classes/class_animatablebody2d.rst:22-24`). Movido a través del padre, no llevó al jugador.
  Medido en headless el 27-oct-2026: en 60 ticks el cuerpo hijo avanzó 150 px y el jugador encima, 0. La misma
  plataforma con el `Vaiven` puesto en el `AnimatableBody2D` mismo avanzó 260 px y llevó al jugador 256.
- **Arreglo:** la pieza que lleva al jugador es ella misma el `AnimatableBody2D` con el script `Vaiven`, que además la
  pone en `ESCENARIO` sin máscara. El validador falla con cualquier cuerpo de física dentro de un `Vaiven` o un
  `Giro` que no sea el nodo mismo (`_revisar_cuerpos_moviles` en `herramientas/validar.gd`); las `Area2D` que dañan
  sí van dentro.
- **Lo cubre:** `herramientas/guiones/nucleo/plataformas.guion` (el cuerpo hijo no lleva al jugador y el armado bueno
  sí) y `herramientas/guiones/herramientas/validador.guion` (un cuerpo dentro de un `Vaiven` falla; el
  `AnimatableBody2D` que es el `Vaiven` no).
