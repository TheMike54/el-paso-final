extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de las ranuras de partida: rutas independientes, la partida de antes de las ranuras pasa una vez a la ranura 1
# sin pisar nada, la copia y Restaurar, Borrar quita tambien la copia, el texto de cada ficha, la Confirmacion
# compartida sola y, con el menu, los estados, confirmar al borrar, Atras un nivel, la ruta del autoguardado y el
# personaje y nombre de una vacia. Deja casos y fallos para ranuras.guion.

const ESCENA_MENU: PackedScene = preload("res://nucleo/menu.tscn")
const FORMATO: String = "user://prueba_ranura_%d.json"
const VIEJA: String = "user://prueba_ranura_vieja.json"
const PARTIDA: Dictionary = {"banco": {}, "vidas_maximas": 5, "habilidades": ["impulso", "pluma"], "jefes": [],
		"amuletos_tenidos": [], "amuletos_equipados": [], "monedas": 0, "mochila": {}, "mapas": [],
		"salas_visitadas": ["prueba_1", "prueba_2"], "salas_mapeadas": [],
		"salas": {"prueba_2": {"coleccionable_1": true, "suelo": true}}, "personaje": "", "nombre": "",
		"tiempo_jugado": 3900.0}


func _ready() -> void:
	_limpiar()
	_caso("cada ranura tiene su archivo", Guardado.ruta_ranura(1) == "user://partida_1.json" and Guardado.ruta_ranura(4) == "user://partida_4.json")

	# Migracion de la partida de antes de las ranuras.
	var r1: String = FORMATO % 1
	_caso("sin partida vieja, migrar no hace nada", Guardado.migrar(VIEJA, r1) == OK and not FileAccess.file_exists(r1))
	Guardado.guardar(PARTIDA, VIEJA)
	_caso("la partida vieja pasa a la ranura 1", Guardado.migrar(VIEJA, r1) == OK and Guardado.cargar(r1).estado == Guardado.Estado.VALIDA and not FileAccess.file_exists(VIEJA))
	var otra: Dictionary = PARTIDA.duplicate(true)
	otra["vidas_maximas"] = 9
	Guardado.guardar(otra, VIEJA)
	Guardado.migrar(VIEJA, r1)
	_caso("y nunca pisa una ranura 1 que ya existe", (Guardado.cargar(r1).partida["vidas_maximas"] as int) == 5 and FileAccess.file_exists(VIEJA))

	# Copia y Restaurar.
	_caso("una ranura valida se copia", Guardado.respaldar(r1) == OK and Guardado.tiene_respaldo(r1))
	Guardado.guardar(otra, r1)
	_caso("restaurar vuelve a la copia", Guardado.restaurar(r1) == OK and (Guardado.cargar(r1).partida["vidas_maximas"] as int) == 5 and not FileAccess.file_exists(r1 + ".tmp"))
	_escribir(r1, "{\"version\": 3, \"partida\": {\"ban")
	_caso("una ranura danada no se copia y la copia buena sigue", Guardado.respaldar(r1) != OK and (Guardado.cargar(r1 + Guardado.RESPALDO).partida["vidas_maximas"] as int) == 5)
	_caso("restaurar rescata la ranura danada", Guardado.restaurar(r1) == OK and Guardado.cargar(r1).estado == Guardado.Estado.VALIDA)
	_caso("borrar quita tambien la copia", Guardado.borrar(r1) == OK and not FileAccess.file_exists(r1) and not Guardado.tiene_respaldo(r1))
	_caso("sin copia no se restaura", Guardado.restaurar(r1) != OK)
	Guardado.guardar(PARTIDA, r1)
	Guardado.respaldar(r1)
	_escribir(r1 + Guardado.RESPALDO, "{\"version\": 3, \"par")
	_caso("una copia cortada no cuenta y no pisa la ranura", not Guardado.tiene_respaldo(r1) and Guardado.restaurar(r1) != OK and Guardado.cargar(r1).estado == Guardado.Estado.VALIDA)
	_caso("la siguiente copia la reemplaza, sin temporal", Guardado.respaldar(r1) == OK and Guardado.tiene_respaldo(r1) and not FileAccess.file_exists(r1 + Guardado.RESPALDO + ".tmp"))
	Guardado.borrar(r1)

	# Texto de las fichas.
	_caso("tiempo en minutos", Ranuras.tiempo_texto(0.0) == "0 min" and Ranuras.tiempo_texto(3599.0) == "59 min")
	_caso("tiempo en horas y minutos", Ranuras.tiempo_texto(3600.0) == "1 h 00 min" and Ranuras.tiempo_texto(3900.0) == "1 h 05 min")
	var con_banco: Dictionary = PARTIDA.duplicate(true)
	con_banco["banco"] = {"sala": "raices_1", "id": "banco_1"}
	_caso("la ubicacion es la sala del banco", Ranuras.ubicacion(con_banco) == "Raices 1")
	_caso("sin banco, la ultima sala visitada", Ranuras.ubicacion(PARTIDA) == "Prueba 2")
	var suelta: Dictionary = PARTIDA.duplicate(true)
	suelta["salas_visitadas"] = ["res://herramientas/salas/sala_banco.tscn"]
	_caso("una sala suelta, por el nombre de su escena", Ranuras.ubicacion(suelta) == "Sala Banco")
	suelta["salas_visitadas"] = []
	_caso("sin ninguna, Inicio", Ranuras.ubicacion(suelta) == "Inicio")
	_caso("un paso por habilidad, jefe y coleccionable", Ranuras.pasos(PARTIDA) == 3)
	_caso("la ficha dice ubicacion, vidas y tiempo", Ranuras.detalle(PARTIDA) == "Prueba 2\nVidas: 5\n1 h 05 min")
	_caso("4 fichas en fila desde la vista de 1280", Ranuras.columnas_para(1280.0 - 128.0) == 4 and Ranuras.columnas_para(1760.0 - 128.0) == 4)
	_caso("si caben 3, en 2x2 y no 3 y 1", Ranuras.columnas_para(1000.0) == 2)

	_probar_confirmacion()
	await _probar_menu()
	_limpiar()
	_resumen()


# Con el menu: cada estado se muestra, borrar pide confirmacion, Atras vuelve un nivel, entrar a una ranura fija la
# ruta del autoguardado y una vacia pide personaje y nombre (limpio) y los guarda. Todo en archivos de prueba; solo el
# menu, al abrir, pasa la partida vieja real a la ranura 1, como lo hace el juego.
func _probar_menu() -> void:
	var menu: MenuPrincipal = ESCENA_MENU.instantiate() as MenuPrincipal
	add_child(menu)
	var ranuras: Ranuras = menu.ranuras
	ranuras.formato_ruta = FORMATO
	Guardado.guardar(PARTIDA, FORMATO % 2)
	Guardado.respaldar(FORMATO % 2)
	_escribir(FORMATO % 3, "no es una partida")
	_escribir(FORMATO % 4, JSON.stringify({"version": 99, "partida": PARTIDA}))
	(menu.get_node(^"Centro/Opciones/Jugar") as Button).pressed.emit()
	var centro: Control = menu.get_node(^"Centro") as Control
	_caso("Jugar abre las ranuras en lugar del menu", ranuras.visible and not centro.visible)
	_caso("con el foco en la primera ficha", _ficha(ranuras, 1, "Principal").has_focus())
	_caso("la vacia dice Nueva partida y no se borra", _detalle(ranuras, 1) == "Nueva partida" and not _ficha(ranuras, 1, "Borrar").visible)
	_caso("la ocupada dice su detalle, con Borrar y Restaurar", _detalle(ranuras, 2) == Ranuras.detalle(PARTIDA) and _ficha(ranuras, 2, "Borrar").visible and _ficha(ranuras, 2, "Restaurar").visible)
	_caso("y su rastro tiene un cuadrito por paso", ranuras.get_node(^"Marco/Desplazable").find_child("Ficha2", true, false).find_child("Rastro", true, false).get_child_count() == 3)
	_caso("la danada no se abre y se puede borrar", _detalle(ranuras, 3) == "Dañada" and _ficha(ranuras, 3, "Principal").disabled and _ficha(ranuras, 3, "Borrar").visible)
	_caso("la de otra version tampoco se abre", _detalle(ranuras, 4) == "De otra versión" and _ficha(ranuras, 4, "Principal").disabled)

	var confirmacion: Control = ranuras.get_node(^"Confirmar") as Control
	_ficha(ranuras, 3, "Borrar").pressed.emit()
	_caso("Borrar pide confirmacion", confirmacion.visible and FileAccess.file_exists(FORMATO % 3))
	var vista: Rect2 = ranuras.get_viewport_rect()
	var si_borrar: Button = confirmacion.find_child("Si", true, false) as Button
	_caso("la confirmacion cubre la pantalla y su Si se ve entero", ranuras.size == vista.size and confirmacion.get_global_rect() == vista and vista.encloses(si_borrar.get_global_rect()))
	# Con teclado o control el foco no se escapa a las fichas de detras.
	var escapo: bool = false
	for direccion: StringName in [&"ui_left", &"ui_up", &"ui_right", &"ui_right", &"ui_down", &"ui_down"]:
		var evento: InputEventAction = InputEventAction.new()
		evento.action = direccion
		evento.pressed = true
		get_viewport().push_input(evento)
		var dueno: Control = get_viewport().gui_get_focus_owner()
		if dueno == null or not confirmacion.is_ancestor_of(dueno):
			escapo = true
	_caso("con la confirmacion abierta el foco no sale de ella", not escapo)
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en la confirmacion no borra y vuelve a la ficha", not confirmacion.visible and FileAccess.file_exists(FORMATO % 3) and _ficha(ranuras, 3, "Borrar").has_focus())
	_ficha(ranuras, 3, "Borrar").pressed.emit()
	(ranuras.get_node(^"Confirmar").find_child("Si", true, false) as Button).pressed.emit()
	_caso("confirmar borra y la ficha queda vacia", not FileAccess.file_exists(FORMATO % 3) and _detalle(ranuras, 3) == "Nueva partida")

	# Restaurar desde la ficha: la ranura 2 avanzo (9 vidas) despues de su copia (5).
	var avanzada: Dictionary = PARTIDA.duplicate(true)
	avanzada["vidas_maximas"] = 9
	Guardado.guardar(avanzada, FORMATO % 2)
	ranuras.leer()
	_ficha(ranuras, 2, "Restaurar").pressed.emit()
	var si: Button = ranuras.get_node(^"Confirmar").find_child("Si", true, false) as Button
	_caso("Restaurar pide confirmacion", confirmacion.visible and si.text == "Restaurar")
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras no restaura y vuelve a Restaurar", not confirmacion.visible and _ficha(ranuras, 2, "Restaurar").has_focus() and (Guardado.cargar(FORMATO % 2).partida["vidas_maximas"] as int) == 9)
	_ficha(ranuras, 2, "Restaurar").pressed.emit()
	si.pressed.emit()
	_caso("confirmar vuelve la ranura a su copia", (Guardado.cargar(FORMATO % 2).partida["vidas_maximas"] as int) == 5 and _detalle(ranuras, 2) == Ranuras.detalle(PARTIDA))
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras en las ranuras vuelve al menu", not ranuras.visible and centro.visible)
	_caso("con el foco en Jugar", (menu.get_node(^"Centro/Opciones/Jugar") as Button).has_focus())

	# Una vacia pide personaje y nombre antes de empezar.
	(menu.get_node(^"Centro/Opciones/Jugar") as Button).pressed.emit()
	_caso("la ficha sin nombre se titula Partida N", _titulo(ranuras, 2) == "Partida 2")
	var nueva: NuevaPartida = menu.nueva_partida
	_ficha(ranuras, 1, "Principal").pressed.emit()
	_caso("tocar una vacia abre Nueva partida con el foco en Hombre", nueva.visible and not ranuras.visible and nueva.botones["hombre"].has_focus())
	_caso("sin personaje Empezar no responde", nueva.empezar_boton.disabled)
	nueva.botones["mujer"].pressed.emit()
	_caso("elegir uno lo enciende y habilita Empezar", nueva.personaje == "mujer" and nueva.botones["mujer"].button_pressed and not nueva.botones["hombre"].button_pressed and not nueva.empezar_boton.disabled)
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)
	_caso("Atras vuelve a las ranuras con el foco en la elegida", not nueva.visible and ranuras.visible and _ficha(ranuras, 1, "Principal").has_focus())
	_caso("el nombre se limpia: sin simbolos, orillas ni espacios repetidos", NuevaPartida.limpiar_nombre("  Ana   María!! ", "mujer") == "Ana María" and NuevaPartida.limpiar_nombre("Ñandú_123", "hombre") == "Ñandú123")
	_caso("hasta 12 caracteres", NuevaPartida.limpiar_nombre("abcdefghijklmnop", "hombre").length() == NuevaPartida.LARGO_NOMBRE)
	_caso("vacio toma el del personaje", NuevaPartida.limpiar_nombre("", "mujer") == "Alumna" and NuevaPartida.limpiar_nombre(" @@ ", "hombre") == "Alumno")
	menu.notification(NOTIFICATION_WM_GO_BACK_REQUEST)

	# Entrar a una ranura (sin cambiar de escena).
	_caso("una vacia empieza en la sala inicial", menu.preparar_ranura(1) == menu.sala_inicial)
	_caso("y fija el autoguardado en su ranura, ya escrita", Partida.ruta_guardado == FORMATO % 1 and Guardado.cargar(FORMATO % 1).estado == Guardado.Estado.VALIDA)
	Guardado.borrar(FORMATO % 1)
	menu.preparar_ranura(1, "mujer", "Ana")
	var escrita: Dictionary = Guardado.cargar(FORMATO % 1).partida
	_caso("una nueva guarda personaje y nombre", Partida.personaje == "mujer" and Partida.nombre == "Ana" and str(escrita.get("personaje")) == "mujer" and str(escrita.get("nombre")) == "Ana")
	ranuras.leer()
	_caso("y su ficha se titula con el nombre", _titulo(ranuras, 1) == "Ana")
	Guardado.borrar(FORMATO % 2)
	Guardado.guardar(PARTIDA, FORMATO % 2)
	_caso("una ocupada sin banco continua en la sala inicial", menu.preparar_ranura(2) == menu.sala_inicial)
	_caso("con su partida, su ruta y su copia", Partida.vidas_maximas == 5 and Partida.ruta_guardado == FORMATO % 2 and Guardado.tiene_respaldo(FORMATO % 2))
	var con_banco: Dictionary = PARTIDA.duplicate(true)
	con_banco["banco"] = {"sala": "prueba_1", "id": "banco_prueba"}
	Guardado.guardar(con_banco, FORMATO % 2)
	Sala.llegada_a_banco = false
	_caso("una ocupada con banco continua en la sala del banco", menu.preparar_ranura(2) == "res://herramientas/salas/zonas/prueba/prueba_1.tscn" and Sala.llegada_a_banco)
	var antes: String = FileAccess.get_file_as_string(FORMATO % 4)
	_caso("la de otra version no se abre ni se pisa", menu.preparar_ranura(4).is_empty() and FileAccess.get_file_as_string(FORMATO % 4) == antes)
	remove_child(menu)
	menu.free()

	# Con el aviso de pocos toques las fichas quedan arriba de el.
	Toques.forzar(true)
	var con_aviso: MenuPrincipal = ESCENA_MENU.instantiate() as MenuPrincipal
	add_child(con_aviso)
	con_aviso.abrir_ranuras()
	await get_tree().process_frame
	var aviso: Control = con_aviso.get_node(^"AvisoToques") as Control
	var marco: Control = con_aviso.get_node(^"Ranuras/Marco") as Control
	_caso("con el aviso, las ranuras terminan arriba de el", marco.get_global_rect().end.y <= aviso.get_global_rect().position.y)
	con_aviso.nueva_partida.abrir(1)
	await get_tree().process_frame
	var marco_nueva: Control = con_aviso.get_node(^"NuevaPartida/Marco") as Control
	_caso("y Nueva partida tambien", marco_nueva.get_global_rect().end.y <= aviso.get_global_rect().position.y and con_aviso.nueva_partida.empezar_boton.get_global_rect().end.y <= aviso.get_global_rect().position.y)
	remove_child(con_aviso)
	con_aviso.free()
	Toques.olvidar()
	Partida.reiniciar()
	Partida.ruta_guardado = Partida.RUTA_PRUEBAS
	Sala.llegada_a_banco = false


# La confirmacion compartida sola: foco inicial segun el parametro, Si emite una vez, Atras (cancelar) cierra y emite
# una vez, y con una variacion de boton Si y No miden lo que su texto.
func _probar_confirmacion() -> void:
	var caja: Confirmacion = Confirmacion.new()
	add_child(caja)
	var veces: Array[int] = [0, 0]
	caja.confirmada.connect(func() -> void: veces[0] += 1)
	caja.cancelada.connect(func() -> void: veces[1] += 1)
	_caso("la confirmacion empieza oculta", not caja.visible)
	caja.abrir("¿Seguro?", "Sí", "No", Confirmacion.Foco.SI)
	_caso("con foco SI abre con el foco en Si y sus textos", caja.visible and caja.si.has_focus() and caja.si.text == "Sí" and caja.no.text == "No")
	caja.si.pressed.emit()
	caja.si.pressed.emit()
	_caso("Si emite confirmada una vez aunque se toque dos, y no la cierra", veces[0] == 1 and veces[1] == 0 and caja.visible)
	caja.cerrar()
	caja.abrir("¿Seguro?", "Sí", "No")
	_caso("por omision abre con el foco en No", caja.no.has_focus())
	caja.cancelar()
	caja.cancelar()
	caja.si.pressed.emit()
	_caso("Atras la cierra y emite cancelada una vez; cerrada, Si no emite", not caja.visible and veces[1] == 1 and veces[0] == 1)
	caja.abrir("¿Seguro?", "Sí", "No")
	caja.no.pressed.emit()
	_caso("No tambien cancela", not caja.visible and veces[1] == 2)
	remove_child(caja)
	caja.free()
	var centrada: Confirmacion = Confirmacion.new()
	centrada.variacion_boton = Tema.OPCION_CENTRADA
	add_child(centrada)
	_caso("con otra variacion Si y No no tienen ancho minimo", centrada.si.theme_type_variation == Tema.OPCION_CENTRADA and is_zero_approx(centrada.no.custom_minimum_size.x))
	remove_child(centrada)
	centrada.free()


func _ficha(ranuras: Ranuras, numero: int, nombre: String) -> Button:
	return ranuras.get_node(NodePath("Marco/Desplazable")).find_child("Ficha%d" % numero, true, false).get_node(NodePath(nombre)) as Button


func _titulo(ranuras: Ranuras, numero: int) -> String:
	return (_ficha(ranuras, numero, "Principal").find_child("Titulo", true, false) as Label).text


func _detalle(ranuras: Ranuras, numero: int) -> String:
	return (_ficha(ranuras, numero, "Principal").find_child("Detalle", true, false) as Label).text


func _limpiar() -> void:
	for numero: int in range(1, Guardado.RANURAS + 1):
		Guardado.borrar(FORMATO % numero)
	Guardado.borrar(VIEJA)
