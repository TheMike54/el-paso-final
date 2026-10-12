extends Control
# Zona de pruebas: un boton por cada sala de prueba de esta carpeta, en una lista que se desplaza, y Volver
# fijo arriba. Lista la carpeta al entrar, asi una sala nueva aparece sin tocar este archivo. Se llega desde la
# Configuracion del menu con el modo desarrollador encendido, en depuracion y en publicacion; Volver, Atras y
# pausa regresan a esa Configuracion, un nivel atras, como en el resto de los menus.
const CARPETA: String = "res://herramientas/salas/"
const MENU: String = "res://nucleo/menu.tscn"
## Escenas de la carpeta que no son salas para recorrer: esta y las pruebas sin jugador.
const EXCLUIDAS: PackedStringArray = ["zona_pruebas.tscn", "sala_guardado.tscn", "sala_tactil.tscn", "sala_control.tscn", "sala_foco.tscn", "sala_aterrizaje.tscn", "sala_vista.tscn", "sala_controles_configurables.tscn", "sala_menu_configuracion.tscn", "sala_peligro_anti_bucle.tscn", "sala_enemigo_al_morir.tscn", "sala_sala_id.tscn", "sala_estado_sala.tscn", "sala_combate_chico_cuentas.tscn", "sala_recursos_cuentas.tscn", "sala_mapa_cuentas.tscn"]
## Tamano de cada boton y separacion de la cuadricula: caben tantas columnas como permita el ancho (de 3 a 6).
const TAMANO_BOTON: Vector2 = Vector2(260.0, 64.0)
const SEPARACION: float = 16.0

# En cuadricula y dentro de un ScrollContainer: con unas 30 salas ya no cabian en 480 px de alto (S50, 12-oct-2026).
@onready var _lista: GridContainer = $Desplazable/Centro/Lista as GridContainer
@onready var _desplazable: ScrollContainer = $Desplazable as ScrollContainer
@onready var _volver: Button = $Volver as Button


func _ready() -> void:
	for archivo: String in DirAccess.get_files_at(CARPETA):
		# En un paquete exportado las escenas aparecen como <nombre>.tscn.remap.
		var nombre: String = archivo.trim_suffix(".remap")
		if nombre.ends_with(".tscn") and not EXCLUIDAS.has(nombre):
			_agregar(nombre.get_basename().capitalize(), CARPETA + nombre)
	# Zonas de prueba (zonas/<zona>/<id>.tscn): salas con id conectadas entre si, como las del juego.
	for zona: String in DirAccess.get_directories_at(CARPETA + "zonas"):
		for archivo: String in DirAccess.get_files_at(CARPETA + "zonas/" + zona):
			var nombre: String = archivo.trim_suffix(".remap")
			if nombre.ends_with(".tscn"):
				_agregar("Zona " + nombre.get_basename().capitalize(), CARPETA + "zonas/" + zona + "/" + nombre)
	_volver.pressed.connect(volver)
	_acomodar_columnas()
	resized.connect(_acomodar_columnas)
	var primero: Button = _lista.get_child(0) as Button
	if primero != null:
		primero.grab_focus()


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"pausa"):
		volver()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		volver()


## Regresa a la Configuracion del menu, de donde se llega aqui.
func volver() -> void:
	Configuracion.abrir_al_volver = true
	get_tree().change_scene_to_file(MENU)


func _agregar(texto: String, escena: String) -> void:
	var boton: Button = Button.new()
	boton.text = texto
	boton.custom_minimum_size = TAMANO_BOTON
	boton.add_theme_font_size_override(&"font_size", 24)
	# PASS deja que el arrastre llegue a la lista para desplazarla con el dedo.
	boton.mouse_filter = Control.MOUSE_FILTER_PASS
	boton.pressed.connect(_ir.bind(escena))
	_lista.add_child(boton)


func _acomodar_columnas() -> void:
	var ancho: float = _desplazable.size.x if _desplazable.size.x > 0.0 else size.x
	_lista.columns = clampi(floori((ancho - SEPARACION) / (TAMANO_BOTON.x + SEPARACION)), 3, 6)


func _ir(escena: String) -> void:
	Partida.reiniciar()
	Partida.ruta_guardado = Partida.RUTA_PRUEBAS
	Sala.puerta_llegada = &""
	get_tree().change_scene_to_file(escena)
