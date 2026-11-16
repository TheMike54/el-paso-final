class_name Circulos
extends Control
# Fila de circulos de gis: llenos los usados y vacios los demas. Muestra la carga de los amuletos, el costo de cada uno y
# los cupos de los utiles en la misma unidad, para no tener que traducir un numero a circulos. Solo informa: no toma
# el foco ni los toques. Un _draw por cambio.

## Diametro de cada circulo y espacio entre dos.
const DIAMETRO: float = 24.0
const SEPARACION: float = 7.0
const GROSOR: float = 3.0

## Cuantos estan llenos y cuantos hay. Publicos para las pruebas; se cambian con poner().
var usados: int = 0
var total: int = 0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	size_flags_vertical = Control.SIZE_SHRINK_CENTER


## Cambia la cuenta y el tamano minimo; usados de mas se dibujan todos llenos.
func poner(nuevos_usados: int, nuevo_total: int) -> void:
	usados = nuevos_usados
	total = maxi(nuevo_total, 0)
	custom_minimum_size = Vector2(total * DIAMETRO + maxi(total - 1, 0) * SEPARACION, DIAMETRO)
	queue_redraw()


func _draw() -> void:
	var radio: float = DIAMETRO / 2.0
	var y: float = size.y / 2.0
	for i: int in range(total):
		var centro: Vector2 = Vector2(radio + i * (DIAMETRO + SEPARACION), y)
		if i < usados:
			draw_circle(centro, radio, Tema.GIS, true, -1.0, true)
		else:
			draw_arc(centro, radio - GROSOR / 2.0, 0.0, TAU, 24, Tema.GASTADO, GROSOR, true)
