class_name Configuracion
extends Control
# Configuracion del menu principal, en orden de uso: audio (panel con el volumen general, de musica y de efectos, con
# - y +, que mientras esta abierto toca la musica de prueba y tiene un boton para oir un efecto), brillo (con - y +),
# vibracion, temblor, recursos (con aviso si
# se elige alto en un telefono debil), botones tactiles (abre el editor), botones del control (con aviso si no hay
# uno conectado), modo desarrollador (el menu muestra entonces la zona de pruebas) y creditos. La partida
# se borra en su ranura (Ranuras). Cada cambio se guarda al momento en los ajustes (las barras, al soltarlas).
# Volver va siempre arriba a la izquierda, y las cuadriculas toman las columnas que caben (Tema). Atras y pausa
# vuelven un nivel a la vez: del subpanel a la lista, y de la lista al menu (cerrado). Se usa con toque, teclado y
# control.

signal cerrado()
signal editor_pedido()

## Nombre en pantalla de cada accion reasignable del control.
const NOMBRES_ACCION: Dictionary[StringName, String] = {&"saltar": "Saltar", &"atacar": "Atacar", &"curar": "Curar", &"mapa": "Mapa", &"mapa_rapido": "Mapa rápido", &"mochila": "Mochila", &"pausa": "Pausa"}
## Lo que suben o bajan - y + de los volumenes y del brillo, en %.
const PASO_VOLUMEN: float = 10.0
## Lo que se oye en el panel de audio: la musica en su bus mientras esta abierto y un efecto al pedirlo.
const MUSICA_PRUEBA: AudioStream = preload("res://nucleo/sonidos/musica_prueba.ogg")
const EFECTO_PRUEBA: AudioStream = preload("res://nucleo/sonidos/efecto_golpe.wav")

## Archivo de los ajustes: publico para que la prueba trabaje con el suyo.
var ruta_ajustes: String = Ajustes.RUTA
## Accion del control que espera que se presione un boton, o vacio.
var esperando: StringName = &""
## Franja de abajo que se deja libre (el aviso de pocos toques del menu), en px de la vista: sin ella, el aviso de
## recursos quedaba encima de ese (S50, 13-oct-2026).
var reservado_abajo: float = 0.0:
	set(valor):
		reservado_abajo = valor
		if _hueco_abajo != null:
			_hueco_abajo.custom_minimum_size.y = maxf(valor - Tema.MARGEN_VERTICAL, 0.0)

# Tick en que se asigno un boton: si era Start, la accion pausa quedo recien presionada en ese tick y el menu
# la tomaria como Atras (ver acaba_de_asignar).
var _tick_asignado: int = -10
# Tick en que se cerro la lista de Recursos: en Android, Atras cierra la lista y despues llega como Atras del
# menu; sin esto subia un nivel de mas (S50, 12-oct-2026).
var _tick_lista_cerrada: int = -10
# Una barra (volumen o brillo) cambio y no se ha guardado: arrastrarla escribia ajustes.json en cada paso.
var _barra_sin_guardar: bool = false

@onready var _lista: Control = $Lista as Control
@onready var _opciones: GridContainer = $Lista/Desplazable/Centro/Opciones as GridContainer
@onready var _desplazable: ScrollContainer = $Lista/Desplazable as ScrollContainer
@onready var _desplazable_mando: ScrollContainer = $PanelMando/Desplazable as ScrollContainer
@onready var _controles: Button = $Lista/Desplazable/Centro/Opciones/Controles as Button
@onready var _mando: Button = $Lista/Desplazable/Centro/Opciones/Mando as Button
@onready var _vibracion: CheckButton = $Lista/Desplazable/Centro/Opciones/Vibracion as CheckButton
@onready var _temblor: CheckButton = $Lista/Desplazable/Centro/Opciones/Temblor as CheckButton
@onready var _audio: Button = $Lista/Desplazable/Centro/Opciones/Audio as Button
@onready var _brillo: HSlider = $Lista/Desplazable/Centro/Opciones/Brillo/Medio/Barra as HSlider
@onready var _menos_brillo: Button = $Lista/Desplazable/Centro/Opciones/Brillo/Menos as Button
@onready var _mas_brillo: Button = $Lista/Desplazable/Centro/Opciones/Brillo/Mas as Button
@onready var _panel_audio: Control = $PanelAudio as Control
@onready var _filas_audio: VBoxContainer = $PanelAudio/Desplazable/Centro/Filas as VBoxContainer
@onready var _volver_audio: Button = $PanelAudio/Arriba/Volver as Button
@onready var _recursos: OptionButton = $Lista/Desplazable/Centro/Opciones/Recursos as OptionButton
@onready var _aviso_recursos: Label = $Lista/AvisoRecursos as Label
@onready var _modo: CheckButton = $Lista/Desplazable/Centro/Opciones/ModoDesarrollador as CheckButton
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

var _botones_mando: Dictionary[StringName, Button] = {}
# Barra de cada volumen del panel de audio, por el nombre de su fila (General, Musica, Efectos).
var _barras_audio: Dictionary[String, HSlider] = {}
var _musica: AudioStreamPlayer = null
var _efecto: AudioStreamPlayer = null
# Debajo del aviso de recursos, del alto de reservado_abajo.
var _hueco_abajo: Control = null


func _ready() -> void:
	Ajustes.cargar_una_vez()
	_controles.pressed.connect(editor_pedido.emit)
	_mando.pressed.connect(_abrir_mando)
	_vibracion.toggled.connect(_al_cambiar_vibracion)
	_temblor.toggled.connect(_al_cambiar_temblor)
	_audio.pressed.connect(_abrir_audio)
	_volver_audio.pressed.connect(atras)
	_brillo.value_changed.connect(_al_cambiar_brillo)
	_brillo.drag_ended.connect(_al_soltar_barra)
	_menos_brillo.pressed.connect(_mover.bind(_brillo, -PASO_VOLUMEN))
	_mas_brillo.pressed.connect(_mover.bind(_brillo, PASO_VOLUMEN))
	_armar_audio()
	_recursos.clear()
	_recursos.add_item("Recursos: auto (%s)" % ("bajo" if Recursos.es_debil() else "alto"))
	_recursos.add_item("Recursos: bajo")
	_recursos.add_item("Recursos: alto")
	_recursos.item_selected.connect(_al_elegir_recursos)
	# El alto de cada opcion de la lista lo da el tema (median ~18 px en el S50 el 12-oct-2026).
	_recursos.get_popup().popup_hide.connect(_al_cerrar_lista)
	_modo.toggled.connect(_al_cambiar_modo)
	_creditos.pressed.connect(_abrir_creditos)
	_volver.pressed.connect(atras)
	_por_omision.pressed.connect(_mando_por_omision)
	_volver_mando.pressed.connect(atras)
	_volver_creditos.pressed.connect(atras)
	# Un boton por accion con su boton del control adentro («Saltar: A / Cruz»); si no cabe, en dos lineas.
	for accion: StringName in Mando.REASIGNABLES:
		var boton: Button = Button.new()
		boton.custom_minimum_size = Tema.CELDA
		boton.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		boton.pressed.connect(_esperar_boton.bind(accion))
		_filas.add_child(boton)
		_botones_mando[accion] = boton
	Input.joy_connection_changed.connect(_al_cambiar_controles)
	_hueco_abajo = Control.new()
	_hueco_abajo.name = "HuecoAbajo"
	_hueco_abajo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lista.add_child(_hueco_abajo)
	reservado_abajo = reservado_abajo
	for panel: Control in [_lista, _panel_mando, _panel_audio, _panel_creditos]:
		Tema.ajustar(panel)
		panel.resized.connect(_acomodar_columnas)
	_acomodar_columnas()
	visible = false


## Muestra la lista con los valores actuales y pone el foco en el primer boton.
func abrir() -> void:
	_vibracion.set_pressed_no_signal(Ajustes.vibracion)
	_temblor.set_pressed_no_signal(Ajustes.temblor)
	_brillo.set_value_no_signal(roundf(Ajustes.brillo * 100.0))
	_modo.set_pressed_no_signal(Ajustes.modo_desarrollador)
	_poner_textos_interruptores()
	_recursos.select(maxi(Recursos.MODOS.find(Ajustes.recursos), 0))
	_mostrar_aviso_recursos()
	visible = true
	_mostrar(_lista)
	_audio.grab_focus()
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
	elif not esperando.is_empty():
		esperando = &""
		_aviso_mando.text = ""
		_botones_mando[Mando.REASIGNABLES[0]].grab_focus()
	elif _panel_mando.visible:
		_mostrar(_lista)
		_mando.grab_focus()
	elif _panel_audio.visible:
		_mostrar(_lista)
		_audio.grab_focus()
	elif _panel_creditos.visible:
		_mostrar(_lista)
		_creditos.grab_focus()
	else:
		_guardar_barras()
		visible = false
		cerrado.emit()


## Vuelve a la lista con el foco en Controles: al cerrar el editor de botones.
func volver_del_editor() -> void:
	visible = true
	_mostrar(_lista)
	_controles.grab_focus()


func _mostrar(panel: Control) -> void:
	_guardar_barras()
	_lista.visible = panel == _lista
	_panel_mando.visible = panel == _panel_mando
	_panel_creditos.visible = panel == _panel_creditos
	_panel_audio.visible = panel == _panel_audio
	# Sin pantalla no se toca: nadie la oye y, con el audio de mentira, a veces deja la reproduccion viva al salir
	# («2 resources still in use at exit», 1 de cada 6 corridas del guion el 13-oct-2026).
	if _panel_audio.visible and not _musica.playing and DisplayServer.get_name() != "headless":
		_musica.play()
	elif not _panel_audio.visible:
		_musica.stop()


func _al_cambiar_vibracion(encendida: bool) -> void:
	Ajustes.vibracion = encendida
	_poner_textos_interruptores()
	_guardar()


func _al_cambiar_temblor(encendido: bool) -> void:
	Ajustes.temblor = encendido
	_poner_textos_interruptores()
	_guardar()


func _mover(barra: HSlider, cambio: float) -> void:
	barra.value = clampf(barra.value + cambio, barra.min_value, barra.max_value)
	_guardar_barras()


# Las barras aplican al momento y guardan al soltarlas, con - y +, al cambiar de panel, al cerrar y al perder el foco
# la app (con teclado o control se mueven sin arrastre).
func _al_soltar_barra(_cambio: bool) -> void:
	_guardar_barras()


func _guardar_barras() -> void:
	if _barra_sin_guardar:
		_barra_sin_guardar = false
		_guardar()


func _notification(que: int) -> void:
	if que == NOTIFICATION_APPLICATION_FOCUS_OUT or que == NOTIFICATION_APPLICATION_PAUSED or que == NOTIFICATION_WM_CLOSE_REQUEST:
		_guardar_barras()


func _al_cambiar_brillo(valor: float) -> void:
	Ajustes.brillo = valor / 100.0
	Ajustes.aplicar_brillo()
	_barra_sin_guardar = true


# Las tres filas de volumen (como la de brillo: -, nombre y barra, +), el boton de probar y los reproductores.
func _armar_audio() -> void:
	var nombres: PackedStringArray = ["General", "Musica", "Efectos"]
	var textos: PackedStringArray = ["General", "Música", "Efectos"]
	for i: int in range(nombres.size()):
		_barras_audio[nombres[i]] = _fila_volumen(nombres[i], textos[i])
	var probar: Button = Button.new()
	probar.name = "Probar"
	probar.text = "Probar efecto"
	probar.custom_minimum_size = Tema.CELDA
	probar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_filas_audio.add_child(probar)
	_musica = AudioStreamPlayer.new()
	_musica.stream = MUSICA_PRUEBA
	_musica.bus = Ajustes.BUS_MUSICA
	add_child(_musica)
	_efecto = AudioStreamPlayer.new()
	_efecto.stream = EFECTO_PRUEBA
	_efecto.bus = Ajustes.BUS_EFECTOS
	add_child(_efecto)
	probar.pressed.connect(_efecto.play)
	# La musica de prueba vuelve a empezar al terminar, mientras el panel siga abierto.
	_musica.finished.connect(_musica.play)


func _fila_volumen(nombre: String, texto: String) -> HSlider:
	var fila: HBoxContainer = HBoxContainer.new()
	fila.name = nombre
	fila.custom_minimum_size = Vector2(600.0, Tema.ALTO_TOQUE)
	fila.add_theme_constant_override(&"separation", 8)
	_filas_audio.add_child(fila)
	var menos: Button = Button.new()
	menos.name = "Menos"
	menos.text = "−"
	menos.custom_minimum_size = Vector2(Tema.ALTO_TOQUE, Tema.ALTO_TOQUE)
	fila.add_child(menos)
	var medio: VBoxContainer = VBoxContainer.new()
	medio.name = "Medio"
	medio.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	medio.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_child(medio)
	var etiqueta: Label = Label.new()
	etiqueta.text = texto
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	medio.add_child(etiqueta)
	var barra: HSlider = HSlider.new()
	barra.name = "Barra"
	barra.custom_minimum_size = Vector2(0.0, 40.0)
	barra.step = 5.0
	medio.add_child(barra)
	var mas: Button = Button.new()
	mas.name = "Mas"
	mas.text = "+"
	mas.custom_minimum_size = Vector2(Tema.ALTO_TOQUE, Tema.ALTO_TOQUE)
	fila.add_child(mas)
	barra.value_changed.connect(_al_cambiar_volumen.bind(nombre))
	barra.drag_ended.connect(_al_soltar_barra)
	menos.pressed.connect(_mover.bind(barra, -PASO_VOLUMEN))
	mas.pressed.connect(_mover.bind(barra, PASO_VOLUMEN))
	return barra


func _abrir_audio() -> void:
	_barras_audio["General"].set_value_no_signal(roundf(Ajustes.volumen * 100.0))
	_barras_audio["Musica"].set_value_no_signal(roundf(Ajustes.volumen_musica * 100.0))
	_barras_audio["Efectos"].set_value_no_signal(roundf(Ajustes.volumen_efectos * 100.0))
	_mostrar(_panel_audio)
	_barras_audio["General"].grab_focus()
	_desplazable_audio().set_deferred(&"scroll_vertical", 0)


func _desplazable_audio() -> ScrollContainer:
	return $PanelAudio/Desplazable as ScrollContainer


func _al_cambiar_volumen(valor: float, nombre: String) -> void:
	match nombre:
		"General":
			Ajustes.volumen = valor / 100.0
		"Musica":
			Ajustes.volumen_musica = valor / 100.0
		"Efectos":
			Ajustes.volumen_efectos = valor / 100.0
	Ajustes.aplicar_volumen()
	_barra_sin_guardar = true


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
