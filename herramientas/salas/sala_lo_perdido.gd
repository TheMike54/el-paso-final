extends Sala
# Sala de prueba de lo perdido al morir: al entrar sin monedas ni mochila da 120 PejeCoins, y deja al jugador con una
# vida para que el pincho lo mate de un toque. Al morir, la mochila queda en el ultimo punto seguro y la sala vuelve a
# cargar; la mochila se recupera con el reto de la bolsa de prueba, que le pone esta sala (el nucleo solo carga la del
# juego, para que el paquete publicado nunca muestre preguntas de prueba).

const MONEDAS_AL_ENTRAR: int = 120
const BOLSA_PRUEBA: String = "res://herramientas/salas/preguntas_mochila_prueba.tres"


func _ready() -> void:
	if Partida.monedas == 0 and Partida.mochila.is_empty():
		Partida.monedas = MONEDAS_AL_ENTRAR
	super._ready()
	Partida.vidas = 1
	var mochila: Mochila = get_node_or_null(^"Mochila") as Mochila
	if mochila != null and mochila.bolsa == null:
		mochila.bolsa = load(BOLSA_PRUEBA) as BolsaPreguntas
