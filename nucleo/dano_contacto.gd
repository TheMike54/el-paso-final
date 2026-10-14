class_name DanoContacto
extends Area2D
# Componente que dana al jugador mientras lo toca. Enemigo o cuerpo danino: retroceso. Peligro
# (pinchos, acido, fosas): lleva al jugador a su ultimo punto seguro. Revisa el contacto en cada
# tick y no al entrar, para volver a danar al que sigue dentro al acabarse la invulnerabilidad.

## Vidas que quita cada golpe.
@export var dano: int = 1
## Peligro del entorno: en vez de empujar, devuelve al jugador al ultimo suelo firme.
@export var peligro: bool = false


func _ready() -> void:
	Capas.poner(self, Capas.DANINO, Capas.JUGADOR)


func _physics_process(_delta: float) -> void:
	for cuerpo: Node2D in get_overlapping_bodies():
		var jugador: Jugador = cuerpo as Jugador
		if jugador != null:
			jugador.recibir_dano(dano, global_position.x, peligro)
