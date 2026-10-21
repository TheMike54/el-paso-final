extends "res://herramientas/validar.gd"
# Prueba de las reglas del validador sobre nodos y entradas armados en memoria: por regla, un caso roto que da su
# FALLO (por texto parcial) y uno sano que no da ninguno. Hereda de validar.gd y reemplaza su _ready sin llamar a
# super(), asi no recorre el proyecto ni sale; no hereda de prueba_base.gd y repite aqui su cuenta y su resumen.

const NOMBRE: String = "validador"
## Ruta inventada de una sala de una zona de prueba con id prueba_90 (no se carga: solo se pasa a la regla).
const RUTA_SALA: String = "res://herramientas/salas/zonas/prueba/prueba_90.tscn"
const RUTA: String = "res://prueba_en_memoria.tscn"

var casos: int = 0
var fallos: int = 0


func _ready() -> void:
	_probar_entradas()
	_probar_id_recordado()
	_probar_peligros()
	_probar_avisos()
	_probar_tiendas()
	_probar_rutas_de_secretos()
	_probar_habilidades()
	_probar_sala()
	_resumen()


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO %s: %s" % [NOMBRE, nombre])


func _resumen() -> void:
	print("PRUEBAS %s casos=%d fallos=%d" % [NOMBRE, casos, fallos])


# Corre una regla con la lista de fallos y las salas vacias y devuelve lo que anoto.
func _correr(regla: Callable) -> PackedStringArray:
	_fallos.clear()
	_salas.clear()
	regla.call()
	var anotados: PackedStringArray = _fallos.duplicate()
	_fallos.clear()
	_salas.clear()
	return anotados


# Caso roto: algun fallo anotado contiene texto.
func _da(nombre: String, anotados: PackedStringArray, texto: String) -> void:
	var bien: bool = false
	for fallo: String in anotados:
		if fallo.contains(texto):
			bien = true
	_caso(nombre if bien else "%s; obtenido: [%s]" % [nombre, " | ".join(anotados)], bien)


# Caso sano: ningun fallo.
func _sin_fallos(nombre: String, anotados: PackedStringArray) -> void:
	var bien: bool = anotados.is_empty()
	_caso(nombre if bien else "%s; obtenido: [%s]" % [nombre, " | ".join(anotados)], bien)


func _agregar(padre: Node, hijo: Node, nombre: String) -> Node:
	hijo.name = nombre
	padre.add_child(hijo)
	return hijo


func _entrada(id: String, comprobacion: String, pasa: Variant) -> Dictionary:
	return {"id": id, "que": "algo", "comprobacion": comprobacion, "pasa": pasa}


func _probar_entradas() -> void:
	var ids: Array[String] = []
	_caso("entrada: una lista no es un objeto", _fallo_de_entrada([], ids) == "no es un objeto")
	var sin_que: Dictionary = _entrada("a", "manual: x", false)
	sin_que.erase("que")
	_caso("entrada: sin 'que' falla", _fallo_de_entrada(sin_que, ids).contains("falta el texto 'que'"))
	_caso("entrada: 'pasa' de texto falla", _fallo_de_entrada(_entrada("b", "manual: x", "si"), ids).contains("'pasa' debe ser true o false"))
	ids.clear()
	var sana: String = _fallo_de_entrada(_entrada("c", "herramientas/validar.gd", true), ids)
	_caso("entrada: sana con pasa true y archivo que existe no falla", sana.is_empty())
	_caso("entrada: id repetido falla", _fallo_de_entrada(_entrada("c", "manual: x", false), ids).contains("id repetido 'c'"))
	var falta: String = _fallo_de_entrada(_entrada("d", "herramientas/validar.gd; herramientas/no_existe.guion", true), ids)
	_caso("entrada: pasa true con una ruta que no existe falla", falta.contains("no existe 'herramientas/no_existe.guion'"))
	_caso("entrada: pasa true con comprobacion manual no falla", _fallo_de_entrada(_entrada("e", "manual: mirar", true), ids).is_empty())
	_probar_esperado(ids)


# Un .guion con su .esperado no falla; sin el .esperado, si. Arma los dos en una carpeta temporal de user:// y la
# borra al terminar.
func _probar_esperado(ids: Array[String]) -> void:
	var raiz: String = "user://prueba_validador_esperado/"
	DirAccess.make_dir_recursive_absolute(raiz)
	# Sin nombres reservados de Windows (con, aux, nul...): FileAccess no los crea.
	var nombres: PackedStringArray = ["par.guion", "par.esperado", "suelto.guion"]
	for nombre: String in nombres:
		var archivo: FileAccess = FileAccess.open(raiz + nombre, FileAccess.WRITE)
		if archivo != null:
			archivo.close()
	var par: String = _fallo_de_entrada(_entrada("f", "par.guion", true), ids, raiz)
	_caso("entrada: pasa true con un .guion y su .esperado no falla" + ("" if par.is_empty() else "; obtenido: " + par),
		par.is_empty())
	var suelto: String = _fallo_de_entrada(_entrada("g", "par.guion; suelto.guion", true), ids, raiz)
	var bien: bool = suelto == "pasa es true y falta el .esperado de 'suelto.guion'"
	_caso("entrada: pasa true con un .guion sin .esperado falla" + ("" if bien else "; obtenido: '%s'" % suelto), bien)
	for nombre: String in nombres:
		DirAccess.remove_absolute(raiz + nombre)
	DirAccess.remove_absolute(raiz)


func _probar_id_recordado() -> void:
	var suelo: SueloFragil = SueloFragil.new()
	_caso("id recordado: suelo fragil sin id da ?", _id_recordado(suelo) == "?")
	suelo.free()
	var palanca: Palanca = Palanca.new()
	palanca.id = "palanca_a"
	_caso("id recordado: palanca con id da su id", _id_recordado(palanca) == "palanca_a")
	palanca.free()
	var tienda: Tienda = Tienda.new()
	_caso("id recordado: tienda sin id da ?", _id_recordado(tienda) == "?")
	tienda.free()
	var aviso: AvisoAccion = AvisoAccion.new()
	_caso("id recordado: aviso sin id da vacio (opcional)", _id_recordado(aviso) == "")
	aviso.free()
	var otro: Node2D = Node2D.new()
	_caso("id recordado: un nodo que no se recuerda da vacio", _id_recordado(otro) == "")
	otro.free()


func _probar_peligros() -> void:
	var raiz: Node2D = Node2D.new()
	var vaiven: Node = _agregar(raiz, Vaiven.new(), "Vaiven")
	var sierra: DanoContacto = _agregar(vaiven, DanoContacto.new(), "Sierra") as DanoContacto
	sierra.peligro = true
	_da("peligros: peligro dentro de un Vaiven falla", _correr(_revisar_peligros.bind(RUTA, raiz)), "Sierra se mueve con Vaiven")
	sierra.peligro = false
	_sin_fallos("peligros: golpe (no peligro) dentro de un Vaiven no falla", _correr(_revisar_peligros.bind(RUTA, raiz)))
	var enemigo: Node = _agregar(raiz, Enemigo.new(), "Enemigo")
	var grupo: Node = _agregar(enemigo, Node2D.new(), "Grupo")
	var espinas: DanoContacto = _agregar(grupo, DanoContacto.new(), "Espinas") as DanoContacto
	espinas.peligro = true
	_da("peligros: peligro dentro de un enemigo, a dos niveles, falla", _correr(_revisar_peligros.bind(RUTA, raiz)), "Espinas se mueve con Enemigo")
	espinas.peligro = false
	var pinchos: DanoContacto = _agregar(raiz, DanoContacto.new(), "Pinchos") as DanoContacto
	pinchos.peligro = true
	_sin_fallos("peligros: peligro fijo no falla", _correr(_revisar_peligros.bind(RUTA, raiz)))
	raiz.free()


func _aviso(padre: Node, nombre: String, id: String, acciones: Array[StringName]) -> AvisoAccion:
	var aviso: AvisoAccion = _agregar(padre, AvisoAccion.new(), nombre) as AvisoAccion
	aviso.id = id
	aviso.acciones.assign(acciones)
	return aviso


func _probar_avisos() -> void:
	var raiz: Node2D = Node2D.new()
	_aviso(raiz, "Vacio", "", [])
	_da("avisos: sin acciones falla", _correr(_revisar_avisos.bind(RUTA, raiz)), "el aviso Vacio ensena 0 acciones")
	raiz.free()
	raiz = Node2D.new()
	_aviso(raiz, "Tres", "", [&"saltar", &"atacar", &"curar"])
	_da("avisos: tres acciones falla", _correr(_revisar_avisos.bind(RUTA, raiz)), "el aviso Tres ensena 3 acciones")
	raiz.free()
	raiz = Node2D.new()
	_aviso(raiz, "Mal", "", [&"accion_inexistente"])
	_da("avisos: accion fuera del InputMap falla", _correr(_revisar_avisos.bind(RUTA, raiz)), "'accion_inexistente', que no esta en el InputMap")
	raiz.free()
	raiz = Node2D.new()
	_aviso(raiz, "Uno", "aviso_a", [&"saltar"])
	_aviso(raiz, "Dos", "aviso_a", [&"atacar"])
	_da("avisos: id repetido falla", _correr(_revisar_avisos.bind(RUTA, raiz)), "el aviso Dos repite el id 'aviso_a'")
	raiz.free()
	raiz = Node2D.new()
	_aviso(raiz, "Reservado", Partida.PREFIJO_COLECCIONABLE + "_x", [&"saltar"])
	_da("avisos: id con prefijo de coleccionable falla", _correr(_revisar_avisos.bind(RUTA, raiz)), "el aviso Reservado usa un id reservado")
	raiz.free()
	var sala: Sala = Sala.new()
	sala.botones_por_ensenar.assign([&"mover_izquierda"])
	_da("avisos: boton por ensenar que no es de la pantalla falla", _correr(_revisar_avisos.bind(RUTA, sala)), "'mover_izquierda', que no es un boton de la pantalla")
	sala.botones_por_ensenar.assign([&"impulso"])
	_aviso(sala, "Salto", "aviso_b", [&"saltar"])
	_da("avisos: boton por ensenar sin aviso que lo ensene falla", _correr(_revisar_avisos.bind(RUTA, sala)), "el boton 'impulso' esta por ensenar y ningun aviso de la sala lo ensena")
	sala.botones_por_ensenar.assign([&"saltar"])
	_sin_fallos("avisos: sala sana con su boton ensenado no falla", _correr(_revisar_avisos.bind(RUTA, sala)))
	sala.free()


func _articulo(id: String, precio: int, con_recompensa: bool) -> ArticuloTienda:
	var articulo: ArticuloTienda = ArticuloTienda.new()
	articulo.id = id
	articulo.precio = precio
	if con_recompensa:
		articulo.recompensa = Recompensa.new()
	return articulo


func _probar_tiendas() -> void:
	var tienda: Tienda = Tienda.new()
	tienda.name = "Puesto"
	_da("tiendas: tienda vacia falla", _correr(_revisar_tiendas.bind(RUTA, tienda)), "la tienda Puesto no vende nada")
	tienda.articulos.append(null)
	_da("tiendas: articulo vacio falla", _correr(_revisar_tiendas.bind(RUTA, tienda)), "la tienda Puesto tiene un articulo vacio")
	tienda.articulos.clear()
	tienda.articulos.append(_articulo("pan", 10, true))
	tienda.articulos.append(_articulo("pan", 10, true))
	_da("tiendas: id de articulo repetido falla", _correr(_revisar_tiendas.bind(RUTA, tienda)), "articulo 'pan' sin id o con id repetido")
	tienda.articulos.clear()
	tienda.articulos.append(_articulo("gratis", 0, true))
	_da("tiendas: precio 0 falla", _correr(_revisar_tiendas.bind(RUTA, tienda)), "el articulo gratis cuesta 0")
	tienda.articulos.clear()
	tienda.articulos.append(_articulo("humo", 5, false))
	_da("tiendas: articulo sin recompensa falla", _correr(_revisar_tiendas.bind(RUTA, tienda)), "el articulo humo no entrega nada")
	tienda.articulos.clear()
	tienda.articulos.append(_articulo("pan", 10, true))
	tienda.articulos.append(_articulo("leche", 20, true))
	_sin_fallos("tiendas: tienda sana no falla", _correr(_revisar_tiendas.bind(RUTA, tienda)))
	tienda.free()


func _probar_rutas_de_secretos() -> void:
	var raiz: Node2D = Node2D.new()
	var palanca: Palanca = _agregar(raiz, Palanca.new(), "Palanca") as Palanca
	_agregar(raiz, Node2D.new(), "Adorno")
	_agregar(raiz, Porton.new(), "Porton")
	palanca.portones.append(^"../Adorno")
	_da("secretos: palanca que apunta a algo que no es Porton falla", _correr(_revisar_rutas_de_secretos.bind(RUTA, palanca)), "la palanca Palanca abre ../Adorno, que no es un Porton")
	palanca.portones.clear()
	palanca.portones.append(^"../Porton")
	_sin_fallos("secretos: palanca que apunta a un Porton no falla", _correr(_revisar_rutas_de_secretos.bind(RUTA, palanca)))
	var muro: MuroRompible = _agregar(raiz, MuroRompible.new(), "Muro") as MuroRompible
	_agregar(raiz, Node.new(), "Dato")
	_agregar(raiz, Sprite2D.new(), "Tapa")
	muro.tapas.append(^"../Dato")
	_da("secretos: muro con tapa que no es un dibujo falla", _correr(_revisar_rutas_de_secretos.bind(RUTA, muro)), "el muro Muro tapa con ../Dato, que no es un dibujo")
	muro.tapas.clear()
	muro.tapas.append(^"../Tapa")
	_sin_fallos("secretos: muro con tapa Sprite2D no falla", _correr(_revisar_rutas_de_secretos.bind(RUTA, muro)))
	raiz.free()


func _probar_habilidades() -> void:
	var raiz: Node2D = Node2D.new()
	var objeto: ObjetoHabilidad = _agregar(raiz, ObjetoHabilidad.new(), "Objeto") as ObjetoHabilidad
	objeto.habilidad = &"volar"
	_da("habilidades: objeto con una habilidad que no existe falla", _correr(_revisar_habilidades.bind(RUTA, raiz)), "Objeto: 'volar' no es una habilidad")
	objeto.habilidad = Habilidades.IMPULSO
	var tienda: Tienda = _agregar(raiz, Tienda.new(), "Puesto") as Tienda
	var articulo: ArticuloTienda = _articulo("pluma", 10, true)
	articulo.recompensa.tipo = Recompensa.Tipo.HABILIDAD
	articulo.recompensa.id = &"pluma_falsa"
	tienda.articulos.append(articulo)
	_da("habilidades: articulo que entrega una habilidad que no existe falla", _correr(_revisar_habilidades.bind(RUTA, raiz)), "Puesto: 'pluma_falsa' no es una habilidad")
	articulo.recompensa.id = Habilidades.PLUMA
	articulo.requisito = &"nada"
	_da("habilidades: requisito de articulo que no existe falla", _correr(_revisar_habilidades.bind(RUTA, raiz)), "Puesto: 'nada' no es una habilidad")
	articulo.requisito = Habilidades.DOBLE_SALTO
	_sin_fallos("habilidades: objeto y articulo con habilidades de TODAS no fallan", _correr(_revisar_habilidades.bind(RUTA, raiz)))
	raiz.free()
	var suelta: ObjetoHabilidad = ObjetoHabilidad.new()
	_sin_fallos("habilidades: la pieza suelta sin habilidad (raiz) no falla", _correr(_revisar_habilidades.bind(RUTA, suelta)))
	suelta.free()


# Sala sana de la zona de prueba: id igual al archivo, limites con area y Entrada dentro. Los hijos llevan owner: la
# regla busca los objetos recordados solo entre los nodos con owner, como los de una escena cargada.
func _sala_sana() -> Sala:
	var sala: Sala = Sala.new()
	sala.id = "prueba_90"
	var entrada: Node2D = Node2D.new()
	entrada.position = Vector2(100.0, 100.0)
	_hijo_de_sala(sala, entrada, "Entrada")
	return sala


func _hijo_de_sala(sala: Sala, hijo: Node, nombre: String) -> Node:
	_agregar(sala, hijo, nombre)
	hijo.owner = sala
	return hijo


func _suelo(sala: Sala, nombre: String, id: String) -> void:
	var suelo: SueloFragil = SueloFragil.new()
	suelo.id = id
	_hijo_de_sala(sala, suelo, nombre)


func _probar_sala() -> void:
	var sala: Sala = _sala_sana()
	_sin_fallos("sala: sala sana no falla", _correr(_revisar_sala.bind(RUTA_SALA, sala)))
	var otra: Node2D = Node2D.new()
	_da("sala: raiz que no es Sala falla", _correr(_revisar_sala.bind(RUTA_SALA, otra)), "la raiz no es una Sala")
	otra.free()
	sala.id = "prueba_91"
	_da("sala: id distinto del archivo falla", _correr(_revisar_sala.bind(RUTA_SALA, sala)), "id 'prueba_91': debe ser <zona>_<numero> e igual al archivo")
	sala.id = "prueba_90"
	_da("sala: sala fuera de la carpeta de su zona falla", _correr(_revisar_sala.bind("res://herramientas/salas/zonas/otra/prueba_90.tscn", sala)), "debe estar en la carpeta de su zona, prueba")
	sala.limites = Rect2(0.0, 0.0, 0.0, 720.0)
	_da("sala: limites sin area falla", _correr(_revisar_sala.bind(RUTA_SALA, sala)), "limites sin area")
	sala.limites = Rect2(0.0, 0.0, 1280.0, 720.0)
	(sala.get_node(^"Entrada") as Node2D).position = Vector2(2000.0, 100.0)
	_da("sala: Entrada fuera de limites falla", _correr(_revisar_sala.bind(RUTA_SALA, sala)), "falta Entrada o queda fuera de limites")
	(sala.get_node(^"Entrada") as Node2D).position = Vector2(100.0, 100.0)
	sala.habilidades_de_prueba.append(Habilidades.IMPULSO)
	_da("sala: habilidades_de_prueba en una sala del juego falla", _correr(_revisar_sala.bind("res://contenido/salas/prueba/prueba_90.tscn", sala)), "habilidades_de_prueba es solo para salas de prueba")
	sala.habilidades_de_prueba.clear()
	_suelo(sala, "SueloSinId", "")
	_da("sala: suelo fragil sin id falla", _correr(_revisar_sala.bind(RUTA_SALA, sala)), "SueloSinId se recuerda en la partida y necesita id")
	sala.free()
	sala = _sala_sana()
	var grupo: Node2D = _hijo_de_sala(sala, Node2D.new(), "Grupo") as Node2D
	var suelo: SueloFragil = SueloFragil.new()
	suelo.id = "suelo_a"
	_agregar(grupo, suelo, "SueloA")
	suelo.owner = sala
	_suelo(sala, "SueloB", "suelo_a")
	_da("sala: id recordado repetido (uno dentro de un grupo) falla", _correr(_revisar_sala.bind(RUTA_SALA, sala)), "id suelo_a repetido en la sala")
	(sala.get_node(^"SueloB") as SueloFragil).id = "suelo_b"
	var palanca: Palanca = Palanca.new()
	palanca.id = "palanca_a"
	palanca.portones.append(^"../Nada")
	_hijo_de_sala(sala, palanca, "Palanca")
	_da("sala: revisa las rutas de secretos de sus nodos", _correr(_revisar_sala.bind(RUTA_SALA, sala)), "la palanca Palanca abre ../Nada, que no es un Porton")
	palanca.portones.clear()
	_sin_fallos("sala: sala sana con suelos y palanca con id distinto no falla", _correr(_revisar_sala.bind(RUTA_SALA, sala)))
	sala.free()
