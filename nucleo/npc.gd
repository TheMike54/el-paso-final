class_name Npc
extends Interactuable
# Personaje con quien se habla: con el jugador encima y en el suelo, interactuar abre una CajaDialogo con la
# conversacion de su etapa y deja al jugador quieto (Jugador.hablando). Terminarla contando entrega sus recompensas
# una sola vez, sube la etapa (un numero en el estado de su sala, sin cambiar el guardado) y autoguarda; la ultima
# se repite sin entregar. Un golpe, un peligro o morir la cortan sin contarla. Va como hijo directo de una sala.

signal conversacion_terminada(etapa: int)

const ANCHO: float = 120.0
const ALTO: float = 160.0
const COLOR: Color = Color(0.45, 0.55, 0.7, 1.0)

## Id unico en la sala: es la clave de su etapa en Partida.salas. No empieza con "coleccionable" ni "entregado_".
@export var id: String = ""
## Una conversacion por etapa; terminada la ultima, se repite la ultima sin volver a entregar.
@export var conversaciones: Array[FichaDialogo] = []

## Conversaciones terminadas contando; publica para los guiones.
var etapa: int = 0


func _ready() -> void:
	super()
	etapa = Partida.estado_entero(Sala.clave_de(self), id, etapa)


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
		conversacion_terminada.emit(etapa)
	_cerrar_caja()


func _al_interactuar(jugador: Jugador) -> void:
	var ficha: FichaDialogo = conversacion()
	if ficha == null or ficha.lineas.is_empty():
		return
	_abrir_caja(jugador, ficha)


func _al_terminar(contar: bool) -> void:
	terminar(contar)


# La forma provisional del personaje y, si se puede hablar, un triangulo encima. Solo se redibuja cuando cambia.
func _draw() -> void:
	dibujar_provisional(ANCHO, ALTO, COLOR)
	dibujar_aviso(ALTO + 24.0)
