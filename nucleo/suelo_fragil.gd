class_name SueloFragil
extends StaticBody2D
# Suelo que rompe la caida en picada: se pisa y se camina como cualquier solido, pero el jugador en
# picada que lo toca lo rompe y sigue cayendo. Va en la sala con su forma y su dibujo, como un
# solido. Que siga roto al volver a la sala todavia no se guarda.

## Ya se rompio: desaparece al terminar el cuadro.
var roto: bool = false


func romper() -> void:
	if roto:
		return
	roto = true
	queue_free()
