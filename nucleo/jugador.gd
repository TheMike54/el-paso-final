class_name Jugador
extends CharacterBody2D
# Jugador del nucleo: camina, salta, ataca, se cura y usa poderes con las acciones del InputMap,
# con toda su logica en _physics_process y las reglas de docs/contrato.md. Las habilidades solo
# funcionan si Partida las tiene. Cada valor se exporta para afinarlo en la zona de pruebas.
# Avisa al resto del juego por el bus Eventos.
const TAMANO: Vector2 = Vector2(80.0, 160.0)
const COLOR: Color = Color(0.85, 0.85, 0.9)
const COLOR_INVULNERABLE: Color = Color(0.85, 0.85, 0.9, 0.4)
const COLOR_MUERTO: Color = Color(0.15, 0.15, 0.2)
const COLOR_CURANDO: Color = Color(0.6, 0.9, 0.7)
const COLOR_DESCANSANDO: Color = Color(0.7, 0.75, 0.9)
## Alto del jugador sentado en un banco.
const ALTO_SENTADO: float = 110.0
const COLOR_ATAQUE: Color = Color(1.0, 0.9, 0.5, 0.5)
const NUNCA: int = 1000000
const ESCENA_PROYECTIL: PackedScene = preload("res://nucleo/proyectil.tscn")

@export_group("Movimiento")
## Velocidad al caminar, en px/s. Sin aceleracion: arranca y frena en el mismo tick.
@export var velocidad: float = 360.0
## Gravedad, en px/s^2.
@export var gravedad: float = 2400.0
## Altura maxima del salto manteniendo saltar, en px. El impulso se calcula a partir de ella.
@export var altura_salto: float = 200.0
## Al soltar saltar mientras sube, la velocidad vertical se multiplica por este factor.
@export_range(0.0, 1.0) var corte_salto: float = 0.4
## Ticks de subida antes de que soltar saltar corte el salto: un toque corto da un salto bajo, no nulo.
@export var ticks_minimos_salto: int = 4
## Ticks despues de salir de una orilla en que saltar todavia funciona.
@export var ticks_coyote: int = 3
## Ticks antes de aterrizar en que presionar saltar hace saltar al tocar el suelo.
@export var ticks_salto_en_cola: int = 3
## Tope de la velocidad de caida, en px/s, despues de los primeros distancia_caida_inicial px.
@export var velocidad_caida_max: float = 1200.0
## Tope de la velocidad al empezar a caer, en px/s: al principio se cae mas lento.
@export var velocidad_caida_inicial: float = 700.0
## Px de caida (desde la cima del salto o desde la orilla) con el tope velocidad_caida_inicial.
@export var distancia_caida_inicial: float = 240.0

@export_group("Combate")
## Ticks en que el area de ataque golpea despues de presionar atacar.
@export var ticks_ataque: int = 8
## Ticks entre un ataque y el siguiente, contados desde que empieza.
@export var ticks_entre_ataques: int = 20
## Dano de cada golpe del ataque.
@export var dano_ataque: int = 1
## Centro del area de ataque hacia abajo (pogo), relativo a los pies del jugador.
@export var posicion_pogo: Vector2 = Vector2(0.0, 50.0)
## Altura del rebote del pogo, en px.
@export var altura_pogo: float = 120.0
## Ticks sin recibir dano despues de un golpe.
@export var ticks_invulnerable: int = 60
## Ticks en que el retroceso manda sobre el movimiento horizontal.
@export var ticks_retroceso: int = 10
## Velocidad del retroceso al recibir dano: x, alejandose del origen del dano; y, hacia arriba.
@export var retroceso: Vector2 = Vector2(420.0, 420.0)
## Ticks seguidos en el suelo para que una posicion cuente como punto seguro tras un peligro.
@export var ticks_suelo_firme: int = 6
## Cuantas posiciones firmes atras se toma el punto seguro: aleja la reaparicion de la orilla.
@export var ticks_atras_punto_seguro: int = 15
## Ticks quieto tras volver al punto seguro por un peligro, antes de responder otra vez.
@export var ticks_reaparicion_peligro: int = 20

@export_group("Sensacion del golpe")
## Ticks que el jugador se detiene al recibir dano (hit-stop), antes del retroceso.
@export var ticks_hit_stop: int = 4
## Ticks en que el jugador sale empujado hacia atras al golpear algo.
@export var ticks_rebote_al_golpear: int = 4
## Velocidad de ese empuje, en px/s, alejandose de lo golpeado.
@export var velocidad_rebote_al_golpear: float = 240.0

@export_group("Curar")
## Inspiracion que cuesta curar una vida.
@export var costo_curacion: int = 33
## Ticks manteniendo curar para recuperar una vida. Soltar o recibir dano antes la pierde.
@export var ticks_curacion: int = 60
## Inspiracion que gana cada golpe a algo golpeable.
@export var inspiracion_por_golpe: int = 11

@export_group("Poderes")
## Ticks manteniendo curar a partir de los cuales es mantener (curar) y no un toque (lanzar el poder).
@export var ticks_mantener_poder: int = 10
## Inspiracion que cuesta cada poder (la bola, la caida en picada).
@export var costo_poder: int = 33
## Donde sale el proyectil, relativo a los pies del jugador cuando mira a la derecha.
@export var salida_proyectil: Vector2 = Vector2(60.0, -90.0)
## Ticks desde que sale una bola hasta poder lanzar otra. Un amuleto podria reducirlo.
@export var ticks_recarga_bola: int = 18

@export_group("Caida en picada")
## Velocidad de la caida en picada, en px/s; no tiene el tope de velocidad_caida_max.
@export var velocidad_picada: float = 1800.0
## Dano de la onda al aterrizar a cada Golpeable que toca.
@export var dano_picada: int = 3
## Tamano de la onda al aterrizar, centrada a lo ancho en los pies del jugador.
@export var onda_picada: Vector2 = Vector2(320.0, 120.0)
## Ticks sin recibir dano despues de aterrizar. Durante la picada tampoco se recibe.
@export var ticks_invulnerable_picada: int = 24
## Desde el suelo: altura del saltito antes de la picada, en px.
@export var altura_saltito_picada: float = 40.0
## Desde el suelo: ticks quieto en la cima del saltito antes de bajar.
@export var ticks_carga_picada: int = 15

@export_group("Impulso")
## Velocidad horizontal del impulso, en px/s.
@export var velocidad_impulso: float = 1200.0
## Ticks que dura el impulso, sin gravedad.
@export var ticks_impulso: int = 10
## Ticks desde que empieza un impulso hasta poder hacer otro.
@export var ticks_recarga_impulso: int = 36

@export_group("Pared")
## Velocidad maxima de caida sostenido en una pared, en px/s.
@export var velocidad_deslizar_pared: float = 150.0
## Velocidad horizontal con que el salto en pared despega de ella, en px/s.
@export var velocidad_despegue_pared: float = 420.0
## Ticks tras el salto en pared en que la entrada horizontal no manda.
@export var ticks_despegue_pared: int = 8
## Ticks despues de dejar de tocar la pared en que saltar todavia es un salto en pared.
@export var ticks_coyote_pared: int = 3

@export_group("Temblor al aterrizar")
## Ticks seguidos cayendo a velocidad_caida_max desde los que aterrizar es un aterrizaje duro (el
## mecanismo de Hollow Knight: tiempo cayendo, no velocidad ni altura). 18 = 0,3 s: con la caida de
## hoy, unos 794 px; con distancia_caida_inicial en 0, unos 650. La caida en picada tiembla siempre.
@export var ticks_caida_dura: int = 18
## Amplitud vertical inicial del temblor, en px; baja en linea recta hasta 0. Provisional y sin
## fuente: con 8 px casi no se veia en el telefono (07-oct-2026).
@export var temblor_px: float = 20.0
## Amplitud horizontal, en fraccion de temblor_px.
@export var temblor_fraccion_x: float = 1.0 / 3.0
## Ticks que dura el temblor (0,3 s). Provisional y sin fuente, como temblor_px.
@export var temblor_ticks: int = 18

@export_group("Aterrizaje duro")
## Ticks sin control tras un aterrizaje duro (el que hace temblar; no el de la picada). 21 = 0,35 s,
## sin fuente: el valor de Hollow Knight esta en sus recursos.
@export var ticks_aterrizaje_duro: int = 21

@export_group("Camara")
## Seguimiento horizontal: fraccion por segundo de lo que le falta a la camara (el mismo calculo
## que position_smoothing_speed de Camera2D).
@export var suavizado_camara_x: float = 8.0
## Seguimiento vertical, en s: amortiguado critico (como SmoothDamp de Unity). Cayendo a velocidad
## constante, la camara va tiempo_camara_y por detras; con menos, el frenado en el limite se nota.
@export var tiempo_camara_y: float = 0.15

## Vidas que le quedan; viven en Partida para sobrevivir al cambio de sala. A 0, muere.
var vidas: int:
	get:
		return Partida.vidas
	set(valor):
		Partida.vidas = valor
## Muerto: ya no responde a la entrada. La sala lo hace reaparecer (ver nucleo/sala.gd).
var muerto: bool = false
## Curando: lleva ticks_curados de ticks_curacion manteniendo curar.
var curando: bool = false
var ticks_curados: int = 0
## Sostenido en una pared, deslizando.
var en_pared: bool = false
## Rebotes del pogo desde que entro a la sala.
var rebotes_pogo: int = 0
## En caida en picada: cae recto y no responde a la entrada hasta tocar el suelo.
var en_picada: bool = false
## Toques del boton de poderes (soltar curar antes de ticks_mantener_poder) desde que entro a la sala.
var toques_poder: int = 0
## Sentado en un banco: quieto hasta que se mueve, salta o ataca.
var descansando: bool = false
## Golpes que dio la onda de la caida en picada desde que entro a la sala.
var golpes_onda: int = 0
## Desplazamiento vertical del temblor en este tick, en px. La camara lo recibe solo con el ajuste
## temblor encendido; publico para que un guion lo lea aunque el ajuste este apagado.
var temblor_y: float = 0.0
## Desplazamiento horizontal del temblor en este tick, en px; como temblor_y.
var temblor_x: float = 0.0
## Quieto y sin control tras un aterrizaje duro (ver ticks_aterrizaje_duro).
var aterrizando: bool:
	get:
		return _ticks_aterrizando > 0
## No recibe dano: tras un golpe, durante la picada (con su saltito y su carga) y justo despues.
var invulnerable: bool:
	get:
		return _ticks_sin_dano > 0 or en_picada or _preparando_picada

@onready var _camara: Camera2D = $Camara as Camera2D
@onready var _ataque: Area2D = $Ataque as Area2D
@onready var _forma_ataque: CollisionShape2D = $Ataque/Forma as CollisionShape2D

var _ticks_sin_suelo: int = NUNCA
var _ticks_desde_pulsar: int = NUNCA
var _subiendo: bool = false
var _ticks_subiendo: int = 0
var _cortado: bool = false
var _mirando: float = 1.0
var _ticks_atacando: int = 0
var _ticks_hasta_ataque: int = 0
var _golpeados: Array[Golpeable] = []
var _ticks_sin_dano: int = 0
var _ticks_retrocediendo: int = 0
var _sentido_retroceso: float = 0.0
var _ticks_rebote: int = 0
var _sentido_rebote: float = 0.0
var _ticks_en_suelo: int = 0
var _puntos_seguros: PackedVector2Array = []
var _ticks_congelado: int = 0
var _inspiracion_al_empezar: int = 0
var _ticks_impulsando: int = 0
var _ticks_hasta_impulso: int = 0
var _impulso_en_el_aire: bool = true
var _doble_salto_disponible: bool = true
var _ticks_despegando: int = 0
var _sentido_despegue: float = 0.0
# Ticks que lleva presionado curar; -1 si no hay una pulsacion que cuente.
var _ticks_poder: int = -1
# Ataque hacia abajo (pogo) en curso, y si ya reboto en este ataque.
var _atacando_abajo: bool = false
var _rebotado: bool = false
# Centro del area de ataque de la escena, mirando a la derecha.
var _posicion_ataque: Vector2 = Vector2.ZERO
# Caida en curso (velocity.y >= 0 en el aire) y la y donde empezo, para el tope inicial.
var _cayendo: bool = false
var _y_inicio_caida: float = 0.0
var _ticks_hasta_bola: int = 0
# Recien sentado: el primer tick sentado no se levanta (joystick en diagonal da arriba y un lado juntos).
var _recien_sentado: bool = false
# Picada desde el suelo: el saltito y los ticks de carga en su cima.
var _preparando_picada: bool = false
var _ticks_carga: int = 0
# Ticks desde que estuvo contra una pared por ultima vez, y la normal de esa pared.
var _ticks_sin_pared: int = NUNCA
var _normal_pared: float = 0.0
# Temblor al aterrizar: ticks que le quedan, si estaba en el suelo el tick anterior y la ultima
# velocidad vertical que tuvo en el aire (al aterrizar, move_and_slide ya la dejo en 0).
var _ticks_temblando: int = 0
var _en_suelo_antes: bool = true
# Ticks seguidos cayendo a velocidad_caida_max.
var _ticks_a_tope: int = 0
var _ticks_aterrizando: int = 0
# Camara: limites de la sala, altura sobre los pies y velocidad vertical del suavizado.
var _limites: Rect2 = Rect2(-10000000.0, -10000000.0, 20000000.0, 20000000.0)
var _altura_camara: Vector2 = Vector2.ZERO
var _velocidad_camara_y: float = 0.0


func _ready() -> void:
	# La camara se mueve a mano (_seguir_con_camara): deja de heredar la posicion del jugador.
	_altura_camara = _camara.position
	_camara.top_level = true
	_colocar_camara()
	# El temblor lee Ajustes.temblor cada tick: no depende de que la pausa o la vibracion lo carguen antes.
	Ajustes.cargar_una_vez()
	_ataque.monitoring = false
	_posicion_ataque = _forma_ataque.position
	_puntos_seguros = [global_position]


func _physics_process(delta: float) -> void:
	_mover(delta)
	_seguir_con_camara(delta)


func _mover(delta: float) -> void:
	var en_suelo: bool = is_on_floor()
	_aterrizar(en_suelo)
	if _ticks_congelado > 0:
		_ticks_congelado -= 1
		return
	_caer(en_suelo, delta)
	if muerto:
		velocity.x = 0.0
		move_and_slide()
		return
	if descansando:
		_seguir_descansando()
		return
	_recordar_punto_seguro(en_suelo)

	_ticks_sin_suelo = 0 if en_suelo else mini(_ticks_sin_suelo + 1, NUNCA)
	if Input.is_action_just_pressed(&"saltar"):
		_ticks_desde_pulsar = 0
	else:
		_ticks_desde_pulsar = mini(_ticks_desde_pulsar + 1, NUNCA)
	_ticks_sin_dano = maxi(_ticks_sin_dano - 1, 0)
	_ticks_hasta_impulso = maxi(_ticks_hasta_impulso - 1, 0)
	_ticks_hasta_bola = maxi(_ticks_hasta_bola - 1, 0)
	if en_suelo:
		_impulso_en_el_aire = true
		_doble_salto_disponible = true
	if _ticks_aterrizando > 0:
		_seguir_aterrizando()
		return
	if _preparando_picada:
		_seguir_preparando_picada()
		return
	if en_picada:
		_seguir_picada()
		return

	if _boton_poderes(en_suelo):
		velocity.x = 0.0
		move_and_slide()
		return

	var eje: float = Input.get_axis(&"mover_izquierda", &"mover_derecha")
	_mover_en_horizontal(eje)
	_saltos(en_suelo, eje)
	_impulsar()
	_atacar()
	move_and_slide()


# Aterrizaje: se mira al empezar el tick, tras el move_and_slide del anterior. Es duro (tiembla la
# camara y deja sin control) si venia de ticks_caida_dura ticks cayendo a velocidad_caida_max.
# El contador se reinicia en el suelo y con cualquier velocidad menor al tope (pared, pogo, impulso,
# retroceso). Romper un suelo fragil en la picada no es aterrizar: sigue en_picada hasta el suelo.
func _aterrizar(en_suelo: bool) -> void:
	# La picada no pasa por aqui: tiembla y avisa en _seguir_picada, solo al aterrizar de verdad (romper
	# un suelo fragil tambien deja en_suelo un tick, y una picada puede tocar el suelo en su primer tick).
	if en_suelo and not _en_suelo_antes and not en_picada and _ticks_a_tope >= ticks_caida_dura:
		_ticks_temblando = maxi(_ticks_temblando, temblor_ticks)
		# Un golpe o un banco del mismo tick se procesan antes que el jugador: si ya lo empujaron o lo
		# sentaron, no hay bloqueo (si no, el retroceso esperaria 21 ticks o se levantaria sin control).
		if not muerto and not descansando and _ticks_retrocediendo == 0:
			_empezar_aterrizaje_duro()
			Eventos.jugador_aterrizo.emit(velocidad_caida_max)
	if en_suelo or en_picada or velocity.y < velocidad_caida_max:
		_ticks_a_tope = 0
	else:
		_ticks_a_tope += 1
	_en_suelo_antes = en_suelo
	_temblar()


# Aterrizaje duro, como en Hollow Knight: corta lo que estaba haciendo y deja al jugador quieto
# ticks_aterrizaje_duro ticks. Lo cancelan un golpe, un peligro, morir y sentarse.
func _empezar_aterrizaje_duro() -> void:
	_cortar_lo_que_empuja()
	_cortar_curacion()
	_ticks_poder = -1
	velocity.x = 0.0
	_ticks_aterrizando = ticks_aterrizaje_duro


# Sin control: la gravedad (en _caer) y los golpes siguen. Las pulsaciones de saltar, atacar y curar
# hechas durante el bloqueo se pierden (no quedan en la cola al terminar); lo que se mantiene
# presionado (caminar) vuelve a contar en cuanto termina.
func _seguir_aterrizando() -> void:
	_ticks_aterrizando -= 1
	_ticks_desde_pulsar = NUNCA
	_ticks_poder = -1
	velocity.x = 0.0
	move_and_slide()


# Temblor de la camara: patron fijo, sin azar, y la amplitud baja en linea recta. En vertical el signo
# cambia cada 2 ticks; en horizontal, cada 3 y con un tercio de la amplitud: con periodos distintos
# el punto no da vueltas en circulo. Aterrizar otra vez lo reinicia, no lo suma.
func _temblar() -> void:
	temblor_x = 0.0
	temblor_y = 0.0
	if _ticks_temblando > 0 and temblor_ticks > 0:
		var transcurridos: int = temblor_ticks - _ticks_temblando
		var queda: float = temblor_px * float(_ticks_temblando) / float(temblor_ticks)
		temblor_y = queda if (transcurridos / 2) % 2 == 0 else -queda
		temblor_x = queda * temblor_fraccion_x * (1.0 if (transcurridos / 3) % 2 == 0 else -1.0)
		_ticks_temblando -= 1
	_camara.offset = Vector2(temblor_x, temblor_y) if Ajustes.temblor else Vector2.ZERO


# Gravedad. Al empezar a caer el tope es velocidad_caida_inicial; pasados distancia_caida_inicial
# px, velocidad_caida_max: al principio se cae mas lento y despues mas rapido. Sin gravedad durante
# el impulso, la picada y la carga de la picada.
func _caer(en_suelo: bool, delta: float) -> void:
	if en_suelo or velocity.y < 0.0:
		_cayendo = false
	elif not _cayendo:
		_cayendo = true
		_y_inicio_caida = position.y
	if en_suelo or _ticks_impulsando > 0 or en_picada or _ticks_carga > 0:
		return
	var tope: float = velocidad_caida_max
	if _cayendo and position.y - _y_inicio_caida < distancia_caida_inicial:
		tope = velocidad_caida_inicial
	# Si ya iba mas rapido que el tope (un retroceso, un tope cambiado), no se frena de golpe.
	velocity.y = minf(velocity.y + gravedad * delta, maxf(tope, velocity.y))


# Prioridad del movimiento horizontal: retroceso del golpe recibido, impulso, despegue de la
# pared, rebote al golpear y por ultimo la entrada.
func _mover_en_horizontal(eje: float) -> void:
	if _ticks_retrocediendo > 0:
		_ticks_retrocediendo -= 1
		velocity.x = _sentido_retroceso * retroceso.x
	elif _ticks_impulsando > 0:
		_ticks_impulsando -= 1
		velocity.x = _mirando * velocidad_impulso
		velocity.y = 0.0
	elif _ticks_despegando > 0:
		_ticks_despegando -= 1
		velocity.x = _sentido_despegue * velocidad_despegue_pared
	elif _ticks_rebote > 0:
		_ticks_rebote -= 1
		velocity.x = _sentido_rebote * velocidad_rebote_al_golpear
	else:
		velocity.x = eje * velocidad
		if eje != 0.0:
			_mirando = signf(eje)


func _saltos(en_suelo: bool, eje: float) -> void:
	# Contra la pared: en el aire, tocandola y empujando hacia ella (salto_en_pared), suba o baje.
	# Sostenido (deslizando) solo al caer. Saltar sale aunque se haya dejado de tocar hace poco.
	var normal: float = get_wall_normal().x if is_on_wall() else 0.0
	var contra_pared: bool = Partida.tiene(&"salto_en_pared") and not en_suelo and normal != 0.0 \
			and signf(eje) == -normal and _ticks_impulsando == 0
	if contra_pared:
		_ticks_sin_pared = 0
		_normal_pared = normal
		_impulso_en_el_aire = true
		_doble_salto_disponible = true
	else:
		_ticks_sin_pared = mini(_ticks_sin_pared + 1, NUNCA)
	en_pared = contra_pared and velocity.y >= 0.0
	var quiere_saltar: bool = _ticks_desde_pulsar <= ticks_salto_en_cola
	# Durante el retroceso no se salta: el golpe manda, y el tick siguiente al golpe el jugador
	# todavia cuenta como en el suelo, lo que abriria el tiempo coyote.
	if _ticks_retrocediendo > 0 or _ticks_impulsando > 0 or not quiere_saltar:
		if _subiendo:
			_seguir_subiendo()
	elif _ticks_sin_suelo <= ticks_coyote:
		_saltar()
	elif not en_suelo and _ticks_sin_pared <= ticks_coyote_pared:
		_saltar()
		_ticks_despegando = ticks_despegue_pared
		_sentido_despegue = _normal_pared
		_mirando = _normal_pared
		_ticks_sin_pared = NUNCA
		en_pared = false
	elif Partida.tiene(&"doble_salto") and _doble_salto_disponible and _ticks_desde_pulsar == 0:
		_doble_salto_disponible = false
		_saltar()
	elif _subiendo:
		_seguir_subiendo()
	if en_pared:
		velocity.y = minf(velocity.y, velocidad_deslizar_pared)


func _saltar() -> void:
	velocity.y = -sqrt(2.0 * gravedad * altura_salto)
	_subiendo = true
	_ticks_subiendo = 0
	_cortado = false
	# Gasta la pulsacion y el suelo: ni el salto en cola ni el coyote dan un segundo salto.
	_ticks_desde_pulsar = NUNCA
	_ticks_sin_suelo = NUNCA


# Salto variable: soltar saltar corta la subida, pero no antes de ticks_minimos_salto.
func _seguir_subiendo() -> void:
	_ticks_subiendo += 1
	if velocity.y >= 0.0:
		_subiendo = false
	elif not _cortado and _ticks_subiendo >= ticks_minimos_salto and not Input.is_action_pressed(&"saltar"):
		velocity.y *= corte_salto
		_cortado = true


# Impulso (habilidad impulso): hacia donde mira, sin gravedad unos ticks; uno por salto en el aire.
func _impulsar() -> void:
	if not Partida.tiene(&"impulso") or not Input.is_action_just_pressed(&"impulso"):
		return
	if _ticks_hasta_impulso > 0 or _ticks_retrocediendo > 0 or not _impulso_en_el_aire:
		return
	_ticks_impulsando = ticks_impulso
	_ticks_hasta_impulso = ticks_recarga_impulso
	_subiendo = false
	velocity.y = 0.0
	if not is_on_floor():
		_impulso_en_el_aire = false


# Boton de poderes (curar), como en Hollow Knight: soltarlo antes de ticks_mantener_poder es un
# toque y lanza el poder; mantenerlo hasta ese tick empieza la curacion. Una pulsacion que empieza
# durante el impulso o el retroceso no cuenta. Devuelve si el jugador se esta curando (y por eso
# no se mueve este tick).
func _boton_poderes(en_suelo: bool) -> bool:
	var mantiene: bool = Input.is_action_pressed(&"curar")
	if Input.is_action_just_pressed(&"curar"):
		_ticks_poder = 0 if _ticks_retrocediendo == 0 and _ticks_impulsando == 0 else -1
		# Con abajo, la caida en picada sale en el tick de la pulsacion, sin esperar al toque: en el
		# aire baja enseguida; en el suelo, primero un saltito.
		if _ticks_poder == 0 and Input.is_action_pressed(&"mover_abajo") and _puede_picar():
			_ticks_poder = -1
			Partida.inspiracion -= costo_poder
			if en_suelo:
				_preparar_picada()
			else:
				_empezar_picada()
			return true
	elif _ticks_poder >= 0:
		if not mantiene:
			_ticks_poder = -1
			toques_poder += 1
			_lanzar_poder()
		else:
			_ticks_poder += 1
			if _ticks_poder >= ticks_mantener_poder:
				_ticks_poder = -1
				_empezar_curacion(en_suelo)
	return curando and _seguir_curando(en_suelo, mantiene)


func _puede_picar() -> bool:
	return Partida.tiene(&"caida_en_picada") and Partida.inspiracion >= costo_poder


# Picada desde el suelo: un saltito de altura_saltito_picada, ticks_carga_picada quieto en su cima y
# despues la picada. Sin control y sin recibir dano desde el saltito.
func _preparar_picada() -> void:
	_cortar_lo_que_empuja()
	_preparando_picada = true
	_ticks_carga = 0
	velocity = Vector2(0.0, -sqrt(2.0 * gravedad * altura_saltito_picada))
	_ticks_sin_suelo = NUNCA


func _seguir_preparando_picada() -> void:
	if _ticks_carga > 0:
		_ticks_carga -= 1
		velocity = Vector2.ZERO
		if _ticks_carga == 0:
			_preparando_picada = false
			_empezar_picada()
		return
	velocity.x = 0.0
	move_and_slide()
	if velocity.y >= 0.0:
		_ticks_carga = ticks_carga_picada


# Caida en picada (habilidad caida_en_picada; la Inspiracion ya se cobro): recta hacia abajo a
# velocidad_picada, sin control ni tope de caida y sin recibir dano, hasta tocar el suelo. Un
# SueloFragil que toca se rompe y la caida sigue. Al aterrizar, la onda dana lo que esta cerca.
func _empezar_picada() -> void:
	en_picada = true
	_cortar_lo_que_empuja()
	velocity = Vector2(0.0, velocidad_picada)


# Antes de la picada o de sentarse: un ataque a medias se corta (si no, quedaria pausado y seguiria
# despues) y nada de lo que empujaba al jugador sigue.
func _cortar_lo_que_empuja() -> void:
	_subiendo = false
	_ticks_atacando = 0
	_atacando_abajo = false
	_ataque.set_deferred(&"monitoring", false)
	_ticks_impulsando = 0
	_ticks_despegando = 0
	_ticks_rebote = 0


func _seguir_picada() -> void:
	velocity = Vector2(0.0, velocidad_picada)
	move_and_slide()
	var rompio: bool = false
	for i: int in range(get_slide_collision_count()):
		var fragil: SueloFragil = get_slide_collision(i).get_collider() as SueloFragil
		# Uno ya roto cuenta como suelo: asi la picada no se queda atorada si tarda en desaparecer.
		if fragil != null and not fragil.roto:
			fragil.romper()
			rompio = true
	if is_on_floor() and not rompio:
		en_picada = false
		# La picada tiembla siempre al aterrizar, sin importar la altura, y no deja sin control.
		_ticks_temblando = maxi(_ticks_temblando, temblor_ticks)
		velocity = Vector2.ZERO
		_ticks_sin_dano = maxi(_ticks_sin_dano, ticks_invulnerable_picada)
		# Antes de la onda: si la onda golpea, la vibracion del aterrizaje (la fuerte) llega primero.
		Eventos.jugador_aterrizo.emit(velocidad_picada)
		_onda()


# La onda de la picada: golpea una vez a cada Golpeable dentro de onda_picada, sin dar Inspiracion.
func _onda() -> void:
	var forma: RectangleShape2D = RectangleShape2D.new()
	forma.size = onda_picada
	var consulta: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	consulta.shape = forma
	consulta.transform = Transform2D(0.0, global_position + Vector2(0.0, -onda_picada.y / 2.0))
	consulta.collide_with_areas = true
	consulta.collide_with_bodies = false
	for choque: Dictionary in get_world_2d().direct_space_state.intersect_shape(consulta):
		var golpeable: Golpeable = choque["collider"] as Golpeable
		if golpeable != null:
			golpeable.recibir_golpe(self, dano_picada)
			golpes_onda += 1


# Toque del boton de poderes: con la habilidad proyectil y Inspiracion, lanza la bola hacia donde
# mira, en el suelo o en el aire. Se agrega a la sala en diferido, fuera del paso de la fisica.
func _lanzar_poder() -> void:
	if not Partida.tiene(&"proyectil") or Partida.inspiracion < costo_poder or _ticks_hasta_bola > 0:
		return
	Partida.inspiracion -= costo_poder
	_ticks_hasta_bola = ticks_recarga_bola
	var salida: Vector2 = position + Vector2(salida_proyectil.x * _mirando, salida_proyectil.y)
	# Pegado a una pared, la salida queda dentro de ella y el rayo de la bola no la veria: se revisa
	# el camino desde el jugador. Si hay un solido, la bola se deshace ahi (el costo ya se pago).
	var desde: Vector2 = global_position + Vector2(0.0, salida_proyectil.y)
	var hasta: Vector2 = global_position + Vector2(salida_proyectil.x * _mirando + _mirando * Proyectil.TAMANO.x / 2.0, salida_proyectil.y)
	var consulta: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(desde, hasta)
	consulta.exclude = [get_rid()]
	if not get_world_2d().direct_space_state.intersect_ray(consulta).is_empty():
		return
	var bola: Proyectil = ESCENA_PROYECTIL.instantiate() as Proyectil
	bola.sentido = _mirando
	bola.lanzador = self
	bola.position = salida
	get_parent().add_child.call_deferred(bola)


# Curar: en el suelo, con vidas por llenar, Inspiracion suficiente y fuera del retroceso y del
# impulso. La Inspiracion se gasta poco a poco: soltar o recibir un golpe antes de terminar pierde
# lo gastado.
func _empezar_curacion(en_suelo: bool) -> void:
	var puede: bool = en_suelo and vidas < Partida.vidas_maximas and Partida.inspiracion >= costo_curacion
	if not puede or _ticks_retrocediendo > 0 or _ticks_impulsando > 0:
		return
	curando = true
	ticks_curados = 0
	_inspiracion_al_empezar = Partida.inspiracion
	# Quieto mientras se cura: nada de lo que empujaba al jugador sigue despues.
	_ticks_despegando = 0
	_ticks_rebote = 0


func _seguir_curando(en_suelo: bool, mantiene: bool) -> bool:
	if not mantiene or not en_suelo:
		_cortar_curacion()
		return false
	ticks_curados += 1
	Partida.inspiracion = _inspiracion_al_empezar - floori(float(costo_curacion) * ticks_curados / ticks_curacion)
	if ticks_curados >= ticks_curacion:
		Partida.inspiracion = _inspiracion_al_empezar - costo_curacion
		vidas = mini(vidas + 1, Partida.vidas_maximas)
		curando = false
		Eventos.jugador_curado.emit(vidas)
	return true


func _cortar_curacion() -> void:
	curando = false
	ticks_curados = 0


# El area de ataque se enciende unos ticks hacia donde mira el jugador y golpea una sola vez a
# cada Golpeable que toca durante ese ataque. Cada golpe da Inspiracion y empuja al jugador. En el
# aire con mover_abajo, el ataque va hacia abajo (pogo): ver _rebotar_pogo.
func _atacar() -> void:
	_ticks_hasta_ataque = maxi(_ticks_hasta_ataque - 1, 0)
	if Input.is_action_just_pressed(&"atacar") and _ticks_hasta_ataque == 0:
		_ticks_atacando = ticks_ataque
		_ticks_hasta_ataque = ticks_entre_ataques
		_golpeados.clear()
		_atacando_abajo = not is_on_floor() and Input.is_action_pressed(&"mover_abajo")
		_rebotado = false
		if _atacando_abajo:
			_forma_ataque.position = posicion_pogo
		else:
			_forma_ataque.position = Vector2(absf(_posicion_ataque.x) * _mirando, _posicion_ataque.y)
		_ataque.set_deferred(&"monitoring", true)
	if _ticks_atacando == 0:
		return
	_ticks_atacando -= 1
	# monitoring se enciende en diferido: el primer tick del ataque todavia no ve nada.
	if _ataque.monitoring:
		for area: Area2D in _ataque.get_overlapping_areas():
			var golpeable: Golpeable = area as Golpeable
			if golpeable != null and not _golpeados.has(golpeable):
				_golpeados.append(golpeable)
				golpeable.recibir_golpe(self, dano_ataque)
				Partida.ganar_inspiracion(inspiracion_por_golpe)
				if _atacando_abajo:
					_rebotar_pogo()
				else:
					_ticks_rebote = ticks_rebote_al_golpear
					_sentido_rebote = -_mirando
			elif _atacando_abajo:
				var contacto: DanoContacto = area as DanoContacto
				if contacto != null and contacto.peligro:
					_rebotar_pogo()
	if _ticks_atacando == 0:
		_ataque.set_deferred(&"monitoring", false)


# Pogo: el golpe hacia abajo a un Golpeable o a un peligro lanza al jugador hacia arriba (una vez por
# ataque) y le devuelve el doble salto y el impulso en el aire. Soltar saltar no corta el rebote.
func _rebotar_pogo() -> void:
	if _rebotado:
		return
	_rebotado = true
	velocity.y = -sqrt(2.0 * gravedad * altura_pogo)
	_subiendo = false
	_ticks_sin_suelo = NUNCA
	_impulso_en_el_aire = true
	_doble_salto_disponible = true
	rebotes_pogo += 1


## Lo llama lo que dana al jugador. origen_x: de donde viene el golpe, para el retroceso.
## peligro: pinchos, acido, fosas. Quita vidas y lleva al ultimo punto seguro, sin retroceso.
func recibir_dano(dano: int, origen_x: float, peligro: bool = false) -> void:
	if muerto:
		return
	if invulnerable:
		# Invulnerable no pierde vidas, pero un peligro igual lo saca de ahi.
		if peligro:
			_volver_al_punto_seguro()
		return
	vidas = maxi(vidas - dano, 0)
	_ticks_aterrizando = 0
	_cortar_curacion()
	# Un golpe tambien pierde la pulsacion de curar a medias (ni toque ni curacion) y levanta del banco.
	_ticks_poder = -1
	descansando = false
	_ticks_impulsando = 0
	_ticks_despegando = 0
	_ticks_rebote = 0
	Eventos.jugador_danado.emit(vidas)
	if vidas == 0:
		_morir()
		return
	_ticks_sin_dano = ticks_invulnerable
	if peligro:
		_volver_al_punto_seguro()
		return
	_ticks_congelado = maxi(_ticks_congelado, ticks_hit_stop)
	_ticks_retrocediendo = ticks_retroceso
	var lado: float = signf(global_position.x - origen_x)
	_sentido_retroceso = lado if lado != 0.0 else -_mirando
	velocity.y = -retroceso.y
	_subiendo = false


func _morir() -> void:
	muerto = true
	_ticks_aterrizando = 0
	_ticks_atacando = 0
	_ticks_sin_dano = 0
	_ataque.set_deferred(&"monitoring", false)
	Eventos.jugador_muerto.emit()


# Puntos seguros: posiciones con ticks_suelo_firme ticks seguidos en el suelo, fuera de la
# invulnerabilidad (asi no cuenta un suelo con pinchos que se piso sin recibir dano). Se vuelve a
# la mas vieja de las ultimas ticks_atras_punto_seguro: un poco antes de la orilla, no en ella.
func _recordar_punto_seguro(en_suelo: bool) -> void:
	_ticks_en_suelo = _ticks_en_suelo + 1 if en_suelo else 0
	if _ticks_en_suelo >= ticks_suelo_firme and _ticks_sin_dano == 0:
		_puntos_seguros.append(global_position)
		if _puntos_seguros.size() > ticks_atras_punto_seguro:
			_puntos_seguros.remove_at(0)


func _volver_al_punto_seguro() -> void:
	global_position = _puntos_seguros[0]
	velocity = Vector2.ZERO
	en_picada = false
	_preparando_picada = false
	_ticks_carga = 0
	descansando = false
	# Ni una pulsacion de curar a medias: soltarla congelado contaria como toque.
	_ticks_poder = -1
	_subiendo = false
	_ticks_retrocediendo = 0
	_ticks_impulsando = 0
	_ticks_despegando = 0
	_ticks_rebote = 0
	_ticks_en_suelo = 0
	# Una pulsacion de saltar justo antes del peligro no debe hacer saltar al reaparecer.
	_ticks_desde_pulsar = NUNCA
	_ticks_sin_suelo = NUNCA
	_ticks_sin_pared = NUNCA
	_ticks_congelado = ticks_reaparicion_peligro
	# Reaparecer no tiembla ni deja la camara movida.
	_ticks_temblando = 0
	_en_suelo_antes = true
	_ticks_a_tope = 0
	_ticks_aterrizando = 0
	temblor_x = 0.0
	temblor_y = 0.0
	_camara.offset = Vector2.ZERO
	_colocar_camara()


## Lo llama el banco al descansar: el jugador se acomoda sobre el (en su x) y se queda sentado.
func sentarse(x: float) -> void:
	_cortar_lo_que_empuja()
	_cortar_curacion()
	_ticks_poder = -1
	# Ni el hit-stop ni el retroceso de un golpe justo antes siguen al levantarse.
	_ticks_retrocediendo = 0
	_ticks_congelado = 0
	_ticks_aterrizando = 0
	descansando = true
	_recien_sentado = true
	global_position.x = x
	velocity = Vector2.ZERO


# Sentado: quieto hasta que se mueve, salta o ataca. Levantarse no hace saltar ni atacar: esto
# corre antes de leer saltar y atacar, y en el tick siguiente la pulsacion ya no es nueva.
func _seguir_descansando() -> void:
	if _recien_sentado:
		_recien_sentado = false
		velocity.x = 0.0
		move_and_slide()
		return
	for accion: StringName in [&"mover_izquierda", &"mover_derecha", &"mover_abajo", &"saltar", &"atacar"]:
		if Input.is_action_just_pressed(accion):
			descansando = false
	if descansando:
		velocity.x = 0.0
		move_and_slide()


# La sala le pasa sus limites: la camara sigue al jugador sin mostrar nada fuera de ellos.
func fijar_limites(limites: Rect2) -> void:
	_limites = limites
	_camara.limit_left = floori(limites.position.x)
	_camara.limit_top = floori(limites.position.y)
	_camara.limit_right = ceili(limites.end.x)
	_camara.limit_bottom = ceili(limites.end.y)
	_colocar_camara()


# Seguimiento a mano, como Hollow Knight: el objetivo se recorta a los limites ANTES de suavizar, asi
# la camara se frena sola al acercarse al borde en vez de chocar con el limite. En Y el suavizado es
# de segundo orden: su velocidad no cambia de golpe cuando el objetivo se detiene. Corre en todos los
# ticks, tambien congelado, muerto o sentado. Los limit_* de la Camera2D quedan como seguro.
func _seguir_con_camara(delta: float) -> void:
	var objetivo: Vector2 = _objetivo_camara()
	var actual: Vector2 = _camara.global_position
	actual.x += (objetivo.x - actual.x) * minf(suavizado_camara_x * delta, 1.0)
	actual.y = _amortiguar_y(actual.y, objetivo.y, delta)
	_camara.global_position = actual


# Pone la camara en su objetivo, sin suavizado: al entrar a la sala y al reaparecer.
func _colocar_camara() -> void:
	_camara.global_position = _objetivo_camara()
	_velocidad_camara_y = 0.0
	_camara.reset_smoothing()


# Centro de la camara al que se quiere llegar: sobre el jugador, recortado para que la vista no salga
# de la sala. Si la vista es mayor que la sala en un eje, se centra en ese eje, como hace Camera2D con
# sus limites (medido el 07-oct-2026); si no, el recorte con los bordes invertidos daria otro punto.
func _objetivo_camara() -> Vector2:
	var media: Vector2 = get_viewport_rect().size / _camara.zoom / 2.0
	var centro: Vector2 = _limites.get_center()
	var objetivo: Vector2 = global_position + _altura_camara
	if _limites.size.x <= media.x * 2.0:
		objetivo.x = centro.x
	else:
		objetivo.x = clampf(objetivo.x, _limites.position.x + media.x, _limites.end.x - media.x)
	if _limites.size.y <= media.y * 2.0:
		objetivo.y = centro.y
	else:
		objetivo.y = clampf(objetivo.y, _limites.position.y + media.y, _limites.end.y - media.y)
	return objetivo


# Amortiguado critico hacia el objetivo (la formula de SmoothDamp de Unity, sin tope de velocidad).
func _amortiguar_y(actual: float, objetivo: float, delta: float) -> float:
	var omega: float = 2.0 / maxf(tiempo_camara_y, 0.0001)
	var x: float = omega * delta
	var factor: float = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var diferencia: float = actual - objetivo
	var empuje: float = (_velocidad_camara_y + omega * diferencia) * delta
	_velocidad_camara_y = (_velocidad_camara_y - omega * empuje) * factor
	var nuevo: float = objetivo + (diferencia + empuje) * factor
	# No se pasa del objetivo.
	if (objetivo - actual > 0.0) == (nuevo > objetivo):
		nuevo = objetivo
		_velocidad_camara_y = 0.0
	return nuevo


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var cuerpo: Rect2 = Rect2(-TAMANO.x / 2.0, -TAMANO.y, TAMANO.x, TAMANO.y)
	var color: Color = COLOR
	if descansando:
		cuerpo = Rect2(-TAMANO.x / 2.0, -ALTO_SENTADO, TAMANO.x, ALTO_SENTADO)
		color = COLOR_DESCANSANDO
	if muerto:
		color = COLOR_MUERTO
	elif _ticks_sin_dano > 0:
		color = COLOR_INVULNERABLE
	elif curando:
		color = COLOR_CURANDO
	draw_rect(cuerpo, color)
	if _ticks_atacando > 0:
		var forma: RectangleShape2D = _forma_ataque.shape as RectangleShape2D
		draw_rect(Rect2(_forma_ataque.position - forma.size / 2.0, forma.size), COLOR_ATAQUE)
