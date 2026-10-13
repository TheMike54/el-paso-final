class_name CajaDialogo
extends CanvasLayer
# Caja de una conversacion, abajo de la pantalla: el texto aparece letra por letra (en ticks, igual en un guion) y
# interactuar, saltar, atacar o tocar la caja lo completan y despues pasan a la linea siguiente. Las opciones de una
# pregunta van en fila: izquierda y derecha las recorren y se toman con las mismas acciones, o tocandolas (tocar la
# caja entonces no elige). La crea un Npc o un RetoPreguntas al hablar y la libera al terminar; corre con el juego,
# asi la pausa y el marco de menus la detienen.

## terminada(true): se termino contando (ultima linea o FIN); terminada(false): CANCELAR.
signal terminada(contar: bool)
## Al tomar una opcion de una pregunta, antes de pasar a su destino (quien la abrio puede cambiar esa linea).
signal opcion_elegida(linea: int, opcion: int)

const CAPA: int = 12
const ACCIONES_AVANZAR: Array[StringName] = [&"interactuar", &"saltar", &"atacar"]
const ALTO_CAJA: float = 200.0
const ANCHO_MAXIMO: float = 1100.0
const ANCHO_OPCION: float = 300.0
const COLOR_QUIEN: Color = Color(0.88, 0.69, 0.29, 1.0)

## 2 ticks por letra: 30 letras por segundo.
@export var ticks_por_letra: int = 2

var ficha: FichaDialogo = null
## Publicas para los guiones: linea actual, letras a la vista, si ya se ve entera y la opcion marcada.
var linea: int = 0
var letras_visibles: int = 0
var completa: bool = false
var elegida: int = 0

var _ticks_letra: int = 0
# La pulsacion de interactuar que abrio la caja no completa la primera linea.
var _primer_tick: bool = true
var _toque: bool = false
var _opcion_tocada: int = -1
var _caja: Button = null
var _quien: Label = null
var _texto: Label = null
var _opciones: HBoxContainer = null
var _botones: Array[Button] = []


func _ready() -> void:
	layer = CAPA
	_armar()
	ControlesTactiles.hablando = true
	get_viewport().size_changed.connect(_acomodar)
	_acomodar()
	_mostrar_linea(0)


func _exit_tree() -> void:
	# Salir al menu o recargar la sala con la caja abierta no deja los botones tactiles escondidos.
	ControlesTactiles.hablando = false
	get_viewport().size_changed.disconnect(_acomodar)


func _physics_process(_delta: float) -> void:
	if ficha == null:
		return
	if _primer_tick:
		_primer_tick = false
		_toque = false
		return
	var avanzar: bool = _toque or _alguna_pulsada()
	_toque = false
	if not completa:
		if avanzar:
			_completar()
		else:
			_escribir()
		_opcion_tocada = -1
		return
	var actual: LineaDialogo = ficha.lineas[linea]
	if not actual.opciones.is_empty():
		# Con opciones a la vista, tocar la caja no elige: se toca la opcion (en el S50 un toque de mas contestaba
		# la marcada sin querer). Las acciones si toman la marcada.
		avanzar = _alguna_pulsada()
		if Input.is_action_just_pressed(&"mover_izquierda"):
			_elegir(elegida - 1)
		elif Input.is_action_just_pressed(&"mover_derecha"):
			_elegir(elegida + 1)
		if _opcion_tocada >= 0:
			_elegir(_opcion_tocada)
			avanzar = true
	_opcion_tocada = -1
	if avanzar:
		_siguiente()


func _alguna_pulsada() -> bool:
	for accion: StringName in ACCIONES_AVANZAR:
		if Input.is_action_just_pressed(accion):
			return true
	return false


func _mostrar_linea(indice: int) -> void:
	linea = indice
	var actual: LineaDialogo = ficha.lineas[linea]
	_quien.text = actual.quien
	_quien.visible = not actual.quien.is_empty()
	_texto.text = actual.texto
	letras_visibles = 0
	_ticks_letra = 0
	completa = false
	_texto.visible_characters = 0
	_opciones.visible = false
	for boton: Button in _botones:
		boton.free()
	_botones.clear()
	for i: int in range(actual.opciones.size()):
		var boton: Button = Button.new()
		boton.text = actual.opciones[i]
		boton.custom_minimum_size = Vector2(ANCHO_OPCION, Tema.ALTO_TOQUE)
		boton.focus_mode = Control.FOCUS_NONE
		boton.toggle_mode = true
		boton.pressed.connect(_al_tocar_opcion.bind(i))
		_opciones.add_child(boton)
		_botones.append(boton)
	_elegir(0)


func _escribir() -> void:
	_ticks_letra += 1
	if _ticks_letra < ticks_por_letra:
		return
	_ticks_letra = 0
	letras_visibles += 1
	_texto.visible_characters = letras_visibles
	if letras_visibles >= ficha.lineas[linea].texto.length():
		_completar()


func _completar() -> void:
	completa = true
	letras_visibles = ficha.lineas[linea].texto.length()
	_texto.visible_characters = -1
	_opciones.visible = not _botones.is_empty()


func _elegir(indice: int) -> void:
	if _botones.is_empty():
		elegida = 0
		return
	elegida = clampi(indice, 0, _botones.size() - 1)
	# La marcada se ve encendida, sin usar el foco de Godot: ui_left y el stick la moverian dos veces.
	for i: int in range(_botones.size()):
		_botones[i].set_pressed_no_signal(i == elegida)


func _siguiente() -> void:
	var actual: LineaDialogo = ficha.lineas[linea]
	var destino: int = linea + 1
	if not actual.opciones.is_empty():
		destino = actual.destinos[elegida]
		opcion_elegida.emit(linea, elegida)
	if destino == LineaDialogo.CANCELAR:
		terminada.emit(false)
	elif destino == LineaDialogo.FIN or destino >= ficha.lineas.size():
		terminada.emit(true)
	else:
		_mostrar_linea(destino)


# Los toques solo levantan marcas: la logica corre en el tick, como todo lo demas.
func _al_tocar_caja() -> void:
	_toque = true


func _al_tocar_opcion(indice: int) -> void:
	_opcion_tocada = indice


func _acomodar() -> void:
	var vista: Vector2 = get_viewport().get_visible_rect().size
	var area: Rect2 = Tema.area_util(vista)
	var ancho: float = minf(area.size.x, ANCHO_MAXIMO)
	_caja.size = Vector2(ancho, ALTO_CAJA)
	_caja.position = Vector2(area.position.x + (area.size.x - ancho) / 2.0, area.end.y - ALTO_CAJA)
	_opciones.size = Vector2(ancho, Tema.ALTO_TOQUE)
	_opciones.position = _caja.position - Vector2(0.0, Tema.ALTO_TOQUE + Tema.SEPARACION_FILAS)


func _armar() -> void:
	var raiz: Control = Control.new()
	raiz.name = "Raiz"
	raiz.theme = Tema.crear()
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(raiz)
	_caja = Button.new()
	_caja.name = "Caja"
	_caja.focus_mode = Control.FOCUS_NONE
	_caja.pressed.connect(_al_tocar_caja)
	raiz.add_child(_caja)
	var contenido: VBoxContainer = VBoxContainer.new()
	contenido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenido.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	contenido.offset_left = 24.0
	contenido.offset_top = 16.0
	contenido.offset_right = -24.0
	contenido.offset_bottom = -16.0
	_caja.add_child(contenido)
	_quien = Label.new()
	_quien.name = "Quien"
	_quien.add_theme_font_size_override(&"font_size", Tema.LETRA_CHICA)
	_quien.add_theme_color_override(&"font_color", COLOR_QUIEN)
	_quien.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenido.add_child(_quien)
	_texto = Label.new()
	_texto.name = "Texto"
	_texto.add_theme_font_size_override(&"font_size", Tema.LETRA_CHICA)
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	_texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenido.add_child(_texto)
	_opciones = HBoxContainer.new()
	_opciones.name = "Opciones"
	_opciones.alignment = BoxContainer.ALIGNMENT_CENTER
	_opciones.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	_opciones.visible = false
	raiz.add_child(_opciones)
