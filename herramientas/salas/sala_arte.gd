extends Sala
# Sala de arte y rendimiento: capas Parallax2D con imagenes generadas con IA (docs/uso-de-ia.md), variantes
# alternadas y espejadas, adornos sembrados al azar, animaciones y particulas, para medir FPS en alto y en bajo
# (Recursos.bajos()) en cada telefono y ver como evitar que el fondo se repita. Los botones de arriba apagan cada grupo.
# La decoracion se arma en _ready, asi que el presupuesto del validador no la cuenta: es a proposito, es una sala de
# medicion.

const T: String = "res://herramientas/salas/arte/"
const ANCHO: float = 6400.0
const PISO: float = 1040.0

var _etiqueta: Label = null
var _azar: RandomNumberGenerator = RandomNumberGenerator.new()
var _bajo: bool = false
var _acumulado: float = 0.0
# Grupos que se apagan con los botones de arriba, para medir cuanto cuesta cada uno.
var _emisores: Array[CPUParticles2D] = []
var _tweens: Array[Tween] = []
var _niebla: Sprite2D = null
var _capa_frente: Parallax2D = null


func _ready() -> void:
	_azar.seed = 1309
	_bajo = Recursos.bajos()
	_armar()
	super._ready()
	_medidor()


func _armar() -> void:
	# Cielo: dos fotos de ESCOM de noche alternadas (bajo: una sola).
	var cielo: Parallax2D = _capa("Cielo", 0.1, -100)
	var cielos: Array[String] = ["cielo_escom", "cielo_escom_2"]
	if _bajo:
		cielos = ["cielo_escom", "cielo_escom"]
	_tira(cielo, cielos, 1.0, -120.0, Color(0.55, 0.6, 0.85), false)
	# Cueva lejana: una imagen, normal y espejada, a una escala que no coincide con las otras capas.
	var lejana: Parallax2D = _capa("Lejana", 0.3, -90)
	_tira(lejana, ["lejana1", "lejana1"], 1.7, 120.0, Color(0.5, 0.55, 0.7), true)
	# Plano medio: la franja baja de dos imagenes de distinto ancho, la primera tambien espejada: el patron se
	# repite cada 5840 px, y deja ver arriba la cueva y el cielo.
	var fondo: Parallax2D = _capa("Fondo", 0.6, -80)
	var fondos: Array[String] = ["fondo1", "fondo2", "fondo1"]
	if _bajo:
		fondos = ["fondo1", "fondo2"]
	_tira(fondo, fondos, 1.25, PISO - 420.0, Color(0.75, 0.75, 0.85), true)
	# Suelo pintado, a la velocidad del jugador.
	var suelo: Node2D = Node2D.new()
	suelo.name = "SueloPintado"
	suelo.z_index = -10
	add_child(suelo)
	var x: float = 0.0
	var i: int = 0
	while x < ANCHO:
		var s: Sprite2D = _sprite("suelo", Vector2(x, PISO - 40.0), 1.0, i % 2 == 1)
		s.centered = false
		suelo.add_child(s)
		x += 1344.0
		i += 1
	_adornos()
	if not _bajo:
		_frente()
	_particulas()


func _capa(nombre: String, escala: float, z: int) -> Parallax2D:
	var capa: Parallax2D = Parallax2D.new()
	capa.name = nombre
	capa.scroll_scale = Vector2(escala, escala)
	capa.z_index = z
	add_child(capa)
	return capa


# Una tira de imagenes seguidas que se repite: repeat_size es la suma de sus anchos.
func _tira(capa: Parallax2D, nombres: Array[String], escala: float, y: float, tinte: Color, espejar_alternas: bool) -> void:
	var x: float = 0.0
	for k: int in range(nombres.size()):
		var s: Sprite2D = _sprite(nombres[k], Vector2(x, y), escala, espejar_alternas and k % 2 == 1)
		s.centered = false
		s.modulate = tinte
		capa.add_child(s)
		x += s.texture.get_width() * escala
	capa.repeat_size = Vector2(x, 0.0)
	capa.repeat_times = 3


func _sprite(nombre: String, posicion: Vector2, escala: float, espejo: bool) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.texture = load(T + nombre + ".png") as Texture2D
	s.position = posicion
	s.scale = Vector2(escala, escala)
	s.flip_h = espejo
	return s


# Adornos sembrados con semilla fija: escala, espejo y tinte al azar para que no se lean como copias.
func _adornos() -> void:
	var capa: Node2D = Node2D.new()
	capa.name = "Adornos"
	capa.z_index = -5
	add_child(capa)
	var cuantos: int = 5 if _bajo else 12
	for k: int in range(cuantos):
		var nombre: String = ["hongos", "hongos_2", "tronco"][k % 3]
		var escala: float = _azar.randf_range(0.35, 0.7)
		var s: Sprite2D = _sprite(nombre, Vector2(_azar.randf_range(400.0, ANCHO - 400.0), PISO), escala, _azar.randf() < 0.5)
		s.offset = Vector2(0.0, -s.texture.get_height() / 2.0)
		s.modulate = Color(1.0, 1.0, 1.0).darkened(_azar.randf_range(0.0, 0.3))
		capa.add_child(s)
		if nombre != "tronco" and not _bajo:
			_latir(s, escala)
	var banco: Sprite2D = _sprite("banco", Vector2(1800.0, PISO), 0.6, false)
	banco.offset = Vector2(0.0, -banco.texture.get_height() / 2.0)
	capa.add_child(banco)
	var alumno: Sprite2D = _sprite("alumno", Vector2(2600.0, PISO), 0.45, true)
	alumno.offset = Vector2(0.0, -alumno.texture.get_height() / 2.0)
	capa.add_child(alumno)
	if not _bajo:
		var t: Tween = alumno.create_tween().set_loops()
		_tweens.append(t)
		t.tween_property(alumno, "scale:y", 0.47, 0.6).set_trans(Tween.TRANS_SINE)
		t.tween_property(alumno, "scale:y", 0.45, 0.6).set_trans(Tween.TRANS_SINE)


# Los hongos brillan y respiran a destiempo.
func _latir(s: Sprite2D, escala: float) -> void:
	var t: Tween = s.create_tween().set_loops()
	_tweens.append(t)
	var dur: float = _azar.randf_range(0.9, 1.6)
	t.tween_property(s, "modulate", Color(1.4, 1.6, 1.5), dur).set_trans(Tween.TRANS_SINE)
	t.parallel().tween_property(s, "scale", Vector2(escala * 1.04, escala * 0.97), dur).set_trans(Tween.TRANS_SINE)
	t.tween_property(s, "modulate", s.modulate, dur).set_trans(Tween.TRANS_SINE)
	t.parallel().tween_property(s, "scale", Vector2(escala, escala), dur).set_trans(Tween.TRANS_SINE)


# Raices colgando delante, oscuras, que se mecen; y niebla que cruza.
func _frente() -> void:
	var frente: Parallax2D = _capa("Frente", 1.3, 20)
	_capa_frente = frente
	frente.repeat_size = Vector2(3100.0, 0.0)
	frente.repeat_times = 3
	for k: int in range(4):
		var s: Sprite2D = _sprite("raiz", Vector2(k * 775.0 + _azar.randf_range(0.0, 300.0), -40.0), _azar.randf_range(0.6, 0.95), k % 2 == 0)
		s.offset = Vector2(0.0, s.texture.get_height() / 2.0)
		s.modulate = Color(0.25, 0.25, 0.3)
		frente.add_child(s)
		var t: Tween = s.create_tween().set_loops()
		_tweens.append(t)
		var dur: float = _azar.randf_range(1.8, 2.8)
		t.tween_property(s, "rotation", 0.05, dur).set_trans(Tween.TRANS_SINE)
		t.tween_property(s, "rotation", -0.05, dur).set_trans(Tween.TRANS_SINE)
	var niebla: Sprite2D = _sprite("lejana1", Vector2(0.0, 600.0), 2.5, false)
	niebla.modulate = Color(0.6, 0.8, 0.8, 0.12)
	add_child(niebla)
	niebla.z_index = 21
	_niebla = niebla
	var tn: Tween = niebla.create_tween().set_loops()
	tn.tween_property(niebla, "position:x", 1500.0, 12.0)
	tn.tween_property(niebla, "position:x", 0.0, 12.0)


func _particulas() -> void:
	var aditivo: CanvasItemMaterial = CanvasItemMaterial.new()
	aditivo.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	var tramos: int = 1 if _bajo else 4
	for k: int in range(tramos):
		var centro: float = (k + 0.5) * ANCHO / tramos
		_emisor("Esporas%d" % k, Vector2(centro, PISO - 200.0), Vector2(ANCHO / tramos / 2.0, 200.0), 20 if _bajo else 60, Color(0.4, 1.0, 0.8), 3.0, 6.0, aditivo, Vector2(0.0, -25.0))
		if not _bajo:
			_emisor("Luciernagas%d" % k, Vector2(centro, PISO - 450.0), Vector2(ANCHO / tramos / 2.0, 300.0), 25, Color(0.9, 1.0, 0.4), 6.0, 10.0, aditivo, Vector2.ZERO)
			_emisor("Polvo%d" % k, Vector2(centro, PISO - 500.0), Vector2(ANCHO / tramos / 2.0, 500.0), 40, Color(1.0, 1.0, 1.0, 0.35), 1.5, 3.0, null, Vector2(8.0, 5.0))


func _emisor(nombre: String, centro: Vector2, medio: Vector2, cantidad: int, color: Color, tam_min: float, tam_max: float, material_: Material, gravedad: Vector2) -> void:
	var p: CPUParticles2D = CPUParticles2D.new()
	p.name = nombre
	p.position = centro
	p.amount = cantidad
	p.lifetime = 5.0
	p.preprocess = 5.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = medio
	p.direction = Vector2(0.0, -1.0)
	p.spread = 180.0
	p.initial_velocity_min = 5.0
	p.initial_velocity_max = 25.0
	p.gravity = gravedad
	p.scale_amount_min = tam_min
	p.scale_amount_max = tam_max
	p.color = color
	var rampa: Gradient = Gradient.new()
	rampa.set_color(0, Color(color, 0.0))
	rampa.set_color(1, Color(color, 0.0))
	rampa.add_point(0.3, color)
	rampa.add_point(0.7, color)
	p.color_ramp = rampa
	if material_ != null:
		p.material = material_
	p.z_index = 5
	add_child(p)
	_emisores.append(p)


func _medidor() -> void:
	var capa: CanvasLayer = CanvasLayer.new()
	capa.layer = 11
	add_child(capa)
	_etiqueta = Label.new()
	_etiqueta.position = Vector2(560.0, 8.0)
	_etiqueta.add_theme_font_size_override(&"font_size", 28)
	capa.add_child(_etiqueta)
	var x: float = 120.0
	for nombre: String in ["Part", "Frente", "Niebla", "Anim"]:
		var b: Button = Button.new()
		b.text = nombre
		b.toggle_mode = true
		b.position = Vector2(x, 60.0)
		b.custom_minimum_size = Vector2(150.0, 70.0)
		b.focus_mode = Control.FOCUS_NONE
		b.toggled.connect(_apagar.bind(nombre))
		capa.add_child(b)
		x += 170.0


# Boton hundido = grupo apagado.
func _apagar(apagado: bool, nombre: String) -> void:
	match nombre:
		"Part":
			for p: CPUParticles2D in _emisores:
				p.emitting = not apagado
				p.visible = not apagado
		"Frente":
			if _capa_frente != null:
				_capa_frente.visible = not apagado
		"Niebla":
			if _niebla != null:
				_niebla.visible = not apagado
		"Anim":
			for t: Tween in _tweens:
				if apagado:
					t.pause()
				else:
					t.play()


func _process(delta: float) -> void:
	_acumulado += delta
	if _acumulado >= 0.5 and _etiqueta != null:
		_acumulado = 0.0
		_etiqueta.text = "%s  %d FPS" % ["BAJO" if _bajo else "ALTO", Engine.get_frames_per_second()]
