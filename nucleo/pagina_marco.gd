class_name PaginaMarco
extends CanvasLayer
# Base de las paginas del marco de menus (MarcoMenus): capa, grupo pagina_marco, correr en pausa y el estado abierta.
# El marco les habla con llamadas tipadas a esta clase en lugar de call() por nombre, que el validador no revisa.
# Vive en el nucleo: mapa/ la extiende (PantallaMapa) y el nucleo sigue sin nombrar clases de mapa/.

## Capa de las paginas: debajo de la barra del marco (MarcoMenus.CAPA).
const CAPA: int = 20

## A la vista dentro del marco. Publico para los guiones.
var abierta: bool = false


# Una pagina que define su _ready empieza con super(): sin eso no entra al grupo y el marco no la encuentra.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = CAPA
	add_to_group(MarcoMenus.GRUPO_PAGINAS)
	visible = false


## Id estable de la pagina (el de MarcoMenus.ORDEN). Cada pagina lo da.
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
