class_name FondoTapado
extends Control
# Recorta los Parallax2D hijos tras una pared opaca con clip_contents (classes/class_control.rst) para no pintarlos.
# Los oculta del todo si la vista queda dentro de la pared; lado admite pared a izquierda o derecha de lo visible.
# En La Celda del S50 dio +7 FPS en el borde y +2,6 en el recorrido; el limite de cada sala se mide A/B.
# Se coloca en (0, 0) en el editor y se acomoda al entrar para compensar el recorte.

## Grupo de los fondos tapados de la sala: el panel de pruebas los apaga juntos.
const GRUPO: StringName = &"fondos_sala"
## Lo que el recorte empieza antes del fin de la pared, en px: tapa la costura del borde.
const MARGEN: float = 2.0
## Alto y ancho del rectangulo de recorte: de sobra para cualquier sala y cualquier capa.
const EXTENSION: float = 100000.0

## De que lado de lo visible esta la pared opaca.
enum Lado {
	IZQUIERDA,
	DERECHA,
}

## x de la sala donde acaba la pared opaca: con la pared a la izquierda, lo de atras solo se ve a su derecha; con la
## pared a la derecha, es donde empieza la pared y lo de atras solo se ve a su izquierda.
@export var fin_pared: float = 0.0
## Lado de la pared respecto de lo que se ve.
@export var lado: Lado = Lado.IZQUIERDA

var _compensa: Node2D = null


func _ready() -> void:
	add_to_group(GRUPO)
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var x: float = fin_pared - MARGEN if lado == Lado.IZQUIERDA else fin_pared + MARGEN - EXTENSION
	position = Vector2(x, -EXTENSION / 2.0)
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
	var ver: bool = not tapado(vista, fin_pared, lado == Lado.DERECHA)
	if ver != visible:
		visible = ver


## Si la vista (en coordenadas de la sala) cae entera dentro de la pared: la que acaba en fin (a la izquierda) o, con
## a_la_derecha, la que empieza en fin.
static func tapado(vista: Rect2, fin: float, a_la_derecha: bool = false) -> bool:
	if a_la_derecha:
		return vista.position.x >= fin + MARGEN
	return vista.end.x <= fin - MARGEN
