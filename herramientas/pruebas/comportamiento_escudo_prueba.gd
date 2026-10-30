extends ComportamientoEnemigo
# Comportamiento de prueba de los ganchos de ComportamientoEnemigo: bloquea los golpes que le llegan de frente
# (escudo) y no se mueve. Solo lo usa prueba_enemigo_enganches.gd; no es jugable.


func bloquea_golpe(atacante: Node2D) -> bool:
	return lado_de(atacante) == enemigo.mirando
