extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del dibujo del cuerpo del jugador: la tabla de prioridades de AnimacionJugador.elegir (una fila por caso), el
# giro en carrera como capa aparte, el reparto de cuadros por ticks, que cada animacion exista en el SpriteFrames, que
# cada cuadro mida lo mismo que el lienzo comun y que la muerte dure lo que la sala tarda en reaparecer. Deja casos y
# fallos para animacion_jugador.guion. Imprime el resumen y los fallos.

const RUTA_CUADROS: String = "res://nucleo/arte/jugador_hombre/jugador_hombre.tres"
const ESCENA_JUGADOR: String = "res://nucleo/jugador.tscn"
const A: GDScript = preload("res://nucleo/animacion_jugador.gd")


func _ready() -> void:
	_prioridades()
	_giro()
	_cola_ataque()
	_reparto()
	_recurso()
	_escena()
	_resumen()


# Cada caso pone lo minimo para una fila y, si hace falta, algo de una fila de menos prioridad que no debe ganar.
func _prioridades() -> void:
	var e: AnimacionJugador.Estado = AnimacionJugador.Estado.new()
	_es("sin nada, quieto", e, AnimacionJugador.QUIETO)
	e.velocidad = Vector2(360.0, 0.0)
	_es("en el suelo moviendose, correr", e, AnimacionJugador.CORRER)
	e.ticks_rebote = 3
	_es("empujado por un rebote, quieto (no camina)", e, AnimacionJugador.QUIETO)
	e = AnimacionJugador.Estado.new()
	e.velocidad = Vector2(756.0, 0.0)
	e.corriendo = true
	_es("en carrera, carrera (gana a correr)", e, AnimacionJugador.CARRERA)
	e.en_suelo = false
	_es("en el aire, aire (gana a la carrera)", e, AnimacionJugador.AIRE)
	e.en_pared = true
	_es("sostenido en la pared, pared (gana al aire)", e, AnimacionJugador.PARED)
	e.ticks_despegando = 5
	_es("despegando de la pared, saltar_pared", e, AnimacionJugador.SALTAR_PARED)
	e.ticks_impulsando = 6
	_es("impulso, gana a la pared", e, AnimacionJugador.IMPULSO)
	e.volteando = true
	_es("voltereta, gana al impulso", e, AnimacionJugador.VOLTERETA)
	e.ticks_hasta_ataque = 12
	_es("ataque al lado, gana a la voltereta (pegado a la pared tambien sale al lado)", e, AnimacionJugador.ATAQUE_LADO)
	e.atacando_arriba = true
	_es("ataque hacia arriba", e, AnimacionJugador.ATAQUE_ARRIBA)
	e.atacando_arriba = false
	e.atacando_abajo = true
	_es("ataque hacia abajo (pogo)", e, AnimacionJugador.ATAQUE_ABAJO)
	e.atacando_en_carrera = true
	_es("estocada, gana al ataque", e, AnimacionJugador.ESTOCADA)
	e.ticks_poder = 3
	_es("curar presionado (puede ser un toque), bola", e, AnimacionJugador.BOLA)
	e.ticks_poder = -1
	e.ticks_hasta_bola = 10
	_es("recarga de la bola, bola", e, AnimacionJugador.BOLA)
	e.curando = true
	_es("curando, gana a la bola", e, AnimacionJugador.CURAR)
	e.en_picada = true
	_es("en picada, gana a curar", e, AnimacionJugador.PICADA)
	e.preparando_picada = true
	_es("carga de la picada, gana a la picada", e, AnimacionJugador.PICADA_CARGA)
	e.ticks_aterrizando = 10
	_es("aterrizaje duro, gana a la picada", e, AnimacionJugador.ATERRIZAJE_DURO)
	e.ticks_retrocediendo = 5
	_es("retroceso, dano", e, AnimacionJugador.DANO)
	e.descansando = true
	_es("en el banco, dormir (gana al dano)", e, AnimacionJugador.DORMIR)
	e.ticks_hasta_reaparecer = 8
	_es("fundido de un peligro, dano (gana a dormir)", e, AnimacionJugador.DANO)
	e.muerto = true
	_es("muerto, muerte (gana a todo)", e, AnimacionJugador.MUERTE)


func _giro() -> void:
	var e: AnimacionJugador.Estado = AnimacionJugador.Estado.new()
	e.corriendo = true
	e.ticks_girando = 4
	_caso("giro: en el suelo, la carrera se tapa con giro_carrera",
			AnimacionJugador.con_giro(AnimacionJugador.elegir(e), e) == AnimacionJugador.GIRO_CARRERA)
	_caso("giro: elegir no conoce el giro (es una capa)", AnimacionJugador.elegir(e) == AnimacionJugador.CARRERA)
	e.en_suelo = false
	_caso("giro: en el aire no hay giro",
			AnimacionJugador.con_giro(AnimacionJugador.elegir(e), e) == AnimacionJugador.AIRE)
	e.en_suelo = true
	e.ticks_hasta_ataque = 10
	_caso("giro: no tapa un ataque",
			AnimacionJugador.con_giro(AnimacionJugador.elegir(e), e) == AnimacionJugador.ATAQUE_LADO)
	_caso("volteo: pegado a la pared mira hacia afuera; atacando en ella y en el aire, hacia donde mira",
			AnimacionJugador.volteo(AnimacionJugador.PARED, -1.0) == 1.0
			and AnimacionJugador.volteo(AnimacionJugador.ATAQUE_LADO, -1.0) == -1.0
			and AnimacionJugador.volteo(AnimacionJugador.AIRE, 1.0) == 1.0)


# La cola del ataque (tras el golpe, hasta ticks_entre_ataques) no vuelve si algo la interrumpio: ticks_hasta_ataque
# no baja mientras el jugador no puede atacar.
func _cola_ataque() -> void:
	var e: AnimacionJugador.Estado = AnimacionJugador.Estado.new()
	e.ticks_hasta_ataque = 10
	_tras_cola("cola del ataque sin nada que la corte, ataque al lado", e, AnimacionJugador.ATAQUE_LADO)
	e.curando = true
	_tras_cola("cola del ataque durante curar, curar", e, AnimacionJugador.CURAR)
	e.curando = false
	_tras_cola("cola del ataque tras curar, no vuelve: quieto", e, AnimacionJugador.QUIETO)
	e.ticks_atacando = 7
	e.ticks_hasta_ataque = 19
	_tras_cola("un golpe nuevo abre la cola otra vez, ataque al lado", e, AnimacionJugador.ATAQUE_LADO)
	e.ticks_atacando = 0
	e.ticks_hasta_ataque = 10
	e.hablando = true
	_tras_cola("cola del ataque al hablar, quieto", e, AnimacionJugador.QUIETO)
	e.hablando = false
	e.ticks_atacando = 7
	_tras_cola("golpe nuevo tras hablar", e, AnimacionJugador.ATAQUE_LADO)
	e.ticks_atacando = 0
	e.ticks_congelado = 20
	_tras_cola("cola del ataque en la pausa tras un peligro, quieto", e, AnimacionJugador.QUIETO)
	e.ticks_congelado = 0
	e.corriendo = true
	e.atacando_en_carrera = true
	e.ticks_atacando = 7
	e.ticks_hasta_ataque = 19
	_tras_cola("estocada en carrera", e, AnimacionJugador.ESTOCADA)
	e.atacando_en_carrera = false
	e.ticks_atacando = 0
	e.ticks_hasta_ataque = 12
	_tras_cola("tras la estocada, sigue la carrera y no el ataque al lado", e, AnimacionJugador.CARRERA)


func _reparto() -> void:
	var tres: PackedFloat32Array = [4.2, 6.6, 9.0]
	_caso("reparto: el primer tick del ataque es el cuadro 1", AnimacionJugador.repartir(0, 20, tres) == 0)
	_caso("reparto: a la mitad del ataque, el cuadro 2", AnimacionJugador.repartir(8, 20, tres) == 1)
	_caso("reparto: el ultimo tick, el cuadro 3", AnimacionJugador.repartir(19, 20, tres) == 2)
	_caso("reparto desde el cuadro 2: el primer tick es el 2 y el ultimo el 3",
			AnimacionJugador.repartir(0, 18, tres, 1) == 1 and AnimacionJugador.repartir(17, 18, tres, 1) == 2)
	var e: AnimacionJugador.Estado = AnimacionJugador.Estado.new()
	e.en_suelo = false
	e.velocidad = Vector2(0.0, -900.0)
	var sube: int = AnimacionJugador.cuadro(AnimacionJugador.AIRE, e, PackedFloat32Array())
	e.velocidad = Vector2(0.0, 1200.0)
	var cae: int = AnimacionJugador.cuadro(AnimacionJugador.AIRE, e, PackedFloat32Array())
	_caso("aire: subiendo el cuadro 2 y cayendo el 5", sube == 1 and cae == 4)
	_caso("los bucles los corre el sprite (cuadro -1)",
			AnimacionJugador.cuadro(AnimacionJugador.CORRER, e, PackedFloat32Array()) == -1)


func _recurso() -> void:
	var cuadros: SpriteFrames = load(RUTA_CUADROS) as SpriteFrames
	_caso("el SpriteFrames del hombre carga", cuadros != null)
	if cuadros == null:
		return
	var faltan: PackedStringArray = []
	for nombre: StringName in AnimacionJugador.TODAS:
		if not cuadros.has_animation(nombre) or cuadros.get_frame_count(nombre) == 0:
			faltan.append(String(nombre))
	_caso("cada animacion de AnimacionJugador existe y tiene cuadros (faltan: %s)" % ", ".join(faltan), faltan.is_empty())
	var lienzo: Vector2 = Vector2.ZERO
	var malos: PackedStringArray = []
	for nombre: StringName in cuadros.get_animation_names():
		for i: int in range(cuadros.get_frame_count(nombre)):
			var trozo: AtlasTexture = cuadros.get_frame_texture(nombre, i) as AtlasTexture
			if trozo == null:
				malos.append("%s %d no es AtlasTexture" % [nombre, i])
				continue
			if lienzo == Vector2.ZERO:
				lienzo = trozo.get_size()
			# Mide el lienzo y la region cabe dentro: margin.size no redimensiona el dibujo.
			var dentro: bool = (trozo.margin.position.x >= 0.0 and trozo.margin.position.y >= 0.0
					and trozo.margin.position.x + trozo.region.size.x <= lienzo.x
					and trozo.margin.position.y + trozo.region.size.y <= lienzo.y)
			if trozo.get_size() != lienzo or not dentro or not trozo.filter_clip:
				malos.append("%s %d" % [nombre, i])
	_caso("cada cuadro mide lo mismo que el lienzo, cabe en el y recorta su filtro (malos: %s)" % ", ".join(malos),
			malos.is_empty() and lienzo != Vector2.ZERO)
	# La muerte dura lo que la sala tarda en reaparecer; dormir no tiene una constante en ticks (el bucle sigue hasta
	# levantarse), asi que no se compara.
	_caso("la muerte dura Sala.TICKS_PARA_REAPARECER ticks",
			is_equal_approx(_segundos(cuadros, AnimacionJugador.MUERTE) * 60.0, float(Sala.TICKS_PARA_REAPARECER)))
	_caso("la muerte y sentarse no se repiten; dormir si",
			cuadros.get_animation_loop_mode(AnimacionJugador.MUERTE) == SpriteFrames.LOOP_NONE
			and cuadros.get_animation_loop_mode(AnimacionJugador.SENTARSE) == SpriteFrames.LOOP_NONE
			and cuadros.get_animation_loop_mode(AnimacionJugador.DORMIR) != SpriteFrames.LOOP_NONE)
	# Eje del lienzo en x = 158 (offset del Dibujo); la mano del cuadro 1 empieza en x = 68: 90 px detras, menos 40.
	var separacion: float = AnimacionJugador.separacion_pared(cuadros, 158.0, 40.0)
	_caso("pared: el cuerpo se aparta 50 px para que la mano toque la pared (dio %s)" % separacion,
			is_equal_approx(separacion, 50.0))
	# La escala de la hoja del ataque vertical salia de la katana y no de la mascara: el cuerpo quedaba al 71 %
	# (docs/errores/2026-10-24-ataque-vertical-encogido.md). De pie con el brazo arriba mide al menos lo que quieto.
	var alto_arriba: float = _mas_alto(cuadros, AnimacionJugador.ATAQUE_ARRIBA)
	var alto_quieto: float = _mas_alto(cuadros, AnimacionJugador.QUIETO)
	_caso("ataque arriba: el cuerpo no se encoge (%s px contra %s de quieto)" % [alto_arriba, alto_quieto],
			alto_arriba >= alto_quieto)
	# Tendido, el cuerpo se apoya en el suelo como quieto: el borde de abajo de cada cuadro en el del lienzo
	# (docs/errores/2026-10-24-hueco-al-morir.md).
	var en_el_aire: PackedStringArray = []
	for i: int in range(cuadros.get_frame_count(AnimacionJugador.MUERTE)):
		var trozo: AtlasTexture = cuadros.get_frame_texture(AnimacionJugador.MUERTE, i) as AtlasTexture
		var hueco: float = lienzo.y - trozo.margin.position.y - trozo.region.size.y
		if not is_zero_approx(hueco):
			en_el_aire.append("%d a %s px" % [i, hueco])
	_caso("muerte: el cuerpo toca el suelo (en el aire: %s)" % ", ".join(en_el_aire), en_el_aire.is_empty())


func _escena() -> void:
	var escena: PackedScene = load(ESCENA_JUGADOR) as PackedScene
	var jugador: Node = escena.instantiate()
	var dibujo: AnimatedSprite2D = jugador.get_node_or_null(^"Dibujo") as AnimatedSprite2D
	var bien: bool = (dibujo != null and dibujo.sprite_frames != null
			and dibujo.sprite_frames.resource_path == RUTA_CUADROS and not dibujo.centered
			and dibujo.show_behind_parent and dibujo.material is ShaderMaterial)
	_caso("el Dibujo del jugador usa el SpriteFrames, sin centrar, detras de los efectos y con el destello", bien)
	jugador.free()


func _es(que: String, e: AnimacionJugador.Estado, esperado: StringName) -> void:
	var dio: StringName = AnimacionJugador.elegir(e)
	_caso("%s (dio %s)" % [que, dio], dio == esperado)


func _tras_cola(que: String, e: AnimacionJugador.Estado, esperado: StringName) -> void:
	AnimacionJugador.actualizar_cola_ataque(e)
	_es(que, e, esperado)


# Alto del cuadro mas alto de una animacion (su region, sin el margen).
func _mas_alto(cuadros: SpriteFrames, nombre: StringName) -> float:
	var alto: float = 0.0
	for i: int in range(cuadros.get_frame_count(nombre)):
		alto = maxf(alto, (cuadros.get_frame_texture(nombre, i) as AtlasTexture).region.size.y)
	return alto


func _segundos(cuadros: SpriteFrames, nombre: StringName) -> float:
	var suma: float = 0.0
	for i: int in range(cuadros.get_frame_count(nombre)):
		suma += cuadros.get_frame_duration(nombre, i)
	return suma / cuadros.get_animation_speed(nombre)
