extends ComportamientoEnemigo
# Escupidor de pruebas: quieto en el suelo y mirando al jugador. Cuando lo ve, avisa aviso ticks (se aclara, como el
# muneco que ataca) y le lanza una bola en arco que cae donde estaba (la cuenta de Silksong: angulo fijo, rapidez
# calculada). Espera espera ticks antes del siguiente. La bola se puede desviar con el ataque.

const DatosEscupidor = preload("datos_escupidor.gd")

## Bolas lanzadas; publico para los guiones.
var lanzados: int = 0
## La ultima bola lanzada y adonde iba, para las pruebas.
var ultimo: ProyectilEnemigo = null
var ultimo_objetivo: Vector2 = Vector2.ZERO

var _ticks_aviso: int = 0
var _ticks_espera: int = 0
var _d: DatosEscupidor = null


func _ready() -> void:
	_d = datos as DatosEscupidor


func datos_por_omision() -> DatosComportamiento:
	return DatosEscupidor.new()


func actuar() -> void:
	caer()
	enemigo.velocity.x = 0.0
	mover()
	var objetivo: Jugador = jugador()
	if objetivo != null and objetivo.global_position.x != enemigo.global_position.x:
		enemigo.mirando = signf(objetivo.global_position.x - enemigo.global_position.x)
	if _ticks_espera > 0:
		_ticks_espera -= 1
		return
	if _ticks_aviso == 0:
		if ve_al_jugador(_d.radio):
			_ticks_aviso = _d.aviso
			enemigo.modulate = COLOR_AVISO
		return
	_ticks_aviso -= 1
	if _ticks_aviso > 0 or objetivo == null:
		return
	enemigo.modulate = Color.WHITE
	ultimo_objetivo = objetivo.global_position + Vector2(0.0, -40.0)
	ultimo = lanzar_en_arco(_d.salida, ultimo_objetivo, _d.grados, _d.gravedad_bola, _d.tope, 1, true)
	lanzados += 1
	_ticks_espera = _d.espera
