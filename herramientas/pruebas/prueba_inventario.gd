extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba la pagina Inventario del marco: al empezar no hay arma ni habilidades y nada se elige; con arma y habilidades
# muestra los nombres escritos (nunca el id), los simbolos en el orden de la aventura, el detalle del elegido sin
# boton, la Inspiracion en numero y bloques, y lo perdido y los mapas con el nombre de su zona. Aisla la partida.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const RUTA: String = "user://prueba_inventario.json"


func _ready() -> void:
	_aislar_partida(RUTA)
	Partida.reiniciar()
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(jugador)
	var pagina: PaginaInventario = PaginaInventario.new()
	pagina.name = "Inventario"
	add_child(pagina)
	pagina.mostrar_en_marco()
	_caso("al empezar no hay arma, habilidades ni nada elegido", pagina.valores["Arma"] == "Sin arma"
			and pagina.simbolos.is_empty() and pagina.elegido.is_empty() and pagina.detalle.nombre.text.is_empty()
			and (pagina.get_node(^"Fondo/Cuerpo/Abajo/Izquierda/Ninguna") as Control).visible)
	_caso("sin arma la carta no se toca ni lleva marco", pagina.carta_arma.flat and not (pagina.carta_arma.get_node(^"Katana") as CanvasItem).visible and pagina.carta_arma.focus_mode == Control.FOCUS_NONE
			and pagina.carta_arma.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	_caso("al empezar no hay nada perdido ni mapas", pagina.valores["Lo perdido"] == "Nada" and pagina.valores["Mapas"] == "Ninguno")
	pagina.ocultar_de_marco()

	Partida.habilidades.append_array([Habilidades.PROYECTIL, Habilidades.PLUMA, Habilidades.IMPULSO, Habilidades.CAIDA_EN_PICADA] as Array[StringName])
	Partida.mapas.append("prueba")
	Partida.mochila = {"sala": "prueba_1", "x": 10.0, "y": 20.0, "monto": 36}
	Partida.inspiracion = 22
	pagina.mostrar_en_marco()
	_caso("con arma la elige primero y el detalle dice su nombre, sin boton", pagina.elegido == PaginaInventario.ARMA
			and pagina.carta_arma.button_pressed and pagina.detalle.nombre.text == "La Pluma"
			and pagina.detalle.texto.text == PaginaInventario.TEXTO_ARMA and not pagina.detalle.accion.visible
			and (pagina.detalle.imagen() as TextureRect).texture == PaginaInventario.KATANA
			and (pagina.carta_arma.get_node(^"Katana") as CanvasItem).visible)
	_caso("las habilidades van con simbolo en el orden de la aventura, sin el arma",
			pagina.simbolos.keys() == [Habilidades.IMPULSO, Habilidades.CAIDA_EN_PICADA, Habilidades.PROYECTIL]
			and (pagina.simbolos[Habilidades.IMPULSO].get_node(^"Simbolo") as SimboloHabilidad).habilidad == Habilidades.IMPULSO)
	_caso("los nombres son los escritos, no el id", pagina.valores["Habilidades"] == "Impulso, Caída en picada, Proyectil"
			and SimboloHabilidad.nombre_de(Habilidades.CAIDA_EN_PICADA) == "Caída en picada")
	pagina.simbolos[Habilidades.PROYECTIL].pressed.emit()
	_caso("tocar una habilidad la elige y muestra su texto", pagina.elegido == Habilidades.PROYECTIL
			and pagina.simbolos[Habilidades.PROYECTIL].button_pressed and not pagina.carta_arma.button_pressed
			and pagina.detalle.nombre.text == "Proyectil" and pagina.detalle.texto.text == SimboloHabilidad.texto_de(Habilidades.PROYECTIL)
			and pagina.detalle.imagen() is SimboloHabilidad)
	_caso("la Inspiracion va con numero", pagina.valores["Inspiración"] == "22 de %d" % Partida.inspiracion_maxima)
	var zona: String = Sala.nombre_de("prueba_1")
	_caso("lo perdido dice el monto y la zona, sin el id", pagina.valores["Lo perdido"] == "36 PejeCoins en %s" % zona
			and not pagina.valores["Lo perdido"].contains("prueba_1"))
	_caso("los mapas dicen el nombre de su zona", pagina.valores["Mapas"] == Sala.nombre_de("prueba_")
			and pagina.valores["Mapas"] != "prueba")
	_caso("cada habilidad del orden tiene nombre y texto escritos", _textos_completos())
	pagina.ocultar_de_marco()

	pagina.free()
	jugador.free()
	_restaurar_partida()
	_resumen()


func _textos_completos() -> bool:
	for habilidad: StringName in SimboloHabilidad.ORDEN:
		if not SimboloHabilidad.NOMBRES.has(habilidad) or SimboloHabilidad.texto_de(habilidad).is_empty():
			return false
	return true
