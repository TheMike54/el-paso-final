class_name Giro
extends Node2D
# Gira sobre su origen a ritmo fijo (aspas de un ventilador, una sierra); el dibujo y lo que dana son hijos. Cuenta en
# ticks, como Vaiven: la logica del juego va a 60 ticks y un guion sabe el angulo sin convertir unidades. Se queda
# quieto en la pausa y el congelado comun. Dentro de un Vaiven viaja y gira a la vez; lo que dana dentro solo golpea.

## Ticks por vuelta completa; negativo gira al reves, 0 no gira.
@export var ticks_vuelta: int = 60
## Ticks de la vuelta que ya lleva al entrar: desfasa piezas iguales.
@export var desfase_ticks: int = 0

var _rotacion_inicial: float = 0.0
var _tick: int = 0


func _ready() -> void:
	_rotacion_inicial = rotation
	rotation = angulo_en(_tick + desfase_ticks)


func _physics_process(_delta: float) -> void:
	if Congelado.activo() or ticks_vuelta == 0:
		return
	_tick += 1
	rotation = angulo_en(_tick + desfase_ticks)


## Rotacion en el tick t: la de la escena mas la parte de vuelta que lleva. Se calcula del tick, no se acumula, asi
## no deriva.
func angulo_en(t: int) -> float:
	if ticks_vuelta == 0:
		return _rotacion_inicial
	var vuelta: int = absi(ticks_vuelta)
	return _rotacion_inicial + TAU * float(posmod(t, vuelta)) / float(ticks_vuelta)
