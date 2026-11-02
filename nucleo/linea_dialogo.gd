class_name LineaDialogo
extends Resource
# Una linea de conversacion contiene quien habla, el texto y sus opciones.
# Es dato, no codigo: se cambia sin tocar el nucleo.
# CajaDialogo la presenta y sigue sus destinos.

## Destinos especiales de una opcion: terminar contando la conversacion, o terminar sin contarla (se repite).
const FIN: int = -1
const CANCELAR: int = -2
## Opciones que caben en fila.
const MAX_OPCIONES: int = 3

## Quien habla; vacio, sin nombre.
@export var quien: String = ""
## Lo que dice, completo (sin armar frases a pedazos).
@export_multiline var texto: String = ""
## Vacio: avanzar pasa a la linea siguiente (o termina contando si es la ultima).
@export var opciones: Array[String] = []
## Una por opcion: indice de la linea a la que salta, FIN o CANCELAR.
@export var destinos: Array[int] = []


## Una linea sin opciones: quien habla y lo que dice.
static func nueva(de_quien: String, que_dice: String) -> LineaDialogo:
	var linea: LineaDialogo = LineaDialogo.new()
	linea.quien = de_quien
	linea.texto = que_dice
	return linea
