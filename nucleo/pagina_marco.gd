class_name PaginaMarco
extends CanvasLayer
# Base de las paginas del marco de menus (MarcoMenus): capa, grupo pagina_marco, correr en pausa y el estado abierta.
# El marco les habla con llamadas tipadas a esta clase en lugar de call() por nombre, que el validador no revisa.
# Tambien da lo que comparten Amuletos, Utiles e Inventario: el panel de detalle, elegir sin cambiar nada, las filas
# de equipo y el acomodo en el area de contenido. Vive en el nucleo: mapa/ la extiende (PantallaMapa).

## Capa de las paginas: debajo de la barra del marco (MarcoMenus.CAPA).
const CAPA: int = ModalPausa.CAPA

## A la vista dentro del marco. Publico para los guiones.
var abierta: bool = false
## El panel de la derecha, en las paginas que lo usan (null en las demas). Publico para las pruebas.
var detalle: DetalleMenu = null
## Lo que muestra el detalle.
var elegido: StringName = &""


# Una pagina que define su _ready empieza con super(): sin eso no entra al grupo y el marco no la encuentra.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = CAPA
	add_to_group(MarcoMenus.GRUPO_PAGINAS)
	visible = false


## Id estable de la pagina (el de MarcoMenus.PAGINAS). Cada pagina lo da.
func id_pagina() -> StringName:
	return &""


## Nombre en la barra del marco. Cada pagina lo da.
func titulo_pagina() -> String:
	return ""


## El marco la muestra con el juego ya detenido. Una pagina que llena algo al mostrarse llama a super() primero.
func mostrar_en_marco() -> void:
	abierta = true
	visible = true


## El marco la quita de la vista al cambiar de pagina y al cerrarse.
func ocultar_de_marco() -> void:
	abierta = false
	visible = false


## Sentado en un banco de esta sala; las paginas de equipo comparten esta regla.
func puede_cambiar() -> bool:
	return Jugador.sentado(get_tree())


## Elige algo de la pagina y llena el detalle, sin cambiar nada. Cada pagina con detalle lo da.
func elegir(id: StringName) -> void:
	elegido = id


# Pone control (hijo de un Control que no es contenedor) en MarcoMenus.area_contenido: dentro del area segura, sin las
# flechas ni la barra, con MARGEN_VERTICAL arriba y abajo. Se repite si la ventana cambia. Una vez, ya en el arbol.
func _acomodar_en_contenido(control: Control) -> void:
	var al_cambiar: Callable = func() -> void:
		var vista: Vector2 = control.get_viewport_rect().size
		var area: Rect2 = MarcoMenus.area_contenido(vista, DisposicionControles.area_segura(vista))
		control.set_anchors_preset(Control.PRESET_TOP_LEFT)
		control.position = area.position + Vector2(0.0, Tema.MARGEN_VERTICAL)
		control.size = area.size - Vector2(0.0, 2.0 * Tema.MARGEN_VERTICAL)
	al_cambiar.call()
	var ventana: Viewport = control.get_viewport()
	ventana.size_changed.connect(al_cambiar)
	control.tree_exiting.connect(ventana.size_changed.disconnect.bind(al_cambiar), CONNECT_ONE_SHOT)


# El detalle de la derecha, conectado a _al_accion, agregado a padre.
func _crear_detalle(padre: Control) -> void:
	detalle = DetalleMenu.new()
	detalle.accion_pulsada.connect(_al_accion)
	padre.add_child(detalle)


# El boton del detalle. Cada pagina con accion lo da.
func _al_accion() -> void:
	pass


# Un toque o A sobre una fila: la elige y, si hay accion, lleva el foco al boton del detalle (con el control, A otra
# vez actua).
func _al_pulsar(id: StringName) -> void:
	elegir(id)
	if detalle != null and detalle.accion.visible:
		Tema.dar_foco(detalle.accion)


# Etiqueta de la pagina sin agregar: el mensaje de pagina vacia, centrado y tenue.
func _crear_vacio(texto: String) -> Label:
	var vacio: Label = Label.new()
	vacio.name = "Vacio"
	vacio.text = texto
	vacio.theme_type_variation = Tema.TENUE
	vacio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vacio.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vacio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vacio.visible = false
	return vacio


# Una fila de equipo (amuleto o util) sin agregar: icono, nombre en hasta 2 lineas, el costo en circulos si costo es
# mayor que 0, el estado (Dice) y la marca de en uso. Tocarla o darle el foco solo la elige; la elegida queda
# encendida (toggle_mode, lo pone _marcar_elegido).
func _fila_equipo(id: StringName, nombre: String, icono: Control, costo: int) -> Button:
	var boton: Button = Button.new()
	boton.name = String(id)
	boton.custom_minimum_size.y = Tema.ALTO_TOQUE
	boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boton.theme_type_variation = Tema.TARJETA
	boton.toggle_mode = true
	boton.focus_entered.connect(elegir.bind(id))
	boton.pressed.connect(_al_pulsar.bind(id))
	var fila: HBoxContainer = HBoxContainer.new()
	fila.name = "Ficha"
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_theme_constant_override(&"separation", int(Tema.SEPARACION_ICONO))
	boton.add_child(fila)
	fila.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fila.offset_left = Tema.MARGEN_DERECHO
	fila.offset_right = -Tema.MARGEN_DERECHO
	icono.name = "Icono"
	icono.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_child(icono)
	var textos: VBoxContainer = VBoxContainer.new()
	textos.name = "Textos"
	textos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textos.alignment = BoxContainer.ALIGNMENT_CENTER
	textos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.add_theme_constant_override(&"separation", 0)
	fila.add_child(textos)
	var etiqueta: Label = Label.new()
	etiqueta.name = "Nombre"
	etiqueta.text = nombre
	etiqueta.theme_type_variation = Tema.TEXTO_FICHA
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.max_lines_visible = 2
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.add_child(etiqueta)
	var estado: HBoxContainer = HBoxContainer.new()
	estado.name = "Estado"
	estado.mouse_filter = Control.MOUSE_FILTER_IGNORE
	estado.add_theme_constant_override(&"separation", int(Tema.SEPARACION_ICONO))
	textos.add_child(estado)
	if costo > 0:
		# El costo en circulos, la misma unidad que la carga (hallazgo 6 del estudio de UX).
		var circulos: Circulos = Circulos.new()
		circulos.name = "Costo"
		circulos.poner(costo, costo)
		estado.add_child(circulos)
	var dice: Label = Label.new()
	dice.name = "Dice"
	dice.theme_type_variation = Tema.TEXTO_FICHA
	dice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	estado.add_child(dice)
	# La marca de gis de lo que esta en uso: se ve sin leer (hallazgo 3).
	var marca: MarcaUso = MarcaUso.new()
	marca.name = "Marca"
	fila.add_child(marca)
	return boton


# Pinta una fila de _fila_equipo: su estado, la marca y, apagada, el texto y el icono en gris.
func _pintar_fila(boton: Button, dice: String, en_uso: bool, apagada: bool) -> void:
	var fila: Node = boton.get_node(^"Ficha")
	var variacion: StringName = Tema.TEXTO_FICHA_APAGADO if apagada else Tema.TEXTO_FICHA
	(fila.get_node(^"Textos/Nombre") as Label).theme_type_variation = variacion
	var etiqueta: Label = fila.get_node(^"Textos/Estado/Dice") as Label
	etiqueta.theme_type_variation = variacion
	etiqueta.text = dice
	(fila.get_node(^"Marca") as MarcaUso).encender(en_uso)
	var icono: Control = fila.get_node(^"Icono") as Control
	if icono is IconoArticulo:
		(icono as IconoArticulo).apagado = apagada
		icono.queue_redraw()
	else:
		icono.modulate = Tema.GRIS_APAGADO if apagada else Color.WHITE


# Enciende solo la fila elegida.
func _marcar_elegido(botones: Dictionary[StringName, Button]) -> void:
	for id: StringName in botones:
		botones[id].set_pressed_no_signal(id == elegido)


# Un icono de equipo del lado pedido, sin agregar: la textura de la ficha o, sin ella, la forma de gis.
static func _icono_equipo(textura: Texture2D, forma: IconoArticulo.Forma, lado: float) -> Control:
	if textura != null:
		var imagen: TextureRect = DetalleMenu.imagen_de(textura)
		imagen.custom_minimum_size = Vector2.ONE * lado
		return imagen
	return IconoArticulo.crear(forma, lado, false)


# Indicador fijo bajo una lista desplazable: una flecha de gis hacia abajo mientras quede algo por ver (hallazgo 4 del
# estudio de UX: la fila cortada no basta). Se apaga con el alfa y no con visible, para que la lista no brinque.
func _indicador_mas(desplazable: ScrollContainer) -> Control:
	var flecha: Control = Control.new()
	flecha.name = "MasAbajo"
	flecha.custom_minimum_size.y = Tema.ALTO_DETALLE
	flecha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flecha.draw.connect(func() -> void:
		var centro: Vector2 = flecha.size / 2.0
		var lado: float = Tema.ALTO_DETALLE / 3.0
		var puntos: PackedVector2Array = [centro + Vector2(-lado, -lado / 2.0), centro + Vector2(0.0, lado / 2.0),
				centro + Vector2(lado, -lado / 2.0)]
		flecha.draw_polyline(puntos, Tema.GASTADO, IconoArticulo.GROSOR, true))
	var barra: VScrollBar = desplazable.get_v_scroll_bar()
	var revisar: Callable = func() -> void:
		flecha.modulate.a = 1.0 if barra.value + barra.page < barra.max_value - 1.0 else 0.0
	barra.changed.connect(revisar)
	barra.value_changed.connect(func(_valor: float) -> void: revisar.call())
	revisar.call()
	return flecha


# Lista desplazable de una columna o mas, sin agregar: el ScrollContainer (Desplazable) con su rejilla (Fichas).
func _crear_desplazable(columnas: int) -> ScrollContainer:
	var desplazable: ScrollContainer = ScrollContainer.new()
	desplazable.name = "Desplazable"
	desplazable.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desplazable.follow_focus = true
	desplazable.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	# Sin barra a la vista: se desplaza igual con el dedo y el foco, y el aviso de mas abajo dice que hay mas. La barra
	# se comia el ancho de las filas y quedaba encima de la marca de en uso.
	desplazable.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	var rejilla: GridContainer = GridContainer.new()
	rejilla.name = "Fichas"
	rejilla.columns = columnas
	rejilla.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rejilla.add_theme_constant_override(&"h_separation", int(Tema.SEPARACION_FILAS))
	rejilla.add_theme_constant_override(&"v_separation", int(Tema.SEPARACION_FILAS))
	desplazable.add_child(rejilla)
	return desplazable
