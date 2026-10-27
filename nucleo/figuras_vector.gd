class_name FigurasVector
extends RefCounted
# Las figuras en vector aprobadas para el mapa y el HUD (mascara, mochila, PejeCoin y disquete), en una figura de 100
# de alto con el centro en (0, 0). Una pieza con contorno se rellena dos veces, entera en el color del contorno y
# encogida en el suyo, para no depender de las uniones de una linea; antes va el contorno claro, la silueta crecida.
# Los poligonos se arman una vez (Geometry2D.offset_polygon) y se dibujan escalados con draw_set_transform.

const MASCARA: StringName = &"mascara"
const MOCHILA: StringName = &"mochila"
const MONEDA: StringName = &"moneda"
const DISQUETE: StringName = &"disquete"
## Contorno claro de las cuatro: el borde de las salas del mapa, que separa la figura del fondo.
const CLARO: Color = Color("#e6d9b3")
const NEGRO: Color = Color("#0e0c10")
const PUNTOS_CURVA: int = 40
## Alto de la P de la PejeCoin, en unidades de la figura, y lo que mide una mayuscula respecto al tamano de letra.
const ALTO_P: float = 44.0
const MAYUSCULA: float = 0.72
const COLOR_P: Color = Color("#8c601c")

# nombre -> [piezas, silueta]; piezas: lista de [poligono, color, borde cerrado para suavizar la orilla].
static var _figuras: Dictionary[StringName, Array] = {}


## Dibuja la figura en el lienzo con su centro en centro y alto px de alto. modulado multiplica cada color (el alfa
## del desvanecido); brillo pone encima la silueta en blanco con ese alfa (la respiracion del disquete).
static func dibujar(lienzo: CanvasItem, nombre: StringName, centro: Vector2, alto: float,
		modulado: Color = Color.WHITE, brillo: float = 0.0) -> void:
	# Sin alto (un Control sin tamano en su primer _draw) no hay nada que dibujar, y la orilla dividiria entre 0.
	if alto <= 0.0:
		return
	var figura: Array = _figura(nombre)
	var escala: float = alto / 100.0
	lienzo.draw_set_transform(centro, 0.0, Vector2(escala, escala))
	for pieza: Array in figura[0] as Array:
		var color: Color = (pieza[1] as Color) * modulado
		lienzo.draw_colored_polygon(pieza[0] as PackedVector2Array, color)
		# draw_colored_polygon no suaviza la orilla: una linea de 1 px suavizada encima.
		lienzo.draw_polyline(pieza[2] as PackedVector2Array, color, 1.0 / escala, true)
	if brillo > 0.0:
		var blanco: Color = Color(1.0, 1.0, 1.0, brillo * modulado.a)
		for silueta: PackedVector2Array in figura[1] as Array:
			lienzo.draw_colored_polygon(silueta, blanco)
	lienzo.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## La PejeCoin con su P en la fuente dada, de diametro px.
static func dibujar_moneda(lienzo: CanvasItem, centro: Vector2, diametro: float, fuente: Font,
		modulado: Color = Color.WHITE) -> void:
	dibujar(lienzo, MONEDA, centro, diametro, modulado)
	var tamano: int = maxi(1, roundi(ALTO_P * diametro / 100.0 / MAYUSCULA))
	var ancho: float = fuente.get_string_size("P", HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x
	var base: Vector2 = centro + Vector2(-ancho / 2.0, tamano * MAYUSCULA / 2.0)
	lienzo.draw_string(fuente, base, "P", HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, COLOR_P * modulado)


static func _figura(nombre: StringName) -> Array:
	if not _figuras.has(nombre):
		var armado: _Armado = _Armado.new()
		match nombre:
			MASCARA:
				_armar_mascara(armado)
			MOCHILA:
				_armar_mochila(armado)
			MONEDA:
				_armar_moneda(armado)
			DISQUETE:
				_armar_disquete(armado)
		_figuras[nombre] = [armado.claro + armado.piezas, armado.silueta]
	return _figuras[nombre] as Array


# Ovalo de 74 x 100 con contorno negro de 8 hacia dentro y dos ojos (proporciones de la mascara del icono).
static func _armar_mascara(a: _Armado) -> void:
	a.ancho_claro = 5.5
	a.pieza(_ovalo(Vector2.ZERO, 37.0, 50.0), Color("#eeece6"), 8.0)
	for x: float in [-17.02, 17.02]:
		a.pieza(_ovalo(Vector2(x, -4.0), 8.51, 15.0), NEGRO, 0.0, NEGRO, false)


# La mochila del marcador: tirantes, asa, bolsillos, cuerpo, etiqueta, bolsillo grande, cierre y jalador.
static func _armar_mochila(a: _Armado) -> void:
	a.ancho_claro = 5.5
	var oscuro: Color = Color("#563822")
	var cafe: Color = Color("#805634")
	for x: float in [-30.36, 13.2]:
		a.pieza(_centrada(_caja(Rect2(x, -46.0, 17.16, 26.0), 6.6), 4.5), oscuro, 4.5)
	var asa: PackedVector2Array = _arco(Vector2(0.0, -34.0), 7.0, 8.0, 180.0, 360.0)
	a.linea(asa, 8.0, NEGRO)
	a.linea(asa, 3.5, oscuro, false)
	for x: float in [-42.9, 29.7]:
		a.pieza(_centrada(_caja(Rect2(x, 8.0, 13.2, 28.0), 3.3), 4.5), cafe, 4.5)
	# Cuerpo: tapa en medio ovalo y abajo esquinas redondeadas.
	var cuerpo: PackedVector2Array = _arco(Vector2(0.0, -6.3), 30.75, 27.45, 180.0, 360.0)
	cuerpo.append_array(_esquina(Vector2(30.75, 40.5), Vector2(30.75, 47.75), Vector2(23.5, 47.75)))
	cuerpo.append_array(_esquina(Vector2(-23.5, 47.75), Vector2(-30.75, 47.75), Vector2(-30.75, 40.5)))
	a.pieza(_centrada(cuerpo, 4.5), cafe, 4.5)
	a.pieza(_centrada(_caja(Rect2(-10.56, -23.0, 21.12, 8.0), 2.0), 3.6), oscuro, 3.6, NEGRO, false)
	a.pieza(_centrada(_caja(Rect2(-25.08, 0.0, 50.16, 42.0), 3.96), 4.5), oscuro, 4.5, NEGRO, false)
	a.linea(PackedVector2Array([Vector2(-20.58, 6.0), Vector2(20.58, 6.0)]), 3.15, NEGRO, false)
	a.pieza(_centrada(_caja(Rect2(16.48, 5.0, 4.0, 10.0), 1.5), 2.25), Color("#d6b468"), 2.25, NEGRO, false)


# Bimetalica: anillo plateado con contorno negro de 6 hacia dentro, brillo arriba a la izquierda y centro dorado.
static func _armar_moneda(a: _Armado) -> void:
	a.ancho_claro = 3.0
	a.pieza(_ovalo(Vector2.ZERO, 50.0, 50.0), Color("#c4c8ce"), 6.0)
	a.linea(_arco(Vector2.ZERO, 42.5, 42.5, 205.0, 245.0), 5.0, Color("#eef0f3"), false)
	a.pieza(_ovalo(Vector2.ZERO, 33.0, 33.0), Color("#deb246"), 4.0, Color("#6e747e"), false)


# Disquete de 3.5": cuerpo con la esquina de arriba a la derecha cortada, obturador con su ventana y etiqueta.
static func _armar_disquete(a: _Armado) -> void:
	a.ancho_claro = 3.0
	var cuerpo: PackedVector2Array = PackedVector2Array([Vector2(-46.0, -46.0), Vector2(30.0, -46.0),
			Vector2(46.0, -30.0), Vector2(46.0, 46.0), Vector2(-46.0, 46.0)])
	a.pieza(_centrada(cuerpo, 8.0), Color("#3c5a96"), 8.0)
	a.silueta = [a.piezas[0][0]]
	a.pieza(_centrada(_caja(Rect2(-26.0, -46.0, 50.0, 32.0), 0.0), 5.6), Color("#c4c8ce"), 5.6, NEGRO, false)
	a.pieza(_caja(Rect2(8.0, -40.0, 10.0, 20.0), 0.0), Color("#24345c"), 0.0, NEGRO, false)
	a.pieza(_centrada(_caja(Rect2(-32.0, 2.0, 64.0, 42.0), 0.0), 5.6), Color("#eeece6"), 5.6, NEGRO, false)


static func _ovalo(centro: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var puntos: PackedVector2Array = _arco(centro, rx, ry, 0.0, 360.0)
	puntos.resize(puntos.size() - 1)
	return puntos


# Puntos de un arco de elipse, en grados con y hacia abajo (180 a 360 es la mitad de arriba).
static func _arco(centro: Vector2, rx: float, ry: float, desde: float, hasta: float) -> PackedVector2Array:
	var puntos: PackedVector2Array = []
	for i: int in range(PUNTOS_CURVA + 1):
		var angulo: float = deg_to_rad(lerpf(desde, hasta, float(i) / PUNTOS_CURVA))
		puntos.append(centro + Vector2(cos(angulo) * rx, sin(angulo) * ry))
	return puntos


# Rectangulo con las esquinas redondeadas (radio 0: esquinas rectas).
static func _caja(caja: Rect2, radio: float) -> PackedVector2Array:
	if radio <= 0.0:
		return PackedVector2Array([caja.position, Vector2(caja.end.x, caja.position.y), caja.end,
				Vector2(caja.position.x, caja.end.y)])
	var puntos: PackedVector2Array = []
	var centros: Array[Vector2] = [caja.position + Vector2(radio, radio), Vector2(caja.end.x - radio, caja.position.y + radio),
			caja.end - Vector2(radio, radio), Vector2(caja.position.x + radio, caja.end.y - radio)]
	for i: int in range(4):
		puntos.append_array(_arco(centros[i], radio, radio, 180.0 + 90.0 * i, 270.0 + 90.0 * i))
	return puntos


# Esquina como curva cuadratica de inicio a fin con su punto de control.
static func _esquina(inicio: Vector2, control: Vector2, fin: Vector2) -> PackedVector2Array:
	var puntos: PackedVector2Array = []
	for i: int in range(9):
		var t: float = i / 8.0
		puntos.append(inicio.lerp(control, t).lerp(control.lerp(fin, t), t))
	return puntos


# Lo que ocupa una forma dibujada con un trazo centrado de ese ancho (como en el SVG): la forma crecida medio trazo.
static func _centrada(forma: PackedVector2Array, trazo: float) -> PackedVector2Array:
	return _crecer(forma, trazo / 2.0)[0]


static func _crecer(forma: PackedVector2Array, distancia: float) -> Array[PackedVector2Array]:
	return Geometry2D.offset_polygon(forma, distancia, Geometry2D.JOIN_ROUND)


# Lo que se va juntando al armar una figura, en orden de dibujo.
class _Armado:
	var ancho_claro: float = 0.0
	var claro: Array = []
	var piezas: Array = []
	var silueta: Array = []

	# exterior es la orilla de afuera; con trazo, el contorno va hacia dentro con ese ancho. claro: si su silueta
	# crecida entra al contorno claro (no hace falta en lo que queda dentro de otra pieza).
	func pieza(exterior: PackedVector2Array, relleno: Color, trazo: float = 0.0, color_trazo: Color = NEGRO,
			con_claro: bool = true) -> void:
		if con_claro:
			for forma: PackedVector2Array in FigurasVector._crecer(exterior, ancho_claro):
				_poner(claro, forma, CLARO)
		if trazo <= 0.0:
			_poner(piezas, exterior, relleno)
			return
		_poner(piezas, exterior, color_trazo)
		for forma: PackedVector2Array in FigurasVector._crecer(exterior, -trazo):
			_poner(piezas, forma, relleno)

	# Una linea de ese ancho con las puntas redondas.
	func linea(puntos: PackedVector2Array, ancho: float, color: Color, con_claro: bool = true) -> void:
		for forma: PackedVector2Array in Geometry2D.offset_polyline(puntos, ancho / 2.0, Geometry2D.JOIN_ROUND,
				Geometry2D.END_ROUND):
			if con_claro:
				for crecida: PackedVector2Array in FigurasVector._crecer(forma, ancho_claro):
					_poner(claro, crecida, CLARO)
			_poner(piezas, forma, color)

	func _poner(lista: Array, forma: PackedVector2Array, color: Color) -> void:
		var borde: PackedVector2Array = forma.duplicate()
		borde.append(forma[0])
		lista.append([forma, color, borde])
