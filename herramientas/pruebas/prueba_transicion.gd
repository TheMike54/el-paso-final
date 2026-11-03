extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del cruce de puertas: inmunidad y sin interactuar en transicion, clip de entrar_puerta hasta el negro, el
# Fundido de la sala (desde un hijo, sin muerte, sin cambio doble, sin congelar el aclarado) y la llegada con su
# transicion y su punto seguro. Deja casos y fallos para transicion.guion (clave valor) e imprime el resumen y solo los
# que fallan.
const RUTA: String = "user://prueba_transicion.json"
const PRUEBA_3: String = "res://herramientas/salas/zonas/prueba/prueba_3.tscn"
const ESCENA_PUERTA: PackedScene = preload("res://nucleo/puerta.tscn")
const CUADROS: SpriteFrames = preload("res://nucleo/arte/jugador_hombre/jugador_hombre.tres")
## Puerta de techo que se agrega a prueba_3: arriba al centro, llega en el aire y su punto seguro esta en el suelo.
const POS_ARRIBA: Vector2 = Vector2(800.0, 100.0)
const LLEGADA_ARRIBA: Vector2 = Vector2(0.0, 200.0)
const SEGURO_ARRIBA: Vector2 = Vector2(0.0, 580.0)


func _ready() -> void:
	_aislar_partida(RUTA)
	_probar_clip()
	_probar_lado_al_llegar()
	var sala: Sala = _sala(&"")
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	await _esperar(30)
	_caso("Fundido.de encuentra el fundido de la sala desde el jugador",
		Fundido.de(jugador) == sala.get_node(^"Fundido") and Fundido.de(self) == null)
	await _probar_inmunidad(jugador)
	await _probar_llegada_por_puerta(jugador)
	await _probar_fundido_con_muerto(sala, jugador)
	await _probar_retraso_sin_congelar(sala, jugador)
	sala.queue_free()
	await get_tree().physics_frame
	await _probar_punto_seguro_de_puerta()
	_restaurar_partida()
	_resumen()


# entrar_puerta dura al menos el giro, el oscurecer y el negro de una PUERTA: el jugador no queda quieto en el
# ultimo cuadro antes de que la pantalla este negra.
func _probar_clip() -> void:
	var giro: int = AnimacionJugador.ticks_de(CUADROS, AnimacionJugador.ENTRAR_PUERTA, AnimacionJugador.CUADROS_GIRO_PUERTA)
	var clip: int = AnimacionJugador.ticks_de(CUADROS, AnimacionJugador.ENTRAR_PUERTA)
	_caso("entrar_puerta dura hasta el negro de una PUERTA (clip=%d giro=%d)" % [clip, giro],
		giro > 0 and clip >= Fundido.ticks_hasta_cambio(Fundido.Perfil.PUERTA, giro))
	_caso("salir_puerta tiene cuadros", AnimacionJugador.ticks_de(CUADROS, AnimacionJugador.SALIR_PUERTA) > 0)


func _probar_lado_al_llegar() -> void:
	var puerta: Puerta = Puerta.new()
	puerta.position = Vector2(100.0, 680.0)
	puerta.llegada = Vector2(-160.0, 0.0)
	_caso("una puerta LADO hace entrar hacia su llegada", puerta.lado_al_llegar(800.0) == -1.0)
	puerta.tipo = Puerta.Tipo.PUERTA
	_caso("una PUERTA sin mirar_al_llegar deja mirando al centro de la sala", puerta.lado_al_llegar(800.0) == 1.0)
	puerta.mirar_al_llegar = -1
	_caso("una PUERTA con mirar_al_llegar deja mirando hacia el", puerta.lado_al_llegar(800.0) == -1.0)
	puerta.tipo = Puerta.Tipo.ARRIBA
	_caso("una puerta ARRIBA no mueve al llegar", puerta.lado_al_llegar(800.0) == 0.0)
	puerta.free()


# Entra caminando (LLEGA_CAMINANDO): ni un golpe ni un peligro le quitan vidas, no interactua y al acabar los ticks de la
# llegada vuelve el control, habiendo avanzado.
func _probar_inmunidad(jugador: Jugador) -> void:
	var vidas: int = jugador.vidas
	var x: float = jugador.global_position.x
	jugador.entrar_a_sala(Puerta.Tipo.LADO, 1.0)
	_caso("llegar por una puerta LADO pone al jugador en transicion", jugador.transicion == Jugador.Transicion.LLEGA_CAMINANDO)
	_caso("en transicion no puede interactuar", jugador.en_transicion and not jugador.puede_interactuar)
	jugador.recibir_dano(1, x - 50.0)
	jugador.recibir_dano(1, x, true)
	_caso("en transicion ni un golpe ni un peligro quitan vidas", jugador.vidas == vidas)
	await _esperar(Jugador.TICKS_LLEGAR_CAMINANDO + 2)
	_caso("al acabar la llegada caminando vuelve el control", jugador.transicion == Jugador.Transicion.NINGUNA)
	_caso("la llegada caminando avanza hacia su lado", jugador.global_position.x > x + 20.0)
	_caso("tras la transicion un golpe vuelve a contar", _golpe_cuenta(jugador))


func _golpe_cuenta(jugador: Jugador) -> bool:
	var vidas: int = jugador.vidas
	jugador.recibir_dano(1, jugador.global_position.x - 50.0)
	var cuenta: bool = jugador.vidas == vidas - 1
	jugador.vidas = vidas
	return cuenta


func _probar_llegada_por_puerta(jugador: Jugador) -> void:
	await _esperar(jugador.ticks_invulnerable + 2)
	jugador.entrar_a_sala(Puerta.Tipo.PUERTA, -1.0)
	_caso("llegar por una PUERTA sale de espaldas", jugador.transicion == Jugador.Transicion.LLEGA_POR_PUERTA)
	await _esperar(AnimacionJugador.ticks_de(CUADROS, AnimacionJugador.SALIR_PUERTA) + 2)
	_caso("al acabar salir_puerta vuelve el control", jugador.transicion == Jugador.Transicion.NINGUNA)


# Un cambio a la vez; mientras dura, otro fundido_pedido no cambia la pantalla; si el jugador muere antes del negro, el
# Fundido avisa con en_negro una vez y no cambia de escena.
func _probar_fundido_con_muerto(sala: Sala, jugador: Jugador) -> void:
	var fundido: Fundido = Fundido.de(jugador)
	var negros: Array[int] = [0]
	fundido.en_negro.connect(func() -> void: negros[0] += 1)
	var pedido: bool = fundido.cambiar_sala(sala.scene_file_path, Fundido.Llegada.ENTRADA, "", Fundido.Perfil.PUERTA, 0, jugador)
	var otro: bool = fundido.cambiar_sala(sala.scene_file_path, Fundido.Llegada.ENTRADA, "", Fundido.Perfil.PUERTA)
	_caso("el Fundido acepta un cambio y rechaza un segundo", pedido and not otro)
	var puerta: Puerta = _primera_puerta(sala)
	if puerta != null:
		puerta._cruzar(jugador, 0)
	_caso("con un cambio en curso una puerta no pone al jugador a salir ni queda cruzada",
		puerta != null and not puerta._cruzada and not jugador.en_transicion)
	Eventos.fundido_pedido.emit(0, 5, 5)
	_caso("con un cambio en curso otro fundido_pedido no pinta negro en el acto", fundido.opacidad < 0.5)
	jugador.muerto = true
	# La sala pide reaparecer mientras este cambio sigue en curso: el Fundido lo rechaza y la sala reintenta. Se corta
	# el reintento a mano para que no cambie de escena en medio de la prueba.
	var al_cambio: int = Fundido.ticks_hasta_cambio(Fundido.Perfil.MUERTE)
	sala._ticks_para_reaparecer = al_cambio + 1
	await _esperar(2)
	_caso("con otro cambio en curso la sala reintenta reaparecer", sala._ticks_para_reaparecer == al_cambio + 1)
	sala._ticks_para_reaparecer = 0
	await _esperar(Fundido.ticks_hasta_cambio(Fundido.Perfil.PUERTA) + 5)
	_caso("con el jugador muerto el Fundido llega al negro una vez", negros[0] == 1)
	_caso("con el jugador muerto el Fundido no cambia de sala",
		fundido.ruta_destino.is_empty() and sala.is_inside_tree() and get_tree().current_scene == self)
	jugador.muerto = false


# Mientras corre el retraso de una PUERTA (el giro), un aclarado que venia de antes sigue avanzando. El jugador muere
# antes del negro para que el Fundido no cambie de escena.
func _probar_retraso_sin_congelar(sala: Sala, jugador: Jugador) -> void:
	var fundido: Fundido = Fundido.de(jugador)
	var retraso: int = 18
	fundido.empezar_en_negro(30)
	await _esperar(5)
	fundido.cambiar_sala(sala.scene_file_path, Fundido.Llegada.ENTRADA, "", Fundido.Perfil.PUERTA, retraso, jugador)
	var antes: float = fundido.opacidad
	await _esperar(10)
	_caso("durante el retraso de una PUERTA el aclarado sigue (antes=%.2f despues=%.2f)" % [antes, fundido.opacidad],
		fundido.opacidad < antes - 0.1)
	jugador.muerto = true
	await _esperar(Fundido.ticks_hasta_cambio(Fundido.Perfil.PUERTA, retraso) + 5)
	_caso("tras el retraso el cambio llega al negro", fundido.opacidad > 0.99 and fundido.ruta_destino.is_empty())
	jugador.muerto = false


# La primera Puerta hija de la sala; null si no tiene.
func _primera_puerta(sala: Sala) -> Puerta:
	for hijo: Node in sala.get_children():
		if hijo is Puerta:
			return hijo as Puerta
	return null


# Una puerta ARRIBA con punto seguro, agregada a la sala antes de que entre al arbol: el jugador llega a su llegada (en
# el aire), con el control, y su respaldo de punto seguro es el de la puerta, que tiene suelo debajo.
func _probar_punto_seguro_de_puerta() -> void:
	var sala: Sala = _sala(&"arriba_prueba")
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	_caso("llega a la llegada de la puerta", jugador.global_position == POS_ARRIBA + LLEGADA_ARRIBA)
	_caso("por una puerta ARRIBA llega con el control", jugador.transicion == Jugador.Transicion.NINGUNA)
	await get_tree().physics_frame
	_caso("el punto seguro de la puerta va antes que la llegada sin suelo",
		jugador._llegada_con_suelo() == POS_ARRIBA + SEGURO_ARRIBA)
	sala.queue_free()
	await get_tree().physics_frame


# prueba_3 en el arbol; con puerta, antes le agrega la puerta ARRIBA y pide llegar por ella.
func _sala(puerta: StringName) -> Sala:
	var sala: Sala = (load(PRUEBA_3) as PackedScene).instantiate() as Sala
	if not puerta.is_empty():
		var arriba: Puerta = ESCENA_PUERTA.instantiate() as Puerta
		arriba.name = &"PuertaArriba"
		arriba.id = puerta
		arriba.tipo = Puerta.Tipo.ARRIBA
		arriba.position = POS_ARRIBA
		arriba.llegada = LLEGADA_ARRIBA
		arriba.punto_seguro = SEGURO_ARRIBA
		arriba.sala_destino = "prueba_3"
		arriba.puerta_destino = puerta
		sala.add_child(arriba)
		Sala.puerta_llegada = puerta
	add_child(sala)
	return sala
