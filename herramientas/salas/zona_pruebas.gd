extends Control
# Zona de pruebas: las salas de prueba de esta carpeta agrupadas por categoria (GRUPOS), con una fila de categorias
# arriba que cambia la cuadricula de abajo, y Volver fijo arriba a la izquierda. Lista la carpeta al entrar: una
# sala que no esta en GRUPOS ni en OCULTAS aparece sola en «Otras». Se llega desde el menu principal con el modo
# desarrollador encendido, en depuracion y en publicacion; Volver, Atras y pausa regresan a ese menu.
const CARPETA: String = "res://herramientas/salas/"
const MENU: String = "res://nucleo/menu.tscn"
## Salas de cada categoria, en el orden en que se muestran (rutas desde CARPETA). validar.gd falla si una no existe.
## Nombres cortos: con los largos la fila media 1481 px y en el S50 caben 1312.
const GRUPOS: Dictionary = {
	"Movimiento": ["sala_movimiento.tscn", "sala_caida.tscn", "sala_salida_abajo.tscn", "sala_doble_salto.tscn", "sala_impulso.tscn", "sala_pared.tscn", "sala_carrera.tscn"],
	"Combate": ["sala_combate.tscn", "sala_combate_chico.tscn", "sala_golpe.tscn", "sala_parry.tscn", "sala_pogo.tscn", "sala_picada.tscn", "sala_bola.tscn", "sala_curar.tscn"],
	"Enemigos": ["sala_enemigos.tscn", "sala_enemigos_banco.tscn", "sala_peligro.tscn", "sala_peligro_movil.tscn"],
	"Salas": ["sala_banco.tscn", "sala_dialogo.tscn", "sala_reto.tscn", "sala_puerta_a.tscn", "sala_puerta_b.tscn", "sala_camara.tscn", "sala_capas.tscn", "sala_recursos.tscn", "sala_arte.tscn"],
	"Zonas": ["zonas/mapa/mapa_1.tscn", "zonas/mapa/mapa_2.tscn", "zonas/prueba/prueba_1.tscn", "zonas/prueba/prueba_2.tscn", "zonas/prueba/prueba_3.tscn", "zonas/prueba/prueba_4.tscn"],
}
const OTRAS: String = "Otras"
## Escenas de la carpeta que no se listan: esta y las pruebas sin jugador, que solo corre un guion.
const OCULTAS: PackedStringArray = ["zona_pruebas.tscn", "sala_guardado.tscn", "sala_tactil.tscn", "sala_control.tscn", "sala_foco.tscn", "sala_aterrizaje.tscn", "sala_vista.tscn", "sala_controles_configurables.tscn", "sala_menu_configuracion.tscn", "sala_ranuras.tscn", "sala_amuletos.tscn", "sala_marco.tscn", "sala_dialogo_prueba.tscn", "sala_reto_prueba.tscn", "sala_sonido.tscn", "sala_peligro_anti_bucle.tscn", "sala_enemigo_al_morir.tscn", "sala_sala_id.tscn", "sala_estado_sala.tscn", "sala_combate_chico_cuentas.tscn", "sala_recursos_cuentas.tscn", "sala_mapa_cuentas.tscn"]
## Boton de cada sala: cabe «Enemigos banco» con la letra del tema. 3 columnas en la vista de 1280 y 4 desde 1600;
## 2 solo si el area segura recorta mucho.
const CELDA: Vector2 = Vector2(320.0, Tema.ALTO_TOQUE)

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
		boton.custom_minimum_size = Vector2(0.0, Tema.ALTO_TOQUE)
		boton.toggle_mode = true
		boton.button_group = grupo
		# PASS deja que el arrastre llegue a la fila para desplazarla con el dedo si no cabe.
		boton.mouse_filter = Control.MOUSE_FILTER_PASS
		boton.pressed.connect(_mostrar.bind(categoria))
		_fila.add_child(boton)
		_botones_categoria[categoria] = boton
	_volver.pressed.connect(volver)
	Tema.ajustar(_marco)
	_marco.resized.connect(_acomodar_columnas)
	if not _salas.is_empty():
		_mostrar(_ultima if _salas.has(_ultima) else _salas.keys()[0] as String)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pausa"):
		volver()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		volver()


## Regresa al menu principal, de donde se llega aqui.
func volver() -> void:
	MenuPrincipal.volver_a_zona = true
	get_tree().change_scene_to_file(MENU)


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
		var boton: Button = Button.new()
		boton.text = ruta.get_file().get_basename().trim_prefix("sala_").capitalize()
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
