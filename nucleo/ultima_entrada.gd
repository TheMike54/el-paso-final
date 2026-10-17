class_name UltimaEntrada
extends Node
# Recuerda si lo ultimo que uso la persona fue el dedo (o el raton) o un control o el teclado. Tema.dar_foco lo lee
# para dibujar el foco de un menu solo al navegar con control o teclado, aunque haya un control conectado y se este
# tocando con el dedo. Lo crea Arranque; corre tambien en pausa, porque la pausa es un menu. En Android ademas esconde
# el puntero del sistema que saca el touchpad del DUALSHOCK 4 (o un raton), y su clic no cuenta como un toque. Tambien
# dice que se uso (dispositivo): IconoBoton dibuja la tecla o el boton de esa familia de control.

## Valores de dispositivo que no son una familia de control (Mando.XBOX, Mando.PLAYSTATION).
const TOQUE: String = "toque"
const TECLADO: String = "teclado"

## true: lo ultimo fue un control o el teclado. Al arrancar, true si ya hay un control conectado.
static var con_control: bool = false
## Lo ultimo que se uso: TOQUE (dedo o clic), TECLADO, o la familia del control (Mando.familia). Al arrancar, la del
## primer control conectado, o TOQUE.
static var dispositivo: String = TOQUE

var _android: bool = false
# Hay que volver a pedir que se esconda el puntero con el siguiente evento de raton real. Godot en Android solo lo
# esconde si lo ultimo que vio fue un raton (GodotInputHandler.canCapturePointer, rama 4.5 del motor) y no reintenta
# un modo ya pedido; tras un toque con el dedo el pedido pudo no aplicarse.
var _reesconder: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	con_control = not Input.get_connected_joypads().is_empty()
	dispositivo = _familia_de(Input.get_connected_joypads()[0]) if con_control else TOQUE
	_android = OS.has_feature("android")
	if _android:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	# En depuracion, el nombre y el GUID de cada control van al log (logcat en Android): con ellos se ajusta
	# Mando.familia si un control sale con los botones de otra marca. Los reales no se han medido.
	if OS.is_debug_build():
		for control: int in Input.get_connected_joypads():
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


## Un evento de raton que no emula Godot a partir de un toque (esos llevan DEVICE_ID_EMULATION): un raton o el
## touchpad de un control.
static func es_raton_real(evento: InputEvent) -> bool:
	return evento is InputEventMouse and evento.device != InputEvent.DEVICE_ID_EMULATION


## Anota un evento: un toque o un clic lo pasan a false; una tecla, un boton del control o un stick inclinado a
## la mitad, a true. Lo demas (soltar, arrastrar, mover el raton) no cambia nada. En Android un clic de raton real
## (el touchpad del DUALSHOCK 4) no cuenta: el dedo llega como toque. Publico para la prueba.
static func anotar(evento: InputEvent, android: bool = false) -> void:
	if evento is InputEventScreenTouch or evento is InputEventMouseButton:
		if android and es_raton_real(evento):
			return
		if evento.is_pressed():
			con_control = false
			dispositivo = TOQUE
	elif evento is InputEventKey:
		if evento.is_pressed():
			con_control = true
			dispositivo = TECLADO
	elif evento is InputEventJoypadButton:
		if evento.is_pressed():
			con_control = true
			dispositivo = _familia_de(evento.device)
	elif evento is InputEventJoypadMotion:
		if absf((evento as InputEventJoypadMotion).axis_value) >= 0.5:
			con_control = true
			dispositivo = _familia_de(evento.device)


func _registrar(control: int, conectado: bool) -> void:
	if conectado:
		print("CONTROL %d nombre=\"%s\" guid=%s familia=%s" % [control, Input.get_joy_name(control),
				Input.get_joy_guid(control), _familia_de(control)])


static func _familia_de(control: int) -> String:
	return Mando.familia(Input.get_joy_name(control), Input.get_joy_guid(control))
