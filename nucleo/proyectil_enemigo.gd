class_name ProyectilEnemigo
extends AtaqueEnemigo
# Disparo de un enemigo: un ataque que avanza recto (crear_disparo) o en arco con su propia gravedad (crear_arco),
# dana al jugador al tocarlo y desaparece contra un solido (buscado con un rayo que cubre el paso del tick, como la
# bola del jugador) o al acabar su vida. Con se_puede_parar, el ataque del jugador lo para como a cualquier
# AtaqueEnemigo. Lo crea ComportamientoEnemigo (disparar, lanzar_en_arco).

const TAMANO: Vector2 = Vector2(36.0, 36.0)

## Velocidad del disparo recto, en px/s.
@export var velocidad: float = 480.0
## Gravedad propia, en px/s^2. 0: recto.
@export var gravedad: float = 0.0

## Velocidad de cada tick, en px/s; publica para las pruebas.
var velocidad_actual: Vector2 = Vector2.ZERO


static func crear_disparo(direccion: Vector2, dano_del_golpe: int, parable: bool) -> ProyectilEnemigo:
	var disparo: ProyectilEnemigo = ProyectilEnemigo._crear(dano_del_golpe, parable)
	disparo.velocidad_actual = direccion.normalized() * disparo.velocidad
	return disparo


## Disparo en arco: sale con velocidad_inicial (px/s) y cae con gravedad_propia (px/s^2).
static func crear_arco(velocidad_inicial: Vector2, gravedad_propia: float, dano_del_golpe: int, parable: bool) -> ProyectilEnemigo:
	var disparo: ProyectilEnemigo = ProyectilEnemigo._crear(dano_del_golpe, parable)
	disparo.velocidad_actual = velocidad_inicial
	disparo.gravedad = gravedad_propia
	return disparo


## Velocidad inicial para que un arco que sale a grados sobre la horizontal caiga en objetivo (relativo a la
## salida), como CalculateProjectileVelocity de Silksong: el angulo fijo y la rapidez calculada, sin pasar de
## tope. Sin solucion (el objetivo esta demasiado alto para ese angulo), sale con el tope.
static func velocidad_para(objetivo: Vector2, grados: float, gravedad_propia: float, tope: float) -> Vector2:
	var sentido: float = 1.0 if objetivo.x >= 0.0 else -1.0
	var angulo: float = deg_to_rad(grados)
	var dx: float = absf(objetivo.x)
	var subida: float = -objetivo.y
	var coseno: float = cos(angulo)
	var denominador: float = 2.0 * coseno * coseno * (dx * tan(angulo) - subida)
	var rapidez: float = tope
	if denominador > 0.0 and dx > 0.0:
		rapidez = minf(sqrt(gravedad_propia * dx * dx / denominador), tope)
	return Vector2(sentido * rapidez * coseno, -rapidez * sin(angulo))


static func _crear(dano_del_golpe: int, parable: bool) -> ProyectilEnemigo:
	var disparo: ProyectilEnemigo = ProyectilEnemigo.new()
	disparo.dano = dano_del_golpe
	disparo.se_puede_parar = parable
	disparo.ticks = 180
	disparo.monitorable = true
	disparo._poner_forma(Rect2(-TAMANO / 2.0, TAMANO))
	return disparo


func _physics_process(delta: float) -> void:
	if parado or Congelado.activo():
		return
	velocidad_actual.y += gravedad * delta
	var paso: Vector2 = velocidad_actual * delta
	var frente: Vector2 = global_position + paso + velocidad_actual.normalized() * TAMANO.x / 2.0
	if not Capas.rayo_a_escenario(self, global_position, frente).is_empty():
		queue_free()
		return
	position += paso
	super(delta)
