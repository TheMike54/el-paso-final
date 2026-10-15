class_name Archivo
extends RefCounted
# Escritura atomica de archivos de user://: se escribe o copia a "<destino>.tmp" y despues se renombra, asi un
# cierre a la mitad nunca deja el destino cortado. La usan el guardado de la partida (y su copia para Restaurar) y
# los ajustes, para que un arreglo a esta regla llegue a todos a la vez.


## Escribe texto en ruta pasando por ruta.tmp. Devuelve el error de abrir, escribir o renombrar.
static func escribir_atomico(ruta: String, texto: String) -> Error:
	var temporal: String = ruta + ".tmp"
	var archivo: FileAccess = FileAccess.open(temporal, FileAccess.WRITE)
	if archivo == null:
		return FileAccess.get_open_error()
	archivo.store_string(texto)
	var error: Error = archivo.get_error()
	archivo.close()
	if error != OK:
		return error
	return DirAccess.rename_absolute(temporal, ruta)


## Copia desde a hacia pasando por hacia.tmp: una copia cortada a la mitad no queda como copia.
static func copiar_atomico(desde: String, hacia: String) -> Error:
	var temporal: String = hacia + ".tmp"
	var error: Error = DirAccess.copy_absolute(desde, temporal)
	if error != OK:
		return error
	return DirAccess.rename_absolute(temporal, hacia)
