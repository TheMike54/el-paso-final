# Recuerda los puntos seguros y busca el suelo fijo para volver tras un peligro.
# Conserva la memoria de la llegada sin separar el movimiento del tick del jugador.
# Las consultas se hacen al llamarlas, en el mismo lugar del tick que antes.
class_name PuntoSeguroJugador
extends RefCounted

var jugador: Jugador
var _ticks_en_suelo: int = 0
var _puntos_seguros: PackedVector2Array = []
var _punto_llegada: Vector2 = Vector2.ZERO
var _punto_seguro_puerta: Vector2 = Vector2.INF


func _init(cuerpo: Jugador) -> void:
	jugador = cuerpo


func _recordar_punto_seguro(en_suelo: bool) -> void:
	_ticks_en_suelo = _ticks_en_suelo + 1 if en_suelo and _hay_suelo_fijo(jugador.global_position) else 0
	if _ticks_en_suelo >= jugador.ticks_suelo_firme and jugador._ticks_sin_dano == 0:
		_puntos_seguros.append(jugador.global_position)
		if _puntos_seguros.size() > jugador.ticks_atras_punto_seguro:
			_puntos_seguros.remove_at(0)


func ultimo_punto_seguro() -> Vector2:
	# Fuera del tick el espacio de fisica no se consulta (tutorials/physics/ray-casting.rst:42): sin comprobar.
	if not Engine.is_in_physics_frame():
		return _puntos_seguros[0] if not _puntos_seguros.is_empty() else _punto_llegada
	for punto: Vector2 in _puntos_seguros:
		if _hay_suelo_fijo(punto):
			return punto
	return _llegada_con_suelo()


func _llegada_con_suelo() -> Vector2:
	if _punto_seguro_puerta != Vector2.INF and _hay_suelo_fijo(_punto_seguro_puerta):
		return _punto_seguro_puerta
	if _hay_suelo_fijo(_punto_llegada):
		return _punto_llegada
	var sala: Sala = jugador.get_parent() as Sala
	if sala != null:
		for punto: Vector2 in sala.puntos_de_respaldo():
			if _hay_suelo_fijo(punto):
				return punto
	var abajo: Dictionary = _suelo_fijo_bajo(
		_punto_llegada - Vector2(0.0, Jugador.RAYO_SUELO_ARRIBA), Vector2(_punto_llegada.x, jugador._limites.end.y))
	if not abajo.is_empty():
		return abajo["position"] as Vector2
	return _punto_llegada


func _suelo_fijo_bajo(desde: Vector2, hasta: Vector2) -> Dictionary:
	var excluir: Array[RID] = []
	for _intento: int in Jugador.RAYO_SUELO_MOVILES_MAX:
		var choque: Dictionary = Capas.rayo_a_escenario(jugador, desde, hasta, excluir)
		if choque.is_empty() or Vaiven.movil_de(choque["collider"] as Node) == null:
			return choque
		excluir.append(choque["rid"] as RID)
	return {}


func _volver_al_punto_seguro() -> void:
	jugador._reaparecer(ultimo_punto_seguro())
	jugador._ticks_desde_peligro = 0


func _hay_suelo_fijo(punto: Vector2) -> bool:
	for lado: float in Jugador.RAYOS_SUELO_X:
		var pie: Vector2 = punto + Vector2(lado, 0.0)
		var choque: Dictionary = Capas.rayo_a_escenario(
			jugador, pie - Vector2(0.0, Jugador.RAYO_SUELO_ARRIBA), pie + Vector2(0.0, Jugador.RAYO_SUELO_ABAJO))
		if not choque.is_empty() and Vaiven.movil_de(choque["collider"] as Node) == null:
			return true
	return false
