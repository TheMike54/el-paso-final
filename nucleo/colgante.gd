class_name Colgante
extends Node2D
# Algo que cuelga (cable, cadena) y se mece como un resorte alrededor de su origen, que es de donde cuelga; el dibujo
# es hijo de la escena. Si es empujable, el jugador que pasa por debajo lo empuja segun su velocidad. Va en
# _physics_process (60 ticks), asi se mece igual a 60 que a 120 FPS y se queda quieto en la pausa y el congelado.

## Grupo de los colgantes de la sala: el panel de pruebas los detiene juntos.
const GRUPO: StringName = &"colgantes_sala"

## Si el jugador lo empuja al pasar por debajo.
@export var empujable: bool = false
## Mitad del ancho, en px, en que el jugador lo empuja (centrado en el origen).
@export var ancho_empuje: float = 40.0
## Cuanto empuja el jugador: radianes por tick por cada 400 px/s de su velocidad.
@export var fuerza: float = 0.012
## Vaiven propio: amplitud en radianes y velocidad en radianes por segundo.
@export var vaiven: float = 0.02
@export var vaiven_velocidad: float = 1.3
## Resorte hacia el vaiven y freno, por tick.
@export var rigidez: float = 0.02
@export var amortiguacion: float = 0.04

# Velocidad angular, en radianes por tick.
var _velocidad: float = 0.0
var _tiempo: float = 0.0
var _jugador_dentro: bool = false
var _jugador: Node2D = null


func _ready() -> void:
	add_to_group(GRUPO)
	_tiempo = randf_range(0.0, TAU)
	# En modo bajo se queda quieto, como Planta: ni se llama a _physics_process.
	set_physics_process(not Recursos.bajos())


func _physics_process(delta: float) -> void:
	if Congelado.activo():
		return
	if empujable and not is_instance_valid(_jugador):
		_jugador = get_tree().get_first_node_in_group(Jugador.GRUPO) as Node2D
	var empuje: float = 0.0
	if empujable and is_instance_valid(_jugador):
		var dentro: bool = absf(_jugador.global_position.x - global_position.x) < ancho_empuje
		if dentro and not _jugador_dentro:
			var cuerpo: CharacterBody2D = _jugador as CharacterBody2D
			empuje = clampf(cuerpo.velocity.x / 400.0, -1.5, 1.5) * fuerza if cuerpo != null else 0.0
		_jugador_dentro = dentro
	avanzar(delta, empuje)


## Un tick: el resorte hacia el vaiven, el freno y el empuje dado (radianes por tick).
func avanzar(delta: float, empuje: float) -> void:
	_tiempo += delta
	var objetivo: float = sin(_tiempo * vaiven_velocidad) * vaiven
	_velocidad += empuje + (objetivo - rotation) * rigidez - _velocidad * amortiguacion
	rotation += _velocidad
