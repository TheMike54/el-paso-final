extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de que A (aceptar y saltar) pulsado y soltado en el mismo cuadro sobre un boton que quita la pausa (Continuar,
# No del CobroEstacion, Volver del marco) lo cierra sin que el jugador salte (ni en cola ni con el coyote) ni se levante
# del banco, que saltar pulsado en el tick siguiente si salta, y que A apretado en un cuadro y soltado en el siguiente
# sin tick de fisica entre los dos (pasa a 120 FPS) tampoco salta. Manda eventos de verdad (Input.parse_input_event): el
# boton solo se pulsa con un evento. Su guion lee "valor . casos" y "valor . fallos".
const SALA: String = "res://herramientas/salas/zonas/prueba/prueba_4.tscn"
# Ticks que se mira al jugador tras cerrar: un salto sube decenas de px en ese tiempo.
const TICKS_MIRAR: int = 20
# Lo que tiene que subir para contar como salto, en px.
const SUBIDA_SALTO: float = 4.0
# Ticks por segundo de la fisica en el caso de 120 FPS: con --fixed-fps 60, un tick cada dos cuadros.
const TICKS_LENTOS: int = 30

var _jugador: Jugador = null


func _ready() -> void:
	_aislar_partida()
	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	_jugador = sala.get_node(^"Jugador") as Jugador
	var estacion: Estacion = sala.get_node(^"Estacion") as Estacion
	var pausa: Pausa = sala.get_node(^"Pausa") as Pausa
	var marco: MarcoMenus = sala.get_node(^"Marco") as MarcoMenus
	var punto: Vector2 = estacion.global_position
	await _parar_en(punto)

	pausa.abrir()
	await _esperar(2)
	var subida: float = await _aceptar_y_medir()
	_caso("A en Continuar cierra la pausa sin saltar (subio %.1f px)" % subida, not pausa.abierta and not get_tree().paused and subida < SUBIDA_SALTO)

	await _parar_en(punto)
	estacion.interactuar(_jugador)
	await _esperar(2)
	var cobro: CobroEstacion = estacion.cobro
	# Al cerrarse se libera: se anota antes si estaba abierto.
	var con_cobro: bool = cobro != null
	if con_cobro:
		Tema.dar_foco(cobro.confirmacion.no)
	subida = await _aceptar_y_medir()
	_caso("A en el No del cobro lo cierra sin saltar (subio %.1f px)" % subida, con_cobro and estacion.cobro == null and not get_tree().paused and subida < SUBIDA_SALTO)

	await _parar_en(punto)
	marco.abrir(&"inventario")
	await _esperar(2)
	var volver: Button = marco.find_child("Volver", true, false) as Button
	if volver != null:
		Tema.dar_foco(volver)
	subida = await _aceptar_y_medir()
	_caso("A en Volver del marco lo cierra sin saltar (subio %.1f px)" % subida, volver != null and not marco.abierta and not get_tree().paused and subida < SUBIDA_SALTO)

	# Cerca del suelo y cayendo: la pulsacion que cerro la pausa no queda como salto en cola ni salta con el coyote.
	await _parar_en(punto)
	_jugador.global_position = punto + Vector2(0.0, -20.0)
	_jugador.velocity = Vector2(0.0, 600.0)
	pausa.abrir()
	await _esperar(2)
	subida = await _aceptar_y_medir()
	_caso("A al cerrar la pausa en el aire no salta al aterrizar (subio %.1f px)" % subida, not get_tree().paused and subida < SUBIDA_SALTO and _jugador.is_on_floor())

	# Sentado (como en un banco): la pulsacion que cerro la pausa no lo levanta.
	await _parar_en(punto)
	_jugador.descansando = true
	pausa.abrir()
	await _esperar(2)
	await _aceptar()
	await _esperar(3)
	var sentado: bool = _jugador.descansando
	_jugador.descansando = false
	_caso("A al cerrar la pausa sentado no lo levanta", not get_tree().paused and sentado)

	# Una pulsacion nueva de saltar en el tick siguiente al cierre si salta.
	await _parar_en(punto)
	pausa.abrir()
	await _esperar(2)
	var y: float = _jugador.global_position.y
	await _aceptar()
	await get_tree().physics_frame
	Input.action_press(&"saltar")
	var minima: float = await _minima_y(TICKS_MIRAR)
	Input.action_release(&"saltar")
	_caso("saltar pulsado en el tick siguiente al cierre si salta (subio %.1f px)" % (y - minima), not get_tree().paused and y - minima > SUBIDA_SALTO)

	# A 120 FPS A puede bajar en un cuadro y subir en el siguiente sin tick entre medio: al quitarse la pausa saltar ya no
	# esta recien pulsada fuera de la fisica, pero el tick siguiente si la lee asi.
	await _parar_en(punto)
	pausa.abrir()
	await _esperar(2)
	y = _jugador.global_position.y
	var ticks_antes: int = Engine.physics_ticks_per_second
	Engine.physics_ticks_per_second = TICKS_LENTOS
	var sin_tick: bool = await _aceptar_en_dos_cuadros()
	await get_tree().physics_frame
	Engine.physics_ticks_per_second = ticks_antes
	minima = await _minima_y(TICKS_MIRAR)
	_caso("A apretado y soltado en dos cuadros sin tick entre medio cierra la pausa sin saltar (subio %.1f px)" % (y - minima), sin_tick and not get_tree().paused and y - minima < SUBIDA_SALTO)

	await _esperar(30)
	sala.free()
	get_tree().paused = false
	_restaurar_partida()
	_resumen()


# Deja al jugador quieto en el suelo en punto.
func _parar_en(punto: Vector2) -> void:
	Input.action_release(&"saltar")
	_jugador.global_position = punto
	_jugador.velocity = Vector2.ZERO
	await _esperar(30)


# A del control, apretado y soltado en el mismo cuadro, mandado fuera del tick como llega un evento real.
func _aceptar() -> void:
	await get_tree().process_frame
	for apretado: bool in [true, false]:
		var evento: InputEventJoypadButton = InputEventJoypadButton.new()
		evento.button_index = JOY_BUTTON_A
		evento.pressed = apretado
		Input.parse_input_event(evento)


# A del control apretado en un cuadro y soltado en el siguiente, sin tick de fisica entre los dos: la bajada se manda en
# el _process de un cuadro con tick, cuando los ticks ya alternan (con tick, sin tick, con tick: justo tras cambiar
# TICKS_LENTOS puede haber dos con tick seguidos), y se despacha al empezar el siguiente, que no lo tiene; la subida, que
# pulsa el boton, se despacha al empezar el de despues. Devuelve si de verdad no hubo tick entre las dos y la bajada sola
# no quito la pausa.
func _aceptar_en_dos_cuadros() -> bool:
	await get_tree().process_frame
	var tick: int = Engine.get_physics_frames()
	# Ultimos cuadros, el mas nuevo al final: 1 con tick, 0 sin tick.
	var cuadros: String = ""
	while not cuadros.ends_with("101"):
		await get_tree().process_frame
		cuadros += "1" if Engine.get_physics_frames() != tick else "0"
		tick = Engine.get_physics_frames()
	var evento: InputEventJoypadButton = InputEventJoypadButton.new()
	evento.button_index = JOY_BUTTON_A
	evento.pressed = true
	Input.parse_input_event(evento)
	var al_bajar: int = Engine.get_physics_frames()
	await get_tree().process_frame
	var al_subir: int = Engine.get_physics_frames()
	var en_pausa: bool = get_tree().paused
	var suelta: InputEventJoypadButton = InputEventJoypadButton.new()
	suelta.button_index = JOY_BUTTON_A
	suelta.pressed = false
	Input.parse_input_event(suelta)
	return al_subir == al_bajar and en_pausa


# Cierra con A y devuelve cuanto subio el jugador en los ticks siguientes, en px.
func _aceptar_y_medir() -> float:
	var y: float = _jugador.global_position.y
	await _aceptar()
	var minima: float = await _minima_y(TICKS_MIRAR)
	return y - minima


func _minima_y(ticks: int) -> float:
	var minima: float = _jugador.global_position.y
	for i: int in range(ticks):
		await get_tree().physics_frame
		minima = minf(minima, _jugador.global_position.y)
	return minima
