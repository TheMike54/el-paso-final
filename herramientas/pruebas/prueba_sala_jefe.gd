# Prueba la sala jugable del jefe y su ciclo de BattleScene con guardado aislado.
# Recorre umbrales, activacion, victoria unica y regreso sin jefe, usando sus piezas reales.
# Tambien cubre un golpe que salta dos fases y la muerte antes del golpe final del jefe.
extends "res://herramientas/pruebas/prueba_base.gd"

const ESCENA: PackedScene = preload("res://herramientas/salas/sala_jefe.tscn")
const ComportamientoJefe = preload("res://herramientas/salas/comportamientos/jefe_prueba.gd")
const ID: StringName = &"arena_jefe_prueba"

var _fases: Array[int] = []
var _victorias: Array[StringName] = []
var _premios: int = 0
var _vencidos: int = 0
var _vencido_antes_de_liberar: bool = false


func _ready() -> void:
	_aislar_partida("user://prueba_sala_jefe.json")
	Eventos.jefe_vencido.connect(_anotar_victoria)
	Eventos.habilidad_obtenida.connect(_anotar_premio)
	await _probar_victoria()
	await _probar_salto_de_fases()
	await _probar_muerte()
	await _probar_enemigo_comun()
	Eventos.jefe_vencido.disconnect(_anotar_victoria)
	Eventos.habilidad_obtenida.disconnect(_anotar_premio)
	_restaurar_partida()
	_resumen()


func _probar_victoria() -> void:
	var sala: Sala = ESCENA.instantiate() as Sala
	add_child(sala)
	await _esperar(4)
	var jefe: Enemigo = sala.get_node(^"Jefe") as Enemigo
	var arena: ArenaJefe = sala.get_node(^"Arena") as ArenaJefe
	var comportamiento: ComportamientoJefe = jefe.get_node(^"Comportamiento") as ComportamientoJefe
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	var izquierdo: Porton = sala.get_node(^"PortonIzquierdo") as Porton
	var derecho: Porton = sala.get_node(^"PortonDerecho") as Porton
	jefe.golpeable.velocidad_retroceso = 0.0
	jefe.fase_cambiada.connect(_anotar_fase)
	jefe.vencido.connect(_anotar_vencido.bind(jefe))
	_caso("empieza con pluma, sin impulso y fase 0", Partida.tiene(Habilidades.PLUMA)
			and not Partida.tiene(&"impulso") and jefe.fase == 0)
	_caso("arena detecta al jugador en la capa de interaccion", arena.collision_layer == Capas.INTERACCION
			and arena.collision_mask == Capas.JUGADOR)
	_caso("portones abiertos y comportamiento dormido", izquierdo.esta_abierto and derecho.esta_abierto
			and not arena.activa and not comportamiento.is_physics_processing())
	var posicion: Vector2 = jefe.position
	await _esperar(8)
	_caso("dormido no camina", jefe.position == posicion)
	jefe.golpeable.recibir_golpe(jugador, 1)
	_caso("dormido sigue recibiendo golpes", jefe.vida == 11 and jefe.fase == 0 and _fases.is_empty())
	jugador.global_position = Vector2(800.0, 680.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(4)
	_caso("entrar cierra los dos portones y despierta", arena.activa and not izquierdo.esta_abierto
			and not derecho.esta_abierto and comportamiento.is_physics_processing())
	# Reentrar no reinicia la pelea ni la fase.
	arena.body_entered.emit(jugador)
	jefe.golpeable.recibir_golpe(jugador, 4)
	_caso("por encima del umbral no cambia de fase", jefe.vida == 7 and jefe.fase == 0 and _fases.is_empty())
	jefe.golpeable.recibir_golpe(jugador, 1)
	_caso("igualar el umbral cambia una vez y llama al gancho", jefe.vida == 6 and jefe.fase == 1
			and _fases == [1] and comportamiento.cambios == [1])
	jefe.golpeable.recibir_golpe(jugador, 1)
	_caso("bajar mas no repite la fase", jefe.fase == 1 and _fases == [1] and comportamiento.cambios == [1])
	# Lejos del jefe y fuera de su altura de contacto: observar el patron sin morir.
	jugador.global_position = Vector2(800.0, 200.0)
	jugador.velocity = Vector2.ZERO
	jugador.set_physics_process(false)
	await _esperar(40)
	_caso("los portones terminan cerrados", is_equal_approx(izquierdo.position.y, 320.0)
			and is_equal_approx(derecho.position.y, 320.0))
	await _esperar(135)
	_caso("segunda fase embiste", comportamiento.embestidas >= 1)
	jefe.golpeable.recibir_golpe(jugador, 5)
	jefe.golpeable.recibir_golpe(jugador, 5)
	_caso("vencido se emite una vez antes de queue_free", _vencidos == 1 and _vencido_antes_de_liberar
			and jefe.is_queued_for_deletion())
	_caso("victoria con id de arena da impulso una vez", _victorias == [ID] and _premios == 1
			and Partida.jefes.has(ID) and Partida.tiene(&"impulso"))
	var guardados: int = Partida.autoguardados
	arena._al_vencer()
	_caso("repetir victoria no da premio ni autoguarda", _premios == 1 and _victorias.size() == 1
			and Partida.autoguardados == guardados)
	await _esperar(40)
	_caso("vencer abre los dos portones y libera al jefe", izquierdo.esta_abierto and derecho.esta_abierto
			and not is_instance_valid(jefe))
	sala.free()
	sala = ESCENA.instantiate() as Sala
	add_child(sala)
	await _esperar(4)
	arena = sala.get_node(^"Arena") as ArenaJefe
	izquierdo = sala.get_node(^"PortonIzquierdo") as Porton
	derecho = sala.get_node(^"PortonDerecho") as Porton
	_caso("volver deja la arena abierta y sin jefe", sala.get_node_or_null(^"Jefe") == null
			and izquierdo.esta_abierto and derecho.esta_abierto and not arena.activa)
	jugador = sala.get_node(^"Jugador") as Jugador
	jugador.global_position = Vector2(800.0, 680.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(4)
	_caso("volver y entrar no repite premio, victoria ni guardado", _premios == 1 and _victorias.size() == 1
			and Partida.autoguardados == guardados and not arena.activa)
	sala.free()


func _probar_salto_de_fases() -> void:
	Partida.reiniciar()
	_fases.clear()
	var sala: Sala = ESCENA.instantiate() as Sala
	var jefe: Enemigo = sala.get_node(^"Jefe") as Enemigo
	var ficha: FichaEnemigo = jefe.ficha.duplicate() as FichaEnemigo
	ficha.umbrales_fase = [9, 6]
	jefe.ficha = ficha
	add_child(sala)
	await _esperar(3)
	jefe.fase_cambiada.connect(_anotar_fase)
	var comportamiento: ComportamientoJefe = jefe.get_node(^"Comportamiento") as ComportamientoJefe
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	jefe.golpeable.velocidad_retroceso = 0.0
	jefe.golpeable.recibir_golpe(jugador, 7)
	_caso("un golpe por debajo de dos umbrales emite ambas fases en orden", jefe.vida == 5
			and jefe.fase == 2 and _fases == [1, 2] and comportamiento.cambios == [1, 2])
	jefe.golpeable.recibir_golpe(jugador, 1)
	_caso("las fases saltadas no vuelven a emitirse", _fases == [1, 2] and comportamiento.cambios == [1, 2])
	var original: Sala = ESCENA.instantiate() as Sala
	_caso("la ficha compartida conserva sus umbrales", (original.get_node(^"Jefe") as Enemigo).ficha.umbrales_fase == [6])
	original.free()
	# La ficha original es un recurso compartido; solo se cambia la copia de este ejemplar.
	sala.free()


func _probar_muerte() -> void:
	Partida.reiniciar()
	var sala: Sala = ESCENA.instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	var jefe: Enemigo = sala.get_node(^"Jefe") as Enemigo
	var arena: ArenaJefe = sala.get_node(^"Arena") as ArenaJefe
	jugador.global_position = Vector2(800.0, 680.0)
	jugador.velocity = Vector2.ZERO
	await _esperar(3)
	_caso("el intento antes de morir esta activo", arena.activa)
	var premios: int = _premios
	var victorias: int = _victorias.size()
	jugador._morir()
	_caso("morir no da recompensa ni victoria", jugador.muerto and not arena.activa
			and not Partida.tiene(&"impulso") and not Partida.jefes.has(ID)
			and _premios == premios and _victorias.size() == victorias)
	jefe.golpeable.recibir_golpe(jugador, 100)
	_caso("un golpe final durante la muerte tampoco premia", not Partida.tiene(&"impulso")
			and not Partida.jefes.has(ID) and _premios == premios and _victorias.size() == victorias)
	# Antes de que Fundido cambie la escena del guion: reconstruir la sala, como hace la reaparicion.
	sala.free()
	Partida.llenar_vidas()
	sala = ESCENA.instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	jefe = sala.get_node(^"Jefe") as Enemigo
	var porton: Porton = sala.get_node(^"PortonIzquierdo") as Porton
	_caso("tras morir el siguiente intento empieza entero y abierto", jefe.vida == jefe.ficha.vida
			and jefe.fase == 0 and porton.esta_abierto and not Partida.jefes.has(ID))
	sala.free()


func _probar_enemigo_comun() -> void:
	var sala: Sala = ESCENA.instantiate() as Sala
	var enemigo: Enemigo = sala.get_node(^"Jefe") as Enemigo
	var ficha: FichaEnemigo = enemigo.ficha.duplicate() as FichaEnemigo
	ficha.jefe = false
	ficha.comportamiento = null
	ficha.umbrales_fase = []
	ficha.vida = 1
	enemigo.ficha = ficha
	# Quitar la arena antes de entrar al arbol: el enemigo comun no da premios de jefe.
	sala.get_node(^"Arena").free()
	add_child(sala)
	await _esperar(3)
	var anteriores: int = _vencidos
	enemigo.vencido.connect(_anotar_vencido.bind(enemigo))
	enemigo.golpeable.recibir_golpe(sala.get_node(^"Jugador") as Jugador, 1)
	_caso("el enemigo comun tambien emite vencido antes de liberarse", _vencidos == anteriores + 1
			and _vencido_antes_de_liberar and enemigo.is_queued_for_deletion())
	sala.free()


func _anotar_fase(fase: int) -> void:
	_fases.append(fase)


func _anotar_victoria(id_jefe: StringName) -> void:
	_victorias.append(id_jefe)


func _anotar_premio(habilidad: StringName) -> void:
	if habilidad == &"impulso":
		_premios += 1


func _anotar_vencido(enemigo: Enemigo) -> void:
	_vencidos += 1
	_vencido_antes_de_liberar = is_instance_valid(enemigo) and not enemigo.is_queued_for_deletion()
