extends "res://herramientas/pruebas/prueba_base.gd"
# Comprueba la ampliacion de Inspiracion y carga con recompensas reales y guardado aislado de la partida habitual.
# Lee el archivo autoguardado para comprobar persistencia, capacidades intermedias y compatibilidad sin el campo nuevo.
# Cubre topes y avisos al HUD e inventario; expone casos y fallos para que el guion compruebe el resultado.

const RUTA: String = "user://prueba_crecer.json"


func _ready() -> void:
	_aislar_partida(RUTA)
	_caso("empieza con capacidad de 33 y sin Inspiracion", Partida.inspiracion_maxima == 33 and Partida.inspiracion == 0)
	_caso("empieza con tres muescas", Partida.carga_maxima == 3)
	Partida.ganar_inspiracion(999)
	_caso("ganar no supera el maximo inicial", Partida.inspiracion == 33)
	Partida.inspiracion = 999
	_caso("asignar no supera el maximo", Partida.inspiracion == 33)
	Partida.inspiracion = -1
	_caso("la Inspiracion no es negativa", Partida.inspiracion == 0)

	var hud: Hud = Hud.new()
	hud.size = Vector2(1280.0, 720.0)
	add_child(hud)
	Partida.ganar_inspiracion(33)
	_caso("el HUD empieza con tres bloques y los llena con 33", hud.inspiracion_maxima == 33
			and hud.inspiracion_maxima / Partida.INSPIRACION_POR_GOLPE == 3 and hud.bloques_llenos == 3)
	Partida.inspiracion = 0
	var aviso: Array[int] = [0, 0, 0]
	var al_cambiar: Callable = func(actual: int, maxima: int) -> void:
		aviso[0] += 1
		aviso[1] = actual
		aviso[2] = maxima
	Eventos.inspiracion_cambiada.connect(al_cambiar)
	var modulo: Recompensa = Recompensa.new()
	modulo.tipo = Recompensa.Tipo.INSPIRACION_MAXIMA
	modulo.monto = 33
	var antes: int = Partida.autoguardados
	Partida.dar_recompensa(modulo)
	_caso("un Modulo de RAM sube a 66 y autoguarda", Partida.inspiracion_maxima == 66
			and Partida.autoguardados == antes + 1)
	_caso("subir el maximo con barra vacia avisa el nuevo maximo", aviso[0] == 1 and aviso[1] == 0 and aviso[2] == 66)
	_caso("el HUD recibe seis bloques por el bus", hud.inspiracion_maxima == 66 and hud.bloques_llenos == 0)
	Partida.ganar_inspiracion(999)
	_caso("la barra ampliada permite 66 y emite ese maximo", Partida.inspiracion == 66 and aviso[1] == 66 and aviso[2] == 66)
	Partida.dar_recompensa(modulo)
	_caso("otro modulo sube a 99", Partida.inspiracion_maxima == 99)
	Partida.dar_recompensa(modulo)
	_caso("un tercer modulo no pasa de 99", Partida.inspiracion_maxima == 99)
	Partida.ganar_inspiracion(999)
	_caso("ganar no pasa del tope ampliado", Partida.inspiracion == 99 and hud.bloques_llenos == 9)

	var muesca: Recompensa = Recompensa.new()
	muesca.tipo = Recompensa.Tipo.CARGA
	muesca.monto = 1
	var cambios: Array[int] = [0]
	var al_equipar: Callable = func() -> void: cambios[0] += 1
	Eventos.equipo_cambiado.connect(al_equipar)
	antes = Partida.autoguardados
	var de_una_en_una: bool = true
	for maxima: int in range(4, 12):
		Partida.dar_recompensa(muesca)
		de_una_en_una = de_una_en_una and Partida.carga_maxima == maxima
	_caso("la carga crece de una en una hasta 11", de_una_en_una and Partida.carga_maxima == 11)
	_caso("cada muesca avisa y autoguarda", cambios[0] == 8 and Partida.autoguardados == antes + 8)
	Partida.dar_recompensa(muesca)
	_caso("otra muesca no pasa de 11", Partida.carga_maxima == 11)

	# Lee el archivo que escribieron las recompensas, no solo el diccionario en memoria.
	var guardada: Guardado.Resultado = Guardado.cargar(RUTA)
	_caso("el autoguardado conserva los dos maximos", guardada.estado == Guardado.Estado.VALIDA
			and Guardado.entero(guardada.partida.get("inspiracion_maxima"), 0) == 99
			and Guardado.entero(guardada.partida.get("carga_maxima"), 0) == 11)
	Partida.reiniciar()
	_caso("reiniciar devuelve ambas capacidades iniciales", Partida.inspiracion_maxima == 33 and Partida.carga_maxima == 3)
	if guardada.estado == Guardado.Estado.VALIDA:
		Partida.desde_diccionario(guardada.partida)
	_caso("cargar recupera ambos maximos y vacia la barra", Partida.inspiracion_maxima == 99
			and Partida.carga_maxima == 11 and Partida.inspiracion == 0 and hud.inspiracion_maxima == 99)

	# Tambien se conservan capacidades intermedias; una carga al tope no prueba la conversion de float a int.
	Partida.inspiracion_maxima = 66
	Partida.carga_maxima = 4
	_caso("guardar capacidades intermedias funciona", Partida.guardar(RUTA) == OK)
	guardada = Guardado.cargar(RUTA)
	Partida.reiniciar()
	if guardada.estado == Guardado.Estado.VALIDA:
		Partida.desde_diccionario(guardada.partida)
	_caso("el JSON conserva 66 y 4", guardada.estado == Guardado.Estado.VALIDA
			and Partida.inspiracion_maxima == 66 and Partida.carga_maxima == 4)
	var antigua: Dictionary = Partida.a_diccionario()
	antigua.erase("inspiracion_maxima")
	_caso("guardar sin el campo nuevo funciona", Guardado.guardar(antigua, RUTA) == OK)
	guardada = Guardado.cargar(RUTA)
	_caso("Guardado rellena el campo ausente sin subir version", guardada.estado == Guardado.Estado.VALIDA
			and Guardado.entero(guardada.partida.get("inspiracion_maxima"), 0) == 33)
	if guardada.estado == Guardado.Estado.VALIDA:
		Partida.desde_diccionario(guardada.partida)
	_caso("la partida sin campo carga con 33", Partida.inspiracion_maxima == 33 and Partida.carga_maxima == 4)
	Partida.inspiracion_maxima = 99
	Partida.desde_diccionario(antigua)
	_caso("cargar sin pasar por Guardado tambien usa 33", Partida.inspiracion_maxima == 33)
	var excesiva: Dictionary = Partida.a_diccionario()
	excesiva["inspiracion_maxima"] = 999.0
	excesiva["carga_maxima"] = 999.0
	Partida.desde_diccionario(excesiva)
	_caso("cargar recorta ambos topes", Partida.inspiracion_maxima == 99 and Partida.carga_maxima == 11)
	Partida.inspiracion = 99
	antes = aviso[0]
	Partida.inspiracion_maxima = 33
	_caso("reducir capacidad recorta la barra y avisa una vez", Partida.inspiracion == 33
			and aviso[0] == antes + 1 and aviso[1] == 33 and aviso[2] == 33)

	var inventario: PaginaInventario = PaginaInventario.new()
	add_child(inventario)
	inventario.mostrar_en_marco()
	_caso("el inventario muestra el maximo actual", inventario.valores["Inspiración"] == "33 de 33")
	inventario.free()
	var articulo: ArticuloTienda = ArticuloTienda.new()
	articulo.recompensa = modulo
	_caso("el modulo tiene su forma de tienda", IconoArticulo.forma_de(articulo) == IconoArticulo.Forma.INSPIRACION_MAXIMA)
	var icono_ram: IconoArticulo = IconoArticulo.crear(IconoArticulo.forma_de(articulo), 64.0, false)
	add_child(icono_ram)
	articulo.recompensa = muesca
	_caso("la carga tiene su forma de tienda", IconoArticulo.forma_de(articulo) == IconoArticulo.Forma.CARGA)
	var icono_carga: IconoArticulo = IconoArticulo.crear(IconoArticulo.forma_de(articulo), 64.0, false)
	add_child(icono_carga)
	await _esperar_cuadros(2)
	icono_ram.free()
	icono_carga.free()
	hud.free()
	Eventos.inspiracion_cambiada.disconnect(al_cambiar)
	Eventos.equipo_cambiado.disconnect(al_equipar)
	_restaurar_partida()
	_resumen()
