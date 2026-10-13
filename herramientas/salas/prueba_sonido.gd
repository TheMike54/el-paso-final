extends Node
# Prueba de los efectos: Sonido vive en Arranque con la ficha de prueba mientras no haya una en contenido/, cuenta y
# toca cada evento del bus, no repite el mismo evento en ticks seguidos salvo dano y parry, calla lo que la ficha no
# tiene, y el salto del jugador lo pide. Deja casos y fallos para sonido.guion e imprime el resumen.

const ESCENA_SALA: PackedScene = preload("res://herramientas/salas/sala_dialogo.tscn")

var casos: int = 0
var fallos: int = 0


func _ready() -> void:
	var sonido: Sonido = get_node_or_null(^"/root/Arranque/Sonido") as Sonido
	_caso("Arranque crea Sonido con sus voces, en pausa tambien", sonido != null and sonido.get_child_count() == sonido.voces and sonido.process_mode == Node.PROCESS_MODE_ALWAYS)
	if sonido == null:
		print("PRUEBAS sonido casos=%d fallos=%d" % [casos, fallos])
		return
	_caso("usa la ficha de prueba", sonido.ficha != null and sonido.ficha.resource_path == Sonido.FICHA_PRUEBA)

	await get_tree().physics_frame
	var tocados: int = sonido.tocados
	Eventos.enemigo_golpeado.emit(null)
	_caso("un golpe suena", sonido.tocados == tocados + 1 and sonido.ultimo == &"golpe")
	Eventos.enemigo_golpeado.emit(null)
	_caso("otro golpe en el mismo tick no suena", sonido.tocados == tocados + 1)
	for i: int in range(sonido.ticks_entre_iguales):
		await get_tree().physics_frame
	Eventos.enemigo_golpeado.emit(null)
	_caso("pasados los ticks de espera vuelve a sonar", sonido.tocados == tocados + 2)
	Eventos.jugador_danado.emit(3)
	Eventos.jugador_danado.emit(2)
	Eventos.parry.emit()
	Eventos.parry.emit()
	_caso("dano y parry no esperan", sonido.tocados == tocados + 6 and sonido.ultimo == &"parry")
	Eventos.jugador_curado.emit(4)
	Eventos.descanso_en_banco.emit(&"banco_prueba")
	_caso("curar y el banco suenan", sonido.tocados == tocados + 8 and sonido.ultimo == &"banco")
	var ficha: FichaSonidos = sonido.ficha
	sonido.ficha = FichaSonidos.new()
	var pedidos: int = sonido.pedidos
	await get_tree().physics_frame
	Eventos.jugador_curado.emit(4)
	_caso("lo que la ficha no tiene se pide pero no suena", sonido.pedidos == pedidos + 1 and sonido.tocados == tocados + 8)
	sonido.ficha = ficha

	# El salto del jugador, en una sala con suelo.
	var sala: Sala = ESCENA_SALA.instantiate() as Sala
	add_child(sala)
	for i: int in range(40):
		await get_tree().physics_frame
	tocados = sonido.tocados
	Input.action_press(&"saltar")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(&"saltar")
	await get_tree().physics_frame
	_caso("saltar pide el efecto del salto", sonido.tocados == tocados + 1 and sonido.ultimo == &"salto")
	sala.free()
	Partida.reiniciar()
	print("PRUEBAS sonido casos=%d fallos=%d" % [casos, fallos])


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO sonido: %s" % nombre)
