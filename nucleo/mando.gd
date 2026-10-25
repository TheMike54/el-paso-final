class_name Mando
extends RefCounted
# Reasignacion de los botones del control (mando): cada accion reasignable tiene un boton; asignar uno que ya
# usaba otra accion los intercambia, asi ninguna accion se queda sin boton. Los ejes no se reasignan: ni el
# movimiento ni impulso (RT) ni interactuar (stick arriba), que en project.godot no tienen boton. Lo que se cambia se guarda en Ajustes ("mando") y se aplica al InputMap al cargarlos. Estatico,
# como Ajustes: el InputMap es uno solo para todo el juego. Tambien da el nombre de cada boton (BOTONES), el mismo
# origen para Configuracion y para IconoBoton.

## Lo ultimo que se uso (UltimaEntrada.dispositivo): el dedo o un clic, el teclado o la familia de un control
## (familia), que decide como se dibujan sus botones en la interfaz (IconoBoton).
enum Dispositivo {TOQUE, TECLADO, XBOX, PLAYSTATION}

const REASIGNABLES: Array[StringName] = [&"saltar", &"atacar", &"curar", &"mapa", &"mapa_rapido", &"inventario", &"pausa"]
## Nombre que tenia inventario en ajustes de antes del 13-oct-2026, y el nuevo: aplicar() los traduce.
const ACCION_VIEJA: String = "mochila"
const ACCION_RENOMBRADA: StringName = &"inventario"
## Columnas de BOTONES: el nombre neutro (Configuracion, nombre_de) y el de cada familia (IconoBoton, nombre_en).
const NEUTRO: int = 0
const COLUMNA_XBOX: int = 1
const COLUMNA_PLAYSTATION: int = 2
## Los botones 0..CARA-1 son los de la cara (A B X Y): se dibujan como disco. En ellos la columna Xbox es la letra y
## la de PlayStation el simbolo que traza IconoBoton; en los demas, el texto de la pastilla.
const CARA: int = 4
# Array[Array] y no Array[PackedStringArray]: en una const, las filas literales quedan Array y leerlas como
# PackedStringArray da "" (sonda del 18-oct-2026 en 4.7.2).
## Nombre de cada boton de un control estandar, una fila por indice de JoyButton (0..14), y por columna neutro, Xbox y
## PlayStation. Las columnas difieren a proposito (Select / View / Share, Izquierda / Izq.).
const BOTONES: Array[Array] = [
	["A / Cruz", "A", "cruz"],
	["B / Circulo", "B", "circulo"],
	["X / Cuadrado", "X", "cuadrado"],
	["Y / Triangulo", "Y", "triangulo"],
	["Select", "View", "Share"],
	["Guia", "Guia", "PS"],
	["Start", "Menu", "Options"],
	["Stick izq.", "LS", "L3"],
	["Stick der.", "RS", "R3"],
	["LB / L1", "LB", "L1"],
	["RB / R1", "RB", "R1"],
	["Arriba", "Arriba", "Arriba"],
	["Abajo", "Abajo", "Abajo"],
	["Izquierda", "Izq.", "Izq."],
	["Derecha", "Der.", "Der."],
]
# Filas de BOTONES con el nombre de cada stick, que tambien nombra sus ejes.
const _STICK_IZQUIERDO: int = 7
const _STICK_DERECHO: int = 8

## Palabras del nombre de un control (Input.get_joy_name, base de SDL) que dicen PlayStation, en minusculas.
const NOMBRES_PLAYSTATION: PackedStringArray = ["ps3", "ps4", "ps5", "playstation", "dualshock", "dualsense", "sony"]
## Fabricante Sony (054c) en un GUID de SDL: bytes 4 y 5, al reves (classes/class_input.rst, get_joy_guid).
const FABRICANTE_SONY: String = "4c05"

## Sube cada vez que se pone un boton en el InputMap, aunque sea el mismo que ya tenia (lo leen las pruebas).
## Quien dibuja botones escucha Eventos.mando_cambiado, que sale una vez al final de asignar, aplicar o
## por_omision si se puso algun boton (un boton invalido no pone nada).
static var cambios: int = 0
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


## Nombre neutro del boton, el de Configuracion: «—» sin boton, «Boton n» fuera de BOTONES.
static func nombre_de(boton: int) -> String:
	if boton < 0:
		return "—"
	return _celda(boton, NEUTRO)


## Nombre del boton para una familia (Dispositivo.PLAYSTATION; cualquier otra, Xbox), el que dibuja IconoBoton.
## En los de la cara es la letra (Xbox) o el simbolo (PlayStation); «Boton n» fuera de BOTONES.
static func nombre_en(boton: int, familia_del_control: Dispositivo) -> String:
	if boton < 0:
		return "—"
	return _celda(boton, COLUMNA_PLAYSTATION if familia_del_control == Dispositivo.PLAYSTATION else COLUMNA_XBOX)


## Nombre de un eje para una familia: los gatillos LT / RT o L2 / R2; los sticks, su nombre neutro (cualquier otro
## eje cuenta como el stick derecho).
static func nombre_de_eje(eje: JoyAxis, familia_del_control: Dispositivo) -> String:
	var playstation: bool = familia_del_control == Dispositivo.PLAYSTATION
	match eje:
		JOY_AXIS_TRIGGER_LEFT:
			return "L2" if playstation else "LT"
		JOY_AXIS_TRIGGER_RIGHT:
			return "R2" if playstation else "RT"
		JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
			return nombre_de(_STICK_IZQUIERDO)
	return nombre_de(_STICK_DERECHO)


static func _celda(boton: int, columna: int) -> String:
	if boton >= BOTONES.size():
		return "Boton %d" % boton
	var fila: Array = BOTONES[boton]
	var nombre: String = fila[columna]
	return nombre


## Asigna el boton a la accion; si otra accion lo tenia, recibe el boton viejo de esta.
static func asignar(accion: StringName, boton: int) -> void:
	var antes: int = cambios
	_asignar(accion, boton)
	_avisar(antes)


## El autoload Eventos, o null si todavia no esta en el arbol. Mando y UltimaEntrada son estaticos y emiten por aqui
## (emit_signal con el nombre de la senal) y no con el identificador Eventos: asi compilan y no dan error aunque no
## haya autoloads (un -s, antes de que se carguen). En el juego siempre esta: es el primer autoload y Ajustes carga
## en Arranque, el tercero.
static func bus() -> Node:
	var arbol: SceneTree = Engine.get_main_loop() as SceneTree
	if arbol == null or arbol.root == null:
		return null
	return arbol.root.get_node_or_null(^"Eventos")


# Una sola vez por operacion publica, y solo si _poner cambio algo: aplicar llama a por_omision y a asignar varias veces.
static func _avisar(antes: int) -> void:
	var eventos: Node = bus()
	if cambios != antes and eventos != null:
		eventos.emit_signal(&"mando_cambiado")


static func _asignar(accion: StringName, boton: int) -> void:
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


## PlayStation si el GUID trae el fabricante Sony o el nombre lo dice; si no, Xbox (tambien un control generico).
static func familia(nombre: String, guid: String) -> Dispositivo:
	if guid.length() >= 12 and guid.substr(8, 4).to_lower() == FABRICANTE_SONY:
		return Dispositivo.PLAYSTATION
	var bajo: String = nombre.to_lower()
	for palabra: String in NOMBRES_PLAYSTATION:
		if bajo.contains(palabra):
			return Dispositivo.PLAYSTATION
	return Dispositivo.XBOX


static func _poner(accion: StringName, boton: int) -> void:
	cambios += 1
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
	var antes: int = cambios
	_aplicar(guardado)
	_avisar(antes)


static func _aplicar(guardado: Variant) -> void:
	_restablecer()
	if typeof(guardado) != TYPE_DICTIONARY:
		return
	var cambios: Dictionary = (guardado as Dictionary).duplicate()
	# La accion mochila se renombro inventario (13-oct-2026): unos ajustes viejos guardan su boton con el nombre viejo.
	if cambios.has(ACCION_VIEJA) and not cambios.has(String(ACCION_RENOMBRADA)):
		cambios[String(ACCION_RENOMBRADA)] = cambios[ACCION_VIEJA]
	cambios.erase(ACCION_VIEJA)
	for clave: Variant in cambios:
		var accion: StringName = StringName(str(clave))
		var valor: Variant = cambios[clave]
		if REASIGNABLES.has(accion) and typeof(valor) == TYPE_FLOAT:
			var boton: float = valor
			_asignar(accion, int(boton))


## Vuelve a los botones de project.godot.
static func por_omision() -> void:
	var antes: int = cambios
	_restablecer()
	_avisar(antes)


static func _restablecer() -> void:
	_recordar_por_omision()
	for accion: StringName in REASIGNABLES:
		_poner(accion, _por_omision[accion])
