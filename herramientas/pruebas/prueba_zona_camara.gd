extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de ZonaCamara y de su pila en CamaraJugador: topes (tambien con y negativas), zonas encimadas, una zona que
# desaparece, la deteccion real del jugador, entrar y salir al instante recien colocada la camara y el lento solo si
# cambia la zona que manda. Deja casos y fallos para zona_camara.guion; imprime el resumen y solo los que fallan.

const ESCENA_SALA: PackedScene = preload("res://herramientas/salas/sala_camara.tscn")
## Limites amplios, con y negativas, para que la sala no recorte nada cerca del jugador: los topes son de la zona.
const LIMITES_GRANDES: Rect2 = Rect2(0.0, -3000.0, 3200.0, 6000.0)
## Cuanto muerde cada tope en el objetivo de la camara, en px.
const MORDIDA: float = 100.0
## Tolerancia de posicion: la camara colocada cae exacta; la que se acerca suavizando, a menos de esto.
const CERCA: float = 0.5


func _ready() -> void:
	await _al_llegar()
	var sala: Sala = await _nueva_sala(null)
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	var camara: CamaraJugador = jugador.camara()
	_capas()
	await _deteccion(sala, jugador, camara)
	jugador.fijar_limites(LIMITES_GRANDES)
	_topes(sala, jugador, camara)
	_encimadas(sala, jugador, camara)
	await _entrar_despues(sala, jugador, camara)
	await _lento_solo_si_cambia(sala, camara)
	sala.queue_free()
	Partida.reiniciar()
	_resumen()


func _nueva_sala(zona: ZonaCamara) -> Sala:
	Partida.reiniciar()
	var sala: Sala = ESCENA_SALA.instantiate() as Sala
	if zona != null:
		sala.add_child(zona)
	add_child(sala)
	await _esperar(5)
	return sala


# Zona con su forma hija sobre area (en coordenadas de la sala) y sus limites.
func _zona(area: Rect2, limites: Rect2) -> ZonaCamara:
	var caja: RectangleShape2D = RectangleShape2D.new()
	caja.size = area.size
	var forma: CollisionShape2D = CollisionShape2D.new()
	forma.shape = caja
	forma.position = area.get_center()
	var zona: ZonaCamara = ZonaCamara.new()
	zona.limites = limites
	zona.add_child(forma)
	return zona


func _media(camara: CamaraJugador) -> Vector2:
	return camara.get_viewport_rect().size / camara.zoom / 2.0


func _cerca(a: Vector2, b: Vector2) -> bool:
	return a.distance_to(b) < CERCA


func _capas() -> void:
	var zona: ZonaCamara = _zona(Rect2(0.0, 0.0, 10.0, 10.0), LIMITES_GRANDES)
	add_child(zona)
	_caso("la zona esta en interaccion y mira solo al jugador", zona.collision_layer == Capas.INTERACCION
		and zona.collision_mask == Capas.JUGADOR)
	zona.free()


# Recien llegada la sala con el jugador dentro de una zona, la camara ya esta en el tope sin suavizar: con el
# seguimiento normal tardaria mas de un segundo en recorrer esos px.
func _al_llegar() -> void:
	var limites: Rect2 = Rect2(1800.0, 0.0, 1400.0, 1440.0)
	var zona: ZonaCamara = _zona(Rect2(1400.0, 1200.0, 400.0, 240.0), limites)
	var sala: Sala = await _nueva_sala(zona)
	var camara: CamaraJugador = (sala.get_node(^"Jugador") as Jugador).camara()
	var media: Vector2 = _media(camara)
	_caso("al llegar a la sala dentro de una zona la camara se coloca al instante en su tope",
		camara.limites_vista() == limites and absf(camara.global_position.x - (limites.position.x + media.x)) < CERCA)
	sala.queue_free()
	await _esperar(1)


# Con la fisica real: entrar a la forma de la zona la hace mandar y salir la suelta.
func _deteccion(sala: Sala, jugador: Jugador, camara: CamaraJugador) -> void:
	var limites: Rect2 = Rect2(0.0, 0.0, 1600.0, 1440.0)
	var zona: ZonaCamara = _zona(Rect2(0.0, 1000.0, 1200.0, 440.0), limites)
	sala.add_child(zona)
	jugador.global_position = Vector2(1000.0, 1400.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(3)
	_caso("el jugador que entra a la forma hace mandar a la zona", camara.limites_vista() == limites)
	jugador.global_position = Vector2(1600.0, 1400.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(3)
	_caso("el jugador que sale de la forma devuelve la camara a la sala", camara.limites_vista() == sala.limites)
	zona.free()


# Cada tope muerde MORDIDA px en el objetivo sin zona, y los de y negativa topan igual que los demas.
func _topes(sala: Sala, jugador: Jugador, camara: CamaraJugador) -> void:
	var pies: Vector2 = jugador.global_position
	var media: Vector2 = _media(camara)
	camara.colocar(pies, 1.0)
	var libre: Vector2 = camara.global_position
	var g: Rect2 = LIMITES_GRANDES
	var casos_tope: Dictionary[String, Array] = {
		"izquierdo": [Rect2(libre.x - media.x + MORDIDA, g.position.y, g.end.x - (libre.x - media.x + MORDIDA), g.size.y),
			libre + Vector2(MORDIDA, 0.0)],
		"derecho": [Rect2(g.position.x, g.position.y, libre.x + media.x - MORDIDA, g.size.y), libre - Vector2(MORDIDA, 0.0)],
		"de arriba": [Rect2(g.position.x, libre.y - media.y + MORDIDA, g.size.x, g.end.y - (libre.y - media.y + MORDIDA)),
			libre + Vector2(0.0, MORDIDA)],
		"de abajo": [Rect2(g.position.x, g.position.y, g.size.x, libre.y + media.y - MORDIDA - g.position.y),
			libre - Vector2(0.0, MORDIDA)],
		# Todo en y negativas, lejos sobre el jugador: el tope de abajo queda en y = -1000.
		"de abajo en y negativas": [Rect2(g.position.x, -3000.0, g.size.x, 2000.0), Vector2(libre.x, -1000.0 - media.y)],
	}
	for nombre: String in casos_tope:
		var limites: Rect2 = casos_tope[nombre][0]
		var esperado: Vector2 = casos_tope[nombre][1]
		var zona: ZonaCamara = _zona(Rect2(), limites)
		sala.add_child(zona)
		camara.entrar_zona(zona)
		camara.colocar(pies, 1.0)
		_caso("el tope %s de la zona recorta el objetivo" % nombre, _cerca(camara.global_position, esperado))
		camara.salir_zona(zona)
		zona.free()
	camara.colocar(pies, 1.0)
	_caso("sin zona la camara vuelve al objetivo de la sala", _cerca(camara.global_position, libre))
	# Reaparecer fuera de la zona: colocar todavia recorta con ella y la salida llega despues; recien colocada, la
	# camara salta al objetivo de la sala en vez de deslizarse desde el tope.
	var limites_viejos: Rect2 = casos_tope["izquierdo"][0]
	var zona_vieja: ZonaCamara = _zona(Rect2(), limites_viejos)
	sala.add_child(zona_vieja)
	camara.entrar_zona(zona_vieja)
	camara.colocar(pies, 1.0)
	camara.salir_zona(zona_vieja)
	_caso("salir de una zona recien colocada salta al objetivo de la sala", _cerca(camara.global_position, libre))
	zona_vieja.free()


func _encimadas(sala: Sala, jugador: Jugador, camara: CamaraJugador) -> void:
	var a: ZonaCamara = _zona(Rect2(), Rect2(0.0, -3000.0, 2000.0, 6000.0))
	var b: ZonaCamara = _zona(Rect2(), Rect2(0.0, -3000.0, 3200.0, 4000.0))
	sala.add_child(a)
	sala.add_child(b)
	var de_a: Rect2 = LIMITES_GRANDES.intersection(a.limites)
	var de_b: Rect2 = LIMITES_GRANDES.intersection(b.limites)
	camara.entrar_zona(a)
	camara.entrar_zona(b)
	_caso("con dos zonas encimadas manda la ultima en que entro", camara.limites_vista() == de_b)
	camara.salir_zona(b)
	_caso("al salir de la segunda vuelve a mandar la primera", camara.limites_vista() == de_a)
	camara.entrar_zona(b)
	camara.salir_zona(a)
	_caso("al salir de la primera sigue mandando la segunda", camara.limites_vista() == de_b)
	camara.entrar_zona(a)
	_caso("volver a entrar a una zona la hace mandar otra vez", camara.limites_vista() == de_a)
	camara.salir_zona(a)
	camara.salir_zona(b)
	_caso("al salir de las dos vuelve a mandar la sala", camara.limites_vista() == LIMITES_GRANDES)
	camara.entrar_zona(b)
	b.free()
	_caso("una zona que desaparece con el jugador dentro deja de mandar", camara.limites_vista() == LIMITES_GRANDES)
	a.free()
	camara.colocar(jugador.global_position, 1.0)


# Pasado el medio segundo tras colocarla, entrar a una zona no salta: la camara la alcanza con el seguimiento lento y
# llega a su tope.
func _entrar_despues(sala: Sala, jugador: Jugador, camara: CamaraJugador) -> void:
	await _esperar(CamaraJugador.TICKS_AL_INSTANTE + 5)
	var media: Vector2 = _media(camara)
	var antes: Vector2 = camara.global_position
	var tope_x: float = antes.x + 400.0
	var g: Rect2 = LIMITES_GRANDES
	var zona: ZonaCamara = _zona(Rect2(), Rect2(tope_x - media.x, g.position.y, g.end.x - (tope_x - media.x), g.size.y))
	sala.add_child(zona)
	camara.entrar_zona(zona)
	_caso("entrar a una zona despues de llegar no coloca la camara al instante", _cerca(camara.global_position, antes))
	await _esperar(1)
	var avance: float = camara.global_position.x - antes.x
	# Con el seguimiento normal el primer tick avanzaria suavizado_camara_x / 60 de los 400 px.
	var normal: float = 400.0 * camara.suavizado_camara_x / 60.0
	_caso("entrar a una zona sigue lento el primer tick", avance > 0.0 and avance < normal / 2.0)
	await _esperar(300)
	_caso("la camara llega al tope de la zona", absf(camara.global_position.x - tope_x) < CERCA)
	camara.salir_zona(zona)
	zona.free()


# Pasado el medio segundo, el seguimiento lento solo arranca si cambia la zona que manda: salir de una que no manda o
# volver a entrar a la que ya manda no cambia la vista.
func _lento_solo_si_cambia(sala: Sala, camara: CamaraJugador) -> void:
	var a: ZonaCamara = _zona(Rect2(), LIMITES_GRANDES)
	var b: ZonaCamara = _zona(Rect2(), LIMITES_GRANDES)
	sala.add_child(a)
	sala.add_child(b)
	camara.entrar_zona(a)
	camara.entrar_zona(b)
	await _esperar(CamaraJugador.TICKS_LENTO + 2)
	camara.salir_zona(a)
	_caso("salir de una zona que no manda no frena el seguimiento", camara._ticks_lento == 0)
	camara.entrar_zona(b)
	_caso("volver a entrar a la zona que ya manda no frena el seguimiento", camara._ticks_lento == 0)
	camara.salir_zona(b)
	_caso("salir de la zona que manda activa el seguimiento lento", camara._ticks_lento == CamaraJugador.TICKS_LENTO)
	a.free()
	b.free()
