class_name Archivo
extends RefCounted
# Escritura atomica de archivos de user://: se escribe o copia a "<destino>.tmp" y despues se renombra, asi un
# cierre a la mitad nunca deja el destino cortado. La usan el guardado de la partida (y su copia para Restaurar) y
# los ajustes, para que un arreglo a esta regla llegue a todos a la vez.


## Escribe texto en ruta pasando por ruta.tmp. Devuelve el error de abrir, escribir o renombrar. El temporal se relee
## antes de renombrar: lo que cabe en el bufer llega al disco en close(), que no informa si falla, y con el disco
## lleno store_string y get_error dan bien sobre un temporal vacio que dejaria la partida en 0 bytes.
static func escribir_atomico(ruta: String, texto: String) -> Error:
	var temporal: String = ruta + ".tmp"
	var archivo: FileAccess = FileAccess.open(temporal, FileAccess.WRITE)
	if archivo == null:
		return FileAccess.get_open_error()
	var escrito: bool = archivo.store_string(texto)
	archivo.close()
	if not escrito or FileAccess.get_file_as_string(temporal) != texto:
		DirAccess.remove_absolute(temporal)
		return ERR_FILE_CANT_WRITE
	return DirAccess.rename_absolute(temporal, ruta)


## Copia desde a hacia pasando por hacia.tmp: una copia cortada a la mitad no queda como copia.
static func copiar_atomico(desde: String, hacia: String) -> Error:
	var temporal: String = hacia + ".tmp"
	var error: Error = DirAccess.copy_absolute(desde, temporal)
	if error != OK:
		return error
	if FileAccess.get_file_as_bytes(temporal) != FileAccess.get_file_as_bytes(desde):
		DirAccess.remove_absolute(temporal)
		return ERR_FILE_CANT_WRITE
	return DirAccess.rename_absolute(temporal, hacia)
