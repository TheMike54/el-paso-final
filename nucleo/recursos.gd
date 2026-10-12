class_name Recursos
extends RefCounted
# Modo de recursos: bajo para telefonos debiles (sin decoracion prescindible, plantas y niebla quietas), alto
# con todo dentro del presupuesto. El ajuste "recursos" vale auto, bajo o alto; en auto decide la deteccion: un
# build de 32 bits o menos de UMBRAL_MEMORIA de memoria es debil. Estatico: lo consultan las piezas
# decorativas al entrar a la sala, asi un cambio en Configuracion vale desde la sala siguiente.

const AUTO: String = "auto"
const BAJO: String = "bajo"
const ALTO: String = "alto"
const MODOS: PackedStringArray = [AUTO, BAJO, ALTO]
## Memoria fisica por debajo de la cual el telefono cuenta como debil (el S50 tiene 1,9 GB; el S20, 8 GB).
const UMBRAL_MEMORIA: int = 3 * 1024 * 1024 * 1024


## Regla de la deteccion, aparte para probarla: 32 bits o poca memoria (0: desconocida, no cuenta).
static func debil_segun(es_de_32_bits: bool, memoria: int) -> bool:
	return es_de_32_bits or (memoria > 0 and memoria < UMBRAL_MEMORIA)


## Regla del aviso de la Configuracion: alto en un telefono debil se permite, con aviso.
static func avisar(modo: String, debil: bool) -> bool:
	return modo == ALTO and debil


## Si este telefono cuenta como debil.
static func es_debil() -> bool:
	return debil_segun(OS.has_feature("32"), _memoria())


static func _memoria() -> int:
	var memoria: Variant = OS.get_memory_info().get("physical", 0)
	return memoria as int if typeof(memoria) == TYPE_INT else 0


## Por que la deteccion dice lo que dice, para la Configuracion.
static func motivo() -> String:
	if OS.has_feature("32"):
		return "32 bits"
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
