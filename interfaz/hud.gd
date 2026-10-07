class_name Hud
extends Control
# Interfaz durante el juego: corazones de vida y, debajo, la barra de bloques de Inspiracion, arriba
# a la izquierda; y el aviso «Partida guardada». Se entera de todo por el bus de eventos y lee
# Partida una sola vez al entrar a la sala: nunca lee al jugador. Todo en gris hasta tener arte.

## Centro del grupo en la distribucion inicial del diseno: fraccion de una pantalla 16:9, anclado
## arriba a la izquierda y medido en el lado corto, como los botones tactiles.
const CENTRO: Vector2 = Vector2(0.17, 0.12)
const PROPORCION_REFERENCIA: float = 16.0 / 9.0
## Lado de un corazon y separacion, en fraccion del lado corto.
const LADO_CORAZON: float = 0.06
const SEPARACION: float = 0.015
## Inspiracion de un bloque: lo que da un golpe (Jugador.inspiracion_por_golpe).
const INSPIRACION_POR_BLOQUE: int = 11
const ALTO_BLOQUE: float = 0.022
## Ticks que se ve el aviso de guardado: 2 s.
const TICKS_AVISO: int = 120
const COLOR_LLENO: Color = Color(0.85, 0.85, 0.9)
const COLOR_VACIO: Color = Color(0.16, 0.16, 0.19, 0.9)

## Lo que muestra; publico para los guiones.
var vidas: int = 0
var vidas_maximas: int = 0
var inspiracion: int = 0
var inspiracion_maxima: int = 0
## Bloques llenos de la barra; uno a medio llenar no cuenta.
var bloques_llenos: int = 0
var aviso_visible: bool = false

var _ticks_aviso: int = 0


func _ready() -> void:
	vidas = Partida.vidas
	vidas_maximas = Partida.vidas_maximas
	inspiracion = Partida.inspiracion
	inspiracion_maxima = Partida.INSPIRACION_MAXIMA
	bloques_llenos = inspiracion / INSPIRACION_POR_BLOQUE
	Eventos.vidas_cambiadas.connect(_al_cambiar_vidas)
	Eventos.inspiracion_cambiada.connect(_al_cambiar_inspiracion)
	Eventos.partida_guardada.connect(_al_guardar)


func _al_cambiar_vidas(nuevas: int, maximas: int) -> void:
	vidas = nuevas
	vidas_maximas = maximas
	queue_redraw()


func _al_cambiar_inspiracion(nueva: int, maxima: int) -> void:
	inspiracion = nueva
	inspiracion_maxima = maxima
	bloques_llenos = inspiracion / INSPIRACION_POR_BLOQUE
	queue_redraw()


func _al_guardar() -> void:
	_ticks_aviso = TICKS_AVISO
	aviso_visible = true
	queue_redraw()


func _physics_process(_delta: float) -> void:
	if _ticks_aviso == 0:
		return
	_ticks_aviso -= 1
	if _ticks_aviso == 0:
		aviso_visible = false
		queue_redraw()


func _draw() -> void:
	var corto: float = minf(size.x, size.y)
	var lado: float = LADO_CORAZON * corto
	var paso: float = lado + SEPARACION * corto
	# El borde izquierdo queda fijo con las vidas iniciales centradas en CENTRO: una vida mas crece
	# hacia la derecha, como en el diseno.
	var ancho_inicial: float = Partida.VIDAS_MAXIMAS_INICIALES * paso - SEPARACION * corto
	var centro: Vector2 = CENTRO * Vector2(PROPORCION_REFERENCIA, 1.0) * corto
	var izquierda: float = centro.x - ancho_inicial / 2.0
	var arriba: float = centro.y - lado
	for i: int in range(vidas_maximas):
		_corazon(Vector2(izquierda + i * paso + lado / 2.0, arriba + lado / 2.0), lado, i < vidas)
	var bloques: int = inspiracion_maxima / INSPIRACION_POR_BLOQUE
	if bloques > 0:
		var separacion_bloque: float = 0.006 * corto
		var ancho_bloque: float = (ancho_inicial - (bloques - 1) * separacion_bloque) / bloques
		var y: float = arriba + lado + SEPARACION * corto
		for i: int in range(bloques):
			var x: float = izquierda + i * (ancho_bloque + separacion_bloque)
			draw_rect(Rect2(x, y, ancho_bloque, ALTO_BLOQUE * corto), COLOR_VACIO)
			var lleno: float = clampf(float(inspiracion - i * INSPIRACION_POR_BLOQUE) / INSPIRACION_POR_BLOQUE, 0.0, 1.0)
			if lleno > 0.0:
				draw_rect(Rect2(x, y, ancho_bloque * lleno, ALTO_BLOQUE * corto), COLOR_LLENO)
		if aviso_visible:
			var fuente: Font = ThemeDB.fallback_font
			var tamano_letra: int = maxi(14, roundi(0.035 * corto))
			draw_string(fuente, Vector2(izquierda, y + ALTO_BLOQUE * corto + tamano_letra * 1.4), "Partida guardada",
					HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_letra, COLOR_LLENO)


# Corazon gris: dos circulos y un triangulo. Vacio, oscuro.
func _corazon(c: Vector2, lado: float, lleno: bool) -> void:
	var color: Color = COLOR_LLENO if lleno else COLOR_VACIO
	var q: float = lado / 4.0
	draw_circle(c + Vector2(-q, -q * 0.6), q * 1.05, color)
	draw_circle(c + Vector2(q, -q * 0.6), q * 1.05, color)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-2.0 * q, -q * 0.3), c + Vector2(2.0 * q, -q * 0.3),
			c + Vector2(0.0, 2.0 * q)]), color)
