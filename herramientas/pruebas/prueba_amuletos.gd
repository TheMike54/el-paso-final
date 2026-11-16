extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de los amuletos: Partida pone y quita solo lo que esta en el catalogo, se tiene y cabe en la carga, avisa y
# autoguarda, y suma sus efectos; la pagina Amuletos del marco de menus: sin amuletos lo dice, tocar una fila solo la
# elige y llena el detalle, el boton del detalle pone o quita solo sentado, lo que no cabe se explica y con muchos se
# desplaza con el foco. Usa el catalogo de pruebas (equipo_prueba.tres: prueba y velocidad cuestan 1, escudo y pesado
# 2). Deja casos y fallos para amuletos.guion e imprime el resumen.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const RUTA: String = "user://prueba_amuletos.json"
# Amuletos de mas para el caso de la lista que no cabe: 5 + 12 filas de 108 px no caben en 720 px.
const MUCHOS: int = 12
const PRUEBA: StringName = &"amuleto_prueba"
const VELOCIDAD: StringName = &"amuleto_velocidad"
const ESCUDO: StringName = &"amuleto_escudo"
const PESADO: StringName = &"amuleto_pesado"


func _ready() -> void:
	_aislar_partida(RUTA)

	# Partida.
	var cambios: Array[int] = [0]
	Eventos.equipo_cambiado.connect(func() -> void: cambios[0] += 1)
	_caso("sin tenerlo no se pone", not Partida.puede_equipar(PRUEBA) and not Partida.equipar(PRUEBA)
			and Partida.amuletos_equipados.is_empty())
	Partida.amuletos_tenidos.append_array([PRUEBA, VELOCIDAD, ESCUDO, PESADO, &"fuera_del_catalogo"] as Array[StringName])
	_caso("uno fuera del catalogo no se pone aunque se tenga", not Partida.equipar(&"fuera_del_catalogo"))
	var antes: int = Partida.autoguardados
	_caso("uno que se tiene se pone, avisa y autoguarda", Partida.equipar(PRUEBA) and Partida.esta_equipado(PRUEBA)
			and Partida.autoguardados == antes + 1 and cambios[0] == 1 and Partida.carga_usada() == 1)
	_caso("puesto no se pone dos veces", not Partida.equipar(PRUEBA) and Partida.amuletos_equipados.size() == 1)
	Partida.equipar(ESCUDO)
	_caso("con la carga llena (3 de 3) no cabe uno de costo 1", Partida.carga_usada() == Partida.CARGA_INICIAL
			and not Partida.puede_equipar(VELOCIDAD) and not Partida.equipar(VELOCIDAD))
	antes = Partida.autoguardados
	_caso("quitar uno puesto lo quita, avisa y autoguarda", Partida.desequipar(PRUEBA) and not Partida.esta_equipado(PRUEBA)
			and Partida.autoguardados == antes + 1 and cambios[0] == 3)
	_caso("quitar uno que no esta puesto no hace nada", not Partida.desequipar(PRUEBA) and Partida.autoguardados == antes + 1)
	_caso("con 1 libre cabe uno de costo 1 y no uno de costo 2", Partida.equipar(VELOCIDAD) and not Partida.equipar(PESADO))
	var efectos: FichaAmuleto = Partida.efectos_amuletos()
	_caso("los efectos suman los puestos", is_equal_approx(efectos.velocidad_factor, 1.25)
			and efectos.invulnerable_extra == 30 and efectos.inspiracion_extra == 0)
	Partida.carga_maxima = 4
	var datos: Dictionary = Partida.a_diccionario()
	Partida.reiniciar()
	_caso("empezar partida vuelve a la carga inicial", Partida.carga_maxima == Partida.CARGA_INICIAL
			and Partida.amuletos_equipados.is_empty())
	Partida.desde_diccionario(datos)
	_caso("los puestos y la carga vuelven al cargar", Partida.esta_equipado(ESCUDO) and Partida.esta_equipado(VELOCIDAD)
			and not Partida.esta_equipado(PRUEBA) and Partida.amuletos_tenidos.size() == 5 and Partida.carga_maxima == 4)
	Partida.carga_maxima = Partida.CARGA_INICIAL

	# Pagina del marco, con un jugador de pie (abrir y cerrar el marco lo prueba prueba_marco.gd).
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.name = "Jugador"
	add_child(jugador)
	var pantalla: PantallaAmuletos = PantallaAmuletos.new()
	pantalla.name = "Amuletos"
	add_child(pantalla)
	_caso("es la pagina amuletos del marco", pantalla.is_in_group(MarcoMenus.GRUPO_PAGINAS) and pantalla.id_pagina() == &"amuletos")
	var tenidos: Array[StringName] = Partida.amuletos_tenidos.duplicate()
	var equipados: Array[StringName] = Partida.amuletos_equipados.duplicate()
	Partida.amuletos_tenidos.clear()
	Partida.amuletos_equipados.clear()
	pantalla.mostrar_en_marco()
	var cuerpo: Control = pantalla.get_node(^"Fondo/Cuerpo") as Control
	_caso("sin amuletos lo dice y no muestra la lista ni el detalle", pantalla.vacio.visible and not cuerpo.visible
			and pantalla.botones.is_empty() and pantalla.detalle.nombre.text.is_empty())
	pantalla.ocultar_de_marco()
	Partida.amuletos_tenidos.assign(tenidos)
	Partida.amuletos_equipados.assign(equipados)

	# De pie, con escudo y velocidad puestos (carga 3 de 3).
	pantalla.mostrar_en_marco()
	var rejilla: GridContainer = pantalla.get_node(^"Fondo/Cuerpo/Lista/Desplazable/Fichas") as GridContainer
	_caso("mostrarla lista los que se tienen en dos columnas", pantalla.visible and not pantalla.vacio.visible
			and cuerpo.visible and pantalla.botones.size() == 5 and rejilla.columns == 2)
	_caso("la fila del escudo dice su nombre, su costo en circulos y que esta en uso, con la marca",
			_nombre_fila(pantalla, ESCUDO) == "Chamarra de prueba" and _costo(pantalla, ESCUDO).usados == 2
			and _costo(pantalla, ESCUDO).total == 2 and _dice(pantalla, ESCUDO) == "En uso" and _marca(pantalla, ESCUDO).encendida)
	_caso("la de prueba dice que no esta en uso y no lleva marca", _dice(pantalla, PRUEBA) == "Sin usar"
			and not _marca(pantalla, PRUEBA).encendida)
	var lleva: Node = pantalla.get_node(^"Fondo/Cuerpo/Lista/Puesto/Lleva")
	_caso("arriba van los dos puestos y la carga en circulos", lleva.get_child_count() == 2 and lleva.has_node(NodePath(String(ESCUDO)))
			and pantalla.carga.usados == 3 and pantalla.carga.total == Partida.CARGA_INICIAL)
	var ficha_prueba: FichaAmuleto = CatalogoEquipo.amuleto(PRUEBA)
	_caso("al abrir elige la primera, la enciende y llena el detalle", pantalla.elegido == PRUEBA
			and pantalla.botones[PRUEBA].button_pressed and not pantalla.botones[ESCUDO].button_pressed
			and pantalla.detalle.nombre.text == ficha_prueba.nombre and pantalla.detalle.texto.text == ficha_prueba.descripcion
			and pantalla.detalle.imagen() is IconoArticulo)
	_caso("de pie el detalle dice que hay que sentarse y no ofrece boton",
			pantalla.detalle.motivo.text == "Siéntate en un banco para cambiarlos." and not pantalla.detalle.accion.visible
			and not pantalla.alternar(PRUEBA) and not Partida.esta_equipado(PRUEBA))
	Tema.dar_foco(pantalla.botones[VELOCIDAD])
	_caso("enfocar otra fila la elige", pantalla.elegido == VELOCIDAD and pantalla.botones[VELOCIDAD].button_pressed
			and not pantalla.botones[PRUEBA].button_pressed
			and pantalla.detalle.texto.text == CatalogoEquipo.amuleto(VELOCIDAD).descripcion)
	pantalla.botones[ESCUDO].pressed.emit()
	_caso("tocar una fila puesta de pie solo la elige", pantalla.elegido == ESCUDO and Partida.esta_equipado(ESCUDO)
			and Partida.amuletos_equipados.size() == 2)
	var icono: IconoArticulo = pantalla.botones[PRUEBA].get_node(^"Ficha/Icono") as IconoArticulo
	_caso("sin icono en la ficha usa el amuleto de gis", ficha_prueba.icono == null
			and icono != null and icono.forma == IconoArticulo.Forma.AMULETO)
	pantalla.elegir(&"fuera_del_catalogo")
	_caso("fuera del catalogo muestra un nombre legible, sin boton ni motivo",
			_nombre_fila(pantalla, &"fuera_del_catalogo") == "Fuera Del Catalogo"
			and pantalla.detalle.nombre.text == "Fuera Del Catalogo" and pantalla.detalle.motivo.text.is_empty()
			and not pantalla.detalle.accion.visible and not pantalla.alternar(&"fuera_del_catalogo"))
	pantalla.ocultar_de_marco()
	_caso("ocultarla la quita de la vista", not pantalla.visible and not pantalla.abierta)

	# Sentado, con escudo y velocidad puestos (carga 3 de 3).
	jugador.descansando = true
	pantalla.mostrar_en_marco()
	pantalla.elegir(VELOCIDAD)
	_caso("sentado, el puesto elegido ofrece Quitar", pantalla.detalle.accion.visible
			and pantalla.detalle.accion.text == "Quitar" and pantalla.detalle.motivo.text == "En uso")
	pantalla.elegir(PRUEBA)
	_caso("el que no cabe explica por que, sin boton y apagado",
			pantalla.detalle.motivo.text == "No cabe: cuesta 1 y te queda 0 de carga." and not pantalla.detalle.accion.visible
			and _etiqueta(pantalla, PRUEBA, ^"Textos/Nombre").theme_type_variation == Tema.TEXTO_FICHA_APAGADO
			and _etiqueta(pantalla, VELOCIDAD, ^"Textos/Nombre").theme_type_variation == Tema.TEXTO_FICHA)
	pantalla.botones[VELOCIDAD].pressed.emit()
	_caso("tocar una fila la elige y lleva el foco al boton sin cambiar nada", pantalla.elegido == VELOCIDAD
			and pantalla.detalle.accion.has_focus() and Partida.esta_equipado(VELOCIDAD) and Partida.carga_usada() == 3)
	pantalla.detalle.accion.pressed.emit()
	_caso("el boton quita el elegido y la pantalla lo muestra", not Partida.esta_equipado(VELOCIDAD)
			and _dice(pantalla, VELOCIDAD) == "Sin usar" and not _marca(pantalla, VELOCIDAD).encendida
			and pantalla.detalle.accion.text == "Poner" and lleva.get_child_count() == 1 and pantalla.carga.usados == 2)
	pantalla.elegir(PRUEBA)
	pantalla.detalle.accion.pressed.emit()
	_caso("con 1 libre el boton pone el de costo 1 y la carga se llena", Partida.esta_equipado(PRUEBA)
			and pantalla.carga.usados == Partida.carga_maxima and pantalla.detalle.accion.text == "Quitar")
	pantalla.elegir(PESADO)
	_caso("lleno, el pesado no ofrece boton ni se pone", not pantalla.detalle.accion.visible
			and pantalla.rotulo(PESADO).is_empty() and not pantalla.alternar(PESADO))
	_caso("fuera del catalogo tampoco se pone sentado", pantalla.rotulo(&"fuera_del_catalogo").is_empty()
			and not pantalla.alternar(&"fuera_del_catalogo"))
	pantalla.ocultar_de_marco()

	# Mas de los que caben a lo alto: la lista se desplaza, el foco lleva el ultimo a la vista y el indicador de mas
	# abajo se apaga al llegar al final.
	for i: int in range(MUCHOS):
		Partida.amuletos_tenidos.append(StringName("extra_%d" % i))
	pantalla.mostrar_en_marco()
	await _esperar_cuadros(3)
	var desplazable: ScrollContainer = pantalla.get_node(^"Fondo/Cuerpo/Lista/Desplazable") as ScrollContainer
	var mas: Control = pantalla.get_node(^"Fondo/Cuerpo/Lista/MasAbajo") as Control
	var ultimo: Button = pantalla.botones[Partida.amuletos_tenidos[Partida.amuletos_tenidos.size() - 1]]
	var vista: Rect2 = desplazable.get_global_rect()
	_caso("con muchos la lista no cabe, el ultimo empieza fuera de la vista y se avisa que hay mas",
			desplazable.get_v_scroll_bar().max_value > vista.size.y and not vista.encloses(ultimo.get_global_rect())
			and is_equal_approx(mas.modulate.a, 1.0))
	Tema.dar_foco(ultimo)
	await _esperar_cuadros(3)
	_caso("el ultimo con el foco queda dentro de la vista y el aviso se apaga", desplazable.scroll_vertical > 0
			and desplazable.get_global_rect().encloses(ultimo.get_global_rect()) and is_zero_approx(mas.modulate.a))
	pantalla.ocultar_de_marco()

	pantalla.free()
	jugador.free()
	get_tree().paused = false
	_restaurar_partida()
	# El objeto de una sala da su amuleto una vez y, ya tenido, no aparece.
	var objeto: ObjetoAmuleto = (load("res://nucleo/objeto_amuleto.tscn") as PackedScene).instantiate() as ObjetoAmuleto
	objeto.amuleto = &"amuleto_de_objeto"
	add_child(objeto)
	objeto._al_recoger(null)
	_caso("el objeto da su amuleto", Partida.amuletos_tenidos.has(&"amuleto_de_objeto"))
	var repetido: ObjetoAmuleto = objeto.duplicate() as ObjetoAmuleto
	add_child(repetido)
	_caso("ya tenido, el objeto no aparece", repetido.is_queued_for_deletion())
	objeto.free()
	Partida.amuletos_tenidos.erase(&"amuleto_de_objeto")
	_resumen()


func _etiqueta(pantalla: PantallaAmuletos, amuleto: StringName, ruta: NodePath) -> Label:
	return pantalla.botones[amuleto].get_node(^"Ficha").get_node(ruta) as Label


func _nombre_fila(pantalla: PantallaAmuletos, amuleto: StringName) -> String:
	return _etiqueta(pantalla, amuleto, ^"Textos/Nombre").text


func _dice(pantalla: PantallaAmuletos, amuleto: StringName) -> String:
	return _etiqueta(pantalla, amuleto, ^"Textos/Estado/Dice").text


func _costo(pantalla: PantallaAmuletos, amuleto: StringName) -> Circulos:
	return pantalla.botones[amuleto].get_node(^"Ficha/Textos/Estado/Costo") as Circulos


func _marca(pantalla: PantallaAmuletos, amuleto: StringName) -> MarcaUso:
	return pantalla.botones[amuleto].get_node(^"Ficha/Marca") as MarcaUso
