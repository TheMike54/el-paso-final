class_name DatosMapa
extends RefCounted
# Cuentas del mapa, sin dibujo, para probarlas: que salas se dibujan (las mapeadas que estan en el indice),
# como se agrupan por zona, el rectangulo que las abarca y la transformacion que lo encaja en la pantalla. No
# conoce ninguna zona: trabaja con lo que diga el indice.

const COLORES_ZONA: Array[Color] = [Color(0.45, 0.55, 0.65), Color(0.6, 0.5, 0.4), Color(0.45, 0.6, 0.45), Color(0.6, 0.45, 0.6)]


## Salas dibujadas por zona: {zona: [id, ...]}, solo las mapeadas que el indice conoce, en orden de id.
static func por_zona(indice: IndiceSalas, mapeadas: Array[String]) -> Dictionary[String, Array]:
	var zonas: Dictionary[String, Array] = {}
	var ordenadas: Array[String] = mapeadas.duplicate()
	ordenadas.sort()
	for id: String in ordenadas:
		if not indice.rectangulos.has(id):
			continue
		var zona: String = Sala.zona_de(id)
		if not zonas.has(zona):
			zonas[zona] = []
		zonas[zona].append(id)
	return zonas


## Rectangulo que abarca las salas dadas (vacio si no hay ninguna).
static func abarca(indice: IndiceSalas, ids: Array) -> Rect2:
	var total: Rect2 = Rect2()
	var primero: bool = true
	for valor: Variant in ids:
		var id: String = str(valor)
		if not indice.rectangulos.has(id):
			continue
		var rectangulo: Rect2 = indice.rectangulos[id]
		total = rectangulo if primero else total.merge(rectangulo)
		primero = false
	return total


## Escala y desplazamiento que encajan mundo dentro de pantalla con margen, sin deformar: punto en pantalla =
## punto en el mundo * x + o (la x de la Transform2D lleva la escala).
static func encajar(mundo: Rect2, pantalla: Rect2, margen: float) -> Transform2D:
	if mundo.size.x <= 0.0 or mundo.size.y <= 0.0:
		return Transform2D(0.0, pantalla.get_center())
	var util: Rect2 = pantalla.grow(-margen)
	var escala: float = minf(util.size.x / mundo.size.x, util.size.y / mundo.size.y)
	var origen: Vector2 = util.get_center() - mundo.get_center() * escala
	return Transform2D(Vector2(escala, 0.0), Vector2(0.0, escala), origen)


## Nombre visible de la ficha, o el id con mayuscula si la zona no tiene ficha.
static func nombre_de_zona(indice: IndiceSalas, zona: String) -> String:
	return indice.nombres_zona[zona] if indice.nombres_zona.has(zona) else zona.capitalize()


## Color de la ficha, o la paleta alternada para las zonas sin ficha.
static func color_de_zona(indice: IndiceSalas, zona: String, numero: int) -> Color:
	return indice.colores_zona[zona] if indice.colores_zona.has(zona) else COLORES_ZONA[numero % COLORES_ZONA.size()]
