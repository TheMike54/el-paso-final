class_name Capas
extends RefCounted
# Capas de fisica con nombre (los nombres estan en project.godot, layer_names/2d_physics): cada pieza se pone en la
# suya y mira solo lo que le toca, en lugar de ver todo en la capa 1 y descartar por tipo. Las ponen los scripts de
# cada pieza en _ready, asi una sala no puede olvidarlas. Tabla completa en docs/contrato.md, «Capas de fisica».

## Suelos, paredes y todo StaticBody2D. Es la capa 1, la de omision: las formas de las salas no la fijan.
const ESCENARIO: int = 1 << 0
## El cuerpo del jugador (y la caja gris).
const JUGADOR: int = 1 << 1
## Lo que el ataque del jugador golpea: Golpeable y Cortable.
const GOLPEABLE: int = 1 << 2
## Lo que dana al jugador: DanoContacto y lo que hereda de el (pinchos, enemigos, ataques y proyectiles enemigos).
const DANINO: int = 1 << 3
## Zonas que solo esperan al jugador: puertas, banco, recogibles, NPC, reto, entregas.
const INTERACCION: int = 1 << 4
## El ataque del jugador y su bola: nadie los mira.
const ATAQUE_JUGADOR: int = 1 << 5
## Reservada para el primer enemigo que camine con fisica (CharacterBody2D): miraria ESCENARIO.
const CUERPO_ENEMIGO: int = 1 << 6


## Pone la capa y la mascara de un objeto de fisica.
static func poner(objeto: CollisionObject2D, capa: int, mascara: int) -> void:
	objeto.collision_layer = capa
	objeto.collision_mask = mascara
