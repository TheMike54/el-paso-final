class_name ObjetoMapa
extends Area2D
# Mapa de una zona (como los que vende Cornifer en Hollow Knight): al tocarlo, Partida.obtener_mapa lo suma y lo
# avisa (autoguarda) y el objeto desaparece; si ya se tiene, no aparece. Con la pluma_mapa, lo visitado de esa
# zona se dibuja en el siguiente descanso. Sin zona, da el de la zona de la sala donde esta.

## Zona cuyo mapa entrega; vacia, la de la sala.
@export var zona: String = ""


func _ready() -> void:
	Capas.poner(self, Capas.INTERACCION, Capas.JUGADOR)
	if zona.is_empty():
		var sala: Sala = owner as Sala
		if sala != null:
			zona = Sala.zona_de(sala.id)
	if Partida.mapas.has(zona):
		queue_free()
		return
	body_entered.connect(_al_entrar)


func _al_entrar(cuerpo: Node2D) -> void:
	if not cuerpo is Jugador or zona.is_empty() or Partida.mapas.has(zona):
		return
	Partida.obtener_mapa(zona)
	queue_free()
