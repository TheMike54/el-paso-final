extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del Npc con dibujo animado sobre la sala Dialogo: un AnimatedSprite2D armado aqui (sin arte) hace quieto,
# hablar con la caja abierta y entregar al terminar contando, que vuelve a quieto; el Npc se voltea hacia el jugador
# con una zona muerta. Asi ningun script de sala anima un NPC: el dibujo y el volteo los lleva el Npc. Su guion lee
# casos y fallos.

const ESCENA_SALA: PackedScene = preload("res://herramientas/salas/sala_dialogo.tscn")
const RUTA: String = "user://prueba_npc.json"

var _terminadas: int = 0


func _ready() -> void:
	_aislar_partida(RUTA)
	var sala: Sala = ESCENA_SALA.instantiate() as Sala
	var npc: Npc = sala.get_node(^"Guia") as Npc
	var dibujo: AnimatedSprite2D = AnimatedSprite2D.new()
	dibujo.name = "Dibujo"
	dibujo.sprite_frames = _cuadros()
	npc.add_child(dibujo)
	npc.animacion = dibujo
	add_child(sala)
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	npc.conversacion_terminada.connect(func(_etapa: int) -> void: _terminadas += 1)
	await _esperar(3)
	_caso("con dibujo no se pinta la forma provisional", not npc.sin_arte())
	_caso("al empezar, quieto", dibujo.animation == Npc.ANIM_QUIETO and dibujo.is_playing())

	# Se voltea hacia el jugador: el dibujo se refleja con scale.x y se queda asi dentro de la zona muerta.
	_poner(jugador, Vector2(300.0, 680.0))
	await _esperar(2)
	_caso("con el jugador a la izquierda mira a la izquierda", npc.mira < 0.0 and dibujo.scale.x < 0.0)
	_poner(jugador, Vector2(900.0, 680.0))
	await _esperar(2)
	_caso("con el jugador a la derecha mira a la derecha", npc.mira > 0.0 and dibujo.scale.x > 0.0)
	_poner(jugador, Vector2(npc.global_position.x - Npc.ZONA_MUERTA / 2.0, 680.0))
	await _esperar(2)
	_caso("dentro de la zona muerta no se voltea", npc.mira > 0.0)
	npc.mirar_al_jugador = false
	_poner(jugador, Vector2(300.0, 680.0))
	await _esperar(2)
	_caso("sin mirar_al_jugador no se voltea", npc.mira > 0.0 and dibujo.scale.x > 0.0)
	npc.mirar_al_jugador = true

	# Hablar mientras dura la caja; entregar al terminar contando y despues quieto.
	_poner(jugador, Vector2(npc.global_position.x, 680.0))
	await _esperar(40)
	await _presionar(&"interactuar")
	await _esperar(2)
	_caso("con la caja abierta, hablar", npc.caja != null and dibujo.animation == Npc.ANIM_HABLAR)
	npc.terminar(true)
	await _esperar(2)
	_caso("al terminar contando, entregar", npc.caja == null and dibujo.animation == Npc.ANIM_ENTREGAR and _terminadas == 1)
	await _esperar(40)
	_caso("acabada la entrega, vuelve a quieto", dibujo.animation == Npc.ANIM_QUIETO)
	npc.terminar(false)
	await _esperar(2)
	_caso("terminar sin contar no entrega", dibujo.animation == Npc.ANIM_QUIETO and _terminadas == 1)

	sala.queue_free()
	_restaurar_partida()
	_resumen()


# Tres animaciones de dos cuadros de 4x4 px; entregar sin bucle (5 cuadros por segundo: 0,4 s, unos 24 ticks).
func _cuadros() -> SpriteFrames:
	var cuadros: SpriteFrames = SpriteFrames.new()
	var textura: ImageTexture = ImageTexture.create_from_image(Image.create(4, 4, false, Image.FORMAT_RGBA8))
	for nombre: StringName in [Npc.ANIM_QUIETO, Npc.ANIM_HABLAR, Npc.ANIM_ENTREGAR]:
		cuadros.add_animation(nombre)
		cuadros.add_frame(nombre, textura)
		cuadros.add_frame(nombre, textura)
	cuadros.set_animation_loop(Npc.ANIM_ENTREGAR, false)
	return cuadros


func _poner(jugador: Jugador, punto: Vector2) -> void:
	jugador.global_position = punto
	jugador.velocity = Vector2.ZERO
