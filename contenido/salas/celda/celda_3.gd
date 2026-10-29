extends Sala
# La Celda, sala 3: su unico evento propio. Cuando el Eterno termina su primera conversacion (la que entrega la Pluma)
# se ve la entrega y la sala le pide al Fundido el cambio a la cinematica de la Pluma, que al acabar vuelve aqui, a la
# Entrada, junto al Eterno. El dibujo y la animacion del Eterno son de su escena (contenido/npc/eterno/).

const CINEMATICA: String = "res://contenido/cinematicas/cinematica_eterno_pluma.tscn"

# Ticks de espera antes de oscurecer: lo que dura la animacion entregar del Eterno, leida de sus SpriteFrames para que
# un cambio en la tira no deje el fundido a destiempo.
var _ticks_entrega: int = 0

@onready var _eterno: Npc = $Eterno as Npc


func _ready() -> void:
	super()
	_ticks_entrega = _duracion_entrega()
	_eterno.conversacion_terminada.connect(_al_terminar_conversacion)


# Solo la primera etapa entrega la Pluma; las siguientes repiten la conversacion sin cinematica. Se pasa el jugador:
# si muere mientras oscurece, manda la muerte y no hay cinematica (Fundido.cambiar_sala).
func _al_terminar_conversacion(etapa: int) -> void:
	if etapa != 1:
		return
	var fundido: Fundido = Fundido.de(self)
	if fundido == null:
		push_error("Celda 3: la sala no tiene Fundido")
		return
	var jugador: Jugador = get_tree().get_first_node_in_group(Jugador.GRUPO) as Jugador
	fundido.cambiar_sala(CINEMATICA, Fundido.Llegada.ENTRADA, "", Fundido.Perfil.PUERTA, _ticks_entrega, jugador)


# Duracion absoluta de la animacion = suma de las duraciones relativas / (fps de la animacion * speed_scale)
# (classes/class_spriteframes.rst:252-256), en ticks de fisica. Sin la animacion, oscurece sin esperar.
# Vale porque Npc reproduce con play(nombre), velocidad propia 1; si un dia pasa otra, usar get_playing_speed().
func _duracion_entrega() -> int:
	var dibujo: AnimatedSprite2D = _eterno.animacion
	if dibujo == null or dibujo.sprite_frames == null or not dibujo.sprite_frames.has_animation(Npc.ANIM_ENTREGAR):
		push_error("Celda 3: el Eterno no tiene la animacion entregar")
		return 0
	var cuadros: SpriteFrames = dibujo.sprite_frames
	var velocidad: float = cuadros.get_animation_speed(Npc.ANIM_ENTREGAR) * absf(dibujo.speed_scale)
	if is_zero_approx(velocidad):
		push_error("Celda 3: la animacion entregar del Eterno no avanza")
		return 0
	var relativa: float = 0.0
	for i: int in range(cuadros.get_frame_count(Npc.ANIM_ENTREGAR)):
		relativa += cuadros.get_frame_duration(Npc.ANIM_ENTREGAR, i)
	return roundi(relativa / velocidad * Engine.physics_ticks_per_second)
