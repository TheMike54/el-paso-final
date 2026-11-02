class_name Congelado
extends RefCounted
# Hit-stop comun al recibir dano o vencer enemigos, inspirado en GameManager.FreezeMoment de Hollow Knight.
# Detiene jugador, enemigos, proyectiles, empujes, plantas y niebla; las particulas por tiempo siguen corriendo.
# Cada pieza consulta activo() al empezar su tick o cuadro; evita Engine.time_scale porque los guiones cuentan ticks.
# Usa el cuadro de fisica como reloj para no necesitar un nodo que descuente la duracion.

## Congelado al vencer a un enemigo: FreezeMoment(1) de Hollow Knight baja en 0,04 s, sostiene 0,03 y sube en
## 0,04: unos 4 ticks quietos.
const TICKS_AL_VENCER: int = 4

## Ultimo cuadro de fisica congelado.
static var _hasta: int = -1


## Congela ticks cuadros contando el actual (el tick del golpe es el primero). Si ya habia un congelado mas largo, gana el largo.
static func pedir(ticks: int) -> void:
	_hasta = maxi(_hasta, Engine.get_physics_frames() + ticks - 1)


static func activo() -> bool:
	return Engine.get_physics_frames() <= _hasta


## Lo llama la sala al entrar: un congelado no pasa de una sala a otra.
static func reiniciar() -> void:
	_hasta = -1
