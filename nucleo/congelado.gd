class_name Congelado
extends RefCounted
# Congelado comun (hit-stop), como GameManager.FreezeMoment de Hollow Knight, que baja la escala de tiempo
# de todo el juego: al recibir dano y al vencer a un enemigo se detienen unos ticks el jugador, los enemigos,
# los proyectiles, los empujes y la decoracion que se mueve (plantas y niebla; las particulas, que corren por
# tiempo, no). Sin Engine.time_scale (los guiones cuentan ticks): cada una pregunta activo() al empezar su tick
# o su cuadro. Se mide en cuadros de fisica, asi no hace falta quien lo descuente.

## Congelado al vencer a un enemigo: FreezeMoment(1) de Hollow Knight baja en 0,04 s, sostiene 0,03 y sube en
## 0,04: unos 4 ticks quietos.
const TICKS_AL_VENCER: int = 4

## Ultimo cuadro de fisica congelado.
static var _hasta: int = -1


## Congela ticks cuadros contando el actual, como el contador propio que reemplaza (el tick del golpe es el
## primero). Si ya habia un congelado mas largo, gana el largo.
static func pedir(ticks: int) -> void:
	_hasta = maxi(_hasta, Engine.get_physics_frames() + ticks - 1)


static func activo() -> bool:
	return Engine.get_physics_frames() <= _hasta


## Lo llama la sala al entrar: un congelado no pasa de una sala a otra.
static func reiniciar() -> void:
	_hasta = -1
