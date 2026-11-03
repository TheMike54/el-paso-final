# Un enemigo dentro de una pieza se recordaba en la pieza y no en la sala

**Síntoma.** Vencer a un enemigo fuerte colgado de una pieza instanciada guardaba `res://pieza_de_prueba.tscn#en_pieza` en lugar de `<sala>#en_pieza` (reproducido el 1-nov-2026): dos salas con la misma pieza compartirían lo vencido.

**Causa.** `Enemigo.clave()` miraba solo el `owner`, que dentro de una pieza es la raíz de la pieza (`classes/class_node.rst`), mientras que su botín ya usaba `Sala.clave_de`.

**Arreglo.** `Enemigo.clave()` usa `Sala.clave_de(self)`, que sube hasta la sala.

**Guion.** `nucleo/enemigo_botin`, casos «dentro de una pieza su clave es la de la sala» y «y queda vencido en la sala, no en la pieza».
