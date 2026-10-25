extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de los amuletos: Partida pone y quita solo lo que se tiene y con lugar, y autoguarda; la pagina Amuletos del
# marco de menus deja cambiarlos solo sentado en un banco, de pie solo los muestra y con muchos se desplaza con el
# foco. Deja casos y fallos para amuletos.guion e imprime el resumen.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const RUTA: String = "user://prueba_amuletos.json"
# Amuletos de mas para el caso de la lista que no cabe: 4 + 12 filas de 108 px no caben en 720 px.
const MUCHOS: int = 12


func _ready() -> void:
	_aislar_partida(RUTA)

	# Partida.
	_caso("sin tenerlo no se pone", not Partida.puede_equipar(&"brujula") and not Partida.equipar(&"brujula") and Partida.amuletos_equipados.is_empty())
	Partida.amuletos_tenidos.append_array([&"brujula", &"a", &"b", &"c"] as Array[StringName])
	var antes: int = Partida.autoguardados
	_caso("uno que se tiene se pone y autoguarda", Partida.equipar(&"brujula") and Partida.esta_equipado(&"brujula") and Partida.autoguardados == antes + 1)
	_caso("puesto no se pone dos veces", not Partida.equipar(&"brujula") and Partida.amuletos_equipados.size() == 1)
	Partida.equipar(&"a")
	Partida.equipar(&"b")
	_caso("con %d puestos no cabe otro" % Partida.MAX_EQUIPADOS, not Partida.puede_equipar(&"c") and not Partida.equipar(&"c") and Partida.amuletos_equipados.size() == Partida.MAX_EQUIPADOS)
	antes = Partida.autoguardados
	_caso("quitar uno puesto lo quita y autoguarda", Partida.desequipar(&"a") and not Partida.esta_equipado(&"a") and Partida.autoguardados == antes + 1)
	_caso("quitar uno que no esta puesto no hace nada", not Partida.desequipar(&"a") and Partida.autoguardados == antes + 1)
	var datos: Dictionary = Partida.a_diccionario()
	Partida.reiniciar()
	Partida.desde_diccionario(datos)
	_caso("los puestos vuelven al cargar", Partida.esta_equipado(&"brujula") and Partida.esta_equipado(&"b") and not Partida.esta_equipado(&"a") and Partida.amuletos_tenidos.size() == 4)

	# Pagina del marco, con un jugador de pie (abrir y cerrar el marco lo prueba prueba_marco.gd).
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.name = "Jugador"
	add_child(jugador)
	var pantalla: PantallaAmuletos = PantallaAmuletos.new()
	pantalla.name = "Amuletos"
	add_child(pantalla)
	_caso("es la pagina amuletos del marco", pantalla.is_in_group(MarcoMenus.GRUPO_PAGINAS) and pantalla.id_pagina() == &"amuletos")
	pantalla.mostrar_en_marco()
	_caso("mostrarla lista los que se tienen", pantalla.visible and pantalla.botones.size() == 4)
	_caso("de pie se ven pero no se cambian", pantalla.botones[&"a"].disabled and not pantalla.alternar(&"a") and not Partida.esta_equipado(&"a"))
	pantalla.ocultar_de_marco()
	_caso("ocultarla la quita de la vista", not pantalla.visible and not pantalla.abierta)

	# Sentado.
	jugador.descansando = true
	pantalla.mostrar_en_marco()
	_caso("sentado, el que cabe responde y el que esta puesto tambien", not pantalla.botones[&"a"].disabled and not pantalla.botones[&"brujula"].disabled)
	_caso("sentado se quita uno puesto", pantalla.alternar(&"brujula") and not Partida.esta_equipado(&"brujula") and pantalla.botones[&"brujula"].text.ends_with("guardado"))
	pantalla.alternar(&"a")
	pantalla.alternar(&"c")
	_caso("sentado se ponen hasta llenar y el siguiente no responde", Partida.amuletos_equipados.size() == Partida.MAX_EQUIPADOS and pantalla.botones[&"brujula"].disabled and not pantalla.alternar(&"brujula"))
	pantalla.ocultar_de_marco()

	# Mas de los que caben a lo alto: la lista se desplaza y el foco lleva el ultimo a la vista.
	for i: int in range(MUCHOS):
		Partida.amuletos_tenidos.append(StringName("extra_%d" % i))
	pantalla.mostrar_en_marco()
	await _esperar_cuadros(3)
	var desplazable: ScrollContainer = pantalla.get_node(^"Fondo/Desplazable") as ScrollContainer
	var ultimo: Button = pantalla.botones[Partida.amuletos_tenidos[Partida.amuletos_tenidos.size() - 1]]
	var vista: Rect2 = desplazable.get_global_rect()
	_caso("con muchos la lista no cabe y el ultimo empieza fuera de la vista", desplazable.get_v_scroll_bar().max_value > vista.size.y and not vista.encloses(ultimo.get_global_rect()))
	Tema.dar_foco(ultimo)
	await _esperar_cuadros(3)
	_caso("el ultimo con el foco queda dentro de la vista", desplazable.scroll_vertical > 0 and desplazable.get_global_rect().encloses(ultimo.get_global_rect()))
	pantalla.ocultar_de_marco()

	pantalla.free()
	jugador.free()
	get_tree().paused = false
	_restaurar_partida()
	_resumen()


# Espera cuadros de dibujo: el acomodo de los contenedores y el follow_focus corren diferidos.
func _esperar_cuadros(cuadros: int) -> void:
	for i: int in range(cuadros):
		await get_tree().process_frame
