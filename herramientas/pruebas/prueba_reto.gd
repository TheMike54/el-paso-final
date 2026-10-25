extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del reto de preguntas: el validador de preguntas atrapa cada forma mala; responder cuenta, recuerda y
# autoguarda; una ronda perdida vuelve a empezar sin premio y una ganada da la recompensa una sola vez; lo guardado se
# lee al entrar y un estado que ya no cabe empieza de nuevo; con la caja, cada respuesta dice si acerto y el final
# dice el resultado. Deja casos y fallos para reto.guion e imprime el resumen.

const ESCENA_SALA: PackedScene = preload("res://herramientas/salas/sala_reto.tscn")
const PREGUNTA_1: FichaPregunta = preload("res://herramientas/salas/fichas/pregunta_prueba_1.tres")
const RUTA: String = "user://prueba_reto.json"

var _ganados: int = 0


func _ready() -> void:
	_aislar_partida(RUTA)

	# Forma de las preguntas.
	_caso("la pregunta de prueba no tiene fallos", PREGUNTA_1.fallos().is_empty())
	_caso("sin texto, una sola opcion y la correcta fuera dan un fallo cada uno", _pregunta("", ["a"], 3).fallos().size() == 3)
	_caso("cuatro opciones y una vacia dan un fallo cada uno", _pregunta("p", ["a", "", "c", "d"], 0).fallos().size() == 2)

	var sala: Sala = ESCENA_SALA.instantiate() as Sala
	add_child(sala)
	var reto: RetoPreguntas = sala.get_node(^"Reto") as RetoPreguntas
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	var clave: String = Sala.clave_de(reto)
	reto.ganado.connect(_al_ganar)

	# Respuestas, sin caja (preguntas: correcta 1, 1 y 0; meta 2).
	var antes: int = Partida.autoguardados
	_caso("una respuesta mala cuenta, se recuerda y autoguarda", not reto.responder(0) and reto.indice == 1 and reto.aciertos == 0 and Partida.estado_entero(clave, "reto_indice", -1) == 1 and Partida.autoguardados == antes + 1)
	reto.responder(0)
	var monedas: int = Partida.monedas
	_caso("acabar la ronda sin la meta la empieza otra vez sin premio", reto.responder(0) and reto.indice == 0 and reto.aciertos == 0 and not reto.gano and Partida.monedas == monedas and Partida.estado_entero(clave, "reto_aciertos", -1) == 0)
	reto.responder(1)
	_caso("una buena suma un acierto", reto.indice == 1 and reto.aciertos == 1)
	reto.responder(1)
	reto.responder(2)
	_caso("acabar la ronda con la meta gana y entrega una vez", reto.gano and Partida.monedas == monedas + 50 and Partida.estado_entero(clave, "reto", -1) == -1 and Partida.estado_de(clave, "reto") is bool and _ganados == 1)
	_caso("ganado no pregunta ni entrega otra vez", reto.pregunta_actual() == null and not reto.responder(0) and Partida.monedas == monedas + 50 and _ganados == 1)
	var otro: RetoPreguntas = RetoPreguntas.new()
	otro.id = "reto"
	otro.preguntas = reto.preguntas
	sala.add_child(otro)
	_caso("uno nuevo con el mismo id lee que ya se gano y no vuelve a preguntar", otro.gano and otro.pregunta_actual() == null)
	otro.free()
	Partida.marcar(clave, "reto", false)
	Partida.marcar(clave, "reto_indice", 2)
	Partida.marcar(clave, "reto_aciertos", 1)
	otro = RetoPreguntas.new()
	otro.id = "reto"
	otro.preguntas = reto.preguntas
	sala.add_child(otro)
	_caso("a media ronda sigue donde iba", not otro.gano and otro.indice == 2 and otro.aciertos == 1 and otro.pregunta_actual() == reto.preguntas[2])
	otro.free()
	Partida.marcar(clave, "reto_indice", 7)
	otro = RetoPreguntas.new()
	otro.id = "reto"
	otro.preguntas = reto.preguntas
	sala.add_child(otro)
	_caso("un estado que ya no cabe empieza la ronda otra vez", otro.indice == 0 and otro.aciertos == 0)
	otro.free()

	# Con la caja y el jugador, desde cero.
	Partida.marcar(clave, "reto_indice", 0)
	Partida.marcar(clave, "reto_aciertos", 0)
	reto.gano = false
	reto.indice = 0
	reto.aciertos = 0
	_ganados = 0
	monedas = Partida.monedas
	jugador.global_position = Vector2(reto.global_position.x, 600.0)
	await _esperar(40)
	await _presionar(&"interactuar")
	var caja: CajaDialogo = reto.caja
	_caso("interactuar abre la caja con tres preguntas, sus respuestas y el final", caja != null and jugador.hablando and caja.ficha.lineas.size() == 7)
	if caja == null:
		_cerrar(sala)
		return
	await _presionar(&"saltar")
	await _presionar(&"mover_derecha")
	await _presionar(&"saltar")
	_caso("la buena dice que acerto", caja.linea == 1 and caja.ficha.lineas[1].texto == reto.texto_correcto and reto.aciertos == 1)
	await _presionar(&"saltar")
	await _presionar(&"saltar")
	await _presionar(&"saltar")
	await _presionar(&"saltar")
	_caso("la mala dice cual era", caja.linea == 3 and caja.ficha.lineas[3].texto == reto.texto_incorrecto % "Pila" and reto.indice == 2)
	await _presionar(&"saltar")
	await _presionar(&"saltar")
	await _presionar(&"saltar")
	await _presionar(&"saltar")
	_caso("dos de tres gana y el final lo dice", reto.gano and caja.linea == 5 and caja.ficha.lineas[6].texto == reto.texto_ganaste and Partida.monedas == monedas + 50)
	await _presionar(&"saltar")
	await _presionar(&"saltar")
	await _presionar(&"saltar")
	await _presionar(&"saltar")
	await get_tree().physics_frame
	_caso("al final la caja se cierra y el jugador deja de hablar", reto.caja == null and not jugador.hablando)
	await _presionar(&"interactuar")
	_caso("ya ganado, solo dice el texto de ganado", reto.caja != null and reto.caja.ficha.lineas.size() == 1 and reto.caja.ficha.lineas[0].texto == reto.texto_ganado)

	_cerrar(sala)


func _cerrar(sala: Sala) -> void:
	sala.free()
	get_tree().paused = false
	_restaurar_partida()
	_resumen()


func _pregunta(texto: String, opciones: Array[String], correcta: int) -> FichaPregunta:
	var pregunta: FichaPregunta = FichaPregunta.new()
	pregunta.pregunta = texto
	pregunta.opciones = opciones
	pregunta.correcta = correcta
	return pregunta


func _al_ganar() -> void:
	_ganados += 1
