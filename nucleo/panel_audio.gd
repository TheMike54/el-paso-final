class_name PanelAudio
extends VBoxContainer
# Panel de audio de Configuracion (el nodo PanelAudio de configuracion.tscn): tres filas de volumen (general, musica y
# efectos) con su barra ancha, su porcentaje y un altavoz que silencia, y el boton de probar un efecto; mientras el panel
# esta abierto le pide a Musica un tema para probar si no se oye ninguno. Aparte de Configuracion para que esta no cargue con todo (M6 de
# planes/cerrados/nucleo-auditoria-7-menus.md); guardar los ajustes sigue siendo de Configuracion, a la que avisa con barra_movida y barra_soltada.

## Una barra cambio de valor (aplicado ya en Ajustes): Configuracion lo anota como sin guardar.
signal barra_movida()
## Una barra se solto o un altavoz la cambio: Configuracion guarda lo que quedo sin guardar.
signal barra_soltada()

## El efecto que toca «Probar efecto», en el bus de efectos.
const EFECTO_PRUEBA: AudioStream = preload("res://nucleo/sonidos/jugador/golpe.wav")

# Por el nombre de su fila (General, Musica, Efectos): la barra, el porcentaje, el altavoz y el valor antes de
# silenciar (para volver a el).
var _barras: Dictionary[String, HSlider] = {}
var _porcentajes: Dictionary[String, Label] = {}
var _altavoces: Dictionary[String, Button] = {}
var _antes_de_silenciar: Dictionary[String, float] = {}
var _efecto: AudioStreamPlayer = null

@onready var _filas: VBoxContainer = $Desplazable/Centro/Filas as VBoxContainer
@onready var _desplazable: ScrollContainer = $Desplazable as ScrollContainer


# Las tres filas de volumen (nombre, barra, porcentaje y altavoz), el boton de probar y su reproductor.
func _ready() -> void:
	var nombres: PackedStringArray = ["General", "Musica", "Efectos"]
	var textos: PackedStringArray = ["General", "Música", "Efectos"]
	for i: int in range(nombres.size()):
		_fila_volumen(nombres[i], textos[i])
	var probar: Button = Button.new()
	probar.name = "Probar"
	probar.text = "Probar efecto"
	probar.custom_minimum_size = Tema.CELDA
	probar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_filas.add_child(probar)
	_efecto = AudioStreamPlayer.new()
	_efecto.stream = EFECTO_PRUEBA
	_efecto.bus = Ajustes.BUS_EFECTOS
	add_child(_efecto)
	probar.pressed.connect(_efecto.play)


## Pone cada barra en su volumen de Ajustes. Emite barra_movida: Configuracion lo descarta al abrir.
func poner_valores() -> void:
	_barras["General"].value = roundf(Ajustes.volumen * 100.0)
	_barras["Musica"].value = roundf(Ajustes.volumen_musica * 100.0)
	_barras["Efectos"].value = roundf(Ajustes.volumen_efectos * 100.0)


## La primera barra, la del volumen general: toma el foco al abrir el panel.
func primera_barra() -> HSlider:
	return _barras["General"]


## Lleva el desplazamiento al principio, despues del acomodo.
func desplazar_arriba() -> void:
	_desplazable.set_deferred(&"scroll_vertical", 0)


## Con el panel a la vista, Musica pone un tema para probar la barra si no se oye ninguno; al ocultarlo devuelve lo
## que habia (Musica.probar). La musica tiene un solo dueno: el panel no la toca directo.
func musica_de_prueba(sonar: bool) -> void:
	Arranque.musica.probar(sonar)


func _fila_volumen(nombre: String, texto: String) -> void:
	var fila: HBoxContainer = HBoxContainer.new()
	fila.name = nombre
	fila.custom_minimum_size = Vector2(960.0, Tema.ALTO_TOQUE)
	fila.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	_filas.add_child(fila)
	var etiqueta: Label = Label.new()
	etiqueta.name = "Nombre"
	etiqueta.text = texto
	etiqueta.custom_minimum_size.x = 200.0
	etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fila.add_child(etiqueta)
	var barra: HSlider = Configuracion.barra_ancha(0.0, 100.0)
	fila.add_child(barra)
	var porcentaje: Label = Label.new()
	porcentaje.name = "Porcentaje"
	porcentaje.custom_minimum_size.x = 110.0
	porcentaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	porcentaje.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fila.add_child(porcentaje)
	var altavoz: Button = Button.new()
	altavoz.name = "Silencio"
	altavoz.custom_minimum_size = Vector2(Tema.ALTO_TOQUE, Tema.ALTO_TOQUE)
	altavoz.draw.connect(_dibujar_altavoz.bind(altavoz, barra))
	fila.add_child(altavoz)
	_barras[nombre] = barra
	_porcentajes[nombre] = porcentaje
	_altavoces[nombre] = altavoz
	barra.value_changed.connect(_al_cambiar_volumen.bind(nombre))
	barra.drag_ended.connect(_al_soltar)
	altavoz.pressed.connect(_silenciar.bind(nombre))


# Altavoz: cuerpo y cono; con ondas si suena y con una cruz si esta en 0.
func _dibujar_altavoz(boton: Button, barra: HSlider) -> void:
	var c: Vector2 = boton.size / 2.0
	var color: Color = Color(0.92, 0.92, 0.94)
	boton.draw_rect(Rect2(c.x - 26.0, c.y - 10.0, 14.0, 20.0), color)
	boton.draw_colored_polygon(PackedVector2Array([Vector2(c.x - 12.0, c.y - 10.0), Vector2(c.x + 4.0, c.y - 24.0), Vector2(c.x + 4.0, c.y + 24.0), Vector2(c.x - 12.0, c.y + 10.0)]), color)
	if barra.value <= 0.0:
		boton.draw_line(Vector2(c.x + 12.0, c.y - 10.0), Vector2(c.x + 28.0, c.y + 10.0), color, 5.0)
		boton.draw_line(Vector2(c.x + 12.0, c.y + 10.0), Vector2(c.x + 28.0, c.y - 10.0), color, 5.0)
	else:
		boton.draw_arc(Vector2(c.x + 4.0, c.y), 14.0, -PI / 4.0, PI / 4.0, 8, color, 4.0)
		boton.draw_arc(Vector2(c.x + 4.0, c.y), 24.0, -PI / 4.0, PI / 4.0, 8, color, 4.0)


# Silencia un volumen o lo devuelve al valor que tenia antes de silenciarlo; se guarda al momento.
func _silenciar(nombre: String) -> void:
	var barra: HSlider = _barras[nombre]
	if barra.value > 0.0:
		_antes_de_silenciar[nombre] = barra.value
		barra.value = 0.0
	else:
		var antes: float = _antes_de_silenciar.get(nombre, Configuracion.VOLUMEN_AL_QUITAR_SILENCIO)
		barra.value = antes
	barra_soltada.emit()


func _al_cambiar_volumen(valor: float, nombre: String) -> void:
	match nombre:
		"General":
			Ajustes.volumen = valor / 100.0
		"Musica":
			Ajustes.volumen_musica = valor / 100.0
		"Efectos":
			Ajustes.volumen_efectos = valor / 100.0
	Ajustes.aplicar_volumen()
	_porcentajes[nombre].text = "%d %%" % roundi(valor)
	_altavoces[nombre].queue_redraw()
	barra_movida.emit()


func _al_soltar(_cambio: bool) -> void:
	barra_soltada.emit()
