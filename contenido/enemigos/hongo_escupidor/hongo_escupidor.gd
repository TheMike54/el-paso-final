extends ComportamientoEnemigo
# Hongo escupidor: fijo en el suelo y mirando al jugador. Cuando lo ve, avisa con un destello y le lanza una espora
# en arco que cae donde estaba. Un golpe que cuenta lo cierra ticks_cerrado ticks: cerrado no dispara y los golpes
# rebotan, sin dano ni Inspiracion, para que el jugador tenga que esperar a que abra. Parte de escupidor.gd.

const DatosHongoEscupidor = preload("datos_hongo_escupidor.gd")
## Oscurecimiento del dibujo mientras esta cerrado (en caja gris no hay otra forma de verlo).
const COLOR_CERRADO: Color = Color(0.45, 0.45, 0.45)
## La espora: el disparo del nucleo no se dibuja, asi que el Hongo le pone un circulo del color de los hongos de la
## zona, sin luz para que se vea en la oscuridad de la sala.
const COLOR_ESPORA: Color = Color("5fe0c8")
const RADIO_ESPORA: float = 18.0
const LADOS_ESPORA: int = 12
const MATERIAL_SIN_LUZ: CanvasItemMaterial = preload("res://nucleo/arte/sin_luz.tres")

enum Estado { ABIERTO, AVISANDO, CERRADO }

## Estado actual; publico para los guiones (0 abierto, 1 avisa, 2 cerrado).
var estado: Estado = Estado.ABIERTO
## Esporas lanzadas y veces que se cerro; publicos para los guiones.
var lanzados: int = 0
var cierres: int = 0

var _ticks: int = 0
var _ticks_espera: int = 0
var _d: DatosHongoEscupidor = null


func _ready() -> void:
	_d = datos as DatosHongoEscupidor
	# Esta plantado: un golpe no lo empuja (sin esto, el retroceso del Golpeable lo arrastraria hacia un foso).
	enemigo.golpeable.velocidad_retroceso = 0.0
	enemigo.golpeable.golpeado.connect(_al_golpear)


func datos_por_omision() -> DatosComportamiento:
	return DatosHongoEscupidor.new()


func actuar() -> void:
	caer()
	enemigo.velocity.x = 0.0
	mover()
	var objetivo: Jugador = jugador()
	if objetivo != null and objetivo.global_position.x != enemigo.global_position.x:
		enemigo.mirando = signf(objetivo.global_position.x - enemigo.global_position.x)
	match estado:
		Estado.ABIERTO:
			_abierto()
		Estado.AVISANDO:
			_avisando(objetivo)
		Estado.CERRADO:
			_ticks -= 1
			if _ticks <= 0:
				_abrir()


## Cerrado, todo golpe rebota.
func bloquea_golpe(_atacante: Node2D) -> bool:
	return estado == Estado.CERRADO


## Llega solo con un golpe que conto, a veces dentro de una senal de fisica: solo cambia el estado y los ticks.
func _al_golpear(_atacante: Node2D, _dano: int) -> void:
	if estado == Estado.CERRADO:
		return
	estado = Estado.CERRADO
	_ticks = _d.ticks_cerrado
	cierres += 1
	enemigo.modulate = COLOR_CERRADO


func _abierto() -> void:
	if _ticks_espera > 0:
		_ticks_espera -= 1
		return
	if ve_al_jugador(_d.radio):
		estado = Estado.AVISANDO
		_ticks = _d.aviso
		enemigo.modulate = COLOR_AVISO


func _avisando(objetivo: Jugador) -> void:
	_ticks -= 1
	if _ticks > 0:
		return
	estado = Estado.ABIERTO
	enemigo.modulate = Color.WHITE
	_ticks_espera = _d.espera
	if objetivo == null:
		return
	var destino: Vector2 = objetivo.global_position + Vector2(0.0, -40.0)
	var espora: ProyectilEnemigo = lanzar_en_arco(_d.salida, destino, _d.grados, _d.gravedad_bola, _d.tope, 1, true)
	_dibujar_espora(espora)
	lanzados += 1


## Un circulo del tamano de la forma del disparo (ProyectilEnemigo.TAMANO), hijo del disparo para que viaje con el.
func _dibujar_espora(espora: ProyectilEnemigo) -> void:
	var puntos: PackedVector2Array = PackedVector2Array()
	for i: int in range(LADOS_ESPORA):
		puntos.append(Vector2.from_angle(TAU * float(i) / float(LADOS_ESPORA)) * RADIO_ESPORA)
	var dibujo: Polygon2D = Polygon2D.new()
	dibujo.polygon = puntos
	dibujo.color = COLOR_ESPORA
	dibujo.material = MATERIAL_SIN_LUZ
	espora.add_child(dibujo)


## Al abrir conserva una espera para no disparar en el mismo tick.
func _abrir() -> void:
	estado = Estado.ABIERTO
	enemigo.modulate = Color.WHITE
	_ticks_espera = _d.espera
