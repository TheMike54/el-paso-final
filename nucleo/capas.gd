class_name Capas
extends RefCounted
# Capas de fisica con nombre (los nombres estan en project.godot, layer_names/2d_physics): cada pieza se pone en la
# suya y mira solo lo que le toca, en lugar de ver todo en la capa 1 y descartar por tipo. Las ponen los scripts de
# cada pieza en _ready, asi una sala no puede olvidarlas. Tabla completa en docs/contrato.md, «Capas de fisica».

## Suelos, paredes y todo StaticBody2D. Es la capa 1, la de omision: las formas de las salas no la fijan.
const ESCENARIO: int = 1 << 0
## El cuerpo del jugador.
const JUGADOR: int = 1 << 1
## Lo que el ataque del jugador golpea: Golpeable y Cortable.
const GOLPEABLE: int = 1 << 2
## Lo que dana al jugador: DanoContacto y lo que hereda de el (pinchos, enemigos, ataques y proyectiles enemigos).
const DANINO: int = 1 << 3
## Zonas que solo esperan al jugador: puertas, banco, recogibles, NPC, reto, entregas.
const INTERACCION: int = 1 << 4
## El ataque del jugador y su bola: nadie los mira.
const ATAQUE_JUGADOR: int = 1 << 5
## El cuerpo de cada Enemigo (CharacterBody2D): mira ESCENARIO. Nadie lo mira: el jugador lo atraviesa.
const CUERPO_ENEMIGO: int = 1 << 6


## Pone la capa y la mascara de un objeto de fisica.
static func poner(objeto: CollisionObject2D, capa: int, mascara: int) -> void:
	objeto.collision_layer = capa
	objeto.collision_mask = mascara


## Rayo de desde a hasta (globales) contra los solidos de ESCENARIO, sin areas: el Dictionary de intersect_ray,
## vacio si no choca. Solo dentro del tick (_physics_process o lo que este llama).
## excluir: los RID de los cuerpos que el rayo atraviesa (classes/class_physicsrayqueryparameters2d.rst:131).
static func rayo_a_escenario(quien: Node2D, desde: Vector2, hasta: Vector2, excluir: Array[RID] = []) -> Dictionary:
	var consulta: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(desde, hasta)
	consulta.exclude = excluir
	consulta.collision_mask = ESCENARIO
	return quien.get_world_2d().direct_space_state.intersect_ray(consulta)
