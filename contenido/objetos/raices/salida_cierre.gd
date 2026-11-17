extends Interactuable
# Salida de la primera version hacia la pantalla de cierre. Una Puerta solo lleva a otra sala (Sala.ruta_de) y la
# pantalla no lo es; por eso va como pieza aparte. Se usa como una puerta PUERTA (enfrente y con interactuar, con su
# aviso: la salida de raices_8).

const PANTALLA: String = "res://contenido/cierre/pantalla_cierre.tscn"
## Puerta provisional sin arte (como COLOR_PROVISIONAL de Puerta) y altura del aviso sobre el piso.
const ANCHO: float = 120.0
const ALTO: float = 200.0
const COLOR_PROVISIONAL: Color = Color(0.6, 0.45, 0.2, 0.6)
const ALTURA_AVISO: float = 290.0

var _saliendo: bool = false


func _draw() -> void:
	dibujar_provisional(ANCHO, ALTO, COLOR_PROVISIONAL)
	dibujar_aviso(ALTURA_AVISO)


func _puede_interactuar() -> bool:
	return not _saliendo


func _al_interactuar(_jugador_encima: Jugador) -> void:
	_salir()


func _salir() -> void:
	if _saliendo:
		return
	_saliendo = true
	cerca = false
	queue_redraw()
	get_tree().change_scene_to_file.call_deferred(PANTALLA)
