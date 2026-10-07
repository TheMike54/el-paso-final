extends Node2D
# Dibuja franjas verticales sobre un rectangulo, con un color de base opcional. Sirve para que
# las capas de fondo y de frente de la sala de prueba se vean moverse sin ninguna imagen: el
# arte de las capas entra despues, con su registro de procedencia.

## Rectangulo que cubren las franjas, en coordenadas de la capa.
@export var area: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)
## Distancia entre el inicio de una franja y el de la siguiente, en px.
@export var separacion: float = 320.0
## Ancho de cada franja, en px.
@export var ancho: float = 80.0
@export var color_franja: Color = Color(0.3, 0.3, 0.4)
## Color que llena todo el area debajo de las franjas. Transparente: sin base.
@export var color_base: Color = Color(0.0, 0.0, 0.0, 0.0)


func _draw() -> void:
	if color_base.a > 0.0:
		draw_rect(area, color_base)
	var x: float = area.position.x
	while x < area.end.x:
		draw_rect(Rect2(x, area.position.y, ancho, area.size.y), color_franja)
		x += separacion
