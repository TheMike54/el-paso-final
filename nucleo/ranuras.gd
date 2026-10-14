class_name Ranuras
extends Control
# Seleccion de partida del menu principal, como la de Silksong: una ficha por ranura. La vacia dice «Nueva partida»;
# la ocupada lleva el nombre de la partida (si tiene) y dice donde se quedo, las vidas maximas, el tiempo jugado y un rastro de cuadritos por lo obtenido. Borrar
# y Restaurar piden confirmacion. Se arma en codigo porque las fichas son iguales. Atras y pausa vuelven un nivel a
# la vez: de la confirmacion a las fichas y de ahi al menu (cerrado).

signal elegida(numero: int)
signal cerrado()

enum Accion { BORRAR, RESTAURAR }

## Ancho de una ficha: 4 en fila caben desde la vista de 1280 (1152 utiles).
const ANCHO_FICHA: float = 270.0
## Alto del boton principal de la ficha: titulo, tres lineas y el rastro.
const ALTO_PRINCIPAL: float = 250.0
const SEPARACION_FICHA: float = 8.0
## Cuadritos del rastro: lado, separacion, color y cuantos caben como mucho.
const LADO_PASO: float = 14.0
const SEPARACION_PASO: int = 4
const COLOR_PASO: Color = Color(0.62, 0.68, 0.8, 1.0)
const MAX_PASOS: int = 24

## Formato de la ruta de cada ranura (con su numero); publico para que la prueba use las suyas.
var formato_ruta: String = Guardado.FORMATO_RANURA
## Lo leido de cada ranura al abrir; el indice 0 es la ranura 1.
var resultados: Array[Guardado.Resultado] = []
## Franja de abajo que se deja libre (el aviso de pocos toques), en px de la vista.
var reservado_abajo: float = 0.0:
	set(valor):
		reservado_abajo = valor
		if is_inside_tree():
			_acomodar()

var _marco: VBoxContainer = null
var _volver: Button = null
var _fichas: GridContainer = null
var _principales: Array[Button] = []
var _detalles: Array[Label] = []
var _titulos: Array[Label] = []
var _rastros: Array[HFlowContainer] = []
var _borrar: Array[Button] = []
var _restaurar: Array[Button] = []
var _confirmar: ColorRect = null
var _pregunta: Label = null
var _si: Button = null
var _no: Button = null
var _accion: Accion = Accion.BORRAR
var _numero_accion: int = 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_armar()
	get_viewport().size_changed.connect(_acomodar)
	_acomodar()
	visible = false


func _exit_tree() -> void:
	get_viewport().size_changed.disconnect(_acomodar)


func ruta(numero: int) -> String:
	return formato_ruta % numero


## Lee las ranuras, las muestra y pone el foco en la primera.
func abrir() -> void:
	leer()
	visible = true
	_ver_confirmacion(false)
	_enfocar(1)


## Vuelve a mostrarse, sin releer, con el foco en una ranura (al volver de «Nueva partida»).
func volver(numero: int) -> void:
	visible = true
	_enfocar(numero)


## Vuelve a leer las ranuras del disco y repinta sus fichas.
func leer() -> void:
	resultados.clear()
	for numero: int in range(1, Guardado.RANURAS + 1):
		resultados.append(Guardado.cargar(ruta(numero)))
		_pintar(numero)


## Un nivel hacia atras: de la confirmacion a las fichas; de las fichas, cierra.
func atras() -> void:
	if not visible:
		return
	if _confirmar.visible:
		_ver_confirmacion(false)
		Tema.dar_foco(_borrar[_numero_accion - 1] if _accion == Accion.BORRAR else _restaurar[_numero_accion - 1])
	else:
		visible = false
		cerrado.emit()


## Pide confirmar borrar o restaurar una ranura; publico para la prueba.
func pedir(accion: Accion, numero: int) -> void:
	_accion = accion
	_numero_accion = numero
	if accion == Accion.BORRAR:
		_pregunta.text = "¿Borrar la partida %d? No se puede deshacer." % numero
		_si.text = "Borrar"
	else:
		_pregunta.text = "¿Volver la partida %d al inicio de la última sesión?" % numero
		_si.text = "Restaurar"
	_ver_confirmacion(true)
	Tema.dar_foco(_no)


# Con la confirmacion abierta las fichas se ocultan, como el menu en la de salir: si no, con teclado o control el
# foco se escapaba a los botones de detras.
func _ver_confirmacion(abierta: bool) -> void:
	_confirmar.visible = abierta
	_marco.visible = not abierta


## Hace lo que se confirmo; publico para la prueba.
func confirmar() -> void:
	var destino: String = ruta(_numero_accion)
	var error: Error = Guardado.borrar(destino) if _accion == Accion.BORRAR else Guardado.restaurar(destino)
	if error != OK:
		push_error("Ranuras: no se pudo %s la partida %d (error %d)" % ["borrar" if _accion == Accion.BORRAR else "restaurar", _numero_accion, error])
	_ver_confirmacion(false)
	leer()
	_enfocar(_numero_accion)


## Columnas de fichas para un ancho util: todas en fila si caben (desde la vista de 1280) y si no, 2x2; 3 y 1 se ve
## como si faltara una.
static func columnas_para(ancho: float) -> int:
	var caben: int = Tema.columnas(ancho, ANCHO_FICHA, Tema.SEPARACION, 1, Guardado.RANURAS)
	return Guardado.RANURAS if caben >= Guardado.RANURAS else 2


## Lo que dice una ficha ocupada debajo de su titulo: donde se quedo, vidas maximas y tiempo jugado.
static func detalle(partida: Dictionary) -> String:
	var vidas: int = partida.get("vidas_maximas", 0) as int
	var segundos: float = partida.get("tiempo_jugado", 0.0) as float
	return "%s\nVidas: %d\n%s" % [ubicacion(partida), vidas, tiempo_texto(segundos)]


## La sala del banco; sin banco, la ultima visitada; sin ninguna, «Inicio». Con su nombre legible.
static func ubicacion(partida: Dictionary) -> String:
	var banco: Dictionary = partida.get("banco", {}) as Dictionary
	var sala: String = str(banco.get("sala", ""))
	var visitadas: Array = partida.get("salas_visitadas", []) as Array
	if sala.is_empty() and not visitadas.is_empty():
		sala = str(visitadas.back())
	if sala.is_empty():
		return "Inicio"
	if sala.begins_with("res://"):
		sala = sala.get_file().get_basename()
	return sala.capitalize()


## «12 min» o «1 h 05 min».
static func tiempo_texto(segundos: float) -> String:
	var minutos: int = floori(segundos / 60.0)
	if minutos < 60:
		return "%d min" % minutos
	return "%d h %02d min" % [floori(minutos / 60.0), minutos % 60]


## Cuadritos del rastro: uno por habilidad, jefe y coleccionable obtenidos.
static func pasos(partida: Dictionary) -> int:
	var total: int = (partida.get("habilidades", []) as Array).size() + (partida.get("jefes", []) as Array).size()
	var salas: Dictionary = partida.get("salas", {}) as Dictionary
	for clave: Variant in salas:
		var estado: Variant = salas[clave]
		if estado is Dictionary:
			for objeto: Variant in estado as Dictionary:
				if str(objeto).begins_with(Partida.PREFIJO_COLECCIONABLE):
					total += 1
	return total


func _pintar(numero: int) -> void:
	var leida: Guardado.Resultado = resultados[numero - 1]
	var principal: Button = _principales[numero - 1]
	var texto: Label = _detalles[numero - 1]
	var rastro: HFlowContainer = _rastros[numero - 1]
	for cuadrito: Node in rastro.get_children():
		rastro.remove_child(cuadrito)
		cuadrito.queue_free()
	principal.disabled = leida.estado == Guardado.Estado.DANADA or leida.estado == Guardado.Estado.INCOMPATIBLE
	var nombre: String = str(leida.partida.get("nombre", "")) if leida.estado == Guardado.Estado.VALIDA else ""
	_titulos[numero - 1].text = nombre if not nombre.is_empty() else "Partida %d" % numero
	match leida.estado:
		Guardado.Estado.VACIA:
			texto.text = "Nueva partida"
		Guardado.Estado.DANADA:
			texto.text = "Dañada"
		Guardado.Estado.INCOMPATIBLE:
			texto.text = "De otra versión"
		Guardado.Estado.VALIDA:
			texto.text = detalle(leida.partida)
			for i: int in range(mini(pasos(leida.partida), MAX_PASOS)):
				var cuadrito: ColorRect = ColorRect.new()
				cuadrito.custom_minimum_size = Vector2(LADO_PASO, LADO_PASO)
				cuadrito.color = COLOR_PASO
				cuadrito.mouse_filter = Control.MOUSE_FILTER_IGNORE
				rastro.add_child(cuadrito)
	_borrar[numero - 1].visible = leida.estado != Guardado.Estado.VACIA
	_restaurar[numero - 1].visible = Guardado.tiene_respaldo(ruta(numero))


func _enfocar(numero: int) -> void:
	var principal: Button = _principales[numero - 1]
	if not principal.disabled:
		Tema.dar_foco(principal)
	else:
		Tema.dar_foco(_borrar[numero - 1])


# El marco ocupa el area util (Tema) menos la franja reservada abajo.
func _acomodar() -> void:
	var vista: Vector2 = get_viewport_rect().size
	var area: Rect2 = Tema.area_util(vista)
	if reservado_abajo > 0.0:
		area.end.y = minf(area.end.y, vista.y - reservado_abajo)
	_marco.position = area.position
	_marco.size = area.size
	_fichas.columns = columnas_para(area.size.x)


func _armar() -> void:
	_marco = VBoxContainer.new()
	_marco.name = "Marco"
	_marco.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	add_child(_marco)
	var arriba: HBoxContainer = HBoxContainer.new()
	arriba.name = "Arriba"
	arriba.add_theme_constant_override(&"separation", 32)
	_marco.add_child(arriba)
	_volver = _boton("Volver", Vector2(240.0, Tema.ALTO_TOQUE))
	_volver.name = "Volver"
	_volver.pressed.connect(atras)
	arriba.add_child(_volver)
	var titulo: Label = Label.new()
	titulo.text = "Elige una partida"
	titulo.add_theme_font_size_override(&"font_size", Tema.LETRA_TITULO)
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arriba.add_child(titulo)
	# Con el area segura muy recortada las fichas van en 2x2 y pueden no caber a lo alto: se desplazan.
	var desplazable: ScrollContainer = ScrollContainer.new()
	desplazable.name = "Desplazable"
	desplazable.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desplazable.follow_focus = true
	desplazable.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_marco.add_child(desplazable)
	var centro: CenterContainer = CenterContainer.new()
	centro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	centro.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desplazable.add_child(centro)
	_fichas = GridContainer.new()
	_fichas.name = "Fichas"
	_fichas.add_theme_constant_override(&"h_separation", int(Tema.SEPARACION))
	_fichas.add_theme_constant_override(&"v_separation", int(Tema.SEPARACION_FILAS))
	centro.add_child(_fichas)
	for numero: int in range(1, Guardado.RANURAS + 1):
		_armar_ficha(numero)
	_armar_confirmacion()


func _armar_ficha(numero: int) -> void:
	var ficha: VBoxContainer = VBoxContainer.new()
	ficha.name = "Ficha%d" % numero
	ficha.add_theme_constant_override(&"separation", int(SEPARACION_FICHA))
	_fichas.add_child(ficha)
	var principal: Button = _boton("", Vector2(ANCHO_FICHA, ALTO_PRINCIPAL))
	principal.name = "Principal"
	principal.pressed.connect(elegida.emit.bind(numero))
	ficha.add_child(principal)
	# El contenido va dentro del boton y no recibe toques: el toque es del boton.
	var contenido: VBoxContainer = VBoxContainer.new()
	contenido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenido.anchor_right = 1.0
	contenido.anchor_bottom = 1.0
	contenido.offset_left = 16.0
	contenido.offset_top = 16.0
	contenido.offset_right = -16.0
	contenido.offset_bottom = -16.0
	principal.add_child(contenido)
	var titulo: Label = Label.new()
	titulo.text = "Partida %d" % numero
	titulo.name = "Titulo"
	titulo.add_theme_font_size_override(&"font_size", Tema.LETRA)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.clip_text = true
	titulo.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	contenido.add_child(titulo)
	_titulos.append(titulo)
	var texto: Label = Label.new()
	texto.name = "Detalle"
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texto.clip_text = true
	texto.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	contenido.add_child(texto)
	var rastro: HFlowContainer = HFlowContainer.new()
	rastro.name = "Rastro"
	rastro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rastro.alignment = FlowContainer.ALIGNMENT_CENTER
	rastro.add_theme_constant_override(&"h_separation", SEPARACION_PASO)
	rastro.add_theme_constant_override(&"v_separation", SEPARACION_PASO)
	contenido.add_child(rastro)
	var borrar: Button = _boton("Borrar", Vector2(ANCHO_FICHA, Tema.ALTO_TOQUE))
	borrar.name = "Borrar"
	borrar.pressed.connect(pedir.bind(Accion.BORRAR, numero))
	ficha.add_child(borrar)
	var restaurar: Button = _boton("Restaurar", Vector2(ANCHO_FICHA, Tema.ALTO_TOQUE))
	restaurar.name = "Restaurar"
	restaurar.pressed.connect(pedir.bind(Accion.RESTAURAR, numero))
	ficha.add_child(restaurar)
	_principales.append(principal)
	_detalles.append(texto)
	_rastros.append(rastro)
	_borrar.append(borrar)
	_restaurar.append(restaurar)


func _armar_confirmacion() -> void:
	_confirmar = ColorRect.new()
	_confirmar.name = "Confirmar"
	_confirmar.color = Color(0.0, 0.0, 0.0, 0.8)
	_confirmar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_confirmar.visible = false
	add_child(_confirmar)
	var caja: VBoxContainer = VBoxContainer.new()
	caja.add_theme_constant_override(&"separation", 32)
	caja.set_anchors_preset(Control.PRESET_CENTER)
	caja.grow_horizontal = Control.GROW_DIRECTION_BOTH
	caja.grow_vertical = Control.GROW_DIRECTION_BOTH
	_confirmar.add_child(caja)
	_pregunta = Label.new()
	_pregunta.custom_minimum_size = Vector2(800.0, 0.0)
	_pregunta.add_theme_font_size_override(&"font_size", 40)
	_pregunta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pregunta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caja.add_child(_pregunta)
	var botones: HBoxContainer = HBoxContainer.new()
	botones.add_theme_constant_override(&"separation", 64)
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	caja.add_child(botones)
	_si = _boton("Borrar", Vector2(300.0, Tema.ALTO_TOQUE))
	_si.name = "Si"
	_si.pressed.connect(confirmar)
	botones.add_child(_si)
	_no = _boton("Cancelar", Vector2(300.0, Tema.ALTO_TOQUE))
	_no.name = "No"
	_no.pressed.connect(atras)
	botones.add_child(_no)


func _boton(texto: String, tamano: Vector2) -> Button:
	var boton: Button = Button.new()
	boton.text = texto
	boton.custom_minimum_size = tamano
	return boton
