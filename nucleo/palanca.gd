class_name Palanca
extends Node2D
# Palanca que se mueve con un golpe del jugador (como la Lever de Silksong): el primer golpe la activa, la deja
# inclinada hacia el otro lado y, tras ticks_retraso, abre cada Porton de su lista. Despues ya no cambia; los
# golpes solo rebotan al jugador. La bola no la mueve. Con id se marca en el estado de su sala y aparece activada;
# cada porton guarda lo suyo. Golpearla no da Inspiracion (su Golpeable no es un enemigo).

## Al activarse.
signal activada()

const TAMANO_GOLPE: Vector2 = Vector2(70.0, 110.0)
const COLOR_BASE: Color = Color(0.4, 0.4, 0.44)
const COLOR_PALANCA: Color = Color(0.75, 0.7, 0.55)
## Inclinacion de la palanca, en grados desde la vertical.
const GRADOS: float = 35.0
const LARGO: float = 70.0

## Id unico dentro de la sala; lo exige el validador en las salas con id.
@export var id: String = ""
## Portones que abre, de la misma sala (nodos exportados, resueltos por el editor).
@export var portones: Array[Porton] = []
## Ticks entre el golpe y la apertura (Hollow Knight: 0,75 s).
@export var ticks_retraso: int = 45
## Congelado al activarla y temblor de camara: ticks y px.
@export var ticks_congelado: int = 6
@export var ticks_temblor: int = 10
@export var px_temblor: float = 6.0

## Activada (ya no cambia) y si ya abrio sus portones; publicos para los guiones.
var esta_activada: bool = false
var abrio: bool = false
var golpeable: Golpeable = null

# Hacia donde queda inclinada: -1 izquierda, 1 derecha.
var _inclinacion: float = -1.0
var _ticks_para_abrir: int = -1


func _ready() -> void:
	golpeable = Golpeable.new()
	golpeable.name = "Golpeable"
	golpeable.es_enemigo = false
	golpeable.velocidad_retroceso = 0.0
	var forma: CollisionShape2D = CollisionShape2D.new()
	var caja: RectangleShape2D = RectangleShape2D.new()
	caja.size = TAMANO_GOLPE
	forma.shape = caja
	forma.position = Vector2(0.0, -TAMANO_GOLPE.y / 2.0)
	golpeable.add_child(forma)
	add_child(golpeable)
	golpeable.golpeado.connect(_al_recibir_golpe)
	if not id.is_empty() and Partida.estado_de(Sala.clave_de(self), id) != null:
		esta_activada = true
		abrio = true
		_inclinacion = 1.0
	queue_redraw()


func _physics_process(_delta: float) -> void:
	if _ticks_para_abrir < 0 or Congelado.activo():
		return
	if _ticks_para_abrir > 0:
		_ticks_para_abrir -= 1
		return
	_ticks_para_abrir = -1
	abrio = true
	for porton: Porton in portones:
		if is_instance_valid(porton):
			porton.abrir()


func _al_recibir_golpe(atacante: Node2D, _dano: int) -> void:
	if esta_activada or not atacante is Jugador:
		return
	esta_activada = true
	# Se inclina hacia el lado contrario al de quien la golpea.
	var lado: float = signf(global_position.x - atacante.global_position.x)
	_inclinacion = lado if lado != 0.0 else -_inclinacion
	queue_redraw()
	if not id.is_empty():
		Partida.marcar(Sala.clave_de(self), id)
	Congelado.pedir(ticks_congelado)
	(atacante as Jugador).temblar(ticks_temblor, px_temblor)
	_ticks_para_abrir = ticks_retraso
	activada.emit()


func _draw() -> void:
	# Caja gris: base y palanca inclinada, mientras no haya arte.
	draw_rect(Rect2(-30.0, -20.0, 60.0, 20.0), COLOR_BASE)
	var punta: Vector2 = Vector2(0.0, -20.0) + Vector2.UP.rotated(deg_to_rad(GRADOS) * _inclinacion) * LARGO
	draw_line(Vector2(0.0, -20.0), punta, COLOR_PALANCA, 10.0)
	draw_circle(punta, 10.0, COLOR_PALANCA)
