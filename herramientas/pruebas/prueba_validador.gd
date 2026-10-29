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
	_probar_recogibles()
	_probar_peligros()
	_probar_avisos()
	_probar_tiendas()
	_probar_muro()
	_probar_rutas_de_nodos()
	_probar_npc_animado()
	_probar_habilidades()
	_probar_sala()
	_probar_llegada_puertas()
	_probar_zonas_camara()
	_probar_uids()
	_probar_una_via()
	_probar_limites_origen()
	_probar_encimes()
	_probar_puertas_abajo()
	_probar_fondo_tapado()
	_probar_musica()
	_probar_halos()
	_probar_avisos_contenido()
	_probar_redibujo()
	_probar_imagenes_sin_uso()
	_probar_enemigos()
	_probar_salas_sin_guion()
	_resumen()


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO %s: %s" % [NOMBRE, nombre])


func _resumen() -> void:
	print("PRUEBAS %s casos=%d fallos=%d" % [NOMBRE, casos, fallos])


# Corre una regla con la lista de fallos, la de avisos y las salas vacias y devuelve los fallos que anoto.
func _correr(regla: Callable) -> PackedStringArray:
	_fallos.clear()
	_avisos.clear()
	_salas.clear()
	regla.call()
	var anotados: PackedStringArray = _fallos.duplicate()
	_fallos.clear()
	_avisos.clear()
	_salas.clear()
	return anotados


# Como _correr, pero devuelve los avisos; un fallo anotado tambien sale, marcado, para que el caso lo note.
func _correr_avisos(regla: Callable) -> PackedStringArray:
	_fallos.clear()
	_avisos.clear()
	regla.call()
	var anotados: PackedStringArray = _avisos.duplicate()
	for fallo: String in _fallos:
		anotados.append("FALLO " + fallo)
	_fallos.clear()
	_avisos.clear()
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
	_caso("id recordado: aviso sin id da vacio (que UNA_VEZ lo lleve lo exige la regla de avisos)", _id_recordado(aviso) == "")
	aviso.id = "aviso_a"
	aviso.modo = AvisoAccion.Modo.SIEMPRE
	_caso("id recordado: aviso SIEMPRE con id da su id", _id_recordado(aviso) == "aviso_a")
	aviso.modo = AvisoAccion.Modo.POR_VISITA
	_caso("id recordado: aviso POR_VISITA da vacio (no se recuerda)", _id_recordado(aviso) == "")
	aviso.free()
	var otro: Node2D = Node2D.new()
	_caso("id recordado: un nodo que no se recuerda da vacio", _id_recordado(otro) == "")
	otro.free()
	var monedas: MonedasSueltas = MonedasSueltas.new()
	_caso("id recordado: monedas sueltas sin id da ?", _id_recordado(monedas) == "?")
	monedas.id = "monedas_1"
	_caso("id recordado: monedas sueltas con id da su id", _id_recordado(monedas) == "monedas_1")
	monedas.free()
	var objeto: ObjetoHabilidad = ObjetoHabilidad.new()
	_caso("id recordado: el objeto de habilidad da vacio (lo recuerda la habilidad)", _id_recordado(objeto) == "")
	objeto.free()
	var mapa: ObjetoMapa = ObjetoMapa.new()
	_caso("id recordado: el objeto de mapa da vacio (lo recuerda la lista de mapas)", _id_recordado(mapa) == "")
	mapa.free()


# Recogibles en cualquier escena: el coleccionable con su prefijo, los demas sin un prefijo reservado.
func _probar_recogibles() -> void:
	var raiz: Node2D = Node2D.new()
	# Con su escena, como en el juego: el script toma el Arte de ella.
	var escena: PackedScene = load("res://nucleo/coleccionable.tscn") as PackedScene
	var coleccionable: Coleccionable = _agregar(raiz, escena.instantiate(), "Credencial") as Coleccionable
	coleccionable.id = "credencial"
	_da("recogibles: coleccionable sin el prefijo falla", _correr(_revisar_recogibles.bind(RUTA, raiz)), "el coleccionable Credencial debe tener un id que empiece con 'coleccionable'")
	coleccionable.id = "coleccionable_1"
	var monedas: MonedasSueltas = _agregar(raiz, MonedasSueltas.new(), "Monedas") as MonedasSueltas
	monedas.id = "coleccionable_2"
	_da("recogibles: monedas con el prefijo de coleccionable fallan", _correr(_revisar_recogibles.bind(RUTA, raiz)), "el recogible Monedas usa un id reservado: coleccionable_2")
	monedas.id = EntregaRecompensas.PREFIJO_ENTREGADO + "4"
	_da("recogibles: monedas con el prefijo de entrega fallan", _correr(_revisar_recogibles.bind(RUTA, raiz)), "el recogible Monedas usa un id reservado")
	monedas.id = "monedas"
	_agregar(raiz, ObjetoHabilidad.new(), "Objeto")
	_sin_fallos("recogibles: coleccionable, monedas y objeto de habilidad sanos no fallan", _correr(_revisar_recogibles.bind(RUTA, raiz)))
	raiz.free()


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
	var giro: Node = _agregar(raiz, Giro.new(), "Giro")
	var aspa: DanoContacto = _agregar(giro, DanoContacto.new(), "Aspa") as DanoContacto
	aspa.peligro = true
	_da("peligros: peligro dentro de un Giro suelto falla", _correr(_revisar_peligros.bind(RUTA, raiz)), "Aspa se mueve con Giro")
	aspa.peligro = false
	_sin_fallos("cuerpos moviles: un Vaiven y un Giro con areas dentro no fallan", _correr(_revisar_cuerpos_moviles.bind(RUTA, raiz)))
	var hija: Node = _agregar(vaiven, AnimatableBody2D.new(), "PlataformaHija")
	_da("cuerpos moviles: un cuerpo dentro de un Vaiven falla", _correr(_revisar_cuerpos_moviles.bind(RUTA, raiz)), "PlataformaHija esta dentro de Vaiven")
	hija.free()
	var plataforma: AnimatableBody2D = AnimatableBody2D.new()
	plataforma.set_script(Vaiven)
	_agregar(raiz, plataforma, "Plataforma")
	_sin_fallos("cuerpos moviles: el AnimatableBody2D que es el mismo Vaiven no falla", _correr(_revisar_cuerpos_moviles.bind(RUTA, raiz)))
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
	raiz = Node2D.new()
	_aviso(raiz, "Olvidado", "", [&"saltar"])
	_da("avisos: UNA_VEZ sin id falla", _correr(_revisar_avisos.bind(RUTA, raiz)), "el aviso Olvidado sale una vez en la partida y necesita id")
	raiz.free()
	raiz = Node2D.new()
	_aviso(raiz, "Visita", "aviso_v", [&"saltar"]).modo = AvisoAccion.Modo.POR_VISITA
	_da("avisos: POR_VISITA con id falla", _correr(_revisar_avisos.bind(RUTA, raiz)), "el aviso Visita sale en cada visita y no se recuerda: sin id")
	raiz.free()
	raiz = Node2D.new()
	_aviso(raiz, "Visita", "", [&"saltar"]).modo = AvisoAccion.Modo.POR_VISITA
	_aviso(raiz, "Siempre", "", [&"atacar"]).modo = AvisoAccion.Modo.SIEMPRE
	_aviso(raiz, "SiempreId", "aviso_s", [&"curar"]).modo = AvisoAccion.Modo.SIEMPRE
	_sin_fallos("avisos: POR_VISITA sin id y SIEMPRE con o sin id no fallan", _correr(_revisar_avisos.bind(RUTA, raiz)))
	raiz.free()


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


func _probar_muro() -> void:
	var raiz: Node2D = Node2D.new()
	var muro: MuroRompible = _agregar(raiz, MuroRompible.new(), "Muro") as MuroRompible
	var tapa: Sprite2D = _agregar(raiz, Sprite2D.new(), "Tapa") as Sprite2D
	var orilla: ColorRect = _agregar(raiz, ColorRect.new(), "Orilla") as ColorRect
	var dentro: Sprite2D = _agregar(muro, Sprite2D.new(), "Dibujo") as Sprite2D
	muro.tapas.append(dentro)
	_da("muro: muro que tapa con un dibujo suyo falla", _correr(_revisar_muro.bind(RUTA, muro)), "el muro Muro nombra a Dibujo, que esta dentro del muro")
	muro.tapas.clear()
	muro.tapas.append(tapa)
	muro.descubre.append(tapa)
	_da("muro: muro que tapa y descubre el mismo dibujo falla", _correr(_revisar_muro.bind(RUTA, muro)), "el muro Muro tapa y descubre a Tapa a la vez")
	muro.descubre.clear()
	var monedas: MonedasSueltas = _agregar(raiz, MonedasSueltas.new(), "Monedas") as MonedasSueltas
	muro.descubre.append(monedas)
	_da("muro: muro que descubre algo con fisica falla", _correr(_revisar_muro.bind(RUTA, muro)), "el muro Muro descubre a Monedas, que tiene fisica")
	muro.descubre.clear()
	var grupo: Node2D = _agregar(raiz, Node2D.new(), "Grupo") as Node2D
	_agregar(grupo, Area2D.new(), "Area")
	muro.descubre.append(grupo)
	_da("muro: muro que descubre un grupo con un area dentro falla", _correr(_revisar_muro.bind(RUTA, muro)), "el muro Muro descubre a Grupo, que tiene fisica")
	muro.descubre.clear()
	muro.descubre.append(orilla)
	_sin_fallos("muro: muro con tapa y descubre fuera de el, sin fisica, no falla", _correr(_revisar_muro.bind(RUTA, muro)))
	raiz.free()


# Escena escrita en user:// y cargada de ahi (un .tscn con rutas rotas no puede vivir en el repo: el validador lo
# recorreria): Muro guarda tapas y descubre y Luz, la imagen encendida de una LuzSala.
func _escena_con_rutas(tapas: String, descubre: String, encendida: String) -> PackedScene:
	var ruta: String = "user://prueba_validador_rutas.tscn"
	var texto: String = "\n".join(PackedStringArray([
		"[gd_scene format=3]",
		"",
		"[ext_resource type=\"Script\" path=\"res://nucleo/muro_rompible.gd\" id=\"1_muro\"]",
		"[ext_resource type=\"Script\" path=\"res://nucleo/luz_sala.gd\" id=\"2_luz\"]",
		"",
		"[node name=\"Raiz\" type=\"Node2D\"]",
		"",
		"[node name=\"Tapa\" type=\"Sprite2D\" parent=\".\"]",
		"",
		"[node name=\"Muro\" type=\"StaticBody2D\" parent=\".\" node_paths=PackedStringArray(\"tapas\", \"descubre\")]",
		"script = ExtResource(\"1_muro\")",
		"tapas = [%s]" % tapas,
		"descubre = [%s]" % descubre,
		"",
		"[node name=\"Luz\" type=\"Node2D\" parent=\".\"%s]" % (" node_paths=PackedStringArray(\"encendida\")" if not encendida.is_empty() else ""),
		"script = ExtResource(\"2_luz\")",
		("encendida = %s" % encendida) if not encendida.is_empty() else "",
		"",
	]))
	var archivo: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	archivo.store_string(texto)
	archivo.close()
	return ResourceLoader.load(ruta, "", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene


func _rutas_de(escena: PackedScene) -> PackedStringArray:
	var raiz: Node = escena.instantiate()
	var anotados: PackedStringArray = _correr(_revisar_rutas_de_nodos.bind(RUTA, escena, raiz))
	raiz.free()
	return anotados


func _probar_rutas_de_nodos() -> void:
	var sana: PackedScene = _escena_con_rutas("NodePath(\"../Tapa\")", "", "NodePath(\"../Tapa\")")
	_sin_fallos("rutas: tapas y encendida que resuelven no fallan", _rutas_de(sana))
	var sin_encendida: PackedScene = _escena_con_rutas("NodePath(\"../Tapa\")", "", "")
	_sin_fallos("rutas: un export de nodo en null a proposito no falla", _rutas_de(sin_encendida))
	var rota: PackedScene = _escena_con_rutas("NodePath(\"../Tapa\")", "NodePath(\"../Nada\")", "")
	_da("rutas: una ruta rota en un arreglo de nodos falla", _rutas_de(rota), "./Muro.descubre nombra un nodo que no existe")
	var suelta: PackedScene = _escena_con_rutas("", "", "NodePath(\"../Perdida\")")
	_da("rutas: una ruta rota en un export de nodo falla", _rutas_de(suelta), "./Luz.encendida nombra un nodo que no existe")
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://prueba_validador_rutas.tscn"))


# Un Npc cuya animacion de entregar repite en bucle no vuelve nunca a quieto.
func _probar_npc_animado() -> void:
	var npc: Npc = Npc.new()
	var dibujo: AnimatedSprite2D = _agregar(npc, AnimatedSprite2D.new(), "Dibujo") as AnimatedSprite2D
	dibujo.sprite_frames = SpriteFrames.new()
	dibujo.sprite_frames.add_animation(Npc.ANIM_ENTREGAR)
	npc.animacion = dibujo
	_da("npc: entregar en bucle falla", _correr(_revisar_npcs.bind(RUTA, npc)), "repite en bucle 'entregar'")
	dibujo.sprite_frames.set_animation_loop(Npc.ANIM_ENTREGAR, false)
	_sin_fallos("npc: entregar sin bucle no falla", _correr(_revisar_npcs.bind(RUTA, npc)))
	npc.free()


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


# Sala sana de la zona de prueba: id igual al archivo, limites con area y Entrada dentro. Los hijos llevan owner, como
# los de una escena cargada; los de una pieza instanciada llevan el de la raiz de la pieza.
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
	_hijo_de_sala(sala, palanca, "Palanca")
	# Un recordado dentro de una pieza instanciada: su owner es la raiz de la pieza, no la sala (Sala.clave_de sube).
	var pieza: Node2D = _hijo_de_sala(sala, Node2D.new(), "Pieza") as Node2D
	var en_pieza: SueloFragil = SueloFragil.new()
	en_pieza.id = "suelo_b"
	_agregar(pieza, en_pieza, "SueloPieza")
	en_pieza.owner = pieza
	_da("sala: id recordado repetido dentro de una pieza instanciada falla", _correr(_revisar_sala.bind(RUTA_SALA, sala)), "id suelo_b repetido en la sala")
	en_pieza.id = "suelo_c"
	_sin_fallos("sala: sala sana con suelos y palanca con id distinto no falla", _correr(_revisar_sala.bind(RUTA_SALA, sala)))
	sala.free()
	# Dos montones con el id por omision se pisan: tomar uno borraria el otro al volver.
	sala = _sala_sana()
	for nombre: String in ["MonedasA", "MonedasB"]:
		var monedas: MonedasSueltas = MonedasSueltas.new()
		monedas.id = "monedas"
		_hijo_de_sala(sala, monedas, nombre)
	_da("sala: dos monedas sueltas con el mismo id fallan", _correr(_revisar_sala.bind(RUTA_SALA, sala)), "id monedas repetido en la sala")
	(sala.get_node(^"MonedasB") as MonedasSueltas).id = "monedas_2"
	_hijo_de_sala(sala, ObjetoHabilidad.new(), "Objeto")
	_sin_fallos("sala: monedas con ids distintos y un objeto de habilidad sin id no fallan", _correr(_revisar_sala.bind(RUTA_SALA, sala)))
	sala.free()


# Una puerta de la escena del nucleo (con su area) en una sala de 1280 x 720, al pie de la sala.
func _puerta_en(sala: Sala, tipo: Puerta.Tipo, llegada: Vector2) -> Puerta:
	var puerta: Puerta = (load("res://nucleo/puerta.tscn") as PackedScene).instantiate() as Puerta
	puerta.position = Vector2(600.0, 680.0)
	puerta.tipo = tipo
	puerta.llegada = llegada
	_hijo_de_sala(sala, puerta, "Puerta")
	return puerta


func _probar_llegada_puertas() -> void:
	var sala: Sala = _sala_sana()
	sala.limites = Rect2(0.0, 0.0, 1280.0, 720.0)
	var puerta: Puerta = _puerta_en(sala, Puerta.Tipo.LADO, Vector2(160.0, 0.0))
	_sin_fallos("llegada: puerta de lado con la llegada lejos de su area no falla", _correr(_revisar_llegada_puertas.bind(RUTA, sala)))
	puerta.llegada = Vector2(50.0, 0.0)
	_da("llegada: puerta de lado que deja al jugador dentro de su area falla", _correr(_revisar_llegada_puertas.bind(RUTA, sala)), "deja al jugador que llega dentro de su area")
	puerta.tipo = Puerta.Tipo.ABAJO
	_da("llegada: puerta de abajo que deja al jugador dentro de su area falla", _correr(_revisar_llegada_puertas.bind(RUTA, sala)), "deja al jugador que llega dentro de su area")
	puerta.tipo = Puerta.Tipo.PUERTA
	puerta.llegada = Vector2.ZERO
	_sin_fallos("llegada: puerta que se cruza con la accion puede dejarlo encima", _correr(_revisar_llegada_puertas.bind(RUTA, sala)))
	puerta.llegada = Vector2(800.0, 0.0)
	_da("llegada: llegada fuera de limites falla", _correr(_revisar_llegada_puertas.bind(RUTA, sala)), "queda fuera de limites")
	sala.free()


func _probar_zonas_camara() -> void:
	var sala: Sala = _sala_sana()
	sala.limites = Rect2(0.0, -720.0, 2560.0, 1440.0)
	var zona: ZonaCamara = _hijo_de_sala(sala, ZonaCamara.new(), "Zona") as ZonaCamara
	zona.limites = Rect2(0.0, -720.0, 1280.0, 720.0)
	_da("zona de camara: sin forma hija falla", _correr(_revisar_zonas_camara.bind(RUTA, sala)), "no tiene una CollisionShape2D hija")
	var forma: CollisionShape2D = CollisionShape2D.new()
	_agregar(zona, forma, "Forma")
	_da("zona de camara: forma hija sin shape falla", _correr(_revisar_zonas_camara.bind(RUTA, sala)), "no tiene una CollisionShape2D hija")
	forma.shape = RectangleShape2D.new()
	_sin_fallos("zona de camara: forma hija y limites negativos dentro de la sala no fallan", _correr(_revisar_zonas_camara.bind(RUTA, sala)))
	zona.limites = Rect2()
	_da("zona de camara: limites sin area fallan", _correr(_revisar_zonas_camara.bind(RUTA, sala)), "limites sin area")
	zona.limites = Rect2(0.0, -800.0, 1280.0, 720.0)
	_da("zona de camara: limites fuera de la sala fallan", _correr(_revisar_zonas_camara.bind(RUTA, sala)), "salen de los de la sala")
	sala.free()
	# En una pieza que no es sala solo se revisa la forma: sus limites se leen en la sala que la instancia.
	var pieza: Node2D = Node2D.new()
	var suelta: ZonaCamara = _agregar(pieza, ZonaCamara.new(), "Zona") as ZonaCamara
	_da("zona de camara: en una pieza, sin forma hija falla", _correr(_revisar_zonas_camara.bind(RUTA, pieza)), "no tiene una CollisionShape2D hija")
	var forma_suelta: CollisionShape2D = CollisionShape2D.new()
	forma_suelta.shape = RectangleShape2D.new()
	_agregar(suelta, forma_suelta, "Forma")
	_sin_fallos("zona de camara: en una pieza, con forma y sin limites no falla", _correr(_revisar_zonas_camara.bind(RUTA, pieza)))
	pieza.free()
	# Una escena cuya raiz es la zona (una pieza para instanciar) tambien se revisa.
	var raiz: ZonaCamara = ZonaCamara.new()
	_da("zona de camara: como raiz de su escena, sin forma hija falla", _correr(_revisar_zonas_camara.bind(RUTA, raiz)), "no tiene una CollisionShape2D hija")
	var forma_raiz: CollisionShape2D = CollisionShape2D.new()
	forma_raiz.shape = RectangleShape2D.new()
	_agregar(raiz, forma_raiz, "Forma")
	_sin_fallos("zona de camara: como raiz de su escena, con forma no falla", _correr(_revisar_zonas_camara.bind(RUTA, raiz)))
	raiz.free()


# Linea de cabecera de un ext_resource de un script, con uid o sin el.
func _linea_ext(destino: String, uid: String) -> String:
	var con_uid: String = (" uid=\"%s\"" % uid) if not uid.is_empty() else ""
	return "[ext_resource type=\"Script\"%s path=\"%s\" id=\"1_x\"]" % [con_uid, destino]


# Uid de la cabecera de la escena misma y de cada ext_resource: falta, otro, el bueno, y un destino de texto sin uid en
# su cabecera; con_uids los arregla y guardar_con_uids escribe la cabecera y el uid del destino.
func _probar_uids() -> void:
	var destino: String = "res://nucleo/npc.gd"
	var bueno: String = uid_de(destino)
	_caso("uid: un script del repo tiene uid", not bueno.is_empty())
	var cabecera: String = "[gd_scene format=3 uid=\"uid://bprueba\"]\n\n"
	_da("uid: una escena sin uid en su cabecera falla", _correr(_revisar_uids.bind(RUTA, "[gd_scene format=3]\n\n" + _linea_ext(destino, bueno))), "sin uid en su cabecera")
	_sin_fallos("uid: una escena con uid en su cabecera no falla", _correr(_revisar_uids.bind(RUTA, cabecera)))
	_da("uid: ext_resource sin uid falla", _correr(_revisar_uids.bind(RUTA, cabecera + _linea_ext(destino, ""))), "no lleva su uid")
	var otro: String = uid_de("res://nucleo/sala.gd")
	_da("uid: ext_resource con el uid de otro archivo falla", _correr(_revisar_uids.bind(RUTA, cabecera + _linea_ext(destino, otro))), "y su uid es " + bueno)
	_sin_fallos("uid: ext_resource con el uid de su destino no falla", _correr(_revisar_uids.bind(RUTA, cabecera + _linea_ext(destino, bueno))))
	var sin_uid: String = "user://prueba_validador_sin_uid.tres"
	ResourceSaver.save(Resource.new(), sin_uid)
	_da("uid: ext_resource de un recurso sin uid en su cabecera falla", _correr(_revisar_uids.bind(RUTA, cabecera + _linea_ext(sin_uid, ""))), "que no tiene uid")
	var arreglado: String = con_uids(cabecera + _linea_ext(destino, "") + "\n" + _linea_ext(sin_uid, "") + "\n" + _linea_ext(destino, otro))
	_caso("uid: con_uids pone el que falta, corrige el otro y deja el destino sin uid", arreglado == cabecera
		+ _linea_ext(destino, bueno) + "\n" + _linea_ext(sin_uid, "") + "\n" + _linea_ext(destino, bueno))
	var cuadros: SpriteFrames = SpriteFrames.new()
	var trozo: AtlasTexture = AtlasTexture.new()
	trozo.atlas = load("res://nucleo/arte/coleccionable.png") as Texture2D
	cuadros.add_frame(&"default", trozo)
	var guardado: String = "user://prueba_validador_guardado.tres"
	var error: Error = guardar_con_uids(cuadros, guardado)
	var texto: String = FileAccess.get_file_as_string(guardado)
	_caso("uid: guardar_con_uids escribe el uid de la cabecera y el del destino", error == OK
		and texto.get_slice("\n", 0).contains(" uid=\"uid://")
		and texto.contains("uid=\"%s\" path=\"res://nucleo/arte/coleccionable.png\"" % uid_de("res://nucleo/arte/coleccionable.png")))
	for ruta: String in [sin_uid, guardado]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))


# Una via: solo la PlataformaDelgada (crea su forma al correr), y nunca en algo que se mueve.
func _probar_una_via() -> void:
	var raiz: Node2D = Node2D.new()
	var cuerpo: StaticBody2D = _agregar(raiz, StaticBody2D.new(), "Lampara") as StaticBody2D
	var forma: CollisionShape2D = _agregar(cuerpo, CollisionShape2D.new(), "Forma") as CollisionShape2D
	forma.shape = RectangleShape2D.new()
	forma.one_way_collision = true
	_da("una via: una forma de una via escrita en la escena falla", _correr(_revisar_una_via.bind(RUTA, raiz)), "Forma es de una via")
	forma.one_way_collision = false
	var poligono: CollisionPolygon2D = _agregar(cuerpo, CollisionPolygon2D.new(), "Poligono") as CollisionPolygon2D
	poligono.one_way_collision = true
	_da("una via: un poligono de una via falla", _correr(_revisar_una_via.bind(RUTA, raiz)), "Poligono es de una via")
	poligono.free()
	var escena: PackedScene = load(ESCENA_DELGADA) as PackedScene
	_agregar(raiz, escena.instantiate(), "Delgada")
	_sin_fallos("una via: una plataforma delgada fija y una forma solida no fallan", _correr(_revisar_una_via.bind(RUTA, raiz)))
	var vaiven: Node = _agregar(raiz, Vaiven.new(), "Vaiven")
	_agregar(vaiven, escena.instantiate(), "DelgadaMovil")
	_da("una via: una plataforma delgada dentro de un Vaiven falla", _correr(_revisar_una_via.bind(RUTA, raiz)), "DelgadaMovil va en Vaiven, que se mueve")
	vaiven.free()
	var giro: Node = _agregar(raiz, Giro.new(), "Giro")
	var brazo: Node = _agregar(giro, Node2D.new(), "Brazo")
	_agregar(brazo, escena.instantiate(), "DelgadaGiro")
	_da("una via: una plataforma delgada dentro de un Giro, a dos niveles, falla", _correr(_revisar_una_via.bind(RUTA, raiz)), "DelgadaGiro va en Giro")
	raiz.free()
	var sola: Node = escena.instantiate()
	_sin_fallos("una via: la escena de la plataforma delgada sola no falla", _correr(_revisar_una_via.bind(ESCENA_DELGADA, sola)))
	sola.free()


func _probar_limites_origen() -> void:
	var sala: Sala = _sala_sana()
	sala.limites = Rect2(80.0, 0.0, 1280.0, 720.0)
	_da("limites: una sala que no empieza en (0, 0) falla", _correr(_revisar_sala.bind(RUTA_SALA, sala)), "debe empezar en (0, 0)")
	sala.limites = Rect2(0.0, 0.0, 1280.0, 720.0)
	_sin_fallos("limites: una sala que empieza en (0, 0) no falla", _correr(_revisar_sala.bind(RUTA_SALA, sala)))
	sala.free()


func _probar_encimes() -> void:
	var misma: Dictionary = {"prueba_1": Rect2(0.0, 0.0, 100.0, 100.0), "prueba_2": Rect2(50.0, 50.0, 100.0, 100.0)}
	_da("mapa: dos salas de la misma zona encimadas fallan", _correr(_revisar_encimes.bind(misma)), "prueba_1 y prueba_2 se enciman en el mapa")
	var zonas: Dictionary = {"prueba_1": Rect2(0.0, 0.0, 100.0, 100.0), "mapa_1": Rect2(50.0, 50.0, 100.0, 100.0)}
	_da("mapa: dos salas de zonas distintas encimadas fallan", _correr(_revisar_encimes.bind(zonas)), "son de zonas distintas")
	var juntas: Dictionary = {"prueba_1": Rect2(0.0, 0.0, 100.0, 100.0), "prueba_2": Rect2(100.0, 0.0, 100.0, 100.0)}
	_sin_fallos("mapa: dos salas que solo se tocan por un borde no fallan", _correr(_revisar_encimes.bind(juntas)))


# _revisar_puertas con unas salas armadas a mano: id -> {ruta, puertas: {id: [destino, puerta_destino, tipo]}}.
func _puertas_de(salas: Dictionary) -> PackedStringArray:
	_fallos.clear()
	_salas.clear()
	for id: String in salas:
		_salas[id] = salas[id] as Dictionary
	_revisar_puertas()
	var anotados: PackedStringArray = _fallos.duplicate()
	_fallos.clear()
	_salas.clear()
	return anotados


# La puerta ABAJO es de ida sola: basta que exista la puerta de llegada; las demas, de ida y vuelta.
func _probar_puertas_abajo() -> void:
	var arriba: Dictionary = {"ruta": "res://a.tscn", "puertas": {"tiro": ["res://b.tscn", "lado", Puerta.Tipo.ABAJO]}}
	var abajo: Dictionary = {"ruta": "res://b.tscn", "puertas": {"lado": ["res://c.tscn", "x", Puerta.Tipo.LADO]}}
	_sin_fallos("puertas: una puerta ABAJO que llega a una puerta que lleva a otra sala no falla", _puertas_de({"prueba_1": arriba, "prueba_2": abajo}))
	(arriba["puertas"] as Dictionary)["tiro"] = ["res://b.tscn", "lado", Puerta.Tipo.LADO]
	_da("puertas: la misma puerta de LADO sin vuelta falla", _puertas_de({"prueba_1": arriba, "prueba_2": abajo}), "no tiene la puerta lado de vuelta a ella")
	(arriba["puertas"] as Dictionary)["tiro"] = ["res://b.tscn", "nada", Puerta.Tipo.ABAJO]
	_da("puertas: una puerta ABAJO a una puerta que no existe falla", _puertas_de({"prueba_1": arriba, "prueba_2": abajo}), "no tiene la puerta nada")
	(arriba["puertas"] as Dictionary)["tiro"] = ["res://b.tscn", "lado", Puerta.Tipo.LADO]
	(abajo["puertas"] as Dictionary)["lado"] = ["res://a.tscn", "tiro", Puerta.Tipo.LADO]
	_sin_fallos("puertas: dos puertas de ida y vuelta no fallan", _puertas_de({"prueba_1": arriba, "prueba_2": abajo}))


func _probar_fondo_tapado() -> void:
	var sala: Sala = _sala_sana()
	var fondo: FondoTapado = _hijo_de_sala(sala, FondoTapado.new(), "Fondos") as FondoTapado
	fondo.fin_pared = 1280.0
	_da("fondo tapado: con la pared hasta el borde derecho falla (solo se veria la costura)", _correr(_revisar_fondos_tapados.bind(RUTA, sala)), "el fondo tapado Fondos acaba su pared en x=1280")
	fondo.fin_pared = 3000.0
	_da("fondo tapado: con la pared mas alla de la sala falla", _correr(_revisar_fondos_tapados.bind(RUTA, sala)), "nunca se ve")
	fondo.fin_pared = 900.0
	_sin_fallos("fondo tapado: con la pared que acaba dentro de la sala no falla", _correr(_revisar_fondos_tapados.bind(RUTA, sala)))
	fondo.lado = FondoTapado.Lado.DERECHA
	fondo.fin_pared = 0.0
	_da("fondo tapado: con la pared a la derecha que empieza en el borde izquierdo falla", _correr(_revisar_fondos_tapados.bind(RUTA, sala)), "empieza su pared en x=0")
	fondo.fin_pared = 900.0
	_sin_fallos("fondo tapado: con la pared a la derecha que empieza dentro de la sala no falla", _correr(_revisar_fondos_tapados.bind(RUTA, sala)))
	sala.free()


func _probar_musica() -> void:
	var sala: Sala = _sala_sana()
	var ogg: AudioStreamOggVorbis = AudioStreamOggVorbis.new()
	sala.tema_musica = ogg
	_da("musica: un tema Ogg sin bucle falla", _correr(_revisar_musica.bind(RUTA, sala)), "no se repite")
	ogg.loop = true
	_sin_fallos("musica: un tema Ogg en bucle no falla", _correr(_revisar_musica.bind(RUTA, sala)))
	sala.tema_musica = Musica.SILENCIO
	_sin_fallos("musica: SILENCIO no se revisa (no se reproduce)", _correr(_revisar_musica.bind(RUTA, sala)))
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	sala.tema_musica = wav
	_da("musica: un tema WAV sin bucle falla", _correr(_revisar_musica.bind(RUTA, sala)), "no se repite")
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_sin_fallos("musica: un tema WAV en bucle no falla", _correr(_revisar_musica.bind(RUTA, sala)))
	sala.tema_musica = AudioStreamGenerator.new()
	_da("musica: un tema de un tipo que no se sabe revisar falla", _correr(_revisar_musica.bind(RUTA, sala)), "que el validador no sabe revisar")
	sala.tema_musica = null
	var region: RegionMusica = _hijo_de_sala(sala, RegionMusica.new(), "Banco") as RegionMusica
	_da("musica: una region sin forma hija falla", _correr(_revisar_musica.bind(RUTA, sala)), "la region de musica Banco no tiene una CollisionShape2D hija")
	var forma: CollisionShape2D = CollisionShape2D.new()
	forma.shape = RectangleShape2D.new()
	_agregar(region, forma, "Forma")
	region.tema = AudioStreamMP3.new()
	_da("musica: una region con un tema MP3 sin bucle falla", _correr(_revisar_musica.bind(RUTA, sala)), "Banco: el tema")
	region.tema = Musica.TEMA_MENU
	_sin_fallos("musica: una region con forma y el tema del menu (en bucle) no falla", _correr(_revisar_musica.bind(RUTA, sala)))
	sala.free()


# Halos de LuzSala en el presupuesto de capas translucidas: aviso, no fallo, cuando pasan el maximo.
func _probar_halos() -> void:
	var sala: Sala = _sala_sana()
	for i: int in range(MAXIMO_CAPAS_TRANSLUCIDAS):
		(_hijo_de_sala(sala, LuzSala.new(), "Luz%d" % i) as LuzSala).radio = 470.0
	_sin_fallos("halos: hasta el maximo de capas no avisan", _correr_avisos(_revisar_presupuesto.bind(RUTA, sala)))
	var otra: LuzSala = _hijo_de_sala(sala, LuzSala.new(), "LuzDeMas") as LuzSala
	otra.radio = 470.0
	_da("halos: uno grande de mas avisa sin fallar", _correr_avisos(_revisar_presupuesto.bind(RUTA, sala)), "contando 3 halos de LuzSala")
	otra.halo_radio = 0.2
	_sin_fallos("halos: un halo chico no cuenta", _correr_avisos(_revisar_presupuesto.bind(RUTA, sala)))
	sala.free()


func _probar_avisos_contenido() -> void:
	var raiz: Node2D = Node2D.new()
	var oculto: Sprite2D = _agregar(raiz, Sprite2D.new(), "Oculto") as Sprite2D
	oculto.owner = raiz
	oculto.visible = false
	_da("contenido: un nodo oculto avisa", _correr_avisos(_avisar_contenido.bind(RUTA, raiz)), "Oculto esta oculto")
	oculto.visible = true
	var forma: CollisionShape2D = _agregar(raiz, CollisionShape2D.new(), "Apagada") as CollisionShape2D
	forma.owner = raiz
	forma.disabled = true
	_da("contenido: una forma apagada avisa", _correr_avisos(_avisar_contenido.bind(RUTA, raiz)), "la forma Apagada esta apagada")
	forma.disabled = false
	oculto.scale = Vector2(2.0, 1.5)
	_da("contenido: una escala no uniforme avisa", _correr_avisos(_avisar_contenido.bind(RUTA, raiz)), "Oculto tiene escala no uniforme")
	oculto.scale = Vector2(-2.0, 2.0)
	var pieza: Node2D = _agregar(raiz, Node2D.new(), "Pieza") as Node2D
	pieza.owner = raiz
	var dentro: Sprite2D = _agregar(pieza, Sprite2D.new(), "DentroDePieza") as Sprite2D
	dentro.owner = pieza
	dentro.visible = false
	_sin_fallos("contenido: volteado, y lo oculto dentro de una pieza instanciada, no avisan", _correr_avisos(_avisar_contenido.bind(RUTA, raiz)))
	raiz.free()


func _probar_redibujo() -> void:
	var suelto: String = "extends Node2D\n\n\nfunc _process(_delta: float) -> void:\n\tqueue_redraw()\n"
	_da("redibujo: queue_redraw sin guarda en _process avisa", _correr_avisos(_avisar_redibujo.bind(RUTA, suelto)), ":5 (queue_redraw() en _process sin una guarda")
	var guardado: String = "extends Node2D\n\n\nfunc _process(_delta: float) -> void:\n\tif _cambio:\n\t\tqueue_redraw()\n\n\nfunc _draw() -> void:\n\tqueue_redraw()\n"
	_sin_fallos("redibujo: con un if, o fuera de _process, no avisa", _correr_avisos(_avisar_redibujo.bind(RUTA, guardado)))
	var salida: String = "extends Node2D\n\n\nfunc _process(_delta: float) -> void:\n\tif not _cambio:\n\t\treturn\n\tqueue_redraw()\n"
	_sin_fallos("redibujo: tras una salida temprana con return no avisa", _correr_avisos(_avisar_redibujo.bind(RUTA, salida)))
	_sin_fallos("redibujo: un script que prende y apaga su _process no avisa", _correr_avisos(_avisar_redibujo.bind(RUTA, suelto + "\n\nfunc mostrar() -> void:\n\tset_process(true)\n")))
	var fisica: String = "extends Node2D\n\n\nfunc _physics_process(_delta: float) -> void:\n\tqueue_redraw()\n"
	_da("redibujo: queue_redraw sin guarda en _physics_process avisa", _correr_avisos(_avisar_redibujo.bind(RUTA, fisica)), ":5 (queue_redraw() en _physics_process sin una guarda")
	var fisica_guardada: String = "extends Node2D\n\n\nfunc _physics_process(_delta: float) -> void:\n\tif not _cambio:\n\t\treturn\n\tqueue_redraw()\n"
	_sin_fallos("redibujo: _physics_process con salida temprana no avisa", _correr_avisos(_avisar_redibujo.bind(RUTA, fisica_guardada)))


func _probar_imagenes_sin_uso() -> void:
	var revisados: PackedStringArray = _revisados.duplicate()
	var imagenes: PackedStringArray = _imagenes_contenido.duplicate()
	_revisados = PackedStringArray(["res://nucleo/coleccionable.tscn"])
	_imagenes_contenido = PackedStringArray(["res://contenido/sin_uso_inventada.png"])
	_da("imagenes: una imagen que nada nombra avisa", _correr_avisos(_avisar_imagenes_sin_uso), "sin_uso_inventada.png (ninguna escena")
	_imagenes_contenido = PackedStringArray(["res://nucleo/arte/coleccionable.png"])
	_sin_fallos("imagenes: una imagen que una escena nombra no avisa", _correr_avisos(_avisar_imagenes_sin_uso))
	_revisados = revisados
	_imagenes_contenido = imagenes


func _probar_enemigos() -> void:
	var raiz: Node2D = Node2D.new()
	var enemigo: Enemigo = _agregar(raiz, Enemigo.new(), "Bicho") as Enemigo
	_da("enemigo: sin ficha falla", _correr(_revisar_enemigos.bind(RUTA, raiz)), "el enemigo Bicho no tiene ficha")
	var base: Enemigo = Enemigo.new()
	_sin_fallos("enemigo: la raiz de la escena (la base) sin ficha no falla", _correr(_revisar_enemigos.bind(RUTA, base)))
	base.free()
	var ficha: FichaEnemigo = FichaEnemigo.new()
	enemigo.ficha = ficha
	var anotados: PackedStringArray = _correr(_revisar_enemigos.bind(RUTA, raiz))
	_da("enemigo: ficha sin id falla", anotados, "no tiene id")
	ficha.id = &"bicho"
	ficha.vida = 0
	_da("enemigo: ficha con vida 0 falla", _correr(_revisar_enemigos.bind(RUTA, raiz)), "tiene vida 0")
	ficha.vida = 2
	ficha.comportamiento = load("res://nucleo/palanca.gd") as GDScript
	_da("enemigo: un comportamiento que no hereda de ComportamientoEnemigo falla",
			_correr(_revisar_enemigos.bind(RUTA, raiz)), "no hereda de ComportamientoEnemigo")
	ficha.comportamiento = load("res://nucleo/comportamiento_enemigo.gd") as GDScript
	_sin_fallos("enemigo: ficha con id y vida y comportamiento de la familia no falla", _correr(_revisar_enemigos.bind(RUTA, raiz)))
	_caso("id recordado: enemigo sin id da ?", _id_recordado(enemigo) == "?")
	enemigo.id = &"bicho_a"
	_caso("id recordado: enemigo con id da su id", _id_recordado(enemigo) == "bicho_a")
	raiz.free()


func _probar_salas_sin_guion() -> void:
	var antes: Dictionary[String, Dictionary] = _salas.duplicate()
	_salas = {"celda_99": {"ruta": "res://contenido/salas/celda/celda_99.tscn", "puertas": {}}}
	_da("guion por sala: una sala de contenido sin guion avisa", _correr_avisos(_avisar_salas_sin_guion), "celda_99.tscn (ningun guion")
	_salas = {"celda_1": {"ruta": "res://contenido/salas/celda/celda_1.tscn", "puertas": {}}}
	_sin_fallos("guion por sala: una sala con su guion no avisa", _correr_avisos(_avisar_salas_sin_guion))
	_salas = antes
