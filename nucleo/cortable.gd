class_name Cortable
extends Area2D
# Decoracion que el ataque del jugador corta (pasto y lo que cada zona quiera): muestra su version cortada,
# suelta unos trozos y emite cortado. No es un Golpeable: no da Inspiracion, no rebota al jugador, no hace
# pogo y no cuenta como enemigo. Se agita al pasar el jugador. Vuelve al entrar otra vez a la sala (no se
# guarda), como el pasto de Hollow Knight. Generica: el dibujo entero y el cortado son hijos de la escena.

signal cortado()

## Hijo que se ve entero; al cortarlo se oculta. Vacio: no cambia nada.
@export var entero: NodePath = ^"Entero"
## Hijo que se ve cortado; empieza oculto. Vacio: el cortable desaparece sin dejar nada.
@export var version_cortada: NodePath = ^"Cortado"
## Trozos que suelta al cortarse (0: ninguno).
@export var trozos: int = 4
## Color de los trozos mientras no hay arte.
@export var color_trozos: Color = Color(0.35, 0.55, 0.3)
## Grados que se inclina al pasar el jugador y ticks que dura la sacudida.
@export var grados_sacudida: float = 12.0
@export var ticks_sacudida: int = 18

## Ya cortado; publico para los guiones.
var esta_cortado: bool = false
## Sacudidas desde que entro a la sala.
var sacudidas: int = 0

var _ticks_sacudiendo: int = 0
var _nodo_entero: Node2D = null


func _ready() -> void:
	Capas.poner(self, Capas.GOLPEABLE, Capas.JUGADOR)
	_nodo_entero = get_node_or_null(entero) as Node2D
	var cortada: CanvasItem = get_node_or_null(version_cortada) as CanvasItem
	if cortada != null:
		cortada.visible = false
	body_entered.connect(_al_pasar)


## Lo llama el ataque del jugador. Uno ya cortado no cambia.
func cortar() -> void:
	if esta_cortado:
		return
	esta_cortado = true
	if _nodo_entero != null:
		_nodo_entero.visible = false
	var cortada: CanvasItem = get_node_or_null(version_cortada) as CanvasItem
	if cortada != null:
		cortada.visible = true
	if trozos > 0:
		_soltar_trozos()
	cortado.emit()


func _al_pasar(cuerpo: Node2D) -> void:
	if cuerpo is Jugador and not esta_cortado:
		sacudidas += 1
		_ticks_sacudiendo = ticks_sacudida


func _physics_process(_delta: float) -> void:
	if _ticks_sacudiendo == 0 or _nodo_entero == null or Congelado.activo():
		return
	_ticks_sacudiendo -= 1
	# Se inclina y vuelve: media onda de seno, sin shader ni tween (cuenta ticks como todo el juego).
	var fase: float = 1.0 - float(_ticks_sacudiendo) / float(ticks_sacudida)
	_nodo_entero.rotation_degrees = sin(fase * TAU) * grados_sacudida * (1.0 - fase)


func _soltar_trozos() -> void:
	var particulas: CPUParticles2D = CPUParticles2D.new()
	particulas.one_shot = true
	particulas.amount = trozos
	particulas.lifetime = 0.5
	particulas.explosiveness = 1.0
	particulas.direction = Vector2.UP
	particulas.spread = 60.0
	particulas.initial_velocity_min = 120.0
	particulas.initial_velocity_max = 220.0
	particulas.gravity = Vector2(0.0, 900.0)
	particulas.scale_amount_min = 6.0
	particulas.scale_amount_max = 10.0
	particulas.color = color_trozos
	particulas.position = Vector2(0.0, -20.0)
	add_child(particulas)
	particulas.emitting = true
	particulas.finished.connect(particulas.queue_free)
