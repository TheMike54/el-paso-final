class_name MenuTienda
extends CanvasLayer
# Menu de una Tienda como los de Hollow Knight y Silksong: el juego detenido y a la vista a la izquierda, y en la mitad
# derecha del area util, sobre un velo, la lista y el detalle. Elegir pide confirmar con la Confirmacion compartida;
# Volver, Circulo / B, pausa y Atras de Android cierran un nivel. Lo crea la Tienda al abrirlo y se libera al cerrarlo;
# mientras existe, la pausa no se abre (grupo pantalla_encima). Las PejeCoins las muestra el HUD, avisado por el bus.

signal cerrado

## Encima del juego, la caja de dialogo y el fundido; nunca a la vez que la pausa o el marco de menus.
const CAPA: int = 20
## Ancho de la columna de filas (icono, moneda y precio) y separacion entre ella y el detalle.
const ANCHO_FILAS: float = 260.0
const SEPARACION_DETALLE: float = 32.0
## Si al detalle le quedan menos px que esto a la derecha de las filas, va debajo de ellas (medido en capturas: con la
## vista de 1280 de ancho, 4:3 y 16:9, le quedan 284).
const ANCHO_MINIMO_DETALLE: float = 240.0
## El velo empieza este tanto a la izquierda del panel, para que la franja y Volver no queden en su orilla.
const MARGEN_VELO: float = 32.0
const NADA: String = "Ya no hay nada a la venta"

var tienda: Tienda = null
## Publicos para las pruebas.
var lista: ListaElegir = null
var visibles: Array[ArticuloTienda] = []
var confirmacion: Confirmacion = null
## Raiz transparente a pantalla completa (detiene los toques sobre el juego), el velo de la mitad derecha y el detalle.
var fondo: ColorRect = null
var velo: ColorRect = null
var nombre: Label = null
var descripcion: Label = null

var _elegido: int = -1
var _area: Control = null
var _detalle: VBoxContainer = null


func _ready() -> void:
	layer = CAPA
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_physics_priority = MarcoMenus.PRIORIDAD_FISICA
	add_to_group(MarcoMenus.GRUPO)
	# Transparente y con mouse_filter STOP (el de fondo_menu): el juego se ve a la izquierda pero no se toca.
	fondo = Tema.fondo_menu(0.0)
	add_child(fondo)
	velo = ColorRect.new()
	velo.name = "Velo"
	velo.color = Color(0.0, 0.0, 0.0, Tema.VELO)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.add_child(velo)
	_area = Control.new()
	_area.name = "Area"
	_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.add_child(_area)
	Tema.ajustar(_area)
	_armar_lista()
	_area.resized.connect(_acomodar)
	fondo.resized.connect(_acomodar)
	_armar_confirmacion(fondo)
	get_tree().paused = true
	rehacer(-1)
	_acomodar()
	Eventos.tienda_abierta.emit()


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"volver") or Input.is_action_just_pressed(&"pausa"):
		atras()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		atras()


## La pausa no se abre con la tienda a la vista (ni en el tick en que se cierra: el menu sigue en el arbol).
func bloquea_pausa() -> bool:
	return true


## Vuelve a leer lo que esta a la venta y lo que alcanza, con el foco en la fila foco (o la primera que se puede).
func rehacer(foco: int) -> void:
	visibles = tienda.a_la_venta() if tienda != null else ([] as Array[ArticuloTienda])
	var precios: PackedStringArray = []
	var datos: PackedStringArray = []
	var apagar: Array[bool] = []
	for articulo: ArticuloTienda in visibles:
		precios.append(str(articulo.precio))
		datos.append("")
		apagar.append(articulo.precio > Partida.monedas)
	if visibles.is_empty():
		precios.append("")
		datos.append("")
		apagar.append(true)
	lista.armar(precios, datos, apagar, mini(foco, visibles.size() - 1))
	for i: int in range(visibles.size()):
		var fila: Button = lista.filas[i]
		var icono: IconoArticulo = IconoArticulo.crear(IconoArticulo.forma_de(visibles[i]), Tema.LADO_ICONO_FILA, apagar[i])
		fila.add_child(icono)
		icono.position = Vector2(Tema.MARGEN_DERECHO, (Tema.ALTO_TOQUE - Tema.LADO_ICONO_FILA) / 2.0)
		var moneda: IconoArticulo = IconoArticulo.crear(IconoArticulo.Forma.MONEDA, Tema.LADO_MONEDA_FILA, apagar[i])
		moneda.name = "Moneda"
		fila.add_child(moneda)
		moneda.position = Vector2(Tema.MARGEN_DERECHO + Tema.LADO_ICONO_FILA + Tema.SEPARACION_ICONO,
				(Tema.ALTO_TOQUE - Tema.LADO_MONEDA_FILA) / 2.0)
	_al_enfocar(lista.con_franja_en())


## Un nivel atras: de la confirmacion a la lista (como No, sin comprar); de la lista, cierra.
func atras() -> void:
	if confirmacion.visible:
		confirmacion.cancelar()
	else:
		cerrar()


func cerrar() -> void:
	if is_queued_for_deletion():
		return
	get_tree().paused = false
	Eventos.tienda_cerrada.emit()
	cerrado.emit()
	queue_free()


## Compra lo que se confirmo y rehace la lista. Publica para las pruebas; en el juego la llama Si (una vez por
## confirmacion: la Confirmacion no emite dos veces).
func confirmar() -> bool:
	confirmacion.cerrar()
	_mostrar_lista(true)
	if _elegido < 0 or _elegido >= visibles.size():
		return false
	var hecho: bool = tienda.comprar(visibles[_elegido])
	rehacer(_elegido)
	return hecho


func _al_elegir(indice: int) -> void:
	if indice >= visibles.size():
		return
	_elegido = indice
	var articulo: ArticuloTienda = visibles[indice]
	# Con la confirmacion abierta la lista se oculta, como en las ranuras: si no, con el control el foco se escapa a
	# las filas de detras.
	_mostrar_lista(false)
	# El foco en Si, como el cobro de Silksong (plan nucleo-tienda-gis).
	confirmacion.abrir("¿Comprar %s?" % articulo.nombre, "Sí", "No", Confirmacion.Foco.SI, "%d PejeCoins" % articulo.precio)


func _al_enfocar(indice: int) -> void:
	if indice >= 0 and indice < visibles.size():
		nombre.text = visibles[indice].nombre
		descripcion.text = visibles[indice].descripcion
	else:
		nombre.text = NADA if visibles.is_empty() else ""
		descripcion.text = ""


# No o Atras: vuelve a la lista sin comprar, con el foco en lo que se habia elegido.
func _al_cancelar() -> void:
	_mostrar_lista(true)
	if _elegido >= 0 and _elegido < lista.filas.size():
		Tema.dar_foco(lista.filas[_elegido])


# La lista y el detalle se ocultan con la confirmacion abierta, y el velo pasa a toda la pantalla: la confirmacion se
# ve como antes de partir la pantalla (pieza 3 del paso 7).
func _mostrar_lista(mostrar: bool) -> void:
	lista.visible = mostrar
	_acomodar()


# La ListaElegir en la mitad derecha del area util, con el aspecto de la tienda: filas de icono de gis por tipo, moneda
# y precio (en gris lo que no alcanza), la franja de gis en la elegida, sin encabezado ni pie, y el detalle (nombre en
# gis grueso y descripcion) junto a las filas (debajo, si no cabe).
func _armar_lista() -> void:
	lista = ListaElegir.new()
	lista.name = "Lista"
	lista.variacion_fila = Tema.FILA_TIENDA
	lista.variacion_fila_apagada = Tema.FILA_TIENDA_APAGADA
	lista.con_franja = true
	_area.add_child(lista)
	lista.anchor_left = 0.5
	lista.anchor_right = 1.0
	lista.anchor_bottom = 1.0
	lista.offset_left = 0.0
	lista.offset_top = 0.0
	lista.offset_right = 0.0
	lista.offset_bottom = 0.0
	lista.titulo.text = tienda.nombre if tienda != null else "Tienda"
	# El nombre de la tienda comparte la barra con Volver en media pantalla: si no cabe, baja de linea.
	lista.titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lista.encabezado.visible = false
	lista.pie.visible = false
	lista.cuerpo.add_theme_constant_override(&"separation", int(SEPARACION_DETALLE))
	lista.desliza.size_flags_horizontal = Control.SIZE_FILL
	lista.desliza.custom_minimum_size = Vector2(ANCHO_FILAS, 0.0)
	_detalle = VBoxContainer.new()
	_detalle.name = "Detalle"
	_detalle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detalle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detalle.add_theme_constant_override(&"separation", int(Tema.SEPARACION))
	lista.cuerpo.add_child(_detalle)
	nombre = Label.new()
	nombre.name = "Nombre"
	nombre.theme_type_variation = Tema.TITULO
	nombre.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detalle.add_child(nombre)
	descripcion = Label.new()
	descripcion.name = "Descripcion"
	descripcion.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detalle.add_child(descripcion)
	lista.elegida.connect(_al_elegir)
	lista.enfocada.connect(_al_enfocar)
	lista.cerrada.connect(cerrar)


# El velo cubre de la orilla del panel (menos MARGEN_VELO) a la derecha de la pantalla; con la lista oculta (la
# confirmacion abierta), toda. El detalle va a la derecha de las filas si le quedan ANCHO_MINIMO_DETALLE px.
func _acomodar() -> void:
	if velo == null or lista == null:
		return
	var desde: float = 0.0
	if lista.visible:
		desde = maxf(0.0, _area.position.x + _area.size.x * 0.5 - MARGEN_VELO)
	velo.position = Vector2(desde, 0.0)
	velo.size = Vector2(fondo.size.x - desde, fondo.size.y)
	var libre: float = _area.size.x * 0.5 - ANCHO_FILAS - SEPARACION_DETALLE
	var abajo: bool = libre < ANCHO_MINIMO_DETALLE
	if lista.cuerpo.vertical != abajo:
		lista.cuerpo.vertical = abajo


# La Confirmacion compartida con el aspecto del cobro de Silksong (el foco en Si lo pone _al_elegir): sin velo propio
# (lo oscurece el velo del menu, que pasa a toda la pantalla), la pregunta con la letra de 36 que tenia la tienda, el
# precio en su linea y Si y No centrados con flechitas de gis.
func _armar_confirmacion(raiz: Control) -> void:
	confirmacion = Confirmacion.new()
	confirmacion.name = "Confirmacion"
	confirmacion.alfa_velo = 0.0
	confirmacion.variacion_pregunta = Tema.DESTACADA
	confirmacion.variacion_boton = Tema.OPCION_CENTRADA
	confirmacion.confirmada.connect(confirmar)
	confirmacion.cancelada.connect(_al_cancelar)
	raiz.add_child(confirmacion)
