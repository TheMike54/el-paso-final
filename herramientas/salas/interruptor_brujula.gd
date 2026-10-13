extends Area2D
# Interruptor de la brujula para la zona de prueba del mapa: al entrar el jugador, equipa el amuleto brujula si
# no lo lleva o lo quita si lo lleva, sin banco (en el juego se comprara y se pondra sentado en un banco, en la
# pantalla de los amuletos). Asi se prueba el mapa con y sin el marcador del jugador.

const BRUJULA: StringName = &"brujula"
## Aviso sobre el interruptor (provisional, 12-oct-2026): en el telefono no se notaba si se puso o se quito.
const TICKS_AVISO: int = 120
const ALTO_AVISO: float = 220.0

var _aviso: Label
var _ticks_aviso: int = 0


func _ready() -> void:
	body_entered.connect(_al_entrar)
	# Se crea aqui y no al declararla: el validador instancia la escena sin _ready y la etiqueta quedaria huerfana.
	_aviso = Label.new()
	_aviso.add_theme_font_size_override(&"font_size", 32)
	_aviso.position = Vector2(-160.0, -ALTO_AVISO)
	_aviso.size = Vector2(320.0, 48.0)
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.visible = false
	add_child(_aviso)


func _physics_process(_delta: float) -> void:
	if _ticks_aviso > 0:
		_ticks_aviso -= 1
		_aviso.visible = _ticks_aviso > 0


func _al_entrar(cuerpo: Node2D) -> void:
	if not cuerpo is Jugador:
		return
	if not Partida.amuletos_tenidos.has(BRUJULA):
		Partida.amuletos_tenidos.append(BRUJULA)
	if Partida.desequipar(BRUJULA):
		_aviso.text = "Brújula quitada"
	elif Partida.equipar(BRUJULA):
		_aviso.text = "Brújula puesta"
	else:
		_aviso.text = "Sin lugar para la brújula"
	_ticks_aviso = TICKS_AVISO
	_aviso.visible = true
