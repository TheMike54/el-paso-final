class_name Enemigo
extends CharacterBody2D
# Enemigo del nucleo: su ficha dice que es y que script lo mueve (ComportamientoEnemigo, que se agrega como
# hijo sin que el nucleo sepa cual es; sin script, quieto). Es un cuerpo que choca con el escenario (el jugador
# lo atraviesa); el que vuela flota, sin suelo. Pierde vida con cada golpe que recibe su Golpeable y dana al
# jugador por contacto. Vencido, emite Eventos.enemigo_vencido y desaparece; si es fuerte, Partida lo recuerda
# hasta el proximo descanso y no vuelve a aparecer en su sala. Con un AnimatedSprite2D (animacion) se ve con arte en
# vez de la caja gris: el tipo de enemigo con arte es una escena heredada de enemigo.tscn, como el Npc.

## Cada umbral cruzado avisa una vez, en orden, antes de comprobar la muerte.
signal fase_cambiada(fase: int)
## Todo enemigo avisa antes de queue_free; la arena escucha esta senal para resolver la victoria.
signal vencido()

const ANIM_QUIETO: StringName = &"quieto"
const ESCENA_MONEDAS: PackedScene = preload("res://nucleo/monedas_sueltas.tscn")
## Las PejeCoins que suelta se llaman "botin_<id>": es su id de MonedasSueltas, la marca que queda al tomarlas.
const PREFIJO_BOTIN: String = "botin_"
## Salto del botin: sube SALTO_BOTIN px desde el centro del enemigo y cae al suelo que tenga debajo, en segundos.
const SALTO_BOTIN: float = 60.0
const SUBIDA_BOTIN: float = 0.2
const CAIDA_BOTIN: float = 0.35
## Hasta donde busca suelo bajo un enemigo que vuela; sin suelo, el botin cae donde estaba.
const ALCANCE_SUELO: float = 2000.0

## Vida, dano, tamano y reaparicion del enemigo: los datos, en una ficha .tres.
@export var ficha: FichaEnemigo
## Id del ejemplar, unico dentro de su sala: junto con la clave de la sala lo identifica.
@export var id: StringName = &""
## Dibujo animado opcional, hijo del enemigo; sin el, la caja gris de la ficha. Mira a la derecha sin voltear y se
## refleja con scale.x sobre los pies segun mirando. Al aparecer toca ANIM_QUIETO si su SpriteFrames la tiene; las
## demas las pide su comportamiento con animar(). Se detiene durante el congelado, como el resto del juego.
@export var animacion: AnimatedSprite2D = null
## Numeros del comportamiento solo para este ejemplar (un radio mayor, otra espera); ganan a los de la ficha. De la
## misma clase que los de su comportamiento: otra clase se avisa con un error y se usan los de la ficha.
@export var datos: DatosComportamiento = null

## Vida que le queda.
var vida: int = 0
## Fase actual: 0 al aparecer, una mas por cada umbral de la ficha.
var fase: int = 0
## Sin gravedad aunque su ficha la tenga (trepar, enterrarse): MOTION_MODE_FLOATING y caer() no hace nada. Lo
## cambia su comportamiento con flotar(); en false vuelve al modo de la ficha.
var flotando: bool = false:
	set(valor):
		flotando = valor
		if ficha != null:
			motion_mode = MOTION_MODE_FLOATING if flotando or ficha.gravedad <= 0.0 else MOTION_MODE_GROUNDED
## Hacia donde mira: -1 izquierda, 1 derecha. Lo cambia su comportamiento (girar); el dibujo se refleja solo.
var mirando: float = -1.0:
	set(valor):
		mirando = valor
		_voltear()
## Su Golpeable: lo que recibe los golpes (el parry tambien le pega aqui).
var golpeable: Golpeable:
	get:
		return _golpeable

@onready var _golpeable: Golpeable = $Golpeable as Golpeable
@onready var _contacto: DanoContacto = $DanoContacto as DanoContacto


func _ready() -> void:
	# Antes de cualquier salida: sin dibujo, _physics_process no tiene nada que hacer.
	set_physics_process(animacion != null)
	Capas.poner(self, Capas.CUERPO_ENEMIGO, Capas.ESCENARIO)
	if ficha == null or id.is_empty():
		push_error("Enemigo %s: le falta la ficha o el id" % name)
		queue_free()
		return
	if not ficha.jefe and ficha.reaparicion == FichaEnemigo.Reaparicion.AL_DESCANSAR and Partida.fue_vencido(clave()):
		queue_free()
		return
	vida = ficha.vida
	_contacto.dano = ficha.dano_contacto
	_poner_forma(_golpeable)
	_poner_forma(_contacto)
	_poner_cuerpo()
	motion_mode = MOTION_MODE_FLOATING if ficha.gravedad <= 0.0 else MOTION_MODE_GROUNDED
	_golpeable.golpeado.connect(_al_ser_golpeado)
	if animacion != null:
		_voltear()
		if _tiene(ANIM_QUIETO):
			animacion.play(ANIM_QUIETO)
	if ficha.comportamiento != null:
		var comportamiento: ComportamientoEnemigo = ficha.comportamiento.new() as ComportamientoEnemigo
		if comportamiento == null:
			push_error("Enemigo %s: el comportamiento de la ficha %s no hereda de ComportamientoEnemigo" % [name, ficha.id])
		else:
			comportamiento.enemigo = self
			comportamiento.datos = _datos_para(comportamiento)
			comportamiento.name = "Comportamiento"
			_golpeable.bloqueo = comportamiento.bloquea_golpe
			add_child(comportamiento)


## "<sala>#<id>" (la sala por su id o, si es de prueba suelta, por su ruta): lo que Partida recuerda de un
## enemigo fuerte vencido.
func clave() -> String:
	var sala: Sala = owner as Sala
	var nombre: String = sala.clave() if sala != null else (owner.scene_file_path if owner != null else "")
	return "%s#%s" % [nombre, id]


## Toca la animacion nombre si su SpriteFrames la tiene y no es la que ya corre (classes/class_spriteframes.rst:280);
## sin dibujo, nada. Para su comportamiento: se puede llamar cada tick.
func animar(nombre: StringName) -> void:
	if animacion != null and _tiene(nombre) and animacion.animation != nombre:
		animacion.play(nombre)


# Solo corre con dibujo: el congelado de un golpe tambien lo detiene (los ticks no avanzan para nadie).
func _physics_process(_delta: float) -> void:
	animacion.speed_scale = 0.0 if Congelado.activo() else 1.0


func _tiene(nombre: StringName) -> bool:
	return animacion.sprite_frames != null and animacion.sprite_frames.has_animation(nombre)


# Un mirando de 0 no voltea: dejaria scale.x en 0 y el dibujo no volveria a verse.
func _voltear() -> void:
	if animacion != null and mirando != 0.0:
		animacion.scale.x = absf(animacion.scale.x) * mirando


# Los datos del ejemplar, si no los de la ficha, si no los que trae la clase del comportamiento. Uno de otra clase
# que la del comportamiento (o cualquiera, si el comportamiento no tiene datos) se descarta con un error: su lectura
# con as daria null en medio de actuar().
func _datos_para(comportamiento: ComportamientoEnemigo) -> DatosComportamiento:
	var propios: DatosComportamiento = comportamiento.datos_por_omision()
	for elegido: DatosComportamiento in [datos, ficha.datos]:
		if elegido == null:
			continue
		if propios == null or elegido.get_script() != propios.get_script():
			push_error("Enemigo %s: sus datos no son de la clase que pide su comportamiento" % name)
			continue
		return elegido
	return propios


# Las formas se crean aqui con el tamano de la ficha: una forma de la escena seria la misma para
# todos los ejemplares.
func _poner_forma(area: Area2D) -> void:
	var rectangulo: RectangleShape2D = RectangleShape2D.new()
	rectangulo.size = ficha.tamano
	var forma: CollisionShape2D = area.get_node(^"Forma") as CollisionShape2D
	forma.shape = rectangulo
	forma.position = Vector2(0.0, -ficha.tamano.y / 2.0)


# Forma del cuerpo, hija directa (las nietas no cuentan), con el tamano de la ficha.
func _poner_cuerpo() -> void:
	var rectangulo: RectangleShape2D = RectangleShape2D.new()
	rectangulo.size = ficha.tamano
	var forma: CollisionShape2D = CollisionShape2D.new()
	forma.name = "Cuerpo"
	forma.shape = rectangulo
	forma.position = Vector2(0.0, -ficha.tamano.y / 2.0)
	add_child(forma)


func _al_ser_golpeado(_atacante: Node2D, dano: int) -> void:
	if vida <= 0:
		return
	vida = maxi(vida - dano, 0)
	# La fase nueva se guarda en una local: si el gancho provoca otro golpe que cruza el umbral siguiente, la llamada
	# anidada avanza fase y el bucle de fuera no repite ni salta ninguna.
	while fase < ficha.umbrales_fase.size() and vida <= ficha.umbrales_fase[fase]:
		fase += 1
		var nueva: int = fase
		var comportamiento: ComportamientoEnemigo = get_node_or_null(^"Comportamiento") as ComportamientoEnemigo
		if comportamiento != null:
			comportamiento.al_cambiar_fase(nueva)
		fase_cambiada.emit(nueva)
	if vida > 0:
		return
	if not ficha.jefe and ficha.reaparicion == FichaEnemigo.Reaparicion.AL_DESCANSAR:
		Partida.vencer(clave())
	Congelado.pedir(Congelado.TICKS_AL_VENCER)
	Eventos.enemigo_vencido.emit(ficha.id)
	if Arranque.sonido != null:
		Arranque.sonido.tocar(&"vencido", ficha.sonidos)
	_soltar_botin()
	vencido.emit()
	queue_free()


# Las PejeCoins de la ficha, como un MonedasSueltas hijo de la sala que salta desde su centro y cae al suelo de abajo.
# Si las de este ejemplar ya se tomaron (su marca en la sala), nada. El golpe puede llegar dentro de una senal de
# fisica (la bola, por area_entered): ahi no se puede agregar un Area2D, asi que se agrega con call_deferred y el
# Tween, de la sala y atado al monton (classes/class_tween.rst:481), lo mueve desde el tick siguiente.
func _soltar_botin() -> void:
	var sala: Node2D = get_parent() as Node2D
	var id_botin: String = PREFIJO_BOTIN + String(id)
	if ficha.botin <= 0 or sala == null or Partida.estado_de(Sala.clave_de(self), id_botin) != null:
		return
	var inicio: Vector2 = global_position + Vector2(0.0, -ficha.tamano.y / 2.0)
	var suelo: Dictionary = Capas.rayo_a_escenario(self, inicio, inicio + Vector2(0.0, ALCANCE_SUELO))
	var destino_y: float = (suelo["position"] as Vector2).y if not suelo.is_empty() else global_position.y
	var monedas: MonedasSueltas = ESCENA_MONEDAS.instantiate() as MonedasSueltas
	monedas.id = id_botin
	monedas.name = id_botin
	monedas.cantidad = roundi(ficha.botin * Partida.efectos_amuletos().botin_factor)
	monedas.position = sala.to_local(inicio)
	sala.add_child.call_deferred(monedas)
	# En ticks de fisica y por subpropiedad, en coordenadas de la sala (classes/class_tween.rst:274, :792 y :851). Atado
	# al monton: tomarlo a medio salto detiene el Tween sin error.
	var salto: Tween = sala.create_tween().bind_node(monedas).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	salto.tween_property(monedas, ^"position:y", monedas.position.y - SALTO_BOTIN, SUBIDA_BOTIN) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	salto.tween_property(monedas, ^"position:y", sala.to_local(Vector2(inicio.x, destino_y)).y, CAIDA_BOTIN) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


# La caja gris, solo sin dibujo; no depende de mirando, asi que no se redibuja al girar.
func _draw() -> void:
	if ficha != null and animacion == null:
		draw_rect(Rect2(-ficha.tamano.x / 2.0, -ficha.tamano.y, ficha.tamano.x, ficha.tamano.y), ficha.color)
