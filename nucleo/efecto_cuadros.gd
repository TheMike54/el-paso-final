class_name EfectoCuadros
extends Sprite2D
# Efecto dibujado como hoja de cuadros (las de herramientas/generar_efectos.gd): avanza un cuadro cada
# TICKS_POR_CUADRO ticks de fisica, en bucle o una sola vez y entonces se libera. Sin luz, para que la oscuridad de la
# sala no lo apague; con mezcla aditiva si es luz (el destello del parry). Lo usan el parry, la bola y curar, y lo
# puede usar cualquier enemigo: un efecto nuevo es una hoja y una llamada a crear().

## 20 cuadros/s, la velocidad a la que se dibujaron las hojas.
const TICKS_POR_CUADRO: int = 3
# Material sin luz con mezcla normal, uno para todo el juego (gpu_optimization.rst:85): el mismo recurso que usan
# las escenas (resources.rst:30). Privado: desde el codigo se pide con material_sin_luz(), una sola entrada.
const _SIN_LUZ: CanvasItemMaterial = preload("res://nucleo/arte/sin_luz.tres")

## Fila de la hoja que se muestra (la bola usa la segunda al salir).
var fila: int = 0

var _cuadros: int = 1
var _una_vez: bool = false
var _corre_congelado: bool = false
var _tick: int = 0


## Un efecto con la hoja textura de cuadros x filas. aditivo: es luz (suma al fondo). una_vez: se libera al acabar.
## corre_congelado: sigue durante el congelado comun (el destello del parry se ve mientras todo esta quieto).
static func crear(textura: Texture2D, cuadros: int, filas: int, aditivo: bool, una_vez: bool,
		corre_congelado: bool) -> EfectoCuadros:
	var efecto: EfectoCuadros = EfectoCuadros.new()
	efecto.texture = textura
	efecto.hframes = cuadros
	efecto.vframes = filas
	efecto.material = LuzSala.material_aditivo() if aditivo else material_sin_luz()
	efecto._cuadros = cuadros
	efecto._una_vez = una_vez
	efecto._corre_congelado = corre_congelado
	return efecto


## Material sin luz con mezcla normal, compartido (tambien el de TrazoAtaque).
static func material_sin_luz() -> CanvasItemMaterial:
	return _SIN_LUZ


func _ready() -> void:
	frame_coords = Vector2i(0, fila)


func _physics_process(_delta: float) -> void:
	if Congelado.activo() and not _corre_congelado:
		return
	_tick += 1
	var cuadro: int = floori(float(_tick) / TICKS_POR_CUADRO)
	if _una_vez and cuadro >= _cuadros:
		queue_free()
		return
	frame_coords = Vector2i(cuadro % _cuadros, fila)


## Vuelve al primer cuadro (al volver a mostrar un efecto en bucle que se oculto).
func reiniciar() -> void:
	_tick = 0
	frame_coords = Vector2i(0, fila)
