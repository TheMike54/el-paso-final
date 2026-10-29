class_name ObjetoHabilidad
extends Recogible
# Objeto que entrega una habilidad: al tocarlo, el jugador la suma a Partida, se emite
# Eventos.habilidad_obtenida (que autoguarda) y el objeto desaparece. Si la partida ya la tiene, no aparece. Lo usan
# las salas de prueba de cada habilidad; en el juego lo daran los jefes. No usa id: lo recuerda la habilidad.

## Id de la habilidad: una de Habilidades.TODAS (el validador lo revisa).
@export var habilidad: StringName = &""


func ya_recogido() -> bool:
	return Partida.tiene(habilidad)


func recordado_por_id() -> bool:
	return false


func _al_recoger(_jugador: Jugador) -> void:
	Partida.obtener_habilidad(habilidad)
