class_name Enemigo
extends Node2D
# Enemigo del nucleo: su ficha dice que es y que script lo mueve (ComportamientoEnemigo, que se agrega como
# hijo sin que el nucleo sepa cual es; sin script, quieto). Pierde vida con cada golpe que recibe su
# Golpeable y dana al jugador por contacto. Vencido, emite Eventos.enemigo_vencido y desaparece; si es
# fuerte, Partida lo recuerda hasta el proximo descanso y no vuelve a aparecer en su sala.

@export var ficha: FichaEnemigo
## Id del ejemplar, unico dentro de su sala: junto con la clave de la sala lo identifica.
@export var id: StringName = &""

## Vida que le queda.
var vida: int = 0
## Su Golpeable: lo que recibe los golpes (el parry tambien le pega aqui).
var golpeable: Golpeable:
	get:
		return _golpeable

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
	if ficha.comportamiento != null:
		var comportamiento: ComportamientoEnemigo = ficha.comportamiento.new() as ComportamientoEnemigo
		if comportamiento == null:
			push_error("Enemigo %s: el comportamiento de la ficha %s no hereda de ComportamientoEnemigo" % [name, ficha.id])
		else:
			comportamiento.enemigo = self
			comportamiento.name = "Comportamiento"
			add_child(comportamiento)


## "<sala>#<id>" (la sala por su id o, si es de prueba suelta, por su ruta): lo que Partida recuerda de un
## enemigo fuerte vencido.
func clave() -> String:
	var sala: Sala = owner as Sala
	var nombre: String = sala.clave() if sala != null else (owner.scene_file_path if owner != null else "")
	return "%s#%s" % [nombre, id]


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
	Congelado.pedir(Congelado.TICKS_AL_VENCER)
	Eventos.enemigo_vencido.emit(ficha.id)
	queue_free()


func _draw() -> void:
	if ficha != null:
		draw_rect(Rect2(-ficha.tamano.x / 2.0, -ficha.tamano.y, ficha.tamano.x, ficha.tamano.y), ficha.color)
