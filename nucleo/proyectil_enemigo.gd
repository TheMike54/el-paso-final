class_name ProyectilEnemigo
extends AtaqueEnemigo
# Disparo de un enemigo: un ataque que avanza recto y sin gravedad, dana al jugador al tocarlo y desaparece
# contra un solido (buscado con un rayo, como la bola del jugador) o al acabar su vida. Con se_puede_parar, el
# ataque del jugador lo para como a cualquier AtaqueEnemigo. Lo crea ComportamientoEnemigo.disparar (crear_disparo).

const TAMANO: Vector2 = Vector2(36.0, 36.0)

## Velocidad, en px/s.
@export var velocidad: float = 480.0

var _direccion: Vector2 = Vector2.RIGHT


static func crear_disparo(direccion: Vector2, dano_del_golpe: int, parable: bool) -> ProyectilEnemigo:
	var disparo: ProyectilEnemigo = ProyectilEnemigo.new()
	disparo._direccion = direccion.normalized()
	disparo.dano = dano_del_golpe
	disparo.se_puede_parar = parable
	disparo.ticks = 180
	disparo.monitorable = true
	disparo._poner_forma(Rect2(-TAMANO / 2.0, TAMANO))
	return disparo


func _physics_process(delta: float) -> void:
	if parado or Congelado.activo():
		return
	var paso: Vector2 = _direccion * velocidad * delta
	var frente: Vector2 = global_position + paso + _direccion * TAMANO.x / 2.0
	var consulta: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, frente)
	consulta.collision_mask = Capas.ESCENARIO
	if not get_world_2d().direct_space_state.intersect_ray(consulta).is_empty():
		queue_free()
		return
	position += paso
	super(delta)
