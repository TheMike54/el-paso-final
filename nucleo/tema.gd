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
	var vacia: StyleBoxEmpty = TemaEstilos._vacia(MARGEN_OPCION)
	var elegida: EstiloGis = TemaEstilos._gis(EstiloGis.Forma.SUBRAYADO, GIS, MARGEN_OPCION)
	var foco: EstiloGis = TemaEstilos._gis(EstiloGis.Forma.MARCA, GIS, MARGEN_OPCION)
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
	TemaEstilos._volver(tema)
	TemaEstilos._tarjeta(tema)
	TemaEstilos._simbolo(tema)
	TemaEstilos._pestana(tema)
	TemaEstilos._con_detalle(tema)
	var caja_foco: EstiloGis = TemaEstilos._gis(EstiloGis.Forma.CAJA, GIS, 0.0)
	tema.set_stylebox(&"focus", &"HSlider", caja_foco)
	TemaEstilos._barra_ancha(tema, caja_foco)
	tema.set_type_variation(FILA_APAGADA, &"Button")
	for estado: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed"]:
		tema.set_stylebox(estado, FILA_APAGADA, vacia)
	for color: StringName in [&"font_color", &"font_hover_color", &"font_pressed_color", &"font_focus_color", &"font_hover_pressed_color"]:
		tema.set_color(color, FILA_APAGADA, GRIS_APAGADO)
	tema.set_type_variation(DATO_APAGADO, &"Label")
	tema.set_color(&"font_color", DATO_APAGADO, GRIS_APAGADO)
	_etiquetas(tema)
	TemaEstilos._opcion_centrada(tema)
	TemaEstilos._adornos(tema)
	TemaEstilos._fila_tienda(tema)
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
