class_name PantallaUtiles
extends PaginaMarco
# Pagina Utiles del marco, encima del juego detenido: a la izquierda la mochila de gis con sus 4 cupos y la cuenta en
# circulos, al centro la lista y a la derecha el detalle. Tocar una fila o un cupo lleno solo elige; poner o quitar va
# en el boton del detalle, y solo sentado en un banco, como en Silksong. Los utiles no gastan carga de amuletos.
# Armada en codigo; Partida cuida el catalogo, la posesion y los cupos (MAX_UTILES).

## Botones de la lista por id del util; publicos para las pruebas.
var botones: Dictionary[StringName, Button] = {}
## Los 4 cupos de la mochila, en orden; publicos para las pruebas.
var cupos: Array[Button] = []
## Publicos para las pruebas.
var cuenta: Circulos = null
var vacio: Label = null

var _cuerpo: HBoxContainer = null
var _rejilla: GridContainer = null


func _ready() -> void:
	super()
	var panel: ColorRect = Tema.fondo_menu()
	add_child(panel)
	_cuerpo = HBoxContainer.new()
	_cuerpo.name = "Cuerpo"
	_cuerpo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Mas junto que Amuletos: con la mochila, la lista se queda angosta y «Antiderrapante» no cabia en una linea.
	_cuerpo.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	panel.add_child(_cuerpo)
	_acomodar_en_contenido(_cuerpo)
	_cuerpo.add_child(_crear_bolsa())
	var lista: VBoxContainer = VBoxContainer.new()
	lista.name = "Lista"
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lista.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	_cuerpo.add_child(lista)
	var desplazable: ScrollContainer = _crear_desplazable(1)
	_rejilla = desplazable.get_node(^"Fichas") as GridContainer
	lista.add_child(desplazable)
	lista.add_child(_indicador_mas(desplazable))
	_crear_detalle(_cuerpo)
	vacio = _crear_vacio("Todavía no tienes útiles.")
	panel.add_child(vacio)
	_acomodar_en_contenido(vacio)


func id_pagina() -> StringName:
	return &"utiles"


func titulo_pagina() -> String:
	return "Útiles"


func mostrar_en_marco() -> void:
	super()
	_mostrar()


## Pone o quita solo sentado; Partida comprueba catalogo, posesion y cupo libre. Lo usa el boton del detalle.
func alternar(util: StringName) -> bool:
	if not puede_cambiar():
		return false
	var cambio: bool = Partida.desequipar_util(util) if Partida.util_equipado(util) else Partida.equipar_util(util)
	_actualizar()
	return cambio


## Elige un util (desde la lista o desde su cupo) y llena el detalle. No cambia nada.
func elegir(util: StringName) -> void:
	super(util)
	_marcar_elegido(botones)
	for i: int in range(cupos.size()):
		cupos[i].set_pressed_no_signal(i < Partida.utiles_equipados.size() and Partida.utiles_equipados[i] == elegido)
	var ficha: FichaUtil = CatalogoEquipo.util(util)
	var nombre: String = ficha.nombre if ficha != null else String(util).capitalize()
	var descripcion: String = ficha.descripcion if ficha != null else ""
	detalle.mostrar(nombre, _icono(ficha, DetalleMenu.LADO_IMAGEN), descripcion, motivo(util), rotulo(util))


## Lo que dice el detalle abajo: por que no se puede cambiar, o si esta en un cupo.
func motivo(util: StringName) -> String:
	if CatalogoEquipo.util(util) == null:
		return ""
	if not puede_cambiar():
		return "Siéntate en un banco para cambiarlos."
	if Partida.util_equipado(util):
		return "En un cupo"
	if not Partida.puede_equipar_util(util):
		return "Cupos llenos: toca un cupo de la mochila y quítalo primero."
	return "Sin usar"


## El texto del boton del detalle; vacio si no se puede cambiar (de pie, cupos llenos o fuera del catalogo).
func rotulo(util: StringName) -> String:
	if not puede_cambiar() or CatalogoEquipo.util(util) == null:
		return ""
	if Partida.util_equipado(util):
		return "Quitar"
	return "Poner" if Partida.puede_equipar_util(util) else ""


func _crear_bolsa() -> VBoxContainer:
	var bolsa: VBoxContainer = VBoxContainer.new()
	bolsa.name = "Bolsa"
	bolsa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bolsa.alignment = BoxContainer.ALIGNMENT_CENTER
	var dibujo: DibujoMochila = DibujoMochila.new()
	dibujo.name = "Mochila"
	bolsa.add_child(dibujo)
	for i: int in range(Partida.MAX_UTILES):
		var cupo: Button = Button.new()
		cupo.name = "Cupo%d" % i
		cupo.theme_type_variation = Tema.TARJETA
		cupo.toggle_mode = true
		var rect: Rect2 = DibujoMochila.cupo_rect(i)
		cupo.position = rect.position
		cupo.size = rect.size
		cupo.custom_minimum_size = rect.size
		cupo.pressed.connect(_al_tocar_cupo.bind(i))
		cupo.focus_entered.connect(_al_enfocar_cupo.bind(i))
		dibujo.add_child(cupo)
		cupos.append(cupo)
	var fila: HBoxContainer = HBoxContainer.new()
	fila.name = "Cuenta"
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	bolsa.add_child(fila)
	var rotulo_cupos: Label = Label.new()
	rotulo_cupos.name = "Rotulo"
	rotulo_cupos.text = "cupos"
	rotulo_cupos.theme_type_variation = Tema.TENUE
	rotulo_cupos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_child(rotulo_cupos)
	cuenta = Circulos.new()
	cuenta.name = "Circulos"
	fila.add_child(cuenta)
	return bolsa


func _mostrar() -> void:
	for hijo: Node in _rejilla.get_children():
		hijo.free()
	botones.clear()
	var hay: bool = not Partida.utiles_tenidos.is_empty()
	vacio.visible = not hay
	_cuerpo.visible = hay
	for util: StringName in Partida.utiles_tenidos:
		var ficha: FichaUtil = CatalogoEquipo.util(util)
		var nombre: String = ficha.nombre if ficha != null else String(util).capitalize()
		botones[util] = _fila_equipo(util, nombre, _icono(ficha, Tema.LADO_ICONO_FILA), 0)
		_rejilla.add_child(botones[util])
	_actualizar()
	if not hay:
		elegido = &""
		detalle.limpiar()
		return
	if not botones.has(elegido):
		elegido = Partida.utiles_tenidos[0]
	elegir(elegido)
	Tema.dar_foco(botones[elegido])


func _actualizar() -> void:
	var sentado: bool = puede_cambiar()
	cuenta.poner(Partida.utiles_equipados.size(), Partida.MAX_UTILES)
	for i: int in range(cupos.size()):
		_pintar_cupo(cupos[i], Partida.utiles_equipados[i] if i < Partida.utiles_equipados.size() else &"")
	for util: StringName in botones:
		var puesto: bool = Partida.util_equipado(util)
		var apagada: bool = (CatalogoEquipo.util(util) == null
				or (sentado and not puesto and not Partida.puede_equipar_util(util)))
		_pintar_fila(botones[util], "En un cupo" if puesto else "Sin usar", puesto, apagada)
	if botones.has(elegido):
		elegir(elegido)


# Un cupo lleno muestra el icono de su util y se toca para elegirlo; uno vacio dice «vacío» y no se toca ni toma foco.
func _pintar_cupo(cupo: Button, util: StringName) -> void:
	for hijo: Node in cupo.get_children():
		hijo.free()
	var lleno: bool = not util.is_empty()
	cupo.focus_mode = Control.FOCUS_ALL if lleno else Control.FOCUS_NONE
	cupo.mouse_filter = Control.MOUSE_FILTER_STOP if lleno else Control.MOUSE_FILTER_IGNORE
	var contenido: Control = null
	if lleno:
		contenido = _icono(CatalogoEquipo.util(util), DibujoMochila.LADO_CUPO * 0.72)
		contenido.name = "Icono"
	else:
		var texto: Label = Label.new()
		texto.name = "Vacio"
		texto.text = "vacío"
		texto.theme_type_variation = Tema.TENUE
		texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		contenido = texto
	contenido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cupo.add_child(contenido)
	contenido.set_anchors_and_offsets_preset(Control.PRESET_CENTER if lleno else Control.PRESET_FULL_RECT)
	if lleno:
		contenido.position = (cupo.size - contenido.custom_minimum_size) / 2.0
		contenido.size = contenido.custom_minimum_size


func _al_tocar_cupo(indice: int) -> void:
	if indice < Partida.utiles_equipados.size():
		_al_pulsar(Partida.utiles_equipados[indice])


func _al_enfocar_cupo(indice: int) -> void:
	if indice < Partida.utiles_equipados.size():
		elegir(Partida.utiles_equipados[indice])


func _al_accion() -> void:
	alternar(elegido)
	if not detalle.accion.visible and botones.has(elegido):
		Tema.dar_foco(botones[elegido])


func _icono(ficha: FichaUtil, lado: float) -> Control:
	return _icono_equipo(ficha.icono if ficha != null else null, IconoArticulo.Forma.UTIL, lado)
