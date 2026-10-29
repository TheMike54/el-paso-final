class_name MonedasSueltas
extends Recogible
# PejeCoins tiradas en un rincon de la sala, premio a quien explora (como el geo suelto de Hollow Knight): al tocarlas
# se suman a Partida.monedas, se marcan con su id en el estado de su sala y no vuelven. El monton es un Sprite2D con la
# PejeCoin horneada (herramientas/generar_efectos.gd), sin _draw: redibujarla en vector cada cuadro bajaba el S50 de
# 59,7 a 37-40 FPS. No autoguarda: la marca y las monedas viajan juntas en el siguiente guardado.

## PejeCoins que da.
@export var cantidad: int = 10


func _al_recoger(_jugador: Jugador) -> void:
	Partida.monedas += cantidad
