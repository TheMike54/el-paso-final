class_name ObjetoHabilidad
extends Area2D
# Objeto que entrega una habilidad: al tocarlo, el jugador la suma a Partida, se emite
# Eventos.habilidad_obtenida (que autoguarda) y el objeto desaparece. Si la partida ya la tiene, no aparece. Lo usan
# las salas de prueba de cada habilidad; en el juego lo daran los jefes.

## Id de la habilidad: una de Habilidades.TODAS (el validador lo revisa).
@export var habilidad: StringName = &""


func _ready() -> void:
	Capas.poner(self, Capas.INTERACCION, Capas.JUGADOR)
	if Partida.tiene(habilidad):
		queue_free()
		return
	body_entered.connect(_al_entrar)


func _al_entrar(cuerpo: Node2D) -> void:
	if not cuerpo is Jugador or Partida.tiene(habilidad):
		return
	Partida.obtener_habilidad(habilidad)
	queue_free()
