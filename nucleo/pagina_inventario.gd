class_name PaginaInventario
extends PaginaMarco
# Pagina Inventario del marco de menus: lo que el jugador lleva, solo para leer. Arriba vida, Inspiracion (numero y
# bloques juntos) y PejeCoins; abajo el arma, lo perdido al morir, los simbolos de las habilidades y los mapas; a la
# derecha el detalle del arma o de la habilidad elegida. Solo tiene marco lo que se toca (regla 3 del estudio de UX):
# lo perdido y los mapas son texto. Nombres escritos, nunca sacados del id. La crea cada sala, como Amuletos.

## El arma es la habilidad pluma: sin ella no se ataca.
const ARMA: StringName = Habilidades.PLUMA
const NOMBRE_ARMA: String = "La Pluma"
const TEXTO_ARMA: String = "La pluma del Eterno, transformada en katana."
const KATANA: Texture2D = preload("res://nucleo/arte/katana.png")
## Lado del icono de los datos de arriba y del simbolo de una habilidad en su caja.
const LADO_DATO: float = 64.0

## Texto de cada dato por nombre ("Vida", "Lo perdido", ...). Publico para las pruebas.
var valores: Dictionary[String, String] = {}
## Las cajas de las habilidades que se tienen, por id. Publico para las pruebas.
var simbolos: Dictionary[StringName, Button] = {}
## La carta del arma (se toca solo si se tiene). Publica para las pruebas.
var carta_arma: Button = null

var _datos: Dictionary[String, Label] = {}
var _bloques: Control = null
var _habilidades: HBoxContainer = null
var _ninguna: Label = null


func _ready() -> void:
	super()
	var fondo: ColorRect = Tema.fondo_menu()
	add_child(fondo)
	var cuerpo: VBoxContainer = VBoxContainer.new()
	cuerpo.name = "Cuerpo"
	cuerpo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cuerpo.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	fondo.add_child(cuerpo)
	_acomodar_en_contenido(cuerpo)
	cuerpo.add_child(_crear_estado())
	var abajo: HBoxContainer = HBoxContainer.new()
	abajo.name = "Abajo"
	abajo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	abajo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	abajo.add_theme_constant_override(&"separation", int(2.0 * Tema.SEPARACION))
	cuerpo.add_child(abajo)
	var izquierda: VBoxContainer = VBoxContainer.new()
	izquierda.name = "Izquierda"
	izquierda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	izquierda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	izquierda.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	abajo.add_child(izquierda)
	var par: HBoxContainer = _fila_par("Arriba")
	izquierda.add_child(par)
	carta_arma = Button.new()
	carta_arma.name = "Arma"
	carta_arma.theme_type_variation = Tema.TARJETA
	carta_arma.toggle_mode = true
	carta_arma.custom_minimum_size.y = Tema.ALTO_TOQUE
	carta_arma.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	carta_arma.focus_entered.connect(elegir.bind(ARMA))
	carta_arma.pressed.connect(_al_pulsar.bind(ARMA))
	par.add_child(carta_arma)
	var texto_arma: Control = _dato_texto("Arma", null)
	carta_arma.add_child(texto_arma)
	texto_arma.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texto_arma.offset_left = Tema.MARGEN_DERECHO
	var miniatura: TextureRect = DetalleMenu.imagen_de(KATANA)
	miniatura.name = "Katana"
	miniatura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	carta_arma.add_child(miniatura)
	miniatura.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	miniatura.offset_left = -0.55 * DetalleMenu.ANCHO
	miniatura.offset_right = -Tema.SEPARACION
	par.add_child(_dato_texto("Lo perdido", IconoArticulo.crear(IconoArticulo.Forma.MONEDA, LADO_DATO, false)))
	var rotulo: Label = Label.new()
	rotulo.name = "RotuloHabilidades"
	rotulo.text = "Habilidades"
	rotulo.theme_type_variation = Tema.TENUE
	izquierda.add_child(rotulo)
	_habilidades = HBoxContainer.new()
	_habilidades.name = "Habilidades"
	_habilidades.custom_minimum_size.y = Tema.ALTO_TOQUE
	_habilidades.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_habilidades.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	izquierda.add_child(_habilidades)
	_ninguna = Label.new()
	_ninguna.name = "Ninguna"
	_ninguna.text = "Ninguna todavía"
	_ninguna.theme_type_variation = Tema.TENUE
	_ninguna.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	izquierda.add_child(_ninguna)
	var par_abajo: HBoxContainer = _fila_par("Abajo")
	izquierda.add_child(par_abajo)
	par_abajo.add_child(_dato_texto("Mapas", IconoArticulo.crear(IconoArticulo.Forma.MAPA, LADO_DATO, false)))
	_crear_detalle(abajo)


func id_pagina() -> StringName:
	return &"inventario"


func titulo_pagina() -> String:
	return "Inventario"


func mostrar_en_marco() -> void:
	super()
	_llenar()


## Elige el arma o una habilidad y llena el detalle. Solo se lee: el detalle no tiene boton.
func elegir(id: StringName) -> void:
	super(id)
	carta_arma.set_pressed_no_signal(id == ARMA)
	for habilidad: StringName in simbolos:
		simbolos[habilidad].set_pressed_no_signal(habilidad == id)
	if id == ARMA:
		var katana: TextureRect = DetalleMenu.imagen_de(KATANA)
		katana.custom_minimum_size = Vector2(DetalleMenu.ANCHO - DetalleMenu.SANGRIA, DetalleMenu.LADO_IMAGEN / 2.0)
		detalle.mostrar(NOMBRE_ARMA, katana, TEXTO_ARMA, "", "")
	else:
		detalle.mostrar(SimboloHabilidad.nombre_de(id), SimboloHabilidad.crear(id, DetalleMenu.LADO_IMAGEN),
				SimboloHabilidad.texto_de(id), "", "")


func _llenar() -> void:
	var tiene_arma: bool = Partida.tiene(ARMA)
	valores = {
		"Vida": "%d de %d" % [Partida.vidas, Partida.vidas_maximas],
		"Inspiración": "%d de %d" % [Partida.inspiracion, Partida.inspiracion_maxima],
		"PejeCoins": str(Partida.monedas),
		"Arma": NOMBRE_ARMA if tiene_arma else "Sin arma",
		"Mapas": _mapas(),
		"Lo perdido": perdido(Partida.mochila),
	}
	for nombre: String in _datos:
		_datos[nombre].text = valores[nombre]
	_bloques.queue_redraw()
	carta_arma.flat = not tiene_arma
	(carta_arma.get_node(^"Katana") as CanvasItem).visible = tiene_arma
	carta_arma.focus_mode = Control.FOCUS_ALL if tiene_arma else Control.FOCUS_NONE
	carta_arma.mouse_filter = Control.MOUSE_FILTER_STOP if tiene_arma else Control.MOUSE_FILTER_IGNORE
	for hijo: Node in _habilidades.get_children():
		hijo.free()
	simbolos.clear()
	for habilidad: StringName in SimboloHabilidad.ORDEN:
		if Partida.tiene(habilidad):
			simbolos[habilidad] = _caja_habilidad(habilidad)
			_habilidades.add_child(simbolos[habilidad])
	_habilidades.visible = not simbolos.is_empty()
	_ninguna.visible = simbolos.is_empty()
	var primero: StringName = ARMA if tiene_arma else (simbolos.keys()[0] as StringName if not simbolos.is_empty() else &"")
	if primero.is_empty():
		elegido = &""
		carta_arma.set_pressed_no_signal(false)
		detalle.limpiar()
		return
	elegir(primero)
	Tema.dar_foco(carta_arma if primero == ARMA else simbolos[primero])


## Lo perdido al morir ({sala, x, y, monto} de docs/contrato.md), en una linea, con el nombre de la zona y no su id.
static func perdido(mochila: Dictionary) -> String:
	var monto: Variant = mochila.get("monto")
	var sala: Variant = mochila.get("sala")
	# Como Partida.monto_mochila: un monto con decimales (guardado editado) se trunca.
	var cantidad: int = Guardado.entero(monto, 0)
	if cantidad <= 0:
		return "Nada"
	if typeof(sala) != TYPE_STRING:
		return "%d PejeCoins" % cantidad
	var id_sala: String = sala
	return "%d PejeCoins en %s" % [cantidad, Sala.nombre_de(id_sala)]


# Los mapas que se tienen, por el nombre de su zona.
func _mapas() -> String:
	var nombres: PackedStringArray = []
	for mapa: String in Partida.mapas:
		nombres.append(Sala.nombre_de(mapa + "_"))
	return ", ".join(nombres) if not nombres.is_empty() else "Ninguno"


func _crear_estado() -> HBoxContainer:
	var estado: HBoxContainer = HBoxContainer.new()
	estado.name = "Estado"
	estado.custom_minimum_size.y = Tema.ALTO_TOQUE
	estado.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Tema.raya_abajo(estado)
	estado.add_child(_dato_texto("Vida", IconoArticulo.crear(IconoArticulo.Forma.VIDA, LADO_DATO, false)))
	var inspiracion: Control = _dato_texto("Inspiración", null)
	_bloques = Control.new()
	_bloques.name = "Bloques"
	_bloques.custom_minimum_size = Vector2(160.0, 14.0)
	_bloques.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bloques.draw.connect(_dibujar_bloques)
	inspiracion.get_node(^"Textos").add_child(_bloques)
	estado.add_child(inspiracion)
	estado.add_child(_dato_texto("PejeCoins", IconoArticulo.crear(IconoArticulo.Forma.MONEDA, LADO_DATO, false)))
	return estado


# La Inspiracion tambien en bloques, la unidad de los textos (hallazgo 5): uno por INSPIRACION_POR_GOLPE.
func _dibujar_bloques() -> void:
	var cuantos: int = ceili(Partida.inspiracion_maxima / float(Partida.INSPIRACION_POR_GOLPE))
	if cuantos <= 0:
		return
	var ancho: float = 50.0
	var hueco: float = 5.0
	for i: int in range(cuantos):
		var caja: Rect2 = Rect2(i * (ancho + hueco), 1.0, ancho, 12.0)
		var lleno: float = clampf((Partida.inspiracion - i * Partida.INSPIRACION_POR_GOLPE) / float(Partida.INSPIRACION_POR_GOLPE), 0.0, 1.0)
		if lleno > 0.0:
			_bloques.draw_rect(Rect2(caja.position, Vector2(ancho * lleno, caja.size.y)), Tema.GIS)
		_bloques.draw_rect(caja, Tema.GASTADO, false, 2.0)


# Un dato: icono opcional, el valor y debajo su nombre en tenue. Guarda la etiqueta del valor en _datos.
func _dato_texto(nombre: String, icono: Control) -> HBoxContainer:
	var dato: HBoxContainer = HBoxContainer.new()
	dato.name = nombre.replace("ó", "o").replace(" ", "")
	dato.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dato.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	if icono != null:
		icono.name = "Icono"
		icono.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dato.add_child(icono)
	var textos: VBoxContainer = VBoxContainer.new()
	textos.name = "Textos"
	textos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	textos.alignment = BoxContainer.ALIGNMENT_CENTER
	textos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.add_theme_constant_override(&"separation", 0)
	dato.add_child(textos)
	var etiqueta_nombre: Label = Label.new()
	etiqueta_nombre.name = "Nombre"
	etiqueta_nombre.text = nombre
	etiqueta_nombre.theme_type_variation = Tema.TEXTO_FICHA
	etiqueta_nombre.modulate = Tema.GIS_TENUE
	etiqueta_nombre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.add_child(etiqueta_nombre)
	var etiqueta_valor: Label = Label.new()
	etiqueta_valor.name = "Valor"
	etiqueta_valor.theme_type_variation = Tema.DESTACADA
	etiqueta_valor.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta_valor.max_lines_visible = 2
	etiqueta_valor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.add_child(etiqueta_valor)
	_datos[nombre] = etiqueta_valor
	return dato


func _fila_par(nombre: String) -> HBoxContainer:
	var par: HBoxContainer = HBoxContainer.new()
	par.name = nombre
	par.custom_minimum_size.y = Tema.ALTO_TOQUE
	par.mouse_filter = Control.MOUSE_FILTER_IGNORE
	par.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	return par


func _caja_habilidad(habilidad: StringName) -> Button:
	var caja: Button = Button.new()
	caja.name = String(habilidad)
	caja.theme_type_variation = Tema.TARJETA
	caja.toggle_mode = true
	caja.custom_minimum_size = Vector2.ONE * Tema.ALTO_TOQUE
	caja.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caja.tooltip_text = SimboloHabilidad.nombre_de(habilidad)
	caja.focus_entered.connect(elegir.bind(habilidad))
	caja.pressed.connect(_al_pulsar.bind(habilidad))
	var simbolo: SimboloHabilidad = SimboloHabilidad.crear(habilidad, LADO_DATO)
	simbolo.name = "Simbolo"
	caja.add_child(simbolo)
	simbolo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return caja
