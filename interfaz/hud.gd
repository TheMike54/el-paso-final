class_name Hud
extends Control
# Interfaz durante el juego: corazones de vida, la barra de bloques de Inspiracion y las PejeCoins, arriba
# a la izquierda, y debajo el icono de guardado. Se entera de todo por el bus de eventos y lee
# Partida una sola vez al entrar a la sala: nunca lee al jugador. Todo en gris hasta tener arte.

## Centro del grupo en la distribucion inicial del diseno: fraccion de una pantalla 16:9, anclado
## arriba a la izquierda y medido en el lado corto, como los botones tactiles.
const CENTRO: Vector2 = Vector2(0.17, 0.12)
## Lado de un corazon y separacion, en fraccion del lado corto.
const LADO_CORAZON: float = 0.06
const SEPARACION: float = 0.015
const ALTO_BLOQUE: float = 0.022
## Ticks que se ve el icono de guardado: 2 s.
const TICKS_AVISO: int = 120
## Lado del icono de guardado, en fraccion del lado corto. Va bajo las PejeCoins: abajo a la derecha lo tapaba
## Saltar (prueba en el S50, 12-oct-2026). Provisional: el diseno del icono va despues.
const LADO_ICONO: float = 0.05
const COLOR_LLENO: Color = Color(0.85, 0.85, 0.9)
const COLOR_VACIO: Color = Color(0.16, 0.16, 0.19, 0.9)

## Lo que muestra; publico para los guiones.
var vidas: int = 0
var vidas_maximas: int = 0
var inspiracion: int = 0
var inspiracion_maxima: int = 0
## Bloques llenos de la barra; uno a medio llenar no cuenta.
var bloques_llenos: int = 0
var monedas: int = 0
## Icono de guardado a la vista.
var aviso_visible: bool = false

var _ticks_aviso: int = 0
# El icono es un nodo propio: girarlo cambia su rotation y no redibuja corazones, barra ni texto.
var _icono: Node2D = null


func _ready() -> void:
	vidas = Partida.vidas
	vidas_maximas = Partida.vidas_maximas
	inspiracion = Partida.inspiracion
	inspiracion_maxima = Partida.INSPIRACION_MAXIMA
	bloques_llenos = inspiracion / Partida.INSPIRACION_POR_GOLPE
	monedas = Partida.monedas
	Eventos.vidas_cambiadas.connect(_al_cambiar_vidas)
	Eventos.monedas_cambiadas.connect(_al_cambiar_monedas)
	Eventos.inspiracion_cambiada.connect(_al_cambiar_inspiracion)
	Eventos.partida_guardada.connect(_al_guardar)
	_icono = Node2D.new()
	_icono.visible = false
	_icono.draw.connect(_dibujar_icono)
	add_child(_icono)
	resized.connect(_colocar_icono)
	_colocar_icono()


func _al_cambiar_vidas(nuevas: int, maximas: int) -> void:
	vidas = nuevas
	vidas_maximas = maximas
	queue_redraw()


func _al_cambiar_inspiracion(nueva: int, maxima: int) -> void:
	inspiracion = nueva
	inspiracion_maxima = maxima
	bloques_llenos = inspiracion / Partida.INSPIRACION_POR_GOLPE
	queue_redraw()


func _al_cambiar_monedas(nuevas: int) -> void:
	monedas = nuevas
	queue_redraw()


func _al_guardar() -> void:
	_ticks_aviso = TICKS_AVISO
	aviso_visible = true
	_icono.visible = true
	_icono.rotation = float(_ticks_aviso) * 0.1


func _physics_process(_delta: float) -> void:
	if _ticks_aviso == 0:
		return
	_ticks_aviso -= 1
	if _ticks_aviso == 0:
		aviso_visible = false
		_icono.visible = false
	_icono.rotation = float(_ticks_aviso) * 0.1


func _draw() -> void:
	var corto: float = minf(size.x, size.y)
	var lado: float = LADO_CORAZON * corto
	var paso: float = lado + SEPARACION * corto
	var ancho_inicial: float = _ancho_inicial(corto)
	var izquierda: float = _izquierda(corto)
	var arriba: float = _arriba(corto)
	for i: int in range(vidas_maximas):
		_corazon(Vector2(izquierda + i * paso + lado / 2.0, arriba + lado / 2.0), lado, i < vidas)
	var bloques: int = inspiracion_maxima / Partida.INSPIRACION_POR_GOLPE
	var fuente: Font = ThemeDB.fallback_font
	var tamano_letra: int = maxi(14, roundi(0.035 * corto))
	if bloques > 0:
		var separacion_bloque: float = 0.006 * corto
		var ancho_bloque: float = (ancho_inicial - (bloques - 1) * separacion_bloque) / bloques
		var y: float = arriba + lado + SEPARACION * corto
		for i: int in range(bloques):
			var x: float = izquierda + i * (ancho_bloque + separacion_bloque)
			draw_rect(Rect2(x, y, ancho_bloque, ALTO_BLOQUE * corto), COLOR_VACIO)
			var lleno: float = clampf(float(inspiracion - i * Partida.INSPIRACION_POR_GOLPE) / Partida.INSPIRACION_POR_GOLPE, 0.0, 1.0)
			if lleno > 0.0:
				draw_rect(Rect2(x, y, ancho_bloque * lleno, ALTO_BLOQUE * corto), COLOR_LLENO)
	draw_string(fuente, Vector2(izquierda, _base_monedas(corto)), "%d PejeCoins" % monedas,
			HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_letra, COLOR_LLENO)


# El borde izquierdo queda fijo con las vidas iniciales centradas en CENTRO: una vida mas crece
# hacia la derecha, como en el diseno.
func _ancho_inicial(corto: float) -> float:
	var paso: float = (LADO_CORAZON + SEPARACION) * corto
	return Partida.VIDAS_MAXIMAS_INICIALES * paso - SEPARACION * corto


func _izquierda(corto: float) -> float:
	return CENTRO.x * Vista.PROPORCION_BASE * corto - _ancho_inicial(corto) / 2.0


func _arriba(corto: float) -> float:
	return CENTRO.y * corto - LADO_CORAZON * corto


# Linea base del texto de las PejeCoins, bajo la barra.
func _base_monedas(corto: float) -> float:
	var y_barra: float = _arriba(corto) + LADO_CORAZON * corto + SEPARACION * corto
	return y_barra + ALTO_BLOQUE * corto + maxi(14, roundi(0.035 * corto)) * 1.4


# Icono provisional de guardado bajo las PejeCoins, alineado a la izquierda del grupo.
func _colocar_icono() -> void:
	var corto: float = minf(size.x, size.y)
	var r: float = LADO_ICONO * corto / 2.0
	_icono.position = Vector2(_izquierda(corto) + r, _base_monedas(corto) + SEPARACION * corto + r)
	_icono.queue_redraw()


# Un rombo centrado en el nodo: girarlo es cambiar su rotation.
func _dibujar_icono() -> void:
	var r: float = LADO_ICONO * minf(size.x, size.y) / 2.0
	var puntos: PackedVector2Array = []
	for i: int in range(4):
		puntos.append(Vector2(r, 0.0).rotated(i * PI / 2.0))
	_icono.draw_colored_polygon(puntos, COLOR_LLENO)


# Corazon gris: dos circulos y un triangulo. Vacio, oscuro.
func _corazon(c: Vector2, lado: float, lleno: bool) -> void:
	var color: Color = COLOR_LLENO if lleno else COLOR_VACIO
	var q: float = lado / 4.0
	draw_circle(c + Vector2(-q, -q * 0.6), q * 1.05, color)
	draw_circle(c + Vector2(q, -q * 0.6), q * 1.05, color)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-2.0 * q, -q * 0.3), c + Vector2(2.0 * q, -q * 0.3),
			c + Vector2(0.0, 2.0 * q)]), color)
