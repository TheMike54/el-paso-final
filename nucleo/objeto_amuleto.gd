class_name ObjetoAmuleto
extends Recogible
# Objeto que entrega un amuleto: al tocarlo, el jugador lo suma a Partida, se emite Eventos.amuleto_obtenido (que
# autoguarda) y el objeto desaparece. Si la partida ya lo tiene, no aparece. Existe para premios puestos en una sala sin
# jefe ni tienda, como un cuarto oculto. No usa id: lo recuerda el amuleto.

## Id del amuleto: uno del catalogo del juego (el validador lo revisa).
@export var amuleto: StringName = &""


func ya_recogido() -> bool:
	return Partida.amuletos_tenidos.has(amuleto)


func recordado_por_id() -> bool:
	return false


func _al_recoger(_jugador: Jugador) -> void:
	Partida.obtener_amuleto(amuleto)
