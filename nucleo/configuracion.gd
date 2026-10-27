class_name Configuracion
extends Control
# Configuracion del menu principal y de la pausa, en orden de uso: audio (panel con el volumen general, de musica y de
# efectos, cada uno con su barra ancha y un altavoz que silencia; mientras esta abierto toca la musica de prueba y
# tiene un boton para oir un efecto), brillo (su pantalla, con la escena de la sala o una de muestra), vibracion,
# temblor, botones tactiles (abre el editor), botones del control (con aviso si no hay uno conectado), Avanzado y
# creditos. Avanzado (maqueta aprobada el 25-oct-2026) agrupa Rendimiento: recursos (con aviso si se elige alto en un
# telefono debil), FPS, luces 2D (bloqueadas en Recursos bajo), niebla y mostrar FPS; y Desarrollo: modo
# desarrollador (el menu muestra la zona de pruebas) y, con el, el panel de pruebas y ver hitbox. Los ajustes graficos
# se aplican al momento, tambien desde la pausa (Eventos.ajuste_grafico_cambiado). Cada opcion es un BotonValor: su valor en gis, con un ovalo en lo que vale, sin interruptores (mockup del 13-oct-2026). La
# partida se borra en su ranura (Ranuras). Cada cambio se guarda al momento en los ajustes (las barras, al
# soltarlas). Volver va siempre arriba a la izquierda, y las cuadriculas toman las columnas que caben (Tema). Atras y
# pausa vuelven un nivel a la vez: del subpanel a la lista, y de la lista al menu (cerrado); se ve un solo panel a la
# vez (Seccion). El panel de audio (PanelAudio) y la pantalla de brillo (PantallaBrillo) son scripts aparte; aqui
# queda guardar sus barras. Se usa con toque, teclado y control.

signal cerrado()
signal editor_pedido()

## El panel a la vista: la lista o uno de sus subpaneles.
enum Seccion {LISTA, MANDO, CREDITOS, AUDIO, BRILLO, AVANZADO}

## Nombre en pantalla de cada accion reasignable del control.
const NOMBRES_ACCION: Dictionary[StringName, String] = {&"saltar": "Saltar", &"atacar": "Atacar", &"curar": "Curar", &"mapa": "Mapa", &"mapa_rapido": "Mapa rápido", &"inventario": "Inventario", &"pausa": "Pausa"}
## Lo que suben o bajan izquierda y derecha (teclado y control) en una barra, en %.
const PASO_TECLAS: float = 10.0
## Al quitar el silencio de una barra que se silencio arrastrandola a 0: no hay valor anterior al que volver.
const VOLUMEN_AL_QUITAR_SILENCIO: float = 50.0
## Aviso al tocar Recursos abierto desde la pausa. Publico para la prueba.
const AVISO_RECURSOS_EN_PARTIDA: String = "Para cambiar los gráficos, sal al menú principal."
## Aviso al tocar Luces 2D con Recursos en bajo (bloqueadas); en la partida suma donde se cambia Recursos.
const AVISO_LUCES: String = "Luces 2D pide Recursos en alto."
const AVISO_LUCES_EN_PARTIDA: String = "Luces 2D pide Recursos en alto, y Recursos se cambia desde el menú principal."

## Archivo de los ajustes: publico para que la prueba trabaje con el suyo.
var ruta_ajustes: String = Ajustes.RUTA
## Abierta desde la pausa: avisando que Recursos queda bloqueado: Prescindible, Niebla y Planta lo leen al entrar a una sala, asi que en la partida no se
## veria el cambio; se cambia desde el menu principal, como los graficos en otros juegos.
var en_partida: bool = false
## Foto de la sala tomada al abrir la pausa (la pone Pausa): la pantalla de brillo la muestra. Sin foto, o vacia
## (en el menu, en headless), muestra EscenaMuestra.
var foto: Image = null
## Brillo con el que se tomo la foto: la foto ya lo trae (el modulado de la sala) y se deshace al mostrarla.
var foto_brillo: float = Ajustes.BRILLO_POR_OMISION
## Refresco de la pantalla en Hz (-1 si no se sabe), leido al abrir: con 90 o mas y Recursos en alto se ofrece
## elegir 120 FPS. Publico para que la prueba lo fije, porque sin pantalla no hay.
var refresco: float = -1.0
## Accion del control que espera que se presione un boton, o vacio.
var esperando: StringName = &""
## Franja de abajo que se deja libre (el aviso de pocos toques del menu), en px de la vista: sin ella, el aviso de
## recursos quedaba encima de ese (S50, 13-oct-2026).
var reservado_abajo: float = 0.0:
	set(valor):
		reservado_abajo = valor
		for hueco: Control in _huecos_abajo:
			hueco.custom_minimum_size.y = maxf(valor - Tema.MARGEN_VERTICAL, 0.0)

# Tick en que se asigno un boton: si era Start, la accion pausa quedo recien presionada en ese tick y el menu
# la tomaria como Atras (ver acaba_de_asignar).
var _tick_asignado: int = -10
# Una barra (volumen o brillo) cambio y no se ha guardado: arrastrarla escribia ajustes.json en cada paso.
var _barra_sin_guardar: bool = false
# En la partida se toco Recursos (bloqueado): el aviso dice donde se cambia.
var _recursos_bloqueado_tocado: bool = false
# Con Recursos en bajo se toco Luces 2D (bloqueadas): el aviso dice que piden alto.
var _luces_bloqueadas_tocadas: bool = false
# El panel a la vista (_mostrar).
var _actual: Seccion = Seccion.LISTA

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
@onready var _panel_audio: PanelAudio = $PanelAudio as PanelAudio
@onready var _volver_audio: Button = $PanelAudio/Arriba/Volver as Button
@onready var _avanzado: BotonValor = $Lista/Desplazable/Centro/Opciones/Avanzado as BotonValor
@onready var _panel_avanzado: Control = $PanelAvanzado as Control
@onready var _volver_avanzado: Button = $PanelAvanzado/Arriba/Volver as Button
@onready var _rendimiento: GridContainer = $PanelAvanzado/Desplazable/Centro/Grupos/Rendimiento as GridContainer
@onready var _desarrollo: GridContainer = $PanelAvanzado/Desplazable/Centro/Grupos/Desarrollo as GridContainer
@onready var _recursos: BotonValor = $PanelAvanzado/Desplazable/Centro/Grupos/Rendimiento/Recursos as BotonValor
@onready var _fps: BotonValor = $PanelAvanzado/Desplazable/Centro/Grupos/Rendimiento/Fps as BotonValor
@onready var _luces: BotonValor = $PanelAvanzado/Desplazable/Centro/Grupos/Rendimiento/Luces as BotonValor
@onready var _niebla: BotonValor = $PanelAvanzado/Desplazable/Centro/Grupos/Rendimiento/Niebla as BotonValor
@onready var _mostrar_fps: BotonValor = $PanelAvanzado/Desplazable/Centro/Grupos/Rendimiento/MostrarFps as BotonValor
@onready var _aviso_recursos: Label = $PanelAvanzado/AvisoRecursos as Label
@onready var _modo: BotonValor = $PanelAvanzado/Desplazable/Centro/Grupos/Desarrollo/ModoDesarrollador as BotonValor
@onready var _pruebas: BotonValor = $PanelAvanzado/Desplazable/Centro/Grupos/Desarrollo/Pruebas as BotonValor
@onready var _ver_hitbox: BotonValor = $PanelAvanzado/Desplazable/Centro/Grupos/Desarrollo/VerHitbox as BotonValor
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
# Al pie de la lista y de Avanzado (debajo del aviso de recursos), del alto de reservado_abajo.
var _huecos_abajo: Array[Control] = []
# Pantalla de brillo (se arma en codigo, PantallaBrillo).
var _panel_brillo: PantallaBrillo = null
# El panel de cada Seccion, en el orden del enum, y el boton de la lista que abre cada subpanel (el foco al volver).
var _paneles: Array[Control] = []
var _boton_de: Dictionary[Seccion, Button] = {}


func _ready() -> void:
	Ajustes.cargar_una_vez()
	for arriba: NodePath in [^"Lista/Arriba", ^"PanelMando/Arriba", ^"PanelAudio/Arriba", ^"PanelCreditos/Arriba", ^"PanelAvanzado/Arriba"]:
		Tema.encabezado(get_node(arriba) as Control)
	_controles.pressed.connect(editor_pedido.emit)
	_mando.pressed.connect(_abrir_mando)
	_vibracion.pressed.connect(_alternar.bind(&"vibracion"))
	_temblor.pressed.connect(_alternar.bind(&"temblor"))
	_audio.pressed.connect(_abrir_audio)
	_volver_audio.pressed.connect(atras)
	_brillo.pressed.connect(_abrir_brillo)
	_panel_audio.barra_movida.connect(_al_mover_barra)
	_panel_audio.barra_soltada.connect(_guardar_barras)
	_panel_brillo = PantallaBrillo.new()
	add_child(_panel_brillo)
	_panel_brillo.volver_pedido.connect(atras)
	_panel_brillo.barra_movida.connect(_al_mover_barra)
	_panel_brillo.barra_soltada.connect(_guardar_barras)
	_paneles = [_lista, _panel_mando, _panel_creditos, _panel_audio, _panel_brillo, _panel_avanzado]
	_boton_de = {Seccion.MANDO: _mando, Seccion.CREDITOS: _creditos, Seccion.AUDIO: _audio, Seccion.BRILLO: _brillo, Seccion.AVANZADO: _avanzado}
	_avanzado.pressed.connect(_abrir_avanzado)
	_volver_avanzado.pressed.connect(atras)
	_luces.pressed.connect(_al_tocar_luces)
	_niebla.pressed.connect(_alternar.bind(Ajustes.NIEBLA))
	_mostrar_fps.pressed.connect(_alternar.bind(Ajustes.MOSTRAR_FPS))
	_pruebas.pressed.connect(_alternar.bind(Ajustes.PANEL_PRUEBAS))
	_ver_hitbox.pressed.connect(_alternar.bind(Ajustes.VER_HITBOX))
	_recursos.estilo = BotonValor.Estilo.NEUTRO
	_recursos.pressed.connect(_al_tocar_recursos)
	_fps.estilo = BotonValor.Estilo.NEUTRO
	_fps.opciones = ["60", "120"]
	_fps.pressed.connect(_al_tocar_fps)
	# El contador, el panel de pruebas y ver hitbox dependen de el: cambian al momento, tambien desde la pausa.
	_modo.pressed.connect(_alternar.bind(Ajustes.MODO_DESARROLLADOR))
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
		# Con el control, el boton asignado dibujado como el de ese control, a la derecha del texto.
		IconoBoton.en_boton(boton, accion, true)
		_filas.add_child(boton)
		_botones_mando[accion] = boton
	Input.joy_connection_changed.connect(_al_cambiar_controles)
	for panel: Control in [_lista, _panel_avanzado]:
		var hueco: Control = Control.new()
		hueco.name = "HuecoAbajo"
		hueco.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(hueco)
		_huecos_abajo.append(hueco)
	reservado_abajo = reservado_abajo
	for panel: Control in [_lista, _panel_mando, _panel_audio, _panel_creditos, _panel_brillo.columna, _panel_avanzado]:
		Tema.ajustar(panel)
		panel.resized.connect(_acomodar_columnas)
	_acomodar_columnas()
	visible = false


## Muestra la lista con los valores actuales y pone el foco en el primer boton.
func abrir() -> void:
	_recursos.bloqueado = en_partida
	_recursos_bloqueado_tocado = false
	_luces_bloqueadas_tocadas = false
	if DisplayServer.get_name() != "headless":
		refresco = DisplayServer.screen_get_refresh_rate()
	_poner_valores()
	_mostrar_aviso_recursos()
	visible = true
	_mostrar(Seccion.LISTA)
	Tema.dar_foco(_audio)
	# Seguir el foco bajaba la lista unos 20 px y cortaba la primera fila (vista de 1280x720, 12-oct-2026).
	_desplazable.set_deferred(&"scroll_vertical", 0)


## Columnas de una cuadricula de celdas Tema.CELDA que caben en un ancho util: 2 en la vista de 1280 (4:3 y 16:9) y 3
## desde 1440; 1 solo si el area segura recorta mucho.
static func columnas_para(ancho: float) -> int:
	return Tema.columnas(ancho, Tema.CELDA.x, Tema.SEPARACION, 1, 3)


func _acomodar_columnas() -> void:
	_opciones.columns = columnas_para(_lista.size.x)
	_rendimiento.columns = columnas_para(_panel_avanzado.size.x)
	_desarrollo.columns = _rendimiento.columns
	_filas.columns = columnas_para(_panel_mando.size.x)


# El valor de cada opcion, con su ovalo.
func _poner_valores() -> void:
	_vibracion.poner_si_no(Ajustes.vibracion)
	_temblor.poner_si_no(Ajustes.temblor)
	_modo.poner_si_no(Ajustes.modo_desarrollador)
	_recursos.valor = nombre_recursos(Ajustes.recursos, Recursos.es_debil())
	# FPS solo con Recursos en alto (elegido o por la deteccion) y una pantalla rapida; si no, el juego va a 60.
	_fps.visible = Ajustes.fps_disponible(not Recursos.bajos(), refresco)
	_fps.valor = str(Ajustes.fps)
	_brillo.valor = "%d %%" % roundi(Ajustes.brillo * 100.0)
	# Luces 2D en bajo: bloqueadas y en No (lo que vale), no ocultas; el aviso sale solo al tocarlas.
	_luces.poner_si_no(Ajustes.luces_activas())
	_luces.bloqueado = Recursos.bajos()
	_niebla.poner_si_no(Ajustes.niebla)
	_mostrar_fps.poner_si_no(Ajustes.mostrar_fps)
	_pruebas.poner_si_no(Ajustes.panel_pruebas)
	_ver_hitbox.poner_si_no(Ajustes.ver_hitbox)
	_pruebas.visible = Ajustes.modo_desarrollador
	_ver_hitbox.visible = Ajustes.modo_desarrollador


## Lo que dice el valor de Recursos: en auto, tambien lo que la deteccion eligio.
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
		Tema.dar_foco(_botones_mando[Mando.REASIGNABLES[0]])
	elif _actual == Seccion.LISTA:
		_guardar_barras()
		visible = false
		cerrado.emit()
	else:
		# Del subpanel a la lista, con el foco en el boton que lo abrio; Brillo pone al dia su valor.
		var desde: Seccion = _actual
		_mostrar(Seccion.LISTA)
		if desde == Seccion.BRILLO:
			_poner_valores()
		Tema.dar_foco(_boton_de[desde])


## Vuelve a la lista con el foco en Controles: al cerrar el editor de botones.
func volver_del_editor() -> void:
	visible = true
	_mostrar(Seccion.LISTA)
	Tema.dar_foco(_controles)


# Un solo panel a la vista: el de la seccion; la musica de prueba suena solo con el de audio.
func _mostrar(seccion: Seccion) -> void:
	_guardar_barras()
	_actual = seccion
	for i: int in range(_paneles.size()):
		_paneles[i].visible = i == seccion
	_panel_audio.musica_de_prueba(seccion == Seccion.AUDIO)


# Luces 2D: con Recursos en bajo no cambian y avisan; si no, se alternan al momento.
func _al_tocar_luces() -> void:
	if Recursos.bajos():
		_luces_bloqueadas_tocadas = true
		_mostrar_aviso_recursos()
		return
	_alternar(Ajustes.LUCES_AVANZADAS)


# Cualquier ajuste de si o no (Ajustes.CLAVES_SI_NO): se alterna, se avisa por el bus (lo grafico se aplica al
# momento; el resto no tiene quien lo escuche) y se guarda.
func _alternar(clave: StringName) -> void:
	Ajustes.poner_si_no(clave, not Ajustes.si_no(clave))
	_poner_valores()
	Eventos.ajuste_grafico_cambiado.emit(clave)
	_guardar()


func _abrir_avanzado() -> void:
	_mostrar(Seccion.AVANZADO)
	Tema.dar_foco(_recursos)
	(_panel_avanzado.get_node(^"Desplazable") as ScrollContainer).set_deferred(&"scroll_vertical", 0)


# Cada toque pasa al siguiente: auto, bajo, alto y de nuevo auto.
func _al_tocar_recursos() -> void:
	if en_partida:
		_recursos_bloqueado_tocado = true
		_mostrar_aviso_recursos()
		return
	var i: int = Recursos.MODOS.find(Ajustes.recursos)
	Ajustes.recursos = Recursos.MODOS[(i + 1) % Recursos.MODOS.size()]
	_poner_valores()
	_mostrar_aviso_recursos()
	# Configuracion siempre es un menu: al volver al juego, ContadorFps pone el limite de juego.
	Ajustes.aplicar_fps(true)
	_guardar()


# Alterna 60 y 120. En un menu el limite es 60 siempre; el elegido vale al volver al juego (ContadorFps), sin recargar nada.
func _al_tocar_fps() -> void:
	Ajustes.fps = 120 if Ajustes.fps == 60 else 60
	_poner_valores()
	# Configuracion siempre es un menu: al volver al juego, ContadorFps pone el limite de juego.
	Ajustes.aplicar_fps(true)
	_guardar()


# Las barras (PanelAudio, PantallaBrillo) aplican al momento y guardan al soltarlas, con el altavoz, al cambiar de
# panel, al cerrar y al perder el foco la app (con teclado o control se mueven sin arrastre).
func _al_mover_barra() -> void:
	_barra_sin_guardar = true


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


func _abrir_audio() -> void:
	_guardar_barras()
	_panel_audio.poner_valores()
	# Poner los valores no es un cambio del jugador: no se guarda por eso.
	_barra_sin_guardar = false
	_mostrar(Seccion.AUDIO)
	Tema.dar_foco(_panel_audio.primera_barra())
	_panel_audio.desplazar_arriba()


## Suelta la foto de la sala y su textura (la pausa se cerro): en el telefono pesa unos megas de memoria de video.
func soltar_foto() -> void:
	foto = null
	_panel_brillo.soltar_foto()


## Si la pantalla de brillo muestra la foto de la sala (y no la escena de muestra). Publico para la prueba.
func brillo_con_foto() -> bool:
	return _panel_brillo.con_foto()


func _abrir_brillo() -> void:
	_panel_brillo.poner_foto(foto, foto_brillo)
	_guardar_barras()
	_panel_brillo.poner_valor()
	_barra_sin_guardar = false
	_mostrar(Seccion.BRILLO)
	Tema.dar_foco(_panel_brillo.barra)


# Elegir alto en un telefono que la deteccion marca como debil se permite, con aviso.
func _mostrar_aviso_recursos() -> void:
	var textos: PackedStringArray = []
	if Recursos.avisar(Ajustes.recursos, Recursos.es_debil()):
		textos.append("Este teléfono parece de gama baja (%s): en alto puede ir lento." % Recursos.motivo())
	if _recursos_bloqueado_tocado:
		textos.append(AVISO_RECURSOS_EN_PARTIDA)
	if _luces_bloqueadas_tocadas:
		textos.append(AVISO_LUCES_EN_PARTIDA if en_partida else AVISO_LUCES)
	_aviso_recursos.text = " ".join(textos)
	_aviso_recursos.visible = not textos.is_empty()


func _guardar() -> void:
	var error: Error = Ajustes.guardar(ruta_ajustes)
	if error != OK:
		push_error("Configuracion: no se pudieron guardar los ajustes (error %d)" % error)


func _abrir_mando() -> void:
	_mostrar(Seccion.MANDO)
	_aviso_mando.text = ""
	_mostrar_sin_control()
	_poner_nombres_mando()
	Tema.dar_foco(_botones_mando[Mando.REASIGNABLES[0]])
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
	Tema.dar_foco(_botones_mando[accion])


func _input(evento: InputEvent) -> void:
	if esperando.is_empty():
		return
	var boton: InputEventJoypadButton = evento as InputEventJoypadButton
	if boton != null and boton.pressed:
		# Se consume aqui, antes de que UltimaEntrada lo vea: se anota a mano para que el foco que pone
		# recibir_boton se dibuje (se acaba de usar el control).
		UltimaEntrada.anotar(boton)
		recibir_boton(boton.button_index)
		get_viewport().set_input_as_handled()


func _mando_por_omision() -> void:
	Mando.por_omision()
	_poner_nombres_mando()
	_guardar()


func _abrir_creditos() -> void:
	_mostrar(Seccion.CREDITOS)
	Tema.dar_foco(_volver_creditos)
