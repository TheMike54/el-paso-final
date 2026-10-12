class_name Proyectil
extends Area2D
# Poder del boton de curar (habilidad proyectil; nombre neutro hasta decidir que es en el mundo):
# avanza recto y sin gravedad, golpea una sola vez a cada Golpeable que toca y lo atraviesa, y
# desaparece contra un solido o al acabar su recorrido. Los solidos se buscan con un rayo: un Area2D
# no detecta a un StaticBody2D. Lo crea el jugador en su sala.
const TAMANO: Vector2 = Vector2(60.0, 40.0)
const COLOR: Color = Color(0.75, 0.75, 0.8)

## Velocidad, en px/s.
@export var velocidad: float = 900.0
## Ticks que dura antes de desaparecer solo (60: 900 px).
@export var ticks_vida: int = 60
## Dano que hace a cada Golpeable.
@export var dano: int = 2

## Sentido en x: 1 a la derecha, -1 a la izquierda. Lo fija quien lo lanza.
var sentido: float = 1.0
## Cuerpo que lo lanza: el rayo no lo cuenta como solido.
var lanzador: CollisionObject2D = null

var _golpeados: Array[Golpeable] = []


func _ready() -> void:
	area_entered.connect(_al_tocar_area)


func _physics_process(delta: float) -> void:
	if Congelado.activo():
		return
	# El rayo va del centro hasta el frente de la bola despues de este paso: un solido delgado no
	# se salta aunque la bola avance mas de su grosor en un tick.
	var paso: float = sentido * velocidad * delta
	var frente: Vector2 = global_position + Vector2(paso + sentido * TAMANO.x / 2.0, 0.0)
	var consulta: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, frente)
	if is_instance_valid(lanzador):
		consulta.exclude = [lanzador.get_rid()]
	if not get_world_2d().direct_space_state.intersect_ray(consulta).is_empty():
		queue_free()
		return
	position.x += paso
	ticks_vida -= 1
	if ticks_vida <= 0:
		queue_free()


func _al_tocar_area(area: Area2D) -> void:
	var golpeable: Golpeable = area as Golpeable
	if golpeable != null and not _golpeados.has(golpeable):
		_golpeados.append(golpeable)
		golpeable.recibir_golpe(self, dano)


func _draw() -> void:
	draw_rect(Rect2(-TAMANO / 2.0, TAMANO), COLOR)
