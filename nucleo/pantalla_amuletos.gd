class_name PantallaAmuletos
extends PaginaMarco
# Pagina Amuletos del marco de menus (MarcoMenus), encima del juego detenido. Arriba, lo que se lleva puesto y la carga
# en circulos; abajo, los amuletos en dos columnas y, a la derecha, el detalle (DetalleMenu). Tocar una fila solo la
# elige; poner o quitar va en el boton del detalle, y solo sentado en un banco, como en Hollow Knight. Lo que no se
# puede hacer se explica en el detalle. Armada en codigo; Partida cuida el catalogo, la carga y que se tengan.

## Columnas de la lista, como en el mockup aprobado.
const COLUMNAS: int = 2

## Botones de la lista, por id del amuleto; publico para la prueba.
var botones: Dictionary[StringName, Button] = {}
## Publicos para la prueba.
var carga: Circulos = null
var vacio: Label = null

var _cuerpo: HBoxContainer = null
var _lleva: HBoxContainer = null
var _rejilla: GridContainer = null


func _ready() -> void:
	super()
	var panel: ColorRect = Tema.fondo_menu()
	add_child(panel)
	_cuerpo = HBoxContainer.new()
	_cuerpo.name = "Cuerpo"
	_cuerpo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cuerpo.add_theme_constant_override(&"separation", int(2.0 * Tema.SEPARACION))
	panel.add_child(_cuerpo)
	_acomodar_en_contenido(_cuerpo)
	var lista: VBoxContainer = VBoxContainer.new()
	lista.name = "Lista"
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lista.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	_cuerpo.add_child(lista)
	lista.add_child(_crear_puesto())
	var desplazable: ScrollContainer = _crear_desplazable(COLUMNAS)
	_rejilla = desplazable.get_node(^"Fichas") as GridContainer
	lista.add_child(desplazable)
	lista.add_child(_indicador_mas(desplazable))
	_crear_detalle(_cuerpo)
	vacio = _crear_vacio("Todavía no tienes amuletos.")
	panel.add_child(vacio)
	_acomodar_en_contenido(vacio)


func id_pagina() -> StringName:
	return &"amuletos"


func titulo_pagina() -> String:
	return "Amuletos"


func mostrar_en_marco() -> void:
	super()
	_mostrar()


## Pone o quita un amuleto, solo sentado. Devuelve si cambio algo. Lo usa el boton del detalle.
func alternar(amuleto: StringName) -> bool:
	if not puede_cambiar() or CatalogoEquipo.amuleto(amuleto) == null:
		return false
	var cambio: bool = Partida.desequipar(amuleto) if Partida.esta_equipado(amuleto) else Partida.equipar(amuleto)
	_actualizar()
	return cambio


## Elige un amuleto: lo marca en la lista y llena el detalle. No cambia el equipo.
func elegir(amuleto: StringName) -> void:
	super(amuleto)
	_marcar_elegido(botones)
	var ficha: FichaAmuleto = CatalogoEquipo.amuleto(amuleto)
	var nombre: String = ficha.nombre if ficha != null else nombre_de(amuleto)
	var descripcion: String = ficha.descripcion if ficha != null else ""
	detalle.mostrar(nombre, _icono(ficha, DetalleMenu.LADO_IMAGEN), descripcion, motivo(amuleto), rotulo(amuleto))


## Lo que dice el detalle abajo: por que no se puede cambiar, o si esta en uso.
func motivo(amuleto: StringName) -> String:
	var ficha: FichaAmuleto = CatalogoEquipo.amuleto(amuleto)
	if ficha == null:
		return ""
	if not puede_cambiar():
		return "Siéntate en un banco para cambiarlos."
	if Partida.esta_equipado(amuleto):
		return "En uso"
	if not Partida.puede_equipar(amuleto):
		return "No cabe: cuesta %d y te queda %d de carga." % [ficha.costo, Partida.carga_maxima - Partida.carga_usada()]
	return "Sin usar"


## El texto del boton del detalle; vacio si no se puede cambiar (de pie, no cabe o fuera del catalogo).
func rotulo(amuleto: StringName) -> String:
	if not puede_cambiar() or CatalogoEquipo.amuleto(amuleto) == null:
		return ""
	if Partida.esta_equipado(amuleto):
		return "Quitar"
	return "Poner" if Partida.puede_equipar(amuleto) else ""


func _crear_puesto() -> HBoxContainer:
	var puesto: HBoxContainer = HBoxContainer.new()
	puesto.name = "Puesto"
	puesto.custom_minimum_size.y = Tema.ALTO_TOQUE
	puesto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	puesto.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	Tema.raya_abajo(puesto)
	_lleva = HBoxContainer.new()
	_lleva.name = "Lleva"
	_lleva.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lleva.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lleva.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	puesto.add_child(_lleva)
	var rotulo_carga: Label = Label.new()
	rotulo_carga.name = "Rotulo"
	rotulo_carga.text = "carga"
	rotulo_carga.theme_type_variation = Tema.TENUE
	rotulo_carga.mouse_filter = Control.MOUSE_FILTER_IGNORE
	puesto.add_child(rotulo_carga)
	carga = Circulos.new()
	carga.name = "Carga"
	puesto.add_child(carga)
	return puesto


func _mostrar() -> void:
	for hijo: Node in _rejilla.get_children():
		hijo.free()
	botones.clear()
	var hay: bool = not Partida.amuletos_tenidos.is_empty()
	vacio.visible = not hay
	_cuerpo.visible = hay
	for amuleto: StringName in Partida.amuletos_tenidos:
		var ficha: FichaAmuleto = CatalogoEquipo.amuleto(amuleto)
		var nombre: String = ficha.nombre if ficha != null else nombre_de(amuleto)
		botones[amuleto] = _fila_equipo(amuleto, nombre, _icono(ficha, Tema.LADO_ICONO_FILA), ficha.costo if ficha != null else 0)
		_rejilla.add_child(botones[amuleto])
	_actualizar()
	if not hay:
		elegido = &""
		detalle.limpiar()
		return
	if not botones.has(elegido):
		elegido = Partida.amuletos_tenidos[0]
	elegir(elegido)
	Tema.dar_foco(botones[elegido])


func _actualizar() -> void:
	var sentado: bool = puede_cambiar()
	carga.poner(Partida.carga_usada(), Partida.carga_maxima)
	for hijo: Node in _lleva.get_children():
		hijo.free()
	for amuleto: StringName in Partida.amuletos_equipados:
		var puesto: Control = _icono(CatalogoEquipo.amuleto(amuleto), Tema.LADO_ICONO_FILA)
		puesto.name = String(amuleto)
		puesto.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		puesto.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_lleva.add_child(puesto)
	if Partida.amuletos_equipados.is_empty():
		var nada: Label = Label.new()
		nada.name = "Nada"
		nada.text = "Sin amuletos puestos"
		nada.theme_type_variation = Tema.TENUE
		nada.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_lleva.add_child(nada)
	for amuleto: StringName in botones:
		var puesto: bool = Partida.esta_equipado(amuleto)
		# Apagada la que no se puede poner sentado (no cabe) y la que no esta en el catalogo; de pie todas se leen igual.
		var apagada: bool = (CatalogoEquipo.amuleto(amuleto) == null
				or (sentado and not puesto and not Partida.puede_equipar(amuleto)))
		_pintar_fila(botones[amuleto], "En uso" if puesto else "Sin usar", puesto, apagada)
	if botones.has(elegido):
		elegir(elegido)


func _al_accion() -> void:
	alternar(elegido)
	if not detalle.accion.visible and botones.has(elegido):
		Tema.dar_foco(botones[elegido])


# El icono de una ficha (su imagen, o el amuleto de gis si no tiene) del lado pedido, sin agregar.
func _icono(ficha: FichaAmuleto, lado: float) -> Control:
	return _icono_equipo(ficha.icono if ficha != null else null, IconoArticulo.Forma.AMULETO, lado)


## Nombre de respaldo para un amuleto sin ficha en el catalogo.
static func nombre_de(amuleto: StringName) -> String:
	return String(amuleto).capitalize()
