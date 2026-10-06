extends Node
# Autoload de arranque del nucleo. Carga las herramientas de desarrollo solo si el build es
# de depuracion y el archivo viajo en el paquete: el preset de publicacion excluye
# herramientas/, asi que el juego publicado arranca sin el puerto de depuracion.
const RUTA_PUERTO: String = "res://herramientas/puerto_depuracion.gd"


func _ready() -> void:
	var depuracion: bool = OS.is_debug_build()
	var existe: bool = ResourceLoader.exists(RUTA_PUERTO)
	print("ARRANQUE depuracion=%s puerto=%s" % [depuracion, existe])
	if depuracion and existe:
		var guion: GDScript = load(RUTA_PUERTO) as GDScript
		var puerto: Node = guion.new() as Node
		puerto.name = "PuertoDepuracion"
		add_child(puerto)
