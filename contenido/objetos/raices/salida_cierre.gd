extends Area2D
# Salida de la primera version: al cruzarla, el jugador pasa a la pantalla de cierre. Una Puerta solo lleva a otra
# sala (Sala.ruta_de), y la pantalla no lo es; por eso va como pieza aparte, pegada a la pared del final de raices_7.
# Cuando exista raices_8, raices_7 cambia esta pieza por su puerta derecha y raices_8 la usa en su salida.

const PANTALLA: String = "res://contenido/cierre/pantalla_cierre.tscn"

var _saliendo: bool = false


func _ready() -> void:
	Capas.poner(self, Capas.INTERACCION, Capas.JUGADOR)
	body_entered.connect(_al_entrar)


# Llega dentro de una senal de fisica: el cambio de escena se pide diferido.
func _al_entrar(cuerpo: Node2D) -> void:
	var jugador: Jugador = cuerpo as Jugador
	if jugador == null or jugador.muerto or _saliendo:
		return
	_saliendo = true
	get_tree().change_scene_to_file.call_deferred(PANTALLA)
