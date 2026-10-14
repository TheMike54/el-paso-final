extends Node
# Medidor del jalon de camara al caer: cada tick calcula la velocidad del jugador en pantalla
# (la suya menos la de la camara) y, mientras cae, el mayor aumento de un tick al siguiente. Si la
# camara se frena en su limite antes del aterrizaje, el jugador se acelera de golpe en pantalla.
# Al aterrizar deja en "casos" y "fallos" el resultado para camara_caida.guion.

## Vista del telefono de prueba (Galaxy S20, 20:9). Sin pantalla la ventana mide 64x64 y la
## vista sale de 1280x1280: la camara no llegaria a su limite como en el telefono.
const VISTA_SIN_PANTALLA: Vector2i = Vector2i(1600, 720)

## Aumento maximo de la velocidad en pantalla entre dos ticks de caida, en px/s por tick.
@export var umbral: float = 100.0
## Ticks en el aire a partir de los cuales un aterrizaje cuenta como caida.
@export var ticks_minimos_de_caida: int = 30

var casos: int = 0
var fallos: int = 0
## Mayor aumento de la velocidad en pantalla desde que empezo la sala (no se reinicia entre caidas),
## en px/s por tick.
var mayor_tiron: float = 0.0

var _jugador: CharacterBody2D = null
var _camara: Camera2D = null
var _en_pantalla_antes: float = 0.0
var _velocidad_antes: float = 0.0
var _ticks_en_el_aire: int = 0


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		get_tree().root.size = VISTA_SIN_PANTALLA


# Corre antes que el jugador (esta antes en el arbol): lee la posicion y la camara del tick anterior.
func _physics_process(_delta: float) -> void:
	if _jugador == null:
		_jugador = get_tree().get_first_node_in_group(Jugador.GRUPO) as CharacterBody2D
		if _jugador == null:
			return
		_camara = _jugador.get_node_or_null(^"Camara") as Camera2D
		_en_pantalla_antes = _en_pantalla()
		return
	var en_pantalla: float = _en_pantalla()
	var velocidad: float = (en_pantalla - _en_pantalla_antes) * Engine.physics_ticks_per_second
	if _jugador.is_on_floor():
		if _ticks_en_el_aire >= ticks_minimos_de_caida:
			_contar_caida()
		_ticks_en_el_aire = 0
	else:
		_ticks_en_el_aire += 1
		if _ticks_en_el_aire >= 2:
			mayor_tiron = maxf(mayor_tiron, velocidad - _velocidad_antes)
	_en_pantalla_antes = en_pantalla
	_velocidad_antes = velocidad


func _en_pantalla() -> float:
	var centro: float = _camara.get_screen_center_position().y if _camara != null else 0.0
	return _jugador.global_position.y - centro


func _contar_caida() -> void:
	casos += 1
	if mayor_tiron > umbral:
		fallos += 1
		print("FALLO camara_caida: la velocidad en pantalla subio %.0f px/s en un tick (umbral %.0f)" % [mayor_tiron, umbral])
