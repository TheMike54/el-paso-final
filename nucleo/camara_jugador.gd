class_name CamaraJugador
extends Camera2D
# Camara del jugador (nodo Camara de nucleo/jugador.tscn): lo sigue a mano, recortada a los limites de la sala, y
# tiembla. No tiene tick ni _ready propios: el Jugador la llama en su _physics_process, en los mismos puntos de
# siempre, para que el seguimiento y el temblor corran en el mismo orden que el movimiento y paren con el congelado.

@export_group("Camara")
## Seguimiento horizontal: fraccion por segundo de lo que le falta a la camara (el mismo calculo
## que position_smoothing_speed de Camera2D).
@export var suavizado_camara_x: float = 8.0
## Seguimiento vertical, en s: amortiguado critico (como SmoothDamp de Unity). Cayendo a velocidad
## constante, la camara va tiempo_camara_y por detras; con menos, el frenado en el limite se nota.
@export var tiempo_camara_y: float = 0.15
## Px que la camara se adelanta hacia donde mira el jugador; el suavizado en x hace el paso al voltear.
@export var adelanto_camara: float = 43.0

@export_group("Temblor")
## Amplitud horizontal del temblor, en fraccion de la vertical (Jugador.temblor_px en el aterrizaje).
@export var temblor_fraccion_x: float = 1.0 / 3.0

## Desplazamiento vertical del temblor en este tick, en px. El offset lo recibe solo con el ajuste
## temblor encendido; Jugador.temblor_y lo lee para los guiones aunque el ajuste este apagado.
var temblor_y: float = 0.0
## Desplazamiento horizontal del temblor en este tick, en px; como temblor_y.
var temblor_x: float = 0.0

# Temblor en curso: ticks que le quedan, su duracion y su amplitud inicial.
var _ticks_temblando: int = 0
var _ticks_temblor_total: int = 0
var _px_temblor: float = 0.0
# Limites de la sala, altura sobre los pies y velocidad vertical del suavizado.
var _limites: Rect2 = Rect2(-10000000.0, -10000000.0, 20000000.0, 20000000.0)
var _altura_camara: Vector2 = Vector2.ZERO
var _velocidad_camara_y: float = 0.0


## Lo llama el _ready del Jugador: la altura sale de la posicion de la escena y la camara deja de heredar la
## posicion del jugador (la mueve seguir).
func iniciar(pies: Vector2, mirando: float) -> void:
	_altura_camara = position
	top_level = true
	colocar(pies, mirando)


## La sala le pasa sus limites (por Jugador.fijar_limites): no muestra nada fuera de ellos.
func fijar_limites(limites: Rect2, pies: Vector2, mirando: float) -> void:
	_limites = limites
	limit_left = floori(limites.position.x)
	limit_top = floori(limites.position.y)
	limit_right = ceili(limites.end.x)
	limit_bottom = ceili(limites.end.y)
	colocar(pies, mirando)


## Seguimiento a mano, como Hollow Knight: el objetivo se recorta a los limites ANTES de suavizar, asi
## la camara se frena sola al acercarse al borde en vez de chocar con el limite. En Y el suavizado es
## de segundo orden: su velocidad no cambia de golpe cuando el objetivo se detiene. El Jugador la llama
## en todos los ticks, tambien congelado, muerto o sentado. Los limit_* quedan como seguro.
func seguir(delta: float, pies: Vector2, mirando: float) -> void:
	var objetivo: Vector2 = _objetivo(pies, mirando)
	var actual: Vector2 = global_position
	actual.x += (objetivo.x - actual.x) * minf(suavizado_camara_x * delta, 1.0)
	actual.y = _amortiguar_y(actual.y, objetivo.y, delta)
	global_position = actual


## Pone la camara en su objetivo, sin suavizado: al entrar a la sala y al reaparecer.
func colocar(pies: Vector2, mirando: float) -> void:
	global_position = _objetivo(pies, mirando)
	_velocidad_camara_y = 0.0
	reset_smoothing()


## Tiembla ticks ticks, empezando en px de amplitud (baja en linea recta). Si el temblor en curso todavia
## es mas fuerte, sigue ese. Lo pide Jugador.temblar.
func temblar(ticks: int, px: float) -> void:
	if ticks <= 0:
		return
	if _ticks_temblando > 0 and _ticks_temblor_total > 0:
		var queda: float = _px_temblor * float(_ticks_temblando) / float(_ticks_temblor_total)
		if queda > px:
			return
	_ticks_temblando = ticks
	_ticks_temblor_total = ticks
	_px_temblor = px


## Un tick del temblor: patron fijo, sin azar, y la amplitud baja en linea recta. En vertical el signo
## cambia cada 2 ticks; en horizontal, cada 3 y con temblor_fraccion_x de la amplitud: con periodos distintos
## el punto no da vueltas en circulo. Aterrizar otra vez lo reinicia, no lo suma. Lo llama Jugador._aterrizar.
func avanzar_temblor() -> void:
	temblor_x = 0.0
	temblor_y = 0.0
	if _ticks_temblando > 0 and _ticks_temblor_total > 0:
		var transcurridos: int = _ticks_temblor_total - _ticks_temblando
		var queda: float = _px_temblor * float(_ticks_temblando) / float(_ticks_temblor_total)
		temblor_y = queda if (transcurridos / 2) % 2 == 0 else -queda
		temblor_x = queda * temblor_fraccion_x * (1.0 if (transcurridos / 3) % 2 == 0 else -1.0)
		_ticks_temblando -= 1
	offset = Vector2(temblor_x, temblor_y) if Ajustes.temblor else Vector2.ZERO


## Corta el temblor y deja la camara sin mover: al reaparecer tras un peligro.
func detener_temblor() -> void:
	_ticks_temblando = 0
	temblor_x = 0.0
	temblor_y = 0.0
	offset = Vector2.ZERO


# Centro de la camara al que se quiere llegar: sobre el jugador, recortado para que la vista no salga
# de la sala. Si la vista es mayor que la sala en un eje, se centra en ese eje, como hace Camera2D con
# sus limites (medido el 07-oct-2026); si no, el recorte con los bordes invertidos daria otro punto.
func _objetivo(pies: Vector2, mirando: float) -> Vector2:
	var media: Vector2 = get_viewport_rect().size / zoom / 2.0
	var centro: Vector2 = _limites.get_center()
	var objetivo: Vector2 = pies + _altura_camara
	objetivo.x += adelanto_camara * mirando
	if _limites.size.x <= media.x * 2.0:
		objetivo.x = centro.x
	else:
		objetivo.x = clampf(objetivo.x, _limites.position.x + media.x, _limites.end.x - media.x)
	if _limites.size.y <= media.y * 2.0:
		objetivo.y = centro.y
	else:
		objetivo.y = clampf(objetivo.y, _limites.position.y + media.y, _limites.end.y - media.y)
	return objetivo


# Amortiguado critico hacia el objetivo (la formula de SmoothDamp de Unity, sin tope de velocidad).
func _amortiguar_y(actual: float, objetivo: float, delta: float) -> float:
	var omega: float = 2.0 / maxf(tiempo_camara_y, 0.0001)
	var x: float = omega * delta
	var factor: float = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var diferencia: float = actual - objetivo
	var empuje: float = (_velocidad_camara_y + omega * diferencia) * delta
	_velocidad_camara_y = (_velocidad_camara_y - omega * empuje) * factor
	var nuevo: float = objetivo + (diferencia + empuje) * factor
	# No se pasa del objetivo.
	if (objetivo - actual > 0.0) == (nuevo > objetivo):
		nuevo = objetivo
		_velocidad_camara_y = 0.0
	return nuevo
