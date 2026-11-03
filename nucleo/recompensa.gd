class_name Recompensa
extends Resource
# Ficha de premio para EntregaRecompensas al reunir coleccionables o para un Npc al terminar una conversacion.
# Separa los datos del premio de quien lo entrega, como las recompensas de las larvas en Hollow Knight.
# Cada recompensa se configura como recurso, sin escribir codigo propio para cada premio.

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
@export var tipo: Tipo = Tipo.MONEDAS
## PejeCoins, vidas, puntos de Inspiracion maxima o muescas de carga.
@export var monto: int = 100
## Id del amuleto, del util, de la habilidad o de la zona (MAPA).
@export var id: StringName = &""
