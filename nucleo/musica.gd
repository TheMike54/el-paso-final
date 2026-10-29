class_name Musica
extends Node
# Musica de fondo, como el AudioManager de Hollow Knight: un tema a la vez en el bus Musica y, encima, un volumen de
# region. Cada pedido (tema, volumen y segundos) se guarda y se aplica en el tick siguiente: la sala y una RegionMusica
# que piden en el mismo arranque no se pisan, gana el ultimo. Un tema que ya suena no se reasigna ni vuelve a empezar.
# La crea Arranque y vive fuera de las salas, asi la musica no se corta al cruzar una puerta.

## El tema del menu; tambien el que prueba el panel de audio cuando no se oye nada.
const TEMA_MENU: AudioStream = preload("res://nucleo/sonidos/musica_menu.ogg")
## El tema «silencio»: pedirlo funde la musica a nada. Es un recurso y no null porque null es «no tocar el tema»
## (Sala.tema_musica vacio, una RegionMusica sin tema). Hollow Knight tampoco acepta un cue nulo: el silencio es un cue.
## Nunca se reproduce.
const SILENCIO: AudioStream = preload("res://nucleo/sonidos/silencio.tres")
## Volumen de region normal, en dB: el snapshot «Normal» de Hollow Knight.
const DB_NORMAL: float = 0.0
## El snapshot «Silent» de Hollow Knight: -60 dB, en la practica callado (tutorials/audio/audio_buses.rst:40-42).
const DB_SILENCIO: float = -60.0
## Segundos del fundido de un tema a otro al entrar a una sala.
const FUNDIDO: float = 2.0
## Fundido del menu, de la cinematica y del panel de audio: responden a un toque y no deben tardar.
const FUNDIDO_CORTO: float = 1.0

## Tema aplicado (SILENCIO si se pidio callar); null si nunca se pidio ninguno. Publico para los guiones.
var actual: AudioStream = null
## Volumen de region aplicado, en dB (al que va o en el que esta). Publico para los guiones.
var volumen_db: float = DB_NORMAL
## Veces que un tema empezo desde el principio. Sin pantalla no se reproduce nada, asi que es lo que miran los guiones
## para saber que un tema no se reinicio.
var arranques: int = 0
## Sin pantalla nadie oye: se cuenta igual pero no se reproduce (un Ogg tocado sin pantalla dejaba recursos vivos al
## salir, docs/errores/2026-10-13-musica-sin-pantalla.md).
var mudo: bool = Ajustes.sin_ventana()

# Dos reproductores para el fundido cruzado: el que entra sube mientras el otro baja. Por cada uno, su volumen lineal
# (lo que se oye: el del tema por el de region, en un solo valor), el volumen al que va, el tema que tiene (null si
# esta libre) y su tween. Un solo tween por reproductor y sobre el volumen final: con dos tweens multiplicados (tema y
# region) el producto subia a -12 dB al callar un tema que estaba a -60 (docs/errores/2026-10-27-musica-sube-al-callar.md);
# asi cada reproductor va en linea recta de donde esta a donde va y un pedido nuevo no corta en seco al que se iba.
var _reproductores: Array[AudioStreamPlayer] = []
var _volumenes: Array[float] = [0.0, 0.0]
var _destinos: Array[float] = [0.0, 0.0]
var _temas: Array[AudioStream] = [null, null]
var _fundidos: Array[Tween] = [null, null]
# El pedido pendiente. Gana el ultimo por campo: un pedido sin tema no borra el tema que otro dejo pendiente en el
# mismo tick (la region que solo cambia el volumen no deshace el tema de la sala); el volumen lo reemplaza cada pedido.
var _hay_pedido: bool = false
var _tick_pedido: int = 0
var _pedido_tema: AudioStream = null
var _pedido_segundos_tema: float = FUNDIDO
var _pedido_db: float = DB_NORMAL
var _pedido_segundos_db: float = FUNDIDO
# Lo que habia antes de que el panel de audio pusiera el tema de prueba, para devolverlo al cerrarlo.
var _probando: bool = false
var _antes_tema: AudioStream = null
var _antes_db: float = DB_NORMAL


func _ready() -> void:
	# Corre en pausa: el panel de audio de la pausa le pide el tema de prueba.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i: int in range(2):
		var reproductor: AudioStreamPlayer = AudioStreamPlayer.new()
		reproductor.name = "Reproductor%d" % i
		reproductor.bus = Ajustes.BUS_MUSICA
		reproductor.volume_db = DB_SILENCIO
		add_child(reproductor)
		_reproductores.append(reproductor)
	# Solo corre el tick con un pedido pendiente.
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if not _hay_pedido or Engine.get_physics_frames() <= _tick_pedido:
		return
	_hay_pedido = false
	set_physics_process(false)
	volumen_db = _pedido_db
	# Si cambia el tema, todos los reproductores (el que entra y los que se van, aunque ya se estuvieran yendo) usan los
	# segundos del tema; si no cambia, solo el que suena va al volumen nuevo, con los segundos del volumen (los de la
	# RegionMusica, por ejemplo), y uno que se estaba yendo sigue a su paso.
	var activo: int = _activo()
	var segundos_activo: float = _pedido_segundos_db
	var cambia: bool = _pedido_tema != null and _pedido_tema != actual
	if cambia:
		activo = _entrar(_pedido_tema)
		segundos_activo = _pedido_segundos_tema
	for i: int in range(_reproductores.size()):
		if i == activo:
			_fundir(i, db_to_linear(volumen_db), segundos_activo, cambia)
		else:
			_fundir(i, 0.0, _pedido_segundos_tema, cambia)


# Al cerrar con musica sonando, la reproduccion quedaba registrada al salir (lo mismo que en Sonido).
func _exit_tree() -> void:
	for reproductor: AudioStreamPlayer in _reproductores:
		reproductor.stop()


## Pide un tema y un volumen de region (en dB), con un fundido de segundos. Se aplica en el tick siguiente y gana el
## ultimo pedido. tema null no toca el tema (solo el volumen); SILENCIO lo calla. Pedir el tema que ya suena, o uno que
## todavia se esta yendo, no lo reinicia: sube desde donde va. El bucle lo da el archivo (Ogg importado con loop).
func poner(tema: AudioStream, volumen_en_db: float = DB_NORMAL, segundos: float = FUNDIDO) -> void:
	if tema != null:
		_pedido_tema = tema
		_pedido_segundos_tema = segundos
	elif not _hay_pedido:
		_pedido_tema = null
	_pedido_db = volumen_en_db
	_pedido_segundos_db = segundos
	_hay_pedido = true
	_tick_pedido = Engine.get_physics_frames()
	set_physics_process(true)


## Si se oye un tema, contando el pedido pendiente: hay tema, no es SILENCIO y el volumen de region esta sobre
## DB_SILENCIO.
func se_oye() -> bool:
	var tema: AudioStream = _tema_pedido()
	return tema != null and tema != SILENCIO and _db_pedido() > DB_SILENCIO


## El panel de audio a la vista (true) o al cerrarse (false). Si al abrirlo no se oye nada, pone TEMA_MENU para probar
## la barra de musica; al cerrarlo devuelve lo que habia. Si ya sonaba algo, no lo toca.
func probar(sonar: bool) -> void:
	if sonar:
		if _probando or se_oye():
			return
		_probando = true
		_antes_tema = _tema_pedido() if _tema_pedido() != null else SILENCIO
		_antes_db = _db_pedido()
		poner(TEMA_MENU, DB_NORMAL, FUNDIDO_CORTO)
	elif _probando:
		_probando = false
		poner(_antes_tema, _antes_db, FUNDIDO_CORTO)


# El tema que quedara tras el pedido pendiente.
func _tema_pedido() -> AudioStream:
	return _pedido_tema if _hay_pedido and _pedido_tema != null else actual


func _db_pedido() -> float:
	return _pedido_db if _hay_pedido else volumen_db


# El reproductor que tiene el tema aplicado; -1 con SILENCIO o si nunca se pidio un tema.
func _activo() -> int:
	if actual == null or actual == SILENCIO:
		return -1
	return _temas.find(actual)


# Cambia el tema aplicado y devuelve el reproductor que va a subir: el que ya tiene ese tema (aunque se este yendo: A,
# B y otra vez A dentro del fundido) o, si no, el mas callado, que recibe el tema desde el principio. SILENCIO no sube
# ninguno (-1).
func _entrar(tema: AudioStream) -> int:
	actual = tema
	if tema == SILENCIO:
		return -1
	var entra: int = _temas.find(tema)
	if entra >= 0:
		return entra
	entra = 0 if _volumenes[0] <= _volumenes[1] else 1
	# Asignar el stream corta lo que ese reproductor tocaba (classes/class_audiostreamplayer.rst:301): solo pasa con un
	# tercer tema dentro de un fundido, y es el mas callado de los dos.
	if _fundidos[entra] != null:
		_fundidos[entra].kill()
		_fundidos[entra] = null
	_soltar(entra)
	_temas[entra] = tema
	_reproductores[entra].stream = tema
	arranques += 1
	if not mudo:
		_reproductores[entra].play()
	return entra


# Lleva el volumen de un reproductor a destino (lineal) en linea recta desde el que tiene ahora, asi nunca pasa del
# mayor de los dos; al llegar a 0 lo para y lo deja libre. Si ya iba a ese destino solo lo rehace con rehacer (con
# los segundos nuevos).
func _fundir(cual: int, destino: float, segundos: float, rehacer: bool) -> void:
	if _temas[cual] == null or (not rehacer and is_equal_approx(destino, _destinos[cual])):
		return
	if _fundidos[cual] != null:
		_fundidos[cual].kill()
	_destinos[cual] = destino
	# En ticks de fisica, como el resto de la logica (classes/class_tween.rst:274).
	var tween: Tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_method(_poner_volumen.bind(cual), _volumenes[cual], destino, maxf(segundos, 0.01))
	if is_zero_approx(destino):
		tween.tween_callback(_soltar.bind(cual))
	_fundidos[cual] = tween


# Para un reproductor y lo deja libre, sin tema.
func _soltar(cual: int) -> void:
	_reproductores[cual].stop()
	_reproductores[cual].stream = null
	_temas[cual] = null
	_destinos[cual] = 0.0
	_fundidos[cual] = null
	_poner_volumen(0.0, cual)


func _poner_volumen(valor: float, cual: int) -> void:
	_volumenes[cual] = valor
	_reproductores[cual].volume_db = linear_to_db(maxf(valor, 0.00001))
