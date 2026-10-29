class_name Sonido
extends Node
# Efectos de los eventos del juego: escucha el bus (como Vibracion) y toca lo que diga la FichaSonidos en el bus
# Efectos, sin repetir el mismo evento en ticks seguidos. La crea Arranque y vive fuera de las salas: nada se corta al
# cruzar una puerta o salir al menu. Corre tambien en pausa. Un solo AudioStreamPlayer con AudioStreamPolyphonic: un
# efecto nuevo nunca corta a uno que ya suena. La musica no esta aqui.

## La ficha del juego: los sonidos del jugador y de lo que toca.
const FICHA: String = "res://nucleo/sonidos/sonidos_jugador.tres"

## Efectos a la vez. Con todas ocupadas play_stream descarta el nuevo y no corta uno viejo
## (classes/class_audiostreamplaybackpolyphonic.rst:94): se cuenta en descartados.
@export var voces: int = 8
## Ticks minimos entre dos veces el mismo evento (la onda de la picada golpea a varios en un tick).
@export var ticks_entre_iguales: int = 3
## Eventos que no esperan ticks_entre_iguales, como en Vibracion: el dano y el parry no deben perderse.
@export var sin_espera: Array[StringName] = [&"dano", &"parry"]
## Velocidad de caida minima, en px/s, para que un aterrizaje comun suene. jugador_aterrizo sale en todo aterrizaje con
## caida: bajar un escalon o la union de dos piezas de suelo deja al jugador uno o dos ticks en el aire (unos 40 px/s
## por tick con gravedad 2400) y no debe sonar. 200 px/s es una caida de unos 8 px; saltar o caer de una cornisa llega
## a cientos. El aterrizaje duro y el de la picada suenan siempre.
@export var velocidad_aterrizaje_min: float = 200.0

var ficha: FichaSonidos = null
## Publicos para los guiones y la prueba, como en Vibracion: pedidos, tocados, el ultimo, los que no cupieron en
## las voces y si esta mudo (sin pantalla).
var pedidos: int = 0
var tocados: int = 0
var ultimo: StringName = &""
var descartados: int = 0
## Sin pantalla nadie oye: se cuenta igual pero no se toca (tocar sin pantalla dejaba recursos vivos al salir,
## docs/errores/2026-10-13-musica-sin-pantalla.md).
var mudo: bool = Ajustes.sin_ventana()

var _reproductor: AudioStreamPlayer = null
var _voces: AudioStreamPlaybackPolyphonic = null
var _tick_evento: Dictionary[StringName, int] = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ficha = Cargar.si_existe(FICHA) as FichaSonidos
	_reproductor = AudioStreamPlayer.new()
	_reproductor.name = &"Voces"
	_reproductor.bus = Ajustes.BUS_EFECTOS
	var polifonico: AudioStreamPolyphonic = AudioStreamPolyphonic.new()
	polifonico.polyphony = voces
	_reproductor.stream = polifonico
	add_child(_reproductor)
	if not mudo:
		# El playback solo existe con el stream puesto y tras play() (classes/class_audiostreampolyphonic.rst:24,
		# classes/class_audiostreamplayer.rst:391).
		_reproductor.play()
		_voces = _reproductor.get_stream_playback() as AudioStreamPlaybackPolyphonic
	# Una conexion por senal: unbind quita los argumentos de la senal y bind agrega el evento
	# (classes/class_callable.rst:231, :520-530). El aterrizaje elige su efecto por el argumento picada.
	Eventos.jugador_salto.connect(tocar.bind(&"salto"))
	Eventos.enemigo_golpeado.connect(tocar.bind(&"golpe").unbind(1))
	Eventos.objeto_golpeado.connect(tocar.bind(&"golpe").unbind(1))
	Eventos.muro_roto.connect(tocar.bind(&"muro_roto").unbind(1))
	Eventos.porton_abierto.connect(tocar.bind(&"porton").unbind(1))
	Eventos.jugador_danado.connect(tocar.bind(&"dano").unbind(1))
	Eventos.parry.connect(tocar.bind(&"parry"))
	Eventos.jugador_curado.connect(tocar.bind(&"curar").unbind(1))
	Eventos.descanso_en_banco.connect(tocar.bind(&"banco").unbind(1))
	Eventos.jugador_paso.connect(tocar.bind(&"paso"))
	Eventos.jugador_impulso.connect(tocar.bind(&"impulso"))
	Eventos.jugador_aterrizo.connect(_al_aterrizar)


# Al cerrar el juego con efectos sonando, sus reproducciones seguian vivas a la salida (ERROR resources still in use,
# medido con ventana el 27-oct-2026): se callan antes.
func _exit_tree() -> void:
	_reproductor.stop()


## Toca el efecto de un evento si la ficha tiene uno y no sono hace menos de ticks_entre_iguales. Devuelve el id de
## la voz (AudioStreamPlaybackPolyphonic.INVALID_ID si no sono). Avisa con un WARNING si el evento no es campo de
## FichaSonidos: nunca sonaria.
func tocar(evento: StringName) -> int:
	pedidos += 1
	if ficha == null:
		return AudioStreamPlaybackPolyphonic.INVALID_ID
	if not ficha.tiene_campo(evento):
		push_warning("Sonido: el evento %s no es campo de FichaSonidos y nunca suena" % evento)
		return AudioStreamPlaybackPolyphonic.INVALID_ID
	var stream: AudioStream = ficha.efecto(evento)
	if stream == null:
		return AudioStreamPlaybackPolyphonic.INVALID_ID
	var tick: int = Engine.get_physics_frames()
	var anterior: int = _tick_evento.get(evento, -1000000)
	if not sin_espera.has(evento) and tick - anterior < ticks_entre_iguales:
		return AudioStreamPlaybackPolyphonic.INVALID_ID
	_tick_evento[evento] = tick
	tocados += 1
	ultimo = evento
	if mudo or _voces == null:
		return AudioStreamPlaybackPolyphonic.INVALID_ID
	# El bus va explicito: por omision play_stream usa Master y se saltaria la barra de Efectos
	# (classes/class_audiostreamplaybackpolyphonic.rst:35, :86).
	var voz: int = _voces.play_stream(stream, 0.0, 0.0, 1.0, AudioServer.PLAYBACK_TYPE_DEFAULT, Ajustes.BUS_EFECTOS)
	if voz == AudioStreamPlaybackPolyphonic.INVALID_ID:
		descartados += 1
	return voz


## Si la voz que devolvio tocar() sigue sonando (false si esta mudo).
func sonando(voz: int) -> bool:
	return _voces != null and voz != AudioStreamPlaybackPolyphonic.INVALID_ID and _voces.is_stream_playing(voz)


func _al_aterrizar(velocidad: float, duro: bool, picada: bool) -> void:
	if picada:
		tocar(&"picada")
	elif duro or velocidad >= velocidad_aterrizaje_min:
		tocar(&"aterrizaje")
