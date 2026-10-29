extends Node
# Pone o corrige el uid de cada ext_resource de las escenas y recursos que se escribieron a mano (con_uids de validar.gd),
# y el de la cabecera si falta. Sin esto, un .tscn o .tres escrito como texto cita sus destinos sin uid o con otro.
# Se corre con herramientas/arreglar-uids.ps1, que importa antes para que los destinos nuevos ya tengan su uid:
# & $env:GODOT_PATH --headless --path . --quit-after 600 res://herramientas/arreglar_uids.tscn -- --rutas=res://a.tscn,res://b.tres


func _ready() -> void:
	var rutas: PackedStringArray = []
	for argumento: String in OS.get_cmdline_user_args():
		if argumento.begins_with("--rutas="):
			rutas = argumento.trim_prefix("--rutas=").split(",", false)
	var cambiados: int = 0
	var errores: int = 0
	for ruta: String in rutas:
		var extension: String = ruta.get_extension()
		if not ruta.begins_with("res://") or (extension != "tscn" and extension != "tres") or not FileAccess.file_exists(ruta):
			print("UIDS no es una escena o recurso que exista: %s" % ruta)
			errores += 1
			continue
		var lineas: PackedStringArray = FileAccess.get_file_as_string(ruta).split("\n")
		if not lineas[0].contains(" uid=\""):
			lineas[0] = lineas[0].trim_suffix("]") + " uid=\"%s\"]" % ResourceUID.id_to_text(ResourceUID.create_id())
		var viejo: String = FileAccess.get_file_as_string(ruta)
		var nuevo: String = preload("res://herramientas/validar.gd").con_uids("\n".join(lineas))
		if nuevo == viejo:
			continue
		var archivo: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
		if archivo == null:
			print("UIDS no se pudo escribir %s (error %d)" % [ruta, FileAccess.get_open_error()])
			errores += 1
			continue
		archivo.store_string(nuevo)
		archivo.close()
		cambiados += 1
	print("UIDS rutas=%d cambiados=%d errores=%d" % [rutas.size(), cambiados, errores])
	get_tree().quit(0 if errores == 0 else 1)
