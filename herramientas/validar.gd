extends Node
# Carga cada script, escena y recurso del proyecto con los autoloads activos
# y sale con 1 si alguno no carga. Imprime solo los fallos y un resumen.
# Existe porque Godot sale con 0 aunque un script no compile. Ademas revisa las salas con id (contenido/salas y
# las zonas de prueba): id igual al archivo, puertas de ida y vuelta, bancos con su id, Entrada dentro y
# objetos recordados (suelo fragil, coleccionable, npc, reto de preguntas) con id unico. Revisa tambien la forma de
# cada FichaDialogo y FichaPregunta, y de los Npc y RetoPreguntas de cualquier escena. En cualquier escena, un DanoContacto que se mueve
# (dentro de un Vaiven, un enemigo o un cuerpo que se mueve) no puede ser peligro. Las tablas de la zona de pruebas
# (GRUPOS y OCULTAS) solo nombran escenas que existen. Ninguna imagen pasa de 2048 px por lado. Cada puerta lleva a un
# destino que existe, por id si es una sala con id; cada puerta en el borde lleva su pared detras; cada id de habilidad esta en Habilidades.TODAS; el arte del
# mundo se importa con mipmaps y en VRAM solo sin transparencia.
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
# Cada .gd, .tscn y .tres revisado, para _revisar_pruebas_aparte.
var _revisados: PackedStringArray = []


func _ready() -> void:
	_recorrer("res://")
	_revisar_puertas()
	_revisar_indice_mapa()
	_revisar_zona_pruebas()
	_revisar_pruebas_aparte()
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
		elif IMAGENES.has(ext):
			_revisar_imagen(ruta.path_join(archivo))


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
	var recurso: Resource = ResourceLoader.load(ruta)
	if recurso == null:
		_fallos.append(ruta + " (no carga)")
	elif recurso is GDScript:
		if not (recurso as GDScript).can_instantiate():
			_fallos.append(ruta + " (script con errores)")
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
				if _es_carpeta_de_salas(ruta):
					_revisar_sala(ruta, nodo)
				else:
					for puerta: Node in nodo.find_children("*", "Puerta", true, false):
						_destino_de_puerta(ruta, puerta as Puerta)
				if nodo is Sala:
					_revisar_presupuesto(ruta, nodo)
					_revisar_pared_tras_puerta(ruta, nodo as Sala)
				_revisar_peligros(ruta, nodo)
				_revisar_habilidades(ruta, nodo)
				_revisar_npcs(ruta, nodo)
				_revisar_tiendas(ruta, nodo)
				_revisar_avisos(ruta, nodo)
				_revisar_estaciones(ruta, nodo)
				nodo.free()


# Fichas de datos que traen su propio fallos() (BolsaPreguntas es la de la mochila): el validador anota cada fallo con
# la ruta del recurso.
var _fichas_con_fallos: Array[Script] = [FichaDialogo, FichaPregunta, BolsaPreguntas, FichaEstaciones]


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
## Tolerancia en px para decidir que algo toca un borde.
const TOLERANCIA_BORDE: float = 1.0


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


# Presupuesto de una sala (seccion 8 del plan de cierre del nucleo, medido para el S50): a lo mas 3 emisores de
# particulas con 60 particulas entre todos, 30 plantas, ninguna luz 2D y 2 capas translucidas grandes (cada capa
# translucida se pinta encima de lo de atras: el costo es el area, gpu_optimization.rst).
const MAXIMO_EMISORES: int = 3
const MAXIMO_PARTICULAS: int = 60
const MAXIMO_PLANTAS: int = 30
const MAXIMO_CAPAS_TRANSLUCIDAS: int = 2
## Una capa es grande si cubre al menos un cuarto de la vista base (1280x720).
const AREA_CAPA_GRANDE: float = 1280.0 * 720.0 / 4.0


func _revisar_presupuesto(ruta: String, sala: Node) -> void:
	var emisores: int = 0
	var particulas: int = 0
	var plantas: int = 0
	var capas: PackedStringArray = []
	for nodo: Node in sala.find_children("*", "", true, false):
		if nodo is CPUParticles2D or nodo is GPUParticles2D:
			emisores += 1
			particulas += (nodo as CPUParticles2D).amount if nodo is CPUParticles2D else (nodo as GPUParticles2D).amount
		elif nodo is Planta:
			plantas += 1
		elif nodo is Light2D:
			_fallos.append("%s (%s: sin luces 2D, el renderer Compatibility las cobra caras)" % [ruta, nodo.name])
		elif nodo is CanvasItem and _es_capa_translucida_grande(nodo as CanvasItem, sala):
			capas.append(nodo.name)
	if emisores > MAXIMO_EMISORES or particulas > MAXIMO_PARTICULAS:
		_fallos.append("%s (%d emisores y %d particulas: el maximo es %d y %d)" % [ruta, emisores, particulas, MAXIMO_EMISORES, MAXIMO_PARTICULAS])
	if plantas > MAXIMO_PLANTAS:
		_fallos.append("%s (%d plantas: el maximo es %d)" % [ruta, plantas, MAXIMO_PLANTAS])
	if capas.size() > MAXIMO_CAPAS_TRANSLUCIDAS:
		_fallos.append("%s (%d capas translucidas grandes, %s: el maximo es %d)" % [ruta, capas.size(), ", ".join(capas), MAXIMO_CAPAS_TRANSLUCIDAS])


# Capa translucida grande: un Sprite2D, TextureRect, ColorRect, NinePatchRect o Polygon2D visible, con alfa efectivo
# (el de su color si es ColorRect o Polygon2D, por su self_modulate y por el modulate de el y de sus padres) menor
# que 1 y un area, con la escala de sus padres, de al menos AREA_CAPA_GRANDE. Se mide sin el arbol (el validador no
# agrega la sala): por eso la escala se acumula a mano y el tamano de un Control sale de sus anclas (_tamano_control).
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
	var escala: Vector2 = Vector2.ONE
	var nodo: Node = item
	while nodo != null and nodo != sala.get_parent() and not (nodo is CanvasLayer):
		if nodo is CanvasItem:
			if not (nodo as CanvasItem).visible:
				return false
			alfa *= (nodo as CanvasItem).modulate.a
		if nodo is Node2D:
			escala *= (nodo as Node2D).scale.abs()
		elif nodo is Control:
			escala *= (nodo as Control).scale.abs()
		nodo = nodo.get_parent()
	if nodo is CanvasLayer and not (nodo as CanvasLayer).visible:
		return false
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
		_revisar_rutas_de_secretos(ruta, anidado)
	for hijo: Node in sala.get_children():
		var puerta: Puerta = hijo as Puerta
		if puerta != null:
			if puerta.id.is_empty() or puertas.has(String(puerta.id)):
				_fallos.append("%s (puerta %s sin id o con id repetido)" % [ruta, puerta.name])
			else:
				var destino: String = _destino_de_puerta(ruta, puerta)
				if not destino.is_empty():
					puertas[String(puerta.id)] = [destino, String(puerta.puerta_destino)]
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


# Cada AvisoAccion ensena una o dos acciones que existen en el InputMap: con un nombre mal escrito el pizarron
# quedaria en blanco sin aviso. Su id no se repite en la escena ni usa un prefijo reservado: dos avisos con el mismo
# id se apagarian juntos, y uno con el de coleccionable contaria como coleccionable.
func _revisar_avisos(ruta: String, raiz: Node) -> void:
	var avisos: Array[Node] = raiz.find_children("*", "AvisoAccion", true, false)
	var ids: Array[String] = []
	for nodo: Node in avisos:
		var aviso: AvisoAccion = nodo as AvisoAccion
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


# Cada ruta de portones de una Palanca lleva a un Porton y cada tapa de un MuroRompible a un dibujo: una ruta rota
# dejaria la palanca sin abrir nada o el secreto a la vista, sin aviso.
func _revisar_rutas_de_secretos(ruta: String, nodo: Node) -> void:
	var palanca: Palanca = nodo as Palanca
	if palanca != null:
		for destino: NodePath in palanca.portones:
			if not palanca.get_node_or_null(destino) is Porton:
				_fallos.append("%s (la palanca %s abre %s, que no es un Porton)" % [ruta, palanca.name, destino])
	var muro: MuroRompible = nodo as MuroRompible
	if muro != null:
		for destino: NodePath in muro.tapas:
			if not muro.get_node_or_null(destino) is CanvasItem:
				_fallos.append("%s (el muro %s tapa con %s, que no es un dibujo)" % [ruta, muro.name, destino])


# Clases que se recuerdan en el estado de su sala y necesitan id; todas lo declaran como String. El aviso va aparte:
# su id es opcional.
var _recordados_con_id: Array[Script] = [SueloFragil, MuroRompible, Palanca, Porton, Coleccionable, Npc, RetoPreguntas, Tienda]


# Id de un objeto que se recuerda en el estado de su sala (suelo fragil, muro rompible, palanca, porton, coleccionable,
# npc, reto, tienda, aviso): "" si el nodo no es de esos, "?" si lo es y no tiene id.
func _id_recordado(nodo: Node) -> String:
	for clase: Script in _recordados_con_id:
		if is_instance_of(nodo, clase):
			var id: String = nodo.get(&"id")
			return id if not id.is_empty() else "?"
	# El id del aviso es opcional: sin id vuelve en cada visita y no se recuerda.
	var aviso: AvisoAccion = nodo as AvisoAccion
	if aviso != null:
		return aviso.id
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
const CARPETA_PRUEBAS_CODIGO: String = "res://herramientas/pruebas/"


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
