class_name Vista
extends RefCounted
# Rango de la vista (alternativa D del plan de pantalla completa): dentro del rango de proporciones, la
# vista crece como con aspect=expand; fuera, se recorta a la proporcion limite y el motor pone barras
# negras. Asi una ventana o pantalla extrema nunca muestra mas que 22:9 a lo ancho ni 4:3 a lo alto.
# Funciones estaticas y puras para probarlas con una tabla; arranque.gd aplica el resultado.

## Tamano base de la vista (project.godot: viewport_width x viewport_height).
const BASE: Vector2 = Vector2(1280.0, 720.0)
## Proporcion de BASE (16:9): la referencia con que se miden los botones tactiles y el HUD.
const PROPORCION_BASE: float = BASE.x / BASE.y


## Tamano de la vista para una ventana: alto 720 si es mas ancha que 16:9, ancho 1280 si es mas
## cuadrada; con la proporcion de la ventana recortada a [minima, maxima].
static func calcular(ventana: Vector2, minima: float, maxima: float) -> Vector2:
	var proporcion: float = clampf(ventana.x / maxf(ventana.y, 1.0), minima, maxima)
	if proporcion >= BASE.x / BASE.y:
		return Vector2(roundf(BASE.y * proporcion), BASE.y)
	return Vector2(BASE.x, roundf(BASE.x / proporcion))


## Verdadero si la ventana queda fuera del rango: la vista se recorta y aparecen barras.
static func con_barras(ventana: Vector2, minima: float, maxima: float) -> bool:
	var proporcion: float = ventana.x / maxf(ventana.y, 1.0)
	return proporcion < minima or proporcion > maxima
