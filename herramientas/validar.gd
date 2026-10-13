extends Node
# Carga cada script, escena y recurso del proyecto con los autoloads activos
# y sale con 1 si alguno no carga. Imprime solo los fallos y un resumen.
# Existe porque Godot sale con 0 aunque un script no compile. Ademas revisa las salas con id (contenido/salas y
# las zonas de prueba): id igual al archivo, puertas de ida y vuelta, bancos con su id, Entrada dentro y
# objetos recordados (suelo fragil, coleccionable, npc, reto de preguntas) con id unico. Revisa tambien la forma de
# cada FichaDialogo y FichaPregunta, y de los Npc y RetoPreguntas de cualquier escena. En cualquier escena, un DanoContacto que se mueve
# (dentro de un Vaiven, un enemigo o un cuerpo que se mueve) no puede ser peligro. Las tablas de la zona de pruebas
# (GRUPOS y OCULTAS) solo nombran escenas que existen.
const IGNORAR: PackedStringArray = ["addons", "build"]
const CAMPOS_TEXTO: PackedStringArray = ["id", "que", "comprobacion"]
const INDICE_MAPA: String = "res://mapa/indice_salas.gd"
const ZONA_PRUEBAS: String = "res://herramientas/salas/zona_pruebas.gd"
## Carpetas donde cada sala lleva id y vive en <carpeta>/<zona>/<id>.tscn.
const CARPETAS_SALAS: PackedStringArray = [Sala.CARPETA_CONTENIDO, Sala.CARPETA_PRUEBAS]
var _fallos: PackedStringArray = []
var _total: int = 0
# Salas con id: id -> {ruta, puertas: {id_puerta: [sala_destino, puerta_destino]}}.
var _salas: Dictionary[String, Dictionary] = {}


func _ready() -> void:
	_recorrer("res://")
	_revisar_puertas()
	_revisar_indice_mapa()
	_revisar_zona_pruebas()
	for fallo: String in _fallos:
		print("FALLO ", fallo)
	print("VALIDACION archivos=%d fallos=%d" % [_total, _fallos.size()])
	get_tree().quit(1 if _fallos.size() > 0 else 0)


func _recorrer(ruta: String) -> void:
	var dir: DirAccess = DirAccess.open(ruta)
	if dir == null:
		_fallos.append(ruta + " (no se pudo abrir)")
		return
	if dir.file_exists(".gdignore"):
		return
	for sub: String in dir.get_directories():
		if not sub.begins_with(".") and not IGNORAR.has(sub):
			_recorrer(ruta.path_join(sub))
	for archivo: String in dir.get_files():
		var ext: String = archivo.get_extension()
		if ext == "gd" or ext == "tscn" or ext == "tres":
			_revisar(ruta.path_join(archivo))
		elif archivo == "funciones.json":
			_revisar_funciones(ruta.path_join(archivo))


func _revisar(ruta: String) -> void:
	_total += 1
	var recurso: Resource = ResourceLoader.load(ruta)
	if recurso == null:
		_fallos.append(ruta + " (no carga)")
	elif recurso is GDScript:
		if not (recurso as GDScript).can_instantiate():
			_fallos.append(ruta + " (script con errores)")
	elif recurso is FichaDialogo:
		for fallo: String in (recurso as FichaDialogo).fallos():
			_fallos.append("%s (%s)" % [ruta, fallo])
	elif recurso is FichaPregunta:
		for fallo: String in (recurso as FichaPregunta).fallos():
			_fallos.append("%s (%s)" % [ruta, fallo])
	elif recurso is PackedScene:
		var escena: PackedScene = recurso as PackedScene
		if not escena.can_instantiate():
			_fallos.append(ruta + " (escena no instanciable)")
		else:
			var nodo: Node = escena.instantiate()
			if nodo == null:
				_fallos.append(ruta + " (no instancia)")
			else:
				if _es_carpeta_de_salas(ruta):
					_revisar_sala(ruta, nodo)
				if nodo is Sala:
					_revisar_presupuesto(ruta, nodo)
				_revisar_peligros(ruta, nodo)
				_revisar_npcs(ruta, nodo)
				nodo.free()


# Presupuesto de una sala (seccion 8 del plan de cierre del nucleo, medido para el S50): a lo mas 3 emisores de
# particulas con 60 particulas entre todos, 30 plantas y ninguna luz 2D.
const MAXIMO_EMISORES: int = 3
const MAXIMO_PARTICULAS: int = 60
const MAXIMO_PLANTAS: int = 30


func _revisar_presupuesto(ruta: String, sala: Node) -> void:
	var emisores: int = 0
	var particulas: int = 0
	var plantas: int = 0
	for nodo: Node in sala.find_children("*", "", true, false):
		if nodo is CPUParticles2D or nodo is GPUParticles2D:
			emisores += 1
			particulas += (nodo as CPUParticles2D).amount if nodo is CPUParticles2D else (nodo as GPUParticles2D).amount
		elif nodo is Planta:
			plantas += 1
		elif nodo is Light2D:
			_fallos.append("%s (%s: sin luces 2D, el renderer Compatibility las cobra caras)" % [ruta, nodo.name])
	if emisores > MAXIMO_EMISORES or particulas > MAXIMO_PARTICULAS:
		_fallos.append("%s (%d emisores y %d particulas: el maximo es %d y %d)" % [ruta, emisores, particulas, MAXIMO_EMISORES, MAXIMO_PARTICULAS])
	if plantas > MAXIMO_PLANTAS:
		_fallos.append("%s (%d plantas: el maximo es %d)" % [ruta, plantas, MAXIMO_PLANTAS])


# Regla de los peligros: lo fijo (pinchos, acido, lava, vacio) devuelve al suelo seguro; lo que se mueve solo
# golpea, con retroceso. Un DanoContacto con peligro dentro de algo que se mueve es un error de la escena.
func _revisar_peligros(ruta: String, raiz: Node) -> void:
	for nodo: Node in raiz.find_children("*", "", true, false):
		var contacto: DanoContacto = nodo as DanoContacto
		if contacto == null or not contacto.peligro:
			continue
		var arriba: Node = contacto.get_parent()
		while arriba != null and arriba != raiz.get_parent():
			if arriba is Vaiven or arriba is Enemigo or arriba is PathFollow2D or arriba is AnimatableBody2D 					or arriba is CharacterBody2D or arriba is RigidBody2D:
				_fallos.append("%s (%s se mueve con %s: no puede ser peligro, solo golpe)" % [ruta, contacto.name, arriba.name])
				break
			arriba = arriba.get_parent()


# Una funciones.json es una lista de entradas con id, que, comprobacion y pasa.
func _revisar_funciones(ruta: String) -> void:
	_total += 1
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(ruta)) != OK or not (json.data is Array):
		_fallos.append(ruta + " (no es una lista JSON valida)")
		return
	var entradas: Array = json.data
	var ids: Array[String] = []
	for i: int in range(entradas.size()):
		var motivo: String = _fallo_de_entrada(entradas[i], ids)
		if not motivo.is_empty():
			_fallos.append("%s entrada %d (%s)" % [ruta, i + 1, motivo])


# Devuelve por que una entrada no es valida, o "" si lo es. Una entrada con "pasa": true
# necesita que exista cada archivo de su comprobacion (varias rutas van separadas por ";"),
# salvo que sea "manual: ...".
func _fallo_de_entrada(valor: Variant, ids: Array[String]) -> String:
	if not (valor is Dictionary):
		return "no es un objeto"
	var entrada: Dictionary = valor
	for campo: String in CAMPOS_TEXTO:
		if not (entrada.get(campo) is String) or (entrada[campo] as String).is_empty():
			return "falta el texto '%s'" % campo
	if not (entrada.get("pasa") is bool):
		return "'pasa' debe ser true o false"
	var id: String = entrada["id"]
	if ids.has(id):
		return "id repetido '%s'" % id
	ids.append(id)
	var comprobacion: String = entrada["comprobacion"]
	var pasa: bool = entrada["pasa"]
	if pasa and not comprobacion.begins_with("manual:"):
		for parte: String in comprobacion.split(";"):
			var ruta: String = parte.strip_edges()
			if ruta.is_empty() or not FileAccess.file_exists("res://" + ruta):
				return "pasa es true y no existe '%s'" % ruta
	return ""


func _es_carpeta_de_salas(ruta: String) -> bool:
	for carpeta: String in CARPETAS_SALAS:
		if ruta.begins_with(carpeta):
			return true
	return false


# Una sala del juego o de una zona de prueba: raiz Sala con id <zona>_<numero> igual al archivo, en la carpeta de su
# zona y sin repetir; limites con area; Entrada dentro de limites; puertas con id unico y destino existente; bancos
# con id banco_<id de la sala>.
func _revisar_sala(ruta: String, nodo: Node) -> void:
	var sala: Sala = nodo as Sala
	if sala == null:
		_fallos.append(ruta + " (la raiz no es una Sala)")
		return
	var esperado: String = ruta.get_file().get_basename()
	var patron: RegEx = RegEx.create_from_string("^[a-z]+_[0-9]+$")
	if sala.id != esperado or patron.search(sala.id) == null:
		_fallos.append("%s (id '%s': debe ser <zona>_<numero> e igual al archivo)" % [ruta, sala.id])
		return
	if ruta.get_base_dir().get_file() != Sala.zona_de(sala.id):
		_fallos.append("%s (la sala %s debe estar en la carpeta de su zona, %s)" % [ruta, sala.id, Sala.zona_de(sala.id)])
	if _salas.has(sala.id):
		_fallos.append("%s (id %s repetido en %s)" % [ruta, sala.id, _salas[sala.id]["ruta"]])
		return
	if sala.limites.size.x <= 0.0 or sala.limites.size.y <= 0.0:
		_fallos.append(ruta + " (limites sin area)")
	if ruta.begins_with(Sala.CARPETA_CONTENIDO) and not sala.habilidades_de_prueba.is_empty():
		_fallos.append(ruta + " (habilidades_de_prueba es solo para salas de prueba)")
	var entrada: Node2D = sala.get_node_or_null(^"Entrada") as Node2D
	if entrada == null or not sala.limites.has_point(entrada.position):
		_fallos.append(ruta + " (falta Entrada o queda fuera de limites)")
	var puertas: Dictionary = {}
	var recordados: Dictionary = {}
	# Los objetos que se recuerdan pueden ir dentro de un nodo agrupador (Sala.clave_de los resuelve por owner).
	for anidado: Node in sala.find_children("*", "", true, true):
		var recordado: String = _id_recordado(anidado)
		if recordado == "?":
			_fallos.append("%s (%s se recuerda en la partida y necesita id)" % [ruta, anidado.name])
		elif not recordado.is_empty():
			if recordados.has(recordado):
				_fallos.append("%s (id %s repetido en la sala)" % [ruta, recordado])
			recordados[recordado] = true
	for hijo: Node in sala.get_children():
		var puerta: Puerta = hijo as Puerta
		if puerta != null:
			if puerta.id.is_empty() or puertas.has(String(puerta.id)):
				_fallos.append("%s (puerta %s sin id o con id repetido)" % [ruta, puerta.name])
			elif not ResourceLoader.exists(puerta.sala_destino):
				_fallos.append("%s (la puerta %s lleva a %s, que no existe)" % [ruta, puerta.id, puerta.sala_destino])
			else:
				puertas[String(puerta.id)] = [puerta.sala_destino, String(puerta.puerta_destino)]
		var banco: Banco = hijo as Banco
		if banco != null and banco.id != "banco_" + sala.id:
			_fallos.append("%s (el banco %s debe tener id banco_%s)" % [ruta, banco.id, sala.id])
	_salas[sala.id] = {"ruta": ruta, "puertas": puertas}


# Cada Npc y cada RetoPreguntas de una escena tiene sus fichas bien formadas y un id que no choca con otras marcas de
# la sala.
func _revisar_npcs(ruta: String, raiz: Node) -> void:
	var npcs: Array[Node] = raiz.find_children("*", "Npc", true, false)
	if raiz is Npc:
		npcs.append(raiz)
	for nodo: Node in npcs:
		var npc: Npc = nodo as Npc
		if npc.id.begins_with(Partida.PREFIJO_COLECCIONABLE) or npc.id.begins_with("entregado_"):
			_fallos.append("%s (el npc %s usa un id reservado: %s)" % [ruta, npc.name, npc.id])
		# La escena del Npc suelto (nucleo/npc.tscn) no trae conversaciones: las pone cada sala.
		if npc != raiz and npc.conversaciones.is_empty():
			_fallos.append("%s (el npc %s no tiene conversaciones)" % [ruta, npc.name])
		for ficha: FichaDialogo in npc.conversaciones:
			if ficha == null:
				_fallos.append("%s (el npc %s tiene una conversacion vacia)" % [ruta, npc.name])
				continue
			for fallo: String in ficha.fallos():
				_fallos.append("%s (npc %s: %s)" % [ruta, npc.name, fallo])
	var retos: Array[Node] = raiz.find_children("*", "RetoPreguntas", true, false)
	if raiz is RetoPreguntas:
		retos.append(raiz)
	for nodo: Node in retos:
		var reto: RetoPreguntas = nodo as RetoPreguntas
		if reto.id.begins_with(Partida.PREFIJO_COLECCIONABLE) or reto.id.begins_with("entregado_"):
			_fallos.append("%s (el reto %s usa un id reservado: %s)" % [ruta, reto.name, reto.id])
		# La escena suelta (nucleo/reto_preguntas.tscn) no trae preguntas: las pone cada sala.
		if reto == raiz:
			continue
		if reto.meta < 1 or reto.meta > reto.preguntas.size():
			_fallos.append("%s (el reto %s pide %d aciertos de %d preguntas)" % [ruta, reto.name, reto.meta, reto.preguntas.size()])
		for pregunta: FichaPregunta in reto.preguntas:
			if pregunta == null:
				_fallos.append("%s (el reto %s tiene una pregunta vacia)" % [ruta, reto.name])
				continue
			for fallo: String in pregunta.fallos():
				_fallos.append("%s (reto %s: %s)" % [ruta, reto.name, fallo])


# Id de un objeto que se recuerda en el estado de su sala (suelo fragil, coleccionable, npc, reto): "" si el nodo no es de
# esos, "?" si lo es y no tiene id.
func _id_recordado(nodo: Node) -> String:
	var suelo: SueloFragil = nodo as SueloFragil
	if suelo != null:
		return suelo.id if not suelo.id.is_empty() else "?"
	var coleccionable: Coleccionable = nodo as Coleccionable
	if coleccionable != null:
		return coleccionable.id if not coleccionable.id.is_empty() else "?"
	var npc: Npc = nodo as Npc
	if npc != null:
		return npc.id if not npc.id.is_empty() else "?"
	var reto: RetoPreguntas = nodo as RetoPreguntas
	if reto != null:
		return reto.id if not reto.id.is_empty() else "?"
	return ""


# El indice del mapa (mapa/indice_salas.tres) debe decir lo mismo que las salas: si una sala se agrega, se mueve o
# cambia sus limites, posicion_mapa o su dibujo, hay que volver a generarlo. La clase se busca por ruta al correr,
# no por nombre, para que el validador siga funcionando en un proyecto sin el bloque mapa/.
func _revisar_indice_mapa() -> void:
	if not ResourceLoader.exists(INDICE_MAPA):
		return
	var indice: Script = load(INDICE_MAPA) as Script
	var nuevo: Resource = indice.call(&"construir")
	var guardado: Resource = indice.call(&"cargar")
	var coincide: bool = indice.call(&"iguales", nuevo, guardado)
	if not coincide:
		_fallos.append("res://mapa/indice_salas.tres (no coincide con las salas: correr herramientas/generar_mapa.tscn)")


# Una sala renombrada o borrada no puede quedar en las tablas de la zona de pruebas: dejaria de aparecer sin aviso.
func _revisar_zona_pruebas() -> void:
	if not ResourceLoader.exists(ZONA_PRUEBAS):
		return
	var constantes: Dictionary = (load(ZONA_PRUEBAS) as Script).get_script_constant_map()
	var carpeta: String = constantes["CARPETA"]
	var nombradas: Array = (constantes["OCULTAS"] as PackedStringArray).duplicate()
	var grupos: Dictionary = constantes["GRUPOS"]
	for categoria: String in grupos:
		nombradas.append_array(grupos[categoria] as Array)
	for sala: String in nombradas:
		if not ResourceLoader.exists(carpeta + sala):
			_fallos.append("%s (nombra %s, que no existe)" % [ZONA_PRUEBAS, sala])


# Puertas de ida y vuelta entre salas con id: si A lleva a la puerta P de B, B tiene la puerta P y lleva de
# vuelta a la misma puerta de A.
func _revisar_puertas() -> void:
	var por_ruta: Dictionary[String, String] = {}
	for id: String in _salas:
		por_ruta[_salas[id]["ruta"] as String] = id
	for id: String in _salas:
		var puertas: Dictionary = _salas[id]["puertas"]
		for id_puerta: String in puertas:
			var destino: Array = puertas[id_puerta]
			var ruta_destino: String = destino[0]
			var puerta_destino: String = destino[1]
			if not por_ruta.has(ruta_destino):
				continue
			var otras: Dictionary = _salas[por_ruta[ruta_destino]]["puertas"]
			var vuelta: Variant = otras.get(puerta_destino)
			var esperado: Array = [_salas[id]["ruta"], id_puerta]
			if vuelta == null or vuelta != esperado:
				_fallos.append("sala %s, puerta %s: %s no tiene la puerta %s de vuelta a ella" % [id, id_puerta, por_ruta[ruta_destino], puerta_destino])
