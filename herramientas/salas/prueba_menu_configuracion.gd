extends Node
# Prueba de la navegacion de Configuracion en el menu principal: instancia el menu y recorre menu, panel y
# editor de controles con Atras (la notificacion de Android) y con la accion pausa, que vuelven un nivel a
# la vez. Comprueba tambien que Listo desde el menu guarda la disposicion, en un archivo de prueba. Deja
# casos y fallos para menu_configuracion.guion. Imprime el resumen y los fallos.

const ESCENA_MENU: PackedScene = preload("res://nucleo/menu.tscn")
const RUTA_PRUEBA: String = "user://prueba_menu_configuracion.json"

var casos: int = 0
var fallos: int = 0


func _ready() -> void:
	# Primero la carga del archivo real: si llegara despues, dentro del editor, pisaria la disposicion por omision.
	Ajustes.cargar_una_vez()
	Ajustes.disposicion = DisposicionControles.por_omision()
	var menu: Control = ESCENA_MENU.instantiate() as Control
	add_child(menu)
	var centro: Control = menu.get_node(^"Centro") as Control
	var panel: Control = menu.get_node(^"PanelConfiguracion") as Control
	var confirmar: Control = menu.get_node(^"Confirmar") as Control
	_caso("al entrar, el panel de Configuracion esta oculto", centro.visible and not panel.visible)

	(menu.get_node(^"Centro/Opciones/Configuracion") as Button).pressed.emit()
	_caso("Configuracion abre su panel en lugar del menu", panel.visible and not centro.visible)
	(menu.get_node(^"PanelConfiguracion/Opciones/Controles") as Button).pressed.emit()
	var editor: EditorControles = menu.get("editor") as EditorControles
	_caso("Controles abre el editor de botones", editor != null and ControlesTactiles.editando and not panel.visible)

	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await get_tree().process_frame
	_caso("Atras con el editor abierto lo cancela y vuelve al panel", menu.get("editor") == null and panel.visible and not ControlesTactiles.editando)
	_caso("y no pide salir", not confirmar.visible)

	(menu.get_node(^"PanelConfiguracion/Opciones/Controles") as Button).pressed.emit()
	Input.action_press(&"pausa")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(&"pausa")
	await get_tree().process_frame
	_caso("la accion pausa con el editor abierto tambien vuelve al panel", menu.get("editor") == null and panel.visible)
	_caso("y tampoco pide salir", not confirmar.visible)

	(menu.get_node(^"PanelConfiguracion/Opciones/Controles") as Button).pressed.emit()
	editor = menu.get("editor") as EditorControles
	editor.ruta_ajustes = RUTA_PRUEBA
	editor.copia.colocar(0, editor.size / 2.0, editor.size, Rect2(Vector2.ZERO, editor.size), 0.0)
	editor.listo()
	await get_tree().process_frame
	_caso("Listo desde el menu deja la disposicion nueva en Ajustes", not Ajustes.disposicion.igual_a(DisposicionControles.por_omision()))
	_caso("y vuelve al panel", panel.visible and menu.get("editor") == null)

	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en el panel vuelve al menu", centro.visible and not panel.visible and not confirmar.visible)
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en el menu pide salir", confirmar.visible)
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras otra vez cancela la salida", not confirmar.visible and centro.visible)

	(menu.get_node(^"Centro/Opciones/Configuracion") as Button).pressed.emit()
	(menu.get_node(^"PanelConfiguracion/Opciones/Volver") as Button).pressed.emit()
	_caso("Volver cierra el panel", centro.visible and not panel.visible)

	DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_PRUEBA))
	Ajustes.disposicion = DisposicionControles.por_omision()
	print("PRUEBAS menu_configuracion casos=%d fallos=%d" % [casos, fallos])


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO menu_configuracion: %s" % nombre)
