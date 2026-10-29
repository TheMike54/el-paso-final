extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de la musica: Musica vive en Arranque, el pedido se aplica en el tick siguiente y gana el ultimo, un tema que
# ya suena (o que se esta yendo) no vuelve a empezar, SILENCIO calla sin reproducir nada y el panel de audio pide su
# tema. Con la sala Musica: reaparecer en el banco dentro de su RegionMusica no reinicia el tema de la region.

const ESCENA_SALA: PackedScene = preload("res://herramientas/salas/sala_musica.tscn")
const BANCO: String = "banco_musica"
# Ticks para que un pedido se vea: lo aplica el tick siguiente al del pedido y se lee al empezar el otro.
const TICKS_APLICAR: int = 2


func _ready() -> void:
	# Musica es hija de un autoload: siempre existe (tutorials/scripting/singletons_autoload.rst:30).
	var musica: Musica = Arranque.musica
	var en_bus: bool = musica.get_child_count() == 2
	for hijo: Node in musica.get_children():
		var reproductor: AudioStreamPlayer = hijo as AudioStreamPlayer
		en_bus = en_bus and reproductor != null and reproductor.bus == Ajustes.BUS_MUSICA
	_caso("Arranque crea Musica con sus reproductores en el bus Musica, en pausa tambien",
			en_bus and musica.process_mode == Node.PROCESS_MODE_ALWAYS)
	await get_tree().physics_frame
	# Los temas de los casos de logica son recursos vacios: se callan los reproductores para no tocarlos con pantalla.
	var mudo: bool = musica.mudo
	musica.mudo = true
	await _pedidos(musica)
	await _sin_reiniciar(musica)
	await _sin_picos(musica)
	await _silencio_y_volumen(musica)
	await _panel(musica)
	musica.mudo = mudo
	await _region(musica)
	_resumen()


func _pedidos(musica: Musica) -> void:
	var a: AudioStream = AudioStreamWAV.new()
	var b: AudioStream = AudioStreamWAV.new()
	var antes: AudioStream = musica.actual
	musica.poner(a)
	_caso("el pedido no se aplica en el mismo tick", musica.actual == antes)
	await _esperar(TICKS_APLICAR)
	_caso("y si en el siguiente", musica.actual == a)
	var arranques: int = musica.arranques
	musica.poner(b)
	musica.poner(a)
	await _esperar(TICKS_APLICAR)
	_caso("dos pedidos en el mismo tick: gana el ultimo y el primero no empieza", musica.actual == a and musica.arranques == arranques)
	musica.poner(b, Musica.DB_NORMAL)
	musica.poner(null, Musica.DB_SILENCIO)
	await _esperar(TICKS_APLICAR)
	_caso("un pedido sin tema no borra el tema pendiente y su volumen gana",
			musica.actual == b and is_equal_approx(musica.volumen_db, Musica.DB_SILENCIO) and musica.arranques == arranques + 1)
	musica.poner(null, Musica.DB_NORMAL, 0.01)
	await _esperar(TICKS_APLICAR + 2)
	_caso("sin tema solo cambia el volumen de region", musica.actual == b and is_equal_approx(_volumen_de(musica, b), 0.0))


func _sin_reiniciar(musica: Musica) -> void:
	var a: AudioStream = AudioStreamWAV.new()
	var b: AudioStream = AudioStreamWAV.new()
	musica.poner(a, Musica.DB_NORMAL, 0.1)
	await _esperar(TICKS_APLICAR + 10)
	var arranques: int = musica.arranques
	musica.poner(a)
	await _esperar(TICKS_APLICAR)
	_caso("pedir el tema que ya suena no lo reinicia", musica.arranques == arranques)
	musica.poner(b)
	await _esperar(TICKS_APLICAR + 10)
	musica.poner(a)
	await _esperar(TICKS_APLICAR)
	_caso("A, B y otra vez A dentro del fundido: A sube desde donde iba, sin empezar de nuevo",
			musica.actual == a and musica.arranques == arranques + 1)


# Un pedido que baja o calla un tema no lo hace sonar mas fuerte por el camino: el volumen de cada reproductor durante
# el fundido no pasa del mayor entre el de antes y el final (docs/errores/2026-10-27-musica-sube-al-callar.md).
func _sin_picos(musica: Musica) -> void:
	var a: AudioStream = AudioStreamWAV.new()
	var b: AudioStream = AudioStreamWAV.new()
	musica.poner(a, Musica.DB_NORMAL, 0.01)
	await _esperar(TICKS_APLICAR + 2)
	musica.poner(null, Musica.DB_SILENCIO, 0.01)
	await _esperar(TICKS_APLICAR + 2)
	musica.poner(Musica.SILENCIO, Musica.DB_NORMAL, 0.1)
	_caso("SILENCIO con el tema a DB_SILENCIO no lo sube por el camino", await _sin_subir(musica, TICKS_APLICAR + 12))
	musica.poner(a, Musica.DB_NORMAL, 0.01)
	await _esperar(TICKS_APLICAR + 2)
	musica.poner(b, Musica.DB_SILENCIO, 0.1)
	_caso("un tema nuevo a DB_SILENCIO entra callado y el que se va solo baja", await _sin_subir(musica, TICKS_APLICAR + 12))


# Vigila volume_db de cada reproductor tick a tick: ninguno pasa del mayor entre el que tenia al pedir y el final, con
# medio dB de tolerancia. Lee el reproductor y no el estado de Musica porque es lo que se oye; con mudo se escribe igual.
func _sin_subir(musica: Musica, ticks: int) -> bool:
	var reproductores: Array[AudioStreamPlayer] = []
	var inicio: Array[float] = []
	var maximo: Array[float] = []
	for hijo: Node in musica.get_children():
		var reproductor: AudioStreamPlayer = hijo as AudioStreamPlayer
		reproductores.append(reproductor)
		inicio.append(reproductor.volume_db)
		maximo.append(reproductor.volume_db)
	for t: int in range(ticks):
		await get_tree().physics_frame
		for i: int in range(reproductores.size()):
			maximo[i] = maxf(maximo[i], reproductores[i].volume_db)
	for i: int in range(reproductores.size()):
		if maximo[i] > maxf(inicio[i], reproductores[i].volume_db) + 0.5:
			print("musica: el reproductor %d subio a %.1f dB (al pedir %.1f, al final %.1f)"
					% [i, maximo[i], inicio[i], reproductores[i].volume_db])
			return false
	return true


func _silencio_y_volumen(musica: Musica) -> void:
	var arranques: int = musica.arranques
	musica.poner(Musica.SILENCIO, Musica.DB_NORMAL, 0.1)
	await _esperar(TICKS_APLICAR + 12)
	var callados: bool = true
	for hijo: Node in musica.get_children():
		var reproductor: AudioStreamPlayer = hijo as AudioStreamPlayer
		callados = callados and reproductor != null and not reproductor.playing and reproductor.stream == null
	_caso("SILENCIO no empieza nada y, al terminar el fundido, deja los reproductores libres",
			musica.actual == Musica.SILENCIO and musica.arranques == arranques and callados)
	_caso("con SILENCIO no se oye nada", not musica.se_oye())


func _panel(musica: Musica) -> void:
	var arranques: int = musica.arranques
	musica.probar(true)
	await _esperar(TICKS_APLICAR)
	_caso("el panel, sin nada que se oiga, pone el tema del menu", musica.actual == Musica.TEMA_MENU and musica.arranques == arranques + 1)
	musica.probar(false)
	await _esperar(TICKS_APLICAR)
	_caso("al cerrar el panel vuelve lo que habia", musica.actual == Musica.SILENCIO)
	var a: AudioStream = AudioStreamWAV.new()
	musica.poner(a, Musica.DB_NORMAL, 0.01)
	await _esperar(TICKS_APLICAR + 2)
	arranques = musica.arranques
	musica.probar(true)
	await _esperar(TICKS_APLICAR)
	musica.probar(false)
	await _esperar(TICKS_APLICAR)
	_caso("con un tema que se oye, el panel no lo toca", musica.actual == a and musica.arranques == arranques)
	musica.poner(a, Musica.DB_SILENCIO, 0.01)
	await _esperar(TICKS_APLICAR + 2)
	_caso("un tema a DB_SILENCIO no se oye", not musica.se_oye())


# La sala Musica es silenciosa y su region, sobre el banco, toca el tema del menu. Se entra en el banco con el tema
# del menu sonando (cargar desde el menu), se sale y se vuelve a la region, y se reaparece en el banco: liberar la sala
# e instanciarla otra vez con la llegada en el banco es lo que hace el Fundido al reaparecer.
func _region(musica: Musica) -> void:
	_aislar_partida()
	musica.poner(Musica.TEMA_MENU, Musica.DB_NORMAL, 0.01)
	await _esperar(TICKS_APLICAR + 2)
	var arranques: int = musica.arranques
	var sala: Sala = _sala_en_el_banco()
	var region: RegionMusica = sala.get_node(^"Region") as RegionMusica
	await _esperar(10)
	_caso("entrar en el banco con el tema del menu sonando no lo reinicia",
			region.dentro and musica.actual == Musica.TEMA_MENU and musica.arranques == arranques
			and is_equal_approx(musica.volumen_db, Musica.DB_NORMAL))
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	jugador.global_position = (sala.get_node(^"Entrada") as Node2D).global_position
	await _esperar(6)
	_caso("salir de la region baja el volumen y no cambia el tema",
			not region.dentro and musica.actual == Musica.TEMA_MENU and is_equal_approx(musica.volumen_db, region.volumen_salir_db))
	jugador.global_position = (sala.get_node(^"Banco") as Node2D).global_position
	await _esperar(6)
	_caso("volver a la region sube el volumen sin reiniciar el tema",
			region.dentro and is_equal_approx(musica.volumen_db, region.volumen_entrar_db) and musica.arranques == arranques)
	var posicion: float = _posicion_del_tema(musica)
	sala.free()
	_caso("liberar la sala con el jugador en la region no baja la musica", musica.se_oye())
	sala = _sala_en_el_banco()
	region = sala.get_node(^"Region") as RegionMusica
	await _esperar(10)
	_caso("reaparecer en el banco dentro de la region no reinicia el tema",
			region.dentro and musica.actual == Musica.TEMA_MENU and musica.arranques == arranques
			and is_equal_approx(musica.volumen_db, Musica.DB_NORMAL))
	if not musica.mudo:
		_caso("con pantalla, la reproduccion sigue donde iba (%.2f s, antes %.2f s)" % [_posicion_del_tema(musica), posicion],
				posicion > 0.0 and _posicion_del_tema(musica) > posicion)
	sala.free()
	_restaurar_partida()


func _sala_en_el_banco() -> Sala:
	Partida.banco = BANCO
	Sala.llegada_a_banco = true
	var sala: Sala = ESCENA_SALA.instantiate() as Sala
	add_child(sala)
	return sala


# volume_db del reproductor que tiene el tema (-100 si ninguno lo tiene).
func _volumen_de(musica: Musica, tema: AudioStream) -> float:
	for hijo: Node in musica.get_children():
		var reproductor: AudioStreamPlayer = hijo as AudioStreamPlayer
		if reproductor.stream == tema:
			return reproductor.volume_db
	return -100.0


# Posicion de reproduccion del tema del menu en el reproductor que lo toca (0 si ninguno suena).
func _posicion_del_tema(musica: Musica) -> float:
	for hijo: Node in musica.get_children():
		var reproductor: AudioStreamPlayer = hijo as AudioStreamPlayer
		if reproductor != null and reproductor.playing and reproductor.stream == Musica.TEMA_MENU:
			return reproductor.get_playback_position()
	return 0.0
