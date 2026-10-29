class_name MuroRompible
extends StaticBody2D
# Pared, techo o suelo que se rompe a golpes, como los muros secretos de Hollow Knight y Silksong: aguanta
# golpes (uno por golpe, sea el ataque, la bola o la onda de la picada), se sacude y hace temblar la camara con cada
# uno y, al romperse, suelta escombros, desvanece lo que tapaba (tapas), muestra lo que solo existe roto (descubre) y
# se queda roto: con id se marca en el estado de su sala. Golpearlo no da Inspiracion (su Golpeable no es un enemigo).
# Va en la sala con su forma y su dibujo. Lo escondido detras queda encerrado por el solido, no oculto.

## Al romperse.
signal se_rompio()

## Lado desde el que se le pega: el de quien golpea respecto al muro.
enum Lado { CUALQUIERA, IZQUIERDA, DERECHA, ARRIBA, ABAJO }

## Lo que crece el area de golpe alrededor del solido, en px: el ataque se detiene en la pared y debe alcanzarla.
const MARGEN_GOLPE: float = 12.0
const COLOR: Color = Color(0.45, 0.42, 0.4)
const COLOR_ESCOMBROS: Color = Color(0.5, 0.47, 0.44)

## Id unico dentro de la sala; lo exige el validador en las salas con id.
@export var id: String = ""
## Golpes que aguanta (Hollow Knight: 4).
@export var golpes: int = 4
## Solo cuentan los golpes desde este lado (un atajo que se abre desde dentro). CUALQUIERA: todos.
@export var solo_desde: Lado = Lado.CUALQUIERA
## Dibujos que tapan lo de detras: se desvanecen al romperse y, ya roto, no aparecen. Nodos exportados, resueltos por
## el editor (tutorials/scripting/gdscript/gdscript_exports.rst:321).
@export var tapas: Array[CanvasItem] = []
## Dibujos que solo existen roto (las orillas del hueco, lo que asoma por el): ocultos hasta romperse. Solo dibujos:
## visible no apaga la fisica ni el proceso (classes/class_canvasitem.rst:803), asi que un objeto que se toma va
## encerrado detras del muro y no aqui (lo exige el validador).
@export var descubre: Array[CanvasItem] = []
## Ticks que tarda una tapa en desvanecerse.
@export var ticks_desvanecer: int = 20
## Sacudida del dibujo con cada golpe, en px y ticks (Hollow Knight: 0,1 s).
@export var px_sacudida: float = 6.0
@export var ticks_sacudida: int = 6
## Temblor de camara con cada golpe y al romperse: ticks y px.
@export var ticks_temblor_golpe: int = 6
@export var px_temblor_golpe: float = 4.0
@export var ticks_temblor_roto: int = 14
@export var px_temblor_roto: float = 10.0
## Escombros que suelta al romperse.
@export var escombros: int = 12

## Golpes que le quedan y si ya se rompio; publicos para los guiones.
var quedan: int = 0
var roto: bool = false
## Su area de golpe (la busca la bola, que se detiene en el solido antes de tocarla).
var golpeable: Golpeable = null

var _forma: CollisionShape2D = null
var _dibujos: Array[CanvasItem] = []
var _posiciones: Array[Vector2] = []
var _ticks_sacudiendo: int = 0
var _sentido_sacudida: Vector2 = Vector2.ZERO
var _desplazamiento: Vector2 = Vector2.ZERO
var _ticks_desvaneciendo: int = 0


func _ready() -> void:
	Capas.poner(self, Capas.ESCENARIO, 0)
	quedan = golpes
	for hijo: Node in get_children():
		if hijo is CollisionShape2D and _forma == null:
			_forma = hijo as CollisionShape2D
		elif hijo is CanvasItem:
			_dibujos.append(hijo as CanvasItem)
			_posiciones.append(_posicion_de(hijo as CanvasItem))
	var ya_roto: bool = not id.is_empty() and Partida.estado_de(Sala.clave_de(self), id) != null
	_mostrar_descubiertos(ya_roto)
	if ya_roto:
		roto = true
		quedan = 0
		_ocultar_tapas()
		queue_free()
		return
	_crear_golpeable()


## true si un golpe desde la posicion de quien golpea cuenta, segun solo_desde.
func cuenta_desde(punto: Vector2) -> bool:
	return solo_desde == Lado.CUALQUIERA or _lado_de(punto) == solo_desde


func _physics_process(_delta: float) -> void:
	if Congelado.activo():
		return
	if _ticks_sacudiendo > 0:
		_ticks_sacudiendo -= 1
		# Ida y vuelta: el dibujo sale hacia donde se le pego y regresa a su lugar.
		var fase: float = 1.0 - float(_ticks_sacudiendo) / float(maxi(ticks_sacudida, 1))
		_mover_dibujo(_sentido_sacudida * px_sacudida * sin(fase * PI))
	if _ticks_desvaneciendo > 0:
		_ticks_desvaneciendo -= 1
		var alfa: float = float(_ticks_desvaneciendo) / float(maxi(ticks_desvanecer, 1))
		for tapa: CanvasItem in tapas:
			if is_instance_valid(tapa):
				tapa.modulate.a = alfa
		if _ticks_desvaneciendo == 0:
			_ocultar_tapas()
			queue_free()


func _draw() -> void:
	# Caja gris mientras la sala no le ponga dibujo propio.
	if _dibujos.is_empty() and _forma != null and _forma.shape != null and not roto:
		var rectangulo: Rect2 = _forma.shape.get_rect()
		rectangulo.position += _forma.position + _desplazamiento
		draw_rect(rectangulo, COLOR)


func _crear_golpeable() -> void:
	if _forma == null or _forma.shape == null:
		return
	golpeable = Golpeable.new()
	golpeable.name = "Golpeable"
	golpeable.es_enemigo = false
	golpeable.velocidad_retroceso = 0.0
	var forma_golpe: CollisionShape2D = CollisionShape2D.new()
	var caja: RectangleShape2D = RectangleShape2D.new()
	caja.size = _forma.shape.get_rect().size + Vector2.ONE * MARGEN_GOLPE * 2.0
	forma_golpe.shape = caja
	forma_golpe.position = _forma.position + _forma.shape.get_rect().get_center()
	golpeable.add_child(forma_golpe)
	add_child(golpeable)
	golpeable.golpeado.connect(_al_recibir_golpe)


func _al_recibir_golpe(atacante: Node2D, _dano: int) -> void:
	if roto or not cuenta_desde(atacante.global_position):
		return
	quedan -= 1
	_sentido_sacudida = _sentido_desde(atacante.global_position)
	_ticks_sacudiendo = ticks_sacudida
	var jugador: Jugador = _jugador()
	if quedan > 0:
		if jugador != null:
			jugador.temblar(ticks_temblor_golpe, px_temblor_golpe)
		return
	_romper(jugador)


func _romper(jugador: Jugador) -> void:
	roto = true
	if not id.is_empty():
		Partida.marcar(Sala.clave_de(self), id)
	if jugador != null:
		jugador.temblar(ticks_temblor_roto, px_temblor_roto)
	if _forma != null:
		_forma.set_deferred(&"disabled", true)
	golpeable.set_deferred(&"monitorable", false)
	for dibujo: CanvasItem in _dibujos:
		dibujo.visible = false
	queue_redraw()
	_mostrar_descubiertos(true)
	_soltar_escombros()
	Eventos.muro_roto.emit(StringName(id))
	se_rompio.emit()
	# Las tapas se desvanecen y despues el muro se va; sin tapas, se va ya.
	if tapas.is_empty() or ticks_desvanecer <= 0:
		_ocultar_tapas()
		queue_free()
	else:
		_ticks_desvaneciendo = ticks_desvanecer


func _ocultar_tapas() -> void:
	for tapa: CanvasItem in tapas:
		if is_instance_valid(tapa):
			tapa.visible = false


func _mostrar_descubiertos(mostrar: bool) -> void:
	for dibujo: CanvasItem in descubre:
		if is_instance_valid(dibujo):
			dibujo.visible = mostrar


# Lado de quien golpea: a los lados si esta fuera del ancho del muro; si no, arriba o abajo.
func _lado_de(punto: Vector2) -> Lado:
	var caja: Rect2 = _caja_global()
	if punto.x < caja.position.x:
		return Lado.IZQUIERDA
	if punto.x > caja.end.x:
		return Lado.DERECHA
	return Lado.ARRIBA if punto.y < caja.get_center().y else Lado.ABAJO


func _sentido_desde(punto: Vector2) -> Vector2:
	match _lado_de(punto):
		Lado.IZQUIERDA:
			return Vector2.RIGHT
		Lado.DERECHA:
			return Vector2.LEFT
		Lado.ARRIBA:
			return Vector2.DOWN
	return Vector2.UP


func _caja_global() -> Rect2:
	if _forma == null or _forma.shape == null:
		return Rect2(global_position, Vector2.ZERO)
	var caja: Rect2 = _forma.shape.get_rect()
	caja.position += _forma.global_position
	return caja


func _mover_dibujo(desplazamiento: Vector2) -> void:
	_desplazamiento = desplazamiento
	for i: int in range(_dibujos.size()):
		var dibujo: CanvasItem = _dibujos[i]
		if dibujo is Node2D:
			(dibujo as Node2D).position = _posiciones[i] + desplazamiento
		elif dibujo is Control:
			(dibujo as Control).position = _posiciones[i] + desplazamiento
	# Con dibujo propio el _draw sale vacio: redibujar en cada tick de la sacudida no cambia nada.
	if _dibujos.is_empty():
		queue_redraw()


func _posicion_de(dibujo: CanvasItem) -> Vector2:
	if dibujo is Node2D:
		return (dibujo as Node2D).position
	if dibujo is Control:
		return (dibujo as Control).position
	return Vector2.ZERO


func _soltar_escombros() -> void:
	if escombros <= 0 or get_parent() == null:
		return
	var particulas: CPUParticles2D = CPUParticles2D.new()
	particulas.one_shot = true
	particulas.amount = escombros
	particulas.lifetime = 0.6
	particulas.explosiveness = 1.0
	particulas.direction = Vector2.UP
	particulas.spread = 80.0
	particulas.initial_velocity_min = 150.0
	particulas.initial_velocity_max = 320.0
	particulas.gravity = Vector2(0.0, 900.0)
	particulas.scale_amount_min = 6.0
	particulas.scale_amount_max = 12.0
	particulas.color = COLOR_ESCOMBROS
	var padre: Node2D = get_parent() as Node2D
	var centro: Vector2 = _caja_global().get_center()
	particulas.position = padre.to_local(centro) if padre != null else centro
	particulas.finished.connect(particulas.queue_free)
	get_parent().add_child.call_deferred(particulas)
	particulas.emitting = true


func _jugador() -> Jugador:
	return Jugador.actual(get_tree())
