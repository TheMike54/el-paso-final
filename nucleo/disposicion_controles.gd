class_name DisposicionControles
extends RefCounted
# Donde va cada boton tactil y de que tamano: esquina de ancla, desplazamiento desde ella en fraccion del
# lado corto y escala, mas una opacidad para todos. Es el mismo modelo de la distribucion inicial, asi
# la distancia al pulgar se conserva entre proporciones. Solo cuentas, sin nodos, para probarlas con un
# guion: el editor de controles la cambia, Ajustes la guarda y ControlesTactiles la dibuja.

const ESCALA_MINIMA: float = 0.5
const ESCALA_MAXIMA: float = 2.0
const OPACIDAD_MINIMA: float = 0.2
const OPACIDAD_MAXIMA: float = 1.0
## Android pide objetivos tactiles de 48 x 48 dp. El toque cuenta hasta HOLGURA veces el radio, asi que el
## circulo dibujado puede ser mas chico que eso.
const OBJETIVO_DP: float = 48.0

## Por boton, en el orden de ControlesTactiles.ACCIONES.
var anclas: PackedVector2Array = PackedVector2Array()
var desplazamientos: PackedVector2Array = PackedVector2Array()
var escalas: PackedFloat32Array = PackedFloat32Array()
var opacidad: float = 1.0


## La distribucion inicial del diseno: con ella los botones quedan donde estaban antes del editor.
static func por_omision() -> DisposicionControles:
	var d: DisposicionControles = DisposicionControles.new()
	for i: int in range(ControlesTactiles.ACCIONES.size()):
		var ancla: Vector2 = ControlesTactiles.ANCLAS[i]
		d.anclas.append(ancla)
		d.desplazamientos.append((ControlesTactiles.CENTROS[i] - ancla) * Vector2(Vista.PROPORCION_BASE, 1.0))
		d.escalas.append(1.0)
	return d


func copia() -> DisposicionControles:
	var d: DisposicionControles = DisposicionControles.new()
	d.anclas = anclas.duplicate()
	d.desplazamientos = desplazamientos.duplicate()
	d.escalas = escalas.duplicate()
	d.opacidad = opacidad
	return d


func igual_a(otra: DisposicionControles) -> bool:
	if anclas != otra.anclas or not is_equal_approx(opacidad, otra.opacidad):
		return false
	for i: int in range(anclas.size()):
		if not desplazamientos[i].is_equal_approx(otra.desplazamientos[i]) or not is_equal_approx(escalas[i], otra.escalas[i]):
			return false
	return true


func centro(i: int, tamano: Vector2) -> Vector2:
	return anclas[i] * tamano + desplazamientos[i] * minf(tamano.x, tamano.y)


## El radio minimo solo frena al achicar: un boton no baja de su tamano por omision ni del minimo, el que
## sea menor. Asi la distribucion por omision no cambia en ninguna pantalla.
func radio(i: int, tamano: Vector2, radio_minimo: float) -> float:
	var por_omision: float = ControlesTactiles.RADIOS[i] * minf(tamano.x, tamano.y)
	return maxf(por_omision * escalas[i], minf(por_omision, radio_minimo))


func fijar_escala(i: int, escala: float) -> void:
	escalas[i] = clampf(escala, ESCALA_MINIMA, ESCALA_MAXIMA)


func fijar_opacidad(valor: float) -> void:
	opacidad = clampf(valor, OPACIDAD_MINIMA, OPACIDAD_MAXIMA)


## Pone el centro del boton en posicion, con el circulo dentro del area; se ancla a la esquina mas cercana.
func colocar(i: int, posicion: Vector2, tamano: Vector2, area: Rect2, radio_minimo: float) -> void:
	var r: float = radio(i, tamano, radio_minimo)
	var c: Vector2 = Vector2(_limitar(posicion.x, area.position.x + r, area.end.x - r), _limitar(posicion.y, area.position.y + r, area.end.y - r))
	var ancla: Vector2 = Vector2(1.0 if c.x > tamano.x / 2.0 else 0.0, 1.0 if c.y > tamano.y / 2.0 else 0.0)
	anclas[i] = ancla
	desplazamientos[i] = (c - ancla * tamano) / minf(tamano.x, tamano.y)


## Mete todos los botones en el area: al cargar, otra pantalla puede tener otra area segura.
func ajustar(tamano: Vector2, area: Rect2, radio_minimo: float) -> void:
	for i: int in range(anclas.size()):
		colocar(i, centro(i, tamano), tamano, area, radio_minimo)


func a_diccionario() -> Dictionary:
	var botones: Dictionary = {}
	for i: int in range(anclas.size()):
		botones[String(ControlesTactiles.ACCIONES[i])] = {
			"ancla": [anclas[i].x, anclas[i].y],
			"desplazamiento": [desplazamientos[i].x, desplazamientos[i].y],
			"escala": escalas[i],
		}
	return {"opacidad": opacidad, "botones": botones}


## Lee lo que escribio a_diccionario. Lo que falta o no es valido se queda en su valor por omision, boton por boton.
static func desde_diccionario(datos: Variant) -> DisposicionControles:
	var d: DisposicionControles = por_omision()
	if typeof(datos) != TYPE_DICTIONARY:
		return d
	var contenido: Dictionary = datos
	var opacidad_leida: Variant = contenido.get("opacidad")
	if typeof(opacidad_leida) == TYPE_FLOAT:
		d.fijar_opacidad(opacidad_leida as float)
	var botones_leidos: Variant = contenido.get("botones")
	if typeof(botones_leidos) != TYPE_DICTIONARY:
		return d
	var botones: Dictionary = botones_leidos
	for i: int in range(ControlesTactiles.ACCIONES.size()):
		var boton: Variant = botones.get(String(ControlesTactiles.ACCIONES[i]))
		if typeof(boton) != TYPE_DICTIONARY:
			continue
		var entrada: Dictionary = boton
		var ancla: Variant = _vector(entrada.get("ancla"))
		var desplazamiento: Variant = _vector(entrada.get("desplazamiento"))
		var escala: Variant = entrada.get("escala")
		if ancla == null or desplazamiento == null or typeof(escala) != TYPE_FLOAT:
			continue
		var esquina: Vector2 = ancla
		if not (esquina.x in [0.0, 1.0] and esquina.y in [0.0, 1.0]):
			continue
		d.anclas[i] = esquina
		d.desplazamientos[i] = desplazamiento
		d.fijar_escala(i, escala as float)
	return d


## El area segura del telefono (recorte de la camara, esquinas) en coordenadas de la vista. En la PC
## no hay recorte: toda la vista.
static func area_segura(vista: Vector2) -> Rect2:
	if not OS.has_feature("mobile"):
		return Rect2(Vector2.ZERO, vista)
	var ventana: Vector2 = Vector2(DisplayServer.window_get_size())
	var area: Rect2 = Rect2(DisplayServer.get_display_safe_area())
	area.position -= Vector2(DisplayServer.window_get_position())
	return area_en_vista(area, ventana, vista)


## Radio minimo en pixeles de la vista. En la PC, 0: se usa el raton, no el pulgar.
static func radio_minimo(vista: Vector2) -> float:
	if not OS.has_feature("mobile"):
		return 0.0
	return radio_minimo_en_vista(float(DisplayServer.screen_get_dpi()), Vector2(DisplayServer.window_get_size()), vista)


## Un rectangulo de la ventana en coordenadas de la vista: con canvas_items la vista se escala igual en
## los dos ejes y se centra (las barras, si las hay, quedan a los lados o arriba y abajo).
static func area_en_vista(area: Rect2, ventana: Vector2, vista: Vector2) -> Rect2:
	var escala: float = minf(ventana.x / vista.x, ventana.y / vista.y)
	var margen: Vector2 = (ventana - vista * escala) / 2.0
	var convertida: Rect2 = Rect2((area.position - margen) / escala, area.size / escala)
	return convertida.intersection(Rect2(Vector2.ZERO, vista))


static func radio_minimo_en_vista(dpi: float, ventana: Vector2, vista: Vector2) -> float:
	var escala: float = minf(ventana.x / vista.x, ventana.y / vista.y)
	return OBJETIVO_DP / 2.0 / ControlesTactiles.HOLGURA * dpi / 160.0 / escala


# Como clampf, pero si el area es mas chica que el boton lo deja en medio en vez de en un borde.
static func _limitar(valor: float, minimo: float, maximo: float) -> float:
	if minimo > maximo:
		return (minimo + maximo) / 2.0
	return clampf(valor, minimo, maximo)


# Un par de numeros de JSON ([x, y]) como Vector2; null si no lo es.
static func _vector(valor: Variant) -> Variant:
	if typeof(valor) != TYPE_ARRAY:
		return null
	var par: Array = valor
	if par.size() != 2 or typeof(par[0]) != TYPE_FLOAT or typeof(par[1]) != TYPE_FLOAT:
		return null
	var x: float = par[0]
	var y: float = par[1]
	if not (is_finite(x) and is_finite(y)):
		return null
	return Vector2(x, y)
