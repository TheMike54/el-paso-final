class_name Configuracion
extends Control
# Configuracion del menu principal, en orden de uso: volumen (con - y +), vibracion, temblor, recursos (con aviso si
# se elige alto en un telefono debil), botones tactiles (abre el editor), botones del control (con aviso si no hay
# uno conectado), modo desarrollador (el menu muestra entonces la zona de pruebas), borrar la partida y creditos.
# Cada cambio se guarda al momento en los ajustes. Volver va siempre arriba a la izquierda, y las cuadriculas toman
# las columnas que caben (Tema). Atras y pausa vuelven un nivel a la vez: de la confirmacion o del subpanel a la
# lista, y de la lista al menu (cerrado). Se usa con toque, teclado y control.

signal cerrado()
signal editor_pedido()
signal partida_borrada()

## Nombre en pantalla de cada accion reasignable del control.
const NOMBRES_ACCION: Dictionary[StringName, String] = {&"saltar": "Saltar", &"atacar": "Atacar", &"curar": "Curar", &"mapa": "Mapa", &"mapa_rapido": "Mapa rápido", &"mochila": "Mochila", &"pausa": "Pausa"}
## Lo que suben o bajan - y + del volumen, en %.
const PASO_VOLUMEN: float = 10.0

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
@onready var _opciones: GridContainer = $Lista/Desplazable/Centro/Opciones as GridContainer
@onready var _desplazable: ScrollContainer = $Lista/Desplazable as ScrollContainer
@onready var _desplazable_mando: ScrollContainer = $PanelMando/Desplazable as ScrollContainer
@onready var _controles: Button = $Lista/Desplazable/Centro/Opciones/Controles as Button
@onready var _mando: Button = $Lista/Desplazable/Centro/Opciones/Mando as Button
@onready var _vibracion: CheckButton = $Lista/Desplazable/Centro/Opciones/Vibracion as CheckButton
@onready var _temblor: CheckButton = $Lista/Desplazable/Centro/Opciones/Temblor as CheckButton
@onready var _volumen: HSlider = $Lista/Desplazable/Centro/Opciones/Volumen/Medio/Barra as HSlider
@onready var _menos: Button = $Lista/Desplazable/Centro/Opciones/Volumen/Menos as Button
@onready var _mas: Button = $Lista/Desplazable/Centro/Opciones/Volumen/Mas as Button
@onready var _recursos: OptionButton = $Lista/Desplazable/Centro/Opciones/Recursos as OptionButton
@onready var _aviso_recursos: Label = $Lista/AvisoRecursos as Label
@onready var _modo: CheckButton = $Lista/Desplazable/Centro/Opciones/ModoDesarrollador as CheckButton
@onready var _borrar: Button = $Lista/Desplazable/Centro/Opciones/BorrarPartida as Button
@onready var _creditos: Button = $Lista/Desplazable/Centro/Opciones/Creditos as Button
@onready var _volver: Button = $Lista/Arriba/Volver as Button
@onready var _panel_mando: Control = $PanelMando as Control
@onready var _filas: GridContainer = $PanelMando/Desplazable/Centro/Filas as GridContainer
@onready var _sin_control: Label = $PanelMando/SinControl as Label
@onready var _aviso_mando: Label = $PanelMando/Aviso as Label
@onready var _por_omision: Button = $PanelMando/Botones/PorOmision as Button
@onready var _volver_mando: Button = $PanelMando/Arriba/Volver as Button
@onready var _panel_creditos: Control = $PanelCreditos as Control
@onready var _volver_creditos: Button = $PanelCreditos/Arriba/Volver as Button
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
	_menos.pressed.connect(_mover_volumen.bind(-PASO_VOLUMEN))
	_mas.pressed.connect(_mover_volumen.bind(PASO_VOLUMEN))
	_recursos.clear()
	_recursos.add_item("Recursos: auto (%s)" % ("bajo" if Recursos.es_debil() else "alto"))
	_recursos.add_item("Recursos: bajo")
	_recursos.add_item("Recursos: alto")
	_recursos.item_selected.connect(_al_elegir_recursos)
	# El alto de cada opcion de la lista lo da el tema (median ~18 px en el S50 el 12-oct-2026).
	_recursos.get_popup().popup_hide.connect(_al_cerrar_lista)
	_modo.toggled.connect(_al_cambiar_modo)
	_borrar.pressed.connect(_pedir_borrado)
	_creditos.pressed.connect(_abrir_creditos)
	_volver.pressed.connect(atras)
	_por_omision.pressed.connect(_mando_por_omision)
	_volver_mando.pressed.connect(atras)
	_volver_creditos.pressed.connect(atras)
	_si_borrar.pressed.connect(_borrar_partida)
	_no_borrar.pressed.connect(atras)
	# Un boton por accion con su boton del control adentro («Saltar: A / Cruz»); si no cabe, en dos lineas.
	for accion: StringName in Mando.REASIGNABLES:
		var boton: Button = Button.new()
		boton.custom_minimum_size = Tema.CELDA
		boton.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		boton.pressed.connect(_esperar_boton.bind(accion))
		_filas.add_child(boton)
		_botones_mando[accion] = boton
	Input.joy_connection_changed.connect(_al_cambiar_controles)
	for panel: Control in [_lista, _panel_mando, _panel_creditos]:
		Tema.ajustar(panel)
		panel.resized.connect(_acomodar_columnas)
	_acomodar_columnas()
	visible = false


## Muestra la lista con los valores actuales y pone el foco en el primer boton.
func abrir() -> void:
	_vibracion.set_pressed_no_signal(Ajustes.vibracion)
	_temblor.set_pressed_no_signal(Ajustes.temblor)
	_volumen.set_value_no_signal(roundf(Ajustes.volumen * 100.0))
	_modo.set_pressed_no_signal(Ajustes.modo_desarrollador)
	_poner_textos_interruptores()
	_recursos.select(maxi(Recursos.MODOS.find(Ajustes.recursos), 0))
	_mostrar_aviso_recursos()
	visible = true
	_mostrar(_lista)
	_volumen.grab_focus()
	# Seguir el foco bajaba la lista unos 20 px y cortaba la primera fila (vista de 1280x720, 12-oct-2026).
	_desplazable.set_deferred(&"scroll_vertical", 0)


## Columnas de una cuadricula de celdas Tema.CELDA que caben en un ancho util: 2 en la vista de 1280 (4:3 y 16:9) y 3
## desde 1440; 1 solo si el area segura recorta mucho.
static func columnas_para(ancho: float) -> int:
	return Tema.columnas(ancho, Tema.CELDA.x, Tema.SEPARACION, 1, 3)


func _acomodar_columnas() -> void:
	_opciones.columns = columnas_para(_lista.size.x)
	_filas.columns = columnas_para(_panel_mando.size.x)


# Vibracion, temblor y modo desarrollador dicen su estado con palabras, no solo con el interruptor.
func _poner_textos_interruptores() -> void:
	_vibracion.text = "Vibración: %s" % ("sí" if _vibracion.button_pressed else "no")
	_temblor.text = "Temblor: %s" % ("sí" if _temblor.button_pressed else "no")
	_modo.text = "Desarrollador: %s" % ("sí" if _modo.button_pressed else "no")


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


func _al_cambiar_vibracion(encendida: bool) -> void:
	Ajustes.vibracion = encendida
	_poner_textos_interruptores()
	_guardar()


func _al_cambiar_temblor(encendido: bool) -> void:
	Ajustes.temblor = encendido
	_poner_textos_interruptores()
	_guardar()


func _mover_volumen(cambio: float) -> void:
	_volumen.value = clampf(_volumen.value + cambio, _volumen.min_value, _volumen.max_value)


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
	_poner_textos_interruptores()
	_guardar()


func _guardar() -> void:
	var error: Error = Ajustes.guardar(ruta_ajustes)
	if error != OK:
		push_error("Configuracion: no se pudieron guardar los ajustes (error %d)" % error)


func _abrir_mando() -> void:
	_mostrar(_panel_mando)
	_aviso_mando.text = ""
	_mostrar_sin_control()
	_poner_nombres_mando()
	_botones_mando[Mando.REASIGNABLES[0]].grab_focus()
	_desplazable_mando.set_deferred(&"scroll_vertical", 0)


func _poner_nombres_mando() -> void:
	for accion: StringName in Mando.REASIGNABLES:
		_botones_mando[accion].text = "%s: %s" % [NOMBRES_ACCION.get(accion, String(accion)), Mando.nombre_de(Mando.boton_de(accion))]


## Sin control conectado, un aviso arriba de los botones; se actualiza solo al conectar o desconectar uno. Los
## botones siguen ahi (la pantalla no se mueve y el foco no se pierde).
func _mostrar_sin_control() -> void:
	_sin_control.visible = Input.get_connected_joypads().is_empty()


func _al_cambiar_controles(_dispositivo: int, _conectado: bool) -> void:
	_mostrar_sin_control()


func _esperar_boton(accion: StringName) -> void:
	esperando = accion
	_aviso_mando.text = "Presiona en el control el botón para «%s» (Atrás cancela)." % NOMBRES_ACCION.get(accion, String(accion))


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
