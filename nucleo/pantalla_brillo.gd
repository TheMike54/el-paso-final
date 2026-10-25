class_name PantallaBrillo
extends Control
# Pantalla de brillo de Configuracion, como la de Hollow Knight: detras, la escena tenue a pantalla completa; arriba,
# Volver y el titulo; al centro, la misma escena en una ventana con el cuadro de calibracion en la esquina; abajo, el
# texto y la barra. La escena es la foto de la sala (desde la pausa) o EscenaMuestra. Aparte de Configuracion (M6 de la
# auditoria), que la crea con el nombre PanelBrillo y guarda los ajustes cuando avisa barra_movida o barra_soltada.

## Volver de la barra de arriba: Configuracion vuelve un nivel.
signal volver_pedido()
## La barra cambio de valor (aplicado ya en Ajustes): Configuracion lo anota como sin guardar.
signal barra_movida()
## La barra se solto: Configuracion guarda lo que quedo sin guardar.
signal barra_soltada()

## Tamano de la ventana con la escena, lo tenue de la escena de fondo y el cuadro de calibracion.
const VENTANA_BRILLO: Vector2 = Vector2(576.0, 324.0)
const FONDO_TENUE: Color = Color(1.0, 1.0, 1.0, 0.3)
const CALIBRACION: float = 96.0
const COLOR_CALIBRACION: Color = Color(0.05, 0.05, 0.05, 1.0)
const TEXTO_BRILLO: String = "Ajusta el brillo hasta que el cuadro de la esquina apenas se vea."
# Deshace en la foto el brillo con el que se tomo (el modulado de la sala la multiplico): sin esto la escena se veria
# con el brillo aplicado dos veces. Solo se dibuja en la ventana y el fondo, no copia la pantalla.
const SHADER_FOTO: String = "shader_type canvas_item;
uniform float brillo_foto = 1.0;
void fragment() {
	COLOR.rgb = COLOR.rgb / brillo_foto;
}
"

## La columna de Volver, la ventana, el texto y la barra: Configuracion la acomoda al area util (Tema.ajustar).
var columna: VBoxContainer = null
## La barra del brillo: toma el foco al abrir la pantalla.
var barra: HSlider = null

var _porcentaje: Label = null
var _fondo_foto: TextureRect = null
var _fondo_muestra: EscenaMuestra = null
var _ventana_foto: TextureRect = null
var _ventana_muestra: EscenaMuestra = null
var _calibracion: ColorRect = null


func _init() -> void:
	name = "PanelBrillo"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


# El brillo de la sala no llega a los menus: la escena y el cuadro se modulan aqui (_modular_escena).
func _ready() -> void:
	var fondo: Control = Control.new()
	fondo.name = "Fondo"
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.modulate = FONDO_TENUE
	add_child(fondo)
	_fondo_muestra = EscenaMuestra.new()
	_fondo_muestra.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(_fondo_muestra)
	_fondo_foto = _foto_nueva()
	fondo.add_child(_fondo_foto)
	columna = VBoxContainer.new()
	columna.name = "Columna"
	columna.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	add_child(columna)
	var arriba: HBoxContainer = Tema.barra_arriba("Brillo", volver_pedido.emit)
	columna.add_child(arriba)
	var centro: CenterContainer = CenterContainer.new()
	centro.size_flags_vertical = Control.SIZE_EXPAND_FILL
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(centro)
	var ventana: Control = Control.new()
	ventana.name = "Ventana"
	ventana.custom_minimum_size = VENTANA_BRILLO
	ventana.clip_contents = true
	ventana.mouse_filter = Control.MOUSE_FILTER_IGNORE
	centro.add_child(ventana)
	_ventana_muestra = EscenaMuestra.new()
	_ventana_muestra.set_anchors_preset(Control.PRESET_FULL_RECT)
	ventana.add_child(_ventana_muestra)
	_ventana_foto = _foto_nueva()
	ventana.add_child(_ventana_foto)
	# Cuadro de calibracion: casi negro sobre negro, en la esquina de abajo a la derecha.
	var negro: ColorRect = ColorRect.new()
	negro.name = "Calibracion"
	negro.color = Color.BLACK
	negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	negro.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	negro.offset_left = -CALIBRACION
	negro.offset_top = -CALIBRACION
	ventana.add_child(negro)
	_calibracion = negro
	var cuadro: ColorRect = ColorRect.new()
	cuadro.color = COLOR_CALIBRACION
	cuadro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cuadro.position = Vector2(CALIBRACION / 4.0, CALIBRACION / 4.0)
	cuadro.size = Vector2(CALIBRACION / 2.0, CALIBRACION / 2.0)
	negro.add_child(cuadro)
	var borde: Panel = Panel.new()
	var caja: StyleBoxFlat = StyleBoxFlat.new()
	caja.draw_center = false
	caja.border_color = Tema.BORDE_BOTON.lightened(0.3)
	caja.set_border_width_all(4)
	borde.add_theme_stylebox_override(&"panel", caja)
	borde.set_anchors_preset(Control.PRESET_FULL_RECT)
	borde.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ventana.add_child(borde)
	var texto: Label = Label.new()
	texto.text = TEXTO_BRILLO
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	columna.add_child(texto)
	var fila: HBoxContainer = HBoxContainer.new()
	fila.name = "Fila"
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	columna.add_child(fila)
	barra = Configuracion.barra_ancha(Ajustes.BRILLO_MINIMO * 100.0, Ajustes.BRILLO_MAXIMO * 100.0)
	barra.size_flags_horizontal = Control.SIZE_FILL
	barra.custom_minimum_size.x = 720.0
	fila.add_child(barra)
	_porcentaje = Label.new()
	_porcentaje.name = "Porcentaje"
	_porcentaje.custom_minimum_size.x = 130.0
	_porcentaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_porcentaje.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fila.add_child(_porcentaje)
	barra.value_changed.connect(_al_cambiar_brillo)
	barra.drag_ended.connect(_al_soltar)


## Pone la foto de la sala, con el brillo con que se tomo, en la ventana y el fondo; sin foto, o vacia, la escena de
## muestra. La textura se arma aqui y no al abrir la pausa: casi nunca se abre esta pantalla.
func poner_foto(foto: Image, foto_brillo: float) -> void:
	var textura: ImageTexture = null
	if foto != null and not foto.is_empty():
		textura = ImageTexture.create_from_image(foto)
	var material: ShaderMaterial = null
	if textura != null:
		var shader: Shader = Shader.new()
		shader.code = SHADER_FOTO
		material = ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter(&"brillo_foto", Brillo.color_para(foto_brillo).r)
	for imagen: TextureRect in [_fondo_foto, _ventana_foto]:
		imagen.texture = textura
		imagen.material = material
	_fondo_muestra.visible = textura == null
	_ventana_muestra.visible = textura == null


## Pone la barra en el brillo de Ajustes (emite barra_movida si cambia: Configuracion lo descarta al abrir) y modula
## la escena con el.
func poner_valor() -> void:
	barra.value = roundf(Ajustes.brillo * 100.0)
	_modular_escena()


## Quita la textura y el material de la foto: en el telefono pesan unos megas de memoria de video.
func soltar_foto() -> void:
	for imagen: TextureRect in [_fondo_foto, _ventana_foto]:
		imagen.texture = null
		imagen.material = null


## Si muestra la foto de la sala (y no la escena de muestra).
func con_foto() -> bool:
	return _ventana_foto.texture != null


func _foto_nueva() -> TextureRect:
	var imagen: TextureRect = TextureRect.new()
	imagen.name = "Foto"
	imagen.set_anchors_preset(Control.PRESET_FULL_RECT)
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return imagen


func _al_cambiar_brillo(valor: float) -> void:
	Ajustes.brillo = valor / 100.0
	Ajustes.aplicar_brillo()
	_porcentaje.text = "%d %%" % roundi(valor)
	barra_movida.emit()
	_modular_escena()


func _al_soltar(_cambio: bool) -> void:
	barra_soltada.emit()


# La escena (foto o muestra) y el cuadro de calibracion, con el mismo color que el modulado de la sala; lo lee la
# prueba en el modulate de cada pieza.
func _modular_escena() -> void:
	var color: Color = Brillo.color_para(Ajustes.brillo)
	for pieza: Control in [_fondo_muestra, _fondo_foto, _ventana_muestra, _ventana_foto, _calibracion]:
		pieza.modulate = color
