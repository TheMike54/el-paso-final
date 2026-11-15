extends Interactuable
# Salida de la primera version hacia la pantalla de cierre. Una Puerta solo lleva a otra sala (Sala.ruta_de) y la
# pantalla no lo es; por eso va como pieza aparte. Con con_interactuar se usa como una puerta PUERTA (enfrente y con
# interactuar, con su aviso: la salida de raices_8); sin el, se cruza al entrar en su area, como una LADO.

const PANTALLA: String = "res://contenido/cierre/pantalla_cierre.tscn"
## Puerta provisional sin arte (como COLOR_PROVISIONAL de Puerta) y altura del aviso sobre el piso.
const ANCHO: float = 120.0
const ALTO: float = 200.0
const COLOR_PROVISIONAL: Color = Color(0.6, 0.45, 0.2, 0.6)
const ALTURA_AVISO: float = 290.0

## Verdadero: se usa con interactuar estando enfrente. Falso: se cruza al entrar.
@export var con_interactuar: bool = false

var _saliendo: bool = false


func _ready() -> void:
	super()
	if not con_interactuar:
		body_entered.connect(_al_entrar)
		set_physics_process(false)


func _draw() -> void:
	if con_interactuar:
		dibujar_provisional(ANCHO, ALTO, COLOR_PROVISIONAL)
		dibujar_aviso(ALTURA_AVISO)


func _puede_interactuar() -> bool:
	return con_interactuar and not _saliendo


func _al_interactuar(_jugador_encima: Jugador) -> void:
	_salir()


# Llega dentro de una senal de fisica: el cambio de escena se pide diferido.
func _al_entrar(cuerpo: Node2D) -> void:
	var jugador: Jugador = cuerpo as Jugador
	if jugador == null or jugador.muerto:
		return
	_salir()


func _salir() -> void:
	if _saliendo:
		return
	_saliendo = true
	cerca = false
	queue_redraw()
	get_tree().change_scene_to_file.call_deferred(PANTALLA)
