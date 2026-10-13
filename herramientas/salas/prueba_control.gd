extends Node
# Prueba del mapeo del control (Xbox / PlayStation) sin control conectado: para cada fila de la
# tabla de docs/contrato.md arma el evento de boton o de eje y revisa que el InputMap lo
# traduzca a su accion, y solo a esa. Deja en "casos" y "fallos" el resultado para el guion.

var casos: int = 0
var fallos: int = 0


func _ready() -> void:
	_boton(JOY_BUTTON_A, &"saltar")
	_boton(JOY_BUTTON_X, &"atacar")
	_boton(JOY_BUTTON_B, &"curar")
	# LB es mapa rapido con el juego andando y pagina anterior en el marco, que detiene el juego: no chocan.
	_botones(JOY_BUTTON_LEFT_SHOULDER, [&"mapa_rapido", &"pagina_anterior"])
	_boton(JOY_BUTTON_Y, &"mapa")
	_boton(JOY_BUTTON_BACK, &"inventario")
	_boton(JOY_BUTTON_START, &"pausa")
	_eje(JOY_AXIS_LEFT_X, -1.0, [&"mover_izquierda"])
	_eje(JOY_AXIS_LEFT_X, 1.0, [&"mover_derecha"])
	_eje(JOY_AXIS_LEFT_Y, -1.0, [&"mover_arriba", &"interactuar"])
	_eje(JOY_AXIS_LEFT_Y, 1.0, [&"mover_abajo"])
	_eje(JOY_AXIS_TRIGGER_RIGHT, 1.0, [&"impulso"])
	_eje(JOY_AXIS_TRIGGER_RIGHT, 0.5, [&"impulso"])
	_eje(JOY_AXIS_LEFT_X, 0.1, [])
	_eje(JOY_AXIS_TRIGGER_LEFT, 1.0, [])
	_boton(JOY_BUTTON_RIGHT_SHOULDER, &"pagina_siguiente")
	print("PRUEBAS control casos=%d fallos=%d" % [casos, fallos])


# Un boton debe disparar solo su accion; con accion vacia, ninguna (boton libre).
func _boton(boton: JoyButton, accion: StringName) -> void:
	var evento: InputEventJoypadButton = InputEventJoypadButton.new()
	evento.button_index = boton
	evento.pressed = true
	var esperadas: Array[StringName] = []
	if not accion.is_empty():
		esperadas.append(accion)
	_revisar("boton %d" % boton, evento, esperadas)


func _botones(boton: JoyButton, esperadas: Array[StringName]) -> void:
	var evento: InputEventJoypadButton = InputEventJoypadButton.new()
	evento.button_index = boton
	evento.pressed = true
	_revisar("boton %d" % boton, evento, esperadas)


func _eje(eje: JoyAxis, valor: float, esperadas: Array[StringName]) -> void:
	var evento: InputEventJoypadMotion = InputEventJoypadMotion.new()
	evento.axis = eje
	evento.axis_value = valor
	_revisar("eje %d en %.1f" % [eje, valor], evento, esperadas)


func _revisar(nombre: String, evento: InputEvent, esperadas: Array[StringName]) -> void:
	var obtenidas: Array[StringName] = []
	for accion: StringName in InputMap.get_actions():
		if not String(accion).begins_with("ui_") and evento.is_action_pressed(accion):
			obtenidas.append(accion)
	casos += 1
	var bien: bool = obtenidas.size() == esperadas.size()
	for accion: StringName in esperadas:
		bien = bien and obtenidas.has(accion)
	if not bien:
		fallos += 1
		print("FALLO control: %s da %s, se esperaba %s" % [nombre, obtenidas, esperadas])
