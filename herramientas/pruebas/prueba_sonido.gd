extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de los efectos: Sonido vive en Arranque con la ficha de prueba mientras no haya una en contenido/, cuenta y
# toca cada evento del bus, no repite el mismo evento en ticks seguidos salvo dano y parry, calla lo que la ficha no
# tiene, y el salto del jugador lo pide. Deja casos y fallos para sonido.guion e imprime el resumen.

const ESCENA_SALA: PackedScene = preload("res://herramientas/salas/sala_dialogo.tscn")


func _ready() -> void:
	var sonido: Sonido = get_node_or_null(^"/root/Arranque/Sonido") as Sonido
	_caso("Arranque crea Sonido con sus voces, en pausa tambien", sonido != null and sonido.get_child_count() == sonido.voces and sonido.process_mode == Node.PROCESS_MODE_ALWAYS)
	if sonido == null:
		_resumen()
		return
	_caso("usa la ficha de prueba", sonido.ficha != null and sonido.ficha.resource_path == Sonido.FICHA_PRUEBA)

	await get_tree().physics_frame
	var tocados: int = sonido.tocados
	Eventos.enemigo_golpeado.emit(null)
	_caso("un golpe suena", sonido.tocados == tocados + 1 and sonido.ultimo == &"golpe")
	Eventos.enemigo_golpeado.emit(null)
	_caso("otro golpe en el mismo tick no suena", sonido.tocados == tocados + 1)
	await _esperar(sonido.ticks_entre_iguales)
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
	await _esperar(40)
	tocados = sonido.tocados
	Input.action_press(&"saltar")
	await _esperar(2)
	Input.action_release(&"saltar")
	await get_tree().physics_frame
	_caso("saltar pide el efecto del salto", sonido.tocados == tocados + 1 and sonido.ultimo == &"salto")
	sala.free()
	Partida.reiniciar()
	_eventos_en_la_ficha()
	_resumen()


# Cada evento de Sonido.EVENTOS es un campo de efecto de FichaSonidos: si no, ficha.efecto() da null y ese evento
# nunca suena. Ademas, los tocar(&"...") del codigo de Sonido son justo los de EVENTOS, para que la lista no se quede
# atras al agregar un evento (el aviso de tocar() solo sale al correr ese evento).
func _eventos_en_la_ficha() -> void:
	var usados: Array[StringName] = _eventos_en_el_codigo()
	var sin_lista: PackedStringArray = []
	for evento: StringName in usados:
		if not Sonido.EVENTOS.has(evento):
			sin_lista.append(String(evento))
	for evento: StringName in Sonido.EVENTOS:
		if not usados.has(evento):
			sin_lista.append(String(evento))
	_caso("los tocar() de Sonido son los de Sonido.EVENTOS (sobran o faltan: %s)" % ", ".join(sin_lista), sin_lista.is_empty() and not usados.is_empty())
	var campos: Array[StringName] = FichaSonidos.new().campos_de_efecto()
	var faltan: PackedStringArray = []
	for evento: StringName in Sonido.EVENTOS:
		if not campos.has(evento):
			faltan.append(String(evento))
	_caso("cada evento de Sonido.EVENTOS es un campo de FichaSonidos (faltan: %s)" % ", ".join(faltan), faltan.is_empty())


func _eventos_en_el_codigo() -> Array[StringName]:
	var codigo: String = (load("res://nucleo/sonido.gd") as GDScript).source_code
	var patron: RegEx = RegEx.create_from_string(r'tocar\(&"(\w+)"\)')
	var eventos: Array[StringName] = []
	for hallado: RegExMatch in patron.search_all(codigo):
		eventos.append(StringName(hallado.get_string(1)))
	return eventos
