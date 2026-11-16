class_name DetalleMenu
extends MarginContainer
# Panel de detalle a la derecha de las paginas del marco (Amuletos, Utiles, Inventario): nombre, imagen, texto, el motivo
# abajo (por que no se puede poner, o que hay que sentarse) y un boton de accion. Tocar una fila solo elige y llena este
# panel; poner o quitar se hace con su boton, asi un toque nunca cambia el equipo por error. Armado en codigo, como las
# paginas que lo usan; una raya de gis a la izquierda lo separa de la lista.

## Se pulso el boton de accion (Poner o Quitar). Quien llena el panel decide que hace.
signal accion_pulsada

## Ancho del panel, sin la separacion que pone la pagina.
const ANCHO: float = 340.0
## Lado de la imagen cuadrada (icono de amuleto, util o habilidad).
const LADO_IMAGEN: float = 120.0
## Espacio entre la raya de la izquierda y el contenido.
const SANGRIA: float = 24.0

## Publicos para las paginas y sus pruebas.
var nombre: Label = null
var texto: Label = null
var motivo: Label = null
var accion: Button = null

var _imagen: CenterContainer = null


func _init() -> void:
	name = "Detalle"
	custom_minimum_size.x = ANCHO
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override(&"margin_left", int(SANGRIA))
	var columna: VBoxContainer = VBoxContainer.new()
	columna.name = "Columna"
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	add_child(columna)
	nombre = _etiqueta("Nombre", Tema.NOMBRE_DETALLE)
	columna.add_child(nombre)
	_imagen = CenterContainer.new()
	_imagen.name = "Imagen"
	_imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(_imagen)
	# El texto ocupa lo que sobra y se desplaza si no cabe: en un telefono 2:1 (1440x720) un texto largo con el motivo
	# empujaba el boton fuera de la pantalla. Asi el motivo y el boton quedan siempre abajo y a la vista.
	var desplazable: ScrollContainer = ScrollContainer.new()
	desplazable.name = "Desplazable"
	desplazable.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desplazable.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	desplazable.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	desplazable.follow_focus = false
	columna.add_child(desplazable)
	texto = _etiqueta("Texto", &"")
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desplazable.add_child(texto)
	motivo = _etiqueta("Motivo", Tema.TENUE)
	columna.add_child(motivo)
	accion = Button.new()
	accion.name = "Accion"
	accion.custom_minimum_size.y = Tema.ALTO_TOQUE
	accion.theme_type_variation = Tema.TARJETA
	accion.visible = false
	accion.pressed.connect(accion_pulsada.emit)
	columna.add_child(accion)


func _draw() -> void:
	var azar: RandomNumberGenerator = RandomNumberGenerator.new()
	azar.seed = hash(Vector2i(size))
	var puntos: PackedVector2Array = EstiloGis.puntos(azar, Vector2(0.0, 0.0), Vector2(1.0, size.y), 1.0)
	draw_polyline(puntos, Color(Tema.GASTADO, 0.4), 2.0, true)


func _notification(que: int) -> void:
	if que == NOTIFICATION_RESIZED:
		queue_redraw()


## Llena el panel. imagen es un Control sin padre (lo libera el siguiente mostrar o limpiar); null deja el hueco vacio.
## rotulo vacio esconde el boton (de pie, o lo que no se puede poner); motivo vacio no dice nada abajo.
func mostrar(titulo: String, imagen: Control, descripcion: String, nota: String, rotulo: String) -> void:
	nombre.text = titulo
	_quitar_imagen()
	if imagen != null:
		imagen.name = "Dibujo"
		imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_imagen.add_child(imagen)
	texto.text = descripcion
	motivo.text = nota
	accion.text = rotulo
	accion.visible = not rotulo.is_empty()


## Deja el panel vacio: sin nada elegido (una pagina sin objetos).
func limpiar() -> void:
	mostrar("", null, "", "", "")


## La imagen que muestra el panel, o null.
func imagen() -> Control:
	return _imagen.get_node_or_null(^"Dibujo") as Control


## Una imagen de LADO_IMAGEN para mostrar, con la textura centrada y sin deformarla.
static func imagen_de(textura: Texture2D) -> TextureRect:
	var nueva: TextureRect = TextureRect.new()
	nueva.texture = textura
	nueva.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nueva.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	nueva.custom_minimum_size = Vector2.ONE * LADO_IMAGEN
	return nueva


func _quitar_imagen() -> void:
	var vieja: Control = imagen()
	if vieja != null:
		_imagen.remove_child(vieja)
		vieja.queue_free()


func _etiqueta(nombre_nodo: String, variacion: StringName) -> Label:
	var etiqueta: Label = Label.new()
	etiqueta.name = nombre_nodo
	etiqueta.theme_type_variation = variacion
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return etiqueta
