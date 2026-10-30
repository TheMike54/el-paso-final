extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de los datos por ejemplar de los comportamientos: dos voladores del mismo tipo en la misma sala, uno con un
# radio de alerta propio (Enemigo.datos, que gana a los de su ficha) y otro sin datos, ven al jugador a la misma
# distancia de forma distinta; un tercero, mas cerca, toma los de su ficha (radio 100) y no lo ve. Desde que aparece,
# el jugador ya esta entre los radios: si empezara mas cerca, el volador lo veria con cualquier radio y lo seguiria
# persiguiendo. Los datos no se tocan al correr. Deja casos y fallos para enemigo_datos.guion.

const SALA: String = "res://herramientas/salas/enemigos/sala_volador.tscn"
const ENEMIGO: String = "res://nucleo/enemigo.tscn"
const DATOS_VOLADOR: String = "res://herramientas/salas/comportamientos/datos_volador.gd"
const FICHA: String = "res://herramientas/salas/fichas/volador.tres"


func _ready() -> void:
	_aislar_partida()
	var ficha: FichaEnemigo = load(FICHA) as FichaEnemigo
	var clase_datos: GDScript = load(DATOS_VOLADOR) as GDScript
	var propios: DatosComportamiento = clase_datos.new() as DatosComportamiento
	propios.set(&"radio_alerta", 600.0)
	var de_ficha: DatosComportamiento = clase_datos.new() as DatosComportamiento
	de_ficha.set(&"radio_alerta", 100.0)
	var ficha_con_datos: FichaEnemigo = ficha.duplicate() as FichaEnemigo
	ficha_con_datos.datos = de_ficha

	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	var cerca: Enemigo = sala.get_node(^"Enemigo") as Enemigo
	cerca.position = Vector2(150.0, 400.0)
	cerca.ficha = ficha_con_datos
	cerca.datos = propios
	var lejos: Enemigo = _volador(&"volador_lejos", ficha, Vector2(1050.0, 400.0))
	sala.add_child(lejos)
	var con_ficha: Enemigo = _volador(&"volador_ficha", ficha_con_datos, Vector2(600.0, 450.0))
	sala.add_child(con_ficha)
	add_child(sala)
	await _esperar(3)
	var jugador: Jugador = get_tree().get_first_node_in_group(&"jugador") as Jugador
	var c_cerca: ComportamientoEnemigo = cerca.get_node(^"Comportamiento") as ComportamientoEnemigo
	var c_lejos: ComportamientoEnemigo = lejos.get_node(^"Comportamiento") as ComportamientoEnemigo
	var c_ficha: ComportamientoEnemigo = con_ficha.get_node(^"Comportamiento") as ComportamientoEnemigo

	_caso("los datos del ejemplar ganan a los de su ficha", c_cerca.datos == propios)
	var de_clase: bool = c_lejos.datos != null and c_lejos.datos.get_script() == clase_datos
	var radio_lejos: float = c_lejos.datos.get(&"radio_alerta") if de_clase else 0.0
	_caso("sin datos en el ejemplar ni en la ficha usa los de su clase", de_clase and is_equal_approx(radio_lejos, 330.0))
	_caso("sin datos en el ejemplar usa los de la ficha", c_ficha.datos == de_ficha)
	var distancia_cerca: float = c_cerca.centro().distance_to(jugador.centro())
	var distancia_lejos: float = c_lejos.centro().distance_to(jugador.centro())
	_caso("los dos voladores quedan entre los dos radios", distancia_cerca > 330.0 and distancia_cerca < 600.0
			and distancia_lejos > 330.0 and distancia_lejos < 600.0)
	var distancia_ficha: float = c_ficha.centro().distance_to(jugador.centro())
	_caso("el de la ficha queda entre 100 y 330", distancia_ficha > 100.0 and distancia_ficha < 330.0)
	await _esperar(5)
	var persigue_cerca: bool = c_cerca.get(&"persiguiendo")
	var persigue_lejos: bool = c_lejos.get(&"persiguiendo")
	var persigue_ficha: bool = c_ficha.get(&"persiguiendo")
	_caso("con radio 600 lo ve y lo persigue", persigue_cerca)
	_caso("con el radio de su clase no lo ve", not persigue_lejos)
	_caso("con el radio de su ficha (100) no lo ve", not persigue_ficha)
	_caso("los datos no cambian al correr", is_equal_approx(propios.get(&"radio_alerta") as float, 600.0)
			and ficha.datos == null)
	_restaurar_partida()
	_resumen()


func _volador(id: StringName, ficha: FichaEnemigo, posicion: Vector2) -> Enemigo:
	var enemigo: Enemigo = (load(ENEMIGO) as PackedScene).instantiate() as Enemigo
	enemigo.name = String(id)
	enemigo.id = id
	enemigo.ficha = ficha
	enemigo.position = posicion
	return enemigo
