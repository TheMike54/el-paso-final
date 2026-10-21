class_name Confirmacion
extends ColorRect
# Confirmacion Si / No compartida: velo a pantalla completa, pregunta centrada, una linea opcional con la cantidad y
# dos botones. La usan las ranuras (Borrar, Restaurar), Salir del menu principal, la tienda y el cobro de una estacion.
# Se arma en codigo, como las ranuras, porque solo cambia lo que piden sus parametros. No lee la entrada: quien la
# abre llama a cancelar() desde su Atras, asi Atras sigue bajando un nivel a la vez.

## Se eligio Si. Una vez por cada abrir(), aunque se toque dos veces; la confirmacion sigue a la vista y la cierra
## quien la abrio (cerrar()), para que nada cambie antes de lo que hace (salir de la app la deja hasta el final).
signal confirmada()
## Se eligio No, o quien la abrio la cancelo (Atras): ya esta cerrada.
signal cancelada()

## Donde empieza el foco al abrir.
enum Foco {
	SI,
	NO,
}

## Ancho minimo de Si y No con la variacion por omision del boton (la de hoy en las ranuras y en Salir).
const ANCHO_BOTON: float = 300.0
const SEPARACION_BOTONES: int = 64

## Aspecto. Se fija antes de agregarla al arbol, porque se arma en _ready: opacidad del negro del velo, separacion entre
## la pregunta y los botones, ancho de la pregunta (mas larga, se parte en lineas; 0: una linea, mide lo que su texto),
## variacion de la pregunta y de la cantidad (Label) y de Si y No (Button; vacia: el boton del tema con ANCHO_BOTON de
## ancho minimo; otra, como Tema.OPCION_CENTRADA, sin ancho minimo, para que mida lo que su texto).
var alfa_velo: float = 0.8
var separacion: int = 32
var ancho_pregunta: float = 800.0
var variacion_pregunta: StringName = Tema.PREGUNTA
var variacion_cantidad: StringName = Tema.TITULO
var variacion_boton: StringName = &""
## Sus partes, publicas para quien la usa y para las pruebas; existen desde que entra al arbol. La cantidad solo se ve
## si abrir() le da texto.
var pregunta: Label = null
var cantidad: Label = null
var si: Button = null
var no: Button = null

var _respondida: bool = false


func _init() -> void:
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


# Se arma ya en el arbol y con la pregunta configurada antes de agregarla, como la armaban las ranuras: armada en
# _init y con el ancho y el ajuste de linea puestos despues, la pregunta media 1847 px de alto en la prueba de las
# ranuras (18-oct-2026) y la caja salia de la vista por arriba.
func _ready() -> void:
	color = Color(0.0, 0.0, 0.0, alfa_velo)
	var caja: VBoxContainer = VBoxContainer.new()
	caja.name = "Caja"
	caja.add_theme_constant_override(&"separation", separacion)
	caja.set_anchors_preset(Control.PRESET_CENTER)
	caja.grow_horizontal = Control.GROW_DIRECTION_BOTH
	caja.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(caja)
	pregunta = Label.new()
	pregunta.name = "Pregunta"
	pregunta.theme_type_variation = variacion_pregunta
	pregunta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if ancho_pregunta > 0.0:
		pregunta.custom_minimum_size = Vector2(ancho_pregunta, 0.0)
		pregunta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caja.add_child(pregunta)
	cantidad = Label.new()
	cantidad.name = "Cantidad"
	cantidad.theme_type_variation = variacion_cantidad
	cantidad.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cantidad.visible = false
	caja.add_child(cantidad)
	var botones: HBoxContainer = HBoxContainer.new()
	botones.name = "Botones"
	botones.add_theme_constant_override(&"separation", SEPARACION_BOTONES)
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	caja.add_child(botones)
	si = _boton("Si")
	si.pressed.connect(_al_si)
	botones.add_child(si)
	no = _boton("No")
	no.pressed.connect(cancelar)
	botones.add_child(no)


## La muestra con sus textos y pone el foco en Si o en No. texto_cantidad, si no esta vacio, va en su linea entre la
## pregunta y los botones (lo que cuesta: "50 PejeCoins").
func abrir(texto_pregunta: String, texto_si: String, texto_no: String, foco: Foco = Foco.NO, texto_cantidad: String = "") -> void:
	pregunta.text = texto_pregunta
	cantidad.text = texto_cantidad
	cantidad.visible = not texto_cantidad.is_empty()
	si.text = texto_si
	no.text = texto_no
	_respondida = false
	visible = true
	Tema.dar_foco(si if foco == Foco.SI else no)


## La oculta sin emitir nada (quien la abrio ya sabe por que).
func cerrar() -> void:
	visible = false


## No, o Atras de quien la abrio: la cierra y emite cancelada. Cerrada, no hace nada.
func cancelar() -> void:
	if not visible:
		return
	_respondida = true
	visible = false
	cancelada.emit()


func _al_si() -> void:
	if not visible or _respondida:
		return
	_respondida = true
	confirmada.emit()


func _boton(nombre: String) -> Button:
	var ancho: float = ANCHO_BOTON if variacion_boton.is_empty() else 0.0
	var boton: Button = Tema.boton("", Vector2(ancho, Tema.ALTO_TOQUE))
	boton.name = nombre
	boton.theme_type_variation = variacion_boton
	return boton
