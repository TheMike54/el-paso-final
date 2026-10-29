class_name IndiceSalas
extends Resource
# Indice de las salas para el mapa: id de cada sala con id -> su rectangulo en el mundo (posicion_mapa mas sus
# limites), la ruta de su escena y, si existe, su dibujo (<id>_mapa.png junto a la sala). Lo escribe
# herramientas/generar_mapa.tscn y el validador falla si no coincide con las salas: el paquete exportado no deja
# listar escenas con fiabilidad. No se edita a mano.

const RUTA: String = "res://mapa/indice_salas.tres"

## Rectangulo de cada sala en el mapa del mundo, por id.
@export var rectangulos: Dictionary[String, Rect2] = {}
## Escena de cada sala, por id.
@export var rutas: Dictionary[String, String] = {}
## Dibujo del mapa de cada sala, por id; puede faltar.
@export var dibujos: Dictionary[String, String] = {}


## El indice del juego, o uno vacio si todavia no existe.
static func cargar() -> IndiceSalas:
	var indice: IndiceSalas = Cargar.si_existe(RUTA) as IndiceSalas
	return indice if indice != null else IndiceSalas.new()


## Recorre las carpetas de salas (las del juego y las zonas de prueba, si existen) y arma el indice.
static func construir() -> IndiceSalas:
	var indice: IndiceSalas = IndiceSalas.new()
	for carpeta: String in [Sala.CARPETA_CONTENIDO, Sala.CARPETA_PRUEBAS]:
		_recorrer(carpeta, indice)
	return indice


static func _recorrer(carpeta: String, indice: IndiceSalas) -> void:
	var dir: DirAccess = DirAccess.open(carpeta)
	if dir == null:
		return
	for sub: String in dir.get_directories():
		_recorrer(carpeta.path_join(sub), indice)
	for archivo: String in dir.get_files():
		if archivo.get_extension() != "tscn":
			continue
		var ruta: String = carpeta.path_join(archivo)
		var escena: PackedScene = load(ruta) as PackedScene
		if escena == null:
			continue
		var nodo: Node = escena.instantiate()
		var sala: Sala = nodo as Sala
		if sala != null and not sala.id.is_empty():
			indice.rectangulos[sala.id] = Rect2(sala.posicion_mapa + sala.limites.position, sala.limites.size)
			indice.rutas[sala.id] = ruta
			var dibujo: String = carpeta.path_join(sala.id + "_mapa.png")
			if ResourceLoader.exists(dibujo):
				indice.dibujos[sala.id] = dibujo
		nodo.free()


## Si dos indices dicen lo mismo (el guardado y el que sale de las salas).
static func iguales(a: IndiceSalas, b: IndiceSalas) -> bool:
	return a.rectangulos == b.rectangulos and a.rutas == b.rutas and a.dibujos == b.dibujos
