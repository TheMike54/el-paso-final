class_name Recompensa
extends Resource
# Lo que entrega una EntregaRecompensas al juntar cierta cantidad de coleccionables, como las
# recompensas de las larvas en Hollow Knight, o un Npc al terminar una conversacion. Es dato, no codigo: cada recompensa es una ficha.

## Lo nuevo va al final: los .tres guardan el tipo como entero.
enum Tipo {
	MONEDAS,
	VIDA_MAXIMA,
	AMULETO,
	HABILIDAD,
	MAPA,
	UTIL,
	INSPIRACION_MAXIMA,
	CARGA,
}

## Coleccionables juntados para recibirla.
@export var cantidad: int = 4
## Que se entrega.
@export var tipo: Tipo = Tipo.MONEDAS
## PejeCoins, vidas, puntos de Inspiracion maxima (Modulo de RAM: 33) o muescas de carga.
@export var monto: int = 100
## Id del amuleto, del util, de la habilidad o de la zona (MAPA).
@export var id: StringName = &""
