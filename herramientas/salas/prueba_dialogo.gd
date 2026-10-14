extends "res://herramientas/salas/prueba_base.gd"
# Prueba del dialogo: el validador de fichas atrapa cada forma mala; el Npc sube de etapa, entrega una sola vez,
# repite la ultima y recuerda la etapa en Partida; la caja escribe letra por letra, se completa y avanza con las
# acciones, recorre las opciones y CANCELAR no cuenta; un golpe corta la charla. Deja casos y fallos para
# dialogo.guion e imprime el resumen.

const ESCENA_SALA: PackedScene = preload("res://herramientas/salas/sala_dialogo.tscn")
const FICHA_1: FichaDialogo = preload("res://herramientas/salas/fichas/guia_prueba_1.tres")
const RUTA: String = "user://prueba_dialogo.json"

var _terminadas: int = 0


func _ready() -> void:
	var ruta_real: String = Partida.ruta_guardado
	Partida.ruta_guardado = RUTA
	Partida.reiniciar()

	# Forma de las fichas.
	_caso("la ficha del guia de prueba no tiene fallos", FICHA_1.fallos().is_empty())
	_caso("una ficha sin lineas falla", FichaDialogo.new().fallos().size() == 1)
	var mala: FichaDialogo = FichaDialogo.new()
	mala.lineas = [_linea("", [], []), _linea("a", ["x"], []), _linea("b", ["1", "2", "3", "4"], [0, 0, 0, 0]), _linea("c", ["x"], [9])] as Array[LineaDialogo]
	_caso("texto vacio, opciones sin destino, mas de 3 opciones y destino fuera dan un fallo cada uno", mala.fallos().size() == 4)
	var sin_id: Recompensa = Recompensa.new()
	sin_id.tipo = Recompensa.Tipo.HABILIDAD
	var monedas: Recompensa = Recompensa.new()
	var con_recompensas: FichaDialogo = FichaDialogo.new()
	con_recompensas.lineas = [_linea("a", [" ", "si"], [LineaDialogo.FIN, LineaDialogo.FIN])] as Array[LineaDialogo]
	con_recompensas.recompensas = [null, sin_id, monedas] as Array[Recompensa]
	_caso("una opcion sin texto, una recompensa vacia y una habilidad sin id dan un fallo cada uno (monedas sin id no)", con_recompensas.fallos().size() == 3)

	var sala: Sala = ESCENA_SALA.instantiate() as Sala
	add_child(sala)
	var npc: Npc = sala.get_node(^"Guia") as Npc
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	var clave: String = Sala.clave_de(npc)
	npc.conversacion_terminada.connect(_al_terminar_conversacion)

	# Etapas, sin caja.
	_caso("en la etapa 0 toca la primera conversacion", npc.etapa == 0 and npc.conversacion() == npc.conversaciones[0])
	npc.terminar(false)
	_caso("terminar sin contar no sube la etapa ni entrega", npc.etapa == 0 and not Partida.tiene(&"pluma_mapa") and _terminadas == 0)
	var antes: int = Partida.autoguardados
	npc.terminar(true)
	_caso("terminar contando sube la etapa, la recuerda, entrega y autoguarda", npc.etapa == 1 and Partida.estado_entero(clave, "guia", -1) == 1 and Partida.tiene(&"pluma_mapa") and Partida.mapas.has("prueba") and Partida.autoguardados > antes and _terminadas == 1)
	_caso("en la etapa 1 toca la segunda", npc.conversacion() == npc.conversaciones[1])
	npc.terminar(true)
	antes = Partida.autoguardados
	var mapas: int = Partida.mapas.size()
	npc.terminar(true)
	_caso("terminada la ultima se repite sin subir ni entregar", npc.etapa == 2 and npc.conversacion() == npc.conversaciones[1] and Partida.autoguardados == antes and Partida.mapas.size() == mapas and _terminadas == 2)
	var otro: Npc = Npc.new()
	otro.id = "guia"
	sala.add_child(otro)
	_caso("un Npc nuevo con el mismo id lee su etapa de Partida", otro.etapa == 2)
	otro.free()

	# Con la caja y el jugador, desde la etapa 0.
	Partida.marcar(clave, "guia", 0)
	npc.etapa = 0
	_terminadas = 0
	jugador.global_position = Vector2(npc.global_position.x, 600.0)
	await _esperar(40)
	await _presionar(&"interactuar")
	var caja: CajaDialogo = npc.caja
	_caso("interactuar encima del guia abre la caja y el jugador habla", caja != null and jugador.hablando and ControlesTactiles.hablando)
	if caja == null:
		_cerrar(sala, ruta_real)
		return
	_caso("la pulsacion que abrio la caja no completa la linea", not caja.completa and caja.letras_visibles < 3)
	var x: float = jugador.global_position.x
	Input.action_press(&"mover_derecha")
	await _esperar(10)
	Input.action_release(&"mover_derecha")
	_caso("las letras van saliendo y el jugador no camina", caja.letras_visibles > 2 and is_equal_approx(jugador.global_position.x, x))
	await _presionar(&"saltar")
	_caso("saltar completa la linea", caja.completa and caja.linea == 0)
	await _presionar(&"atacar")
	_caso("atacar pasa a la siguiente", caja.linea == 1 and not caja.completa)
	await _presionar(&"interactuar")
	_caso("en la pregunta empieza marcada la primera opcion", caja.completa and caja.elegida == 0)
	(caja.get_node(^"Raiz/Caja") as Button).pressed.emit()
	await _esperar(2)
	_caso("con opciones, tocar la caja no elige", caja.linea == 1 and npc.caja != null)
	await _presionar(&"mover_derecha")
	await _presionar(&"mover_derecha")
	_caso("derecha recorre las opciones sin pasarse", caja.elegida == 1)
	await _presionar(&"saltar")
	await get_tree().physics_frame
	_caso("No cancela: cierra sin contar y el jugador deja de hablar", npc.caja == null and npc.etapa == 0 and not jugador.hablando and not ControlesTactiles.hablando and _terminadas == 0)
	_caso("el salto que cerro la charla no hace saltar", jugador.is_on_floor())

	# Un golpe corta la charla sin contarla, aunque llegue en el tick en que se cerraba la ultima linea.
	await _presionar(&"interactuar")
	_caso("se puede volver a hablar", npc.caja != null and jugador.hablando)
	for i: int in range(5):
		await _presionar(&"saltar")
	_caso("con Si se llega a la ultima linea", npc.caja != null and npc.caja.linea == 2 and npc.caja.completa)
	jugador.recibir_dano(1, npc.global_position.x - 100.0)
	Input.action_press(&"saltar")
	await _esperar(2)
	Input.action_release(&"saltar")
	await get_tree().physics_frame
	_caso("un golpe en el tick que cerraba la caja la cierra sin contar", npc.caja == null and not jugador.hablando and npc.etapa == 0 and _terminadas == 0)

	_cerrar(sala, ruta_real)


func _cerrar(sala: Sala, ruta_real: String) -> void:
	sala.free()
	get_tree().paused = false
	Partida.reiniciar()
	Partida.ruta_guardado = ruta_real
	DirAccess.remove_absolute(RUTA)
	_resumen()


func _linea(texto: String, opciones: Array[String], destinos: Array[int]) -> LineaDialogo:
	var linea: LineaDialogo = LineaDialogo.new()
	linea.texto = texto
	linea.opciones = opciones
	linea.destinos = destinos
	return linea


func _al_terminar_conversacion(_etapa: int) -> void:
	_terminadas += 1
