extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de los ganchos de ComportamientoEnemigo para las mecanicas nuevas: un golpe bloqueado (escudo de frente) no
# hace dano ni cuenta como golpe a enemigo, y por la espalda si; jugador_lo_mira sigue la mirada del jugador; flotar
# apaga la gravedad y la devuelve. Usa la sala de enemigos con el fuerte cambiado a una copia de su ficha con el
# comportamiento de escudo de prueba y gravedad. Deja casos y fallos para enemigo_enganches.guion.

const SALA: String = "res://herramientas/salas/sala_enemigos.tscn"
const ESCUDO: String = "res://herramientas/pruebas/comportamiento_escudo_prueba.gd"

var _objetos_golpeados: int = 0
var _enemigos_golpeados: int = 0


func _ready() -> void:
	_aislar_partida()
	Eventos.objeto_golpeado.connect(func(_objeto: Node) -> void: _objetos_golpeados += 1)
	Eventos.enemigo_golpeado.connect(func(_enemigo: Node) -> void: _enemigos_golpeados += 1)
	var ficha: FichaEnemigo = (load("res://herramientas/salas/fichas/enemigo_fuerte.tres") as FichaEnemigo).duplicate() as FichaEnemigo
	ficha.comportamiento = load(ESCUDO) as GDScript
	ficha.gravedad = 3000.0
	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	(sala.get_node(^"Fuerte") as Enemigo).ficha = ficha
	add_child(sala)
	await _esperar(3)
	var jugador: Jugador = get_tree().get_first_node_in_group(&"jugador") as Jugador
	var fuerte: Enemigo = sala.get_node(^"Fuerte") as Enemigo
	var comportamiento: ComportamientoEnemigo = fuerte.get_node(^"Comportamiento") as ComportamientoEnemigo
	var vida: int = fuerte.vida

	# El fuerte mira a la izquierda; el jugador entra por la izquierda: de frente.
	jugador.global_position = Vector2(900.0, 680.0)
	var conto: bool = fuerte.golpeable.recibir_golpe(jugador, 1)
	_caso("de frente el escudo bloquea: sin dano y sin contar", not conto and fuerte.vida == vida
			and fuerte.golpeable.golpes == 0)
	_caso("el golpe bloqueado avisa como objeto, no como enemigo", _objetos_golpeados == 1 and _enemigos_golpeados == 0)
	jugador.global_position = Vector2(1300.0, 680.0)
	conto = fuerte.golpeable.recibir_golpe(jugador, 1)
	_caso("por la espalda el golpe entra", conto and fuerte.vida == vida - 1 and _enemigos_golpeados == 1)
	await _esperar(10)

	# Con el ataque de verdad del jugador: de frente, sin Inspiracion, sin empuje y con la senal bloqueado; por la
	# espalda, con Inspiracion.
	var bloqueos: Array[int] = [0]
	fuerte.golpeable.bloqueado.connect(func(_atacante: Node2D) -> void: bloqueos[0] += 1)
	var x_fuerte: float = fuerte.global_position.x
	jugador.global_position = Vector2(x_fuerte - 90.0, 680.0)
	jugador.velocity = Vector2.ZERO
	jugador._mirando = 1.0
	Partida.inspiracion = 0
	await _presionar(&"atacar")
	await _esperar(12)
	_caso("el ataque bloqueado no da Inspiracion, no empuja y avisa bloqueado", Partida.inspiracion == 0
			and bloqueos[0] == 1 and is_equal_approx(fuerte.global_position.x, x_fuerte) and fuerte.vida == vida - 1)
	jugador.global_position = Vector2(x_fuerte + 90.0, 680.0)
	jugador.velocity = Vector2.ZERO
	jugador._mirando = -1.0
	await _esperar(20)
	await _presionar(&"atacar")
	await _esperar(12)
	_caso("el ataque por la espalda da Inspiracion", Partida.inspiracion > 0 and fuerte.vida == vida - 2)

	# A la derecha del fuerte: mirar a la izquierda es mirarlo.
	jugador.global_position = Vector2(1300.0, 680.0)
	jugador._mirando = -1.0
	var lo_mira: bool = comportamiento.jugador_lo_mira()
	jugador._mirando = 1.0
	_caso("jugador_lo_mira sigue hacia donde mira el jugador", lo_mira and not comportamiento.jugador_lo_mira())

	comportamiento.flotar(true)
	fuerte.velocity = Vector2.ZERO
	comportamiento.caer()
	_caso("flotando no cae y el cuerpo flota", fuerte.velocity.y == 0.0
			and fuerte.motion_mode == CharacterBody2D.MOTION_MODE_FLOATING)
	comportamiento.flotar(false)
	comportamiento.caer()
	_caso("sin flotar vuelve la gravedad de la ficha", fuerte.velocity.y > 0.0
			and fuerte.motion_mode == CharacterBody2D.MOTION_MODE_GROUNDED)

	sala.queue_free()
	_restaurar_partida()
	_resumen()
