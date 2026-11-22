# Recuerda los puntos seguros y busca el suelo fijo para volver tras un peligro.
# Conserva la memoria de la llegada sin separar el movimiento del tick del jugador.
# Las consultas se hacen al llamarlas, en el mismo lugar del tick que antes.
class_name PuntoSeguroJugador
extends RefCounted

var jugador: Jugador
var ticks_en_suelo: int = 0
var puntos_seguros: PackedVector2Array = []
var punto_llegada: Vector2 = Vector2.ZERO
var punto_seguro_puerta: Vector2 = Vector2.INF


func _init(cuerpo: Jugador) -> void:
	jugador = cuerpo


func recordar_punto_seguro(en_suelo: bool) -> void:
	ticks_en_suelo = ticks_en_suelo + 1 if en_suelo and hay_suelo_fijo(jugador.global_position) else 0
	if ticks_en_suelo >= jugador.ticks_suelo_firme and jugador.ticks_sin_dano == 0:
		puntos_seguros.append(jugador.global_position)
		if puntos_seguros.size() > jugador.ticks_atras_punto_seguro:
			puntos_seguros.remove_at(0)


func ultimo_punto_seguro() -> Vector2:
	# Fuera del tick el espacio de fisica no se consulta (tutorials/physics/ray-casting.rst): sin comprobar.
	if not Engine.is_in_physics_frame():
		return puntos_seguros[0] if not puntos_seguros.is_empty() else punto_llegada
	for punto: Vector2 in puntos_seguros:
		if hay_suelo_fijo(punto):
			return punto
	return llegada_con_suelo()


func llegada_con_suelo() -> Vector2:
	if punto_seguro_puerta != Vector2.INF and hay_suelo_fijo(punto_seguro_puerta):
		return punto_seguro_puerta
	if hay_suelo_fijo(punto_llegada):
		return punto_llegada
	var sala: Sala = jugador.get_parent() as Sala
	if sala != null:
		for punto: Vector2 in sala.puntos_de_respaldo():
			if hay_suelo_fijo(punto):
				return punto
	var abajo: Dictionary = suelo_fijo_bajo(
		punto_llegada - Vector2(0.0, Jugador.RAYO_SUELO_ARRIBA), Vector2(punto_llegada.x, jugador.limites_sala.end.y))
	if not abajo.is_empty():
		return abajo["position"] as Vector2
	return punto_llegada



# El primer solido de ESCENARIO que no se mueve entre desde y hasta: repite el rayo excluyendo cada pieza que
# Vaiven.movil_de da por movil (classes/class_physicsdirectspacestate2d.rst, el rid del choque). Vacio si no hay.
func suelo_fijo_bajo(desde: Vector2, hasta: Vector2) -> Dictionary:
	var excluir: Array[RID] = []
	for _intento: int in Jugador.RAYO_SUELO_MOVILES_MAX:
		var choque: Dictionary = Capas.rayo_a_escenario(jugador, desde, hasta, excluir)
		if choque.is_empty() or Vaiven.movil_de(choque["collider"] as Node) == null:
			return choque
		excluir.append(choque["rid"] as RID)
	return {}


func volver_al_punto_seguro() -> void:
	jugador.reaparecer(ultimo_punto_seguro())
	jugador.ticks_desde_peligro = 0


# Si bajo el punto (los pies) hay un solido de ESCENARIO a menos de Jugador.RAYO_SUELO_ABAJO px que no se mueve.
# Un rayo en el centro y uno en cada orilla del cuerpo: parado en una orilla con el centro sobre el vacio sigue en el
# suelo, como para is_on_floor(). Solo cuenta el primer choque de cada rayo, sin atravesar lo que se mueve (a
# diferencia de suelo_fijo_bajo): una plataforma sobre los pinchos tiene suelo a menos de
# Jugador.RAYO_SUELO_ABAJO px bajo ella, y ese punto quedaria sobre los pinchos. A cambio, un punto con un elevador
# posado en el suelo se descarta y se usa otro.
func hay_suelo_fijo(punto: Vector2) -> bool:
	for lado: float in Jugador.RAYOS_SUELO_X:
		var pie: Vector2 = punto + Vector2(lado, 0.0)
		var choque: Dictionary = Capas.rayo_a_escenario(
			jugador, pie - Vector2(0.0, Jugador.RAYO_SUELO_ARRIBA), pie + Vector2(0.0, Jugador.RAYO_SUELO_ABAJO))
		if not choque.is_empty() and Vaiven.movil_de(choque["collider"] as Node) == null:
			return true
	return false
