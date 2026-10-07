extends Node
# Prueba de la pausa al perder el foco, sin salir de la app de verdad: pone la sala de movimiento y,
# en el cuadro cuadro_aviso, le manda al arbol el aviso que Godot da al cambiar de app o de ventana.
# El guion revisa que la pausa se abrio y el jugador se detuvo.
const SALA: PackedScene = preload("res://herramientas/salas/sala_movimiento.tscn")

## Cuadro de fisica en que se avisa que la app perdio el foco.
@export var cuadro_aviso: int = 20

var _cuadro: int = 0


func _ready() -> void:
	# Sigue contando con el juego en pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	var sala: Node = SALA.instantiate()
	# La sala si se detiene con la pausa, como cuando es la escena actual.
	sala.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(sala)


func _physics_process(_delta: float) -> void:
	_cuadro += 1
	if _cuadro == cuadro_aviso:
		get_tree().root.propagate_notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
