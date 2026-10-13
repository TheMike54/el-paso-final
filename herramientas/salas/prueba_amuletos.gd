extends Node
# Prueba de los amuletos: Partida pone y quita solo lo que se tiene y con lugar, y autoguarda; la pagina Amuletos del
# marco de menus deja cambiarlos solo sentado en un banco y de pie solo los muestra. Deja casos y fallos para
# amuletos.guion e imprime el resumen.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const RUTA: String = "user://prueba_amuletos.json"

var casos: int = 0
var fallos: int = 0


func _ready() -> void:
	var ruta_real: String = Partida.ruta_guardado
	Partida.ruta_guardado = RUTA
	Partida.reiniciar()

	# Partida.
	_caso("sin tenerlo no se pone", not Partida.puede_equipar(&"brujula") and not Partida.equipar(&"brujula") and Partida.amuletos_equipados.is_empty())
	Partida.amuletos_tenidos.append_array([&"brujula", &"a", &"b", &"c"] as Array[StringName])
	var antes: int = Partida.autoguardados
	_caso("uno que se tiene se pone y autoguarda", Partida.equipar(&"brujula") and Partida.esta_equipado(&"brujula") and Partida.autoguardados == antes + 1)
	_caso("puesto no se pone dos veces", not Partida.equipar(&"brujula") and Partida.amuletos_equipados.size() == 1)
	Partida.equipar(&"a")
	Partida.equipar(&"b")
	_caso("con %d puestos no cabe otro" % Partida.MAX_EQUIPADOS, not Partida.puede_equipar(&"c") and not Partida.equipar(&"c") and Partida.amuletos_equipados.size() == Partida.MAX_EQUIPADOS)
	antes = Partida.autoguardados
	_caso("quitar uno puesto lo quita y autoguarda", Partida.desequipar(&"a") and not Partida.esta_equipado(&"a") and Partida.autoguardados == antes + 1)
	_caso("quitar uno que no esta puesto no hace nada", not Partida.desequipar(&"a") and Partida.autoguardados == antes + 1)
	var datos: Dictionary = Partida.a_diccionario()
	Partida.reiniciar()
	Partida.desde_diccionario(datos)
	_caso("los puestos vuelven al cargar", Partida.esta_equipado(&"brujula") and Partida.esta_equipado(&"b") and not Partida.esta_equipado(&"a") and Partida.amuletos_tenidos.size() == 4)

	# Pagina del marco, con un jugador de pie (abrir y cerrar el marco lo prueba prueba_marco.gd).
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.name = "Jugador"
	add_child(jugador)
	var pantalla: PantallaAmuletos = PantallaAmuletos.new()
	pantalla.name = "Amuletos"
	add_child(pantalla)
	_caso("es la pagina amuletos del marco", pantalla.is_in_group(MarcoMenus.GRUPO_PAGINAS) and pantalla.id_pagina() == &"amuletos")
	pantalla.mostrar_en_marco()
	_caso("mostrarla lista los que se tienen", pantalla.visible and pantalla.botones.size() == 4)
	_caso("de pie se ven pero no se cambian", pantalla.botones[&"a"].disabled and not pantalla.alternar(&"a") and not Partida.esta_equipado(&"a"))
	pantalla.ocultar_de_marco()
	_caso("ocultarla la quita de la vista", not pantalla.visible and not pantalla.abierta)

	# Sentado.
	jugador.descansando = true
	pantalla.mostrar_en_marco()
	_caso("sentado, el que cabe responde y el que esta puesto tambien", not pantalla.botones[&"a"].disabled and not pantalla.botones[&"brujula"].disabled)
	_caso("sentado se quita uno puesto", pantalla.alternar(&"brujula") and not Partida.esta_equipado(&"brujula") and pantalla.botones[&"brujula"].text.ends_with("guardado"))
	pantalla.alternar(&"a")
	pantalla.alternar(&"c")
	_caso("sentado se ponen hasta llenar y el siguiente no responde", Partida.amuletos_equipados.size() == Partida.MAX_EQUIPADOS and pantalla.botones[&"brujula"].disabled and not pantalla.alternar(&"brujula"))
	pantalla.ocultar_de_marco()

	pantalla.free()
	jugador.free()
	get_tree().paused = false
	Partida.reiniciar()
	Partida.ruta_guardado = ruta_real
	DirAccess.remove_absolute(RUTA)
	print("PRUEBAS amuletos casos=%d fallos=%d" % [casos, fallos])


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO amuletos: %s" % nombre)
