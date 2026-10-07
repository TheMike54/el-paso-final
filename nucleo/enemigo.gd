class_name Enemigo
extends Node2D
# Enemigo del nucleo: su ficha dice que es, asi un enemigo nuevo es una ficha y no codigo. Pierde
# vida con cada golpe que recibe su Golpeable y dana al jugador por contacto. Vencido, emite
# Eventos.enemigo_vencido y desaparece; si es fuerte, Partida lo recuerda hasta el proximo
# descanso y no vuelve a aparecer en su sala. Por ahora no se mueve.

@export var ficha: FichaEnemigo
## Id del ejemplar, unico dentro de su sala: junto con la escena de la sala lo identifica.
@export var id: StringName = &""

## Vida que le queda.
var vida: int = 0

@onready var _golpeable: Golpeable = $Golpeable as Golpeable
@onready var _contacto: DanoContacto = $DanoContacto as DanoContacto


func _ready() -> void:
	if ficha == null or id.is_empty():
		push_error("Enemigo %s: le falta la ficha o el id" % name)
		queue_free()
		return
	if ficha.reaparicion == FichaEnemigo.Reaparicion.AL_DESCANSAR and Partida.fue_vencido(clave()):
		queue_free()
		return
	vida = ficha.vida
	_contacto.dano = ficha.dano_contacto
	_poner_forma(_golpeable)
	_poner_forma(_contacto)
	_golpeable.golpeado.connect(_al_ser_golpeado)


## "<escena de la sala>#<id>": lo que Partida recuerda de un enemigo fuerte vencido.
func clave() -> String:
	var sala: String = owner.scene_file_path if owner != null else ""
	return "%s#%s" % [sala, id]


# Las formas se crean aqui con el tamano de la ficha: una forma de la escena seria la misma para
# todos los ejemplares.
func _poner_forma(area: Area2D) -> void:
	var rectangulo: RectangleShape2D = RectangleShape2D.new()
	rectangulo.size = ficha.tamano
	var forma: CollisionShape2D = area.get_node(^"Forma") as CollisionShape2D
	forma.shape = rectangulo
	forma.position = Vector2(0.0, -ficha.tamano.y / 2.0)


func _al_ser_golpeado(_atacante: Node2D, dano: int) -> void:
	if vida <= 0:
		return
	vida = maxi(vida - dano, 0)
	if vida > 0:
		return
	if ficha.reaparicion == FichaEnemigo.Reaparicion.AL_DESCANSAR:
		Partida.vencer(clave())
	Eventos.enemigo_vencido.emit(ficha.id)
	queue_free()


func _draw() -> void:
	if ficha != null:
		draw_rect(Rect2(-ficha.tamano.x / 2.0, -ficha.tamano.y, ficha.tamano.x, ficha.tamano.y), ficha.color)
