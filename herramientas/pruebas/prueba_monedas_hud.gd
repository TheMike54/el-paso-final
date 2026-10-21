extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del contador de PejeCoins del Hud, como el de Silksong: oculto al entrar, aparece al ganar con el +N, espera
# antes de contar, cuenta hasta el valor nuevo, suma ganancias seguidas, corrige si se gasta a media cuenta, se
# desvanece, el banco lo muestra, morir lo cuenta hasta 0 y una tienda abierta lo deja fijo, contando con el arbol
# detenido, hasta que se cierra. Su guion lee "valor . casos" y "valor . fallos".
const INTERFAZ: String = "res://interfaz/interfaz.tscn"


func _ready() -> void:
	Partida.reiniciar()
	Partida.monedas = 50
	var interfaz: CanvasLayer = (load(INTERFAZ) as PackedScene).instantiate() as CanvasLayer
	add_child(interfaz)
	var hud: Hud = interfaz.get_node(^"Hud") as Hud
	await _esperar(5)
	_caso("al entrar esta oculto aunque haya monedas", not hud.monedas_visibles and hud.monedas_mostradas == 50)

	# Ganar 100: aparece con +100, no cuenta durante la espera y llega en unos 34 ticks.
	Partida.monedas = 150
	await _esperar(Hud.TICKS_APARECER)
	_caso("ganar lo muestra con el +N", hud.monedas_visibles and hud.monedas_pendientes == 100 and hud.monedas_mostradas == 50)
	await _esperar(Hud.TICKS_ESPERA_CONTEO - Hud.TICKS_APARECER - 2)
	_caso("durante la espera no cuenta", hud.monedas_mostradas == 50)
	await _esperar(20)
	_caso("a media cuenta va entre los dos valores", hud.monedas_mostradas > 50 and hud.monedas_mostradas < 150)
	await _esperar(20)
	_caso("llega al valor nuevo y quita el +N", hud.monedas_mostradas == 150 and hud.monedas_pendientes == 0)
	await _esperar(Hud.TICKS_A_LA_VISTA - 10)
	_caso("ya contado sigue a la vista un rato", hud.monedas_visibles)
	await _esperar(10 + Hud.TICKS_DESVANECER + 2)
	_caso("despues se desvanece", not hud.monedas_visibles)

	# Dos ganancias seguidas: el +N suma y la espera vuelve a empezar.
	Partida.monedas = 160
	await _esperar(30)
	Partida.monedas = 165
	await _esperar(Hud.TICKS_ESPERA_CONTEO - 2)
	_caso("dos ganancias seguidas suman el +N y reinician la espera", hud.monedas_pendientes == 15 and hud.monedas_mostradas == 150)
	await _esperar(30)
	Partida.monedas = 135
	await _esperar(Hud.TICKS_ESPERA_CONTEO + 40)
	_caso("gastar a media cuenta corrige al valor final", hud.monedas_mostradas == 135 and hud.monedas_pendientes == 0)
	await _esperar(Hud.TICKS_A_LA_VISTA + Hud.TICKS_DESVANECER + 2)

	# Descansar en un banco lo muestra sin contar, y se vuelve a ir.
	Eventos.descanso_en_banco.emit(&"banco_prueba")
	await _esperar(Hud.TICKS_APARECER)
	_caso("descansar en un banco lo muestra sin +N", hud.monedas_visibles and hud.monedas_pendientes == 0 and hud.monedas_mostradas == 135)
	await _esperar(Hud.TICKS_A_LA_VISTA + Hud.TICKS_DESVANECER + 2)
	_caso("tras descansar se vuelve a ir", not hud.monedas_visibles)

	# Morir, en el orden del jugador: las monedas pasan a la mochila y despues se avisa la muerte. El contador baja
	# hasta 0 con el -N antes de que la pantalla oscurezca para reaparecer.
	Partida.monedas = 0
	Eventos.jugador_muerto.emit()
	await _esperar(Hud.TICKS_APARECER)
	_caso("morir muestra el -N", hud.monedas_visibles and hud.monedas_pendientes == -135)
	await _esperar(Sala.TICKS_PARA_REAPARECER - Fundido.TICKS_OSCURECER - Hud.TICKS_APARECER)
	_caso("y cuenta hasta 0 antes del fundido", hud.monedas_mostradas == 0 and hud.monedas_visibles)
	await _esperar(Hud.TICKS_ESPERA_CONTEO + 40 + Hud.TICKS_A_LA_VISTA + Hud.TICKS_DESVANECER + 2)
	await _tienda(hud)
	Partida.reiniciar()
	_resumen()


# Con una tienda abierta (el arbol detenido, como la deja MenuTienda) el contador aparece y no se va, y lo que se gasta
# cuenta igual; al cerrarla sigue un rato a la vista y se desvanece, como despues de contar. Primero sin gastar: abrir
# con el contador oculto y cerrar enseguida tambien termina desvanecido.
func _tienda(hud: Hud) -> void:
	Partida.monedas = 200
	await _esperar(Hud.TICKS_ESPERA_CONTEO + 40 + Hud.TICKS_A_LA_VISTA + Hud.TICKS_DESVANECER + 2)
	var oculto: bool = not hud.monedas_visibles
	get_tree().paused = true
	Eventos.tienda_abierta.emit()
	await _esperar(Hud.TICKS_APARECER + Hud.TICKS_A_LA_VISTA + Hud.TICKS_DESVANECER + 2)
	_caso("con una tienda abierta y el arbol detenido aparece y no se va", oculto and hud.monedas_visibles and hud.monedas_pendientes == 0)
	get_tree().paused = false
	Eventos.tienda_cerrada.emit()
	await _esperar(Hud.TICKS_A_LA_VISTA - 10)
	var sigue: bool = hud.monedas_visibles and hud.process_mode == Node.PROCESS_MODE_INHERIT
	await _esperar(10 + Hud.TICKS_DESVANECER + 2)
	_caso("cerrarla sin gastar lo deja un rato a la vista y se desvanece", sigue and not hud.monedas_visibles)

	get_tree().paused = true
	Eventos.tienda_abierta.emit()
	await _esperar(10)
	Partida.monedas = 150
	await _esperar(Hud.TICKS_ESPERA_CONTEO + 40 + Hud.TICKS_A_LA_VISTA + Hud.TICKS_DESVANECER + 2)
	_caso("con la tienda abierta lo que se gasta cuenta con el arbol detenido y sigue a la vista", hud.monedas_mostradas == 150 and hud.monedas_pendientes == 0 and hud.monedas_visibles)
	get_tree().paused = false
	Eventos.tienda_cerrada.emit()
	await _esperar(Hud.TICKS_A_LA_VISTA - 10)
	_caso("al cerrarla tras gastar sigue a la vista un rato", hud.monedas_visibles and hud.process_mode == Node.PROCESS_MODE_INHERIT)
	await _esperar(10 + Hud.TICKS_DESVANECER + 2)
	_caso("y despues se desvanece", not hud.monedas_visibles)
