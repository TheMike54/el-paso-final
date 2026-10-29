extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de los efectos: Sonido vive en Arranque con la ficha del juego y un solo reproductor polifonico, cada senal
# del bus toca el efecto que le toca, no repite el mismo evento en ticks seguidos salvo dano y parry, calla lo que la
# ficha no tiene, y el jugador avisa saltos, pasos y aterrizajes. Con pantalla comprueba ademas que suena de verdad.

const ESCENA_SALA: PackedScene = preload("res://herramientas/salas/sala_dialogo.tscn")

var _pasos: int = 0
var _aterrizajes: int = 0
var _picadas: int = 0


func _ready() -> void:
	# Sonido es hija de un autoload: siempre existe (tutorials/scripting/singletons_autoload.rst:30).
	var sonido: Sonido = Arranque.sonido
	var reproductor: AudioStreamPlayer = sonido.get_node_or_null(^"Voces") as AudioStreamPlayer
	var polifonico: AudioStreamPolyphonic = reproductor.stream as AudioStreamPolyphonic if reproductor != null else null
	_caso("Arranque crea Sonido con un reproductor polifonico de sus voces en Efectos, en pausa tambien",
			polifonico != null and polifonico.polyphony == sonido.voces and reproductor.bus == Ajustes.BUS_EFECTOS
			and sonido.get_child_count() == 1 and sonido.process_mode == Node.PROCESS_MODE_ALWAYS)
	_caso("usa la ficha del juego", sonido.ficha != null and sonido.ficha.resource_path == Sonido.FICHA)
	_caso("la ficha del juego deja el salto y el parry sin sonido", sonido.ficha.salto == null and sonido.ficha.parry == null)
	_caso("paso, aterrizaje y golpe varian el tono con un AudioStreamRandomizer",
			sonido.ficha.paso is AudioStreamRandomizer and sonido.ficha.aterrizaje is AudioStreamRandomizer
			and sonido.ficha.golpe is AudioStreamRandomizer)

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
	_caso("el dano no espera", sonido.tocados == tocados + 4 and sonido.ultimo == &"dano")
	var pedidos: int = sonido.pedidos
	Eventos.parry.emit()
	_caso("el parry se pide y en la ficha del juego no suena", sonido.pedidos == pedidos + 1 and sonido.tocados == tocados + 4)
	await _senales_a_eventos(sonido)
	_sin_efecto(sonido)
	if sonido.mudo:
		_caso("sin pantalla cuenta pero no toca", sonido.tocar(&"porton") == AudioStreamPlaybackPolyphonic.INVALID_ID)
	else:
		await _con_pantalla(sonido)

	await _jugador_en_sala(sonido)
	_resumen()


# Cada senal toca su evento, con una ficha armada aqui que los tiene todos (salto y parry incluidos): si una conexion
# de Sonido apunta a un evento mal escrito o a otro, el ultimo no coincide.
func _senales_a_eventos(sonido: Sonido) -> void:
	var ficha: FichaSonidos = sonido.ficha
	var completa: FichaSonidos = FichaSonidos.new()
	var efecto: AudioStream = AudioStreamWAV.new()
	# Los campos salen de la propia ficha: un campo nuevo sin su senal en esta tabla (y sin conexion en Sonido) falla.
	var campos: Array[StringName] = []
	for propiedad: Dictionary in completa.get_property_list():
		if propiedad["class_name"] == "AudioStream":
			campos.append(StringName(propiedad["name"] as String))
	for campo: StringName in campos:
		completa.set(campo, efecto)
	sonido.ficha = completa
	await _esperar(sonido.ticks_entre_iguales)
	var casos_senal: Array[Array] = [
		[&"salto", func() -> void: Eventos.jugador_salto.emit()],
		[&"golpe", func() -> void: Eventos.objeto_golpeado.emit(null)],
		[&"dano", func() -> void: Eventos.jugador_danado.emit(3)],
		[&"muro_roto", func() -> void: Eventos.muro_roto.emit(&"muro")],
		[&"porton", func() -> void: Eventos.porton_abierto.emit(&"porton")],
		[&"parry", func() -> void: Eventos.parry.emit()],
		[&"curar", func() -> void: Eventos.jugador_curado.emit(4)],
		[&"banco", func() -> void: Eventos.descanso_en_banco.emit(&"banco_prueba")],
		[&"paso", func() -> void: Eventos.jugador_paso.emit()],
		[&"impulso", func() -> void: Eventos.jugador_impulso.emit()],
		[&"aterrizaje", func() -> void: Eventos.jugador_aterrizo.emit(600.0, false, false)],
		[&"picada", func() -> void: Eventos.jugador_aterrizo.emit(1800.0, false, true)],
	]
	var sin_senal: PackedStringArray = []
	for campo: StringName in campos:
		var tiene: bool = false
		for caso: Array in casos_senal:
			tiene = tiene or caso[0] == campo
		if not tiene:
			sin_senal.append(String(campo))
	_caso("cada campo de FichaSonidos tiene su senal en esta prueba (sin ella: %s)" % ", ".join(sin_senal),
			sin_senal.is_empty())
	var mal: PackedStringArray = []
	for caso: Array in casos_senal:
		var evento: StringName = caso[0]
		var emitir: Callable = caso[1]
		var antes: int = sonido.tocados
		emitir.call()
		if sonido.tocados != antes + 1 or sonido.ultimo != evento:
			mal.append(String(evento))
	await _esperar(sonido.ticks_entre_iguales)
	var antes_duro: int = sonido.tocados
	Eventos.jugador_aterrizo.emit(1200.0, true, false)
	if sonido.tocados != antes_duro + 1 or sonido.ultimo != &"aterrizaje":
		mal.append("aterrizaje duro")
	_caso("cada senal toca su evento (mal: %s)" % ", ".join(mal), mal.is_empty())
	await _esperar(sonido.ticks_entre_iguales)
	var lenta: float = sonido.velocidad_aterrizaje_min * 0.5
	var antes_lento: int = sonido.tocados
	Eventos.jugador_aterrizo.emit(lenta, false, false)
	var lento_calla: bool = sonido.tocados == antes_lento
	Eventos.jugador_aterrizo.emit(lenta, false, true)
	_caso("un aterrizaje mas lento que velocidad_aterrizaje_min no suena y una picada lenta si",
			lento_calla and sonido.tocados == antes_lento + 1 and sonido.ultimo == &"picada")
	sonido.ficha = ficha


func _sin_efecto(sonido: Sonido) -> void:
	var ficha: FichaSonidos = sonido.ficha
	sonido.ficha = FichaSonidos.new()
	var pedidos: int = sonido.pedidos
	var tocados: int = sonido.tocados
	Eventos.jugador_curado.emit(4)
	_caso("lo que la ficha no tiene se pide pero no suena", sonido.pedidos == pedidos + 1 and sonido.tocados == tocados)
	sonido.ficha = ficha


# Solo con pantalla: play_stream toca un Randomizer, un sonido largo no lo corta una tanda de pasos y con las voces
# llenas se descarta el nuevo sin cortar el viejo. Todo en el mismo tick y sin espera entre iguales: con ventana los
# ticks no van a tiempo real (unos 100 ms cada uno al arrancar, medido el 27-oct-2026) y el porton (2,6 s) acabaria
# solo.
func _con_pantalla(sonido: Sonido) -> void:
	var espera: int = sonido.ticks_entre_iguales
	sonido.ticks_entre_iguales = 0
	var porton: int = sonido.tocar(&"porton")
	var pasos: Array[int] = []
	for i: int in range(5):
		pasos.append(sonido.tocar(&"paso"))
	_caso("un paso (AudioStreamRandomizer) suena por play_stream", not pasos.has(AudioStreamPlaybackPolyphonic.INVALID_ID))
	_caso("un porton y cinco pasos: el porton sigue sonando", sonido.sonando(porton))
	sonido.ticks_entre_iguales = espera
	await _esperar(30)
	var descartados: int = sonido.descartados
	var primera: int = sonido.tocar(&"dano")
	for i: int in range(sonido.voces):
		sonido.tocar(&"dano")
	_caso("con las voces llenas se descarta el nuevo y el primero sigue", sonido.descartados > descartados and sonido.sonando(primera))


# En una sala con suelo: aparecer no es aterrizar, saltar pide el salto, caer avisa un aterrizaje que no vibra
# (Vibracion solo con el duro o la picada), caminar da pasos (unos cuatro por segundo) y entrar caminando por una
# puerta no da pasos.
func _jugador_en_sala(sonido: Sonido) -> void:
	Eventos.jugador_paso.connect(_al_paso)
	Eventos.jugador_aterrizo.connect(_al_aterrizar)
	var sala: Sala = ESCENA_SALA.instantiate() as Sala
	add_child(sala)
	var vibracion: Vibracion = sala.get_node(^"Vibracion") as Vibracion
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	await _esperar(40)
	_caso("aparecer en la sala no avisa un aterrizaje", _aterrizajes == 0)
	var pedidos: int = sonido.pedidos
	var aterrizajes: int = _aterrizajes
	var vibraciones: int = vibracion.pedidas
	Input.action_press(&"saltar")
	await _esperar(2)
	Input.action_release(&"saltar")
	await get_tree().physics_frame
	_caso("saltar pide el efecto del salto", sonido.pedidos == pedidos + 1)
	await _esperar(80)
	_caso("caer del salto avisa un aterrizaje, sin picada", _aterrizajes == aterrizajes + 1 and _picadas == 0)
	_caso("un aterrizaje comun no vibra", vibracion.pedidas == vibraciones)
	var pasos: int = _pasos
	Input.action_press(&"mover_derecha")
	await _esperar(60)
	Input.action_release(&"mover_derecha")
	_caso("caminar un segundo da unos cuatro pasos (%d)" % (_pasos - pasos), _pasos - pasos >= 3 and _pasos - pasos <= 5)
	pasos = _pasos
	jugador.entrar_a_sala(Puerta.Tipo.LADO, -1.0)
	await _esperar(Jugador.TICKS_LLEGAR_CAMINANDO + 2)
	_caso("entrar caminando por una puerta no da pasos (%d)" % (_pasos - pasos), _pasos == pasos)
	sala.free()
	Partida.reiniciar()
	Eventos.jugador_paso.disconnect(_al_paso)
	Eventos.jugador_aterrizo.disconnect(_al_aterrizar)


func _al_paso() -> void:
	_pasos += 1


func _al_aterrizar(_velocidad: float, _duro: bool, picada: bool) -> void:
	_aterrizajes += 1
	if picada:
		_picadas += 1
