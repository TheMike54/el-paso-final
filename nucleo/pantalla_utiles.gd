class_name PantallaUtiles
extends PaginaMarco
# Pagina Utiles del marco, armada en codigo como Amuletos: consulta el catalogo y lo que tiene Partida.
# Solo deja poner y quitar sentado en un banco; los utiles ocupan ranuras y no gastan carga de amuletos.
# La lista se desplaza con el dedo y el foco, cuya ficha da la descripcion; sin arte usa una brujula de gis.

## Botones por id del util, publicos para las pruebas.
var botones: Dictionary[StringName, Button] = {}

var _descripcion: Label = null


func _ready() -> void:
	super()
	var panel: ColorRect = Tema.fondo_menu()
	add_child(panel)
	var columna: VBoxContainer = _crear_columna_equipo(panel)
	_descripcion = Label.new()
	_descripcion.name = "Descripcion"
	_descripcion.custom_minimum_size.x = Tema.CELDA.x
	_descripcion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_descripcion.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(_descripcion)
	_crear_lista_equipo(columna)


func id_pagina() -> StringName:
	return &"utiles"


func titulo_pagina() -> String:
	return "Útiles"


func mostrar_en_marco() -> void:
	super()
	_mostrar()


## Pone o quita solo sentado; Partida comprueba catalogo, posesion y ranura.
func alternar(util: StringName) -> bool:
	if not puede_cambiar():
		return false
	var cambio: bool = Partida.desequipar_util(util) if Partida.util_equipado(util) else Partida.equipar_util(util)
	_actualizar()
	_describir(util)
	return cambio


func _mostrar() -> void:
	for hijo: Node in _lista.get_children():
		hijo.free()
	botones.clear()
	_descripcion.text = ""
	for util: StringName in Partida.utiles_tenidos:
		var ficha: FichaUtil = CatalogoEquipo.util(util)
		var fila: HBoxContainer = HBoxContainer.new()
		fila.name = String(util)
		fila.add_theme_constant_override(&"separation", int(Tema.SEPARACION_ICONO))
		_lista.add_child(fila)
		if ficha != null and ficha.icono != null:
			var icono: TextureRect = TextureRect.new()
			icono.name = "Icono"
			icono.texture = ficha.icono
			icono.custom_minimum_size = Vector2.ONE * Tema.LADO_ICONO_FILA
			icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
			fila.add_child(icono)
		else:
			fila.add_child(IconoArticulo.crear(IconoArticulo.Forma.UTIL, Tema.LADO_ICONO_FILA, false))
		var boton: Button = Button.new()
		boton.name = String(util)
		boton.custom_minimum_size = Tema.CELDA
		boton.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		boton.pressed.connect(alternar.bind(util))
		boton.focus_entered.connect(_describir.bind(util))
		boton.mouse_entered.connect(_describir.bind(util))
		boton.gui_input.connect(_al_tocar.bind(util))
		fila.add_child(boton)
		botones[util] = boton
	_actualizar()
	if not botones.is_empty():
		_describir(Partida.utiles_tenidos[0])
		Tema.dar_foco(botones[Partida.utiles_tenidos[0]])


func _actualizar() -> void:
	var sentado: bool = puede_cambiar()
	if Partida.utiles_tenidos.is_empty():
		_aviso.text = "Todavía no tienes útiles."
	else:
		_aviso.text = _aviso_equipo(sentado, "ranuras", Partida.utiles_equipados.size(), Partida.MAX_UTILES)
	for util: StringName in botones:
		var ficha: FichaUtil = CatalogoEquipo.util(util)
		var nombre: String = ficha.nombre if ficha != null else String(util).capitalize()
		var puesto: bool = Partida.util_equipado(util)
		botones[util].text = "%s: %s" % [nombre, "puesto" if puesto else "guardado"]
		botones[util].disabled = not sentado or (not puesto and not Partida.puede_equipar_util(util))


func _describir(util: StringName) -> void:
	var ficha: FichaUtil = CatalogoEquipo.util(util)
	_descripcion.text = ficha.descripcion if ficha != null else ""


# Tambien permite consultar una fila deshabilitada (de pie o sin ranura) al tocarla.
func _al_tocar(evento: InputEvent, util: StringName) -> void:
	if ((evento is InputEventScreenTouch and (evento as InputEventScreenTouch).pressed)
			or (evento is InputEventMouseButton and (evento as InputEventMouseButton).pressed)):
		_describir(util)
