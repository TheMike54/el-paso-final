extends "res://herramientas/salas/prueba_base.gd"
# Prueba de que morir hace reaparecer a los enemigos fuertes, como descansar: marca a uno como vencido en
# Partida, emite la muerte del jugador por el bus y revisa la lista; tambien que descansar sigue haciendolo.
# Sin sala: una sala recargaria la escena al morir. Deja casos y fallos para enemigo_al_morir.guion.
# Imprime el resumen y los fallos.

const CLAVE: String = "res://herramientas/salas/sala_enemigos.tscn#fuerte"


func _ready() -> void:
	Partida.reiniciar()
	Partida.vencer(CLAVE)
	_caso("un fuerte vencido queda recordado", Partida.fue_vencido(CLAVE))
	Eventos.jugador_muerto.emit()
	_caso("al morir el jugador, el fuerte deja de estar vencido", not Partida.fue_vencido(CLAVE))
	Partida.vencer(CLAVE)
	Eventos.descanso_en_banco.emit(&"banco")
	_caso("descansar tambien lo hace reaparecer", not Partida.fue_vencido(CLAVE))
	Partida.reiniciar()
	_resumen()
