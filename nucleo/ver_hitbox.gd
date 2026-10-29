class_name VerHitbox
extends Node2D
# Dibuja encima del juego cada forma de colision de la sala: rojo lo que dana, verde el suelo y las paredes, azul los
# cuerpos que se mueven (jugador, enemigos) y amarillo las demas areas (ataques, golpeables, puertas). Solo con el
# modo desarrollador y el ajuste ver_hitbox, al momento. debug_collisions_hint no sirve: no cambia en ejecucion.

const DANINO: Color = Color(1.0, 0.2, 0.2, 0.35)
const ESCENARIO: Color = Color(0.2, 1.0, 0.3, 0.3)
const CUERPO: Color = Color(0.3, 0.5, 1.0, 0.4)
const AREA: Color = Color(1.0, 0.9, 0.2, 0.3)
## Encima de todo lo de la sala (el frente usa z_index positivos chicos).
const Z: int = 100

var _formas: Array[CollisionShape2D] = []


func _ready() -> void:
	name = &"VerHitbox"
	z_index = Z
	z_as_relative = false
	top_level = true
	_aplicar()
	Eventos.ajuste_grafico_cambiado.connect(_al_cambiar_ajuste)


func _process(_delta: float) -> void:
	# Lo que se mueve cambia cada cuadro: se redibuja siempre mientras esta encendido (custom_drawing_in_2d.rst:122).
	queue_redraw()


func _draw() -> void:
	_formas.clear()
	_juntar(get_parent())
	for forma: CollisionShape2D in _formas:
		if forma.disabled or forma.shape == null:
			continue
		# Un area apagada (el ataque del jugador entre golpes) no toca nada: no se dibuja.
		var area: Area2D = forma.get_parent() as Area2D
		if area != null and not area.monitoring and not area.monitorable:
			continue
		draw_set_transform_matrix(forma.global_transform)
		var color: Color = color_de(forma.get_parent())
		var circulo: CircleShape2D = forma.shape as CircleShape2D
		if circulo != null:
			draw_circle(Vector2.ZERO, circulo.radius, color)
		else:
			var caja: Rect2 = forma.shape.get_rect()
			draw_rect(caja, color)
	draw_set_transform_matrix(Transform2D.IDENTITY)


## Color de la forma segun lo que es su dueno.
static func color_de(dueno: Node) -> Color:
	if dueno is DanoContacto:
		return DANINO
	if dueno is StaticBody2D:
		return ESCENARIO
	if dueno is CharacterBody2D:
		return CUERPO
	return AREA


func _juntar(nodo: Node) -> void:
	for hijo: Node in nodo.get_children():
		var forma: CollisionShape2D = hijo as CollisionShape2D
		if forma != null:
			_formas.append(forma)
		_juntar(hijo)


func _aplicar() -> void:
	visible = Ajustes.desarrollo(Ajustes.VER_HITBOX)
	set_process(visible)
	queue_redraw()


func _al_cambiar_ajuste(clave: StringName) -> void:
	if clave == Ajustes.VER_HITBOX or clave == Ajustes.MODO_DESARROLLADOR:
		_aplicar()
