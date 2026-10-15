class_name Pausa
extends CanvasLayer
# Pausa del juego: la accion pausa o el boton Atras de Android la abren y la cierran durante el
# juego, y se abre sola al salir de la app o cambiar de ventana. Pausar detiene el arbol y no
# guarda la partida; salir al menu si guarda lo obtenido, y pasar a segundo plano lo guarda Partida. Continuar,
# Configuracion (la misma del menu, encima y con el juego detenido; de ahi sale el editor de botones tactiles) y
# Salir al menu, como en Hollow Knight. Los amuletos y el mapa estan en el marco de menus. La crea cada sala.
const ESCENA_EDITOR: PackedScene = preload("res://nucleo/editor_controles.tscn")
const ESCENA_CONFIGURACION: PackedScene = preload("res://nucleo/configuracion.tscn")
## Configuracion abierta desde la pausa: encima de la pausa y del marco, debajo del editor de botones (23).
const CAPA_CONFIGURACION: int = 22

## Si la pausa esta abierta. Publica para que un guion la lea con valor.
var abierta: bool = false
## El editor de controles, mientras esta abierto. Publico para que la prueba lo maneje.
var editor: EditorControles = null
## La Configuracion, creada la primera vez que se abre. Publica para que la prueba la maneje.
var configuracion: Configuracion = null
# Foto de la sala al abrir la pausa, para la pantalla de brillo de Configuracion, y el brillo que traia. Una copia
# al abrir, no cada cuadro; se suelta al cerrar (en el telefono pesa unos megas).
var _foto: Image = null
var _foto_brillo: float = Ajustes.BRILLO_POR_OMISION
# El editor de botones se abrio desde Configuracion: al cerrarlo se vuelve a ella.
var _editor_desde_configuracion: bool = false

@onready var _panel: Control = $Panel as Control
@onready var _continuar: Button = $Panel/Opciones/Continuar as Button
@onready var _salir: Button = $Panel/Opciones/SalirAlMenu as Button
@onready var _boton_configuracion: Button = $Panel/Opciones/Configuracion as Button


func _ready() -> void:
	_panel.theme = Tema.crear()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel.visible = false
	_continuar.pressed.connect(cerrar)
	_salir.pressed.connect(_salir_al_menu)
	_boton_configuracion.pressed.connect(abrir_configuracion)


# Se lee la accion y no el evento: asi la abren igual el teclado, el boton tactil y un guion.
func _physics_process(_delta: float) -> void:
	if not Input.is_action_just_pressed(&"pausa") or editor != null:
		return
	# Con Configuracion abierta, pausa vuelve un nivel, como Atras; salvo el Start recien asignado a una accion.
	if _configuracion_abierta():
		if not configuracion.acaba_de_asignar():
			configuracion.atras()
	elif not _pantalla_encima():
		alternar()


# Una pantalla abierta encima del juego (el marco de menus) se queda la pulsacion de pausa y Atras: se
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
		elif _configuracion_abierta():
			configuracion.atras()
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
	# Lo ultimo dibujado es todavia la sala: el panel sale en el cuadro siguiente. En headless no hay imagen.
	if DisplayServer.get_name() != "headless":
		_foto = get_viewport().get_texture().get_image()
		_foto_brillo = Ajustes.brillo
	abierta = true
	_panel.visible = true
	get_tree().paused = true
	Tema.dar_foco(_continuar)


func cerrar() -> void:
	_foto = null
	if configuracion != null:
		configuracion.soltar_foto()
	abierta = false
	_panel.visible = false
	get_tree().paused = false


## Oculta el panel y abre Configuracion encima del juego detenido; al cerrarla vuelve el panel.
func abrir_configuracion() -> void:
	if configuracion == null:
		var capa: CanvasLayer = CanvasLayer.new()
		capa.name = "CapaConfiguracion"
		capa.layer = CAPA_CONFIGURACION
		add_child(capa)
		var fondo: ColorRect = ColorRect.new()
		fondo.name = "Fondo"
		fondo.color = Color(0.0, 0.0, 0.0, 0.9)
		fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
		fondo.theme = Tema.crear()
		capa.add_child(fondo)
		configuracion = ESCENA_CONFIGURACION.instantiate() as Configuracion
		configuracion.en_partida = true
		fondo.add_child(configuracion)
		configuracion.cerrado.connect(_al_cerrar_configuracion)
		configuracion.editor_pedido.connect(abrir_editor)
	_panel.visible = false
	_fondo_configuracion().visible = true
	configuracion.foto = _foto
	configuracion.foto_brillo = _foto_brillo
	configuracion.abrir()


func _configuracion_abierta() -> bool:
	return configuracion != null and configuracion.visible


func _fondo_configuracion() -> Control:
	return configuracion.get_parent() as Control


func _al_cerrar_configuracion() -> void:
	_fondo_configuracion().visible = false
	_panel.visible = abierta
	Tema.dar_foco(_boton_configuracion)


## Abre el editor de botones tactiles encima del juego detenido (lo pide Configuracion); al cerrarlo vuelve a
## Configuracion, o al panel si se abrio sin ella.
func abrir_editor() -> void:
	var capa: CanvasLayer = ESCENA_EDITOR.instantiate() as CanvasLayer
	add_child(capa)
	editor = capa.get_node(^"Lienzo") as EditorControles
	editor.cerrado.connect(_al_cerrar_editor)
	_panel.visible = false
	# Sin el fondo negro de Configuracion: los botones se acomodan viendo la sala detenida debajo.
	_editor_desde_configuracion = _configuracion_abierta()
	if configuracion != null:
		configuracion.visible = false
		_fondo_configuracion().visible = false


func _al_cerrar_editor() -> void:
	editor = null
	if _editor_desde_configuracion:
		_editor_desde_configuracion = false
		_fondo_configuracion().visible = true
		configuracion.volver_del_editor()
	else:
		_panel.visible = abierta
		Tema.dar_foco(_boton_configuracion)


# Salir al menu guarda lo obtenido (no la posicion): al continuar se aparece en el ultimo banco.
func _salir_al_menu() -> void:
	cerrar()
	Partida.autoguardar()
	get_tree().change_scene_to_file(MenuPrincipal.RUTA)
