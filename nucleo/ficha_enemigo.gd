class_name FichaEnemigo
extends Resource
# Ficha de un enemigo: lo que lo distingue de los demas (vida, dano, tamano, grupo de reaparicion),
# como datos y no como codigo. La usa nucleo/enemigo.gd. Es de solo lectura en ejecucion: la vida
# que le queda a cada ejemplar vive en su Enemigo, no aqui.

## Debil: reaparece al salir y volver a entrar a la sala. Fuerte: solo despues de descansar en un banco.
enum Reaparicion { AL_VOLVER_A_ENTRAR, AL_DESCANSAR }

## Id del tipo de enemigo, estable: es lo que emite Eventos.enemigo_vencido.
@export var id: StringName = &""
## Vida al aparecer: cada golpe le resta su dano (ataque 1, bola 2).
@export var vida: int = 2
## Vidas que le quita al jugador al tocarlo.
@export var dano_contacto: int = 1
## Tamano de su cuerpo, en px, con los pies en el origen.
@export var tamano: Vector2 = Vector2(80.0, 80.0)
## Color de la caja gris mientras no hay arte.
@export var color: Color = Color(0.55, 0.55, 0.58)
@export var reaparicion: Reaparicion = Reaparicion.AL_VOLVER_A_ENTRAR
