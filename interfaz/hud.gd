class_name Hud
extends Control
# Interfaz durante el juego: corazones de vida, la barra de bloques de Inspiracion y las PejeCoins, arriba
# a la izquierda, y debajo el icono de guardado. Las PejeCoins van como en Silksong: aparecen al ganar, gastar o
# descansar con un +N, cuentan hasta el valor nuevo y se desvanecen; el total esta en el inventario. Con una tienda
# abierta se quedan fijas, como en los dos juegos, y el Hud corre con el arbol detenido solo mientras tanto. Se entera
# de todo por el bus de eventos y lee Partida una sola vez al entrar a la sala. Todo en gris hasta tener arte.

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
## PejeCoins como el contador de Silksong (CurrencyCounterBase), en ticks: aparecen en 0,1 s, esperan 1 s antes de
## contar, cuentan en unos 34 pasos (0,57 s), siguen 1,5 s a la vista y se desvanecen en 0,3 s.
const TICKS_APARECER: int = 6
const TICKS_ESPERA_CONTEO: int = 60
const PASOS_CONTEO: float = 34.0
const TICKS_A_LA_VISTA: int = 90
const TICKS_DESVANECER: int = 18
## Al morir la espera se acorta: con la de siempre el conteo no llegaba a 0 antes de reaparecer (90 ticks, prueba en
## el S21, 17-oct-2026). 6 + 20 + 34 ticks caben antes de que la pantalla oscurezca.
const TICKS_ESPERA_MUERTE: int = 20

## Lo que muestra; publico para los guiones.
var vidas: int = 0
var vidas_maximas: int = 0
var inspiracion: int = 0
var inspiracion_maxima: int = 0
## Bloques llenos de la barra; uno a medio llenar no cuenta.
var bloques_llenos: int = 0
var monedas: int = 0
## Lo que dice el contador mientras cuenta hacia monedas, y el +N (o -N) que se ve a su lado.
var monedas_mostradas: int = 0
var monedas_pendientes: int = 0
## El contador de PejeCoins se ve, aunque sea a medio aparecer o desvanecer.
var monedas_visibles: bool = false
## Una tienda esta abierta: el contador no se desvanece y el Hud corre con el arbol detenido.
var monedas_fijas: bool = false
## Icono de guardado a la vista.
var aviso_visible: bool = false

var _ticks_aviso: int = 0
# Contador de PejeCoins: si debe verse, su opacidad, ticks antes de contar y ticks a la vista ya contado.
var _monedas_activas: bool = false
var _alfa_monedas: float = 0.0
var _ticks_espera_conteo: int = 0
var _ticks_a_la_vista: int = 0
# Nodo propio, como el icono: contar o desvanecer no redibuja corazones ni barra.
var _monedas: Node2D = null
# El icono es un nodo propio: girarlo cambia su rotation y no redibuja corazones, barra ni texto.
var _icono: Node2D = null


func _ready() -> void:
	vidas = Partida.vidas
	vidas_maximas = Partida.vidas_maximas
	inspiracion = Partida.inspiracion
	inspiracion_maxima = Partida.INSPIRACION_MAXIMA
	bloques_llenos = inspiracion / Partida.INSPIRACION_POR_GOLPE
	monedas = Partida.monedas
	monedas_mostradas = monedas
	Eventos.vidas_cambiadas.connect(_al_cambiar_vidas)
	Eventos.monedas_cambiadas.connect(_al_cambiar_monedas)
	Eventos.inspiracion_cambiada.connect(_al_cambiar_inspiracion)
	Eventos.partida_guardada.connect(_al_guardar)
	Eventos.descanso_en_banco.connect(_al_descansar)
	Eventos.jugador_muerto.connect(_al_morir)
	Eventos.tienda_abierta.connect(_al_abrir_tienda)
	Eventos.tienda_cerrada.connect(_al_cerrar_tienda)
	_monedas = Node2D.new()
	_monedas.visible = false
	_monedas.draw.connect(_dibujar_monedas)
	add_child(_monedas)
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


# Ganar o gastar: el +N acumula, el contador aparece y la espera antes de contar vuelve a empezar.
func _al_cambiar_monedas(nuevas: int) -> void:
	monedas_pendientes += nuevas - monedas
	monedas = nuevas
	_monedas_activas = true
	_ticks_espera_conteo = TICKS_ESPERA_CONTEO
	_ticks_a_la_vista = 0
	_monedas.queue_redraw()


# Descansar en un banco muestra el total un rato, sin contar.
func _al_descansar(_banco: StringName) -> void:
	_monedas_activas = true
	if _ticks_espera_conteo == 0 and monedas_mostradas == monedas:
		_ticks_a_la_vista = TICKS_A_LA_VISTA


# Las monedas ya pasaron a la mochila (el jugador las deja antes de avisar): que el -N cuente antes del fundido.
func _al_morir() -> void:
	if monedas_pendientes != 0:
		_ticks_espera_conteo = mini(_ticks_espera_conteo, TICKS_ESPERA_MUERTE)


# La tienda detiene el arbol: el Hud sigue corriendo para que el contador aparezca y cuente lo que se gasta.
func _al_abrir_tienda() -> void:
	monedas_fijas = true
	_monedas_activas = true
	process_mode = Node.PROCESS_MODE_ALWAYS


# De vuelta al ciclo de siempre: si ya no cuenta, sigue a la vista TICKS_A_LA_VISTA y se desvanece.
func _al_cerrar_tienda() -> void:
	monedas_fijas = false
	process_mode = Node.PROCESS_MODE_INHERIT
	if _ticks_espera_conteo == 0 and monedas_mostradas == monedas:
		_ticks_a_la_vista = TICKS_A_LA_VISTA


func _al_guardar() -> void:
	_ticks_aviso = TICKS_AVISO
	aviso_visible = true
	_icono.visible = true
	_icono.rotation = float(_ticks_aviso) * 0.1


func _physics_process(_delta: float) -> void:
	_avanzar_monedas()
	if _ticks_aviso == 0:
		return
	_ticks_aviso -= 1
	if _ticks_aviso == 0:
		aviso_visible = false
		_icono.visible = false
	_icono.rotation = float(_ticks_aviso) * 0.1


# Espera, cuenta hacia monedas (un paso por tick, unos PASOS_CONTEO en total), sigue a la vista y se desvanece; con
# una tienda abierta no se desvanece.
func _avanzar_monedas() -> void:
	if not _monedas_activas and _alfa_monedas == 0.0:
		return
	if _ticks_espera_conteo > 0:
		_ticks_espera_conteo -= 1
	elif monedas_mostradas != monedas:
		var paso: int = maxi(1, ceili(float(absi(monedas_pendientes)) / PASOS_CONTEO))
		var falta: int = monedas - monedas_mostradas
		monedas_mostradas += signi(falta) * mini(paso, absi(falta))
		if monedas_mostradas == monedas:
			monedas_pendientes = 0
			_ticks_a_la_vista = TICKS_A_LA_VISTA
	elif _ticks_a_la_vista > 0 and not monedas_fijas:
		_ticks_a_la_vista -= 1
		if _ticks_a_la_vista == 0:
			_monedas_activas = false
	if _monedas_activas:
		_alfa_monedas = minf(1.0, _alfa_monedas + 1.0 / TICKS_APARECER)
	else:
		_alfa_monedas = maxf(0.0, _alfa_monedas - 1.0 / TICKS_DESVANECER)
	monedas_visibles = _alfa_monedas > 0.0
	_monedas.visible = monedas_visibles
	_monedas.queue_redraw()


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


# PejeCoins bajo la barra: un circulo gris del alto de la letra (el icono, hasta tener arte), el numero y el +N.
func _dibujar_monedas() -> void:
	var corto: float = minf(size.x, size.y)
	var tamano_letra: int = maxi(14, roundi(0.035 * corto))
	var fuente: Font = ThemeDB.fallback_font
	var color: Color = Color(COLOR_LLENO, _alfa_monedas)
	var base: float = _base_monedas(corto)
	var r: float = tamano_letra * 0.4
	var x: float = _izquierda(corto)
	_monedas.draw_circle(Vector2(x + r, base - tamano_letra * 0.35), r, color)
	x += 2.0 * r + SEPARACION * corto
	var numero: String = str(monedas_mostradas)
	_monedas.draw_string(fuente, Vector2(x, base), numero, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_letra, color)
	if monedas_pendientes != 0:
		x += fuente.get_string_size(numero, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_letra).x + SEPARACION * corto
		var signo: String = "+" if monedas_pendientes > 0 else "-"
		_monedas.draw_string(fuente, Vector2(x, base), signo + str(absi(monedas_pendientes)),
				HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_letra, color)


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
