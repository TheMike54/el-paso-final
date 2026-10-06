extends Node
# Puerto de depuracion, modo guion: reproduce entradas por cuadro de fisica y compara el
# estado con el archivo .esperado. Imprime "GUION OK" o "GUION FALLA" y sale con 0 o 1.
# No es autoload: lo carga nucleo/arranque.gd solo en builds de depuracion, y sin el
# argumento --guion= no hace nada. Asi el CI comprueba una sala sin abrir ventana.
const GRUPO_JUGADOR: StringName = &"jugador"
const TOLERANCIA: float = 0.5
const CLAVES: PackedStringArray = ["x", "y", "en_suelo", "escena"]

var _ruta: String = ""
var _cuadro: int = 0
var _fin: int = 0
var _cuadros: PackedInt32Array = []
var _acciones: Array[StringName] = []
var _pulsar: Array[bool] = []
var _esperado: Array[PackedStringArray] = []


func _ready() -> void:
	process_physics_priority = -100
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
	_cuadro += 1
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
		var numerica: bool = partes[0] == "x" or partes[0] == "y"
		var valida: bool = CLAVES.has(partes[0]) and partes.size() >= 2 and partes.size() <= (3 if numerica else 2)
		if valida and numerica:
			valida = partes[1].is_valid_float() and (partes.size() == 2 or partes[2].is_valid_float())
		elif valida and partes[0] == "en_suelo":
			valida = partes[1] == "true" or partes[1] == "false"
		if not valida:
			return "linea de esperado no valida: '%s'" % linea
		_esperado.append(partes)
	if _esperado.is_empty():
		return "el archivo .esperado no comprueba nada"
	return ""


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
	for partes: PackedStringArray in _esperado:
		var clave: String = partes[0]
		if clave == "escena":
			var ruta_escena: String = escena.scene_file_path if escena != null else "(ninguna)"
			if ruta_escena != partes[1]:
				diferencias.append("escena esperado=%s obtenido=%s" % [partes[1], ruta_escena])
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


func _terminar(bien: bool, detalle: String) -> void:
	set_physics_process(false)
	if bien:
		print("GUION OK %s cuadro=%d" % [_ruta, _cuadro])
	else:
		print("GUION FALLA %s: %s" % [_ruta, detalle])
	get_tree().quit(0 if bien else 1)
