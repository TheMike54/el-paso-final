class_name Recursos
extends RefCounted
# Modo de recursos: bajo para telefonos debiles (sin decoracion prescindible, plantas y niebla quietas), alto
# con todo dentro del presupuesto. El ajuste "recursos" vale auto, bajo o alto; en auto decide la deteccion: un
# build de 32 bits, menos de UMBRAL_MEMORIA de memoria o un telefono que Android marca de poca memoria es debil.
# Estatico: lo consultan las piezas decorativas al entrar a la sala, asi un cambio en Configuracion vale desde la
# sala siguiente. En Android OS.get_memory_info() da -1: la memoria se lee de /proc/meminfo (medido el 25-oct-2026).

const AUTO: String = "auto"
const BAJO: String = "bajo"
const ALTO: String = "alto"
const MODOS: PackedStringArray = [AUTO, BAJO, ALTO]
## Memoria fisica por debajo de la cual el telefono cuenta como debil (el S50 tiene 1,9 GB; el S20, 8 GB).
const UMBRAL_MEMORIA: int = 3 * 1024 * 1024 * 1024

static var _debil_calculado: bool = false
static var _debil: bool = false
static var _memoria_leida: int = -1
static var _poca_memoria: bool = false


## Regla de la deteccion, aparte para probarla: 32 bits, poca memoria (0: desconocida, no cuenta) o un telefono que
## Android marca de poca memoria (ActivityManager.isLowRamDevice).
static func debil_segun(es_de_32_bits: bool, memoria: int, poca_memoria: bool = false) -> bool:
	return es_de_32_bits or poca_memoria or (memoria > 0 and memoria < UMBRAL_MEMORIA)


## Memoria total en bytes de un texto de /proc/meminfo («MemTotal:  1978704 kB»); 0 si no la trae.
static func memoria_de_meminfo(texto: String) -> int:
	for linea: String in texto.split("\n"):
		if linea.begins_with("MemTotal:"):
			var partes: PackedStringArray = linea.trim_prefix("MemTotal:").strip_edges().split(" ", false)
			if not partes.is_empty() and partes[0].is_valid_int():
				return partes[0].to_int() * 1024
	return 0


## Regla del aviso de la Configuracion: alto en un telefono debil se permite, con aviso.
static func avisar(modo: String, debil: bool) -> bool:
	return modo == ALTO and debil


## Si este telefono cuenta como debil. Se calcula una vez: la memoria fisica no cambia, y cada adorno lo
## consulta al entrar a la sala.
static func es_debil() -> bool:
	if not _debil_calculado:
		_debil = debil_segun(OS.has_feature("32"), _memoria(), _es_de_poca_memoria())
		_debil_calculado = true
	return _debil


static func _memoria() -> int:
	if _memoria_leida >= 0:
		return _memoria_leida
	var memoria: Variant = OS.get_memory_info().get("physical", 0)
	_memoria_leida = maxi(memoria as int, 0) if typeof(memoria) == TYPE_INT else 0
	if _memoria_leida == 0 and OS.get_name() == "Android":
		# FileAccess no puede abrir /proc/meminfo en Android (error 1); cat si (OS.execute, sin root).
		var salida: Array = []
		if OS.execute("cat", ["/proc/meminfo"], salida) == 0 and not salida.is_empty():
			_memoria_leida = memoria_de_meminfo(salida[0] as String)
	return _memoria_leida


# ActivityManager.isLowRamDevice() por el plugin AndroidRuntime, que da el contexto de la app como objeto de Java
# (tutorials/platform/android/javaclasswrapper_and_androidruntimeplugin.rst): verdadero en el S50, falso en el S21.
static func _es_de_poca_memoria() -> bool:
	if OS.get_name() != "Android" or not Engine.has_singleton("AndroidRuntime"):
		return false
	# Cada llamada se revisa: get_exception solo guarda la de la ultima (classes/class_javaclasswrapper.rst:36).
	var runtime: Object = Engine.get_singleton("AndroidRuntime")
	var contexto: Object = runtime.call(&"getApplicationContext") as Object
	if contexto == null or JavaClassWrapper.get_exception() != null:
		return false
	var gestor: Object = contexto.call(&"getSystemService", "activity") as Object
	if gestor == null or JavaClassWrapper.get_exception() != null:
		return false
	var poca: bool = gestor.call(&"isLowRamDevice") as bool
	if JavaClassWrapper.get_exception() != null:
		return false
	_poca_memoria = poca
	return _poca_memoria


## Por que la deteccion dice lo que dice, para la Configuracion.
static func motivo() -> String:
	if OS.has_feature("32"):
		return "32 bits"
	es_debil()
	if _poca_memoria:
		return "Android lo marca de poca memoria"
	var memoria: int = _memoria()
	if memoria > 0:
		return "%.1f GB de memoria" % (float(memoria) / float(1024 * 1024 * 1024))
	return "memoria desconocida"


## Modo en vigor: el del ajuste o, en auto, el de la deteccion.
static func bajos() -> bool:
	match Ajustes.recursos:
		BAJO:
			return true
		ALTO:
			return false
		_:
			return es_debil()
