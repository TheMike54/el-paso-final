extends Node
# Prueba del aterrizaje duro: al entrar crea un jugador y comprueba, llamando a sus metodos, que el
# bloqueo empieza quieto, que lo cortan un golpe, un peligro, sentarse y morir (tambien en el mismo
# tick del aterrizaje) y que la picada no lo empieza: asi nunca deja atrapado al jugador. Deja la
# cuenta en "casos" y "fallos", que aterrizaje.guion lee. Imprime el resumen y los casos que fallan.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const PUNTO: Vector2 = Vector2(200.0, 300.0)

var casos: int = 0
var fallos: int = 0


func _ready() -> void:
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.position = PUNTO
	add_child(jugador)
	var lejos: float = PUNTO.x - 100.0

	jugador.velocity = Vector2(300.0, 0.0)
	jugador._empezar_aterrizaje_duro()
	_caso("el aterrizaje duro deja al jugador quieto y sin control", jugador.aterrizando and jugador.velocity.x == 0.0)

	jugador.recibir_dano(1, lejos)
	_caso("un golpe corta el aterrizaje duro", not jugador.aterrizando)

	jugador._ticks_sin_dano = 0
	jugador.global_position = PUNTO + Vector2(300.0, 0.0)
	jugador._empezar_aterrizaje_duro()
	jugador.recibir_dano(1, lejos, true)
	_esperar_fundido(jugador)
	_caso("un peligro corta el aterrizaje duro y lo devuelve al punto seguro", not jugador.aterrizando and jugador.global_position == PUNTO)

	# Ya con control: un peligro durante la reaparicion no cuenta. Aqui la llegada y el punto seguro son PUNTO: el
	# destino del anti-bucle lo prueba jugador_peligro_anti_bucle_contacto.guion.
	jugador._ticks_congelado = 0
	jugador._reapareciendo = false
	jugador._empezar_aterrizaje_duro()
	_caso("invulnerable, un peligro igual corta el aterrizaje duro", jugador.invulnerable)
	jugador.recibir_dano(1, lejos, true)
	_esperar_fundido(jugador)
	_caso("y corta el aterrizaje duro tambien por el anti-bucle", not jugador.aterrizando and jugador.global_position == PUNTO)

	jugador._empezar_aterrizaje_duro()
	jugador.sentarse(PUNTO.x)
	_caso("sentarse corta el aterrizaje duro", not jugador.aterrizando and jugador.descansando)

	# El mismo tick del aterrizaje, en el orden del arbol: el golpe o el banco van antes que el jugador.
	jugador.descansando = false
	jugador._ticks_sin_dano = 0
	_preparar_aterrizaje(jugador)
	jugador.recibir_dano(1, lejos)
	jugador._aterrizar(true)
	_caso("un golpe del mismo tick no deja empezar el aterrizaje duro", not jugador.aterrizando and jugador._ticks_retrocediendo > 0)

	jugador._ticks_retrocediendo = 0
	jugador._ticks_congelado = 0
	_preparar_aterrizaje(jugador)
	jugador.sentarse(PUNTO.x)
	jugador._aterrizar(true)
	_caso("sentarse en el mismo tick no deja empezar el aterrizaje duro", not jugador.aterrizando)

	jugador.descansando = false
	_preparar_aterrizaje(jugador)
	jugador.en_picada = true
	jugador._aterrizar(true)
	_caso("una picada que toca el suelo en su primer tick no deja sin control", not jugador.aterrizando)
	jugador.en_picada = false

	jugador._ticks_sin_dano = 0
	Partida.vidas = 1
	jugador._empezar_aterrizaje_duro()
	jugador.recibir_dano(1, lejos)
	_caso("morir corta el aterrizaje duro", jugador.muerto and not jugador.aterrizando)

	jugador.free()
	Partida.llenar_vidas()
	print("PRUEBAS aterrizaje casos=%d fallos=%d" % [casos, fallos])


# Un peligro deja al jugador quieto donde lo toco mientras la pantalla funde a negro: los ticks del fundido
# pasan por _mover, que al final lo pone en el punto seguro.
func _esperar_fundido(jugador: Jugador) -> void:
	while jugador._ticks_hasta_reaparecer > 0:
		jugador._mover(1.0 / 60.0)


# Deja al jugador como en el tick en que toca el suelo tras una caida larga.
func _preparar_aterrizaje(jugador: Jugador) -> void:
	jugador._en_suelo_antes = false
	jugador._ticks_a_tope = jugador.ticks_caida_dura
	jugador._ticks_temblando = 0


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO aterrizaje: %s" % nombre)
