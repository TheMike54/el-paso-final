extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del dibujo de un Enemigo (animacion): quieto al aparecer, el reflejo al cambiar mirando, animar() y la pausa
# del dibujo durante el congelado. Arma el enemigo en codigo con la ficha del debil de prueba (sin comportamiento) y
# unos SpriteFrames con dos animaciones, sin sala. Deja casos y fallos para enemigo_arte.guion.

const ENEMIGO: String = "res://nucleo/enemigo.tscn"
const FICHA: String = "res://herramientas/salas/fichas/enemigo_debil.tres"


func _ready() -> void:
	Congelado.reiniciar()
	var cuadros: SpriteFrames = SpriteFrames.new()
	for nombre: StringName in [&"quieto", &"caminar"]:
		cuadros.add_animation(nombre)
		cuadros.add_frame(nombre, PlaceholderTexture2D.new())
	var dibujo: AnimatedSprite2D = AnimatedSprite2D.new()
	dibujo.sprite_frames = cuadros
	dibujo.animation = &"caminar"
	dibujo.scale = Vector2(0.5, 0.5)
	var enemigo: Enemigo = (load(ENEMIGO) as PackedScene).instantiate() as Enemigo
	enemigo.ficha = load(FICHA) as FichaEnemigo
	enemigo.id = &"arte"
	enemigo.add_child(dibujo)
	enemigo.animacion = dibujo
	add_child(enemigo)

	_caso("al aparecer toca quieto aunque la escena diga otra", dibujo.animation == &"quieto" and dibujo.is_playing())
	_caso("mirando a la izquierda, el dibujo se refleja sin perder su escala", is_equal_approx(dibujo.scale.x, -0.5))
	enemigo.mirando = 1.0
	_caso("al cambiar mirando, el dibujo se voltea solo", is_equal_approx(dibujo.scale.x, 0.5))
	enemigo.mirando = 0.0
	enemigo.mirando = -1.0
	_caso("un mirando de 0 no borra el dibujo", is_equal_approx(dibujo.scale.x, -0.5))
	enemigo.animar(&"caminar")
	_caso("animar toca una animacion que tiene", dibujo.animation == &"caminar")
	enemigo.animar(&"no_existe")
	_caso("animar ignora una que no tiene", dibujo.animation == &"caminar")

	await _esperar(2)
	_caso("fuera del congelado el dibujo corre", dibujo.speed_scale == 1.0)
	Congelado.pedir(6)
	await _esperar(2)
	_caso("durante el congelado el dibujo se detiene", dibujo.speed_scale == 0.0)
	await _esperar(8)
	_caso("al terminar el congelado vuelve a correr", dibujo.speed_scale == 1.0)

	enemigo.queue_free()
	Congelado.reiniciar()
	_resumen()
