class_name Pausa
extends CanvasLayer
# Pausa del juego: la accion pausa o el boton Atras de Android la abren y la cierran durante el
# juego, y se abre sola al salir de la app o cambiar de ventana. Pausar detiene el arbol y no
# guarda la partida; salir al menu si guarda lo obtenido, y pasar a segundo plano lo guarda Partida. Tiene los interruptores de vibracion y de temblor
# de camara mientras no haya Opciones, y el boton que abre el editor de los botones tactiles. La crea cada
# sala; corre siempre, aun con el arbol en pausa, para poder cerrarse.
const MENU: String = "res://nucleo/menu.tscn"
const ESCENA_EDITOR: PackedScene = preload("res://nucleo/editor_controles.tscn")

## Si la pausa esta abierta. Publica para que un guion la lea con valor.
var abierta: bool = false
## El editor de controles, mientras esta abierto. Publico para que la prueba lo maneje.
var editor: EditorControles = null

@onready var _panel: Control = $Panel as Control
@onready var _continuar: Button = $Panel/Opciones/Continuar as Button
@onready var _salir: Button = $Panel/Opciones/SalirAlMenu as Button
@onready var _vibracion: CheckButton = $Panel/Opciones/Vibracion as CheckButton
@onready var _temblor: CheckButton = $Panel/Opciones/Temblor as CheckButton
@onready var _controles: Button = $Panel/Opciones/Controles as Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.visible = false
	_continuar.pressed.connect(cerrar)
	_salir.pressed.connect(_salir_al_menu)
	Ajustes.cargar_una_vez()
	_vibracion.button_pressed = Ajustes.vibracion
	_vibracion.toggled.connect(_al_cambiar_vibracion)
	_temblor.button_pressed = Ajustes.temblor
	_temblor.toggled.connect(_al_cambiar_temblor)
	_controles.pressed.connect(abrir_editor)


# Se lee la accion y no el evento: asi la abren igual el teclado, el boton tactil y un guion.
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pausa") and editor == null:
		alternar()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		# Con el editor abierto, Atras es Cancelar y se vuelve a la pausa.
		if editor != null:
			editor.cancelar()
		else:
			alternar()
	# Al volver, el jugador encuentra el juego detenido donde lo dejo, no a medio caer.
	elif (que == NOTIFICATION_APPLICATION_FOCUS_OUT or que == NOTIFICATION_APPLICATION_PAUSED) and not abierta:
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


func _al_cambiar_vibracion(encendida: bool) -> void:
	Ajustes.vibracion = encendida
	_guardar_ajustes()


func _al_cambiar_temblor(encendido: bool) -> void:
	Ajustes.temblor = encendido
	_guardar_ajustes()


func _guardar_ajustes() -> void:
	var error: Error = Ajustes.guardar()
	if error != OK:
		push_error("Pausa: no se pudieron guardar los ajustes (error %d)" % error)


# Salir al menu guarda lo obtenido (no la posicion): al continuar se aparece en el ultimo banco.
func _salir_al_menu() -> void:
	cerrar()
	Partida.autoguardar()
	get_tree().change_scene_to_file(MENU)
