extends ComportamientoEnemigo
# Volador de pruebas, como el Vengefly de Hollow Knight: zumba alrededor de donde empezo hasta ver al jugador (cerca
# y sin una pared en medio); entonces lo persigue acelerando por eje con un tope y choca con las paredes. Tras
# TICKS_OLVIDO ticks sin verlo vuelve a zumbar en su sitio. Su ficha va sin gravedad: su cuerpo flota.

## Distancia a la que despierta, en px (7,6 u de Hollow Knight).
const RADIO_ALERTA: float = 330.0
## Aceleracion por eje al perseguir, en px/s^2: llega al tope en 1 s (en Hollow Knight, 2,25 u/s^2 = 98 px/s^2,
## tardaba 2,2 s y en el telefono se sintio lento, 17-oct-2026).
const ACELERACION: float = 217.0
## Rapidez maxima por eje al perseguir, en px/s (5 u/s).
const TOPE: float = 217.0
## Ticks sin ver al jugador antes de olvidarlo (10 s).
const TICKS_OLVIDO: int = 600
## Zumbido en su sitio: aceleracion, tope y distancia a la que se queda dando vueltas.
const ACELERACION_ZUMBIDO: float = 60.0
const TOPE_ZUMBIDO: float = 60.0
const RADIO_ZUMBIDO: float = 24.0

## Si persigue al jugador; publico para los guiones.
var persiguiendo: bool = false

var _origen: Vector2 = Vector2.ZERO
var _con_origen: bool = false
var _ticks_sin_ver: int = 0


func actuar() -> void:
	if not _con_origen:
		_origen = centro()
		_con_origen = true
	var ve: bool = ve_al_jugador(RADIO_ALERTA)
	if ve:
		persiguiendo = true
		_ticks_sin_ver = 0
	elif persiguiendo:
		_ticks_sin_ver += 1
		if _ticks_sin_ver >= TICKS_OLVIDO:
			persiguiendo = false
	var objetivo: Jugador = jugador()
	if persiguiendo and objetivo != null:
		_acelerar_hacia(objetivo.global_position + Vector2(0.0, -80.0), ACELERACION, TOPE, 0.0)
	else:
		_acelerar_hacia(_origen, ACELERACION_ZUMBIDO, TOPE_ZUMBIDO, RADIO_ZUMBIDO)
	mover()
	if absf(enemigo.velocity.x) > 1.0:
		enemigo.mirando = signf(enemigo.velocity.x)


## Lo pone a perseguir como si acabara de ver al jugador, con la cuenta del olvido en cero (para las pruebas).
func despertar() -> void:
	persiguiendo = true
	_ticks_sin_ver = 0


# Acelera cada eje hacia el punto, sin pasar del tope; a menos de radio en un eje, frena en ese eje.
func _acelerar_hacia(punto: Vector2, aceleracion: float, tope: float, radio: float) -> void:
	var delta: float = get_physics_process_delta_time()
	var falta: Vector2 = punto - centro()
	var velocidad: Vector2 = enemigo.velocity
	for eje: int in range(2):
		var hacia: float = signf(falta[eje]) if absf(falta[eje]) > radio else -signf(velocidad[eje])
		velocidad[eje] = clampf(velocidad[eje] + hacia * aceleracion * delta, -tope, tope)
	enemigo.velocity = velocidad
