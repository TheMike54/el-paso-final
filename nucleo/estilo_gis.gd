class_name EstiloGis
extends StyleBox
# Trazo de gis de los menus, como StyleBox para que cualquier Button lo herede del tema sin cambiar cada menu (las
# formas, en Forma). Un StyleBox no conoce el texto del boton: el subrayado va de lado a lado del contenido y las
# flechitas de LADOS van en las orillas (classes/class_stylebox.rst:180). Los trazos tiemblan con una semilla que sale
# del tamano: no cambian al redibujar.

enum Forma {
	MARCA, # La flechita y el subrayado de la opcion con foco.
	SUBRAYADO, # El subrayado de lo elegido.
	ATRAS, # La flecha de Volver.
	CAJA, # La caja de una tarjeta.
	LADOS, # Una flechita a cada lado (opcion centrada).
	ADORNO, # El adorno de arriba y abajo de una lista.
	FRANJA, # La franja de la fila elegida de la tienda.
}

## Cada cuanto se quiebra un trazo y cuanto se aparta de la recta, en px.
const PASO: float = 14.0
const TEMBLOR: float = 1.4
## Largo de la flechita del foco y de la de Volver, y su lugar desde la orilla izquierda: Tema deja ese margen.
const ANCHO_FLECHA: float = 30.0
const MARGEN_FLECHA: float = 6.0

var forma: Forma = Forma.MARCA
var color: Color = Color.WHITE
var grosor: float = 3.0
## Relleno de la caja (CAJA) y de la franja (FRANJA); transparente, sin relleno.
var fondo: Color = Color(0.0, 0.0, 0.0, 0.0)


## Los puntos de un trazo tembloroso de a a b, quebrado cada PASO px.
static func puntos(azar: RandomNumberGenerator, a: Vector2, b: Vector2, temblor: float) -> PackedVector2Array:
	var n: int = maxi(2, int(a.distance_to(b) / PASO))
	var normal: Vector2 = (b - a).normalized().orthogonal()
	var lista: PackedVector2Array = PackedVector2Array()
	for i: int in n + 1:
		lista.append(a.lerp(b, float(i) / n) + normal * azar.randf_range(-temblor, temblor))
	return lista


func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	var azar: RandomNumberGenerator = RandomNumberGenerator.new()
	azar.seed = hash(Vector2i(rect.size))
	# A la altura del texto, en medio del contenido (con Tema.CON_DETALLE el contenido no esta en medio del boton).
	var medio: float = rect.position.y + content_margin_top + (rect.size.y - content_margin_top - content_margin_bottom) / 2.0
	match forma:
		Forma.MARCA:
			var punta: Vector2 = Vector2(rect.position.x + MARGEN_FLECHA + ANCHO_FLECHA, medio)
			_trazo(to_canvas_item, azar, punta - Vector2(ANCHO_FLECHA, -1.0), punta, 3.4, 1.0)
			_trazo(to_canvas_item, azar, punta + Vector2(-12.0, -10.0), punta, 3.4, 0.8)
			_trazo(to_canvas_item, azar, punta + Vector2(-12.0, 11.0), punta, 3.4, 0.8)
			_subrayar(to_canvas_item, azar, rect)
		Forma.SUBRAYADO:
			_subrayar(to_canvas_item, azar, rect)
		Forma.ATRAS:
			var punta: Vector2 = Vector2(rect.position.x + MARGEN_FLECHA, medio)
			_trazo(to_canvas_item, azar, punta + Vector2(ANCHO_FLECHA, 0.0), punta, 3.4, 1.0)
			_trazo(to_canvas_item, azar, punta + Vector2(12.0, -11.0), punta, 3.4, 0.8)
			_trazo(to_canvas_item, azar, punta + Vector2(12.0, 11.0), punta, 3.4, 0.8)
		Forma.CAJA:
			if fondo.a > 0.0:
				RenderingServer.canvas_item_add_rect(to_canvas_item, rect, fondo)
			var s: float = 6.0
			var p: Vector2 = rect.position
			var e: Vector2 = rect.end
			_trazo(to_canvas_item, azar, p + Vector2(-s, 1.0), Vector2(e.x + s, p.y - 1.0), grosor, TEMBLOR)
			_trazo(to_canvas_item, azar, Vector2(e.x, p.y - s), Vector2(e.x + 1.0, e.y + s), grosor, TEMBLOR)
			_trazo(to_canvas_item, azar, Vector2(e.x + s, e.y), Vector2(p.x - s, e.y + 1.0), grosor, TEMBLOR)
			_trazo(to_canvas_item, azar, Vector2(p.x - 1.0, e.y + s), p + Vector2(1.0, -s), grosor, TEMBLOR)
		Forma.LADOS:
			# La flechita de MARCA a la izquierda y su espejo a la derecha, las dos hacia el texto.
			var izquierda: Vector2 = Vector2(rect.position.x + MARGEN_FLECHA + ANCHO_FLECHA, medio)
			_trazo(to_canvas_item, azar, izquierda - Vector2(ANCHO_FLECHA, -1.0), izquierda, 3.4, 1.0)
			_trazo(to_canvas_item, azar, izquierda + Vector2(-12.0, -10.0), izquierda, 3.4, 0.8)
			_trazo(to_canvas_item, azar, izquierda + Vector2(-12.0, 11.0), izquierda, 3.4, 0.8)
			var derecha: Vector2 = Vector2(rect.end.x - MARGEN_FLECHA - ANCHO_FLECHA, medio)
			_trazo(to_canvas_item, azar, derecha + Vector2(ANCHO_FLECHA, -1.0), derecha, 3.4, 1.0)
			_trazo(to_canvas_item, azar, derecha + Vector2(12.0, -10.0), derecha, 3.4, 0.8)
			_trazo(to_canvas_item, azar, derecha + Vector2(12.0, 11.0), derecha, 3.4, 0.8)
		Forma.ADORNO:
			_adorno(to_canvas_item, azar, rect)
		Forma.FRANJA:
			_franja(to_canvas_item, azar, rect)


# Una raya de lado a lado con un rombo en medio y uno chico en cada punta; el rombo del medio mide el alto del rect.
func _adorno(lienzo: RID, azar: RandomNumberGenerator, rect: Rect2) -> void:
	var centro: Vector2 = rect.get_center()
	var alto: float = rect.size.y / 2.0
	var ancho: float = alto * 1.3
	var punta: float = alto * 0.35
	var izquierda: float = rect.position.x + punta
	var derecha: float = rect.end.x - punta
	_rombo(lienzo, azar, centro, ancho, alto)
	_trazo(lienzo, azar, Vector2(izquierda + punta + 4.0, centro.y), Vector2(centro.x - ancho - 6.0, centro.y + 1.0), grosor, 1.0)
	_trazo(lienzo, azar, Vector2(centro.x + ancho + 6.0, centro.y + 1.0), Vector2(derecha - punta - 4.0, centro.y), grosor, 1.0)
	_rombo(lienzo, azar, Vector2(izquierda, centro.y), punta, punta)
	_rombo(lienzo, azar, Vector2(derecha, centro.y), punta, punta)


# La franja de la fila elegida, como la de las tiendas de los dos juegos: un relleno claro entre dos rayas de gis, con un
# adorno centrado sobre cada raya. Todo dentro del rect (content_margin_top y _bottom dicen donde van las rayas): asi
# el ScrollContainer de la lista no la recorta ni se encima con la fila de al lado.
func _franja(lienzo: RID, azar: RandomNumberGenerator, rect: Rect2) -> void:
	var arriba: float = rect.position.y + content_margin_top
	var abajo: float = rect.end.y - content_margin_bottom
	if fondo.a > 0.0:
		RenderingServer.canvas_item_add_rect(lienzo, Rect2(rect.position.x, arriba, rect.size.x, abajo - arriba), fondo)
	var color_raya: Color = Color(color, 0.55)
	for y: float in [arriba, abajo]:
		RenderingServer.canvas_item_add_polyline(lienzo, puntos(azar, Vector2(rect.position.x, y),
				Vector2(rect.end.x, y + 1.0), 1.0), PackedColorArray([color_raya]), 2.0, true)
	var alto: float = minf(content_margin_top, content_margin_bottom) * 2.0 * 0.6
	var ancho: float = minf(rect.size.x * 0.6, alto * 8.0)
	for y: float in [arriba, abajo]:
		_adorno(lienzo, azar, Rect2(rect.get_center().x - ancho / 2.0, y - alto / 2.0, ancho, alto))


func _rombo(lienzo: RID, azar: RandomNumberGenerator, centro: Vector2, medio_ancho: float, medio_alto: float) -> void:
	var arriba: Vector2 = centro + Vector2(0.0, -medio_alto)
	var der: Vector2 = centro + Vector2(medio_ancho, 0.0)
	var abajo: Vector2 = centro + Vector2(0.0, medio_alto)
	var izq: Vector2 = centro + Vector2(-medio_ancho, 0.0)
	for lado: Array in [[izq, arriba], [arriba, der], [der, abajo], [abajo, izq]]:
		_trazo(lienzo, azar, lado[0] as Vector2, lado[1] as Vector2, grosor, 0.6)


# Dos rayas bajo el contenido, la segunda mas corta, como un subrayado a mano.
func _subrayar(lienzo: RID, azar: RandomNumberGenerator, rect: Rect2) -> void:
	var izquierda: float = rect.position.x + content_margin_left - 4.0
	var ancho: float = maxf(rect.size.x - content_margin_left - content_margin_right + 8.0, 0.0)
	var y: float = rect.end.y - content_margin_bottom + 4.0
	_trazo(lienzo, azar, Vector2(izquierda, y), Vector2(izquierda + ancho, y - 3.0), grosor, 1.2)
	_trazo(lienzo, azar, Vector2(izquierda + ancho * 0.12, y + 6.0), Vector2(izquierda + ancho * 0.92, y + 4.0), grosor * 0.7, 1.0)


func _trazo(lienzo: RID, azar: RandomNumberGenerator, a: Vector2, b: Vector2, ancho: float, temblor: float) -> void:
	RenderingServer.canvas_item_add_polyline(lienzo, puntos(azar, a, b, temblor), PackedColorArray([color]), ancho, true)
