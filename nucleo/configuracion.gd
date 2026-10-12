class_name Configuracion
extends Control
# Configuracion del menu principal: botones tactiles (abre el editor), botones del control, vibracion,
# temblor, volumen, recursos (con aviso si se elige alto en un telefono debil), modo desarrollador (muestra la entrada a la zona de pruebas), borrar la partida y
# creditos. Cada cambio se guarda al momento en los ajustes. Atras y pausa vuelven un nivel a la vez: de la
# confirmacion o del subpanel a la lista, y de la lista al menu (cerrado). Se usa con toque, teclado y control.

signal cerrado()
signal editor_pedido()
signal zona_pruebas_pedida()
signal partida_borrada()

const ZONA_PRUEBAS: String = "res://herramientas/salas/zona_pruebas.tscn"

## Lo pone la zona de pruebas al volver: el menu abre la Configuracion en lugar de su lista, un nivel atras de la zona.
static var abrir_al_volver: bool = false

## Archivos que usa: publicos para que la prueba trabaje con los suyos.
var ruta_ajustes: String = Ajustes.RUTA
var ruta_partida: String = Guardado.RUTA
## Accion del control que espera que se presione un boton, o vacio.
var esperando: StringName = &""

# Tick en que se asigno un boton: si era Start, la accion pausa quedo recien presionada en ese tick y el menu
# la tomaria como Atras (ver acaba_de_asignar).
var _tick_asignado: int = -10
# Tick en que se cerro la lista de Recursos: en Android, Atras cierra la lista y despues llega como Atras del
# menu; sin esto subia un nivel de mas (S50, 12-oct-2026).
var _tick_lista_cerrada: int = -10

@onready var _lista: Control = $Lista as Control
@onready var _controles: Button = $Lista/Caja/Opciones/Controles as Button
@onready var _mando: Button = $Lista/Caja/Opciones/Mando as Button
@onready var _vibracion: CheckButton = $Lista/Caja/Opciones/Vibracion as CheckButton
@onready var _temblor: CheckButton = $Lista/Caja/Opciones/Temblor as CheckButton
@onready var _volumen: HSlider = $Lista/Caja/Opciones/Volumen/Barra as HSlider
@onready var _recursos: OptionButton = $Lista/Caja/Opciones/Recursos as OptionButton
@onready var _aviso_recursos: Label = $Lista/Caja/AvisoRecursos as Label
@onready var _modo: CheckButton = $Lista/Caja/Opciones/ModoDesarrollador as CheckButton
@onready var _zona: Button = $Lista/Caja/Opciones/ZonaPruebas as Button
@onready var _borrar: Button = $Lista/Caja/Opciones/BorrarPartida as Button
@onready var _creditos: Button = $Lista/Caja/Opciones/Creditos as Button
@onready var _volver: Button = $Lista/Caja/Opciones/Volver as Button
@onready var _panel_mando: Control = $PanelMando as Control
@onready var _filas: GridContainer = $PanelMando/Caja/Filas as GridContainer
@onready var _aviso_mando: Label = $PanelMando/Caja/Aviso as Label
@onready var _por_omision: Button = $PanelMando/Caja/Botones/PorOmision as Button
@onready var _volver_mando: Button = $PanelMando/Caja/Botones/Volver as Button
@onready var _panel_creditos: Control = $PanelCreditos as Control
@onready var _volver_creditos: Button = $PanelCreditos/Caja/Volver as Button
@onready var _confirmar: Control = $ConfirmarBorrado as Control
@onready var _si_borrar: Button = $ConfirmarBorrado/Caja/Botones/Borrar as Button
@onready var _no_borrar: Button = $ConfirmarBorrado/Caja/Botones/Cancelar as Button

var _botones_mando: Dictionary[StringName, Button] = {}


func _ready() -> void:
	Ajustes.cargar_una_vez()
	_controles.pressed.connect(editor_pedido.emit)
	_mando.pressed.connect(_abrir_mando)
	_vibracion.toggled.connect(_al_cambiar_vibracion)
	_temblor.toggled.connect(_al_cambiar_temblor)
	_volumen.value_changed.connect(_al_cambiar_volumen)
	_recursos.clear()
	_recursos.add_item("Recursos: automático (%s)" % ("bajo" if Recursos.es_debil() else "alto"))
	_recursos.add_item("Recursos: bajo")
	_recursos.add_item("Recursos: alto")
	_recursos.item_selected.connect(_al_elegir_recursos)
	# Las opciones de la lista median ~18 px en el S50: el dedo no les atinaba (prueba del 12-oct-2026).
	var opciones: PopupMenu = _recursos.get_popup()
	opciones.add_theme_font_size_override(&"font_size", 30)
	opciones.add_theme_constant_override(&"v_separation", 28)
	opciones.popup_hide.connect(_al_cerrar_lista)
	_modo.toggled.connect(_al_cambiar_modo)
	_zona.pressed.connect(zona_pruebas_pedida.emit)
	_borrar.pressed.connect(_pedir_borrado)
	_creditos.pressed.connect(_abrir_creditos)
	_volver.pressed.connect(atras)
	_por_omision.pressed.connect(_mando_por_omision)
	_volver_mando.pressed.connect(atras)
	_volver_creditos.pressed.connect(atras)
	_si_borrar.pressed.connect(_borrar_partida)
	_no_borrar.pressed.connect(atras)
	for accion: StringName in Mando.REASIGNABLES:
		var nombre: Label = Label.new()
		nombre.text = String(accion).capitalize()
		nombre.add_theme_font_size_override(&"font_size", 26)
		_filas.add_child(nombre)
		var boton: Button = Button.new()
		boton.custom_minimum_size = Vector2(260.0, 52.0)
		boton.add_theme_font_size_override(&"font_size", 24)
		boton.pressed.connect(_esperar_boton.bind(accion))
		_filas.add_child(boton)
		_botones_mando[accion] = boton
	visible = false


## Muestra la lista con los valores actuales y pone el foco en el primer boton.
func abrir() -> void:
	_vibracion.set_pressed_no_signal(Ajustes.vibracion)
	_temblor.set_pressed_no_signal(Ajustes.temblor)
	_volumen.set_value_no_signal(roundf(Ajustes.volumen * 100.0))
	_modo.set_pressed_no_signal(Ajustes.modo_desarrollador)
	_recursos.select(maxi(Recursos.MODOS.find(Ajustes.recursos), 0))
	_mostrar_aviso_recursos()
	_mostrar_zona()
	visible = true
	_mostrar(_lista)
	_controles.grab_focus()


## Pone el foco en la entrada a la zona de pruebas: al volver de ella.
func enfocar_zona() -> void:
	if _zona.visible:
		_zona.grab_focus()


## Si se acaba de asignar un boton (este tick o el anterior): el menu ignora entonces la accion pausa.
func acaba_de_asignar() -> bool:
	return Engine.get_physics_frames() - _tick_asignado <= 1


## Un nivel hacia atras. En la lista, cierra la Configuracion.
func atras() -> void:
	if not visible:
		return
	var opciones: PopupMenu = _recursos.get_popup()
	if opciones.visible:
		opciones.hide()
	elif Engine.get_physics_frames() - _tick_lista_cerrada <= 1:
		pass
	elif _confirmar.visible:
		_confirmar.visible = false
		_borrar.grab_focus()
	elif not esperando.is_empty():
		esperando = &""
		_aviso_mando.text = ""
		_botones_mando[Mando.REASIGNABLES[0]].grab_focus()
	elif _panel_mando.visible:
		_mostrar(_lista)
		_mando.grab_focus()
	elif _panel_creditos.visible:
		_mostrar(_lista)
		_creditos.grab_focus()
	else:
		visible = false
		cerrado.emit()


## Vuelve a la lista con el foco en Controles: al cerrar el editor de botones.
func volver_del_editor() -> void:
	visible = true
	_mostrar(_lista)
	_controles.grab_focus()


func _mostrar(panel: Control) -> void:
	_lista.visible = panel == _lista
	_panel_mando.visible = panel == _panel_mando
	_panel_creditos.visible = panel == _panel_creditos
	_confirmar.visible = false


func _mostrar_zona() -> void:
	_zona.visible = Ajustes.modo_desarrollador and ResourceLoader.exists(ZONA_PRUEBAS)


func _al_cambiar_vibracion(encendida: bool) -> void:
	Ajustes.vibracion = encendida
	_guardar()


func _al_cambiar_temblor(encendido: bool) -> void:
	Ajustes.temblor = encendido
	_guardar()


func _al_cambiar_volumen(valor: float) -> void:
	Ajustes.volumen = valor / 100.0
	Ajustes.aplicar_volumen()
	_guardar()


func _al_cerrar_lista() -> void:
	_tick_lista_cerrada = Engine.get_physics_frames()


func _al_elegir_recursos(indice: int) -> void:
	Ajustes.recursos = Recursos.MODOS[indice]
	_mostrar_aviso_recursos()
	_guardar()


# Elegir alto en un telefono que la deteccion marca como debil se permite, con aviso.
func _mostrar_aviso_recursos() -> void:
	var avisar: bool = Recursos.avisar(Ajustes.recursos, Recursos.es_debil())
	_aviso_recursos.text = "Este teléfono parece de gama baja (%s): en alto puede ir lento." % Recursos.motivo() if avisar else ""
	_aviso_recursos.visible = avisar


func _al_cambiar_modo(encendido: bool) -> void:
	Ajustes.modo_desarrollador = encendido
	_mostrar_zona()
	_guardar()


func _guardar() -> void:
	var error: Error = Ajustes.guardar(ruta_ajustes)
	if error != OK:
		push_error("Configuracion: no se pudieron guardar los ajustes (error %d)" % error)


func _abrir_mando() -> void:
	_mostrar(_panel_mando)
	_aviso_mando.text = ""
	_poner_nombres_mando()
	_botones_mando[Mando.REASIGNABLES[0]].grab_focus()


func _poner_nombres_mando() -> void:
	for accion: StringName in Mando.REASIGNABLES:
		_botones_mando[accion].text = Mando.nombre_de(Mando.boton_de(accion))


func _esperar_boton(accion: StringName) -> void:
	esperando = accion
	_aviso_mando.text = "Presiona en el control el botón para «%s» (Atrás cancela)." % String(accion).capitalize()


## Asigna el boton a la accion que espera (lo llama _input con el boton del control; publico para la prueba).
func recibir_boton(boton: int) -> void:
	if esperando.is_empty():
		return
	Mando.asignar(esperando, boton)
	_tick_asignado = Engine.get_physics_frames()
	var accion: StringName = esperando
	esperando = &""
	_aviso_mando.text = ""
	_poner_nombres_mando()
	_guardar()
	_botones_mando[accion].grab_focus()


func _input(evento: InputEvent) -> void:
	if esperando.is_empty():
		return
	var boton: InputEventJoypadButton = evento as InputEventJoypadButton
	if boton != null and boton.pressed:
		recibir_boton(boton.button_index)
		get_viewport().set_input_as_handled()


func _mando_por_omision() -> void:
	Mando.por_omision()
	_poner_nombres_mando()
	_guardar()


func _abrir_creditos() -> void:
	_mostrar(_panel_creditos)
	_volver_creditos.grab_focus()


func _pedir_borrado() -> void:
	_confirmar.visible = true
	_no_borrar.grab_focus()


func _borrar_partida() -> void:
	var error: Error = Guardado.borrar(ruta_partida)
	if error != OK:
		push_error("Configuracion: no se pudo borrar la partida (error %d)" % error)
	_confirmar.visible = false
	_borrar.grab_focus()
	partida_borrada.emit()
