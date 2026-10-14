class_name BotonValor
extends Button
# Boton de Configuracion con su nombre a la izquierda y su valor a la derecha, en una pastilla: «Sí» verde, «No»
# gris, un valor que cambia con cada toque (Recursos) en otro tono, o «›» si abre otra pantalla. Reemplaza a los
# interruptores (mockup del 13-oct-2026): el boton entero se toca, y el valor se lee con palabras, no con la forma
# de un interruptor. El boton no cambia nada solo: quien lo usa decide que hace el toque y le pone el valor.

enum Estilo {
	SI,
	NO,
	NEUTRO,
	ENLACE,
}

const ALTO_PASTILLA: float = 64.0
const RELLENO_PASTILLA: float = 20.0
## Espacio minimo entre el nombre y el valor, y la letra mas chica a la que baja el valor.
const SEPARACION: float = 16.0
const LETRA_MINIMA: int = 26
const COLOR_NO: Color = Color(0.36, 0.36, 0.4, 1.0)
const COLOR_NEUTRO: Color = Color(0.25, 0.4, 0.55, 1.0)
const LETRA_CLARA: Color = Color(0.92, 0.92, 0.94, 1.0)
const LETRA_ENLACE: Color = Color(0.75, 0.75, 0.8, 1.0)

## Lo que dice la pastilla («Sí», «Auto», «100 %»); con ENLACE va seguido de «›». Publico para la prueba.
var valor: String = "":
	set(nuevo):
		valor = nuevo
		queue_redraw()
var estilo: Estilo = Estilo.ENLACE:
	set(nuevo):
		estilo = nuevo
		queue_redraw()


func _ready() -> void:
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS


## Pone «Sí» o «No» con su color.
func poner_si_no(encendido: bool) -> void:
	estilo = Estilo.SI if encendido else Estilo.NO
	valor = "Sí" if encendido else "No"


func _draw() -> void:
	var fuente: Font = get_theme_font(&"font")
	var letra: int = get_theme_font_size(&"font_size")
	var margen: float = get_theme_stylebox(&"normal").content_margin_right
	var texto: String = (valor + "  ›").strip_edges() if estilo == Estilo.ENLACE else valor
	if texto.is_empty():
		return
	# Si el valor no cabe junto al nombre («Recursos» y «Auto (alto)» en 420 px), su letra baja hasta LETRA_MINIMA.
	var libre: float = size.x - 2.0 * margen - fuente.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, letra).x - SEPARACION
	var relleno: float = 0.0 if estilo == Estilo.ENLACE else 2.0 * RELLENO_PASTILLA
	var ancho_texto: float = fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, letra).x
	while ancho_texto + relleno > libre and letra > LETRA_MINIMA:
		letra -= 1
		ancho_texto = fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, letra).x
	var linea: float = fuente.get_ascent(letra) - (fuente.get_ascent(letra) + fuente.get_descent(letra)) / 2.0
	if estilo == Estilo.ENLACE:
		draw_string(fuente, Vector2(size.x - margen - ancho_texto, size.y / 2.0 + linea), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, letra, LETRA_ENLACE)
		return
	var ancho: float = ancho_texto + 2.0 * RELLENO_PASTILLA
	var caja: Rect2 = Rect2(size.x - margen - ancho, (size.y - ALTO_PASTILLA) / 2.0, ancho, ALTO_PASTILLA)
	var pastilla: StyleBoxFlat = StyleBoxFlat.new()
	pastilla.bg_color = Tema.ENCENDIDO if estilo == Estilo.SI else (COLOR_NO if estilo == Estilo.NO else COLOR_NEUTRO)
	pastilla.set_corner_radius_all(int(ALTO_PASTILLA / 2.0))
	draw_style_box(pastilla, caja)
	var color: Color = LETRA_CLARA
	draw_string(fuente, Vector2(caja.position.x + RELLENO_PASTILLA, size.y / 2.0 + linea), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, letra, color)
