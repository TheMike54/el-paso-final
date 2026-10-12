extends Node
# Genera mapa/indice_salas.tres a partir de las salas (contenido/salas y las zonas de prueba): el paquete exportado no
# deja listar escenas con fiabilidad, asi que el mapa lee este indice. Se corre tras agregar o mover una sala:
# & $env:GODOT_PATH --headless --path . --quit-after 600 res://herramientas/generar_mapa.tscn


func _ready() -> void:
	var indice: IndiceSalas = IndiceSalas.construir()
	var error: Error = ResourceSaver.save(indice, IndiceSalas.RUTA)
	print("MAPA salas=%d error=%d" % [indice.rectangulos.size(), error])
	get_tree().quit(0 if error == OK else 1)
