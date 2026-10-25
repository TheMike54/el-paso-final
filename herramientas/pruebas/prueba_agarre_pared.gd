extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de altura_agarre_pared: un jugador con salto_en_pared cae empujando contra una pared cuya esquina de
# arriba le queda a 48 px de los pies (el 70 % del cuerpo por encima). En 0, como hoy, se sostiene; en 0,5 ya no,
# y con la pared entera a su lado se sostiene igual. agarre_pared.guion lee "casos" y "fallos".
const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
## Cara izquierda de la pared y su esquina de arriba.
const CARA: float = 600.0
const ESQUINA: float = 400.0
const BAJO_ESQUINA: float = 48.0


func _ready() -> void:
	Partida.reiniciar()
	Partida.habilidades.append(Habilidades.SALTO_EN_PARED)
	var pared: StaticBody2D = StaticBody2D.new()
	var forma: CollisionShape2D = CollisionShape2D.new()
	var rectangulo: RectangleShape2D = RectangleShape2D.new()
	rectangulo.size = Vector2(80.0, 800.0)
	forma.shape = rectangulo
	forma.position = Vector2(CARA + 40.0, ESQUINA + 400.0)
	pared.add_child(forma)
	add_child(pared)
	_caso("en 0 se sostiene con el 70 % del cuerpo por encima", await _sostenido(0.0, ESQUINA + BAJO_ESQUINA))
	_caso("en 0,5 no se sostiene con el 70 % del cuerpo por encima", not await _sostenido(0.5, ESQUINA + BAJO_ESQUINA))
	_caso("en 0,5 se sostiene con la pared a todo lo alto", await _sostenido(0.5, ESQUINA + 300.0))
	Input.action_release(&"mover_derecha")
	Partida.reiniciar()
	_resumen()


# Un jugador nuevo con los pies en pies_y, pegado a la cara de la pared, empuja hacia ella unos ticks.
func _sostenido(altura: float, pies_y: float) -> bool:
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.altura_agarre_pared = altura
	jugador.position = Vector2(CARA - Jugador.TAMANO.x / 2.0 - 1.0, pies_y)
	add_child(jugador)
	Input.action_press(&"mover_derecha")
	await _esperar(4)
	var sostenido: bool = jugador.en_pared
	Input.action_release(&"mover_derecha")
	jugador.free()
	await _esperar(1)
	return sostenido
