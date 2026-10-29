class_name Cargar
extends RefCounted
# Carga un recurso que puede no existir: el nucleo no depende de interfaz/, mapa/, contenido/ ni herramientas/, asi
# que los nombra por ruta y los carga solo si estan (nunca con preload). Un solo lugar para esa comprobacion.


## El recurso de la ruta, o null si no existe. Quien lo llama lo convierte con `as` a su tipo.
static func si_existe(ruta: String) -> Resource:
	if ruta.is_empty() or not ResourceLoader.exists(ruta):
		return null
	return load(ruta)
