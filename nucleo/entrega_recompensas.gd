class_name EntregaRecompensas
extends Area2D
# Quien entrega las recompensas de los coleccionables (el padre de las larvas de Hollow Knight): con el
# jugador encima y en el suelo, interactuar entrega cada recompensa cuya cantidad ya se junto y que no se
# entrego antes. Cada entrega queda marcada en el estado de su sala (entregado_<cantidad>) y autoguarda.
# Va como hija directa de la raiz de una sala, con su forma.

## Recompensas por cantidad, de menor a mayor.
@export var recompensas: Array[Recompensa] = []

## Recompensas entregadas desde que entro a la sala; publica para los guiones.
var entregadas: int = 0


func _physics_process(_delta: float) -> void:
	if not Input.is_action_just_pressed(&"interactuar"):
		return
	for cuerpo: Node2D in get_overlapping_bodies():
		var jugador: Jugador = cuerpo as Jugador
		if jugador != null and jugador.is_on_floor() and not jugador.muerto:
			entregar()
			return


## Entrega lo pendiente; devuelve cuantas recompensas dio.
func entregar() -> int:
	var sala: String = Sala.clave_de(self)
	var total: int = Partida.total_coleccionables()
	var dadas: int = 0
	for recompensa: Recompensa in recompensas:
		var marca: String = "entregado_%d" % recompensa.cantidad
		if recompensa.cantidad > total or Partida.estado_de(sala, marca) != null:
			continue
		Partida.marcar(sala, marca)
		Partida.dar_recompensa(recompensa)
		dadas += 1
	entregadas += dadas
	if dadas > 0:
		Partida.autoguardar()
	return dadas
