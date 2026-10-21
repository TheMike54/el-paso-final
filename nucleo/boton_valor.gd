class_name BotonValor
extends Button
# Boton de Configuracion con su nombre a la izquierda y su valor a la derecha, en gis: con dos opciones (Sí / No,
# 60 / 120) se ven las dos y la que vale va en un ovalo de gis; un valor que cambia con cada toque (Recursos) va solo
# en su ovalo, y uno que abre otra pantalla, seguido de «›». El boton entero se toca y el valor se lee con palabras.
# El boton no cambia nada solo: quien lo usa decide que hace el toque y le pone el valor.

enum Estilo {
	SI,
	NO,
	NEUTRO,
	ENLACE,
}

## Espacio minimo entre el nombre y el valor, entre las opciones, y la letra mas chica a la que baja el valor.
const SEPARACION: float = 16.0
const SEPARACION_OPCIONES: float = 40.0
const LETRA_MINIMA: int = 26
## Cuanto sobra el ovalo alrededor de la palabra, a los lados y de alto.
const HOLGURA_OVALO: Vector2 = Vector2(16.0, 24.0)
## Opacidad de la opcion que no vale y del boton bloqueado: se lee, pero se ve que ahora no se puede cambiar.
const OPACIDAD_OTRA: float = 0.55
const OPACIDAD_BLOQUEADO: float = 0.45

## Lo que vale («Sí», «Auto (alto)», «100 %»); con ENLACE va seguido de «›». Publico para la prueba.
var valor: String = "":
	set(nuevo):
		valor = nuevo
		queue_redraw()
var estilo: Estilo = Estilo.ENLACE:
	set(nuevo):
		estilo = nuevo
		queue_redraw()
## Las opciones que se ven juntas, en orden («60», «120»); si valor no es una de ellas, se ve solo valor. Sí / No las
## pone poner_si_no.
var opciones: PackedStringArray = []:
	set(nuevas):
		opciones = nuevas
		queue_redraw()
## Se ve apagado, pero sigue tomando el foco y el toque (no es `disabled`): quien lo usa decide que explicar al tocarlo.
var bloqueado: bool = false:
	set(nuevo):
		bloqueado = nuevo
		modulate.a = OPACIDAD_BLOQUEADO if nuevo else 1.0


func _ready() -> void:
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS


## Pone «Sí» o «No», con las dos a la vista.
func poner_si_no(encendido: bool) -> void:
	opciones = ["Sí", "No"]
	estilo = Estilo.SI if encendido else Estilo.NO
	valor = "Sí" if encendido else "No"


func _draw() -> void:
	if valor.is_empty() and estilo != Estilo.ENLACE:
		return
	var fuente: Font = get_theme_font(&"font")
	var letra: int = get_theme_font_size(&"font_size")
	var margen: float = get_theme_stylebox(&"normal").content_margin_right
	var textos: PackedStringArray = [(valor + "  ›").strip_edges()] if estilo == Estilo.ENLACE else (opciones if opciones.has(valor) else PackedStringArray([valor]))
	# Si el valor no cabe junto al nombre («Recursos» y «Auto (alto)» en 420 px), su letra baja hasta LETRA_MINIMA.
	var izquierda: float = get_theme_stylebox(&"normal").content_margin_left
	var libre: float = size.x - izquierda - margen - fuente.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, letra).x - SEPARACION
	# El ovalo sobra HOLGURA_OVALO.x a cada lado de la palabra que vale.
	var holgura: float = 0.0 if estilo == Estilo.ENLACE else 2.0 * HOLGURA_OVALO.x
	while _ancho(textos, fuente, letra) + holgura > libre and letra > LETRA_MINIMA:
		letra -= 1
	var linea: float = fuente.get_ascent(letra) - (fuente.get_ascent(letra) + fuente.get_descent(letra)) / 2.0
	var x: float = size.x - margen - (HOLGURA_OVALO.x if estilo != Estilo.ENLACE and textos[-1] == valor else 0.0)
	var azar: RandomNumberGenerator = RandomNumberGenerator.new()
	azar.seed = hash(Vector2i(size))
	for i: int in range(textos.size() - 1, -1, -1):
		var texto: String = textos[i]
		var ancho: float = fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, letra).x
		x -= ancho
		var vale: bool = estilo != Estilo.ENLACE and texto == valor
		var color: Color = Tema.GIS if vale else (Tema.GASTADO if estilo == Estilo.ENLACE else Color(Tema.GASTADO, OPACIDAD_OTRA))
		draw_string(fuente, Vector2(x, size.y / 2.0 + linea), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, letra, color)
		if vale:
			_ovalo(azar, Vector2(x + ancho / 2.0, size.y / 2.0), Vector2(ancho / 2.0 + HOLGURA_OVALO.x, HOLGURA_OVALO.y))
		x -= SEPARACION_OPCIONES


func _ancho(textos: PackedStringArray, fuente: Font, letra: int) -> float:
	var total: float = SEPARACION_OPCIONES * (textos.size() - 1)
	for texto: String in textos:
		total += fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, letra).x
	return total


# Ovalo de gis a mano: un poco torcido y con la punta pasada, como se cierra al dibujarlo.
func _ovalo(azar: RandomNumberGenerator, centro: Vector2, radios: Vector2) -> void:
	var puntos: PackedVector2Array = PackedVector2Array()
	var pasos: int = 30
	for i: int in pasos + 4:
		var angulo: float = -2.4 + TAU * float(i) / pasos
		var r: Vector2 = radios * azar.randf_range(0.96, 1.04)
		puntos.append(centro + Vector2(cos(angulo) * r.x, sin(angulo) * r.y).rotated(-0.06))
	draw_polyline(puntos, Tema.GIS, 2.6, true)
