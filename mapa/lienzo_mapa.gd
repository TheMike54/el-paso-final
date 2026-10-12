class_name LienzoMapa
extends Control
# Dibujo del mapa en sus dos estados: alejado (cada zona como la silueta rellena de sus salas, con su nombre) y
# acercado (las salas de la zona actual con borde, o su dibujo si lo tienen). Recibe todo hecho en dibujar() y
# solo pinta; las cuentas viven en DatosMapa. Deja en propiedades publicas lo que dibujo, para las pruebas.

const MARGEN: float = 60.0
const COLOR_SALA: Color = Color(0.55, 0.5, 0.4, 1.0)
const COLOR_BORDE: Color = Color(0.9, 0.85, 0.7, 1.0)
const COLOR_MARCADOR: Color = Color(1.0, 0.85, 0.2, 1.0)
const COLORES_ZONA: Array[Color] = [Color(0.45, 0.55, 0.65), Color(0.6, 0.5, 0.4), Color(0.45, 0.6, 0.45), Color(0.6, 0.45, 0.6)]

## Lo que quedo dibujado en la ultima llamada a dibujar(): salas, zonas, si hay marcador y si quedo acercado.
var salas_dibujadas: int = 0
var zonas_dibujadas: int = 0
var marcador_visible: bool = false
var quedo_acercado: bool = false

var _indice: IndiceSalas = IndiceSalas.new()
var _zonas: Dictionary[String, Array] = {}
var _ids: Array = []
var _marcador: Vector2 = Vector2.ZERO
var _transformacion: Transform2D = Transform2D.IDENTITY


## Prepara el dibujo. acercado se cumple solo si la zona actual tiene salas dibujadas; si no, queda alejado.
func dibujar(indice: IndiceSalas, zonas: Dictionary[String, Array], zona_actual: String, acercado: bool, con_marcador: bool, marcador: Vector2) -> void:
	_indice = indice
	_zonas = zonas
	quedo_acercado = acercado and zonas.has(zona_actual)
	_ids = []
	if quedo_acercado:
		_ids = zonas[zona_actual].duplicate()
	else:
		for zona: String in zonas:
			_ids.append_array(zonas[zona])
	salas_dibujadas = _ids.size()
	zonas_dibujadas = 1 if quedo_acercado else zonas.size()
	_transformacion = DatosMapa.encajar(DatosMapa.abarca(indice, _ids), Rect2(Vector2.ZERO, size), MARGEN)
	_marcador = marcador
	marcador_visible = con_marcador and salas_dibujadas > 0
	queue_redraw()


func _draw() -> void:
	if salas_dibujadas == 0:
		draw_string(get_theme_default_font(), Vector2(size.x / 2.0 - 160.0, size.y / 2.0), "Aún no hay nada en el mapa", HORIZONTAL_ALIGNMENT_CENTER, 320.0, 28)
		return
	var escala: float = _transformacion.x.x
	if quedo_acercado:
		for valor: Variant in _ids:
			var id: String = str(valor)
			var rectangulo: Rect2 = _en_pantalla(_indice.rectangulos[id], escala)
			if _indice.dibujos.has(id):
				var textura: Texture2D = load(_indice.dibujos[id]) as Texture2D
				if textura != null:
					draw_texture_rect(textura, rectangulo, false)
					continue
			draw_rect(rectangulo, COLOR_SALA)
			draw_rect(rectangulo, COLOR_BORDE, false, 3.0)
	else:
		var numero: int = 0
		for zona: String in _zonas:
			var color: Color = COLORES_ZONA[numero % COLORES_ZONA.size()]
			numero += 1
			for valor: Variant in _zonas[zona]:
				draw_rect(_en_pantalla(_indice.rectangulos[str(valor)], escala), color)
			var centro: Vector2 = _transformacion * DatosMapa.abarca(_indice, _zonas[zona]).get_center()
			draw_string(get_theme_default_font(), centro - Vector2(150.0, -10.0), DatosMapa.nombre_de_zona(zona), HORIZONTAL_ALIGNMENT_CENTER, 300.0, 30)
	if marcador_visible:
		draw_circle(_transformacion * _marcador, 10.0, COLOR_MARCADOR)


func _en_pantalla(rectangulo: Rect2, escala: float) -> Rect2:
	return Rect2(_transformacion * rectangulo.position, rectangulo.size * escala)
