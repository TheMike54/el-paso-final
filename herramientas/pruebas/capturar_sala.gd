extends Node
# Saca una captura de una sala del juego, cargada como la carga el juego, en cada posicion de camara pedida (por
# omision la rejilla de Medicion, que llega a los extremos de la sala). Necesita ventana: sin ella no dibuja.
# La corre herramientas/capturar.ps1, una vez por resolucion. Vive en herramientas/pruebas/: no viaja en el paquete
# de publicacion. Argumentos despues de «--»: --sala= --salida= --etiqueta= --recursos=bajo|alto --puntos=640:360;1700:360

const TICKS_ASENTAR: int = 70
const TICKS_MOVER: int = 6

var _sala: String = "celda_1"
var _salida: String = ""
var _etiqueta: String = "captura"
var _recursos: String = Recursos.BAJO
var _puntos: Array[Vector2] = []


func _ready() -> void:
	_leer_argumentos()
	AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Master"), true)
	_empezar.call_deferred()


func _leer_argumentos() -> void:
	for argumento: String in OS.get_cmdline_user_args():
		var partes: PackedStringArray = argumento.trim_prefix("--").split("=", true, 1)
		if partes.size() != 2:
			continue
		var valor: String = partes[1]
		match partes[0]:
			"sala":
				_sala = valor
			"salida":
				_salida = valor
			"etiqueta":
				_etiqueta = valor
			"recursos":
				_recursos = valor
			"puntos":
				for punto: String in valor.split(";", false):
					var xy: PackedStringArray = punto.split(":", false)
					if xy.size() == 2:
						_puntos.append(Vector2(xy[0].to_float(), xy[1].to_float()))


func _empezar() -> void:
	if Ajustes.sin_ventana():
		_terminar(0, 1, "sin ventana: headless no dibuja")
		return
	if _salida.is_empty() or DirAccess.make_dir_recursive_absolute(_salida) != OK:
		_terminar(0, 1, "no se pudo crear la carpeta de salida '%s'" % _salida)
		return
	# Este nodo deja de ser la escena actual: el cambio de escena reemplaza solo la sala y la captura sigue viva.
	get_tree().current_scene = null
	var sala: Sala = await _cargar(_sala)
	if sala == null:
		_terminar(0, 1, "no hay sala '%s'" % _sala)
		return
	var jugador: Jugador = get_tree().get_first_node_in_group(Jugador.GRUPO) as Jugador
	if jugador == null:
		_terminar(0, 1, "la sala '%s' no tiene jugador" % _sala)
		return
	# Sin su tick el jugador no se mueve ni mueve la camara.
	jugador.set_physics_process(false)
	var camara: Camera2D = jugador.get_node(^"Camara") as Camera2D
	var puntos: Array[Vector2] = _puntos if not _puntos.is_empty() else preload("res://herramientas/pruebas/medicion.gd").rejilla(sala.limites)
	var hechas: int = 0
	var fallos: int = 0
	for punto: Vector2 in puntos:
		camara.global_position = punto
		camara.reset_smoothing()
		for i: int in range(TICKS_MOVER):
			await get_tree().physics_frame
		await RenderingServer.frame_post_draw
		var imagen: Image = get_viewport().get_texture().get_image()
		var ruta: String = "%s/%s_%s_x%d_y%d.png" % [_salida, _sala, _etiqueta, roundi(punto.x), roundi(punto.y)]
		if imagen.save_png(ruta) == OK:
			hechas += 1
			print("CAPTURA archivo=%s tam=%dx%d" % [ruta, imagen.get_width(), imagen.get_height()])
		else:
			fallos += 1
			print("CAPTURA_FALLA archivo=%s" % ruta)
	_terminar(hechas, fallos, "")


# Carga la sala sin puerta de llegada (el jugador aparece en Entrada), con los ajustes fijos de la captura:
# recursos pedidos, sin luces avanzadas ni niebla, como la medicion.
func _cargar(id: String) -> Sala:
	Ajustes.recursos = _recursos
	Ajustes.luces_avanzadas = false
	Ajustes.niebla = false
	Sala.puerta_llegada = &""
	Sala.estacion_llegada = ""
	Sala.llegada_a_banco = false
	Sala.cambio_pedido_ms = -1
	var ruta: String = Sala.ruta_de(id)
	if ruta.is_empty() or not ResourceLoader.exists(ruta):
		return null
	get_tree().change_scene_to_file(ruta)
	var sala: Sala = null
	while sala == null:
		await get_tree().process_frame
		sala = get_tree().current_scene as Sala
	for i: int in range(TICKS_ASENTAR):
		await get_tree().physics_frame
	return sala


func _terminar(hechas: int, fallos: int, motivo: String) -> void:
	print("CAPTURAS sala=%s etiqueta=%s total=%d fallos=%d %s" % [_sala, _etiqueta, hechas, fallos, motivo])
	get_tree().quit(1 if fallos > 0 else 0)
