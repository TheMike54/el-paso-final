class_name MarcoMenus
extends CanvasLayer
# Marco de los menus del juego, como el inventario de Hollow Knight: paginas en ciclo (Inventario, Amuletos, Mapa)
# encima del juego detenido, con una barra arriba que nombra la actual y sus vecinas. Lo crea cada sala; las
# paginas son nodos en el grupo pagina_marco y el marco las busca por el grupo, sin conocer sus clases: asi el
# nucleo no depende del bloque mapa. Lo abren mapa (en Mapa) e inventario (en Amuletos sentado, si no en Inventario).

const GRUPO: StringName = &"pantalla_encima"
## Grupo de las paginas. Cada una ofrece id_pagina(), titulo_pagina(), mostrar_en_marco() y ocultar_de_marco().
const GRUPO_PAGINAS: StringName = &"pagina_marco"
## Encima de las paginas (capa 20) y debajo de Configuracion abierta desde la pausa (22).
const CAPA: int = 21
## Alto de la barra de arriba: una pagina deja libre esa franja.
const ALTO_BARRA: float = Tema.ALTO_TOQUE + 2.0 * Tema.MARGEN_VERTICAL
## Orden del ciclo por id de pagina; una pagina que no esta aqui va al final.
const ORDEN: Array[StringName] = [&"inventario", &"amuletos", &"mapa"]
const ANCHO_VOLVER: float = 240.0

## Abierto (juego detenido) y la pagina a la vista. Publicos para los guiones.
var abierta: bool = false
var pagina: StringName = &""

var _paginas: Array[Node] = []
var _tick_cerrada: int = -10
var _volver: Button = null
var _anterior: Button = null
var _siguiente: Button = null
var _titulo: Label = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = CAPA
	add_to_group(GRUPO)
	var barra: HBoxContainer = HBoxContainer.new()
	barra.name = "Barra"
	barra.theme = Tema.crear()
	barra.set_anchors_preset(Control.PRESET_TOP_WIDE)
	barra.offset_left = Tema.MARGEN_LATERAL
	barra.offset_right = -Tema.MARGEN_LATERAL
	barra.offset_top = Tema.MARGEN_VERTICAL
	barra.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	add_child(barra)
	_volver = _boton(barra, "Volver", cerrar)
	_volver.name = "Volver"
	_volver.custom_minimum_size.x = ANCHO_VOLVER
	barra.add_child(_relleno())
	_anterior = _boton(barra, "", cambiar.bind(-1))
	_anterior.name = "Anterior"
	_titulo = Label.new()
	_titulo.name = "Titulo"
	_titulo.add_theme_font_size_override(&"font_size", Tema.LETRA_TITULO)
	_titulo.custom_minimum_size = Vector2(360.0, Tema.ALTO_TOQUE)
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	barra.add_child(_titulo)
	_siguiente = _boton(barra, "", cambiar.bind(1))
	_siguiente.name = "Siguiente"
	barra.add_child(_relleno())
	# Del ancho de Volver, para que el titulo quede al centro de la pantalla.
	var contrapeso: Control = Control.new()
	contrapeso.custom_minimum_size.x = ANCHO_VOLVER
	contrapeso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	barra.add_child(contrapeso)
	visible = false


func _boton(barra: HBoxContainer, texto: String, al_tocar: Callable) -> Button:
	var boton: Button = Button.new()
	boton.text = texto
	boton.custom_minimum_size.y = Tema.ALTO_TOQUE
	boton.pressed.connect(al_tocar)
	barra.add_child(boton)
	return boton


func _relleno() -> Control:
	var relleno: Control = Control.new()
	relleno.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	relleno.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return relleno


# Se leen acciones con nombre: lo abren y lo manejan igual el teclado, el control, el boton tactil y un guion.
func _physics_process(_delta: float) -> void:
	if abierta:
		if Input.is_action_just_pressed(&"pausa") or Input.is_action_just_pressed(&"mapa") or Input.is_action_just_pressed(&"inventario"):
			cerrar()
		elif Input.is_action_just_pressed(&"pagina_anterior"):
			cambiar(-1)
		elif Input.is_action_just_pressed(&"pagina_siguiente"):
			cambiar(1)
	elif not get_tree().paused and Engine.get_physics_frames() != _tick_cerrada:
		if Input.is_action_just_pressed(&"mapa"):
			abrir(&"mapa")
		elif Input.is_action_just_pressed(&"inventario"):
			abrir(&"amuletos" if _sentado() else &"inventario")


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST and abierta:
		cerrar()


## Abre en la pagina pedida deteniendo el juego. No abre con el juego ya detenido (la pausa) ni si esa pagina no
## existe (sin el bloque mapa no hay pagina Mapa).
func abrir(id: StringName) -> void:
	if abierta or get_tree().paused:
		return
	_buscar_paginas()
	if _indice_de(id) < 0:
		return
	abierta = true
	visible = true
	get_tree().paused = true
	_ver(id)


func cerrar() -> void:
	if not abierta:
		return
	for nodo: Node in _paginas:
		nodo.call(&"ocultar_de_marco")
	abierta = false
	visible = false
	pagina = &""
	_tick_cerrada = Engine.get_physics_frames()
	get_tree().paused = false


## Pasa a la pagina vecina: -1 la anterior, 1 la siguiente, en ciclo.
func cambiar(paso: int) -> void:
	if not abierta or _paginas.size() < 2:
		return
	var i: int = posmod(_indice_de(pagina) + paso, _paginas.size())
	_ver(_id(_paginas[i]))


## Con el marco abierto, y en el tick en que se cerro, la pausa no se abre (la misma pulsacion de pausa o Atras).
func bloquea_pausa() -> bool:
	return abierta or Engine.get_physics_frames() == _tick_cerrada


## Ids de las paginas en el orden del ciclo. Publico para los guiones.
func ids() -> Array[StringName]:
	_buscar_paginas()
	var lista: Array[StringName] = []
	for nodo: Node in _paginas:
		lista.append(_id(nodo))
	return lista


func _ver(id: StringName) -> void:
	pagina = id
	for nodo: Node in _paginas:
		if _id(nodo) != id:
			nodo.call(&"ocultar_de_marco")
	_paginas[_indice_de(id)].call(&"mostrar_en_marco")
	var i: int = _indice_de(id)
	var n: int = _paginas.size()
	_titulo.text = _titulo_de(_paginas[i])
	_anterior.visible = n > 1
	_siguiente.visible = n > 1
	_anterior.text = "‹ " + _titulo_de(_paginas[posmod(i - 1, n)])
	_siguiente.text = _titulo_de(_paginas[posmod(i + 1, n)]) + " ›"
	# Si la pagina no tomo el foco (sin nada que tocar), lo toma Volver: con el control siempre hay foco.
	var foco: Control = get_viewport().gui_get_focus_owner()
	if foco == null or not foco.is_visible_in_tree():
		_volver.grab_focus()


func _buscar_paginas() -> void:
	_paginas.clear()
	for nodo: Node in get_tree().get_nodes_in_group(GRUPO_PAGINAS):
		_paginas.append(nodo)
	_paginas.sort_custom(func(a: Node, b: Node) -> bool: return _orden(a) < _orden(b))


func _orden(nodo: Node) -> int:
	var i: int = ORDEN.find(_id(nodo))
	return i if i >= 0 else ORDEN.size()


func _indice_de(id: StringName) -> int:
	for i: int in range(_paginas.size()):
		if _id(_paginas[i]) == id:
			return i
	return -1


func _id(nodo: Node) -> StringName:
	var id: StringName = nodo.call(&"id_pagina")
	return id


func _titulo_de(nodo: Node) -> String:
	var titulo: String = nodo.call(&"titulo_pagina")
	return titulo


func _sentado() -> bool:
	var jugador: Jugador = get_tree().get_first_node_in_group(&"jugador") as Jugador
	return jugador != null and jugador.descansando
