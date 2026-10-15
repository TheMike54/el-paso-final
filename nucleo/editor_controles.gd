class_name EditorControles
extends Control
# Editor de los botones tactiles, que abre la pausa: tocar un boton lo selecciona y arrastrarlo lo mueve;
# un deslizador cambia el tamano del seleccionado y otro la opacidad de todos. Trabaja sobre una copia:
# Listo la guarda en Ajustes y en user://ajustes.json, Cancelar la descarta. Lee el raton, que en el
# telefono llega emulado desde el toque, para que tambien se pueda usar en la ventana de la PC.

signal cerrado

const COLOR_SELECCION: Color = Color(1.0, 0.85, 0.3, 0.9)
const TEXTO_RESTAURAR: String = "Restaurar"
const TEXTO_CONFIRMAR: String = "¿Restaurar? Toca otra vez"

## Donde guarda Listo. Una prueba la cambia para no tocar los ajustes reales.
var ruta_ajustes: String = Ajustes.RUTA
## La disposicion que se esta editando. Publica para que la prueba la lea.
var copia: DisposicionControles = null
## Boton seleccionado (indice de ControlesTactiles.ACCIONES); -1 si ninguno.
var seleccion: int = -1

var _area: Rect2 = Rect2()
var _radio_minimo: float = 0.0
var _arrastrando: bool = false
# Del punto tocado al centro del boton, para que no salte bajo el dedo al empezar a arrastrar.
var _desfase: Vector2 = Vector2.ZERO
var _confirmar_restaurar: bool = false

@onready var _barra: Control = $Barra as Control
@onready var _tamano: HSlider = $Barra/Filas/Deslizadores/Tamano as HSlider
@onready var _opacidad: HSlider = $Barra/Filas/Deslizadores/Opacidad as HSlider
@onready var _restaurar: Button = $Barra/Filas/Botones/Restaurar as Button
@onready var _cancelar: Button = $Barra/Filas/Botones/Cancelar as Button
@onready var _listo: Button = $Barra/Filas/Botones/Listo as Button


func _ready() -> void:
	ControlesTactiles.editando = true
	Ajustes.cargar_una_vez()
	_medir()
	copia = Ajustes.disposicion.copia()
	copia.ajustar(size, _area, _radio_minimo)
	_tamano.min_value = DisposicionControles.ESCALA_MINIMA * 100.0
	_tamano.max_value = DisposicionControles.ESCALA_MAXIMA * 100.0
	_opacidad.min_value = DisposicionControles.OPACIDAD_MINIMA * 100.0
	_opacidad.max_value = DisposicionControles.OPACIDAD_MAXIMA * 100.0
	_mostrar_valores()
	_tamano.value_changed.connect(_al_cambiar_tamano)
	_opacidad.value_changed.connect(_al_cambiar_opacidad)
	_restaurar.pressed.connect(restaurar)
	_cancelar.pressed.connect(cancelar)
	_listo.pressed.connect(listo)
	resized.connect(_al_cambiar_de_tamano)


func _exit_tree() -> void:
	ControlesTactiles.editando = false


func _gui_input(evento: InputEvent) -> void:
	procesar(evento)


## Traduce un evento del raton. Publico para que la prueba le pase clics sin pantalla.
func procesar(evento: InputEvent) -> void:
	var boton: InputEventMouseButton = evento as InputEventMouseButton
	var movimiento: InputEventMouseMotion = evento as InputEventMouseMotion
	if boton != null and boton.button_index == MOUSE_BUTTON_LEFT:
		if boton.pressed:
			_tocar(boton.position)
		elif _arrastrando:
			_soltar(boton.position)
	elif movimiento != null and _arrastrando:
		# Mientras se arrastra basta con no salirse de la vista; el area segura se aplica al soltar.
		copia.colocar(seleccion, movimiento.position + _desfase, size, Rect2(Vector2.ZERO, size), _radio_minimo)
		queue_redraw()


## Vuelve todo a la distribucion inicial; la primera vez solo pide confirmacion.
func restaurar() -> void:
	if not _confirmar_restaurar:
		_confirmar_restaurar = true
		_restaurar.text = TEXTO_CONFIRMAR
		return
	_quitar_confirmacion()
	copia = DisposicionControles.por_omision()
	copia.ajustar(size, _area, _radio_minimo)
	_mostrar_valores()
	queue_redraw()


func listo() -> void:
	Ajustes.disposicion = copia
	var error: Error = Ajustes.guardar(ruta_ajustes)
	if error != OK:
		push_error("EditorControles: no se pudieron guardar los ajustes (error %d)" % error)
	_cerrar()


func cancelar() -> void:
	_cerrar()


func _cerrar() -> void:
	ControlesTactiles.editando = false
	cerrado.emit()
	get_parent().queue_free()


func _medir() -> void:
	_area = DisposicionControles.area_segura(size)
	_radio_minimo = DisposicionControles.radio_minimo(size)


func _al_cambiar_de_tamano() -> void:
	_medir()
	copia.ajustar(size, _area, _radio_minimo)
	queue_redraw()


# El boton de encima gana: se busca del ultimo al primero, que es el que se dibuja al final.
func _tocar(posicion: Vector2) -> void:
	_quitar_confirmacion()
	for i: int in range(ControlesTactiles.ACCIONES.size() - 1, -1, -1):
		var c: Vector2 = copia.centro(i, size)
		if posicion.distance_to(c) <= copia.radio(i, size, _radio_minimo) * ControlesTactiles.HOLGURA:
			seleccion = i
			_arrastrando = true
			_desfase = c - posicion
			# La barra se oculta mientras se arrastra para poder poner un boton debajo de ella.
			_barra.visible = false
			_mostrar_valores()
			queue_redraw()
			return


func _soltar(posicion: Vector2) -> void:
	_arrastrando = false
	_barra.visible = true
	copia.colocar(seleccion, posicion + _desfase, size, _area, _radio_minimo)
	queue_redraw()


func _al_cambiar_tamano(valor: float) -> void:
	if seleccion < 0:
		return
	copia.fijar_escala(seleccion, valor / 100.0)
	# Al crecer puede salirse del area: se vuelve a colocar donde esta.
	copia.colocar(seleccion, copia.centro(seleccion, size), size, _area, _radio_minimo)
	queue_redraw()


func _al_cambiar_opacidad(valor: float) -> void:
	copia.fijar_opacidad(valor / 100.0)
	queue_redraw()


func _mostrar_valores() -> void:
	_tamano.editable = seleccion >= 0
	_tamano.set_value_no_signal(copia.escalas[seleccion] * 100.0 if seleccion >= 0 else 100.0)
	_opacidad.set_value_no_signal(copia.opacidad * 100.0)


func _quitar_confirmacion() -> void:
	_confirmar_restaurar = false
	_restaurar.text = TEXTO_RESTAURAR


func _draw() -> void:
	var fuente: Font = ThemeDB.fallback_font
	var color: Color = Color(ControlesTactiles.COLOR_BOTON, ControlesTactiles.COLOR_BOTON.a * copia.opacidad)
	for i: int in range(ControlesTactiles.ACCIONES.size()):
		var c: Vector2 = copia.centro(i, size)
		var r: float = copia.radio(i, size, _radio_minimo)
		if i == seleccion:
			draw_circle(c, r, Color(COLOR_SELECCION, 0.3))
			draw_arc(c, r, 0.0, TAU, 48, COLOR_SELECCION, 3.0)
		else:
			draw_arc(c, r, 0.0, TAU, 48, color, 2.0)
		var etiqueta: String = ControlesTactiles.ETIQUETAS[i]
		var tamano_letra: int = maxi(12, roundi(r * 0.35))
		var ancho: float = fuente.get_string_size(etiqueta, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_letra).x
		draw_string(fuente, c + Vector2(-ancho / 2.0, tamano_letra * 0.35), etiqueta, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano_letra, color if i != seleccion else COLOR_SELECCION)
