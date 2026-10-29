class_name Fundido
extends CanvasLayer
# Fundido a negro (como Hollow Knight): un rectangulo negro sobre el juego, los botones y la interfaz, y
# debajo de la pausa. La sala lo crea; oscurece, se queda en negro y aclara cuando alguien emite
# Eventos.fundido_pedido (un peligro) y cada sala empieza en negro y aclara. Es ademas el unico dueno del cambio de
# sala (como GameManager.BeginSceneTransition): puerta, estacion y muerte le piden el cambio con su perfil de tiempos y
# el, ya en negro, avisa con en_negro, escribe la llegada y cambia de escena. Cuenta ticks de fisica, no tiempo real,
# para que los guiones den siempre lo mismo.

## La pantalla llego al negro de un cambio de sala, justo antes de cambiar de escena (o de no hacerlo, si el jugador
## murio mientras oscurecia).
signal en_negro
## El cambio de sala que siguio a en_negro no se pudo hacer (la sala no existe, no es una escena o el arbol devolvio un
## Error): la pantalla aclara y quien pidio el cambio recupera lo suyo (la Estacion su viaje, la Puerta su cruce).
signal cambio_fallido

## Perfil de tiempos de un cambio de sala: los ticks de cada uno viven solo aqui (ticks_oscurecer y ticks_en_negro).
enum Perfil { PUERTA, ESTACION, MUERTE }
## Donde aparece el jugador en la sala nueva: en la Entrada, en una puerta, en una estacion o en el banco de Partida.
enum Llegada { ENTRADA, PUERTA, ESTACION, BANCO }

## Ticks en oscurecer del todo: 9 = 0,15 s (peligro, muerte y estacion). Provisional.
const TICKS_OSCURECER: int = 9
## Ticks en aclarar del todo: 15 = 0,25 s (al empezar una sala sin puerta y tras un peligro). Provisional.
const TICKS_ACLARAR: int = 15
## Ticks en negro tras un peligro, antes de aclarar: 18 = 0,3 s. Provisional (la muerte ya tiene la pausa de
## recargar la sala).
const TICKS_EN_NEGRO_PELIGRO: int = 18
## Al cruzar una puerta, como Hollow Knight (camera_fade: oscurece en 0,33 s, aclara en 0,5 s): oscurece en 20 ticks
## mientras el jugador sale, sigue en negro 10 (0,17 s) y la sala nueva aclara en 30.
const TICKS_OSCURECER_PUERTA: int = 20
const TICKS_EN_NEGRO_PUERTA: int = 10
const TICKS_ACLARAR_PUERTA: int = 30
## Ticks en negro de un viaje de estacion antes de cambiar de sala: 6 = 0,1 s (el tiempo de las puertas hasta el
## 27-oct-2026, que la estacion conserva).
const TICKS_EN_NEGRO_ESTACION: int = 6
## Encima de los controles tactiles (5) y la interfaz (10), que se oscurecen con el juego; debajo de la pausa y las
## paginas del marco (20), su barra (21), Configuracion (22) y el editor de botones (23), que se ven aunque se abran
## en negro.
const CAPA: int = 15

## Lo que tapa el negro: 0, nada; 1, todo.
var opacidad: float = 0.0
## Ruta de la sala a la que va el cambio en curso; vacia si no hay ninguno. Publica para las pruebas.
var ruta_destino: String = ""

var _negro: ColorRect = null
var _ticks_oscurecer: int = 0
var _ticks_en_negro: int = 0
var _ticks_aclarar: int = 0
# Ticks que lleva la fase en curso: oscurecer, en negro y despues aclarar.
var _tick: int = 0
var _oscureciendo: bool = false
var _en_negro: bool = false
var _opacidad_inicial: float = 0.0
var _aclarando: bool = false
# Cambio de sala en curso: ticks de espera antes de oscurecer, la llegada y el jugador que, si muere, lo cancela.
var _ticks_retraso: int = 0
var _perfil: Perfil = Perfil.PUERTA
var _llegada: Llegada = Llegada.ENTRADA
var _id_llegada: String = ""
var _jugador: Jugador = null
var _con_jugador: bool = false
# Ya llego al negro y el cambio de escena esta pedido en diferido: no se vuelve a pedir.
var _cambiando: bool = false


func _ready() -> void:
	layer = CAPA
	_negro = ColorRect.new()
	_negro.color = Color.BLACK
	_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_negro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_negro)
	_pintar()
	Eventos.fundido_pedido.connect(_al_pedir)


func _physics_process(_delta: float) -> void:
	# Durante el retraso (el giro hacia una PUERTA) la fase anterior sigue: un aclarado a medias no se congela. El
	# cambio empieza desde la opacidad que haya en el tick en que se acaba el retraso.
	if _ticks_retraso > 0:
		_ticks_retraso -= 1
		if _ticks_retraso == 0:
			_empezar_cambio()
			return
	# Sin transicion en curso no cambia nada: no se vuelve a pintar. No se apaga el proceso porque, al
	# reactivarlo a mitad de un tick, el motor lo corre hasta el siguiente y la transicion se atrasa uno.
	if not (_oscureciendo or _en_negro or _aclarando):
		if _cambio_esperando_negro():
			_llegar_al_negro()
		return
	if _oscureciendo:
		_tick += 1
		opacidad = lerpf(_opacidad_inicial, 1.0, minf(float(_tick) / float(_ticks_oscurecer), 1.0))
		if _tick >= _ticks_oscurecer:
			_oscureciendo = false
			_empezar_en_negro_fijo()
	elif _en_negro:
		_tick += 1
		if _tick >= _ticks_en_negro:
			_en_negro = false
			_empezar_a_aclarar(_ticks_aclarar)
	elif _aclarando:
		_tick += 1
		opacidad = maxf(1.0 - float(_tick) / float(_ticks_aclarar), 0.0)
		if _tick >= _ticks_aclarar:
			_aclarando = false
	_pintar()
	if _cambio_esperando_negro() and not (_oscureciendo or _en_negro):
		_llegar_al_negro()


## Ticks de oscurecer y en negro de un perfil: lo que tarda en cambiar de sala desde que empieza a oscurecer.
static func ticks_de(perfil: Perfil) -> Vector2i:
	match perfil:
		Perfil.PUERTA:
			return Vector2i(TICKS_OSCURECER_PUERTA, TICKS_EN_NEGRO_PUERTA)
		Perfil.ESTACION:
			return Vector2i(TICKS_OSCURECER, TICKS_EN_NEGRO_ESTACION)
	return Vector2i(TICKS_OSCURECER, 0)


## Ticks desde el pedido hasta cambiar de sala con ese perfil y retraso: el tope que espera quien sale.
static func ticks_hasta_cambio(perfil: Perfil, retraso: int = 0) -> int:
	var ticks: Vector2i = ticks_de(perfil)
	return retraso + ticks.x + ticks.y


## El Fundido de la sala de un nodo (el hijo Fundido de la primera Sala hacia arriba); null si no esta en una sala.
static func de(nodo: Node) -> Fundido:
	var actual: Node = nodo
	while actual != null:
		if actual is Sala:
			return actual.get_node_or_null(^"Fundido") as Fundido
		actual = actual.get_parent()
	return null


## Cambia de escena a la sala de ruta, con el jugador en llegada (id de la puerta o la estacion; vacio para la Entrada
## o el banco). Escribe la llegada en las estaticas de Sala, que sobreviven al cambio de escena, solo si la escena se
## puede cargar, y las vuelve a dejar vacias si el cambio falla; devuelve el Error del cambio
## (classes/class_scenetree.rst:609). Lo llama el Fundido ya en negro y, sin fundido propio, la Cinematica; los dos
## en diferido: cambiar de escena saca la actual del arbol en el acto (class_scenetree.rst:584-588).
static func ir_a_sala(arbol: SceneTree, ruta: String, llegada: Llegada, id_llegada: String) -> Error:
	if not ResourceLoader.exists(ruta):
		push_error("Fundido: la sala '%s' no existe" % ruta)
		return ERR_CANT_OPEN
	var escena: PackedScene = load(ruta) as PackedScene
	if escena == null:
		push_error("Fundido: '%s' no es una escena" % ruta)
		return ERR_CANT_OPEN
	Sala.puerta_llegada = StringName(id_llegada) if llegada == Llegada.PUERTA else &""
	Sala.estacion_llegada = id_llegada if llegada == Llegada.ESTACION else ""
	Sala.llegada_a_banco = llegada == Llegada.BANCO
	Sala.cambio_pedido_ms = Time.get_ticks_msec()
	var error: Error = arbol.change_scene_to_packed(escena)
	if error != OK:
		# Ninguna sala nueva las va a leer: no se quedan para la proxima.
		Sala.puerta_llegada = &""
		Sala.estacion_llegada = ""
		Sala.llegada_a_banco = false
		Sala.cambio_pedido_ms = -1
		push_error("Fundido: no se pudo cambiar a '%s' (error %d)" % [ruta, error])
	return error


## Empieza en negro y aclara en ticks_aclarar ticks.
func empezar_en_negro(ticks_aclarar: int = TICKS_ACLARAR) -> void:
	opacidad = 1.0
	_oscureciendo = false
	_en_negro = false
	_empezar_a_aclarar(ticks_aclarar)
	_pintar()


## Pide el cambio a la sala de ruta: espera retraso ticks (el jugador se voltea hacia una puerta), oscurece y sigue en
## negro segun el perfil y entonces emite en_negro y cambia de escena. Con jugador, si muere antes del negro no cambia:
## manda la muerte. Un solo cambio a la vez: si ya hay uno en curso, este se ignora y devuelve false.
func cambiar_sala(ruta: String, llegada: Llegada, id_llegada: String, perfil: Perfil, retraso: int = 0,
		jugador: Jugador = null) -> bool:
	# Sin ruta no hay a donde ir: aceptarla dejaria la pantalla en negro sin cambio ni cambio_fallido.
	if not ruta_destino.is_empty() or ruta.is_empty():
		return false
	ruta_destino = ruta
	_llegada = llegada
	_id_llegada = id_llegada
	_perfil = perfil
	_jugador = jugador
	_con_jugador = jugador != null
	_ticks_retraso = retraso
	if retraso <= 0:
		_empezar_cambio()
	return true


# Oscurece en ticks_oscurecer, sigue en negro ticks_en_negro y aclara en ticks_aclarar; con ticks_aclarar
# en 0, se queda en negro. Mientras hay un cambio de sala en curso no hace caso: la sala se va igual.
func _al_pedir(ticks_oscurecer: int, ticks_en_negro: int, ticks_aclarar: int) -> void:
	if not ruta_destino.is_empty():
		return
	_fundir(ticks_oscurecer, ticks_en_negro, ticks_aclarar)


func _fundir(ticks_oscurecer: int, ticks_en_negro: int, ticks_aclarar: int) -> void:
	_ticks_oscurecer = ticks_oscurecer
	_ticks_en_negro = ticks_en_negro
	_ticks_aclarar = ticks_aclarar
	_en_negro = false
	_aclarando = false
	# Desde la opacidad que ya tiene, y siempre en ticks_oscurecer: un pedido a media transicion no hace bajar la
	# capa de golpe, y el negro llega en el tick en que lo espera quien lo pidio.
	_opacidad_inicial = opacidad
	_tick = 0
	_oscureciendo = ticks_oscurecer > 0
	if not _oscureciendo:
		opacidad = 1.0
		_empezar_en_negro_fijo()
	_pintar()


# El fundido del cambio, sin aclarar (la sala nueva empieza en negro). Pasa por el bus como cualquier fundido.
func _empezar_cambio() -> void:
	var ticks: Vector2i = ticks_de(_perfil)
	_fundir(ticks.x, ticks.y, 0)
	Eventos.fundido_pedido.emit(ticks.x, ticks.y, 0)


# Ya en negro: avisa y, si el jugador sigue vivo, cambia de escena en diferido; si murio, el negro se queda y la sala
# lo hace reaparecer.
func _llegar_al_negro() -> void:
	var ruta: String = ruta_destino
	en_negro.emit()
	if _con_jugador and (not is_instance_valid(_jugador) or _jugador.muerto):
		ruta_destino = ""
		_jugador = null
		return
	_cambiando = true
	_cambiar.call_deferred(ruta)


# Hay un cambio pedido, ya paso su retraso y todavia no llego al negro.
func _cambio_esperando_negro() -> bool:
	return not ruta_destino.is_empty() and not _cambiando and _ticks_retraso == 0


func _cambiar(ruta: String) -> void:
	if ir_a_sala(get_tree(), ruta, _llegada, _id_llegada) != OK:
		# La sala no cambio: se aclara para no dejar la pantalla en negro y se avisa a quien lo pidio.
		ruta_destino = ""
		_cambiando = false
		_jugador = null
		_empezar_a_aclarar(TICKS_ACLARAR)
		_pintar()
		cambio_fallido.emit()


# Negro del todo ticks_en_negro ticks; con 0, aclara en el acto.
func _empezar_en_negro_fijo() -> void:
	_tick = 0
	_en_negro = _ticks_en_negro > 0
	if not _en_negro:
		_empezar_a_aclarar(_ticks_aclarar)


func _empezar_a_aclarar(ticks_aclarar: int) -> void:
	_ticks_aclarar = ticks_aclarar
	_tick = 0
	_aclarando = ticks_aclarar > 0


func _pintar() -> void:
	_negro.color.a = opacidad
	_negro.visible = opacidad > 0.0
