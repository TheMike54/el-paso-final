class_name PantallaMapa
extends CanvasLayer
# Pantalla del mapa, como en Hollow Knight y Silksong: la accion mapa abre el mapa completo (detiene el juego) y
# mapa_rapido, mantenida, lo muestra encima mientras se camina. Dos estados, alejado y acercado, con + y -. Sin
# la habilidad pluma_mapa no hay nada dibujado; el jugador se ve solo con el amuleto brujula equipado. La carga
# la sala con load() si existe: el nucleo no depende de este bloque. No conoce ninguna zona.

const GRUPO: StringName = &"pantalla_encima"
const PLUMA: StringName = &"pluma_mapa"
const BRUJULA: StringName = &"brujula"

## Mapa completo abierto (juego detenido) y mapa rapido a la vista. Publicas para los guiones.
var abierta: bool = false
var rapido: bool = false
## Estado del mapa completo: acercado a la zona actual o alejado con todas.
var acercado: bool = true
## El lienzo; publico para que la prueba lea lo dibujado.
var lienzo: LienzoMapa = null

var _indice: IndiceSalas = null
var _tick_cerrada: int = -10
var _botones: HBoxContainer = null
var _mas: Button = null
var _menos: Button = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	add_to_group(GRUPO)
	_indice = IndiceSalas.cargar()
	var fondo: ColorRect = ColorRect.new()
	fondo.color = Color(0.0, 0.0, 0.0, 0.85)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)
	lienzo = LienzoMapa.new()
	lienzo.set_anchors_preset(Control.PRESET_FULL_RECT)
	lienzo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lienzo)
	_botones = HBoxContainer.new()
	_botones.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_botones.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_botones.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_botones.position = Vector2(-24.0, -24.0)
	_botones.add_theme_constant_override(&"separation", 16)
	add_child(_botones)
	_menos = _boton("−", alejar)
	_mas = _boton("+", acercar)
	_boton("Cerrar", cerrar)
	visible = false


func _boton(texto: String, al_tocar: Callable) -> Button:
	var boton: Button = Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(120.0, 96.0)
	boton.add_theme_font_size_override(&"font_size", 40)
	boton.pressed.connect(al_tocar)
	_botones.add_child(boton)
	return boton


# Se leen acciones con nombre, como la pausa: las abren igual el teclado, el control, el boton tactil y un guion.
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"mapa"):
		alternar()
	elif abierta and Input.is_action_just_pressed(&"pausa"):
		cerrar()
	elif not abierta:
		var mantiene: bool = Input.is_action_pressed(&"mapa_rapido") and not get_tree().paused
		if mantiene != rapido:
			rapido = mantiene
			_mostrar()
	# Con la brujula, el marcador sigue al jugador mientras el mapa rapido esta a la vista.
	if rapido and Partida.amuletos_equipados.has(BRUJULA):
		_mostrar()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST and abierta:
		cerrar()


func alternar() -> void:
	if abierta:
		cerrar()
	else:
		abrir()


## Abre el mapa completo, salvo con el juego ya detenido (la pausa abierta).
func abrir() -> void:
	if abierta or get_tree().paused:
		return
	abierta = true
	rapido = false
	acercado = true
	get_tree().paused = true
	_mostrar()
	_menos.grab_focus()


func cerrar() -> void:
	if not abierta:
		return
	abierta = false
	_tick_cerrada = Engine.get_physics_frames()
	get_tree().paused = false
	_mostrar()


func acercar() -> void:
	acercado = true
	_mostrar()


func alejar() -> void:
	acercado = false
	_mostrar()


## La pausa no se abre con el mapa abierto ni en el tick en que se cerro (la misma pulsacion de pausa o Atras).
func bloquea_pausa() -> bool:
	return abierta or Engine.get_physics_frames() == _tick_cerrada


func _mostrar() -> void:
	visible = abierta or rapido
	_botones.visible = abierta
	if not visible:
		return
	var sala: Sala = get_parent() as Sala
	var zona_actual: String = Sala.zona_de(sala.id) if sala != null and not sala.id.is_empty() else ""
	var mapeadas: Array[String] = Partida.salas_mapeadas if Partida.tiene(PLUMA) else ([] as Array[String])
	var zonas: Dictionary[String, Array] = DatosMapa.por_zona(_indice, mapeadas)
	var marcador: Vector2 = Vector2.ZERO
	var con_marcador: bool = false
	if sala != null and _indice.rectangulos.has(sala.id) and Partida.amuletos_equipados.has(BRUJULA):
		var jugador: Node2D = sala.get_node_or_null(^"Jugador") as Node2D
		if jugador != null:
			marcador = sala.posicion_mapa + jugador.position
			con_marcador = true
	lienzo.dibujar(_indice, zonas, zona_actual, acercado or rapido, con_marcador, marcador)
