class_name Ajustes
extends RefCounted
# Ajustes del jugador (vibracion, temblor de camara, volumen general, de musica y de efectos, brillo, FPS, modo
# desarrollador, luces 2D, niebla, mostrar FPS, disposicion de los botones tactiles y botones del control), en su propio
# archivo JSON: son del telefono y no de la partida, y asi agregar uno no cambia la version del guardado.
# Funciones estaticas, como Guardado; un archivo que falta o esta danado deja los valores por omision.

const VERSION: int = 1
const RUTA: String = "user://ajustes.json"
## Valores por omision de las opciones de si o no; la disposicion de los botones tiene los suyos en
## DisposicionControles.por_omision().
const POR_OMISION: Dictionary[String, bool] = {
	"vibracion": true, "temblor": true, "modo_desarrollador": false,
	"luces_avanzadas": true, "niebla": false, "mostrar_fps": false, "panel_pruebas": false, "ver_hitbox": false,
}
## Ajustes graficos que se aplican al momento (Eventos.ajuste_grafico_cambiado con la clave): los escuchan LuzSala,
## Niebla, ContadorFps, PanelPruebas y VerHitbox. MODO_DESARROLLADOR tambien se avisa: muestra o quita el panel, ver
## hitbox y el monitor.
const MODO_DESARROLLADOR: StringName = &"modo_desarrollador"
const LUCES_AVANZADAS: StringName = &"luces_avanzadas"
const NIEBLA: StringName = &"niebla"
const MOSTRAR_FPS: StringName = &"mostrar_fps"
const PANEL_PRUEBAS: StringName = &"panel_pruebas"
const VER_HITBOX: StringName = &"ver_hitbox"
## Claves de si o no: se reinician, se leen y se guardan en un bucle. Una nueva se agrega aqui, en POR_OMISION y en
## si_no y poner_si_no, sin tocar cargar, _leer ni guardar.
const CLAVES_SI_NO: Array[StringName] = [
	&"vibracion", &"temblor", MODO_DESARROLLADOR, LUCES_AVANZADAS, NIEBLA, MOSTRAR_FPS, PANEL_PRUEBAS, VER_HITBOX,
]
const VOLUMEN_POR_OMISION: float = 1.0
## Bus de cada volumen (default_bus_layout.tres): general, musica y efectos.
const BUS_MUSICA: StringName = &"Musica"
const BUS_EFECTOS: StringName = &"Efectos"
const BRILLO_POR_OMISION: float = 1.0
const BRILLO_MINIMO: float = 0.5
const BRILLO_MAXIMO: float = 1.5
## FPS que el jugador puede elegir; 120 solo vale con Recursos en alto y una pantalla rapida (limite_fps).
const FPS_OPCIONES: Array[int] = [60, 120]
const FPS_POR_OMISION: int = 60
## Desde este refresco (Hz) la pantalla cuenta como rapida y se ofrece 120.
const REFRESCO_RAPIDO: float = 90.0

## Vibrar al pegar, al recibir dano, al curarse y al descansar.
static var vibracion: bool = POR_OMISION["vibracion"]
## Temblor de la camara al aterrizar de una caida; se apaga por mareo.
static var temblor: bool = POR_OMISION["temblor"]
## Muestra en Configuracion la entrada a la zona de pruebas (tambien en el paquete de publicacion), y en Avanzado
## el panel de pruebas y Ver hitbox.
static var modo_desarrollador: bool = POR_OMISION["modo_desarrollador"]
## Luces 2D (PointLight2D de LuzSala): solo valen con Recursos en alto (luces_avanzadas_activas).
static var luces_avanzadas: bool = POR_OMISION["luces_avanzadas"]
## Niebla de las salas: apagada por omision, cuesta 2 a 4 FPS en el S50 donde se ve.
static var niebla: bool = POR_OMISION["niebla"]
## Contador de FPS arriba al centro (ContadorFps).
static var mostrar_fps: bool = POR_OMISION["mostrar_fps"]
## Solo con el modo desarrollador: la pestana del panel de pruebas en las salas (PanelPruebas) y el monitor junto
## al contador.
static var panel_pruebas: bool = POR_OMISION["panel_pruebas"]
## Solo con el modo desarrollador: dibuja las formas de colision encima del juego (VerHitbox).
static var ver_hitbox: bool = POR_OMISION["ver_hitbox"]
## Volumen general, de 0 a 1 (bus Master).
static var volumen: float = VOLUMEN_POR_OMISION
## Volumen de la musica y de los efectos, de 0 a 1 (buses Musica y Efectos, que pasan por Master).
static var volumen_musica: float = VOLUMEN_POR_OMISION
static var volumen_efectos: float = VOLUMEN_POR_OMISION
## Brillo de la pantalla, de BRILLO_MINIMO a BRILLO_MAXIMO; 1 no cambia nada (Brillo).
static var brillo: float = BRILLO_POR_OMISION
## Modo de recursos: Recursos.AUTO (decide la deteccion), BAJO o ALTO.
static var recursos: String = Recursos.AUTO
## FPS elegidos: 60 o 120 (FPS_OPCIONES).
static var fps: int = FPS_POR_OMISION
## Donde va cada boton tactil, su tamano y la opacidad de todos. El editor de controles la reemplaza.
static var disposicion: DisposicionControles = DisposicionControles.por_omision()
static var _cargados: bool = false


## Carga los ajustes la primera vez que se pide; despues no hace nada.
static func cargar_una_vez(ruta: String = RUTA) -> void:
	if not _cargados:
		cargar(ruta)


static func cargar(ruta: String = RUTA) -> void:
	_cargados = true
	for clave: StringName in CLAVES_SI_NO:
		poner_si_no(clave, POR_OMISION[String(clave)])
	volumen = VOLUMEN_POR_OMISION
	volumen_musica = VOLUMEN_POR_OMISION
	volumen_efectos = VOLUMEN_POR_OMISION
	brillo = BRILLO_POR_OMISION
	recursos = Recursos.AUTO
	fps = FPS_POR_OMISION
	disposicion = DisposicionControles.por_omision()
	Mando.por_omision()
	_leer(ruta)
	aplicar_volumen()
	aplicar_brillo()
	aplicar_fps()


static func _leer(ruta: String) -> void:
	if not FileAccess.file_exists(ruta):
		return
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(ruta)) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return
	var sobre: Dictionary = json.data
	var version: Variant = sobre.get("version")
	var contenido: Variant = sobre.get("ajustes")
	if typeof(version) != TYPE_FLOAT or typeof(contenido) != TYPE_DICTIONARY:
		return
	var numero: float = version
	if numero != VERSION:
		return
	var ajustes: Dictionary = contenido
	# Una clave que falta (un archivo de antes de que existiera) se queda con su valor por omision.
	var valor: Variant = null
	for clave: StringName in CLAVES_SI_NO:
		valor = ajustes.get(String(clave))
		if typeof(valor) == TYPE_BOOL:
			poner_si_no(clave, valor as bool)
	volumen = _numero(ajustes.get("volumen"), volumen, 0.0, 1.0)
	volumen_musica = _numero(ajustes.get("volumen_musica"), volumen_musica, 0.0, 1.0)
	volumen_efectos = _numero(ajustes.get("volumen_efectos"), volumen_efectos, 0.0, 1.0)
	brillo = _numero(ajustes.get("brillo"), brillo, BRILLO_MINIMO, BRILLO_MAXIMO)
	valor = ajustes.get("recursos")
	if typeof(valor) == TYPE_STRING and Recursos.MODOS.has(valor as String):
		recursos = valor
	valor = ajustes.get("fps")
	if typeof(valor) == TYPE_FLOAT and FPS_OPCIONES.has(int(valor as float)):
		fps = int(valor as float)
	disposicion = DisposicionControles.desde_diccionario(ajustes.get("controles"))
	Mando.aplicar(ajustes.get("mando"))


# Un numero leido del archivo, recortado a su rango; si no es numero, el valor que ya tenia.
static func _numero(valor: Variant, actual: float, minimo: float, maximo: float) -> float:
	if typeof(valor) != TYPE_FLOAT:
		return actual
	var leido: float = valor
	return clampf(leido, minimo, maximo)


## Pone cada volumen en su bus; en 0, silencio. Un bus que no existe se salta con un aviso.
static func aplicar_volumen() -> void:
	_poner_bus(&"Master", volumen)
	_poner_bus(BUS_MUSICA, volumen_musica)
	_poner_bus(BUS_EFECTOS, volumen_efectos)


## Decibeles de un volumen de 0 a 1: 0 dB arriba y -80 dB (con silencio aparte) en 0.
static func db_de(lineal: float) -> float:
	return linear_to_db(clampf(lineal, 0.0001, 1.0))


static func _poner_bus(nombre: StringName, lineal: float) -> void:
	var indice: int = AudioServer.get_bus_index(nombre)
	if indice < 0:
		push_warning("Ajustes: no existe el bus de audio %s" % nombre)
		return
	AudioServer.set_bus_mute(indice, lineal <= 0.0)
	AudioServer.set_bus_volume_db(indice, db_de(lineal))


## Pasa el brillo al modulado de la sala, si hay una (Brillo).
static func aplicar_brillo() -> void:
	if is_instance_valid(Brillo.instancia):
		Brillo.instancia.poner(brillo)


## Limite de FPS para Engine.max_fps: 0 (sin limite: V-Sync lo deja en el refresco de la pantalla) solo con 120
## elegidos, Recursos en alto, una pantalla rapida y fuera de un menu; si no, 60. Un refresco desconocido (-1)
## cuenta como 60 Hz. En un menu, 60 siempre: mas no se nota y gasta bateria (decision del 25-oct-2026).
static func limite_fps(elegidos: int, recursos_altos: bool, refresco: float, en_menu: bool = false) -> int:
	return 0 if elegidos == 120 and fps_disponible(recursos_altos, refresco) and not en_menu else 60


## Si Configuracion ofrece elegir 120: con Recursos en alto y una pantalla de REFRESCO_RAPIDO Hz o mas.
static func fps_disponible(recursos_altos: bool, refresco: float) -> bool:
	return recursos_altos and refresco >= REFRESCO_RAPIDO


## Pone el limite de FPS segun el ajuste, Recursos, la pantalla y si hay un menu abierto. Sin pantalla (guiones,
## CI) no lo toca: ahi los cuadros van tan rapido como se pueda. Lo llama ContadorFps al cambiar de menu a juego.
static func aplicar_fps(en_menu: bool = false) -> void:
	if DisplayServer.get_name() == "headless":
		return
	Engine.max_fps = limite_fps(fps, not Recursos.bajos(), DisplayServer.screen_get_refresh_rate(), en_menu)


## Valor de una clave de si o no (CLAVES_SI_NO).
static func si_no(clave: StringName) -> bool:
	match clave:
		&"vibracion":
			return vibracion
		&"temblor":
			return temblor
		MODO_DESARROLLADOR:
			return modo_desarrollador
		LUCES_AVANZADAS:
			return luces_avanzadas
		NIEBLA:
			return niebla
		MOSTRAR_FPS:
			return mostrar_fps
		PANEL_PRUEBAS:
			return panel_pruebas
		VER_HITBOX:
			return ver_hitbox
	push_error("Ajustes: no hay una clave de si o no '%s'" % clave)
	return false


static func poner_si_no(clave: StringName, valor: bool) -> void:
	match clave:
		&"vibracion":
			vibracion = valor
		&"temblor":
			temblor = valor
		MODO_DESARROLLADOR:
			modo_desarrollador = valor
		LUCES_AVANZADAS:
			luces_avanzadas = valor
		NIEBLA:
			niebla = valor
		MOSTRAR_FPS:
			mostrar_fps = valor
		PANEL_PRUEBAS:
			panel_pruebas = valor
		VER_HITBOX:
			ver_hitbox = valor
		_:
			push_error("Ajustes: no hay una clave de si o no '%s'" % clave)


## Las herramientas de desarrollo (panel de pruebas, ver hitbox) valen solo con el modo desarrollador encendido.
static func desarrollo(clave: StringName) -> bool:
	return modo_desarrollador and si_no(clave)


## Si las luces 2D se ven: el ajuste encendido y Recursos en alto (en bajo no se ofrecen: 52 -> 7-10 FPS en el S50).
static func luces_avanzadas_activas(valor: bool, recursos_bajos: bool) -> bool:
	return valor and not recursos_bajos


## Las luces 2D de este telefono, con el ajuste y Recursos en vigor.
static func luces_activas() -> bool:
	return luces_avanzadas_activas(luces_avanzadas, Recursos.bajos())


## Escribe con Archivo (a un temporal que despues renombra), como el guardado de la partida.
static func guardar(ruta: String = RUTA) -> Error:
	var ajustes: Dictionary = {
		"volumen": volumen,
		"volumen_musica": volumen_musica,
		"volumen_efectos": volumen_efectos,
		"brillo": brillo,
		"recursos": recursos,
		"fps": fps,
		"controles": disposicion.a_diccionario(),
		"mando": Mando.a_diccionario(),
	}
	for clave: StringName in CLAVES_SI_NO:
		ajustes[String(clave)] = si_no(clave)
	return Archivo.escribir_atomico(ruta, JSON.stringify({"version": VERSION, "ajustes": ajustes}, "\t"))
