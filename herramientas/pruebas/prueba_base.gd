extends Node
# Base de las escenas de prueba que corre un guion: cuenta casos y fallos (los guiones leen "valor . casos" y
# "valor . fallos"), imprime solo los que fallan y el resumen, y junta los ayudantes que repiten tres o mas
# pruebas. Se hereda por ruta y sin class_name: nada fuera de herramientas/ depende de ella.

var casos: int = 0
var fallos: int = 0

# Ruta de guardado que tenia Partida antes de _aislar_partida y la que se uso mientras tanto.
var _ruta_real: String = ""
var _ruta_aislada: String = ""


## Nombre que sale en "FALLO <nombre>:" y en el resumen: el del archivo sin "prueba_".
func _nombre() -> String:
	return (get_script() as Script).resource_path.get_file().get_basename().trim_prefix("prueba_")


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO %s: %s" % [_nombre(), nombre])


func _resumen() -> void:
	print("PRUEBAS %s casos=%d fallos=%d" % [_nombre(), casos, fallos])


## Espera ticks de fisica.
func _esperar(ticks: int) -> void:
	for i: int in range(ticks):
		await get_tree().physics_frame


## Presiona una accion dos ticks y la suelta, como un toque corto.
func _presionar(accion: StringName) -> void:
	Input.action_press(accion)
	await _esperar(2)
	Input.action_release(accion)
	await get_tree().physics_frame


# Acciones del InputMap que dispara un boton del control, las ui_ incluidas: un boton real las pulsa todas en el
# mismo tick (B es volver y curar; LB, mapa_rapido y pagina_anterior). Se lee del InputMap, no de una lista.
func _acciones_del_boton(boton: JoyButton) -> Array[StringName]:
	var acciones: Array[StringName] = []
	for accion: StringName in InputMap.get_actions():
		for evento: InputEvent in InputMap.action_get_events(accion):
			var del_control: InputEventJoypadButton = evento as InputEventJoypadButton
			if del_control != null and del_control.button_index == boton:
				acciones.append(accion)
				break
	return acciones


# Presiona (sostener = true) o suelta todas las acciones de un boton del control a la vez.
func _sostener_boton(boton: JoyButton, sostener: bool) -> void:
	for accion: StringName in _acciones_del_boton(boton):
		if sostener:
			Input.action_press(accion)
		else:
			Input.action_release(accion)


# Como _presionar, pero con todas las acciones de un boton del control en los mismos ticks.
func _presionar_boton(boton: JoyButton) -> void:
	_sostener_boton(boton, true)
	await _esperar(2)
	_sostener_boton(boton, false)
	await get_tree().physics_frame


# Nombres de las pantallas encima del juego (grupo de MarcoMenus) y de los nodos extra que no se procesan despues
# del jugador en la fisica: el numero mas bajo de process_physics_priority corre primero.
func _procesados_antes_que(jugador: Jugador, extra: Array[Node]) -> PackedStringArray:
	var nodos: Array[Node] = get_tree().get_nodes_in_group(MarcoMenus.GRUPO)
	nodos.append_array(extra)
	var antes: PackedStringArray = []
	for nodo: Node in nodos:
		if nodo.process_physics_priority <= jugador.process_physics_priority:
			antes.append(String(nodo.name))
	return antes


# B (volver y curar en el mismo tick) cierra lo que abre abrir sin que el jugador lo cuente como pulsacion del
# boton de poderes: ni un toque ni, mantenido, la curacion. Pide que el jugador pueda curarse (en el suelo, con una
# vida por llenar) para que el segundo caso mida.
func _b_cierra(que: String, jugador: Jugador, abrir: Callable, abierta: Callable) -> void:
	jugador.vidas = Partida.vidas_maximas - 1
	Partida.inspiracion = jugador.costo_curacion
	abrir.call()
	await get_tree().physics_frame
	var toques: int = jugador.toques_poder
	await _presionar_boton(JOY_BUTTON_B)
	await _esperar(2)
	var sigue: bool = abierta.call()
	_caso("B cierra %s sin contar un toque del boton de poderes" % que, not sigue and not get_tree().paused and jugador.toques_poder == toques)
	abrir.call()
	await get_tree().physics_frame
	_sostener_boton(JOY_BUTTON_B, true)
	await _esperar(jugador.ticks_mantener_poder + 4)
	var curando: bool = jugador.curando
	_sostener_boton(JOY_BUTTON_B, false)
	await _esperar(3)
	_caso("B mantenido al cerrar %s no empieza a curar" % que, not curando)


## Los IconoBoton que cuelgan de un nodo, a cualquier profundidad.
func _iconos(raiz: Node) -> Array[IconoBoton]:
	var iconos: Array[IconoBoton] = []
	for nodo: Node in raiz.find_children("*", "", true, false):
		if nodo is IconoBoton:
			iconos.append(nodo as IconoBoton)
	return iconos


## Anota el ultimo dispositivo como lo haria un evento real (control o toque). Los iconos lo ven en el acto por el bus
## (Eventos.dispositivo_cambiado); se siguen esperando los dos cuadros que pedia el sondeo de antes, para no cambiar lo
## que miran los casos que la usan.
func _usar(con_control: bool) -> void:
	if con_control:
		var boton: InputEventJoypadButton = InputEventJoypadButton.new()
		boton.pressed = true
		UltimaEntrada.anotar(boton)
	else:
		var toque: InputEventScreenTouch = InputEventScreenTouch.new()
		toque.pressed = true
		UltimaEntrada.anotar(toque)
	await get_tree().process_frame
	await get_tree().process_frame


## true si todos los iconos estan visibles (o todos ocultos, con visibles = false) y hay al menos uno.
func _iconos_en(iconos: Array[IconoBoton], visibles: bool) -> bool:
	if iconos.is_empty():
		return false
	for icono: IconoBoton in iconos:
		if icono.visible != visibles:
			return false
	return true


# Aparta la partida: recuerda la ruta de guardado de Partida, guarda en ruta (un archivo de prueba) y empieza una
# partida nueva. No borra ruta antes: la prueba que necesita empezar sin archivo lo borra ella.
func _aislar_partida(ruta: String = Partida.RUTA_PRUEBAS) -> void:
	_ruta_real = Partida.ruta_guardado
	_ruta_aislada = ruta
	Partida.ruta_guardado = ruta
	Partida.reiniciar()


# Deshace _aislar_partida: partida nueva con la ruta de prueba todavia puesta (lo que se guarde al reiniciar cae en
# el archivo de prueba), la ruta de antes, y borra el archivo de prueba y su .tmp (Archivo.escribir_atomico).
func _restaurar_partida() -> void:
	Partida.reiniciar()
	Partida.ruta_guardado = _ruta_real
	for ruta: String in [_ruta_aislada, _ruta_aislada + ".tmp"]:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ruta)


func _escribir(ruta: String, texto: String) -> void:
	var archivo: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	archivo.store_string(texto)
	archivo.close()
