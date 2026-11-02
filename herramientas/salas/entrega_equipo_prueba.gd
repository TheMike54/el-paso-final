extends EntregaRecompensas
# Entrega gratuita del lote de equipo para la sala jugable de pruebas.
# Conserva la interaccion de EntregaRecompensas, pero recuerda el lote completo
# con una sola marca: sus siete premios no dependen de coleccionables.

const MARCA: String = "equipo_entregado"


func entregar() -> int:
	var sala: String = Sala.clave_de(self)
	if Partida.estado_de(sala, MARCA) != null:
		return 0
	for recompensa: Recompensa in recompensas:
		Partida.dar_recompensa(recompensa)
	# Obtener equipo es idempotente: si se interrumpe un autoguardado intermedio, el lote sigue pendiente.
	Partida.marcar(sala, MARCA)
	entregadas += recompensas.size()
	Partida.autoguardar()
	return recompensas.size()
