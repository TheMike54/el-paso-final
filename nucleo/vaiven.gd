class_name Vaiven
extends Node2D
# Pieza que va y viene en linea recta (sierras que viajan, trampas, plataformas): recorre recorrido en
# ticks_ida ticks, vuelve y repite, y se detiene durante el congelado comun. Lo que dana dentro de ella es un
# golpe de enemigo, con retroceso, nunca un peligro de suelo seguro (como los pinchos que lanza la Radiance):
# al entrar fija peligro en falso en cada DanoContacto que lleva, y el validador lo exige en la escena.

## Desplazamiento de la ida, desde donde empieza.
@export var recorrido: Vector2 = Vector2(200.0, 0.0)
## Ticks de la ida (la vuelta tarda lo mismo).
@export var ticks_ida: int = 90

var _inicio: Vector2 = Vector2.ZERO
var _tick: int = 0


func _ready() -> void:
	_inicio = position
	for nodo: Node in find_children("*", "", true, false):
		var contacto: DanoContacto = nodo as DanoContacto
		if contacto != null:
			contacto.peligro = false


func _physics_process(_delta: float) -> void:
	if Congelado.activo() or ticks_ida <= 0:
		return
	_tick += 1
	var fase: float = float(_tick % (2 * ticks_ida)) / float(ticks_ida)
	var avance: float = fase if fase <= 1.0 else 2.0 - fase
	position = _inicio + recorrido * avance
