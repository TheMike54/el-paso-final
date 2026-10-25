extends Sala
# Sala de prueba de la tienda: la primera vez que se entra da 300 PejeCoins (se marca en el estado de la sala, asi
# comprar y volver a entrar no las repone). La tienda vende uno barato, uno caro que no alcanza, uno que pide el
# impulso (su objeto esta en la sala) y un amuleto.

const MONEDAS_AL_ENTRAR: int = 300
const MARCA: String = "monedas_dadas"


func _ready() -> void:
	if Partida.estado_de(clave(), MARCA) == null:
		Partida.monedas += MONEDAS_AL_ENTRAR
		Partida.marcar(clave(), MARCA)
	super._ready()
