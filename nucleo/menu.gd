extends Control
# Menu principal: Nueva partida, Continuar y Configuracion (nucleo/configuracion.tscn, que con el modo
# desarrollador muestra la zona de pruebas). Dice el estado de la partida guardada (carga, sin partida,
# danada u otra version) y pide confirmacion antes de cerrar la app con Atras o con pausa. Atras y pausa
# vuelven un nivel a la vez: del editor de botones a Configuracion, de ahi al menu, y ahi piden salir. Abajo, el
# aviso de pocos toques si el telefono lo necesita.
const ZONA_PRUEBAS: String = "res://herramientas/salas/zona_pruebas.tscn"
const ESCENA_EDITOR: PackedScene = preload("res://nucleo/editor_controles.tscn")

## Sala donde empieza una partida nueva, y por ahora tambien la que se continua.
@export_file("*.tscn") var sala_inicial: String = ""

## El editor de controles, mientras esta abierto. Publico para que la prueba lo maneje.
var editor: EditorControles = null

@onready var _nueva: Button = $Centro/Opciones/NuevaPartida as Button
@onready var _continuar: Button = $Centro/Opciones/Continuar as Button
@onready var _configuracion: Button = $Centro/Opciones/Configuracion as Button
## La pantalla de Configuracion; publica para que la prueba la maneje.
@onready var configuracion: Configuracion = $Configuracion as Configuracion
@onready var _estado: Label = $Centro/Opciones/Estado as Label
@onready var _confirmar: Control = $Confirmar as Control
@onready var _centro: Control = $Centro as Control
@onready var _si: Button = $Confirmar/Caja/Botones/Si as Button
@onready var _no: Button = $Confirmar/Caja/Botones/No as Button

var _guardada: Guardado.Resultado = null


func _ready() -> void:
	_confirmar.visible = false
	_nueva.pressed.connect(_nueva_partida.bind(sala_inicial))
	_continuar.pressed.connect(_continuar_partida)
	_configuracion.pressed.connect(abrir_configuracion)
	configuracion.editor_pedido.connect(abrir_editor)
	configuracion.zona_pruebas_pedida.connect(_nueva_partida.bind(ZONA_PRUEBAS))
	configuracion.cerrado.connect(_al_cerrar_configuracion)
	configuracion.partida_borrada.connect(_leer_partida)
	_si.pressed.connect(get_tree().quit)
	_no.pressed.connect(_cancelar_salida)
	_leer_partida()
	_poner_aviso_toques()
	_nueva.grab_focus()
	if Configuracion.abrir_al_volver:
		Configuracion.abrir_al_volver = false
		abrir_configuracion()
		configuracion.enfocar_zona()


# Telefono con pocos toques a la vez (ver Toques): una linea abajo, encima del fondo y debajo de la confirmacion de
# salida. Se ve en el menu y en Configuracion, que no tiene fondo propio.
func _poner_aviso_toques() -> void:
	var aviso: Label = Toques.crear_aviso()
	if aviso != null:
		add_child(aviso)
		move_child(aviso, _confirmar.get_index())


func _leer_partida() -> void:
	_estado.text = "Cargando partida…"
	_guardada = Guardado.cargar()
	_mostrar_partida(_guardada.estado)


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
	# El Start con que se acaba de asignar un boton del control no es Atras.
	if Input.is_action_just_pressed(&"pausa") and not configuracion.acaba_de_asignar():
		atras()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		atras()


## Un nivel hacia atras: el editor se cancela, Configuracion retrocede (y al final vuelve al menu) y el menu
## pide salir.
func atras() -> void:
	if editor != null:
		editor.cancelar()
	elif configuracion.visible:
		configuracion.atras()
	else:
		_pedir_salida()


func abrir_configuracion() -> void:
	_centro.visible = false
	configuracion.abrir()


func _al_cerrar_configuracion() -> void:
	_centro.visible = true
	_configuracion.grab_focus()


## El mismo editor que abre la pausa, sobre el fondo del menu; al cerrarlo vuelve Configuracion.
func abrir_editor() -> void:
	var capa: CanvasLayer = ESCENA_EDITOR.instantiate() as CanvasLayer
	add_child(capa)
	editor = capa.get_node(^"Lienzo") as EditorControles
	editor.cerrado.connect(_al_cerrar_editor)
	configuracion.visible = false


func _al_cerrar_editor() -> void:
	editor = null
	configuracion.volver_del_editor()


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
