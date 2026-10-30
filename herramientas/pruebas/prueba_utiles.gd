extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba Partida y la pagina Utiles: catalogo, posesion, ranura, avisos, autoguardado y cambio solo en el banco.
# Usa la brujula del catalogo y estados cargados para ocupar la unica ranura sin modificar fichas compartidas.
# Comprueba nombres, descripcion, icono y desplazamiento con foco; aisla y restaura el archivo de la partida.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const RUTA: String = "user://prueba_utiles.json"
const BRUJULA: StringName = &"brujula"
const DESCONOCIDO: StringName = &"fuera_del_catalogo"
const MUCHOS: int = 12


func _ready() -> void:
	_aislar_partida(RUTA)
	var cambios: Array[int] = [0]
	var al_cambiar: Callable = func() -> void: cambios[0] += 1
	Eventos.equipo_cambiado.connect(al_cambiar)
	var ficha: FichaUtil = CatalogoEquipo.util(BRUJULA)
	_caso("la brujula esta en el catalogo", ficha != null)
	_caso("sin tenerla no se pone", not Partida.puede_equipar_util(BRUJULA) and not Partida.equipar_util(BRUJULA))
	var antes: int = Partida.autoguardados
	Partida.obtener_util(BRUJULA)
	_caso("obtener autoguarda y no cambia el equipo", Partida.utiles_tenidos.has(BRUJULA)
			and Partida.autoguardados == antes + 1 and cambios[0] == 0)
	Partida.obtener_util(BRUJULA)
	_caso("obtener no repite ni autoguarda dos veces", Partida.utiles_tenidos.size() == 1 and Partida.autoguardados == antes + 1)
	Partida.obtener_util(DESCONOCIDO)
	antes = Partida.autoguardados
	_caso("fuera del catalogo no se pone aunque se tenga", not Partida.equipar_util(DESCONOCIDO)
			and cambios[0] == 0 and Partida.autoguardados == antes)
	_caso("equipar avisa y autoguarda sin gastar carga", Partida.equipar_util(BRUJULA)
			and Partida.util_equipado(BRUJULA) and cambios[0] == 1 and Partida.autoguardados == antes + 1
			and Partida.carga_usada() == 0 and Partida.carga_maxima == Partida.CARGA_INICIAL)
	_caso("no se repite con la ranura llena", Partida.utiles_equipados.size() == Partida.MAX_UTILES
			and not Partida.equipar_util(BRUJULA) and cambios[0] == 1 and Partida.autoguardados == antes + 1)
	var guardada: Guardado.Resultado = Guardado.cargar(RUTA)
	_caso("el autoguardado contiene el util puesto", guardada.estado == Guardado.Estado.VALIDA
			and (guardada.partida["utiles_equipados"] as Array).has(String(BRUJULA)))
	antes = Partida.autoguardados
	_caso("quitar avisa y autoguarda", Partida.desequipar_util(BRUJULA) and not Partida.util_equipado(BRUJULA)
			and cambios[0] == 2 and Partida.autoguardados == antes + 1)
	_caso("quitar otra vez no cambia ni guarda", not Partida.desequipar_util(BRUJULA)
			and cambios[0] == 2 and Partida.autoguardados == antes + 1)
	if guardada.estado == Guardado.Estado.VALIDA:
		Partida.desde_diccionario(guardada.partida)
	_caso("cargar recupera los utiles y avisa", Partida.util_equipado(BRUJULA) and cambios[0] == 3)
	Partida.desequipar_util(BRUJULA)

	# Solo hay una brujula: un estado cargado con otra ranura ocupada permite medir el limite con una candidata valida.
	var libre: Dictionary = Partida.a_diccionario()
	var lleno: Dictionary = libre.duplicate(true)
	lleno["utiles_equipados"] = ["ocupante_prueba"]
	Partida.desde_diccionario(lleno)
	antes = Partida.autoguardados
	var avisos: int = cambios[0]
	_caso("una ranura ocupada impide poner una candidata valida", not Partida.puede_equipar_util(BRUJULA)
			and not Partida.equipar_util(BRUJULA) and cambios[0] == avisos and Partida.autoguardados == antes)
	Partida.desde_diccionario(libre)

	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.name = "Jugador"
	jugador.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(jugador)
	var pantalla: PantallaUtiles = PantallaUtiles.new()
	pantalla.name = "Utiles"
	add_child(pantalla)
	_caso("es la pagina Utiles del marco", pantalla.id_pagina() == &"utiles"
			and pantalla.titulo_pagina() == "Útiles" and pantalla.is_in_group(MarcoMenus.GRUPO_PAGINAS))
	pantalla.mostrar_en_marco()
	_caso("lista lo tenido incluso sin ficha", pantalla.visible and pantalla.botones.size() == 2
			and pantalla.botones[DESCONOCIDO].text == "Fuera Del Catalogo: guardado")
	_caso("de pie no responde", pantalla.botones[BRUJULA].disabled and not pantalla.alternar(BRUJULA)
			and not Partida.util_equipado(BRUJULA))
	var descripcion: Label = pantalla.find_child("Descripcion", true, false) as Label
	_caso("usa el nombre y descripcion de la ficha", ficha != null
			and pantalla.botones[BRUJULA].text == ficha.nombre + ": guardado" and descripcion.text == ficha.descripcion)
	var icono: Node = pantalla.botones[BRUJULA].get_parent().get_node(^"Icono")
	_caso("usa textura o brujula de gis segun la ficha", ficha != null
			and ((ficha.icono != null and icono is TextureRect and (icono as TextureRect).texture == ficha.icono)
			or (ficha.icono == null and icono is IconoArticulo and (icono as IconoArticulo).forma == IconoArticulo.Forma.UTIL)))
	jugador.descansando = true
	pantalla.mostrar_en_marco()
	_caso("sentado pone la brujula que consulta el mapa", not pantalla.botones[BRUJULA].disabled
			and pantalla.alternar(BRUJULA) and Partida.util_equipado(BRUJULA)
			and pantalla.botones[BRUJULA].text.ends_with("puesto"))
	_caso("sentado quita la brujula", pantalla.alternar(BRUJULA) and not Partida.util_equipado(BRUJULA)
			and pantalla.botones[BRUJULA].text.ends_with("guardado"))
	Partida.desde_diccionario(lleno)
	pantalla.mostrar_en_marco()
	_caso("con la ranura llena la pagina no pone la brujula", pantalla.botones[BRUJULA].disabled
			and not pantalla.alternar(BRUJULA) and not Partida.util_equipado(BRUJULA))
	Partida.desde_diccionario(libre)
	var recompensa: Recompensa = Recompensa.new()
	recompensa.tipo = Recompensa.Tipo.UTIL
	var articulo: ArticuloTienda = ArticuloTienda.new()
	articulo.recompensa = recompensa
	_caso("la recompensa UTIL tiene icono UTIL", IconoArticulo.forma_de(articulo) == IconoArticulo.Forma.UTIL)

	for i: int in range(MUCHOS):
		Partida.obtener_util(StringName("extra_%d" % i))
	pantalla.mostrar_en_marco()
	await _esperar_cuadros(3)
	var desplazable: ScrollContainer = pantalla.get_node(^"Fondo/Desplazable") as ScrollContainer
	var ultimo: Button = pantalla.botones[&"extra_11"]
	_caso("la lista larga no cabe en la vista", desplazable.follow_focus
			and not desplazable.get_global_rect().encloses(ultimo.get_global_rect()))
	Tema.dar_foco(ultimo)
	await _esperar_cuadros(3)
	_caso("el foco desplaza el ultimo a la vista y limpia la descripcion sin ficha", desplazable.scroll_vertical > 0
			and desplazable.get_global_rect().encloses(ultimo.get_global_rect()) and descripcion.text.is_empty())
	pantalla.ocultar_de_marco()
	_caso("ocultar cierra la pagina", not pantalla.visible and not pantalla.abierta)
	pantalla.free()
	jugador.free()
	Eventos.equipo_cambiado.disconnect(al_cambiar)
	_restaurar_partida()
	_resumen()


func _esperar_cuadros(cuadros: int) -> void:
	for i: int in range(cuadros):
		await get_tree().process_frame
