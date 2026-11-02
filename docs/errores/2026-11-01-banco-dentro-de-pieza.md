# Un banco dentro de una pieza guardaba la ruta de la pieza

**Síntoma.** Descansar en un banco colgado de una pieza dejaba `sala_guardada=res://una_pieza.tscn` (reproducido el 1-nov-2026): la partida no podía volver a la sala.

**Causa.** `Banco` tomaba la clave de la escena de su padre (`get_parent()`) y `Sala` solo buscaba bancos entre sus hijos.

**Arreglo.** `Banco` usa `Sala.clave_de(self)`, que sube hasta la sala, y `Sala._bancos()` y el validador los buscan a cualquier profundidad.

**Guion.** `nucleo/muro_rompible`, casos del banco dentro de una pieza; `herramientas/validador`, «sala: banco dentro de una pieza con id ajeno falla».
