class_name ListaElegir
extends VBoxContainer
# Lista con foco que comparten el menu de la tienda y el de las estaciones del viaje rapido (decision del 17-oct-2026):
# arriba Volver y el titulo, un encabezado, las filas (nombre y un dato a la derecha, como el precio) y un pie (la
# descripcion de la fila con foco). Una fila apagada se ve en gris y toma el foco, pero no se elige. Se arma en codigo
# porque sus filas cambian; va bajo un Control con Tema.crear() y se acomoda con Tema.ajustar.

## Al elegir una fila que no esta apagada.
signal elegida(indice: int)
## Al cambiar la fila con foco (para el pie).
signal enfocada(indice: int)
## Solo el boton Volver; Circulo / B, pausa y Atras los lee el menu que la usa (MenuTienda, MenuEstaciones).
signal cerrada

## Ancho de la columna del dato, a la derecha de cada fila.
const ANCHO_DATO: float = 260.0

## Filas a la vista y cuales estan apagadas; publicas para las pruebas.
var filas: Array[Button] = []
var apagadas: Array[bool] = []
var titulo: Label = null
var encabezado: Label = null
var pie: Label = null
## Caja con las filas (desliza); quien la usa puede agregar algo a su lado o debajo (el detalle de la tienda).
var cuerpo: BoxContainer = null
var desliza: ScrollContainer = null
# La tienda usa su propio aspecto (variaciones de fila, franja en la elegida y el detalle junto a las filas, en cuerpo);
# sin tocar estas propiedades se ve como siempre.
## Aspecto de las filas; se fija antes de armar. Por omision, el Button del tema y Tema.FILA_APAGADA.
var variacion_fila: StringName = &""
var variacion_fila_apagada: StringName = Tema.FILA_APAGADA
## Con franja, la fila con el foco lleva un Panel Tema.FRANJA detras (hijo Franja); sigue a la vista tras un toque, cuando
## el foco no se dibuja. Se fija antes de armar.
var con_franja: bool = false

var _caja_filas: VBoxContainer = null


func _ready() -> void:
	add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	var arriba: HBoxContainer = Tema.barra_arriba("", func() -> void: cerrada.emit())
	add_child(arriba)
	titulo = arriba.get_node(^"Titulo") as Label
	encabezado = Label.new()
	encabezado.name = "Encabezado"
	encabezado.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(encabezado)
	cuerpo = BoxContainer.new()
	cuerpo.name = "Cuerpo"
	cuerpo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(cuerpo)
	desliza = ScrollContainer.new()
	desliza.name = "Desliza"
	desliza.follow_focus = true
	desliza.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	desliza.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desliza.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cuerpo.add_child(desliza)
	_caja_filas = VBoxContainer.new()
	_caja_filas.name = "Filas"
	_caja_filas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_caja_filas.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	desliza.add_child(_caja_filas)
	pie = Label.new()
	pie.name = "Pie"
	pie.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pie.custom_minimum_size = Vector2(0.0, Tema.ALTO_LETRA * 2.0)
	add_child(pie)


## Rehace las filas: nombres y datos del mismo largo; apagar dice cuales van en gris. El foco va a la fila foco o, si
## es -1 o esta apagada, a la primera que se puede elegir (o a la primera, si todas estan apagadas).
func armar(nombres: PackedStringArray, datos: PackedStringArray, apagar: Array[bool], foco: int = -1) -> void:
	for fila: Button in filas:
		fila.queue_free()
	filas.clear()
	apagadas.clear()
	for i: int in range(nombres.size()):
		var apagada: bool = i < apagar.size() and apagar[i]
		var fila: Button = Tema.boton(nombres[i], Vector2(0.0, Tema.ALTO_TOQUE))
		fila.name = "Fila%d" % i
		fila.alignment = HORIZONTAL_ALIGNMENT_LEFT
		fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.theme_type_variation = variacion_fila_apagada if apagada else variacion_fila
		var dato: Label = Label.new()
		dato.name = "Dato"
		dato.text = datos[i] if i < datos.size() else ""
		dato.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		dato.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		dato.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dato.theme_type_variation = Tema.DATO_APAGADO if apagada else &""
		# Pegado a la derecha de la fila: el boton no es un contenedor, asi que se acomoda con anclas.
		dato.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
		dato.offset_left = -ANCHO_DATO
		dato.offset_right = -24.0
		fila.add_child(dato)
		if con_franja:
			var franja: Panel = Panel.new()
			franja.name = "Franja"
			franja.theme_type_variation = Tema.FRANJA
			franja.show_behind_parent = true
			franja.mouse_filter = Control.MOUSE_FILTER_IGNORE
			franja.visible = false
			franja.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			fila.add_child(franja)
		fila.pressed.connect(elegir.bind(i))
		fila.focus_entered.connect(_al_enfocar_fila.bind(i))
		_caja_filas.add_child(fila)
		filas.append(fila)
		apagadas.append(apagada)
	var inicial: int = primera_elegible() if foco < 0 or foco >= filas.size() or apagadas[foco] else foco
	if inicial < 0 and not filas.is_empty():
		inicial = 0
	if inicial >= 0:
		Tema.dar_foco(filas[inicial])
		_al_enfocar_fila(inicial)


## La fila que lleva la franja (la ultima que tuvo el foco); -1 sin franja o sin filas.
func con_franja_en() -> int:
	for i: int in range(filas.size()):
		var franja: Control = filas[i].get_node_or_null(^"Franja") as Control
		if franja != null and franja.visible:
			return i
	return -1


## La primera fila que no esta apagada; -1 si no hay.
func primera_elegible() -> int:
	for i: int in range(apagadas.size()):
		if not apagadas[i]:
			return i
	return -1


## La fila con foco; -1 si ninguna lo tiene.
func con_foco() -> int:
	for i: int in range(filas.size()):
		if filas[i].has_focus():
			return i
	return -1


## Elige una fila: si no esta apagada emite elegida y devuelve true. Publica para las pruebas; en el juego la llama el
## boton de la fila.
func elegir(indice: int) -> bool:
	if indice < 0 or indice >= filas.size() or apagadas[indice]:
		return false
	elegida.emit(indice)
	return true


# La franja va con el foco y se queda en la ultima fila que lo tuvo (Volver no la quita): marca lo que dice el detalle.
func _al_enfocar_fila(indice: int) -> void:
	if con_franja:
		for i: int in range(filas.size()):
			(filas[i].get_node(^"Franja") as Control).visible = i == indice
	enfocada.emit(indice)
