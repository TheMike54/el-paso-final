class_name Niebla
extends Node2D
# Niebla que se desliza: sus hijos (franjas translucidas) avanzan en x a velocidad px/s con tiempo propio y
# vuelven al llegar a recorrido, asi se queda quieta en la pausa y en el congelado comun. En modo bajo de
# recursos no se mueve. No colisiona ni tapa avisos de peligro: va en una capa de fondo o de frente con z_index.

## Velocidad de las franjas, en px/s.
@export var velocidad: float = 20.0
## Distancia, en px, tras la que cada franja vuelve a su lugar.
@export var recorrido: float = 400.0

var _quieta: bool = false
var _avance: float = 0.0
var _inicio: Vector2 = Vector2.ZERO


func _ready() -> void:
	_quieta = Recursos.bajos()
	_inicio = position
	# Quieta no hace nada cada cuadro: ni se llama a _process.
	set_process(not _quieta)


func _process(delta: float) -> void:
	if _quieta or recorrido <= 0.0 or Congelado.activo():
		return
	_avance = fmod(_avance + velocidad * delta, recorrido)
	position = _inicio + Vector2(_avance, 0.0)
