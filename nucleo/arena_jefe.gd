# Arena de jefe inspirada en la BattleScene de Hollow Knight: encierra y despierta al entrar.
# La victoria abre los portones, entrega el premio y avisa a Partida por el bus existente.
# El id de la arena recuerda al jefe para siempre; morir aborta la victoria hasta recargar la sala.
class_name ArenaJefe
extends Area2D

@export var jefe: Enemigo = null
@export var id_jefe: StringName = &""
@export var portones: Array[Porton] = []
@export var recompensa: Recompensa = null

## Si ya entro el jugador y el combate sigue pendiente.
var activa: bool = false
var _terminada: bool = false


func _ready() -> void:
	Capas.poner(self, Capas.INTERACCION, Capas.JUGADOR)
	# Un jefe ya vencido se apaga antes de cualquier espera: sin esto existiria, chocaria y se veria hasta que
	# llegue su queue_free (apagado, sus cuerpos y areas salen de la fisica: classes/class_collisionobject2d.rst:208).
	if Partida.jefes.has(id_jefe) and is_instance_valid(jefe):
		jefe.process_mode = Node.PROCESS_MODE_DISABLED
		jefe.hide()
	# Los hermanos pueden estar escritos en cualquier orden: esperar ready no consume ticks.
	# classes/class_node.rst:2575, :3073 (Godot 4.7).
	for porton: Porton in portones:
		if is_instance_valid(porton) and not porton.is_node_ready():
			await porton.ready
	if Partida.jefes.has(id_jefe):
		_terminada = true
		if is_instance_valid(jefe):
			jefe.queue_free()
		_abrir()
		return
	if not is_instance_valid(jefe) or id_jefe.is_empty():
		push_error("ArenaJefe %s: falta jefe o id_jefe" % name)
		return
	if not jefe.is_node_ready():
		await jefe.ready
	_dormir(true)
	jefe.vencido.connect(_al_vencer)
	Eventos.jugador_muerto.connect(_al_morir)
	body_entered.connect(_al_entrar)


func _al_entrar(cuerpo: Node2D) -> void:
	var jugador: Jugador = cuerpo as Jugador
	if _terminada or activa or jugador == null or jugador.muerto:
		return
	activa = true
	for porton: Porton in portones:
		if is_instance_valid(porton):
			porton.cerrar()
	_dormir(false)


func _al_vencer() -> void:
	var jugador: Jugador = Jugador.actual(get_tree())
	if _terminada or (jugador != null and jugador.muerto):
		return
	_terminada = true
	activa = false
	_abrir()
	if recompensa != null:
		Partida.dar_recompensa(recompensa)
	Eventos.jefe_vencido.emit(id_jefe)


func _al_morir() -> void:
	if _terminada:
		return
	_terminada = true
	activa = false
	_dormir(true)
	# Sala conserva su reaparicion habitual; ningun premio durante el fundido de muerte.


func _dormir(si: bool) -> void:
	if not is_instance_valid(jefe):
		return
	var comportamiento: ComportamientoEnemigo = jefe.get_node_or_null(^"Comportamiento") as ComportamientoEnemigo
	if comportamiento != null:
		comportamiento.set_physics_process(not si)


func _abrir() -> void:
	for porton: Porton in portones:
		if is_instance_valid(porton):
			porton.abrir()
