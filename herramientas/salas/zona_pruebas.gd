extends Control
# Zona de pruebas: un boton por cada sala de prueba de esta carpeta, mas uno para volver al
# menu. Lista la carpeta al entrar, asi una sala nueva aparece sin tocar este archivo. Se llega
# desde la Configuracion del menu con el modo desarrollador encendido, en depuracion y en publicacion.
const CARPETA: String = "res://herramientas/salas/"
const MENU: String = "res://nucleo/menu.tscn"
## Escenas de la carpeta que no son salas para recorrer: esta y las pruebas sin jugador.
const EXCLUIDAS: PackedStringArray = ["zona_pruebas.tscn", "sala_guardado.tscn", "sala_tactil.tscn", "sala_control.tscn", "sala_foco.tscn", "sala_aterrizaje.tscn", "sala_vista.tscn", "sala_controles_configurables.tscn", "sala_menu_configuracion.tscn", "sala_peligro_anti_bucle.tscn", "sala_enemigo_al_morir.tscn", "sala_sala_id.tscn", "sala_estado_sala.tscn", "sala_combate_chico_cuentas.tscn", "sala_recursos_cuentas.tscn", "sala_mapa_cuentas.tscn"]

# En cuadricula de tres columnas: en una sola columna las salas ya no caben en la pantalla.
@onready var _lista: GridContainer = $Centro/Lista as GridContainer


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
	_agregar("Volver al menú", MENU)
	var primero: Button = _lista.get_child(0) as Button
	if primero != null:
		primero.grab_focus()


func _agregar(texto: String, escena: String) -> void:
	var boton: Button = Button.new()
	boton.text = texto
	boton.custom_minimum_size = Vector2(340.0, 64.0)
	boton.add_theme_font_size_override(&"font_size", 28)
	boton.pressed.connect(_ir.bind(escena))
	_lista.add_child(boton)


func _ir(escena: String) -> void:
	Partida.reiniciar()
	Partida.ruta_guardado = Partida.RUTA_PRUEBAS
	Sala.puerta_llegada = &""
	get_tree().change_scene_to_file(escena)
