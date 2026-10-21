class_name IconoArticulo
extends Control
# Icono de gis de un articulo de la tienda segun lo que entrega (vida, mapa, amuleto, habilidad, monedas), y la moneda
# de su precio, como las filas de las tiendas de los dos juegos. Se dibuja en codigo con trazos de EstiloGis hasta que
# haya arte (decision del plan nucleo-tienda-gis): un solo _draw por icono, que solo se repite al cambiar de tamano.

enum Forma {
	NINGUNA,
	MONEDA,
	VIDA,
	AMULETO,
	HABILIDAD,
	MAPA,
}

var forma: Forma = Forma.NINGUNA
## En gris (lo que no alcanza), como el precio de su fila.
var apagado: bool = false


## La forma que corresponde a un articulo: la del tipo de su Recompensa; NINGUNA si no entrega nada.
static func forma_de(articulo: ArticuloTienda) -> Forma:
	if articulo == null or articulo.recompensa == null:
		return Forma.NINGUNA
	match articulo.recompensa.tipo:
		Recompensa.Tipo.MONEDAS:
			return Forma.MONEDA
		Recompensa.Tipo.VIDA_MAXIMA:
			return Forma.VIDA
		Recompensa.Tipo.AMULETO:
			return Forma.AMULETO
		Recompensa.Tipo.HABILIDAD:
			return Forma.HABILIDAD
		Recompensa.Tipo.MAPA:
			return Forma.MAPA
	return Forma.NINGUNA


## Un icono nuevo, sin agregar, de lado px, que no toma toques ni foco.
static func crear(nueva: Forma, lado: float, gris: bool) -> IconoArticulo:
	var icono: IconoArticulo = IconoArticulo.new()
	icono.name = "Icono"
	icono.forma = nueva
	icono.apagado = gris
	icono.custom_minimum_size = Vector2(lado, lado)
	icono.size = Vector2(lado, lado)
	icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icono.focus_mode = Control.FOCUS_NONE
	return icono


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var azar: RandomNumberGenerator = RandomNumberGenerator.new()
	azar.seed = hash(Vector2i(size)) + int(forma)
	var color: Color = Tema.GRIS_APAGADO if apagado else Tema.GIS
	var c: Vector2 = size / 2.0
	var r: float = minf(size.x, size.y) / 2.0 - 3.0
	match forma:
		Forma.MONEDA:
			_circulo(azar, c, r, color)
			_circulo(azar, c, r * 0.55, Color(color, 0.7))
		Forma.VIDA:
			# Corazon: dos lobulos y la punta abajo.
			var puntos: PackedVector2Array = []
			for i: int in range(25):
				var t: float = TAU * i / 24.0
				var x: float = 16.0 * pow(sin(t), 3.0)
				var y: float = 13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)
				puntos.append(c + Vector2(x, -y - 1.5) * r / 17.0 + _temblor(azar, 0.8))
			draw_polyline(puntos, color, 3.0, true)
		Forma.AMULETO:
			# Un dije: la piedra redonda colgando de una argolla chica.
			_circulo(azar, c + Vector2(0.0, r * 0.25), r * 0.7, color)
			_circulo(azar, c + Vector2(0.0, r * 0.25), r * 0.3, Color(color, 0.7))
			_circulo(azar, c + Vector2(0.0, -r * 0.68), r * 0.22, color)
		Forma.HABILIDAD:
			# Un destello: cuatro rayos largos y cuatro cortos desde el centro.
			for i: int in range(8):
				var largo: float = r if i % 2 == 0 else r * 0.5
				var punta: Vector2 = c + Vector2(0.0, -largo).rotated(i * PI / 4.0)
				draw_polyline(EstiloGis.puntos(azar, c + (punta - c) * 0.18, punta, 0.8), color, 3.0, true)
		Forma.MAPA:
			# Un mapa doblado en tres, con la ruta punteada en medio.
			var alto: float = r * 0.75
			var x0: float = c.x - r
			var tercio: float = r * 2.0 / 3.0
			var esquinas: PackedVector2Array = []
			for i: int in range(4):
				var y: float = c.y - alto + (r * 0.18 if i % 2 == 1 else 0.0)
				esquinas.append(Vector2(x0 + i * tercio, y))
			for i: int in range(3, -1, -1):
				var y: float = c.y + alto + (r * 0.18 if i % 2 == 1 else 0.0)
				esquinas.append(Vector2(x0 + i * tercio, y))
			esquinas.append(esquinas[0])
			draw_polyline(esquinas, color, 3.0, true)
			for i: int in range(1, 3):
				draw_line(esquinas[i], esquinas[7 - i], Color(color, 0.6), 2.0, true)
			for i: int in range(3):
				draw_circle(c + Vector2(-r * 0.5 + i * r * 0.5, sin(i * 2.0) * r * 0.25), 2.5, color)


# Un circulo de gis: un trazo que da la vuelta y se pasa un poco, como hecho a mano.
func _circulo(azar: RandomNumberGenerator, centro: Vector2, radio: float, color: Color) -> void:
	var puntos: PackedVector2Array = []
	var n: int = maxi(12, int(TAU * radio / EstiloGis.PASO))
	for i: int in range(n + 2):
		puntos.append(centro + Vector2(radio, 0.0).rotated(TAU * i / n - 0.4) + _temblor(azar, 0.7))
	draw_polyline(puntos, color, 3.0, true)


func _temblor(azar: RandomNumberGenerator, cuanto: float) -> Vector2:
	return Vector2(azar.randf_range(-cuanto, cuanto), azar.randf_range(-cuanto, cuanto))
