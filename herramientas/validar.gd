extends Node
# Carga cada script, escena y recurso del proyecto con los autoloads activos
# y sale con 1 si alguno no carga. Imprime solo los fallos y un resumen.
# Existe porque Godot sale con 0 aunque un script no compile. Ademas revisa las salas con id (contenido/salas y
# las zonas de prueba): id igual al archivo, puertas de ida y vuelta, bancos con su id, Entrada dentro y
# objetos recordados (suelo fragil, recogibles, npc, reto de preguntas) con id unico. Revisa tambien la forma de
# cada FichaDialogo y FichaPregunta, y de los Npc y RetoPreguntas de cualquier escena. En cualquier escena, un DanoContacto que se mueve
# (dentro de un Vaiven, un Giro, un enemigo o un cuerpo que se mueve) no puede ser peligro, y ningun cuerpo de fisica va
# dentro de un Vaiven o un Giro. Cada ZonaCamara lleva su forma hija y, en una sala, limites con area dentro de los de
# la sala. Toda ruta de nodo guardada para una variable de script resuelve; las tapas y lo que descubre un
# MuroRompible son dibujos fuera de el, y lo que descubre no tiene fisica. Las tablas de la zona de pruebas
# (GRUPOS y OCULTAS) solo nombran escenas que existen. Ninguna imagen pasa de 2048 px por lado. Cada puerta lleva a un
# destino que existe, por id si es una sala con id; cada puerta en el borde lleva su pared detras; cada id de habilidad esta en Habilidades.TODAS; el arte del
# mundo se importa con mipmaps y en VRAM solo sin transparencia. En los bloques del juego cada ext_resource lleva el uid
# de su destino. La unica una via es una PlataformaDelgada fija; las salas con id empiezan sus limites en (0, 0) y no se
# enciman en el mapa; un FondoTapado se ve en algun punto; RegionMusica lleva su forma hija y todo tema se repite.
# Ademas imprime avisos (AVISO, no fallan): imagen de contenido/ sin uso, queue_redraw sin guarda en _process, nodo
# oculto, colision apagada o escala no uniforme en contenido/ y halos de LuzSala que pasan el presupuesto de capas.
const IGNORAR: PackedStringArray = ["addons", "build"]
const CAMPOS_TEXTO: PackedStringArray = ["id", "que", "comprobacion"]
const INDICE_MAPA: String = "res://mapa/indice_salas.gd"
const ZONA_PRUEBAS: String = "res://herramientas/salas/zona_pruebas.gd"
## Carpetas donde cada sala lleva id y vive en <carpeta>/<zona>/<id>.tscn.
const CARPETAS_SALAS: PackedStringArray = [Sala.CARPETA_CONTENIDO, Sala.CARPETA_PRUEBAS]
# Ninguna textura de mas de 2048 px por lado (decision cerrada del CLAUDE.md raiz: limite de los telefonos de gama
# baja con el renderer Compatibility).
const IMAGENES: PackedStringArray = ["png", "jpg", "jpeg", "webp", "svg"]
const MAXIMO_LADO_TEXTURA: int = 2048
## Arte del mundo: el de las salas del juego y el de la sala de arte. El HUD y los menus no llevan mipmaps.
const CARPETAS_ARTE_MUNDO: PackedStringArray = ["res://contenido/", "res://herramientas/salas/arte/"]
## Imagenes con transparencia que van comprimidas en VRAM por excepcion (fondos de la sala de arte, decidido el
## 13-oct-2026). Una excepcion nueva se anota aqui y en docs/contrato.md, «Recursos».
const ALFA_EN_VRAM: PackedStringArray = [
	"res://herramientas/salas/arte/fondo1.png",
	"res://herramientas/salas/arte/fondo2.png",
	"res://herramientas/salas/arte/lejana1.png",
	"res://herramientas/salas/arte/suelo.png",
]
## compress/mode de un .import: 2 es VRAM Compressed.
const MODO_VRAM: int = 2
## Tolerancia en px para decidir que algo toca un borde (pared detras de una puerta).
const TOLERANCIA_BORDE: float = 1.0
# Presupuesto de una sala (_revisar_presupuesto), medido para el S50.
const MAXIMO_EMISORES: int = 16
const MAXIMO_PARTICULAS: int = 200
const MAXIMO_PLANTAS: int = 30
const MAXIMO_CAPAS_TRANSLUCIDAS: int = 2
## Una capa es grande si cubre al menos un cuarto de la vista base (1280x720).
const AREA_CAPA_GRANDE: float = 1280.0 * 720.0 / 4.0
## Carpeta de las pruebas de codigo, que no viajan en el paquete de publicacion (_revisar_pruebas_aparte).
const CARPETA_PRUEBAS_CODIGO: String = "res://herramientas/pruebas/"
## Bloques del juego donde cada ext_resource de una escena o recurso lleva el uid de su destino (_revisar_uids).
const CARPETAS_CON_UID: PackedStringArray = ["res://contenido/", "res://nucleo/", "res://mapa/", "res://interfaz/"]
## Carpeta del contenido, donde se avisa de lo que sobra (_avisar_contenido, _avisar_imagenes_sin_uso).
const CARPETA_CONTENIDO: String = "res://contenido/"
## Scripts del mundo donde se avisa de un queue_redraw() sin guarda en _process (_avisar_redibujo).
const CARPETAS_REDIBUJO: PackedStringArray = ["res://contenido/", "res://nucleo/"]
## Carpeta de los guiones de prueba (_avisar_salas_sin_guion).
const CARPETA_GUIONES: String = "res://herramientas/guiones/"
## Escena de la unica plataforma de una via (docs/contrato.md, «Sala», «Suelos y plataformas»).
const ESCENA_DELGADA: String = "res://nucleo/piezas/plataforma_delgada.tscn"

var _fallos: PackedStringArray = []
# Avisos: lo que conviene revisar pero no rompe el juego. Se imprimen como AVISO y no cuentan en fallos.
var _avisos: PackedStringArray = []
# Imagenes de contenido/ encontradas al recorrer, para _avisar_imagenes_sin_uso.
var _imagenes_contenido: PackedStringArray = []
var _total: int = 0
# Salas con id: id -> {ruta, puertas: {id_puerta: [sala_destino, puerta_destino]}}.
var _salas: Dictionary[String, Dictionary] = {}
# Cada .gd, .tscn y .tres revisado, para _revisar_pruebas_aparte.
var _revisados: PackedStringArray = []
# Fichas de datos que traen su propio fallos() (BolsaPreguntas es la de la mochila): el validador anota cada fallo con
# la ruta del recurso.
var _fichas_con_fallos: Array[Script] = [FichaDialogo, FichaPregunta, BolsaPreguntas, FichaEstaciones]
# Clases que se recuerdan en el estado de su sala y necesitan id; todas lo declaran como String (Enemigo, StringName). Toda clase que llame a
# Partida.marcar va aqui, salvo EntregaRecompensas (no tiene id: dos en una sala se pisarian) y el aviso (abajo). Recogible cubre sus subclases (Coleccionable, MonedasSueltas y las que vengan); el que no se
# recuerda por id (ObjetoHabilidad) lo dice con recordado_por_id(). El aviso va aparte: su id es opcional.
var _recordados_con_id: Array[Script] = [SueloFragil, MuroRompible, Palanca, Porton, Recogible, Npc, RetoPreguntas, Tienda, Enemigo]


func _ready() -> void:
	_recorrer("res://")
	_revisar_puertas()
	_revisar_indice_mapa()
	_revisar_zona_pruebas()
	_revisar_pruebas_aparte()
	_revisar_tema("res://nucleo/musica.gd", "TEMA_MENU", Musica.TEMA_MENU)
	_avisar_imagenes_sin_uso()
	_avisar_salas_sin_guion()
	for aviso: String in _avisos:
		print("AVISO ", aviso)
	for fallo: String in _fallos:
		print("FALLO ", fallo)
	print("AVISOS total=%d" % _avisos.size())
	print("VALIDACION archivos=%d fallos=%d" % [_total, _fallos.size()])
	get_tree().quit(1 if _fallos.size() > 0 else 0)


## Uid en texto (uid://...) del recurso de ruta, o "" si no tiene: un .tscn o .tres sin uid en su cabecera
## (classes/class_resourceloader.rst:266).
static func uid_de(ruta: String) -> String:
	var uid: int = ResourceLoader.get_resource_uid(ruta)
	return ResourceUID.id_to_text(uid) if uid != ResourceUID.INVALID_ID else ""


## El texto de una escena o recurso con el uid de su destino en cada ext_resource: lo pone si falta y lo corrige si no
## coincide. Una linea cuyo destino no tiene uid queda igual.
static func con_uids(texto: String) -> String:
	var lineas: PackedStringArray = texto.split("\n")
	for i: int in range(lineas.size()):
		var linea: String = lineas[i]
		if not linea.begins_with("[ext_resource"):
			continue
		var uid: String = uid_de(_atributo(linea, "path"))
		var escrito: String = _atributo(linea, "uid")
		if uid.is_empty() or escrito == uid:
			continue
		if escrito.is_empty():
			lineas[i] = linea.replace(" path=\"", " uid=\"%s\" path=\"" % uid)
		else:
			lineas[i] = linea.replace(" uid=\"%s\"" % escrito, " uid=\"%s\"" % uid)
	return "\n".join(lineas)


## Guarda recurso en ruta (un .tres o .tscn) con ResourceSaver, que escribe el formato, y le pone lo que ese guardado no
## escribe fuera del editor (medido el 27-oct-2026; ResourceSaver.set_uid tampoco lo escribe): el uid de la cabecera, el
## que ya tenia el archivo o uno nuevo (classes/class_resourceuid.rst:106), y el de cada ext_resource (con_uids). Lo
## usan generar_sprites y generar_mapa.
static func guardar_con_uids(recurso: Resource, ruta: String) -> Error:
	var uid: int = ResourceLoader.get_resource_uid(ruta)
	if uid == ResourceUID.INVALID_ID:
		uid = ResourceUID.create_id()
	var error: Error = ResourceSaver.save(recurso, ruta)
	if error != OK:
		return error
	var lineas: PackedStringArray = FileAccess.get_file_as_string(ruta).split("\n")
	if _atributo(lineas[0], "uid").is_empty():
		lineas[0] = lineas[0].trim_suffix("]") + " uid=\"%s\"]" % ResourceUID.id_to_text(uid)
	var archivo: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	if archivo == null:
		return FileAccess.get_open_error()
	archivo.store_string(con_uids("\n".join(lineas)))
	archivo.close()
	return OK


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
		elif IMAGENES.has(ext):
			_revisar_imagen(ruta.path_join(archivo))
			if ruta.path_join(archivo).begins_with(CARPETA_CONTENIDO):
				_imagenes_contenido.append(ruta.path_join(archivo))


# Ninguna textura de mas de MAXIMO_LADO_TEXTURA por lado, y el arte del mundo con su importacion.
func _revisar_imagen(ruta: String) -> void:
	var textura: Texture2D = ResourceLoader.load(ruta) as Texture2D
	if textura == null:
		_fallos.append(ruta + " (imagen que no carga como textura)")
	elif textura.get_width() > MAXIMO_LADO_TEXTURA or textura.get_height() > MAXIMO_LADO_TEXTURA:
		_fallos.append("%s (%dx%d px: el maximo es %d por lado)" % [ruta, textura.get_width(), textura.get_height(), MAXIMO_LADO_TEXTURA])
	for carpeta: String in CARPETAS_ARTE_MUNDO:
		if ruta.begins_with(carpeta):
			_revisar_importacion(ruta)


# Importacion del arte del mundo (tutorials/assets_pipeline/importing_images.rst:185-189 y :373-393): con mipmaps,
# porque la vista de 1280x720 se encoge en las pantallas mas chicas; Lossless por omision y VRAM Compressed solo en
# una imagen sin transparencia (en 2D, VRAM deja artefactos que se notan mas en los bordes translucidos).
func _revisar_importacion(ruta: String) -> void:
	var importado: ConfigFile = ConfigFile.new()
	if importado.load(ruta + ".import") != OK:
		_fallos.append(ruta + " (sin .import)")
		return
	if not (importado.get_value("params", "mipmaps/generate", false) as bool):
		_fallos.append(ruta + " (arte del mundo sin mipmaps: Mipmaps > Generate al importar)")
	if (importado.get_value("params", "compress/mode", 0) as int) != MODO_VRAM or ALFA_EN_VRAM.has(ruta):
		return
	# Se lee el archivo original: la textura importada en VRAM ya viene comprimida.
	var imagen: Image = Image.load_from_file(ProjectSettings.globalize_path(ruta))
	if imagen != null and imagen.detect_alpha() != Image.ALPHA_NONE:
		_fallos.append(ruta + " (tiene transparencia y va en VRAM Compressed: Lossless, o excepcion en ALFA_EN_VRAM)")


func _revisar(ruta: String) -> void:
	_total += 1
	_revisados.append(ruta)
	if _en_carpetas(ruta, CARPETAS_CON_UID) and ruta.get_extension() != "gd":
		_revisar_uids(ruta, FileAccess.get_file_as_string(ruta))
	var recurso: Resource = ResourceLoader.load(ruta)
	if recurso == null:
		_fallos.append(ruta + " (no carga)")
	elif recurso is GDScript:
		if not (recurso as GDScript).can_instantiate():
			_fallos.append(ruta + " (script con errores)")
		elif _en_carpetas(ruta, CARPETAS_REDIBUJO):
			_avisar_redibujo(ruta, FileAccess.get_file_as_string(ruta))
	elif _es_ficha_con_fallos(recurso):
		var fallos_ficha: PackedStringArray = recurso.call(&"fallos")
		for fallo: String in fallos_ficha:
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
				_revisar_rutas_de_nodos(ruta, escena, nodo)
				if _es_carpeta_de_salas(ruta):
					_revisar_sala(ruta, nodo)
				else:
					for puerta: Node in nodo.find_children("*", "Puerta", true, false):
						_destino_de_puerta(ruta, puerta as Puerta)
				if nodo is Sala:
					_revisar_presupuesto(ruta, nodo)
					_revisar_pared_tras_puerta(ruta, nodo as Sala)
					_revisar_llegada_puertas(ruta, nodo as Sala)
					_revisar_fondos_tapados(ruta, nodo as Sala)
				if ruta.begins_with(CARPETA_CONTENIDO):
					_avisar_contenido(ruta, nodo)
				_revisar_una_via(ruta, nodo)
				_revisar_musica(ruta, nodo)
				_revisar_peligros(ruta, nodo)
				_revisar_cuerpos_moviles(ruta, nodo)
				_revisar_habilidades(ruta, nodo)
				_revisar_npcs(ruta, nodo)
				_revisar_tiendas(ruta, nodo)
				_revisar_avisos(ruta, nodo)
				_revisar_estaciones(ruta, nodo)
				_revisar_enemigos(ruta, nodo)
				_revisar_recogibles(ruta, nodo)
				_revisar_zonas_camara(ruta, nodo)
				for muro: Node in _de_tipo(nodo, MuroRompible, true):
					_revisar_muro(ruta, muro as MuroRompible)
				nodo.free()


func _es_ficha_con_fallos(recurso: Resource) -> bool:
	for clase: Script in _fichas_con_fallos:
		if is_instance_of(recurso, clase):
			return true
	return false


# Nodos de una clase propia (class_name) bajo raiz, en orden de arbol; con con_raiz, tambien la raiz si es de esa
# clase, al principio. Sin clase, todos los nodos (y la raiz al principio si con_raiz).
func _de_tipo(raiz: Node, clase: Script, con_raiz: bool) -> Array[Node]:
	var tipo: String = String(clase.get_global_name()) if clase != null else ""
	var nodos: Array[Node] = raiz.find_children("*", tipo, true, false)
	if con_raiz and (clase == null or is_instance_of(raiz, clase)):
		nodos.push_front(raiz)
	return nodos


# Una puerta en el borde izquierdo o derecho de limites lleva detras un StaticBody2D fuera de limites, pegado al
# borde, desde lo alto de la sala hasta el pie de la puerta (docs/contrato.md, «Cambio de sala»): sin el, un salto
# pasa por encima del area y el jugador sale de la sala (docs/errores/2026-10-14-salto-sobre-puerta.md).
func _revisar_pared_tras_puerta(ruta: String, sala: Sala) -> void:
	var limites: Rect2 = sala.limites
	var paredes: Array[Rect2] = []
	for cuerpo: Node in sala.find_children("*", "StaticBody2D", true, false):
		for forma: Node in cuerpo.find_children("*", "CollisionShape2D", true, false):
			var colision: CollisionShape2D = forma as CollisionShape2D
			if colision.shape != null and not colision.disabled:
				paredes.append(_transformada_en(sala, colision) * colision.shape.get_rect())
	for hijo: Node in sala.get_children():
		var puerta: Puerta = hijo as Puerta
		if puerta == null:
			continue
		for forma: Node in puerta.find_children("*", "CollisionShape2D", true, false):
			var colision: CollisionShape2D = forma as CollisionShape2D
			if colision.shape == null:
				continue
			var area: Rect2 = _transformada_en(sala, colision) * colision.shape.get_rect()
			var derecha: bool = area.end.x >= limites.end.x - TOLERANCIA_BORDE
			var izquierda: bool = area.position.x <= limites.position.x + TOLERANCIA_BORDE
			if not derecha and not izquierda:
				continue
			var cubierta: bool = false
			for pared: Rect2 in paredes:
				var por_fuera: bool = (
					absf(pared.position.x - limites.end.x) <= TOLERANCIA_BORDE if derecha
					else absf(pared.end.x - limites.position.x) <= TOLERANCIA_BORDE
				)
				if (por_fuera and pared.position.y <= limites.position.y + TOLERANCIA_BORDE
						and pared.end.y >= area.end.y - TOLERANCIA_BORDE):
					cubierta = true
					break
			if not cubierta:
				_fallos.append("%s (la puerta %s esta en el borde %s y no tiene detras una pared desde lo alto de la sala hasta su pie: ParedTrasPuerta)"
					% [ruta, puerta.name, "derecho" if derecha else "izquierdo"])


# La llegada de cada puerta (position + llegada, los pies del jugador) cae dentro de limites, y en una puerta que se
# cruza al tocarla (todas menos Puerta.Tipo.PUERTA) el cuerpo del jugador recien llegado (Jugador.TAMANO) no toca el
# area de la puerta: si la tocara, la cruzaria de vuelta al llegar (docs/contrato.md, «Cambio de sala»).
func _revisar_llegada_puertas(ruta: String, sala: Sala) -> void:
	for hijo: Node in sala.get_children():
		var puerta: Puerta = hijo as Puerta
		if puerta == null:
			continue
		var pies: Vector2 = puerta.position + puerta.llegada
		if not sala.limites.has_point(pies):
			_fallos.append("%s (la llegada de la puerta %s queda fuera de limites)" % [ruta, puerta.name])
			continue
		if puerta.tipo == Puerta.Tipo.PUERTA:
			continue
		var cuerpo: Rect2 = Rect2(pies - Vector2(Jugador.TAMANO.x / 2.0, Jugador.TAMANO.y), Jugador.TAMANO)
		for forma: Node in puerta.find_children("*", "CollisionShape2D", true, false):
			var colision: CollisionShape2D = forma as CollisionShape2D
			if colision.shape == null or colision.disabled:
				continue
			var area: Rect2 = _transformada_en(sala, colision) * colision.shape.get_rect()
			if cuerpo.intersects(area):
				_fallos.append("%s (la puerta %s deja al jugador que llega dentro de su area: alejar llegada)"
					% [ruta, puerta.name])
				break


# Transformada de un nodo relativa a la raiz de la sala, sin que la escena este en el arbol.
func _transformada_en(raiz: Node, nodo: Node) -> Transform2D:
	var total: Transform2D = Transform2D.IDENTITY
	var actual: Node = nodo
	while actual != null and actual != raiz:
		var nodo_2d: Node2D = actual as Node2D
		if nodo_2d != null:
			total = nodo_2d.transform * total
		actual = actual.get_parent()
	return total


# Presupuesto de una sala, medido para el S50: a lo mas 16 emisores de particulas con 200 particulas entre todos
# (La Celda, con 13 y ~100, costo menos de 1 FPS el 25-oct-2026; que limita en el S50 depende de la sala y se mide
# A/B, herramientas/pruebas/medicion.tscn), 30 plantas, ninguna luz 2D en la escena (LuzSala la crea en codigo solo
# con su ajuste) y 2 capas translucidas grandes (cada capa translucida se pinta encima de lo de atras: el costo es el
# area, tutorials/performance/gpu_optimization.rst:259-263). El halo de una LuzSala tambien es una capa que se suma
# encima: los grandes se cuentan como aviso, no como fallo, porque su costo en el S50 aun no se mide A/B.
func _revisar_presupuesto(ruta: String, sala: Node) -> void:
	var emisores: int = 0
	var particulas: int = 0
	var plantas: int = 0
	var capas: PackedStringArray = []
	var halos: PackedStringArray = []
	for nodo: Node in sala.find_children("*", "", true, false):
		if nodo is CPUParticles2D or nodo is GPUParticles2D:
			emisores += 1
			particulas += (nodo as CPUParticles2D).amount if nodo is CPUParticles2D else (nodo as GPUParticles2D).amount
		elif nodo is Planta:
			plantas += 1
		elif nodo is Light2D:
			_fallos.append("%s (%s: sin luces 2D, el renderer Compatibility las cobra caras)" % [ruta, nodo.name])
		elif nodo is LuzSala:
			var luz: LuzSala = nodo as LuzSala
			var escala: Vector2 = _escala_visible(luz, sala)
			if luz.area_halo() * escala.x * escala.y >= AREA_CAPA_GRANDE:
				halos.append(luz.name)
		elif nodo is CanvasItem and _es_capa_translucida_grande(nodo as CanvasItem, sala):
			capas.append(nodo.name)
	if emisores > MAXIMO_EMISORES or particulas > MAXIMO_PARTICULAS:
		_fallos.append("%s (%d emisores y %d particulas: el maximo es %d y %d)" % [ruta, emisores, particulas, MAXIMO_EMISORES, MAXIMO_PARTICULAS])
	if plantas > MAXIMO_PLANTAS:
		_fallos.append("%s (%d plantas: el maximo es %d)" % [ruta, plantas, MAXIMO_PLANTAS])
	if capas.size() > MAXIMO_CAPAS_TRANSLUCIDAS:
		_fallos.append("%s (%d capas translucidas grandes, %s: el maximo es %d)" % [ruta, capas.size(), ", ".join(capas), MAXIMO_CAPAS_TRANSLUCIDAS])
	elif capas.size() + halos.size() > MAXIMO_CAPAS_TRANSLUCIDAS:
		_avisos.append("%s (%d capas translucidas grandes contando %d halos de LuzSala, %s: el maximo es %d; medir en el S50 o bajar halo_radio)"
			% [ruta, capas.size() + halos.size(), halos.size(), ", ".join(capas + halos), MAXIMO_CAPAS_TRANSLUCIDAS])


# Escala de un CanvasItem en la sala, acumulada a mano porque el validador no agrega la sala al arbol; Vector2.ZERO si
# el o un padre esta oculto (no se pinta). La usan el halo de LuzSala y _es_capa_translucida_grande.
func _escala_visible(item: CanvasItem, sala: Node) -> Vector2:
	var escala: Vector2 = Vector2.ONE
	var nodo: Node = item
	while nodo != null and nodo != sala.get_parent() and not (nodo is CanvasLayer):
		if nodo is CanvasItem and not (nodo as CanvasItem).visible:
			return Vector2.ZERO
		if nodo is Node2D:
			escala *= (nodo as Node2D).scale.abs()
		elif nodo is Control:
			escala *= (nodo as Control).scale.abs()
		nodo = nodo.get_parent()
	if nodo is CanvasLayer and not (nodo as CanvasLayer).visible:
		return Vector2.ZERO
	return escala


# Capa translucida grande: un Sprite2D, TextureRect, ColorRect, NinePatchRect o Polygon2D visible, con alfa efectivo
# (el de su color si es ColorRect o Polygon2D, por su self_modulate y por el modulate de el y de sus padres) menor
# que 1 y un area, con la escala de sus padres, de al menos AREA_CAPA_GRANDE. Se mide sin el arbol (el validador no
# agrega la sala): la escala y la visibilidad salen de _escala_visible, el alfa se multiplica aqui subiendo por los
# CanvasItem (un CanvasLayer corta la cadena) y el tamano de un Control sale de sus anclas (_tamano_control).
func _es_capa_translucida_grande(item: CanvasItem, sala: Node) -> bool:
	var tam: Vector2 = Vector2.ZERO
	if item is Sprite2D:
		var sprite: Sprite2D = item as Sprite2D
		if sprite.texture == null:
			return false
		tam = sprite.region_rect.size if sprite.region_enabled else sprite.texture.get_size() / Vector2(sprite.hframes, sprite.vframes)
	elif item is TextureRect or item is ColorRect or item is NinePatchRect:
		tam = _tamano_control(item as Control)
	elif item is Polygon2D:
		var caja: Rect2 = Rect2()
		var puntos: PackedVector2Array = (item as Polygon2D).polygon
		if puntos.is_empty():
			return false
		caja.position = puntos[0]
		for punto: Vector2 in puntos:
			caja = caja.expand(punto)
		tam = caja.size
	else:
		return false
	var alfa: float = item.self_modulate.a
	if item is ColorRect:
		alfa *= (item as ColorRect).color.a
	elif item is Polygon2D:
		alfa *= (item as Polygon2D).color.a
	var escala: Vector2 = _escala_visible(item, sala)
	if escala == Vector2.ZERO:
		return false
	var nodo: Node = item
	while nodo is CanvasItem and nodo != sala.get_parent():
		alfa *= (nodo as CanvasItem).modulate.a
		nodo = nodo.get_parent()
	return alfa < 1.0 and tam.x * escala.x * tam.y * escala.y >= AREA_CAPA_GRANDE


# Tamano de un Control como quedaria en el juego: fuera del arbol, size no aplica las anclas (un PRESET_FULL_RECT
# mide 0x0) ni el minimo de su contenido. Las anclas toman su parte del padre Control; bajo un Node2D, de nada (el
# motor ancla contra 0x0); bajo un CanvasLayer o sin CanvasItem encima, de la vista base.
func _tamano_control(control: Control) -> Vector2:
	var padre: Vector2 = Vista.BASE
	if control.get_parent() is Control:
		padre = _tamano_control(control.get_parent() as Control)
	elif control.get_parent() is CanvasItem:
		padre = Vector2.ZERO
	var ancho: float = (control.anchor_right - control.anchor_left) * padre.x + control.offset_right - control.offset_left
	var alto: float = (control.anchor_bottom - control.anchor_top) * padre.y + control.offset_bottom - control.offset_top
	var minimo: Vector2 = control.get_combined_minimum_size()
	return Vector2(maxf(ancho, minimo.x), maxf(alto, minimo.y))


# Regla de los peligros: lo fijo (pinchos, acido, lava, vacio) devuelve al suelo seguro; lo que se mueve solo
# golpea, con retroceso. Un DanoContacto con peligro dentro de algo que se mueve (Vaiven.movil_de, la misma lista
# que usa el jugador) es un error de la escena.
func _revisar_peligros(ruta: String, raiz: Node) -> void:
	for nodo: Node in raiz.find_children("*", "", true, false):
		var contacto: DanoContacto = nodo as DanoContacto
		if contacto == null or not contacto.peligro:
			continue
		var movil: Node = Vaiven.movil_de(contacto.get_parent())
		if movil != null:
			_fallos.append("%s (%s se mueve con %s: no puede ser peligro, solo golpe)" % [ruta, contacto.name, movil.name])


# Un cuerpo de fisica dentro de un Vaiven o un Giro (que no sea el nodo mismo) no lleva lo que tiene encima: se mueve
# con su padre sin que el motor estime su velocidad (docs/errores/2026-10-26-plataforma-hija-de-vaiven.md). La pieza
# que lleva al jugador es ella misma el AnimatableBody2D con el script. Las Area2D (lo que dana) si van dentro.
func _revisar_cuerpos_moviles(ruta: String, raiz: Node) -> void:
	var piezas: Array[Node] = raiz.find_children("*", "Node2D", true, false)
	piezas.push_front(raiz)
	for pieza: Node in piezas:
		if not (pieza is Vaiven or pieza is Giro):
			continue
		for cuerpo: Node in pieza.find_children("*", "PhysicsBody2D", true, false):
			_fallos.append("%s (%s esta dentro de %s y no lleva al jugador: la pieza es ella misma el cuerpo)"
				% [ruta, cuerpo.name, pieza.name])


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
# salvo que sea "manual: ...", y cada .guion, su .esperado al lado. raiz solo cambia en la prueba del validador.
func _fallo_de_entrada(valor: Variant, ids: Array[String], raiz: String = "res://") -> String:
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
			if ruta.is_empty() or not FileAccess.file_exists(raiz + ruta):
				return "pasa es true y no existe '%s'" % ruta
			if ruta.ends_with(".guion") and not FileAccess.file_exists(raiz + ruta.trim_suffix(".guion") + ".esperado"):
				return "pasa es true y falta el .esperado de '%s'" % ruta
	return ""


func _es_carpeta_de_salas(ruta: String) -> bool:
	for carpeta: String in CARPETAS_SALAS:
		if ruta.begins_with(carpeta):
			return true
	return false


# Ruta de la escena a la que lleva una puerta. sala_destino es el id de una sala o, para una sala de prueba suelta,
# su ruta res://. Anota el fallo y devuelve "" si el destino no existe, si no es id ni ruta o si es la ruta de una
# sala con id (esas se nombran por su id). No usa Sala.ruta_de con lo que no es id: su push_error haria fallar la
# validacion sin decir de que puerta viene.
func _destino_de_puerta(ruta: String, puerta: Puerta) -> String:
	var destino: String = puerta.sala_destino
	var motivo: String = ""
	if destino.begins_with("res://"):
		if _es_carpeta_de_salas(destino):
			motivo = "usa la ruta %s: una sala con id se nombra por su id" % destino
	elif Sala.zona_de(destino).is_empty():
		motivo = "lleva a '%s', que no es un id de sala ni una ruta res://" % destino
	else:
		destino = Sala.ruta_de(destino)
	if motivo.is_empty() and not ResourceLoader.exists(destino):
		motivo = "lleva a %s, que no existe" % destino
	if not motivo.is_empty():
		_fallos.append("%s (la puerta %s %s)" % [ruta, puerta.id, motivo])
		return ""
	return destino


# Cada id de habilidad de una escena esta en Habilidades.TODAS: el de un ObjetoHabilidad puesto en una sala, el de las recompensas de
# una EntregaRecompensas, un RetoPreguntas o un articulo de una Tienda (y su requisito) y los de habilidades_de_prueba. Las de un Npc las revisa
# FichaDialogo.fallos().
func _revisar_habilidades(ruta: String, raiz: Node) -> void:
	for nodo: Node in _de_tipo(raiz, null, true):
		var ids: Array[StringName] = []
		var recompensas: Array[Recompensa] = []
		# La escena de la pieza sola (nucleo/objeto_habilidad.tscn) va sin habilidad: la pone la sala que la usa.
		if nodo is ObjetoHabilidad and nodo != raiz:
			ids.append((nodo as ObjetoHabilidad).habilidad)
		elif nodo is EntregaRecompensas:
			recompensas = (nodo as EntregaRecompensas).recompensas
		elif nodo is RetoPreguntas:
			recompensas.append((nodo as RetoPreguntas).recompensa)
		elif nodo is Tienda:
			for articulo: ArticuloTienda in (nodo as Tienda).articulos:
				if articulo != null:
					recompensas.append(articulo.recompensa)
					if not articulo.requisito.is_empty():
						ids.append(articulo.requisito)
		elif nodo is Sala:
			ids.append_array((nodo as Sala).habilidades_de_prueba)
		for recompensa: Recompensa in recompensas:
			if recompensa != null and recompensa.tipo == Recompensa.Tipo.HABILIDAD:
				ids.append(recompensa.id)
		for id: StringName in ids:
			if not Habilidades.TODAS.has(id):
				_fallos.append("%s (%s: '%s' no es una habilidad de Habilidades.TODAS)" % [ruta, nodo.name, id])


# Una sala del juego o de una zona de prueba: raiz Sala con id <zona>_<numero> igual al archivo, en la carpeta de su
# zona y sin repetir; limites con area que empiezan en (0, 0); Entrada dentro de limites; puertas con id unico y
# destino existente; bancos con id banco_<id de la sala>.
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
	# El mapa pone lo que se guarda en coordenadas de la sala (la mochila) sobre el rectangulo del indice, que empieza
	# en posicion_mapa + limites.position: con otro origen sale corrido justo esa cantidad (docs/contrato.md, «Sala»).
	if sala.limites.position != Vector2.ZERO:
		_fallos.append("%s (limites empieza en %s: debe empezar en (0, 0), mover el contenido de la sala)" % [ruta, sala.limites.position])
	if ruta.begins_with(Sala.CARPETA_CONTENIDO) and not sala.habilidades_de_prueba.is_empty():
		_fallos.append(ruta + " (habilidades_de_prueba es solo para salas de prueba)")
	var entrada: Node2D = sala.get_node_or_null(^"Entrada") as Node2D
	if entrada == null or not sala.limites.has_point(entrada.position):
		_fallos.append(ruta + " (falta Entrada o queda fuera de limites)")
	var puertas: Dictionary = {}
	var recordados: Dictionary = {}
	# Los objetos que se recuerdan pueden ir dentro de un nodo agrupador o de una pieza instanciada (Sala.clave_de sube
	# hasta la primera Sala): por eso se recorren tambien los nodos que no son de la sala (owned en falso).
	for anidado: Node in sala.find_children("*", "", true, false):
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
			else:
				var destino: String = _destino_de_puerta(ruta, puerta)
				if not destino.is_empty():
					puertas[String(puerta.id)] = [destino, String(puerta.puerta_destino), puerta.tipo]
		var banco: Banco = hijo as Banco
		if banco != null and banco.id != "banco_" + sala.id:
			_fallos.append("%s (el banco %s debe tener id banco_%s)" % [ruta, banco.id, sala.id])
	_salas[sala.id] = {"ruta": ruta, "puertas": puertas}


# Cada Npc y cada RetoPreguntas de una escena tiene sus fichas bien formadas y un id que no choca con otras marcas de
# la sala.
func _revisar_npcs(ruta: String, raiz: Node) -> void:
	for nodo: Node in _de_tipo(raiz, Npc, true):
		var npc: Npc = nodo as Npc
		if _id_reservado(npc.id):
			_fallos.append("%s (el npc %s usa un id reservado: %s)" % [ruta, npc.name, npc.id])
		# La escena del Npc suelto (nucleo/npc.tscn) no trae conversaciones: las pone cada sala.
		if (npc.animacion != null and npc.animacion.sprite_frames != null
				and npc.animacion.sprite_frames.has_animation(Npc.ANIM_ENTREGAR)
				and npc.animacion.sprite_frames.get_animation_loop(Npc.ANIM_ENTREGAR)):
			_fallos.append("%s (el npc %s repite en bucle '%s': nunca vuelve a quieto)" % [ruta, npc.name, Npc.ANIM_ENTREGAR])
		if npc != raiz and npc.conversaciones.is_empty():
			_fallos.append("%s (el npc %s no tiene conversaciones)" % [ruta, npc.name])
		for ficha: FichaDialogo in npc.conversaciones:
			if ficha == null:
				_fallos.append("%s (el npc %s tiene una conversacion vacia)" % [ruta, npc.name])
				continue
			for fallo: String in ficha.fallos():
				_fallos.append("%s (npc %s: %s)" % [ruta, npc.name, fallo])
	for nodo: Node in _de_tipo(raiz, RetoPreguntas, true):
		var reto: RetoPreguntas = nodo as RetoPreguntas
		if _id_reservado(reto.id):
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


# Un id con el prefijo de coleccionable o de entregado choca con esas marcas de la partida.
func _id_reservado(id: String) -> bool:
	return id.begins_with(Partida.PREFIJO_COLECCIONABLE) or id.begins_with(EntregaRecompensas.PREFIJO_ENTREGADO)


# Prefijo de los recogibles de cualquier escena: el id de un Coleccionable empieza con PREFIJO_COLECCIONABLE (asi lo
# cuenta Partida.total_coleccionables) y el de cualquier otro recogible no usa un prefijo reservado, que lo contaria
# como coleccionable o como entrega. La regla vive aqui y no en el _ready del Coleccionable: se revisa sin correr.
func _revisar_recogibles(ruta: String, raiz: Node) -> void:
	for nodo: Node in _de_tipo(raiz, Recogible, true):
		var recogible: Recogible = nodo as Recogible
		if not recogible.recordado_por_id() or recogible.id.is_empty():
			continue
		if recogible is Coleccionable:
			if not recogible.id.begins_with(Partida.PREFIJO_COLECCIONABLE):
				_fallos.append("%s (el coleccionable %s debe tener un id que empiece con '%s'; tiene '%s')" % [ruta,
					recogible.name, Partida.PREFIJO_COLECCIONABLE, recogible.id])
		elif _id_reservado(recogible.id):
			_fallos.append("%s (el recogible %s usa un id reservado: %s)" % [ruta, recogible.name, recogible.id])


# Cada ZonaCamara lleva su forma como CollisionShape2D hija directa, con forma y encendida (las nietas no cuentan,
# tutorials/physics/collision_shapes_2d.rst:18): sin ella no detecta al jugador y la zona no hace nada. En una sala,
# sus limites tienen area y caben en los de la sala (classes/class_rect2.rst:281): fuera de ellos la camara los
# recortaria igual, y un eje sin tope se escribe igual al de la sala.
func _revisar_zonas_camara(ruta: String, raiz: Node) -> void:
	var sala: Sala = raiz as Sala
	for nodo: Node in _de_tipo(raiz, ZonaCamara, true):
		var zona: ZonaCamara = nodo as ZonaCamara
		if not _con_forma_hija(zona):
			_fallos.append("%s (la zona de camara %s no tiene una CollisionShape2D hija con forma)" % [ruta, zona.name])
		if sala == null:
			continue
		if not zona.limites.has_area():
			_fallos.append("%s (la zona de camara %s tiene limites sin area)" % [ruta, zona.name])
		elif not sala.limites.encloses(zona.limites):
			_fallos.append("%s (los limites de la zona de camara %s salen de los de la sala)" % [ruta, zona.name])


# Si un area tiene su forma como CollisionShape2D hija directa, con forma y encendida (convencion de las areas que se
# ajustan a ojo: ZonaCamara, RegionMusica).
func _con_forma_hija(area: Node) -> bool:
	for hijo: Node in area.get_children():
		var forma: CollisionShape2D = hijo as CollisionShape2D
		if forma != null and forma.shape != null and not forma.disabled:
			return true
	return false


func _en_carpetas(ruta: String, carpetas: PackedStringArray) -> bool:
	for carpeta: String in carpetas:
		if ruta.begins_with(carpeta):
			return true
	return false


# Una via (docs/contrato.md, «Sala», «Suelos y plataformas»): la unica es PlataformaDelgada, que crea su forma al correr
# con grosor y margen fijos. Por eso toda forma con one_way_collision escrita en una escena falla
# (classes/class_collisionshape2d.rst:108, classes/class_collisionpolygon2d.rst:126), y una PlataformaDelgada nunca va
# en algo que se mueve (Vaiven.movil_de): medido el 27-oct-2026, una de una via que baja hasta el suelo pasa a traves
# del jugador parado. Si algun dia entra un TileMapLayer, su una via por poligono (classes/class_tiledata.rst) se suma
# aqui.
func _revisar_una_via(ruta: String, raiz: Node) -> void:
	for nodo: Node in _de_tipo(raiz, null, true):
		var forma: CollisionShape2D = nodo as CollisionShape2D
		var poligono: CollisionPolygon2D = nodo as CollisionPolygon2D
		if (forma != null and forma.one_way_collision) or (poligono != null and poligono.one_way_collision):
			_fallos.append("%s (%s es de una via: la unica es una instancia de %s)" % [ruta, nodo.name, ESCENA_DELGADA])
		var delgada: PlataformaDelgada = nodo as PlataformaDelgada
		if delgada == null or delgada == raiz:
			continue
		var movil: Node = Vaiven.movil_de(delgada.get_parent())
		if movil != null:
			_fallos.append("%s (la plataforma de una via %s va en %s, que se mueve: lo que se mueve y lleva al jugador es solido)"
				% [ruta, delgada.name, movil.name])


# Musica: cada RegionMusica lleva su forma como CollisionShape2D hija (sin ella no detecta al jugador), y el tema de
# una sala o de una region se repite (_revisar_tema).
func _revisar_musica(ruta: String, raiz: Node) -> void:
	for nodo: Node in _de_tipo(raiz, null, true):
		if nodo is Sala:
			_revisar_tema(ruta, nodo.name, (nodo as Sala).tema_musica)
		elif nodo is RegionMusica:
			var region: RegionMusica = nodo as RegionMusica
			if not _con_forma_hija(region):
				_fallos.append("%s (la region de musica %s no tiene una CollisionShape2D hija con forma)" % [ruta, region.name])
			_revisar_tema(ruta, region.name, region.tema)


# Un tema de musica se repite: sin bucle se apaga al acabar y la sala queda callada sin que nadie lo pidiera (Musica no
# lo vuelve a tocar). Musica.SILENCIO no se reproduce nunca y se salta; null es «no tocar». El bucle se lee por tipo
# (classes/class_audiostreamoggvorbis.rst:137, classes/class_audiostreammp3.rst:179,
# classes/class_audiostreamwav.rst:253); otro tipo falla, para que nada se cuele sin revisar.
func _revisar_tema(ruta: String, quien: String, tema: AudioStream) -> void:
	if tema == null or tema == Musica.SILENCIO:
		return
	var bucle: bool = false
	if tema is AudioStreamOggVorbis:
		bucle = (tema as AudioStreamOggVorbis).loop
	elif tema is AudioStreamMP3:
		bucle = (tema as AudioStreamMP3).loop
	elif tema is AudioStreamWAV:
		bucle = (tema as AudioStreamWAV).loop_mode != AudioStreamWAV.LOOP_DISABLED
	else:
		_fallos.append("%s (%s: el tema %s es un %s, que el validador no sabe revisar: Ogg, MP3 o WAV)"
			% [ruta, quien, tema.resource_path, tema.get_class()])
		return
	if not bucle:
		_fallos.append("%s (%s: el tema %s no se repite: activar Loop al importarlo)" % [ruta, quien, tema.resource_path])


# Un FondoTapado se ve en algun punto de la sala: la vista nunca pasa de limites.end.x y lo de atras solo se ve a la
# derecha de fin_pared, asi que con fin_pared en ese borde o despues no se ve nunca, salvo la costura de
# FondoTapado.MARGEN px en el borde, que no justifica pintar la textura entera detras de la pared. Se borra o se
# corrige fin_pared.
func _revisar_fondos_tapados(ruta: String, sala: Sala) -> void:
	for nodo: Node in _de_tipo(sala, FondoTapado, false):
		var fondo: FondoTapado = nodo as FondoTapado
		var fin: float = (_transformada_en(sala, fondo.get_parent()) * Vector2(fondo.fin_pared, 0.0)).x
		if fondo.lado == FondoTapado.Lado.DERECHA:
			if fin <= sala.limites.position.x:
				_fallos.append("%s (el fondo tapado %s empieza su pared en x=%d, en el borde izquierdo de la sala o antes: nunca se ve)"
					% [ruta, fondo.name, roundi(fin)])
		elif fin >= sala.limites.end.x:
			_fallos.append("%s (el fondo tapado %s acaba su pared en x=%d, en el borde derecho de la sala o despues: nunca se ve)"
				% [ruta, fondo.name, roundi(fin)])


# En los bloques del juego (CARPETAS_CON_UID) cada ext_resource lleva el uid de su destino: con el, la referencia
# sigue intacta aunque el archivo se mueva o se renombre (classes/class_resourceuid.rst:22). Falla una linea sin uid,
# con un uid que no es el del destino, o que nombra un recurso de texto sin uid en su cabecera (no se le puede poner
# hasta darselo). El arreglo es con_uids, el mismo que usan generar_sprites y generar_mapa al guardar. La escena o el
# recurso mismo tambien lleva uid en su cabecera: sin el, la primera escena que lo nombre fallaria la regla.
func _revisar_uids(ruta: String, texto: String) -> void:
	var cabecera: String = texto.get_slice("\n", 0)
	if (cabecera.begins_with("[gd_scene") or cabecera.begins_with("[gd_resource")) and _atributo(cabecera, "uid").is_empty():
		_fallos.append("%s (sin uid en su cabecera: guardarla en el editor o darle uno con ResourceUID.create_id)" % ruta)
	for linea: String in texto.split("\n"):
		if not linea.begins_with("[ext_resource"):
			continue
		var destino: String = _atributo(linea, "path")
		var esperado: String = uid_de(destino)
		var escrito: String = _atributo(linea, "uid")
		if esperado.is_empty():
			_fallos.append("%s (nombra %s, que no tiene uid: darle uno en su cabecera)" % [ruta, destino])
		elif escrito.is_empty():
			_fallos.append("%s (el ext_resource de %s no lleva su uid, %s)" % [ruta, destino, esperado])
		elif escrito != esperado:
			_fallos.append("%s (el ext_resource de %s lleva %s y su uid es %s)" % [ruta, destino, escrito, esperado])


# Valor de un atributo nombre="..." de una linea de cabecera de un .tscn o .tres, o "" si no esta.
static func _atributo(linea: String, nombre: String) -> String:
	var marca: String = " %s=\"" % nombre
	var inicio: int = linea.find(marca)
	if inicio < 0:
		return ""
	inicio += marca.length()
	var fin: int = linea.find("\"", inicio)
	return linea.substr(inicio, fin - inicio) if fin >= 0 else ""


# Avisos de contenido/: un nodo oculto o una forma apagada es contenido muerto que viaja en el paquete y se carga con
# la sala, y una escala no uniforme estira el arte (pierde la proporcion con que se dibujo). Solo los nodos de la escena misma (owner), no los de dentro de una pieza
# instanciada: esos se revisan en la escena de la pieza.
func _avisar_contenido(ruta: String, raiz: Node) -> void:
	for nodo: Node in _de_tipo(raiz, null, true):
		if nodo != raiz and nodo.owner != raiz:
			continue
		var item: CanvasItem = nodo as CanvasItem
		if item != null and not item.visible:
			_avisos.append("%s (%s esta oculto: quitarlo si no se usa)" % [ruta, nodo.name])
		var forma: CollisionShape2D = nodo as CollisionShape2D
		var poligono: CollisionPolygon2D = nodo as CollisionPolygon2D
		if (forma != null and forma.disabled) or (poligono != null and poligono.disabled):
			_avisos.append("%s (la forma %s esta apagada: quitarla si no se usa)" % [ruta, nodo.name])
		var nodo_2d: Node2D = nodo as Node2D
		if nodo_2d != null and not is_equal_approx(absf(nodo_2d.scale.x), absf(nodo_2d.scale.y)):
			_avisos.append("%s (%s tiene escala no uniforme %s: el arte se deforma)" % [ruta, nodo.name, nodo_2d.scale])


# queue_redraw() en _process o _physics_process sin un if que lo guarde redibuja en cada cuadro (en el S50, las monedas
# vectoriales costaban hasta 23 FPS, medido el 25-oct-2026). Revision de texto, sin entender el codigo: una linea con
# queue_redraw( a un solo tabulador dentro del cuerpo de una de esas funciones. Un return antes de esa linea en la misma
# funcion (una salida temprana como if not cambio: return) cuenta como guarda. Un script que llama a set_process( o
# set_physics_process( prende y apaga su proceso (VerHitbox, solo mientras se ve): se toma como guarda y no se avisa. Huecos conocidos, por ser
# solo texto: no sigue llamadas (un queue_redraw() en una funcion que _process llama no se ve) y un set_process( en
# cualquier lugar del script lo salta entero.
func _avisar_redibujo(ruta: String, texto: String) -> void:
	if texto.contains("set_process(") or texto.contains("set_physics_process("):
		return
	var funcion: String = ""
	var dentro: bool = false
	var con_salida: bool = false
	var numero: int = 0
	for linea: String in texto.split("\n"):
		numero += 1
		if not linea.is_empty() and not linea.begins_with("\t"):
			funcion = "_process" if linea.begins_with("func _process(") else "_physics_process"
			dentro = linea.begins_with("func _process(") or linea.begins_with("func _physics_process(")
			con_salida = false
		elif dentro and _es_return(linea):
			con_salida = true
		elif dentro and not con_salida and not linea.begins_with("\t\t") and linea.contains("queue_redraw("):
			_avisos.append("%s:%d (queue_redraw() en %s sin una guarda: redibuja en cada cuadro)" % [ruta, numero, funcion])


# Una linea de GDScript que sale de la funcion: return solo o con valor, en su propia linea o tras un if ...:.
static func _es_return(linea: String) -> bool:
	var limpia: String = linea.strip_edges()
	return limpia == "return" or limpia.begins_with("return ") or limpia.ends_with(": return") or limpia.contains(": return ")


# Cada sala de contenido/ debe tener un guion (herramientas/guiones/) con una linea `escena <su ruta>`: el validador solo
# revisa los guiones que nombra un funciones.json, y una sala sin guion pasaria el CI sin que nada la corra. Aviso por
# ahora; falla cuando todas las salas de La Celda esten al dia (docs/contrato.md, «Avisos del validador»).
func _avisar_salas_sin_guion() -> void:
	var con_guion: Dictionary[String, bool] = {}
	for guion: String in _guiones_en(CARPETA_GUIONES):
		for linea: String in FileAccess.get_file_as_string(guion).split("
"):
			if linea.begins_with("escena "):
				con_guion[linea.trim_prefix("escena ").strip_edges()] = true
	for id: String in _salas:
		var ruta: String = _salas[id]["ruta"]
		if ruta.begins_with(CARPETA_CONTENIDO) and not con_guion.has(ruta):
			_avisos.append("%s (ningun guion de herramientas/guiones/ tiene `escena %s`: agregar el de la sala)" % [ruta, ruta])


# Los .guion bajo una carpeta, a cualquier profundidad.
func _guiones_en(carpeta: String) -> PackedStringArray:
	var encontrados: PackedStringArray = []
	for archivo: String in DirAccess.get_files_at(carpeta):
		if archivo.ends_with(".guion"):
			encontrados.append(carpeta + archivo)
	for subcarpeta: String in DirAccess.get_directories_at(carpeta):
		encontrados.append_array(_guiones_en(carpeta + subcarpeta + "/"))
	return encontrados


# Las rutas res:// y los uid:// que nombran los archivos revisados, armado una sola vez (en lugar de buscar cada imagen
# en todo el texto de todos los archivos).
func _citas_de_archivos() -> Dictionary[String, bool]:
	var citas: Dictionary[String, bool] = {}
	var patron: RegEx = RegEx.create_from_string("(?:res|uid)://[^\\s\"'\\]\\[(),{}]+")
	for ruta: String in _revisados:
		for coincidencia: RegExMatch in patron.search_all(FileAccess.get_file_as_string(ruta)):
			citas[coincidencia.get_string().rstrip(".:;")] = true
	return citas


# Una imagen de contenido/ que ninguna escena, recurso ni script nombra, por ruta o por uid, viaja en el paquete sin
# usarse: ocupa espacio en el APK sin que nada la cargue.
func _avisar_imagenes_sin_uso() -> void:
	if _imagenes_contenido.is_empty():
		return
	var citados: Dictionary[String, bool] = _citas_de_archivos()
	for imagen: String in _imagenes_contenido:
		var uid: String = uid_de(imagen)
		if not citados.has(imagen) and (uid.is_empty() or not citados.has(uid)):
			_avisos.append("%s (ninguna escena, recurso ni script la nombra: borrarla si no se usa)" % imagen)


# Cada AvisoAccion ensena una o dos acciones que existen en el InputMap: con un nombre mal escrito el pizarron
# quedaria en blanco sin aviso. Su id no se repite en la escena ni usa un prefijo reservado: dos avisos con el mismo
# id se apagarian juntos, y uno con el de coleccionable contaria como coleccionable.
func _revisar_avisos(ruta: String, raiz: Node) -> void:
	var avisos: Array[Node] = raiz.find_children("*", "AvisoAccion", true, false)
	var ids: Array[String] = []
	for nodo: Node in avisos:
		var aviso: AvisoAccion = nodo as AvisoAccion
		if aviso.modo == AvisoAccion.Modo.UNA_VEZ and aviso.id.is_empty():
			_fallos.append("%s (el aviso %s sale una vez en la partida y necesita id para recordarlo)" % [ruta, aviso.name])
		elif aviso.modo == AvisoAccion.Modo.POR_VISITA and not aviso.id.is_empty():
			_fallos.append("%s (el aviso %s sale en cada visita y no se recuerda: sin id)" % [ruta, aviso.name])
		if not aviso.id.is_empty():
			if ids.has(aviso.id):
				_fallos.append("%s (el aviso %s repite el id '%s')" % [ruta, aviso.name, aviso.id])
			if _id_reservado(aviso.id):
				_fallos.append("%s (el aviso %s usa un id reservado: %s)" % [ruta, aviso.name, aviso.id])
			ids.append(aviso.id)
		if aviso.acciones.is_empty() or aviso.acciones.size() > AvisoAccion.MAXIMO_ACCIONES:
			_fallos.append("%s (el aviso %s ensena %d acciones; van 1 o %d)" % [ruta, aviso.name, aviso.acciones.size(), AvisoAccion.MAXIMO_ACCIONES])
		for accion: StringName in aviso.acciones:
			if not InputMap.has_action(accion):
				_fallos.append("%s (el aviso %s nombra la accion '%s', que no esta en el InputMap)" % [ruta, aviso.name, accion])
	# Un boton por ensenar es un boton de la pantalla y algun aviso de la sala lo ensena: si no, el jugador se queda
	# sin el en tactil.
	var sala: Sala = raiz as Sala
	if sala != null:
		for accion: StringName in sala.botones_por_ensenar:
			if not ControlesTactiles.ACCIONES.has(accion):
				_fallos.append("%s (botones_por_ensenar nombra '%s', que no es un boton de la pantalla)" % [ruta, accion])
				continue
			var ensenado: bool = false
			for nodo: Node in avisos:
				if (nodo as AvisoAccion).acciones.has(accion):
					ensenado = true
			if not ensenado:
				_fallos.append("%s (el boton '%s' esta por ensenar y ningun aviso de la sala lo ensena)" % [ruta, accion])


# Cada Estacion va como hija directa de una sala con id, se llama estacion_<id de la sala> (una por sala), esta en la
# tabla de su sala (Estacion.tabla_de) con esa misma sala y cuesta 0 o mas. Si no, el viaje llevaria a una sala que no
# la tiene o el menu no la listaria.
func _revisar_estaciones(ruta: String, raiz: Node) -> void:
	var estaciones: Array[Node] = raiz.find_children("*", "Estacion", true, false)
	if estaciones.size() > 1:
		_fallos.append("%s (%d estaciones; va una por sala, con id estacion_<sala>)" % [ruta, estaciones.size()])
	for nodo: Node in estaciones:
		var estacion: Estacion = nodo as Estacion
		var sala: Sala = estacion.get_parent() as Sala
		if sala == null or sala != raiz or sala.id.is_empty():
			_fallos.append("%s (la estacion %s debe ser hija directa de una sala con id)" % [ruta, estacion.name])
			continue
		if estacion.id != Estacion.PREFIJO + sala.id:
			_fallos.append("%s (la estacion %s debe tener id %s%s; tiene '%s')" % [ruta, estacion.name, Estacion.PREFIJO, sala.id, estacion.id])
		if estacion.costo < 0:
			_fallos.append("%s (la estacion %s cuesta %d; debe costar 0 o mas)" % [ruta, estacion.name, estacion.costo])
		var tabla: FichaEstaciones = Estacion.tabla_de(sala.id)
		var dato: DatoEstacion = tabla.buscar(estacion.id) if tabla != null else null
		if dato == null:
			_fallos.append("%s (la estacion %s no esta en la tabla de estaciones de su sala)" % [ruta, estacion.id])
		elif dato.sala != sala.id:
			_fallos.append("%s (la tabla dice que la estacion %s esta en %s)" % [ruta, estacion.id, dato.sala])


# Cada Enemigo de una escena tiene ficha con id y vida, y un comportamiento que hereda de ComportamientoEnemigo (el id del
# ejemplar y que no se repita en la sala lo revisa _id_recordado). Sin esto el fallo solo salia con un push_error al correr.
func _revisar_enemigos(ruta: String, raiz: Node) -> void:
	for nodo: Node in _de_tipo(raiz, Enemigo, true):
		var enemigo: Enemigo = nodo as Enemigo
		if enemigo.ficha == null:
			# La raiz de una escena de enemigo (nucleo/enemigo.tscn, o una heredada) es la base: la ficha la pone quien la instancia.
			if enemigo != raiz:
				_fallos.append("%s (el enemigo %s no tiene ficha)" % [ruta, enemigo.name])
			continue
		if enemigo.ficha.id.is_empty():
			_fallos.append("%s (la ficha del enemigo %s no tiene id)" % [ruta, enemigo.name])
		if enemigo.ficha.vida <= 0:
			_fallos.append("%s (la ficha del enemigo %s tiene vida %d; debe ser mayor que 0)" % [ruta, enemigo.name, enemigo.ficha.vida])
		var comportamiento: GDScript = enemigo.ficha.comportamiento
		if comportamiento != null and not _hereda_de(comportamiento, ComportamientoEnemigo):
			_fallos.append("%s (el comportamiento de la ficha del enemigo %s no hereda de ComportamientoEnemigo)" % [ruta, enemigo.name])


# Si el script es la clase base o hereda de ella.
func _hereda_de(script: Script, base: Script) -> bool:
	var actual: Script = script
	while actual != null:
		if actual == base:
			return true
		actual = actual.get_base_script()
	return false


# Cada Tienda de una escena vende algo, y cada articulo tiene id sin repetir en su tienda (con el se marca comprado),
# precio mayor que 0 y una Recompensa. Las habilidades de los articulos las revisa _revisar_habilidades.
func _revisar_tiendas(ruta: String, raiz: Node) -> void:
	for nodo: Node in _de_tipo(raiz, Tienda, true):
		var tienda: Tienda = nodo as Tienda
		if tienda.articulos.is_empty():
			_fallos.append("%s (la tienda %s no vende nada)" % [ruta, tienda.name])
		var vistos: Dictionary = {}
		for articulo: ArticuloTienda in tienda.articulos:
			if articulo == null:
				_fallos.append("%s (la tienda %s tiene un articulo vacio)" % [ruta, tienda.name])
				continue
			if articulo.id.is_empty() or vistos.has(articulo.id):
				_fallos.append("%s (tienda %s: articulo '%s' sin id o con id repetido)" % [ruta, tienda.name, articulo.id])
			vistos[articulo.id] = true
			if articulo.precio <= 0:
				_fallos.append("%s (tienda %s: el articulo %s cuesta %d; debe costar mas de 0)" % [ruta, tienda.name, articulo.id, articulo.precio])
			if articulo.recompensa == null:
				_fallos.append("%s (tienda %s: el articulo %s no entrega nada)" % [ruta, tienda.name, articulo.id])


# Las tapas y lo que descubre un MuroRompible son dibujos fuera del muro (el muro se va al romperse y se los llevaria),
# ninguno en las dos listas, y lo descubierto sin fisica: visible no apaga un area ni su proceso
# (classes/class_canvasitem.rst:803), asi que lo que se toma va encerrado detras del muro, no oculto. Que cada ruta
# resuelva lo revisa _revisar_rutas_de_nodos; que sea un CanvasItem (o un Porton en una Palanca), el arreglo tipado,
# que da error al cargar.
func _revisar_muro(ruta: String, muro: MuroRompible) -> void:
	var dibujos: Array[CanvasItem] = []
	dibujos.append_array(muro.tapas)
	dibujos.append_array(muro.descubre)
	for dibujo: CanvasItem in dibujos:
		if dibujo != null and muro.is_ancestor_of(dibujo):
			_fallos.append("%s (el muro %s nombra a %s, que esta dentro del muro)" % [ruta, muro.name, dibujo.name])
	for dibujo: CanvasItem in muro.descubre:
		if dibujo == null:
			continue
		if muro.tapas.has(dibujo):
			_fallos.append("%s (el muro %s tapa y descubre a %s a la vez)" % [ruta, muro.name, dibujo.name])
		if dibujo is CollisionObject2D or not dibujo.find_children("*", "CollisionObject2D", true, false).is_empty():
			_fallos.append("%s (el muro %s descubre a %s, que tiene fisica: lo escondido va encerrado detras del muro)"
				% [ruta, muro.name, dibujo.name])


# Toda ruta de nodo que la escena guarda para una variable de script resuelve al instanciarla (tapas, descubre,
# portones, encendida, destello y las que vengan). Rota, Godot deja null sin una linea de error (medido el
# 27-oct-2026): se compara lo guardado en el SceneState (classes/class_scenestate.rst:384) con lo instanciado. Un
# export de nodo en null a proposito no guarda ruta y no cuenta.
func _revisar_rutas_de_nodos(ruta: String, escena: PackedScene, raiz: Node) -> void:
	var estado: SceneState = escena.get_state()
	for i: int in estado.get_node_count():
		var nodo: Node = raiz.get_node_or_null(estado.get_node_path(i))
		if nodo == null:
			continue
		for j: int in estado.get_node_property_count(i):
			var guardado: Variant = estado.get_node_property_value(i, j)
			if not (guardado is NodePath or guardado is Array):
				continue
			var propiedad: StringName = estado.get_node_property_name(i, j)
			if not _es_variable_de_script(nodo, propiedad):
				continue
			if _ruta_rota(nodo, guardado, nodo.get(propiedad)):
				_fallos.append("%s (%s.%s nombra un nodo que no existe)" % [ruta, estado.get_node_path(i), propiedad])


func _es_variable_de_script(nodo: Node, propiedad: StringName) -> bool:
	for datos: Dictionary in nodo.get_property_list():
		if datos["name"] == propiedad:
			var uso: int = datos["usage"]
			return uso & PROPERTY_USAGE_SCRIPT_VARIABLE != 0
	return false


# Una ruta guardada (o un arreglo de rutas) cuyo valor instanciado no llego: null en un export de nodo, o una NodePath
# exportada que no resuelve desde el nodo.
func _ruta_rota(nodo: Node, guardado: Variant, valor: Variant) -> bool:
	if guardado is NodePath:
		if valor is NodePath:
			return nodo.get_node_or_null(valor as NodePath) == null
		return valor == null
	var rutas: Array = guardado as Array
	var valores: Array = valor as Array if valor is Array else []
	for k: int in rutas.size():
		if not rutas[k] is NodePath:
			continue
		if k >= valores.size() or _ruta_rota(nodo, rutas[k], valores[k]):
			return true
	return false


# Id de un objeto que se recuerda en el estado de su sala (suelo fragil, muro rompible, palanca, porton, recogible,
# npc, reto, tienda, aviso): "" si el nodo no es de esos, "?" si lo es y no tiene id.
func _id_recordado(nodo: Node) -> String:
	var recogible: Recogible = nodo as Recogible
	if recogible != null and not recogible.recordado_por_id():
		return ""
	for clase: Script in _recordados_con_id:
		if is_instance_of(nodo, clase):
			var id: String = nodo.get(&"id")
			return id if not id.is_empty() else "?"
	# El aviso se recuerda con su id salvo en POR_VISITA; que UNA_VEZ lo lleve lo exige _revisar_avisos.
	var aviso: AvisoAccion = nodo as AvisoAccion
	if aviso != null:
		return aviso.id if aviso.modo != AvisoAccion.Modo.POR_VISITA else ""
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
	_revisar_encimes(nuevo.get(&"rectangulos") as Dictionary)


# Todas las zonas comparten un plano: cada una va en su franja (docs/contrato.md, «Sala», posicion_mapa) y una sala
# encimada con la de otra zona se pintaria encima en la vista alejada del mapa. Dentro de una zona tampoco se enciman:
# dos salas del mismo espacio no ocupan el mismo lugar, y el mapa pintaria una sobre la otra. Tocarse por un borde no
# es encimarse (classes/class_rect2.rst:464, intersects con include_borders en false).
func _revisar_encimes(rectangulos: Dictionary) -> void:
	var ids: Array = rectangulos.keys()
	for i: int in range(ids.size()):
		for j: int in range(i + 1, ids.size()):
			var a: String = ids[i]
			var b: String = ids[j]
			var rect_a: Rect2 = rectangulos[a]
			var rect_b: Rect2 = rectangulos[b]
			if not rect_a.intersects(rect_b):
				continue
			if Sala.zona_de(a) != Sala.zona_de(b):
				_fallos.append("res://mapa/indice_salas.tres (%s y %s son de zonas distintas y se enciman en el mapa: mover posicion_mapa)" % [a, b])
			else:
				_fallos.append("res://mapa/indice_salas.tres (%s y %s se enciman en el mapa: mover posicion_mapa)" % [a, b])


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
	# Cada sala de GRUPOS con su nombre y su detalle en SALAS, y SALAS sin salas que no esten en GRUPOS.
	var salas: Dictionary = constantes["SALAS"]
	var agrupadas: Array = []
	for categoria: String in grupos:
		agrupadas.append_array(grupos[categoria] as Array)
	for sala: String in agrupadas:
		var info: Array = salas.get(sala, [])
		if info.size() != 2 or (info[0] as String).is_empty() or (info[1] as String).is_empty():
			_fallos.append("%s (%s no tiene nombre y detalle en SALAS)" % [ZONA_PRUEBAS, sala])
	for sala: String in salas:
		if not agrupadas.has(sala):
			_fallos.append("%s (SALAS nombra %s, que no esta en GRUPOS)" % [ZONA_PRUEBAS, sala])


# Las pruebas de codigo no viajan en el paquete de publicacion (exclude_filter de «Publicacion», docs/contrato.md,
# «Paquete de publicacion»): un script, escena o recurso de fuera, o project.godot, que nombre una por su ruta o por
# su uid cargaria en el APK algo que no esta. Este script se salta: nombra la carpeta para buscarla.
func _revisar_pruebas_aparte() -> void:
	var buscados: PackedStringArray = [CARPETA_PRUEBAS_CODIGO]
	for archivo: String in DirAccess.get_files_at(CARPETA_PRUEBAS_CODIGO):
		if not ["gd", "tscn", "tres"].has(archivo.get_extension()):
			continue
		var uid: int = ResourceLoader.get_resource_uid(CARPETA_PRUEBAS_CODIGO + archivo)
		if uid != ResourceUID.INVALID_ID:
			buscados.append(ResourceUID.id_to_text(uid))
	var propio: String = (get_script() as Script).resource_path
	var rutas: PackedStringArray = _revisados.duplicate()
	rutas.append("res://project.godot")
	for ruta: String in rutas:
		if ruta.begins_with(CARPETA_PRUEBAS_CODIGO) or ruta == propio:
			continue
		var texto: String = FileAccess.get_file_as_string(ruta)
		for buscado: String in buscados:
			if texto.contains(buscado):
				_fallos.append("%s (nombra %s, de herramientas/pruebas/, que no viaja en el paquete de publicacion)" % [ruta, buscado])
				break


# Puertas de ida y vuelta entre salas con id: si A lleva a la puerta P de B, B tiene la puerta P y lleva de
# vuelta a la misma puerta de A. Salvo una puerta ABAJO (una caida, el tiro de una sala): es de ida sola y basta que P
# exista, porque la sala de abajo la usa como llegada (Sala._puerta_con_id). Exigir la vuelta obligaria a poner abajo
# una puerta ARRIBA a la que no se llega y cuya llegada quedaria sobre el hueco, que devuelve al jugador a la caida.
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
			if not otras.has(puerta_destino):
				_fallos.append("sala %s, puerta %s: %s no tiene la puerta %s" % [id, id_puerta, por_ruta[ruta_destino], puerta_destino])
				continue
			var tipo: int = destino[2]
			if tipo == Puerta.Tipo.ABAJO:
				continue
			var vuelta: Array = otras[puerta_destino]
			if vuelta[0] != _salas[id]["ruta"] or vuelta[1] != id_puerta:
				_fallos.append("sala %s, puerta %s: %s no tiene la puerta %s de vuelta a ella" % [id, id_puerta, por_ruta[ruta_destino], puerta_destino])
