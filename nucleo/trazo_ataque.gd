class_name TrazoAtaque
extends Sprite2D
# Media luna blanca que deja un golpe (mockup de La Celda; el SlashEffect de Hollow Knight): aparece unos ticks
# despues de empezar el golpe, crece de 0,9 a 1,05 y se desvanece. Se coloca sobre el area de golpe de quien ataca,
# girada hacia donde pega y espejada al mirar a la izquierda. Cuenta ticks de fisica: se congela en la pausa y en el
# congelado comun. Sin luz: ni la oscuridad de la sala ni el brillo lo apagan (medido: queda en blanco puro).

enum Direccion {
	LADO,
	ARRIBA,
	ABAJO,
}

const TEXTURA: Texture2D = preload("res://nucleo/arte/trazo_ataque.png")
## Lado del trazo en pantalla, en px (el mockup: 190; la textura mide 256).
const LADO_PX: float = 190.0
## Ticks desde el golpe hasta que se ve (el mockup: 70 ms; Hollow Knight deja 50 ms vacios) y ticks que dura
## (el mockup: 140 ms).
const TICKS_RETRASO: int = 4
const TICKS_DURA: int = 8
## Donde va el centro del dibujo respecto del centro del area de golpe, con el golpe hacia +x: la parte que se ve de
## la media luna es la de delante, asi que el centro queda detras (mockup: 60 px delante de los pies contra los 90
## del area) y un poco arriba.
const DESDE_AREA: Vector2 = Vector2(-30.0, -5.0)

var _tick: int = -1
var _pose: Transform2D = Transform2D.IDENTITY


func _ready() -> void:
	texture = TEXTURA
	visible = false
	material = EfectoCuadros.material_sin_luz()
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if Congelado.activo():
		return
	_tick += 1
	var p: float = float(_tick - TICKS_RETRASO) / TICKS_DURA
	if p >= 1.0:
		visible = false
		set_physics_process(false)
		return
	visible = p >= 0.0
	if visible:
		transform = _pose.scaled_local(Vector2.ONE * (LADO_PX / TEXTURA.get_width() * lerpf(0.9, 1.05, p)))
		modulate.a = 0.95 * (1.0 - p * p)


## Empieza un trazo sobre el area de golpe con centro centro_area (en coordenadas del padre), hacia direccion y
## mirando (1 derecha, -1 izquierda).
func mostrar(centro_area: Vector2, direccion: Direccion, mirando: float) -> void:
	_pose = pose(centro_area, direccion, mirando)
	_tick = 0
	visible = false
	set_physics_process(true)


## Colocacion del trazo (sin su escala): el corrimiento DESDE_AREA girado hacia donde pega, espejado a la izquierda.
## De lado mira hacia mirando; arriba gira -90 grados y abajo +90, espejados tambien al mirar a la izquierda.
static func pose(centro_area: Vector2, direccion: Direccion, mirando: float) -> Transform2D:
	var espejo: float = -1.0 if mirando < 0.0 else 1.0
	var giro: float = 0.0
	match direccion:
		Direccion.ARRIBA:
			giro = -PI / 2.0 * espejo
		Direccion.ABAJO:
			giro = PI / 2.0 * espejo
	var base: Transform2D = Transform2D(giro, Vector2.ZERO).scaled_local(Vector2(espejo, 1.0))
	return Transform2D(base.x, base.y, centro_area + base * DESDE_AREA)
