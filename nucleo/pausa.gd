class_name Pausa
extends CanvasLayer
# Pausa del juego: la accion pausa o el boton Atras de Android la abren y la cierran durante el
# juego, y se abre sola al salir de la app o cambiar de ventana. Pausar detiene el arbol y no
# guarda la partida; salir al menu si guarda lo obtenido, y pasar a segundo plano lo guarda Partida. Tiene el
# boton que abre el editor de los botones tactiles; vibracion, temblor y lo demas estan en la Configuracion del
# menu. La crea cada sala; corre siempre, aun con el arbol en pausa, para poder cerrarse.
const MENU: String = "res://nucleo/menu.tscn"
const ESCENA_EDITOR: PackedScene = preload("res://nucleo/editor_controles.tscn")

## Si la pausa esta abierta. Publica para que un guion la lea con valor.
var abierta: bool = false
## El editor de controles, mientras esta abierto. Publico para que la prueba lo maneje.
var editor: EditorControles = null

@onready var _panel: Control = $Panel as Control
@onready var _continuar: Button = $Panel/Opciones/Continuar as Button
@onready var _salir: Button = $Panel/Opciones/SalirAlMenu as Button
@onready var _controles: Button = $Panel/Opciones/Controles as Button


func _ready() -> void:
	_panel.theme = Tema.crear()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.visible = false
	_continuar.pressed.connect(cerrar)
	_salir.pressed.connect(_salir_al_menu)
	_controles.pressed.connect(abrir_editor)


# Se lee la accion y no el evento: asi la abren igual el teclado, el boton tactil y un guion.
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pausa") and editor == null and not _pantalla_encima():
		alternar()


# Una pantalla de otro bloque abierta encima del juego (el mapa) se queda la pulsacion de pausa y Atras: se
# encuentra por el grupo, sin conocerla, y dice si bloquea con bloquea_pausa().
func _pantalla_encima() -> bool:
	for nodo: Node in get_tree().get_nodes_in_group(&"pantalla_encima"):
		if nodo.has_method(&"bloquea_pausa") and nodo.call(&"bloquea_pausa") == true:
			return true
	return false


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		# Con el editor abierto, Atras es Cancelar y se vuelve a la pausa.
		if editor != null:
			editor.cancelar()
		elif not _pantalla_encima():
			alternar()
	# Al volver, el jugador encuentra el juego detenido donde lo dejo, no a medio caer.
	elif (que == NOTIFICATION_APPLICATION_FOCUS_OUT or que == NOTIFICATION_APPLICATION_PAUSED) and not abierta and not _pantalla_encima():
		abrir()


func alternar() -> void:
	if abierta:
		cerrar()
	else:
		abrir()


func abrir() -> void:
	abierta = true
	_panel.visible = true
	get_tree().paused = true
	_continuar.grab_focus()


func cerrar() -> void:
	abierta = false
	_panel.visible = false
	get_tree().paused = false


## Oculta el panel y abre el editor encima del juego detenido; al cerrarlo vuelve el panel.
func abrir_editor() -> void:
	var capa: CanvasLayer = ESCENA_EDITOR.instantiate() as CanvasLayer
	add_child(capa)
	editor = capa.get_node(^"Lienzo") as EditorControles
	editor.cerrado.connect(_al_cerrar_editor)
	_panel.visible = false


func _al_cerrar_editor() -> void:
	editor = null
	_panel.visible = abierta
	_controles.grab_focus()


# Salir al menu guarda lo obtenido (no la posicion): al continuar se aparece en el ultimo banco.
func _salir_al_menu() -> void:
	cerrar()
	Partida.autoguardar()
	get_tree().change_scene_to_file(MENU)
