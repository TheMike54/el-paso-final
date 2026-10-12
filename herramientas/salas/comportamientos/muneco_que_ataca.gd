extends ComportamientoEnemigo
# Muneco de pruebas que ataca, para probar el parry: a mitad de cada ciclo avisa (se aclara AVISO ticks) y da un
# golpe al frente que dura GOLPE ticks; al final del ciclo dispara hacia el mismo lado. Los golpes alternan: el de los
# ciclos impares se puede parar (rastro blanco) y el de los pares no (rojo). El disparo siempre se puede parar.

const CICLO: int = 120
const AVISO: int = 30
const GOLPE: int = 12
## Golpe relativo a los pies del muneco, mirando a la izquierda.
const RECTANGULO_GOLPE: Rect2 = Rect2(-140.0, -100.0, 100.0, 80.0)
const SALIDA_DISPARO: Vector2 = Vector2(-60.0, -60.0)

## Golpes dados desde que entro a la sala; publico para los guiones.
var golpes_dados: int = 0
var disparos: int = 0
## Ticks que actuo; se detiene durante el congelado comun.
var reloj: int = 0


func actuar() -> void:
	reloj += 1
	var fase: int = reloj % CICLO
	# Aviso: se aclara los AVISO ticks antes del golpe.
	enemigo.modulate = Color(1.7, 1.7, 1.7) if fase > CICLO / 2 - AVISO and fase < CICLO / 2 else Color.WHITE
	if fase == CICLO / 2:
		golpes_dados += 1
		atacar(RECTANGULO_GOLPE, GOLPE, 1, golpes_dados % 2 == 1)
	elif fase == 0:
		disparos += 1
		disparar(SALIDA_DISPARO, Vector2.LEFT, 1, true)
