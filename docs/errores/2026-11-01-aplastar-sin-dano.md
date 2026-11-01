# La pieza sólida hundía al jugador en el suelo y lo sacaba encima

**Síntoma.** Quedarse debajo del elevador de la sala Plataformas o de la raíz de `celda_4` no hacía nada: la pieza lo
hundía hasta 91 px en el suelo y la física lo sacaba encima o a un lado, sin daño. Lo reportó el QA del teléfono.

**Causa.** Un `AnimatableBody2D` no reacciona a los choques y empuja lo que tiene en su camino
(`classes/class_animatablebody2d.rst:22-24`), y nada en el juego trataba el aplastamiento: se había dado por bueno
porque no dejaba atrapado al jugador.

**Arreglo.** `DanoContacto.aplastador`: una zona fija con `peligro = true` en el extremo del recorrido, que solo daña al
que está en el suelo mientras `Vaiven.aplasta` dice que la pieza viene hacia ella y lo alcanza. Dentro de la zona no se
recuerda punto seguro: reaparecer bajo la pieza repetía el síntoma, y en `celda_4` lo hundía en el piso o lo sacaba por
la puerta de abajo. Regla en `docs/componentes.md`, fila de `DanoContacto`.

**Guion.** `nucleo/plataformas` (los casos «aplastar») y `contenido/celda_4_raiz`.
