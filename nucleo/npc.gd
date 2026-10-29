class_name Npc
extends Interactuable
# Personaje con quien se habla: con el jugador encima y en el suelo, interactuar abre una CajaDialogo con la
# conversacion de su etapa y deja al jugador quieto (Jugador.hablando). Terminarla contando entrega sus recompensas
# una sola vez, sube la etapa (un numero en el estado de su sala, sin cambiar el guardado) y autoguarda; la ultima
# se repite sin entregar. Un golpe, un peligro o morir la cortan sin contarla. Va como hijo directo de una sala. Con
# un AnimatedSprite2D (animacion) anima quieto, hablar y entregar y se voltea hacia el jugador: el NPC que sale en
# varias salas trae su dibujo en su escena y ninguna sala lo programa.

signal conversacion_terminada(etapa: int)

const ANCHO: float = 120.0
const ALTO: float = 160.0
const COLOR: Color = Color(0.45, 0.55, 0.7, 1.0)
const ANIM_QUIETO: StringName = &"quieto"
const ANIM_HABLAR: StringName = &"hablar"
const ANIM_ENTREGAR: StringName = &"entregar"
## Px que el jugador debe pasar al otro lado antes de voltearse: parado justo encima no parpadea.
const ZONA_MUERTA: float = 4.0

## Id unico en la sala: es la clave de su etapa en Partida.salas. No empieza con "coleccionable" ni "entregado_".
@export var id: String = ""
## Una conversacion por etapa; terminada la ultima, se repite la ultima sin volver a entregar.
@export var conversaciones: Array[FichaDialogo] = []

## Dibujo animado opcional (hijo del Npc; sin el, la forma provisional). Se tocan solo las animaciones que tenga
## (classes/class_spriteframes.rst:280): ANIM_QUIETO, ANIM_HABLAR mientras dura la conversacion y ANIM_ENTREGAR al
## terminar contando una etapa, que vuelve a quieto al acabar (sin bucle; classes/class_animatedsprite2d.rst:112).
@export var animacion: AnimatedSprite2D = null
## Se voltea hacia el jugador: el dibujo mira a la derecha sin voltear y se refleja con scale.x, sobre los pies.
@export var mirar_al_jugador: bool = true

## Conversaciones terminadas contando; publica para los guiones.
var etapa: int = 0
## Hacia donde mira: 1 derecha, -1 izquierda; publica para los guiones.
var mira: float = 1.0

var _jugador_cercano: Jugador = null
var _entregando: bool = false


func _ready() -> void:
	super()
	etapa = Partida.estado_entero(Sala.clave_de(self), id, etapa)
	if animacion != null:
		animacion.animation_finished.connect(_al_acabar_animacion)
		_animar(ANIM_QUIETO)


func _physics_process(delta: float) -> void:
	super(delta)
	if animacion == null:
		return
	if not _entregando:
		_animar(ANIM_HABLAR if caja != null else ANIM_QUIETO)
	if mirar_al_jugador:
		_mirar_al_jugador()


## La conversacion que toca en esta etapa (la ultima si ya se terminaron todas).
func conversacion() -> FichaDialogo:
	if conversaciones.is_empty():
		return null
	return conversaciones[mini(etapa, conversaciones.size() - 1)]


## Termina la conversacion; con contar, entrega lo de esta etapa la primera vez. Publica para la prueba.
func terminar(contar: bool) -> void:
	if contar and etapa < conversaciones.size():
		var ficha: FichaDialogo = conversaciones[etapa]
		etapa += 1
		# Antes de entregar: el autoguardado que dispara una habilidad ya lleva la etapa.
		Partida.marcar(Sala.clave_de(self), id, etapa)
		for recompensa: Recompensa in ficha.recompensas:
			Partida.dar_recompensa(recompensa)
		Partida.autoguardar()
		if animacion != null and _tiene(ANIM_ENTREGAR):
			_entregando = true
			_animar(ANIM_ENTREGAR)
		conversacion_terminada.emit(etapa)
	_cerrar_caja()


func _al_interactuar(jugador: Jugador) -> void:
	var ficha: FichaDialogo = conversacion()
	if ficha == null or ficha.lineas.is_empty():
		return
	_abrir_caja(jugador, ficha)


func _al_terminar(contar: bool) -> void:
	terminar(contar)


# La sala crea al jugador despues del _ready de sus hijos: se busca hasta encontrarlo y luego se guarda.
func _mirar_al_jugador() -> void:
	if not is_instance_valid(_jugador_cercano):
		_jugador_cercano = get_tree().get_first_node_in_group(Jugador.GRUPO) as Jugador
		if _jugador_cercano == null:
			return
	var distancia: float = _jugador_cercano.global_position.x - global_position.x
	if absf(distancia) > ZONA_MUERTA:
		mira = signf(distancia)
	animacion.scale.x = absf(animacion.scale.x) * mira


func _animar(nombre: StringName) -> void:
	if _tiene(nombre) and animacion.animation != nombre:
		animacion.play(nombre)


func _tiene(nombre: StringName) -> bool:
	return animacion.sprite_frames != null and animacion.sprite_frames.has_animation(nombre)


func _al_acabar_animacion() -> void:
	if _entregando:
		_entregando = false
		_animar(ANIM_QUIETO)


# La forma provisional del personaje y, si se puede hablar, un triangulo encima. Solo se redibuja cuando cambia.
func _draw() -> void:
	dibujar_provisional(ANCHO, ALTO, COLOR)
	dibujar_aviso(ALTO + 24.0)
