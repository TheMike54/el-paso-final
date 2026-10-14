class_name Recompensa
extends Resource
# Lo que entrega una EntregaRecompensas al juntar cierta cantidad de coleccionables, como las
# recompensas de las larvas en Hollow Knight, o un Npc al terminar una conversacion. Es dato, no codigo: cada recompensa es una ficha.

## MAPA va al final: los .tres guardan el tipo como entero.
enum Tipo {
	MONEDAS,
	VIDA_MAXIMA,
	AMULETO,
	HABILIDAD,
	MAPA,
}

## Coleccionables juntados para recibirla.
@export var cantidad: int = 4
## Que se entrega.
@export var tipo: Tipo = Tipo.MONEDAS
## PejeCoins (MONEDAS) o vidas (VIDA_MAXIMA).
@export var monto: int = 100
## Id del amuleto, de la habilidad o de la zona (MAPA).
@export var id: StringName = &""
