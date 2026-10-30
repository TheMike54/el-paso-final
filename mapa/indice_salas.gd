class_name IndiceSalas
extends Resource
# Indice de las salas para el mapa: id -> rectangulo en el mundo (origen de zona, posicion_mapa y limites),
# ruta y dibujo opcional (<id>_mapa.png junto a la sala); por zona con ficha, nombre y color. Lo escribe
# herramientas/generar_mapa.tscn y el validador falla si no coincide con las salas: el paquete exportado no deja
# listar escenas con fiabilidad. No se edita a mano.

const RUTA: String = "res://mapa/indice_salas.tres"

## Rectangulo de cada sala en el mapa del mundo, por id.
@export var rectangulos: Dictionary[String, Rect2] = {}
## Escena de cada sala, por id.
@export var rutas: Dictionary[String, String] = {}
## Dibujo del mapa de cada sala, por id; puede faltar.
@export var dibujos: Dictionary[String, String] = {}
## Nombre visible de cada zona con ficha.
@export var nombres_zona: Dictionary[String, String] = {}
## Color de relleno de cada zona con ficha.
@export var colores_zona: Dictionary[String, Color] = {}


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


## Incorpora una sala con id, sumando el origen comun de su zona a su posicion local.
func agregar_sala(sala: Sala, ruta: String) -> void:
	var origen: Vector2 = sala.ficha_zona.origen_mapa if sala.ficha_zona != null else Vector2.ZERO
	rectangulos[sala.id] = Rect2(origen + sala.posicion_mapa + sala.limites.position, sala.limites.size)
	rutas[sala.id] = ruta
	if sala.ficha_zona != null:
		var zona: String = Sala.zona_de(sala.id)
		nombres_zona[zona] = sala.ficha_zona.nombre
		colores_zona[zona] = sala.ficha_zona.color


## Borde inferior mas bajo del mapa; sin salas, la primera franja empieza en 0.
func franja_libre() -> float:
	var borde: float = 0.0
	var primero: bool = true
	for rectangulo: Rect2 in rectangulos.values():
		borde = rectangulo.end.y if primero else maxf(borde, rectangulo.end.y)
		primero = false
	return borde


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
			indice.agregar_sala(sala, ruta)
			var dibujo: String = carpeta.path_join(sala.id + "_mapa.png")
			if ResourceLoader.exists(dibujo):
				indice.dibujos[sala.id] = dibujo
		nodo.free()


## Si dos indices dicen lo mismo (el guardado y el que sale de las salas).
static func iguales(a: IndiceSalas, b: IndiceSalas) -> bool:
	return (a.rectangulos == b.rectangulos and a.rutas == b.rutas and a.dibujos == b.dibujos
		and a.nombres_zona == b.nombres_zona and a.colores_zona == b.colores_zona)
