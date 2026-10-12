extends Area2D
# Interruptor de la brujula para la zona de prueba del mapa: al entrar el jugador, equipa el amuleto brujula si
# no lo lleva o lo quita si lo lleva (en el juego se comprara y se equipara en la mochila). Asi se prueba el mapa
# con y sin el marcador del jugador.

const BRUJULA: StringName = &"brujula"


func _ready() -> void:
	body_entered.connect(_al_entrar)


func _al_entrar(cuerpo: Node2D) -> void:
	if not cuerpo is Jugador:
		return
	if not Partida.amuletos_tenidos.has(BRUJULA):
		Partida.amuletos_tenidos.append(BRUJULA)
	if Partida.amuletos_equipados.has(BRUJULA):
		Partida.amuletos_equipados.erase(BRUJULA)
	else:
		Partida.amuletos_equipados.append(BRUJULA)
