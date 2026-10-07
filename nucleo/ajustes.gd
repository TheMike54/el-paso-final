class_name Ajustes
extends RefCounted
# Ajustes del jugador (vibracion y temblor de camara), en su propio archivo JSON: son del telefono y no de
# la partida, y asi agregar uno no cambia la version del guardado. Funciones estaticas, como
# Guardado; un archivo que falta o esta danado deja los valores por omision.

const VERSION: int = 1
const RUTA: String = "user://ajustes.json"
## Valores por omision; tambien la lista de ajustes que existen.
const POR_OMISION: Dictionary[String, bool] = {"vibracion": true, "temblor": true}

## Vibrar al pegar, al recibir dano, al curarse y al descansar.
static var vibracion: bool = POR_OMISION["vibracion"]
## Temblor de la camara al aterrizar de una caida; se apaga por mareo.
static var temblor: bool = POR_OMISION["temblor"]
static var _cargados: bool = false


## Carga los ajustes la primera vez que se pide; despues no hace nada.
static func cargar_una_vez(ruta: String = RUTA) -> void:
	if not _cargados:
		cargar(ruta)


static func cargar(ruta: String = RUTA) -> void:
	_cargados = true
	vibracion = POR_OMISION["vibracion"]
	temblor = POR_OMISION["temblor"]
	if not FileAccess.file_exists(ruta):
		return
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(ruta)) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return
	var sobre: Dictionary = json.data
	var version: Variant = sobre.get("version")
	var contenido: Variant = sobre.get("ajustes")
	if typeof(version) != TYPE_FLOAT or typeof(contenido) != TYPE_DICTIONARY:
		return
	var numero: float = version
	if numero != VERSION:
		return
	var ajustes: Dictionary = contenido
	# Una clave que falta (un archivo de antes de que existiera) se queda con su valor por omision.
	var valor: Variant = ajustes.get("vibracion")
	if typeof(valor) == TYPE_BOOL:
		vibracion = valor
	valor = ajustes.get("temblor")
	if typeof(valor) == TYPE_BOOL:
		temblor = valor


## Escribe a un temporal y lo renombra, como el guardado de la partida.
static func guardar(ruta: String = RUTA) -> Error:
	var temporal: String = ruta + ".tmp"
	var archivo: FileAccess = FileAccess.open(temporal, FileAccess.WRITE)
	if archivo == null:
		return FileAccess.get_open_error()
	archivo.store_string(JSON.stringify({"version": VERSION, "ajustes": {"vibracion": vibracion, "temblor": temblor}}, "\t"))
	var error: Error = archivo.get_error()
	archivo.close()
	if error != OK:
		return error
	return DirAccess.rename_absolute(temporal, ruta)
