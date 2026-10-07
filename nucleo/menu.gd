extends Control
# Menu de desarrollo: Nueva partida, Continuar y, solo en depuracion y con las herramientas en
# el paquete, la zona de pruebas. Dice el estado de la partida guardada (carga, sin partida,
# danada u otra version) y pide confirmacion antes de cerrar la app con Atras o con pausa.
const ZONA_PRUEBAS: String = "res://herramientas/salas/zona_pruebas.tscn"

## Sala donde empieza una partida nueva, y por ahora tambien la que se continua.
@export_file("*.tscn") var sala_inicial: String = ""

@onready var _nueva: Button = $Centro/Opciones/NuevaPartida as Button
@onready var _continuar: Button = $Centro/Opciones/Continuar as Button
@onready var _zona: Button = $Centro/Opciones/ZonaPruebas as Button
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
	_si.pressed.connect(get_tree().quit)
	_no.pressed.connect(_cancelar_salida)
	_estado.text = "Cargando partida…"
	_guardada = Guardado.cargar()
	_mostrar_partida(_guardada.estado)
	_nueva.grab_focus()


func _nueva_partida(escena: String) -> void:
	Partida.reiniciar()
	_ir(escena)


# Se continua en el banco guardado; una partida sin banco, en sala_inicial.
func _continuar_partida() -> void:
	Partida.desde_diccionario(_guardada.partida)
	if Partida.sala.is_empty():
		_ir(sala_inicial)
	else:
		_ir(Partida.sala)
		Sala.llegada_a_banco = true


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
		_pedir_salida()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		_pedir_salida()


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
