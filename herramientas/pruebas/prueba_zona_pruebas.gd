extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de la zona de pruebas con el control: L1 / R1 (pagina_anterior y pagina_siguiente) pasan de categoria en el
# orden de la fila, con la vuelta en los extremos, y dejan el foco en la primera sala; sus botones del control se ven
# solo tras usar el control. Las siete categorias en orden, cada sala con nombre y detalle, Puerta B no se lista y el
# foco es la marca de gis, oculta tras un toque. Su guion lee "valor . casos" y "valor . fallos".
const ZONA: String = "res://herramientas/salas/zona_pruebas.tscn"


# Instancia la zona como hija.
func _ready() -> void:
	var escena: PackedScene = load(ZONA) as PackedScene
	var zona: Control = escena.instantiate() as Control
	add_child(zona)
	await _esperar(2)
	var fila: HBoxContainer = zona.get_node(^"Marco/Categorias/Fila") as HBoxContainer
	var lista: GridContainer = zona.get_node(^"Marco/Desplazable/Centro/Lista") as GridContainer
	var nombres: Array[String] = []
	var botones: Array[Button] = []
	for hijo: Node in fila.get_children():
		if hijo is Button:
			botones.append(hijo as Button)
			nombres.append((hijo as Button).text)
	# La zona abre en la ultima categoria vista (estatica): se avanza hasta la primera.
	var primera: String = nombres[0]
	for i: int in range(nombres.size()):
		var actual: String = zona.call(&"categoria")
		if actual == primera:
			break
		zona.call(&"cambiar", 1)
	_mostrando(zona, primera, "la fila tiene mas de una categoria y se llega a la primera")
	_caso("hay al menos dos categorias", nombres.size() >= 2)
	await _presionar(&"pagina_siguiente")
	_mostrando(zona, nombres[1], "R1 pasa a la segunda categoria")
	var foco: Control = get_viewport().gui_get_focus_owner()
	_caso("y deja el foco en su primera sala", foco != null and lista.get_child_count() > 0 and foco == lista.get_child(0))
	_caso("y su boton queda marcado en la fila", botones[1].button_pressed)
	await _presionar(&"pagina_anterior")
	_mostrando(zona, primera, "L1 vuelve a la primera")
	var marcados: Array[int] = _marcados(botones)
	_caso("y solo su boton queda marcado (docs/errores/2026-10-24-varias-categorias-marcadas.md)", marcados.size() == 1 and marcados[0] == 0)
	await _presionar(&"pagina_anterior")
	_mostrando(zona, nombres[nombres.size() - 1], "L1 desde la primera da la vuelta a la ultima")
	await _presionar(&"pagina_siguiente")
	_mostrando(zona, primera, "R1 desde la ultima da la vuelta a la primera")
	_caso("las siete categorias van en orden", nombres == ["Movimiento", "Combate", "Enemigos", "Mundo", "Partida", "Rendimiento", "Zonas"])
	# Cada categoria: cada sala con su nombre y su detalle, y Puerta B en ninguna.
	var sin_detalle: Array[String] = []
	var puerta_b: bool = false
	for i: int in range(nombres.size()):
		await _esperar(1)
		for hijo: Node in lista.get_children():
			var boton: Button = hijo as Button
			if boton.is_queued_for_deletion():
				continue
			if (boton.get(&"detalle") as String).is_empty():
				sin_detalle.append(boton.text)
			puerta_b = puerta_b or boton.text == "Puerta B"
		zona.call(&"cambiar", 1)
	_caso("cada sala lleva su nombre y para que sirve", sin_detalle.is_empty())
	_caso("Puerta B no se lista: se llega por la puerta de Puerta A", not puerta_b)
	_caso("el foco del tema es la marca de gis", Tema.crear().get_stylebox(&"focus", &"Button") is EstiloGis)
	await _usar(false)
	var primera_sala: Button = lista.get_child(0) as Button
	Tema.dar_foco(primera_sala)
	_caso("tras un toque el foco se da oculto: sin marca", primera_sala.has_focus() and not primera_sala.has_focus(true))
	await _usar(true)
	Tema.dar_foco(primera_sala)
	_caso("con el control la marca se ve", primera_sala.has_focus(true))
	# Barra de arriba: Volver con su boton, y L1 y R1 con «Categoria».
	var iconos: Array[IconoBoton] = _iconos(zona.get_node(^"Marco/Arriba"))
	await _usar(true)
	_caso("con el control la barra muestra Volver, L1 y R1", iconos.size() == 3 and _iconos_en(iconos, true))
	await _usar(false)
	_caso("tras un toque la barra no los muestra", _iconos_en(iconos, false))
	_resumen()


# Indices de los botones de la fila que estan marcados.
func _marcados(botones: Array[Button]) -> Array[int]:
	var marcados: Array[int] = []
	for i: int in range(botones.size()):
		if botones[i].button_pressed:
			marcados.append(i)
	return marcados


func _mostrando(zona: Control, esperada: String, nombre: String) -> void:
	var actual: String = zona.call(&"categoria")
	_caso(nombre, actual == esperada)
