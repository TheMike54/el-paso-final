class_name LuzSala
extends Node2D
# Fuente de luz de una sala (tubo, hongo, chispa): un halo aditivo chico, que cuesta casi nada en el S50, y, solo con
# las luces 2D encendidas (Ajustes.luces_activas), una PointLight2D creada en codigo, asi una sala no puede traerla
# encendida a un telefono debil. Parpadeo, pulso y destello van con tiempo propio: quietos en la pausa y el congelado.

enum Tipo {
	FIJA,
	PARPADEO,
	PULSO,
	DESTELLO,
}

## Grupo de todas las luces de la sala: el panel de pruebas las apaga juntas.
const GRUPO: StringName = &"luces_sala"
## Lado de la textura del halo y de la luz: el radio se consigue con la escala.
const LADO: int = 128
## Halo sin luces 2D: radio por omision (fraccion de radio; cada pieza puede cambiarlo con halo_radio) y alfa medidos
## en La Celda (halos chicos, 25-oct-2026).
const HALO_RADIO: float = 0.55
const HALO_ALFA: float = 0.42
## Con luces 2D el halo baja: la luz ya aclara alrededor.
const HALO_ALFA_CON_LUZ: float = 0.22
## Fuerza de la luz sobre la oscuridad de la sala: 0,92 de la oscuridad (ajustada en La Celda, 25-oct-2026).
const FUERZA_LUZ: float = 0.92
## Segundos que tarda en apagarse un destello.
const DURACION_DESTELLO: float = 0.15
# Material aditivo sin sombreado, uno para todo el juego (tambien EfectoCuadros, el jugador y las escenas). Privado:
# desde el codigo se pide con material_aditivo(), para que haya una sola entrada.
const _ADITIVO: CanvasItemMaterial = preload("res://nucleo/arte/aditivo.tres")

static var _textura: GradientTexture2D = null

## Radio de la luz, en px.
@export var radio: float = 100.0
@export var tinte: Color = Color.WHITE
@export var tipo: Tipo = Tipo.FIJA
## Radio del halo como fraccion de radio. Un halo grande es una capa translucida grande (area_halo).
@export_range(0.1, 1.0, 0.01) var halo_radio: float = HALO_RADIO
## Px sobre la luz donde se corta el halo (el techo del que cuelga): asi no se ve luz en el piso de arriba ni en un
## nicho tapado. Negativo, sin corte. Solo el halo: la PointLight2D de las luces avanzadas (apagadas por omision) no
## se corta.
@export var corte_arriba: float = -1.0
## Imagen de la pieza encendida (opcional): sigue a la luz (visible en el parpadeo, alfa en el pulso y el destello).
@export var encendida: CanvasItem = null
## Pulso: fuerza media, cuanto sube y baja, y su velocidad en radianes por segundo.
@export var pulso_medio: float = 0.75
@export var pulso_amplitud: float = 0.15
@export var pulso_velocidad: float = 1.7
## Fuerza maxima de la luz (una lampara tenue: 0,8); el parpadeo, el pulso y el destello van de 0 a esto.
@export_range(0.0, 1.0, 0.01) var intensidad: float = 1.0
## Semilla del parpadeo; 0 la toma al azar. Las pruebas la fijan.
@export var semilla: int = 0

## Fuerza actual, de 0 a 1 (publica para las pruebas).
var fuerza: float = 1.0
var _tiempo: float = 0.0
var _siguiente: float = 0.0
var _cambios: int = 0
var _encendida_parpadeo: bool = true
var _azar: RandomNumberGenerator = RandomNumberGenerator.new()
var _halo: Sprite2D = null
var _luz: PointLight2D = null


func _ready() -> void:
	add_to_group(GRUPO)
	if semilla != 0:
		_azar.seed = semilla
	else:
		_azar.randomize()
	_siguiente = _azar.randf_range(3.0, 10.0)
	fuerza = 0.0 if tipo == Tipo.DESTELLO else 1.0
	_halo = Sprite2D.new()
	_halo.name = &"Halo"
	_halo.texture = textura()
	_halo.material = material_aditivo()
	_halo.modulate = tinte
	add_child(_halo)
	_recortar_halo()
	_poner_luz_2d()
	Eventos.ajuste_grafico_cambiado.connect(_al_cambiar_ajuste)
	_pintar()
	# La energia de la luz 2D depende de la oscuridad del Brillo, que la Sala crea en su _ready, despues que el de sus
	# hijos: se pinta otra vez al final del cuadro. Sin esto una luz FIJA (sin _process) quedaba con energia 0.
	_pintar.call_deferred()
	# Una luz fija no cambia: sin _process.
	set_process(tipo != Tipo.FIJA)


func _process(delta: float) -> void:
	if Congelado.activo():
		return
	avanzar(delta)


## Avanza el parpadeo, el pulso o el destello delta segundos y lo pinta.
func avanzar(delta: float) -> void:
	_tiempo += delta
	match tipo:
		Tipo.PARPADEO:
			_siguiente -= delta
			if _siguiente <= 0.0:
				# Un tren de 2 a 10 cambios rapidos y luego encendida de 3 a 10 s: el parpadeo de un tubo fluorescente.
				if _cambios == 0:
					_cambios = _azar.randi_range(2, 10) * 2
				_encendida_parpadeo = not _encendida_parpadeo
				_cambios -= 1
				_siguiente = _azar.randf_range(0.04, 0.16) if _cambios > 0 else _azar.randf_range(3.0, 10.0)
				if _cambios == 0:
					_encendida_parpadeo = true
			fuerza = 1.0 if _encendida_parpadeo else 0.0
		Tipo.PULSO:
			fuerza = pulso_medio + pulso_amplitud * sin(_tiempo * pulso_velocidad)
		Tipo.DESTELLO:
			fuerza = maxf(0.0, fuerza - delta / DURACION_DESTELLO)
	_pintar()


## Destello: enciende al maximo y se apaga solo (lo llama un EmisorRafaga al disparar).
func destellar() -> void:
	fuerza = 1.0
	_pintar()


## Textura comun del halo y de la luz: un degradado radial blanco que se tine con el color.
static func textura() -> GradientTexture2D:
	if _textura == null:
		var g: Gradient = Gradient.new()
		g.set_color(0, Color.WHITE)
		g.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
		_textura = GradientTexture2D.new()
		_textura.gradient = g
		_textura.fill = GradientTexture2D.FILL_RADIAL
		_textura.fill_from = Vector2(0.5, 0.5)
		_textura.fill_to = Vector2(1.0, 0.5)
		_textura.width = LADO
		_textura.height = LADO
	return _textura


## Rectangulo que cubre el halo, relativo a la luz: un cuadrado de lado 2 * radio * halo_radio, cortado arriba en
## -corte_arriba si corta. Estatico para que el validador lo calcule desde los exports sin correr _ready.
static func caja_halo(radio_luz: float, fraccion: float, corte: float) -> Rect2:
	var lado: float = 2.0 * radio_luz * fraccion
	var caja: Rect2 = Rect2(-lado / 2.0, -lado / 2.0, lado, lado)
	if corte >= 0.0 and corte < lado / 2.0:
		caja.position.y = -corte
		caja.size.y = lado / 2.0 + corte
	return caja


## Area en px del halo de esta luz (sin la escala de sus padres).
func area_halo() -> float:
	return caja_halo(radio, halo_radio, corte_arriba).get_area()


## Un solo material aditivo para todos los halos y destellos (gpu_optimization.rst:85; tambien EfectoCuadros):
## nucleo/arte/aditivo.tres, el mismo recurso que usan las escenas (resources.rst:30). Sin sombreado: la oscuridad de
## la sala (CanvasModulate) no apaga el halo (medido en La Celda: un sprite normal queda en 0,30 y uno sin sombreado
## en 1).
static func material_aditivo() -> CanvasItemMaterial:
	return _ADITIVO


func _pintar() -> void:
	var con_luz: bool = _luz != null
	_halo.visible = fuerza > 0.01
	_halo.scale = Vector2.ONE * (2.0 * radio * halo_radio / LADO)
	_halo.modulate.a = (HALO_ALFA_CON_LUZ if con_luz else HALO_ALFA) * fuerza * intensidad
	if con_luz:
		_luz.visible = fuerza > 0.01
		_luz.energy = _oscuridad() * FUERZA_LUZ * fuerza * intensidad
	if encendida != null:
		if tipo == Tipo.PARPADEO:
			encendida.visible = _encendida_parpadeo
		elif tipo != Tipo.FIJA:
			encendida.modulate.a = fuerza


# Con corte_arriba, el halo muestra solo las filas de su textura desde esa altura (region_rect,
# classes/class_sprite2d.rst:287): la region va de ahi al pie y el offset, en px de textura, deja el centro de la luz
# donde estaba. Mas barato que un clip_children o un LightOccluder2D, que no ocluye un sprite.
func _recortar_halo() -> void:
	var caja: Rect2 = caja_halo(radio, halo_radio, corte_arriba)
	var px_por_fila: float = 2.0 * radio * halo_radio / LADO
	var arriba: float = clampf(LADO / 2.0 + caja.position.y / px_por_fila, 0.0, LADO - 1.0)
	if arriba <= 0.0:
		return
	_halo.region_enabled = true
	_halo.region_rect = Rect2(0.0, arriba, LADO, LADO - arriba)
	_halo.offset = Vector2(0.0, arriba / 2.0)


# La PointLight2D existe solo con las luces 2D activas; se crea o se quita al momento, tambien desde la pausa.
func _poner_luz_2d() -> void:
	var quiere: bool = Ajustes.luces_activas()
	if quiere and _luz == null:
		_luz = PointLight2D.new()
		_luz.name = &"Luz"
		_luz.texture = textura()
		_luz.color = Color.WHITE.lerp(tinte, 0.3)
		_luz.texture_scale = 2.0 * radio / LADO
		add_child(_luz)
	elif not quiere and _luz != null:
		_luz.queue_free()
		_luz = null


func _oscuridad() -> float:
	return Brillo.instancia.oscuridad if is_instance_valid(Brillo.instancia) else 0.0


func _al_cambiar_ajuste(clave: StringName) -> void:
	if clave == Ajustes.LUCES_AVANZADAS:
		_poner_luz_2d()
		_pintar()
