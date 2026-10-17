class_name IconoBoton
extends Control
# Ayuda de un menu con el control: el boton de una accion del InputMap (con lo reasignado) dibujado como el del control
# que se esta usando (Xbox o PlayStation) o, con el teclado, su tecla, junto a un texto («Volver»). Tras un toque no
# se ve: en tactil los botones son los de la pantalla. Se dibuja con _draw, sin imagenes, como Silksong lo hace por accion.
# Dentro de un Button (en_boton) le reserva su lugar con un icono transparente del mismo ancho: el boton acomoda el texto.

## Formas del dibujo de un boton.
const DISCO: String = "disco"
const PASTILLA: String = "pastilla"
const COLOR_BOTON: Color = Color(0.93, 0.93, 0.95, 1.0)
const COLOR_SIMBOLO: Color = Color(0.1, 0.1, 0.12, 1.0)
## Letra de los botones de la cara de Xbox y de las pastillas, en px.
const LETRA_BOTON: int = 24
const SEPARACION_TEXTO: float = 12.0
const RELLENO_PASTILLA: float = 12.0
# Texto de cada boton que no es de la cara (indices de JoyButton), para Xbox y para PlayStation.
const PASTILLAS_XBOX: Dictionary[int, String] = {4: "View", 5: "Guia", 6: "Menu", 7: "LS", 8: "RS", 9: "LB", 10: "RB", 11: "Arriba", 12: "Abajo", 13: "Izq.", 14: "Der."}
const PASTILLAS_PLAYSTATION: Dictionary[int, String] = {4: "Share", 5: "PS", 6: "Options", 7: "L3", 8: "R3", 9: "L1", 10: "R1", 11: "Arriba", 12: "Abajo", 13: "Izq.", 14: "Der."}
const LETRAS_XBOX: PackedStringArray = ["A", "B", "X", "Y"]
const SIMBOLOS_PLAYSTATION: PackedStringArray = ["cruz", "circulo", "cuadrado", "triangulo"]

## Accion del InputMap cuyo boton se dibuja.
@export var accion: StringName = &"":
	set(valor):
		accion = valor
		_refrescar()
## Texto junto al boton; vacio, solo el boton.
@export var texto: String = "":
	set(valor):
		texto = valor
		_refrescar()
## true: el texto a la izquierda y el boton a la derecha (esquina inferior derecha de Silksong).
@export var boton_a_la_derecha: bool = false:
	set(valor):
		boton_a_la_derecha = valor
		_refrescar()

# Huecos transparentes por tamano, compartidos: el icono del Button que reserva el lugar.
static var _huecos: Dictionary[Vector2i, ImageTexture] = {}

# Lo que se dibuja ahora (dibujo()), y la entrada y los cambios del InputMap con que se calculo.
var _dibujo: Dictionary = {}
var _dispositivo: String = ""
var _cambios: int = -1


## Pone el boton de una accion dentro de un Button, a la izquierda o a la derecha de su texto.
static func en_boton(boton: Button, nombre_accion: StringName, a_la_derecha: bool = false) -> IconoBoton:
	var icono: IconoBoton = IconoBoton.new()
	icono.name = "Icono"
	icono.accion = nombre_accion
	boton.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT if a_la_derecha else HORIZONTAL_ALIGNMENT_LEFT
	icono.anchor_top = 0.5
	icono.anchor_bottom = 0.5
	icono.anchor_left = 1.0 if a_la_derecha else 0.0
	icono.anchor_right = icono.anchor_left
	icono.grow_vertical = Control.GROW_DIRECTION_BOTH
	icono.grow_horizontal = Control.GROW_DIRECTION_BEGIN if a_la_derecha else Control.GROW_DIRECTION_END
	boton.add_child(icono)
	return icono


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	process_mode = Node.PROCESS_MODE_ALWAYS
	_refrescar()


# Se compara un texto y un numero por cuadro: es mas simple que una senal y cuesta casi nada con pocos iconos.
func _process(_delta: float) -> void:
	if _dispositivo != UltimaEntrada.dispositivo or _cambios != Mando.cambios:
		_refrescar()


## Como se dibuja el boton de una accion para un dispositivo (UltimaEntrada.dispositivo): {forma, texto, simbolo};
## vacio si no se dibuja (tras un toque, o la accion no tiene boton para ese dispositivo). Publica para la prueba.
static func dibujo(nombre_accion: StringName, dispositivo: String) -> Dictionary:
	if not InputMap.has_action(nombre_accion):
		return {}
	if dispositivo == UltimaEntrada.TECLADO:
		for evento: InputEvent in InputMap.action_get_events(nombre_accion):
			var tecla: InputEventKey = evento as InputEventKey
			if tecla != null:
				var codigo: Key = tecla.physical_keycode if tecla.physical_keycode != KEY_NONE else tecla.keycode
				return {"forma": PASTILLA, "texto": OS.get_keycode_string(codigo), "simbolo": ""}
		return {}
	if dispositivo != Mando.XBOX and dispositivo != Mando.PLAYSTATION:
		return {}
	var playstation: bool = dispositivo == Mando.PLAYSTATION
	var boton: int = Mando.boton_de(nombre_accion)
	if boton >= 0 and boton < 4:
		if playstation:
			return {"forma": DISCO, "texto": "", "simbolo": SIMBOLOS_PLAYSTATION[boton]}
		return {"forma": DISCO, "texto": LETRAS_XBOX[boton], "simbolo": ""}
	if boton >= 0:
		var pastillas: Dictionary[int, String] = PASTILLAS_PLAYSTATION if playstation else PASTILLAS_XBOX
		return {"forma": PASTILLA, "texto": pastillas.get(boton, "Boton %d" % boton), "simbolo": ""}
	for evento: InputEvent in InputMap.action_get_events(nombre_accion):
		var eje: InputEventJoypadMotion = evento as InputEventJoypadMotion
		if eje != null:
			return {"forma": PASTILLA, "texto": _nombre_eje(eje.axis, playstation), "simbolo": ""}
	return {}


static func _nombre_eje(eje: JoyAxis, playstation: bool) -> String:
	match eje:
		JOY_AXIS_TRIGGER_LEFT:
			return "L2" if playstation else "LT"
		JOY_AXIS_TRIGGER_RIGHT:
			return "R2" if playstation else "RT"
		JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
			return "Stick izq."
	return "Stick der."


func _refrescar() -> void:
	if not is_node_ready():
		return
	_dispositivo = UltimaEntrada.dispositivo
	_cambios = Mando.cambios
	_dibujo = dibujo(accion, _dispositivo)
	visible = not _dibujo.is_empty()
	custom_minimum_size = _medir()
	var boton: Button = get_parent() as Button
	if boton != null:
		_reservar_en(boton)
	queue_redraw()


# Dentro de un Button: el hueco del ancho del icono y el icono sobre el, al borde del contenido del boton.
func _reservar_en(boton: Button) -> void:
	if not visible:
		boton.icon = null
		return
	var medida: Vector2i = Vector2i(ceili(custom_minimum_size.x), ceili(custom_minimum_size.y))
	if not _huecos.has(medida):
		var imagen: Image = Image.create_empty(medida.x, medida.y, false, Image.FORMAT_RGBA8)
		_huecos[medida] = ImageTexture.create_from_image(imagen)
	boton.icon = _huecos[medida]
	var margen: float = boton.get_theme_stylebox(&"normal").get_margin(SIDE_LEFT)
	offset_top = 0.0
	offset_bottom = 0.0
	if boton.icon_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		offset_right = -margen
		offset_left = -margen
	else:
		offset_left = margen
		offset_right = margen


# Alto de la letra del menu; el boton mide eso y el texto va a su lado.
func _medir() -> Vector2:
	if _dibujo.is_empty():
		return Vector2.ZERO
	var alto: float = Tema.ALTO_LETRA
	var ancho: float = _ancho_boton(alto)
	if not texto.is_empty():
		ancho += SEPARACION_TEXTO + get_theme_font(&"font", &"Label").get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1.0, _letra()).x
	return Vector2(ancho, alto)


func _ancho_boton(alto: float) -> float:
	if _dibujo["forma"] == DISCO:
		return alto
	var fuente: Font = get_theme_font(&"font", &"Label")
	return maxf(alto * 1.6, fuente.get_string_size(_dibujo["texto"] as String, HORIZONTAL_ALIGNMENT_LEFT, -1.0, LETRA_BOTON).x + RELLENO_PASTILLA * 2.0)


func _letra() -> int:
	return get_theme_font_size(&"font_size", &"Label")


func _notification(que: int) -> void:
	# El margen del Button y la letra salen del tema, que puede llegar despues de _ready.
	if que == NOTIFICATION_THEME_CHANGED:
		_refrescar()


# Se dibuja con el alto de la letra, centrado en lo que le de su contenedor (una fila de botones lo estira a 108).
func _draw() -> void:
	if _dibujo.is_empty():
		return
	var alto: float = minf(size.y, Tema.ALTO_LETRA)
	var arriba: float = (size.y - alto) / 2.0
	var ancho_boton: float = _ancho_boton(alto)
	var fuente: Font = get_theme_font(&"font", &"Label")
	var x_boton: float = size.x - ancho_boton if boton_a_la_derecha else 0.0
	_dibujar_boton(Rect2(x_boton, arriba, ancho_boton, alto), fuente)
	if texto.is_empty():
		return
	var x_texto: float = 0.0 if boton_a_la_derecha else ancho_boton + SEPARACION_TEXTO
	var base: float = arriba + (alto + fuente.get_ascent(_letra()) - fuente.get_descent(_letra())) / 2.0
	draw_string(fuente, Vector2(x_texto, base), texto, HORIZONTAL_ALIGNMENT_LEFT, -1.0, _letra(), get_theme_color(&"font_color", &"Label"))


func _dibujar_boton(caja: Rect2, fuente: Font) -> void:
	var centro: Vector2 = caja.get_center()
	if _dibujo["forma"] == PASTILLA:
		var estilo: StyleBoxFlat = StyleBoxFlat.new()
		estilo.bg_color = COLOR_BOTON
		estilo.set_corner_radius_all(int(caja.size.y / 2.0))
		draw_style_box(estilo, caja.grow(-caja.size.y * 0.1))
		_texto_centrado(fuente, _dibujo["texto"] as String, centro)
		return
	var radio: float = caja.size.y * 0.45
	draw_circle(centro, radio, COLOR_BOTON)
	var simbolo: String = _dibujo["simbolo"]
	if simbolo.is_empty():
		_texto_centrado(fuente, _dibujo["texto"] as String, centro)
		return
	# Los simbolos de PlayStation, trazados: la fuente del tema no los trae.
	var r: float = radio * 0.5
	var grosor: float = maxf(radio * 0.14, 2.0)
	match simbolo:
		"cruz":
			draw_line(centro + Vector2(-r, -r), centro + Vector2(r, r), COLOR_SIMBOLO, grosor, true)
			draw_line(centro + Vector2(-r, r), centro + Vector2(r, -r), COLOR_SIMBOLO, grosor, true)
		"circulo":
			draw_arc(centro, r, 0.0, TAU, 32, COLOR_SIMBOLO, grosor, true)
		"cuadrado":
			draw_rect(Rect2(centro - Vector2(r, r) * 0.9, Vector2(r, r) * 1.8), COLOR_SIMBOLO, false, grosor)
		"triangulo":
			var puntos: PackedVector2Array = [centro + Vector2(0.0, -r), centro + Vector2(r * 1.05, r * 0.75), centro + Vector2(-r * 1.05, r * 0.75), centro + Vector2(0.0, -r)]
			draw_polyline(puntos, COLOR_SIMBOLO, grosor, true)


func _texto_centrado(fuente: Font, cadena: String, centro: Vector2) -> void:
	var medida: Vector2 = fuente.get_string_size(cadena, HORIZONTAL_ALIGNMENT_LEFT, -1.0, LETRA_BOTON)
	var base: float = centro.y + (fuente.get_ascent(LETRA_BOTON) - fuente.get_descent(LETRA_BOTON)) / 2.0
	draw_string(fuente, Vector2(centro.x - medida.x / 2.0, base), cadena, HORIZONTAL_ALIGNMENT_LEFT, -1.0, LETRA_BOTON, COLOR_SIMBOLO)
