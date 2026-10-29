extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de los recogibles que se recuerdan por id, con las PejeCoins sueltas: se toman una vez (un segundo toque ni
# un jugador muerto suman), y no vuelven ni al recargar la sala ni al cargar la partida guardada, con las monedas
# tomadas de vuelta. Tambien que un jugador muerto no toma un objeto de habilidad y que un mapa tomado no vuelve.
# Deja casos y fallos para monedas_sueltas.guion (clave valor) e imprime el resumen y solo los que fallan.
const RUTA: String = "user://prueba_monedas_sueltas.json"
const PRUEBA_3: String = "res://herramientas/salas/zonas/prueba/prueba_3.tscn"
const ESCENA_MONEDAS: PackedScene = preload("res://nucleo/monedas_sueltas.tscn")
const CANTIDAD: int = 10


func _ready() -> void:
	_aislar_partida(RUTA)
	_borrar()

	var sala: Sala = _sala()
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	var tomadas: MonedasSueltas = _monedas(sala, "monedas_1")
	tomadas.body_entered.emit(jugador)
	_caso("tocar las monedas suma su cantidad", Partida.monedas == CANTIDAD)
	_caso("las monedas tomadas quedan marcadas en su sala", Partida.estado_de("prueba_3", "monedas_1") != null)
	tomadas.body_entered.emit(jugador)
	_caso("un segundo toque antes de irse no suma otra vez", Partida.monedas == CANTIDAD and tomadas.is_queued_for_deletion())

	var otras: MonedasSueltas = _monedas(sala, "monedas_2")
	jugador.muerto = true
	otras.body_entered.emit(jugador)
	var objeto: ObjetoHabilidad = ObjetoHabilidad.new()
	objeto.habilidad = Habilidades.IMPULSO
	sala.add_child(objeto)
	objeto.body_entered.emit(jugador)
	jugador.muerto = false
	_caso("un jugador muerto no toma las monedas", Partida.monedas == CANTIDAD and Partida.estado_de("prueba_3", "monedas_2") == null
		and not otras.is_queued_for_deletion())
	_caso("un jugador muerto no toma un objeto de habilidad", not Partida.tiene(Habilidades.IMPULSO))
	# El mapa es otro recogible que no se recuerda por id: lo recuerda Partida.mapas.
	var mapa: ObjetoMapa = ObjetoMapa.new()
	mapa.zona = "prueba"
	sala.add_child(mapa)
	mapa.body_entered.emit(jugador)
	var otro_mapa: ObjetoMapa = ObjetoMapa.new()
	otro_mapa.zona = "prueba"
	sala.add_child(otro_mapa)
	_caso("un mapa tomado se suma a la partida y no vuelve a aparecer", Partida.mapas.has("prueba")
		and otro_mapa.is_queued_for_deletion())
	# Sin Sala duena ni zona no hay mapa que dar: no se consume ni suma nada.
	var sin_zona: ObjetoMapa = ObjetoMapa.new()
	sala.add_child(sin_zona)
	var mapas_antes: int = Partida.mapas.size()
	sin_zona.body_entered.emit(jugador)
	_caso("un mapa sin zona no se consume ni suma un mapa", not sin_zona.is_queued_for_deletion()
		and Partida.mapas.size() == mapas_antes)
	sala.free()

	# Recargar la sala: las tomadas no aparecen y las de otro id si.
	sala = _sala()
	var al_volver: MonedasSueltas = _monedas(sala, "monedas_1")
	var sin_tomar: MonedasSueltas = _monedas(sala, "monedas_2")
	_caso("al recargar la sala las monedas tomadas no vuelven", al_volver.is_queued_for_deletion() and Partida.monedas == CANTIDAD)
	_caso("al recargar la sala las monedas de otro id siguen", not sin_tomar.is_queued_for_deletion())
	sala.free()

	# Guardar, empezar de cero y cargar: vuelven las monedas tomadas y la marca, y el monton no reaparece.
	var error: Error = Partida.guardar(RUTA)
	Partida.reiniciar()
	_caso("partida nueva sin monedas ni marcas", Partida.monedas == 0 and Partida.estado_de("prueba_3", "monedas_1") == null)
	var cargada: Guardado.Resultado = Guardado.cargar(RUTA)
	var valida: bool = error == OK and cargada.estado == Guardado.Estado.VALIDA
	if valida:
		Partida.desde_diccionario(cargada.partida)
	_caso("al cargar la partida vuelven las monedas tomadas", valida and Partida.monedas == CANTIDAD)
	sala = _sala()
	var tras_cargar: MonedasSueltas = _monedas(sala, "monedas_1")
	_caso("al cargar la partida las monedas tomadas no vuelven a aparecer", tras_cargar.is_queued_for_deletion())
	sala.free()

	_restaurar_partida()
	_resumen()


func _sala() -> Sala:
	var sala: Sala = (load(PRUEBA_3) as PackedScene).instantiate() as Sala
	add_child(sala)
	return sala


func _monedas(sala: Sala, id: String) -> MonedasSueltas:
	var monedas: MonedasSueltas = ESCENA_MONEDAS.instantiate() as MonedasSueltas
	monedas.id = id
	monedas.cantidad = CANTIDAD
	sala.add_child(monedas)
	return monedas


func _borrar() -> void:
	for ruta: String in [RUTA, RUTA + ".tmp"]:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ruta)
