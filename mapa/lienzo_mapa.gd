class_name LienzoMapa
extends Control
# Dibujo del mapa en sus dos estados: alejado (cada zona como la silueta rellena de sus salas, con su nombre) y
# acercado (las salas de la zona actual con borde, o su dibujo si lo tienen). Recibe todo hecho en dibujar() y
# solo pinta; las cuentas viven en DatosMapa. Deja en propiedades publicas lo que dibujo, para las pruebas.

const MARGEN: float = 60.0
const COLOR_SALA: Color = Color(0.55, 0.5, 0.4, 1.0)
const COLOR_BORDE: Color = FigurasVector.CLARO
const COLORES_ZONA: Array[Color] = [Color(0.45, 0.55, 0.65), Color(0.6, 0.5, 0.4), Color(0.45, 0.6, 0.45), Color(0.6, 0.45, 0.6)]
## Alto en px de los marcadores (FigurasVector): la mascara del jugador, con la brujula, y la mochila.
const ALTO_MASCARA: float = 36.0
const ALTO_MOCHILA: float = 38.0

## Lo que quedo dibujado en la ultima llamada a dibujar(): salas, zonas, si hay marcador y si quedo acercado.
var salas_dibujadas: int = 0
var zonas_dibujadas: int = 0
var marcador_visible: bool = false
var quedo_acercado: bool = false
## Donde quedo el punto del jugador, en la pantalla del mapa (para la prueba).
var marcador_en_pantalla: Vector2 = Vector2.ZERO
## Si se dibujo el icono de la mochila (lo perdido al morir) y donde, en la pantalla del mapa.
var mochila_visible: bool = false
var mochila_en_pantalla: Vector2 = Vector2.ZERO

var _indice: IndiceSalas = IndiceSalas.new()
var _zonas: Dictionary[String, Array] = {}
var _ids: Array = []
var _transformacion: Transform2D = Transform2D.IDENTITY
# Centro en pantalla y nombre de cada zona de la vista alejada: se calculan en dibujar(), no en cada _draw.
var _centros_zona: PackedVector2Array = []
var _nombres_zona: PackedStringArray = []
# Dibujos de las salas, cargados en dibujar() y retenidos mientras el mapa se ve: cargarlos en _draw los
# volvia a pedir en cada redibujo. La pantalla los suelta al ocultarse.
var _texturas: Dictionary[String, Texture2D] = {}
# El punto del jugador es un nodo aparte: seguir al jugador en el mapa rapido solo cambia su position y el
# mapa no se vuelve a dibujar.
var _punto: Node2D = null


func _ready() -> void:
	_punto = Node2D.new()
	_punto.visible = false
	_punto.draw.connect(_dibujar_punto)
	add_child(_punto)


## Prepara el dibujo. acercado se cumple solo si la zona actual tiene salas dibujadas; si no, queda alejado.
## sala_mochila y punto_mochila: donde esta lo perdido (sala vacia: no hay); se dibuja si esa sala queda dibujada.
func dibujar(indice: IndiceSalas, zonas: Dictionary[String, Array], zona_actual: String, acercado: bool, con_marcador: bool, marcador: Vector2, sala_mochila: String = "", punto_mochila: Vector2 = Vector2.ZERO) -> void:
	_indice = indice
	_zonas = zonas
	quedo_acercado = acercado and zonas.has(zona_actual)
	_ids = []
	if quedo_acercado:
		_ids = zonas[zona_actual].duplicate()
	else:
		for zona: String in zonas:
			_ids.append_array(zonas[zona])
	salas_dibujadas = _ids.size()
	zonas_dibujadas = 1 if quedo_acercado else zonas.size()
	_transformacion = DatosMapa.encajar(DatosMapa.abarca(indice, _ids), Rect2(Vector2.ZERO, size), MARGEN)
	_centros_zona = []
	_nombres_zona = []
	if quedo_acercado:
		for valor: Variant in _ids:
			var id: String = str(valor)
			if _indice.dibujos.has(id) and not _texturas.has(id):
				_texturas[id] = load(_indice.dibujos[id]) as Texture2D
	else:
		for zona: String in zonas:
			_centros_zona.append(_transformacion * DatosMapa.abarca(indice, zonas[zona]).get_center())
			_nombres_zona.append(DatosMapa.nombre_de_zona(zona))
	# Todas las salas empiezan sus limites en (0, 0): el punto de la sala en el mundo es la esquina de su rectangulo
	# mas el punto. Si una sala empezara en otra esquina, el icono se correria lo mismo.
	mochila_visible = not sala_mochila.is_empty() and _ids.has(sala_mochila)
	if mochila_visible:
		mochila_en_pantalla = _transformacion * (indice.rectangulos[sala_mochila].position + punto_mochila)
	marcador_visible = con_marcador and salas_dibujadas > 0
	if _punto != null:
		_punto.visible = marcador_visible
		_punto.queue_redraw()
	mover_marcador(marcador)
	queue_redraw()


## Solo mueve el punto del jugador: el mapa no se vuelve a dibujar. marcador va en px del mapa del mundo.
func mover_marcador(marcador: Vector2) -> void:
	marcador_en_pantalla = _transformacion * marcador
	if _punto != null:
		_punto.position = marcador_en_pantalla


## Suelta los dibujos de las salas: con el mapa oculto no ocupan memoria.
func soltar_texturas() -> void:
	_texturas.clear()


func _draw() -> void:
	if salas_dibujadas == 0:
		# Centrado en todo el ancho del lienzo: en un ancho fijo el texto se cortaba.
		draw_string(get_theme_default_font(), Vector2(0.0, size.y / 2.0), "Aún no hay nada en el mapa", HORIZONTAL_ALIGNMENT_CENTER, size.x, 28)
		return
	var escala: float = _transformacion.x.x
	if quedo_acercado:
		for valor: Variant in _ids:
			var id: String = str(valor)
			var rectangulo: Rect2 = _en_pantalla(_indice.rectangulos[id], escala)
			var textura: Texture2D = _texturas.get(id) as Texture2D
			if textura != null:
				draw_texture_rect(textura, rectangulo, false)
				continue
			draw_rect(rectangulo, COLOR_SALA)
			draw_rect(rectangulo, COLOR_BORDE, false, 3.0)
	else:
		var numero: int = 0
		for zona: String in _zonas:
			var color: Color = COLORES_ZONA[numero % COLORES_ZONA.size()]
			numero += 1
			for valor: Variant in _zonas[zona]:
				draw_rect(_en_pantalla(_indice.rectangulos[str(valor)], escala), color)
		for i: int in range(_nombres_zona.size()):
			draw_string(get_theme_default_font(), _centros_zona[i] - Vector2(150.0, -10.0), _nombres_zona[i], HORIZONTAL_ALIGNMENT_CENTER, 300.0, 30)
	if mochila_visible:
		FigurasVector.dibujar(self, FigurasVector.MOCHILA, mochila_en_pantalla, ALTO_MOCHILA)


func _dibujar_punto() -> void:
	FigurasVector.dibujar(_punto, FigurasVector.MASCARA, Vector2.ZERO, ALTO_MASCARA)


func _en_pantalla(rectangulo: Rect2, escala: float) -> Rect2:
	return Rect2(_transformacion * rectangulo.position, rectangulo.size * escala)
