class_name Golpeable
extends Area2D
# Componente de lo que el ataque del jugador puede golpear (enemigos, objetos que se rompen).
# Va como hijo del nodo golpeable, con su forma; cuenta los golpes, empuja un poco a su padre
# lejos del atacante y avisa con la senal golpeado (con el dano, para quien lleve la vida) y con
# Eventos.enemigo_golpeado. Lo golpean el ataque del jugador y el proyectil.

signal golpeado(atacante: Node2D, dano: int)

## Velocidad con que el padre sale empujado al recibir un golpe, en px/s. 0: no se mueve.
@export var velocidad_retroceso: float = 240.0
## Ticks que dura ese empuje.
@export var ticks_retroceso: int = 6

## Golpes recibidos desde que entro a la sala, y el dano que sumaron.
var golpes: int = 0
var dano_recibido: int = 0

var _ticks_empujado: int = 0
var _sentido: float = 0.0


func recibir_golpe(atacante: Node2D, dano: int = 1) -> void:
	golpes += 1
	dano_recibido += dano
	var padre: Node2D = get_parent() as Node2D
	if padre != null and velocidad_retroceso > 0.0:
		var lado: float = signf(padre.global_position.x - atacante.global_position.x)
		# Golpeado justo desde arriba (pogo): no se sabe hacia donde empujarlo, y no se empuja.
		_sentido = lado
		_ticks_empujado = ticks_retroceso if lado != 0.0 else 0
	golpeado.emit(atacante, dano)
	Eventos.enemigo_golpeado.emit(get_parent())


func _physics_process(delta: float) -> void:
	if _ticks_empujado == 0:
		return
	_ticks_empujado -= 1
	var padre: Node2D = get_parent() as Node2D
	padre.position.x += _sentido * velocidad_retroceso * delta
