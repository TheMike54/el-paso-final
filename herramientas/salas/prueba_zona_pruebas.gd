extends "res://herramientas/salas/prueba_base.gd"
# Prueba de la zona de pruebas con el control: L1 / R1 (pagina_anterior y pagina_siguiente) pasan de categoria en
# el orden de la fila, con la vuelta en los extremos, y dejan el foco en la primera sala; sus botones del control se
# ven solo tras usar el control. Instancia la zona como
# hija; su guion lee "valor . casos" y "valor . fallos".
const ZONA: String = "res://herramientas/salas/zona_pruebas.tscn"


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
	await _presionar(&"pagina_anterior")
	_mostrando(zona, nombres[nombres.size() - 1], "L1 desde la primera da la vuelta a la ultima")
	await _presionar(&"pagina_siguiente")
	_mostrando(zona, primera, "R1 desde la ultima da la vuelta a la primera")
	# Barra de arriba: Volver con su boton, y L1 y R1 con «Categoria».
	var iconos: Array[IconoBoton] = _iconos(zona.get_node(^"Marco/Arriba"))
	await _usar(true)
	_caso("con el control la barra muestra Volver, L1 y R1", iconos.size() == 3 and _iconos_en(iconos, true))
	await _usar(false)
	_caso("tras un toque la barra no los muestra", _iconos_en(iconos, false))
	_resumen()


func _mostrando(zona: Control, esperada: String, nombre: String) -> void:
	var actual: String = zona.call(&"categoria")
	_caso(nombre, actual == esperada)
