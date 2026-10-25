class_name EntregaRecompensas
extends Interactuable
# Quien entrega las recompensas de los coleccionables (el padre de las larvas de Hollow Knight): con el
# jugador encima y en el suelo, interactuar entrega cada recompensa cuya cantidad ya se junto y que no se
# entrego antes. Cada entrega queda marcada en el estado de su sala (entregado_<cantidad>) y autoguarda.
# Va como hija directa de la raiz de una sala, con su forma. La capa y el disparador (sin congelado) son de la
# base Interactuable, sin aviso: la entrega no lo dibuja.

## Las marcas de las entregas en el estado de la sala empiezan asi; un Npc o un reto no usan ese id.
const PREFIJO_ENTREGADO: String = "entregado_"

## Recompensas por cantidad, de menor a mayor.
@export var recompensas: Array[Recompensa] = []

## Recompensas entregadas desde que entro a la sala; publica para los guiones.
var entregadas: int = 0


func _init() -> void:
	con_aviso = false


func _al_interactuar(_jugador_encima: Jugador) -> void:
	entregar()


## Entrega lo pendiente; devuelve cuantas recompensas dio.
func entregar() -> int:
	var sala: String = Sala.clave_de(self)
	var total: int = Partida.total_coleccionables()
	var dadas: int = 0
	for recompensa: Recompensa in recompensas:
		var marca: String = PREFIJO_ENTREGADO + str(recompensa.cantidad)
		if recompensa.cantidad > total or Partida.estado_de(sala, marca) != null:
			continue
		Partida.marcar(sala, marca)
		Partida.dar_recompensa(recompensa)
		dadas += 1
	entregadas += dadas
	if dadas > 0:
		Partida.autoguardar()
	return dadas
