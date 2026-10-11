extends Node
# Autoload de arranque del nucleo. Carga las herramientas de desarrollo solo si el build es
# de depuracion y el archivo viajo en el paquete: el preset de publicacion excluye
# herramientas/, asi que el juego publicado arranca sin el puerto de depuracion.
const RUTA_PUERTO: String = "res://herramientas/puerto_depuracion.gd"

## Rango de proporciones de la vista (ver nucleo/vista.gd): de 4:3 a 22:9, el mismo en escritorio,
## telefono y tableta. Fuera de el, la vista se recorta y el motor pone barras negras.
@export var proporcion_minima: float = 4.0 / 3.0
@export var proporcion_maxima: float = 22.0 / 9.0


func _ready() -> void:
	# Lo que queda fuera de una sala (y la sala sin Fondo) se ve negro, como las barras, no gris.
	RenderingServer.set_default_clear_color(Color.BLACK)
	# Sin pantalla (guiones y validador) la vista se queda como esta: los guiones dependen de ella.
	if DisplayServer.get_name() != "headless":
		get_window().size_changed.connect(_al_cambiar_tamano)
		_ajustar_vista()
	var depuracion: bool = OS.is_debug_build()
	var existe: bool = ResourceLoader.exists(RUTA_PUERTO)
	print("ARRANQUE depuracion=%s puerto=%s" % [depuracion, existe])
	if depuracion and existe:
		var guion: GDScript = load(RUTA_PUERTO) as GDScript
		var puerto: Node = guion.new() as Node
		puerto.name = "PuertoDepuracion"
		add_child(puerto)


# Diferido: cambiar content_scale dentro de size_changed dejaba a veces la imagen con la vista anterior
# al pasar a una ventana muy larga o al maximizar desde ella o desde una vertical (medido con una ventana
# real el 07-oct-2026), aunque la ventana dijera que cambio. Al final del cuadro el cambio si se dibuja.
func _al_cambiar_tamano() -> void:
	_ajustar_vista.call_deferred()


# Aplica el rango de la vista a la ventana. Solo asigna si algo cambia: cambiar content_scale_size
# puede volver a disparar size_changed.
func _ajustar_vista() -> void:
	var ventana: Window = get_window()
	var tamano: Vector2 = Vector2(ventana.size)
	var aspecto: Window.ContentScaleAspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	var vista: Vector2i = Vector2i(Vista.BASE)
	if Vista.con_barras(tamano, proporcion_minima, proporcion_maxima):
		aspecto = Window.CONTENT_SCALE_ASPECT_KEEP
		vista = Vector2i(Vista.calcular(tamano, proporcion_minima, proporcion_maxima))
	if ventana.content_scale_aspect != aspecto:
		ventana.content_scale_aspect = aspecto
	if ventana.content_scale_size != vista:
		ventana.content_scale_size = vista
