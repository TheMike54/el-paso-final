class_name PaginaInventario
extends PaginaMarco
# Pagina Inventario del marco de menus: lo que el jugador lleva, solo para leer. Muestra lo que ya existe en
# Partida (vida, Inspiracion, PejeCoins, arma, habilidades, mapas y lo perdido al morir); no hay objetos todavia,
# porque un inventario de objetos subiria el guardado a la version 4. La crea cada sala, como Amuletos.

## El arma es la habilidad pluma: sin ella no se ataca.
const ARMA: StringName = Habilidades.PLUMA

## Texto de cada fila por nombre ("Vida", "Lo perdido", ...). Publico para la prueba.
var valores: Dictionary[String, String] = {}

var _filas: GridContainer = null


func _ready() -> void:
	super()
	var fondo: ColorRect = Tema.fondo_menu()
	add_child(fondo)
	var centro: CenterContainer = CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	centro.offset_top = MarcoMenus.ALTO_BARRA
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.add_child(centro)
	_filas = GridContainer.new()
	_filas.name = "Filas"
	_filas.columns = 2
	_filas.add_theme_constant_override(&"h_separation", 48)
	_filas.add_theme_constant_override(&"v_separation", int(Tema.SEPARACION_FILAS))
	centro.add_child(_filas)


func id_pagina() -> StringName:
	return &"inventario"


func titulo_pagina() -> String:
	return "Inventario"


func mostrar_en_marco() -> void:
	super()
	_llenar()


func _llenar() -> void:
	valores = {
		"Vida": "%d de %d" % [Partida.vidas, Partida.vidas_maximas],
		"Inspiración": "%d de %d" % [Partida.inspiracion, Partida.INSPIRACION_MAXIMA],
		"PejeCoins": str(Partida.monedas),
		"Arma": PantallaAmuletos.nombre_de(ARMA) if Partida.tiene(ARMA) else "Sin arma",
		"Habilidades": _lista(Partida.habilidades.filter(func(h: StringName) -> bool: return h != ARMA), "Ninguna"),
		"Mapas": _lista(Partida.mapas, "Ninguno"),
		"Lo perdido": perdido(Partida.mochila),
	}
	for hijo: Node in _filas.get_children():
		hijo.free()
	for nombre: String in valores:
		var etiqueta: Label = Label.new()
		etiqueta.text = nombre
		etiqueta.theme_type_variation = Tema.TENUE
		_filas.add_child(etiqueta)
		var valor: Label = Label.new()
		valor.text = valores[nombre]
		_filas.add_child(valor)


## Lo perdido al morir ({sala, x, y, monto} de docs/contrato.md), en una linea. Lo llena morir con PejeCoins.
static func perdido(mochila: Dictionary) -> String:
	var monto: Variant = mochila.get("monto")
	var sala: Variant = mochila.get("sala")
	var cantidad: int = 0
	if typeof(monto) == TYPE_INT:
		cantidad = monto
	elif typeof(monto) == TYPE_FLOAT:
		var decimal: float = monto
		cantidad = roundi(decimal)
	if cantidad <= 0:
		return "Nada"
	return "%d PejeCoins en %s" % [cantidad, str(sala)] if typeof(sala) == TYPE_STRING else "%d PejeCoins" % cantidad


func _lista(ids: Array, vacio: String) -> String:
	var nombres: PackedStringArray = []
	for id: Variant in ids:
		nombres.append(String(str(id)).capitalize())
	return ", ".join(nombres) if not nombres.is_empty() else vacio
