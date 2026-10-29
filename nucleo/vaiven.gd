class_name Vaiven
extends Node2D
# Pieza que va y viene en linea recta (sierras que viajan, trampas, plataformas, elevadores): espera ticks_espera en
# el origen, recorre recorrido en ticks_ida ticks, espera en el extremo, vuelve y repite; quieta durante el congelado
# comun. Lo que dana dentro de ella solo golpea (lo exige el validador). La plataforma que lleva al jugador es ella
# misma el AnimatableBody2D con este script: un cuerpo hijo de un Vaiven no lo lleva (docs/errores).

## Desplazamiento de la ida, desde donde empieza.
@export var recorrido: Vector2 = Vector2(200.0, 0.0)
## Ticks de la ida (la vuelta tarda lo mismo).
@export var ticks_ida: int = 90
## Ticks quieta en cada extremo, tambien al empezar (un elevador que deja subir y bajar); 0 = da la vuelta en seguida.
@export var ticks_espera: int = 0
## Ticks del ciclo que ya lleva al entrar: desfasa piezas iguales. Uno de espera + ida empieza en el extremo.
@export var desfase_ticks: int = 0

var _inicio: Vector2 = Vector2.ZERO
var _tick: int = 0


func _ready() -> void:
	_inicio = position
	# El cuerpo que lleva al jugador es escenario y no mira nada: un AnimatableBody2D no reacciona a choques
	# (classes/class_animatablebody2d.rst:22).
	# Por Object: un Node2D no se convierte a PhysicsBody2D en la compilacion, aunque la escena lo ponga en uno. Un
	# Area2D no es PhysicsBody2D: si lleva este script, conserva sus capas y sigue detectando.
	var nodo: Object = self
	var cuerpo: PhysicsBody2D = nodo as PhysicsBody2D
	if cuerpo != null:
		Capas.poner(cuerpo, Capas.ESCENARIO, 0)
	position = _inicio + recorrido * avance_en(_tick + desfase_ticks)


func _physics_process(_delta: float) -> void:
	if Congelado.activo() or ticks_ida <= 0:
		return
	_tick += 1
	position = _inicio + recorrido * avance_en(_tick + desfase_ticks)


## Avance de 0 (origen) a 1 (extremo) en el tick t del ciclo: espera en el origen, ida, espera en el extremo, vuelta.
func avance_en(t: int) -> float:
	if ticks_ida <= 0:
		return 0.0
	var espera: int = maxi(ticks_espera, 0)
	var fase: int = posmod(t, 2 * (espera + ticks_ida))
	if fase < espera:
		return 0.0
	if fase < espera + ticks_ida:
		return float(fase - espera) / float(ticks_ida)
	if fase < 2 * espera + ticks_ida:
		return 1.0
	return 1.0 - float(fase - 2 * espera - ticks_ida) / float(ticks_ida)


## El primer nodo, desde nodo hacia arriba (el mismo incluido), que se mueve: un Vaiven, un Giro o un cuerpo que se
## mueve (AnimatableBody2D, el Porton incluido; CharacterBody2D, como Enemigo; RigidBody2D) o un PathFollow2D. null
## si nada lo mueve. Una sola lista para el jugador (no toma punto seguro sobre ello) y el validador (lo que va dentro
## solo golpea): una pieza nueva que se mueve se agrega aqui. Por clase y no por grupo: el validador no corre _ready.
static func movil_de(nodo: Node) -> Node:
	var arriba: Node = nodo
	while arriba != null:
		if (arriba is Vaiven or arriba is Giro or arriba is AnimatableBody2D or arriba is CharacterBody2D
				or arriba is RigidBody2D or arriba is PathFollow2D):
			return arriba
		arriba = arriba.get_parent()
	return null
