extends Control
# Zona de pruebas: las salas de prueba de esta carpeta agrupadas por categoria (GRUPOS), con una fila de categorias
# arriba que cambia la cuadricula de abajo, y Volver fijo arriba a la izquierda. Lista la carpeta al entrar: una
# sala que no esta en GRUPOS ni en OCULTAS aparece sola en «Otras». Se llega desde el menu principal con el modo
# desarrollador encendido, en depuracion y en publicacion; Volver, Atras, pausa y volver (B) regresan a ese menu, y
# L1 / R1 cambian de categoria.
const CARPETA: String = "res://herramientas/salas/"
## Salas de cada categoria, en el orden en que se muestran (rutas desde CARPETA). validar.gd falla si una no existe.
## Nombres cortos: las siete caben en la fila en la vista del S21 (1600 px); en el S50 y en la de 1280 la fila se
## desplaza.
const GRUPOS: Dictionary = {
	"Movimiento": ["sala_movimiento.tscn", "sala_caida.tscn", "sala_salida_abajo.tscn", "sala_doble_salto.tscn", "sala_impulso.tscn", "sala_pared.tscn", "sala_carrera.tscn"],
	"Combate": ["sala_combate.tscn", "sala_combate_chico.tscn", "sala_golpe.tscn", "sala_parry.tscn", "sala_pogo.tscn", "sala_picada.tscn", "sala_bola.tscn", "sala_curar.tscn"],
	"Enemigos": ["sala_enemigos.tscn", "sala_enemigos_banco.tscn", "sala_peligro.tscn", "sala_peligro_movil.tscn", "sala_enemigos_moviles.tscn"],
	"Mundo": ["sala_banco.tscn", "sala_puerta_a.tscn", "sala_camara.tscn", "sala_capas.tscn", "sala_secretos.tscn", "sala_pizarrones.tscn"],
	"Partida": ["sala_dialogo.tscn", "sala_reto.tscn", "sala_lo_perdido.tscn", "sala_tienda.tscn"],
	"Rendimiento": ["sala_recursos.tscn", "sala_arte.tscn"],
	"Zonas": ["zonas/mapa/mapa_1.tscn", "zonas/mapa/mapa_2.tscn", "zonas/prueba/prueba_1.tscn", "zonas/prueba/prueba_2.tscn", "zonas/prueba/prueba_3.tscn", "zonas/prueba/prueba_4.tscn"],
}
## Nombre y para que sirve cada sala de GRUPOS, el detalle en una linea corta (cabe en CELDA con Tema.LETRA_DETALLE).
## validar.gd falla si una sala de GRUPOS no tiene su linea o si una linea nombra una sala que no esta en GRUPOS. Una
## sala de «Otras» se ve con su nombre de archivo y sin detalle.
const SALAS: Dictionary = {
	"sala_movimiento.tscn": ["Movimiento", "Caminar y saltar"],
	"sala_caida.tscn": ["Caída", "Caída larga y cámara"],
	"sala_salida_abajo.tscn": ["Salida abajo", "Salir por abajo"],
	"sala_doble_salto.tscn": ["Doble salto", "Saltar en el aire"],
	"sala_impulso.tscn": ["Impulso", "Cruzar el foso"],
	"sala_pared.tscn": ["Pared", "Subir entre paredes"],
	"sala_carrera.tscn": ["Carrera", "Giro y voltereta"],
	"sala_combate.tscn": ["Combate", "Atacar y recibir daño"],
	"sala_combate_chico.tscn": ["Combate chico", "Recoger el arma"],
	"sala_golpe.tscn": ["Golpe", "Congelado y empuje"],
	"sala_parry.tscn": ["Parry", "Desviar un ataque"],
	"sala_pogo.tscn": ["Pogo", "Rebotar en pinchos"],
	"sala_picada.tscn": ["Picada", "Romper el suelo"],
	"sala_bola.tscn": ["Bola", "Alcance y recarga"],
	"sala_curar.tscn": ["Curar", "Curar y soltar"],
	"sala_enemigos.tscn": ["Enemigos", "Débil y fuerte"],
	"sala_enemigos_banco.tscn": ["Enemigos banco", "Reaparecen al sentarse"],
	"sala_peligro.tscn": ["Peligro", "Volver a lo seguro"],
	"sala_peligro_movil.tscn": ["Peligro móvil", "Sierra que va y viene"],
	"sala_enemigos_moviles.tscn": ["Enemigos móviles", "Caminan, vuelan, lanzan"],
	"sala_banco.tscn": ["Banco", "Sentarse y guardar"],
	"sala_puerta_a.tscn": ["Puerta A", "Cambio de sala"],
	"sala_camara.tscn": ["Cámara", "Seguimiento y límites"],
	"sala_capas.tscn": ["Capas", "Paralaje"],
	"sala_secretos.tscn": ["Secretos", "Muros y palancas"],
	"sala_pizarrones.tscn": ["Pizarrones", "Aprender cada acción"],
	"sala_dialogo.tscn": ["Diálogo", "Opciones y premios"],
	"sala_reto.tscn": ["Reto", "Preguntas con premio"],
	"sala_lo_perdido.tscn": ["Lo perdido", "Volver por la mochila"],
	"sala_tienda.tscn": ["Tienda", "Comprar con PejeCoins"],
	"sala_recursos.tscn": ["Recursos", "Bajo y alto"],
	"sala_arte.tscn": ["Arte", "FPS con todo el arte"],
	"zonas/mapa/mapa_1.tscn": ["Mapa 1", "Mapa, pluma y brújula"],
	"zonas/mapa/mapa_2.tscn": ["Mapa 2", "Sala alta en el mapa"],
	"zonas/prueba/prueba_1.tscn": ["Prueba 1", "Banco y viaje rápido"],
	"zonas/prueba/prueba_2.tscn": ["Prueba 2", "Un coleccionable"],
	"zonas/prueba/prueba_3.tscn": ["Prueba 3", "Dos coleccionables"],
	"zonas/prueba/prueba_4.tscn": ["Prueba 4", "Vitrina y estación"],
}
const OTRAS: String = "Otras"
## Escenas de la carpeta que no se listan: esta y Puerta B (se llega por la puerta de Puerta A). Las pruebas sin
## jugador, que solo corre un guion, viven en herramientas/pruebas/.
const OCULTAS: PackedStringArray = ["zona_pruebas.tscn", "sala_puerta_b.tscn"]
## Boton de cada sala, con su nombre y debajo su detalle: caben «Enemigos móviles» y «Caminan, vuelan, lanzan». 3
## columnas en la vista de 1280 y 4 en la de 1600; 2 solo si el area segura recorta mucho.
const CELDA: Vector2 = Vector2(352.0, Tema.ALTO_TOQUE + Tema.ALTO_DETALLE)

## La ultima categoria abierta, mientras la app sigue abierta: al volver de una sala se abre esa.
static var _ultima: String = ""

# Categoria -> rutas completas de sus salas presentes, en orden.
var _salas: Dictionary[String, PackedStringArray] = {}
var _botones_categoria: Dictionary[String, Button] = {}

@onready var _marco: Control = $Marco as Control
@onready var _fila: HBoxContainer = $Marco/Categorias/Fila as HBoxContainer
@onready var _lista: GridContainer = $Marco/Desplazable/Centro/Lista as GridContainer
@onready var _volver: Button = $Marco/Arriba/Volver as Button


func _ready() -> void:
	theme = Tema.crear()
	_leer_salas()
	var grupo: ButtonGroup = ButtonGroup.new()
	for categoria: String in _salas:
		var boton: Button = Button.new()
		boton.text = categoria
		boton.theme_type_variation = Tema.PESTANA
		boton.custom_minimum_size = Vector2(0.0, Tema.ALTO_TOQUE)
		boton.toggle_mode = true
		boton.button_group = grupo
		# PASS deja que el arrastre llegue a la fila para desplazarla con el dedo si no cabe.
		boton.mouse_filter = Control.MOUSE_FILTER_PASS
		boton.pressed.connect(_mostrar.bind(categoria))
		_fila.add_child(boton)
		_botones_categoria[categoria] = boton
	_volver.pressed.connect(volver)
	Tema.encabezado(_volver.get_parent() as Control)
	# L1 y R1 con «Categoria» a la derecha de la barra de arriba: en la fila no caben sin desplazarla (1280x720,
	# 16-oct-2026). Tras un toque no se ven.
	var arriba: HBoxContainer = _volver.get_parent() as HBoxContainer
	var l1: IconoBoton = IconoBoton.new()
	l1.accion = &"pagina_anterior"
	arriba.add_child(l1)
	var r1: IconoBoton = IconoBoton.new()
	r1.accion = &"pagina_siguiente"
	r1.texto = "Categoría"
	arriba.add_child(r1)
	Tema.ajustar(_marco)
	_marco.resized.connect(_acomodar_columnas)
	if not _salas.is_empty():
		_mostrar(_ultima if _salas.has(_ultima) else _salas.keys()[0] as String)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pausa") or Input.is_action_just_pressed(&"volver"):
		volver()
	elif Input.is_action_just_pressed(&"pagina_anterior"):
		cambiar(-1)
	elif Input.is_action_just_pressed(&"pagina_siguiente"):
		cambiar(1)


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		volver()


## Pasa a la categoria anterior (-1) o siguiente (1) de la fila, con la vuelta en los extremos, como las paginas del
## marco de menus; con L1 / R1 (pagina_anterior y pagina_siguiente).
func cambiar(paso: int) -> void:
	if _salas.is_empty():
		return
	var categorias: Array[String] = []
	categorias.assign(_salas.keys())
	var i: int = maxi(categorias.find(_ultima), 0)
	_mostrar(categorias[posmod(i + paso, categorias.size())])


## La categoria que se muestra. Publica para la prueba.
func categoria() -> String:
	return _ultima


## Regresa al menu principal, de donde se llega aqui.
func volver() -> void:
	MenuPrincipal.volver_a_zona = true
	get_tree().change_scene_to_file(MenuPrincipal.RUTA)


## Columnas de botones de sala que caben en un ancho: de 2 a 4.
static func columnas_para(ancho: float) -> int:
	return Tema.columnas(ancho, CELDA.x, Tema.SEPARACION, 2, 4)


# Arma _salas con lo que hay en la carpeta (en un paquete exportado las escenas aparecen como <nombre>.tscn.remap).
func _leer_salas() -> void:
	var presentes: PackedStringArray = []
	for archivo: String in DirAccess.get_files_at(CARPETA):
		var nombre: String = archivo.trim_suffix(".remap")
		if nombre.ends_with(".tscn") and not OCULTAS.has(nombre):
			presentes.append(nombre)
	for zona: String in DirAccess.get_directories_at(CARPETA + "zonas"):
		for archivo: String in DirAccess.get_files_at(CARPETA + "zonas/" + zona):
			var nombre: String = archivo.trim_suffix(".remap")
			if nombre.ends_with(".tscn"):
				presentes.append("zonas/" + zona + "/" + nombre)
	var agrupadas: PackedStringArray = []
	for categoria: String in GRUPOS:
		var lista: Array = GRUPOS[categoria]
		var rutas: PackedStringArray = []
		for sala: String in lista:
			agrupadas.append(sala)
			if presentes.has(sala):
				rutas.append(CARPETA + sala)
		if not rutas.is_empty():
			_salas[categoria] = rutas
	var otras: PackedStringArray = []
	for sala: String in presentes:
		if not agrupadas.has(sala):
			otras.append(CARPETA + sala)
	if not otras.is_empty():
		_salas[OTRAS] = otras


func _mostrar(categoria: String) -> void:
	_ultima = categoria
	_botones_categoria[categoria].set_pressed_no_signal(true)
	for hijo: Node in _lista.get_children():
		_lista.remove_child(hijo)
		hijo.queue_free()
	for ruta: String in _salas[categoria]:
		var boton: BotonSala = BotonSala.new()
		var info: Array = SALAS.get(ruta.trim_prefix(CARPETA), [])
		boton.text = info[0] if info.size() == 2 else ruta.get_file().get_basename().trim_prefix("sala_").capitalize()
		boton.detalle = info[1] if info.size() == 2 else ""
		boton.custom_minimum_size = CELDA
		# PASS deja que el arrastre llegue a la lista para desplazarla con el dedo.
		boton.mouse_filter = Control.MOUSE_FILTER_PASS
		boton.pressed.connect(_ir.bind(ruta))
		_lista.add_child(boton)
	_acomodar_columnas()
	Tema.dar_foco(_lista.get_child(0) as Button)


func _acomodar_columnas() -> void:
	_lista.columns = columnas_para(_marco.size.x)


func _ir(escena: String) -> void:
	Partida.reiniciar()
	Partida.ruta_guardado = Partida.RUTA_PRUEBAS
	Sala.puerta_llegada = &""
	get_tree().change_scene_to_file(escena)


# Boton de una sala: su nombre arriba y, debajo, en gis gastado, para que sirve (Tema.CON_DETALLE deja el lugar).
class BotonSala:
	extends Button

	## Para que sirve la sala; publico para la prueba.
	var detalle: String = ""

	func _ready() -> void:
		theme_type_variation = Tema.CON_DETALLE
		alignment = HORIZONTAL_ALIGNMENT_LEFT

	func _draw() -> void:
		if detalle.is_empty():
			return
		var fuente: Font = get_theme_font(&"font")
		var estilo: StyleBox = get_theme_stylebox(&"normal")
		var letra: int = Tema.LETRA_DETALLE
		var linea: float = size.y - estilo.content_margin_bottom + 12.0 + (Tema.ALTO_DETALLE + fuente.get_ascent(letra) - fuente.get_descent(letra)) / 2.0
		var ancho: float = size.x - estilo.content_margin_left - estilo.content_margin_right
		draw_string(fuente, Vector2(estilo.content_margin_left, linea), detalle, HORIZONTAL_ALIGNMENT_LEFT, ancho, letra, Color(Tema.GASTADO, 0.8))
