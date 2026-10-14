class_name NuevaPartida
extends Control
# Pantalla de partida nueva del menu: al tocar una ranura vacia se elige personaje (hombre o mujer) y se escribe un
# nombre con el teclado del telefono antes de empezar. Lo elegido va a Partida y al guardado (personaje y nombre, que
# ya existian vacios). Se arma en codigo como las ranuras. Atras y pausa vuelven a las ranuras (cerrado).

signal confirmada(personaje: String, nombre: String)
signal cerrado()

const PERSONAJES: PackedStringArray = ["hombre", "mujer"]
const LARGO_NOMBRE: int = 12
## Nombre si se deja vacio, segun el personaje.
const NOMBRE_POR_OMISION: Dictionary[String, String] = {"hombre": "Alumno", "mujer": "Alumna"}

## Ranura que se esta empezando.
var numero: int = 0
## Personaje elegido; vacio hasta tocar uno. Publico para la prueba.
var personaje: String = ""
## Franja de abajo que se deja libre (el aviso de pocos toques), en px de la vista.
var reservado_abajo: float = 0.0:
	set(valor):
		reservado_abajo = valor
		if is_inside_tree():
			_acomodar()
## Botones de cada personaje y el campo del nombre; publicos para la prueba.
var botones: Dictionary[String, Button] = {}
var campo: LineEdit = null
var empezar_boton: Button = null

static var _no_permitido: RegEx = null

var _marco: VBoxContainer = null
var _titulo: Label = null
var _arriba_base: float = 0.0
var _subida: float = 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_armar()
	get_viewport().size_changed.connect(_acomodar)
	_acomodar()
	visible = false


func _exit_tree() -> void:
	get_viewport().size_changed.disconnect(_acomodar)


func abrir(ranura: int) -> void:
	numero = ranura
	personaje = ""
	campo.text = ""
	_titulo.text = "Nueva partida %d" % ranura
	_pintar()
	visible = true
	Tema.dar_foco(botones[PERSONAJES[0]])


func atras() -> void:
	if not visible:
		return
	campo.release_focus()
	visible = false
	cerrado.emit()


func elegir(cual: String) -> void:
	personaje = cual
	_pintar()


## Empieza con lo elegido; sin personaje no hace nada. Publico para la prueba.
func empezar() -> void:
	if personaje.is_empty():
		return
	campo.release_focus()
	confirmada.emit(personaje, limpiar_nombre(campo.text, personaje))


## Sin espacios en las orillas ni repetidos, solo letras (con acentos y ñ), numeros y espacios, hasta LARGO_NOMBRE.
## Vacio, el del personaje.
static func limpiar_nombre(texto: String, de: String) -> String:
	if _no_permitido == null:
		_no_permitido = RegEx.create_from_string("[^\\p{L}\\p{N} ]")
	var limpio: String = _no_permitido.sub(texto, "", true)
	while limpio.contains("  "):
		limpio = limpio.replace("  ", " ")
	limpio = limpio.strip_edges().left(LARGO_NOMBRE).strip_edges()
	if limpio.is_empty():
		return NOMBRE_POR_OMISION.get(de, "") as String
	return limpio


func _pintar() -> void:
	# El elegido se ve encendido (mas claro), como la categoria elegida de la zona de pruebas.
	for cual: String in botones:
		botones[cual].set_pressed_no_signal(cual == personaje)
	empezar_boton.disabled = personaje.is_empty()
	campo.placeholder_text = NOMBRE_POR_OMISION.get(personaje, "Tu nombre") as String


func _acomodar() -> void:
	var vista: Vector2 = get_viewport_rect().size
	var area: Rect2 = Tema.area_util(vista)
	if reservado_abajo > 0.0:
		area.end.y = minf(area.end.y, vista.y - reservado_abajo)
	_marco.position = area.position
	_marco.size = area.size
	_arriba_base = area.position.y
	_subida = 0.0


# El teclado del telefono tapaba el campo del nombre (S50, 13-oct-2026): mientras esta abierto, todo sube lo justo
# para que el campo quede encima de el.
func _process(_delta: float) -> void:
	var subida: float = 0.0
	# Solo con el campo enfocado: en PC la consulta imprime un aviso de que no hay teclado virtual.
	var alto: int = DisplayServer.virtual_keyboard_get_height() if visible and campo.has_focus() and DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD) else 0
	if alto > 0:
		var vista: float = get_viewport_rect().size.y
		var tope: float = vista - float(alto) * vista / float(get_window().size.y) - Tema.MARGEN_VERTICAL
		subida = minf(0.0, tope - (campo.get_global_rect().end.y - _subida))
	if subida != _subida:
		_subida = subida
		_marco.position.y = _arriba_base + _subida


func _armar() -> void:
	_marco = VBoxContainer.new()
	_marco.name = "Marco"
	_marco.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	add_child(_marco)
	var arriba: HBoxContainer = HBoxContainer.new()
	arriba.name = "Arriba"
	arriba.add_theme_constant_override(&"separation", 32)
	_marco.add_child(arriba)
	var volver: Button = _boton("Volver", Vector2(240.0, Tema.ALTO_TOQUE))
	volver.name = "Volver"
	volver.pressed.connect(atras)
	arriba.add_child(volver)
	_titulo = Label.new()
	_titulo.add_theme_font_size_override(&"font_size", Tema.LETRA_TITULO)
	_titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arriba.add_child(_titulo)
	var centro: CenterContainer = CenterContainer.new()
	centro.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_marco.add_child(centro)
	var filas: VBoxContainer = VBoxContainer.new()
	filas.name = "Filas"
	filas.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	centro.add_child(filas)
	var personajes: HBoxContainer = HBoxContainer.new()
	personajes.name = "Personajes"
	personajes.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	filas.add_child(personajes)
	for cual: String in PERSONAJES:
		var boton: Button = _boton(cual.capitalize(), Tema.CELDA)
		boton.name = cual.capitalize()
		boton.toggle_mode = true
		boton.pressed.connect(elegir.bind(cual))
		personajes.add_child(boton)
		botones[cual] = boton
	var etiqueta: Label = Label.new()
	etiqueta.text = "Nombre"
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	filas.add_child(etiqueta)
	campo = LineEdit.new()
	campo.name = "Nombre"
	campo.custom_minimum_size = Vector2(Tema.CELDA.x * 2.0 + Tema.SEPARACION, Tema.ALTO_TOQUE)
	campo.max_length = LARGO_NOMBRE
	campo.alignment = HORIZONTAL_ALIGNMENT_CENTER
	campo.text_submitted.connect(_al_enviar)
	filas.add_child(campo)
	empezar_boton = _boton("Empezar", Vector2(Tema.CELDA.x * 2.0 + Tema.SEPARACION, Tema.ALTO_TOQUE))
	empezar_boton.name = "Empezar"
	empezar_boton.pressed.connect(empezar)
	filas.add_child(empezar_boton)


# Enter en el teclado del telefono: cierra el teclado y, con personaje elegido, empieza.
func _al_enviar(_texto: String) -> void:
	campo.release_focus()
	empezar()


func _boton(texto: String, tamano: Vector2) -> Button:
	var boton: Button = Button.new()
	boton.text = texto
	boton.custom_minimum_size = tamano
	return boton
