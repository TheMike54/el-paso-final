extends Node2D
# Medicion del tiron al primer uso de un efecto: sin sala, con una camara fija, hace aparecer cada efecto con particulas
# del juego dos veces seguidas y escribe el peor cuadro de cada aparicion. Si la primera cuesta mucho mas que la
# segunda, es la compilacion del shader. Antes de medir pone el CalentadorShaders del menu (sin el, con calentar en
# false). Como se corre en el telefono: docs/pruebas.md, «Medicion del primer uso».

## Efectos que se miden, en este orden; los dos primeros son las dos variantes de shader que calienta el menu.
const EFECTOS: Array[String] = ["escombros", "polvo_cucaracha", "polvo_tubo", "corte"]
const ESCENA_POLVO_CUCARACHA: String = "res://contenido/enemigos/cucaracha/polvo_cucaracha.tscn"
const ESCENA_POLVO_TUBO: String = "res://contenido/objetos/celda/polvo_tubo.tscn"
## Cuadros que se miden por aparicion y cuadros de pausa entre una y otra.
const CUADROS_EFECTO: int = 45
const CUADROS_PAUSA: int = 30
## Cuadros que se esperan al empezar y tras el calentador.
const CUADROS_ASENTAR: int = 120

## Con false no se pone el calentador: es el A del A/B. Se cambia aqui en la copia del APK de medicion (los argumentos
## de linea de comandos no estan comprobados en Android).
var calentar: bool = true


func _ready() -> void:
	for argumento: String in OS.get_cmdline_user_args():
		if argumento == "--calentar=no":
			calentar = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Master"), true)
	if not Ajustes.sin_ventana():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var fondo: ColorRect = ColorRect.new()
	fondo.color = Color(0.1, 0.1, 0.12)
	fondo.size = Vector2(1280.0, 720.0)
	add_child(fondo)
	var camara: Camera2D = Camera2D.new()
	camara.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	add_child(camara)
	camara.make_current()
	_empezar.call_deferred()


func _empezar() -> void:
	Engine.max_fps = 0
	print("PRIMER_USO inicio so=%s modelo=%s vsync=%d calentar=%s" % [OS.get_name(), OS.get_model_name(),
		DisplayServer.window_get_vsync_mode(), "si" if calentar else "no"])
	await _cuadros(CUADROS_ASENTAR)
	if calentar:
		var calentador: CalentadorShaders = CalentadorShaders.new()
		add_child(calentador)
		move_child(calentador, 0)
		var dato_calentar: Vector2 = await _medir(CalentadorShaders.CUADROS + 2)
		print("PRIMER_USO calentador peor_ms=%.1f" % dato_calentar.x)
		await _cuadros(CUADROS_ASENTAR)
	var base: Vector2 = await _medir(CUADROS_EFECTO)
	print("PRIMER_USO efecto=ninguno peor_ms=%.1f media_ms=%.1f" % [base.x, base.y])
	for efecto: String in EFECTOS:
		for vez: int in [1, 2]:
			var nodo: CPUParticles2D = _crear(efecto)
			nodo.position = Vector2(640.0, 400.0)
			add_child(nodo)
			nodo.emitting = true
			var dato: Vector2 = await _medir(CUADROS_EFECTO)
			print("PRIMER_USO efecto=%s vez=%d peor_ms=%.1f media_ms=%.1f" % [efecto, vez, dato.x, dato.y])
			nodo.queue_free()
			await _cuadros(CUADROS_PAUSA)
	print("PRIMER_USO FIN")
	get_tree().quit()


func _crear(efecto: String) -> CPUParticles2D:
	match efecto:
		"polvo_cucaracha":
			return (load(ESCENA_POLVO_CUCARACHA) as PackedScene).instantiate() as CPUParticles2D
		"polvo_tubo":
			return (load(ESCENA_POLVO_TUBO) as PackedScene).instantiate() as CPUParticles2D
		"corte":
			var corte: CPUParticles2D = CPUParticles2D.new()
			corte.one_shot = true
			corte.amount = 8
			corte.explosiveness = 1.0
			corte.color = Color(0.4, 0.7, 0.3)
			corte.scale_amount_min = 3.0
			corte.scale_amount_max = 5.0
			return corte
	# escombros, con los valores de nucleo/muro_rompible.gd
	var particulas: CPUParticles2D = CPUParticles2D.new()
	particulas.one_shot = true
	particulas.amount = 12
	particulas.lifetime = 0.6
	particulas.explosiveness = 1.0
	particulas.direction = Vector2.UP
	particulas.spread = 80.0
	particulas.initial_velocity_min = 150.0
	particulas.initial_velocity_max = 320.0
	particulas.gravity = Vector2(0.0, 900.0)
	particulas.scale_amount_min = 6.0
	particulas.scale_amount_max = 12.0
	particulas.color = Color(0.5, 0.45, 0.4)
	return particulas


# Devuelve (peor cuadro, cuadro medio) en ms durante n cuadros.
func _medir(n: int) -> Vector2:
	var peor: int = 0
	var inicio: int = Time.get_ticks_usec()
	var anterior: int = inicio
	for i: int in range(n):
		await get_tree().process_frame
		var ahora: int = Time.get_ticks_usec()
		peor = maxi(peor, ahora - anterior)
		anterior = ahora
	return Vector2(float(peor) / 1000.0, float(Time.get_ticks_usec() - inicio) / 1000.0 / float(n))


func _cuadros(n: int) -> void:
	for i: int in range(n):
		await get_tree().process_frame
