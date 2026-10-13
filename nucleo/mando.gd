class_name Mando
extends RefCounted
# Reasignacion de los botones del control (mando): cada accion reasignable tiene un boton; asignar uno que ya
# usaba otra accion los intercambia, asi ninguna accion se queda sin boton. Los ejes no se reasignan: ni el
# movimiento ni impulso (RT) ni interactuar (stick arriba), que en project.godot no tienen boton. Lo que se cambia se guarda en Ajustes ("mando") y se aplica al InputMap al cargarlos. Estatico,
# como Ajustes: el InputMap es uno solo para todo el juego.

const REASIGNABLES: Array[StringName] = [&"saltar", &"atacar", &"curar", &"mapa", &"mapa_rapido", &"mochila", &"pausa"]
## Nombre en pantalla de cada boton de un control estandar (indices de JoyButton).
const NOMBRES: PackedStringArray = ["A / Cruz", "B / Circulo", "X / Cuadrado", "Y / Triangulo", "Select", "Guia", "Start", "Stick izq.", "Stick der.", "LB / L1", "RB / R1", "Arriba", "Abajo", "Izquierda", "Derecha"]

# Boton de cada accion segun project.godot, leido la primera vez: lo que restaura «Restablecer».
static var _por_omision: Dictionary[StringName, int] = {}


static func _recordar_por_omision() -> void:
	if not _por_omision.is_empty():
		return
	for accion: StringName in REASIGNABLES:
		_por_omision[accion] = boton_de(accion)


## Boton del control de la accion, o -1 si no tiene.
static func boton_de(accion: StringName) -> int:
	for evento: InputEvent in InputMap.action_get_events(accion):
		var boton: InputEventJoypadButton = evento as InputEventJoypadButton
		if boton != null:
			return boton.button_index
	return -1


static func nombre_de(boton: int) -> String:
	if boton < 0:
		return "—"
	return NOMBRES[boton] if boton < NOMBRES.size() else "Boton %d" % boton


## Asigna el boton a la accion; si otra accion lo tenia, recibe el boton viejo de esta.
static func asignar(accion: StringName, boton: int) -> void:
	_recordar_por_omision()
	if not REASIGNABLES.has(accion) or not es_boton_valido(boton):
		return
	var viejo: int = boton_de(accion)
	if viejo < 0:
		return
	for otra: StringName in REASIGNABLES:
		if otra != accion and boton_de(otra) == boton:
			_poner(otra, viejo)
	_poner(accion, boton)


static func es_boton_valido(boton: int) -> bool:
	return boton >= 0 and boton < JOY_BUTTON_SDL_MAX


static func _poner(accion: StringName, boton: int) -> void:
	for evento: InputEvent in InputMap.action_get_events(accion):
		if evento is InputEventJoypadButton:
			InputMap.action_erase_event(accion, evento)
	if boton >= 0:
		var nuevo: InputEventJoypadButton = InputEventJoypadButton.new()
		nuevo.button_index = boton as JoyButton
		nuevo.device = -1
		InputMap.action_add_event(accion, nuevo)


## Los botones que difieren de project.godot, para guardarlos.
static func a_diccionario() -> Dictionary:
	_recordar_por_omision()
	var cambios: Dictionary = {}
	for accion: StringName in REASIGNABLES:
		var boton: int = boton_de(accion)
		if boton != _por_omision[accion]:
			cambios[String(accion)] = boton
	return cambios


## Vuelve a project.godot y aplica lo guardado intercambiando como asignar (un archivo editado a mano no deja dos
## acciones en el mismo boton); un valor raro (de un archivo danado, fuera de rango) se ignora.
static func aplicar(guardado: Variant) -> void:
	por_omision()
	if typeof(guardado) != TYPE_DICTIONARY:
		return
	var cambios: Dictionary = guardado
	for clave: Variant in cambios:
		var accion: StringName = StringName(str(clave))
		var valor: Variant = cambios[clave]
		if REASIGNABLES.has(accion) and typeof(valor) == TYPE_FLOAT:
			var boton: float = valor
			asignar(accion, int(boton))


static func por_omision() -> void:
	_recordar_por_omision()
	for accion: StringName in REASIGNABLES:
		_poner(accion, _por_omision[accion])
