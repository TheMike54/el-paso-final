extends "res://herramientas/salas/prueba_base.gd"
# Prueba de los botones tactiles configurables sin pantalla: la cuenta de DisposicionControles (meter un
# boton en el area, ancla, tamano minimo, area segura en la vista), guardar y volver a leer en un archivo
# de prueba, un archivo sin la clave controles, los toques sobre un boton movido y el editor manejado con
# clics simulados. Deja casos y fallos para controles_configurables.guion. Imprime el resumen y los fallos.

const ESCENA_CONTROLES: PackedScene = preload("res://nucleo/controles_tactiles.tscn")
const ESCENA_PAUSA: PackedScene = preload("res://nucleo/pausa.tscn")
const RUTA_PRUEBA: String = "user://prueba_controles_configurables.json"
const TAMANO: Vector2 = Vector2(1600.0, 720.0)
const SALTAR: int = 0


func _ready() -> void:
	_cuenta()
	_archivo()
	await _toques()
	await _editor()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_PRUEBA))
	Ajustes.disposicion = DisposicionControles.por_omision()
	_resumen()


func _cuenta() -> void:
	var omision: DisposicionControles = DisposicionControles.por_omision()
	var igual: bool = true
	for i: int in range(ControlesTactiles.ACCIONES.size()):
		var antes: Vector2 = ControlesTactiles.ANCLAS[i] * TAMANO + (ControlesTactiles.CENTROS[i] - ControlesTactiles.ANCLAS[i]) * Vector2(Vista.PROPORCION_BASE, 1.0) * TAMANO.y
		igual = igual and omision.centro(i, TAMANO).is_equal_approx(antes)
	_caso("la distribucion por omision es la de antes del editor", igual)

	var vista: Rect2 = Rect2(Vector2.ZERO, TAMANO)
	var d: DisposicionControles = omision.copia()
	d.colocar(SALTAR, Vector2(5000.0, -300.0), TAMANO, vista, 0.0)
	_caso("un boton soltado fuera de la pantalla vuelve dentro", _dentro(d, SALTAR, vista, 0.0))
	_caso("se ancla a la esquina mas cercana", d.anclas[SALTAR] == Vector2(1.0, 0.0))
	d.colocar(SALTAR, Vector2(200.0, 600.0), TAMANO, vista, 0.0)
	_caso("abajo a la izquierda se ancla abajo a la izquierda", d.anclas[SALTAR] == Vector2(0.0, 1.0))
	var centro: Vector2 = d.centro(SALTAR, TAMANO)
	var otra: Vector2 = Vector2(2000.0, 720.0)
	_caso("anclado a su esquina, en otra pantalla conserva la distancia a ella", d.centro(SALTAR, otra).is_equal_approx(Vector2(centro.x, centro.y + otra.y - TAMANO.y)))

	var segura: Rect2 = Rect2(90.0, 0.0, 1420.0, 690.0)
	d.colocar(SALTAR, Vector2(1590.0, 710.0), TAMANO, segura, 0.0)
	_caso("dentro del area segura al soltar en la esquina", _dentro(d, SALTAR, segura, 0.0))
	d.fijar_escala(SALTAR, 9.0)
	_caso("la escala no pasa del maximo", is_equal_approx(d.escalas[SALTAR], DisposicionControles.ESCALA_MAXIMA))
	d.fijar_escala(SALTAR, 0.1)
	_caso("la escala no baja del minimo", is_equal_approx(d.escalas[SALTAR], DisposicionControles.ESCALA_MINIMA))
	_caso("al achicar, el radio no baja del minimo de 48 dp", is_equal_approx(d.radio(SALTAR, TAMANO, 40.0), 40.0))
	d.fijar_escala(SALTAR, 1.0)
	var pausa: int = ControlesTactiles.ACCIONES.find(&"pausa")
	d.fijar_escala(pausa, 0.5)
	_caso("al achicar un boton por omision mas chico que el minimo, no pasa de su tamano por omision", is_equal_approx(d.radio(pausa, TAMANO, 40.0), ControlesTactiles.RADIOS[pausa] * TAMANO.y))
	_caso("el minimo no agranda un boton por omision mas chico que el", is_equal_approx(d.radio(SALTAR, TAMANO, 80.0), ControlesTactiles.RADIOS[SALTAR] * TAMANO.y))

	var area: Rect2 = DisposicionControles.area_en_vista(Rect2(0.0, 80.0, 2400.0, 1000.0), Vector2(2400.0, 1080.0), TAMANO)
	_caso("el area segura de la ventana pasa a la vista", area.is_equal_approx(Rect2(0.0, 80.0 / 1.5, 1600.0, 1000.0 / 1.5)))
	var con_barras: Rect2 = DisposicionControles.area_en_vista(Rect2(0.0, 0.0, 3200.0, 900.0), Vector2(3200.0, 900.0), Vector2(1760.0, 720.0))
	_caso("con barras, el area segura no sale de la vista", con_barras.is_equal_approx(Rect2(0.0, 0.0, 1760.0, 720.0)))
	_caso("48 dp con la holgura, a 480 dpi y al 150 %, son 38,4 px de radio", is_equal_approx(DisposicionControles.radio_minimo_en_vista(480.0, Vector2(2400.0, 1080.0), TAMANO), 38.4))


func _archivo() -> void:
	var d: DisposicionControles = DisposicionControles.por_omision()
	d.colocar(SALTAR, Vector2(300.0, 200.0), TAMANO, Rect2(Vector2.ZERO, TAMANO), 0.0)
	d.fijar_escala(SALTAR, 1.5)
	d.fijar_opacidad(0.6)
	Ajustes.disposicion = d
	Ajustes.temblor = false
	_caso("se guarda el archivo", Ajustes.guardar(RUTA_PRUEBA) == OK)
	Ajustes.disposicion = DisposicionControles.por_omision()
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("guardar y volver a leer da la misma disposicion", Ajustes.disposicion.igual_a(d))
	_caso("guardar los controles no cambia los otros ajustes", not Ajustes.temblor)

	_escribir(RUTA_PRUEBA, '{"version": 1, "ajustes": {"vibracion": false}}')
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("un archivo sin la clave controles deja la disposicion por omision", Ajustes.disposicion.igual_a(DisposicionControles.por_omision()))
	_caso("y lee los demas ajustes", not Ajustes.vibracion)

	_escribir(RUTA_PRUEBA, '{"version": 1, "ajustes": {"controles": {"opacidad": 0.01, "botones": {"saltar": {"ancla": [3, 3], "desplazamiento": [0.1, 0.1], "escala": 1.0}, "atacar": {"ancla": [0, 1], "desplazamiento": [0.3, -0.2], "escala": 7}}}}}')
	Ajustes.cargar(RUTA_PRUEBA)
	var omision: DisposicionControles = DisposicionControles.por_omision()
	_caso("un boton con un ancla que no es esquina se queda en su lugar", Ajustes.disposicion.anclas[SALTAR] == omision.anclas[SALTAR])
	_caso("un boton valido se lee aunque otro no lo sea", Ajustes.disposicion.anclas[1] == Vector2(0.0, 1.0))
	_caso("una escala fuera de rango se recorta al leerla", is_equal_approx(Ajustes.disposicion.escalas[1], DisposicionControles.ESCALA_MAXIMA))
	_caso("una opacidad fuera de rango se recorta al leerla", is_equal_approx(Ajustes.disposicion.opacidad, DisposicionControles.OPACIDAD_MINIMA))


func _toques() -> void:
	var c: ControlesTactiles = _crear_controles()
	var viejo: Vector2 = c.centro(&"saltar")
	var d: DisposicionControles = DisposicionControles.por_omision()
	var nuevo: Vector2 = c.size / 2.0
	d.colocar(SALTAR, nuevo, c.size, Rect2(Vector2.ZERO, c.size), 0.0)
	Ajustes.disposicion = d
	# process_frame llega antes del _process de los nodos: hacen falta dos cuadros.
	await get_tree().process_frame
	await get_tree().process_frame
	_caso("los controles toman la disposicion nueva sin recargar la sala", c.centro(&"saltar").is_equal_approx(nuevo))
	_tocar(c, 0, nuevo, true)
	_caso("un toque sobre el boton movido acciona su accion", Input.is_action_pressed(&"saltar"))
	_tocar(c, 0, nuevo, false)
	_tocar(c, 1, viejo, true)
	_caso("un toque sobre su lugar viejo no la acciona", not Input.is_action_pressed(&"saltar"))
	_tocar(c, 1, viejo, false)

	ControlesTactiles.editando = true
	_tocar(c, 2, c.centro(&"atacar"), true)
	_caso("con el editor abierto, los toques no accionan nada", not Input.is_action_pressed(&"atacar"))
	_tocar(c, 2, c.centro(&"atacar"), false)
	ControlesTactiles.editando = false
	c.get_parent().queue_free()
	Ajustes.disposicion = DisposicionControles.por_omision()


func _editor() -> void:
	Ajustes.disposicion = DisposicionControles.por_omision()
	var pausa: Pausa = ESCENA_PAUSA.instantiate() as Pausa
	add_child(pausa)
	pausa.abrir()
	pausa.abrir_editor()
	var e: EditorControles = pausa.editor
	_caso("abrir el editor marca que se esta editando", ControlesTactiles.editando)
	var tamano: Vector2 = e.size
	var desde: Vector2 = e.copia.centro(SALTAR, tamano)
	var hasta: Vector2 = tamano / 2.0
	_clic(e, desde, true)
	_mover(e, hasta)
	_clic(e, hasta, false)
	_caso("arrastrar Saltar lo mueve en el editor", e.copia.centro(SALTAR, e.size).is_equal_approx(hasta))
	_caso("antes de Listo, los ajustes no cambian", Ajustes.disposicion.igual_a(DisposicionControles.por_omision()))
	e.cancelar()
	await get_tree().process_frame
	_caso("Cancelar descarta lo editado", Ajustes.disposicion.igual_a(DisposicionControles.por_omision()))
	_caso("al cerrar el editor se deja de editar", not ControlesTactiles.editando)
	_caso("al cerrar el editor vuelve el panel de la pausa", pausa.editor == null and (pausa.get_node(^"Panel") as Control).visible)

	pausa.abrir_editor()
	e = pausa.editor
	e.ruta_ajustes = RUTA_PRUEBA
	_clic(e, desde, true)
	_mover(e, hasta)
	_clic(e, hasta, false)
	e.listo()
	await get_tree().process_frame
	_caso("Listo deja la disposicion nueva en Ajustes", Ajustes.disposicion.centro(SALTAR, tamano).is_equal_approx(hasta))
	Ajustes.disposicion = DisposicionControles.por_omision()
	Ajustes.cargar(RUTA_PRUEBA)
	_caso("Listo la guarda en el archivo", not Ajustes.disposicion.igual_a(DisposicionControles.por_omision()))

	pausa.abrir_editor()
	e = pausa.editor
	e.restaurar()
	_caso("Restaurar la primera vez solo pide confirmacion", not e.copia.igual_a(DisposicionControles.por_omision()))
	e.restaurar()
	_caso("Restaurar confirmado vuelve a los valores por omision", e.copia.igual_a(DisposicionControles.por_omision()))
	e.cancelar()
	await get_tree().process_frame
	pausa.cerrar()
	pausa.queue_free()


func _crear_controles() -> ControlesTactiles:
	var capa: CanvasLayer = ESCENA_CONTROLES.instantiate() as CanvasLayer
	add_child(capa)
	return capa.get_node(^"Controles") as ControlesTactiles


func _dentro(d: DisposicionControles, i: int, area: Rect2, radio_minimo: float) -> bool:
	var c: Vector2 = d.centro(i, TAMANO)
	var r: float = d.radio(i, TAMANO, radio_minimo)
	var margen: float = 0.001
	return c.x - r >= area.position.x - margen and c.x + r <= area.end.x + margen and c.y - r >= area.position.y - margen and c.y + r <= area.end.y + margen


func _tocar(c: ControlesTactiles, dedo: int, posicion: Vector2, presionado: bool) -> void:
	var toque: InputEventScreenTouch = InputEventScreenTouch.new()
	toque.index = dedo
	toque.position = posicion
	toque.pressed = presionado
	c.procesar(toque)


func _clic(e: EditorControles, posicion: Vector2, presionado: bool) -> void:
	var clic: InputEventMouseButton = InputEventMouseButton.new()
	clic.button_index = MOUSE_BUTTON_LEFT
	clic.position = posicion
	clic.pressed = presionado
	e.procesar(clic)


func _mover(e: EditorControles, posicion: Vector2) -> void:
	var movimiento: InputEventMouseMotion = InputEventMouseMotion.new()
	movimiento.position = posicion
	e.procesar(movimiento)
