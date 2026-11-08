extends ComportamientoEnemigo
# Cucaracha: camina como el caminante; al ver al jugador cerca se entierra (invisible, sin danar ni recibir golpes),
# avisa con polvo en el punto donde estaba el jugador, sale ahi y descansa antes de volver a caminar.
# Si en ese punto no hay suelo o espacio para su cuerpo, sale donde se enterro. Parte de caminante.gd.

const DatosCucaracha = preload("datos_cucaracha.gd")
const ESCENA_POLVO: PackedScene = preload("polvo_cucaracha.tscn")
## Hasta donde busca suelo bajo el punto de salida, en px.
const ALCANCE_SALIDA: float = 400.0

enum Estado { CAMINANDO, ENTERRADA, AVISANDO, RECUPERANDO }

## Estado actual; publico para los guiones (0 camina, 1 enterrada, 2 avisa, 3 se recupera).
var estado: Estado = Estado.CAMINANDO
## Veces que se enterro y veces que se volteo; publicos para los guiones.
var entierros: int = 0
var giros: int = 0

var _ticks: int = 0
var _ticks_quieto: int = 0
var _x_salida: float = 0.0
var _y_salida: float = 0.0
var _punto_salida: Vector2 = Vector2.ZERO
var _polvo: Node2D = null
var _d: DatosCucaracha = null


func _ready() -> void:
	_d = datos as DatosCucaracha


func _exit_tree() -> void:
	_quitar_polvo()


func datos_por_omision() -> DatosComportamiento:
	return DatosCucaracha.new()


func actuar() -> void:
	match estado:
		Estado.CAMINANDO:
			_caminar()
		Estado.ENTERRADA:
			_ticks -= 1
			if _ticks <= 0:
				_avisar()
		Estado.AVISANDO:
			_ticks -= 1
			if _ticks <= 0:
				_salir()
		Estado.RECUPERANDO:
			_recuperar()


## Bajo tierra (enterrada o avisando) ningun golpe le entra.
func bloquea_golpe(_atacante: Node2D) -> bool:
	return estado == Estado.ENTERRADA or estado == Estado.AVISANDO


## Si esta en la pausa antes de voltearse.
func esta_quieto() -> bool:
	return _ticks_quieto > 0


# Igual que el caminante, pero antes de nada se entierra si ve al jugador cerca.
func _caminar() -> void:
	caer()
	if en_suelo() and ve_al_jugador(_d.radio_alerta):
		_enterrarse()
		return
	if not en_suelo():
		enemigo.velocity.x = 0.0
	elif _ticks_quieto > 0:
		enemigo.velocity.x = 0.0
		_ticks_quieto -= 1
		if _ticks_quieto == 0:
			girar()
			giros += 1
	elif pared_delante(enemigo.mirando) or orilla_delante(enemigo.mirando):
		enemigo.velocity.x = 0.0
		_ticks_quieto = _d.ticks_giro
	else:
		enemigo.velocity.x = enemigo.mirando * enemigo.ficha.velocidad
	mover()


# Anota donde esta el jugador (por ahi saldra), se queda quieta y desaparece.
func _enterrarse() -> void:
	var objetivo: Jugador = jugador()
	if objetivo == null:
		return
	_x_salida = objetivo.global_position.x
	_y_salida = objetivo.global_position.y
	entierros += 1
	_ticks_quieto = 0
	enemigo.velocity = Vector2.ZERO
	flotar(true)
	_bajo_tierra(true)
	estado = Estado.ENTERRADA
	_ticks = _d.ticks_enterrada


# Decide el punto de salida y pone el polvo ahi: es lo que el jugador ve para esquivar.
func _avisar() -> void:
	_punto_salida = _buscar_salida()
	_polvo = ESCENA_POLVO.instantiate() as Node2D
	enemigo.get_parent().add_child(_polvo)
	_polvo.global_position = _punto_salida
	estado = Estado.AVISANDO
	_ticks = _d.ticks_aviso


# Sale en el punto del aviso, mirando al jugador, y queda quieta un rato.
func _salir() -> void:
	enemigo.global_position = _punto_salida
	enemigo.velocity = Vector2.ZERO
	flotar(false)
	_bajo_tierra(false)
	_quitar_polvo()
	var objetivo: Jugador = jugador()
	if objetivo != null and lado_de(objetivo) != 0.0:
		enemigo.mirando = lado_de(objetivo)
	estado = Estado.RECUPERANDO
	_ticks = _d.ticks_recuperacion


func _recuperar() -> void:
	caer()
	enemigo.velocity.x = 0.0
	mover()
	_ticks -= 1
	if _ticks <= 0:
		estado = Estado.CAMINANDO


# Punto del suelo bajo donde estaba el jugador, si ahi cabe su cuerpo; si no, donde se enterro.
func _buscar_salida() -> Vector2:
	var mitad: float = enemigo.ficha.tamano.x / 2.0
	var alto: float = enemigo.ficha.tamano.y
	var desde: Vector2 = Vector2(_x_salida, _y_salida - _d.margen_suelo)
	var suelo: Dictionary = Capas.rayo_a_escenario(enemigo, desde, desde + Vector2(0.0, ALCANCE_SALIDA))
	if suelo.is_empty():
		return enemigo.global_position
	var pie: Vector2 = suelo["position"] as Vector2
	var medio: Vector2 = pie + Vector2(0.0, -alto / 2.0)
	var libre_arriba: bool = Capas.rayo_a_escenario(
			enemigo, pie + Vector2(0.0, -_d.margen_suelo), pie + Vector2(0.0, -alto)).is_empty()
	var libre_ancho: bool = Capas.rayo_a_escenario(
			enemigo, medio + Vector2(-mitad, 0.0), medio + Vector2(mitad, 0.0)).is_empty()
	if libre_arriba and libre_ancho:
		return pie
	return enemigo.global_position


# Enterrada: sin dibujo, sin danar y sin ser golpeable. El DanoContacto dana en su _physics_process, asi que se
# apaga ese (con monitoring en false, get_overlapping_bodies daria error cada tick).
func _bajo_tierra(si: bool) -> void:
	enemigo.visible = not si
	enemigo.golpeable.monitorable = not si
	var contacto: DanoContacto = enemigo.get_node_or_null(^"DanoContacto") as DanoContacto
	if contacto != null:
		contacto.set_physics_process(not si)


func _quitar_polvo() -> void:
	if is_instance_valid(_polvo):
		_polvo.queue_free()
	_polvo = null
