class_name EscenaMuestra
extends Control
# Escena de muestra de la pantalla de brillo cuando no hay sala detras (Configuracion abierta desde el menu): cielo,
# edificios, suelo, un banco y el jugador, dibujados con rectangulos de color en proporcion a su tamano. Sin
# texturas, para no pesar en el S50 ni depender de herramientas/. Desde la pausa se usa la foto de la sala.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var a: float = size.x
	var h: float = size.y
	draw_rect(Rect2(0.0, 0.0, a, h), Color(0.09, 0.11, 0.2))
	draw_rect(Rect2(0.0, h * 0.45, a, h * 0.25), Color(0.13, 0.15, 0.26))
	# Edificios: x, ancho y alto en fracciones de la escena.
	for edificio: Vector3 in [Vector3(0.04, 0.16, 0.42), Vector3(0.24, 0.12, 0.3), Vector3(0.62, 0.18, 0.5), Vector3(0.84, 0.12, 0.34)]:
		draw_rect(Rect2(a * edificio.x, h * (0.78 - edificio.z), a * edificio.y, h * edificio.z), Color(0.2, 0.2, 0.28))
		draw_rect(Rect2(a * (edificio.x + 0.03), h * (0.82 - edificio.z), a * 0.03, h * 0.05), Color(0.85, 0.7, 0.35))
	draw_rect(Rect2(0.0, h * 0.78, a, h * 0.22), Color(0.24, 0.2, 0.17))
	draw_rect(Rect2(0.0, h * 0.78, a, h * 0.02), Color(0.4, 0.34, 0.26))
	# Banco y jugador.
	draw_rect(Rect2(a * 0.4, h * 0.71, a * 0.12, h * 0.03), Color(0.55, 0.38, 0.22))
	draw_rect(Rect2(a * 0.41, h * 0.74, a * 0.015, h * 0.04), Color(0.4, 0.27, 0.15))
	draw_rect(Rect2(a * 0.495, h * 0.74, a * 0.015, h * 0.04), Color(0.4, 0.27, 0.15))
	draw_rect(Rect2(a * 0.6, h * 0.62, a * 0.04, h * 0.16), Color(0.85, 0.85, 0.9))
	draw_rect(Rect2(a * 0.605, h * 0.585, a * 0.03, h * 0.05), Color(0.95, 0.82, 0.7))
