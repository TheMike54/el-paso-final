class_name Guardado
extends RefCounted
# Guarda y carga la partida como JSON con numero de version. Escribe en un archivo temporal y
# despues lo renombra, para que un cierre a la mitad nunca deje la partida danada. Al cargar
# distingue partida valida, sin partida, archivo danado y version incompatible.

enum Estado { VALIDA, VACIA, DANADA, INCOMPATIBLE }

const VERSION: int = 2
const RUTA: String = "user://partida.json"
## Campos que toda partida de esta version debe tener, con su tipo despues de leer el JSON
## (los numeros vuelven siempre como float).
const ESQUEMA: Dictionary[String, int] = {
	"banco": TYPE_STRING,
	"sala": TYPE_STRING,
	"vidas_maximas": TYPE_FLOAT,
	"habilidades": TYPE_ARRAY,
}


## Lo que devuelve cargar(): el estado y, solo si es VALIDA, la partida.
class Resultado:
	var estado: Estado
	var partida: Dictionary

	func _init(estado_leido: Estado, partida_leida: Dictionary = {}) -> void:
		estado = estado_leido
		partida = partida_leida


static func guardar(partida: Dictionary, ruta: String = RUTA) -> Error:
	var temporal: String = ruta + ".tmp"
	var archivo: FileAccess = FileAccess.open(temporal, FileAccess.WRITE)
	if archivo == null:
		return FileAccess.get_open_error()
	archivo.store_string(JSON.stringify({"version": VERSION, "partida": partida}, "\t"))
	var error: Error = archivo.get_error()
	archivo.close()
	if error != OK:
		return error
	return DirAccess.rename_absolute(temporal, ruta)


static func cargar(ruta: String = RUTA) -> Resultado:
	if not FileAccess.file_exists(ruta):
		return Resultado.new(Estado.VACIA)
	# JSON.new().parse no imprime errores, a diferencia de JSON.parse_string.
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(ruta)) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return Resultado.new(Estado.DANADA)
	var sobre: Dictionary = json.data
	var version: Variant = sobre.get("version")
	if typeof(version) != TYPE_FLOAT:
		return Resultado.new(Estado.DANADA)
	var numero: float = version
	if numero != VERSION:
		return Resultado.new(Estado.INCOMPATIBLE)
	var contenido: Variant = sobre.get("partida")
	if typeof(contenido) != TYPE_DICTIONARY:
		return Resultado.new(Estado.DANADA)
	var partida: Dictionary = contenido
	for campo: String in ESQUEMA:
		if not partida.has(campo) or typeof(partida[campo]) != ESQUEMA[campo]:
			return Resultado.new(Estado.DANADA)
	return Resultado.new(Estado.VALIDA, partida)
