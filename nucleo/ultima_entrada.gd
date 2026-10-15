class_name UltimaEntrada
extends Node
# Recuerda si lo ultimo que uso la persona fue el dedo (o el raton) o un control o el teclado. Tema.dar_foco lo lee
# para dibujar el foco de un menu solo al navegar con control o teclado, aunque haya un control conectado y se este
# tocando con el dedo. Lo crea Arranque; corre tambien en pausa, porque la pausa es un menu.

## true: lo ultimo fue un control o el teclado. Al arrancar, true si ya hay un control conectado.
static var con_control: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	con_control = not Input.get_connected_joypads().is_empty()


func _input(evento: InputEvent) -> void:
	anotar(evento)


## Anota un evento: un toque o un clic lo pasan a false; una tecla, un boton del control o un stick inclinado a
## la mitad, a true. Lo demas (soltar, arrastrar, mover el raton) no cambia nada. Publico para la prueba.
static func anotar(evento: InputEvent) -> void:
	if evento is InputEventScreenTouch or evento is InputEventMouseButton:
		if evento.is_pressed():
			con_control = false
	elif evento is InputEventKey or evento is InputEventJoypadButton:
		if evento.is_pressed():
			con_control = true
	elif evento is InputEventJoypadMotion:
		if absf((evento as InputEventJoypadMotion).axis_value) >= 0.5:
			con_control = true
