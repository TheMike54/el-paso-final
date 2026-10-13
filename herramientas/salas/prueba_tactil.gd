extends Node
# Prueba de los controles tactiles sin pantalla: crea la capa, le pasa toques y arrastres
# simulados y revisa que acciones del InputMap quedan presionadas y con que fuerza. Deja en
# "casos" y "fallos" el resultado para controles_tactiles.guion. No sustituye la prueba en el
# telefono: no mira si los botones se ven bien ni si el pulgar los alcanza.
const ESCENA_CONTROLES: PackedScene = preload("res://nucleo/controles_tactiles.tscn")
const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const MOVIMIENTOS: Array[StringName] = [&"mover_izquierda", &"mover_derecha", &"mover_arriba", &"mover_abajo"]

var casos: int = 0
var fallos: int = 0


func _ready() -> void:
	# Atacar pide la pluma (el arma), como Impulso pide su habilidad.
	Partida.reiniciar()
	Partida.habilidades.append(&"pluma")
	var capa: CanvasLayer = ESCENA_CONTROLES.instantiate() as CanvasLayer
	add_child(capa)
	var c: ControlesTactiles = capa.get_node(^"Controles") as ControlesTactiles
	var corto: float = minf(c.size.x, c.size.y)
	var radio_joystick: float = ControlesTactiles.RADIO_JOYSTICK * corto

	_tocar(c, 0, c.centro(&"saltar"), true)
	_caso("tocar Saltar presiona saltar", Input.is_action_pressed(&"saltar"))
	_caso("tocar Saltar no presiona otra accion", not Input.is_action_pressed(&"atacar"))
	_tocar(c, 0, c.centro(&"saltar"), false)
	_caso("soltar Saltar suelta saltar", not Input.is_action_pressed(&"saltar"))

	var origen: Vector2 = Vector2(0.12, 0.7) * c.size
	_tocar(c, 1, origen, true)
	_caso("tocar la zona del joystick no mueve todavia", _ninguna_movida())
	_arrastrar(c, 1, origen + Vector2(0.6 * radio_joystick, 0.0))
	_caso("arrastrar a la derecha da mover_derecha con fuerza 0,6", absf(Input.get_action_strength(&"mover_derecha") - 0.6) < 0.01)
	_caso("arrastrar a la derecha no da mover_izquierda", not Input.is_action_pressed(&"mover_izquierda"))
	_arrastrar(c, 1, origen + Vector2(-3.0 * radio_joystick, 0.0))
	_caso("arrastrar lejos a la izquierda da fuerza 1", is_equal_approx(Input.get_action_strength(&"mover_izquierda"), 1.0))
	_caso("al cambiar de lado se suelta mover_derecha", not Input.is_action_pressed(&"mover_derecha"))
	_arrastrar(c, 1, origen + Vector2(0.1 * radio_joystick, 0.0))
	_caso("dentro de la zona muerta no hay movimiento", _ninguna_movida())
	_arrastrar(c, 1, origen + Vector2(0.0, -radio_joystick))
	_caso("arrastrar hacia arriba da mover_arriba", Input.is_action_pressed(&"mover_arriba"))
	_caso("arrastrar hacia arriba da tambien interactuar", Input.is_action_pressed(&"interactuar"))

	_tocar(c, 2, c.centro(&"atacar"), true)
	_caso("con el joystick en uso, otro dedo presiona atacar", Input.is_action_pressed(&"atacar"))
	_caso("el segundo dedo no suelta el joystick", Input.is_action_pressed(&"mover_arriba"))
	_tocar(c, 1, origen, false)
	_caso("soltar el joystick suelta el movimiento", _ninguna_movida())
	_caso("soltar el joystick no suelta atacar", Input.is_action_pressed(&"atacar"))
	_tocar(c, 2, c.centro(&"atacar"), false)

	_tocar(c, 3, c.size / 2.0, true)
	_caso("tocar el centro de la pantalla no presiona nada", not Input.is_action_pressed(&"saltar") and not Input.is_action_pressed(&"atacar") and _ninguna_movida())
	_tocar(c, 3, c.size / 2.0, false)

	var atras: InputEventKey = InputEventKey.new()
	atras.keycode = KEY_BACK
	atras.pressed = true
	c.procesar(atras)
	_caso("el boton Atras de Android no oculta los controles", c.visible)

	# El boton del mapa: de pie manda mapa; sentado en un banco manda inventario, y suelta lo que mando.
	_caso("ya no hay boton Mochila", not ControlesTactiles.ACCIONES.has(&"mochila"))
	_tocar(c, 12, c.centro(&"mapa"), true)
	_caso("de pie, el boton del mapa presiona mapa y no inventario", Input.is_action_pressed(&"mapa") and not Input.is_action_pressed(&"inventario"))
	_tocar(c, 12, c.centro(&"mapa"), false)
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(jugador)
	jugador.descansando = true
	_tocar(c, 12, c.centro(&"mapa"), true)
	_caso("sentado, el boton del mapa presiona inventario y no mapa", Input.is_action_pressed(&"inventario") and not Input.is_action_pressed(&"mapa"))
	# Si se levanta con el dedo encima, al soltar se suelta inventario, que fue lo que presiono.
	jugador.descansando = false
	_tocar(c, 12, c.centro(&"mapa"), false)
	_caso("soltar el boton suelta la accion que presiono aunque el jugador ya no este sentado", not Input.is_action_pressed(&"inventario") and not Input.is_action_pressed(&"mapa"))
	jugador.free()

	# El boton Impulso existe solo con la habilidad impulso; los controles la revisan cada cuadro.
	Partida.reiniciar()
	await get_tree().process_frame
	_tocar(c, 10, c.centro(&"impulso"), true)
	_caso("sin la habilidad, tocar Impulso no presiona impulso", not Input.is_action_pressed(&"impulso"))
	_tocar(c, 10, c.centro(&"impulso"), false)
	_tocar(c, 11, c.centro(&"atacar"), true)
	_caso("sin la pluma, tocar Atacar no presiona atacar", not Input.is_action_pressed(&"atacar"))
	_tocar(c, 11, c.centro(&"atacar"), false)
	Partida.habilidades.append(&"impulso")
	Eventos.habilidad_obtenida.emit(&"impulso")
	await get_tree().process_frame
	_tocar(c, 10, c.centro(&"impulso"), true)
	_caso("con la habilidad, tocar Impulso presiona impulso", Input.is_action_pressed(&"impulso"))
	Partida.reiniciar()
	await get_tree().process_frame
	_caso("al perder la habilidad con el dedo encima se suelta impulso", not Input.is_action_pressed(&"impulso"))
	_tocar(c, 10, c.centro(&"impulso"), false)
	Partida.habilidades.append(&"impulso")
	await get_tree().process_frame

	_tocar(c, 4, c.centro(&"impulso"), true)
	var tecla: InputEventKey = InputEventKey.new()
	tecla.physical_keycode = KEY_D
	tecla.pressed = true
	c.procesar(tecla)
	_caso("una tecla oculta los controles", not c.visible)
	_caso("ocultar los controles suelta lo presionado", not Input.is_action_pressed(&"impulso"))
	_tocar(c, 5, c.size / 2.0, true)
	_caso("tocar la pantalla los vuelve a mostrar", c.visible)
	_tocar(c, 5, c.size / 2.0, false)

	# Una accion que sostiene el teclado (Input la marca antes de pasar el evento a los controles).
	Input.action_press(&"mover_izquierda")
	_tocar(c, 6, origen, true)
	_arrastrar(c, 6, origen + Vector2(0.6 * radio_joystick, 0.0))
	_tocar(c, 6, origen, false)
	_caso("soltar el joystick no suelta lo que sostiene el teclado", Input.is_action_pressed(&"mover_izquierda"))
	c.procesar(tecla)
	_caso("ocultar los controles no suelta lo que sostiene el teclado", Input.is_action_pressed(&"mover_izquierda"))
	Input.action_release(&"mover_izquierda")

	# Cambio de sala o reaparicion con un dedo en la pantalla: los controles de la sala se van y
	# llegan otros, como al morir (docs/errores/2026-10-06-dedo-perdido-al-cambiar-de-sala.md).
	_tocar(c, 7, origen, true)
	_arrastrar(c, 7, origen + Vector2(-radio_joystick, 0.0))
	_tocar(c, 8, c.centro(&"atacar"), true)
	c = _cambiar_de_sala(capa)
	_caso("el dedo que sigue en el joystick al cambiar de sala sigue moviendo", Input.is_action_pressed(&"mover_izquierda"))
	_tocar(c, 7, origen, false)
	_caso("soltar ese dedo en los controles nuevos suelta el movimiento", _ninguna_movida())
	_tocar(c, 8, c.centro(&"atacar"), false)
	_caso("soltar un boton en los controles nuevos lo suelta", not Input.is_action_pressed(&"atacar"))

	# Si entre una sala y otra pasa mucho (el menu), el dedo ya no esta: se suelta todo al llegar.
	_tocar(c, 9, origen, true)
	_arrastrar(c, 9, origen + Vector2(radio_joystick, 0.0))
	var vieja: Node = c.get_parent()
	remove_child(vieja)
	vieja.free()
	for i: int in range(ControlesTactiles.CUADROS_CAMBIO_DE_SALA + 2):
		await get_tree().process_frame
	var nueva: CanvasLayer = ESCENA_CONTROLES.instantiate() as CanvasLayer
	add_child(nueva)
	_caso("tras pasar por el menu no queda movimiento presionado", _ninguna_movida())

	print("PRUEBAS controles_tactiles casos=%d fallos=%d" % [casos, fallos])


# Quita la capa de controles y pone otra en el mismo cuadro, como hace una sala nueva.
func _cambiar_de_sala(capa: CanvasLayer) -> ControlesTactiles:
	remove_child(capa)
	capa.free()
	var nueva: CanvasLayer = ESCENA_CONTROLES.instantiate() as CanvasLayer
	add_child(nueva)
	return nueva.get_node(^"Controles") as ControlesTactiles


func _tocar(c: ControlesTactiles, dedo: int, posicion: Vector2, presionado: bool) -> void:
	var toque: InputEventScreenTouch = InputEventScreenTouch.new()
	toque.index = dedo
	toque.position = posicion
	toque.pressed = presionado
	c.procesar(toque)


func _arrastrar(c: ControlesTactiles, dedo: int, posicion: Vector2) -> void:
	var arrastre: InputEventScreenDrag = InputEventScreenDrag.new()
	arrastre.index = dedo
	arrastre.position = posicion
	c.procesar(arrastre)


func _ninguna_movida() -> bool:
	for accion: StringName in MOVIMIENTOS:
		if Input.is_action_pressed(accion):
			return false
	return true


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO controles_tactiles: %s" % nombre)
