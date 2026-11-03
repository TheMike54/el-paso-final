class_name PantallaAmuletos
extends PaginaMarco
# Pagina Amuletos del marco de menus (MarcoMenus), encima del juego detenido. Como en Hollow Knight, solo sentado en
# un banco se ponen y se quitan; de pie solo se consultan. PaginaMarco comparte la regla del banco; Partida
# cuida el catalogo, que se tengan y que quepan en la carga. Cada fila lee su FichaAmuleto (icono, nombre, costo) y la
# descripcion va al lado. La crea cada sala; el marco la abre y la cierra.

## Botones de la lista, por id del amuleto; publico para la prueba.
var botones: Dictionary[StringName, Button] = {}

var _descripcion: Label = null


func _ready() -> void:
	super()
	var panel: ColorRect = Tema.fondo_menu()
	add_child(panel)
	# Con muchos amuletos la lista no cabe a lo alto: se desplaza con el foco y con el dedo. Si cabe, el centro llena
	# la vista y la lista queda centrada como sin desplazamiento.
	var columna: VBoxContainer = _crear_columna_equipo(panel, 0.7)
	_crear_lista_equipo(columna)
	_descripcion = Label.new()
	_descripcion.name = "Descripcion"
	_descripcion.anchor_left = 0.72
	_descripcion.anchor_right = 1.0
	_descripcion.anchor_bottom = 1.0
	_descripcion.offset_top = MarcoMenus.ALTO_BARRA + Tema.MARGEN_VERTICAL
	_descripcion.offset_right = -Tema.MARGEN_LATERAL
	_descripcion.offset_bottom = -Tema.MARGEN_VERTICAL
	_descripcion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_descripcion.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(_descripcion)


func id_pagina() -> StringName:
	return &"amuletos"


func titulo_pagina() -> String:
	return "Amuletos"


func mostrar_en_marco() -> void:
	super()
	_mostrar()


## Pone o quita un amuleto, solo sentado. Devuelve si cambio algo.
func alternar(amuleto: StringName) -> bool:
	_describir(amuleto)
	if not puede_cambiar() or CatalogoEquipo.amuleto(amuleto) == null:
		return false
	var cambio: bool = Partida.desequipar(amuleto) if Partida.esta_equipado(amuleto) else Partida.equipar(amuleto)
	_actualizar()
	return cambio


func _mostrar() -> void:
	for hijo: Node in _lista.get_children():
		hijo.free()
	botones.clear()
	_descripcion.text = ""
	for amuleto: StringName in Partida.amuletos_tenidos:
		var ficha: FichaAmuleto = CatalogoEquipo.amuleto(amuleto)
		var boton: Button = Button.new()
		boton.name = String(amuleto)
		boton.custom_minimum_size = Tema.CELDA
		boton.theme_type_variation = Tema.TARJETA
		boton.focus_entered.connect(_describir.bind(amuleto))
		boton.gui_input.connect(_al_tocar.bind(amuleto))
		boton.pressed.connect(alternar.bind(amuleto))
		_lista.add_child(boton)
		var fila: HBoxContainer = HBoxContainer.new()
		fila.name = "Ficha"
		fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
		boton.add_child(fila)
		fila.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fila.offset_left = Tema.MARGEN_DERECHO
		fila.offset_right = -Tema.MARGEN_DERECHO
		fila.add_theme_constant_override(&"separation", int(Tema.SEPARACION_ICONO))
		var icono: Control = null
		if ficha != null and ficha.icono != null:
			var imagen: TextureRect = TextureRect.new()
			imagen.texture = ficha.icono
			imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			imagen.custom_minimum_size = Vector2.ONE * Tema.LADO_ICONO_FILA
			icono = imagen
		else:
			icono = IconoArticulo.crear(IconoArticulo.Forma.AMULETO, Tema.LADO_ICONO_FILA, false)
		icono.name = "Icono"
		icono.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fila.add_child(icono)
		var texto: Label = Label.new()
		texto.name = "Texto"
		texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		texto.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fila.add_child(texto)
		botones[amuleto] = boton
	_actualizar()
	if not botones.is_empty():
		Tema.dar_foco(botones[Partida.amuletos_tenidos[0]])


func _actualizar() -> void:
	var sentado: bool = puede_cambiar()
	if Partida.amuletos_tenidos.is_empty():
		_aviso.text = "Todavía no tienes amuletos."
	else:
		_aviso.text = _aviso_equipo(sentado, "carga", Partida.carga_usada(), Partida.carga_maxima)
	for amuleto: StringName in botones:
		var puesto: bool = Partida.esta_equipado(amuleto)
		var ficha: FichaAmuleto = CatalogoEquipo.amuleto(amuleto)
		var texto: Label = botones[amuleto].get_node(^"Ficha/Texto") as Label
		var nombre: String = ficha.nombre if ficha != null else nombre_de(amuleto)
		var costo: String = "costo %d" % ficha.costo if ficha != null else String(amuleto)
		texto.text = "%s\n%s · %s" % [nombre, costo, "puesto" if puesto else "guardado"]
		# De pie se ven pero no responden; sentado, uno que no cabe tampoco.
		botones[amuleto].disabled = ficha == null or not sentado or (not puesto and not Partida.puede_equipar(amuleto))
		texto.theme_type_variation = Tema.DATO_APAGADO if botones[amuleto].disabled else &""
		var icono: Control = botones[amuleto].get_node(^"Ficha/Icono") as Control
		if icono is IconoArticulo:
			(icono as IconoArticulo).apagado = botones[amuleto].disabled
			icono.queue_redraw()
		else:
			icono.modulate = Tema.GRIS_APAGADO if botones[amuleto].disabled else Color.WHITE


func _describir(amuleto: StringName) -> void:
	var ficha: FichaAmuleto = CatalogoEquipo.amuleto(amuleto)
	_descripcion.text = ficha.descripcion if ficha != null else ""


# Tambien permite consultar una fila deshabilitada (de pie o sin carga) al tocarla.
func _al_tocar(evento: InputEvent, amuleto: StringName) -> void:
	if ((evento is InputEventScreenTouch and (evento as InputEventScreenTouch).pressed)
			or (evento is InputEventMouseButton and (evento as InputEventMouseButton).pressed)):
		_describir(amuleto)


## Nombre de respaldo para un amuleto sin ficha en el catalogo.
static func nombre_de(amuleto: StringName) -> String:
	return String(amuleto).capitalize()
