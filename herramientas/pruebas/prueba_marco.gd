extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del marco de menus: en que pagina abre de pie y sentado, el ciclo con las acciones y con la barra, que cierre
# con pausa, Atras, Volver y la misma accion sin abrir la pausa, que detenga el juego, dos paginas sin el bloque mapa,
# que LB o mapa_rapido sostenidos al cerrar no muestren el mapa rapido, la pagina Inventario, la pausa con Configuracion
# encima y los botones del control. Deja casos y fallos para marco.guion.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const ESCENA_PAUSA: PackedScene = preload("res://nucleo/pausa.tscn")
const MAPA: String = "res://mapa/pantalla_mapa.tscn"
const RUTA: String = "user://prueba_marco.json"


# Arma las piezas en el orden de una sala. El ciclo va tambien con los botones de la barra; LB o mapa_rapido, al
# cerrar el marco o la pausa; los botones del control, en la barra y en Continuar.
func _ready() -> void:
	_aislar_partida(RUTA)
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.name = "Jugador"
	jugador.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(jugador)
	var pausa: Pausa = ESCENA_PAUSA.instantiate() as Pausa
	add_child(pausa)
	var marco: MarcoMenus = MarcoMenus.new()
	marco.name = &"Marco"
	add_child(marco)
	var inventario: PaginaInventario = PaginaInventario.new()
	add_child(inventario)
	var amuletos: PantallaAmuletos = PantallaAmuletos.new()
	amuletos.name = "Amuletos"
	add_child(amuletos)
	_caso("la pausa ya no tiene boton Amuletos", pausa.get_node_or_null(^"Panel/Opciones/Amuletos") == null)

	# Sin el bloque mapa.
	_caso("sin la pagina Mapa el ciclo es Inventario y Amuletos", marco.ids() == ([&"inventario", &"amuletos"] as Array[StringName]))
	await _presionar(&"mapa")
	_caso("sin la pagina Mapa, mapa no abre el marco", not marco.abierta and not get_tree().paused)
	var mapa: PantallaMapa = (load(MAPA) as PackedScene).instantiate() as PantallaMapa
	add_child(mapa)
	_caso("con el bloque mapa el ciclo es Inventario, Amuletos y Mapa", marco.ids() == ([&"inventario", &"amuletos", &"mapa"] as Array[StringName]))

	# De pie.
	await _presionar(&"inventario")
	_caso("de pie, inventario abre en Inventario y detiene el juego", marco.abierta and marco.pagina == &"inventario" and inventario.visible and get_tree().paused and not pausa.abierta)
	await _presionar(&"pagina_siguiente")
	_caso("pagina_siguiente pasa a Amuletos y oculta Inventario", marco.pagina == &"amuletos" and amuletos.visible and not inventario.visible)
	await _presionar(&"pagina_anterior")
	await _presionar(&"pagina_anterior")
	_caso("pagina_anterior da la vuelta del primero al ultimo", marco.pagina == &"mapa" and mapa.abierta and not amuletos.visible)
	var titulo: Label = marco.get_node(^"Barra/Titulo") as Label
	var anterior: Button = marco.get_node(^"Barra/Anterior") as Button
	var siguiente: Button = marco.get_node(^"Barra/Siguiente") as Button
	_caso("la barra nombra la pagina y sus vecinas", titulo.text == "Mapa" and anterior.text == "‹ Amuletos" and siguiente.text == "Inventario ›")
	siguiente.pressed.emit()
	_caso("tocar la vecina de la barra cambia de pagina", marco.pagina == &"inventario" and not mapa.abierta)
	await _presionar(&"inventario")
	_caso("inventario otra vez lo cierra y el juego sigue", not marco.abierta and not inventario.visible and not get_tree().paused)
	await _presionar(&"mapa")
	_caso("mapa abre en Mapa", marco.abierta and marco.pagina == &"mapa" and mapa.abierta and mapa.visible)
	await _presionar(&"pausa")
	_caso("pausa lo cierra sin abrir la pausa", not marco.abierta and not mapa.visible and not pausa.abierta and not get_tree().paused)
	await _presionar(&"mapa")
	await _presionar(&"volver")
	_caso("volver (B) lo cierra sin abrir la pausa", not marco.abierta and not pausa.abierta and not get_tree().paused)
	var antes: PackedStringArray = _procesados_antes_que(jugador, [pausa] as Array[Node])
	_caso("el marco y la Pausa van despues del jugador (antes: %s)" % ", ".join(antes), antes.is_empty())

	# LB es mapa_rapido y pagina_anterior. Sostenido con el juego andando muestra el mapa rapido (asi se ve que la
	# prueba mide); sostenido al cerrar el marco, no debe mostrarlo.
	_sostener_boton(JOY_BUTTON_LEFT_SHOULDER, true)
	await _esperar(4)
	var mide: bool = mapa.rapido
	_sostener_boton(JOY_BUTTON_LEFT_SHOULDER, false)
	await _esperar(2)
	_caso("sin el marco, LB sostenido muestra el mapa rapido y soltarlo lo quita", mide and not mapa.rapido)
	await _presionar(&"inventario")
	_sostener_boton(JOY_BUTTON_LEFT_SHOULDER, true)
	await _esperar(2)
	await _presionar(&"volver")
	await _esperar(4)
	var rapido: bool = mapa.rapido
	_sostener_boton(JOY_BUTTON_LEFT_SHOULDER, false)
	await _esperar(2)
	_caso("cerrar el marco con LB sostenido no muestra el mapa rapido", not marco.abierta and not rapido)
	# Con el mapa rapido a la vista, mapa abre el marco en Mapa; cerrarlo sin soltar LB no vuelve a mostrarlo.
	_sostener_boton(JOY_BUTTON_LEFT_SHOULDER, true)
	await _esperar(4)
	var armado: bool = mapa.rapido
	await _presionar(&"mapa")
	var en_mapa: bool = marco.abierta and marco.pagina == &"mapa" and mapa.abierta
	await _presionar(&"volver")
	await _esperar(4)
	rapido = mapa.rapido
	_sostener_boton(JOY_BUTTON_LEFT_SHOULDER, false)
	await _esperar(2)
	_caso("con el mapa rapido, mapa abre el marco en Mapa y cerrarlo sin soltar LB no lo muestra", armado and en_mapa and not marco.abierta and not rapido)
	# La Pausa: cerrarla con mapa_rapido sostenido no lo muestra.
	await _presionar(&"pausa")
	var pausada: bool = pausa.abierta
	Input.action_press(&"mapa_rapido")
	await _esperar(2)
	await _presionar(&"pausa")
	await _esperar(4)
	rapido = mapa.rapido
	_caso("cerrar la Pausa con mapa_rapido sostenido no muestra el mapa rapido", pausada and not pausa.abierta and not get_tree().paused and not rapido)
	# Soltar y volver a pulsar con el juego andando si lo muestra.
	Input.action_release(&"mapa_rapido")
	await _esperar(2)
	Input.action_press(&"mapa_rapido")
	await _esperar(4)
	rapido = mapa.rapido
	_caso("tras soltar, volver a pulsar mapa_rapido si muestra el mapa rapido", rapido)
	# La sala crea otra PantallaMapa al cruzar una puerta: con mapa_rapido sostenido, la nueva lo sigue mostrando.
	var otra: PantallaMapa = (load(MAPA) as PackedScene).instantiate() as PantallaMapa
	add_child(otra)
	await _esperar(2)
	var sigue: bool = otra.rapido
	otra.free()
	Input.action_release(&"mapa_rapido")
	await _esperar(2)
	_caso("una PantallaMapa nueva, como al cruzar una puerta, con mapa_rapido sostenido lo sigue mostrando", sigue and not mapa.rapido)

	# Sentado.
	jugador.descansando = true
	await _presionar(&"inventario")
	_caso("sentado, inventario abre en Amuletos", marco.abierta and marco.pagina == &"amuletos" and amuletos.visible)
	get_tree().root.propagate_notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_caso("Atras lo cierra sin abrir la pausa", not marco.abierta and not pausa.abierta and not get_tree().paused)
	marco.abrir(&"inventario")
	(marco.get_node(^"Barra/Volver") as Button).pressed.emit()
	_caso("Volver de la barra lo cierra", not marco.abierta and not get_tree().paused)
	jugador.descansando = false

	# Con la pausa abierta no se abre.
	pausa.abrir()
	await _presionar(&"mapa")
	await _presionar(&"inventario")
	_caso("con la pausa abierta ni mapa ni inventario lo abren", not marco.abierta and pausa.abierta)
	pausa.cerrar()

	# La pausa: Continuar, Configuracion y Salir al menu; Configuracion encima, sin Desarrollador.
	var opciones: Node = pausa.get_node(^"Panel/Opciones")
	var nombres: Array[String] = []
	for hijo: Node in opciones.get_children():
		if hijo is Button:
			nombres.append(String(hijo.name))
	_caso("la pausa tiene Continuar, Configuracion y Salir al menu", nombres == (["Continuar", "Configuracion", "SalirAlMenu"] as Array[String]))
	pausa.abrir()
	(opciones.get_node(^"Configuracion") as Button).pressed.emit()
	var config: Configuracion = pausa.configuracion
	var panel_pausa: Control = pausa.get_node(^"Panel") as Control
	_caso("Configuracion de la pausa se abre encima con el juego detenido", config != null and config.is_visible_in_tree() and not panel_pausa.visible and get_tree().paused)
	_caso("dentro de la partida no aparece Desarrollador", not (config.get_node(^"Lista/Desplazable/Centro/Opciones/ModoDesarrollador") as Control).visible)
	(config.get_node(^"Lista/Desplazable/Centro/Opciones/Controles") as Button).pressed.emit()
	_caso("Botones tactiles abre el editor encima de Configuracion", pausa.editor != null and (pausa.editor.get_parent() as CanvasLayer).layer > Pausa.CAPA_CONFIGURACION and not config.visible)
	_caso("con el editor abierto no queda el fondo negro de Configuracion: se ve la sala", not (pausa.get_node(^"CapaConfiguracion/Fondo") as Control).visible)
	pausa.editor.cancelar()
	await get_tree().process_frame
	_caso("cancelar el editor vuelve a Configuracion", pausa.editor == null and config.is_visible_in_tree())
	get_tree().root.propagate_notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en Configuracion vuelve a la pausa con el foco en Configuracion", not config.is_visible_in_tree() and panel_pausa.visible and pausa.abierta and get_viewport().gui_get_focus_owner() == opciones.get_node(^"Configuracion"))
	(opciones.get_node(^"Configuracion") as Button).pressed.emit()
	await _presionar(&"pausa")
	_caso("pausa en Configuracion vuelve a la pausa sin cerrarla", not config.is_visible_in_tree() and panel_pausa.visible and pausa.abierta and get_tree().paused)
	# Una foto como la que toma la pausa con pantalla (en headless no la toma): cerrar la suelta con su textura.
	var foto: Image = Image.create_empty(16, 9, false, Image.FORMAT_RGBA8)
	foto.fill(Color.GRAY)
	config.foto = foto
	(config.get_node(^"Lista/Desplazable/Centro/Opciones/Brillo") as Button).pressed.emit()
	var con_foto: bool = config.brillo_con_foto()
	config.atras()
	config.atras()
	pausa.cerrar()
	_caso("cerrar la pausa suelta la foto y su textura", con_foto and config.foto == null and not config.brillo_con_foto())

	# Lo que muestra Inventario.
	Partida.monedas = 120
	Partida.habilidades.append_array([&"pluma", &"impulso"] as Array[StringName])
	marco.abrir(&"inventario")
	_caso("Inventario muestra vida, PejeCoins, arma y habilidades sin repetir el arma", inventario.valores["Vida"] == "4 de 4" and inventario.valores["PejeCoins"] == "120" and inventario.valores["Arma"] == "Pluma" and inventario.valores["Habilidades"] == "Impulso")
	_caso("sin nada perdido dice Nada", inventario.valores["Lo perdido"] == "Nada")
	marco.cerrar()
	_caso("lo perdido dice cuanto y donde", PaginaInventario.perdido({"sala": "prueba_1", "x": 10.0, "y": 20.0, "monto": 30.0}) == "30 PejeCoins en prueba_1" and PaginaInventario.perdido({"monto": 0}) == "Nada")

	# Botones del control en la barra (Volver, Anterior y Siguiente) y en Continuar de la pausa.
	var iconos: Array[IconoBoton] = _iconos(marco)
	var continuar: Array[IconoBoton] = _iconos(pausa.get_node(^"Panel/Opciones/Continuar"))
	await _usar(true)
	_caso("con el control la barra muestra Volver, L1 y R1, y Continuar el de volver", iconos.size() == 3 and _iconos_en(iconos, true) and continuar.size() == 1 and _iconos_en(continuar, true))
	# En Mapa las vecinas tienen los nombres mas largos («‹ Amuletos», «Inventario ›»).
	marco.abrir(&"mapa")
	await get_tree().process_frame
	await get_tree().process_frame
	var boton_siguiente: Control = marco.get_node(^"Barra/Siguiente") as Control
	var orilla: float = boton_siguiente.get_viewport_rect().size.x - Tema.MARGEN_LATERAL
	_caso("con el control la barra cabe: Siguiente no pasa del margen derecho", boton_siguiente.visible and boton_siguiente.get_global_rect().end.x <= orilla + 0.5)
	marco.cerrar()
	await _usar(false)
	_caso("tras un toque no se muestran botones del control", _iconos_en(iconos, false) and _iconos_en(continuar, false))

	for nodo: Node in [mapa, amuletos, inventario, marco, pausa, jugador]:
		nodo.free()
	get_tree().paused = false
	_restaurar_partida()
	_resumen()
