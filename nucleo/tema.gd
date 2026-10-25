class_name Tema
extends RefCounted
# Tema de los menus (menu principal, Configuracion, pausa y zona de pruebas), en gis: letra Cabin Sketch (gruesa en
# los titulos), opciones sin caja de 108 px de alto, que en el telefono mas chico probado (Senwa S50, densidad 240)
# son los 48 dp que pide Android, y el foco como flechita y subrayado de gis (EstiloGis, visible tras usar control o
# teclado, Tema.dar_foco). Se arma en codigo y se asigna solo a las raices de los menus, asi no toca el HUD. Da tambien
# las columnas segun el ancho de la vista, el area util dentro del area segura y las piezas que repiten los menus
# (boton, encabezado con Volver, titulo y raya).

## Alto minimo de todo lo que se toca, en px de la vista.
const ALTO_TOQUE: float = 108.0
## Celda de las cuadriculas de opciones y separacion entre columnas y entre filas.
const CELDA: Vector2 = Vector2(420.0, ALTO_TOQUE)
# 16 y no 24: con 24 tres columnas de Configuracion median 1308 de los 1312 px del S50 y la izquierda se cortaba
# (captura del 12-oct-2026).
const SEPARACION: float = 16.0
const SEPARACION_FILAS: float = 12.0
## Margen minimo alrededor del menu, dentro del area segura: nada pegado a las orillas.
const MARGEN_LATERAL: float = 64.0
const MARGEN_VERTICAL: float = 16.0
## Ancho de Volver y separacion de la barra de arriba de cada menu. configuracion.tscn y zona_pruebas.tscn
## repiten estos numeros en su vista previa del editor: un .tscn no cita constantes.
const ANCHO_VOLVER: float = 240.0
const SEPARACION_ARRIBA: int = 32
## Letra de botones (16 dp en el S50) y de etiquetas y avisos (14 dp).
const LETRA: int = 36
const LETRA_CHICA: int = 33
const LETRA_TITULO: int = 48
## Alto de una linea con LETRA en Cabin Sketch (get_height, medido el 17-oct-2026; con la fuente por omision era 50).
const ALTO_LETRA: float = 43.0
## Margen izquierdo de cada opcion: ahi va la flechita del foco (EstiloGis), y el texto empieza despues.
const MARGEN_OPCION: float = 52.0
const MARGEN_DERECHO: float = 24.0
## Distancia minima del borde izquierdo a la columna del menu principal (margen_columna).
const COLUMNA_MINIMA: float = 128.0

## Letra de los menus: Cabin Sketch (SIL Open Font License, nucleo/fuentes/ofl.txt). Se carga con load() al armar el
## tema y no con preload: en un clon limpio, la primera importacion compila este script antes de importar las fuentes
## y el preload fallaba (copia del 17-oct-2026).
const RUTA_FUENTE: String = "res://nucleo/fuentes/cabin_sketch.ttf"
const RUTA_FUENTE_GRUESA: String = "res://nucleo/fuentes/cabin_sketch_bold.ttf"
## Gis blanco (texto con foco o elegido, titulos) y gis gastado (las demas opciones, rayas de fondo).
const GIS: Color = Color(0.93, 0.94, 0.91, 1.0)
const GASTADO: Color = Color(0.64, 0.67, 0.64, 1.0)
## Relleno oscuro de una tarjeta (ranuras, caja de dialogo), para leerse sobre el juego.
const FONDO_TARJETA: Color = Color(0.03, 0.04, 0.05, 0.86)
const BORDE_BOTON: Color = Color(0.27, 0.27, 0.3, 1.0)
## Opacidad del negro que tapa el juego detras de un menu (fondo_menu).
const VELO: float = 0.85
## Dorado comun: el nombre de quien habla.
const DORADO: Color = Color(0.88, 0.69, 0.29, 1.0)
## Lo encendido o lleno (lo lleno de las barras).
const ENCENDIDO: Color = Color(0.3, 0.6, 0.42, 1.0)
## Variaciones del tema: titulo en gis grueso (Label), Volver con su flecha y tarjeta con caja de gis (Button).
const TITULO: StringName = &"Titulo"
const VOLVER: StringName = &"Volver"
const TARJETA: StringName = &"Tarjeta"
## Pestana de una fila de categorias (Button): margenes cortos para que quepan siete, la elegida subrayada y el foco en
## una caja de gis.
const PESTANA: StringName = &"Pestana"
## Opcion con una linea de detalle debajo (Button): el texto arriba y ALTO_DETALLE px libres abajo, que dibuja quien la
## usa (las salas de la zona de pruebas), con LETRA_DETALLE.
const CON_DETALLE: StringName = &"ConDetalle"
const ALTO_DETALLE: float = 36.0
const LETRA_DETALLE: int = 28
## Barra ancha (volumen y brillo): nombre de la variacion, grosor de la pista y diametro del pomo, en px de la vista.
const BARRA_ANCHA: StringName = &"BarraAncha"
const GROSOR_PISTA: float = 24.0
const POMO: int = 72
## Fila apagada de una ListaElegir (lo que no alcanza en la tienda), en gris pero con foco, para leer su descripcion; y
## el dato de su derecha (el precio), tambien en gris.
const FILA_APAGADA: StringName = &"FilaApagada"
const DATO_APAGADO: StringName = &"DatoApagado"
const GRIS_APAGADO: Color = Color(0.45, 0.47, 0.45, 1.0)
## Titulos mas grandes que TITULO, variaciones de el (Label): el nombre del juego en el menu principal y el de la pausa.
const TITULO_JUEGO: StringName = &"TituloJuego"
const LETRA_TITULO_JUEGO: int = 96
const TITULO_PAUSA: StringName = &"TituloPausa"
const LETRA_TITULO_PAUSA: int = 72
## Etiquetas (Label): con la letra de los botones (titulo de una ranura, pregunta de la tienda), la pregunta de una
## confirmacion de las ranuras, el nombre de quien habla en dorado y un nombre tenue (las filas del inventario).
const DESTACADA: StringName = &"Destacada"
const PREGUNTA: StringName = &"Pregunta"
const LETRA_PREGUNTA: int = 40
const QUIEN: StringName = &"Quien"
const TENUE: StringName = &"Tenue"
const GIS_TENUE: Color = Color(GIS, 0.7)
## Opcion con la letra de las etiquetas (Button): la Zona de pruebas del menu principal.
const OPCION_CHICA: StringName = &"OpcionChica"
## Boton de un solo simbolo (Button, de TARJETA): + y - del mapa, en Cabin Sketch. La caja lo separa de lo dibujado
## debajo. Letra de 96 sin margenes de arriba y abajo: el + mide 35 px de ancho y el boton 113 de alto (a la letra de
## los botones el + media unos 12 px; capturas del 20-oct-2026).
const SIMBOLO: StringName = &"Simbolo"
const LETRA_SIMBOLO: int = 96
const MARGEN_SIMBOLO: float = 0.0
## Opcion centrada (Button), como la pausa de Silksong: sin flechita fija a la izquierda ni subrayado, y con el foco una
## flechita de gis a cada lado (EstiloGis.Forma.LADOS). Las flechas van en las orillas del boton, no del texto: el boton
## mide lo que su texto (sin ancho minimo) para que queden pegadas a el.
const OPCION_CENTRADA: StringName = &"OpcionCentrada"
## Adornos de gis (Panel) para arriba y abajo de una lista de opciones (la pausa); miden lo que dicen estas constantes.
const ADORNO_ANCHO: StringName = &"AdornoAncho"
const ADORNO_CHICO: StringName = &"AdornoChico"
const TAMANO_ADORNO_ANCHO: Vector2 = Vector2(520.0, 36.0)
const TAMANO_ADORNO_CHICO: Vector2 = Vector2(200.0, 24.0)
## Fila de la lista de la tienda (Button), como las de los dos juegos: a la izquierda el icono del articulo y la moneda
## (los dibuja IconoArticulo, hijo de la fila) y el precio como texto; sin flechita ni subrayado, porque la fila con el
## foco la marca la franja. FILA_TIENDA_APAGADA es la misma en gris (lo que no alcanza).
const FILA_TIENDA: StringName = &"FilaTienda"
const FILA_TIENDA_APAGADA: StringName = &"FilaTiendaApagada"
## Lado del icono del articulo y de la moneda en una fila de la tienda, y la separacion entre ellos y el precio.
const LADO_ICONO_FILA: float = 56.0
const LADO_MONEDA_FILA: float = 28.0
const SEPARACION_ICONO: float = 12.0
## Franja de gis (Panel) de la fila elegida de la tienda: relleno claro, una raya arriba y otra abajo, a ALTO_ORILLA_FRANJA
## px de cada orilla de la fila, con un adorno chico sobre cada raya (EstiloGis.Forma.FRANJA).
const FRANJA: StringName = &"Franja"
const ALTO_ORILLA_FRANJA: float = 20.0
const RELLENO_FRANJA: Color = Color(GIS, 0.1)

static var _tema: Theme = null


## El tema de los menus, el mismo objeto para todos.
static func crear() -> Theme:
	if _tema != null:
		return _tema
	var tema: Theme = Theme.new()
	tema.default_font = load(RUTA_FUENTE) as Font
	tema.default_font_size = LETRA
	var vacia: StyleBoxEmpty = _vacia(MARGEN_OPCION)
	var elegida: EstiloGis = _gis(EstiloGis.Forma.SUBRAYADO, GIS, MARGEN_OPCION)
	var foco: EstiloGis = _gis(EstiloGis.Forma.MARCA, GIS, MARGEN_OPCION)
	# Sin caja: el texto en gis gastado y, con el foco, encima o presionado (encendido: la categoria o el personaje
	# elegidos), en gis blanco; lo presionado ademas subrayado.
	tema.set_stylebox(&"normal", &"Button", vacia)
	tema.set_stylebox(&"hover", &"Button", vacia)
	tema.set_stylebox(&"pressed", &"Button", elegida)
	tema.set_stylebox(&"hover_pressed", &"Button", elegida)
	tema.set_stylebox(&"disabled", &"Button", vacia)
	tema.set_stylebox(&"focus", &"Button", foco)
	tema.set_font_size(&"font_size", &"Button", LETRA)
	tema.set_color(&"font_color", &"Button", GASTADO)
	for color: StringName in [&"font_hover_color", &"font_pressed_color", &"font_focus_color", &"font_hover_pressed_color"]:
		tema.set_color(color, &"Button", GIS)
	tema.set_color(&"font_disabled_color", &"Button", GRIS_APAGADO)
	tema.set_color(&"font_color", &"Label", GIS)
	tema.set_font_size(&"font_size", &"Label", LETRA_CHICA)
	tema.set_type_variation(TITULO, &"Label")
	tema.set_font(&"font", TITULO, load(RUTA_FUENTE_GRUESA) as Font)
	tema.set_font_size(&"font_size", TITULO, LETRA_TITULO)
	_volver(tema)
	_tarjeta(tema)
	_simbolo(tema)
	_pestana(tema)
	_con_detalle(tema)
	var caja_foco: EstiloGis = _gis(EstiloGis.Forma.CAJA, GIS, 0.0)
	tema.set_stylebox(&"focus", &"HSlider", caja_foco)
	_barra_ancha(tema, caja_foco)
	tema.set_type_variation(FILA_APAGADA, &"Button")
	for estado: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed"]:
		tema.set_stylebox(estado, FILA_APAGADA, vacia)
	for color: StringName in [&"font_color", &"font_hover_color", &"font_pressed_color", &"font_focus_color", &"font_hover_pressed_color"]:
		tema.set_color(color, FILA_APAGADA, GRIS_APAGADO)
	tema.set_type_variation(DATO_APAGADO, &"Label")
	tema.set_color(&"font_color", DATO_APAGADO, GRIS_APAGADO)
	_etiquetas(tema)
	_opcion_centrada(tema)
	_adornos(tema)
	_fila_tienda(tema)
	# Cada opcion de un menu emergente (copiar y pegar del campo del nombre) tambien mide ALTO_TOQUE: letra mas
	# separacion.
	tema.set_font_size(&"font_size", &"PopupMenu", LETRA)
	tema.set_constant(&"v_separation", &"PopupMenu", int(ALTO_TOQUE - ALTO_LETRA))
	_tema = tema
	return _tema


## Columnas que caben en un ancho util, entre minimo y maximo.
static func columnas(ancho_util: float, ancho_celda: float, separacion: float, minimo: int, maximo: int) -> int:
	return clampi(floori((ancho_util + separacion) / (ancho_celda + separacion)), minimo, maximo)


## El rectangulo de la vista donde va un menu: el area segura (recorte de camara) menos los margenes minimos.
static func area_util(vista: Vector2) -> Rect2:
	var segura: Rect2 = DisposicionControles.area_segura(vista)
	return segura.grow_individual(-MARGEN_LATERAL, -MARGEN_VERTICAL, -MARGEN_LATERAL, -MARGEN_VERTICAL)


## Pone el foco en un control de un menu. Si lo ultimo que se uso fue el dedo no lo dibuja (grab_focus con
## hide_focus): con el dedo no hace falta la marca, y la primera flecha o el primer movimiento del control la
## muestra (`classes/class_control.rst:38`). Si fue un control o el teclado, se ve desde que se abre el menu.
static func dar_foco(control: Control) -> void:
	control.grab_focus(not UltimaEntrada.con_control())


## Distancia del borde izquierdo a la columna del menu principal: el area util mas MARGEN_LATERAL, y al
## menos COLUMNA_MINIMA, para que no quede bajo la camara de un telefono con el recorte a la izquierda.
static func margen_columna(vista: Vector2) -> float:
	return maxf(COLUMNA_MINIMA, area_util(vista).position.x + MARGEN_LATERAL)


## El area util menos la franja de abajo que reserva quien abre el menu (el aviso de recursos).
static func area_menu(vista: Vector2, reservado_abajo: float) -> Rect2:
	var area: Rect2 = area_util(vista)
	if reservado_abajo > 0.0:
		area.end.y = minf(area.end.y, vista.y - reservado_abajo)
	return area


## Fondo de un menu armado en codigo, sin agregar: negro con alfa (VELO por omision) a pantalla completa, llamado Fondo
## y con el tema de los menus, para ser la raiz de su rama de UI. Detiene los toques (mouse_filter por omision).
static func fondo_menu(alfa: float = VELO) -> ColorRect:
	var fondo: ColorRect = ColorRect.new()
	fondo.name = "Fondo"
	fondo.color = Color(0.0, 0.0, 0.0, alfa)
	fondo.theme = crear()
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return fondo


## Dibuja cadena en lienzo centrada a lo ancho sobre base.x, con su linea base en base.y; la altura la pone quien llama.
static func texto_centrado(lienzo: CanvasItem, fuente: Font, cadena: String, base: Vector2, letra: int, color: Color) -> void:
	var ancho: float = fuente.get_string_size(cadena, HORIZONTAL_ALIGNMENT_LEFT, -1, letra).x
	lienzo.draw_string(fuente, base - Vector2(ancho / 2.0, 0.0), cadena, HORIZONTAL_ALIGNMENT_LEFT, -1, letra, color)


static func boton(texto: String, tamano: Vector2) -> Button:
	var nuevo: Button = Button.new()
	nuevo.text = texto
	nuevo.custom_minimum_size = tamano
	return nuevo


## Un adorno de gis (ADORNO_ANCHO o ADORNO_CHICO), sin agregar: mide lo que dice el tema, no toma el foco ni los toques.
static func adorno(variacion: StringName) -> PanelContainer:
	var nuevo: PanelContainer = PanelContainer.new()
	nuevo.name = String(variacion)
	nuevo.theme_type_variation = variacion
	nuevo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nuevo.focus_mode = Control.FOCUS_NONE
	return nuevo


## Barra de arriba de un menu armado en codigo: Volver a la izquierda y el titulo, con el aspecto de encabezado().
## Sus hijos se llaman Volver y Titulo, para quien necesite tomarlos.
static func barra_arriba(titulo: String, al_volver: Callable) -> HBoxContainer:
	var arriba: HBoxContainer = HBoxContainer.new()
	arriba.name = "Arriba"
	arriba.add_theme_constant_override(&"separation", SEPARACION_ARRIBA)
	var volver: Button = boton("Volver", Vector2(ANCHO_VOLVER, ALTO_TOQUE))
	volver.name = "Volver"
	volver.pressed.connect(al_volver)
	arriba.add_child(volver)
	var etiqueta: Label = Label.new()
	etiqueta.name = "Titulo"
	etiqueta.text = titulo
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiqueta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arriba.add_child(etiqueta)
	encabezado(arriba)
	return arriba


## El encabezado unico de los menus: a una barra con hijos Volver (Button) y Titulo (Label), la flecha de Volver, el
## boton del control de la accion icono dentro de Volver (IconoBoton; vacio, sin el), el titulo en gis grueso y una
## raya de gis debajo. Lo usan barra_arriba, las barras escritas en un .tscn (Configuracion, zona de pruebas) y la del
## marco de menus, para que todas se vean igual. Una sola vez por barra: si Volver ya tiene su Icono, no pone otro.
static func encabezado(arriba: Control, icono: StringName = &"volver") -> void:
	var volver: Button = arriba.get_node_or_null(^"Volver") as Button
	if volver != null:
		volver.theme_type_variation = VOLVER
		if not icono.is_empty() and volver.get_node_or_null(^"Icono") == null:
			IconoBoton.en_boton(volver, icono)
	var titulo: Label = arriba.get_node_or_null(^"Titulo") as Label
	if titulo != null:
		titulo.theme_type_variation = TITULO
	raya_abajo(arriba)


## Raya de gis gastado bajo un control (el encabezado), de lado a lado, dibujada en su draw.
static func raya_abajo(control: Control) -> void:
	var dibujar: Callable = func() -> void:
		var azar: RandomNumberGenerator = RandomNumberGenerator.new()
		azar.seed = hash(Vector2i(control.size))
		var y: float = control.size.y + 4.0
		var puntos: PackedVector2Array = EstiloGis.puntos(azar, Vector2(-8.0, y), Vector2(control.size.x, y - 2.0), 1.0)
		control.draw_polyline(puntos, Color(GASTADO, 0.6), 2.0, true)
	control.draw.connect(dibujar)
	control.resized.connect(control.queue_redraw)
	control.queue_redraw()


## Acomoda un Control de pantalla completa al area util de su vista, ahora, cada vez que la ventana cambia y cada vez
## que cambia su minimo: una etiqueta con ajuste de linea lo infla un momento al armarse y, sin esto, se quedaba
## alto de mas (1298 px en una vista de 720, 12-oct-2026). Se llama una vez, en el _ready del control; se
## desconecta solo al salir del arbol.
static func ajustar(control: Control) -> void:
	# Una funcion propia por control: un metodo estatico con bind no distingue un control de otro al conectar.
	var al_cambiar: Callable = func() -> void: _ajustar_ya(control)
	al_cambiar.call()
	var vista: Viewport = control.get_viewport()
	vista.size_changed.connect(al_cambiar)
	control.minimum_size_changed.connect(al_cambiar, CONNECT_DEFERRED)
	control.tree_exiting.connect(vista.size_changed.disconnect.bind(al_cambiar), CONNECT_ONE_SHOT)


static func _ajustar_ya(control: Control) -> void:
	var area: Rect2 = area_util(control.get_viewport_rect().size)
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.position = area.position
	control.size = area.size


# Variacion VOLVER: la flecha de gis hacia atras siempre a la vista (gastada; blanca con el foco, encima o presionado),
# y con el foco ademas el subrayado.
static func _volver(tema: Theme) -> void:
	tema.set_type_variation(VOLVER, &"Button")
	var gastada: EstiloGis = _gis(EstiloGis.Forma.ATRAS, GASTADO, MARGEN_OPCION)
	var blanca: EstiloGis = _gis(EstiloGis.Forma.ATRAS, GIS, MARGEN_OPCION)
	tema.set_stylebox(&"normal", VOLVER, gastada)
	tema.set_stylebox(&"hover", VOLVER, blanca)
	tema.set_stylebox(&"pressed", VOLVER, blanca)
	tema.set_stylebox(&"hover_pressed", VOLVER, blanca)
	tema.set_stylebox(&"focus", VOLVER, _gis(EstiloGis.Forma.SUBRAYADO, GIS, MARGEN_OPCION))


# Variacion TARJETA: un boton con contenido propio (ficha de ranura, caja de dialogo y sus opciones) en una caja de gis
# con relleno oscuro; con el foco, encima o presionado, la caja en gis blanco.
static func _tarjeta(tema: Theme) -> void:
	tema.set_type_variation(TARJETA, &"Button")
	_cajas_tarjeta(tema, TARJETA)
	tema.set_color(&"font_color", TARJETA, GIS)


# Variacion SIMBOLO: las cajas de TARJETA con margenes de arriba y abajo de MARGEN_SIMBOLO y LETRA_SIMBOLO.
static func _simbolo(tema: Theme) -> void:
	tema.set_type_variation(SIMBOLO, TARJETA)
	_cajas_tarjeta(tema, SIMBOLO, MARGEN_SIMBOLO)
	tema.set_font_size(&"font_size", SIMBOLO, LETRA_SIMBOLO)


# Las cajas de gis de una tarjeta para la variacion nombre; vertical menor que 0 deja los margenes de _margenes.
static func _cajas_tarjeta(tema: Theme, nombre: StringName, vertical: float = -1.0) -> void:
	var normal: EstiloGis = _gis(EstiloGis.Forma.CAJA, Color(GASTADO, 0.7), MARGEN_DERECHO)
	normal.fondo = FONDO_TARJETA
	normal.grosor = 2.4
	var clara: EstiloGis = _gis(EstiloGis.Forma.CAJA, GIS, MARGEN_DERECHO)
	clara.fondo = FONDO_TARJETA
	var foco: EstiloGis = _gis(EstiloGis.Forma.CAJA, GIS, MARGEN_DERECHO)
	foco.grosor = 3.4
	if vertical >= 0.0:
		for estilo: EstiloGis in [normal, clara, foco]:
			estilo.content_margin_top = vertical
			estilo.content_margin_bottom = vertical
	tema.set_stylebox(&"normal", nombre, normal)
	tema.set_stylebox(&"hover", nombre, clara)
	tema.set_stylebox(&"pressed", nombre, clara)
	tema.set_stylebox(&"hover_pressed", nombre, clara)
	tema.set_stylebox(&"disabled", nombre, normal)
	tema.set_stylebox(&"focus", nombre, foco)


# Variacion PESTANA: sin la flechita a la izquierda, para que quepan siete en la fila.
static func _pestana(tema: Theme) -> void:
	tema.set_type_variation(PESTANA, &"Button")
	var vacia: StyleBoxEmpty = _vacia(MARGEN_DERECHO)
	var elegida: EstiloGis = _gis(EstiloGis.Forma.SUBRAYADO, GIS, MARGEN_DERECHO)
	tema.set_stylebox(&"normal", PESTANA, vacia)
	tema.set_stylebox(&"hover", PESTANA, vacia)
	tema.set_stylebox(&"disabled", PESTANA, vacia)
	tema.set_stylebox(&"pressed", PESTANA, elegida)
	tema.set_stylebox(&"hover_pressed", PESTANA, elegida)
	tema.set_stylebox(&"focus", PESTANA, _gis(EstiloGis.Forma.CAJA, GIS, MARGEN_DERECHO))


# Variacion CON_DETALLE: los mismos trazos que un boton, con el contenido arriba; el subrayado del foco queda bajo el
# texto y el detalle va debajo.
static func _con_detalle(tema: Theme) -> void:
	tema.set_type_variation(CON_DETALLE, &"Button")
	var arriba: float = (ALTO_TOQUE - ALTO_LETRA) / 2.0 - ALTO_DETALLE / 2.0
	var abajo: float = ALTO_TOQUE + ALTO_DETALLE - ALTO_LETRA - arriba
	var normal: StyleBoxEmpty = _vacia(MARGEN_OPCION)
	var elegida: EstiloGis = _gis(EstiloGis.Forma.SUBRAYADO, GIS, MARGEN_OPCION)
	var foco: EstiloGis = _gis(EstiloGis.Forma.MARCA, GIS, MARGEN_OPCION)
	for estilo: StyleBox in [normal, elegida, foco]:
		estilo.content_margin_top = arriba
		estilo.content_margin_bottom = abajo
	for estado: StringName in [&"normal", &"hover", &"disabled"]:
		tema.set_stylebox(estado, CON_DETALLE, normal)
	for estado: StringName in [&"pressed", &"hover_pressed"]:
		tema.set_stylebox(estado, CON_DETALLE, elegida)
	tema.set_stylebox(&"focus", CON_DETALLE, foco)


# Variaciones de etiqueta y la opcion chica: solo cambian letra o color; TITULO_JUEGO y TITULO_PAUSA heredan de TITULO
# el gis grueso (una variacion puede salir de otra, classes/class_theme.rst:1173).
static func _etiquetas(tema: Theme) -> void:
	tema.set_type_variation(TITULO_JUEGO, TITULO)
	tema.set_font_size(&"font_size", TITULO_JUEGO, LETRA_TITULO_JUEGO)
	tema.set_type_variation(TITULO_PAUSA, TITULO)
	tema.set_font_size(&"font_size", TITULO_PAUSA, LETRA_TITULO_PAUSA)
	tema.set_type_variation(DESTACADA, &"Label")
	tema.set_font_size(&"font_size", DESTACADA, LETRA)
	tema.set_type_variation(PREGUNTA, &"Label")
	tema.set_font_size(&"font_size", PREGUNTA, LETRA_PREGUNTA)
	tema.set_type_variation(QUIEN, &"Label")
	tema.set_color(&"font_color", QUIEN, DORADO)
	tema.set_type_variation(TENUE, &"Label")
	tema.set_color(&"font_color", TENUE, GIS_TENUE)
	tema.set_type_variation(OPCION_CHICA, &"Button")
	tema.set_font_size(&"font_size", OPCION_CHICA, LETRA_CHICA)


# Variacion OPCION_CENTRADA: el mismo margen a los dos lados en todos los estados (Button acomoda el texto con el
# stylebox del estado y dibuja focus encima: si solo focus cambiara, el texto brincaria al enfocar), sin subrayado al
# presionar y con el foco una flechita a cada lado.
static func _opcion_centrada(tema: Theme) -> void:
	tema.set_type_variation(OPCION_CENTRADA, &"Button")
	var vacia: StyleBoxEmpty = _vacia(MARGEN_OPCION)
	vacia.content_margin_right = MARGEN_OPCION
	var foco: EstiloGis = _gis(EstiloGis.Forma.LADOS, GIS, MARGEN_OPCION)
	foco.content_margin_right = MARGEN_OPCION
	for estado: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"disabled"]:
		tema.set_stylebox(estado, OPCION_CENTRADA, vacia)
	tema.set_stylebox(&"focus", OPCION_CENTRADA, foco)


# Variaciones ADORNO_ANCHO y ADORNO_CHICO de PanelContainer: un PanelContainer sin hijos mide lo minimo de su stylebox,
# que son sus margenes; asi el adorno trae su tamano del tema y nadie repite los numeros.
static func _adornos(tema: Theme) -> void:
	for par: Array in [[ADORNO_ANCHO, TAMANO_ADORNO_ANCHO], [ADORNO_CHICO, TAMANO_ADORNO_CHICO]]:
		var nombre: StringName = par[0] as StringName
		var tamano: Vector2 = par[1] as Vector2
		var estilo: EstiloGis = EstiloGis.new()
		estilo.forma = EstiloGis.Forma.ADORNO
		estilo.color = GIS
		estilo.grosor = 2.4
		estilo.content_margin_left = tamano.x / 2.0
		estilo.content_margin_right = tamano.x / 2.0
		estilo.content_margin_top = tamano.y / 2.0
		estilo.content_margin_bottom = tamano.y / 2.0
		tema.set_type_variation(nombre, &"PanelContainer")
		tema.set_stylebox(&"panel", nombre, estilo)


# Variaciones FILA_TIENDA (Button), FILA_TIENDA_APAGADA (de ella, en gris) y FRANJA (Panel). La fila deja a la
# izquierda el lugar del icono y la moneda; su foco no dibuja nada (lo marca la franja, que se ve tambien tras un toque).
static func _fila_tienda(tema: Theme) -> void:
	tema.set_type_variation(FILA_TIENDA, &"Button")
	var vacia: StyleBoxEmpty = _vacia(MARGEN_DERECHO + LADO_ICONO_FILA + LADO_MONEDA_FILA + SEPARACION_ICONO * 2.0)
	for estado: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"disabled", &"focus"]:
		tema.set_stylebox(estado, FILA_TIENDA, vacia)
	tema.set_type_variation(FILA_TIENDA_APAGADA, FILA_TIENDA)
	for color: StringName in [&"font_color", &"font_hover_color", &"font_pressed_color", &"font_focus_color", &"font_hover_pressed_color"]:
		tema.set_color(color, FILA_TIENDA_APAGADA, GRIS_APAGADO)
	var franja: EstiloGis = EstiloGis.new()
	franja.forma = EstiloGis.Forma.FRANJA
	franja.color = GIS
	franja.grosor = 2.4
	franja.fondo = RELLENO_FRANJA
	franja.content_margin_top = ALTO_ORILLA_FRANJA
	franja.content_margin_bottom = ALTO_ORILLA_FRANJA
	tema.set_type_variation(FRANJA, &"Panel")
	tema.set_stylebox(&"panel", FRANJA, franja)


## Variacion BARRA_ANCHA de HSlider (volumen y brillo, mockup del 13-oct-2026): pista gruesa, lo lleno en verde y un
## pomo redondo de POMO px. Una variacion y no el HSlider del tema: las barras del editor de botones no cambian.
static func _barra_ancha(tema: Theme, foco: StyleBox) -> void:
	tema.set_type_variation(BARRA_ANCHA, &"HSlider")
	var pista: StyleBoxFlat = StyleBoxFlat.new()
	pista.bg_color = BORDE_BOTON
	pista.set_corner_radius_all(int(GROSOR_PISTA / 2.0))
	pista.content_margin_top = GROSOR_PISTA / 2.0
	pista.content_margin_bottom = GROSOR_PISTA / 2.0
	var lleno: StyleBoxFlat = pista.duplicate() as StyleBoxFlat
	lleno.bg_color = ENCENDIDO
	tema.set_stylebox(&"slider", BARRA_ANCHA, pista)
	tema.set_stylebox(&"grabber_area", BARRA_ANCHA, lleno)
	tema.set_stylebox(&"grabber_area_highlight", BARRA_ANCHA, lleno)
	tema.set_stylebox(&"focus", BARRA_ANCHA, foco)
	var pomo: ImageTexture = _circulo(POMO, GIS)
	tema.set_icon(&"grabber", BARRA_ANCHA, pomo)
	tema.set_icon(&"grabber_highlight", BARRA_ANCHA, pomo)
	tema.set_icon(&"grabber_disabled", BARRA_ANCHA, pomo)


static func _circulo(diametro: int, color: Color) -> ImageTexture:
	var imagen: Image = Image.create_empty(diametro, diametro, false, Image.FORMAT_RGBA8)
	var radio: float = diametro / 2.0
	for y: int in range(diametro):
		for x: int in range(diametro):
			# Borde suavizado de 1 px.
			var d: float = Vector2(x + 0.5 - radio, y + 0.5 - radio).length()
			imagen.set_pixel(x, y, Color(color, clampf(radio - d, 0.0, 1.0)))
	return ImageTexture.create_from_image(imagen)


# Con la letra de 36 (ALTO_LETRA) los margenes de arriba y abajo dan los 108 px del toque.
static func _margenes(estilo: StyleBox, izquierdo: float) -> void:
	estilo.content_margin_left = izquierdo
	estilo.content_margin_right = MARGEN_DERECHO
	estilo.content_margin_top = (ALTO_TOQUE - ALTO_LETRA) / 2.0
	estilo.content_margin_bottom = (ALTO_TOQUE - ALTO_LETRA) / 2.0


static func _vacia(izquierdo: float) -> StyleBoxEmpty:
	var vacia: StyleBoxEmpty = StyleBoxEmpty.new()
	_margenes(vacia, izquierdo)
	return vacia


static func _gis(forma: EstiloGis.Forma, color: Color, izquierdo: float) -> EstiloGis:
	var estilo: EstiloGis = EstiloGis.new()
	estilo.forma = forma
	estilo.color = color
	_margenes(estilo, izquierdo)
	return estilo
