class_name ControlesTactiles
extends Control
# Controles tactiles: traducen cada toque a las mismas acciones del InputMap que el teclado,
# con Input.action_press y action_release, para que la logica nunca lea el toque. Joystick
# invisible abajo a la izquierda y botones en la distribucion inicial del diseno, anclados a
# su esquina. Se ocultan al usar teclado o control y reaparecen al tocar la pantalla. Un boton
# que pide una habilidad solo se dibuja y responde mientras Partida la tiene.

const ACCIONES: Array[StringName] = [&"saltar", &"atacar", &"curar", &"impulso", &"pausa", &"mapa", &"mochila"]
const ETIQUETAS: PackedStringArray = ["Saltar", "Atacar", "Curar", "Impulso", "Pausa", "Mapa", "Mochila"]
## Centro de cada boton en la distribucion inicial: fraccion de una pantalla 16:9.
const CENTROS: PackedVector2Array = [
	Vector2(0.91, 0.81), Vector2(0.81, 0.81), Vector2(0.82, 0.63), Vector2(0.91, 0.60),
	Vector2(0.94, 0.09), Vector2(0.94, 0.21), Vector2(0.94, 0.32),
]
## Esquina a la que se ancla cada boton: (1, 1) abajo a la derecha, (1, 0) arriba a la derecha.
const ANCLAS: PackedVector2Array = [
	Vector2(1, 1), Vector2(1, 1), Vector2(1, 1), Vector2(1, 1), Vector2(1, 0), Vector2(1, 0), Vector2(1, 0),
]
## Radio de cada boton, en fraccion del lado corto de la pantalla. Con los centros del diseno,
## Atacar y Saltar quedan a 0,18 del lado corto: sus radios suman menos para no encimarse.
const RADIOS: PackedFloat32Array = [0.085, 0.07, 0.07, 0.07, 0.05, 0.05, 0.05]
## El toque cuenta un poco fuera del circulo dibujado: es mas facil acertar con el pulgar.
const HOLGURA: float = 1.25
## Zona del joystick: fraccion de la pantalla desde la esquina de arriba a la izquierda.
const ZONA_JOYSTICK: Rect2 = Rect2(0.0, 0.3, 0.45, 0.7)
## Radio del joystick y zona muerta, en fraccion del lado corto y del radio.
const RADIO_JOYSTICK: float = 0.12
const ZONA_MUERTA: float = 0.2
const PROPORCION_REFERENCIA: float = 16.0 / 9.0
const COLOR_BOTON: Color = Color(1.0, 1.0, 1.0, 0.5)
const COLOR_PRESIONADO: Color = Color(1.0, 1.0, 1.0, 0.25)
## Botones que solo existen con una habilidad: accion -> habilidad de Partida. Sin ella no se
## dibujan ni responden, y los demas no se mueven.
const HABILIDAD_DE_BOTON: Dictionary[StringName, StringName] = {&"impulso": &"impulso"}

## Cuadros entre que se van los controles de una sala y llegan los de la siguiente: con mas, ya
## no es un cambio de sala (se paso por el menu) y lo que quedo presionado se suelta.
const CUADROS_CAMBIO_DE_SALA: int = 5

# Los dedos se recuerdan en variables estaticas: cada sala crea sus propios controles, y un dedo
# que sigue en la pantalla al cambiar de sala (o al reaparecer tras morir) lo suelta en los
# controles nuevos. Sin esto, su accion quedaba presionada sin nadie que la soltara.
# Dedo -> indice del boton que presiona.
static var _dedos_en_botones: Dictionary[int, int] = {}
static var _dedo_joystick: int = -1
static var _origen_joystick: Vector2 = Vector2.ZERO
static var _palanca: Vector2 = Vector2.ZERO
# Acciones de movimiento que presiono el joystick: solo esas se sueltan, para no soltar una
# que sostiene el teclado o el control.
static var _movimientos_propios: Array[StringName] = []
# Cuadro en que salieron del arbol los ultimos controles; -1 si no hay dedos por heredar.
static var _cuadro_salida: int = -1

# Que botones estaban disponibles en la ultima revision, para redibujar solo si cambia.
var _disponibles: Array[bool] = []


func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available()
	if _cuadro_salida >= 0 and Engine.get_process_frames() - _cuadro_salida > CUADROS_CAMBIO_DE_SALA:
		_soltar_todo()
	_cuadro_salida = -1
	_revisar_habilidades()


func _exit_tree() -> void:
	_cuadro_salida = Engine.get_process_frames()


# Cada cuadro, porque la habilidad llega al tomar el objeto y Partida.reiniciar() la borra sin
# avisar: asi el boton aparece y desaparece sin recargar la sala.
func _process(_delta: float) -> void:
	_revisar_habilidades()


func _input(evento: InputEvent) -> void:
	procesar(evento)


## Traduce un evento de entrada. Publico para que la prueba le pase toques sin pantalla.
func procesar(evento: InputEvent) -> void:
	var toque: InputEventScreenTouch = evento as InputEventScreenTouch
	var arrastre: InputEventScreenDrag = evento as InputEventScreenDrag
	if toque != null:
		visible = true
		if toque.pressed:
			_tocar(toque.index, toque.position)
		else:
			_soltar(toque.index)
	elif arrastre != null:
		if arrastre.index == _dedo_joystick:
			_mover_joystick(arrastre.position)
	elif _es_de_juego(evento):
		if visible:
			_soltar_todo()
			visible = false
	queue_redraw()


## Centro de un boton en la pantalla actual. Para la prueba y para dibujar.
func centro(accion: StringName) -> Vector2:
	var i: int = ACCIONES.find(accion)
	var corto: float = minf(size.x, size.y)
	var desplazamiento: Vector2 = (CENTROS[i] - ANCLAS[i]) * Vector2(PROPORCION_REFERENCIA, 1.0) * corto
	return ANCLAS[i] * size + desplazamiento


func _radio(i: int) -> float:
	return RADIOS[i] * minf(size.x, size.y)


func _disponible(i: int) -> bool:
	var habilidad: StringName = HABILIDAD_DE_BOTON.get(ACCIONES[i], &"")
	return habilidad.is_empty() or Partida.tiene(habilidad)


# Un boton que deja de estar disponible con un dedo encima suelta su accion, como al levantar el dedo.
func _revisar_habilidades() -> void:
	var disponibles: Array[bool] = []
	for i: int in range(ACCIONES.size()):
		disponibles.append(_disponible(i))
	if disponibles == _disponibles:
		return
	_disponibles = disponibles
	for dedo: int in _dedos_en_botones.keys():
		if not _disponibles[_dedos_en_botones[dedo]]:
			_soltar(dedo)
	queue_redraw()


func _tocar(dedo: int, posicion: Vector2) -> void:
	_revisar_habilidades()
	for i: int in range(ACCIONES.size()):
		if not _disponibles[i]:
			continue
		if posicion.distance_to(centro(ACCIONES[i])) <= _radio(i) * HOLGURA:
			_dedos_en_botones[dedo] = i
			Input.action_press(ACCIONES[i])
			return
	var zona: Rect2 = Rect2(ZONA_JOYSTICK.position * size, ZONA_JOYSTICK.size * size)
	if _dedo_joystick == -1 and zona.has_point(posicion):
		_dedo_joystick = dedo
		_origen_joystick = posicion
		_palanca = Vector2.ZERO


func _soltar(dedo: int) -> void:
	if dedo == _dedo_joystick:
		_dedo_joystick = -1
		_palanca = Vector2.ZERO
		_aplicar_palanca()
	elif _dedos_en_botones.has(dedo):
		var i: int = _dedos_en_botones[dedo]
		_dedos_en_botones.erase(dedo)
		# Otro dedo puede seguir sobre el mismo boton.
		if not _dedos_en_botones.values().has(i):
			Input.action_release(ACCIONES[i])


func _soltar_todo() -> void:
	for i: int in _dedos_en_botones.values():
		Input.action_release(ACCIONES[i])
	_dedos_en_botones.clear()
	_dedo_joystick = -1
	_palanca = Vector2.ZERO
	_aplicar_palanca()


func _mover_joystick(posicion: Vector2) -> void:
	var radio: float = RADIO_JOYSTICK * minf(size.x, size.y)
	_palanca = ((posicion - _origen_joystick) / radio).limit_length(1.0)
	_aplicar_palanca()


func _aplicar_palanca() -> void:
	_aplicar_eje(_palanca.x, &"mover_izquierda", &"mover_derecha")
	_aplicar_eje(_palanca.y, &"mover_arriba", &"mover_abajo")
	# Como la flecha arriba y el stick arriba, el joystick arriba tambien es interactuar.
	if _palanca.y <= -ZONA_MUERTA:
		_presionar_movimiento(&"interactuar", -_palanca.y)
	else:
		_soltar_movimiento(&"interactuar")


# Un eje del joystick a dos acciones con fuerza: la logica las lee con Input.get_axis.
func _aplicar_eje(valor: float, negativa: StringName, positiva: StringName) -> void:
	if valor <= -ZONA_MUERTA:
		_presionar_movimiento(negativa, -valor)
		_soltar_movimiento(positiva)
	elif valor >= ZONA_MUERTA:
		_presionar_movimiento(positiva, valor)
		_soltar_movimiento(negativa)
	else:
		_soltar_movimiento(negativa)
		_soltar_movimiento(positiva)


func _presionar_movimiento(accion: StringName, fuerza: float) -> void:
	Input.action_press(accion, fuerza)
	if not _movimientos_propios.has(accion):
		_movimientos_propios.append(accion)


func _soltar_movimiento(accion: StringName) -> void:
	if _movimientos_propios.has(accion):
		_movimientos_propios.erase(accion)
		Input.action_release(accion)


# Solo una tecla o un control que dispara una accion del juego oculta los controles: Atras y el
# volumen del telefono llegan como teclas y no deben ocultarlos.
func _es_de_juego(evento: InputEvent) -> bool:
	if not (evento is InputEventKey or evento is InputEventJoypadButton or evento is InputEventJoypadMotion):
		return false
	if not evento.is_pressed():
		return false
	for accion: StringName in InputMap.get_actions():
		if not String(accion).begins_with("ui_") and evento.is_action(accion):
			return true
	return false


func _draw() -> void:
	var fuente: Font = ThemeDB.fallback_font
	var presionados: Array[int] = []
	presionados.assign(_dedos_en_botones.values())
	for i: int in range(ACCIONES.size()):
		if not _disponibles[i]:
			continue
		var c: Vector2 = centro(ACCIONES[i])
		var r: float = _radio(i)
		if presionados.has(i):
			draw_circle(c, r, COLOR_PRESIONADO)
		draw_arc(c, r, 0.0, TAU, 48, COLOR_BOTON, 2.0)
		var tamano_letra: int = maxi(12, roundi(r * 0.35))
		var ancho: float = fuente.get_string_size(ETIQUETAS[i], HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_letra).x
		draw_string(fuente, c + Vector2(-ancho / 2.0, tamano_letra * 0.35), ETIQUETAS[i], HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_letra, COLOR_BOTON)
	if _dedo_joystick != -1:
		var radio: float = RADIO_JOYSTICK * minf(size.x, size.y)
		draw_arc(_origen_joystick, radio, 0.0, TAU, 48, COLOR_BOTON, 2.0)
		draw_circle(_origen_joystick + _palanca * radio, radio * 0.4, COLOR_PRESIONADO)
