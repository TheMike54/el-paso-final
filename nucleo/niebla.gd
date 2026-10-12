class_name Niebla
extends Node2D
# Niebla que se desliza: sus hijos (franjas translucidas) avanzan en x a velocidad px/s con tiempo propio y
# vuelven al llegar a recorrido, asi se queda quieta en la pausa. En modo bajo de recursos no se mueve. No
# colisiona ni tapa avisos de peligro: va en una capa de fondo o de frente con z_index.

@export var velocidad: float = 20.0
@export var recorrido: float = 400.0

var _quieta: bool = false
var _avance: float = 0.0
var _inicio: Vector2 = Vector2.ZERO


func _ready() -> void:
	_quieta = Recursos.bajos()
	_inicio = position


func _process(delta: float) -> void:
	if _quieta or recorrido <= 0.0:
		return
	_avance = fmod(_avance + velocidad * delta, recorrido)
	position = _inicio + Vector2(_avance, 0.0)
