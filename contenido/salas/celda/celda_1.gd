extends Sala
# La Celda, sala 1: lo unico de esta sala sobre la base de la zona y sus piezas (luces de tubo, foso, puerta, fondos y
# niebla son escenas sin codigo aqui). El polvo de los pies al correr y al caer, los papeles que vuelan al pasar
# corriendo junto a una pila y el rebote en el suelo de las piedritas de la grieta alta. Lee al jugador en el tick de
# fisica; en la pausa y el congelado no hace nada.

## Velocidad en x, en px/s, desde la que el jugador levanta polvo al correr y vuela los papeles.
const CORRE_POLVO: float = 120.0
const CORRE_PAPELES: float = 250.0
## Distancia en x, en px, al centro de una pila desde la que el jugador la vuela.
const CERCA_PILA: float = 70.0
## Ticks entre dos voladas de la misma pila (1,2 s).
const ESPERA_PAPELES: int = 72

var _jugador: Jugador = null
var _en_suelo_antes: bool = true
# Ticks que faltan para el rebote de las piedritas; -1 sin rebote pendiente.
var _rebote_en: int = -1

@onready var _rastro: CPUParticles2D = $Particulas/PolvoRastro as CPUParticles2D
@onready var _aterrizaje: CPUParticles2D = $Particulas/PolvoAterrizaje as CPUParticles2D
@onready var _piedritas: EmisorRafaga = $Particulas/Piedritas as EmisorRafaga
@onready var _rebote: CPUParticles2D = $Particulas/Rebote as CPUParticles2D
@onready var _papeles_1: CPUParticles2D = $Particulas/Papeles1 as CPUParticles2D
@onready var _papeles_2: CPUParticles2D = $Particulas/Papeles2 as CPUParticles2D
@onready var _espera_papeles: Dictionary[CPUParticles2D, int] = {_papeles_1: 0, _papeles_2: 0}


func _ready() -> void:
	super()
	_piedritas.disparado.connect(_al_caer_piedritas)


func _physics_process(delta: float) -> void:
	super(delta)
	if Congelado.activo():
		return
	if _rebote_en > 0:
		_rebote_en -= 1
		if _rebote_en == 0:
			_rebote.restart()
	if not is_instance_valid(_jugador):
		_jugador = get_tree().get_first_node_in_group(Jugador.GRUPO) as Jugador
		if _jugador == null:
			return
	var pies: Vector2 = _jugador.global_position
	var en_suelo: bool = _jugador.is_on_floor()
	var vx: float = absf(_jugador.velocity.x)
	if en_suelo and not _en_suelo_antes:
		_aterrizaje.global_position = pies
		_aterrizaje.restart()
	_en_suelo_antes = en_suelo
	_rastro.global_position = pies
	_rastro.emitting = en_suelo and vx > CORRE_POLVO
	for papeles: CPUParticles2D in _espera_papeles:
		_espera_papeles[papeles] = maxi(0, _espera_papeles[papeles] - 1)
		if _espera_papeles[papeles] == 0 and vx > CORRE_PAPELES and absf(pies.x - papeles.global_position.x) < CERCA_PILA:
			_espera_papeles[papeles] = ESPERA_PAPELES
			papeles.restart()


# Las piedritas llegan al suelo al acabar su vida: entonces rebotan.
func _al_caer_piedritas() -> void:
	_rebote_en = roundi(_piedritas.lifetime * Engine.physics_ticks_per_second)
