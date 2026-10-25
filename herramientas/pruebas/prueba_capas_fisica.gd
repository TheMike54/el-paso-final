extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de las capas de fisica: crea cada pieza que detecta o es detectada y revisa la capa y la mascara que le
# pone su _ready contra la tabla de docs/contrato.md, «Capas de fisica», y que project.godot nombre las capas en
# el mismo orden que Capas. Lo que cada pieza hace con lo que ve lo cubren los guiones de combate y de salas.
const NOMBRES: PackedStringArray = ["escenario", "jugador", "golpeable", "danino", "interaccion", "ataque_jugador", "cuerpo_enemigo"]
const INTERRUPTOR: String = "res://herramientas/salas/interruptor_brujula.gd"


func _ready() -> void:
	var capas: Array[int] = [Capas.ESCENARIO, Capas.JUGADOR, Capas.GOLPEABLE, Capas.DANINO, Capas.INTERACCION, Capas.ATAQUE_JUGADOR, Capas.CUERPO_ENEMIGO]
	for i: int in range(NOMBRES.size()):
		var nombre: String = ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % (i + 1), "") as String
		_caso("la capa %d se llama %s y es Capas.%s" % [i + 1, NOMBRES[i], NOMBRES[i].to_upper()], nombre == NOMBRES[i] and capas[i] == 1 << i)
	var jugador: Jugador = (load("res://nucleo/jugador.tscn") as PackedScene).instantiate() as Jugador
	add_child(jugador)
	_caso("jugador: capa jugador, mira escenario", _tiene(jugador, Capas.JUGADOR, Capas.ESCENARIO))
	_caso("ataque del jugador: mira golpeable y danino", _tiene(jugador.get_node("Ataque") as Area2D, Capas.ATAQUE_JUGADOR, Capas.GOLPEABLE | Capas.DANINO))
	jugador.free()
	var caja: Node = (load("res://nucleo/caja_gris.tscn") as PackedScene).instantiate()
	add_child(caja)
	_caso("caja gris: como el jugador", _tiene(caja.get_node("Caja") as CollisionObject2D, Capas.JUGADOR, Capas.ESCENARIO))
	caja.free()
	_revisar("golpeable", Golpeable.new(), Capas.GOLPEABLE, 0)
	_revisar("cortable", Cortable.new(), Capas.GOLPEABLE, Capas.JUGADOR)
	_revisar("dano por contacto", DanoContacto.new(), Capas.DANINO, Capas.JUGADOR)
	_revisar("ataque enemigo", AtaqueEnemigo.crear(Rect2(0.0, 0.0, 10.0, 10.0), 0, 1, true), Capas.DANINO, Capas.JUGADOR)
	_revisar("proyectil enemigo", ProyectilEnemigo.crear_disparo(Vector2.RIGHT, 1, true), Capas.DANINO, Capas.JUGADOR)
	_revisar("bola del jugador", Proyectil.new(), Capas.ATAQUE_JUGADOR, Capas.GOLPEABLE)
	var enemigo: Enemigo = (load("res://nucleo/enemigo.tscn") as PackedScene).instantiate() as Enemigo
	enemigo.ficha = FichaEnemigo.new()
	enemigo.id = &"capas"
	_revisar("cuerpo del enemigo", enemigo, Capas.CUERPO_ENEMIGO, Capas.ESCENARIO)
	_revisar("muro rompible", MuroRompible.new(), Capas.ESCENARIO, 0)
	_revisar("porton", Porton.new(), Capas.ESCENARIO, 0)
	var coleccionable: Coleccionable = Coleccionable.new()
	coleccionable.id = Partida.PREFIJO_COLECCIONABLE + "capas"
	var interaccion: Array[Area2D] = [Puerta.new(), Banco.new(), coleccionable, ObjetoHabilidad.new(), ObjetoMapa.new(), Npc.new(), RetoPreguntas.new(), EntregaRecompensas.new(), Mochila.new(), Tienda.new(), Estacion.new(), AvisoAccion.new(), (load(INTERRUPTOR) as GDScript).new() as Area2D]
	for area: Area2D in interaccion:
		_revisar((area.get_script() as Script).resource_path.get_file().get_basename(), area, Capas.INTERACCION, Capas.JUGADOR)
	_resumen()


func _revisar(nombre: String, objeto: CollisionObject2D, capa: int, mascara: int) -> void:
	add_child(objeto)
	_caso("%s: capa %d y mascara %d" % [nombre, capa, mascara], _tiene(objeto, capa, mascara))
	objeto.free()


func _tiene(objeto: CollisionObject2D, capa: int, mascara: int) -> bool:
	return objeto != null and objeto.collision_layer == capa and objeto.collision_mask == mascara
