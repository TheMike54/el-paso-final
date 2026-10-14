class_name Npc
extends Area2D
# Personaje con quien se habla: con el jugador encima y en el suelo, interactuar abre una CajaDialogo con la
# conversacion de su etapa y deja al jugador quieto (Jugador.hablando). Terminarla contando entrega sus recompensas
# una sola vez, sube la etapa (un numero en el estado de su sala, sin cambiar el guardado) y autoguarda; la ultima
# se repite sin entregar. Un golpe, un peligro o morir la cortan sin contarla. Va como hijo directo de una sala.

signal conversacion_terminada(etapa: int)

const ANCHO: float = 120.0
const ALTO: float = 160.0
const COLOR: Color = Color(0.45, 0.55, 0.7, 1.0)
const COLOR_AVISO: Color = Color(1.0, 1.0, 1.0, 0.9)

## Id unico en la sala: es la clave de su etapa en Partida.salas. No empieza con "coleccionable" ni "entregado_".
@export var id: String = ""
## Una conversacion por etapa; terminada la ultima, se repite la ultima sin volver a entregar.
@export var conversaciones: Array[FichaDialogo] = []

## Conversaciones terminadas contando, si el jugador puede hablar ahora y la caja abierta; publicas para los guiones.
var etapa: int = 0
var cerca: bool = false
var caja: CajaDialogo = null

var _jugador: Jugador = null


func _ready() -> void:
	etapa = Partida.estado_entero(Sala.clave_de(self), id, etapa)


func _physics_process(_delta: float) -> void:
	if caja != null:
		if not is_instance_valid(_jugador) or not _jugador.hablando or _jugador.muerto:
			_cerrar()
		return
	var jugador: Jugador = Jugador.encima_de(self)
	if (jugador != null) != cerca:
		cerca = jugador != null
		queue_redraw()
	if jugador != null and Input.is_action_just_pressed(&"interactuar") and not Congelado.activo():
		_empezar(jugador)


## La conversacion que toca en esta etapa (la ultima si ya se terminaron todas).
func conversacion() -> FichaDialogo:
	if conversaciones.is_empty():
		return null
	return conversaciones[mini(etapa, conversaciones.size() - 1)]


func _empezar(jugador: Jugador) -> void:
	var ficha: FichaDialogo = conversacion()
	if ficha == null or ficha.lineas.is_empty():
		return
	_jugador = jugador
	jugador.empezar_a_hablar()
	cerca = false
	queue_redraw()
	caja = CajaDialogo.new()
	caja.name = "Caja"
	caja.ficha = ficha
	caja.terminada.connect(_al_terminar)
	add_child(caja)


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
		conversacion_terminada.emit(etapa)
	_cerrar()


func _al_terminar(contar: bool) -> void:
	terminar(contar)


func _cerrar() -> void:
	if is_instance_valid(_jugador):
		_jugador.dejar_de_hablar()
	_jugador = null
	if caja != null:
		# Sin ficha, la caja ya no procesa: liberada en este tick, todavia correria despues de este nodo y una
		# pulsacion del mismo tick terminaria contando la conversacion que el golpe corto.
		caja.ficha = null
		caja.queue_free()
		caja = null


# La forma provisional del personaje y, si se puede hablar, un triangulo encima. Solo se redibuja cuando cambia.
func _draw() -> void:
	draw_rect(Rect2(-ANCHO / 2.0, -ALTO, ANCHO, ALTO), COLOR)
	if cerca:
		var punta: Vector2 = Vector2(0.0, -ALTO - 24.0)
		draw_colored_polygon(PackedVector2Array([punta + Vector2(-20.0, -28.0), punta + Vector2(20.0, -28.0), punta]), COLOR_AVISO)
