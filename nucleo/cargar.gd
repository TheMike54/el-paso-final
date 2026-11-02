class_name Cargar
extends RefCounted
# Centraliza la carga opcional para que el nucleo funcione sin interfaz/, mapa/, contenido/ ni herramientas/.
# Nombra los recursos por ruta y los carga solo si existen, sin preload que los vuelva dependencias obligatorias.
# Devuelve null ante una ruta vacia o ausente; quien llama convierte el recurso a su tipo.


## El recurso de la ruta, o null si no existe. Quien lo llama lo convierte con `as` a su tipo.
static func si_existe(ruta: String) -> Resource:
	if ruta.is_empty() or not ResourceLoader.exists(ruta):
		return null
	return load(ruta)
