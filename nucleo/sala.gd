class_name Sala
extends Node2D
# Raiz de toda sala: al entrar crea al jugador (en la puerta por la que llega o en Entrada), le
# pasa los limites para la camara y pone los controles tactiles, la pausa, el marco de menus con sus paginas, la vibracion, el fundido
# a negro (empieza en negro y aclara), el contador de FPS (que tambien pone el limite de FPS), el panel de pruebas y ver
# hitbox (solo con el modo desarrollador), la interfaz y el mapa. Si el jugador muere, funde a negro y lo hace
# reaparecer en el ultimo banco (o en Entrada) con las vidas llenas.
const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const ESCENA_CONTROLES: PackedScene = preload("res://nucleo/controles_tactiles.tscn")
const ESCENA_PAUSA: PackedScene = preload("res://nucleo/pausa.tscn")
## La interfaz y el mapa son de otros bloques: se cargan con load() solo si existen, asi el nucleo corre sin ellos.
const INTERFAZ: String = "res://interfaz/interfaz.tscn"
const MAPA: String = "res://mapa/pantalla_mapa.tscn"
## Ticks que el jugador muerto se queda en pantalla (oscuro) antes de reaparecer: 1,5 s.
const TICKS_PARA_REAPARECER: int = 90
## Lo que el Fondo de la sala se extiende fuera de limites, en px. Cubre el rango de la vista (4:3 a
## 22:9) con la camara centrada en una sala minima de 1280x720: (1760 - 1280) / 2 = 240 a lo ancho y
## (960 - 720) / 2 = 120 a lo alto, mas 40 para el temblor de la camara (20 px). Asi lo que se ve fuera
## de la sala es su fondo, no un borde.
const MARGEN_FONDO: float = 280.0

## Id de la puerta por la que llega el jugador a la proxima sala; vacio al empezar una partida.
## Es estatica porque sobrevive al cambio de escena sin necesitar un autoload.
static var puerta_llegada: StringName = &""
## Verdadero si el jugador debe aparecer en el banco Partida.banco de la proxima sala.
static var llegada_a_banco: bool = false
## Id de la Estacion donde aparece el jugador en la proxima sala (viaje rapido); manda sobre puerta_llegada.
static var estacion_llegada: String = ""
## Time.get_ticks_msec() cuando una puerta pidio el cambio de escena; -1 si no hay uno en curso. En un build de
## depuracion, el primer tick de la sala nueva imprime cuanto tardo (decision del 14-oct-2026: se mide en el S50
## antes de pensar en cargar en segundo plano).
static var cambio_pedido_ms: int = -1

## Carpeta de las salas del juego: contenido/salas/<zona>/<id>.tscn.
const CARPETA_CONTENIDO: String = "res://contenido/salas/"
## Carpeta de las zonas de prueba, con la misma forma. El juego no depende de ella: solo se usa si existe.
const CARPETA_PRUEBAS: String = "res://herramientas/salas/zonas/"

## Id de la sala, `<zona>_<numero>` (celda_1), igual al nombre de su archivo: es lo que guardan la partida y el
## mapa. Vacio en las salas de prueba sueltas, que se identifican por su ruta.
@export var id: String = ""
## Rectangulo de la sala en sus coordenadas: la camara no muestra nada fuera de el.
@export var limites: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)
## Solo salas de prueba: habilidades que la sala da en silencio al entrar (sin aviso ni autoguardado), para
## probar algo sin conseguirlo antes. Una sala del juego la deja vacia (lo revisa el validador).
@export var habilidades_de_prueba: Array[StringName] = []
## Botones de la pantalla que en esta sala no se ven hasta que un AvisoAccion los ensena (Partida.botones_ensenados):
## la sala Pizarrones empieza sin saltar, atacar ni curar. Solo tactil; el validador exige que un aviso de la sala ensene cada uno.
@export var botones_por_ensenar: Array[StringName] = []
## Esquina de la sala en el mapa del mundo, en px: el mapa la dibuja en posicion_mapa + limites. Las salas de una
## zona se acomodan como se recorren (la de la derecha empieza donde acaba la otra).
@export var posicion_mapa: Vector2 = Vector2.ZERO
## Oscuridad de la sala, de 0 (sin cambio) a 1 (negro): la aplica el Brillo de la sala, multiplicando, sin dibujar
## nada encima (una capa oscura encima costaba 2,2 FPS en el S50). Las LuzSala la aclaran con su halo aditivo y, con
## las luces 2D, con su PointLight2D.
@export_range(0.0, 1.0, 0.01) var oscuridad: float = 0.0

var _ticks_para_reaparecer: int = 0


## Ruta de la escena de una sala a partir de su id: celda_1 -> res://contenido/salas/celda/celda_1.tscn (o la zona
## de prueba con ese nombre, si existe). Una ruta res:// se devuelve tal cual: las salas de prueba sueltas guardan su ruta.
static func ruta_de(id_o_ruta: String) -> String:
	if id_o_ruta.begins_with("res://"):
		return id_o_ruta
	var zona: String = zona_de(id_o_ruta)
	if zona.is_empty():
		push_error("Sala.ruta_de: '%s' no es un id de sala ni una ruta" % id_o_ruta)
		return ""
	var ruta: String = CARPETA_CONTENIDO + zona + "/" + id_o_ruta + ".tscn"
	if ResourceLoader.exists(ruta):
		return ruta
	var prueba: String = CARPETA_PRUEBAS + zona + "/" + id_o_ruta + ".tscn"
	return prueba if ResourceLoader.exists(prueba) else ruta


## Zona de un id de sala: lo que va antes del primer guion bajo (celda_1 -> celda). Vacio si no es un id.
static func zona_de(id_o_ruta: String) -> String:
	if id_o_ruta.begins_with("res://") or not id_o_ruta.contains("_"):
		return ""
	return id_o_ruta.get_slice("_", 0)


## Como se nombra esta sala en la partida y el mapa: su id o, en una sala de prueba suelta, su ruta.
func clave() -> String:
	return id if not id.is_empty() else scene_file_path


## Clave de la sala a la que pertenece un nodo de su escena (su owner); vacia si no esta en una sala.
static func clave_de(nodo: Node) -> String:
	var sala: Sala = nodo.owner as Sala
	if sala == null:
		sala = nodo.get_parent() as Sala
	return sala.clave() if sala != null else ""


func _ready() -> void:
	_extender_fondo()
	Congelado.reiniciar()
	for habilidad: StringName in habilidades_de_prueba:
		if not Partida.tiene(habilidad):
			Partida.habilidades.append(habilidad)
	Partida.visitar(clave())
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.position = _punto_de_llegada()
	# Si manda la estacion, no se llego por una puerta: cambio_de_sala no se emite.
	var puerta: StringName = puerta_llegada if estacion_llegada.is_empty() else &""
	puerta_llegada = &""
	llegada_a_banco = false
	estacion_llegada = ""
	add_child(jugador)
	jugador.fijar_limites(limites)
	_poner_mochila()
	add_child(ESCENA_CONTROLES.instantiate())
	add_child(ESCENA_PAUSA.instantiate())
	# El marco de menus y sus paginas del nucleo; la pagina Mapa la agrega el bloque mapa si existe (abajo).
	var marco: MarcoMenus = MarcoMenus.new()
	marco.name = &"Marco"
	add_child(marco)
	var inventario: PaginaInventario = PaginaInventario.new()
	inventario.name = &"Inventario"
	add_child(inventario)
	var amuletos: PantallaAmuletos = PantallaAmuletos.new()
	amuletos.name = &"Amuletos"
	add_child(amuletos)
	var fundido: Fundido = Fundido.new()
	fundido.name = &"Fundido"
	add_child(fundido)
	fundido.empezar_en_negro()
	var vibracion: Vibracion = Vibracion.new()
	vibracion.name = &"Vibracion"
	add_child(vibracion)
	var brillo: Brillo = Brillo.new()
	brillo.name = &"Brillo"
	brillo.oscuridad = oscuridad
	add_child(brillo)
	add_child(ContadorFps.new())
	add_child(PanelPruebas.new())
	add_child(VerHitbox.new())
	for ruta: String in [INTERFAZ, MAPA]:
		if ResourceLoader.exists(ruta):
			var escena: PackedScene = load(ruta) as PackedScene
			add_child(escena.instantiate())
	Eventos.jugador_muerto.connect(_al_morir_el_jugador)
	if not puerta.is_empty():
		Eventos.cambio_de_sala.emit(clave(), puerta)


# Si la sala tiene un Fondo visible, crea detras de todo un rectangulo de su color MARGEN_FONDO px mas
# grande por lado. Sin Fondo (o con el Fondo oculto, como la sala de capas), no hace nada: lo de fuera
# se ve con el color de borrado, negro (nucleo/arranque.gd).
func _extender_fondo() -> void:
	var fondo: ColorRect = get_node_or_null(^"Fondo") as ColorRect
	if fondo == null or not fondo.visible:
		return
	var extendido: ColorRect = ColorRect.new()
	extendido.name = &"FondoExtendido"
	extendido.color = fondo.color
	extendido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	extendido.z_index = RenderingServer.CANVAS_ITEM_Z_MIN
	var area: Rect2 = limites.grow(MARGEN_FONDO)
	extendido.position = area.position
	extendido.size = area.size
	add_child(extendido)
	move_child(extendido, 0)


# Lo perdido al morir aparece en su sala, donde quedo (Partida.mochila).
func _poner_mochila() -> void:
	if Partida.mochila.is_empty() or str(Partida.mochila.get("sala", "")) != clave():
		return
	var mochila: Mochila = Mochila.new()
	mochila.name = &"Mochila"
	mochila.position = Partida.punto_de_mochila()
	add_child(mochila)


# Se reaparece en el ultimo banco donde se descanso; si no hay, en la Entrada de esta sala.
func _al_morir_el_jugador() -> void:
	_ticks_para_reaparecer = TICKS_PARA_REAPARECER


func _physics_process(_delta: float) -> void:
	if cambio_pedido_ms >= 0:
		if OS.is_debug_build():
			print("SALA %s carga_ms=%d" % [clave(), Time.get_ticks_msec() - cambio_pedido_ms])
		cambio_pedido_ms = -1
	if _ticks_para_reaparecer == 0:
		return
	_ticks_para_reaparecer -= 1
	# Los ultimos ticks oscuro, la pantalla funde a negro; la sala siguiente (o esta, recargada) aclara.
	if _ticks_para_reaparecer == Fundido.TICKS_OSCURECER:
		Eventos.fundido_pedido.emit(Fundido.TICKS_OSCURECER, 0, 0)
	if _ticks_para_reaparecer == 0:
		Partida.llenar_vidas()
		puerta_llegada = &""
		estacion_llegada = ""
		if Partida.sala.is_empty():
			get_tree().reload_current_scene()
		else:
			var ruta: String = Sala.ruta_de(Partida.sala)
			if ResourceLoader.exists(ruta):
				llegada_a_banco = true
				get_tree().change_scene_to_file(ruta)
			else:
				push_error("Sala: la sala del banco '%s' no existe; se reaparece aqui" % Partida.sala)
				get_tree().reload_current_scene()


func _punto_de_llegada() -> Vector2:
	if llegada_a_banco:
		for hijo: Node in get_children():
			var banco: Banco = hijo as Banco
			if banco != null and banco.id == Partida.banco:
				return banco.position
		push_error("Sala %s: no hay un banco con id '%s'" % [scene_file_path, Partida.banco])
	elif not estacion_llegada.is_empty():
		# Si una puerta y una estacion piden a la vez, manda la estacion: el viaje es lo ultimo que se pidio.
		for hijo: Node in get_children():
			var estacion: Estacion = hijo as Estacion
			if estacion != null and estacion.id == estacion_llegada:
				return estacion.position + estacion.llegada
		push_error("Sala %s: no hay una estacion con id '%s'" % [scene_file_path, estacion_llegada])
	elif not puerta_llegada.is_empty():
		for hijo: Node in get_children():
			var puerta: Puerta = hijo as Puerta
			if puerta != null and puerta.id == puerta_llegada:
				return puerta.position + puerta.llegada
		push_error("Sala %s: no hay una puerta con id '%s'" % [scene_file_path, puerta_llegada])
	var entrada: Node2D = get_node_or_null(^"Entrada") as Node2D
	return entrada.position if entrada != null else Vector2.ZERO
