extends Control
# Pantalla de cierre de la primera version: «Continuara» y, en chico, «Fin de la primera version», con un boton para
# volver al menu. Antes de salir autoguarda lo obtenido, como Salir al menu de la pausa: al continuar se aparece en
# el ultimo banco. Se arma en codigo con el tema de los menus; B o Esc (volver) tambien regresa.

const TEXTO: String = "Continuará"
const TEXTO_CHICO: String = "Fin de la primera versión"
const TEXTO_BOTON: String = "Volver al menú"
## Separacion vertical entre las lineas y el boton.
const SEPARACION: int = 24

## El boton; publico para los guiones.
var boton: Button = null

var _saliendo: bool = false


func _ready() -> void:
	var fondo: ColorRect = Tema.fondo_menu(1.0)
	add_child(fondo)
	var centro: CenterContainer = CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(centro)
	var columna: VBoxContainer = VBoxContainer.new()
	columna.alignment = BoxContainer.ALIGNMENT_CENTER
	columna.add_theme_constant_override(&"separation", SEPARACION)
	centro.add_child(columna)
	var titulo: Label = Label.new()
	titulo.text = TEXTO
	titulo.theme_type_variation = Tema.TITULO
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(titulo)
	var chico: Label = Label.new()
	chico.text = TEXTO_CHICO
	chico.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chico.add_theme_font_size_override(&"font_size", Tema.LETRA_CHICA)
	chico.add_theme_color_override(&"font_color", Tema.GASTADO)
	columna.add_child(chico)
	boton = Tema.boton(TEXTO_BOTON, Vector2(Tema.CELDA.x, Tema.ALTO_TOQUE))
	boton.pressed.connect(volver)
	columna.add_child(boton)
	Tema.dar_foco(boton)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"volver"):
		volver()


## Autoguarda y vuelve al menu principal, una sola vez.
func volver() -> void:
	if _saliendo:
		return
	_saliendo = true
	Partida.autoguardar()
	get_tree().change_scene_to_file(MenuPrincipal.RUTA)
