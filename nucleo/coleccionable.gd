class_name Coleccionable
extends Recogible
# El coleccionable del juego, uno solo como las larvas de Hollow Knight o las pulgas de Silksong: cada instancia de
# coleccionable.tscn lleva su id, y al tomarla se marca en su sala y se emite Eventos.coleccionable_obtenido (Partida
# autoguarda). El total se cuenta con Partida.total_coleccionables(). La escena trae el arte sin sombreado y un halo
# LuzSala que late; aqui solo flota el arte, sin _draw: no redibuja nada en cada cuadro.

## Color de un coleccionable juntado en la vitrina (VitrinaColeccionables).
const COLOR: Color = Color(0.95, 0.8, 0.3)

## Aclarado del arte (self_modulate): 1 lo deja como es. Sin HDR 2D, un modulate «overbright» no tiene efecto visible
## segun la documentacion (upgrading_to_godot_4.rst:70-71); que aclare algo en el telefono no esta comprobado.
@export_range(1.0, 1.5, 0.05) var brillo: float = 1.0
## Flotacion del arte y su halo: px hacia arriba y abajo y segundos de una vuelta.
@export var flota_px: float = 6.0
@export var flota_segundos: float = 2.0

var _segundos: float = 0.0
var _y_arte: float = 0.0

@onready var _arte: Sprite2D = $Arte as Sprite2D


func _ready() -> void:
	super()
	if is_queued_for_deletion():
		return
	_y_arte = _arte.position.y
	_arte.self_modulate = Color(brillo, brillo, brillo)
	set_process(flota_segundos > 0.0 and flota_px > 0.0)


func _process(delta: float) -> void:
	# Tiempo propio, como Planta: quieto en la pausa y en el congelado.
	if Congelado.activo():
		return
	_segundos += delta
	_arte.position.y = _y_arte + sin(_segundos * TAU / flota_segundos) * flota_px


func _al_recoger(_jugador: Jugador) -> void:
	Eventos.coleccionable_obtenido.emit(StringName(id))
