class_name Fundido
extends CanvasLayer
# Fundido a negro (como Hollow Knight): un rectangulo negro sobre el juego, los botones y la interfaz, y
# debajo de la pausa. La sala lo crea; oscurece, se queda en negro y aclara cuando alguien emite
# Eventos.fundido_pedido (un peligro, la muerte, una puerta) y cada sala empieza en negro y aclara. Cuenta
# ticks de fisica, no tiempo real, para que los guiones den siempre lo mismo.

## Ticks en oscurecer del todo: 9 = 0,15 s. Provisional.
const TICKS_OSCURECER: int = 9
## Ticks en aclarar del todo: 15 = 0,25 s. Provisional.
const TICKS_ACLARAR: int = 15
## Ticks en negro tras un peligro, antes de aclarar: 18 = 0,3 s. Provisional (la muerte ya tiene la pausa de
## recargar la sala).
const TICKS_EN_NEGRO_PELIGRO: int = 18
## Ticks en negro al cruzar una puerta, antes de cambiar de sala: 6 = 0,1 s. Provisional.
const TICKS_EN_NEGRO_PUERTA: int = 6
## Encima de los controles tactiles (5) y la interfaz (10), que se oscurecen con el juego; debajo de la pausa
## (20) y el editor de botones (21), que se ven aunque se abran en negro.
const CAPA: int = 15

## Lo que tapa el negro: 0, nada; 1, todo.
var opacidad: float = 0.0

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


func _ready() -> void:
	layer = CAPA
	_negro = ColorRect.new()
	_negro.color = Color.BLACK
	_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_negro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_negro)
	_pintar()
	Eventos.fundido_pedido.connect(_al_pedir)


## Empieza en negro y aclara en ticks_aclarar ticks.
func empezar_en_negro(ticks_aclarar: int = TICKS_ACLARAR) -> void:
	opacidad = 1.0
	_oscureciendo = false
	_en_negro = false
	_empezar_a_aclarar(ticks_aclarar)
	_pintar()


# Oscurece en ticks_oscurecer, sigue en negro ticks_en_negro y aclara en ticks_aclarar; con ticks_aclarar
# en 0, se queda en negro (una puerta o la muerte: la sala siguiente aclara al empezar).
func _al_pedir(ticks_oscurecer: int, ticks_en_negro: int, ticks_aclarar: int) -> void:
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


func _physics_process(_delta: float) -> void:
	# Sin transicion en curso no cambia nada: no se vuelve a pintar. No se apaga el proceso porque, al
	# reactivarlo a mitad de un tick, el motor lo corre hasta el siguiente y la transicion se atrasa uno.
	if not (_oscureciendo or _en_negro or _aclarando):
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
