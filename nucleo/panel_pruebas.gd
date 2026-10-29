class_name PanelPruebas
extends CanvasLayer
# Panel de pruebas de la sala (maqueta aprobada el 25-oct-2026), solo con el modo desarrollador y el ajuste
# panel_pruebas: oculto es una pestana «‹ Pruebas» a media altura a la derecha (lejos de Pausa y Mapa, arriba, y de
# saltar y atacar, abajo); abierto, una tarjeta con «Ocultar ›» y un boton por grupo de la sala que lo apaga y lo
# enciende. Encuentra las piezas por su grupo o su clase: una sala nueva tiene sus interruptores sin codigo.

## Debajo del fundido (15) y encima de la caja de dialogo (12).
const CAPA: int = 13
## Ancho de cada boton: mas chico que una fila de Configuracion para tapar poco del juego.
const ANCHO_BOTON: float = 220.0
## Donde empieza la tarjeta: debajo de Pausa y Mapa.
const ARRIBA: float = 96.0
## Nombre en pantalla de cada grupo y su grupo de nodos; Partículas son todos los CPUParticles2D de la sala.
const GRUPOS: Dictionary[String, StringName] = {
	"Luces": LuzSala.GRUPO,
	"Niebla": Niebla.GRUPO,
	"Partículas": &"",
	"Cables": Colgante.GRUPO,
	"Fondos": FondoTapado.GRUPO,
}

var _pestana: Button = null
var _tarjeta: PanelContainer = null
var _filas: GridContainer = null
# Si cada grupo esta apagado, por su nombre en pantalla.
var _apagados: Dictionary[String, bool] = {}
# Como estaba cada nodo antes de apagarlo (visible y process_mode): al encenderlo vuelve a eso, no a visible. Asi la
# niebla con su ajuste apagado sigue oculta y no se mide de mas.
var _antes: Dictionary[Node, Array] = {}


func _ready() -> void:
	name = &"PanelPruebas"
	layer = CAPA
	var raiz: Control = Control.new()
	raiz.theme = Tema.crear()
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(raiz)
	_pestana = Tema.boton("‹  Pruebas", Vector2(0.0, Tema.ALTO_TOQUE))
	_pestana.name = &"Pestana"
	_pestana.add_theme_font_size_override(&"font_size", Tema.LETRA_CHICA)
	_pestana.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_pestana.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_pestana.offset_right = -Tema.MARGEN_DERECHO
	_pestana.pressed.connect(abrir.bind(true))
	raiz.add_child(_pestana)
	_tarjeta = PanelContainer.new()
	_tarjeta.name = &"Tarjeta"
	_tarjeta.theme_type_variation = Tema.TARJETA
	_tarjeta.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	_tarjeta.offset_left = -2.0 * ANCHO_BOTON - Tema.SEPARACION - Tema.MARGEN_LATERAL
	_tarjeta.offset_right = -Tema.MARGEN_DERECHO
	_tarjeta.offset_top = ARRIBA
	_tarjeta.offset_bottom = -Tema.MARGEN_VERTICAL
	raiz.add_child(_tarjeta)
	var columna: VBoxContainer = VBoxContainer.new()
	columna.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	_tarjeta.add_child(columna)
	var ocultar: Button = Tema.boton("Ocultar  ›", Vector2(0.0, Tema.ALTO_TOQUE))
	ocultar.name = &"Ocultar"
	ocultar.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ocultar.add_theme_font_size_override(&"font_size", Tema.LETRA_CHICA)
	ocultar.pressed.connect(abrir.bind(false))
	columna.add_child(ocultar)
	var desplazable: ScrollContainer = ScrollContainer.new()
	desplazable.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desplazable.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columna.add_child(desplazable)
	_filas = GridContainer.new()
	_filas.name = &"Filas"
	_filas.columns = 2
	_filas.add_theme_constant_override(&"h_separation", int(Tema.SEPARACION))
	_filas.add_theme_constant_override(&"v_separation", int(Tema.SEPARACION_FILAS))
	desplazable.add_child(_filas)
	abrir(false)
	_aplicar()
	Eventos.ajuste_grafico_cambiado.connect(_al_cambiar_ajuste)
	# Las piezas de la sala entran despues que este nodo: los botones se arman al final del cuadro.
	_armar.call_deferred()


## Abre la tarjeta (con los botones) o la deja en la pestana.
func abrir(si: bool) -> void:
	_tarjeta.visible = si
	_pestana.visible = not si


## Apaga o enciende un grupo: oculto y sin proceso, o como estaba. Publico para la prueba.
func apagar(grupo: String, apagado: bool) -> void:
	_apagados[grupo] = apagado
	for nodo: Node in nodos_de(grupo):
		var dibujo: CanvasItem = nodo as CanvasItem
		if apagado:
			if not _antes.has(nodo):
				_antes[nodo] = [dibujo.visible if dibujo != null else true, nodo.process_mode]
			if dibujo != null:
				dibujo.visible = false
			nodo.process_mode = Node.PROCESS_MODE_DISABLED
		elif _antes.has(nodo):
			var estaba: Array = _antes[nodo]
			if dibujo != null:
				dibujo.visible = estaba[0] as bool
			nodo.process_mode = estaba[1] as Node.ProcessMode
			_antes.erase(nodo)
	_poner_texto(grupo)


## Los nodos de la sala de un grupo del panel.
func nodos_de(grupo: String) -> Array[Node]:
	var nombre: StringName = GRUPOS[grupo]
	if not nombre.is_empty():
		return get_tree().get_nodes_in_group(nombre)
	var lista: Array[Node] = []
	lista.assign(get_parent().find_children("*", "CPUParticles2D", true, false))
	return lista


func _armar() -> void:
	for grupo: String in GRUPOS:
		if nodos_de(grupo).is_empty():
			continue
		var boton: Button = Tema.boton(grupo, Vector2(ANCHO_BOTON, Tema.ALTO_TOQUE))
		boton.name = grupo
		boton.add_theme_font_size_override(&"font_size", Tema.LETRA_CHICA)
		boton.pressed.connect(func() -> void: apagar(grupo, not (_apagados.get(grupo, false) as bool)))
		_filas.add_child(boton)
		_apagados[grupo] = false
	if _apagados.is_empty():
		var vacio: Label = Label.new()
		vacio.name = &"Vacio"
		vacio.text = "Esta sala no tiene grupos."
		vacio.theme_type_variation = Tema.TENUE
		_filas.add_child(vacio)


# Encendido en gis; apagado gastado y marcado con «·».
func _poner_texto(grupo: String) -> void:
	var boton: Button = _filas.get_node_or_null(NodePath(grupo)) as Button
	if boton == null:
		return
	var apagado: bool = _apagados.get(grupo, false)
	boton.text = "· " + grupo if apagado else grupo
	boton.modulate = Tema.GASTADO if apagado else Color.WHITE


func _aplicar() -> void:
	visible = Ajustes.desarrollo(Ajustes.PANEL_PRUEBAS)


func _al_cambiar_ajuste(clave: StringName) -> void:
	if clave == Ajustes.PANEL_PRUEBAS or clave == Ajustes.MODO_DESARROLLADOR:
		_aplicar()
