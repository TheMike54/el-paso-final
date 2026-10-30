# Recorre la sala jugable de equipo y toma su entrega con la accion interactuar.
# Comprueba los seis premios reales, el banco y que repetir o volver no duplica el lote.
# Aisla el guardado para que esta prueba no escriba sobre una partida de juego.
extends "res://herramientas/pruebas/prueba_base.gd"

const ESCENA: PackedScene = preload("res://herramientas/salas/sala_equipo.tscn")
const AMULETOS: Array[StringName] = [
	&"amuleto_prueba", &"amuleto_velocidad", &"amuleto_escudo",
	&"amuleto_inspiracion", &"amuleto_botin",
]


func _ready() -> void:
	_aislar_partida("user://prueba_sala_equipo.json")
	var sala: Sala = ESCENA.instantiate() as Sala
	add_child(sala)
	await _esperar(30)
	_caso("entra con pluma y sin equipo regalado automaticamente", Partida.tiene(Habilidades.PLUMA)
			and Partida.amuletos_tenidos.is_empty() and Partida.utiles_tenidos.is_empty())
	Input.action_press(&"mover_derecha")
	await _esperar(25)
	Input.action_release(&"mover_derecha")
	await _esperar(3)
	await _presionar(&"interactuar")
	var entrega: EntregaRecompensas = sala.get_node(^"Entrega") as EntregaRecompensas
	_caso("interactuar entrega los seis premios", entrega.entregadas == 6)
	for amuleto: StringName in AMULETOS:
		_caso("tiene " + String(amuleto), Partida.amuletos_tenidos.has(amuleto))
	_caso("tiene la brujula como unico util", Partida.utiles_tenidos == [&"brujula"])
	_caso("conserva carga inicial y nada se equipa solo", Partida.carga_maxima == 3
			and Partida.amuletos_tenidos.size() == 5 and Partida.amuletos_equipados.is_empty()
			and Partida.utiles_equipados.is_empty())
	var guardados: int = Partida.autoguardados
	await _presionar(&"interactuar")
	_caso("repetir no entrega ni autoguarda otra vez", entrega.entregadas == 6
			and Partida.autoguardados == guardados)
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	jugador.global_position = Vector2(850.0, 680.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(3)
	await _presionar(&"interactuar")
	_caso("el banco permite sentarse y guarda su id", jugador.descansando and Partida.banco == "banco_equipo")
	var enemigo: Enemigo = sala.get_node(^"Caminante") as Enemigo
	_caso("hay un enemigo con botin y varios golpes de vida", enemigo.ficha.botin == 10 and enemigo.ficha.vida == 6)
	sala.free()
	sala = ESCENA.instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	entrega = sala.get_node(^"Entrega") as EntregaRecompensas
	_caso("volver conserva la marca y no repite el lote", entrega.entregar() == 0
			and Partida.amuletos_tenidos.size() == 5 and Partida.utiles_tenidos.size() == 1)
	sala.free()
	_restaurar_partida()
	_resumen()
