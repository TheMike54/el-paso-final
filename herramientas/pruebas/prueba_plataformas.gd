extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de lo que se mueve y de lo que se pisa: instancia la sala Plataformas y arma en codigo lo que no va en una
# sala jugable (un cuerpo hijo de un Vaiven, una via sobre un cuerpo que se mueve, un suelo fragil sobre los pinchos).
# Comprueba el ritmo de Vaiven y Giro, que la plataforma lleve al jugador, el punto seguro, el aplastamiento, la
# plataforma delgada y platform_on_leave. Deja casos y fallos para plataformas.guion; imprime el resumen y los fallos.

const ESCENA_SALA: PackedScene = preload("res://herramientas/salas/sala_plataformas.tscn")
const ESCENA_DELGADA: PackedScene = preload("res://nucleo/piezas/plataforma_delgada.tscn")
## Cara de arriba del suelo de la sala.
const SUELO_Y: float = 680.0
## Suelo fijo a la izquierda de los pinchos, lejos de la Entrada (x=300).
const PUNTO_FIRME: Vector2 = Vector2(700.0, 680.0)
const ENTRADA: Vector2 = Vector2(300.0, 680.0)
## La cara de arriba del elevador en su pausa de arriba.
const ELEVADOR_ARRIBA: float = 360.0


func _ready() -> void:
	_ritmo_vaiven()
	_ritmo_giro()
	await _giro_en_la_sala()
	await _plataforma_lleva()
	await _cuerpo_hijo_no_lleva()
	await _punto_seguro_sobre_plataforma()
	await _punto_seguro_en_la_pausa()
	await _suelo_fragil_roto()
	await _aplastar()
	await _una_via_sobre_algo_que_se_mueve()
	await _delgada_caminar()
	await _delgada_saltar()
	await _delgada_caer()
	await _salto_desde_el_elevador()
	Partida.reiniciar()
	_resumen()


func _nueva_sala() -> Sala:
	Partida.reiniciar()
	var sala: Sala = ESCENA_SALA.instantiate() as Sala
	add_child(sala)
	await _esperar(2)
	return sala


func _jugador(sala: Sala) -> Jugador:
	return sala.get_node(^"Jugador") as Jugador


func _poner(jugador: Jugador, punto: Vector2) -> void:
	jugador.global_position = punto
	jugador.velocity = Vector2.ZERO


# Un peligro deja al jugador quieto mientras la pantalla funde a negro y, ya en negro, lo pone en su punto.
func _esperar_fundido() -> void:
	await _esperar(Fundido.TICKS_OSCURECER + Fundido.TICKS_EN_NEGRO_PELIGRO + 1)


func _esperar_elevador_arriba(elevador: Node2D) -> void:
	while elevador.global_position.y > ELEVADOR_ARRIBA + 0.5:
		await _esperar(1)


# Una forma de 200x20 con la cara de arriba en el origen.
func _forma(una_via: bool) -> CollisionShape2D:
	var rectangulo: RectangleShape2D = RectangleShape2D.new()
	rectangulo.size = Vector2(200.0, 20.0)
	var forma: CollisionShape2D = CollisionShape2D.new()
	forma.shape = rectangulo
	forma.position = Vector2(0.0, 10.0)
	forma.one_way_collision = una_via
	return forma


func _delgada(sala: Sala, posicion: Vector2, ancho: float) -> PlataformaDelgada:
	var delgada: PlataformaDelgada = ESCENA_DELGADA.instantiate() as PlataformaDelgada
	delgada.position = posicion
	delgada.ancho = ancho
	sala.add_child(delgada)
	return delgada


func _ritmo_vaiven() -> void:
	var vaiven: Vaiven = Vaiven.new()
	vaiven.ticks_ida = 150
	vaiven.ticks_espera = 40
	var bien: bool = (is_zero_approx(vaiven.avance_en(0)) and is_zero_approx(vaiven.avance_en(39))
		and is_equal_approx(vaiven.avance_en(115), 0.5) and is_equal_approx(vaiven.avance_en(190), 1.0)
		and is_equal_approx(vaiven.avance_en(229), 1.0) and is_equal_approx(vaiven.avance_en(305), 0.5)
		and is_zero_approx(vaiven.avance_en(380)))
	_caso("vaiven: espera en el origen al empezar, ida, espera en el extremo, vuelta y repite", bien)
	_caso("vaiven: un desfase negativo cae en el mismo ciclo", is_equal_approx(vaiven.avance_en(-75), 0.5))
	vaiven.ticks_espera = 0
	_caso("vaiven: sin espera da la vuelta en seguida", is_equal_approx(vaiven.avance_en(150), 1.0)
		and is_equal_approx(vaiven.avance_en(225), 0.5))
	vaiven.free()


func _ritmo_giro() -> void:
	var giro: Giro = Giro.new()
	giro.ticks_vuelta = 180
	_caso("giro: un cuarto de vuelta en 45 de 180 ticks y la vuelta entera vuelve al inicio",
		is_equal_approx(giro.angulo_en(45), TAU / 4.0) and is_zero_approx(giro.angulo_en(180)))
	giro.ticks_vuelta = -180
	_caso("giro: ticks negativos giran al reves", is_equal_approx(giro.angulo_en(45), -TAU / 4.0))
	giro.ticks_vuelta = 0
	_caso("giro: cero ticks no gira", is_zero_approx(giro.angulo_en(45)))
	giro.free()


func _giro_en_la_sala() -> void:
	var sala: Sala = await _nueva_sala()
	var barra: Giro = sala.get_node(^"Barra") as Giro
	var antes: float = barra.rotation
	await _esperar(45)
	_caso("giro: en la sala avanza un cuarto de vuelta en 45 ticks", is_equal_approx(barra.rotation - antes, TAU / 4.0))
	Congelado.pedir(10)
	antes = barra.rotation
	await _esperar(5)
	_caso("giro: quieto durante el congelado comun", is_equal_approx(barra.rotation, antes))
	await _esperar(10)
	sala.free()


func _plataforma_lleva() -> void:
	var sala: Sala = await _nueva_sala()
	var jugador: Jugador = _jugador(sala)
	var plataforma: Node2D = sala.get_node(^"Plataforma") as Node2D
	var cuerpo: CollisionObject2D = plataforma as Object as CollisionObject2D
	_caso("plataforma: el Vaiven la pone en escenario sin mascara",
		cuerpo.collision_layer == Capas.ESCENARIO and cuerpo.collision_mask == 0)
	_caso("plataforma: quieta en su origen durante la espera del arranque",
		is_equal_approx(plataforma.position.x, 900.0))
	_poner(jugador, plataforma.global_position)
	await _esperar(4)
	var x0: float = jugador.global_position.x
	var p0: float = plataforma.global_position.x
	await _esperar(100)
	var avance: float = plataforma.global_position.x - p0
	_caso("plataforma: lleva al jugador que esta encima",
		avance > 200.0 and absf(jugador.global_position.x - x0 - avance) < 10.0 and jugador.is_on_floor())
	sala.free()


# El armado que no lleva al jugador (docs/errores/2026-10-26-plataforma-hija-de-vaiven.md): un AnimatableBody2D hijo
# de un Vaiven se mueve con su padre, pero el jugador encima no. El validador lo rechaza en una escena.
func _cuerpo_hijo_no_lleva() -> void:
	var sala: Sala = await _nueva_sala()
	var jugador: Jugador = _jugador(sala)
	var vaiven: Vaiven = Vaiven.new()
	vaiven.recorrido = Vector2(300.0, 0.0)
	vaiven.ticks_ida = 120
	vaiven.position = Vector2(200.0, 400.0)
	var cuerpo: AnimatableBody2D = AnimatableBody2D.new()
	cuerpo.add_child(_forma(false))
	vaiven.add_child(cuerpo)
	sala.add_child(vaiven)
	await _esperar(1)
	_poner(jugador, cuerpo.global_position)
	await _esperar(4)
	var x0: float = jugador.global_position.x
	var p0: float = cuerpo.global_position.x
	await _esperar(60)
	_caso("plataforma hija de un Vaiven: se mueve, pero el jugador encima se queda",
		cuerpo.global_position.x - p0 > 100.0 and absf(jugador.global_position.x - x0) < 5.0)
	sala.free()


# El punto seguro no se toma sobre la plataforma: al volver de un peligro ya no estaria ahi.
func _punto_seguro_sobre_plataforma() -> void:
	var sala: Sala = await _nueva_sala()
	var jugador: Jugador = _jugador(sala)
	var plataforma: Node2D = sala.get_node(^"Plataforma") as Node2D
	_poner(jugador, PUNTO_FIRME)
	await _esperar(40)
	_poner(jugador, plataforma.global_position)
	await _esperar(120)
	var vidas: int = jugador.vidas
	jugador.recibir_dano(1, jugador.global_position.x, true)
	await _esperar_fundido()
	_caso("punto seguro: tras ir en la plataforma, un peligro vuelve al ultimo suelo fijo y quita una vida",
		jugador.global_position.distance_to(PUNTO_FIRME) < 1.0 and jugador.vidas == vidas - 1)
	sala.free()


# Quieto sobre el elevador en su pausa (velocidad 0) tampoco cuenta como suelo fijo.
func _punto_seguro_en_la_pausa() -> void:
	var sala: Sala = await _nueva_sala()
	var jugador: Jugador = _jugador(sala)
	var elevador: Node2D = sala.get_node(^"Elevador") as Node2D
	_poner(jugador, Vector2(1800.0, SUELO_Y))
	await _esperar(40)
	await _esperar_elevador_arriba(elevador)
	_poner(jugador, elevador.global_position)
	await _esperar(40)
	var en_pausa: bool = is_equal_approx(elevador.global_position.y, ELEVADOR_ARRIBA)
	# Ultimo eslabon de la cadena con una llegada sobre el elevador: el rayo largo lo atraviesa hasta el suelo fijo.
	var arriba: Vector2 = Vector2(elevador.global_position.x, ELEVADOR_ARRIBA - Jugador.RAYO_SUELO_ARRIBA)
	var abajo: Dictionary = jugador._suelo_fijo_bajo(arriba, Vector2(arriba.x, 720.0))
	_caso("punto seguro: bajo una llegada sobre el elevador, el rayo largo da el suelo fijo y no el elevador",
		en_pausa and not abajo.is_empty() and absf((abajo["position"] as Vector2).y - SUELO_Y) < 1.0)
	jugador.recibir_dano(1, jugador.global_position.x, true)
	await _esperar_fundido()
	_caso("punto seguro: quieto sobre el elevador en su pausa no cuenta",
		en_pausa and jugador.global_position.distance_to(Vector2(1800.0, SUELO_Y)) < 1.0)
	sala.free()


# Un suelo fragil roto deja sin suelo los puntos tomados encima: se vuelve a la llegada, que si tiene.
func _suelo_fragil_roto() -> void:
	var sala: Sala = await _nueva_sala()
	var jugador: Jugador = _jugador(sala)
	var fragil: SueloFragil = SueloFragil.new()
	fragil.add_child(_forma(false))
	fragil.position = Vector2(1200.0, 560.0)
	sala.add_child(fragil)
	_poner(jugador, Vector2(1200.0, 560.0))
	await _esperar(40)
	var vidas: int = jugador.vidas
	fragil.romper()
	var ticks: int = 0
	while jugador.vidas == vidas and ticks < 120:
		await _esperar(1)
		ticks += 1
	await _esperar_fundido()
	_caso("punto seguro: roto el suelo fragil, el peligro de abajo lleva a la llegada y no al aire",
		jugador.vidas == vidas - 1 and jugador.global_position.distance_to(ENTRADA) < 1.0)
	_caso("punto seguro: la mochila tampoco queda en el aire", jugador.ultimo_punto_seguro().distance_to(ENTRADA) < 1.0)
	sala.free()


# El elevador solido baja sobre el jugador parado en el suelo: lo hunde en el suelo mientras baja y lo saca encima,
# sin dano y sin dejarlo atrapado.
func _aplastar() -> void:
	var sala: Sala = await _nueva_sala()
	var jugador: Jugador = _jugador(sala)
	var elevador: Node2D = sala.get_node(^"Elevador") as Node2D
	await _esperar_elevador_arriba(elevador)
	_poner(jugador, Vector2(2000.0, SUELO_Y))
	var vidas: int = jugador.vidas
	await _esperar(200)
	_caso("aplastar: el elevador que baja sobre el jugador no le quita vida y lo deja encima",
		jugador.vidas == vidas and absf(jugador.global_position.y - SUELO_Y) < 1.0 and jugador.is_on_floor())
	Input.action_press(&"mover_izquierda")
	await _esperar(30)
	Input.action_release(&"mover_izquierda")
	_caso("aplastar: y sale caminando", jugador.global_position.x < 1900.0)
	sala.free()


# Una via sobre un AnimatableBody2D con Vaiven que baja hasta el suelo, contra la misma pieza solida: la medicion con
# la que se decidio la una via sobre lo que se mueve (plan nucleo-piezas-celda, «Decidido en la tanda», N3).
func _una_via_sobre_algo_que_se_mueve() -> void:
	for una_via: bool in [true, false]:
		var sala: Sala = await _nueva_sala()
		var jugador: Jugador = _jugador(sala)
		var cuerpo: AnimatableBody2D = AnimatableBody2D.new()
		cuerpo.set_script(Vaiven)
		var raiz: Vaiven = cuerpo as Object as Vaiven
		raiz.recorrido = Vector2(0.0, 300.0)
		raiz.ticks_ida = 100
		raiz.ticks_espera = 30
		cuerpo.add_child(_forma(una_via))
		cuerpo.position = Vector2(1700.0, 380.0)
		sala.add_child(cuerpo)
		_poner(jugador, Vector2(1700.0, SUELO_Y))
		var vidas: int = jugador.vidas
		var y_min: float = INF
		var y_max: float = -INF
		for i: int in range(330):
			await _esperar(1)
			y_min = minf(y_min, jugador.global_position.y)
			y_max = maxf(y_max, jugador.global_position.y)
		var sube: bool = y_min < ELEVADOR_ARRIBA + 21.0 and jugador.vidas == vidas
		if una_via:
			_caso("una via que se mueve: baja a traves del jugador sin hundirlo y lo sube", sube and y_max < SUELO_Y + 1.0)
		else:
			# Cuanto lo hunde al bajar es del motor (medido: 88 px) y no se exige: solo que no dane ni lo atrape.
			_caso("solida que se mueve: baja sobre el jugador sin dano, lo deja encima y lo sube",
				sube and absf(jugador.global_position.y - cuerpo.global_position.y) < 6.0)
		sala.free()


# Caminando se atraviesa a cualquier altura sobre el suelo (con el margen de 1 px), sin subirse.
func _delgada_caminar() -> void:
	for alto: float in [2.0, 30.0, 140.0]:
		var sala: Sala = await _nueva_sala()
		var jugador: Jugador = _jugador(sala)
		_delgada(sala, Vector2(560.0, SUELO_Y - alto), 120.0)
		_poner(jugador, Vector2(300.0, SUELO_Y))
		await _esperar(2)
		var y_min: float = INF
		Input.action_press(&"mover_derecha")
		for i: int in range(60):
			await _esperar(1)
			y_min = minf(y_min, jugador.global_position.y)
		Input.action_release(&"mover_derecha")
		_caso("delgada a %d px del suelo: se cruza caminando sin subirse" % int(alto),
			jugador.global_position.x > 640.0 and y_min > SUELO_Y - 1.0)
		sala.free()


# Desde abajo, el salto la atraviesa y se queda encima; ahi si se toma el punto seguro (es fija).
func _delgada_saltar() -> void:
	var sala: Sala = await _nueva_sala()
	var jugador: Jugador = _jugador(sala)
	var lampara: PlataformaDelgada = sala.get_node(^"Lampara") as PlataformaDelgada
	var forma: CollisionShape2D = lampara.get_node(^"Forma") as CollisionShape2D
	_caso("delgada: una via con el margen fijo y en escenario",
		forma.one_way_collision and is_equal_approx(forma.one_way_collision_margin, PlataformaDelgada.MARGEN)
		and lampara.collision_layer == Capas.ESCENARIO and lampara.collision_mask == 0)
	_poner(jugador, Vector2(450.0, SUELO_Y))
	await _esperar(4)
	Input.action_press(&"saltar")
	await _esperar(40)
	Input.action_release(&"saltar")
	await _esperar(30)
	_caso("delgada: el salto desde abajo la atraviesa y queda encima",
		absf(jugador.global_position.y - lampara.global_position.y) < 1.0 and jugador.is_on_floor())
	await _esperar(30)
	jugador.recibir_dano(1, jugador.global_position.x, true)
	await _esperar_fundido()
	_caso("delgada: es fija, cuenta como punto seguro", absf(jugador.global_position.y - lampara.global_position.y) < 1.0)
	sala.free()


# Cayendo a velocidad maxima (20 px por tick) y en picada (30) no la atraviesa, empiece donde empiece la caida.
func _delgada_caer() -> void:
	var atraviesa: int = 0
	for fase: int in range(0, 30, 3):
		for picada: bool in [false, true]:
			var sala: Sala = await _nueva_sala()
			var jugador: Jugador = _jugador(sala)
			_delgada(sala, Vector2(200.0, 560.0), 200.0)
			Partida.habilidades.append(Habilidades.CAIDA_EN_PICADA)
			Partida.inspiracion = jugador.costo_poder
			_poner(jugador, Vector2(200.0, 100.0 + float(fase)))
			if picada:
				await _esperar(1)
				Input.action_press(&"mover_abajo")
				Input.action_press(&"curar")
				await _esperar(2)
				Input.action_release(&"curar")
				Input.action_release(&"mover_abajo")
			await _esperar(50)
			# La picada cobra su Inspiracion: si no la cobro, no hubo picada y el caso no prueba nada.
			if picada and Partida.inspiracion != 0:
				atraviesa += 100
			if absf(jugador.global_position.y - 560.0) > 1.0:
				atraviesa += 1
			sala.free()
	_caso("delgada: ni la caida ni la picada la atraviesan en 10 fases", atraviesa == 0)


# platform_on_leave = ADD_UPWARD_VELOCITY (jugador.tscn): saltar del elevador que baja sube lo mismo que del suelo.
func _salto_desde_el_elevador() -> void:
	var sala: Sala = await _nueva_sala()
	var jugador: Jugador = _jugador(sala)
	_caso("platform_on_leave: no hereda la bajada de la plataforma",
		jugador.platform_on_leave == CharacterBody2D.PLATFORM_ON_LEAVE_ADD_UPWARD_VELOCITY)
	_poner(jugador, Vector2(1800.0, SUELO_Y))
	await _esperar(4)
	var del_suelo: float = await _subida_de_salto(jugador)
	var elevador: Node2D = sala.get_node(^"Elevador") as Node2D
	await _esperar_elevador_arriba(elevador)
	_poner(jugador, elevador.global_position)
	while elevador.global_position.y < 500.0:
		await _esperar(1)
	var del_elevador: float = await _subida_de_salto(jugador)
	_caso("platform_on_leave: el salto desde el elevador que baja sube casi lo mismo que desde el suelo",
		del_elevador > 0.95 * del_suelo)
	sala.free()


# Salta manteniendo saltar y devuelve cuanto subio sobre el punto de despegue.
func _subida_de_salto(jugador: Jugador) -> float:
	var y0: float = jugador.global_position.y
	var y_min: float = y0
	Input.action_press(&"saltar")
	for i: int in range(45):
		await _esperar(1)
		y_min = minf(y_min, jugador.global_position.y)
	Input.action_release(&"saltar")
	await _esperar(40)
	return y0 - y_min
