extends "res://herramientas/salas/prueba_base.gd"
# Prueba del mapa: las cuentas de DatosMapa (que salas se dibujan, el rectangulo que abarcan, como se encaja en la
# pantalla) y la pantalla sobre la sala mapa_1 de la zona de prueba: sin la pluma_mapa no hay nada, el banco dibuja
# lo visitado de las zonas cuyo mapa se tiene, acercado y alejado, la brujula, y que el mapa, como pagina del marco
# de menus, detenga el juego y se quede la pulsacion de pausa. Deja casos y fallos para mapa_cuentas.guion.

const SALA: String = "res://herramientas/salas/zonas/mapa/mapa_1.tscn"
const RUTA: String = "user://prueba_mapa.json"


func _ready() -> void:
	Partida.reiniciar()
	Partida.ruta_guardado = RUTA
	_cuentas()
	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await get_tree().physics_frame
	var mapa: PantallaMapa = sala.get_node(^"PantallaMapa") as PantallaMapa
	var pausa: Pausa = sala.get_node(^"Pausa") as Pausa
	var marco: MarcoMenus = sala.get_node(^"Marco") as MarcoMenus

	marco.abrir(&"mapa")
	_caso("abrir el mapa detiene el juego", mapa.abierta and get_tree().paused)
	_caso("sin la pluma_mapa no hay nada dibujado", mapa.lienzo.salas_dibujadas == 0)
	marco.cerrar()
	Partida.salas_mapeadas.append("mapa_1")
	marco.abrir(&"mapa")
	_caso("con una sala mapeada pero sin la pluma_mapa, la pantalla no la dibuja", mapa.lienzo.salas_dibujadas == 0)
	marco.cerrar()
	Partida.salas_mapeadas.clear()
	_caso("cerrar lo reanuda", not mapa.abierta and not get_tree().paused)

	Partida.habilidades.append(&"pluma_mapa")
	Partida.mapas.append("mapa")
	Partida.visitar("mapa_2")
	Partida.visitar("prueba_1")
	Eventos.descanso_en_banco.emit(&"banco_mapa_1")
	_caso("el banco dibuja lo visitado de las zonas cuyo mapa se tiene", Partida.salas_mapeadas.has("mapa_1") and Partida.salas_mapeadas.has("mapa_2") and not Partida.salas_mapeadas.has("prueba_1"))
	marco.abrir(&"mapa")
	_caso("acercado muestra las salas de la zona actual", mapa.lienzo.quedo_acercado and mapa.lienzo.salas_dibujadas == 2 and mapa.lienzo.zonas_dibujadas == 1)
	_caso("sin la brujula no se ve al jugador", not mapa.lienzo.marcador_visible)
	marco.cerrar()

	Partida.mapas.append("prueba")
	Eventos.descanso_en_banco.emit(&"banco_mapa_1")
	Partida.amuletos_tenidos.append(&"brujula")
	Partida.equipar(&"brujula")
	marco.abrir(&"mapa")
	mapa.alejar()
	_caso("alejado muestra todas las zonas dibujadas", not mapa.lienzo.quedo_acercado and mapa.lienzo.salas_dibujadas == 3 and mapa.lienzo.zonas_dibujadas == 2)
	_caso("con la brujula equipada se ve al jugador", mapa.lienzo.marcador_visible)
	mapa.acercar()
	_caso("+ vuelve a acercar", mapa.lienzo.quedo_acercado)

	# La pausa no se abre con el mapa abierto: la misma pulsacion cierra el mapa y nada mas.
	Input.action_press(&"pausa")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(&"pausa")
	_caso("pausa con el mapa abierto lo cierra sin abrir la pausa", not mapa.abierta and not marco.abierta and not pausa.abierta and not get_tree().paused)

	Input.action_press(&"mapa_rapido")
	await get_tree().physics_frame
	await get_tree().physics_frame
	_caso("mantener mapa_rapido lo muestra sin detener el juego", mapa.rapido and mapa.visible and not get_tree().paused)
	# Con la brujula, el marcador sigue al jugador cada tick sin rehacer el mapa.
	var jugador: Node2D = sala.get_node(^"Jugador") as Node2D
	var antes: Vector2 = mapa.lienzo.marcador_en_pantalla
	jugador.position += Vector2(200.0, 0.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_caso("con el mapa rapido y la brujula, el marcador sigue al jugador", mapa.lienzo.marcador_en_pantalla.x > antes.x + 1.0)
	Input.action_release(&"mapa_rapido")
	await get_tree().physics_frame
	await get_tree().physics_frame
	_caso("soltarlo lo oculta", not mapa.rapido and not mapa.visible)

	pausa.abrir()
	marco.abrir(&"mapa")
	_caso("con la pausa abierta el mapa no se abre", not mapa.abierta)
	pausa.cerrar()

	sala.queue_free()
	Partida.reiniciar()
	for ruta: String in [RUTA, RUTA + ".tmp"]:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ruta)
	_resumen()


func _cuentas() -> void:
	var indice: IndiceSalas = IndiceSalas.new()
	indice.rectangulos = {"a_1": Rect2(0, 0, 100, 50), "a_2": Rect2(100, 0, 100, 50), "b_1": Rect2(0, 100, 50, 50)}
	var zonas: Dictionary[String, Array] = DatosMapa.por_zona(indice, ["a_2", "b_1", "a_1", "c_1"] as Array[String])
	_caso("por_zona agrupa por zona, en orden, y deja fuera lo que el indice no conoce", zonas.keys() == ["a", "b"] and zonas["a"] == ["a_1", "a_2"] and zonas["b"] == ["b_1"])
	_caso("abarca une los rectangulos", DatosMapa.abarca(indice, ["a_1", "a_2", "b_1"]) == Rect2(0, 0, 200, 150))
	_caso("abarca de nada es vacio", DatosMapa.abarca(indice, []) == Rect2())
	var t: Transform2D = DatosMapa.encajar(Rect2(0, 0, 200, 100), Rect2(0, 0, 1000, 1000), 100.0)
	var esquina: Vector2 = t * Vector2(0, 0)
	var opuesta: Vector2 = t * Vector2(200, 100)
	_caso("encajar llena el ancho util sin deformar y centra", is_equal_approx(t.x.x, 4.0) and is_equal_approx(t.y.y, 4.0) and esquina.is_equal_approx(Vector2(100, 300)) and opuesta.is_equal_approx(Vector2(900, 700)))
