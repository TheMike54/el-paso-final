extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del botin de un enemigo (FichaEnemigo.botin): al vencerlo salta un MonedasSueltas que cae al suelo, tomarlo
# suma sus PejeCoins y lo marca, y el mismo ejemplar ya no vuelve a soltarlo al volver a la sala; una ficha sin botin
# no suelta nada. Usa la sala de enemigos con una copia de la ficha del debil con botin (la ficha es de solo lectura).
# Deja casos y fallos para enemigo_botin.guion.

const SALA: String = "res://herramientas/salas/sala_enemigos.tscn"
const ENEMIGO: String = "res://nucleo/enemigo.tscn"
const BOLA: String = "res://nucleo/proyectil.tscn"
const BOTIN: int = 7
## Parte de arriba del suelo de la sala de enemigos.
const SUELO_Y: float = 680.0

var _ficha_con_botin: FichaEnemigo = null


func _ready() -> void:
	_aislar_partida()
	_ficha_con_botin = (load("res://herramientas/salas/fichas/enemigo_debil.tres") as FichaEnemigo).duplicate() as FichaEnemigo
	_ficha_con_botin.botin = BOTIN
	var sala: Sala = await _crear_sala()
	var jugador: Jugador = get_tree().get_first_node_in_group(&"jugador") as Jugador
	var clave: String = sala.clave()

	var debil: Enemigo = sala.get_node(^"Debil") as Enemigo
	debil.golpeable.recibir_golpe(jugador, debil.vida)
	await _esperar(1)
	var monedas: MonedasSueltas = sala.get_node_or_null(^"botin_debil") as MonedasSueltas
	_caso("al vencerlo suelta su botin en la sala", monedas != null and monedas.cantidad == BOTIN)
	var y_al_soltar: float = monedas.global_position.y if monedas != null else 0.0
	await _esperar(8)
	_caso("el botin sube primero", monedas != null and monedas.global_position.y < y_al_soltar)
	await _esperar(40)
	_caso("y cae al suelo bajo el enemigo", monedas != null and is_equal_approx(monedas.global_position.y, SUELO_Y)
			and is_equal_approx(monedas.global_position.x, 700.0))

	var antes: int = Partida.monedas
	jugador.global_position = Vector2(700.0, SUELO_Y)
	jugador.velocity = Vector2.ZERO
	await _esperar(3)
	_caso("tomarlo suma sus PejeCoins y lo marca", Partida.monedas == antes + BOTIN
			and Partida.estado_de(clave, "botin_debil") != null and not is_instance_valid(monedas))

	var fuerte: Enemigo = sala.get_node(^"Fuerte") as Enemigo
	fuerte.golpeable.recibir_golpe(jugador, fuerte.vida)
	await _esperar(1)
	var sueltas: int = 0
	for hijo: Node in sala.get_children():
		if hijo is MonedasSueltas:
			sueltas += 1
	_caso("una ficha sin botin no suelta nada", sueltas == 0)

	# Volver a la sala: el debil reaparece, pero su botin ya se tomo.
	sala = await _crear_sala()
	jugador = get_tree().get_first_node_in_group(&"jugador") as Jugador
	debil = sala.get_node(^"Debil") as Enemigo
	debil.golpeable.recibir_golpe(jugador, debil.vida)
	await _esperar(1)
	_caso("vencido otra vez, el mismo ejemplar ya no suelta botin", sala.get_node_or_null(^"botin_debil") == null)

	# Uno que vuela 300 px sobre el suelo, vencido por la bola (golpea desde area_entered, dentro de una senal de
	# fisica): el botin aparece sin error del motor y cae hasta el suelo, no se queda a su altura.
	var volador_ficha: FichaEnemigo = _ficha_con_botin.duplicate() as FichaEnemigo
	volador_ficha.gravedad = 0.0
	var volador: Enemigo = (load(ENEMIGO) as PackedScene).instantiate() as Enemigo
	volador.ficha = volador_ficha
	volador.id = &"volador"
	volador.position = Vector2(1600.0, SUELO_Y - 300.0)
	sala.add_child(volador)
	await _esperar(2)
	var bola: Proyectil = (load(BOLA) as PackedScene).instantiate() as Proyectil
	bola.position = Vector2(1500.0, SUELO_Y - 340.0)
	bola.sentido = 1.0
	sala.add_child(bola)
	# La bola llega en unos 7 ticks; el salto dura SUBIDA_BOTIN + CAIDA_BOTIN (0,55 s, unos 33).
	await _esperar(55)
	var del_volador: MonedasSueltas = sala.get_node_or_null(^"botin_volador") as MonedasSueltas
	_caso("vencido por la bola, el botin aparece y cae al suelo de abajo", not is_instance_valid(volador)
			and del_volador != null and is_equal_approx(del_volador.global_position.y, SUELO_Y))

	sala.queue_free()
	_restaurar_partida()
	_resumen()


# Crea la sala de enemigos como hija (borrando la anterior), con la ficha con botin en el debil, y espera al jugador.
func _crear_sala() -> Sala:
	for hijo: Node in get_children():
		if hijo is Sala:
			hijo.free()
	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	(sala.get_node(^"Debil") as Enemigo).ficha = _ficha_con_botin
	add_child(sala)
	await _esperar(3)
	return sala
