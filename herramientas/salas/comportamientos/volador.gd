extends ComportamientoEnemigo
# Volador de pruebas, como el Vengefly de Hollow Knight: zumba alrededor de donde empezo hasta ver al jugador (cerca
# y sin una pared en medio); entonces lo persigue acelerando por eje con un tope y choca con las paredes. Tras
# ticks_olvido ticks sin verlo vuelve a zumbar en su sitio. Su ficha va sin gravedad: su cuerpo flota.

const DatosVolador = preload("datos_volador.gd")

## Si persigue al jugador; publico para los guiones.
var persiguiendo: bool = false

var _origen: Vector2 = Vector2.ZERO
var _con_origen: bool = false
var _ticks_sin_ver: int = 0
var _d: DatosVolador = null


func _ready() -> void:
	_d = datos as DatosVolador


func datos_por_omision() -> DatosComportamiento:
	return DatosVolador.new()


func actuar() -> void:
	if not _con_origen:
		_origen = centro()
		_con_origen = true
	var ve: bool = ve_al_jugador(_d.radio_alerta)
	if ve:
		persiguiendo = true
		_ticks_sin_ver = 0
	elif persiguiendo:
		_ticks_sin_ver += 1
		if _ticks_sin_ver >= _d.ticks_olvido:
			persiguiendo = false
	var objetivo: Jugador = jugador()
	if persiguiendo and objetivo != null:
		_acelerar_hacia(objetivo.global_position + Vector2(0.0, -80.0), _d.aceleracion, _d.tope, 0.0)
	else:
		_acelerar_hacia(_origen, _d.aceleracion_zumbido, _d.tope_zumbido, _d.radio_zumbido)
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
