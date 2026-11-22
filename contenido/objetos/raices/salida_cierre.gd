extends Interactuable
# Salida de la primera version hacia la pantalla de cierre. Una Puerta solo lleva a otra sala (Sala.ruta_de) y la
# pantalla no lo es; por eso va como pieza aparte. Se usa como una puerta PUERTA (enfrente y con interactuar, con su
# aviso: la salida de raices_8).

const PANTALLA: String = "res://contenido/cierre/pantalla_cierre.tscn"
## Tamano de la puerta provisional sin arte; el color y la altura del aviso son los de Puerta.
const ANCHO: float = 120.0
const ALTO: float = 200.0

var _saliendo: bool = false


func _draw() -> void:
	dibujar_provisional(ANCHO, ALTO, Puerta.COLOR_PROVISIONAL)
	dibujar_aviso(Puerta.ALTURA_AVISO)


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
