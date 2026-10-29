class_name CamaraJugador
extends Camera2D
# Camara del jugador (nodo Camara de nucleo/jugador.tscn): lo sigue a mano, recortada a los limites de la sala y a
# los de la ZonaCamara que manda, y tiembla. No tiene tick ni _ready propios: el Jugador la llama en su
# _physics_process, en los mismos puntos de siempre, para que el seguimiento y el temblor corran en el mismo orden que
# el movimiento y paren con el congelado.

## Ticks desde que se coloco la camara (al entrar a la sala o al reaparecer) en que entrar a una ZonaCamara la coloca
## al instante en vez de suavizar: medio segundo, el startLockedTimer de Hollow Knight. Cubre la llegada por una
## puerta, que camina 20 ticks bajo un aclarado de 30.
const TICKS_AL_INSTANTE: int = 30
## Ticks de seguimiento lento al entrar o salir de una ZonaCamara, para que el cambio de limites no sea un jalon
## (Hollow Knight: dampTimeSlow 0,5 s durante slowTime 0,5 s).
const TICKS_LENTO: int = 30
## Seguimiento horizontal durante el lento, fraccion por segundo: 1 / 0,5 s, el dampTimeSlow de Hollow Knight.
const SUAVIZADO_X_LENTO: float = 2.0
## Seguimiento vertical durante el lento, en s: el dampTimeSlow de Hollow Knight.
const TIEMPO_Y_LENTO: float = 0.5

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
# Zonas de camara con el jugador dentro, en orden de entrada: manda la ultima (lockZoneList de Hollow Knight).
var _zonas: Array[ZonaCamara] = []
# Ultimos pies y direccion recibidos del Jugador: entrar_zona coloca la camara con ellos.
var _pies: Vector2 = Vector2.ZERO
var _mirando: float = 1.0
# Ticks desde el ultimo colocar (tope TICKS_AL_INSTANTE + 1) y ticks que quedan de seguimiento lento.
var _ticks_desde_colocar: int = 0
var _ticks_lento: int = 0


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
	_pies = pies
	_mirando = mirando
	_ticks_desde_colocar = mini(_ticks_desde_colocar + 1, TICKS_AL_INSTANTE + 1)
	var lento: bool = _ticks_lento > 0
	if lento:
		_ticks_lento -= 1
	var objetivo: Vector2 = _objetivo(pies, mirando)
	var actual: Vector2 = global_position
	var suavizado_x: float = SUAVIZADO_X_LENTO if lento else suavizado_camara_x
	actual.x += (objetivo.x - actual.x) * minf(suavizado_x * delta, 1.0)
	actual.y = _amortiguar_y(actual.y, objetivo.y, delta, TIEMPO_Y_LENTO if lento else tiempo_camara_y)
	global_position = actual


## Pone la camara en su objetivo, sin suavizado: al entrar a la sala y al reaparecer.
func colocar(pies: Vector2, mirando: float) -> void:
	_pies = pies
	_mirando = mirando
	_ticks_desde_colocar = 0
	_saltar_al_objetivo()


## Lo llama la ZonaCamara al entrar el jugador: pasa a mandar ella. Recien colocada la camara, se coloca al instante
## dentro de la zona (EnterLockZoneInstant de Hollow Knight); si no, la alcanza con el seguimiento lento.
func entrar_zona(zona: ZonaCamara) -> void:
	# Si ya mandaba, la vista no cambia: ni salto ni seguimiento lento.
	if _zona_que_manda() == zona:
		return
	_zonas.erase(zona)
	_zonas.append(zona)
	_alcanzar_vista_nueva()


## Lo llama la ZonaCamara al salir el jugador: vuelve a mandar la zona anterior o, sin ninguna, la sala. Salir de
## una zona que no mandaba no cambia la vista, asi que no frena el seguimiento.
func salir_zona(zona: ZonaCamara) -> void:
	if not _zonas.has(zona):
		return
	var mandaba: bool = _zona_que_manda() == zona
	_zonas.erase(zona)
	if mandaba:
		_alcanzar_vista_nueva()


## Lo que la camara puede mostrar ahora: los limites de la sala recortados por los de la zona que manda
## (classes/class_rect2.rst:437). Una zona que ya no existe deja de mandar.
func limites_vista() -> Rect2:
	var zona: ZonaCamara = _zona_que_manda()
	if zona == null:
		return _limites
	return _limites.intersection(zona.limites)


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
# de limites_vista() (la sala y la zona que manda). Si la vista es mayor que ese rectangulo en un eje, se centra en
# ese eje, como hace Camera2D con sus limites (medido el 07-oct-2026); si no, el recorte con los bordes invertidos
# daria otro punto.
func _objetivo(pies: Vector2, mirando: float) -> Vector2:
	var limites: Rect2 = limites_vista()
	var media: Vector2 = get_viewport_rect().size / zoom / 2.0
	var centro: Vector2 = limites.get_center()
	var objetivo: Vector2 = pies + _altura_camara
	objetivo.x += adelanto_camara * mirando
	if limites.size.x <= media.x * 2.0:
		objetivo.x = centro.x
	else:
		objetivo.x = clampf(objetivo.x, limites.position.x + media.x, limites.end.x - media.x)
	if limites.size.y <= media.y * 2.0:
		objetivo.y = centro.y
	else:
		objetivo.y = clampf(objetivo.y, limites.position.y + media.y, limites.end.y - media.y)
	return objetivo


# La ultima zona de la pila que sigue existiendo, o null: las liberadas con el jugador dentro se sueltan aqui.
func _zona_que_manda() -> ZonaCamara:
	while not _zonas.is_empty() and not is_instance_valid(_zonas[-1]):
		_zonas.pop_back()
	if _zonas.is_empty():
		return null
	return _zonas[-1]


# Cambio la zona que manda: recien colocada la camara (al llegar a la sala o al reaparecer) salta a la vista nueva,
# porque colocar ya recorto con la zona vieja; despues, la alcanza con el seguimiento lento. Sin volver a contar
# desde cero: una zona tocada mas tarde ya no cambia al instante.
func _alcanzar_vista_nueva() -> void:
	if _ticks_desde_colocar <= TICKS_AL_INSTANTE:
		# Al liberar la sala, la zona avisa la salida con la camara ya fuera del arbol, sin vista que medir.
		if is_inside_tree():
			_saltar_al_objetivo()
	else:
		_ticks_lento = TICKS_LENTO


# La camara en su objetivo con los ultimos pies, sin suavizado ni lento en curso.
func _saltar_al_objetivo() -> void:
	_ticks_lento = 0
	global_position = _objetivo(_pies, _mirando)
	_velocidad_camara_y = 0.0
	reset_smoothing()


# Amortiguado critico hacia el objetivo en tiempo s (la formula de SmoothDamp de Unity, sin tope de velocidad).
func _amortiguar_y(actual: float, objetivo: float, delta: float, tiempo: float) -> float:
	var omega: float = 2.0 / maxf(tiempo, 0.0001)
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
