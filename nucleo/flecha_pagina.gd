class_name FlechaPagina
extends Button
# Flecha de cambio de pagina del marco de menus (propuesta D): una zona de toque alta a un lado de la pantalla, a media
# altura, donde caen los pulgares, con un angulo de gis y un contorno oscuro para que se lea encima del mapa. Debajo
# lleva el boton del control de su accion. No toma el foco: con el control las paginas se cambian con LB y RB.

## Lado del dibujo del angulo, en px (el viewBox de 56 del mockup dibujado a 64).
const LADO_DIBUJO: float = 64.0
const GROSOR: float = 4.0
## Contorno oscuro bajo el gis: separa la flecha de lo que haya detras (una sala del mapa).
const GROSOR_CONTORNO: float = 12.0
const COLOR_CONTORNO: Color = Color(0.0, 0.0, 0.0, 0.7)
## Distancia del boton del control al borde de abajo de la zona de toque.
const MARGEN_ICONO: float = 16.0

## -1: la pagina anterior (flecha a la izquierda); 1: la siguiente (a la derecha).
var paso: int = 1


func _init(direccion: int = 1) -> void:
	paso = -1 if direccion < 0 else 1


func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_NONE
	theme = Tema.crear()
	custom_minimum_size = Vector2(MarcoMenus.ANCHO_FLECHA, MarcoMenus.ALTO_FLECHA)
	# El icono va en un Control intermedio: con un Button de padre, IconoBoton le reserva el lugar como a un texto.
	var pie: Control = Control.new()
	pie.name = "Pie"
	pie.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pie.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(pie)
	var icono: IconoBoton = IconoBoton.new()
	icono.name = "Icono"
	icono.accion = &"pagina_anterior" if paso < 0 else &"pagina_siguiente"
	icono.anchor_left = 0.5
	icono.anchor_right = 0.5
	icono.anchor_top = 1.0
	icono.anchor_bottom = 1.0
	icono.offset_top = -MARGEN_ICONO
	icono.offset_bottom = -MARGEN_ICONO
	icono.grow_horizontal = Control.GROW_DIRECTION_BOTH
	icono.grow_vertical = Control.GROW_DIRECTION_BEGIN
	pie.add_child(icono)


func _draw() -> void:
	var escala: float = LADO_DIBUJO / 56.0
	var origen: Vector2 = (size - Vector2(LADO_DIBUJO, LADO_DIBUJO)) / 2.0
	var puntos: PackedVector2Array = PackedVector2Array()
	for punto: Vector2 in angulo(paso):
		puntos.append(origen + punto * escala)
	# Sin resaltar al pasar el puntero: en tactil el ultimo toque lo dejaria encendido.
	var oprimida: bool = get_draw_mode() == DRAW_PRESSED or get_draw_mode() == DRAW_HOVER_PRESSED
	draw_polyline(puntos, COLOR_CONTORNO, GROSOR_CONTORNO, true)
	draw_polyline(puntos, Tema.GIS if oprimida else Tema.GASTADO, GROSOR, true)


## Los tres puntos del angulo en el viewBox de 56 del mockup: apunta a la izquierda con paso -1 y a la derecha con 1.
static func angulo(direccion: int) -> Array[Vector2]:
	if direccion < 0:
		return [Vector2(35.4, 12.5), Vector2(18.3, 28.7), Vector2(35.6, 43.9)]
	return [Vector2(20.4, 12.1), Vector2(38.0, 28.4), Vector2(19.5, 43.5)]
