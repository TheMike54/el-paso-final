class_name Guardado
extends RefCounted
# Guarda y carga la partida como JSON con numero de version. Escribe con Archivo (a un temporal que
# despues renombra), para que un cierre a la mitad nunca deje la partida danada. Al cargar
# distingue partida valida, sin partida, archivo danado, version incompatible y archivo que no se pudo abrir. Hay 4
# ranuras de partida, cada una con su copia para Restaurar.

enum Estado {
	VALIDA,
	VACIA,
	DANADA,
	INCOMPATIBLE,
	ILEGIBLE,
}

## 4: la brujula paso de amuletos a utiles. Las partidas viejas no se conservan todavia: una de otra
## version se da por incompatible, sin conversion.
const VERSION: int = 4
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
## Campos numericos con su minimo: un valor menor no sale del juego, asi que la partida esta danada.
const MINIMOS: Dictionary[String, float] = {
	"vidas_maximas": 1.0,
	"monedas": 0.0,
	"tiempo_jugado": 0.0,
}
## Campos agregados despues de la version 3, con su valor por omision como queda al leer el JSON (0.0 y no 0, Array
## sin tipo): una partida que no los tiene se rellena al cargar en vez de quedar danada. Cambiar la forma de un campo
## que ya existe no va aqui: sube VERSION (ver VERSION).
const NUEVOS: Dictionary[String, Variant] = {
	# Estaciones del viaje rapido abiertas.
	"estaciones": [],
	# Botones de la pantalla ya ensenados por los pizarrones.
	"botones_ensenados": [],
	# Carga para amuletos y utiles tenidos y puestos.
	"carga_maxima": 3.0,
	# Capacidad de Inspiracion: tres bloques si la partida no trae el campo.
	"inspiracion_maxima": 33.0,
	"utiles_tenidos": [],
	"utiles_equipados": [],
}

# Rutas con un fallo de archivo fingido: leerlas o borrarlas da ese error. Solo lo usa la prueba, porque un archivo que
# existe y no se abre no se puede montar igual en Windows, Linux y Android.
static var _fallos: Dictionary[String, Error] = {}


## Lo que devuelve cargar(): el estado y, solo si es VALIDA, la partida.
class Resultado:
	var estado: Estado
	var partida: Dictionary

	func _init(estado_leido: Estado, partida_leida: Dictionary = {}) -> void:
		estado = estado_leido
		partida = partida_leida

	## Si la ranura no se abre: ni tiene una partida valida ni esta libre.
	func cerrada() -> bool:
		return estado != Estado.VALIDA and estado != Estado.VACIA


static func guardar(partida: Dictionary, ruta: String) -> Error:
	return Archivo.escribir_atomico(ruta, JSON.stringify({"version": VERSION, "partida": partida}, "\t"))


## Un numero leido de una partida como int, o por_omision si no es numero: el JSON devuelve los enteros como float y
## por eso no basta con "as int". Trunca, como int().
static func entero(valor: Variant, por_omision: int) -> int:
	return int(valor as float) if valor is int or valor is float else por_omision


static func ruta_ranura(numero: int) -> String:
	return FORMATO_RANURA % numero


## Borra la partida, su temporal y su copia; sin archivo no es error. La partida va primero: si no se puede borrar,
## su copia sigue ahi. Si la que falla es la copia, devuelve el error aunque la partida ya no este.
static func borrar(ruta: String = RUTA) -> Error:
	for archivo: String in [ruta, ruta + ".tmp", ruta + RESPALDO, ruta + RESPALDO + ".tmp"]:
		if FileAccess.file_exists(archivo):
			var error: Error = _fallos[archivo] if _fallos.has(archivo) else DirAccess.remove_absolute(archivo)
			if error != OK:
				return error
	return OK


## Finge que ruta no se puede leer ni borrar; solo para la prueba. olvidar_fallos lo deshace.
static func fingir_fallo(ruta: String, error: Error) -> void:
	_fallos[ruta] = error


static func olvidar_fallos() -> void:
	_fallos.clear()


## Pasa la partida de antes de las ranuras a una ranura, una sola vez: sin archivo viejo o con la ranura ya ocupada
## no hace nada (nunca pisa una partida).
static func migrar(desde: String, hacia: String) -> Error:
	if not FileAccess.file_exists(desde) or FileAccess.file_exists(hacia):
		return OK
	return DirAccess.rename_absolute(desde, hacia)


## Copia una partida valida al empezar una sesion, para Restaurar. Una danada o de otra version no se copia: asi la
## copia buena de antes sigue sirviendo. Si la copia falla, la anterior se queda: una vieja rescata mas que ninguna.
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
	var texto: String = FileAccess.get_file_as_string(ruta)
	# Existe y no se abre (otro proceso lo tiene, permisos): esta intacto y no se ofrece borrarlo.
	if FileAccess.get_open_error() != OK or _fallos.has(ruta):
		return Resultado.new(Estado.ILEGIBLE)
	# JSON.new().parse no imprime errores, a diferencia de JSON.parse_string.
	var json: JSON = JSON.new()
	if json.parse(texto) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return Resultado.new(Estado.DANADA)
	var sobre: Dictionary = json.data
	var version: Variant = sobre.get("version")
	if typeof(version) != TYPE_FLOAT:
		return Resultado.new(Estado.DANADA)
	var numero: float = version
	# Mas nueva que el juego: no se sabe leer. Mas vieja: tampoco; hasta terminar el juego no hay conversion (ver
	# VERSION).
	if numero != VERSION:
		return Resultado.new(Estado.INCOMPATIBLE)
	var contenido: Variant = sobre.get("partida")
	if typeof(contenido) != TYPE_DICTIONARY:
		return Resultado.new(Estado.DANADA)
	var partida: Dictionary = contenido
	for campo: String in ESQUEMA:
		if not partida.has(campo) or typeof(partida[campo]) != ESQUEMA[campo]:
			return Resultado.new(Estado.DANADA)
	for campo: String in MINIMOS:
		if (partida[campo] as float) < MINIMOS[campo]:
			return Resultado.new(Estado.DANADA)
	if not completar(partida, NUEVOS):
		return Resultado.new(Estado.DANADA)
	var monto: Variant = (partida["mochila"] as Dictionary).get("monto")
	if (monto is int or monto is float) and (monto as float) < 0.0:
		return Resultado.new(Estado.DANADA)
	# El banco va vacio (sin descansar) o con su sala y su id.
	var banco: Dictionary = partida["banco"]
	if not banco.is_empty() and (typeof(banco.get("sala")) != TYPE_STRING or typeof(banco.get("id")) != TYPE_STRING):
		return Resultado.new(Estado.DANADA)
	return Resultado.new(Estado.VALIDA, partida)


## Rellena en la partida los campos de nuevos que le faltan, cada uno con una copia de su valor por omision (el de
## NUEVOS no se comparte). Devuelve false si alguno esta con otro tipo. Recibe nuevos para que la prueba pase los suyos.
static func completar(partida: Dictionary, nuevos: Dictionary[String, Variant]) -> bool:
	for campo: String in nuevos:
		var por_omision: Variant = nuevos[campo]
		if not partida.has(campo):
			if por_omision is Array:
				partida[campo] = (por_omision as Array).duplicate(true)
			elif por_omision is Dictionary:
				partida[campo] = (por_omision as Dictionary).duplicate(true)
			else:
				partida[campo] = por_omision
		elif typeof(partida[campo]) != typeof(por_omision):
			return false
	return true
