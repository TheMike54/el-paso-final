extends "res://herramientas/pruebas/prueba_base.gd"
# Comprueba los efectos de amuletos en escenas reales, con la fisica del jugador detenida para aislar las cuentas.
# Equipar y quitar cada amuleto verifica que el cache se renueva y que se recuperan los valores base.
# Espera la creacion diferida del botin y comprueba su recogida con guardado aislado de la partida habitual.

const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const ESCENA_ENEMIGO: PackedScene = preload("res://nucleo/enemigo.tscn")
const FICHA_ENEMIGO: FichaEnemigo = preload("res://herramientas/salas/fichas/enemigo_debil.tres")
const AMULETOS: Array[StringName] = [
	&"amuleto_velocidad", &"amuleto_escudo", &"amuleto_inspiracion", &"amuleto_botin",
]
const BOTIN_BASE: int = 5

var _mundo: Node2D
var _numero_enemigo: int = 0


func _ready() -> void:
	_aislar_partida("user://prueba_efectos_amuletos.json")
	_mundo = Node2D.new()
	_mundo.name = &"Mundo"
	add_child(_mundo)
	for amuleto: StringName in AMULETOS:
		var ficha: FichaAmuleto = CatalogoEquipo.amuleto(amuleto)
		_caso("%s tiene un efecto en el catalogo" % amuleto, _tiene_efecto(amuleto, ficha))
		if ficha == null:
			continue
		var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
		_mundo.add_child(jugador)
		jugador.set_physics_process(false)
		var neutra: FichaAmuleto = FichaAmuleto.new()
		await _comprobar(amuleto, jugador, neutra, "sin amuleto")
		Partida.obtener_amuleto(amuleto)
		_caso("%s se equipa" % amuleto, Partida.equipar(amuleto))
		await _comprobar(amuleto, jugador, ficha, "con amuleto")
		_caso("%s se quita" % amuleto, Partida.desequipar(amuleto))
		await _comprobar(amuleto, jugador, neutra, "quitado vuelve a base")
		jugador.free()
		Congelado.reiniciar()
	_mundo.free()
	_restaurar_partida()
	_resumen()


func _tiene_efecto(amuleto: StringName, ficha: FichaAmuleto) -> bool:
	if ficha == null:
		return false
	match amuleto:
		&"amuleto_velocidad":
			return ficha.velocidad_factor > 1.0
		&"amuleto_escudo":
			return ficha.invulnerable_extra > 0
		&"amuleto_inspiracion":
			return ficha.inspiracion_extra > 0
		&"amuleto_botin":
			return ficha.botin_factor > 1.0
	return false


func _comprobar(amuleto: StringName, jugador: Jugador, efecto: FichaAmuleto, etapa: String) -> void:
	match amuleto:
		&"amuleto_velocidad":
			jugador._mover_en_horizontal(1.0)
			_caso("caminar: %s" % etapa,
					is_equal_approx(jugador.velocity.x, jugador.velocidad * efecto.velocidad_factor))
		&"amuleto_escudo":
			jugador.vidas = Partida.vidas_maximas
			jugador.ticks_sin_dano = 0
			jugador.recibir_dano(1, jugador.global_position.x - 100.0)
			_caso("invulnerabilidad tras dano: %s" % etapa,
					jugador.vidas == Partida.vidas_maximas - 1
					and jugador.ticks_sin_dano == jugador.ticks_invulnerable + efecto.invulnerable_extra)
		&"amuleto_inspiracion":
			_comprobar_inspiracion(jugador, efecto, etapa)
		&"amuleto_botin":
			await _comprobar_botin(jugador, efecto, etapa)


func _crear_enemigo(botin: int = 0) -> Enemigo:
	_numero_enemigo += 1
	var enemigo: Enemigo = ESCENA_ENEMIGO.instantiate() as Enemigo
	# Cada ejemplar tiene sus datos: nunca se cambia el recurso compartido del disco.
	enemigo.ficha = FICHA_ENEMIGO.duplicate() as FichaEnemigo
	enemigo.ficha.vida = 20
	enemigo.ficha.botin = botin
	enemigo.id = StringName("efectos_%d" % _numero_enemigo)
	enemigo.position = Vector2(2000.0, 0.0)
	_mundo.add_child(enemigo)
	return enemigo


func _comprobar_inspiracion(jugador: Jugador, efecto: FichaAmuleto, etapa: String) -> void:
	var esperado: int = jugador.inspiracion_por_golpe + efecto.inspiracion_extra
	Partida.inspiracion = 0
	jugador._golpeados.clear()
	var enemigo: Enemigo = _crear_enemigo()
	jugador._golpear(enemigo.golpeable)
	_caso("golpe a enemigo da Inspiracion: %s" % etapa,
			Partida.inspiracion == esperado and enemigo.vida == enemigo.ficha.vida - jugador.dano_ataque)
	jugador._golpear(enemigo.golpeable)
	_caso("el mismo ataque no cobra dos veces: %s" % etapa,
			Partida.inspiracion == esperado and enemigo.golpeable.golpes == 1)
	enemigo.free()

	Partida.inspiracion = 0
	jugador._golpeados.clear()
	enemigo = _crear_enemigo()
	enemigo.golpeable.bloqueo = func(_atacante: Node2D) -> bool: return true
	jugador._golpear(enemigo.golpeable)
	_caso("un golpe bloqueado no da Inspiracion: %s" % etapa,
			Partida.inspiracion == 0 and enemigo.vida == enemigo.ficha.vida)
	enemigo.free()
	var objeto: Golpeable = Golpeable.new()
	objeto.es_enemigo = false
	_mundo.add_child(objeto)
	jugador._golpeados.clear()
	jugador._golpear(objeto)
	_caso("un objeto no da Inspiracion: %s" % etapa, Partida.inspiracion == 0 and objeto.golpes == 1)
	objeto.free()

	jugador._golpeados.clear()
	jugador.ticks_sin_dano = 0
	enemigo = _crear_enemigo()
	var ataque: AtaqueEnemigo = AtaqueEnemigo.crear(Rect2(-40.0, -80.0, 80.0, 80.0), 0, 1, true)
	ataque.con_trazo = false
	enemigo.add_child(ataque)
	jugador._parar(ataque)
	_caso("el golpe del parry al enemigo da Inspiracion: %s" % etapa,
			Partida.inspiracion == esperado and enemigo.vida == enemigo.ficha.vida - jugador.dano_ataque)
	_caso("el parry conserva su invulnerabilidad propia: %s" % etapa,
			jugador.ticks_sin_dano == jugador.ticks_invulnerable_parry)
	enemigo.free()


func _comprobar_botin(jugador: Jugador, efecto: FichaAmuleto, etapa: String) -> void:
	var enemigo: Enemigo = _crear_enemigo(BOTIN_BASE)
	var id_botin: String = Enemigo.PREFIJO_BOTIN + String(enemigo.id)
	var esperado: int = roundi(BOTIN_BASE * efecto.botin_factor)
	var antes: int = Partida.monedas
	# _soltar_botin consulta el suelo: se vence en fisica y se espera el add_child diferido.
	await get_tree().physics_frame
	enemigo.golpeable.recibir_golpe(jugador, enemigo.ficha.vida)
	await _esperar_cuadros(2)
	var monedas: MonedasSueltas = _mundo.get_node_or_null(NodePath(id_botin)) as MonedasSueltas
	var cantidad: int = monedas.cantidad if monedas != null else -1
	if monedas != null:
		monedas._al_entrar(jugador)
	_caso("vencer y recoger el botin: %s" % etapa,
			cantidad == esperado and Partida.monedas - antes == esperado)

	enemigo = _crear_enemigo(0)
	id_botin = Enemigo.PREFIJO_BOTIN + String(enemigo.id)
	antes = Partida.monedas
	await get_tree().physics_frame
	enemigo.golpeable.recibir_golpe(jugador, enemigo.ficha.vida)
	await _esperar_cuadros(2)
	_caso("botin cero no crea monedas: %s" % etapa,
			not _mundo.has_node(NodePath(id_botin)) and Partida.monedas == antes)
