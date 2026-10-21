extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de la tienda: Partida.gastar_monedas, la ListaElegir (foco en la primera elegible, una fila gris no se elige,
# Volver cierra), el icono de cada articulo segun su Recompensa y la sala Tienda de punta a punta, de abrir a comprar y
# autoguardar. Su guion lee "valor . casos" y "valor . fallos".
const SALA: String = "res://herramientas/salas/sala_tienda.tscn"

var _comprados: int = 0
var _cerradas: int = 0
var _elegidas: Array[int] = []


func _ready() -> void:
	_aislar_partida()
	Eventos.articulo_comprado.connect(func(_a: ArticuloTienda) -> void: _comprados += 1)
	_monedas()
	_iconos_de_articulos()
	await _lista()
	await _tienda()
	get_tree().paused = false
	_restaurar_partida()
	_resumen()


func _monedas() -> void:
	Partida.monedas = 40
	_caso("gastar mas de lo que hay no cambia nada", not Partida.gastar_monedas(50) and Partida.monedas == 40)
	_caso("gastar un numero negativo no cambia nada", not Partida.gastar_monedas(-5) and Partida.monedas == 40)
	_caso("gastar lo justo deja 0", Partida.gastar_monedas(40) and Partida.monedas == 0)


# Cada tipo de Recompensa tiene su icono; sin recompensa, ninguno.
func _iconos_de_articulos() -> void:
	var formas: Array[IconoArticulo.Forma] = []
	for tipo: Recompensa.Tipo in [Recompensa.Tipo.MONEDAS, Recompensa.Tipo.VIDA_MAXIMA, Recompensa.Tipo.AMULETO,
			Recompensa.Tipo.HABILIDAD, Recompensa.Tipo.MAPA]:
		var articulo: ArticuloTienda = ArticuloTienda.new()
		articulo.recompensa = Recompensa.new()
		articulo.recompensa.tipo = tipo
		formas.append(IconoArticulo.forma_de(articulo))
	var esperadas: Array[IconoArticulo.Forma] = [IconoArticulo.Forma.MONEDA, IconoArticulo.Forma.VIDA,
			IconoArticulo.Forma.AMULETO, IconoArticulo.Forma.HABILIDAD, IconoArticulo.Forma.MAPA]
	_caso("el icono sale del tipo de la recompensa", formas == esperadas)
	var sin_nada: bool = IconoArticulo.forma_de(ArticuloTienda.new()) == IconoArticulo.Forma.NINGUNA
	_caso("sin recompensa no hay icono", sin_nada and IconoArticulo.forma_de(null) == IconoArticulo.Forma.NINGUNA)


func _lista() -> void:
	var capa: CanvasLayer = CanvasLayer.new()
	add_child(capa)
	var fondo: Control = Control.new()
	fondo.theme = Tema.crear()
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa.add_child(fondo)
	var lista: ListaElegir = ListaElegir.new()
	fondo.add_child(lista)
	Tema.ajustar(lista)
	lista.elegida.connect(func(i: int) -> void: _elegidas.append(i))
	lista.cerrada.connect(func() -> void: _cerradas += 1)
	lista.armar(PackedStringArray(["A", "B", "C"]), PackedStringArray(["10", "20", "30"]), [true, false, false] as Array[bool])
	await get_tree().process_frame
	_caso("el foco empieza en la primera fila elegible", lista.con_foco() == 1)
	_caso("una fila gris no se elige", not lista.elegir(0) and _elegidas.is_empty())
	_caso("una fila elegible se elige", lista.elegir(2) and _elegidas == [2])
	lista.armar(PackedStringArray(["A", "B"]), PackedStringArray(["", ""]), [false, false] as Array[bool], 1)
	await get_tree().process_frame
	_caso("el foco pedido se respeta y las filas se rehacen", lista.con_foco() == 1 and lista.filas.size() == 2)
	(lista.get_node(^"Arriba/Volver") as Button).pressed.emit()
	_caso("Volver cierra la lista", _cerradas == 1)
	capa.free()


# La sala Tienda de punta a punta: las PejeCoins fijas en el HUD mientras esta abierta, lo que no alcanza en gris, la
# franja y el detalle siguen al foco, el requisito oculta, comprar pide confirmar (foco en Si; Volver y No vuelven sin
# comprar), Si cobra una vez, entrega, marca, avisa y autoguarda, y lo comprado no vuelve al crear otra vez la sala.
func _tienda() -> void:
	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	var tienda: Tienda = sala.get_node(^"Tienda") as Tienda
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	_caso("la sala da 300 PejeCoins al entrar", Partida.monedas == 300)
	_caso("el requisito oculta el articulo", tienda.a_la_venta().size() == 3)

	jugador.global_position = Vector2(1400.0, 680.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(30)
	await _presionar(&"interactuar")
	var menu: MenuTienda = tienda.menu
	_caso("interactuar abre el menu con el juego detenido", menu != null and get_tree().paused)
	if menu == null:
		sala.free()
		return
	# Las PejeCoins no van en el panel: el HUD las muestra fijas, aunque el arbol este detenido y pase su tiempo a la vista.
	var hud: Hud = sala.get_node(^"Interfaz/Hud") as Hud
	await _esperar(Hud.TICKS_A_LA_VISTA + Hud.TICKS_DESVANECER + 2)
	_caso("con la tienda abierta el HUD muestra las PejeCoins fijas", hud.monedas_fijas and hud.monedas_visibles and hud.monedas_mostradas == 300 and get_tree().paused)
	var gris: bool = menu.lista.apagadas == ([false, true, false] as Array[bool]) and (menu.lista.filas[1].get_node(^"Icono") as IconoArticulo).apagado
	var formas: Array[IconoArticulo.Forma] = [IconoArticulo.Forma.HABILIDAD, IconoArticulo.Forma.VIDA, IconoArticulo.Forma.AMULETO]
	_caso("lo que no alcanza sale en gris, con el icono de su recompensa y el precio", gris and _formas(menu) == formas and menu.lista.filas[1].text == "500")
	_caso("la franja y el detalle van con la fila del foco", menu.lista.con_franja_en() == 0 and menu.nombre.text == "Pluma del mapa")
	Tema.dar_foco(menu.lista.filas[1])
	_caso("al mover el foco, la franja y el detalle lo siguen, tambien a una fila gris", menu.lista.con_franja_en() == 1 and menu.nombre.text == "Vida máxima" and menu.descripcion.text == tienda.articulos[1].descripcion)
	await _presionar(&"pausa")
	var pausa: Pausa = sala.get_node(^"Pausa") as Pausa
	_caso("pausa con la tienda abierta la cierra sin abrir la pausa", tienda.menu == null and not pausa.abierta and not get_tree().paused)
	await _esperar(Hud.TICKS_A_LA_VISTA - 10)
	var sigue: bool = hud.monedas_visibles and not hud.monedas_fijas and hud.process_mode == Node.PROCESS_MODE_INHERIT
	await _esperar(10 + Hud.TICKS_DESVANECER + 2)
	_caso("al cerrarla el HUD vuelve a su ciclo: sigue un rato y se desvanece", sigue and not hud.monedas_visibles)

	tienda.abrir()
	menu = tienda.menu
	await get_tree().process_frame
	menu.lista.elegir(0)
	var confirmacion: Confirmacion = menu.confirmacion
	_caso("elegir pide confirmar con el precio en su linea, la lista oculta y el foco en Si", confirmacion.visible and confirmacion.cantidad.text.contains("50") and not menu.lista.visible and confirmacion.si.has_focus())
	await _presionar(&"volver")
	_caso("Volver vuelve a la lista sin comprar", tienda.menu == menu and not confirmacion.visible and menu.lista.visible and get_tree().paused and Partida.monedas == 300 and _comprados == 0)
	menu.lista.elegir(0)
	confirmacion.no.pressed.emit()
	_caso("No vuelve a la lista sin comprar", not confirmacion.visible and menu.lista.visible and Partida.monedas == 300 and _comprados == 0)
	var guardados: int = Partida.autoguardados
	menu.lista.elegir(0)
	confirmacion.si.pressed.emit()
	confirmacion.si.pressed.emit()
	var marcado: bool = str(Partida.estado_de(sala.clave(), "tienda_prueba_pluma")) == "true"
	_caso("Si cobra una vez, entrega, marca, avisa y autoguarda", not confirmacion.visible and Partida.monedas == 250 and Partida.tiene(&"pluma_mapa") and marcado and _comprados == 1 and Partida.autoguardados > guardados)
	_caso("lo comprado ya no sale", menu.visibles.size() == 2 and menu.visibles[0].id == "vida")
	var pluma: ArticuloTienda = tienda.articulos[0]
	_caso("comprar otra vez no cobra", not tienda.comprar(pluma) and Partida.monedas == 250 and _comprados == 1)
	_caso("con lo caro no alcanza aunque se pida", not tienda.comprar(tienda.articulos[1]) and Partida.monedas == 250)
	# La vida maxima no guarda por su cuenta (la habilidad si): aqui se ve que guarda la tienda.
	Partida.monedas = 500
	var vidas: int = Partida.vidas_maximas
	guardados = Partida.autoguardados
	_caso("comprar lo que no guarda solo tambien autoguarda", tienda.comprar(tienda.articulos[1]) and Partida.vidas_maximas == vidas + 1 and Partida.monedas == 0 and Partida.autoguardados > guardados)
	await _presionar(&"volver")
	_caso("Circulo / B cierra el menu y el juego sigue", tienda.menu == null and not get_tree().paused)
	await _cerrar_con_b(sala, tienda, jugador)
	sala.free()

	sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	tienda = sala.get_node(^"Tienda") as Tienda
	_caso("al volver a crear la sala lo comprado sigue fuera y no se reponen las monedas", tienda.a_la_venta().size() == 1 and Partida.monedas == 0)
	Partida.obtener_habilidad(&"impulso")
	_caso("con la habilidad del requisito aparece", tienda.a_la_venta().size() == 2)
	sala.free()


func _formas(menu: MenuTienda) -> Array[IconoArticulo.Forma]:
	var formas: Array[IconoArticulo.Forma] = []
	for fila: Button in menu.lista.filas:
		var icono: IconoArticulo = fila.get_node_or_null(^"Icono") as IconoArticulo
		formas.append(icono.forma if icono != null else IconoArticulo.Forma.NINGUNA)
	return formas


# B del control es volver y curar a la vez. Primero, sin menu, se ve que la prueba mide (B solo cuenta un toque);
# despues, con la tienda, la pausa y el marco de la sala: cerrar con B no es una pulsacion del boton de poderes, y el
# menu y la pausa se procesan despues del jugador.
func _cerrar_con_b(sala: Sala, tienda: Tienda, jugador: Jugador) -> void:
	var toques: int = jugador.toques_poder
	await _presionar_boton(JOY_BUTTON_B)
	await _esperar(2)
	_caso("sin menu, B cuenta un toque del boton de poderes", jugador.toques_poder == toques + 1)
	var pausa: Pausa = sala.get_node(^"Pausa") as Pausa
	var marco: MarcoMenus = sala.get_node(^"Marco") as MarcoMenus
	tienda.abrir()
	var antes: PackedStringArray = _procesados_antes_que(jugador, [pausa] as Array[Node])
	_caso("con la tienda abierta, las pantallas encima y la Pausa van despues del jugador (antes: %s)" % ", ".join(antes), antes.is_empty())
	tienda.menu.cerrar()
	await get_tree().physics_frame
	await _b_cierra("la tienda", jugador, tienda.abrir, func() -> bool: return tienda.menu != null)
	await _b_cierra("la pausa", jugador, pausa.abrir, func() -> bool: return pausa.abierta)
	await _b_cierra("el marco", jugador, marco.abrir.bind(&"inventario"), func() -> bool: return marco.abierta)
