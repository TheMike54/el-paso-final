extends Node
# Prueba del anti-bucle de peligros y de los peligros con el jugador invulnerable: instancia la sala de
# peligro, deja al jugador quieto en suelo firme lejos de la Entrada y le manda peligros y golpes con
# recibir_dano en ticks medidos. Comprueba vidas y a donde vuelve. Deja casos y fallos para
# jugador_peligro_anti_bucle.guion. Imprime el resumen y los fallos.

const ESCENA_SALA: PackedScene = preload("res://herramientas/salas/sala_peligro.tscn")
## Lejos de la Entrada (x=200) y de la orilla del foso (x=800), sobre el suelo izquierdo.
const PUNTO_FIRME: Vector2 = Vector2(560.0, 680.0)

var casos: int = 0
var fallos: int = 0


func _ready() -> void:
	Partida.reiniciar()
	var sala: Node = ESCENA_SALA.instantiate()
	add_child(sala)
	var jugador: Jugador = get_tree().get_first_node_in_group(&"jugador") as Jugador
	var llegada: Vector2 = jugador.global_position
	var vidas: int = jugador.vidas

	# Quieto en el punto firme el tiempo de juntar sus puntos seguros.
	jugador.global_position = PUNTO_FIRME
	await _ticks(40)
	jugador.recibir_dano(1, jugador.global_position.x, true)
	await _esperar_fundido(jugador)
	_caso("un peligro quita una vida", jugador.vidas == vidas - 1)
	_caso("y vuelve al ultimo suelo firme, no a la llegada", jugador.global_position.distance_to(PUNTO_FIRME) < 1.0)

	# Antes del anti-bucle: los ticks quieto de la reaparicion mas unos pocos con control.
	await _ticks(jugador.ticks_reaparicion_peligro + 5)
	jugador.recibir_dano(1, jugador.global_position.x, true)
	await _esperar_fundido(jugador)
	_caso("un peligro antes de 0,5 s lleva a la llegada", jugador.global_position.distance_to(llegada) < 1.0)
	_caso("sin quitar vida", jugador.vidas == vidas - 1)

	# Justo despues del anti-bucle, otro peligro ya cuesta una vida y vuelve a la llegada (su nuevo punto seguro).
	await _ticks(jugador.ticks_reaparicion_peligro + 2)
	jugador.recibir_dano(1, jugador.global_position.x, true)
	await _esperar_fundido(jugador)
	_caso("tras el anti-bucle, el siguiente peligro quita vida", jugador.vidas == vidas - 2)
	_caso("y vuelve a la llegada, que paso a ser el punto seguro", jugador.global_position.distance_to(llegada) < 1.0)

	# Pasada la ventana: vuelve al punto seguro y pierde vida.
	Partida.llenar_vidas()
	jugador.global_position = PUNTO_FIRME
	# Invulnerable no junta puntos seguros: se espera a que pase y despues los ticks en el suelo.
	await _ticks(jugador.ticks_invulnerable + 40)
	jugador.recibir_dano(1, jugador.global_position.x, true)
	await _esperar_fundido(jugador)
	await _ticks(jugador.ticks_reaparicion_peligro + jugador.ticks_anti_bucle + 2)
	var antes: int = jugador.vidas
	jugador.recibir_dano(1, jugador.global_position.x, true)
	await _esperar_fundido(jugador)
	_caso("pasados 0,5 s, un peligro quita vida", jugador.vidas == antes - 1)
	_caso("y vuelve al punto seguro, no a la llegada", jugador.global_position.distance_to(llegada) > 100.0)

	# Invulnerable tras el golpe de un enemigo: el siguiente golpe no quita vida, un peligro si.
	Partida.llenar_vidas()
	await _ticks(jugador.ticks_reaparicion_peligro + jugador.ticks_invulnerable + 2)
	antes = jugador.vidas
	jugador.recibir_dano(1, jugador.global_position.x - 50.0)
	_caso("el golpe de un enemigo quita una vida y deja invulnerable", jugador.vidas == antes - 1 and jugador.invulnerable)
	jugador.recibir_dano(1, jugador.global_position.x - 50.0)
	_caso("invulnerable, otro golpe de enemigo no quita vida", jugador.vidas == antes - 1)
	jugador.recibir_dano(1, jugador.global_position.x, true)
	_caso("invulnerable, un peligro si quita vida", jugador.vidas == antes - 2)

	Partida.reiniciar()
	print("PRUEBAS peligro_anti_bucle casos=%d fallos=%d" % [casos, fallos])


# Un peligro deja al jugador quieto donde lo toco mientras la pantalla funde a negro; despues lo pone en su punto.
func _esperar_fundido(jugador: Jugador) -> void:
	while jugador._ticks_hasta_reaparecer > 0:
		await get_tree().physics_frame


func _ticks(cuantos: int) -> void:
	for i: int in range(cuantos):
		await get_tree().physics_frame


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO peligro_anti_bucle: %s" % nombre)
