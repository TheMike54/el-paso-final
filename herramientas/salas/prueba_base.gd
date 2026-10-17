extends Node
# Base de las escenas de prueba que corre un guion: cuenta casos y fallos (los guiones leen "valor . casos" y
# "valor . fallos"), imprime solo los que fallan y el resumen, y junta los ayudantes que repiten tres o mas
# pruebas. Se hereda por ruta y sin class_name: nada fuera de herramientas/ depende de ella.

var casos: int = 0
var fallos: int = 0


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


## Los IconoBoton que cuelgan de un nodo, a cualquier profundidad.
func _iconos(raiz: Node) -> Array[IconoBoton]:
	var iconos: Array[IconoBoton] = []
	for nodo: Node in raiz.find_children("*", "", true, false):
		if nodo is IconoBoton:
			iconos.append(nodo as IconoBoton)
	return iconos


## Anota el ultimo dispositivo como lo haria un evento real (control o toque) y espera a que los iconos lo vean:
## process_frame llega antes del _process de ese cuadro, asi que son dos.
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


func _escribir(ruta: String, texto: String) -> void:
	var archivo: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	archivo.store_string(texto)
	archivo.close()
