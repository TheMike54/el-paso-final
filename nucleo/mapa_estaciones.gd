class_name MapaEstaciones
extends Control
# Mapa de gis del viaje rapido, como el del Ciervo de Hollow Knight: un circulo por estacion en el centro de su sala, una
# linea entre cada una y la siguiente en el orden de la tabla, la del foco con un anillo y la actual en gris con «Aquí».
# Las posiciones se las da MenuEstaciones (las lee del indice del mapa); este solo encaja y pinta en un _draw medido
# contra size, que se rehace al cambiar la marca o el tamano. Solo decora: no toma el foco ni los toques.

## Espacio libre entre los circulos y la orilla: cabe el anillo y, debajo de la actual, «Aquí».
const MARGEN: float = 72.0
const RADIO: float = 18.0
const RADIO_ANILLO: float = 30.0
const GROSOR: float = 3.0
## Hueco entre una linea y el circulo al que llega.
const HUECO_LINEA: float = 8.0
const PUNTOS_CIRCULO: int = 28
const TEMBLOR_CIRCULO: float = 1.2

## Centro de la sala de cada estacion en el mundo, en el orden de la tabla.
var centros_mundo: PackedVector2Array = []
## Las lineas, como los indices de las estaciones que une cada una: el camino de la tabla (0-1, 1-2...).
var tramos: Array[Vector2i] = []
## La estacion marcada (la del foco) y la actual; -1, ninguna.
var marcada: int = -1
var actual: int = -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	resized.connect(queue_redraw)


## Pone las estaciones (centros en el mundo, en el orden de la tabla) y cual es la actual, y une cada una con la siguiente.
func poner(centros: PackedVector2Array, indice_actual: int) -> void:
	centros_mundo = centros.duplicate()
	actual = indice_actual
	tramos.clear()
	for i: int in range(1, centros_mundo.size()):
		tramos.append(Vector2i(i - 1, i))
	queue_redraw()


## Marca la estacion del foco; solo redibuja si cambia.
func marcar(indice: int) -> void:
	if indice == marcada:
		return
	marcada = indice
	queue_redraw()


## Los centros en pantalla: el rectangulo que abarca los del mundo, con la misma escala en los dos ejes para caber en size
## menos MARGEN, centrado. Un eje sin largo (todas en una fila, o una sola estacion) queda en medio.
func centros_en_pantalla() -> PackedVector2Array:
	var resultado: PackedVector2Array = []
	if centros_mundo.is_empty():
		return resultado
	var abarca: Rect2 = Rect2(centros_mundo[0], Vector2.ZERO)
	for centro: Vector2 in centros_mundo:
		abarca = abarca.expand(centro)
	var util: Vector2 = (size - Vector2(MARGEN, MARGEN) * 2.0).max(Vector2.ZERO)
	var escala: float = -1.0
	if abarca.size.x > 0.0:
		escala = util.x / abarca.size.x
	if abarca.size.y > 0.0:
		var en_y: float = util.y / abarca.size.y
		escala = en_y if escala < 0.0 else minf(escala, en_y)
	escala = maxf(escala, 0.0)
	for centro: Vector2 in centros_mundo:
		resultado.append(size / 2.0 + (centro - abarca.get_center()) * escala)
	return resultado


func _draw() -> void:
	var centros: PackedVector2Array = centros_en_pantalla()
	if centros.is_empty():
		return
	# La semilla sale del tamano, como en EstiloGis: el trazo no tiembla distinto en cada redibujo.
	var azar: RandomNumberGenerator = RandomNumberGenerator.new()
	azar.seed = hash(Vector2i(size))
	for tramo: Vector2i in tramos:
		var a: Vector2 = centros[tramo.x]
		var b: Vector2 = centros[tramo.y]
		var corte: float = RADIO + HUECO_LINEA
		if a.distance_to(b) <= corte * 2.0:
			continue
		var direccion: Vector2 = (b - a).normalized()
		draw_polyline(EstiloGis.puntos(azar, a + direccion * corte, b - direccion * corte, 1.0), Tema.GIS_TENUE, GROSOR, true)
	var fuente: Font = get_theme_font(&"font", &"Label")
	for i: int in range(centros.size()):
		var es_actual: bool = i == actual
		_circulo(azar, centros[i], RADIO, Tema.GRIS_APAGADO if es_actual else Tema.GIS)
		if es_actual:
			draw_circle(centros[i], RADIO * 0.4, Tema.GRIS_APAGADO)
			var base: Vector2 = centros[i] + Vector2(0.0, RADIO_ANILLO + fuente.get_ascent(Tema.LETRA_CHICA) + 4.0)
			Tema.texto_centrado(self, fuente, MenuEstaciones.AQUI, base, Tema.LETRA_CHICA, Tema.GRIS_APAGADO)
		if i == marcada:
			_circulo(azar, centros[i], RADIO_ANILLO, Tema.GIS)


# Un circulo de gis: una polilinea cerrada que se aparta un poco del radio.
func _circulo(azar: RandomNumberGenerator, centro: Vector2, radio: float, color: Color) -> void:
	var puntos: PackedVector2Array = []
	for i: int in range(PUNTOS_CIRCULO):
		var angulo: float = TAU * float(i) / PUNTOS_CIRCULO
		puntos.append(centro + Vector2.from_angle(angulo) * (radio + azar.randf_range(-TEMBLOR_CIRCULO, TEMBLOR_CIRCULO)))
	puntos.append(puntos[0])
	draw_polyline(puntos, color, GROSOR, true)
