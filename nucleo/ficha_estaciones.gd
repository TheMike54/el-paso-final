class_name FichaEstaciones
extends Resource
# Tabla de las estaciones del viaje rapido, como FastTravelScenes de Silksong: id, nombre y sala de cada una, en el
# orden en que salen en el menu de destinos. Hay una del juego (contenido/estaciones.tres) y una de la zona de pruebas
# (herramientas/salas/zonas/estaciones_prueba.tres); cada estacion usa la de la carpeta de su sala, asi el menu del
# juego nunca muestra las de prueba.

@export var estaciones: Array[DatoEstacion] = []


## La fila con ese id; null si no esta.
func buscar(id: String) -> DatoEstacion:
	for dato: DatoEstacion in estaciones:
		if dato != null and dato.id == id:
			return dato
	return null


## Fallos de forma de la tabla (vacio si esta bien); lo usan el validador y la prueba.
func fallos() -> PackedStringArray:
	var lista: PackedStringArray = []
	var vistos: Dictionary = {}
	for dato: DatoEstacion in estaciones:
		if dato == null:
			lista.append("una fila vacia")
			continue
		if dato.id.is_empty() or vistos.has(dato.id):
			lista.append("estacion '%s' sin id o con id repetido" % dato.id)
		vistos[dato.id] = true
		if dato.sala.is_empty() or dato.id != Estacion.PREFIJO + dato.sala:
			lista.append("la estacion '%s' debe llamarse %s<sala> con su sala '%s'" % [dato.id, Estacion.PREFIJO, dato.sala])
		if dato.nombre.is_empty():
			lista.append("la estacion '%s' no tiene nombre" % dato.id)
	return lista
