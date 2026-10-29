extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del viaje rapido sobre las estaciones de la zona prueba (prueba_1 gratis, prueba_4 de 50): Partida.estaciones y
# su guardado (tambien uno viejo sin el campo), pagar una vez, el cobro (CobroEstacion: pausa, foco en Si, cancelar sin
# cobrar, Si una vez), la gratis que se abre sola, el menu (solo las abiertas, en orden, foco en la actual) y su mapa, y
# un viaje de verdad hasta la llegada. Su guion lee "valor . casos" y "valor . fallos".
const SALA_GRATIS: String = "res://herramientas/salas/zonas/prueba/prueba_1.tscn"
const SALA_DE_PAGO: String = "res://herramientas/salas/zonas/prueba/prueba_4.tscn"
const GRATIS: String = "estacion_prueba_1"
const DE_PAGO: String = "estacion_prueba_4"

var _viajes: Array[String] = []


func _ready() -> void:
	_aislar_partida()
	Eventos.viaje_hecho.connect(func(id: String) -> void: _viajes.append(id))
	_partida()
	await _pagar()
	await _viajar()
	_puerta_y_estacion()
	get_tree().paused = false
	_restaurar_partida()
	_resumen()


func _partida() -> void:
	Partida.abrir_estacion(DE_PAGO)
	Partida.abrir_estacion(DE_PAGO)
	_caso("abrir_estacion agrega y no repite", Partida.estaciones == ([DE_PAGO] as Array[String]) and Partida.estacion_abierta(DE_PAGO) and not Partida.estacion_abierta(GRATIS))
	Partida.guardar(Partida.RUTA_PRUEBAS)
	Partida.reiniciar()
	var leida: Guardado.Resultado = Guardado.cargar(Partida.RUTA_PRUEBAS)
	Partida.desde_diccionario(leida.partida)
	_caso("el guardado lleva las estaciones", Partida.estacion_abierta(DE_PAGO))
	var vieja: Dictionary = Partida.a_diccionario()
	vieja.erase("estaciones")
	Guardado.guardar(vieja, Partida.RUTA_PRUEBAS)
	leida = Guardado.cargar(Partida.RUTA_PRUEBAS)
	# Guardado.NUEVOS rellena el campo al cargar: la partida leida ya lo trae.
	var valida: bool = leida.estado == Guardado.Estado.VALIDA and leida.partida.has("estaciones")
	if valida:
		Partida.desde_diccionario(leida.partida)
	_caso("un guardado sin el campo carga con la lista vacia", valida and Partida.estaciones.is_empty())
	var tabla: FichaEstaciones = Estacion.tabla_de("prueba_1")
	var mala: FichaEstaciones = FichaEstaciones.new()
	var dato: DatoEstacion = DatoEstacion.new()
	dato.id = "estacion_otra"
	dato.nombre = "Otra"
	dato.sala = "prueba_1"
	mala.estaciones = [dato, dato]
	_caso("la tabla de prueba esta bien y una con id repetido y mal nombrado no", tabla != null and tabla.fallos().is_empty() and mala.fallos().size() == 3)
	Partida.reiniciar()


func _pagar() -> void:
	var sala: Sala = (load(SALA_DE_PAGO) as PackedScene).instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	var estacion: Estacion = sala.get_node(^"Estacion") as Estacion
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	_caso("sin monedas no abre ni cobra", not estacion.pagar() and not Partida.estacion_abierta(DE_PAGO))
	Partida.monedas = 80
	var guardados: int = Partida.autoguardados
	_caso("con monedas cobra el costo una vez, abre y autoguarda", estacion.pagar() and Partida.monedas == 30 and Partida.estacion_abierta(DE_PAGO) and Partida.autoguardados > guardados)
	_caso("abierta no vuelve a cobrar", not estacion.pagar() and Partida.monedas == 30)
	_caso("no se viaja a una cerrada ni a la misma", not estacion.viajar(GRATIS) and not estacion.viajar(DE_PAGO) and estacion.destino.is_empty())
	estacion.abrir_menu()
	await get_tree().process_frame
	_caso("con una sola abierta el menu solo la lista a ella y avisa", estacion.menu.ids == PackedStringArray([DE_PAGO]) and not estacion.menu.lista.encabezado.text.is_empty())
	estacion.menu.cerrar()
	await get_tree().physics_frame

	# El cobro, con las entradas de verdad: pausa el arbol, el foco empieza en Si, Volver, pausa, No y B cancelan sin
	# cobrar y Si cobra una vez.
	Partida.estaciones.clear()
	Partida.monedas = 80
	jugador.global_position = estacion.global_position
	jugador.velocity = Vector2.ZERO
	await _esperar(30)
	await _presionar(&"interactuar")
	var cobro: CobroEstacion = estacion.cobro
	_caso("interactuar con la cerrada abre el cobro con el juego detenido, el costo y el foco en Si", cobro != null and get_tree().paused and cobro.confirmacion.si.has_focus() and cobro.confirmacion.cantidad.text.contains("50") and not jugador.hablando)
	if cobro == null:
		sala.free()
		return
	var pausa: Pausa = sala.get_node(^"Pausa") as Pausa
	var antes: PackedStringArray = _procesados_antes_que(jugador, [pausa] as Array[Node])
	_caso("con el cobro abierto, las pantallas encima y la Pausa van despues del jugador (antes: %s)" % ", ".join(antes), antes.is_empty())
	await _presionar(&"volver")
	_caso("Volver cancela sin cobrar y el juego sigue", estacion.cobro == null and not get_tree().paused and Partida.monedas == 80 and not Partida.estacion_abierta(DE_PAGO))
	estacion.interactuar(jugador)
	await _presionar(&"pausa")
	_caso("pausa cancela sin cobrar ni abrir la pausa", estacion.cobro == null and not pausa.abierta and not get_tree().paused and Partida.monedas == 80)
	estacion.interactuar(jugador)
	estacion.cobro.confirmacion.no.pressed.emit()
	await get_tree().physics_frame
	_caso("No cancela sin cobrar y el juego sigue", estacion.cobro == null and not get_tree().paused and Partida.monedas == 80 and not Partida.estacion_abierta(DE_PAGO))
	await _b_cierra("el cobro", jugador, estacion.interactuar.bind(jugador), func() -> bool: return estacion.cobro != null)
	await _esperar(2)
	Partida.monedas = 10
	estacion.interactuar(jugador)
	estacion.cobro.confirmacion.si.pressed.emit()
	await get_tree().physics_frame
	_caso("Si sin monedas no cobra ni abre y lo dice", not Partida.estacion_abierta(DE_PAGO) and Partida.monedas == 10 and estacion.cobro == null and estacion.caja != null and estacion.caja.ficha.lineas[0].texto == Estacion.TEXTO_NO_ALCANZA)
	await _cerrar_caja()
	Partida.monedas = 80
	guardados = Partida.autoguardados
	estacion.interactuar(jugador)
	cobro = estacion.cobro
	cobro.confirmacion.si.pressed.emit()
	cobro.confirmacion.si.pressed.emit()
	await get_tree().physics_frame
	_caso("Si cobra una vez, abre, autoguarda, cierra el cobro y lo dice", Partida.estacion_abierta(DE_PAGO) and Partida.monedas == 30 and Partida.autoguardados > guardados and estacion.cobro == null and not get_tree().paused and estacion.caja != null and estacion.caja.ficha.lineas[0].texto == Estacion.TEXTO_ABIERTA)
	await _cerrar_caja()
	_caso("al terminar la caja el jugador vuelve a moverse", estacion.caja == null and not jugador.hablando)
	sala.free()


# La gratis se abre sola; despues, un viaje de verdad de prueba_1 a prueba_4. La sala pasa a la raiz como escena actual
# para que el cambio de escena la libere a ella y no a esta prueba.
func _viajar() -> void:
	var sala: Sala = (load(SALA_GRATIS) as PackedScene).instantiate() as Sala
	get_tree().root.add_child(sala)
	get_tree().current_scene = sala
	await _esperar(3)
	var estacion: Estacion = sala.get_node(^"Estacion") as Estacion
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	jugador.global_position = estacion.global_position
	jugador.velocity = Vector2.ZERO
	await _esperar(30)
	await _presionar(&"interactuar")
	var menu: MenuEstaciones = estacion.menu
	_caso("la gratis se abre sola sin cobrar y abre el menu con el juego detenido", Partida.estacion_abierta(GRATIS) and Partida.monedas == 30 and menu != null and get_tree().paused)
	if menu == null:
		_volver_aqui()
		return
	_caso("salen las abiertas en el orden de la tabla", menu.ids == PackedStringArray([GRATIS, DE_PAGO]))
	_caso("el foco esta en la actual, en gris, y no se elige", menu.lista.con_foco() == 0 and menu.lista.apagadas[0] and not menu.lista.elegir(0))
	await _mapa(menu, estacion)
	await _presionar(&"pausa")
	var pausa: Pausa = sala.get_node(^"Pausa") as Pausa
	_caso("pausa cierra el menu sin abrir la pausa", estacion.menu == null and not pausa.abierta and not get_tree().paused)
	# B del control es volver y curar a la vez: el menu va despues del jugador y cerrarlo con B no le llega.
	estacion.abrir_menu()
	var antes: PackedStringArray = _procesados_antes_que(jugador, [pausa] as Array[Node])
	_caso("con el menu abierto, las pantallas encima y la Pausa van despues del jugador (antes: %s)" % ", ".join(antes), antes.is_empty())
	estacion.menu.cerrar()
	await get_tree().physics_frame
	await _b_cierra("el menu de estaciones", jugador, estacion.abrir_menu, func() -> bool: return estacion.menu != null)

	Partida.vidas = 3
	Partida.banco = "banco_prueba_1"
	Partida.sala = "prueba_1"
	var guardados: int = Partida.autoguardados
	estacion.abrir_menu()
	await get_tree().process_frame
	estacion.menu.lista.elegir(1)
	_caso("elegir otra cierra el menu y empieza el viaje", estacion.menu == null and estacion.destino == DE_PAGO and not get_tree().paused and jugador.hablando)
	await _esperar(Fundido.ticks_hasta_cambio(Fundido.Perfil.ESTACION) + 10)
	var llegada: Sala = get_tree().current_scene as Sala
	var bien: bool = llegada != null and llegada.id == "prueba_4"
	if bien:
		var otra: Estacion = llegada.get_node(^"Estacion") as Estacion
		var nuevo: Jugador = llegada.get_node(^"Jugador") as Jugador
		bien = nuevo.position.distance_to(otra.position + otra.llegada) < 2.0
	_caso("el viaje cambia a la sala de la otra estacion y deja al jugador en su llegada", bien)
	_caso("viajar avisa una vez y no cambia vidas, banco ni guardado", _viajes == ([DE_PAGO] as Array[String]) and Partida.vidas == 3 and Partida.banco == "banco_prueba_1" and Partida.sala == "prueba_1" and Partida.autoguardados == guardados)
	_volver_aqui()


# El mapa de gis del menu (prueba_1 y prueba_4 abiertas, la actual es prueba_1): un circulo por estacion en el centro
# de su sala, dentro del mapa y en el orden del mundo; la marca sigue al foco y la actual no cambia; las lineas siguen la
# tabla y no la posicion; sin el rectangulo de una sala o sin indice, la lista sola a lo ancho.
func _mapa(menu: MenuEstaciones, estacion: Estacion) -> void:
	await get_tree().process_frame
	var mapa: MapaEstaciones = menu.mapa
	var centros: PackedVector2Array = mapa.centros_en_pantalla() if mapa != null else PackedVector2Array()
	var dentro: bool = mapa != null and mapa.visible and mapa.size.x > 0.0 and centros.size() == menu.ids.size()
	for centro: Vector2 in centros:
		dentro = dentro and Rect2(Vector2.ZERO, mapa.size).has_point(centro)
	_caso("el mapa pone un circulo por estacion abierta dentro de el, prueba_1 a la izquierda de prueba_4", dentro and centros[0].x < centros[1].x)
	if mapa == null:
		return
	var al_abrir: bool = mapa.marcada == 0 and mapa.actual == 0
	Tema.dar_foco(menu.lista.filas[1])
	_caso("la marca del mapa empieza en la actual, sigue al foco y la actual no cambia", al_abrir and mapa.marcada == 1 and mapa.actual == 0)
	Tema.dar_foco(menu.lista.filas[0])

	# Tres estaciones en orden de tabla que no es el del mundo: la linea va 0-1 y 1-2 aunque la 2 quede en medio.
	var suelto: MapaEstaciones = MapaEstaciones.new()
	add_child(suelto)
	suelto.size = Vector2(600.0, 400.0)
	suelto.poner(PackedVector2Array([Vector2(0.0, 0.0), Vector2(2000.0, 0.0), Vector2(1000.0, 500.0)]), 0)
	var en_pantalla: PackedVector2Array = suelto.centros_en_pantalla()
	var caben: bool = true
	for centro: Vector2 in en_pantalla:
		caben = caben and Rect2(Vector2.ZERO, suelto.size).has_point(centro)
	_caso("las lineas siguen el orden de la tabla, no la posicion, y el encaje conserva el orden del mundo", suelto.tramos == ([Vector2i(0, 1), Vector2i(1, 2)] as Array[Vector2i]) and caben and en_pantalla[0].x < en_pantalla[2].x and en_pantalla[2].x < en_pantalla[1].x and en_pantalla[2].y > en_pantalla[0].y)
	suelto.free()

	var rectangulos: Dictionary = {"prueba_1": Rect2(0.0, 0.0, 1600.0, 720.0), "prueba_4": Rect2(5600.0, 0.0, 1600.0, 720.0)}
	var completos: PackedVector2Array = MenuEstaciones.centros_de(PackedStringArray(["prueba_1", "prueba_4"]), rectangulos)
	rectangulos.erase("prueba_4")
	_caso("sin el rectangulo de una sala no hay mapa", completos == PackedVector2Array([Vector2(800.0, 360.0), Vector2(6400.0, 360.0)]) and MenuEstaciones.centros_de(PackedStringArray(["prueba_1", "prueba_4"]), rectangulos).is_empty())

	# Sin indice (como sin el bloque mapa/): un menu aparte con una ruta que no existe. Pausa el arbol: se cierra al final.
	var solo: MenuEstaciones = MenuEstaciones.new()
	solo.estacion = estacion
	solo.ruta_indice = "res://mapa/no_existe.tres"
	add_child(solo)
	await get_tree().process_frame
	await get_tree().process_frame
	_caso("sin indice queda la lista sola a lo ancho, con las mismas filas", solo.mapa == null and solo.ids == menu.ids and solo.lista.cuerpo.get_child_count() == 1 and is_equal_approx(solo.lista.desliza.size.x, solo.lista.size.x))
	solo.cerrar()
	get_tree().paused = true
	await get_tree().process_frame


# La caja que dice como salio el pago: interactuar completa la linea y la siguiente pulsacion la cierra.
func _cerrar_caja() -> void:
	await _presionar(&"interactuar")
	await _presionar(&"interactuar")


# Esta prueba vuelve a ser la escena actual (el guion lee "valor ." de ella) y la sala de llegada se suelta.
func _volver_aqui() -> void:
	var actual: Node = get_tree().current_scene
	get_tree().current_scene = self
	if actual != null and actual != self:
		actual.free()
	get_tree().paused = false


func _puerta_y_estacion() -> void:
	Sala.puerta_llegada = &"derecha"
	Sala.estacion_llegada = GRATIS
	var cambios: Array[String] = []
	var anotar: Callable = func(clave: String, _puerta: StringName) -> void: cambios.append(clave)
	Eventos.cambio_de_sala.connect(anotar)
	var sala: Sala = (load(SALA_GRATIS) as PackedScene).instantiate() as Sala
	add_child(sala)
	Eventos.cambio_de_sala.disconnect(anotar)
	var estacion: Estacion = sala.get_node(^"Estacion") as Estacion
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	_caso("si piden una puerta y una estacion a la vez, manda la estacion y no se avisa llegada por puerta", jugador.position.is_equal_approx(estacion.position + estacion.llegada) and Sala.estacion_llegada.is_empty() and cambios.is_empty())
	sala.free()
