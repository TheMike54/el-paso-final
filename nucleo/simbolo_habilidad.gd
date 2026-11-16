class_name SimboloHabilidad
extends Control
# Simbolo de gis de una habilidad (impulso, doble salto, salto en pared, caida en picada, proyectil y pluma de mapa),
# dibujado en codigo en una caja de 56 que se escala al tamano del control. Tambien guarda el nombre y el texto escrito
# de cada habilidad para la pagina Inventario: no se sacan del id. Solo informa: no toma el foco ni los toques.

## Lado de la caja en que estan escritos los trazos.
const CAJA: float = 56.0
const GROSOR: float = 3.0

## Orden en que se muestran: el de la aventura.
const ORDEN: Array[StringName] = [Habilidades.IMPULSO, Habilidades.DOBLE_SALTO, Habilidades.SALTO_EN_PARED,
		Habilidades.CAIDA_EN_PICADA, Habilidades.PROYECTIL, Habilidades.PLUMA_MAPA]

const NOMBRES: Dictionary[StringName, String] = {
	Habilidades.IMPULSO: "Impulso",
	Habilidades.DOBLE_SALTO: "Doble salto",
	Habilidades.SALTO_EN_PARED: "Salto en pared",
	Habilidades.CAIDA_EN_PICADA: "Caída en picada",
	Habilidades.PROYECTIL: "Proyectil",
	Habilidades.PLUMA_MAPA: "Pluma de mapa",
}

const TEXTOS: Dictionary[StringName, String] = {
	Habilidades.IMPULSO: "Te lanzas hacia adelante a toda velocidad.",
	Habilidades.DOBLE_SALTO: "Saltas una vez más en el aire.",
	Habilidades.SALTO_EN_PARED: "Saltas desde una pared para seguir subiendo.",
	Habilidades.CAIDA_EN_PICADA: "Caes en picada y golpeas lo que esté abajo al aterrizar. Gasta Inspiración.",
	Habilidades.PROYECTIL: "Lanzas una bola a distancia. Gasta Inspiración.",
	Habilidades.PLUMA_MAPA: "Al descansar en un banco, dibuja en el mapa las salas que visitaste.",
}

## La habilidad que dibuja. Publica para las pruebas.
var habilidad: StringName = &""


static func crear(id: StringName, lado: float) -> SimboloHabilidad:
	var nuevo: SimboloHabilidad = SimboloHabilidad.new()
	nuevo.habilidad = id
	nuevo.custom_minimum_size = Vector2.ONE * lado
	nuevo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nuevo.focus_mode = Control.FOCUS_NONE
	return nuevo


## Nombre escrito de una habilidad; una sin nombre usa su id con mayusculas.
static func nombre_de(id: StringName) -> String:
	return NOMBRES.get(id, String(id).capitalize()) as String


static func texto_de(id: StringName) -> String:
	return TEXTOS.get(id, "") as String


func _draw() -> void:
	var escala: float = minf(size.x, size.y) / CAJA
	var desplazo: Vector2 = (size - Vector2.ONE * CAJA * escala) / 2.0
	for trazo: PackedVector2Array in _trazos():
		var puntos: PackedVector2Array = []
		for punto: Vector2 in trazo:
			puntos.append(desplazo + punto * escala)
		draw_polyline(puntos, Tema.GIS, GROSOR, true)


func _trazos() -> Array[PackedVector2Array]:
	match habilidad:
		Habilidades.IMPULSO:
			return [_t([6, 18, 14, 18.5, 22, 18]), _t([4, 28.5, 12, 28.4, 22.5, 28.4]), _t([6, 38.3, 14, 38, 21.5, 38]),
					_t([30.5, 13, 48.4, 28.5, 30, 43.3]), _t([24.5, 28.5, 32, 28, 40, 27.5, 47.6, 28])]
		Habilidades.DOBLE_SALTO:
			return [_t([12, 26, 27.5, 10, 44.5, 26.4]), _t([12, 41.6, 27.7, 26.4, 44.4, 42]), _t([17.5, 51, 27.5, 51.2, 37.5, 50.7])]
		Habilidades.SALTO_EN_PARED:
			return [_t([9.5, 3.5, 10, 20, 10, 36, 10, 52]), _t([10, 10.5, 7, 13.4, 3, 15.4]), _t([9.5, 24, 7, 27.6, 3.6, 30.5]),
					_t([10, 37.7, 6.3, 40.7, 2.8, 43.8]), _t([14.3, 46.5, 24.6, 29.7, 34.6, 19.6, 45.6, 13.7]),
					_t([37, 9.4, 46.5, 13.4, 41.7, 24.2])]
		Habilidades.CAIDA_EN_PICADA:
			return [_t([28, 4, 27.8, 20.6, 28.2, 38.2]), _t([16.2, 27, 28, 40, 39.7, 27.6]),
					_t([10.5, 49, 27.3, 49.6, 46, 48.3]), _t([4.4, 42.7, 8.5, 43.8, 12.7, 45]), _t([50.7, 42.2, 47, 43, 43.2, 45])]
		Habilidades.PROYECTIL:
			return [_circulo(Vector2(37.5, 28), 12.5), _t([4.6, 20, 12.4, 20, 20.2, 20]), _t([2, 28, 11.5, 27.8, 21.2, 28]),
					_t([5, 35.5, 12.3, 35.4, 20, 35.8])]
		Habilidades.PLUMA_MAPA:
			return [_t([28.2, 4.5, 43.6, 26.5, 34.6, 45.6, 22.2, 46.4, 12.5, 26.6, 28.2, 4.5]), _t([28, 4.7, 27.8, 15.2, 28, 25.3]),
					_circulo(Vector2(28.2, 28.6), 3), _t([20.3, 51.3, 27.3, 52.6, 36.3, 52.5])]
	return []


# Puntos x, y seguidos a un trazo.
func _t(valores: Array) -> PackedVector2Array:
	var puntos: PackedVector2Array = []
	for i: int in range(0, valores.size() - 1, 2):
		var x: float = valores[i] as float
		var y: float = valores[i + 1] as float
		puntos.append(Vector2(x, y))
	return puntos


func _circulo(centro: Vector2, radio: float) -> PackedVector2Array:
	var puntos: PackedVector2Array = []
	for i: int in range(17):
		var angulo: float = TAU * i / 16.0
		puntos.append(centro + Vector2(cos(angulo), sin(angulo)) * radio)
	return puntos
