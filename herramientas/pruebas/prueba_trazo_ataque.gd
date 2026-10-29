extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del trazo del ataque (TrazoAtaque): donde queda y hacia donde mira en cada direccion y lado, y sus ticks
# (aparece tras el retraso, se apaga al terminar y se queda quieto en el congelado), y que solo los ataques enemigos
# que se pueden parar lo tengan. Deja casos y fallos para
# trazo_ataque.guion.

const AREA: Vector2 = Vector2(90.0, -90.0)


func _ready() -> void:
	var derecha: Transform2D = TrazoAtaque.pose(AREA, TrazoAtaque.Direccion.LADO, 1.0)
	_caso("de lado a la derecha: detras del centro del area y sin girar", derecha.origin.is_equal_approx(AREA + TrazoAtaque.DESDE_AREA) and derecha.x.is_equal_approx(Vector2.RIGHT))
	var izquierda: Transform2D = TrazoAtaque.pose(Vector2(-AREA.x, AREA.y), TrazoAtaque.Direccion.LADO, -1.0)
	_caso("a la izquierda: espejado, del otro lado", izquierda.origin.is_equal_approx(Vector2(-AREA.x - TrazoAtaque.DESDE_AREA.x, AREA.y + TrazoAtaque.DESDE_AREA.y)) and izquierda.x.is_equal_approx(Vector2.LEFT))
	var arriba: Transform2D = TrazoAtaque.pose(Vector2(0.0, -210.0), TrazoAtaque.Direccion.ARRIBA, 1.0)
	_caso("arriba: la parte de delante apunta arriba y el centro queda debajo del area", arriba.x.is_equal_approx(Vector2.UP) and arriba.origin.y > -210.0)
	var arriba_izquierda: Transform2D = TrazoAtaque.pose(Vector2(0.0, -210.0), TrazoAtaque.Direccion.ARRIBA, -1.0)
	_caso("arriba mirando a la izquierda: tambien apunta arriba, espejado", arriba_izquierda.x.is_equal_approx(Vector2.UP) and arriba_izquierda.y.is_equal_approx(-arriba.y))
	var abajo: Transform2D = TrazoAtaque.pose(Vector2(0.0, 50.0), TrazoAtaque.Direccion.ABAJO, 1.0)
	_caso("abajo: apunta abajo y el centro queda encima del area", abajo.x.is_equal_approx(Vector2.DOWN) and abajo.origin.y < 50.0)

	var trazo: TrazoAtaque = TrazoAtaque.new()
	add_child(trazo)
	trazo.mostrar(AREA, TrazoAtaque.Direccion.LADO, 1.0)
	# Tras un await de physics_frame, el _physics_process de ese tick todavia no corrio: n esperas, n - 1 ticks.
	await _esperar(TrazoAtaque.TICKS_RETRASO)
	var oculto_antes: bool = not trazo.visible
	await _esperar(1)
	_caso("aparece tras el retraso, no antes", oculto_antes and trazo.visible)
	var alfa: float = trazo.modulate.a
	Congelado.pedir(10)
	await _esperar(3)
	_caso("en el congelado no avanza", trazo.modulate.a == alfa and trazo.visible)
	Congelado.reiniciar()
	await _esperar(TrazoAtaque.TICKS_DURA + 1)
	_caso("se apaga al terminar y deja de procesar", not trazo.visible and not trazo.is_physics_processing())

	# Un ataque enemigo que se puede parar deja su trazo hacia donde pega; uno que no, ninguno.
	var parable: AtaqueEnemigo = AtaqueEnemigo.crear(Rect2(-100.0, -60.0, 60.0, 40.0), 30, 1, true)
	add_child(parable)
	var trazo_enemigo: TrazoAtaque = parable.get_node_or_null(^"Trazo") as TrazoAtaque
	_caso("el ataque parable tiene trazo, mirando hacia donde pega", trazo_enemigo != null and trazo_enemigo.is_physics_processing())
	var no_parable: AtaqueEnemigo = AtaqueEnemigo.crear(Rect2(40.0, -60.0, 60.0, 40.0), 30, 1, false)
	add_child(no_parable)
	_caso("el que no se puede parar no tiene trazo", no_parable.get_node_or_null(^"Trazo") == null)
	var disparo: ProyectilEnemigo = ProyectilEnemigo.crear_disparo(Vector2.RIGHT, 1, true)
	add_child(disparo)
	_caso("un proyectil parable no lleva trazo", disparo.get_node_or_null(^"Trazo") == null)
	_resumen()
