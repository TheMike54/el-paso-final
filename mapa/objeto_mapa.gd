class_name ObjetoMapa
extends Recogible
# Mapa de una zona (como los que vende Cornifer en Hollow Knight): al tocarlo, Partida.obtener_mapa lo suma y lo
# avisa (autoguarda) y el objeto desaparece; si ya se tiene, no aparece. Con la pluma_mapa, lo visitado de esa
# zona se dibuja en el siguiente descanso. Sin zona, da el de la zona de la sala donde esta. No usa id: lo recuerda
# la lista de mapas de la partida.

## Zona cuyo mapa entrega; vacia, la de la sala.
@export var zona: String = ""


func _ready() -> void:
	# La zona se resuelve antes que la base pregunte si ya se tiene.
	if zona.is_empty():
		var sala: Sala = owner as Sala
		if sala != null:
			zona = Sala.zona_de(sala.id)
	super()


func ya_recogido() -> bool:
	return Partida.mapas.has(zona)


func recordado_por_id() -> bool:
	return false


# Sin zona (fuera de una Sala con id) no hay mapa que dar: no se consume y se queda a la vista, asi el error se nota
# en la sala en vez de desaparecer sin entregar nada.
func _al_entrar(cuerpo: Node2D) -> void:
	if zona.is_empty():
		return
	super(cuerpo)


func _al_recoger(_jugador: Jugador) -> void:
	Partida.obtener_mapa(zona)
