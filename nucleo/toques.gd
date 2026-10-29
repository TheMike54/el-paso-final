class_name Toques
extends RefCounted
# Pregunta una vez a Android si la pantalla declara 5 o mas toques a la vez (jazzhand). Hay telefonos de gama baja
# que solo reconocen 2 (el S50, medido el 12-oct-2026): el juego no cambia por eso, pero el menu y Configuracion lo
# avisan con una linea discreta. Fuera de Android, o si la pregunta falla, no avisa; las pruebas usan forzar().

enum Respuesta {
	SIN_PREGUNTAR,
	MUCHOS,
	POCOS,
	NO_SE_SABE,
}

const FUNCION_MUCHOS_TOQUES: String = "android.hardware.touchscreen.multitouch.jazzhand"
const TEXTO_AVISO: String = "Tu celular reconoce pocos toques a la vez: algunas combinaciones de botones pueden no responder."
const COLOR_AVISO: Color = Color(1.0, 1.0, 1.0, 0.55)
const TAMANO_LETRA: int = 20
const MARGEN_ABAJO: float = 24.0

static var _respuesta: Respuesta = Respuesta.SIN_PREGUNTAR


## Si hay que avisar: solo cuando Android contesto que no declara 5 o mas toques.
static func pocos() -> bool:
	if _respuesta == Respuesta.SIN_PREGUNTAR:
		_respuesta = _preguntar()
	return _respuesta == Respuesta.POCOS


## Para las pruebas: fija la respuesta sin preguntar a Android.
static func forzar(son_pocos: bool) -> void:
	_respuesta = Respuesta.POCOS if son_pocos else Respuesta.MUCHOS


## Para las pruebas: vuelve a preguntar la proxima vez.
static func olvidar() -> void:
	_respuesta = Respuesta.SIN_PREGUNTAR


## La linea del aviso, abajo y centrada en el Control que la recibe; null si no hay que avisar.
static func crear_aviso() -> Label:
	if not pocos():
		return null
	var aviso: Label = Label.new()
	aviso.name = "AvisoToques"
	aviso.text = TEXTO_AVISO
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	aviso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aviso.add_theme_font_size_override(&"font_size", TAMANO_LETRA)
	aviso.add_theme_color_override(&"font_color", COLOR_AVISO)
	aviso.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	aviso.offset_top = -MARGEN_ABAJO - float(TAMANO_LETRA) * 3.0
	aviso.offset_bottom = -MARGEN_ABAJO
	aviso.grow_vertical = Control.GROW_DIRECTION_BEGIN
	aviso.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	return aviso


# PackageManager.hasSystemFeature por el singleton AndroidRuntime (Godot 4.4 o mas nuevo). Cada paso se revisa:
# si algo falta, no se sabe y no se avisa.
static func _preguntar() -> Respuesta:
	if OS.get_name() != "Android" or not Engine.has_singleton("AndroidRuntime"):
		return Respuesta.NO_SE_SABE
	var runtime: Object = Engine.get_singleton("AndroidRuntime")
	var contexto: Object = runtime.call("getApplicationContext") as Object
	if contexto == null:
		return Respuesta.NO_SE_SABE
	var paquetes: Object = contexto.call("getPackageManager") as Object
	if paquetes == null:
		return Respuesta.NO_SE_SABE
	# El boolean de Java llega como entero (0 o 1; comprobado en el S50 con Godot 4.7.2).
	var respuesta: Variant = paquetes.call("hasSystemFeature", FUNCION_MUCHOS_TOQUES)
	var tiene: bool = false
	if respuesta is bool:
		tiene = respuesta as bool
	elif respuesta is int:
		tiene = (respuesta as int) != 0
	else:
		return Respuesta.NO_SE_SABE
	print("Toques: %s = %s" % [FUNCION_MUCHOS_TOQUES, tiene])
	return Respuesta.MUCHOS if tiene else Respuesta.POCOS
