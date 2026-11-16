class_name MarcaUso
extends Control
# Palomita de gis al final de una fila de Amuletos o Utiles cuando eso esta en uso. Hace que el estado se vea sin leer
# «En uso» (regla 7 del estudio de UX de los menus). Apagada no dibuja nada pero conserva su lugar, para que el texto
# de la fila no se mueva al poner o quitar. Solo informa: no toma el foco ni los toques.

## Lado de la caja de la marca.
const LADO: float = 28.0

## Publico para las pruebas; se cambia con encender().
var encendida: bool = false


func _init() -> void:
	custom_minimum_size = Vector2.ONE * LADO
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE


func encender(si: bool) -> void:
	if encendida != si:
		encendida = si
		queue_redraw()


func _draw() -> void:
	if not encendida:
		return
	var puntos: PackedVector2Array = [Vector2(0.15, 0.55) * size, Vector2(0.4, 0.8) * size, Vector2(0.88, 0.2) * size]
	draw_polyline(puntos, Tema.GIS, IconoArticulo.GROSOR, true)
