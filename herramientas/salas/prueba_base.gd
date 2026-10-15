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


func _escribir(ruta: String, texto: String) -> void:
	var archivo: FileAccess = FileAccess.open(ruta, FileAccess.WRITE)
	archivo.store_string(texto)
	archivo.close()
