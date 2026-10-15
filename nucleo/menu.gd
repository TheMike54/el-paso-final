class_name MenuPrincipal
extends Control
# Menu principal: Jugar (abre las ranuras de partida, Ranuras; una vacia pide personaje y nombre, NuevaPartida), Configuracion (nucleo/configuracion.tscn) y, con el
# modo desarrollador encendido, la zona de pruebas. Usa el tema tactil de los menus (Tema). Al abrir pasa la partida
# de antes de las ranuras a la ranura 1, y pide confirmacion antes de cerrar la app con Atras o con pausa. Atras y
# pausa vuelven un nivel a la vez: del editor de botones a Configuracion, de Nueva partida a las ranuras, de las ranuras o de Configuracion al menu,
# y ahi piden salir. Abajo, el aviso de pocos toques si el telefono lo necesita.
## Escena del menu principal: a ella vuelven la pausa, la zona de pruebas y el boton de volver al menu.
const RUTA: String = "res://nucleo/menu.tscn"
const ZONA_PRUEBAS: String = "res://herramientas/salas/zona_pruebas.tscn"
const ESCENA_EDITOR: PackedScene = preload("res://nucleo/editor_controles.tscn")

## Lo pone la zona de pruebas al volver: el menu abre con el foco en su entrada, un nivel atras de la zona.
static var volver_a_zona: bool = false

## Sala donde empieza una partida nueva, y la que se continua si la partida no tiene banco.
@export_file("*.tscn") var sala_inicial: String = ""

## El editor de controles, mientras esta abierto. Publico para que la prueba lo maneje.
var editor: EditorControles = null
## La seleccion de partida; publica para que la prueba la maneje.
var ranuras: Ranuras = null
## La eleccion de personaje y nombre de una ranura vacia; publica para que la prueba la maneje.
var nueva_partida: NuevaPartida = null

@onready var _jugar: Button = $Centro/Opciones/Jugar as Button
@onready var _configuracion: Button = $Centro/Opciones/Configuracion as Button
@onready var _zona: Button = $Centro/Opciones/ZonaPruebas as Button
## La pantalla de Configuracion; publica para que la prueba la maneje.
@onready var configuracion: Configuracion = $Configuracion as Configuracion
@onready var _confirmar: Control = $Confirmar as Control
@onready var _centro: Control = $Centro as Control
@onready var _si: Button = $Confirmar/Caja/Botones/Si as Button
@onready var _no: Button = $Confirmar/Caja/Botones/No as Button


func _ready() -> void:
	theme = Tema.crear()
	_confirmar.visible = false
	var error: Error = Guardado.migrar(Guardado.RUTA, Guardado.ruta_ranura(1))
	if error != OK:
		push_error("Menu: no se pudo pasar la partida a la ranura 1 (error %d)" % error)
	ranuras = Ranuras.new()
	ranuras.name = "Ranuras"
	add_child(ranuras)
	move_child(ranuras, configuracion.get_index())
	ranuras.elegida.connect(_entrar_a_ranura)
	ranuras.cerrado.connect(_al_cerrar_ranuras)
	nueva_partida = NuevaPartida.new()
	nueva_partida.name = "NuevaPartida"
	add_child(nueva_partida)
	move_child(nueva_partida, configuracion.get_index())
	nueva_partida.confirmada.connect(_empezar_nueva)
	nueva_partida.cerrado.connect(_al_cerrar_nueva)
	_jugar.pressed.connect(abrir_ranuras)
	_configuracion.pressed.connect(abrir_configuracion)
	configuracion.editor_pedido.connect(abrir_editor)
	_zona.pressed.connect(_entrar_a_zona)
	configuracion.cerrado.connect(_al_cerrar_configuracion)
	_si.pressed.connect(salir)
	_no.pressed.connect(_cancelar_salida)
	_poner_aviso_toques()
	_mostrar_zona()
	Tema.dar_foco(_jugar)
	if volver_a_zona:
		volver_a_zona = false
		if _zona.visible:
			Tema.dar_foco(_zona)


# La entrada a la zona de pruebas: solo con el modo desarrollador y si la escena existe (en depuracion y en
# publicacion; ver docs/contrato.md, «Paquete de publicacion»).
func _mostrar_zona() -> void:
	_zona.visible = Ajustes.modo_desarrollador and ResourceLoader.exists(ZONA_PRUEBAS)


# Telefono con pocos toques a la vez (ver Toques): una linea abajo, encima del fondo y debajo de la confirmacion de
# salida. Se ve en el menu, en las ranuras y en Configuracion, que no tienen fondo propio.
func _poner_aviso_toques() -> void:
	var aviso: Label = Toques.crear_aviso()
	if aviso != null:
		add_child(aviso)
		move_child(aviso, _confirmar.get_index())
		# El menu y las ranuras quedan arriba del aviso: centrado en toda la pantalla, el menu quedaba encima del
		# aviso (S50, 12-oct-2026).
		_centro.offset_bottom = aviso.offset_top
		ranuras.reservado_abajo = -aviso.offset_top
		nueva_partida.reservado_abajo = -aviso.offset_top
		configuracion.reservado_abajo = -aviso.offset_top


# La zona de pruebas guarda aparte: nunca pisa una partida real.
func _entrar_a_zona() -> void:
	Partida.reiniciar()
	Partida.ruta_guardado = Partida.RUTA_PRUEBAS
	_ir(ZONA_PRUEBAS)


# Una ranura vacia pide antes personaje y nombre; las demas entran ya.
func _entrar_a_ranura(numero: int) -> void:
	if Guardado.cargar(ranuras.ruta(numero)).estado == Guardado.Estado.VACIA:
		ranuras.visible = false
		nueva_partida.abrir(numero)
		return
	var escena: String = preparar_ranura(numero)
	if not escena.is_empty():
		_ir(escena)


func _empezar_nueva(personaje: String, nombre: String) -> void:
	var escena: String = preparar_ranura(nueva_partida.numero, personaje, nombre)
	if not escena.is_empty():
		_ir(escena)


func _al_cerrar_nueva() -> void:
	ranuras.volver(nueva_partida.numero)


## Deja la partida lista para jugar en una ranura y devuelve la escena a la que se va; publico para la prueba. Toda
## entrada fija Partida.ruta_guardado: sin eso el autoguardado iria al archivo de pruebas. Una ranura valida se copia
## (para Restaurar) y se continua en su banco (sin banco, en sala_inicial); una vacia empieza una partida nueva con el
## personaje y el nombre elegidos y la escribe ya, para que su ficha quede ocupada. Una danada o de otra version no se toca y devuelve vacio: solo se
## borra con su confirmacion.
func preparar_ranura(numero: int, personaje: String = "", nombre: String = "") -> String:
	var ruta: String = ranuras.ruta(numero)
	var leida: Guardado.Resultado = Guardado.cargar(ruta)
	if leida.estado == Guardado.Estado.DANADA or leida.estado == Guardado.Estado.INCOMPATIBLE:
		push_warning("Menu: la partida %d esta danada o es de otra version; no se abre" % numero)
		return ""
	if leida.estado == Guardado.Estado.VACIA:
		Partida.reiniciar()
		Partida.personaje = personaje
		Partida.nombre = nombre
		Partida.ruta_guardado = ruta
		var error: Error = Partida.guardar(ruta)
		if error != OK:
			push_error("Menu: no se pudo escribir la partida %d (error %d)" % [numero, error])
		return sala_inicial
	var copia: Error = Guardado.respaldar(ruta)
	if copia != OK:
		push_error("Menu: no se pudo copiar la partida %d (error %d)" % [numero, copia])
	Partida.desde_diccionario(leida.partida)
	Partida.ruta_guardado = ruta
	var escena: String = "" if Partida.sala.is_empty() else Sala.ruta_de(Partida.sala)
	if not escena.is_empty() and not ResourceLoader.exists(escena):
		push_error("Continuar: la sala %s ya no existe; se empieza en la sala inicial" % Partida.sala)
		escena = ""
	if escena.is_empty():
		return sala_inicial
	Sala.llegada_a_banco = true
	return escena


func _physics_process(_delta: float) -> void:
	# El Start con que se acaba de asignar un boton del control no es Atras.
	if Input.is_action_just_pressed(&"pausa") and not configuracion.acaba_de_asignar():
		atras()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		atras()


## Un nivel hacia atras: el editor se cancela, Configuracion y las ranuras retroceden (y al final vuelven al menu) y
## el menu pide salir.
func atras() -> void:
	if editor != null:
		editor.cancelar()
	elif configuracion.visible:
		configuracion.atras()
	elif nueva_partida.visible:
		nueva_partida.atras()
	elif ranuras.visible:
		ranuras.atras()
	else:
		_pedir_salida()


func abrir_ranuras() -> void:
	_centro.visible = false
	ranuras.abrir()


func _al_cerrar_ranuras() -> void:
	_centro.visible = true
	Tema.dar_foco(_jugar)


func abrir_configuracion() -> void:
	_centro.visible = false
	configuracion.abrir()


func _al_cerrar_configuracion() -> void:
	_centro.visible = true
	_mostrar_zona()
	Tema.dar_foco(_configuracion)


## El editor de botones tactiles, sobre el fondo del menu (la pausa abre el mismo); al cerrarlo vuelve Configuracion.
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
		Tema.dar_foco(_no)


## Sale del juego avisando antes el cierre a todo el arbol, como al cerrar la ventana: quit() solo no lo avisa y
## Configuracion guarda ahi lo que no se guardo (inputs/handling_quit_requests.rst, «Sending your own quit notification»).
func salir() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _cancelar_salida() -> void:
	_confirmar.visible = false
	_centro.visible = true
	Tema.dar_foco(_jugar)


func _ir(escena: String) -> void:
	Sala.puerta_llegada = &""
	get_tree().change_scene_to_file(escena)
