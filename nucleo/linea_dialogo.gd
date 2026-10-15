class_name LineaDialogo
extends Resource
# Una linea de una conversacion: quien habla, que dice y, si pregunta algo, sus opciones en fila con el destino de
# cada una. Es dato, no codigo: el texto lo cambia quien escribe sin tocar el nucleo (lo usa CajaDialogo).

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
