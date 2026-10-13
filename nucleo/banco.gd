class_name Banco
extends Area2D
# Banco: con el jugador encima y en el suelo, la accion interactuar lo hace descansar. Descansar
# sienta al jugador sobre el banco, llena las vidas, deja este banco como punto de reaparicion,
# emite Eventos.descanso_en_banco y guarda la partida, en ese orden: lo que cambia al descansar (el
# mapa dibujado) entra en el archivo. Va como hijo directo de la raiz de una sala, con su forma.

## Id del banco, unico en todo el juego: es lo que se guarda.
@export var id: String = ""
## Archivo donde se guarda al descansar. Con Guardado.RUTA (por omision) usa Partida.ruta_guardado, el de la
## partida en curso; una sala de prueba puede fijar otro para no tocar la partida real.
@export var ruta_guardado: String = Guardado.RUTA

func _physics_process(_delta: float) -> void:
	if not Input.is_action_just_pressed(&"interactuar"):
		return
	for cuerpo: Node2D in get_overlapping_bodies():
		var jugador: Jugador = cuerpo as Jugador
		if jugador != null and jugador.puede_interactuar:
			descansar(jugador)


func descansar(jugador: Jugador = null) -> void:
	if jugador != null:
		jugador.sentarse(global_position.x)
	Partida.llenar_vidas()
	Partida.banco = id
	var sala: Sala = get_parent() as Sala
	Partida.sala = sala.clave() if sala != null else get_parent().scene_file_path
	Eventos.descanso_en_banco.emit(StringName(id))
	var ruta: String = Partida.ruta_guardado if ruta_guardado == Guardado.RUTA else ruta_guardado
	var error: Error = Partida.guardar(ruta)
	if error != OK:
		push_error("Banco %s: no se pudo guardar la partida (error %d)" % [id, error])
