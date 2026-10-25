extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del aterrizaje duro: al entrar crea un jugador por caso y comprueba que el bloqueo empieza quieto, que lo
# cortan un golpe, un peligro, sentarse y morir (tambien en el mismo tick del aterrizaje) y que la picada no lo
# empieza: asi nunca deja atrapado al jugador. Deja la cuenta en "casos" y "fallos", que aterrizaje.guion lee.
# Imprime el resumen y los casos que fallan.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const PUNTO: Vector2 = Vector2(200.0, 300.0)

# Lo unico que se toca por dentro es la pieza bajo prueba: _empezar_aterrizaje_duro() y _aterrizar() (con
# _en_suelo_antes y _ticks_a_tope, el estado que leen) son el aterrizaje duro, y llegar a ellos con una caida
# real no deja poner un golpe o un banco en el mismo tick. Lo demas se lee o se deja por lo publico.


func _ready() -> void:
	# _ready corre fuera de un tick: tras esta espera, cada _esperar(n) cubre n ticks enteros del jugador (sin
	# ella, el primer fundido terminaba un tick antes).
	await get_tree().physics_frame
	var lejos: float = PUNTO.x - 100.0

	var jugador: Jugador = _jugador_nuevo(null)
	jugador.velocity = Vector2(300.0, 0.0)
	jugador._empezar_aterrizaje_duro()
	_caso("el aterrizaje duro deja al jugador quieto y sin control", jugador.aterrizando and jugador.velocity.x == 0.0)

	jugador.recibir_dano(1, lejos)
	_caso("un golpe corta el aterrizaje duro", not jugador.aterrizando)

	jugador = _jugador_nuevo(jugador)
	jugador.global_position = PUNTO + Vector2(300.0, 0.0)
	jugador._empezar_aterrizaje_duro()
	jugador.recibir_dano(1, lejos, true)
	await _esperar_fundido()
	_caso("un peligro corta el aterrizaje duro y lo devuelve al punto seguro", not jugador.aterrizando and jugador.global_position == PUNTO)

	# Ya con control: un peligro durante la reaparicion no cuenta. Aqui la llegada y el punto seguro son PUNTO: el
	# destino del anti-bucle lo prueba jugador_peligro_anti_bucle_contacto.guion.
	await _esperar(jugador.ticks_reaparicion_peligro + 2)
	jugador._empezar_aterrizaje_duro()
	_caso("invulnerable, un peligro igual corta el aterrizaje duro", jugador.invulnerable)
	jugador.recibir_dano(1, lejos, true)
	await _esperar_fundido()
	_caso("y corta el aterrizaje duro tambien por el anti-bucle", not jugador.aterrizando and jugador.global_position == PUNTO)

	jugador = _jugador_nuevo(jugador)
	jugador._empezar_aterrizaje_duro()
	jugador.sentarse(PUNTO.x)
	_caso("sentarse corta el aterrizaje duro", not jugador.aterrizando and jugador.descansando)

	# El mismo tick del aterrizaje, en el orden del arbol: el golpe o el banco van antes que el jugador. El
	# retroceso del golpe empieza subiendo (velocity.y = -retroceso.y): asi se ve que el golpe si entro.
	jugador = _jugador_nuevo(jugador)
	_preparar_aterrizaje(jugador)
	jugador.recibir_dano(1, lejos)
	jugador._aterrizar(true)
	_caso("un golpe del mismo tick no deja empezar el aterrizaje duro", not jugador.aterrizando and jugador.velocity.y < 0.0)

	jugador = _jugador_nuevo(jugador)
	_preparar_aterrizaje(jugador)
	jugador.sentarse(PUNTO.x)
	jugador._aterrizar(true)
	_caso("sentarse en el mismo tick no deja empezar el aterrizaje duro", not jugador.aterrizando)

	jugador = _jugador_nuevo(jugador)
	_preparar_aterrizaje(jugador)
	jugador.en_picada = true
	jugador._aterrizar(true)
	_caso("una picada que toca el suelo en su primer tick no deja sin control", not jugador.aterrizando)

	jugador = _jugador_nuevo(jugador)
	Partida.vidas = 1
	jugador._empezar_aterrizaje_duro()
	jugador.recibir_dano(1, lejos)
	_caso("morir corta el aterrizaje duro", jugador.muerto and not jugador.aterrizando)

	jugador.free()
	Partida.llenar_vidas()
	Congelado.reiniciar()
	_resumen()


# Cada caso empieza con un jugador sin nada a medias (sin invulnerabilidad, retroceso ni reaparicion), con las
# vidas llenas y sin el congelado de un golpe anterior. Libera el del caso anterior.
func _jugador_nuevo(anterior: Jugador) -> Jugador:
	if anterior != null:
		anterior.free()
	Partida.llenar_vidas()
	Congelado.reiniciar()
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.position = PUNTO
	add_child(jugador)
	return jugador


# Un peligro deja al jugador quieto donde lo toco mientras la pantalla funde a negro y, ya en negro, lo pone en el
# punto seguro: Fundido.TICKS_OSCURECER + Fundido.TICKS_EN_NEGRO_PELIGRO ticks del jugador.
func _esperar_fundido() -> void:
	await _esperar(Fundido.TICKS_OSCURECER + Fundido.TICKS_EN_NEGRO_PELIGRO)


# Deja al jugador como en el tick en que toca el suelo tras una caida larga.
func _preparar_aterrizaje(jugador: Jugador) -> void:
	jugador._en_suelo_antes = false
	jugador._ticks_a_tope = jugador.ticks_caida_dura
