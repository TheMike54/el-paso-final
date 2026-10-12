extends Node
# Prueba de la Configuracion del menu principal: instancia el menu y recorre menu, Configuracion, sus subpaneles
# y el editor de controles con Atras (la notificacion de Android) y con la accion pausa, que vuelven un nivel a
# la vez. Comprueba tambien lo que puede romperse: Listo guarda la disposicion, reasignar un boton del control
# intercambia con la accion que lo tenia y se guarda, el modo desarrollador muestra la zona de pruebas y se
# recuerda, borrar la partida la borra y el volumen se guarda. Todo en archivos de prueba. Deja casos y fallos
# para menu_configuracion.guion. Imprime el resumen y los fallos.

const ESCENA_MENU: PackedScene = preload("res://nucleo/menu.tscn")
const RUTA_PRUEBA: String = "user://prueba_menu_configuracion.json"
const RUTA_PARTIDA: String = "user://prueba_menu_partida.json"

var casos: int = 0
var fallos: int = 0


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
	Ajustes.modo_desarrollador = false
	var menu: Control = ESCENA_MENU.instantiate() as Control
	add_child(menu)
	var centro: Control = menu.get_node(^"Centro") as Control
	var config: Configuracion = menu.get_node(^"Configuracion") as Configuracion
	config.ruta_ajustes = RUTA_PRUEBA
	config.ruta_partida = RUTA_PARTIDA
	var lista: Control = config.get_node(^"Lista") as Control
	var confirmar: Control = menu.get_node(^"Confirmar") as Control
	_caso("al entrar, Configuracion esta oculta", centro.visible and not config.visible)

	(menu.get_node(^"Centro/Opciones/Configuracion") as Button).pressed.emit()
	_caso("Configuracion abre su lista en lugar del menu", config.visible and lista.visible and not centro.visible)
	_caso("sin el modo desarrollador no se ve la zona de pruebas", not _boton(config, "ZonaPruebas").visible)
	_boton(config, "Controles").pressed.emit()
	var editor: EditorControles = menu.get("editor") as EditorControles
	_caso("Botones tactiles abre el editor", editor != null and ControlesTactiles.editando and not config.visible)

	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await get_tree().process_frame
	_caso("Atras con el editor abierto lo cancela y vuelve a Configuracion", menu.get("editor") == null and config.visible and not ControlesTactiles.editando)
	_caso("y no pide salir", not confirmar.visible)

	_boton(config, "Controles").pressed.emit()
	Input.action_press(&"pausa")
	await get_tree().physics_frame
	await get_tree().physics_frame
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
	var saltar: int = Mando.boton_de(&"saltar")
	var atacar: int = Mando.boton_de(&"atacar")
	config._esperar_boton(&"saltar")
	config.recibir_boton(atacar)
	_caso("dar a saltar el boton de atacar los intercambia", Mando.boton_de(&"saltar") == atacar and Mando.boton_de(&"atacar") == saltar)
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("el cambio se guarda y se vuelve a leer", Mando.boton_de(&"saltar") == atacar and Mando.boton_de(&"atacar") == saltar)
	_caso("justo despues de asignar, el menu ignora la accion pausa (el Start con que se asigno)", config.acaba_de_asignar())
	config._esperar_boton(&"saltar")
	config.recibir_boton(Mando.boton_de(&"saltar"))
	Input.action_press(&"pausa")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(&"pausa")
	_caso("y el panel del control sigue abierto tras ese Start", panel_mando.visible and config.visible)
	Mando.asignar(&"saltar", 999)
	_caso("un boton fuera de rango no se asigna", Mando.boton_de(&"saltar") == atacar)
	_caso("impulso e interactuar (ejes) no se reasignan", not Mando.REASIGNABLES.has(&"impulso") and not Mando.REASIGNABLES.has(&"interactuar"))
	Mando.aplicar({"saltar": float(Mando.boton_de(&"curar")), "atacar": 999.0, "curar": "x"})
	# saltar pide el boton de curar: curar recibe el de saltar; atacar fuera de rango y curar no numerico se ignoran.
	_caso("aplicar un archivo con un boton repetido intercambia y descarta lo invalido", Mando.boton_de(&"curar") == saltar and Mando.boton_de(&"atacar") == atacar and Mando.boton_de(&"saltar") != saltar)
	config._esperar_boton(&"curar")
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras mientras espera un boton cancela la espera y sigue en el panel", config.esperando.is_empty() and panel_mando.visible)
	(config.get_node(^"PanelMando/Caja/Botones/PorOmision") as Button).pressed.emit()
	_caso("Por omision devuelve los botones de project.godot", Mando.boton_de(&"saltar") == saltar and Mando.boton_de(&"atacar") == atacar)
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en el panel del control vuelve a la lista", lista.visible and not panel_mando.visible)

	# Modo desarrollador: muestra la zona de pruebas y se recuerda.
	var modo: CheckButton = config.get_node(^"Lista/Caja/Opciones/ModoDesarrollador") as CheckButton
	modo.button_pressed = true
	_caso("el modo desarrollador muestra la zona de pruebas", _boton(config, "ZonaPruebas").visible)
	Ajustes.modo_desarrollador = false
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("el modo desarrollador se recuerda", Ajustes.modo_desarrollador)

	# Vibracion y temblor.
	var vibracion_real: bool = Ajustes.vibracion
	var temblor_real: bool = Ajustes.temblor
	(config.get_node(^"Lista/Caja/Opciones/Vibracion") as CheckButton).button_pressed = not vibracion_real
	(config.get_node(^"Lista/Caja/Opciones/Temblor") as CheckButton).button_pressed = not temblor_real
	Ajustes.vibracion = vibracion_real
	Ajustes.temblor = temblor_real
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("vibracion y temblor se guardan al cambiarlos", Ajustes.vibracion != vibracion_real and Ajustes.temblor != temblor_real)
	Ajustes.vibracion = vibracion_real
	Ajustes.temblor = temblor_real

	# Recursos: la opcion elegida se guarda.
	var recursos_real: String = Ajustes.recursos
	var opcion_recursos: OptionButton = config.get_node(^"Lista/Caja/Opciones/Recursos") as OptionButton
	opcion_recursos.select(1)
	opcion_recursos.item_selected.emit(1)
	Ajustes.recursos = Recursos.AUTO
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("elegir recursos bajo se guarda", Ajustes.recursos == Recursos.BAJO)
	Ajustes.recursos = recursos_real

	# Volumen.
	(config.get_node(^"Lista/Caja/Opciones/Volumen/Barra") as HSlider).value = 40.0
	Ajustes.volumen = 1.0
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("el volumen se guarda", is_equal_approx(Ajustes.volumen, 0.4))

	# Borrar partida, con confirmacion.
	Guardado.guardar(Partida.a_diccionario(), RUTA_PARTIDA)
	var temporal: FileAccess = FileAccess.open(RUTA_PARTIDA + ".tmp", FileAccess.WRITE)
	temporal.store_string("{}")
	temporal.close()
	_boton(config, "BorrarPartida").pressed.emit()
	var confirmar_borrado: Control = config.get_node(^"ConfirmarBorrado") as Control
	_caso("Borrar partida pide confirmacion", confirmar_borrado.visible and FileAccess.file_exists(RUTA_PARTIDA))
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en la confirmacion no borra", not confirmar_borrado.visible and FileAccess.file_exists(RUTA_PARTIDA))
	_boton(config, "BorrarPartida").pressed.emit()
	(config.get_node(^"ConfirmarBorrado/Caja/Botones/Borrar") as Button).pressed.emit()
	_caso("confirmar borra la partida y su temporal", not FileAccess.file_exists(RUTA_PARTIDA) and not FileAccess.file_exists(RUTA_PARTIDA + ".tmp") and not confirmar_borrado.visible)

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
	_boton(config, "Volver").pressed.emit()
	_caso("Volver cierra Configuracion", centro.visible and not config.visible)

	for ruta: String in [RUTA_PRUEBA, RUTA_PARTIDA]:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ruta)
	Ajustes.disposicion = DisposicionControles.por_omision()
	Ajustes.modo_desarrollador = modo_real
	Ajustes.volumen = volumen_real
	Ajustes.aplicar_volumen()
	Mando.aplicar(mando_real)
	print("PRUEBAS menu_configuracion casos=%d fallos=%d" % [casos, fallos])


func _boton(config: Configuracion, nombre: String) -> Button:
	return config.get_node(NodePath("Lista/Caja/Opciones/" + nombre)) as Button


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO menu_configuracion: %s" % nombre)
