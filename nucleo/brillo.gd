class_name Brillo
extends CanvasModulate
# Ajuste de brillo de la sala: multiplica el color de todo el mundo (no el HUD, los controles ni los menus, que van en
# su CanvasLayer), como Hollow Knight, que lo aplica solo a la camara del juego. Antes era un rectangulo encima de la
# pantalla: en el Senwa S50 costaba ~6 ms por cuadro con cualquier brillo distinto de 1; multiplicar no dibuja nada mas.
# Lo crea cada Sala; Ajustes.aplicar_brillo() le pasa el valor.

## El de la sala viva, o null fuera de una sala (menu principal, ranuras).
static var instancia: Brillo = null


func _ready() -> void:
	instancia = self
	poner(Ajustes.brillo)


func _exit_tree() -> void:
	if instancia == self:
		instancia = null


func poner(valor: float) -> void:
	color = color_para(valor)


## Color del modulado para un brillo: gris v (recortado al rango de Ajustes); 1 es blanco y no cambia nada, encima
## de 1 aclara.
static func color_para(valor: float) -> Color:
	var v: float = clampf(valor, Ajustes.BRILLO_MINIMO, Ajustes.BRILLO_MAXIMO)
	return Color(v, v, v, 1.0)
