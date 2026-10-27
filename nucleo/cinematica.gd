class_name Cinematica
extends Control
# Cinematica a pantalla completa antes de una sala, como el CinematicPlayer de Hollow Knight: reproduce su video a todo
# lo ancho (sin franjas a los lados en un telefono 20:9; decidido por la persona el 24-oct-2026) y al terminar pasa a
# sala_destino. Solo con el modo desarrollador se salta («Saltar», Atras, pausa, B o A); sin el se ve entera.

## Video sin extension: <video>.mp4 (H.264, Android) y <video>.ogv (Theora, PC). Sin imagen de respaldo: si el
## telefono no puede reproducirlo, se pasa directo a la sala (decidido por la persona el 25-oct-2026). Ver ReproductorVideo.
@export var video: String = ""
## Id de la sala a la que se pasa al terminar (Sala.ruta_de).
@export var sala_destino: String = ""

var _video: ReproductorVideo = null
var _saliendo: bool = false


func _ready() -> void:
	theme = Tema.crear()
	var negro: ColorRect = ColorRect.new()
	negro.name = &"Negro"
	negro.color = Color.BLACK
	negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	negro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(negro)
	_video = ReproductorVideo.crear(video, false, AspectRatioContainer.STRETCH_WIDTH_CONTROLS_HEIGHT)
	add_child(_video)
	_video.terminado.connect(ir_a_la_sala)
	if Ajustes.modo_desarrollador:
		_poner_saltar()
	# Sin el modo desarrollador nada salta la cinematica: no hace falta mirar acciones cada tick.
	set_physics_process(Ajustes.modo_desarrollador)
	_video.reproducir()


func _physics_process(_delta: float) -> void:
	if (Input.is_action_just_pressed(&"pausa") or Input.is_action_just_pressed(&"volver")
			or Input.is_action_just_pressed(&"ui_accept")):
		ir_a_la_sala()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST and Ajustes.modo_desarrollador:
		ir_a_la_sala()


## Deja el video y pasa a la sala; solo la primera vez. Publico para el boton y el guion.
func ir_a_la_sala() -> void:
	if _saliendo:
		return
	_saliendo = true
	_video.detener()
	Sala.puerta_llegada = &""
	get_tree().change_scene_to_file.call_deferred(Sala.ruta_de(sala_destino))


# Abajo a la derecha, tenue y sin foco: no tapa el video ni lo toma el control.
func _poner_saltar() -> void:
	var saltar: Button = Button.new()
	saltar.name = &"Saltar"
	saltar.text = "Saltar"
	saltar.theme_type_variation = Tema.OPCION_CHICA
	saltar.focus_mode = Control.FOCUS_NONE
	saltar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	saltar.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	saltar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	saltar.offset_right = -Tema.MARGEN_DERECHO
	saltar.offset_bottom = -Tema.MARGEN_VERTICAL
	saltar.custom_minimum_size = Vector2(0.0, Tema.ALTO_TOQUE)
	saltar.modulate = Color(1.0, 1.0, 1.0, 0.6)
	saltar.pressed.connect(ir_a_la_sala)
	add_child(saltar)
