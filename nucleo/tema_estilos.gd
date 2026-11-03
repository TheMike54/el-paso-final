# Construye los estilos de los menus sin guardar estado ni recursos compartidos.
# Tema conserva los colores y las medidas y llama estos constructores al crearse.
# Mantiene el orden y las mismas cajas de gis de cada variacion.
class_name TemaEstilos
extends RefCounted

## Variacion VOLVER: la flecha de gis hacia atras siempre a la vista (gastada; blanca con el foco, encima o presionado),
## y con el foco ademas el subrayado.
static func volver(tema: Theme) -> void:
	tema.set_type_variation(Tema.VOLVER, &"Button")
	var gastada: EstiloGis = estilo_gis(EstiloGis.Forma.ATRAS, Tema.GASTADO, Tema.MARGEN_OPCION)
	var blanca: EstiloGis = estilo_gis(EstiloGis.Forma.ATRAS, Tema.GIS, Tema.MARGEN_OPCION)
	tema.set_stylebox(&"normal", Tema.VOLVER, gastada)
	tema.set_stylebox(&"hover", Tema.VOLVER, blanca)
	tema.set_stylebox(&"pressed", Tema.VOLVER, blanca)
	tema.set_stylebox(&"hover_pressed", Tema.VOLVER, blanca)
	tema.set_stylebox(&"focus", Tema.VOLVER, estilo_gis(EstiloGis.Forma.SUBRAYADO, Tema.GIS, Tema.MARGEN_OPCION))


## Variacion TARJETA: un boton con contenido propio (ficha de ranura, caja de dialogo y sus opciones) en una caja de gis
## con relleno oscuro; con el foco, encima o presionado, la caja en gis blanco.
static func tarjeta(tema: Theme) -> void:
	tema.set_type_variation(Tema.TARJETA, &"Button")
	_cajas_tarjeta(tema, Tema.TARJETA)
	tema.set_color(&"font_color", Tema.TARJETA, Tema.GIS)


## Variacion SIMBOLO: las cajas de TARJETA con margenes de arriba y abajo de MARGEN_SIMBOLO y LETRA_SIMBOLO.
static func simbolo(tema: Theme) -> void:
	tema.set_type_variation(Tema.SIMBOLO, Tema.TARJETA)
	_cajas_tarjeta(tema, Tema.SIMBOLO, Tema.MARGEN_SIMBOLO)
	tema.set_font_size(&"font_size", Tema.SIMBOLO, Tema.LETRA_SIMBOLO)


# Las cajas de gis de una tarjeta para la variacion nombre; vertical menor que 0 deja los margenes de _margenes.
static func _cajas_tarjeta(tema: Theme, nombre: StringName, vertical: float = -1.0) -> void:
	var normal: EstiloGis = estilo_gis(EstiloGis.Forma.CAJA, Color(Tema.GASTADO, 0.7), Tema.MARGEN_DERECHO)
	normal.fondo = Tema.FONDO_TARJETA
	normal.grosor = 2.4
	var clara: EstiloGis = estilo_gis(EstiloGis.Forma.CAJA, Tema.GIS, Tema.MARGEN_DERECHO)
	clara.fondo = Tema.FONDO_TARJETA
	var foco: EstiloGis = estilo_gis(EstiloGis.Forma.CAJA, Tema.GIS, Tema.MARGEN_DERECHO)
	foco.grosor = 3.4
	if vertical >= 0.0:
		for estilo: EstiloGis in [normal, clara, foco]:
			estilo.content_margin_top = vertical
			estilo.content_margin_bottom = vertical
	tema.set_stylebox(&"normal", nombre, normal)
	tema.set_stylebox(&"hover", nombre, clara)
	tema.set_stylebox(&"pressed", nombre, clara)
	tema.set_stylebox(&"hover_pressed", nombre, clara)
	tema.set_stylebox(&"disabled", nombre, normal)
	tema.set_stylebox(&"focus", nombre, foco)


## Pone GRIS_APAGADO en los cinco colores de letra de un boton de la variacion nombre.
static func apagar_letra(tema: Theme, nombre: StringName) -> void:
	for color: StringName in [&"font_color", &"font_hover_color", &"font_pressed_color", &"font_focus_color", &"font_hover_pressed_color"]:
		tema.set_color(color, nombre, Tema.GRIS_APAGADO)


## Variacion PESTANA: sin la flechita a la izquierda, para que quepan siete en la fila.
static func pestana(tema: Theme) -> void:
	tema.set_type_variation(Tema.PESTANA, &"Button")
	var vacia: StyleBoxEmpty = estilo_vacio(Tema.MARGEN_DERECHO)
	var elegida: EstiloGis = estilo_gis(EstiloGis.Forma.SUBRAYADO, Tema.GIS, Tema.MARGEN_DERECHO)
	tema.set_stylebox(&"normal", Tema.PESTANA, vacia)
	tema.set_stylebox(&"hover", Tema.PESTANA, vacia)
	tema.set_stylebox(&"disabled", Tema.PESTANA, vacia)
	tema.set_stylebox(&"pressed", Tema.PESTANA, elegida)
	tema.set_stylebox(&"hover_pressed", Tema.PESTANA, elegida)
	tema.set_stylebox(&"focus", Tema.PESTANA, estilo_gis(EstiloGis.Forma.CAJA, Tema.GIS, Tema.MARGEN_DERECHO))


## Variacion CON_DETALLE: los mismos trazos que un boton, con el contenido arriba; el subrayado del foco queda bajo el
## texto y el detalle va debajo.
static func con_detalle(tema: Theme) -> void:
	tema.set_type_variation(Tema.CON_DETALLE, &"Button")
	var arriba: float = (Tema.ALTO_TOQUE - Tema.ALTO_LETRA) / 2.0 - Tema.ALTO_DETALLE / 2.0
	var abajo: float = Tema.ALTO_TOQUE + Tema.ALTO_DETALLE - Tema.ALTO_LETRA - arriba
	var normal: StyleBoxEmpty = estilo_vacio(Tema.MARGEN_OPCION)
	var elegida: EstiloGis = estilo_gis(EstiloGis.Forma.SUBRAYADO, Tema.GIS, Tema.MARGEN_OPCION)
	var foco: EstiloGis = estilo_gis(EstiloGis.Forma.MARCA, Tema.GIS, Tema.MARGEN_OPCION)
	for estilo: StyleBox in [normal, elegida, foco]:
		estilo.content_margin_top = arriba
		estilo.content_margin_bottom = abajo
	for estado: StringName in [&"normal", &"hover", &"disabled"]:
		tema.set_stylebox(estado, Tema.CON_DETALLE, normal)
	for estado: StringName in [&"pressed", &"hover_pressed"]:
		tema.set_stylebox(estado, Tema.CON_DETALLE, elegida)
	tema.set_stylebox(&"focus", Tema.CON_DETALLE, foco)


## Variacion OPCION_CENTRADA: el mismo margen a los dos lados en todos los estados (Button acomoda el texto con el
## stylebox del estado y dibuja focus encima: si solo focus cambiara, el texto brincaria al enfocar), sin subrayado al
## presionar y con el foco una flechita a cada lado.
static func opcion_centrada(tema: Theme) -> void:
	tema.set_type_variation(Tema.OPCION_CENTRADA, &"Button")
	var vacia: StyleBoxEmpty = estilo_vacio(Tema.MARGEN_OPCION)
	vacia.content_margin_right = Tema.MARGEN_OPCION
	var foco: EstiloGis = estilo_gis(EstiloGis.Forma.LADOS, Tema.GIS, Tema.MARGEN_OPCION)
	foco.content_margin_right = Tema.MARGEN_OPCION
	for estado: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"disabled"]:
		tema.set_stylebox(estado, Tema.OPCION_CENTRADA, vacia)
	tema.set_stylebox(&"focus", Tema.OPCION_CENTRADA, foco)


## Variaciones ADORNO_ANCHO y ADORNO_CHICO de PanelContainer: un PanelContainer sin hijos mide lo minimo de su stylebox,
## que son sus margenes; asi el adorno trae su tamano del tema y nadie repite los numeros.
static func adornos(tema: Theme) -> void:
	for par: Array in [[Tema.ADORNO_ANCHO, Tema.TAMANO_ADORNO_ANCHO], [Tema.ADORNO_CHICO, Tema.TAMANO_ADORNO_CHICO]]:
		var nombre: StringName = par[0] as StringName
		var tamano: Vector2 = par[1] as Vector2
		var estilo: EstiloGis = EstiloGis.new()
		estilo.forma = EstiloGis.Forma.ADORNO
		estilo.color = Tema.GIS
		estilo.grosor = 2.4
		estilo.content_margin_left = tamano.x / 2.0
		estilo.content_margin_right = tamano.x / 2.0
		estilo.content_margin_top = tamano.y / 2.0
		estilo.content_margin_bottom = tamano.y / 2.0
		tema.set_type_variation(nombre, &"PanelContainer")
		tema.set_stylebox(&"panel", nombre, estilo)


## Variaciones FILA_TIENDA (Button), FILA_TIENDA_APAGADA (de ella, en gris) y FRANJA (Panel). La fila deja a la
## izquierda el lugar del icono y la moneda; su foco no dibuja nada (lo marca la franja, que se ve tambien tras un toque).
static func fila_tienda(tema: Theme) -> void:
	tema.set_type_variation(Tema.FILA_TIENDA, &"Button")
	var vacia: StyleBoxEmpty = estilo_vacio(Tema.MARGEN_DERECHO + Tema.LADO_ICONO_FILA + Tema.LADO_MONEDA_FILA + Tema.SEPARACION_ICONO * 2.0)
	for estado: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"disabled", &"focus"]:
		tema.set_stylebox(estado, Tema.FILA_TIENDA, vacia)
	tema.set_type_variation(Tema.FILA_TIENDA_APAGADA, Tema.FILA_TIENDA)
	apagar_letra(tema, Tema.FILA_TIENDA_APAGADA)
	var franja: EstiloGis = EstiloGis.new()
	franja.forma = EstiloGis.Forma.FRANJA
	franja.color = Tema.GIS
	franja.grosor = 2.4
	franja.fondo = Tema.RELLENO_FRANJA
	franja.content_margin_top = Tema.ALTO_ORILLA_FRANJA
	franja.content_margin_bottom = Tema.ALTO_ORILLA_FRANJA
	tema.set_type_variation(Tema.FRANJA, &"Panel")
	tema.set_stylebox(&"panel", Tema.FRANJA, franja)


## Variacion BARRA_ANCHA de HSlider (volumen y brillo): pista gruesa, lo lleno en verde y un
## pomo redondo de POMO px. Una variacion y no el HSlider del tema: las barras del editor de botones no cambian.
static func barra_ancha(tema: Theme, foco: StyleBox) -> void:
	tema.set_type_variation(Tema.BARRA_ANCHA, &"HSlider")
	var pista: StyleBoxFlat = StyleBoxFlat.new()
	pista.bg_color = Tema.BORDE_BOTON
	pista.set_corner_radius_all(int(Tema.GROSOR_PISTA / 2.0))
	pista.content_margin_top = Tema.GROSOR_PISTA / 2.0
	pista.content_margin_bottom = Tema.GROSOR_PISTA / 2.0
	var lleno: StyleBoxFlat = pista.duplicate() as StyleBoxFlat
	lleno.bg_color = Tema.ENCENDIDO
	tema.set_stylebox(&"slider", Tema.BARRA_ANCHA, pista)
	tema.set_stylebox(&"grabber_area", Tema.BARRA_ANCHA, lleno)
	tema.set_stylebox(&"grabber_area_highlight", Tema.BARRA_ANCHA, lleno)
	tema.set_stylebox(&"focus", Tema.BARRA_ANCHA, foco)
	var pomo: ImageTexture = _circulo(Tema.POMO, Tema.GIS)
	tema.set_icon(&"grabber", Tema.BARRA_ANCHA, pomo)
	tema.set_icon(&"grabber_highlight", Tema.BARRA_ANCHA, pomo)
	tema.set_icon(&"grabber_disabled", Tema.BARRA_ANCHA, pomo)


static func _circulo(diametro: int, color: Color) -> ImageTexture:
	var imagen: Image = Image.create_empty(diametro, diametro, false, Image.FORMAT_RGBA8)
	var radio: float = diametro / 2.0
	for y: int in range(diametro):
		for x: int in range(diametro):
			# Borde suavizado de 1 px.
			var d: float = Vector2(x + 0.5 - radio, y + 0.5 - radio).length()
			imagen.set_pixel(x, y, Color(color, clampf(radio - d, 0.0, 1.0)))
	return ImageTexture.create_from_image(imagen)


# Con ALTO_LETRA de alto de linea, los margenes de arriba y abajo completan ALTO_TOQUE.
static func _margenes(estilo: StyleBox, izquierdo: float) -> void:
	estilo.content_margin_left = izquierdo
	estilo.content_margin_right = Tema.MARGEN_DERECHO
	estilo.content_margin_top = (Tema.ALTO_TOQUE - Tema.ALTO_LETRA) / 2.0
	estilo.content_margin_bottom = (Tema.ALTO_TOQUE - Tema.ALTO_LETRA) / 2.0


static func estilo_vacio(izquierdo: float) -> StyleBoxEmpty:
	var vacia: StyleBoxEmpty = StyleBoxEmpty.new()
	_margenes(vacia, izquierdo)
	return vacia


static func estilo_gis(forma: EstiloGis.Forma, color: Color, izquierdo: float) -> EstiloGis:
	var estilo: EstiloGis = EstiloGis.new()
	estilo.forma = forma
	estilo.color = color
	_margenes(estilo, izquierdo)
	return estilo
