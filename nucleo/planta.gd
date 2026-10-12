class_name Planta
extends Node2D
# Planta que se mece: rota de un lado a otro con un tiempo propio que avanza en _process, asi se queda quieta
# en la pausa (el arbol pausado no llama _process; el TIME de un shader si avanzaria). En modo bajo de
# recursos no se mece. Generica: el dibujo es hijo de la escena; el pivote son los pies de la planta.

## Grados hacia cada lado y segundos de una ida y vuelta.
@export var grados: float = 6.0
@export var periodo: float = 2.4
## Desfase en segundos, para que las plantas de una sala no se muevan iguales.
@export var desfase: float = 0.0

## Segundos de vaiven acumulados (publico para la prueba).
var tiempo: float = 0.0
var _quieta: bool = false


func _ready() -> void:
	_quieta = Recursos.bajos()
	tiempo = desfase
	# Quieta no hace nada cada cuadro: ni se llama a _process.
	set_process(not _quieta)


func _process(delta: float) -> void:
	if _quieta or periodo <= 0.0:
		return
	tiempo += delta
	rotation_degrees = sin(tiempo * TAU / periodo) * grados
