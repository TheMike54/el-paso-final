class_name Golpeable
extends Area2D
# Componente de lo que el ataque del jugador puede golpear (enemigos, objetos que se rompen).
# Va como hijo del nodo golpeable, con su forma; cuenta los golpes, empuja un poco a su padre
# lejos del atacante (sin cruzar paredes ni salir de la sala) y avisa con la senal golpeado (con el dano, para quien lleve la vida) y con
# Eventos.enemigo_golpeado, o con Eventos.objeto_golpeado si no es un enemigo (muro, palanca: sin Inspiracion). Lo
# golpean el ataque del jugador y el proyectil.

signal golpeado(atacante: Node2D, dano: int)

## Velocidad con que el padre sale empujado al recibir un golpe, en px/s. 0: no se mueve. 600 x 6 ticks = 60 px.
@export var velocidad_retroceso: float = 600.0
## Ticks que dura ese empuje.
@export var ticks_retroceso: int = 6
## false: un objeto (muro rompible, palanca), no un enemigo. Golpearlo no da Inspiracion y avisa con
## Eventos.objeto_golpeado en vez de Eventos.enemigo_golpeado. El jugador rebota igual.
@export var es_enemigo: bool = true

## Golpes recibidos desde que entro a la sala, y el dano que sumaron.
var golpes: int = 0
var dano_recibido: int = 0

var _ticks_empujado: int = 0
var _sentido: float = 0.0


func _ready() -> void:
	Capas.poner(self, Capas.GOLPEABLE, 0)


func recibir_golpe(atacante: Node2D, dano: int = 1) -> void:
	golpes += 1
	dano_recibido += dano
	var padre: Node2D = get_parent() as Node2D
	if padre != null and velocidad_retroceso > 0.0:
		var lado: float = signf(padre.global_position.x - atacante.global_position.x)
		# Golpeado justo desde arriba (pogo): no se sabe hacia donde empujarlo, y no se empuja.
		_sentido = lado
		_ticks_empujado = ticks_retroceso if lado != 0.0 else 0
	golpeado.emit(atacante, dano)
	if es_enemigo:
		Eventos.enemigo_golpeado.emit(get_parent())
	else:
		Eventos.objeto_golpeado.emit(get_parent())


func _physics_process(delta: float) -> void:
	if _ticks_empujado == 0 or Congelado.activo():
		return
	_ticks_empujado -= 1
	var padre: Node2D = get_parent() as Node2D
	var paso: float = _sentido * velocidad_retroceso * delta
	var libre: float = _paso_libre(paso)
	padre.global_position.x += libre
	# Contra una pared o el borde de la sala el empuje se acaba ahi.
	if libre != paso:
		_ticks_empujado = 0


# Cuanto puede avanzar el padre en x sin meter su forma en un solido (pared, suelo) ni sacarla de los limites
# de su sala. Los cuerpos que no son solidos (el jugador) no lo detienen.
func _paso_libre(paso: float) -> float:
	var forma: CollisionShape2D = _forma()
	if forma == null or forma.shape == null or paso == 0.0:
		return paso
	var mitad: float = forma.shape.get_rect().size.x * 0.5
	var centro: Vector2 = forma.global_position
	var sentido: float = signf(paso)
	var libre: float = absf(paso)
	var choque: Dictionary = Capas.rayo_a_escenario(self, centro, centro + Vector2(sentido * (mitad + libre), 0.0))
	if not choque.is_empty():
		var punto: Vector2 = choque["position"] as Vector2
		libre = minf(libre, maxf(absf(punto.x - centro.x) - mitad, 0.0))
	var sala: Sala = _sala()
	if sala != null:
		var limites: Rect2 = Rect2(sala.global_position + sala.limites.position, sala.limites.size)
		var borde: float = limites.end.x if sentido > 0.0 else limites.position.x
		libre = minf(libre, maxf(absf(borde - centro.x) - mitad, 0.0))
	# Un cuerpo que camina y esta en el suelo no sale empujado por la orilla (como el barrido de Hollow Knight).
	var cuerpo: CharacterBody2D = get_parent() as CharacterBody2D
	if (cuerpo != null and cuerpo.motion_mode == CharacterBody2D.MOTION_MODE_GROUNDED and cuerpo.is_on_floor()
			and libre > 0.0):
		var pie: Vector2 = Vector2(centro.x + sentido * (mitad + libre), cuerpo.global_position.y - 4.0)
		if Capas.rayo_a_escenario(self, pie, pie + Vector2(0.0, 16.0)).is_empty():
			libre = 0.0
	return sentido * libre


func _forma() -> CollisionShape2D:
	for hijo: Node in get_children():
		if hijo is CollisionShape2D:
			return hijo as CollisionShape2D
	return null


func _sala() -> Sala:
	var nodo: Node = get_parent()
	while nodo != null:
		if nodo is Sala:
			return nodo as Sala
		nodo = nodo.get_parent()
	return null
