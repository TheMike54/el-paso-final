class_name Jugador
extends CharacterBody2D
# Jugador del nucleo: camina, salta, ataca, se cura y usa poderes con las acciones del InputMap,
# con toda su logica en _physics_process y las reglas de docs/jugador.md. Las habilidades solo
# funcionan si Partida las tiene. Cada valor se exporta para afinarlo en la zona de pruebas.
# Avisa al resto del juego por el bus Eventos.
## Grupo del cuerpo que controla la persona. Lo pone cada escena en groups; quien lo busca usa
## get_first_node_in_group(GRUPO).
const GRUPO: StringName = &"jugador"
const TAMANO: Vector2 = Vector2(80.0, 160.0)
## Cuerpo: el nodo Dibujo (AnimatedSprite2D) con nucleo/arte/jugador_hombre/jugador_hombre.tres; la animacion la
## elige AnimacionJugador. Invulnerable parpadea (alfa PARPADEO cada TICKS_PARPADEO ticks, como el
## InvulnerablePulse de Hollow Knight); unos ticks tras un parry se pone blanco con el shader
## nucleo/arte/destello.gdshader (Compatibility satura el color en 1: un modulate mayor no aclara).
const PARPADEO: float = 0.35
const TICKS_PARPADEO: int = 4
## El golpe se ve solo con su trazo blanco (TrazoAtaque; el area, con «Ver hitbox»: decidido por la persona el
## 25-oct-2026). El parry deja un destello de luz (EfectoCuadros con nucleo/arte/efecto_parry.png, 0,2 s, que corre
## durante el congelado) en la punta de la espada, como Hollow Knight y Silksong; el cuerpo queda en blanco
## TICKS_DESTELLO_PARRY ticks (0,1 s, contados tambien congelado).
const HOJA_PARRY: Texture2D = preload("res://nucleo/arte/efecto_parry.png")
const CUADROS_PARRY: int = 4
const TICKS_DESTELLO_PARRY: int = 6
## Punta de la espada en el cuadro que golpea de lado, respecto de los pies y mirando a la derecha (medida en el atlas
## del jugador). Arriba y abajo la espada del dibujo no llega al punto del golpe: ahi el destello va entre el area de
## golpe y el ataque parado.
const PUNTA_ESPADA_LADO: Vector2 = Vector2(122.0, -117.0)
## Cuadro de los clips de ataque en que la espada golpea (el de PUNTA_ESPADA_LADO).
const CUADRO_GOLPE: int = 1
## Chispa de un disparo desviado: el mismo destello a la mitad, sin congelado ni cuerpo en blanco (como los disparos
## de Silksong, que chocan con el aguijon en su version ligera, noClashFreeze).
const ESCALA_CHISPA: float = 0.5
## Curar: el aura en capas detras del jugador y sus rayas y chispas delante (nucleo/arte/efecto_curar*.png, 320x420,
## los pies del cuadro 185 px bajo su centro), mas una luz falsa: un halo aditivo sin Light2D que crece con lo curado
## (la fuerza del aura del HTML de diseno: 0,35 + t / 0,6) y titila.
const HOJA_CURAR: Texture2D = preload("res://nucleo/arte/efecto_curar.png")
const HOJA_CURAR_FRENTE: Texture2D = preload("res://nucleo/arte/efecto_curar_frente.png")
const CUADROS_CURAR: int = 6
const AURA_SOBRE_PIES: Vector2 = Vector2(0.0, -185.0)
const LUZ_CURAR_SOBRE_PIES: Vector2 = Vector2(0.0, -110.0)
const LUZ_CURAR_LADO: float = 660.0
const LUZ_CURAR_TINTE: Color = Color(0.75, 0.85, 1.0, 0.0)
## Ticks de una vuelta completa de la voltereta (el sprite gira; ver AnimacionJugador.giro_voltereta).
const TICKS_VUELTA: int = 24
const NUNCA: int = 1000000
# Acciones que levantan al jugador del banco (_seguir_descansando).
const ACCIONES_LEVANTARSE: Array[StringName] = [&"mover_izquierda", &"mover_derecha", &"mover_abajo", &"saltar", &"atacar"]
## Cuanto mas alla del borde del cuerpo busca la pared el rayo de altura_agarre_pared, en px.
const ALCANCE_AGARRE: float = 4.0
const ESCENA_PROYECTIL: PackedScene = preload("res://nucleo/proyectil.tscn")

@export_group("Movimiento")
## Velocidad al caminar, en px/s. Sin aceleracion: arranca y frena en el mismo tick.
@export var velocidad: float = 360.0
## Gravedad, en px/s^2.
@export var gravedad: float = 2400.0
## Altura maxima del salto manteniendo saltar, en px. El impulso se calcula a partir de ella.
@export var altura_salto: float = 230.0
## Al soltar saltar mientras sube, la velocidad vertical se multiplica por este factor.
@export_range(0.0, 1.0) var corte_salto: float = 0.4
## Ticks de subida antes de que soltar saltar corte el salto: un toque corto da un salto bajo, no nulo.
@export var ticks_minimos_salto: int = 4
## Ticks despues de salir de una orilla en que saltar todavia funciona. Silksong da 4 pasos (~0,08 s, 5 ticks);
## 4 para que no quede tan facil (probado en el telefono el 15-oct-2026).
@export var ticks_coyote: int = 4
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
## Cola del ataque: presionar atacar hasta estos ticks antes de que se pueda atacar otra vez ataca en cuanto se
## puede (como el salto en cola).
@export var ticks_ataque_en_cola: int = 6
## Centro del area de ataque hacia arriba, relativo a los pies del jugador (encima de la cabeza).
@export var posicion_ataque_arriba: Vector2 = Vector2(0.0, -210.0)
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
## Anti-bucle (como Silksong): un peligro antes de estos ticks con control tras volver de otro lleva al punto
## de llegada a la sala, sin quitar vida. Cuentan despues de ticks_reaparicion_peligro: 30 = 0,5 s.
@export var ticks_anti_bucle: int = 30
## Px que los pies pasan del borde de abajo de la sala para que salir por abajo cuente como un peligro.
## El alto del cuerpo: el jugador ya no se ve.
@export var margen_fuera_de_sala: float = 160.0

@export_group("Sensacion del golpe")
## Ticks que se detiene todo el juego al recibir dano (congelado comun, ver Congelado), antes del retroceso.
@export var ticks_hit_stop: int = 10
## Parry: ticks sin dano de enemigos despues de parar un ataque (los peligros si danan) y ticks de congelado.
## 20 = 0,33 s: Hollow Knight congela 0,36 s (NailClashEffect) y Silksong 0,2-0,3 s (medido en video).
@export var ticks_invulnerable_parry: int = 15
@export var ticks_congelado_parry: int = 20
## Parry: el jugador sale empujado hacia atras estos ticks a esta velocidad, en px/s, despues del congelado
## (Hollow Knight empuja a los dos). Al enemigo lo empuja su Golpeable.
@export var ticks_retroceso_parry: int = 8
@export var velocidad_retroceso_parry: float = 600.0
## Ticks en que el jugador sale empujado hacia atras al golpear algo.
@export var ticks_rebote_al_golpear: int = 4
## Velocidad de ese empuje, en px/s, alejandose de lo golpeado.
@export var velocidad_rebote_al_golpear: float = 240.0

@export_group("Curar")
## Inspiracion que cuesta curar una vida.
@export var costo_curacion: int = 33
## Ticks manteniendo curar para recuperar una vida. Soltar o recibir dano antes la pierde.
@export var ticks_curacion: int = 60
## Soltar curar antes de estos ticks de curacion devuelve toda la Inspiracion gastada; despues se pierde.
@export var ticks_devolver_curacion: int = 27
## Inspiracion que gana cada golpe a un enemigo (Golpeable con es_enemigo).
@export var inspiracion_por_golpe: int = preload("res://nucleo/partida.gd").INSPIRACION_POR_GOLPE

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
## Carrera (sprint) que sigue al impulso si hay direccion al terminar: unas 2,1 veces caminar (Silksong: «112 %
## mas rapido»). Lo que la apaga esta en docs/jugador.md (soltar mas de ticks_soltar_carrera, pared, dano, curar...).
@export var velocidad_carrera: float = 756.0
## Ticks del giro en carrera: la velocidad pasa de un sentido al otro, por 0, sin apagar la carrera.
@export var ticks_giro_carrera: int = 8
## Ticks sin direccion que la carrera aguanta: el pulgar o el stick cruzan el centro (zona muerta) al girar y eso no
## es soltar. Mientras, sigue a velocidad completa hacia donde iba.
@export var ticks_soltar_carrera: int = 4
## Ataque en carrera: mientras dura, el jugador sale empujado hacia adelante a esta velocidad. Provisional: por encima
## de velocidad_impulso; la persona la pidio mas larga cuatro veces tras probarla en el S50 (12-oct-2026).
@export var velocidad_ataque_carrera: float = 2000.0
## Ticks desde un ataque en carrera hasta poder hacer otro sin dejar de correr; lo pedido antes se pierde. Provisional:
## en Silksong sale uno cada 0,65-0,85 s aunque se presione mas rapido (video del 12-oct-2026).
@export var ticks_entre_ataques_carrera: int = 42
## Si el ataque en carrera golpea algo, voltereta (Silksong, blason de cazadora): la carrera se corta y el jugador
## sale hacia arriba esta altura, en px, y hacia adelante a esta velocidad, en px/s, para pasar por encima.
@export var altura_voltereta: float = 160.0
@export var velocidad_voltereta: float = 480.0
## Chocar con una pared corriendo: rebote corto hacia atras (ticks y px/s) y un saltito de esta altura, en px.
@export var ticks_rebote_pared: int = 8
@export var velocidad_rebote_pared: float = 300.0
@export var altura_rebote_pared: float = 30.0

@export_group("Pared")
## Velocidad maxima de caida sostenido en una pared, en px/s.
@export var velocidad_deslizar_pared: float = 150.0
## Velocidad horizontal con que el salto en pared despega de ella, en px/s.
@export var velocidad_despegue_pared: float = 420.0
## Ticks tras el salto en pared en que la entrada horizontal no manda.
@export var ticks_despegue_pared: int = 8
## Ticks despues de dejar de tocar la pared en que saltar todavia es un salto en pared.
@export var ticks_coyote_pared: int = 3
## Fraccion de la altura del cuerpo, contada desde los pies, a la que tiene que haber pared para sostenerse y
## saltar de ella. 0: basta cualquier contacto (asi se juega hoy, decidido el 14-oct-2026); con 0,5 deja de
## agarrarse con mas de medio cuerpo por encima de la esquina de arriba.
@export_range(0.0, 1.0) var altura_agarre_pared: float = 0.0

@export_group("Temblor al aterrizar")
## Ticks seguidos cayendo a velocidad_caida_max desde los que aterrizar es un aterrizaje duro (el
## mecanismo de Hollow Knight: tiempo cayendo, no velocidad ni altura). 18 = 0,3 s: con la caida de
## hoy, unos 794 px; con distancia_caida_inicial en 0, unos 650. La caida en picada tiembla siempre.
@export var ticks_caida_dura: int = 18
## Amplitud vertical inicial del temblor, en px; baja en linea recta hasta 0. Provisional y sin
## fuente: con 8 px casi no se veia en el telefono (07-oct-2026).
@export var temblor_px: float = 20.0
## Ticks que dura el temblor (0,3 s). Provisional y sin fuente, como temblor_px.
@export var temblor_ticks: int = 18

@export_group("Aterrizaje duro")
## Ticks sin control tras un aterrizaje duro (el que hace temblar; no el de la picada). 21 = 0,35 s,
## sin fuente: el valor de Hollow Knight esta en sus recursos.
@export var ticks_aterrizaje_duro: int = 21

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
## Hablando con un Npc: quieto (con gravedad) y sin control hasta que el Npc cierra la conversacion. Un golpe o un
## peligro la cortan.
var hablando: bool = false
## Golpes que dio la onda de la caida en picada desde que entro a la sala.
var golpes_onda: int = 0
## Ataques enemigos parados desde que entro a la sala (los golpes; un disparo se desvia).
var paradas: int = 0
## Disparos enemigos desviados con el ataque desde que entro a la sala.
var desviados: int = 0
## En carrera (sprint), girando dentro de ella y si el ataque en curso es un ataque en carrera.
var corriendo: bool = false
var girando: bool:
	get:
		return _ticks_girando > 0
var atacando_en_carrera: bool = false
## En la voltereta que sigue a un ataque en carrera que golpeo: hasta tocar el suelo, atacar, un impulso, un dano o
## una pared.
var volteando: bool = false
## Desplazamiento vertical del temblor en este tick, en px (lo calcula la CamaraJugador). La camara lo recibe
## solo con el ajuste temblor encendido; publico para que un guion lo lea aunque el ajuste este apagado.
var temblor_y: float:
	get:
		return _camara.temblor_y
## Desplazamiento horizontal del temblor en este tick, en px; como temblor_y.
var temblor_x: float:
	get:
		return _camara.temblor_x
## Quieto y sin control tras un aterrizaje duro (ver ticks_aterrizaje_duro).
var aterrizando: bool:
	get:
		return _ticks_aterrizando > 0
## Con el ataque en curso: los ticks_ataque desde que se pide, salvo que lo corten la picada, curar, sentarse,
## hablar, reaparecer o un aterrizaje duro.
var atacando: bool:
	get:
		return _ticks_atacando > 0
## No recibe dano de enemigos (los peligros si quitan vida): tras un golpe, durante la picada (con su saltito
## y su carga) y justo despues.
var invulnerable: bool:
	get:
		return _ticks_sin_dano > 0 or en_picada or _preparando_picada
## Puede usar interactuar (banco, Npc, reto, entrega): en el suelo, vivo, de pie, sin aterrizaje duro ni conversacion.
## Una sola regla para todos: la entrega olvidaba sentado y aterrizando (auditoria del 13-oct-2026).
var puede_interactuar: bool:
	get:
		return is_on_floor() and not muerto and not descansando and not aterrizando and not hablando

var _ticks_sin_suelo: int = NUNCA
var _ticks_desde_pulsar: int = NUNCA
var _ticks_desde_atacar: int = NUNCA
var _subiendo: bool = false
var _ticks_subiendo: int = 0
var _cortado: bool = false
var _mirando: float = 1.0
var _ticks_atacando: int = 0
var _ticks_hasta_ataque: int = 0
var _ticks_hasta_ataque_carrera: int = 0
var _golpeados: Array[Golpeable] = []
var _ticks_sin_dano: int = 0
var _ticks_destello: int = 0
var _ticks_retrocediendo: int = 0
var _sentido_retroceso: float = 0.0
var _ticks_rebote: int = 0
var _sentido_rebote: float = 0.0
var _velocidad_rebote: float = 0.0
var _sentido_voltereta: float = 1.0
var _ticks_voltereta: int = 0
var _ticks_en_suelo: int = 0
var _puntos_seguros: PackedVector2Array = []
# Donde aparecio el jugador al entrar a la sala (puerta, banco o Entrada): destino del anti-bucle.
var _punto_llegada: Vector2 = Vector2.ZERO
# Ticks con control desde la ultima vuelta por un peligro; NUNCA si no hubo o si ya actuo el anti-bucle.
var _ticks_desde_peligro: int = NUNCA
# Quieto tras reaparecer por un peligro: ningun peligro cuenta. DanoContacto revisa el contacto con la lista
# del tick anterior y, sin esto, volveria a avisar del mismo peligro ya con el jugador en otro lugar.
var _reapareciendo: bool = false
# Fundido de un peligro: ticks quieto donde lo toco hasta que la pantalla esta en negro, y a donde va despues.
var _ticks_hasta_reaparecer: int = 0
var _punto_reaparicion: Vector2 = Vector2.ZERO
var _ticks_congelado: int = 0
var _inspiracion_al_empezar: int = 0
var _ticks_impulsando: int = 0
var _ticks_girando: int = 0
var _ticks_sin_eje: int = 0
var _sentido_carrera: float = 1.0
var _ticks_hasta_impulso: int = 0
var _impulso_en_el_aire: bool = true
# Impulso presionado durante el congelado comun: sale en cuanto termina.
var _impulso_en_cola: bool = false
var _doble_salto_disponible: bool = true
var _ticks_despegando: int = 0
var _sentido_despegue: float = 0.0
# Ticks que lleva presionado curar; -1 si no hay una pulsacion que cuente.
var _ticks_poder: int = -1
# Ataque hacia abajo (pogo) o hacia arriba en curso, y si ya reboto en este ataque.
var _atacando_abajo: bool = false
var _atacando_arriba: bool = false
# Si este golpe ya hizo un parry: su clip salta al cuadro del golpe (_animar).
var _golpe_parado: bool = false
var _rebotado: bool = false
# Centro del area de ataque de la escena, mirando a la derecha.
var _posicion_ataque: Vector2 = Vector2.ZERO
# Caida en curso (velocity.y >= 0 en el aire) y la y donde empezo, para el tope inicial.
var _cayendo: bool = false
var _y_inicio_caida: float = 0.0
var _ticks_hasta_bola: int = 0
# Recien sentado: el primer tick sentado no se levanta (joystick en diagonal da arriba y un lado juntos).
var _recien_sentado: bool = false
# Tick despues de cerrar una conversacion: la pulsacion que la cerro (saltar, atacar) no salta ni ataca.
var _recien_hablado: bool = false
# La pausa se quito fuera del tick: fue un boton de un menu (Continuar, No, Volver), y si lo acepto A esa pulsacion no
# cuenta como saltar en el tick siguiente. Lo pone _notification; dura un tick.
var _saltar_del_menu: bool = false
# Picada desde el suelo: el saltito y los ticks de carga en su cima.
var _preparando_picada: bool = false
var _ticks_carga: int = 0
# Ticks desde que estuvo contra una pared por ultima vez, y la normal de esa pared.
var _ticks_sin_pared: int = NUNCA
var _normal_pared: float = 0.0
# Aterrizaje: si estaba en el suelo el tick anterior (el temblor lo lleva la CamaraJugador).
var _en_suelo_antes: bool = true
# Ticks seguidos cayendo a velocidad_caida_max.
var _ticks_a_tope: int = 0
var _ticks_aterrizando: int = 0
# Limites de la sala (la camara guarda su copia): la salida por abajo los usa.
var _limites: Rect2 = Rect2(-10000000.0, -10000000.0, 20000000.0, 20000000.0)
# Dibujo: la foto del estado para AnimacionJugador (una sola, se rellena cada tick) y el ultimo valor del destello
# puesto en el material (se cambia solo si cambia).
var _estado_dibujo: AnimacionJugador.Estado = AnimacionJugador.Estado.new()
var _cantidad_destello: float = 0.0
# Duraciones relativas de cada clip y si se repite, leidas una vez del SpriteFrames en _ready (no cada tick).
var _duraciones: Dictionary[StringName, PackedFloat32Array] = {}
var _en_bucle: Dictionary[StringName, bool] = {}
# Cuanto se aparta el cuerpo de la pared en la animacion pared para que la mano y los pies toquen su borde.
var _separacion_pared: float = 0.0
# Media luna blanca de cada golpe, hija del jugador: lo sigue sola (TrazoAtaque).
var _trazo: TrazoAtaque = null
# Aura de curar (detras y delante) y su luz, hijas del jugador: se ven solo curando.
var _aura: EfectoCuadros = null
var _aura_frente: EfectoCuadros = null
var _luz_curar: Sprite2D = null

@onready var _camara: CamaraJugador = $Camara as CamaraJugador
@onready var _forma: CollisionShape2D = $Forma as CollisionShape2D
@onready var _ataque: Area2D = $Ataque as Area2D
@onready var _forma_ataque: CollisionShape2D = $Ataque/Forma as CollisionShape2D
@onready var _dibujo: AnimatedSprite2D = $Dibujo as AnimatedSprite2D
# El material del destello (uno solo, local a la escena) y el ultimo valor puesto: se cambia solo si cambia.
@onready var _destello: ShaderMaterial = _dibujo.material as ShaderMaterial


func _ready() -> void:
	Capas.poner(self, Capas.JUGADOR, Capas.ESCENARIO)
	Capas.poner(_ataque, Capas.ATAQUE_JUGADOR, Capas.GOLPEABLE | Capas.DANINO)
	# La camara se mueve a mano (CamaraJugador.seguir): deja de heredar la posicion del jugador.
	_camara.iniciar(global_position, _mirando)
	# El temblor lee Ajustes.temblor cada tick: no depende de que la pausa o la vibracion lo carguen antes.
	Ajustes.cargar_una_vez()
	_ataque.monitoring = false
	_posicion_ataque = _forma_ataque.position
	_trazo = TrazoAtaque.new()
	_trazo.name = &"Trazo"
	add_child(_trazo)
	_crear_aura()
	_puntos_seguros = [global_position]
	_punto_llegada = global_position
	_leer_clips()


func _physics_process(delta: float) -> void:
	# Antes de _mover, igual que un DanoContacto (que se procesa antes que el jugador): asi el fundido de un
	# peligro cuenta sus ticks a la par del Fundido y el jugador pasa al punto con la pantalla en negro.
	_revisar_salida_por_abajo()
	if _ticks_destello > 0:
		_ticks_destello -= 1
	_mover(delta)
	_saltar_del_menu = false
	# Siempre, tambien congelado, muerto o sentado.
	_camara.seguir(delta, global_position, _mirando)
	_animar()


# Un Button se pulsa con ui_accept al despachar el evento, antes del tick y fuera de la fisica: si ese boton quita la
# pausa, la prioridad de fisica de los menus no alcanza y el jugador leeria en su tick el mismo A como saltar. Un menu
# que se cierra leyendo una accion en su _physics_process lo hace dentro del tick y no pasa por aqui. No se mira si
# saltar esta recien pulsado aqui: a 120 FPS A puede bajar un cuadro y subir el siguiente sin tick entre medio, y aqui
# ya no cuenta como recien pulsado aunque el tick siguiente si lo lea asi.
func _notification(que: int) -> void:
	if que == NOTIFICATION_UNPAUSED and not Engine.is_in_physics_frame():
		_saltar_del_menu = true


# saltar recien pulsado, salvo la pulsacion que acepto el boton que cerro un menu.
func _saltar_pulsado() -> bool:
	return Input.is_action_just_pressed(&"saltar") and not _saltar_del_menu


# Al final del tick, ya movido, y solo leyendo: llena la foto del estado, elige la animacion (AnimacionJugador) y
# pone el cuadro. Los clips con tiempo propio toman el cuadro de los contadores de ticks (sin interpolacion de fisica,
# el cuadro va a la par del tick); los bucles los corre el sprite, quieto durante el congelado comun.
func _animar() -> void:
	var e: AnimacionJugador.Estado = _llenar_estado_dibujo()
	AnimacionJugador.actualizar_cola_ataque(e)
	var nombre: StringName = AnimacionJugador.con_giro(AnimacionJugador.elegir(e), e)
	# Dormir: primero sentarse (una vez) y despues el bucle dormido.
	if nombre == AnimacionJugador.DORMIR and _dibujo.animation != AnimacionJugador.DORMIR:
		if _dibujo.animation != AnimacionJugador.SENTARSE or _dibujo.is_playing():
			nombre = AnimacionJugador.SENTARSE
	var cuadro: int = AnimacionJugador.cuadro(nombre, e, _duraciones[nombre])
	# El parry llega en la preparacion del golpe y el congelado la sostendria con la espada atras: se muestra ya el
	# cuadro del golpe, con la espada sobre el destello.
	if _golpe_parado and cuadro == 0 and AnimacionJugador.es_ataque(nombre):
		cuadro = CUADRO_GOLPE
	if cuadro < 0:
		# Un bucle que no corre (el de la escena al aparecer, o tras un clip por ticks) arranca; muerte y sentarse no
		# se repiten: al acabar se quedan en su ultimo cuadro.
		if _dibujo.animation != nombre or (_en_bucle[nombre] and not _dibujo.is_playing()):
			_dibujo.play(nombre)
	else:
		if _dibujo.is_playing():
			_dibujo.stop()
		if _dibujo.animation != nombre:
			_dibujo.animation = nombre
		if _dibujo.frame != cuadro:
			_dibujo.set_frame_and_progress(cuadro, 0.0)
	_dibujo.speed_scale = 0.0 if Congelado.activo() else 1.0
	_dibujo.scale.x = AnimacionJugador.volteo(nombre, _mirando)
	_dibujo.position.x = _dibujo.scale.x * _separacion_pared if nombre == AnimacionJugador.PARED else 0.0
	_dibujo.rotation = AnimacionJugador.giro_voltereta(e) * _mirando if nombre == AnimacionJugador.VOLTERETA else 0.0
	_mostrar_curacion()
	var color: Color = Color.WHITE
	if _ticks_sin_dano > 0 and not muerto and posmod(Engine.get_physics_frames(), 2 * TICKS_PARPADEO) >= TICKS_PARPADEO:
		color.a = PARPADEO
	_dibujo.modulate = color
	# Blanco solo en el parry: el golpe recibido se lee por su parpadeo, como en Hollow Knight (decidido el 21-oct-2026).
	var cantidad: float = 1.0 if not muerto and _ticks_destello > 0 else 0.0
	if cantidad != _cantidad_destello:
		_cantidad_destello = cantidad
		_destello.set_shader_parameter(&"cantidad", cantidad)


func _leer_clips() -> void:
	var cuadros: SpriteFrames = _dibujo.sprite_frames
	for nombre: StringName in AnimacionJugador.TODAS:
		var duraciones: PackedFloat32Array = []
		for i: int in range(cuadros.get_frame_count(nombre)):
			duraciones.append(cuadros.get_frame_duration(nombre, i))
		_duraciones[nombre] = duraciones
		_en_bucle[nombre] = cuadros.get_animation_loop_mode(nombre) != SpriteFrames.LOOP_NONE
	_separacion_pared = AnimacionJugador.separacion_pared(cuadros, -_dibujo.offset.x, TAMANO.x / 2.0)


# Lee el estado del jugador en la foto del dibujo. No cambia nada del jugador.
func _llenar_estado_dibujo() -> AnimacionJugador.Estado:
	var e: AnimacionJugador.Estado = _estado_dibujo
	e.muerto = muerto
	e.ticks_hasta_reaparecer = _ticks_hasta_reaparecer
	e.descansando = descansando
	e.ticks_retrocediendo = _ticks_retrocediendo
	e.ticks_retroceso = ticks_retroceso
	e.ticks_aterrizando = _ticks_aterrizando
	e.ticks_aterrizaje_duro = ticks_aterrizaje_duro
	e.preparando_picada = _preparando_picada
	e.en_picada = en_picada
	e.curando = curando
	e.ticks_curados = ticks_curados
	e.ticks_poder = _ticks_poder
	e.ticks_hasta_bola = _ticks_hasta_bola
	e.ticks_recarga_bola = ticks_recarga_bola
	e.atacando_en_carrera = atacando_en_carrera
	e.ticks_atacando = _ticks_atacando
	e.ticks_ataque = ticks_ataque
	e.ticks_hasta_ataque = _ticks_hasta_ataque
	e.ticks_entre_ataques = ticks_entre_ataques
	e.atacando_abajo = _atacando_abajo
	e.atacando_arriba = _atacando_arriba
	e.volteando = volteando
	e.ticks_voltereta = _ticks_voltereta
	e.ticks_vuelta = TICKS_VUELTA
	e.ticks_impulsando = _ticks_impulsando
	e.ticks_impulso = ticks_impulso
	e.ticks_despegando = _ticks_despegando
	e.en_pared = en_pared
	# Tras un peligro lo pone en el suelo firme sin move_and_slide: is_on_floor() sigue con el valor de la caida
	# hasta que vuelve a moverse.
	e.en_suelo = is_on_floor() or _reapareciendo
	e.velocidad = velocity
	e.subiendo = _subiendo
	e.ticks_subiendo = _ticks_subiendo
	e.corriendo = corriendo
	e.ticks_girando = _ticks_girando
	e.ticks_giro_carrera = ticks_giro_carrera
	e.ticks_rebote = _ticks_rebote
	e.hablando = hablando
	e.ticks_congelado = _ticks_congelado
	return e


# Salir por abajo de los limites de la sala es un peligro, igual que un pincho: quita una vida y
# vuelve al ultimo suelo firme. Sin sala, los limites son enormes y esto nunca ocurre.
func _revisar_salida_por_abajo() -> void:
	if global_position.y > _limites.end.y + margen_fuera_de_sala:
		recibir_dano(1, global_position.x, true)


# Un contador de ticks "desde" avanza uno, con tope en NUNCA.
static func _envejecer(ticks: int) -> int:
	return mini(ticks + 1, NUNCA)


func _mover(delta: float) -> void:
	if _ticks_hasta_reaparecer > 0:
		_ticks_hasta_reaparecer -= 1
		# Pasa al punto en cuanto el negro tapa todo; sigue quieto hasta que empieza a aclarar.
		if _ticks_hasta_reaparecer == Fundido.TICKS_EN_NEGRO_PELIGRO:
			_colocar_tras_peligro(_punto_reaparicion)
		return
	# Congelado comun (dano, enemigo vencido, parry): todo el juego quieto, el jugador tambien. Las pulsaciones
	# de saltar, atacar e impulso hechas mientras dura no se pierden: cuentan como hechas al terminar.
	if Congelado.activo():
		if _saltar_pulsado():
			_ticks_desde_pulsar = 0
		if Input.is_action_just_pressed(&"atacar"):
			_ticks_desde_atacar = 0
		if Input.is_action_just_pressed(&"impulso"):
			_impulso_en_cola = true
		return
	var en_suelo: bool = is_on_floor()
	_aterrizar(en_suelo)
	if _ticks_congelado > 0:
		_ticks_congelado -= 1
		return
	_reapareciendo = false
	_ticks_desde_peligro = _envejecer(_ticks_desde_peligro)
	_caer(en_suelo, delta)
	if muerto:
		velocity.x = 0.0
		move_and_slide()
		return
	if descansando:
		_seguir_descansando()
		return
	if hablando or _recien_hablado:
		_recien_hablado = false
		velocity.x = 0.0
		move_and_slide()
		return
	_recordar_punto_seguro(en_suelo)
	_avanzar_contadores(en_suelo)
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
	_impulsar(eje)
	_atacar()
	move_and_slide()
	_chocar_corriendo()


# Envejece los contadores del tick con control (voltereta, coyote, colas, recargas) y recupera el aire en el suelo.
func _avanzar_contadores(en_suelo: bool) -> void:
	# La voltereta acaba al tocar el suelo: cae caminando.
	if volteando:
		if en_suelo:
			volteando = false
		else:
			_ticks_voltereta += 1

	_ticks_sin_suelo = 0 if en_suelo else _envejecer(_ticks_sin_suelo)
	if _saltar_pulsado():
		_ticks_desde_pulsar = 0
	else:
		_ticks_desde_pulsar = _envejecer(_ticks_desde_pulsar)
	# La cola del ataque envejece cada tick con control, se ataque o no en este tick.
	if Input.is_action_just_pressed(&"atacar"):
		_ticks_desde_atacar = 0
	else:
		_ticks_desde_atacar = _envejecer(_ticks_desde_atacar)
	_ticks_sin_dano = maxi(_ticks_sin_dano - 1, 0)
	_ticks_hasta_impulso = maxi(_ticks_hasta_impulso - 1, 0)
	_ticks_hasta_bola = maxi(_ticks_hasta_bola - 1, 0)
	if en_suelo:
		_recuperar_aire()


# Tras move_and_slide: el choque con pared corriendo y el fin de la voltereta contra una pared.
func _chocar_corriendo() -> void:
	# Chocar con una pared corriendo corta la carrera con un rebote corto hacia atras (Silksong); la voltereta
	# tambien acaba contra una pared.
	if corriendo and is_on_wall() and get_wall_normal().x * _sentido_carrera < 0.0:
		_dejar_de_correr()
		_rebotar(get_wall_normal().x, ticks_rebote_pared, velocidad_rebote_pared)
		if is_on_floor():
			velocity.y = _velocidad_de_salto(altura_rebote_pared)
	if volteando and is_on_wall():
		volteando = false


# Aterrizaje: se mira al empezar el tick, tras el move_and_slide del anterior. Es duro (tiembla la
# camara y deja sin control) si venia de ticks_caida_dura ticks cayendo a velocidad_caida_max.
# El contador se reinicia en el suelo y con cualquier velocidad menor al tope (pared, pogo, impulso,
# retroceso). Romper un suelo fragil en la picada no es aterrizar: sigue en_picada hasta el suelo.
func _aterrizar(en_suelo: bool) -> void:
	# La picada no pasa por aqui: tiembla y avisa en _seguir_picada, solo al aterrizar de verdad (romper
	# un suelo fragil tambien deja en_suelo un tick, y una picada puede tocar el suelo en su primer tick).
	if en_suelo and not _en_suelo_antes and not en_picada and _ticks_a_tope >= ticks_caida_dura:
		temblar(temblor_ticks, temblor_px)
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
	_camara.avanzar_temblor()


## Tiembla la camara ticks ticks, empezando en px de amplitud (baja en linea recta). Si el temblor en curso todavia
## es mas fuerte, sigue ese. Lo usan el aterrizaje, la picada y lo que se rompe (MuroRompible, Palanca).
func temblar(ticks: int, px: float) -> void:
	_camara.temblar(ticks, px)


# Aterrizaje duro, como en Hollow Knight: corta lo que estaba haciendo y deja al jugador quieto
# ticks_aterrizaje_duro ticks. Lo cancelan un golpe, un peligro, morir y sentarse.
func _empezar_aterrizaje_duro() -> void:
	_cortar_empujes()
	_cortar_ataque()
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
	_ticks_desde_atacar = NUNCA
	_ticks_poder = -1
	velocity.x = 0.0
	move_and_slide()


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
# pared, rebote (al golpear, al parar o contra la pared), voltereta, carrera y por ultimo la entrada. El giro de la carrera solo avanza en
# _correr: una rama con prioridad lo cancela y, si al volver el eje se opone, empieza uno nuevo.
func _mover_en_horizontal(eje: float) -> void:
	if _ticks_retrocediendo > 0:
		_ticks_retrocediendo -= 1
		velocity.x = _sentido_retroceso * retroceso.x
	elif _ticks_impulsando > 0:
		_ticks_impulsando -= 1
		velocity.x = _mirando * velocidad_impulso
		velocity.y = 0.0
		_ticks_girando = 0
		if _ticks_impulsando == 0 and eje != 0.0:
			corriendo = true
			_ticks_sin_eje = 0
			_sentido_carrera = signf(eje)
			_mirando = _sentido_carrera
	elif _ticks_despegando > 0:
		_ticks_despegando -= 1
		velocity.x = _sentido_despegue * velocidad_despegue_pared
		_ticks_girando = 0
	elif _ticks_rebote > 0:
		_ticks_rebote -= 1
		velocity.x = _sentido_rebote * _velocidad_rebote
		_ticks_girando = 0
	elif volteando:
		# El joystick la dirige; sin direccion sigue hacia adelante y pasa por encima de lo que golpeo.
		var sentido: float = signf(eje) if eje != 0.0 else _sentido_voltereta
		velocity.x = sentido * velocidad_voltereta
		_mirando = sentido
	elif corriendo:
		_correr(eje)
	else:
		velocity.x = eje * velocidad
		if eje != 0.0:
			_mirando = signf(eje)


# Carrera: velocidad completa hacia donde va, sin importar cuanto se incline el joystick. Soltarlo mas de
# ticks_soltar_carrera ticks la apaga; pedir el otro lado empieza el giro (ticks_giro_carrera de frenado y
# arranque) y la carrera sigue.
func _correr(eje: float) -> void:
	if eje == 0.0:
		_ticks_sin_eje += 1
		if _ticks_sin_eje > ticks_soltar_carrera:
			_dejar_de_correr()
			velocity.x = 0.0
			return
		eje = _sentido_carrera
	else:
		_ticks_sin_eje = 0
	if _ticks_girando == 0 and signf(eje) != _sentido_carrera:
		_ticks_girando = ticks_giro_carrera
		_sentido_carrera = signf(eje)
	if _ticks_girando > 0:
		_ticks_girando -= 1
		# De la velocidad completa hacia el lado viejo (-1) a la completa hacia el nuevo (1), pasando por 0.
		var avance: float = 1.0 - 2.0 * float(_ticks_girando) / float(ticks_giro_carrera)
		velocity.x = _sentido_carrera * velocidad_carrera * avance
		if avance > 0.0:
			_mirando = _sentido_carrera
	elif atacando_en_carrera:
		velocity.x = _sentido_carrera * velocidad_ataque_carrera
	else:
		velocity.x = _sentido_carrera * velocidad_carrera
		_mirando = _sentido_carrera


func _dejar_de_correr() -> void:
	corriendo = false
	_ticks_girando = 0
	_ticks_sin_eje = 0
	atacando_en_carrera = false


func _saltos(en_suelo: bool, eje: float) -> void:
	# Contra la pared: en el aire, tocandola y empujando hacia ella (salto_en_pared), suba o baje.
	# Sostenido (deslizando) solo al caer. Saltar sale aunque se haya dejado de tocar hace poco.
	var normal: float = get_wall_normal().x if is_on_wall() else 0.0
	if normal != 0.0 and altura_agarre_pared > 0.0 and not _pared_a_la_altura(normal):
		normal = 0.0
	var contra_pared: bool = Partida.tiene(Habilidades.SALTO_EN_PARED) and not en_suelo and normal != 0.0 \
			and signf(eje) == -normal and _ticks_impulsando == 0
	if contra_pared:
		_ticks_sin_pared = 0
		_normal_pared = normal
		_recuperar_aire()
	else:
		_ticks_sin_pared = _envejecer(_ticks_sin_pared)
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
	elif Partida.tiene(Habilidades.DOBLE_SALTO) and _doble_salto_disponible and _ticks_desde_pulsar == 0:
		_doble_salto_disponible = false
		_saltar()
	elif _subiendo:
		_seguir_subiendo()
	if en_pared:
		velocity.y = minf(velocity.y, velocidad_deslizar_pared)


func _saltar() -> void:
	velocity.y = _velocidad_de_salto(altura_salto)
	_subiendo = true
	_ticks_subiendo = 0
	_cortado = false
	# Gasta la pulsacion y el suelo: ni el salto en cola ni el coyote dan un segundo salto.
	_ticks_desde_pulsar = NUNCA
	_ticks_sin_suelo = NUNCA
	Eventos.jugador_salto.emit()


# Velocidad vertical inicial para subir altura px con la gravedad del jugador (negativa: hacia arriba).
func _velocidad_de_salto(altura: float) -> float:
	return -sqrt(2.0 * gravedad * altura)


# El suelo, la pared, el pogo y la voltereta devuelven el impulso en el aire y el doble salto.
func _recuperar_aire() -> void:
	_impulso_en_el_aire = true
	_doble_salto_disponible = true


# Salto variable: soltar saltar corta la subida, pero no antes de ticks_minimos_salto.
func _seguir_subiendo() -> void:
	_ticks_subiendo += 1
	if velocity.y >= 0.0:
		_subiendo = false
	elif not _cortado and _ticks_subiendo >= ticks_minimos_salto and not Input.is_action_pressed(&"saltar"):
		velocity.y *= corte_salto
		_cortado = true


# Impulso (habilidad impulso): hacia donde mira, sin gravedad unos ticks; uno por salto en el aire. eje es el que
# _mover leyo en este tick: entre las dos la entrada no cambia.
func _impulsar(eje: float) -> void:
	var pedido: bool = Input.is_action_just_pressed(&"impulso") or _impulso_en_cola
	_impulso_en_cola = false
	if not Partida.tiene(Habilidades.IMPULSO) or not pedido:
		return
	if _ticks_hasta_impulso > 0 or _ticks_retrocediendo > 0 or not _impulso_en_el_aire:
		return
	# En carrera (tambien a mitad de un giro) el impulso sale hacia el joystick, como fuera de ella.
	if corriendo and eje != 0.0:
		_mirando = signf(eje)
	_ticks_impulsando = ticks_impulso
	_ticks_hasta_impulso = ticks_recarga_impulso
	_subiendo = false
	# El impulso corta la voltereta y un rebote a medias (golpe, parry o pared): no sigue al terminar.
	volteando = false
	_ticks_rebote = 0
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
	return Partida.tiene(Habilidades.CAIDA_EN_PICADA) and Partida.inspiracion >= costo_poder


# Picada desde el suelo: un saltito de altura_saltito_picada, ticks_carga_picada quieto en su cima y
# despues la picada. Sin control y sin recibir dano desde el saltito.
func _preparar_picada() -> void:
	_cortar_empujes()
	_cortar_ataque()
	_preparando_picada = true
	_ticks_carga = 0
	velocity = Vector2(0.0, _velocidad_de_salto(altura_saltito_picada))
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
	_cortar_empujes()
	_cortar_ataque()
	velocity = Vector2(0.0, velocidad_picada)


# Lo que deja al jugador quieto o sin control (picada, aterrizaje duro, sentarse, hablar, un golpe, un peligro): nada
# de lo que lo empujaba sigue despues.
func _cortar_empujes() -> void:
	_subiendo = false
	_ticks_impulsando = 0
	_ticks_despegando = 0
	_ticks_rebote = 0
	_dejar_de_correr()
	volteando = false


# Un ataque a medias se corta: si no, quedaria congelado mientras _mover no llega a _atacar() y seguiria despues.
# Tambien se pierde el ataque en cola.
func _cortar_ataque() -> void:
	_ticks_atacando = 0
	_atacando_abajo = false
	_atacando_arriba = false
	_ticks_desde_atacar = NUNCA
	_ataque.set_deferred(&"monitoring", false)


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
		temblar(temblor_ticks, temblor_px)
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
	consulta.collision_mask = Capas.GOLPEABLE
	for choque: Dictionary in get_world_2d().direct_space_state.intersect_shape(consulta):
		var golpeable: Golpeable = choque["collider"] as Golpeable
		if golpeable != null:
			golpeable.recibir_golpe(self, dano_picada)
			golpes_onda += 1


# Hay pared a altura_agarre_pared del cuerpo, del lado contrario a la normal: un rayo desde el centro del cuerpo
# hasta un poco mas alla de su borde, a esa altura.
func _pared_a_la_altura(normal: float) -> bool:
	var rectangulo: Rect2 = _forma.shape.get_rect()
	var altura: float = _forma.position.y + rectangulo.end.y - rectangulo.size.y * altura_agarre_pared
	var desde: Vector2 = global_position + Vector2(_forma.position.x, altura)
	var hasta: Vector2 = desde + Vector2(-normal * (rectangulo.size.x / 2.0 + ALCANCE_AGARRE), 0.0)
	return not Capas.rayo_a_escenario(self, desde, hasta).is_empty()


# Toque del boton de poderes: con la habilidad proyectil y Inspiracion, lanza la bola hacia donde
# mira, en el suelo o en el aire. Se agrega a la sala en diferido, fuera del paso de la fisica.
func _lanzar_poder() -> void:
	if not Partida.tiene(Habilidades.PROYECTIL) or Partida.inspiracion < costo_poder or _ticks_hasta_bola > 0:
		return
	Partida.inspiracion -= costo_poder
	_ticks_hasta_bola = ticks_recarga_bola
	var salida: Vector2 = position + Vector2(salida_proyectil.x * _mirando, salida_proyectil.y)
	# Pegado a una pared, la salida queda dentro de ella y el rayo de la bola no la veria: se revisa
	# el camino desde el jugador. Si hay un solido, la bola se deshace ahi (el costo ya se pago).
	var desde: Vector2 = global_position + Vector2(0.0, salida_proyectil.y)
	var hasta: Vector2 = global_position + Vector2(salida_proyectil.x * _mirando + _mirando * Proyectil.TAMANO.x / 2.0, salida_proyectil.y)
	if not Capas.rayo_a_escenario(self, desde, hasta).is_empty():
		return
	var bola: Proyectil = ESCENA_PROYECTIL.instantiate() as Proyectil
	bola.sentido = _mirando
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
	_dejar_de_correr()
	ticks_curados = 0
	_inspiracion_al_empezar = Partida.inspiracion
	# Quieto mientras se cura: nada de lo que empujaba al jugador sigue despues.
	_ticks_despegando = 0
	_ticks_rebote = 0
	# Mientras cura, _mover sale por _boton_poderes antes de _atacar(): un ataque a medias quedaria encendido.
	_cortar_ataque()


func _seguir_curando(en_suelo: bool, mantiene: bool) -> bool:
	if not mantiene or not en_suelo:
		# Soltar pronto devuelve exactamente lo que habia al empezar: nunca deja mas.
		if not mantiene and ticks_curados < ticks_devolver_curacion:
			Partida.inspiracion = _inspiracion_al_empezar
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
# cada Golpeable que toca durante ese ataque. Cada golpe a un enemigo da Inspiracion; cualquiera empuja al jugador. En el
# aire con mover_abajo, el ataque va hacia abajo (pogo): ver _rebotar_pogo; con mover_arriba, hacia
# arriba. Sin la pluma (el arma) no se ataca. Un Cortable que toca se corta, sin mas.
func _atacar() -> void:
	_ticks_hasta_ataque = maxi(_ticks_hasta_ataque - 1, 0)
	_ticks_hasta_ataque_carrera = maxi(_ticks_hasta_ataque_carrera - 1, 0)
	var pedido: bool = Partida.tiene(Habilidades.PLUMA) and _ticks_desde_atacar <= ticks_ataque_en_cola and _ticks_hasta_ataque == 0
	# Pogo: en el aire con mover_abajo. Sin move_and_slide de por medio, is_on_floor() no cambia en este tick.
	var abajo_en_el_aire: bool = not is_on_floor() and Input.is_action_pressed(&"mover_abajo")
	# En carrera, el ataque pedido durante la recarga del ataque en carrera se pierde: ni estocada ni ataque normal,
	# y se sigue corriendo (Silksong). Hacia arriba o el pogo no cuentan como ataque en carrera.
	if pedido and corriendo and _ticks_girando == 0 and _ticks_hasta_ataque_carrera > 0 \
			and not Input.is_action_pressed(&"mover_arriba") \
			and not abajo_en_el_aire:
		_ticks_desde_atacar = NUNCA
		pedido = false
	if pedido:
		_iniciar_ataque(abajo_en_el_aire)
	if _ticks_atacando == 0:
		return
	_ticks_atacando -= 1
	# monitoring se enciende en diferido: el primer tick del ataque todavia no ve nada.
	if _ataque.monitoring:
		for area: Area2D in _ataque.get_overlapping_areas():
			_golpear(area)
	if _ticks_atacando == 0:
		_ataque.set_deferred(&"monitoring", false)
		atacando_en_carrera = false


# Arranca el golpe pedido: direccion, ticks, recargas y forma del area, que se enciende en diferido.
func _iniciar_ataque(abajo_en_el_aire: bool) -> void:
	_ticks_desde_atacar = NUNCA
	_ticks_atacando = ticks_ataque
	_ticks_hasta_ataque = ticks_entre_ataques
	_golpeados.clear()
	# Atacar en la voltereta la cancela (Silksong).
	volteando = false
	_atacando_abajo = abajo_en_el_aire
	_atacando_arriba = not _atacando_abajo and Input.is_action_pressed(&"mover_arriba")
	atacando_en_carrera = corriendo and _ticks_girando == 0 and not _atacando_abajo and not _atacando_arriba
	if atacando_en_carrera:
		_ticks_hasta_ataque_carrera = ticks_entre_ataques_carrera
	_rebotado = false
	_golpe_parado = false
	if _atacando_abajo:
		_forma_ataque.position = posicion_pogo
	elif _atacando_arriba:
		_forma_ataque.position = posicion_ataque_arriba
	else:
		_forma_ataque.position = Vector2(absf(_posicion_ataque.x) * _mirando, _posicion_ataque.y)
	_ataque.set_deferred(&"monitoring", true)
	# El trazo sale del area de golpe ya colocada: si el area se mueve, el trazo la sigue.
	var direccion: TrazoAtaque.Direccion = TrazoAtaque.Direccion.LADO
	if _atacando_abajo:
		direccion = TrazoAtaque.Direccion.ABAJO
	elif _atacando_arriba:
		direccion = TrazoAtaque.Direccion.ARRIBA
	_trazo.mostrar(_forma_ataque.position, direccion, _mirando)


# Lo que hace el ataque con un area que toca: cortar, parar, golpear una vez y empujar, o rebotar en un peligro.
func _golpear(area: Area2D) -> void:
	var cortable: Cortable = area as Cortable
	if cortable != null:
		cortable.cortar()
		return
	var ataque_enemigo: AtaqueEnemigo = area as AtaqueEnemigo
	if ataque_enemigo != null:
		if ataque_enemigo.se_puede_parar:
			_parar(ataque_enemigo)
		return
	var golpeable: Golpeable = area as Golpeable
	if golpeable != null and not _golpeados.has(golpeable):
		_golpeados.append(golpeable)
		golpeable.recibir_golpe(self, dano_ataque)
		if golpeable.es_enemigo:
			Partida.ganar_inspiracion(inspiracion_por_golpe)
		if _atacando_abajo:
			_rebotar_pogo()
		elif atacando_en_carrera:
			_empezar_voltereta()
		elif not _atacando_arriba and not volteando:
			_rebotar(-_mirando, ticks_rebote_al_golpear, velocidad_rebote_al_golpear)
	elif _atacando_abajo:
		var contacto: DanoContacto = area as DanoContacto
		if contacto != null and contacto.peligro:
			_rebotar_pogo()


# Empuje horizontal unos ticks, con prioridad sobre la carrera y la entrada: al golpear, al parar un ataque y al
# chocar corriendo con una pared.
func _rebotar(sentido: float, ticks: int, velocidad_del_rebote: float) -> void:
	_ticks_rebote = ticks
	_sentido_rebote = sentido
	_velocidad_rebote = velocidad_del_rebote


# Voltereta (Silksong, blason de cazadora): el ataque en carrera que golpea corta la carrera y lanza al jugador
# hacia arriba y adelante; como el pogo, devuelve el doble salto y el impulso en el aire. El ataque en curso
# termina normal y el siguiente se puede pedir en cuanto termine (el ataque en carrera reinicia la recarga).
func _empezar_voltereta() -> void:
	_sentido_voltereta = _sentido_carrera
	_dejar_de_correr()
	# Un ataque en carrera hecho durante un impulso: el golpe corta el impulso (si no, anularia el despegue y al
	# terminar volveria la carrera).
	_ticks_impulsando = 0
	volteando = true
	_ticks_voltereta = 0
	velocity.y = _velocidad_de_salto(altura_voltereta)
	_subiendo = false
	_ticks_sin_suelo = NUNCA
	_recuperar_aire()
	_ticks_hasta_ataque = mini(_ticks_hasta_ataque, _ticks_atacando)
	# El golpe tambien reinicia la recarga del ataque en carrera: tras la voltereta, la siguiente carrera ataca enseguida.
	_ticks_hasta_ataque_carrera = 0


## Lo llama un AtaqueEnemigo que se puede parar antes de danar: si el ataque del jugador ya lo toca, lo para
## (asi el orden en que se procesan los dos no decide si hubo parry).
func intentar_parar(ataque: AtaqueEnemigo) -> bool:
	if muerto or _ticks_atacando == 0 or not _ataque.monitoring or not _ataque.overlaps_area(ataque):
		return false
	_parar(ataque)
	return true


# Parry, con el ataque normal en cualquier direccion: el ataque enemigo desaparece sin danar, el jugador queda
# ticks_invulnerable_parry ticks sin dano de enemigos, todo se congela ticks_congelado_parry ticks con un destello
# en la punta de la espada (_soltar_destello), despues el jugador sale empujado hacia atras y el enemigo recibe el golpe (con su
# Inspiracion, como cualquier golpe; su Golpeable lo empuja). Un disparo no se para: se desvia (_desviar).
func _parar(ataque: AtaqueEnemigo) -> void:
	if ataque.parado:
		return
	if ataque is ProyectilEnemigo:
		_desviar(ataque)
		return
	var centro_ataque: Vector2 = ataque.centro()
	ataque.parar()
	paradas += 1
	_ticks_sin_dano = maxi(_ticks_sin_dano, ticks_invulnerable_parry)
	Congelado.pedir(ticks_congelado_parry)
	_ticks_destello = TICKS_DESTELLO_PARRY
	_golpe_parado = true
	var punto: Vector2 = (_forma_ataque.global_position + centro_ataque) / 2.0
	if not _atacando_abajo and not _atacando_arriba:
		punto = global_position + Vector2(PUNTA_ESPADA_LADO.x * signf(_forma_ataque.position.x), PUNTA_ESPADA_LADO.y)
	_soltar_destello(punto, 1.0, true)
	# Despues del congelado, el jugador sale empujado lejos del ataque; parar corta la carrera y la voltereta.
	var lado: float = signf(global_position.x - centro_ataque.x)
	_dejar_de_correr()
	volteando = false
	_rebotar(lado if lado != 0.0 else -_mirando, ticks_retroceso_parry, velocidad_retroceso_parry)
	# La senal va antes del golpe al dueno: la vibracion del parry gana el tick a la de pegar.
	Eventos.parry.emit()
	var enemigo: Enemigo = ataque.get_parent() as Enemigo
	if enemigo != null and enemigo.golpeable != null and not _golpeados.has(enemigo.golpeable):
		_golpeados.append(enemigo.golpeable)
		enemigo.golpeable.recibir_golpe(self, dano_ataque)
		Partida.ganar_inspiracion(inspiracion_por_golpe)


# Disparo desviado con el ataque (decidido por la persona el 25-oct-2026, como la version ligera del choque de
# Silksong, noClashFreeze): desaparece con una chispa chica, sin congelado, destello, retroceso, invulnerabilidad ni
# Inspiracion (no hay enemigo al que pegarle). Suena y vibra como pegarle a un objeto.
func _desviar(disparo: AtaqueEnemigo) -> void:
	_soltar_destello(disparo.centro(), ESCALA_CHISPA, false)
	disparo.parar()
	desviados += 1
	Eventos.objeto_golpeado.emit(disparo)


# Pogo: el golpe hacia abajo a un Golpeable o a un peligro lanza al jugador hacia arriba (una vez por
# ataque) y le devuelve el doble salto y el impulso en el aire. Soltar saltar no corta el rebote.
func _rebotar_pogo() -> void:
	if _rebotado:
		return
	_rebotado = true
	velocity.y = _velocidad_de_salto(altura_pogo)
	_subiendo = false
	_ticks_sin_suelo = NUNCA
	_recuperar_aire()
	rebotes_pogo += 1


## Lo llama lo que dana al jugador. origen_x: de donde viene el golpe, para el retroceso.
## peligro: pinchos, acido, fosas. Quita vidas aunque el jugador sea invulnerable (como Hollow Knight) y
## lleva al ultimo punto seguro, sin retroceso; si llega antes de ticks_anti_bucle de volver de otro
## peligro, lleva al punto de llegada a la sala sin quitar vida.
func recibir_dano(dano: int, origen_x: float, peligro: bool = false) -> void:
	# Mientras la pantalla funde a negro por un peligro, nada mas cuenta.
	if muerto or _ticks_hasta_reaparecer > 0 or (peligro and _reapareciendo):
		return
	if peligro and _ticks_desde_peligro < ticks_anti_bucle:
		_reaparecer(_punto_llegada)
		# El punto seguro pasa a ser la llegada, y el siguiente peligro ya cuesta una vida: si la llegada
		# tambien fuera peligrosa, el bucle termina en vez de seguir sin fin.
		_puntos_seguros = [_punto_llegada]
		_ticks_desde_peligro = NUNCA
		return
	if invulnerable and not peligro:
		return
	vidas = maxi(vidas - dano, 0)
	_ticks_aterrizando = 0
	_cortar_curacion()
	# Un golpe tambien pierde la pulsacion de curar a medias (ni toque ni curacion) y levanta del banco.
	_ticks_poder = -1
	descansando = false
	hablando = false
	# El ataque a medias no se corta: sigue tras el congelado del golpe.
	_cortar_empujes()
	Eventos.jugador_danado.emit(vidas)
	if vidas == 0:
		_morir()
		return
	_ticks_sin_dano = ticks_invulnerable
	if peligro:
		_volver_al_punto_seguro()
		return
	# Como Hollow Knight: el golpe congela todo el juego unos ticks y despues empieza el retroceso.
	Congelado.pedir(ticks_hit_stop)
	_ticks_retrocediendo = ticks_retroceso
	var lado: float = signf(global_position.x - origen_x)
	_sentido_retroceso = lado if lado != 0.0 else -_mirando
	velocity.y = -retroceso.y


func _morir() -> void:
	muerto = true
	_ticks_aterrizando = 0
	_ticks_atacando = 0
	_ticks_sin_dano = 0
	_ataque.set_deferred(&"monitoring", false)
	# Las PejeCoins quedan en la mochila antes de avisar: asi el autoguardado de Partida al oir la muerte ya la lleva,
	# sin depender del orden de las conexiones ni de que Partida busque al jugador.
	Partida.dejar_mochila(Sala.clave_de(self), ultimo_punto_seguro())
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


## Donde volveria tras un peligro: nunca sobre pinchos ni en el aire. Ahi queda la mochila al morir.
func ultimo_punto_seguro() -> Vector2:
	return _puntos_seguros[0] if not _puntos_seguros.is_empty() else position


func _volver_al_punto_seguro() -> void:
	_reaparecer(_puntos_seguros[0])
	_ticks_desde_peligro = 0


# Tras un peligro (como Hollow Knight): quieto donde lo toco mientras la pantalla funde a negro
# (Fundido.TICKS_OSCURECER); ya en negro, pasa al punto y espera Fundido.TICKS_EN_NEGRO_PELIGRO; la imagen
# aclara mientras sigue quieto.
func _reaparecer(punto: Vector2) -> void:
	_reapareciendo = true
	velocity = Vector2.ZERO
	_cortar_empujes()
	_cortar_ataque()
	# Quieto bajo el negro no corre el temblor: la camara no se queda movida.
	_camara.detener_temblor()
	_punto_reaparicion = punto
	_ticks_hasta_reaparecer = Fundido.TICKS_OSCURECER + Fundido.TICKS_EN_NEGRO_PELIGRO
	Eventos.fundido_pedido.emit(Fundido.TICKS_OSCURECER, Fundido.TICKS_EN_NEGRO_PELIGRO, Fundido.TICKS_ACLARAR)


# Pone al jugador en el punto: quieto ticks_reaparicion_peligro ticks y sin nada a medias.
func _colocar_tras_peligro(punto: Vector2) -> void:
	global_position = punto
	_reapareciendo = true
	velocity = Vector2.ZERO
	en_picada = false
	_preparando_picada = false
	_ticks_carga = 0
	descansando = false
	hablando = false
	# Ni una pulsacion de curar a medias: soltarla congelado contaria como toque.
	_ticks_poder = -1
	_ticks_retrocediendo = 0
	# _reaparecer ya corto el ataque y la carrera; desde ahi _mover no avanzo, asi que siguen cortados.
	_cortar_empujes()
	_ticks_en_suelo = 0
	# Una pulsacion de saltar o atacar justo antes del peligro no debe contar al reaparecer.
	_ticks_desde_pulsar = NUNCA
	_ticks_desde_atacar = NUNCA
	_ticks_sin_suelo = NUNCA
	_ticks_sin_pared = NUNCA
	_ticks_congelado = ticks_reaparicion_peligro
	_en_suelo_antes = true
	_ticks_a_tope = 0
	_ticks_aterrizando = 0
	# Reaparecer no tiembla ni deja la camara movida.
	_camara.detener_temblor()
	_camara.colocar(global_position, _mirando)


## El jugador que esta encima de un area y puede interactuar (banco, Npc, reto, entrega); null si no hay.
static func encima_de(area: Area2D) -> Jugador:
	for cuerpo: Node2D in area.get_overlapping_bodies():
		var jugador: Jugador = cuerpo as Jugador
		if jugador != null and jugador.puede_interactuar:
			return jugador
	return null


## Lo llama el banco al descansar: el jugador se acomoda sobre el (en su x) y se queda sentado, mirando hacia lado
## (1 o -1) si el banco lo dice; con 0, hacia donde miraba.
func sentarse(x: float, lado: float = 0.0) -> void:
	if lado != 0.0:
		_mirando = lado
	_cortar_empujes()
	_cortar_ataque()
	_cortar_curacion()
	_ticks_poder = -1
	# Ni la pausa tras un peligro ni el retroceso de un golpe justo antes siguen al levantarse.
	_ticks_retrocediendo = 0
	_ticks_congelado = 0
	_ticks_aterrizando = 0
	descansando = true
	_recien_sentado = true
	global_position.x = x
	velocity = Vector2.ZERO


## Lo llama el Npc al empezar una conversacion: como sentarse(), corta lo que empujaba al jugador y lo deja quieto.
func empezar_a_hablar() -> void:
	_cortar_empujes()
	_cortar_ataque()
	_cortar_curacion()
	_ticks_poder = -1
	_ticks_retrocediendo = 0
	_ticks_aterrizando = 0
	hablando = true
	velocity.x = 0.0


## Lo llama el Npc al cerrar la conversacion. El tick siguiente sigue quieto: la pulsacion que la cerro no cuenta.
func dejar_de_hablar() -> void:
	if not hablando:
		return
	hablando = false
	_recien_hablado = true
	_ticks_desde_pulsar = NUNCA
	_ticks_desde_atacar = NUNCA


# Sentado: quieto hasta que se mueve, salta o ataca. Levantarse no hace saltar ni atacar: esto
# corre antes de leer saltar y atacar, y en el tick siguiente la pulsacion ya no es nueva.
func _seguir_descansando() -> void:
	if _recien_sentado:
		_recien_sentado = false
		velocity.x = 0.0
		move_and_slide()
		return
	for accion: StringName in ACCIONES_LEVANTARSE:
		if Input.is_action_just_pressed(accion) and not (accion == &"saltar" and _saltar_del_menu):
			descansando = false
	if descansando:
		velocity.x = 0.0
		move_and_slide()


# La sala le pasa sus limites: la camara sigue al jugador sin mostrar nada fuera de ellos.
func fijar_limites(limites: Rect2) -> void:
	_limites = limites
	_camara.fijar_limites(limites, global_position, _mirando)


# Destello del parry o chispa de un disparo desviado en un punto de la sala: hijo de la sala, queda fijo aunque el
# jugador salga empujado, va encima de el y se libera solo al acabar.
func _soltar_destello(punto: Vector2, escala: float, corre_congelado: bool) -> void:
	var efecto: EfectoCuadros = EfectoCuadros.crear(HOJA_PARRY, CUADROS_PARRY, 1, true, true, corre_congelado)
	efecto.scale = Vector2.ONE * escala
	efecto.z_index = z_index + 1
	get_parent().add_child(efecto)
	efecto.global_position = punto


# El aura de curar detras del cuerpo, sus rayas delante y la luz; ocultas hasta curar. Detras sin bajar z_index (con
# z -1 quedaba bajo el fondo de la sala): como el Dibujo, show_behind_parent, y primera de los hijos, antes que el.
func _crear_aura() -> void:
	_aura = EfectoCuadros.crear(HOJA_CURAR, CUADROS_CURAR, 1, false, false, false)
	_aura.name = &"Aura"
	_aura.show_behind_parent = true
	_aura_frente = EfectoCuadros.crear(HOJA_CURAR_FRENTE, CUADROS_CURAR, 1, false, false, false)
	_aura_frente.name = &"AuraFrente"
	_luz_curar = Sprite2D.new()
	_luz_curar.name = &"LuzCurar"
	_luz_curar.texture = LuzSala.textura()
	_luz_curar.material = LuzSala.material_aditivo()
	_luz_curar.scale = Vector2.ONE * (LUZ_CURAR_LADO / LuzSala.LADO)
	_luz_curar.position = LUZ_CURAR_SOBRE_PIES
	_luz_curar.modulate = LUZ_CURAR_TINTE
	for nodo: Node2D in [_aura, _aura_frente]:
		nodo.position = AURA_SOBRE_PIES
	for nodo: Node2D in [_aura, _aura_frente, _luz_curar]:
		nodo.visible = false
		nodo.set_physics_process(false)
		add_child(nodo)
	move_child(_aura, 0)


# Muestra el aura y su luz mientras cura (el aura empieza en su primer cuadro); la luz crece con lo curado y titila.
func _mostrar_curacion() -> void:
	if curando != _aura.visible:
		for nodo: Node2D in [_aura, _aura_frente, _luz_curar]:
			nodo.visible = curando
		for efecto: EfectoCuadros in [_aura, _aura_frente]:
			efecto.set_physics_process(curando)
			efecto.reiniciar()
	if curando:
		# Segundos curados, a 60 ticks por segundo.
		var t: float = float(ticks_curados) / 60.0
		_luz_curar.modulate.a = minf(1.0, 0.35 + t / 0.6) * (0.32 + 0.04 * sin(t * 30.0))
