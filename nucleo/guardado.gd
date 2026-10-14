class_name Guardado
extends RefCounted
# Guarda y carga la partida como JSON con numero de version. Escribe con Archivo (a un temporal que
# despues renombra), para que un cierre a la mitad nunca deje la partida danada. Al cargar
# distingue partida valida, sin partida, archivo danado y version incompatible. Hay 4 ranuras de partida, cada una
# con su copia de la ultima sesion para Restaurar.

enum Estado {
	VALIDA,
	VACIA,
	DANADA,
	INCOMPATIBLE,
}

const VERSION: int = 3
## Partida de antes de las ranuras: se pasa una vez a la ranura 1 (migrar). Banco la usa como centinela.
const RUTA: String = "user://partida.json"
const RANURAS: int = 4
## Ruta de cada ranura, con su numero (1 a RANURAS).
const FORMATO_RANURA: String = "user://partida_%d.json"
## Lo que se agrega a la ruta de una partida para su copia.
const RESPALDO: String = ".bak"
## Campos que toda partida de esta version debe tener, con su tipo despues de leer el JSON
## (los numeros vuelven siempre como float). Lo de cada campo, en docs/contrato.md («Guardado»).
const ESQUEMA: Dictionary[String, int] = {
	"banco": TYPE_DICTIONARY,
	"vidas_maximas": TYPE_FLOAT,
	"habilidades": TYPE_ARRAY,
	"jefes": TYPE_ARRAY,
	"amuletos_tenidos": TYPE_ARRAY,
	"amuletos_equipados": TYPE_ARRAY,
	"monedas": TYPE_FLOAT,
	"mochila": TYPE_DICTIONARY,
	"mapas": TYPE_ARRAY,
	"salas_visitadas": TYPE_ARRAY,
	"salas_mapeadas": TYPE_ARRAY,
	"salas": TYPE_DICTIONARY,
	"personaje": TYPE_STRING,
	"nombre": TYPE_STRING,
	"tiempo_jugado": TYPE_FLOAT,
}


## Lo que devuelve cargar(): el estado y, solo si es VALIDA, la partida.
class Resultado:
	var estado: Estado
	var partida: Dictionary

	func _init(estado_leido: Estado, partida_leida: Dictionary = {}) -> void:
		estado = estado_leido
		partida = partida_leida


static func guardar(partida: Dictionary, ruta: String = RUTA) -> Error:
	return Archivo.escribir_atomico(ruta, JSON.stringify({"version": VERSION, "partida": partida}, "\t"))


static func ruta_ranura(numero: int) -> String:
	return FORMATO_RANURA % numero


## Borra la partida, su temporal y su copia; sin archivo no es error.
static func borrar(ruta: String = RUTA) -> Error:
	for archivo: String in [ruta, ruta + ".tmp", ruta + RESPALDO, ruta + RESPALDO + ".tmp"]:
		if FileAccess.file_exists(archivo):
			var error: Error = DirAccess.remove_absolute(archivo)
			if error != OK:
				return error
	return OK


## Pasa la partida de antes de las ranuras a una ranura, una sola vez: sin archivo viejo o con la ranura ya ocupada
## no hace nada (nunca pisa una partida).
static func migrar(desde: String, hacia: String) -> Error:
	if not FileAccess.file_exists(desde) or FileAccess.file_exists(hacia):
		return OK
	return DirAccess.rename_absolute(desde, hacia)


## Copia una partida valida al empezar una sesion, para Restaurar. Una danada o de otra version no se copia: asi la
## copia buena de antes sigue sirviendo.
static func respaldar(ruta: String) -> Error:
	if cargar(ruta).estado != Estado.VALIDA:
		return ERR_INVALID_DATA
	return Archivo.copiar_atomico(ruta, ruta + RESPALDO)


## Si hay una copia valida a la que volver.
static func tiene_respaldo(ruta: String) -> bool:
	return cargar(ruta + RESPALDO).estado == Estado.VALIDA


## Vuelve la partida a su copia, solo si la copia es valida. Atomica, como guardar: un cierre a la mitad no la dana.
static func restaurar(ruta: String) -> Error:
	if not tiene_respaldo(ruta):
		return ERR_FILE_NOT_FOUND
	return Archivo.copiar_atomico(ruta + RESPALDO, ruta)


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
	# El banco va vacio (sin descansar) o con su sala y su id.
	var banco: Dictionary = partida["banco"]
	if not banco.is_empty() and (typeof(banco.get("sala")) != TYPE_STRING or typeof(banco.get("id")) != TYPE_STRING):
		return Resultado.new(Estado.DANADA)
	return Resultado.new(Estado.VALIDA, partida)
