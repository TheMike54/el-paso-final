extends Node
# Prueba del rango de la vista (nucleo/vista.gd): al entrar recorre una tabla de tamanos de ventana y
# compara la vista que devuelve Vista.calcular y si hay barras con lo esperado. Sin pantalla la vista
# real sigue en 1280x1280 (arranque.gd no aplica el rango): aqui solo se prueba la cuenta. Deja el
# resultado en "casos" y "fallos", que vista.guion lee. Imprime el resumen y los casos que fallan.

const MINIMA: float = 4.0 / 3.0
const MAXIMA: float = 22.0 / 9.0

var casos: int = 0
var fallos: int = 0


func _ready() -> void:
	# Ventana, vista esperada, barras esperadas.
	_caso("4:3", Vector2(1024.0, 768.0), Vector2(1280.0, 960.0), false)
	_caso("16:10", Vector2(1280.0, 800.0), Vector2(1280.0, 800.0), false)
	_caso("16:9", Vector2(1920.0, 1080.0), Vector2(1280.0, 720.0), false)
	_caso("20:9 (S20)", Vector2(2400.0, 1080.0), Vector2(1600.0, 720.0), false)
	_caso("22:9", Vector2(2200.0, 900.0), Vector2(1760.0, 720.0), false)
	_caso("32:9", Vector2(1920.0, 540.0), Vector2(1760.0, 720.0), true)
	_caso("0,78:1", Vector2(780.0, 1000.0), Vector2(1280.0, 960.0), true)
	_caso("1:1 (sin pantalla)", Vector2(64.0, 64.0), Vector2(1280.0, 960.0), true)
	print("PRUEBAS vista casos=%d fallos=%d" % [casos, fallos])


func _caso(nombre: String, ventana: Vector2, vista: Vector2, barras: bool) -> void:
	casos += 1
	var obtenida: Vector2 = Vista.calcular(ventana, MINIMA, MAXIMA)
	var con_barras: bool = Vista.con_barras(ventana, MINIMA, MAXIMA)
	if obtenida != vista or con_barras != barras:
		fallos += 1
		print("FALLO vista: %s da %s con barras=%s; se esperaba %s con barras=%s" % [nombre, str(obtenida), con_barras, str(vista), barras])
