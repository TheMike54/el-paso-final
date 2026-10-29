class_name ContadorFps
extends CanvasLayer
# FPS en pantalla (Ajustes.mostrar_fps) arriba al centro y, con el panel de pruebas encendido, el monitor en la misma
# linea: peor cuadro, draw calls, memoria de video y nodos. Ademas pone el limite de FPS: 60 mientras el arbol esta
# en pausa (cualquier menu de la sala) o en el menu principal. NOTIFICATION_PAUSED solo llega a los nodos que la pausa
# detiene (classes/class_node.rst:809), y este procesa siempre: lo mira en cada cuadro, y asi ningun menu tiene que
# acordarse de llamar a Ajustes.aplicar_fps.

## Cada cuanto se reescribe el texto: leer los monitores en cada cuadro no hace falta para leerlo a ojo.
const CADA: float = 0.5
## Encima de todo (los menus van de 20 a 23 y el fundido en 15): se lee tambien con un menu abierto.
const CAPA: int = 24

## En el menu principal: el limite de menu vale siempre, haya pausa o no.
var siempre_en_menu: bool = false

var _texto: Label = null
var _en_menu: bool = false
var _reloj: float = 0.0
var _peor: float = 0.0


func _ready() -> void:
	name = &"ContadorFps"
	layer = CAPA
	process_mode = Node.PROCESS_MODE_ALWAYS
	var raiz: Control = Control.new()
	raiz.theme = Tema.crear()
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(raiz)
	_texto = Label.new()
	_texto.theme_type_variation = Tema.TENUE
	_texto.add_theme_font_size_override(&"font_size", Tema.LETRA_DETALLE)
	_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texto.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_texto.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_texto.offset_top = Tema.MARGEN_VERTICAL
	raiz.add_child(_texto)
	_en_menu = _hay_menu()
	Ajustes.aplicar_fps(_en_menu)
	_al_cambiar_ajuste(Ajustes.MOSTRAR_FPS)
	Eventos.ajuste_grafico_cambiado.connect(_al_cambiar_ajuste)


func _process(delta: float) -> void:
	var en_menu: bool = _hay_menu()
	if en_menu != _en_menu:
		_en_menu = en_menu
		Ajustes.aplicar_fps(_en_menu)
	if not _texto.visible:
		return
	_peor = maxf(_peor, delta)
	_reloj += delta
	if _reloj < CADA:
		return
	_reloj = 0.0
	_texto.text = texto_de(Engine.get_frames_per_second(), _peor, Ajustes.desarrollo(Ajustes.PANEL_PRUEBAS))
	_peor = 0.0


## Lo que dice el contador; con el monitor, ademas los datos de Performance (classes/class_performance.rst).
static func texto_de(fps: float, peor: float, con_monitor: bool) -> String:
	if not con_monitor:
		return "%d FPS" % roundi(fps)
	return "%d FPS · peor %d ms · %d draw · %d MB · %d nodos" % [
		roundi(fps), roundi(peor * 1000.0),
		roundi(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		roundi(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / (1024.0 * 1024.0)),
		roundi(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))]


func _hay_menu() -> bool:
	return siempre_en_menu or get_tree().paused


func _al_cambiar_ajuste(clave: StringName) -> void:
	if clave == Ajustes.MOSTRAR_FPS or clave == Ajustes.PANEL_PRUEBAS or clave == Ajustes.MODO_DESARROLLADOR:
		_texto.visible = Ajustes.mostrar_fps or Ajustes.desarrollo(Ajustes.PANEL_PRUEBAS)
		_reloj = CADA
