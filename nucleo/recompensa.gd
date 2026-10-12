class_name Recompensa
extends Resource
# Lo que entrega una EntregaRecompensas al juntar cierta cantidad de coleccionables, como las
# recompensas de las larvas en Hollow Knight. Es dato, no codigo: cada recompensa es una ficha.

enum Tipo { MONEDAS, VIDA_MAXIMA, AMULETO, HABILIDAD }

## Coleccionables juntados para recibirla.
@export var cantidad: int = 4
@export var tipo: Tipo = Tipo.MONEDAS
## PejeCoins (MONEDAS) o vidas (VIDA_MAXIMA).
@export var monto: int = 100
## Id del amuleto o de la habilidad.
@export var id: StringName = &""
