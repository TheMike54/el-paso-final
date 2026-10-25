extends ComportamientoEnemigo
# Escupidor de pruebas: quieto en el suelo y mirando al jugador. Cuando lo ve, avisa AVISO ticks (se aclara, como el
# muneco que ataca) y le lanza una bola en arco que cae donde estaba (la cuenta de Silksong: angulo fijo, rapidez
# calculada). Espera ESPERA ticks antes del siguiente. La bola se puede parar.

const RADIO: float = 900.0
const AVISO: int = 30
## Ticks entre un tiro y el siguiente aviso: una bola cada 1,25 s (con 90, cada 2 s, se esquivaba muy facil en el
## telefono, 17-oct-2026).
const ESPERA: int = 45
## Angulo de salida sobre la horizontal.
const GRADOS: float = 50.0
## Gravedad de la bola: 0,7 de la de Hollow Knight (60 u/s^2 a 43 px/u).
const GRAVEDAD_BOLA: float = 1800.0
const TOPE: float = 1300.0
const SALIDA: Vector2 = Vector2(0.0, -70.0)

## Bolas lanzadas; publico para los guiones.
var lanzados: int = 0
## La ultima bola lanzada y adonde iba, para las pruebas.
var ultimo: ProyectilEnemigo = null
var ultimo_objetivo: Vector2 = Vector2.ZERO

var _ticks_aviso: int = 0
var _ticks_espera: int = 0


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
		if ve_al_jugador(RADIO):
			_ticks_aviso = AVISO
			enemigo.modulate = Color(1.7, 1.7, 1.7)
		return
	_ticks_aviso -= 1
	if _ticks_aviso > 0 or objetivo == null:
		return
	enemigo.modulate = Color.WHITE
	ultimo_objetivo = objetivo.global_position + Vector2(0.0, -40.0)
	ultimo = lanzar_en_arco(SALIDA, ultimo_objetivo, GRADOS, GRAVEDAD_BOLA, TOPE, 1, true)
	lanzados += 1
	_ticks_espera = ESPERA
