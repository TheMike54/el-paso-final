extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del mapa: las cuentas de DatosMapa (que salas se dibujan, el rectangulo que abarcan, como se encaja en la
# pantalla) y la pantalla sobre la sala mapa_1 de la zona de prueba: sin la pluma_mapa no hay nada, el banco dibuja
# lo visitado de las zonas cuyo mapa se tiene, acercado y alejado, la brujula, y que el mapa, como pagina del marco
# de menus, detenga el juego y se quede la pulsacion de pausa. Deja casos y fallos para mapa_cuentas.guion.

const SALA: String = "res://herramientas/salas/zonas/mapa/mapa_1.tscn"
const RUTA: String = "user://prueba_mapa.json"


func _ready() -> void:
	_aislar_partida(RUTA)
	_cuentas()
	_fichas_zona()
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
	Partida.utiles_tenidos.append(&"brujula")
	Partida.equipar_util(&"brujula")
	marco.abrir(&"mapa")
	mapa.alejar()
	_caso("alejado muestra todas las zonas dibujadas", not mapa.lienzo.quedo_acercado and mapa.lienzo.salas_dibujadas == 3 and mapa.lienzo.zonas_dibujadas == 2)
	_caso("con la brujula equipada se ve al jugador", mapa.lienzo.marcador_visible)
	mapa.acercar()
	_caso("+ vuelve a acercar", mapa.lienzo.quedo_acercado)
	_caso("sin mochila no hay icono de lo perdido", not mapa.lienzo.mochila_visible)
	Partida.mochila = {"sala": "mapa_2", "x": 300.0, "y": 600.0, "monto": 40}
	mapa.acercar()
	# Sin repetir la cuenta del lienzo: el punto cae dentro de el y, como mapa_2 esta a la derecha de mapa_1
	# (indice_salas.tres) y encajar centra, en la mitad derecha (x 9900 contra el centro 9200 de las dos).
	var punto: Vector2 = mapa.lienzo.mochila_en_pantalla
	var dentro: bool = Rect2(Vector2.ZERO, mapa.lienzo.size).has_point(punto) and punto.x > mapa.lienzo.size.x / 2.0
	_caso("la mochila en una sala dibujada sale en su punto", mapa.lienzo.mochila_visible and dentro)
	Partida.mochila = {"sala": "prueba_1", "x": 300.0, "y": 600.0, "monto": 40}
	mapa.acercar()
	_caso("la mochila en una sala que no se dibuja no sale", not mapa.lienzo.mochila_visible)
	Partida.mochila = {}
	mapa.acercar()

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
	await _origen_del_marcador(mapa, sala, jugador)
	Input.action_release(&"mapa_rapido")
	await get_tree().physics_frame
	await get_tree().physics_frame
	_caso("soltarlo lo oculta", not mapa.rapido and not mapa.visible)

	pausa.abrir()
	marco.abrir(&"mapa")
	_caso("con la pausa abierta el mapa no se abre", not mapa.abierta)
	pausa.cerrar()

	sala.queue_free()
	_restaurar_partida()
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


func _fichas_zona() -> void:
	var indice: IndiceSalas = IndiceSalas.new()
	_caso("sin salas la franja libre es 0", is_zero_approx(indice.franja_libre()))
	_caso("sin ficha el nombre sale del id", DatosMapa.nombre_de_zona(indice, "prueba") == "Prueba")
	_caso("sin ficha el color alterna la paleta", DatosMapa.color_de_zona(indice, "prueba", 5) == DatosMapa.COLORES_ZONA[1])
	var sala: Sala = Sala.new()
	sala.id = "prueba_1"
	sala.posicion_mapa = Vector2(20.0, 30.0)
	# Un origen de limites no nulo comprueba tambien esa suma, aunque una sala publicada lo deja en cero.
	sala.limites = Rect2(5.0, 7.0, 100.0, 50.0)
	indice.agregar_sala(sala, SALA)
	_caso("sin ficha el rectangulo parte de cero", indice.rectangulos[sala.id] == Rect2(25.0, 37.0, 100.0, 50.0))
	_caso("sin ficha no se agregan nombre ni color", indice.nombres_zona.is_empty() and indice.colores_zona.is_empty())
	var ficha: FichaZona = FichaZona.new()
	ficha.nombre = "La Prueba"
	ficha.color = Color(0.2, 0.3, 0.4, 1.0)
	ficha.origen_mapa = Vector2(1000.0, 2000.0)
	sala.ficha_zona = ficha
	indice.agregar_sala(sala, SALA)
	_caso("el origen de zona desplaza el rectangulo", indice.rectangulos[sala.id] == Rect2(1025.0, 2037.0, 100.0, 50.0))
	_caso("el nombre visible viene de la ficha via indice", DatosMapa.nombre_de_zona(indice, "prueba") == "La Prueba")
	_caso("el color viene de la ficha via indice", DatosMapa.color_de_zona(indice, "prueba", 5) == ficha.color)
	var lienzo: LienzoMapa = LienzoMapa.new()
	lienzo.size = Vector2(1000.0, 600.0)
	var zonas: Dictionary[String, Array] = DatosMapa.por_zona(indice, [sala.id] as Array[String])
	lienzo.dibujar(indice, zonas, "prueba", false, false, Vector2.ZERO)
	# Object.get permite inspeccionar el dibujo preparado sin publicar sus caches (class_object.rst).
	var nombres: PackedStringArray = lienzo.get(&"_nombres_zona")
	var colores: Dictionary[String, Color] = lienzo.get(&"_colores_zona")
	_caso("el lienzo prepara el nombre de la ficha para dibujar", nombres == PackedStringArray(["La Prueba"]))
	_caso("el lienzo prepara el color de la ficha para dibujar", colores.has("prueba") and colores["prueba"] == ficha.color)
	lienzo.free()
	indice.rectangulos["otra_1"] = Rect2(0.0, -100.0, 20.0, 20.0)
	_caso("la franja libre es el borde inferior mas bajo", is_equal_approx(indice.franja_libre(), 2087.0))
	var copia: IndiceSalas = indice.duplicate() as IndiceSalas
	_caso("indices copiados son iguales", IndiceSalas.iguales(indice, copia))
	copia.nombres_zona = {"prueba": "Otro nombre"}
	_caso("un nombre distinto cambia el indice", not IndiceSalas.iguales(indice, copia))
	copia.nombres_zona = indice.nombres_zona.duplicate()
	copia.colores_zona = {"prueba": Color.RED}
	_caso("un color distinto cambia el indice", not IndiceSalas.iguales(indice, copia))
	indice.rectangulos = {"otra_1": Rect2(0.0, -100.0, 20.0, 20.0)}
	_caso("la franja tambien considera mapas enteramente negativos", is_equal_approx(indice.franja_libre(), -80.0))
	sala.free()


# Un indice propio desplaza la sala sin cambiar el recurso cargado del juego. El centro de la sala debe quedar
# en el centro del lienzo, tanto al abrir como en el siguiente tick del mapa rapido.
func _origen_del_marcador(mapa: PantallaMapa, sala: Sala, jugador: Node2D) -> void:
	var anterior: IndiceSalas = mapa.get(&"_indice") as IndiceSalas
	var indice: IndiceSalas = IndiceSalas.new()
	var modelo: Sala = Sala.new()
	modelo.id = sala.id
	modelo.posicion_mapa = sala.posicion_mapa
	modelo.limites = sala.limites
	modelo.ficha_zona = FichaZona.new()
	modelo.ficha_zona.origen_mapa = Vector2(1000.0, 2000.0)
	indice.agregar_sala(modelo, SALA)
	modelo.free()
	var mapeadas: Array[String] = Partida.salas_mapeadas.duplicate()
	var posicion: Vector2 = jugador.position
	Partida.salas_mapeadas = [sala.id]
	jugador.position = sala.limites.get_center()
	# La pantalla recibe un indice en memoria solo para esta prueba (class_object.rst).
	mapa.set(&"_indice", indice)
	mapa.acercar()
	_caso("al abrir, el marcador incluye el origen de zona", mapa.lienzo.marcador_en_pantalla.is_equal_approx(mapa.lienzo.size / 2.0))
	await get_tree().physics_frame
	await get_tree().physics_frame
	# La gravedad cambia y; sin movimiento horizontal, x debe seguir centrada tras actualizar el mapa rapido.
	_caso("el mapa rapido conserva el origen al seguir al jugador", is_equal_approx(mapa.lienzo.marcador_en_pantalla.x, mapa.lienzo.size.x / 2.0))
	mapa.set(&"_indice", anterior)
	Partida.salas_mapeadas = mapeadas
	jugador.position = posicion
	mapa.acercar()
