class_name PantallaAmuletos
extends CanvasLayer
# Pantalla de los amuletos, encima del juego detenido, como el mapa: la abre la accion mochila o el boton «Amuletos»
# de la pausa. Como en Hollow Knight, solo sentado en un banco se ponen y se quitan; de pie solo se consultan. La
# regla vive aqui (lee Jugador.descansando): Partida solo cuida que se tengan y que haya lugar. La crea cada sala.

signal cerrada

const GRUPO: StringName = &"pantalla_encima"

## Abierta (juego detenido). Publica para los guiones.
var abierta: bool = false
## Botones de la lista, por id del amuleto; publico para la prueba.
var botones: Dictionary[StringName, Button] = {}

var _tick_cerrada: int = -10
# Si la abrio la pausa: al cerrar vuelve a ella y el juego sigue detenido.
var _desde_pausa: bool = false
var _panel: Control = null
var _aviso: Label = null
var _lista: VBoxContainer = null
var _volver: Button = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 21
	add_to_group(GRUPO)
	_panel = ColorRect.new()
	(_panel as ColorRect).color = Color(0.0, 0.0, 0.0, 0.85)
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.theme = Tema.crear()
	add_child(_panel)
	var arriba: HBoxContainer = HBoxContainer.new()
	arriba.position = Vector2(Tema.MARGEN_LATERAL, Tema.MARGEN_VERTICAL)
	arriba.add_theme_constant_override(&"separation", 32)
	_panel.add_child(arriba)
	_volver = Button.new()
	_volver.name = "Volver"
	_volver.text = "Volver"
	_volver.custom_minimum_size = Vector2(240.0, Tema.ALTO_TOQUE)
	_volver.pressed.connect(cerrar)
	arriba.add_child(_volver)
	var titulo: Label = Label.new()
	titulo.text = "Amuletos"
	titulo.add_theme_font_size_override(&"font_size", Tema.LETRA_TITULO)
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arriba.add_child(titulo)
	var centro: VBoxContainer = VBoxContainer.new()
	centro.set_anchors_preset(Control.PRESET_CENTER)
	centro.grow_horizontal = Control.GROW_DIRECTION_BOTH
	centro.grow_vertical = Control.GROW_DIRECTION_BOTH
	centro.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	_panel.add_child(centro)
	_aviso = Label.new()
	_aviso.name = "Aviso"
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	centro.add_child(_aviso)
	_lista = VBoxContainer.new()
	_lista.name = "Lista"
	_lista.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	centro.add_child(_lista)
	visible = false


# Se leen acciones con nombre: la abren igual el teclado, el control y un guion.
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"mochila"):
		if abierta:
			cerrar()
		elif not get_tree().paused:
			abrir()
	elif abierta and Input.is_action_just_pressed(&"pausa"):
		cerrar()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST and abierta:
		cerrar()


## Abre la pantalla deteniendo el juego, salvo con el juego ya detenido (el mapa o la pausa abiertos).
func abrir() -> void:
	if abierta or get_tree().paused:
		return
	get_tree().paused = true
	_desde_pausa = false
	_mostrar()


## La abre la pausa, que ya detuvo el juego; al cerrar vuelve a ella.
func abrir_desde_pausa() -> void:
	if abierta:
		return
	_desde_pausa = true
	_mostrar()


func cerrar() -> void:
	if not abierta:
		return
	abierta = false
	visible = false
	_tick_cerrada = Engine.get_physics_frames()
	if not _desde_pausa:
		get_tree().paused = false
	cerrada.emit()


## Con la pantalla abierta, y en el tick en que se cerro, la pausa no se abre (la misma pulsacion de pausa o Atras).
func bloquea_pausa() -> bool:
	return abierta or Engine.get_physics_frames() == _tick_cerrada


## Sentado en un banco de esta sala.
func puede_cambiar() -> bool:
	var jugador: Jugador = get_parent().get_node_or_null(^"Jugador") as Jugador
	return jugador != null and jugador.descansando


## Pone o quita un amuleto, solo sentado. Devuelve si cambio algo.
func alternar(amuleto: StringName) -> bool:
	if not puede_cambiar():
		return false
	var cambio: bool = Partida.desequipar(amuleto) if Partida.esta_equipado(amuleto) else Partida.equipar(amuleto)
	_actualizar()
	return cambio


func _mostrar() -> void:
	abierta = true
	visible = true
	for hijo: Node in _lista.get_children():
		hijo.free()
	botones.clear()
	for amuleto: StringName in Partida.amuletos_tenidos:
		var boton: Button = Button.new()
		boton.name = String(amuleto)
		boton.custom_minimum_size = Tema.CELDA
		boton.pressed.connect(alternar.bind(amuleto))
		_lista.add_child(boton)
		botones[amuleto] = boton
	_actualizar()
	if botones.is_empty():
		_volver.grab_focus()
	else:
		botones[Partida.amuletos_tenidos[0]].grab_focus()


func _actualizar() -> void:
	var sentado: bool = puede_cambiar()
	if Partida.amuletos_tenidos.is_empty():
		_aviso.text = "Todavía no tienes amuletos."
	elif sentado:
		_aviso.text = "Toca uno para ponerlo o quitarlo (%d de %d puestos)." % [Partida.amuletos_equipados.size(), Partida.MAX_EQUIPADOS]
	else:
		_aviso.text = "Siéntate en un banco para cambiarlos."
	for amuleto: StringName in botones:
		var puesto: bool = Partida.esta_equipado(amuleto)
		botones[amuleto].text = "%s: %s" % [nombre_de(amuleto), "puesto" if puesto else "guardado"]
		# De pie se ven pero no responden; sentado, uno que no cabe tampoco.
		botones[amuleto].disabled = not sentado or (not puesto and not Partida.puede_equipar(amuleto))


## Nombre para mostrar: los amuletos todavia no tienen ficha con nombre (llega con el contenido).
static func nombre_de(amuleto: StringName) -> String:
	return String(amuleto).capitalize()
