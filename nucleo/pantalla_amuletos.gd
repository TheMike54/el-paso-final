class_name PantallaAmuletos
extends PaginaMarco
# Pagina Amuletos del marco de menus (MarcoMenus), encima del juego detenido. Como en Hollow Knight, solo sentado en
# un banco se ponen y se quitan; de pie solo se consultan. La regla vive aqui (lee Jugador.descansando): Partida
# solo cuida que se tengan y que haya lugar. La crea cada sala; el marco la abre y la cierra.

## Botones de la lista, por id del amuleto; publico para la prueba.
var botones: Dictionary[StringName, Button] = {}

var _aviso: Label = null
var _lista: VBoxContainer = null


func _ready() -> void:
	super()
	var panel: ColorRect = Tema.fondo_menu()
	add_child(panel)
	# Con muchos amuletos la lista no cabe a lo alto: se desplaza con el foco y con el dedo. Si cabe, el centro llena
	# la vista y la lista queda centrada como sin desplazamiento.
	var desplazable: ScrollContainer = ScrollContainer.new()
	desplazable.name = "Desplazable"
	desplazable.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	desplazable.offset_top = MarcoMenus.ALTO_BARRA
	desplazable.follow_focus = true
	desplazable.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	panel.add_child(desplazable)
	var centro: CenterContainer = CenterContainer.new()
	centro.name = "Centro"
	centro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	centro.size_flags_vertical = Control.SIZE_EXPAND_FILL
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desplazable.add_child(centro)
	var columna: VBoxContainer = VBoxContainer.new()
	columna.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	centro.add_child(columna)
	_aviso = Label.new()
	_aviso.name = "Aviso"
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(_aviso)
	_lista = VBoxContainer.new()
	_lista.name = "Lista"
	_lista.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	columna.add_child(_lista)


func id_pagina() -> StringName:
	return &"amuletos"


func titulo_pagina() -> String:
	return "Amuletos"


func mostrar_en_marco() -> void:
	super()
	_mostrar()


## Sentado en un banco de esta sala.
func puede_cambiar() -> bool:
	var jugador: Jugador = get_tree().get_first_node_in_group(Jugador.GRUPO) as Jugador
	return jugador != null and jugador.descansando


## Pone o quita un amuleto, solo sentado. Devuelve si cambio algo.
func alternar(amuleto: StringName) -> bool:
	if not puede_cambiar():
		return false
	var cambio: bool = Partida.desequipar(amuleto) if Partida.esta_equipado(amuleto) else Partida.equipar(amuleto)
	_actualizar()
	return cambio


func _mostrar() -> void:
	for hijo: Node in _lista.get_children():
		hijo.free()
	botones.clear()
	for amuleto: StringName in Partida.amuletos_tenidos:
		var boton: Button = Button.new()
		boton.name = String(amuleto)
		boton.custom_minimum_size = Tema.CELDA
		boton.pressed.connect(alternar.bind(amuleto))
		_lista.add_child(boton)
		botones[amuleto] = boton
	_actualizar()
	if not botones.is_empty():
		Tema.dar_foco(botones[Partida.amuletos_tenidos[0]])


func _actualizar() -> void:
	var sentado: bool = puede_cambiar()
	if Partida.amuletos_tenidos.is_empty():
		_aviso.text = "Todavía no tienes amuletos."
	elif sentado:
		_aviso.text = "Toca uno para ponerlo o quitarlo (%d de %d puestos)." % [Partida.amuletos_equipados.size(), Partida.MAX_EQUIPADOS]
	else:
		_aviso.text = "Siéntate en un banco para cambiarlos."
	for amuleto: StringName in botones:
		var puesto: bool = Partida.esta_equipado(amuleto)
		botones[amuleto].text = "%s: %s" % [nombre_de(amuleto), "puesto" if puesto else "guardado"]
		# De pie se ven pero no responden; sentado, uno que no cabe tampoco.
		botones[amuleto].disabled = not sentado or (not puesto and not Partida.puede_equipar(amuleto))


## Nombre para mostrar: los amuletos todavia no tienen ficha con nombre (llega con el contenido).
static func nombre_de(amuleto: StringName) -> String:
	return String(amuleto).capitalize()
