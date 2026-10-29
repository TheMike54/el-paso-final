extends Node
# Medicion A/B de rendimiento: carga cada sala pedida como el juego (change_scene_to_file de Sala.ruta_de), deja al
# jugador quieto, pone la camara en posiciones fijas y escribe en el log una linea MEDICION_DATO por posicion y
# variante (Recursos, luces 2D, niebla), y una SALA <id> carga_ms=<n> por carga. Vive en herramientas/pruebas/: no
# viaja en el paquete de publicacion. Como se corre (PC y APK de medicion): docs/pruebas.md, «Medicion de rendimiento».

## Vista de referencia del juego (project.godot): el paso de la rejilla de posiciones sale de ella.
const VISTA: Vector2 = Vector2(1280.0, 720.0)
## Paso de la rejilla, en vistas: 0,9 deja un poco de traslape entre una posicion y la siguiente.
const PASO_REJILLA: float = 0.9
## Ticks de fisica tras cargar: el fundido de entrada (Fundido) termina y la sala queda como se juega.
const TICKS_ASENTAR: int = 70
## Ticks tras mover la camara, antes de calentar.
const TICKS_MOVER: int = 6
## Bytes por MB, para los monitores de memoria.
const MB: float = 1024.0 * 1024.0

var _salas: PackedStringArray = ["celda_1"]
var _recursos: PackedStringArray = [Recursos.BAJO, Recursos.ALTO]
var _luces: Array[bool] = [false]
var _niebla: Array[bool] = [false]
var _calentar: float = 2.0
var _muestra: float = 5.0
# Posiciones de camara pedidas a mano (--puntos=); vacio: la rejilla sobre los limites de cada sala.
var _puntos: Array[Vector2] = []


func _ready() -> void:
	_leer_argumentos()
	# Nadie oye la medicion: la musica de una sala no debe sonar mientras se mide.
	AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Master"), true)
	if not Ajustes.sin_ventana():
		# Sin V-Sync los FPS no se topan en el refresco (class_displayserver.rst:7553); Android puede ignorarlo, por
		# eso se imprime el modo que quedo.
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_empezar.call_deferred()


# --salas=celda_1,celda_2 --recursos=bajo,alto --luces=no,si --niebla=no,si --calentar=2 --muestra=5
# --puntos=640:360;1700:360 (argumentos despues de «--», OS.get_cmdline_user_args).
func _leer_argumentos() -> void:
	for argumento: String in OS.get_cmdline_user_args():
		var partes: PackedStringArray = argumento.trim_prefix("--").split("=", true, 1)
		if partes.size() != 2:
			continue
		var valor: String = partes[1]
		match partes[0]:
			"salas":
				_salas = valor.split(",", false)
			"recursos":
				_recursos = valor.split(",", false)
			"luces":
				_luces = _si_no(valor)
			"niebla":
				_niebla = _si_no(valor)
			"calentar":
				_calentar = valor.to_float()
			"muestra":
				_muestra = valor.to_float()
			"puntos":
				for punto: String in valor.split(";", false):
					var xy: PackedStringArray = punto.split(":", false)
					if xy.size() == 2:
						_puntos.append(Vector2(xy[0].to_float(), xy[1].to_float()))


func _si_no(valor: String) -> Array[bool]:
	var lista: Array[bool] = []
	for parte: String in valor.split(",", false):
		lista.append(parte == "si")
	return lista


func _empezar() -> void:
	# Este nodo deja de ser la escena actual: el cambio de escena reemplaza solo la sala y la medicion sigue viva.
	get_tree().current_scene = null
	print("MEDICION inicio so=%s 32bits=%s ventana=%s vsync=%d sin_ventana=%s calentar=%.1f muestra=%.1f" % [
		OS.get_name(), OS.has_feature("32"), get_window().size, DisplayServer.window_get_vsync_mode(),
		Ajustes.sin_ventana(), _calentar, _muestra])
	# Una carga que no se mide, para que la primera variante no pague la carga en frio.
	if not _salas.is_empty():
		await _cargar(_salas[0], _recursos[0] if not _recursos.is_empty() else Recursos.BAJO, false, false)
	for recursos: String in _recursos:
		for luces: bool in _luces:
			for niebla: bool in _niebla:
				for id: String in _salas:
					await _medir_sala(id, recursos, luces, niebla)
	print("MEDICION FIN")
	get_tree().quit()


func _medir_sala(id: String, recursos: String, luces: bool, niebla: bool) -> void:
	var sala: Sala = await _cargar(id, recursos, luces, niebla)
	if sala == null:
		return
	var jugador: Jugador = get_tree().get_first_node_in_group(Jugador.GRUPO) as Jugador
	if jugador == null:
		push_error("Medicion: %s no tiene jugador" % id)
		return
	# Sin su tick el jugador no se mueve ni mueve la camara (CamaraJugador.seguir la llama el jugador).
	jugador.set_physics_process(false)
	var camara: Camera2D = jugador.get_node(^"Camara") as Camera2D
	var variante: String = "recursos=%s luces=%s niebla=%s" % [recursos, _texto(luces), _texto(niebla)]
	var puntos: Array[Vector2] = _puntos if not _puntos.is_empty() else rejilla(sala.limites)
	for punto: Vector2 in puntos:
		camara.global_position = punto
		camara.reset_smoothing()
		await _esperar_fisica(TICKS_MOVER)
		await _muestrear(id, punto, variante)


# Carga la sala sin puerta de llegada (el jugador aparece en Entrada) con los ajustes de la variante, puestos antes:
# LuzSala, Niebla y Prescindible los leen al entrar.
func _cargar(id: String, recursos: String, luces: bool, niebla: bool) -> Sala:
	Ajustes.recursos = recursos
	Ajustes.luces_avanzadas = luces
	Ajustes.niebla = niebla
	Sala.puerta_llegada = &""
	Sala.estacion_llegada = ""
	Sala.llegada_a_banco = false
	# Sin cambio pedido la sala no imprime su propia linea: la escribe la medicion.
	Sala.cambio_pedido_ms = -1
	var ruta: String = Sala.ruta_de(id)
	if ruta.is_empty() or not ResourceLoader.exists(ruta):
		push_error("Medicion: no hay sala '%s'" % id)
		return null
	var antes: int = Time.get_ticks_msec()
	get_tree().change_scene_to_file(ruta)
	var sala: Sala = null
	while sala == null:
		await get_tree().process_frame
		sala = get_tree().current_scene as Sala
	print("SALA %s carga_ms=%d recursos=%s luces=%s niebla=%s" % [id, Time.get_ticks_msec() - antes, recursos,
		_texto(luces), _texto(niebla)])
	await _esperar_fisica(TICKS_ASENTAR)
	return sala


## Centros de camara que cubren los limites con pasos de PASO_REJILLA vistas; en un eje mas chico que la vista, el
## centro. Publica para poder probarla sin cargar una sala.
static func rejilla(limites: Rect2) -> Array[Vector2]:
	var media: Vector2 = VISTA / 2.0
	var xs: Array[float] = _pasos(limites.position.x + media.x, limites.end.x - media.x, VISTA.x * PASO_REJILLA)
	var ys: Array[float] = _pasos(limites.position.y + media.y, limites.end.y - media.y, VISTA.y * PASO_REJILLA)
	var puntos: Array[Vector2] = []
	for y: float in ys:
		for x: float in xs:
			puntos.append(Vector2(roundf(x), roundf(y)))
	return puntos


static func _pasos(desde: float, hasta: float, paso: float) -> Array[float]:
	var lista: Array[float] = []
	if hasta <= desde:
		lista.append((desde + hasta) / 2.0)
		return lista
	var tramos: int = ceili((hasta - desde) / paso)
	for i: int in range(tramos + 1):
		lista.append(lerpf(desde, hasta, float(i) / float(tramos)))
	return lista


# Calienta _calentar s, luego cuenta cuadros durante _muestra s sin tope de FPS. fps es el promedio y peor_ms el
# cuadro mas largo; draw_calls, objetos y primitivas, el maximo de un cuadro (class_performance.rst:167-183); la
# memoria de texturas y de video y los nodos, al final (:149, :191-195).
func _muestrear(id: String, punto: Vector2, variante: String) -> void:
	# Ajustes.aplicar_fps (ContadorFps, al entrar a la sala) lo vuelve a 60: se quita el tope en cada muestra.
	Engine.max_fps = 0
	await _esperar_segundos(_calentar)
	var cuadros: int = 0
	var peor: int = 0
	var llamadas: float = 0.0
	var objetos: float = 0.0
	var primitivas: float = 0.0
	var inicio: int = Time.get_ticks_usec()
	var anterior: int = inicio
	while Time.get_ticks_usec() - inicio < int(_muestra * 1000000.0):
		await get_tree().process_frame
		var ahora: int = Time.get_ticks_usec()
		peor = maxi(peor, ahora - anterior)
		anterior = ahora
		cuadros += 1
		llamadas = maxf(llamadas, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		objetos = maxf(objetos, Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
		primitivas = maxf(primitivas, Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	var segundos: float = float(Time.get_ticks_usec() - inicio) / 1000000.0
	print(("MEDICION_DATO sala=%s x=%d y=%d %s fps=%.1f peor_ms=%.1f draw_calls=%d objetos=%d primitivas=%d"
			+ " tex_mb=%.1f video_mb=%.1f nodos=%d") % [
		id, roundi(punto.x), roundi(punto.y), variante, float(cuadros) / maxf(segundos, 0.001), float(peor) / 1000.0,
		roundi(llamadas), roundi(objetos), roundi(primitivas),
		Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / MB,
		Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / MB,
		roundi(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))])


func _esperar_segundos(segundos: float) -> void:
	var inicio: int = Time.get_ticks_usec()
	while Time.get_ticks_usec() - inicio < int(segundos * 1000000.0):
		await get_tree().process_frame


func _esperar_fisica(ticks: int) -> void:
	for i: int in range(ticks):
		await get_tree().physics_frame


func _texto(si: bool) -> String:
	return "si" if si else "no"
