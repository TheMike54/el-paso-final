extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de las cuentas del combate chico que un guion no mide al tick: el congelado comun (el mas largo
# gana, se acaba solo y la sala lo reinicia) y que morir vacie la Inspiracion. Corre los casos al entrar (unos
# 12 ticks: el congelado se mide en el tiempo) y deja la cuenta en "casos" y "fallos", que
# combate_chico_cuentas.guion lee. Imprime el resumen y los fallos.
const RUTA: String = "user://prueba_combate_chico.json"


func _ready() -> void:
	_aislar_partida(RUTA)
	Congelado.reiniciar()
	_caso("sin pedir no hay congelado", not Congelado.activo())
	Congelado.pedir(10)
	Congelado.pedir(2)
	_caso("pedido, esta activo", Congelado.activo())
	# A los 5 ticks el corto (2) ya acabo y el largo (10) no; a los 12, los dos. Lejos de los bordes: desde _ready
	# el contador de cuadros puede ir corrido en uno.
	await _esperar(5)
	var sigue: bool = Congelado.activo()
	await _esperar(7)
	_caso("un congelado corto no acorta uno largo", sigue and not Congelado.activo())
	Congelado.pedir(10)
	Congelado.reiniciar()
	_caso("reiniciar lo apaga", not Congelado.activo())

	Partida.ganar_inspiracion(44)
	Eventos.jugador_muerto.emit()
	_caso("morir vacia la Inspiracion", Partida.inspiracion == 0)

	_restaurar_partida()
	_resumen()
