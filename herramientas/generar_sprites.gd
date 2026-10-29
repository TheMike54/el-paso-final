extends Node
# Genera nucleo/arte/jugador_hombre/jugador_hombre.tres (SpriteFrames del cuerpo del jugador) desde el JSON que deja el
# script que arma el atlas, fuera del repo: por cuadro, su region en la pagina, su margin.position en el lienzo comun
# y su duracion. Con ResourceSaver, para que Godot escriba el formato, mas el uid de la cabecera y el del atlas, que ese
# guardado no escribe fuera del editor (guardar_con_uids de validar.gd). Se corre tras reimportar el atlas:
# & $env:GODOT_PATH --headless --path . --quit-after 600 res://herramientas/generar_sprites.tscn -- --atlas=<json>
# Los metadatos del .tres anterior (META_CONSERVADOS) pasan al nuevo: son datos del personaje que el atlas no trae.

const CARPETA: String = "res://nucleo/arte/jugador_hombre/"
const DESTINO: String = CARPETA + "jugador_hombre.tres"
## Metadatos del SpriteFrames que no salen del atlas y se copian del .tres anterior. pasos: por animacion, los cuadros
## en que un pie toca el suelo (Jugador emite jugador_paso al entrar a uno).
const META_CONSERVADOS: Array[StringName] = [&"pasos"]
const BUCLES: Dictionary[String, SpriteFrames.LoopMode] = {
	"no": SpriteFrames.LOOP_NONE,
	"lineal": SpriteFrames.LOOP_LINEAR,
	"vaiven": SpriteFrames.LOOP_PINGPONG,
}


func _ready() -> void:
	var ruta: String = ""
	for argumento: String in OS.get_cmdline_user_args():
		if argumento.begins_with("--atlas="):
			ruta = argumento.trim_prefix("--atlas=")
	var texto: String = FileAccess.get_file_as_string(ruta) if not ruta.is_empty() else ""
	var json: JSON = JSON.new()
	if texto.is_empty() or json.parse(texto) != OK or not (json.data is Dictionary):
		print("SPRITES FALLO: falta --atlas=<json> o no se pudo leer '%s'" % ruta)
		get_tree().quit(1)
		return
	var datos: Dictionary = json.data as Dictionary
	var lienzo_lista: Array = datos["lienzo"] as Array
	var lienzo: Vector2 = Vector2(lienzo_lista[0] as float, lienzo_lista[1] as float)
	var paginas: Array[Texture2D] = []
	for nombre: Variant in datos["paginas"] as Array:
		var pagina: Texture2D = load(CARPETA + str(nombre)) as Texture2D
		if pagina == null:
			print("SPRITES FALLO: no se pudo cargar la pagina %s (importar antes)" % nombre)
			get_tree().quit(1)
			return
		paginas.append(pagina)
	var cuadros: SpriteFrames = SpriteFrames.new()
	cuadros.remove_animation(&"default")
	var total: int = 0
	for animacion: Variant in datos["animaciones"] as Array:
		var a: Dictionary = animacion as Dictionary
		var nombre: StringName = StringName(str(a["nombre"]))
		cuadros.add_animation(nombre)
		cuadros.set_animation_speed(nombre, a["fps"] as float)
		cuadros.set_animation_loop_mode(nombre, BUCLES[str(a["bucle"])])
		for c: Variant in a["cuadros"] as Array:
			var d: Dictionary = c as Dictionary
			var region: Array = d["region"] as Array
			var margen: Array = d["margen"] as Array
			var trozo: AtlasTexture = AtlasTexture.new()
			trozo.atlas = paginas[d["pagina"] as int]
			trozo.region = Rect2(region[0] as float, region[1] as float, region[2] as float, region[3] as float)
			# margin.size completa el lienzo: todos los cuadros miden lo mismo y el AnimatedSprite2D no salta.
			trozo.margin = Rect2(margen[0] as float, margen[1] as float, lienzo.x - (region[2] as float),
					lienzo.y - (region[3] as float))
			trozo.filter_clip = true
			cuadros.add_frame(nombre, trozo, d["duracion"] as float)
			total += 1
	var anterior: SpriteFrames = load(DESTINO) as SpriteFrames if ResourceLoader.exists(DESTINO) else null
	if anterior != null:
		for meta: StringName in META_CONSERVADOS:
			if anterior.has_meta(meta):
				cuadros.set_meta(meta, anterior.get_meta(meta))
	var error: Error = preload("res://herramientas/validar.gd").guardar_con_uids(cuadros, DESTINO)
	print("SPRITES animaciones=%d cuadros=%d lienzo=%dx%d error=%d" % [cuadros.get_animation_names().size(), total,
			int(lienzo.x), int(lienzo.y), error])
	get_tree().quit(0 if error == OK else 1)
