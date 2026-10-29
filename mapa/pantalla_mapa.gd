class_name PantallaMapa
extends PaginaMarco
# Pantalla del mapa, como en Hollow Knight y Silksong: es la pagina Mapa del marco de menus (MarcoMenus, que la
# abre con la accion mapa y detiene el juego) y mapa_rapido, mantenida, la muestra encima mientras se camina. Dos
# estados, alejado y acercado, con + y -. Sin la habilidad pluma_mapa no hay nada dibujado; el jugador se ve solo
# con el amuleto brujula equipado. La carga la sala con load() si existe: el nucleo no depende de este bloque.

const PLUMA: StringName = Habilidades.PLUMA_MAPA
const BRUJULA: StringName = &"brujula"

## Mapa rapido a la vista (el mapa completo en el marco es abierta, de PaginaMarco). Publica para los guiones.
var rapido: bool = false
## Estado del mapa completo: acercado a la zona actual o alejado con todas.
var acercado: bool = true
## El lienzo; publico para que la prueba lea lo dibujado.
var lienzo: LienzoMapa = null

var _indice: IndiceSalas = null
var _botones: HBoxContainer = null
var _menos: Button = null
# Si la ultima vista se dibujo con la brujula equipada: equiparla o quitarla con el mapa rapido a la vista rehace todo.
var _con_brujula: bool = false
# Si mapa_rapido empezo a sostenerse con el juego andando. LB es tambien pagina_anterior: sostenido desde el marco o
# la pausa, al cerrarlos no debe mostrar el mapa rapido hasta soltarlo y volver a pulsarlo.
var _armado: bool = false


func _ready() -> void:
	super()
	# La sala crea esta pantalla de nuevo al cruzar una puerta: mapa_rapido sostenido desde la sala anterior, con el
	# juego andando, sigue mostrandolo. Con el marco o la pausa abiertos la sala no cambia, asi que no reabre el fallo.
	_armado = Input.is_action_pressed(&"mapa_rapido") and not get_tree().paused
	_indice = IndiceSalas.cargar()
	# El fondo lleva el tema de los menus y es la raiz de la rama de UI: el lienzo y + y - cuelgan de el. No detiene
	# los toques: el mapa rapido se ve mientras se juega.
	var fondo: ColorRect = Tema.fondo_menu()
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)
	lienzo = LienzoMapa.new()
	lienzo.set_anchors_preset(Control.PRESET_FULL_RECT)
	lienzo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.add_child(lienzo)
	_botones = HBoxContainer.new()
	_botones.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_botones.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_botones.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_botones.position = Vector2(-24.0, -24.0)
	_botones.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	fondo.add_child(_botones)
	# Raya corta (U+2013) y no el signo menos (U+2212): Cabin Sketch no tiene el menos y salia en otra fuente.
	_menos = _boton("–", alejar)
	_boton("+", acercar)
	Eventos.descanso_en_banco.connect(_al_descansar)


func _boton(texto: String, al_tocar: Callable) -> Button:
	var boton: Button = Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(120.0, Tema.ALTO_TOQUE)
	boton.theme_type_variation = Tema.SIMBOLO
	boton.pressed.connect(al_tocar)
	_botones.add_child(boton)
	return boton


# El mapa rapido lee su accion: lo muestran igual el teclado, el control y un guion. Con el juego detenido (el marco
# o la pausa abiertos) no responde, y solo se arma si la accion empezo con el juego andando. Depende de correr antes
# que el marco y la pausa (prioridad 0 frente a MarcoMenus.PRIORIDAD_FISICA): en el tick en que cierran aun ve la pausa.
func _physics_process(_delta: float) -> void:
	var pulsada: bool = Input.is_action_pressed(&"mapa_rapido")
	var andando: bool = not get_tree().paused
	if not pulsada or not andando:
		_armado = false
	elif Input.is_action_just_pressed(&"mapa_rapido"):
		_armado = true
	if not abierta:
		var mantiene: bool = _armado
		if mantiene != rapido:
			rapido = mantiene
			_mostrar()
	if rapido:
		_seguir_jugador()


func id_pagina() -> StringName:
	return &"mapa"


func titulo_pagina() -> String:
	return "Mapa"


## El marco la muestra con el juego ya detenido: el mapa completo, acercado a la zona actual.
func mostrar_en_marco() -> void:
	abierta = true
	rapido = false
	acercado = true
	_mostrar()
	Tema.dar_foco(_menos)


func ocultar_de_marco() -> void:
	if not abierta:
		return
	abierta = false
	_mostrar()


func acercar() -> void:
	acercado = true
	_mostrar()


func alejar() -> void:
	acercado = false
	_mostrar()


# Con el mapa rapido a la vista, cada tick solo se mueve el marcador: el mapa no se rehace ni se redibuja. Equipar o
# quitar la brujula a la vista lo rehace una vez.
func _seguir_jugador() -> void:
	if Partida.amuletos_equipados.has(BRUJULA) != _con_brujula:
		_mostrar()
		return
	if not _con_brujula:
		return
	var sala: Sala = get_parent() as Sala
	if sala == null:
		return
	var jugador: Node2D = get_tree().get_first_node_in_group(Jugador.GRUPO) as Node2D
	if jugador != null:
		lienzo.mover_marcador(sala.posicion_mapa + jugador.position)


# Descansar dibuja salas nuevas en el mapa: si se ve, se rehace despues de que Partida las anote con la misma senal.
func _al_descansar(_banco: StringName) -> void:
	if visible:
		_mostrar.call_deferred()


func _mostrar() -> void:
	visible = abierta or rapido
	_botones.visible = abierta
	# En el marco, la barra de arriba tapa esa franja: el mapa se encaja debajo.
	lienzo.offset_top = MarcoMenus.ALTO_BARRA if abierta else 0.0
	_con_brujula = Partida.amuletos_equipados.has(BRUJULA)
	if not visible:
		lienzo.soltar_texturas()
		return
	var sala: Sala = get_parent() as Sala
	var zona_actual: String = Sala.zona_de(sala.id) if sala != null and not sala.id.is_empty() else ""
	var mapeadas: Array[String] = Partida.salas_mapeadas if Partida.tiene(PLUMA) else ([] as Array[String])
	var zonas: Dictionary[String, Array] = DatosMapa.por_zona(_indice, mapeadas)
	var marcador: Vector2 = Vector2.ZERO
	var con_marcador: bool = false
	if sala != null and _indice.rectangulos.has(sala.id) and Partida.amuletos_equipados.has(BRUJULA):
		var jugador: Node2D = get_tree().get_first_node_in_group(Jugador.GRUPO) as Node2D
		if jugador != null:
			marcador = sala.posicion_mapa + jugador.position
			con_marcador = true
	var sala_mochila: String = str(Partida.mochila.get("sala", ""))
	var punto_mochila: Vector2 = Partida.punto_de_mochila()
	lienzo.dibujar(_indice, zonas, zona_actual, acercado or rapido, con_marcador, marcador, sala_mochila, punto_mochila)
