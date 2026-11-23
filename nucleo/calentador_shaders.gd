class_name CalentadorShaders
extends Node2D
# Dibuja unos cuadros, tapada por el fondo del menu, una CPUParticles2D por cada variante de shader que usan los
# efectos del juego (sin material y sin luz). Compatibility compila cada variante la primera vez que se dibuja y la
# guarda en la cache de shaders: sin esto, el primer cuadro con escombros o polvo tardaba de 145 a 264 ms en el S50
# recien instalado (docs/errores/2026-11-22-tiron-primer-uso-particulas.md).

## Cuadros de proceso hasta quitarse; se dibuja en los anteriores (al menos dos), y el primero ya compila.
const CUADROS: int = 3
## Materiales de partículas del juego; null es el material por omisión. aditivo.tres comparte variante con
## sin_luz.tres (los dos son light_mode sin luz), asi que basta uno.
const MATERIALES: Array[Material] = [null, preload("res://nucleo/arte/sin_luz.tres")]

var _cuadros: int = 0


func _ready() -> void:
	for material_efecto: Material in MATERIALES:
		var particulas: CPUParticles2D = CPUParticles2D.new()
		particulas.material = material_efecto
		particulas.amount = 1
		particulas.lifetime = 1.0
		particulas.gravity = Vector2.ZERO
		particulas.position = Vector2(8.0, 8.0)
		add_child(particulas)
		particulas.emitting = true


func _process(_delta: float) -> void:
	_cuadros += 1
	if _cuadros >= CUADROS:
		set_process(false)
		queue_free()
