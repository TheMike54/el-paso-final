class_name Banco
extends Area2D
# Banco: con el jugador encima y en el suelo, la accion interactuar lo hace descansar. Descansar
# sienta al jugador sobre el banco, llena las vidas, deja este banco como punto de reaparicion,
# guarda la partida y emite Eventos.descanso_en_banco. Va como hijo directo de la raiz de una
# sala, con su forma.

## Id del banco, unico en todo el juego: es lo que se guarda.
@export var id: String = ""
## Archivo donde se guarda al descansar. Las salas de prueba usan uno propio para no tocar la partida real.
@export var ruta_guardado: String = Guardado.RUTA

## Veces que se descanso aqui desde que entro a la sala.
var descansos: int = 0


func _physics_process(_delta: float) -> void:
	if not Input.is_action_just_pressed(&"interactuar"):
		return
	for cuerpo: Node2D in get_overlapping_bodies():
		var jugador: Jugador = cuerpo as Jugador
		if jugador != null and jugador.is_on_floor() and not jugador.muerto and not jugador.descansando and not jugador.aterrizando:
			descansar(jugador)


func descansar(jugador: Jugador = null) -> void:
	descansos += 1
	if jugador != null:
		jugador.sentarse(global_position.x)
	Partida.llenar_vidas()
	Partida.banco = id
	Partida.sala = get_parent().scene_file_path
	var error: Error = Partida.guardar(ruta_guardado)
	if error != OK:
		push_error("Banco %s: no se pudo guardar la partida (error %d)" % [id, error])
	Eventos.descanso_en_banco.emit(StringName(id))
