class_name Tema
extends RefCounted
# Tema de los menus (menu principal, Configuracion, pausa y zona de pruebas): botones de 108 px de alto, que en el
# telefono mas chico probado (Senwa S50, densidad 240) son los 48 dp que pide Android, letra de 36 px y el foco
# visible. Se arma en codigo y se asigna solo a las raices de los menus, asi no toca la interfaz del juego. Da
# tambien las columnas segun el ancho de la vista (1280 en 4:3 y 16:9, porque ahi crece el alto, hasta 1760 en
# 22:9) y el area util dentro del area segura.

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
## Letra de botones (16 dp en el S50) y de etiquetas y avisos (14 dp).
const LETRA: int = 36
const LETRA_CHICA: int = 33
const LETRA_TITULO: int = 48
## Alto de una linea con LETRA en la fuente del juego (medido el 12-oct-2026).
const ALTO_LETRA: float = 50.0

const FONDO_BOTON: Color = Color(0.17, 0.17, 0.2, 1.0)
const BORDE_BOTON: Color = Color(0.27, 0.27, 0.3, 1.0)
const FOCO: Color = Color(0.88, 0.69, 0.29, 1.0)

static var _tema: Theme = null


## El tema de los menus, el mismo objeto para todos.
static func crear() -> Theme:
	if _tema != null:
		return _tema
	var tema: Theme = Theme.new()
	tema.default_font_size = LETRA
	var normal: StyleBoxFlat = _caja(FONDO_BOTON, BORDE_BOTON, 2)
	var encima: StyleBoxFlat = _caja(FONDO_BOTON.lightened(0.08), BORDE_BOTON.lightened(0.2), 2)
	# Presionado (y encendido, en un interruptor o la categoria elegida) se ve mas claro; el dorado es solo del foco,
	# si no, con el control no se sabe donde esta el foco.
	var presionado: StyleBoxFlat = _caja(FONDO_BOTON.lightened(0.2), BORDE_BOTON.lightened(0.45), 2)
	var apagado: StyleBoxFlat = _caja(FONDO_BOTON.darkened(0.3), BORDE_BOTON.darkened(0.3), 2)
	var foco: StyleBoxFlat = _caja(Color(0.0, 0.0, 0.0, 0.0), FOCO, 4)
	foco.draw_center = false
	for tipo: StringName in [&"Button", &"CheckButton", &"OptionButton"]:
		tema.set_stylebox(&"normal", tipo, normal)
		tema.set_stylebox(&"hover", tipo, encima)
		tema.set_stylebox(&"pressed", tipo, presionado)
		tema.set_stylebox(&"hover_pressed", tipo, presionado)
		tema.set_stylebox(&"disabled", tipo, apagado)
		tema.set_stylebox(&"focus", tipo, foco)
		tema.set_font_size(&"font_size", tipo, LETRA)
		tema.set_color(&"font_disabled_color", tipo, Color(0.55, 0.55, 0.58, 1.0))
	tema.set_stylebox(&"focus", &"HSlider", foco)
	tema.set_font_size(&"font_size", &"Label", LETRA_CHICA)
	# Cada opcion de una lista desplegable (Recursos) tambien mide ALTO_TOQUE: letra mas separacion.
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


static func _caja(fondo: Color, borde: Color, grosor: int) -> StyleBoxFlat:
	var caja: StyleBoxFlat = StyleBoxFlat.new()
	caja.bg_color = fondo
	caja.border_color = borde
	caja.set_border_width_all(grosor)
	caja.set_corner_radius_all(10)
	# Con la letra de 36 (ALTO_LETRA) estos margenes dan los 108 px del toque.
	caja.content_margin_left = 24.0
	caja.content_margin_right = 24.0
	caja.content_margin_top = (ALTO_TOQUE - ALTO_LETRA) / 2.0
	caja.content_margin_bottom = (ALTO_TOQUE - ALTO_LETRA) / 2.0
	return caja
