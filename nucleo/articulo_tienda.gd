class_name ArticuloTienda
extends Resource
# Un articulo de una Tienda, como el ShopItem de Silksong: nombre, descripcion, precio en PejeCoins y la Recompensa que
# entrega. Se vende una sola vez (la v1 no tiene objetos de inventario que gastar) y puede pedir una habilidad para
# aparecer. Es dato: las tiendas del juego se arman con fichas, sin tocar el nucleo.

## Unico dentro de su tienda: lo comprado se marca como <id de la tienda>_<id> en el estado de su sala.
@export var id: String = ""
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
## En PejeCoins, mayor que 0.
@export var precio: int = 1
## Lo que se entrega al comprarlo (vida maxima, amuleto, habilidad o mapa).
@export var recompensa: Recompensa = null
## Habilidad que hay que tener para que aparezca; vacia: siempre.
@export var requisito: StringName = &""


## Si se muestra con lo que tiene la partida: sin requisito o con la habilidad.
func a_la_vista() -> bool:
	return requisito.is_empty() or Partida.tiene(requisito)
