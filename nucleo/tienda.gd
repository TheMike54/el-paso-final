class_name Tienda
extends Interactuable
# Tienda de PejeCoins, como las de Silksong: con el jugador encima, interactuar abre su menu (MenuTienda) con el juego
# detenido; la capa, cerca y el disparador son de la base Interactuable. Vende cada articulo una sola vez: al comprarlo
# cobra, entrega su Recompensa, lo marca como <id>_<articulo> en el estado de su sala, lo avisa y autoguarda. Va como
# hija directa de una sala. Caja gris de 160x200 hasta que tenga arte: un CanvasItem hijo la apaga, como en el Porton.

const ANCHO: float = 160.0
const ALTO: float = 200.0
const COLOR: Color = Color(0.45, 0.4, 0.55, 1.0)
const ALTURA_AVISO: float = 240.0

## Unico en la sala; lo exige el validador en las salas con id.
@export var id: String = ""
## Lo que dice arriba del menu.
@export var nombre: String = "Tienda"
@export var articulos: Array[ArticuloTienda] = []

## El menu, mientras esta abierto; publico para las pruebas.
var menu: MenuTienda = null


func _ready() -> void:
	super()
	_crear_forma(ANCHO, ALTO)


## Abre el menu con el juego detenido. Publica para las pruebas; en el juego la llama interactuar.
func abrir() -> void:
	if menu != null:
		return
	menu = MenuTienda.new()
	menu.name = "Menu"
	menu.tienda = self
	menu.cerrado.connect(_al_cerrar)
	add_child(menu)
	cerca = false
	queue_redraw()


## Lo que se muestra: lo no comprado cuyo requisito se cumple, en el orden de articulos.
func a_la_venta() -> Array[ArticuloTienda]:
	var lista: Array[ArticuloTienda] = []
	for articulo: ArticuloTienda in articulos:
		if articulo != null and articulo.a_la_vista() and not comprado(articulo):
			lista.append(articulo)
	return lista


func comprado(articulo: ArticuloTienda) -> bool:
	return Partida.estado_de(Sala.clave_de(self), marca_de(articulo)) != null


## Como queda marcado un articulo comprado en el estado de la sala.
func marca_de(articulo: ArticuloTienda) -> String:
	return id + "_" + articulo.id


## Compra un articulo: false si ya se compro, no esta a la vista o no alcanzan las monedas; si no, cobra, entrega,
## marca, avisa con Eventos.articulo_comprado y autoguarda.
func comprar(articulo: ArticuloTienda) -> bool:
	if articulo == null or comprado(articulo) or not articulo.a_la_vista():
		return false
	if not Partida.gastar_monedas(articulo.precio):
		return false
	Partida.marcar(Sala.clave_de(self), marca_de(articulo))
	if articulo.recompensa != null:
		Partida.dar_recompensa(articulo.recompensa)
	Eventos.articulo_comprado.emit(articulo)
	Partida.autoguardar()
	return true


func _al_interactuar(_jugador_encima: Jugador) -> void:
	abrir()


# Con el menu abierto no sigue cerca ni abre otro.
func _puede_interactuar() -> bool:
	return menu == null


func _al_cerrar() -> void:
	menu = null


func _draw() -> void:
	dibujar_provisional(ANCHO, ALTO, COLOR)
	dibujar_aviso(ALTURA_AVISO)
