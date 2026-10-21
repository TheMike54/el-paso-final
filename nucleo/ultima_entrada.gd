class_name UltimaEntrada
extends Node
# Recuerda si lo ultimo que uso la persona fue el dedo (o el raton) o un control o el teclado. Tema.dar_foco lo lee
# para dibujar el foco de un menu solo al navegar con control o teclado, aunque haya un control conectado y se este
# tocando con el dedo. Lo crea Arranque; corre tambien en pausa, porque la pausa es un menu. En Android ademas esconde
# el puntero del sistema que saca el touchpad del DUALSHOCK 4 (o un raton), y su clic no cuenta como un toque. Tambien
# dice que se uso (dispositivo) y lo avisa en el bus: IconoBoton dibuja la tecla o el boton de esa familia de control.
# Guarda las dos reglas de que entrada cuenta, marca_teclado y es_de_juego (esta la lee ControlesTactiles).

## Lo que devuelve clasificar con un evento que no cambia lo ultimo que se uso.
const SIN_CAMBIO: int = -1

## Lo ultimo que se uso: TOQUE (dedo o clic), TECLADO, o la familia del control (Mando.familia). Al arrancar, la del
## primer control conectado, o TOQUE. Al cambiar de verdad emite Eventos.dispositivo_cambiado (IconoBoton la escucha).
static var dispositivo: Mando.Dispositivo = Mando.Dispositivo.TOQUE:
	set(valor):
		if valor == dispositivo:
			return
		dispositivo = valor
		var eventos: Node = Mando.bus()
		if eventos != null:
			eventos.emit_signal(&"dispositivo_cambiado", valor)

# Familia de cada control (device) ya calculada: un stick inclinado manda un evento por cuadro y el nombre y el GUID
# no cambian mientras siga conectado. Se vacia al conectar o desconectar cualquiera (el device se reutiliza).
static var _familias: Dictionary[int, Mando.Dispositivo] = {}
# Acciones del InputMap que no son ui_*, para es_de_juego: se calculan una vez (Mando cambia eventos, no nombres).
static var _acciones_de_juego: Array[StringName] = []

var _android: bool = false
# Hay que volver a pedir que se esconda el puntero con el siguiente evento de raton real. Godot en Android solo lo
# esconde si lo ultimo que vio fue un raton (GodotInputHandler.canCapturePointer, rama 4.5 del motor) y no reintenta
# un modo ya pedido; tras un toque con el dedo el pedido pudo no aplicarse.
var _reesconder: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Primero el vaciado: asi lo que se registra abajo ya calcula con el control nuevo.
	Input.joy_connection_changed.connect(_al_cambiar_controles)
	var conectados: Array[int] = Input.get_connected_joypads()
	dispositivo = Mando.Dispositivo.TOQUE
	if not conectados.is_empty():
		dispositivo = _familia_de(conectados[0])
	_android = OS.has_feature("android")
	if _android:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	# En depuracion, el nombre y el GUID de cada control van al log (logcat en Android): con ellos se ajusta
	# Mando.familia si un control sale con los botones de otra marca. Los reales no se han medido.
	if OS.is_debug_build():
		for control: int in conectados:
			_registrar(control, true)
		Input.joy_connection_changed.connect(_registrar)


func _input(evento: InputEvent) -> void:
	anotar(evento, _android)
	if not _android:
		return
	if evento is InputEventScreenTouch:
		_reesconder = true
	elif _reesconder and es_raton_real(evento):
		_reesconder = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


## true si lo ultimo que se uso fue un control o el teclado. Al arrancar, true si ya hay un control conectado.
static func con_control() -> bool:
	return dispositivo != Mando.Dispositivo.TOQUE


## Un evento de raton que no emula Godot a partir de un toque (esos llevan DEVICE_ID_EMULATION): un raton o el
## touchpad de un control.
static func es_raton_real(evento: InputEvent) -> bool:
	return evento is InputEventMouse and evento.device != InputEvent.DEVICE_ID_EMULATION


## El dispositivo que dice el evento, o SIN_CAMBIO: un toque o un clic apoyados dan TOQUE; una tecla, TECLADO; un
## boton del control o un stick inclinado a la mitad, la familia del control. Soltar, arrastrar o mover el raton no
## cambian nada. En Android un clic de raton real (el touchpad del DUALSHOCK 4) tampoco: el dedo llega como toque.
## No anota nada: la usan anotar y ControlesTactiles.procesar, que lee el evento antes que este nodo.
static func clasificar(evento: InputEvent, android: bool = false) -> int:
	if evento is InputEventScreenTouch or evento is InputEventMouseButton:
		if android and es_raton_real(evento):
			return SIN_CAMBIO
		if evento.is_pressed():
			return Mando.Dispositivo.TOQUE
	elif evento is InputEventKey:
		if marca_teclado(evento):
			return Mando.Dispositivo.TECLADO
	elif evento is InputEventJoypadButton:
		if evento.is_pressed():
			return _familia_de(evento.device)
	elif evento is InputEventJoypadMotion:
		if absf((evento as InputEventJoypadMotion).axis_value) >= 0.5:
			return _familia_de(evento.device)
	return SIN_CAMBIO


## Regla 1 de las dos sobre que entrada cuenta: cualquier tecla pulsada marca TECLADO en clasificar, tambien las que
## no son de ninguna accion (Atras y el volumen del telefono llegan como teclas), y asi un menu muestra el foco. Mira
## solo el tipo de evento. No es la regla de es_de_juego, que ademas pide una accion del juego: unificarlas cambiaria
## el juego.
static func marca_teclado(evento: InputEvent) -> bool:
	return evento is InputEventKey and evento.is_pressed()


## Regla 2 de las dos sobre que entrada cuenta: una tecla, un boton o un eje del control pulsado que dispara una
## accion del juego (del InputMap y que no empiece por ui_). La usa ControlesTactiles.procesar para ocultar los
## controles: Atras, el volumen o una tecla que solo es ui_accept no los ocultan. A diferencia de marca_teclado y de
## clasificar, pide una accion. Con un eje, is_action no mira la zona muerta (0,2) ni la direccion, y la puerta de
## fuerza es is_pressed, que en 4.7.2 da true desde 0,5 (medido): la misma mitad que clasificar. Lo que clasifica como
## control o teclado y aqui no cuenta: una tecla sin accion, un boton o un eje sin accion (LT, stick derecho, L3, R3).
## Unificarla con marca_teclado cambiaria el juego.
static func es_de_juego(evento: InputEvent) -> bool:
	if not (evento is InputEventKey or evento is InputEventJoypadButton or evento is InputEventJoypadMotion):
		return false
	if not evento.is_pressed():
		return false
	if _acciones_de_juego.is_empty():
		for accion: StringName in InputMap.get_actions():
			if not String(accion).begins_with("ui_"):
				_acciones_de_juego.append(accion)
	for accion: StringName in _acciones_de_juego:
		if evento.is_action(accion):
			return true
	return false


## Anota un evento con clasificar: lo que no cambia nada (SIN_CAMBIO) deja el dispositivo como estaba. Publico
## para la prueba.
static func anotar(evento: InputEvent, android: bool = false) -> void:
	var nuevo: int = clasificar(evento, android)
	if nuevo != SIN_CAMBIO:
		dispositivo = nuevo as Mando.Dispositivo


func _al_cambiar_controles(_control: int, _conectado: bool) -> void:
	_familias.clear()


func _registrar(control: int, conectado: bool) -> void:
	if conectado:
		print("CONTROL %d nombre=\"%s\" guid=%s familia=%s" % [control, Input.get_joy_name(control),
				Input.get_joy_guid(control), str(Mando.Dispositivo.find_key(_familia_de(control))).to_lower()])


static func _familia_de(control: int) -> Mando.Dispositivo:
	if not _familias.has(control):
		_familias[control] = Mando.familia(Input.get_joy_name(control), Input.get_joy_guid(control))
	return _familias[control]
