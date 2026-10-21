extends Node
# Solo salas de prueba: al entrar quita vidas al jugador (sin bajar de 1), para probar curar sin tener que recibir un
# golpe antes. La usa la sala Pizarrones: el pizarron de curar debe poder hacerse aunque el caminante no pegue.
# Va como hijo de la sala; al reaparecer la sala se vuelve a cargar y la quita otra vez.

## Vidas que quita al entrar.
@export var vidas: int = 1


func _ready() -> void:
	Partida.vidas = maxi(1, Partida.vidas - vidas)
