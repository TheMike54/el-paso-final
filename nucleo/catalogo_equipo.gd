class_name CatalogoEquipo
extends Resource
# La lista oficial de amuletos y utiles: la del juego en contenido/ y la de la zona de pruebas en herramientas/. El
# nucleo las carga por ruta solo si existen (Cargar.si_existe) y busca por id; un id que no esta aqui no se puede
# poner y el validador lo rechaza en la tienda, los NPC y los retos. De solo lectura al correr.

const RUTA_JUEGO: String = "res://contenido/equipo.tres"
const RUTA_PRUEBAS: String = "res://herramientas/salas/fichas/equipo_prueba.tres"

@export var amuletos: Array[FichaAmuleto] = []
@export var utiles: Array[FichaUtil] = []


## La ficha del amuleto con ese id, o null si no esta en ningun catalogo. Busca primero en el del juego. Sin cache
## propia: load() devuelve la copia que ya tiene el motor (tutorials/scripting/resources.rst:30) y las listas son
## cortas; una estatica que guardara las fichas no se libera al salir. El catalogo se lee como Resource y no como
## CatalogoEquipo: que este script se nombre a si mismo deja al salir un ciclo de referencias que no se libera
## (docs/errores/2026-10-29-fuga-catalogo-equipo.md).
static func amuleto(id: StringName) -> FichaAmuleto:
	for ruta: String in [RUTA_JUEGO, RUTA_PRUEBAS]:
		var recurso: Resource = Cargar.si_existe(ruta)
		# Un archivo en esa ruta que no sea un catalogo no tiene la lista: se salta.
		var lista: Variant = recurso.get(&"amuletos") if recurso != null else null
		if not lista is Array:
			continue
		for ficha: FichaAmuleto in lista as Array:
			if ficha != null and ficha.id == id:
				return ficha
	return null


## La ficha del util con ese id, o null si no esta en ningun catalogo. Busca primero en el del juego.
static func util(id: StringName) -> FichaUtil:
	for ruta: String in [RUTA_JUEGO, RUTA_PRUEBAS]:
		var recurso: Resource = Cargar.si_existe(ruta)
		var lista: Variant = recurso.get(&"utiles") if recurso != null else null
		if not lista is Array:
			continue
		for ficha: FichaUtil in lista as Array:
			if ficha != null and ficha.id == id:
				return ficha
	return null