class_name Recogible
extends Area2D
# Base de lo que el jugador toma al tocarlo (coleccionable, PejeCoins sueltas, objeto de habilidad): una sola
# deteccion del jugador vivo y un solo recuerdo en la partida, para que cada recogible nuevo sea solo su efecto y su
# arte. Por omision se recuerda con su id en el estado de su sala, como el «Shiny Item» de Hollow Knight; quien lo
# recuerde de otra forma (una habilidad) cambia ya_recogido() y recordado_por_id().

## Id unico dentro de la sala: la clave con que la partida lo recuerda. El validador exige que exista y no se repita.
@export var id: String = ""

var _tomado: bool = false


func _ready() -> void:
	Capas.poner(self, Capas.INTERACCION, Capas.JUGADOR)
	if ya_recogido():
		queue_free()
		return
	body_entered.connect(_al_entrar)


## Si ya se tomo en esta partida. Por omision, la marca de su id en el estado de su sala.
func ya_recogido() -> bool:
	return Partida.estado_de(Sala.clave_de(self), id) != null


## Si lo recuerda la sala por su id (el validador lo exige unico); false si lo recuerda otra cosa de la partida.
func recordado_por_id() -> bool:
	return true


# Efecto de tomarlo. Corre despues de marcarlo: un efecto que autoguarda (coleccionable_obtenido) ya lleva la marca.
func _al_recoger(_jugador: Jugador) -> void:
	pass


func _al_entrar(cuerpo: Node2D) -> void:
	var jugador: Jugador = cuerpo as Jugador
	# _tomado: dos entradas antes del queue_free (dos cuerpos en el mismo tick) no dan el efecto dos veces.
	if jugador == null or jugador.muerto or _tomado:
		return
	_tomado = true
	if recordado_por_id():
		Partida.marcar(Sala.clave_de(self), id)
	_al_recoger(jugador)
	queue_free()
