extends "res://herramientas/pruebas/prueba_base.gd"
# Comprueba el efecto de cada util con y sin el puesto: Gato (botin real del enemigo), Log de Errores (Inspiracion por
# golpe de enemigo, no por aspas ni peligros, tambien a traves de un DanoContacto real), Suela (retroceso a la mitad)
# y Cartera (la mochila con 0, 1, impar y par). Fisica del jugador detenida y guardado aislado.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const ESCENA_ENEMIGO: PackedScene = preload("res://nucleo/enemigo.tscn")
const ESCENA_ASPAS: PackedScene = preload("res://contenido/objetos/celda/aspas.tscn")
const FICHA_ENEMIGO: FichaEnemigo = preload("res://herramientas/salas/fichas/enemigo_debil.tres")
const BOTIN_BASE: int = 5
const SALA: String = "efectos_utiles"

var _mundo: Node2D
var _numero_enemigo: int = 0


func _ready() -> void:
	_aislar_partida("user://prueba_efectos_utiles.json")
	_mundo = Node2D.new()
	_mundo.name = &"Mundo"
	add_child(_mundo)
	for util: StringName in Utiles.TODOS:
		Partida.obtener_util(util)
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	_mundo.add_child(jugador)
	jugador.set_physics_process(false)
	await _esperar(2)

	await _probar_gato(jugador)
	await _probar_log(jugador)
	_probar_suela(jugador)
	_probar_cartera()

	jugador.free()
	_mundo.free()
	Congelado.reiniciar()
	_restaurar_partida()
	_resumen()


func _probar_gato(jugador: Jugador) -> void:
	_caso("sin Gato el botin es el de la ficha", Enemigo.cantidad_botin(BOTIN_BASE) == BOTIN_BASE)
	await _vencer_y_recoger(jugador, BOTIN_BASE, "sin Gato")
	Partida.equipar_util(Utiles.GATO_SUERTE)
	var con_gato: int = roundi(BOTIN_BASE * Utiles.FACTOR_BOTIN_GATO)
	_caso("con Gato el botin se multiplica y redondea", con_gato == 8 and Enemigo.cantidad_botin(BOTIN_BASE) == con_gato)
	await _vencer_y_recoger(jugador, con_gato, "con Gato")
	_caso("con Gato un botin cero sigue en cero", Enemigo.cantidad_botin(0) == 0)
	Partida.desequipar_util(Utiles.GATO_SUERTE)
	_caso("quitar el Gato vuelve al botin de la ficha", Enemigo.cantidad_botin(BOTIN_BASE) == BOTIN_BASE)


func _vencer_y_recoger(jugador: Jugador, esperado: int, etapa: String) -> void:
	var enemigo: Enemigo = _crear_enemigo(BOTIN_BASE)
	var id_botin: String = Enemigo.PREFIJO_BOTIN + String(enemigo.id)
	var antes: int = Partida.monedas
	# _soltar_botin consulta el suelo: se vence en fisica y se espera el add_child diferido.
	await get_tree().physics_frame
	enemigo.golpeable.recibir_golpe(jugador, enemigo.ficha.vida)
	await _esperar_cuadros(2)
	var monedas: MonedasSueltas = _mundo.get_node_or_null(NodePath(id_botin)) as MonedasSueltas
	var cantidad: int = monedas.cantidad if monedas != null else -1
	if monedas != null:
		monedas._al_entrar(jugador)
	_caso("vencer y recoger el botin: %s" % etapa, cantidad == esperado and Partida.monedas - antes == esperado)


func _probar_log(jugador: Jugador) -> void:
	var bloque: int = Partida.INSPIRACION_POR_GOLPE
	_golpear(jugador, false, true)
	_caso("sin Log un golpe de enemigo no da Inspiracion", Partida.inspiracion == 0)
	Partida.equipar_util(Utiles.LOG_ERRORES)
	_golpear(jugador, false, true)
	_caso("con Log un golpe de enemigo da un bloque", Partida.inspiracion == bloque)
	_golpear(jugador, false, false)
	_caso("con Log un golpe del escenario (aspas) no da nada", Partida.inspiracion == 0)
	# Un peligro deja al jugador esperando reaparecer, y con su fisica detenida nunca acaba: va en otro jugador.
	var otro: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	_mundo.add_child(otro)
	otro.set_physics_process(false)
	_golpear(otro, true, false)
	_caso("con Log un peligro no da nada", Partida.inspiracion == 0 and otro.vidas == Partida.vidas_maximas - 1)
	otro.free()

	# Quien marca el golpe: el cuerpo del enemigo y sus ataques si, las aspas de La Celda no.
	var enemigo: Enemigo = _crear_enemigo(0)
	var contacto_enemigo: DanoContacto = enemigo.get_node(^"DanoContacto") as DanoContacto
	var ataque: AtaqueEnemigo = AtaqueEnemigo.crear(Rect2(-40.0, -80.0, 80.0, 80.0), 0, 1, false)
	var aspas: Node = ESCENA_ASPAS.instantiate()
	var dano_aspas: DanoContacto = aspas.get_node(^"Giro/Dano") as DanoContacto
	_caso("el cuerpo y el ataque del enemigo son golpes de enemigo; las aspas no", contacto_enemigo.de_enemigo
			and ataque.de_enemigo and dano_aspas != null and not dano_aspas.de_enemigo and not dano_aspas.peligro)
	enemigo.free()
	ataque.free()
	aspas.free()

	# Un DanoContacto real encima del jugador le pasa de_enemigo a recibir_dano.
	_preparar_golpe(jugador)
	await _tocar_con(jugador, true)
	_caso("un DanoContacto de enemigo encima da el bloque con Log", Partida.inspiracion == bloque
			and jugador.vidas == Partida.vidas_maximas - 1)
	_preparar_golpe(jugador)
	await _tocar_con(jugador, false)
	_caso("un DanoContacto del escenario encima no lo da", Partida.inspiracion == 0
			and jugador.vidas == Partida.vidas_maximas - 1)
	Partida.desequipar_util(Utiles.LOG_ERRORES)
	_golpear(jugador, false, true)
	_caso("quitar el Log deja de dar Inspiracion", Partida.inspiracion == 0)


func _preparar_golpe(jugador: Jugador) -> void:
	jugador.vidas = Partida.vidas_maximas
	jugador.ticks_sin_dano = 0
	Partida.inspiracion = 0
	Congelado.reiniciar()


func _golpear(jugador: Jugador, peligro: bool, de_enemigo: bool) -> void:
	_preparar_golpe(jugador)
	jugador.recibir_dano(1, jugador.global_position.x - 100.0, peligro, de_enemigo)


func _tocar_con(jugador: Jugador, de_enemigo: bool) -> void:
	var contacto: DanoContacto = DanoContacto.new()
	contacto.de_enemigo = de_enemigo
	var forma: CollisionShape2D = CollisionShape2D.new()
	var caja: RectangleShape2D = RectangleShape2D.new()
	caja.size = Vector2(200.0, 400.0)
	forma.shape = caja
	contacto.add_child(forma)
	contacto.global_position = jugador.global_position
	_mundo.add_child(contacto)
	await _esperar(4)
	contacto.free()


func _probar_suela(jugador: Jugador) -> void:
	_golpear(jugador, false, true)
	var sin_y: float = jugador.velocity.y
	jugador._mover_en_horizontal(0.0)
	var sin_x: float = jugador.velocity.x
	_caso("sin Suela el golpe empuja con el retroceso entero", is_equal_approx(sin_y, -jugador.retroceso.y)
			and is_equal_approx(absf(sin_x), jugador.retroceso.x))
	Partida.equipar_util(Utiles.SUELA_ANTIDERRAPANTE)
	_golpear(jugador, false, true)
	var con_y: float = jugador.velocity.y
	jugador._mover_en_horizontal(0.0)
	var con_x: float = jugador.velocity.x
	_caso("con Suela el golpe empuja la mitad", is_equal_approx(con_y, sin_y * Utiles.FACTOR_EMPUJE_SUELA)
			and is_equal_approx(con_x, sin_x * Utiles.FACTOR_EMPUJE_SUELA) and Utiles.FACTOR_EMPUJE_SUELA < 1.0)
	Partida.desequipar_util(Utiles.SUELA_ANTIDERRAPANTE)
	_golpear(jugador, false, true)
	_caso("quitar la Suela vuelve al retroceso entero", is_equal_approx(jugador.velocity.y, sin_y))
	Congelado.reiniciar()


func _probar_cartera() -> void:
	_caso("sin Cartera la mochila se lleva todo", _morir_con(7) == Vector2i(7, 0))
	Partida.equipar_util(Utiles.CARTERA_EMERGENCIA)
	Partida.mochila = {}
	Partida.monedas = 0
	Partida.dejar_mochila(SALA, Vector2.ZERO)
	_caso("con Cartera y sin monedas no hay mochila", Partida.mochila.is_empty() and Partida.monedas == 0)
	_caso("con Cartera y 1 moneda, la mochila se la lleva", _morir_con(1) == Vector2i(1, 0))
	_caso("con Cartera e impar (7), la mochila se lleva 4 y quedan 3", _morir_con(7) == Vector2i(4, 3))
	_caso("con Cartera y par (8), mitad y mitad", _morir_con(8) == Vector2i(4, 4))
	Partida.autoguardar()
	var leida: Guardado.Resultado = Guardado.cargar(Partida.ruta_guardado)
	_caso("la mochila de la Cartera se guarda y se lee bien", leida.estado == Guardado.Estado.VALIDA
			and Guardado.entero((leida.partida["mochila"] as Dictionary).get("monto"), 0) == 4
			and Guardado.entero(leida.partida["monedas"], -1) == 4)
	Partida.desequipar_util(Utiles.CARTERA_EMERGENCIA)
	_caso("quitar la Cartera vuelve a dejar todo", _morir_con(5) == Vector2i(5, 0))
	Partida.mochila = {}
	Partida.monedas = 0


# Muere con esa cantidad de monedas y devuelve (monto de la mochila, monedas que quedan).
func _morir_con(cantidad: int) -> Vector2i:
	Partida.mochila = {}
	Partida.monedas = cantidad
	Partida.dejar_mochila(SALA, Vector2(10.0, 20.0))
	return Vector2i(Partida.monto_mochila(), Partida.monedas)


func _crear_enemigo(botin: int) -> Enemigo:
	_numero_enemigo += 1
	var enemigo: Enemigo = ESCENA_ENEMIGO.instantiate() as Enemigo
	# Cada ejemplar tiene sus datos: nunca se cambia el recurso compartido del disco.
	enemigo.ficha = FICHA_ENEMIGO.duplicate() as FichaEnemigo
	enemigo.ficha.vida = 20
	enemigo.ficha.botin = botin
	enemigo.id = StringName("efectos_utiles_%d" % _numero_enemigo)
	enemigo.position = Vector2(2000.0, 0.0)
	_mundo.add_child(enemigo)
	return enemigo
