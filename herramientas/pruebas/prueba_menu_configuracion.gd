extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de la Configuracion del menu principal: recorre menu, Configuracion, sus subpaneles y el editor de controles
# con Atras y con pausa, un nivel a la vez, y lo que puede romperse en cada panel: disposicion, botones del control,
# modo desarrollador, audio, opciones de si o no, Recursos, brillo, columnas y el aviso de pocos toques. Todo en
# archivos de prueba. Deja casos y fallos para menu_configuracion.guion.

const ESCENA_MENU: PackedScene = preload("res://nucleo/menu.tscn")
const RUTA_PRUEBA: String = "user://prueba_menu_configuracion.json"
const OPCIONES: String = "Lista/Desplazable/Centro/Opciones/"


# Atras es la notificacion de Android. Lo que puede romperse: Listo guarda la disposicion, reasignar un boton del
# control intercambia con la accion que lo tenia y se guarda, el modo desarrollador muestra la zona de pruebas en el
# menu y se recuerda, el panel de audio guarda cada volumen en su ajuste y su bus (barra, teclas y altavoz), las
# opciones de si o no y Recursos cambian con un toque (Recursos, en la partida, queda bloqueado y avisa), la pantalla
# de brillo guarda al soltar y muestra la foto o la escena de muestra, las columnas siguen el ancho de la vista y el
# aviso de pocos toques sale solo cuando toca.
func _ready() -> void:
	# Primero la carga del archivo real: si llegara despues, dentro del editor, pisaria la disposicion por omision.
	Ajustes.cargar_una_vez()
	Ajustes.disposicion = DisposicionControles.por_omision()
	# Arranque ya aplico los botones del control del archivo real: la prueba parte de los de project.godot y al
	# final devuelve los reales.
	var mando_real: Dictionary = Mando.a_diccionario()
	Mando.por_omision()
	var modo_real: bool = Ajustes.modo_desarrollador
	var volumen_real: float = Ajustes.volumen
	var musica_real: float = Ajustes.volumen_musica
	var efectos_real: float = Ajustes.volumen_efectos
	var brillo_real: float = Ajustes.brillo
	Ajustes.modo_desarrollador = false
	var menu: Control = ESCENA_MENU.instantiate() as Control
	add_child(menu)
	var centro: Control = menu.get_node(^"Centro") as Control
	var config: Configuracion = menu.get_node(^"Configuracion") as Configuracion
	config.ruta_ajustes = RUTA_PRUEBA
	var lista: Control = config.get_node(^"Lista") as Control
	var confirmar: Control = menu.get_node(^"Confirmar") as Control
	_caso("al entrar, Configuracion esta oculta", centro.visible and not config.visible)

	(menu.get_node(^"Centro/Opciones/Configuracion") as Button).pressed.emit()
	_caso("Configuracion abre su lista en lugar del menu", config.visible and lista.visible and not centro.visible)
	# Si lo ultimo que se uso no fue un control ni el teclado (UltimaEntrada), el foco esta en Audio pero no se dibuja;
	# la primera flecha lo muestra.
	var audio: Button = _boton(config, "Audio")
	_caso("tras el dedo, el foco existe y no se dibuja", audio.has_focus() and not audio.has_focus(true))
	_tecla(&"ui_down")
	var con_foco: Control = get_viewport().gui_get_focus_owner()
	_caso("la primera flecha dibuja el foco", con_foco != null and con_foco.has_focus(true))
	# Lo ultimo que se uso decide: tras un boton del control el foco se dibuja aunque antes se tocara con el dedo.
	var boton_control: InputEventJoypadButton = InputEventJoypadButton.new()
	boton_control.pressed = true
	UltimaEntrada.anotar(boton_control)
	Tema.dar_foco(audio)
	_caso("tras usar el control, el menu dibuja el foco", audio.has_focus(true))
	var toque: InputEventScreenTouch = InputEventScreenTouch.new()
	toque.pressed = true
	UltimaEntrada.anotar(toque)
	Tema.dar_foco(audio)
	_caso("tras tocar con el dedo, aunque haya control, el foco no se dibuja", audio.has_focus() and not audio.has_focus(true))
	# El boton del control junto a Volver: se ve tras usar el control y se quita tras un toque (con su hueco).
	var volver_lista: Button = config.get_node(^"Lista/Arriba/Volver") as Button
	var icono_volver: IconoBoton = volver_lista.get_node(^"Icono") as IconoBoton
	UltimaEntrada.anotar(boton_control)
	await get_tree().process_frame
	await get_tree().process_frame
	_caso("con el control, Volver muestra el boton de volver y le hace lugar", icono_volver.visible and volver_lista.icon != null)
	UltimaEntrada.anotar(toque)
	await get_tree().process_frame
	await get_tree().process_frame
	_caso("tras un toque, Volver queda solo con su texto", not icono_volver.visible and volver_lista.icon == null)
	var stick: InputEventJoypadMotion = InputEventJoypadMotion.new()
	stick.axis_value = 0.2
	UltimaEntrada.anotar(stick)
	_caso("un stick apenas movido no cuenta como usar el control", not UltimaEntrada.con_control())
	# En Android el touchpad del DUALSHOCK 4 llega como clic de raton real: no apaga el foco. El que Godot emula
	# desde el dedo (DEVICE_ID_EMULATION) y cualquier clic fuera de Android, si.
	UltimaEntrada.anotar(boton_control)
	var clic: InputEventMouseButton = InputEventMouseButton.new()
	clic.pressed = true
	UltimaEntrada.anotar(clic, true)
	var touchpad_no_apaga: bool = UltimaEntrada.con_control()
	clic.device = InputEvent.DEVICE_ID_EMULATION
	UltimaEntrada.anotar(clic, true)
	_caso("en Android el clic del touchpad no apaga el foco y el emulado desde el dedo si", touchpad_no_apaga and not UltimaEntrada.con_control())
	UltimaEntrada.anotar(boton_control)
	UltimaEntrada.anotar(toque, true)
	_caso("en Android un toque con el dedo apaga el foco", not UltimaEntrada.con_control())
	UltimaEntrada.anotar(boton_control)
	clic.device = 0
	UltimaEntrada.anotar(clic, false)
	_caso("fuera de Android un clic de raton apaga el foco", not UltimaEntrada.con_control())
	var zona: Button = menu.get_node(^"Centro/Opciones/ZonaPruebas") as Button
	_caso("sin el modo desarrollador el menu no muestra la zona de pruebas", not zona.visible)
	_boton(config, "Controles").pressed.emit()
	var editor: EditorControles = menu.get("editor") as EditorControles
	_caso("Botones tactiles abre el editor", editor != null and ControlesTactiles.editando and not config.visible)

	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await get_tree().process_frame
	_caso("Atras con el editor abierto lo cancela y vuelve a Configuracion", menu.get("editor") == null and config.visible and not ControlesTactiles.editando)
	_caso("y no pide salir", not confirmar.visible)

	_boton(config, "Controles").pressed.emit()
	Input.action_press(&"pausa")
	await _esperar(2)
	Input.action_release(&"pausa")
	await get_tree().process_frame
	_caso("la accion pausa con el editor abierto tambien vuelve a Configuracion", menu.get("editor") == null and config.visible)
	_caso("y tampoco pide salir", not confirmar.visible)

	_boton(config, "Controles").pressed.emit()
	editor = menu.get("editor") as EditorControles
	editor.ruta_ajustes = RUTA_PRUEBA
	editor.copia.colocar(0, editor.size / 2.0, editor.size, Rect2(Vector2.ZERO, editor.size), 0.0)
	editor.listo()
	await get_tree().process_frame
	_caso("Listo desde el menu deja la disposicion nueva en Ajustes", not Ajustes.disposicion.igual_a(DisposicionControles.por_omision()))
	_caso("y vuelve a Configuracion", config.visible and menu.get("editor") == null)

	# Botones del control: reasignar intercambia con la accion que tenia el boton.
	_boton(config, "Mando").pressed.emit()
	var panel_mando: Control = config.get_node(^"PanelMando") as Control
	_caso("Botones del control abre su panel", panel_mando.visible and not lista.visible)
	# Sin control (la PC del guion y el CI) el aviso debe verse; con uno conectado, no. Nace oculto en la escena.
	_caso("sin control conectado el panel lo avisa", (config.get_node(^"PanelMando/SinControl") as Label).visible == Input.get_connected_joypads().is_empty())
	# Se pone el aviso al reves antes de avisar: solo vuelve si el panel escucha joy_connection_changed.
	var sin_control: Label = config.get_node(^"PanelMando/SinControl") as Label
	sin_control.visible = not Input.get_connected_joypads().is_empty()
	Input.joy_connection_changed.emit(0, false)
	_caso("el aviso del control se recalcula al conectar o desconectar uno", (config.get_node(^"PanelMando/SinControl") as Label).visible == Input.get_connected_joypads().is_empty())
	var saltar: int = Mando.boton_de(&"saltar")
	var atacar: int = Mando.boton_de(&"atacar")
	await _usar(true)
	var dibujo_atacar: Dictionary = IconoBoton.dibujo(&"atacar", UltimaEntrada.dispositivo)
	_tocar_fila(panel_mando, &"saltar")
	config.recibir_boton(atacar)
	_caso("dar a saltar el boton de atacar los intercambia", Mando.boton_de(&"saltar") == atacar and Mando.boton_de(&"atacar") == saltar)
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("el cambio se guarda y se vuelve a leer", Mando.boton_de(&"saltar") == atacar and Mando.boton_de(&"atacar") == saltar)
	_caso("justo despues de asignar, el menu ignora la accion pausa (el Start con que se asigno)", config.acaba_de_asignar())
	await _usar(true)
	var icono_saltar: IconoBoton = null
	for icono: IconoBoton in _iconos(panel_mando):
		if icono.accion == &"saltar":
			icono_saltar = icono
	_caso("la fila de Saltar dibuja ya el boton que tenia Atacar", icono_saltar != null and icono_saltar.visible and not dibujo_atacar.is_empty() and icono_saltar.dibujo_actual == dibujo_atacar)
	await _usar(false)
	_caso("tras un toque la fila de Saltar no dibuja boton", icono_saltar != null and not icono_saltar.visible)
	_tocar_fila(panel_mando, &"saltar")
	config.recibir_boton(Mando.boton_de(&"saltar"))
	Input.action_press(&"pausa")
	await _esperar(2)
	Input.action_release(&"pausa")
	_caso("y el panel del control sigue abierto tras ese Start", panel_mando.visible and config.visible)
	# B tambien es volver: el B con que se asigna un boton no vuelve un nivel.
	_tocar_fila(panel_mando, &"curar")
	config.recibir_boton(Mando.boton_de(&"curar"))
	Input.action_press(&"volver")
	await _esperar(2)
	Input.action_release(&"volver")
	_caso("y tampoco tras el B (volver) con que se asigna", panel_mando.visible and config.visible)
	Mando.asignar(&"saltar", 999)
	_caso("un boton fuera de rango no se asigna", Mando.boton_de(&"saltar") == atacar)
	_caso("impulso e interactuar (ejes) no se reasignan", not Mando.REASIGNABLES.has(&"impulso") and not Mando.REASIGNABLES.has(&"interactuar"))
	Mando.aplicar({"saltar": float(Mando.boton_de(&"curar")), "atacar": 999.0, "curar": "x"})
	# saltar pide el boton de curar: curar recibe el de saltar; atacar fuera de rango y curar no numerico se ignoran.
	_caso("aplicar un archivo con un boton repetido intercambia y descarta lo invalido", Mando.boton_de(&"curar") == saltar and Mando.boton_de(&"atacar") == atacar and Mando.boton_de(&"saltar") != saltar)
	Mando.aplicar({"mochila": float(saltar)})
	_caso("unos ajustes viejos con el boton de mochila se lo dan a inventario", Mando.boton_de(&"inventario") == saltar and not InputMap.has_action(&"mochila"))
	_tocar_fila(panel_mando, &"curar")
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras mientras espera un boton cancela la espera y sigue en el panel", config.esperando.is_empty() and panel_mando.visible)
	(config.get_node(^"PanelMando/Botones/PorOmision") as Button).pressed.emit()
	_caso("Por omision devuelve los botones de project.godot", Mando.boton_de(&"saltar") == saltar and Mando.boton_de(&"atacar") == atacar)
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en el panel del control vuelve a la lista", lista.visible and not panel_mando.visible)
	_boton(config, "Mando").pressed.emit()
	Input.action_press(&"volver")
	await _esperar(2)
	Input.action_release(&"volver")
	_caso("B (volver) en el panel del control vuelve a la lista, como Atras", lista.visible and not panel_mando.visible)

	# Modo desarrollador: al volver al menu, este muestra la zona de pruebas; se recuerda.
	var modo: BotonValor = config.get_node(NodePath(OPCIONES + "ModoDesarrollador")) as BotonValor
	_caso("las opciones de si o no son botones con pastilla, sin interruptor", modo != null and not modo.toggle_mode and modo.valor == "No" and modo.estilo == BotonValor.Estilo.NO)
	modo.pressed.emit()
	_caso("tocar el boton cambia el valor y la pastilla queda en Si", Ajustes.modo_desarrollador and modo.valor == "Sí" and modo.estilo == BotonValor.Estilo.SI)
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("con el modo desarrollador el menu muestra la zona de pruebas", zona.visible and centro.visible)
	(menu.get_node(^"Centro/Opciones/Configuracion") as Button).pressed.emit()
	Ajustes.modo_desarrollador = false
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("el modo desarrollador se recuerda", Ajustes.modo_desarrollador)

	# Vibracion y temblor.
	var vibracion_real: bool = Ajustes.vibracion
	var temblor_real: bool = Ajustes.temblor
	# Se lee el archivo tras cada toque: el segundo guarda todos los ajustes y taparia que el primero no guardo.
	_boton(config, "Vibracion").pressed.emit()
	Ajustes.vibracion = vibracion_real
	Ajustes.cargar(RUTA_PRUEBA)
	var vibracion_guardada: bool = Ajustes.vibracion != vibracion_real
	_boton(config, "Temblor").pressed.emit()
	Ajustes.temblor = temblor_real
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("vibracion y temblor se guardan al tocarlos", vibracion_guardada and Ajustes.temblor != temblor_real)
	Ajustes.vibracion = vibracion_real
	Ajustes.temblor = temblor_real

	# Recursos: cada toque pasa al siguiente y se guarda.
	var recursos_real: String = Ajustes.recursos
	var recursos: BotonValor = _boton(config, "Recursos") as BotonValor
	Ajustes.recursos = Recursos.AUTO
	var vistos: PackedStringArray = []
	for i: int in range(3):
		recursos.pressed.emit()
		Ajustes.recursos = ""
		Ajustes.cargar(RUTA_PRUEBA)
		vistos.append(Ajustes.recursos)
	_caso("cada toque de Recursos pasa al siguiente y se guarda: bajo, alto y auto", vistos == PackedStringArray([Recursos.BAJO, Recursos.ALTO, Recursos.AUTO]))
	_caso("en auto la pastilla dice lo que se eligio", Configuracion.nombre_recursos(Recursos.AUTO, true) == "Auto (bajo)" and Configuracion.nombre_recursos(Recursos.ALTO, true) == "Alto")
	var aviso_de_recursos: Label = config.get_node(^"Lista/AvisoRecursos") as Label
	_caso("desde el menu Recursos no esta bloqueado ni avisa", not recursos.bloqueado and not aviso_de_recursos.text.contains(Configuracion.AVISO_RECURSOS_EN_PARTIDA))
	config.en_partida = true
	config.abrir()
	_caso("en la partida Recursos se ve bloqueado y sin aviso hasta tocarlo", recursos.bloqueado and recursos.modulate.a < 1.0 and not aviso_de_recursos.text.contains(Configuracion.AVISO_RECURSOS_EN_PARTIDA))
	var recursos_antes: String = Ajustes.recursos
	recursos.pressed.emit()
	_caso("en la partida, tocar Recursos no lo cambia y dice que se cambia desde el menu", Ajustes.recursos == recursos_antes and aviso_de_recursos.visible and aviso_de_recursos.text.contains(Configuracion.AVISO_RECURSOS_EN_PARTIDA))
	_caso("en la partida no aparece Desarrollador", not modo.visible)
	config.en_partida = false
	config.abrir()
	# FPS: solo con Recursos en alto y pantalla rapida; el refresco se fija aqui porque sin pantalla no hay.
	var fps_real: int = Ajustes.fps
	var fps: BotonValor = _boton(config, "Fps") as BotonValor
	Ajustes.recursos = Recursos.ALTO
	Ajustes.fps = 60
	config.refresco = 60.0
	config.abrir()
	_caso("con pantalla de 60 Hz no se ofrece FPS", not fps.visible)
	config.refresco = 120.0
	config.abrir()
	_caso("con 120 Hz y Recursos en alto se ofrece FPS, en 60", fps.visible and fps.valor == "60")
	fps.pressed.emit()
	Ajustes.fps = 60
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("tocar FPS pasa a 120 y se guarda", Ajustes.fps == 120)
	config.en_partida = true
	config.abrir()
	fps.pressed.emit()
	_caso("desde la pausa FPS no esta bloqueado y tocarlo lo cambia", fps.visible and not fps.bloqueado and Ajustes.fps == 60)
	config.en_partida = false
	Ajustes.recursos = Recursos.BAJO
	config.abrir()
	_caso("con Recursos en bajo no se ofrece FPS", not fps.visible)
	Ajustes.fps = fps_real
	config.refresco = -1.0
	config.abrir()
	Ajustes.recursos = recursos_real
	await _esperar(3)

	# Audio: un panel con tres barras anchas, cada una en su ajuste y en su bus, con altavoz.
	_boton(config, "Audio").pressed.emit()
	var panel_audio: Control = config.get_node(^"PanelAudio") as Control
	var general: HSlider = _barra_audio(config, "General")
	_caso("Audio abre su panel con el foco en General", panel_audio.visible and not lista.visible and general.has_focus())
	_caso("las barras son anchas, sin - ni +", general.theme_type_variation == Tema.BARRA_ANCHA and config.get_node_or_null(^"PanelAudio/Desplazable/Centro/Filas/General/Mas") == null)
	var antes: String = FileAccess.get_file_as_string(RUTA_PRUEBA)
	general.value = 40.0
	_barra_audio(config, "Musica").value = 30.0
	_barra_audio(config, "Efectos").value = 70.0
	_caso("mover una barra aplica pero no escribe el archivo hasta soltarla", is_equal_approx(Ajustes.volumen, 0.4) and FileAccess.get_file_as_string(RUTA_PRUEBA) == antes)
	_caso("el porcentaje sigue a la barra", (config.get_node(^"PanelAudio/Desplazable/Centro/Filas/General/Porcentaje") as Label).text == "40 %")
	# Salir desde el menu avisa el cierre a todo el arbol (Menu.salir): la barra sin soltar se guarda.
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	_caso("el aviso de cierre guarda las barras que no se soltaron", FileAccess.get_file_as_string(RUTA_PRUEBA) != antes)
	general.drag_ended.emit(true)
	Ajustes.volumen = 1.0
	Ajustes.volumen_musica = 1.0
	Ajustes.volumen_efectos = 1.0
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("cada volumen se guarda en su ajuste", is_equal_approx(Ajustes.volumen, 0.4) and is_equal_approx(Ajustes.volumen_musica, 0.3) and is_equal_approx(Ajustes.volumen_efectos, 0.7))
	general.grab_focus()
	_tecla(&"ui_right")
	_tecla(&"ui_right")
	_tecla(&"ui_left")
	_caso("con teclado o control, izquierda y derecha mueven la barra de 10 en 10", is_equal_approx(general.value, 50.0))
	general.value = 40.0
	var altavoz: Button = config.get_node(^"PanelAudio/Desplazable/Centro/Filas/Musica/Silencio") as Button
	altavoz.pressed.emit()
	Ajustes.volumen_musica = 1.0
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("el altavoz silencia y lo guarda", is_equal_approx(Ajustes.volumen_musica, 0.0) and is_equal_approx(_barra_audio(config, "Musica").value, 0.0))
	altavoz.pressed.emit()
	Ajustes.volumen_musica = 1.0
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("otro toque vuelve al volumen de antes y lo guarda", is_equal_approx(Ajustes.volumen_musica, 0.3))
	var bus_musica: int = AudioServer.get_bus_index(Ajustes.BUS_MUSICA)
	var bus_efectos: int = AudioServer.get_bus_index(Ajustes.BUS_EFECTOS)
	_caso("los buses de musica y efectos existen y pasan por Master", bus_musica > 0 and bus_efectos > 0 and AudioServer.get_bus_send(bus_musica) == &"Master" and AudioServer.get_bus_send(bus_efectos) == &"Master")
	_caso("cada volumen va a su bus", is_equal_approx(AudioServer.get_bus_volume_db(0), Ajustes.db_de(0.4)) and is_equal_approx(AudioServer.get_bus_volume_db(bus_musica), Ajustes.db_de(0.3)) and is_equal_approx(AudioServer.get_bus_volume_db(bus_efectos), Ajustes.db_de(0.7)))
	_barra_audio(config, "Efectos").value = 0.0
	_caso("en 0 su bus queda en silencio y los otros no", AudioServer.is_bus_mute(bus_efectos) and not AudioServer.is_bus_mute(bus_musica))
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en Audio vuelve a la lista con el foco en Audio", lista.visible and not panel_audio.visible and _boton(config, "Audio").has_focus())
	# El efecto en 0 se movio sin soltar: volver a la lista lo guarda.
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("salir del panel guarda la barra que no se solto", is_equal_approx(Ajustes.volumen_efectos, 0.0))
	_boton(config, "Audio").pressed.emit()
	(config.get_node(^"PanelAudio/Desplazable/Centro/Filas/Efectos/Silencio") as Button).pressed.emit()
	_caso("silenciada arrastrando a 0, el altavoz la sube a la mitad", is_equal_approx(_barra_audio(config, "Efectos").value, Configuracion.VOLUMEN_AL_QUITAR_SILENCIO))
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)

	# Brillo: su pantalla, con la escena y la barra.
	var brillo: BotonValor = _boton(config, "Brillo") as BotonValor
	_caso("Brillo dice su valor y que abre otra pantalla", brillo.valor == "%d %%" % roundi(Ajustes.brillo * 100.0) and brillo.estilo == BotonValor.Estilo.ENLACE)
	brillo.pressed.emit()
	var panel_brillo: Control = config.get_node(^"PanelBrillo") as Control
	var barra_brillo: HSlider = config.get_node(^"PanelBrillo/Columna/Fila/Barra") as HSlider
	_caso("Brillo abre su pantalla con el foco en la barra", panel_brillo.visible and not lista.visible and barra_brillo.has_focus())
	_caso("desde el menu no hay foto: se ve la escena de muestra", not config.brillo_con_foto())
	barra_brillo.value = 140.0
	_caso("la barra del brillo aplica pero no escribe hasta soltarla", is_equal_approx(Ajustes.brillo, 1.4) and not FileAccess.get_file_as_string(RUTA_PRUEBA).contains("1.4"))
	# La escena (muestra y foto, en la ventana y en el fondo) y el cuadro de calibracion: el brillo de la sala no llega.
	var ventana: Node = config.get_node(^"PanelBrillo/Columna").find_child("Ventana", true, false)
	var piezas: Array[Control] = []
	for padre: Node in [ventana, config.get_node(^"PanelBrillo/Fondo")]:
		for hijo: Node in padre.get_children():
			if hijo is EscenaMuestra or hijo.name == &"Foto" or hijo.name == &"Calibracion":
				piezas.append(hijo as Control)
	var moduladas: bool = piezas.size() == 5
	for pieza: Control in piezas:
		moduladas = moduladas and pieza.modulate.is_equal_approx(Color(1.4, 1.4, 1.4))
	_caso("la escena y el cuadro de la pantalla de brillo se modulan con el brillo (no los tapa una capa)", moduladas)
	barra_brillo.drag_ended.emit(true)
	Ajustes.brillo = 1.0
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("el brillo se guarda al soltar la barra", is_equal_approx(Ajustes.brillo, 1.4))
	(config.get_node(^"PanelBrillo/Columna/Arriba/Volver") as Button).pressed.emit()
	_caso("Volver vuelve a la lista con el foco en Brillo y su valor al dia", lista.visible and not panel_brillo.visible and brillo.has_focus() and brillo.valor == "140 %")
	var foto: Image = Image.create_empty(64, 36, false, Image.FORMAT_RGBA8)
	foto.fill(Color(0.5, 0.5, 0.5))
	config.foto = foto
	brillo.pressed.emit()
	_caso("con la foto de la sala (desde la pausa) se ve la foto", config.brillo_con_foto())
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en Brillo vuelve a la lista", lista.visible and not panel_brillo.visible)
	config.foto = Image.new()
	brillo.pressed.emit()
	_caso("una foto vacia usa la escena de muestra", not config.brillo_con_foto())
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	config.foto = null

	_boton(config, "Creditos").pressed.emit()
	_caso("Creditos abre su panel", (config.get_node(^"PanelCreditos") as Control).visible)
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en Creditos vuelve a la lista", lista.visible)

	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en la lista vuelve al menu", centro.visible and not config.visible and not confirmar.visible)
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en el menu pide salir", confirmar.visible)
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras otra vez cancela la salida", not confirmar.visible and centro.visible)

	(menu.get_node(^"Centro/Opciones/Configuracion") as Button).pressed.emit()
	(config.get_node(^"Lista/Arriba/Volver") as Button).pressed.emit()
	_caso("Volver cierra Configuracion", centro.visible and not config.visible)

	# Al volver de la zona de pruebas, el menu abre con el foco en su entrada (un nivel atras de la zona), una vez.
	MenuPrincipal.volver_a_zona = true
	var otro: Control = ESCENA_MENU.instantiate() as Control
	add_child(otro)
	_caso("al volver de la zona de pruebas el menu enfoca su entrada", (otro.get_node(^"Centro/Opciones/ZonaPruebas") as Button).has_focus() and not MenuPrincipal.volver_a_zona)
	remove_child(otro)
	otro.free()

	# Columnas segun el ancho util de la vista (720 de alto, de 4:3 a 22:9, menos 2 x 64 de margen).
	_caso("si el area segura recorta mucho (832) cabe una columna", Configuracion.columnas_para(960.0 - 128.0) == 1)
	_caso("en la vista de 1280 (4:3 y 16:9) caben dos", Configuracion.columnas_para(1280.0 - 128.0) == 2)
	_caso("en el S50 (1440) caben tres", Configuracion.columnas_para(1440.0 - 128.0) == 3)
	_caso("en 22:9 (1760) siguen tres", Configuracion.columnas_para(1760.0 - 128.0) == 3)

	# Aviso de pocos toques: sale abajo si Android dice que la pantalla no reconoce 5 toques; si no, no hay aviso.
	_caso("sin pocos toques (y en PC) no hay aviso", menu.get_node_or_null(^"AvisoToques") == null)
	Toques.forzar(true)
	var con_aviso: Control = ESCENA_MENU.instantiate() as Control
	add_child(con_aviso)
	var aviso: Label = con_aviso.get_node_or_null(^"AvisoToques") as Label
	_caso("con pocos toques el menu muestra el aviso", aviso != null and aviso.visible and aviso.text == Toques.TEXTO_AVISO)
	_caso("el aviso queda debajo de la confirmacion de salida", aviso != null and aviso.get_index() < (con_aviso.get_node(^"Confirmar") as Control).get_index())
	# El aviso de recursos de Configuracion queda arriba de esa linea, no encima (S50, 13-oct-2026).
	var conf: Configuracion = con_aviso.get_node(^"Configuracion") as Configuracion
	conf.abrir()
	var aviso_recursos: Label = conf.get_node(^"Lista/AvisoRecursos") as Label
	aviso_recursos.text = "x"
	aviso_recursos.visible = true
	await get_tree().process_frame
	await get_tree().process_frame
	_caso("el aviso de recursos queda arriba del de pocos toques", aviso != null and aviso_recursos.get_global_rect().end.y <= aviso.get_global_rect().position.y + 1.0)
	remove_child(con_aviso)
	con_aviso.free()
	Toques.olvidar()

	if FileAccess.file_exists(RUTA_PRUEBA):
		DirAccess.remove_absolute(RUTA_PRUEBA)
	Ajustes.disposicion = DisposicionControles.por_omision()
	Ajustes.modo_desarrollador = modo_real
	Ajustes.volumen = volumen_real
	Ajustes.volumen_musica = musica_real
	Ajustes.volumen_efectos = efectos_real
	Ajustes.brillo = brillo_real
	Ajustes.aplicar_volumen()
	Mando.aplicar(mando_real)
	_resumen()


func _barra_audio(config: Configuracion, nombre: String) -> HSlider:
	return config.get_node(NodePath("PanelAudio/Desplazable/Centro/Filas/%s/Barra" % nombre)) as HSlider


# Una accion de la interfaz (ui_left, ui_right) al control con el foco, como la manda el teclado o el control.
func _tecla(accion: StringName) -> void:
	var evento: InputEventAction = InputEventAction.new()
	evento.action = accion
	evento.pressed = true
	get_viewport().push_input(evento)
	evento = InputEventAction.new()
	evento.action = accion
	evento.pressed = false
	get_viewport().push_input(evento)


func _boton(config: Configuracion, nombre: String) -> Button:
	return config.get_node(NodePath(OPCIONES + nombre)) as Button


# Toca la fila de una accion en el panel de botones del control: el Button que lleva su IconoBoton.
func _tocar_fila(panel: Control, accion: StringName) -> void:
	for icono: IconoBoton in _iconos(panel):
		if icono.accion == accion and icono.get_parent() is Button:
			(icono.get_parent() as Button).pressed.emit()
			return
	_caso("hay una fila de %s" % accion, false)
