class_name AtaqueEnemigo
extends DanoContacto
# Ataque de un enemigo, separado de su cuerpo: un area que dana al jugador mientras dura. Con
# se_puede_parar, el ataque normal del jugador lo para (parry): el golpe no dana y
# el ataque desaparece. Lo crea el comportamiento del enemigo (ComportamientoEnemigo.atacar); el cuerpo
# del enemigo es un DanoContacto aparte y nunca se para. Uno que se puede parar deja al empezar el mismo trazo
# blanco que el golpe del jugador (TrazoAtaque): asi se reconoce el golpe que se puede parar. El area no se dibuja: se ve
# con «Ver hitbox» (decidido por la persona el 25-oct-2026).

## El ataque normal del jugador lo para.
@export var se_puede_parar: bool = true
## Ticks que dura; 0: hasta que lo quite quien lo creo.
@export var ticks: int = 0

## Deja el trazo blanco al empezar si se puede parar. Un proyectil no: el trazo es de un golpe, no de algo que vuela.
var con_trazo: bool = true
## Ya parado; publico para los guiones.
var parado: bool = false


## Ataque con forma de rectangulo, relativo a la posicion de quien lo crea.
static func crear(rectangulo: Rect2, ticks_que_dura: int, dano_del_golpe: int, parable: bool) -> AtaqueEnemigo:
	var ataque: AtaqueEnemigo = AtaqueEnemigo.new()
	ataque.ticks = ticks_que_dura
	ataque.dano = dano_del_golpe
	ataque.se_puede_parar = parable
	ataque.monitorable = true
	ataque._poner_forma(rectangulo)
	return ataque


func _ready() -> void:
	super()
	if not se_puede_parar or not con_trazo:
		return
	var trazo: TrazoAtaque = TrazoAtaque.new()
	trazo.name = &"Trazo"
	add_child(trazo)
	var centro_forma: Vector2 = centro() - global_position
	trazo.mostrar(centro_forma, TrazoAtaque.Direccion.LADO, -1.0 if centro_forma.x < 0.0 else 1.0)


func _poner_forma(rectangulo: Rect2) -> void:
	var forma: CollisionShape2D = CollisionShape2D.new()
	var figura: RectangleShape2D = RectangleShape2D.new()
	figura.size = rectangulo.size
	forma.shape = figura
	forma.position = rectangulo.get_center()
	add_child(forma)


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


## Centro de su forma en coordenadas de la sala: ahi va la chispa de un disparo desviado, y a medio camino del area
## de golpe, el destello de un parry hacia arriba o abajo (Jugador._parar).
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
