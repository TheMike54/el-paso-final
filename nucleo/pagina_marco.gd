class_name PaginaMarco
extends CanvasLayer
# Base de las paginas del marco de menus (MarcoMenus): capa, grupo pagina_marco, correr en pausa y el estado abierta.
# El marco les habla con llamadas tipadas a esta clase en lugar de call() por nombre, que el validador no revisa.
# Vive en el nucleo: mapa/ la extiende (PantallaMapa) y el nucleo sigue sin nombrar clases de mapa/.

## Capa de las paginas: debajo de la barra del marco (MarcoMenus.CAPA).
const CAPA: int = ModalPausa.CAPA

## A la vista dentro del marco. Publico para los guiones.
var abierta: bool = false

var _aviso: Label = null
var _lista: VBoxContainer = null


# Una pagina que define su _ready empieza con super(): sin eso no entra al grupo y el marco no la encuentra.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = CAPA
	add_to_group(MarcoMenus.GRUPO_PAGINAS)
	visible = false


## Id estable de la pagina (el de MarcoMenus.PAGINAS). Cada pagina lo da.
func id_pagina() -> StringName:
	return &""


## Nombre en la barra del marco. Cada pagina lo da.
func titulo_pagina() -> String:
	return ""


## El marco la muestra con el juego ya detenido. Una pagina que llena algo al mostrarse llama a super() primero.
func mostrar_en_marco() -> void:
	abierta = true
	visible = true


## El marco la quita de la vista al cambiar de pagina y al cerrarse.
func ocultar_de_marco() -> void:
	abierta = false
	visible = false


## Sentado en un banco de esta sala; las paginas de equipo comparten esta regla.
func puede_cambiar() -> bool:
	return Jugador.sentado(get_tree())


# Arma la columna desplazable de las paginas de equipo, con su aviso encima de la lista.
func _crear_columna_equipo(panel: ColorRect, ancho: float = 1.0) -> VBoxContainer:
	var desplazable: ScrollContainer = ScrollContainer.new()
	desplazable.name = "Desplazable"
	desplazable.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	desplazable.offset_top = MarcoMenus.ALTO_BARRA
	desplazable.anchor_right = ancho
	desplazable.follow_focus = true
	desplazable.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	panel.add_child(desplazable)
	var centro: CenterContainer = CenterContainer.new()
	centro.name = "Centro"
	centro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	centro.size_flags_vertical = Control.SIZE_EXPAND_FILL
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desplazable.add_child(centro)
	var columna: VBoxContainer = VBoxContainer.new()
	columna.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	centro.add_child(columna)
	_aviso = Label.new()
	_aviso.name = "Aviso"
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(_aviso)
	return columna


func _crear_lista_equipo(columna: VBoxContainer) -> void:
	_lista = VBoxContainer.new()
	_lista.name = "Lista"
	_lista.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	columna.add_child(_lista)


func _aviso_equipo(sentado: bool, capacidad: String, usada: int, maxima: int) -> String:
	var accion: String = "Toca uno para ponerlo o quitarlo" if sentado else "Siéntate en un banco para cambiarlos"
	return "%s (%s %d de %d)." % [accion, capacidad, usada, maxima]
