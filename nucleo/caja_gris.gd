extends CharacterBody2D
# Caja gris: cuerpo provisional que camina y salta con las acciones del InputMap.
# Existe para probar de punta a punta el arranque, el puerto de depuracion y el primer
# guion antes de programar al jugador. Se dibuja sola, sin ninguna imagen.
const VELOCIDAD: float = 300.0
const GRAVEDAD: float = 1800.0
const IMPULSO_SALTO: float = 700.0
const TAMANO: Vector2 = Vector2(80.0, 160.0)
const COLOR: Color = Color(0.55, 0.55, 0.55)


func _physics_process(delta: float) -> void:
	velocity.x = Input.get_axis(&"mover_izquierda", &"mover_derecha") * VELOCIDAD
	if not is_on_floor():
		velocity.y += GRAVEDAD * delta
	elif Input.is_action_just_pressed(&"saltar"):
		velocity.y = -IMPULSO_SALTO
	move_and_slide()


func _draw() -> void:
	draw_rect(Rect2(-TAMANO.x / 2.0, -TAMANO.y, TAMANO.x, TAMANO.y), COLOR)
