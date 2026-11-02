extends ComportamientoEnemigo
# Escudo inmovil para comprobar el gancho bloquea_golpe de ComportamientoEnemigo con golpes frontales.
# Mantiene fijo al enemigo para aislar el bloqueo de su movimiento y de otros comportamientos.
# Solo lo usa prueba_enemigo_enganches.gd; no es un comportamiento jugable.


func bloquea_golpe(atacante: Node2D) -> bool:
	return lado_de(atacante) == enemigo.mirando
