extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de los enemigos que se mueven en la sala de enemigos moviles: el caminante no cae de su plataforma, gira
# en la pared y en la orilla con su pausa y un golpe no lo saca de la orilla; el volador zumba, no ve tras una pared,
# despierta, respeta su tope, no atraviesa la pared y olvida; el arco cae donde apunta, se detiene en los solidos y
# se puede parar. Su guion lee "valor . casos" y "valor . fallos".
const SALA: String = "res://herramientas/salas/sala_enemigos_moviles.tscn"

var _sala: Sala = null
var _jugador: Jugador = null


func _ready() -> void:
	_aislar_partida()
	_sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(_sala)
	await _esperar(3)
	_jugador = get_tree().get_first_node_in_group(&"jugador") as Jugador
	_caso("cuentas del arco: cae a menos de 40 px del objetivo", _arco_atina(Vector2(300.0, 0.0)) and _arco_atina(Vector2(600.0, 100.0)) and _arco_atina(Vector2(-500.0, -150.0)))
	await _caminantes()
	await _volador()
	await _disparos()
	_sala.queue_free()
	_restaurar_partida()
	_resumen()


func _caminantes() -> void:
	var arriba: Enemigo = _sala.get_node(^"CaminantePlataforma") as Enemigo
	var abajo: Enemigo = _sala.get_node(^"CaminanteSuelo") as Enemigo
	var y_max: float = 0.0
	var x_max_abajo: float = 0.0
	var quieto_seguido: int = 0
	var pausa_mas_larga: int = 0
	for i: int in range(1200):
		await get_tree().physics_frame
		y_max = maxf(y_max, arriba.global_position.y)
		x_max_abajo = maxf(x_max_abajo, abajo.global_position.x)
		if (_comportamiento(arriba).call(&"esta_quieto") as bool) and is_zero_approx(arriba.velocity.x):
			quieto_seguido += 1
			pausa_mas_larga = maxi(pausa_mas_larga, quieto_seguido)
		else:
			quieto_seguido = 0
	_caso("en 20 s el caminante no cae de su plataforma", y_max <= 741.0)
	_caso("el caminante gira en las dos orillas", (_comportamiento(arriba).get(&"giros") as int) >= 2)
	_caso("se queda quieto los 60 ticks antes de girar", pausa_mas_larga >= 59 and pausa_mas_larga <= 61)
	_caso("el del suelo gira en la pared y no la cruza", (_comportamiento(abajo).get(&"giros") as int) >= 1 and x_max_abajo <= 1281.0 - 50.0)
	# Un golpe desde la izquierda en la orilla derecha no lo saca de la plataforma (orilla en x 1000, medio cuerpo 50).
	arriba.global_position = Vector2(940.0, 740.0)
	arriba.velocity = Vector2.ZERO
	await _esperar(2)
	_jugador.global_position = Vector2(700.0, 740.0)
	arriba.golpeable.recibir_golpe(_jugador, 0)
	await _esperar(10)
	_caso("el golpe no lo empuja fuera de la orilla", arriba.global_position.x <= 951.0 and arriba.global_position.y <= 741.0)
	_jugador.global_position = Vector2(1450.0, 1040.0)
	_jugador.velocity = Vector2.ZERO
	await _esperar(10)


func _volador() -> void:
	var volador: Enemigo = _sala.get_node(^"Volador") as Enemigo
	var comportamiento: Node = _comportamiento(volador)
	var origen: Vector2 = volador.global_position
	await _esperar(120)
	_caso("con el jugador lejos zumba en su sitio", not (comportamiento.get(&"persiguiendo") as bool) and volador.global_position.distance_to(origen) < 60.0)
	_poner_jugador(Vector2(2100.0, 1040.0))
	await _esperar(30)
	_caso("cerca pero tras el pilar no lo ve", not (comportamiento.get(&"persiguiendo") as bool))
	_poner_jugador(Vector2(1700.0, 1040.0))
	var antes: float = volador.global_position.distance_to(_jugador.global_position)
	await _esperar(60)
	_caso("cerca y a la vista despierta y se acerca", (comportamiento.get(&"persiguiendo") as bool) and volador.global_position.distance_to(_jugador.global_position) < antes)
	_poner_jugador(Vector2(2250.0, 1040.0))
	var x_max: float = 0.0
	for i: int in range(240):
		await get_tree().physics_frame
		x_max = maxf(x_max, volador.global_position.x)
	_caso("persiguiendo no atraviesa el pilar", x_max <= 1970.0 - 40.0 + 1.0)
	await _esperar(400)
	_caso("tras 600 ticks sin verlo lo olvida", not (comportamiento.get(&"persiguiendo") as bool))
	# Tope: persiguiendo desde arriba en el tramo abierto a la derecha del pilar, cae casi 900 px y llega al tope.
	volador.global_position = Vector2(2300.0, 150.0)
	volador.velocity = Vector2.ZERO
	_poner_jugador(Vector2(2150.0, 1040.0))
	comportamiento.call(&"despertar")
	var tope: float = 0.0
	for i: int in range(300):
		await get_tree().physics_frame
		tope = maxf(tope, maxf(absf(volador.velocity.x), absf(volador.velocity.y)))
	_caso("acelera hasta su tope por eje y no lo pasa", tope >= 200.0 and tope <= 217.01)
	_poner_jugador(Vector2(1450.0, 1040.0))


func _disparos() -> void:
	var escupidor: Enemigo = _sala.get_node(^"Escupidor") as Enemigo
	var comportamiento: Node = _comportamiento(escupidor)
	_poner_jugador(Vector2(2800.0, 1040.0))
	var bola: ProyectilEnemigo = null
	for i: int in range(60):
		await get_tree().physics_frame
		if (comportamiento.get(&"lanzados") as int) > 0:
			bola = comportamiento.get(&"ultimo") as ProyectilEnemigo
			break
	_caso("el escupidor avisa y lanza al verlo", bola != null and bola.se_puede_parar)
	# El jugador se aparta: la bola cae donde estaba.
	var objetivo: Vector2 = comportamiento.get(&"ultimo_objetivo") as Vector2
	_poner_jugador(Vector2(1450.0, 1040.0))
	var ultimo: Vector2 = Vector2.ZERO
	for i: int in range(180):
		if bola == null or not is_instance_valid(bola):
			break
		ultimo = bola.global_position
		await get_tree().physics_frame
	_caso("la bola en arco cae cerca de donde estaba el jugador", absf(ultimo.x - objetivo.x) < 100.0 and ultimo.y > 900.0)
	# Contra la pared derecha: se detiene en el solido.
	var contra_pared: ProyectilEnemigo = ProyectilEnemigo.crear_arco(Vector2(900.0, -300.0), 1800.0, 1, true)
	contra_pared.position = Vector2(3400.0, 800.0)
	_sala.add_child(contra_pared)
	var x_max: float = 0.0
	for i: int in range(60):
		if not is_instance_valid(contra_pared):
			break
		x_max = maxf(x_max, contra_pared.global_position.x)
		await get_tree().physics_frame
	_caso("el arco se detiene contra la pared", not is_instance_valid(contra_pared) and x_max <= 3560.0)
	# Parry de verdad: el ataque del jugador, mirando a la derecha, para un arco que tiene enfrente.
	_poner_jugador(Vector2(1450.0, 1040.0))
	await _presionar(&"mover_derecha")
	await _esperar(10)
	var desviados: int = _jugador.desviados
	var paradas: int = _jugador.paradas
	var vidas: int = _jugador.vidas
	var parable: ProyectilEnemigo = ProyectilEnemigo.crear_arco(Vector2.ZERO, 100.0, 1, true)
	parable.position = _jugador.global_position + Vector2(100.0, -80.0)
	_sala.add_child(parable)
	await _presionar(&"atacar")
	await _esperar(30)
	_caso("el ataque desvia el arco: desaparece sin quitar vida ni contar como parry", _jugador.desviados == desviados + 1 and _jugador.paradas == paradas and not is_instance_valid(parable) and _jugador.vidas == vidas)
	# Sin gravedad sigue recto, como los disparos de antes.
	var recto: ProyectilEnemigo = ProyectilEnemigo.crear_disparo(Vector2.LEFT, 1, true)
	recto.position = Vector2(2500.0, 400.0)
	_sala.add_child(recto)
	await _esperar(10)
	_caso("el disparo sin gravedad sigue recto", is_instance_valid(recto) and is_equal_approx(recto.global_position.y, 400.0) and recto.global_position.x < 2500.0)


# Simula el arco con el mismo paso del tick que ProyectilEnemigo y mira donde cruza la altura del objetivo bajando.
func _arco_atina(objetivo: Vector2) -> bool:
	var gravedad: float = 1800.0
	var velocidad: Vector2 = ProyectilEnemigo.velocidad_para(objetivo, 50.0, gravedad, 5000.0)
	var punto: Vector2 = Vector2.ZERO
	var delta: float = 1.0 / 60.0
	for i: int in range(600):
		velocidad.y += gravedad * delta
		punto += velocidad * delta
		if velocidad.y > 0.0 and punto.y >= objetivo.y:
			return absf(punto.x - objetivo.x) < 40.0
	return false


func _comportamiento(enemigo: Enemigo) -> Node:
	return enemigo.get_node(^"Comportamiento")


func _poner_jugador(punto: Vector2) -> void:
	_jugador.global_position = punto
	_jugador.velocity = Vector2.ZERO
