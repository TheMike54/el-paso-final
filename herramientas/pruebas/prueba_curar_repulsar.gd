extends "res://herramientas/pruebas/prueba_base.gd"
# Curar soltado y vuelto a pulsar entre dos ticks (#55): el tick no ve la soltada. Con la Inspiracion maxima subida
# (Modulo de RAM, 66) la curacion en curso no se cortaba y la pulsacion nueva emitia otra curacion_empezada encima.
# Comprueba que se corta, devuelve lo gastado y que cada curacion_empezada tiene su final antes de la siguiente.
# El guion comprueba el resultado leyendo "valor . casos" y "valor . fallos".
const SALA: String = "res://herramientas/salas/zonas/prueba/prueba_4.tscn"
# Ticks con curar mantenido antes de soltar y pulsar: la curacion ya empezo (ticks_mantener_poder) y va antes de
# ticks_devolver_curacion.
const TICKS_ANTES: int = 20
# Ticks que se mantiene la pulsacion nueva: alcanza para empezar y terminar otra curacion.
const TICKS_DESPUES: int = 90

var _jugador: Jugador = null
var _empezadas: int = 0
var _cortadas: int = 0
var _curadas: int = 0
# curacion_empezada mientras otra seguia sin cortarse ni terminar.
var _encimadas: int = 0
var _en_curso: bool = false


func _ready() -> void:
	_aislar_partida()
	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	_jugador = sala.get_node(^"Jugador") as Jugador
	var estacion: Estacion = sala.get_node(^"Estacion") as Estacion
	_jugador.global_position = estacion.global_position
	_jugador.velocity = Vector2.ZERO
	await _esperar(30)
	Partida.inspiracion_maxima = 66
	Partida.inspiracion = 66
	_jugador.vidas = Partida.vidas_maximas - 1
	Eventos.curacion_empezada.connect(_al_empezar)
	Eventos.curacion_cortada.connect(_al_terminar.bind(true))
	Eventos.jugador_curado.connect(func(_v: int) -> void: _al_terminar(false))

	Input.action_press(&"curar")
	await _esperar(TICKS_ANTES)
	var curando_antes: bool = _jugador.curando
	# Soltar y pulsar fuera del tick, como dos eventos que llegan en el mismo cuadro.
	await get_tree().process_frame
	Input.action_release(&"curar")
	Input.action_press(&"curar")
	await _esperar(2)
	_caso("curaba antes de soltar y pulsar", curando_antes)
	_caso("soltar y pulsar entre dos ticks corta la curacion (%d cortadas)" % _cortadas, _cortadas == 1)
	_caso("la curacion cortada devuelve lo gastado (Inspiracion %d)" % Partida.inspiracion, Partida.inspiracion == 66)
	await _esperar(TICKS_DESPUES)
	Input.action_release(&"curar")
	await _esperar(3)
	_caso("ninguna curacion_empezada sale con otra en curso (%d encimadas, %d empezadas)" % [_encimadas, _empezadas], _encimadas == 0 and _empezadas == 2)
	_caso("la pulsacion nueva cura una vida con su costo (vidas %d, Inspiracion %d)" % [_jugador.vidas, Partida.inspiracion],
			_curadas == 1 and _jugador.vidas == Partida.vidas_maximas and Partida.inspiracion == 33)

	sala.free()
	_restaurar_partida()
	_resumen()


func _al_empezar() -> void:
	_empezadas += 1
	if _en_curso:
		_encimadas += 1
	_en_curso = true


func _al_terminar(cortada: bool) -> void:
	if cortada:
		_cortadas += 1
	else:
		_curadas += 1
	_en_curso = false
