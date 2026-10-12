class_name Vibracion
extends Node
# Vibracion del telefono: escucha el bus y vibra corto al pegar, al parar, al recibir dano, al curarse, al
# descansar y al aterrizar duro o de la picada, cada uno con su duracion y su fuerza (docs/contrato.md, Vibracion). La crea cada sala.
# Con el ajuste vibracion apagado no vibra. Nada mas vibra: moverse, saltar y los menus no.

## Duracion en ms y fuerza (0 a 1) de cada vibracion. En un telefono sin control de fuerza solo
## cuenta la duracion.
@export var al_pegar: Vector2 = Vector2(25.0, 0.35)
## Parry: mas fuerte que pegar, mas corto que recibir dano. Sin fuente.
@export var al_parar: Vector2 = Vector2(45.0, 0.6)
@export var al_recibir_dano: Vector2 = Vector2(60.0, 0.8)
@export var al_curarse: Vector2 = Vector2(40.0, 0.45)
@export var al_descansar: Vector2 = Vector2(70.0, 0.5)
## Aterrizaje duro y aterrizaje de la picada: la mas fuerte. Sin fuente.
@export var al_aterrizar: Vector2 = Vector2(80.0, 0.9)
## Ticks minimos entre dos vibraciones: varios golpes seguidos no se vuelven un zumbido.
@export var ticks_entre_vibraciones: int = 4

## Vibraciones pedidas por los eventos (con el ajuste encendido o no) y las que se enviaron al
## telefono, desde que entro a la sala. Publicas para los guiones.
var pedidas: int = 0
var enviadas: int = 0
## Ultima vibracion pedida: al_pegar, al_parar, al_recibir_dano, al_curarse, al_descansar o al_aterrizar.
var ultima: StringName = &""

var _tick_ultima: int = -1000000


func _ready() -> void:
	Ajustes.cargar_una_vez()
	# Metodos y no funciones anonimas: al borrarse la sala, Godot desconecta solo los metodos.
	Eventos.enemigo_golpeado.connect(_al_pegar)
	Eventos.parry.connect(_al_parar)
	Eventos.jugador_danado.connect(_al_recibir_dano)
	Eventos.jugador_curado.connect(_al_curarse)
	Eventos.descanso_en_banco.connect(_al_descansar)
	Eventos.jugador_aterrizo.connect(_al_aterrizar)


func _al_pegar(_enemigo: Node) -> void:
	_vibrar(&"al_pegar", al_pegar)


func _al_parar() -> void:
	_vibrar(&"al_parar", al_parar)


func _al_recibir_dano(_vidas: int) -> void:
	_vibrar(&"al_recibir_dano", al_recibir_dano)


func _al_curarse(_vidas: int) -> void:
	_vibrar(&"al_curarse", al_curarse)


func _al_descansar(_banco: StringName) -> void:
	_vibrar(&"al_descansar", al_descansar)


func _al_aterrizar(_velocidad: float) -> void:
	_vibrar(&"al_aterrizar", al_aterrizar)


func _vibrar(cual: StringName, patron: Vector2) -> void:
	var tick: int = Engine.get_physics_frames()
	# Recibir dano y el parry mandan sobre el limite: no deben perderse (el parry llega en el mismo tick que pegarle
	# al dueno del ataque).
	if tick - _tick_ultima < ticks_entre_vibraciones and cual != &"al_recibir_dano" and cual != &"al_parar":
		return
	_tick_ultima = tick
	pedidas += 1
	ultima = cual
	if Ajustes.vibracion:
		enviadas += 1
		Input.vibrate_handheld(roundi(patron.x), patron.y)
