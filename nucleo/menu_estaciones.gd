class_name MenuEstaciones
extends CanvasLayer
# Menu de destinos de una Estacion, con el juego detenido, como el del Ciervo de Hollow Knight: a la izquierda una
# ListaElegir con las estaciones abiertas de su tabla, en su orden, y el foco en la actual, en gris y sin elegirse; a la
# derecha su MapaEstaciones (sin indice del mapa, la lista sola). Elegir otra cierra el menu y la Estacion viaja;
# Volver, Circulo / B, pausa y Atras de Android lo cierran. Mientras existe, la pausa no se abre (grupo pantalla_encima).

signal cerrado

## La misma capa que la pausa y el menu de la tienda: nunca hay dos abiertos a la vez.
const CAPA: int = 20
const TITULO: String = "Viajar"
const AQUI: String = "Aquí"
const TEXTO_VIAJAR: String = "Viajar"
const TEXTO_CANCELAR: String = "Cancelar"
## El indice de salas del bloque mapa/: de sus rectangulos salen las posiciones del mapa. Se lee sin nombrar su clase.
const RUTA_INDICE: String = "res://mapa/indice_salas.tres"
## Ancho minimo de la lista con el mapa al lado (cabe el nombre y «Aquí»), el minimo del mapa (con menos, la lista
## sola) y la separacion entre los dos.
const ANCHO_LISTA: float = 480.0
const ANCHO_MINIMO_MAPA: float = 240.0
const SEPARACION_MAPA: float = 32.0
## Lo que el mapa mide a lo ancho por cada px de la lista, cuando hay sitio para los dos.
const PROPORCION_MAPA: float = 1.2

var estacion: Estacion = null
## De donde lee el indice; se fija antes de agregar el menu (una ruta que no existe deja la lista sola, como sin mapa/).
var ruta_indice: String = RUTA_INDICE
## Publicos para las pruebas: la lista, los ids de sus filas en orden, el mapa (null sin indice o sin el rectangulo de
## alguna estacion) y la fila de ayudas de abajo.
var lista: ListaElegir = null
var ids: PackedStringArray = []
var mapa: MapaEstaciones = null
var ayudas: HBoxContainer = null


func _ready() -> void:
	layer = CAPA
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_physics_priority = MarcoMenus.PRIORIDAD_FISICA
	add_to_group(MarcoMenus.GRUPO)
	var fondo: ColorRect = Tema.fondo_menu()
	add_child(fondo)
	lista = ListaElegir.new()
	lista.name = "Lista"
	fondo.add_child(lista)
	Tema.ajustar(lista)
	lista.titulo.text = TITULO
	lista.elegida.connect(_al_elegir)
	lista.cerrada.connect(cerrar)
	# El pie (la descripcion de la fila) nunca se lleno aqui: en su lugar van las ayudas de Viajar y Cancelar.
	lista.pie.visible = false
	_armar_ayudas()
	get_tree().paused = true
	_armar()
	lista.resized.connect(_acomodar)
	_acomodar()


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"volver") or Input.is_action_just_pressed(&"pausa"):
		cerrar()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		cerrar()


## La pausa no se abre con el menu a la vista (ni en el tick en que se cierra: el menu sigue en el arbol).
func bloquea_pausa() -> bool:
	return true


func cerrar() -> void:
	if is_queued_for_deletion():
		return
	get_tree().paused = false
	cerrado.emit()
	queue_free()


## El centro del rectangulo de cada sala, en orden; vacio si a alguna le falta el rectangulo (entonces no hay mapa).
static func centros_de(salas: PackedStringArray, rectangulos: Dictionary) -> PackedVector2Array:
	var centros: PackedVector2Array = []
	for sala: String in salas:
		var valor: Variant = rectangulos.get(sala)
		if not (valor is Rect2):
			return PackedVector2Array()
		var rectangulo: Rect2 = valor
		centros.append(rectangulo.get_center())
	return centros


func _armar() -> void:
	var propia: String = estacion.id if estacion != null else ""
	var tabla: FichaEstaciones = Estacion.tabla_de(Sala.clave_de(estacion)) if estacion != null else null
	var nombres: PackedStringArray = []
	var datos: PackedStringArray = []
	var apagar: Array[bool] = []
	var salas: PackedStringArray = []
	ids.clear()
	if tabla != null:
		for dato: DatoEstacion in tabla.estaciones:
			if dato != null and Partida.estacion_abierta(dato.id):
				ids.append(dato.id)
				salas.append(dato.sala)
				nombres.append(dato.nombre)
				datos.append(AQUI if dato.id == propia else "")
				apagar.append(dato.id == propia)
	# El mapa va antes de las filas: armar y el foco en la actual emiten enfocada, que lo marca.
	var centros: PackedVector2Array = PackedVector2Array() if salas.is_empty() else centros_de(salas, _rectangulos())
	if not centros.is_empty():
		_armar_mapa(centros, ids.find(propia))
	lista.armar(nombres, datos, apagar)
	lista.encabezado.text = "" if ids.size() > 1 else "Abre otra estación para viajar."
	# El foco en la actual, aunque este apagada: ListaElegir lo pondria en la primera que se elige.
	var actual: int = ids.find(propia)
	if actual >= 0:
		Tema.dar_foco(lista.filas[actual])


# Los rectangulos de las salas del indice del mapa (de ellos salen las posiciones del MapaEstaciones), con load() solo
# si existe y get(): el nucleo no depende de mapa/ ni nombra la clase del indice, igual que la sala carga
# mapa/pantalla_mapa.tscn. Vacio sin indice.
func _rectangulos() -> Dictionary:
	if ruta_indice.is_empty() or not ResourceLoader.exists(ruta_indice):
		return {}
	var indice: Resource = load(ruta_indice) as Resource
	if indice == null:
		return {}
	var valor: Variant = indice.get(&"rectangulos")
	if not (valor is Dictionary):
		return {}
	var rectangulos: Dictionary = valor
	return rectangulos


# El mapa a la derecha de las filas, dentro del cuerpo de la lista: la lista con su ancho minimo y el mapa con el resto.
func _armar_mapa(centros: PackedVector2Array, indice_actual: int) -> void:
	mapa = MapaEstaciones.new()
	mapa.name = "Mapa"
	mapa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mapa.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mapa.size_flags_stretch_ratio = PROPORCION_MAPA
	lista.cuerpo.add_child(mapa)
	lista.cuerpo.add_theme_constant_override(&"separation", int(SEPARACION_MAPA))
	lista.desliza.custom_minimum_size = Vector2(ANCHO_LISTA, 0.0)
	mapa.poner(centros, indice_actual)
	lista.enfocada.connect(mapa.marcar)


# Si al mapa no le quedan ANCHO_MINIMO_MAPA px junto a la lista, se oculta y la lista va a lo ancho.
func _acomodar() -> void:
	if mapa == null:
		return
	var cabe: bool = lista.size.x - ANCHO_LISTA - SEPARACION_MAPA >= ANCHO_MINIMO_MAPA
	if mapa.visible != cabe:
		mapa.visible = cabe


# Abajo a la derecha, como en Hollow Knight: el boton que viaja (ui_accept, el que pulsa la fila) y el que cierra
# (volver). Con el dedo no se ven, como todo IconoBoton; la fila guarda su alto para que nada salte.
func _armar_ayudas() -> void:
	ayudas = HBoxContainer.new()
	ayudas.name = "Ayudas"
	ayudas.alignment = BoxContainer.ALIGNMENT_END
	ayudas.custom_minimum_size = Vector2(0.0, Tema.ALTO_LETRA)
	ayudas.add_theme_constant_override(&"separation", int(Tema.SEPARACION * 3.0))
	ayudas.add_child(_ayuda("Viajar", &"ui_accept", TEXTO_VIAJAR))
	ayudas.add_child(_ayuda("Cancelar", &"volver", TEXTO_CANCELAR))
	lista.add_child(ayudas)


func _ayuda(nombre: String, accion: StringName, texto: String) -> IconoBoton:
	var icono: IconoBoton = IconoBoton.new()
	icono.name = nombre
	icono.accion = accion
	icono.texto = texto
	return icono


func _al_elegir(indice: int) -> void:
	var elegido: String = ids[indice]
	cerrar()
	if estacion != null:
		estacion.viajar(elegido)
