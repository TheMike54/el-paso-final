extends Node
# Prueba de los amuletos: Partida pone y quita solo lo que se tiene y con lugar, y autoguarda; la pantalla de los
# amuletos deja cambiarlos solo sentado en un banco y de pie solo los muestra; se abre deteniendo el juego, y desde
# la pausa vuelve a ella; con las acciones mochila y pausa y con Atras, como en una sala. Deja casos y fallos para amuletos.guion e imprime el resumen.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const ESCENA_PAUSA: PackedScene = preload("res://nucleo/pausa.tscn")
const RUTA: String = "user://prueba_amuletos.json"

var casos: int = 0
var fallos: int = 0


func _ready() -> void:
	var ruta_real: String = Partida.ruta_guardado
	Partida.ruta_guardado = RUTA
	Partida.reiniciar()

	# Partida.
	_caso("sin tenerlo no se pone", not Partida.puede_equipar(&"brujula") and not Partida.equipar(&"brujula") and Partida.amuletos_equipados.is_empty())
	Partida.amuletos_tenidos.append_array([&"brujula", &"a", &"b", &"c"] as Array[StringName])
	var antes: int = Partida.autoguardados
	_caso("uno que se tiene se pone y autoguarda", Partida.equipar(&"brujula") and Partida.esta_equipado(&"brujula") and Partida.autoguardados == antes + 1)
	_caso("puesto no se pone dos veces", not Partida.equipar(&"brujula") and Partida.amuletos_equipados.size() == 1)
	Partida.equipar(&"a")
	Partida.equipar(&"b")
	_caso("con %d puestos no cabe otro" % Partida.MAX_EQUIPADOS, not Partida.puede_equipar(&"c") and not Partida.equipar(&"c") and Partida.amuletos_equipados.size() == Partida.MAX_EQUIPADOS)
	antes = Partida.autoguardados
	_caso("quitar uno puesto lo quita y autoguarda", Partida.desequipar(&"a") and not Partida.esta_equipado(&"a") and Partida.autoguardados == antes + 1)
	_caso("quitar uno que no esta puesto no hace nada", not Partida.desequipar(&"a") and Partida.autoguardados == antes + 1)
	var datos: Dictionary = Partida.a_diccionario()
	Partida.reiniciar()
	Partida.desde_diccionario(datos)
	_caso("los puestos vuelven al cargar", Partida.esta_equipado(&"brujula") and Partida.esta_equipado(&"b") and not Partida.esta_equipado(&"a") and Partida.amuletos_tenidos.size() == 4)

	# Pantalla, con un jugador de pie.
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.name = "Jugador"
	add_child(jugador)
	var pantalla: PantallaAmuletos = PantallaAmuletos.new()
	pantalla.name = "Amuletos"
	add_child(pantalla)
	pantalla.abrir()
	_caso("abrir detiene el juego y lista los que se tienen", get_tree().paused and pantalla.visible and pantalla.botones.size() == 4)
	_caso("de pie se ven pero no se cambian", pantalla.botones[&"a"].disabled and not pantalla.alternar(&"a") and not Partida.esta_equipado(&"a"))
	_caso("bloquea la pausa mientras esta abierta", pantalla.bloquea_pausa())
	pantalla.cerrar()
	_caso("cerrar sigue el juego", not get_tree().paused and not pantalla.visible)

	# Sentado.
	jugador.descansando = true
	pantalla.abrir()
	_caso("sentado, el que cabe responde y el que esta puesto tambien", not pantalla.botones[&"a"].disabled and not pantalla.botones[&"brujula"].disabled)
	_caso("sentado se quita uno puesto", pantalla.alternar(&"brujula") and not Partida.esta_equipado(&"brujula") and pantalla.botones[&"brujula"].text.ends_with("guardado"))
	pantalla.alternar(&"a")
	pantalla.alternar(&"c")
	_caso("sentado se ponen hasta llenar y el siguiente no responde", Partida.amuletos_equipados.size() == Partida.MAX_EQUIPADOS and pantalla.botones[&"brujula"].disabled and not pantalla.alternar(&"brujula"))
	pantalla.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras la cierra", not pantalla.abierta and not get_tree().paused)

	# Con el juego ya detenido no se abre sola; la pausa la abre y vuelve a ella.
	var pausa: Pausa = ESCENA_PAUSA.instantiate() as Pausa
	add_child(pausa)
	pausa.abrir()
	pantalla.abrir()
	_caso("con la pausa abierta, mochila no la abre", not pantalla.abierta)
	pausa.abrir_amuletos()
	var panel: Control = pausa.get_node(^"Panel") as Control
	_caso("Amuletos de la pausa la abre encima y oculta la pausa", pantalla.abierta and not panel.visible)
	pantalla.cerrar()
	_caso("al cerrarla vuelve la pausa con el juego detenido", panel.visible and get_tree().paused and pausa.abierta)
	pausa.cerrar()

	# Con las acciones, en el orden de una sala (la pausa antes que la pantalla).
	move_child(pausa, pantalla.get_index())
	await _presionar(&"mochila")
	_caso("mochila la abre deteniendo el juego, sin la pausa", pantalla.abierta and get_tree().paused and not pausa.abierta)
	await _presionar(&"pausa")
	_caso("pausa la cierra sin abrir la pausa", not pantalla.abierta and not pausa.abierta and not get_tree().paused)
	await _presionar(&"mochila")
	await _presionar(&"mochila")
	_caso("mochila otra vez la cierra", not pantalla.abierta and not get_tree().paused)
	await _presionar(&"mochila")
	get_tree().root.propagate_notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	await get_tree().physics_frame
	_caso("Atras la cierra sin abrir la pausa", not pantalla.abierta and not pausa.abierta and not get_tree().paused)

	pausa.free()
	pantalla.free()
	jugador.free()
	get_tree().paused = false
	Partida.reiniciar()
	Partida.ruta_guardado = ruta_real
	DirAccess.remove_absolute(RUTA)
	print("PRUEBAS amuletos casos=%d fallos=%d" % [casos, fallos])


func _presionar(accion: StringName) -> void:
	Input.action_press(accion)
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(accion)
	await get_tree().physics_frame


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO amuletos: %s" % nombre)
