extends Node
# Prueba de las cuentas del combate chico que un guion no mide al tick: el congelado comun (el mas largo
# gana, se acaba solo y la sala lo reinicia) y que morir vacie la Inspiracion. Corre los casos al entrar y
# deja la cuenta en "casos" y "fallos", que combate_chico_cuentas.guion lee. Imprime el resumen y los fallos.
const RUTA: String = "user://prueba_combate_chico.json"

var casos: int = 0
var fallos: int = 0


func _ready() -> void:
	Partida.reiniciar()
	Partida.ruta_guardado = RUTA
	var ahora: int = Engine.get_physics_frames()
	Congelado.reiniciar()
	_caso("sin pedir no hay congelado", not Congelado.activo())
	Congelado.pedir(10)
	Congelado.pedir(2)
	_caso("un congelado corto no acorta uno largo", Congelado._hasta == ahora + 9)
	_caso("pedido, esta activo", Congelado.activo())
	Congelado.reiniciar()
	_caso("reiniciar lo apaga", not Congelado.activo())

	Partida.ganar_inspiracion(44)
	Eventos.jugador_muerto.emit()
	_caso("morir vacia la Inspiracion", Partida.inspiracion == 0)

	for ruta: String in [RUTA, RUTA + ".tmp"]:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ruta)
	Partida.reiniciar()
	Partida.ruta_guardado = Partida.RUTA_PRUEBAS
	print("PRUEBAS combate_chico casos=%d fallos=%d" % [casos, fallos])


func _caso(nombre: String, bien: bool) -> void:
	casos += 1
	if not bien:
		fallos += 1
		print("FALLO combate_chico: %s" % nombre)
