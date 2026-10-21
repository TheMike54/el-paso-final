class_name Sonido
extends Node
# Efectos de los eventos del juego: escucha el bus (como Vibracion) y toca lo que diga la FichaSonidos en el bus
# Efectos, con pocas voces y sin repetir el mismo evento en ticks seguidos. La crea Arranque y vive fuera de las
# salas: nada se corta al cruzar una puerta o salir al menu. Corre tambien en pausa. La musica por zona no esta aqui.

## Por ahora, la de los sonidos de prueba. Donde vivira la del juego (en contenido/ seria una excepcion nueva de
## nucleo/CLAUDE.md) lo decide la persona.
const FICHA_PRUEBA: String = "res://nucleo/sonidos/sonidos_prueba.tres"
## Cada evento que Sonido toca, uno por metodo _al_* de abajo. Cada uno es un campo de efecto de FichaSonidos (lo
## exige la prueba de sonido.guion); tocar() avisa si le llega uno que no lo es.
const EVENTOS: Array[StringName] = [&"salto", &"golpe", &"muro_roto", &"porton", &"dano", &"parry", &"curar", &"banco"]

## Efectos a la vez. Van en rueda: el siguiente toma la voz que empezo hace mas tiempo, aunque otra ya este libre.
@export var voces: int = 4
## Ticks minimos entre dos veces el mismo evento (la onda de la picada golpea a varios en un tick). Dano y parry no
## esperan, como en Vibracion.
@export var ticks_entre_iguales: int = 3

var ficha: FichaSonidos = null
## Publicos para los guiones y la prueba, como en Vibracion: pedidos, tocados y el ultimo.
var pedidos: int = 0
var tocados: int = 0
var ultimo: StringName = &""

var _reproductores: Array[AudioStreamPlayer] = []
var _siguiente_voz: int = 0
var _tick_evento: Dictionary[StringName, int] = {}
var _azar: RandomNumberGenerator = RandomNumberGenerator.new()
# Los campos de efecto de FichaSonidos, leidos una vez: tocar() los consulta en cada evento.
var _campos: Array[StringName] = FichaSonidos.new().campos_de_efecto()
# Sin pantalla nadie oye: se cuenta igual pero no se toca (tocar sin pantalla dejaba recursos vivos al salir,
# docs/errores/2026-10-13-musica-sin-pantalla.md).
var _mudo: bool = DisplayServer.get_name() == "headless"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if ResourceLoader.exists(FICHA_PRUEBA):
		ficha = load(FICHA_PRUEBA) as FichaSonidos
	for i: int in range(voces):
		var reproductor: AudioStreamPlayer = AudioStreamPlayer.new()
		reproductor.bus = Ajustes.BUS_EFECTOS
		add_child(reproductor)
		_reproductores.append(reproductor)
	# Metodos y no funciones anonimas, como en Vibracion.
	Eventos.jugador_salto.connect(_al_saltar)
	Eventos.enemigo_golpeado.connect(_al_pegar)
	Eventos.objeto_golpeado.connect(_al_pegar)
	Eventos.muro_roto.connect(_al_romper_muro)
	Eventos.porton_abierto.connect(_al_abrir_porton)
	Eventos.jugador_danado.connect(_al_recibir_dano)
	Eventos.parry.connect(_al_parar)
	Eventos.jugador_curado.connect(_al_curarse)
	Eventos.descanso_en_banco.connect(_al_descansar)


## Toca el efecto de un evento si la ficha tiene uno y no sono hace menos de ticks_entre_iguales. Avisa con un
## WARNING si el evento no es campo de FichaSonidos: ficha.efecto() daria null y nunca sonaria.
func tocar(evento: StringName) -> void:
	pedidos += 1
	if not _campos.has(evento):
		push_warning("Sonido: el evento %s no es campo de FichaSonidos y nunca suena" % evento)
	var stream: AudioStream = ficha.efecto(evento) if ficha != null else null
	if stream == null:
		return
	var tick: int = Engine.get_physics_frames()
	var anterior: int = _tick_evento.get(evento, -1000000)
	if evento != &"dano" and evento != &"parry" and tick - anterior < ticks_entre_iguales:
		return
	_tick_evento[evento] = tick
	tocados += 1
	ultimo = evento
	if _mudo or _reproductores.is_empty():
		return
	var reproductor: AudioStreamPlayer = _reproductores[_siguiente_voz]
	_siguiente_voz = (_siguiente_voz + 1) % _reproductores.size()
	reproductor.stream = stream
	reproductor.pitch_scale = ficha.tono(evento) + _azar.randf_range(-ficha.variacion_tono, ficha.variacion_tono)
	reproductor.play()


func _al_saltar() -> void:
	tocar(&"salto")


func _al_pegar(_enemigo: Node) -> void:
	tocar(&"golpe")


func _al_romper_muro(_muro: StringName) -> void:
	tocar(&"muro_roto")


func _al_abrir_porton(_porton: StringName) -> void:
	tocar(&"porton")


func _al_recibir_dano(_vidas: int) -> void:
	tocar(&"dano")


func _al_parar() -> void:
	tocar(&"parry")


func _al_curarse(_vidas: int) -> void:
	tocar(&"curar")


func _al_descansar(_banco: StringName) -> void:
	tocar(&"banco")
