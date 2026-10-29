extends SceneTree
# Genera nucleo/arte/trazo_ataque.png, la media luna blanca del trazo del ataque (TrazoAtaque), con la cuenta del
# mockup de La Celda: un disco de radio 112 en 256 px con un halo suave (el shadowBlur 14 del mockup), menos otro
# disco de radio 112 corrido 36 px a la izquierda. Se corre una vez y despues se reimporta:
# & $env:GODOT_PATH --headless --path . --script res://herramientas/generar_trazo.gd

const LADO: int = 256
const RADIO: float = 112.0
const CORRIMIENTO: float = 36.0
## Ancho del halo: el desvanecido gaussiano fuera del disco.
const HALO: float = 7.0
const RUTA: String = "res://nucleo/arte/trazo_ataque.png"


func _initialize() -> void:
	var imagen: Image = Image.create(LADO, LADO, false, Image.FORMAT_RGBA8)
	var centro: Vector2 = Vector2(LADO / 2.0, LADO / 2.0)
	var hueco: Vector2 = centro - Vector2(CORRIMIENTO, 0.0)
	for y: int in range(LADO):
		for x: int in range(LADO):
			var punto: Vector2 = Vector2(x + 0.5, y + 0.5)
			var d1: float = punto.distance_to(centro)
			var d2: float = punto.distance_to(hueco)
			var a: float = 1.0 if d1 <= RADIO else exp(-pow((d1 - RADIO) / HALO, 2.0))
			a *= clampf(d2 - RADIO + 0.5, 0.0, 1.0)
			imagen.set_pixel(x, y, Color(1.0, 1.0, 1.0, a))
	var error: Error = imagen.save_png(RUTA)
	print("TRAZO %s error=%d" % [RUTA, error])
	quit()
