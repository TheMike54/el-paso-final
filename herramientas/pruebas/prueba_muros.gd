extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de MuroRompible, Palanca y Porton en la sala de secretos: golpes que aguanta, lado, ataque real sin
# Inspiracion, bola, pogo, tapas, lo que descubre, las monedas encerradas tras el muro, lo guardado al volver a crear
# la sala, el retraso de la palanca y cerrar el porton.
# Instancia la sala como hija y la vuelve a crear para ver lo guardado; su guion lee "valor . casos" y
# "valor . fallos".
const SALA: String = "res://herramientas/salas/sala_secretos.tscn"
const PROYECTIL: String = "res://nucleo/proyectil.tscn"

var _objetos_golpeados: int = 0
var _enemigos_golpeados: int = 0
var _muros_rotos: int = 0


func _ready() -> void:
	_aislar_partida()
	Eventos.objeto_golpeado.connect(func(_objeto: Node) -> void: _objetos_golpeados += 1)
	Eventos.enemigo_golpeado.connect(func(_enemigo: Node) -> void: _enemigos_golpeados += 1)
	Eventos.muro_roto.connect(func(_muro: StringName) -> void: _muros_rotos += 1)
	var sala: Sala = await _crear_sala()
	var jugador: Jugador = get_tree().get_first_node_in_group(&"jugador") as Jugador
	var clave: String = sala.clave()

	# Muro A: aguanta 4 golpes, se marca y descubre el cuarto.
	var muro: MuroRompible = sala.get_node(^"MuroA") as MuroRompible
	var tapa: CanvasItem = sala.get_node(^"Tapa") as CanvasItem
	var orilla: CanvasItem = sala.get_node(^"Orilla") as CanvasItem
	var monedas: MonedasSueltas = sala.get_node(^"MonedasCuarto") as MonedasSueltas
	_caso("las rutas de tapas y descubre llegan como nodos", muro.tapas == ([tapa] as Array[CanvasItem])
			and muro.descubre == ([orilla] as Array[CanvasItem]))
	_caso("entero, lo que descubre esta oculto y la tapa a la vista", not orilla.visible and tapa.visible)
	# Lo escondido esta encerrado por el solido: caminando contra el muro no se toman las monedas de detras.
	var monedas_antes: int = Partida.monedas
	jugador.global_position = Vector2(780.0, 1160.0)
	jugador.velocity = Vector2.ZERO
	Input.action_press(&"mover_derecha")
	await _esperar(40)
	Input.action_release(&"mover_derecha")
	_caso("entero, el muro encierra las monedas: caminando no se toman", is_instance_valid(monedas)
			and Partida.monedas == monedas_antes and jugador.global_position.x < 870.0)
	jugador.global_position = Vector2(780.0, 1160.0)
	jugador.velocity = Vector2.ZERO
	for i: int in range(3):
		muro.golpeable.recibir_golpe(jugador, 1)
	_caso("con 3 golpes el muro sigue: le queda 1", not muro.roto and muro.quedan == 1)
	_caso("golpear el muro avisa objeto_golpeado y no enemigo_golpeado", _objetos_golpeados == 3 and _enemigos_golpeados == 0)
	muro.golpeable.recibir_golpe(jugador, 1)
	_caso("el cuarto golpe lo rompe, lo marca y avisa muro_roto", muro.roto and Partida.estado_de(clave, "muro_a") != null and _muros_rotos == 1)
	_caso("al romperse, lo que descubre aparece", orilla.visible)
	await _esperar(muro.ticks_desvanecer + 4)
	_caso("la tapa se desvanece y el muro se va", not tapa.visible and not is_instance_valid(muro))
	Input.action_press(&"mover_derecha")
	await _esperar(70)
	Input.action_release(&"mover_derecha")
	_caso("roto, se entra caminando y se toman las monedas", not is_instance_valid(monedas)
			and Partida.monedas == monedas_antes + 10)

	# Muro que solo cuenta desde la derecha, con el ataque de verdad.
	var derecha: MuroRompible = sala.get_node(^"MuroDerecha") as MuroRompible
	_caso("cuenta_desde: la izquierda no, la derecha si", not derecha.cuenta_desde(Vector2(1900.0, 1160.0)) and derecha.cuenta_desde(Vector2(2100.0, 1160.0)))
	Partida.inspiracion = 0
	jugador.global_position = Vector2(1930.0, 1160.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(4)
	await _presionar(&"mover_derecha")
	jugador.global_position = Vector2(1930.0, 1160.0)
	await _esperar(2)
	await _presionar(&"atacar")
	await _esperar(20)
	_caso("el ataque desde la izquierda no cuenta", derecha.quedan == derecha.golpes)
	jugador.global_position = Vector2(2080.0, 1160.0)
	jugador.velocity = Vector2.ZERO
	await _presionar(&"mover_izquierda")
	jugador.global_position = Vector2(2080.0, 1160.0)
	await _esperar(2)
	await _presionar(&"atacar")
	await _esperar(20)
	_caso("el ataque desde la derecha cuenta un golpe", derecha.quedan == derecha.golpes - 1)
	_caso("pegarle al muro no da Inspiracion", Partida.inspiracion == 0)

	# La bola cuenta un golpe, aunque se detenga en el solido.
	var bola: Proyectil = (load(PROYECTIL) as PackedScene).instantiate() as Proyectil
	bola.sentido = -1.0
	bola.position = Vector2(2300.0, 1080.0)
	var antes: int = derecha.quedan
	sala.add_child(bola)
	await _esperar(30)
	_caso("la bola le quita un golpe al muro", derecha.quedan == antes - 1)

	# Techo: se le pega desde abajo. En la sala cuenta desde cualquier lado (sin solo_desde): para ver de que lado
	# lo toma (y 880, 300x40 px), se limita un momento a ABAJO y se vuelve a CUALQUIERA para el pogo de abajo.
	var techo: MuroRompible = sala.get_node(^"TechoRompible") as MuroRompible
	techo.solo_desde = MuroRompible.Lado.ABAJO
	_caso("al techo se le pega desde abajo", techo.cuenta_desde(Vector2(2400.0, 1160.0)) and not techo.cuenta_desde(Vector2(2400.0, 760.0)))
	techo.solo_desde = MuroRompible.Lado.CUALQUIERA
	# Pogo sobre el techo desde arriba (cuenta desde cualquier lado): rebota y le quita un golpe.
	var rebotes: int = jugador.rebotes_pogo
	jugador.global_position = Vector2(2400.0, 760.0)
	jugador.velocity = Vector2.ZERO
	Input.action_press(&"mover_abajo")
	await _esperar(2)
	await _presionar(&"atacar")
	await _esperar(10)
	Input.action_release(&"mover_abajo")
	_caso("el pogo sobre el techo rebota y le cuenta un golpe", jugador.rebotes_pogo == rebotes + 1 and techo.quedan == techo.golpes - 1)
	await _esperar(60)

	# Palanca: la bola no la mueve; el ataque si, y abre el porton tras el retraso.
	var palanca: Palanca = sala.get_node(^"Palanca") as Palanca
	var porton: Porton = sala.get_node(^"Porton") as Porton
	var cerrado_en: Vector2 = porton.position
	var activaciones: Array[int] = [0]
	palanca.activada.connect(func() -> void: activaciones[0] += 1)
	var aperturas: Array[int] = [0]
	porton.abierto.connect(func() -> void: aperturas[0] += 1)
	palanca.golpeable.recibir_golpe(bola if is_instance_valid(bola) else _bola_quieta(sala), 2)
	_caso("la bola no mueve la palanca", not palanca.esta_activada)
	jugador.global_position = Vector2(2620.0, 1160.0)
	palanca.golpeable.recibir_golpe(jugador, 1)
	_caso("el golpe del jugador la activa y la marca", palanca.esta_activada and Partida.estado_de(clave, "palanca") != null)
	await _esperar(palanca.ticks_retraso - 10)
	_caso("antes del retraso el porton no se mueve", not porton.abriendo and not porton.esta_abierto and porton.position == cerrado_en)
	palanca.golpeable.recibir_golpe(jugador, 1)
	_caso("el segundo golpe no la vuelve a activar", activaciones[0] == 1)
	await _esperar(palanca.ticks_congelado + 20)
	_caso("pasado el retraso el porton se abre y se marca", (porton.abriendo or porton.esta_abierto) and Partida.estado_de(clave, "porton") != null)
	await _esperar(porton.ticks_apertura + 4)
	_caso("abierto, subio su alto", porton.esta_abierto and is_equal_approx(porton.position.y, cerrado_en.y - 300.0) and aperturas[0] == 1)

	# Volver a crear la sala: lo roto y lo abierto siguen asi.
	sala = await _crear_sala()
	_caso("al volver, el muro A ya no esta", sala.get_node_or_null(^"MuroA") == null)
	_caso("al volver, la tapa del muro roto no se ve", not (sala.get_node(^"Tapa") as CanvasItem).visible)
	_caso("al volver, lo que descubre el muro roto se ve", (sala.get_node(^"Orilla") as CanvasItem).visible)
	_caso("al volver, las monedas tomadas no estan", sala.get_node_or_null(^"MonedasCuarto") == null)
	var palanca_2: Palanca = sala.get_node(^"Palanca") as Palanca
	var porton_2: Porton = sala.get_node(^"Porton") as Porton
	_caso("al volver, la palanca sigue activada y el porton abierto", palanca_2.esta_activada and porton_2.esta_abierto and is_equal_approx(porton_2.position.y, cerrado_en.y - 300.0))
	_caso("el muro de la derecha recuerda solo lo roto: vuelve entero", (sala.get_node(^"MuroDerecha") as MuroRompible).quedan == 4)
	porton_2.cerrar()
	await _esperar(porton_2.ticks_apertura + 4)
	_caso("cerrar() lo baja otra vez", not porton_2.esta_abierto and is_equal_approx(porton_2.position.y, cerrado_en.y))

	sala.queue_free()
	_restaurar_partida()
	_resumen()


# Crea la sala de secretos como hija (borrando la anterior) y espera a que arme al jugador.
func _crear_sala() -> Sala:
	for hijo: Node in get_children():
		if hijo is Sala:
			hijo.free()
	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	return sala


func _bola_quieta(sala: Sala) -> Node2D:
	var bola: Proyectil = (load(PROYECTIL) as PackedScene).instantiate() as Proyectil
	bola.process_mode = Node.PROCESS_MODE_DISABLED
	bola.position = Vector2(2620.0, 1080.0)
	sala.add_child(bola)
	return bola
