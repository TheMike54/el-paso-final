class_name EntregaRecompensas
extends Interactuable
# Canje de coleccionables como el padre de las larvas de Hollow Knight: interactuar desde el suelo entrega lo reunido.
# Marca entregado_<cantidad> en el estado de la sala y autoguarda cada premio para no entregarlo dos veces.
# Va con su forma como hija directa de la raiz de una sala; hereda capa y disparador sin congelado de Interactuable.
# No dibuja el aviso de interaccion del resto de interactuables.

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
