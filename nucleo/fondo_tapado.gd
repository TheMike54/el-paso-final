class_name FondoTapado
extends Control
# Fondos que una pared opaca tapa: sus hijos (las capas Parallax2D de atras) se recortan al borde donde acaba la
# pared (clip_contents, classes/class_control.rst:1616) y se ocultan del todo mientras la vista cae entera dentro de
# la pared. En el S50 el limite es el relleno: lo tapado ya no se pinta (+7 FPS donde se ve el fin de la pared, +2,6
# en el recorrido, demo de La Celda, 25-oct-2026). En el editor se usa en (0, 0); se acomoda solo al entrar.

## Grupo de los fondos tapados de la sala: el panel de pruebas los apaga juntos.
const GRUPO: StringName = &"fondos_sala"
## Lo que el recorte empieza antes del fin de la pared, en px: tapa la costura del borde.
const MARGEN: float = 2.0
## Alto y ancho del rectangulo de recorte: de sobra para cualquier sala y cualquier capa.
const EXTENSION: float = 100000.0

## x de la sala donde acaba la pared opaca: lo de atras solo se ve a su derecha.
@export var fin_pared: float = 0.0

var _compensa: Node2D = null


func _ready() -> void:
	add_to_group(GRUPO)
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = Vector2(fin_pared - MARGEN, -EXTENSION / 2.0)
	size = Vector2(EXTENSION, EXTENSION)
	# Los hijos se pasan a un nodo que deshace la posicion del recorte: se dibujan donde estaban.
	_compensa = Node2D.new()
	_compensa.name = &"Compensa"
	_compensa.position = -position
	var hijos: Array[Node] = get_children()
	add_child(_compensa)
	for hijo: Node in hijos:
		hijo.reparent(_compensa, false)


func _process(_delta: float) -> void:
	var vista: Rect2 = get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_visible_rect()
	var ver: bool = not tapado(vista, fin_pared)
	if ver != visible:
		visible = ver


## Si la vista (en coordenadas de la sala) cae entera dentro de la pared que acaba en fin.
static func tapado(vista: Rect2, fin: float) -> bool:
	return vista.end.x <= fin - MARGEN
