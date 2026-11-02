extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de los amuletos: Partida pone y quita solo lo que esta en el catalogo, se tiene y cabe en la carga, avisa y
# autoguarda, y suma sus efectos; la pagina Amuletos del marco de menus deja cambiarlos solo sentado en un banco, de
# pie solo los muestra y con muchos se desplaza con el foco. Usa el catalogo de pruebas (equipo_prueba.tres: prueba
# y velocidad cuestan 1, escudo y botin 2). Deja casos y fallos para amuletos.guion e imprime el resumen.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const RUTA: String = "user://prueba_amuletos.json"
# Amuletos de mas para el caso de la lista que no cabe: 5 + 12 filas de 108 px no caben en 720 px.
const MUCHOS: int = 12
const PRUEBA: StringName = &"amuleto_prueba"
const VELOCIDAD: StringName = &"amuleto_velocidad"
const ESCUDO: StringName = &"amuleto_escudo"
const BOTIN: StringName = &"amuleto_botin"


func _ready() -> void:
	_aislar_partida(RUTA)

	# Partida.
	var cambios: Array[int] = [0]
	Eventos.equipo_cambiado.connect(func() -> void: cambios[0] += 1)
	_caso("sin tenerlo no se pone", not Partida.puede_equipar(PRUEBA) and not Partida.equipar(PRUEBA)
			and Partida.amuletos_equipados.is_empty())
	Partida.amuletos_tenidos.append_array([PRUEBA, VELOCIDAD, ESCUDO, BOTIN, &"fuera_del_catalogo"] as Array[StringName])
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
	_caso("con 1 libre cabe uno de costo 1 y no uno de costo 2", Partida.equipar(VELOCIDAD) and not Partida.equipar(BOTIN))
	var efectos: FichaAmuleto = Partida.efectos_amuletos()
	_caso("los efectos suman los puestos", is_equal_approx(efectos.velocidad_factor, 1.25)
			and efectos.invulnerable_extra == 30 and efectos.inspiracion_extra == 0
			and is_equal_approx(efectos.botin_factor, 1.0))
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
	pantalla.mostrar_en_marco()
	_caso("mostrarla lista los que se tienen", pantalla.visible and pantalla.botones.size() == 5)
	var texto_escudo: Label = pantalla.botones[ESCUDO].get_node(^"Ficha/Texto") as Label
	_caso("la fila muestra el nombre de la ficha y su costo", texto_escudo.text == "Chamarra de prueba\ncosto 2 · puesto")
	var fuera: Button = pantalla.botones[&"fuera_del_catalogo"]
	var texto_fuera: Label = fuera.get_node(^"Ficha/Texto") as Label
	_caso("fuera del catalogo muestra su id y no responde", texto_fuera.text.contains("fuera_del_catalogo")
			and fuera.disabled and not pantalla.alternar(&"fuera_del_catalogo"))
	var descripcion: Label = pantalla.get_node(^"Fondo/Descripcion") as Label
	Tema.dar_foco(pantalla.botones[ESCUDO])
	Tema.dar_foco(pantalla.botones[PRUEBA])
	var descripcion_anterior: String = descripcion.text
	Tema.dar_foco(pantalla.botones[VELOCIDAD])
	_caso("la descripcion cambia al enfocar otra fila", descripcion_anterior == CatalogoEquipo.amuleto(PRUEBA).descripcion
			and descripcion.text == CatalogoEquipo.amuleto(VELOCIDAD).descripcion and descripcion.text != descripcion_anterior)
	var icono: IconoArticulo = pantalla.botones[PRUEBA].get_node(^"Ficha/Icono") as IconoArticulo
	_caso("sin icono en la ficha usa el amuleto de gis", CatalogoEquipo.amuleto(PRUEBA).icono == null
			and icono != null and icono.forma == IconoArticulo.Forma.AMULETO)
	var toque: InputEventScreenTouch = InputEventScreenTouch.new()
	toque.pressed = true
	pantalla.botones[ESCUDO].gui_input.emit(toque)
	_caso("tocar una fila deshabilitada permite consultar su descripcion", pantalla.botones[ESCUDO].disabled
			and descripcion.text == CatalogoEquipo.amuleto(ESCUDO).descripcion)
	_caso("de pie se ven pero no se cambian", pantalla.botones[PRUEBA].disabled and not pantalla.alternar(PRUEBA)
			and not Partida.esta_equipado(PRUEBA))
	pantalla.ocultar_de_marco()
	_caso("ocultarla la quita de la vista", not pantalla.visible and not pantalla.abierta)

	# Sentado, con escudo y velocidad puestos (carga 3 de 3).
	jugador.descansando = true
	pantalla.mostrar_en_marco()
	_caso("sentado, el puesto responde y el que no cabe no", not pantalla.botones[VELOCIDAD].disabled
			and pantalla.botones[PRUEBA].disabled)
	_caso("sentado se quita uno puesto", pantalla.alternar(VELOCIDAD) and not Partida.esta_equipado(VELOCIDAD)
			and (pantalla.botones[VELOCIDAD].get_node(^"Ficha/Texto") as Label).text.ends_with("guardado"))
	pantalla.alternar(PRUEBA)
	_caso("sentado se llena la carga y el que no cabe no responde", Partida.carga_usada() == Partida.carga_maxima
			and pantalla.botones[BOTIN].disabled and not pantalla.alternar(BOTIN))
	_caso("fuera del catalogo tampoco responde sentado", pantalla.botones[&"fuera_del_catalogo"].disabled
			and not pantalla.alternar(&"fuera_del_catalogo"))
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
