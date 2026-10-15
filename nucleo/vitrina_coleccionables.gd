class_name VitrinaColeccionables
extends Node2D
# La sala donde se ven todos los coleccionables juntados (como la de las larvas de Hollow Knight o la de
# las pulgas de Silksong): dibuja un lugar por cada coleccionable del juego, lleno si ya se junto. Lee
# Partida al entrar; el total del juego es un dato de la vitrina, no se adivina.

## Coleccionables que hay en todo el juego.
@export var total_del_juego: int = 12
## Lugares por fila y separacion entre ellos, en px.
@export var por_fila: int = 6
@export var separacion: float = 96.0

## Juntados al entrar; publico para los guiones.
var juntados: int = 0


func _ready() -> void:
	juntados = Partida.total_coleccionables()
	queue_redraw()


func _draw() -> void:
	for i: int in range(total_del_juego):
		var lugar: Vector2 = Vector2(float(i % por_fila) * separacion, float(i / por_fila) * separacion)
		draw_circle(lugar, 30.0, Color(0.16, 0.16, 0.19))
		if i < juntados:
			draw_circle(lugar, 24.0, Coleccionable.COLOR)
