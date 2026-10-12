extends Control
# Menu de desarrollo: Nueva partida, Continuar y, solo en depuracion y con las herramientas en
# el paquete, la zona de pruebas. Dice el estado de la partida guardada (carga, sin partida,
# danada u otra version) y pide confirmacion antes de cerrar la app con Atras o con pausa.
# Configuracion abre un panel con Controles, que lleva al mismo editor de botones que la pausa;
# Atras y pausa vuelven un nivel a la vez: del editor al panel, del panel al menu, y ahi piden salir.
const ZONA_PRUEBAS: String = "res://herramientas/salas/zona_pruebas.tscn"
const ESCENA_EDITOR: PackedScene = preload("res://nucleo/editor_controles.tscn")

## Sala donde empieza una partida nueva, y por ahora tambien la que se continua.
@export_file("*.tscn") var sala_inicial: String = ""

## El editor de controles, mientras esta abierto. Publico para que la prueba lo maneje.
var editor: EditorControles = null

@onready var _nueva: Button = $Centro/Opciones/NuevaPartida as Button
@onready var _continuar: Button = $Centro/Opciones/Continuar as Button
@onready var _zona: Button = $Centro/Opciones/ZonaPruebas as Button
@onready var _configuracion: Button = $Centro/Opciones/Configuracion as Button
@onready var _panel_configuracion: Control = $PanelConfiguracion as Control
@onready var _controles: Button = $PanelConfiguracion/Opciones/Controles as Button
@onready var _volver: Button = $PanelConfiguracion/Opciones/Volver as Button
@onready var _estado: Label = $Centro/Opciones/Estado as Label
@onready var _confirmar: Control = $Confirmar as Control
@onready var _centro: Control = $Centro as Control
@onready var _si: Button = $Confirmar/Caja/Botones/Si as Button
@onready var _no: Button = $Confirmar/Caja/Botones/No as Button

var _guardada: Guardado.Resultado = null


func _ready() -> void:
	_zona.visible = OS.is_debug_build() and ResourceLoader.exists(ZONA_PRUEBAS)
	_confirmar.visible = false
	_nueva.pressed.connect(_nueva_partida.bind(sala_inicial))
	_continuar.pressed.connect(_continuar_partida)
	_zona.pressed.connect(_nueva_partida.bind(ZONA_PRUEBAS))
	_configuracion.pressed.connect(abrir_configuracion)
	_controles.pressed.connect(abrir_editor)
	_volver.pressed.connect(cerrar_configuracion)
	_panel_configuracion.visible = false
	_si.pressed.connect(get_tree().quit)
	_no.pressed.connect(_cancelar_salida)
	_estado.text = "Cargando partida…"
	_guardada = Guardado.cargar()
	_mostrar_partida(_guardada.estado)
	_nueva.grab_focus()


func _nueva_partida(escena: String) -> void:
	Partida.reiniciar()
	# La zona de pruebas guarda aparte: nunca pisa la partida real.
	Partida.ruta_guardado = Partida.RUTA_PRUEBAS if escena == ZONA_PRUEBAS else Guardado.RUTA
	_ir(escena)


# Se continua en el banco guardado; una partida sin banco, en sala_inicial.
func _continuar_partida() -> void:
	Partida.desde_diccionario(_guardada.partida)
	Partida.ruta_guardado = Guardado.RUTA
	var ruta: String = "" if Partida.sala.is_empty() else Sala.ruta_de(Partida.sala)
	if not ruta.is_empty() and not ResourceLoader.exists(ruta):
		push_error("Continuar: la sala %s ya no existe; se empieza en la sala inicial" % Partida.sala)
		ruta = ""
	if ruta.is_empty():
		_ir(sala_inicial)
	else:
		Sala.llegada_a_banco = true
		_ir(ruta)


func _mostrar_partida(estado: Guardado.Estado) -> void:
	_continuar.disabled = estado != Guardado.Estado.VALIDA
	match estado:
		Guardado.Estado.VALIDA:
			_estado.text = ""
		Guardado.Estado.VACIA:
			_estado.text = "No hay partida guardada."
		Guardado.Estado.DANADA:
			_estado.text = "La partida guardada está dañada. Puedes empezar una nueva."
		Guardado.Estado.INCOMPATIBLE:
			_estado.text = "La partida guardada es de otra versión del juego."


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pausa"):
		atras()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		atras()


## Un nivel hacia atras: el editor se cancela, el panel vuelve al menu y el menu pide salir.
func atras() -> void:
	if editor != null:
		editor.cancelar()
	elif _panel_configuracion.visible:
		cerrar_configuracion()
	else:
		_pedir_salida()


func abrir_configuracion() -> void:
	_centro.visible = false
	_panel_configuracion.visible = true
	_controles.grab_focus()


func cerrar_configuracion() -> void:
	_panel_configuracion.visible = false
	_centro.visible = true
	_configuracion.grab_focus()


## El mismo editor que abre la pausa, sobre el fondo del menu; al cerrarlo vuelve el panel.
func abrir_editor() -> void:
	var capa: CanvasLayer = ESCENA_EDITOR.instantiate() as CanvasLayer
	add_child(capa)
	editor = capa.get_node(^"Lienzo") as EditorControles
	editor.cerrado.connect(_al_cerrar_editor)
	_panel_configuracion.visible = false


func _al_cerrar_editor() -> void:
	editor = null
	_panel_configuracion.visible = true
	_controles.grab_focus()


func _pedir_salida() -> void:
	if _confirmar.visible:
		_cancelar_salida()
	else:
		_confirmar.visible = true
		_centro.visible = false
		_no.grab_focus()


func _cancelar_salida() -> void:
	_confirmar.visible = false
	_centro.visible = true
	_nueva.grab_focus()


func _ir(escena: String) -> void:
	Sala.puerta_llegada = &""
	get_tree().change_scene_to_file(escena)
