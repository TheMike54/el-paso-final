class_name DanoContacto
extends Area2D
# Componente que dana al jugador mientras lo toca. Enemigo o cuerpo danino: retroceso. Peligro
# (pinchos, acido, fosas): lleva al jugador a su ultimo punto seguro. Revisa el contacto en cada
# tick y no al entrar, para volver a danar al que sigue dentro al acabarse la invulnerabilidad.

## Vidas que quita cada golpe.
@export var dano: int = 1
## Peligro del entorno: en vez de empujar, devuelve al jugador al ultimo suelo firme.
@export var peligro: bool = false
## Pieza que aplasta contra esta zona fija, en el extremo de su recorrido: solo dana al que esta en el suelo mientras la
## pieza viene hacia aca y lo alcanza (como los Hero Squasher de Silksong). Vacio: dana siempre.
@export var aplastador: Vaiven = null
## Px de los pies del jugador al origen de aplastador en los que empieza a danar: su grosor mas el alto del jugador (180),
## y un margen para que el peligro llegue antes de que el cuerpo solido lo hunda en el suelo.
@export var alcance_aplastar: float = 190.0


func _ready() -> void:
	Capas.poner(self, Capas.DANINO, Capas.JUGADOR)


func _physics_process(_delta: float) -> void:
	for cuerpo: Node2D in get_overlapping_bodies():
		var jugador: Jugador = cuerpo as Jugador
		if jugador == null:
			continue
		if aplastador != null:
			jugador.no_recordar_punto_seguro()
		if _alcanza(jugador):
			jugador.recibir_dano(dano, global_position.x, peligro)


func _alcanza(jugador: Jugador) -> bool:
	return aplastador == null or (jugador.is_on_floor()
			and aplastador.aplasta(jugador.global_position, global_position, alcance_aplastar))
