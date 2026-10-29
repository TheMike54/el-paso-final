extends Node
# Autoload de arranque del nucleo. Carga los ajustes, crea los efectos (Sonido) y la musica (Musica), que asi no
# mueren al cambiar de escena, y UltimaEntrada (si se usa el dedo o un control) y, solo si el build es de depuracion y el
# archivo viajo en el paquete, el puerto de depuracion: la zona de pruebas viaja tambien en
# publicacion (con el modo desarrollador), pero el puerto no (exclude_filter de «Publicacion») y nunca corre ahi.
const RUTA_PUERTO: String = "res://herramientas/puerto_depuracion.gd"

## Rango de proporciones de la vista (ver nucleo/vista.gd): de 4:3 a 22:9, el mismo en escritorio,
## telefono y tableta. Fuera de el, la vista se recorta y el motor pone barras negras.
@export var proporcion_minima: float = 4.0 / 3.0
@export var proporcion_maxima: float = 22.0 / 9.0

## Los servicios hermanos que crea en _ready, con su tipo: se llaman como Arranque.musica.poner(...), sin ruta de nodo
## ni comprobar null (un autoload esta siempre cargado, tutorials/scripting/singletons_autoload.rst:30).
var sonido: Sonido = null
var musica: Musica = null


func _ready() -> void:
	# Lo que queda fuera de una sala (y la sala sin Fondo) se ve negro, como las barras, no gris.
	RenderingServer.set_default_clear_color(Color.BLACK)
	# El juego es solo 2D: la vista raiz no prepara nada de 3D (rendering/viewports.rst, «Disable 3D»).
	get_viewport().disable_3d = true
	Ajustes.cargar_una_vez()
	# Sin pantalla (guiones y validador) la vista se queda como esta: los guiones dependen de ella.
	if not Ajustes.sin_ventana():
		get_window().size_changed.connect(_al_cambiar_tamano)
		_ajustar_vista()
	# Lo ultimo que se uso (dedo o control) decide si un menu dibuja su foco (Tema.dar_foco).
	var ultima: UltimaEntrada = UltimaEntrada.new()
	ultima.name = "UltimaEntrada"
	add_child(ultima)
	# Tambien sin pantalla: los guiones leen sus cuentas; ahi no toca nada.
	sonido = Sonido.new()
	sonido.name = "Sonido"
	add_child(sonido)
	# La musica de fondo, igual fuera de las salas: sigue sonando al cruzar una puerta o al pasar del menu a una sala.
	musica = Musica.new()
	musica.name = "Musica"
	add_child(musica)
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
