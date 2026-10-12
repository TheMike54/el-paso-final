class_name Ajustes
extends RefCounted
# Ajustes del jugador (vibracion, temblor de camara, volumen, modo desarrollador, disposicion de los botones
# tactiles y botones del control), en su propio
# archivo JSON: son del telefono y no de la partida, y asi agregar uno no cambia la version del guardado.
# Funciones estaticas, como Guardado; un archivo que falta o esta danado deja los valores por omision.

const VERSION: int = 1
const RUTA: String = "user://ajustes.json"
## Valores por omision de los interruptores; la disposicion de los botones tiene los suyos en
## DisposicionControles.por_omision().
const POR_OMISION: Dictionary[String, bool] = {"vibracion": true, "temblor": true, "modo_desarrollador": false}
const VOLUMEN_POR_OMISION: float = 1.0

## Vibrar al pegar, al recibir dano, al curarse y al descansar.
static var vibracion: bool = POR_OMISION["vibracion"]
## Temblor de la camara al aterrizar de una caida; se apaga por mareo.
static var temblor: bool = POR_OMISION["temblor"]
## Muestra en Configuracion la entrada a la zona de pruebas (tambien en el paquete de publicacion).
static var modo_desarrollador: bool = POR_OMISION["modo_desarrollador"]
## Volumen general, de 0 a 1 (bus Master).
static var volumen: float = VOLUMEN_POR_OMISION
## Modo de recursos: Recursos.AUTO (decide la deteccion), BAJO o ALTO.
static var recursos: String = Recursos.AUTO
## Donde va cada boton tactil, su tamano y la opacidad de todos. El editor de controles la reemplaza.
static var disposicion: DisposicionControles = DisposicionControles.por_omision()
static var _cargados: bool = false


## Carga los ajustes la primera vez que se pide; despues no hace nada.
static func cargar_una_vez(ruta: String = RUTA) -> void:
	if not _cargados:
		cargar(ruta)


static func cargar(ruta: String = RUTA) -> void:
	_cargados = true
	vibracion = POR_OMISION["vibracion"]
	temblor = POR_OMISION["temblor"]
	modo_desarrollador = POR_OMISION["modo_desarrollador"]
	volumen = VOLUMEN_POR_OMISION
	recursos = Recursos.AUTO
	disposicion = DisposicionControles.por_omision()
	Mando.por_omision()
	_leer(ruta)
	aplicar_volumen()


static func _leer(ruta: String) -> void:
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
	valor = ajustes.get("modo_desarrollador")
	if typeof(valor) == TYPE_BOOL:
		modo_desarrollador = valor
	valor = ajustes.get("volumen")
	if typeof(valor) == TYPE_FLOAT:
		var leido: float = valor
		volumen = clampf(leido, 0.0, 1.0)
	valor = ajustes.get("recursos")
	if typeof(valor) == TYPE_STRING and Recursos.MODOS.has(valor as String):
		recursos = valor
	disposicion = DisposicionControles.desde_diccionario(ajustes.get("controles"))
	Mando.aplicar(ajustes.get("mando"))


## Pone el volumen en el bus Master; en 0, silencio.
static func aplicar_volumen() -> void:
	AudioServer.set_bus_mute(0, volumen <= 0.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volumen, 0.0001)))


## Escribe a un temporal y lo renombra, como el guardado de la partida.
static func guardar(ruta: String = RUTA) -> Error:
	var temporal: String = ruta + ".tmp"
	var archivo: FileAccess = FileAccess.open(temporal, FileAccess.WRITE)
	if archivo == null:
		return FileAccess.get_open_error()
	archivo.store_string(JSON.stringify({"version": VERSION, "ajustes": {"vibracion": vibracion, "temblor": temblor, "modo_desarrollador": modo_desarrollador, "volumen": volumen, "recursos": recursos, "controles": disposicion.a_diccionario(), "mando": Mando.a_diccionario()}}, "\t"))
	var error: Error = archivo.get_error()
	archivo.close()
	if error != OK:
		return error
	return DirAccess.rename_absolute(temporal, ruta)
