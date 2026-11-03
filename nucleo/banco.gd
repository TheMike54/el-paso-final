class_name Banco
extends Interactuable
# Descanso al interactuar desde el suelo: sienta, cura y fija el banco como punto de reaparicion.
# Emite descanso_en_banco antes de guardar para incluir cambios del descanso, como el mapa dibujado.
# Se coloca con su forma en una sala o pieza; hereda capa y disparador sin congelado de Interactuable.
# No dibuja el aviso de interaccion del resto de interactuables.

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
	Partida.sala = Sala.clave_de(self)
	Eventos.descanso_en_banco.emit(StringName(id))
	var ruta: String = Partida.ruta_guardado if ruta_guardado == Guardado.RUTA else ruta_guardado
	Partida.guardar(ruta)
