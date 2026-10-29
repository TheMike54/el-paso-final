class_name Brillo
extends CanvasModulate
# Ajuste de brillo de la sala: multiplica el color de todo el mundo (no el HUD, los controles ni los menus, que van en
# su CanvasLayer), como Hollow Knight, que lo aplica solo a la camara del juego. Antes era un rectangulo encima de la
# pantalla: en el Senwa S50 costaba ~6 ms por cuadro con cualquier brillo distinto de 1; multiplicar no dibuja nada mas.
# Lo crea cada Sala; Ajustes.aplicar_brillo() le pasa el valor. Tambien lleva la oscuridad propia de la sala
# (Sala.oscuridad): solo vale un CanvasModulate por canvas (classes/class_canvasmodulate.rst:25), asi que es este.

## El de la sala viva, o null fuera de una sala (menu principal, ranuras).
static var instancia: Brillo = null

## Oscuridad de la sala, de 0 a 1: multiplica el brillo por 1 - oscuridad. La pone la Sala antes de agregarlo.
var oscuridad: float = 0.0


func _ready() -> void:
	instancia = self
	poner(Ajustes.brillo)


func _exit_tree() -> void:
	if instancia == self:
		instancia = null


func poner(valor: float) -> void:
	color = color_para(valor, oscuridad)


## Color del modulado para un brillo: gris v (recortado al rango de Ajustes); 1 es blanco y no cambia nada, encima
## de 1 aclara. Con oscuridad, el gris se multiplica por 1 - oscuridad (recortada de 0 a 1).
static func color_para(valor: float, oscuridad_sala: float = 0.0) -> Color:
	var v: float = clampf(valor, Ajustes.BRILLO_MINIMO, Ajustes.BRILLO_MAXIMO) * (1.0 - clampf(oscuridad_sala, 0.0, 1.0))
	return Color(v, v, v, 1.0)
