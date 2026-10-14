extends "res://herramientas/salas/prueba_base.gd"
# Prueba del estado por sala y del autoguardado: suelo fragil y coleccionable que se recuerdan, entrega de
# recompensas por cantidad, salas visitadas y dibujadas en el mapa al descansar con la pluma del mapa, y los
# momentos que autoguardan. Corre los casos al entrar y deja la cuenta en "casos" y "fallos", que
# estado_sala.guion lee con la clave valor. Imprime el resumen y solo los que fallan.
const RUTA: String = "user://prueba_estado_sala.json"
const PRUEBA_3: String = "res://herramientas/salas/zonas/prueba/prueba_3.tscn"
const ESCENA_COLECCIONABLE: PackedScene = preload("res://nucleo/coleccionable.tscn")


func _ready() -> void:
	Partida.reiniciar()
	Partida.ruta_guardado = RUTA
	_borrar()

	Partida.marcar("celda_3", "examenes_1")
	_caso("marcar recuerda true", _vale(Partida.estado_de("celda_3", "examenes_1"), true))
	_caso("lo no marcado es null", _vale(Partida.estado_de("celda_3", "palanca"), null))
	Partida.marcar("", "examenes_1")
	_caso("una sala sin clave no marca nada", not Partida.salas.has(""))

	# Suelo fragil con id dentro de una sala con id: roto, no vuelve en la siguiente visita.
	var sala: Sala = (load(PRUEBA_3) as PackedScene).instantiate() as Sala
	add_child(sala)
	_caso("entrar a una sala la deja visitada", Partida.salas_visitadas.has("prueba_3"))
	var suelo: SueloFragil = SueloFragil.new()
	suelo.id = "suelo_1"
	sala.add_child(suelo)
	suelo.romper()
	_caso("romper un suelo con id lo marca en su sala", _vale(Partida.estado_de("prueba_3", "suelo_1"), true))
	var otra_vez: SueloFragil = SueloFragil.new()
	otra_vez.id = "suelo_1"
	sala.add_child(otra_vez)
	_caso("un suelo ya roto no vuelve", otra_vez.roto)
	var sin_id: SueloFragil = SueloFragil.new()
	sala.add_child(sin_id)
	sin_id.romper()
	_caso("un suelo sin id no se recuerda", Partida.salas["prueba_3"].size() == 1)

	# Coleccionable: tomarlo lo marca, autoguarda, y ya no aparece.
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	var antes: int = Partida.autoguardados
	var coleccionable: Coleccionable = ESCENA_COLECCIONABLE.instantiate() as Coleccionable
	coleccionable.id = "coleccionable_1"
	sala.add_child(coleccionable)
	coleccionable._al_entrar(jugador)
	_caso("tomar un coleccionable lo cuenta", Partida.total_coleccionables() == 1)
	_caso("tomar un coleccionable autoguarda", Partida.autoguardados == antes + 1 and FileAccess.file_exists(RUTA))
	var guardada: Guardado.Resultado = Guardado.cargar(RUTA)
	_caso("el coleccionable queda en el archivo", guardada.estado == Guardado.Estado.VALIDA and (guardada.partida["salas"] as Dictionary).has("prueba_3"))
	var repetido: Coleccionable = ESCENA_COLECCIONABLE.instantiate() as Coleccionable
	repetido.id = "coleccionable_1"
	sala.add_child(repetido)
	_caso("un coleccionable tomado no vuelve a aparecer", repetido.is_queued_for_deletion())

	# Recompensas por cantidad, una sola vez cada una.
	for i: int in range(2, 5):
		Partida.marcar("prueba_2", "coleccionable_%d" % i)
	var entrega: EntregaRecompensas = EntregaRecompensas.new()
	entrega.recompensas = [_recompensa(4, Recompensa.Tipo.MONEDAS, 100), _recompensa(8, Recompensa.Tipo.AMULETO, 0, &"amuleto_prueba"),
			_recompensa(12, Recompensa.Tipo.VIDA_MAXIMA, 1)]
	sala.add_child(entrega)
	antes = Partida.autoguardados
	_caso("con 4 coleccionables se entrega solo la primera", entrega.entregar() == 1 and Partida.monedas == 100)
	_caso("entregar autoguarda", Partida.autoguardados == antes + 1)
	_caso("una recompensa no se entrega dos veces", entrega.entregar() == 0 and Partida.monedas == 100)
	for i: int in range(5, 13):
		Partida.marcar("prueba_2", "coleccionable_%d" % i)
	_caso("con 12 se entregan el amuleto y la vida maxima", entrega.entregar() == 2 and Partida.amuletos_tenidos.has(&"amuleto_prueba") and Partida.vidas_maximas == 5)
	# La regla de interactuar es una para banco, Npc, reto y entrega: sentado no se interactua (la entrega lo olvidaba).
	# El jugador cae hasta el suelo: asi la unica diferencia entre los dos casos es estar sentado.
	for i: int in range(90):
		if jugador.is_on_floor():
			break
		await get_tree().physics_frame
	var de_pie_puede: bool = jugador.puede_interactuar
	jugador.descansando = true
	var sentado_puede: bool = jugador.puede_interactuar
	jugador.descansando = false
	_caso("de pie en el suelo se puede interactuar y sentado en un banco no", de_pie_puede and not sentado_puede)
	sala.free()

	# Mapa: descansar con la pluma del mapa dibuja las visitadas de las zonas cuyo mapa se tiene.
	Partida.salas_visitadas.assign(["prueba_1", "celda_1"])
	Eventos.descanso_en_banco.emit(&"banco_prueba_1")
	_caso("sin la pluma del mapa no se dibuja nada", Partida.salas_mapeadas.is_empty())
	Partida.habilidades.append(&"pluma_mapa")
	Eventos.descanso_en_banco.emit(&"banco_prueba_1")
	_caso("con pluma pero sin el mapa de la zona no se dibuja", Partida.salas_mapeadas.is_empty())
	Partida.mapas.append("prueba")
	Eventos.descanso_en_banco.emit(&"banco_prueba_1")
	_caso("con pluma y mapa se dibujan solo las salas de esa zona", Partida.salas_mapeadas.size() == 1 and Partida.salas_mapeadas.has("prueba_1"))
	Partida.salas_mapeadas.clear()
	var banco: Banco = Banco.new()
	banco.id = "banco_prueba"
	add_child(banco)
	banco.descansar()
	var del_banco: Guardado.Resultado = Guardado.cargar(RUTA)
	_caso("el banco guarda el mapa que dibuja ese descanso", del_banco.estado == Guardado.Estado.VALIDA and (del_banco.partida["salas_mapeadas"] as Array).has("prueba_1"))
	banco.free()
	# Sin banco otra vez: el caso de abajo revisa que autoguardar no invente uno.
	Partida.banco = ""
	Partida.sala = ""

	# Los demas momentos que autoguardan.
	antes = Partida.autoguardados
	Partida.obtener_habilidad(&"impulso")
	_caso("obtener una habilidad autoguarda", Partida.autoguardados == antes + 1)
	Partida.obtener_habilidad(&"impulso")
	_caso("una habilidad repetida no vuelve a guardar", Partida.autoguardados == antes + 1)
	Eventos.jefe_vencido.emit(&"jefe_prueba")
	_caso("vencer a un jefe lo anota y autoguarda", Partida.jefes.has(&"jefe_prueba") and Partida.autoguardados == antes + 2)
	Partida.obtener_amuleto(&"brujula")
	_caso("recoger un amuleto autoguarda", Partida.autoguardados == antes + 3)
	Eventos.jugador_muerto.emit()
	_caso("morir autoguarda", Partida.autoguardados == antes + 4)
	_caso("autoguardar no cambia el banco", (Guardado.cargar(RUTA).partida["banco"] as Dictionary).is_empty())

	_borrar()
	Partida.reiniciar()
	Partida.ruta_guardado = Partida.RUTA_PRUEBAS
	_resumen()


func _recompensa(cantidad: int, tipo: Recompensa.Tipo, monto: int, id: StringName = &"") -> Recompensa:
	var recompensa: Recompensa = Recompensa.new()
	recompensa.cantidad = cantidad
	recompensa.tipo = tipo
	recompensa.monto = monto
	recompensa.id = id
	return recompensa


func _borrar() -> void:
	for ruta: String in [RUTA, RUTA + ".tmp"]:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ruta)


# Compara un Variant sin pasarlo directo a _caso (el tipado estricto no lo deja). 3.0 del JSON vale 3.
func _vale(valor: Variant, esperado: Variant) -> bool:
	var igual: bool = valor == esperado
	return igual
