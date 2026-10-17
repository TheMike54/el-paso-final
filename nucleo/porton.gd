class_name Porton
extends AnimatableBody2D
# Porton que se abre deslizandose (como el Gate de Silksong): lo abre una Palanca, una arena al vencer al jefe o
# cualquier codigo con abrir(). Con id, abierto se marca en el estado de su sala y aparece abierto al volver. Tambien
# se cierra (cerrar(), para encerrar al jugador en una arena), y eso no se guarda. Va en la sala con su forma y su
# dibujo; se mueve en el tick, como pide un AnimatableBody2D.

## Al terminar de abrirse.
signal abierto()

const COLOR: Color = Color(0.35, 0.36, 0.42)

## Id unico dentro de la sala; lo exige el validador en las salas con id.
@export var id: String = ""
## Cuanto se mueve al abrirse, en px. Cero: su propio alto hacia arriba.
@export var recorrido: Vector2 = Vector2.ZERO
## Ticks que tarda en abrirse o cerrarse.
@export var ticks_apertura: int = 30
## Empieza abierto (el de una arena, que se cierra al entrar el jugador).
@export var abierto_al_empezar: bool = false

## Abierto del todo, o abriendose; publicos para los guiones.
var esta_abierto: bool = false
var abriendo: bool = false

var _cerrado_en: Vector2 = Vector2.ZERO
var _abierto_en: Vector2 = Vector2.ZERO
# Avance de 0 (cerrado) a 1 (abierto) y hacia donde va: 1 abriendo, -1 cerrando, 0 quieto.
var _avance: float = 0.0
var _sentido: float = 0.0
var _forma: CollisionShape2D = null


func _ready() -> void:
	Capas.poner(self, Capas.ESCENARIO, 0)
	for hijo: Node in get_children():
		if hijo is CollisionShape2D:
			_forma = hijo as CollisionShape2D
			break
	if recorrido == Vector2.ZERO and _forma != null and _forma.shape != null:
		recorrido = Vector2(0.0, -_forma.shape.get_rect().size.y)
	_cerrado_en = position
	_abierto_en = position + recorrido
	var guardado: bool = not id.is_empty() and Partida.estado_de(Sala.clave_de(self), id) != null
	if guardado or abierto_al_empezar:
		_avance = 1.0
		esta_abierto = true
		position = _abierto_en


## Empieza a abrirse; ya abierto o abriendose, no hace nada. Con id se marca al empezar: salir de la sala a media
## apertura lo deja abierto.
func abrir() -> void:
	if esta_abierto or _sentido > 0.0:
		return
	_sentido = 1.0
	abriendo = true
	if not id.is_empty():
		Partida.marcar(Sala.clave_de(self), id)
	Eventos.porton_abierto.emit(StringName(id))


## Empieza a cerrarse (arenas). No cambia lo guardado.
func cerrar() -> void:
	if _avance <= 0.0 and _sentido == 0.0:
		return
	_sentido = -1.0
	abriendo = false
	esta_abierto = false


func _physics_process(_delta: float) -> void:
	if _sentido == 0.0 or Congelado.activo():
		return
	_avance = clampf(_avance + _sentido / float(maxi(ticks_apertura, 1)), 0.0, 1.0)
	position = _cerrado_en.lerp(_abierto_en, _avance)
	if _sentido > 0.0 and _avance >= 1.0:
		_sentido = 0.0
		abriendo = false
		esta_abierto = true
		abierto.emit()
	elif _sentido < 0.0 and _avance <= 0.0:
		_sentido = 0.0


func _draw() -> void:
	# Caja gris mientras la sala no le ponga dibujo propio.
	if _forma == null or _forma.shape == null:
		return
	for hijo: Node in get_children():
		if hijo is CanvasItem and not hijo is CollisionShape2D:
			return
	var rectangulo: Rect2 = _forma.shape.get_rect()
	rectangulo.position += _forma.position
	draw_rect(rectangulo, COLOR)
