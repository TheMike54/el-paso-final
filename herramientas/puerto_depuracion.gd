extends Node
# Puerto de depuracion, modo guion: reproduce entradas por cuadro de fisica y compara el
# estado con el archivo .esperado. Imprime "GUION OK" o "GUION FALLA" y sale con 0 o 1.
# No es autoload: lo carga nucleo/arranque.gd solo en builds de depuracion, y sin el
# argumento --guion= no hace nada. Asi el CI comprueba una sala sin abrir ventana.
const GRUPO_JUGADOR: StringName = &"jugador"
const TOLERANCIA: float = 0.5

var _ruta: String = ""
var _escena: String = ""
var _cambio_lanzado: bool = false
var _cuadro: int = 0
var _fin: int = 0
var _cuadros: PackedInt32Array = []
var _acciones: Array[StringName] = []
var _pulsar: Array[bool] = []
var _esperado: Array[PackedStringArray] = []
# Una cuenta por cada linea "senal" del esperado, en el mismo orden.
var _conteos: PackedInt32Array = []


func _ready() -> void:
	process_physics_priority = -100
	# Sigue contando cuadros con el juego en pausa: un guion puede abrirla y volver a cerrarla.
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_physics_process(false)
	for argumento: String in OS.get_cmdline_user_args():
		if argumento.begins_with("--guion="):
			_ruta = argumento.trim_prefix("--guion=").replace("\\", "/")
	if _ruta.is_empty():
		return
	var motivo: String = _cargar()
	if motivo.is_empty():
		set_physics_process(true)
	else:
		_terminar(false, motivo)


func _physics_process(_delta: float) -> void:
	if not _escena_lista():
		return
	_cuadro += 1
	if _cuadro == 1:
		var motivo: String = _conectar_senales()
		if not motivo.is_empty():
			_terminar(false, motivo)
			return
	if _cuadro >= _fin:
		var diferencias: PackedStringArray = _comparar()
		_terminar(diferencias.is_empty(), "; ".join(diferencias))
		return
	for i: int in range(_cuadros.size()):
		if _cuadros[i] == _cuadro:
			if _pulsar[i]:
				Input.action_press(_acciones[i])
			else:
				Input.action_release(_acciones[i])


# Lee el guion y su esperado. Devuelve el motivo del fallo, o "" si los dos son validos.
func _cargar() -> String:
	var ruta_guion: String = _ruta if _ruta.is_absolute_path() else "res://" + _ruta
	if not FileAccess.file_exists(ruta_guion):
		return "no existe el guion"
	for linea: String in _lineas(ruta_guion):
		var partes: PackedStringArray = linea.split(" ", false)
		if partes.size() == 2 and partes[0] == "fin" and partes[1].is_valid_int():
			_fin = partes[1].to_int()
		elif partes.size() == 2 and partes[0] == "escena":
			if not partes[1].ends_with(".tscn") or not ResourceLoader.exists(partes[1]):
				return "la escena '%s' no existe" % partes[1]
			_escena = partes[1]
		elif partes.size() == 3 and partes[0].is_valid_int() and (partes[2] == "press" or partes[2] == "release"):
			if not InputMap.has_action(partes[1]):
				return "la accion '%s' no esta en el InputMap" % partes[1]
			_cuadros.append(partes[0].to_int())
			_acciones.append(StringName(partes[1]))
			_pulsar.append(partes[2] == "press")
		else:
			return "linea de guion no valida: '%s'" % linea
	if _fin < 1:
		return "falta la linea 'fin <cuadro>'"
	for cuadro: int in _cuadros:
		if cuadro < 1 or cuadro >= _fin:
			return "la entrada del cuadro %d queda fuera de 1..%d" % [cuadro, _fin - 1]

	var ruta_esperado: String = ruta_guion.get_basename() + ".esperado"
	if not FileAccess.file_exists(ruta_esperado):
		return "no existe el archivo .esperado del guion"
	for linea: String in _lineas(ruta_esperado):
		var partes: PackedStringArray = linea.split(" ", false)
		if not _linea_esperada_valida(partes):
			return "linea de esperado no valida: '%s'" % linea
		_esperado.append(partes)
		if partes[0] == "senal":
			_conteos.append(0)
	if _esperado.is_empty():
		return "el archivo .esperado no comprueba nada"
	return ""


func _linea_esperada_valida(partes: PackedStringArray) -> bool:
	var n: int = partes.size()
	match partes[0]:
		"x", "y":
			return (n == 2 or n == 3) and partes[1].is_valid_float() and (n == 2 or partes[2].is_valid_float())
		"en_suelo":
			return n == 2 and (partes[1] == "true" or partes[1] == "false")
		"escena":
			return n == 2
		"valor":
			return n == 4 or (n == 5 and partes[3].is_valid_float() and partes[4].is_valid_float())
		"senal":
			return n == 4 and partes[3].is_valid_int()
	return false


# Con la linea "escena", cambia a esa escena en el primer cuadro y no deja contar cuadros del
# guion hasta que es la escena actual: el .esperado no depende de cuanto tarda en cargar.
# En el _ready del puerto la escena principal todavia no existe, por eso no se cambia ahi.
# Solo espera la primera carga: despues, un cambio de sala del propio guion no detiene la cuenta.
func _escena_lista() -> bool:
	if _escena.is_empty() or _cuadro > 0:
		return true
	var actual: Node = get_tree().current_scene
	if actual != null and actual.scene_file_path == _escena:
		return true
	if not _cambio_lanzado:
		_cambio_lanzado = true
		var error: Error = get_tree().change_scene_to_file(_escena)
		if error != OK:
			_terminar(false, "no se pudo cargar la escena '%s' (error %d)" % [_escena, error])
	return false


# Las lineas "senal" se conectan en el cuadro 1 y no en _ready: en _ready del puerto ni la
# escena ni los autoloads que van despues de Arranque existen todavia.
func _conectar_senales() -> String:
	var k: int = 0
	for partes: PackedStringArray in _esperado:
		if partes[0] != "senal":
			continue
		var nodo: Node = _nodo(partes[1])
		if nodo == null:
			return "senal: no existe el nodo '%s'" % partes[1]
		var argumentos: int = -1
		for senal: Dictionary in nodo.get_signal_list():
			if senal["name"] == partes[2]:
				var lista: Array = senal["args"]
				argumentos = lista.size()
		if argumentos < 0:
			return "senal: el nodo '%s' no tiene la senal '%s'" % [partes[1], partes[2]]
		var contar: Callable = _contar.bind(k)
		nodo.connect(partes[2], contar.unbind(argumentos) if argumentos > 0 else contar)
		k += 1
	return ""


func _contar(indice: int) -> void:
	_conteos[indice] += 1


# Ruta absoluta (/root/...) o relativa a la escena actual ("." es su raiz).
func _nodo(ruta: String) -> Node:
	if ruta.begins_with("/"):
		return get_tree().root.get_node_or_null(NodePath(ruta))
	var escena: Node = get_tree().current_scene
	return escena.get_node_or_null(NodePath(ruta)) if escena != null else null


func _lineas(ruta: String) -> PackedStringArray:
	var limpias: PackedStringArray = []
	for linea: String in FileAccess.get_file_as_string(ruta).split("\n", false):
		var texto: String = linea.strip_edges()
		if not texto.is_empty() and not texto.begins_with("#"):
			limpias.append(texto)
	return limpias


# Compara cada linea del esperado con el estado actual. Devuelve las diferencias.
func _comparar() -> PackedStringArray:
	var diferencias: PackedStringArray = []
	var jugador: Node2D = get_tree().get_first_node_in_group(GRUPO_JUGADOR) as Node2D
	var escena: Node = get_tree().current_scene
	var k: int = 0
	for partes: PackedStringArray in _esperado:
		var clave: String = partes[0]
		if clave == "escena":
			var ruta_escena: String = escena.scene_file_path if escena != null else "(ninguna)"
			if ruta_escena != partes[1]:
				diferencias.append("escena esperado=%s obtenido=%s" % [partes[1], ruta_escena])
		elif clave == "valor":
			var diferencia: String = _comparar_valor(partes)
			if not diferencia.is_empty():
				diferencias.append(diferencia)
		elif clave == "senal":
			if _conteos[k] != partes[3].to_int():
				diferencias.append("senal %s %s esperado=%s obtenido=%d" % [partes[1], partes[2], partes[3], _conteos[k]])
			k += 1
		elif jugador == null:
			diferencias.append("%s: no hay un nodo en el grupo '%s'" % [clave, GRUPO_JUGADOR])
		elif clave == "en_suelo":
			var cuerpo: CharacterBody2D = jugador as CharacterBody2D
			var en_suelo: String = str(cuerpo != null and cuerpo.is_on_floor())
			if en_suelo != partes[1]:
				diferencias.append("en_suelo esperado=%s obtenido=%s" % [partes[1], en_suelo])
		else:
			var real: float = jugador.global_position.x if clave == "x" else jugador.global_position.y
			var tolerancia: float = partes[2].to_float() if partes.size() == 3 else TOLERANCIA
			if absf(real - partes[1].to_float()) > tolerancia:
				diferencias.append("%s esperado=%s tolerancia=%s obtenido=%.2f" % [clave, partes[1], tolerancia, real])
	return diferencias


# "valor <nodo> <propiedad> <valor> [tolerancia]". La propiedad admite subpropiedades
# (position:x). Un numero se compara con tolerancia; cualquier otro valor, por su texto.
func _comparar_valor(partes: PackedStringArray) -> String:
	var nodo: Node = _nodo(partes[1])
	if nodo == null:
		return "valor: no existe el nodo '%s'" % partes[1]
	var real: Variant = nodo.get_indexed(NodePath(partes[2]))
	var tipo: int = typeof(real)
	if partes[3].is_valid_float() and (tipo == TYPE_INT or tipo == TYPE_FLOAT):
		var numero: float = real
		var tolerancia: float = partes[4].to_float() if partes.size() == 5 else TOLERANCIA
		if absf(numero - partes[3].to_float()) > tolerancia:
			return "valor %s %s esperado=%s tolerancia=%s obtenido=%.2f" % [partes[1], partes[2], partes[3], tolerancia, numero]
	elif str(real) != partes[3]:
		return "valor %s %s esperado=%s obtenido=%s" % [partes[1], partes[2], partes[3], str(real)]
	return ""


func _terminar(bien: bool, detalle: String) -> void:
	set_physics_process(false)
	if bien:
		print("GUION OK %s cuadro=%d" % [_ruta, _cuadro])
	else:
		print("GUION FALLA %s: %s" % [_ruta, detalle])
	get_tree().quit(0 if bien else 1)
