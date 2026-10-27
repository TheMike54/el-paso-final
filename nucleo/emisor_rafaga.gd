class_name EmisorRafaga
extends CPUParticles2D
# Emisor que suelta rafagas cada cierto tiempo al azar (chispas de un cable, piedritas que caen). La rafaga es un
# disparo unico con todas las particulas a la vez (particle_systems_2d.rst:159, :182). El reloj es propio: quieto en
# la pausa y el congelado. Si tiene una LuzSala de destello, la enciende en cada rafaga.

## Cada rafaga, al soltarla (la sala puede encadenar otra, como el rebote de unas piedritas).
signal disparado

## Segundos entre rafagas, al azar entre los dos.
@export var intervalo_min: float = 1.2
@export var intervalo_max: float = 4.2
## Luz que destella con cada rafaga (opcional).
@export var destello: LuzSala = null

var _espera: float = 0.0


func _ready() -> void:
	one_shot = true
	explosiveness = 1.0
	emitting = false
	_espera = randf_range(intervalo_min, intervalo_max)


func _process(delta: float) -> void:
	if Congelado.activo():
		return
	_espera -= delta
	if _espera > 0.0:
		return
	_espera = randf_range(intervalo_min, intervalo_max)
	disparar()


## Una rafaga ahora y el destello de la luz. La cantidad es amount, fija: cambiarla rehace el emisor.
func disparar() -> void:
	restart()
	if is_instance_valid(destello):
		destello.destellar()
	disparado.emit()
