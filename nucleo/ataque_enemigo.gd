class_name AtaqueEnemigo
extends DanoContacto
# Ataque de un enemigo, separado de su cuerpo: un area que dana al jugador mientras dura. Con
# se_puede_parar (rastro blanco), el ataque normal del jugador lo para (parry): el golpe no dana y
# el ataque desaparece. Lo crea el comportamiento del enemigo (ComportamientoEnemigo.atacar); el cuerpo
# del enemigo es un DanoContacto aparte y nunca se para.

const COLOR_PARABLE: Color = Color(0.95, 0.95, 0.95, 0.85)
const COLOR_NO_PARABLE: Color = Color(0.85, 0.25, 0.2, 0.85)

## El ataque normal del jugador lo para.
@export var se_puede_parar: bool = true
## Ticks que dura; 0: hasta que lo quite quien lo creo.
@export var ticks: int = 0

## Ya parado; publico para los guiones.
var parado: bool = false

var _tamano: Vector2 = Vector2.ZERO


## Ataque con forma de rectangulo, relativo a la posicion de quien lo crea.
static func crear(rectangulo: Rect2, ticks_que_dura: int, dano_del_golpe: int, parable: bool) -> AtaqueEnemigo:
	var ataque: AtaqueEnemigo = AtaqueEnemigo.new()
	ataque.ticks = ticks_que_dura
	ataque.dano = dano_del_golpe
	ataque.se_puede_parar = parable
	ataque.monitorable = true
	ataque._poner_forma(rectangulo)
	return ataque


func _poner_forma(rectangulo: Rect2) -> void:
	var forma: CollisionShape2D = CollisionShape2D.new()
	var figura: RectangleShape2D = RectangleShape2D.new()
	figura.size = rectangulo.size
	forma.shape = figura
	forma.position = rectangulo.get_center()
	add_child(forma)
	_tamano = rectangulo.size


func _physics_process(delta: float) -> void:
	if parado or Congelado.activo():
		return
	# Antes de danar: si el ataque del jugador ya lo toca, es un parry aunque el jugador se procese despues.
	if se_puede_parar:
		for cuerpo: Node2D in get_overlapping_bodies():
			var jugador: Jugador = cuerpo as Jugador
			if jugador != null and jugador.intentar_parar(self):
				return
	super(delta)
	if ticks > 0:
		ticks -= 1
		if ticks == 0:
			queue_free()


## Centro de su forma en coordenadas de la sala: el jugador dibuja ahi el estallido del parry.
func centro() -> Vector2:
	for hijo: Node in get_children():
		var forma: CollisionShape2D = hijo as CollisionShape2D
		if forma != null:
			return forma.global_position
	return global_position


## Lo llama el jugador al pararlo: deja de danar y desaparece.
func parar() -> void:
	if parado:
		return
	parado = true
	set_deferred(&"monitoring", false)
	set_deferred(&"monitorable", false)
	queue_free()


func _draw() -> void:
	for hijo: Node in get_children():
		var forma: CollisionShape2D = hijo as CollisionShape2D
		if forma != null:
			draw_rect(Rect2(forma.position - _tamano / 2.0, _tamano), COLOR_PARABLE if se_puede_parar else COLOR_NO_PARABLE)
