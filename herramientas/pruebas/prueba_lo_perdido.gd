extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de lo perdido al morir sobre la sala Lo Perdido: morir con monedas deja la mochila en el ultimo punto seguro
# antes de guardar, sin monedas no la toca y morir otra vez la reemplaza; la Mochila aparece solo en su sala, el reto
# la devuelve con la meta y al perder se va (una sola oportunidad), sin bolsa se recupera al interactuar y un golpe
# corta el reto sin contar y el siguiente sortea otras preguntas. La sala se suelta antes de que la muerte la recargue. Su guion lee "valor . casos" y "valor . fallos".
const SALA: String = "res://herramientas/salas/sala_lo_perdido.tscn"
const OTRA_SALA: String = "res://herramientas/salas/sala_reto.tscn"
const BOLSA_PRUEBA: String = "res://herramientas/salas/preguntas_mochila_prueba.tres"

var _recuperadas: Array[int] = []


func _ready() -> void:
	_aislar_partida()
	Eventos.mochila_recuperada.connect(_al_recuperar)
	_cuentas()
	await _morir_en_la_sala()
	await _aparece_solo_en_su_sala()
	await _reto()
	_restaurar_partida()
	_resumen()


func _al_recuperar(monto: int) -> void:
	_recuperadas.append(monto)


func _cuentas() -> void:
	Partida.monedas = 70
	Partida.dejar_mochila("sala_a", Vector2(100.0, 200.0))
	_caso("con monedas, todas pasan a la mochila en ese punto", Partida.monedas == 0 and Partida.mochila == {"sala": "sala_a", "x": 100.0, "y": 200.0, "monto": 70})
	Partida.dejar_mochila("sala_b", Vector2(5.0, 5.0))
	_caso("sin monedas la mochila anterior sigue donde estaba", str(Partida.mochila.get("sala")) == "sala_a" and Partida.monto_mochila() == 70)
	Partida.monedas = 30
	Partida.dejar_mochila("sala_b", Vector2(5.0, 5.0))
	_caso("morir otra vez con monedas la reemplaza y la anterior se pierde", str(Partida.mochila.get("sala")) == "sala_b" and Partida.monto_mochila() == 30)
	Partida.guardar(Partida.RUTA_PRUEBAS)
	Partida.reiniciar()
	var leida: Guardado.Resultado = Guardado.cargar(Partida.RUTA_PRUEBAS)
	Partida.desde_diccionario(leida.partida)
	_caso("el guardado la lleva y el monto vuelve como numero", str(Partida.mochila.get("sala")) == "sala_b" and Partida.monto_mochila() == 30)
	var bolsa: BolsaPreguntas = load(BOLSA_PRUEBA) as BolsaPreguntas
	var corta: BolsaPreguntas = BolsaPreguntas.new()
	corta.preguntas = [bolsa.preguntas[0], bolsa.preguntas[1]]
	corta.meta = 4
	_caso("la bolsa de prueba esta bien y una corta con meta de mas no", bolsa.fallos().is_empty() and corta.fallos().size() == 2)
	Partida.reiniciar()


# Morir de verdad en el pincho: la mochila queda en el ultimo punto seguro y el autoguardado de la muerte ya la lleva.
func _morir_en_la_sala() -> void:
	Partida.reiniciar()
	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	_caso("la sala da monedas al entrar y deja una vida", Partida.monedas == 120 and Partida.vidas == 1)
	jugador.global_position = Vector2(1300.0, 680.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(40)
	var seguro: Vector2 = jugador.ultimo_punto_seguro()
	jugador.recibir_dano(1, 0.0, true)
	await get_tree().physics_frame
	var guardada: Guardado.Resultado = Guardado.cargar(Partida.RUTA_PRUEBAS)
	var en_archivo: Dictionary = guardada.partida.get("mochila", {}) if guardada.estado == Guardado.Estado.VALIDA else {}
	_caso("morir deja la mochila en el ultimo punto seguro y las monedas en 0", jugador.muerto and Partida.monedas == 0 and str(Partida.mochila.get("sala")) == sala.clave() and Vector2(Partida.mochila["x"] as float, Partida.mochila["y"] as float).is_equal_approx(seguro) and seguro.distance_to(Vector2(1300.0, 680.0)) < 2.0)
	_caso("el autoguardado de la muerte ya la lleva", (en_archivo.get("monto", 0.0) as float) == 120.0)
	# Antes de los 90 ticks de la muerte: si no, la sala recarga la escena de la prueba.
	sala.free()


func _aparece_solo_en_su_sala() -> void:
	Partida.reiniciar()
	Partida.mochila = {"sala": SALA, "x": 900.0, "y": 680.0, "monto": 50}
	var otra: Sala = (load(OTRA_SALA) as PackedScene).instantiate() as Sala
	add_child(otra)
	await get_tree().physics_frame
	var en_otra: bool = otra.get_node_or_null(^"Mochila") != null
	otra.free()
	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await get_tree().physics_frame
	var mochila: Mochila = sala.get_node_or_null(^"Mochila") as Mochila
	_caso("la mochila aparece solo en su sala y en su punto", not en_otra and mochila != null and mochila.position.is_equal_approx(Vector2(900.0, 680.0)))
	sala.free()
	# Fuera de la sala de prueba solo vale la bolsa del juego: el paquete publicado lleva herramientas/ y no debe
	# mostrar las preguntas de prueba.
	var suelta: Mochila = Mochila.new()
	add_child(suelta)
	var esperada: Resource = load(Mochila.BOLSA_JUEGO) if ResourceLoader.exists(Mochila.BOLSA_JUEGO) else null
	_caso("una mochila fuera de la sala de prueba solo usa la bolsa del juego", suelta.bolsa == esperada)
	suelta.free()


func _reto() -> void:
	Partida.reiniciar()
	Partida.mochila = {"sala": SALA, "x": 900.0, "y": 680.0, "monto": 50}
	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	Partida.vidas = 4
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	var mochila: Mochila = sala.get_node(^"Mochila") as Mochila
	var monedas: int = Partida.monedas
	jugador.global_position = Vector2(900.0, 680.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(40)

	await _presionar(&"interactuar")
	_caso("interactuar abre la caja con la entrada, tres preguntas, sus respuestas y el final", mochila.caja != null and jugador.hablando and mochila.caja.ficha.lineas.size() == 8)
	var primeras: Array[int] = mochila.sorteadas.duplicate()

	# Un golpe corta el reto sin contar, y el intento siguiente no repite ninguna pregunta.
	mochila.responder(_mala(mochila.pregunta_actual()))
	mochila.responder(_mala(mochila.pregunta_actual()))
	jugador.recibir_dano(1, 0.0)
	await _esperar(2)
	_caso("un golpe corta el reto sin contar", mochila.caja == null and not jugador.hablando and not mochila.recuperada and not mochila.perdida and Partida.monto_mochila() == 50)
	await _esperar(80)
	mochila.empezar(jugador)
	var repetidas: int = 0
	for indice: int in mochila.sorteadas:
		if primeras.has(indice):
			repetidas += 1
	_caso("tras el golpe el intento siguiente usa otras preguntas", mochila.sorteadas.size() == 3 and repetidas == 0)

	# Ganar con dos de tres: devuelve el monto exacto, la vacia, lo avisa, autoguarda y desaparece al cerrar.
	var guardados: int = Partida.autoguardados
	mochila.responder(mochila.pregunta_actual().correcta)
	mochila.responder(_mala(mochila.pregunta_actual()))
	mochila.responder(mochila.pregunta_actual().correcta)
	_caso("dos de tres devuelve el monto exacto, la vacia, lo avisa y autoguarda", mochila.recuperada and Partida.monedas == monedas + 50 and Partida.mochila.is_empty() and _recuperadas == [50] and Partida.autoguardados == guardados + 1)
	mochila.caja.terminada.emit(true)
	await get_tree().physics_frame
	_caso("al cerrar la caja la mochila desaparece", not is_instance_valid(mochila))
	sala.free()

	# Perder: una sola oportunidad. Sin la meta la mochila se va sin devolver nada, autoguarda y desaparece al cerrar.
	Partida.mochila = {"sala": SALA, "x": 900.0, "y": 680.0, "monto": 50}
	sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	jugador = sala.get_node(^"Jugador") as Jugador
	mochila = sala.get_node(^"Mochila") as Mochila
	monedas = Partida.monedas
	jugador.global_position = Vector2(900.0, 680.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(40)
	mochila.empezar(jugador)
	guardados = Partida.autoguardados
	mochila.responder(mochila.pregunta_actual().correcta)
	mochila.responder(_mala(mochila.pregunta_actual()))
	mochila.responder(_mala(mochila.pregunta_actual()))
	_caso("perder el reto vacia la mochila sin devolver nada y autoguarda", mochila.perdida and not mochila.recuperada and Partida.mochila.is_empty() and Partida.monedas == monedas and _recuperadas == [50] and Partida.autoguardados == guardados + 1)
	mochila.caja.terminada.emit(true)
	await get_tree().physics_frame
	_caso("al cerrar la caja la mochila perdida desaparece", not is_instance_valid(mochila) and not jugador.hablando)
	sala.free()

	# Sin bolsa se recupera al interactuar.
	Partida.mochila = {"sala": SALA, "x": 900.0, "y": 680.0, "monto": 20}
	sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	jugador = sala.get_node(^"Jugador") as Jugador
	mochila = sala.get_node(^"Mochila") as Mochila
	mochila.bolsa = null
	monedas = Partida.monedas
	jugador.global_position = Vector2(900.0, 680.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(40)
	await _presionar(&"interactuar")
	_caso("sin bolsa se recupera al interactuar", Partida.mochila.is_empty() and Partida.monedas == monedas + 20 and not is_instance_valid(mochila))
	sala.free()


func _mala(pregunta: FichaPregunta) -> int:
	return (pregunta.correcta + 1) % pregunta.opciones.size()
