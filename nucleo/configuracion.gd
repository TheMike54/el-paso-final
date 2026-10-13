class_name Configuracion
extends Control
# Configuracion del menu principal y de la pausa, en orden de uso: audio (panel con el volumen general, de musica y de
# efectos, cada uno con su barra ancha y un altavoz que silencia; mientras esta abierto toca la musica de prueba y
# tiene un boton para oir un efecto), brillo (su pantalla, con la escena de la sala o una de muestra), vibracion,
# temblor, recursos (con aviso si se elige alto en un telefono debil), botones tactiles (abre el editor), botones del
# control (con aviso si no hay uno conectado), modo desarrollador (el menu muestra entonces la zona de pruebas) y
# creditos. Cada opcion es un BotonValor: su valor en una pastilla, sin interruptores (mockup del 13-oct-2026). La
# partida se borra en su ranura (Ranuras). Cada cambio se guarda al momento en los ajustes (las barras, al
# soltarlas). Volver va siempre arriba a la izquierda, y las cuadriculas toman las columnas que caben (Tema). Atras y
# pausa vuelven un nivel a la vez: del subpanel a la lista, y de la lista al menu (cerrado). Se usa con toque,
# teclado y control.

signal cerrado()
signal editor_pedido()

## Nombre en pantalla de cada accion reasignable del control.
const NOMBRES_ACCION: Dictionary[StringName, String] = {&"saltar": "Saltar", &"atacar": "Atacar", &"curar": "Curar", &"mapa": "Mapa", &"mapa_rapido": "Mapa rápido", &"inventario": "Inventario", &"pausa": "Pausa"}
## Lo que suben o bajan izquierda y derecha (teclado y control) en una barra, en %.
const PASO_TECLAS: float = 10.0
## Al quitar el silencio de una barra que se silencio arrastrandola a 0: no hay valor anterior al que volver.
const VOLUMEN_AL_QUITAR_SILENCIO: float = 50.0
## Lo que se oye en el panel de audio: la musica en su bus mientras esta abierto y un efecto al pedirlo.
const MUSICA_PRUEBA: AudioStream = preload("res://nucleo/sonidos/musica_prueba.ogg")
const EFECTO_PRUEBA: AudioStream = preload("res://nucleo/sonidos/efecto_golpe.wav")
## Pantalla de brillo: tamano de la ventana con la escena, lo tenue de la escena de fondo y el cuadro de calibracion.
const VENTANA_BRILLO: Vector2 = Vector2(576.0, 324.0)
const FONDO_TENUE: Color = Color(1.0, 1.0, 1.0, 0.3)
const CALIBRACION: float = 96.0
const COLOR_CALIBRACION: Color = Color(0.05, 0.05, 0.05, 1.0)
const TEXTO_BRILLO: String = "Ajusta el brillo hasta que el cuadro de la esquina apenas se vea."
# Deshace en la foto el rectangulo de Brillo con el que se tomo (Brillo.color_para): sin esto la escena se veria
# con el brillo aplicado dos veces. Solo se dibuja en la ventana y el fondo, no copia la pantalla.
const SHADER_FOTO: String = "shader_type canvas_item;
uniform float alfa = 0.0;
uniform float blanco = 0.0;
void fragment() {
	COLOR.rgb = (COLOR.rgb - blanco * alfa) / (1.0 - alfa);
}
"

## Archivo de los ajustes: publico para que la prueba trabaje con el suyo.
var ruta_ajustes: String = Ajustes.RUTA
## Abierta desde la pausa: sin Desarrollador (solo cambia el menu principal, que ahi no se ve) y avisando que
## Recursos vale al entrar a la siguiente sala (Prescindible, Niebla y Planta lo leen al entrar).
var en_partida: bool = false
## Foto de la sala tomada al abrir la pausa (la pone Pausa): la pantalla de brillo la muestra. Sin foto, o vacia
## (en el menu, en headless), muestra EscenaMuestra.
var foto: Image = null
## Brillo con el que se tomo la foto: la foto ya lo trae (la capa Brillo sale en ella) y se deshace al mostrarla.
var foto_brillo: float = Ajustes.BRILLO_POR_OMISION
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
# Una barra (volumen o brillo) cambio y no se ha guardado: arrastrarla escribia ajustes.json en cada paso.
var _barra_sin_guardar: bool = false
# Recursos al abrir: en la partida, el aviso de la siguiente sala sale solo si cambio.
var _recursos_al_abrir: String = ""

@onready var _lista: Control = $Lista as Control
@onready var _opciones: GridContainer = $Lista/Desplazable/Centro/Opciones as GridContainer
@onready var _desplazable: ScrollContainer = $Lista/Desplazable as ScrollContainer
@onready var _desplazable_mando: ScrollContainer = $PanelMando/Desplazable as ScrollContainer
@onready var _controles: BotonValor = $Lista/Desplazable/Centro/Opciones/Controles as BotonValor
@onready var _mando: BotonValor = $Lista/Desplazable/Centro/Opciones/Mando as BotonValor
@onready var _vibracion: BotonValor = $Lista/Desplazable/Centro/Opciones/Vibracion as BotonValor
@onready var _temblor: BotonValor = $Lista/Desplazable/Centro/Opciones/Temblor as BotonValor
@onready var _audio: BotonValor = $Lista/Desplazable/Centro/Opciones/Audio as BotonValor
@onready var _brillo: BotonValor = $Lista/Desplazable/Centro/Opciones/Brillo as BotonValor
@onready var _panel_audio: Control = $PanelAudio as Control
@onready var _filas_audio: VBoxContainer = $PanelAudio/Desplazable/Centro/Filas as VBoxContainer
@onready var _volver_audio: Button = $PanelAudio/Arriba/Volver as Button
@onready var _recursos: BotonValor = $Lista/Desplazable/Centro/Opciones/Recursos as BotonValor
@onready var _aviso_recursos: Label = $Lista/AvisoRecursos as Label
@onready var _modo: BotonValor = $Lista/Desplazable/Centro/Opciones/ModoDesarrollador as BotonValor
@onready var _creditos: BotonValor = $Lista/Desplazable/Centro/Opciones/Creditos as BotonValor
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
# Por el nombre de su fila (General, Musica, Efectos): la barra, el porcentaje, el altavoz y el valor antes de
# silenciar (para volver a el).
var _barras_audio: Dictionary[String, HSlider] = {}
var _porcentajes_audio: Dictionary[String, Label] = {}
var _altavoces: Dictionary[String, Button] = {}
var _antes_de_silenciar: Dictionary[String, float] = {}
var _musica: AudioStreamPlayer = null
var _efecto: AudioStreamPlayer = null
# Debajo del aviso de recursos, del alto de reservado_abajo.
var _hueco_abajo: Control = null
# Pantalla de brillo (se arma en codigo, _armar_brillo).
var _panel_brillo: Control = null
var _columna_brillo: VBoxContainer = null
var _barra_brillo: HSlider = null
var _porcentaje_brillo: Label = null
var _volver_brillo: Button = null
var _fondo_foto: TextureRect = null
var _fondo_muestra: EscenaMuestra = null
var _ventana_foto: TextureRect = null
var _ventana_muestra: EscenaMuestra = null


func _ready() -> void:
	Ajustes.cargar_una_vez()
	_controles.pressed.connect(editor_pedido.emit)
	_mando.pressed.connect(_abrir_mando)
	_vibracion.pressed.connect(_al_tocar_vibracion)
	_temblor.pressed.connect(_al_tocar_temblor)
	_audio.pressed.connect(_abrir_audio)
	_volver_audio.pressed.connect(atras)
	_brillo.pressed.connect(_abrir_brillo)
	_armar_audio()
	_armar_brillo()
	_recursos.estilo = BotonValor.Estilo.NEUTRO
	_recursos.pressed.connect(_al_tocar_recursos)
	_modo.pressed.connect(_al_tocar_modo)
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
	for panel: Control in [_lista, _panel_mando, _panel_audio, _panel_creditos, _columna_brillo]:
		Tema.ajustar(panel)
		panel.resized.connect(_acomodar_columnas)
	_acomodar_columnas()
	visible = false


## Muestra la lista con los valores actuales y pone el foco en el primer boton.
func abrir() -> void:
	_modo.visible = not en_partida
	_recursos_al_abrir = Ajustes.recursos
	_poner_valores()
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


# El valor de cada opcion, en su pastilla.
func _poner_valores() -> void:
	_vibracion.poner_si_no(Ajustes.vibracion)
	_temblor.poner_si_no(Ajustes.temblor)
	_modo.poner_si_no(Ajustes.modo_desarrollador)
	_recursos.valor = nombre_recursos(Ajustes.recursos, Recursos.es_debil())
	_brillo.valor = "%d %%" % roundi(Ajustes.brillo * 100.0)


## Lo que dice la pastilla de Recursos: en auto, tambien lo que la deteccion eligio.
static func nombre_recursos(modo: String, debil: bool) -> String:
	match modo:
		Recursos.BAJO:
			return "Bajo"
		Recursos.ALTO:
			return "Alto"
	return "Auto (%s)" % ("bajo" if debil else "alto")


## Si se acaba de asignar un boton (este tick o el anterior): el menu ignora entonces la accion pausa.
func acaba_de_asignar() -> bool:
	return Engine.get_physics_frames() - _tick_asignado <= 1


## Un nivel hacia atras. En la lista, cierra la Configuracion.
func atras() -> void:
	if not visible:
		return
	if not esperando.is_empty():
		esperando = &""
		_aviso_mando.text = ""
		_botones_mando[Mando.REASIGNABLES[0]].grab_focus()
	elif _panel_mando.visible:
		_mostrar(_lista)
		_mando.grab_focus()
	elif _panel_audio.visible:
		_mostrar(_lista)
		_audio.grab_focus()
	elif _panel_brillo.visible:
		_mostrar(_lista)
		_poner_valores()
		_brillo.grab_focus()
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
	_panel_brillo.visible = panel == _panel_brillo
	# Sin pantalla no se toca: nadie la oye y, con el audio de mentira, a veces deja la reproduccion viva al salir
	# («2 resources still in use at exit», 1 de cada 6 corridas del guion el 13-oct-2026).
	if _panel_audio.visible and not _musica.playing and DisplayServer.get_name() != "headless":
		_musica.play()
	elif not _panel_audio.visible:
		_musica.stop()


func _al_tocar_vibracion() -> void:
	Ajustes.vibracion = not Ajustes.vibracion
	_poner_valores()
	_guardar()


func _al_tocar_temblor() -> void:
	Ajustes.temblor = not Ajustes.temblor
	_poner_valores()
	_guardar()


func _al_tocar_modo() -> void:
	Ajustes.modo_desarrollador = not Ajustes.modo_desarrollador
	_poner_valores()
	_guardar()


# Cada toque pasa al siguiente: auto, bajo, alto y de nuevo auto.
func _al_tocar_recursos() -> void:
	var i: int = Recursos.MODOS.find(Ajustes.recursos)
	Ajustes.recursos = Recursos.MODOS[(i + 1) % Recursos.MODOS.size()]
	_poner_valores()
	_mostrar_aviso_recursos()
	_guardar()


# Las barras aplican al momento y guardan al soltarlas, con el altavoz, al cambiar de panel, al cerrar y al perder el
# foco la app (con teclado o control se mueven sin arrastre).
func _al_soltar_barra(_cambio: bool) -> void:
	_guardar_barras()


func _guardar_barras() -> void:
	if _barra_sin_guardar:
		_barra_sin_guardar = false
		_guardar()


func _notification(que: int) -> void:
	if que == NOTIFICATION_APPLICATION_FOCUS_OUT or que == NOTIFICATION_APPLICATION_PAUSED or que == NOTIFICATION_WM_CLOSE_REQUEST:
		_guardar_barras()


## Barra ancha de volumen o de brillo (variacion de Tema): salta al punto tocado y se arrastra; izquierda y derecha la
## mueven PASO_TECLAS.
static func barra_ancha(minimo: float, maximo: float) -> HSlider:
	var barra: HSlider = HSlider.new()
	barra.name = "Barra"
	barra.theme_type_variation = Tema.BARRA_ANCHA
	barra.min_value = minimo
	barra.max_value = maximo
	barra.step = 5.0
	barra.custom_minimum_size = Vector2(0.0, Tema.ALTO_TOQUE)
	barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra.gui_input.connect(_teclas_de_barra.bind(barra))
	return barra


# HSlider mueve un paso (5) con izquierda y derecha y no tiene otro paso para las teclas: se toman antes que el.
static func _teclas_de_barra(evento: InputEvent, barra: HSlider) -> void:
	var cambio: float = 0.0
	if evento.is_action_pressed(&"ui_right", true):
		cambio = PASO_TECLAS
	elif evento.is_action_pressed(&"ui_left", true):
		cambio = -PASO_TECLAS
	if cambio != 0.0:
		barra.value += cambio
		barra.accept_event()


# Las tres filas de volumen (nombre, barra, porcentaje y altavoz), el boton de probar y los reproductores.
func _armar_audio() -> void:
	var nombres: PackedStringArray = ["General", "Musica", "Efectos"]
	var textos: PackedStringArray = ["General", "Música", "Efectos"]
	for i: int in range(nombres.size()):
		_fila_volumen(nombres[i], textos[i])
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


func _fila_volumen(nombre: String, texto: String) -> void:
	var fila: HBoxContainer = HBoxContainer.new()
	fila.name = nombre
	fila.custom_minimum_size = Vector2(960.0, Tema.ALTO_TOQUE)
	fila.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	_filas_audio.add_child(fila)
	var etiqueta: Label = Label.new()
	etiqueta.name = "Nombre"
	etiqueta.text = texto
	etiqueta.custom_minimum_size.x = 200.0
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fila.add_child(etiqueta)
	var barra: HSlider = barra_ancha(0.0, 100.0)
	fila.add_child(barra)
	var porcentaje: Label = Label.new()
	porcentaje.name = "Porcentaje"
	porcentaje.custom_minimum_size.x = 110.0
	porcentaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	porcentaje.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fila.add_child(porcentaje)
	var altavoz: Button = Button.new()
	altavoz.name = "Silencio"
	altavoz.custom_minimum_size = Vector2(Tema.ALTO_TOQUE, Tema.ALTO_TOQUE)
	altavoz.draw.connect(_dibujar_altavoz.bind(altavoz, barra))
	fila.add_child(altavoz)
	_barras_audio[nombre] = barra
	_porcentajes_audio[nombre] = porcentaje
	_altavoces[nombre] = altavoz
	barra.value_changed.connect(_al_cambiar_volumen.bind(nombre))
	barra.drag_ended.connect(_al_soltar_barra)
	altavoz.pressed.connect(_silenciar.bind(nombre))


# Altavoz: cuerpo y cono; con ondas si suena y con una cruz si esta en 0.
func _dibujar_altavoz(boton: Button, barra: HSlider) -> void:
	var c: Vector2 = boton.size / 2.0
	var color: Color = Color(0.92, 0.92, 0.94)
	boton.draw_rect(Rect2(c.x - 26.0, c.y - 10.0, 14.0, 20.0), color)
	boton.draw_colored_polygon(PackedVector2Array([Vector2(c.x - 12.0, c.y - 10.0), Vector2(c.x + 4.0, c.y - 24.0), Vector2(c.x + 4.0, c.y + 24.0), Vector2(c.x - 12.0, c.y + 10.0)]), color)
	if barra.value <= 0.0:
		boton.draw_line(Vector2(c.x + 12.0, c.y - 10.0), Vector2(c.x + 28.0, c.y + 10.0), color, 5.0)
		boton.draw_line(Vector2(c.x + 12.0, c.y + 10.0), Vector2(c.x + 28.0, c.y - 10.0), color, 5.0)
	else:
		boton.draw_arc(Vector2(c.x + 4.0, c.y), 14.0, -PI / 4.0, PI / 4.0, 8, color, 4.0)
		boton.draw_arc(Vector2(c.x + 4.0, c.y), 24.0, -PI / 4.0, PI / 4.0, 8, color, 4.0)


# Silencia un volumen o lo devuelve al valor que tenia antes de silenciarlo; se guarda al momento.
func _silenciar(nombre: String) -> void:
	var barra: HSlider = _barras_audio[nombre]
	if barra.value > 0.0:
		_antes_de_silenciar[nombre] = barra.value
		barra.value = 0.0
	else:
		var antes: float = _antes_de_silenciar.get(nombre, VOLUMEN_AL_QUITAR_SILENCIO)
		barra.value = antes
	_guardar_barras()


func _abrir_audio() -> void:
	_guardar_barras()
	_barras_audio["General"].value = roundf(Ajustes.volumen * 100.0)
	_barras_audio["Musica"].value = roundf(Ajustes.volumen_musica * 100.0)
	_barras_audio["Efectos"].value = roundf(Ajustes.volumen_efectos * 100.0)
	# Poner los valores no es un cambio del jugador: no se guarda por eso.
	_barra_sin_guardar = false
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
	_porcentajes_audio[nombre].text = "%d %%" % roundi(valor)
	_altavoces[nombre].queue_redraw()
	_barra_sin_guardar = true


# La pantalla de brillo, como la de Hollow Knight: detras, la escena tenue a pantalla completa; arriba, Volver y el
# titulo; al centro, la misma escena en una ventana con el cuadro de calibracion en la esquina; abajo, el texto y la
# barra. La capa Brillo (100) tapa todo, asi que la escena se ve con el brillo elegido.
func _armar_brillo() -> void:
	_panel_brillo = Control.new()
	_panel_brillo.name = "PanelBrillo"
	_panel_brillo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel_brillo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel_brillo.visible = false
	add_child(_panel_brillo)
	var fondo: Control = Control.new()
	fondo.name = "Fondo"
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.modulate = FONDO_TENUE
	_panel_brillo.add_child(fondo)
	_fondo_muestra = EscenaMuestra.new()
	_fondo_muestra.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(_fondo_muestra)
	_fondo_foto = _foto_nueva()
	fondo.add_child(_fondo_foto)
	_columna_brillo = VBoxContainer.new()
	_columna_brillo.name = "Columna"
	_columna_brillo.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	_panel_brillo.add_child(_columna_brillo)
	var arriba: HBoxContainer = HBoxContainer.new()
	arriba.name = "Arriba"
	arriba.add_theme_constant_override(&"separation", 32)
	_columna_brillo.add_child(arriba)
	_volver_brillo = Button.new()
	_volver_brillo.name = "Volver"
	_volver_brillo.text = "Volver"
	_volver_brillo.custom_minimum_size = Vector2(240.0, Tema.ALTO_TOQUE)
	_volver_brillo.pressed.connect(atras)
	arriba.add_child(_volver_brillo)
	var titulo: Label = Label.new()
	titulo.text = "Brillo"
	titulo.add_theme_font_size_override(&"font_size", Tema.LETRA_TITULO)
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arriba.add_child(titulo)
	var centro: CenterContainer = CenterContainer.new()
	centro.size_flags_vertical = Control.SIZE_EXPAND_FILL
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_columna_brillo.add_child(centro)
	var ventana: Control = Control.new()
	ventana.name = "Ventana"
	ventana.custom_minimum_size = VENTANA_BRILLO
	ventana.clip_contents = true
	ventana.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.add_child(ventana)
	_ventana_muestra = EscenaMuestra.new()
	_ventana_muestra.set_anchors_preset(Control.PRESET_FULL_RECT)
	ventana.add_child(_ventana_muestra)
	_ventana_foto = _foto_nueva()
	ventana.add_child(_ventana_foto)
	# Cuadro de calibracion: casi negro sobre negro, en la esquina de abajo a la derecha.
	var negro: ColorRect = ColorRect.new()
	negro.name = "Calibracion"
	negro.color = Color.BLACK
	negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	negro.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	negro.offset_left = -CALIBRACION
	negro.offset_top = -CALIBRACION
	ventana.add_child(negro)
	var cuadro: ColorRect = ColorRect.new()
	cuadro.color = COLOR_CALIBRACION
	cuadro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cuadro.position = Vector2(CALIBRACION / 4.0, CALIBRACION / 4.0)
	cuadro.size = Vector2(CALIBRACION / 2.0, CALIBRACION / 2.0)
	negro.add_child(cuadro)
	var borde: Panel = Panel.new()
	var caja: StyleBoxFlat = StyleBoxFlat.new()
	caja.draw_center = false
	caja.border_color = Tema.BORDE_BOTON.lightened(0.3)
	caja.set_border_width_all(4)
	borde.add_theme_stylebox_override(&"panel", caja)
	borde.set_anchors_preset(Control.PRESET_FULL_RECT)
	borde.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ventana.add_child(borde)
	var texto: Label = Label.new()
	texto.text = TEXTO_BRILLO
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_columna_brillo.add_child(texto)
	var fila: HBoxContainer = HBoxContainer.new()
	fila.name = "Fila"
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	_columna_brillo.add_child(fila)
	_barra_brillo = barra_ancha(Ajustes.BRILLO_MINIMO * 100.0, Ajustes.BRILLO_MAXIMO * 100.0)
	_barra_brillo.size_flags_horizontal = Control.SIZE_FILL
	_barra_brillo.custom_minimum_size.x = 720.0
	fila.add_child(_barra_brillo)
	_porcentaje_brillo = Label.new()
	_porcentaje_brillo.name = "Porcentaje"
	_porcentaje_brillo.custom_minimum_size.x = 130.0
	_porcentaje_brillo.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_porcentaje_brillo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fila.add_child(_porcentaje_brillo)
	_barra_brillo.value_changed.connect(_al_cambiar_brillo)
	_barra_brillo.drag_ended.connect(_al_soltar_barra)


func _foto_nueva() -> TextureRect:
	var imagen: TextureRect = TextureRect.new()
	imagen.name = "Foto"
	imagen.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return imagen


## Suelta la foto de la sala y su textura (la pausa se cerro): en el telefono pesa unos megas de memoria de video.
func soltar_foto() -> void:
	foto = null
	for imagen: TextureRect in [_fondo_foto, _ventana_foto]:
		imagen.texture = null
		imagen.material = null


## Si la pantalla de brillo muestra la foto de la sala (y no la escena de muestra). Publico para la prueba.
func brillo_con_foto() -> bool:
	return _ventana_foto.texture != null


func _abrir_brillo() -> void:
	# La textura se arma aqui y no al abrir la pausa: casi nunca se abre esta pantalla.
	var textura: ImageTexture = null
	if foto != null and not foto.is_empty():
		textura = ImageTexture.create_from_image(foto)
	var material: ShaderMaterial = null
	if textura != null:
		var shader: Shader = Shader.new()
		shader.code = SHADER_FOTO
		material = ShaderMaterial.new()
		material.shader = shader
		var capa: Color = Brillo.color_para(foto_brillo)
		material.set_shader_parameter(&"alfa", minf(capa.a, 0.9))
		material.set_shader_parameter(&"blanco", 1.0 if capa.r > 0.5 else 0.0)
	for imagen: TextureRect in [_fondo_foto, _ventana_foto]:
		imagen.texture = textura
		imagen.material = material
	_fondo_muestra.visible = textura == null
	_ventana_muestra.visible = textura == null
	_guardar_barras()
	_barra_brillo.value = roundf(Ajustes.brillo * 100.0)
	_barra_sin_guardar = false
	_mostrar(_panel_brillo)
	_barra_brillo.grab_focus()


func _al_cambiar_brillo(valor: float) -> void:
	Ajustes.brillo = valor / 100.0
	Ajustes.aplicar_brillo()
	_porcentaje_brillo.text = "%d %%" % roundi(valor)
	_barra_sin_guardar = true


# Elegir alto en un telefono que la deteccion marca como debil se permite, con aviso.
func _mostrar_aviso_recursos() -> void:
	var textos: PackedStringArray = []
	if Recursos.avisar(Ajustes.recursos, Recursos.es_debil()):
		textos.append("Este teléfono parece de gama baja (%s): en alto puede ir lento." % Recursos.motivo())
	if en_partida and Ajustes.recursos != _recursos_al_abrir:
		textos.append("Recursos cambia al entrar a la siguiente sala.")
	_aviso_recursos.text = " ".join(textos)
	_aviso_recursos.visible = not textos.is_empty()


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
