extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba Partida y la pagina Utiles: catalogo, posesion, los 4 cupos, avisos, autoguardado y cambio solo en el banco.
# Usa los utiles del catalogo y estados cargados para llenar los cupos sin modificar fichas compartidas.
# La pagina: vacia, elegir sin cambiar, el boton del detalle, los cupos de la mochila (elegir desde uno lleno), cupos
# llenos explicados y desplazamiento con foco; aisla y restaura el archivo de la partida.

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
	_caso("puesta no se pone otra vez aunque queden cupos", Partida.utiles_equipados.size() == 1
			and Partida.MAX_UTILES > 1 and not Partida.equipar_util(BRUJULA) and cambios[0] == 1
			and Partida.autoguardados == antes + 1)
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

	# Un estado cargado con los cupos ocupados por otros ids permite medir el limite con una candidata valida.
	var libre: Dictionary = Partida.a_diccionario()
	var lleno: Dictionary = libre.duplicate(true)
	lleno["utiles_equipados"] = ["ocupante_1", "ocupante_2", "ocupante_3", "ocupante_4"]
	Partida.desde_diccionario(lleno)
	antes = Partida.autoguardados
	var avisos: int = cambios[0]
	_caso("los cupos ocupados impiden poner una candidata valida", Partida.MAX_UTILES == 4
			and not Partida.puede_equipar_util(BRUJULA) and not Partida.equipar_util(BRUJULA)
			and cambios[0] == avisos and Partida.autoguardados == antes)
	Partida.desde_diccionario(libre)

	# Los cinco utiles del juego: caben cuatro, el quinto no entra, y los cuatro se guardan y se leen en orden.
	_caso("el catalogo del juego tiene los cinco utiles de Utiles, cada uno con nombre e icono", _catalogo_completo())
	for util: StringName in Utiles.TODOS:
		Partida.obtener_util(util)
	var puestos: int = 0
	for i: int in range(Partida.MAX_UTILES):
		if Partida.equipar_util(Utiles.TODOS[i]):
			puestos += 1
	antes = Partida.autoguardados
	avisos = cambios[0]
	var quinto: StringName = Utiles.TODOS[Partida.MAX_UTILES]
	_caso("caben cuatro utiles y el quinto no entra", puestos == 4 and Partida.utiles_equipados.size() == 4
			and not Partida.puede_equipar_util(quinto) and not Partida.equipar_util(quinto)
			and not Partida.util_equipado(quinto) and cambios[0] == avisos and Partida.autoguardados == antes)
	var cuatro: Array[StringName] = Partida.utiles_equipados.duplicate()
	var leida: Guardado.Resultado = Guardado.cargar(RUTA)
	Partida.desde_diccionario(libre)
	if leida.estado == Guardado.Estado.VALIDA:
		Partida.desde_diccionario(leida.partida)
	_caso("los cuatro puestos se guardan y se leen en el mismo orden", leida.estado == Guardado.Estado.VALIDA
			and Partida.utiles_equipados == cuatro)
	Partida.desequipar_util(Utiles.TODOS[0])
	_caso("quitar uno deja entrar al quinto", Partida.equipar_util(quinto) and Partida.utiles_equipados.size() == 4)
	var de_mas: Dictionary = Partida.a_diccionario()
	de_mas["utiles_equipados"] = ["brujula", "gato_suerte", "log_errores", "cartera_emergencia", "suela_antiderrapante"]
	Partida.desde_diccionario(de_mas)
	_caso("un archivo con cinco puestos se lee con los primeros cuatro", Partida.utiles_equipados.size() == 4
			and not Partida.util_equipado(quinto))
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
	var tenidos: Array[StringName] = Partida.utiles_tenidos.duplicate()
	Partida.utiles_tenidos.clear()
	pantalla.mostrar_en_marco()
	_caso("sin utiles lo dice y no muestra la mochila", pantalla.vacio.visible
			and not (pantalla.get_node(^"Fondo/Cuerpo") as Control).visible and pantalla.botones.is_empty())
	Partida.utiles_tenidos.assign(tenidos)
	pantalla.mostrar_en_marco()
	_caso("lista lo tenido incluso sin ficha, con nombre legible", pantalla.visible and pantalla.botones.size() == 2
			and _texto(pantalla, DESCONOCIDO, ^"Textos/Nombre") == "Fuera Del Catalogo")
	_caso("al abrir elige la brujula y el detalle usa su ficha", ficha != null and pantalla.elegido == BRUJULA
			and pantalla.botones[BRUJULA].button_pressed and pantalla.detalle.nombre.text == ficha.nombre
			and pantalla.detalle.texto.text == ficha.descripcion and _texto(pantalla, BRUJULA, ^"Textos/Estado/Dice") == "Sin usar")
	_caso("de pie pide sentarse, sin boton, y no cambia", pantalla.detalle.motivo.text == "Siéntate en un banco para cambiarlos."
			and not pantalla.detalle.accion.visible and not pantalla.alternar(BRUJULA) and not Partida.util_equipado(BRUJULA))
	var icono: Node = pantalla.botones[BRUJULA].get_node(^"Ficha/Icono")
	_caso("usa textura o brujula de gis segun la ficha", ficha != null
			and ((ficha.icono != null and icono is TextureRect and (icono as TextureRect).texture == ficha.icono)
			or (ficha.icono == null and icono is IconoArticulo and (icono as IconoArticulo).forma == IconoArticulo.Forma.UTIL)))
	_caso("los cuatro cupos empiezan vacios, sin foco ni toque, y la cuenta en 0 de 4", pantalla.cupos.size() == 4
			and pantalla.cupos[0].has_node(^"Vacio") and pantalla.cupos[0].focus_mode == Control.FOCUS_NONE
			and pantalla.cupos[3].mouse_filter == Control.MOUSE_FILTER_IGNORE
			and pantalla.cuenta.usados == 0 and pantalla.cuenta.total == 4)
	jugador.descansando = true
	pantalla.mostrar_en_marco()
	pantalla.botones[BRUJULA].pressed.emit()
	_caso("sentado, tocar la fila solo la elige y lleva el foco a Poner", not Partida.util_equipado(BRUJULA)
			and pantalla.detalle.accion.has_focus() and pantalla.detalle.accion.text == "Poner")
	pantalla.detalle.accion.pressed.emit()
	_caso("el boton pone la brujula en el primer cupo, con su marca y la cuenta", Partida.util_equipado(BRUJULA)
			and pantalla.cupos[0].has_node(^"Icono") and pantalla.cupos[0].focus_mode == Control.FOCUS_ALL
			and pantalla.cuenta.usados == 1 and (pantalla.botones[BRUJULA].get_node(^"Ficha/Marca") as MarcaUso).encendida
			and _texto(pantalla, BRUJULA, ^"Textos/Estado/Dice") == "En un cupo" and pantalla.detalle.accion.text == "Quitar")
	pantalla.elegir(DESCONOCIDO)
	pantalla.cupos[0].pressed.emit()
	_caso("tocar un cupo lleno elige su util", pantalla.elegido == BRUJULA and pantalla.cupos[0].button_pressed
			and pantalla.detalle.motivo.text == "En un cupo")
	pantalla.cupos[1].pressed.emit()
	_caso("tocar un cupo vacio no elige nada", pantalla.elegido == BRUJULA)
	pantalla.detalle.accion.pressed.emit()
	_caso("desde el cupo, el boton quita la brujula y el cupo queda vacio", not Partida.util_equipado(BRUJULA)
			and pantalla.cupos[0].has_node(^"Vacio") and pantalla.cuenta.usados == 0)
	Partida.desde_diccionario(lleno)
	pantalla.mostrar_en_marco()
	pantalla.elegir(BRUJULA)
	_caso("con los cupos llenos explica que hay que quitar uno, sin boton y apagada",
			pantalla.detalle.motivo.text == "Cupos llenos: toca un cupo de la mochila y quítalo primero."
			and not pantalla.detalle.accion.visible and not pantalla.alternar(BRUJULA) and not Partida.util_equipado(BRUJULA)
			and (pantalla.botones[BRUJULA].get_node(^"Ficha/Textos/Nombre") as Label).theme_type_variation == Tema.TEXTO_FICHA_APAGADO
			and pantalla.cuenta.usados == 4)
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
	var desplazable: ScrollContainer = pantalla.get_node(^"Fondo/Cuerpo/Lista/Desplazable") as ScrollContainer
	var ultimo: Button = pantalla.botones[&"extra_11"]
	_caso("la lista larga no cabe en la vista", desplazable.follow_focus
			and not desplazable.get_global_rect().encloses(ultimo.get_global_rect()))
	Tema.dar_foco(ultimo)
	await _esperar_cuadros(3)
	_caso("el foco desplaza el ultimo a la vista y el detalle sin ficha queda sin texto", desplazable.scroll_vertical > 0
			and desplazable.get_global_rect().encloses(ultimo.get_global_rect()) and pantalla.detalle.texto.text.is_empty())
	pantalla.ocultar_de_marco()
	_caso("ocultar cierra la pagina", not pantalla.visible and not pantalla.abierta)
	pantalla.free()
	jugador.free()
	Eventos.equipo_cambiado.disconnect(al_cambiar)
	_restaurar_partida()
	_resumen()


func _texto(pantalla: PantallaUtiles, util: StringName, ruta: NodePath) -> String:
	return (pantalla.botones[util].get_node(^"Ficha").get_node(ruta) as Label).text


# Los ids del catalogo del juego son los de Utiles, en su orden, y cada ficha trae nombre e icono.
func _catalogo_completo() -> bool:
	var catalogo: Resource = Cargar.si_existe(CatalogoEquipo.RUTA_JUEGO)
	var lista: Variant = catalogo.get(&"utiles") if catalogo != null else null
	if not lista is Array:
		return false
	var ids: Array[StringName] = []
	for ficha: FichaUtil in lista as Array:
		if ficha == null or ficha.nombre.is_empty() or ficha.icono == null:
			return false
		ids.append(ficha.id)
	return ids == Utiles.TODOS
