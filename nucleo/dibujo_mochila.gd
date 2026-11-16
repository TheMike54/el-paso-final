class_name DibujoMochila
extends Control
# Mochila de gis de la pagina Utiles: solo linea, sin relleno, dibujada en codigo como los demas trazos de los menus.
# Encima lleva los 4 cupos (los pone PantallaUtiles con cupo_rect), en una rejilla de 2 por 2 sobre el cuerpo.
# Un solo _draw: los trazos tiemblan con una semilla fija, asi no cambian de un cuadro a otro.

## Tamano del dibujo; los cupos se miden contra el.
const TAMANO: Vector2 = Vector2(344.0, 460.0)
## Lado de un cupo (tocable: mas que Tema.ALTO_TOQUE) y espacio entre dos.
const LADO_CUPO: float = 110.0
const SEPARACION_CUPO: float = 12.0
## Esquina de arriba a la izquierda del primer cupo.
const ORIGEN_CUPOS: Vector2 = Vector2(56.0, 172.0)
const GROSOR: float = 3.5


func _init() -> void:
	custom_minimum_size = TAMANO
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER


## Rectangulo del cupo indice (0 a 3, por filas) dentro del dibujo.
static func cupo_rect(indice: int) -> Rect2:
	var columna: int = indice % 2
	var fila: int = indice / 2
	var paso: float = LADO_CUPO + SEPARACION_CUPO
	return Rect2(ORIGEN_CUPOS + Vector2(columna * paso, fila * paso), Vector2.ONE * LADO_CUPO)


func _draw() -> void:
	var azar: RandomNumberGenerator = RandomNumberGenerator.new()
	azar.seed = 54
	# Cuerpo: lados rectos, base con esquinas chicas y la parte de arriba redonda.
	var cuerpo: PackedVector2Array = []
	cuerpo.append_array(_arco(Vector2(146.0, 182.0), 110.0, PI, 1.5 * PI))
	cuerpo.append_array(_arco(Vector2(198.0, 182.0), 110.0, 1.5 * PI, TAU))
	cuerpo.append_array(_arco(Vector2(290.0, 424.0), 18.0, 0.0, 0.5 * PI))
	cuerpo.append_array(_arco(Vector2(54.0, 424.0), 18.0, 0.5 * PI, PI))
	cuerpo.append(cuerpo[0])
	_trazo(azar, cuerpo)
	# Asa.
	_trazo(azar, _arco(Vector2(172.0, 66.0), 42.0, PI, TAU))
	# Tapa: curva de lado a lado bajo el asa, con la hebilla en medio.
	var tapa: PackedVector2Array = []
	for i: int in range(13):
		var t: float = i / 12.0
		tapa.append(Vector2(lerpf(52.0, 292.0, t), 150.0 - sin(t * PI) * 24.0))
	_trazo(azar, tapa)
	_trazo(azar, [Vector2(172.0, 126.0), Vector2(172.0, 146.0)])
	_trazo(azar, [Vector2(164.0, 146.0), Vector2(180.0, 146.0), Vector2(180.0, 160.0), Vector2(164.0, 160.0),
			Vector2(164.0, 146.0)])
	# Bolsas de los lados.
	_trazo(azar, [Vector2(36.0, 262.0), Vector2(14.0, 272.0), Vector2(4.0, 300.0), Vector2(4.0, 372.0),
			Vector2(14.0, 396.0), Vector2(36.0, 404.0)])
	_trazo(azar, [Vector2(308.0, 262.0), Vector2(330.0, 272.0), Vector2(340.0, 300.0), Vector2(340.0, 372.0),
			Vector2(330.0, 396.0), Vector2(308.0, 404.0)])


# Puntos de un arco de centro y radio entre dos angulos (en radianes, sentido de las manecillas en pantalla).
func _arco(centro: Vector2, radio: float, desde: float, hasta: float) -> PackedVector2Array:
	var puntos: PackedVector2Array = []
	for i: int in range(9):
		var angulo: float = lerpf(desde, hasta, i / 8.0)
		puntos.append(centro + Vector2(cos(angulo), sin(angulo)) * radio)
	return puntos


# Un trazo de gis por los puntos dados, tembloroso como el resto de los menus.
func _trazo(azar: RandomNumberGenerator, puntos: PackedVector2Array) -> void:
	var linea: PackedVector2Array = []
	for i: int in range(puntos.size() - 1):
		linea.append_array(EstiloGis.puntos(azar, puntos[i], puntos[i + 1], 1.0))
	draw_polyline(linea, Tema.GIS, GROSOR, true)
