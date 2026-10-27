class_name Proyectil
extends Area2D
# Poder del boton de curar (habilidad proyectil; nombre neutro hasta decidir que es en el mundo):
# avanza recto y sin gravedad, golpea una sola vez a cada Golpeable que toca y lo atraviesa, corta cada Cortable, y
# desaparece contra un solido o al acabar su recorrido. Los solidos se buscan con un rayo: este Area2D, movido
# por posicion, no detecto los StaticBody2D de las salas (docs/errores/2026-10-06-bola-atravesaba-paredes.md).
# Lo crea el jugador en su sala. Se ve como bola de fuego en capas (EfectoCuadros con nucleo/arte/efecto_bola.png).
const TAMANO: Vector2 = Vector2(60.0, 40.0)
const HOJA: Texture2D = preload("res://nucleo/arte/efecto_bola.png")
## Cuadros de la hoja y cuantos salen de la fila sin gotas sueltas: al salir asomarian sobre la cabeza del jugador.
const CUADROS: int = 6
const CUADROS_SIN_GOTAS: int = 3
## Del centro del cuadro (224x160) al centro de la bola, que va 70 px antes de la orilla derecha: la bola dibujada
## queda sobre la forma de golpe y la cola, atras.
const DESDE_CENTRO: Vector2 = Vector2(-42.0, 0.0)

## Velocidad, en px/s.
@export var velocidad: float = 900.0
## Ticks que dura antes de desaparecer solo (60: 900 px).
@export var ticks_vida: int = 60
## Dano que hace a cada Golpeable.
@export var dano: int = 2

## Sentido en x: 1 a la derecha, -1 a la izquierda. Lo fija quien lo lanza.
var sentido: float = 1.0

var _golpeados: Array[Golpeable] = []
var _dibujo: EfectoCuadros = null
var _ticks_volando: int = 0


func _ready() -> void:
	Capas.poner(self, Capas.ATAQUE_JUGADOR, Capas.GOLPEABLE)
	_dibujo = EfectoCuadros.crear(HOJA, CUADROS, 2, false, false, false)
	_dibujo.name = &"Dibujo"
	_dibujo.fila = 1
	_dibujo.offset = DESDE_CENTRO
	_dibujo.scale.x = sentido
	add_child(_dibujo)
	area_entered.connect(_al_tocar_area)


func _physics_process(delta: float) -> void:
	if Congelado.activo():
		return
	# El rayo va del centro hasta el frente de la bola despues de este paso: un solido delgado no
	# se salta aunque la bola avance mas de su grosor en un tick.
	var paso: float = sentido * velocidad * delta
	var frente: Vector2 = global_position + Vector2(paso + sentido * TAMANO.x / 2.0, 0.0)
	var choque: Dictionary = Capas.rayo_a_escenario(self, global_position, frente)
	if not choque.is_empty():
		# Un muro rompible para a la bola en su solido, antes de que toque su area de golpe: se le pega aqui.
		var muro: MuroRompible = choque["collider"] as MuroRompible
		if muro != null and muro.golpeable != null and not _golpeados.has(muro.golpeable):
			_golpeados.append(muro.golpeable)
			muro.golpeable.recibir_golpe(self, dano)
		queue_free()
		return
	position.x += paso
	ticks_vida -= 1
	_ticks_volando += 1
	if _ticks_volando == CUADROS_SIN_GOTAS * EfectoCuadros.TICKS_POR_CUADRO:
		_dibujo.fila = 0
	if ticks_vida <= 0:
		queue_free()


func _al_tocar_area(area: Area2D) -> void:
	# El pasto se corta como con el ataque y la bola sigue: no es solido.
	var cortable: Cortable = area as Cortable
	if cortable != null:
		cortable.cortar()
		return
	var golpeable: Golpeable = area as Golpeable
	if golpeable != null and not _golpeados.has(golpeable):
		_golpeados.append(golpeable)
		golpeable.recibir_golpe(self, dano)
