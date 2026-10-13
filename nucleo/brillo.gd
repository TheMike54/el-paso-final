class_name Brillo
extends CanvasLayer
# Capa del ajuste de brillo, encima de todo (juego, interfaz, pausa y menus): un rectangulo que oscurece con negro o
# aclara con blanco segun el valor, y que se oculta en 1 para no costar nada. Un rectangulo y no un shader que lea la
# pantalla: en 2D ese shader copia la pantalla entera en cada cuadro, caro en un telefono de gama baja. La crea
# Arranque (no en headless); Ajustes.aplicar_brillo() le pasa el valor.

const CAPA: int = 100
## Lo mas que aclara: alfa del blanco con el brillo al maximo (provisional, lo juzga la persona en el telefono).
const ACLARADO_MAXIMO: float = 0.25

## La capa viva, o null si no hay (headless).
static var instancia: Brillo = null

var _rectangulo: ColorRect = null


func _ready() -> void:
	layer = CAPA
	_rectangulo = ColorRect.new()
	_rectangulo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rectangulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rectangulo)
	instancia = self
	poner(Ajustes.brillo)


func _exit_tree() -> void:
	if instancia == self:
		instancia = null


func poner(valor: float) -> void:
	var color: Color = color_para(valor)
	_rectangulo.color = color
	_rectangulo.visible = color.a > 0.0


## Color del rectangulo para un brillo: negro con alfa 1 - v por debajo de 1, blanco con alfa (v - 1) * 0,5 por encima
## (tope ACLARADO_MAXIMO) y transparente en 1.
static func color_para(valor: float) -> Color:
	var v: float = clampf(valor, Ajustes.BRILLO_MINIMO, Ajustes.BRILLO_MAXIMO)
	if v < 1.0:
		return Color(0.0, 0.0, 0.0, 1.0 - v)
	if v > 1.0:
		return Color(1.0, 1.0, 1.0, minf((v - 1.0) * 0.5, ACLARADO_MAXIMO))
	return Color(0.0, 0.0, 0.0, 0.0)
