class_name SueloFragil
extends StaticBody2D
# Suelo que rompe la caida en picada: se pisa y se camina como cualquier solido, pero el jugador en
# picada que lo toca lo rompe y sigue cayendo. Va en la sala con su forma y su dibujo, como un
# solido. Con id, se queda roto: se marca en el estado de su sala y no vuelve al entrar (como Hollow
# Knight). Sin id (salas de prueba sueltas), vuelve cada vez.

## Id unico dentro de la sala; lo exige el validador en las salas con id.
@export var id: String = ""

## Ya se rompio: desaparece al terminar el cuadro.
var roto: bool = false


func _ready() -> void:
	if not id.is_empty() and Partida.estado_de(Sala.clave_de(self), id) != null:
		roto = true
		queue_free()


func romper() -> void:
	if roto:
		return
	roto = true
	if not id.is_empty():
		Partida.marcar(Sala.clave_de(self), id)
	queue_free()
