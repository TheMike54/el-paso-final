class_name Banco
extends Interactuable
# Banco: con el jugador encima y en el suelo, la accion interactuar lo hace descansar. Descansar
# sienta al jugador sobre el banco, llena las vidas, deja este banco como punto de reaparicion,
# emite Eventos.descanso_en_banco y guarda la partida, en ese orden: lo que cambia al descansar (el
# mapa dibujado) entra en el archivo. Va como hijo directo de la raiz de una sala, con su forma. La capa y el
# disparador (sin congelado) son de la base Interactuable, sin aviso: el banco no lo dibuja.

## Rectangulo provisional de un banco sin arte; el arte como hijo (la silla de la sala) lo apaga, sin abrir la escena.
const COLOR_PROVISIONAL: Color = Color(0.5, 0.4, 0.25, 1.0)

## Id del banco, unico en todo el juego: es lo que se guarda.
@export var id: String = ""
## Archivo donde se guarda al descansar. Con Guardado.RUTA (por omision) usa Partida.ruta_guardado, el de la
## partida en curso; una sala de prueba puede fijar otro para no tocar la partida real.
@export var ruta_guardado: String = Guardado.RUTA
## Hacia donde mira el asiento: 1 derecha, -1 izquierda; el jugador se sienta mirando hacia ahi. 0: como llego (un
## banco sin dibujo de un solo lado).
@export_enum("Izquierda:-1", "Como llega:0", "Derecha:1") var mirando: int = 0


func _init() -> void:
	con_aviso = false


func _draw() -> void:
	dibujar_provisional(120.0, 40.0, COLOR_PROVISIONAL)


func _al_interactuar(jugador: Jugador) -> void:
	descansar(jugador)


func descansar(jugador: Jugador = null) -> void:
	if jugador != null:
		jugador.sentarse(global_position.x, float(mirando))
	Partida.llenar_vidas()
	Partida.banco = id
	var sala: Sala = get_parent() as Sala
	Partida.sala = sala.clave() if sala != null else get_parent().scene_file_path
	Eventos.descanso_en_banco.emit(StringName(id))
	var ruta: String = Partida.ruta_guardado if ruta_guardado == Guardado.RUTA else ruta_guardado
	var error: Error = Partida.guardar(ruta)
	if error != OK:
		push_error("Banco %s: no se pudo guardar la partida (error %d)" % [id, error])
