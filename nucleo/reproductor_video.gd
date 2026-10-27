class_name ReproductorVideo
extends AspectRatioContainer
# Video a pantalla completa sin deformar (tutorials/animation/playing_videos.rst:62-80). En Android, el .mp4 H.264 por
# el decodificador del telefono: MediaPlayer dibuja en una SurfaceTexture atada a una ExternalTexture, armado desde
# GDScript con JavaClassWrapper (sin plugin; prueba V0 del 25-oct-2026, planes nucleo-video-hardware). En la PC, el
# .ogv con Theora, que no viaja en el APK; si el telefono no puede, la imagen de respaldo (un video sin bucle termina
# al momento). Sin ventana (guiones), nada: un video sin bucle termina a los DURACION_SIN_VENTANA s. Lo usan el menu y la Cinematica.

signal terminado

const SHADER_EXTERNO: String = "res://nucleo/arte/video_externo.gdshader"
const SHADER_DESENFOQUE: String = "res://nucleo/arte/video_desenfoque.gdshader"
## Division del fondo desenfocado: el video se reduce a 1/8 de la pantalla (elegido en el S50 el 25-oct-2026).
const DIVISION_DESENFOQUE: int = 8
## Lo que dura un video sin bucle sin ventana: no al momento, para que el puerto de depuracion alcance a ver la
## escena que lo reproduce antes de que cambie (un guion empieza contando cuadros en la escena de su linea «escena»).
const DURACION_SIN_VENTANA: float = 0.5
## Donde se copia cada .mp4: sin compilacion Gradle MediaPlayer no puede abrirlo dentro del APK.
const CARPETA_COPIAS: String = "user://video/"
## Cuadros que se espera el id de la ExternalTexture antes de darla por perdida y pasar al respaldo.
const ESPERA_TEXTURA: int = 120
## Vigilante de un video sin bucle: cada REVISAR_CADA s lee la posicion de MediaPlayer; si no avanza en SIN_AVANCE s
## de reproduccion (se trabo sin error, o termino sin avisar), termina igual. No compara con la duracion: en el S50
## el video va un poco detras del reloj y un margen fijo cortaba el final (25-oct-2026). Pausa y segundo plano no
## cuentan.
const REVISAR_CADA: float = 1.0
const SIN_AVANCE: float = 5.0

var _ruta: String = ""
var _bucle: bool = false
var _theora: VideoStreamPlayer = null
var _respaldo: TextureRect = null
var _externa: ExternalTexture = null
var _material: ShaderMaterial = null
var _lienzo: ColorRect = null
var _superficie_textura: Object = null
var _superficie: Object = null
var _medios: Object = null
var _borroso: Control = null
var _sonando: bool = false
var _pausado: bool = false
var _en_segundo_plano: bool = false
var _terminado: bool = false
# Sube en cada reproducir() y detener(): un reproducir() que vuelve de su espera y ya no es el ultimo no sigue.
var _generacion: int = 0
# Vigilante (solo sin bucle): si esta encendido, la ultima posicion leida en ms, y cuanto lleva sin avanzar y desde la
# ultima lectura, en s.
var _vigilando: bool = false
var _posicion: int = -1
var _sin_avanzar: float = 0.0
var _desde_revision: float = 0.0


## Contenedor con el video de ruta_base (sin extension: <ruta_base>.mp4, <ruta_base>.ogv y, si lo hay, la imagen de
## respaldo <ruta_base>.jpg para cuando no se puede reproducir ninguno). modo: STRETCH_COVER llena
## la pantalla recortando (menu); STRETCH_WIDTH_CONTROLS_HEIGHT ocupa todo el ancho (cinematica,
## classes/class_aspectratiocontainer.rst:68).
static func crear(ruta_base: String, bucle: bool, modo: AspectRatioContainer.StretchMode) -> ReproductorVideo:
	var video: ReproductorVideo = ReproductorVideo.new()
	video.name = &"Video"
	video._ruta = ruta_base
	video._bucle = bucle
	video.ratio = 16.0 / 9.0
	video.stretch_mode = modo
	video.mouse_filter = Control.MOUSE_FILTER_IGNORE
	video.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return video


## Si este equipo usa el decodificador del telefono: Android con su runtime de Java (la ruta probada en V0).
static func usa_h264() -> bool:
	return OS.get_name() == "Android" and Engine.has_singleton("AndroidRuntime")


## Sin ventana (guiones y validador): no se decodifica nada.
static func sin_ventana() -> bool:
	return DisplayServer.get_name() == "headless"


## Volumen lineal del video H.264: Master por Musica, 0 si alguno esta silenciado. MediaPlayer suena fuera de los
## buses de Godot; Theora no lo necesita: va por el bus Musica, que ya lo aplica.
static func volumen() -> float:
	var total: float = 1.0
	for bus: StringName in [&"Master", Ajustes.BUS_MUSICA]:
		var indice: int = AudioServer.get_bus_index(bus)
		if indice < 0:
			continue
		if AudioServer.is_bus_mute(indice):
			return 0.0
		total *= db_to_linear(AudioServer.get_bus_volume_db(indice))
	return total


func _ready() -> void:
	set_process(false)
	if sin_ventana():
		return
	if usa_h264():
		_armar_lienzo()
	else:
		_armar_respaldo()


## Empieza desde el principio.
func reproducir() -> void:
	_terminado = false
	_generacion += 1
	var generacion: int = _generacion
	if sin_ventana():
		if not _bucle:
			get_tree().create_timer(DURACION_SIN_VENTANA).timeout.connect(_terminar_si_sigue.bind(generacion))
		return
	if _lienzo == null:
		_reproducir_respaldo()
		return
	# La ExternalTexture recien creada no tiene id hasta que la crea el hilo de dibujo; sin la extension que pide
	# (classes/class_externaltexture.rst:24) no llegaria nunca: tras ESPERA_TEXTURA cuadros, el respaldo.
	var espera: int = 0
	while is_inside_tree() and _externa.get_external_texture_id() == 0 and espera < ESPERA_TEXTURA:
		espera += 1
		await get_tree().process_frame
	# Un detener() o un reproducir() nuevo durante la espera: este ya no sigue.
	if not is_inside_tree() or generacion != _generacion:
		return
	if _externa.get_external_texture_id() == 0 or not _armar_medios(_externa.get_external_texture_id()):
		_pasar_a_respaldo()
		return
	_sonando = true
	set_process(true)
	_vigilando = not _bucle
	_posicion = -1
	_sin_avanzar = 0.0
	_desde_revision = 0.0
	# Pausado (Configuracion abierta) o en segundo plano: arranca al seguir o al volver a la app.
	if not _pausado and not _en_segundo_plano and not _llamar(&"start"):
		_pasar_a_respaldo()


func detener() -> void:
	_generacion += 1
	_vigilando = false
	_sonando = false
	set_process(false)
	if _theora != null:
		_theora.stop()
	_liberar()


## Pausa o sigue sin volver al principio; al seguir toma el volumen actual (pudo cambiar en Configuracion).
func pausar(si: bool) -> void:
	_pausado = si
	if _theora != null:
		_theora.paused = si
	elif _medios != null and _sonando and not _en_segundo_plano:
		if si:
			_llamar(&"pause")
		elif not _llamar(&"setVolume", [volumen(), volumen()]) or not _llamar(&"start"):
			_pasar_a_respaldo()


## El fondo desenfocado de Configuracion, congelado: el video se dibuja una vez a media pantalla (una sola lectura de
## la textura del decodificador por px: leerla varias veces costaba hasta 26 FPS en el S50), se reduce a 1/8 y se
## desenfoca en una pasada, y se estira con filtro lineal; el video se pausa mientras tanto. En el S50: menu 52,7 FPS,
## con Configuracion y el desenfoque 55,1 (demo de La Celda, 25-oct-2026). Falso lo quita y sigue el video.
func desenfocar(si: bool) -> void:
	if _borroso != null:
		_borroso.queue_free()
		_borroso = null
	# Sin video ni imagen (el respaldo sin .jpg) no hay nada que desenfocar.
	if not si or sin_ventana() or (_lienzo == null and _theora == null and _respaldo == null):
		_mostrar(true)
		pausar(false)
		return
	_borroso = Control.new()
	_borroso.name = &"Borroso"
	_borroso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_borroso)
	var pantalla: Vector2 = get_viewport().get_visible_rect().size
	var copia: Control = null
	if _theora != null or _respaldo != null:
		copia = _imagen(_theora.get_video_texture() if _theora != null else _respaldo.texture, null)
	else:
		var rect: ColorRect = ColorRect.new()
		rect.material = _material
		copia = rect
	var fuente: Texture2D = _etapa(pantalla / 2.0, copia)
	var chico: Vector2 = pantalla / float(DIVISION_DESENFOQUE)
	var reducir: ShaderMaterial = ShaderMaterial.new()
	reducir.shader = load(SHADER_DESENFOQUE) as Shader
	reducir.set_shader_parameter(&"paso", Vector2(1.0 / chico.x, 1.0 / chico.y))
	fuente = _etapa(chico, _imagen(fuente, reducir))
	var borroso: Control = _borroso
	# Dos cuadros: el de cada etapa. Despues no se redibujan.
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	if borroso != _borroso or not is_instance_valid(borroso):
		return
	for vista: Node in _borroso.get_children():
		(vista as SubViewport).render_target_update_mode = SubViewport.UPDATE_DISABLED
	_borroso.add_child(_imagen(fuente, null))
	_mostrar(false)
	pausar(true)


func _process(delta: float) -> void:
	if _superficie_textura == null or _pausado or _en_segundo_plano:
		return
	_superficie_textura.call(&"updateTexImage")
	if _vigilando:
		_vigilar(delta)


func _notification(que: int) -> void:
	if que == NOTIFICATION_APPLICATION_PAUSED:
		_en_segundo_plano = true
		if _medios != null and _sonando and not _pausado:
			_llamar(&"pause")
	elif que == NOTIFICATION_APPLICATION_RESUMED:
		_en_segundo_plano = false
		# Un video sin bucle que ya termino no vuelve a empezar al regresar a la app.
		if _medios != null and _sonando and not _pausado and not _terminado and not _llamar(&"start"):
			_pasar_a_respaldo()


func _exit_tree() -> void:
	detener()


## Lo llama MediaPlayer, por el proxy de OnCompletionListener, al terminar un video sin bucle. Puede llegar desde otro
## hilo de Java: el trabajo se hace en el hilo principal.
func onCompletion(_medios_java: Object) -> void:
	_al_terminar.call_deferred()


## Lo llama MediaPlayer, por el mismo proxy (OnErrorListener), si la decodificacion falla a mitad. Devuelve true: el
## error queda atendido y no llega onCompletion. El respaldo se arma en el hilo principal.
func onError(_medios_java: Object, que: int, extra: int) -> bool:
	_fallo.call_deferred(que, extra)
	return true


func _al_terminar() -> void:
	_vigilando = false
	if _terminado:
		return
	_terminado = true
	terminado.emit()


# Una lectura de la posicion cada REVISAR_CADA s (una llamada a Java, no una por cuadro).
func _vigilar(delta: float) -> void:
	_desde_revision += delta
	if _desde_revision < REVISAR_CADA:
		return
	var transcurrido: float = _desde_revision
	_desde_revision = 0.0
	var posicion: int = _medios.call(&"getCurrentPosition") as int
	if not _bien("getCurrentPosition"):
		_pasar_a_respaldo()
		return
	if posicion > _posicion:
		_posicion = posicion
		_sin_avanzar = 0.0
		return
	_sin_avanzar += transcurrido
	if _sin_avanzar >= SIN_AVANCE:
		push_warning("ReproductorVideo: %s dejo de avanzar en %d ms; sigue sin el" % [_ruta, posicion])
		_al_terminar()


# El fin sin ventana, solo si nadie detuvo ni volvio a empezar el video mientras tanto.
func _terminar_si_sigue(generacion: int) -> void:
	if generacion == _generacion:
		_al_terminar()


func _fallo(que: int, extra: int) -> void:
	push_warning("ReproductorVideo: MediaPlayer fallo (%d, %d); sigue con el respaldo" % [que, extra])
	_pasar_a_respaldo()


# Theora si el .ogv esta (PC); si no (APK), la imagen de respaldo si la hay; si tampoco, negro.
func _armar_respaldo() -> void:
	if ResourceLoader.exists(_ruta + ".ogv"):
		_armar_theora()
	elif ResourceLoader.exists(_ruta + ".jpg"):
		_respaldo = _imagen(load(_ruta + ".jpg") as Texture2D, null)
		_respaldo.name = &"Respaldo"
		add_child(_respaldo)


# Theora suena; una imagen o el negro no tienen fin: un video sin bucle termina ya (la cinematica pasa a su sala).
func _reproducir_respaldo() -> void:
	if _theora != null:
		_theora.play()
	elif not _bucle:
		_al_terminar.call_deferred()


func _armar_theora() -> void:
	_theora = VideoStreamPlayer.new()
	_theora.name = &"Theora"
	_theora.stream = load(_ruta + ".ogv") as VideoStream
	_theora.expand = true
	_theora.loop = _bucle
	_theora.bus = Ajustes.BUS_MUSICA
	_theora.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_theora.finished.connect(_al_terminar)
	add_child(_theora)


func _armar_lienzo() -> void:
	_externa = ExternalTexture.new()
	_externa.size = Vector2(1920.0, 1080.0)
	_material = ShaderMaterial.new()
	_material.shader = load(SHADER_EXTERNO) as Shader
	_material.set_shader_parameter(&"externa", _externa)
	_lienzo = ColorRect.new()
	_lienzo.name = &"Lienzo"
	_lienzo.material = _material
	_lienzo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_lienzo)


# SurfaceTexture(id) -> Surface -> MediaPlayer, con el .mp4 copiado a user://. Falso si un paso falla: el llamador
# pasa al respaldo. Cada llamada se revisa con JavaClassWrapper.get_exception (classes/class_javaclasswrapper.rst:36).
func _armar_medios(id: int) -> bool:
	var archivo: String = _copiar(_ruta + ".mp4")
	if archivo.is_empty():
		return false
	_superficie_textura = JavaClassWrapper.wrap("android.graphics.SurfaceTexture").call(&"SurfaceTexture", id) as Object
	if not _bien("SurfaceTexture"):
		return false
	_superficie = JavaClassWrapper.wrap("android.view.Surface").call(&"Surface", _superficie_textura) as Object
	if not _bien("Surface"):
		return false
	_medios = JavaClassWrapper.wrap("android.media.MediaPlayer").call(&"MediaPlayer") as Object
	if not _bien("MediaPlayer"):
		return false
	# Un solo proxy atiende el fin y el error (classes/class_javaclasswrapper.rst:78).
	var oyente: Object = JavaClassWrapper.create_proxy(self,
			["android.media.MediaPlayer$OnCompletionListener", "android.media.MediaPlayer$OnErrorListener"])
	return (_llamar(&"setDataSource", [ProjectSettings.globalize_path(archivo)])
			and _llamar(&"setSurface", [_superficie])
			and _llamar(&"setLooping", [_bucle])
			and _llamar(&"setVolume", [volumen(), volumen()])
			and _llamar(&"setOnErrorListener", [oyente])
			and (_bucle or _llamar(&"setOnCompletionListener", [oyente]))
			and _llamar(&"prepare"))


# Copia el .mp4 del paquete a user:// si no esta o si cambio su tamano (otra version del APK). Devuelve la copia o
# vacio si fallo. 13 MB tardan 122 ms en el S50, una sola vez. No usa Archivo.copiar_atomico: DirAccess.copy_absolute
# no abre un archivo del paquete del APK (sparse pack, probado en el S50 el 25-oct-2026). Una copia cortada no se
# queda: su tamano no coincide y se vuelve a copiar.
func _copiar(origen: String) -> String:
	var destino: String = CARPETA_COPIAS + origen.get_file()
	var leido: FileAccess = FileAccess.open(origen, FileAccess.READ)
	if leido == null:
		push_warning("ReproductorVideo: no se abre %s" % origen)
		return ""
	var tamano: int = leido.get_length()
	var hecho: FileAccess = FileAccess.open(destino, FileAccess.READ)
	if hecho != null and hecho.get_length() == tamano:
		return destino
	hecho = null
	DirAccess.make_dir_recursive_absolute(CARPETA_COPIAS)
	var escrito: FileAccess = FileAccess.open(destino, FileAccess.WRITE)
	if escrito == null:
		push_warning("ReproductorVideo: no se escribe %s" % destino)
		return ""
	escrito.store_buffer(leido.get_buffer(tamano))
	escrito.close()
	return destino


# Llama un metodo del MediaPlayer y revisa su excepcion: get_exception solo guarda la de la ultima llamada.
func _llamar(metodo: StringName, argumentos: Array = []) -> bool:
	_medios.callv(metodo, argumentos)
	return _bien(metodo)


func _bien(paso: String) -> bool:
	var error: Object = JavaClassWrapper.get_exception()
	if error == null:
		return true
	push_warning("ReproductorVideo: %s fallo (%s); sigue con el respaldo" % [paso, error.call(&"toString")])
	return false


# Si la ruta de Android falla: la imagen de respaldo, o la sala si es una cinematica.
func _pasar_a_respaldo() -> void:
	_liberar()
	if is_instance_valid(_lienzo):
		_lienzo.queue_free()
	_lienzo = null
	_externa = null
	_armar_respaldo()
	_reproducir_respaldo()


func _liberar() -> void:
	for objeto: Object in [_medios, _superficie, _superficie_textura]:
		if objeto != null:
			objeto.call(&"release")
			_bien("release")
	_medios = null
	_superficie = null
	_superficie_textura = null


func _mostrar(si: bool) -> void:
	if _lienzo != null:
		_lienzo.visible = si
	elif _respaldo != null:
		_respaldo.visible = si
	elif _theora != null:
		# Theora sigue decodificando hasta que se pausa: transparente para no pintarlo dos veces.
		_theora.self_modulate.a = 1.0 if si else 0.0


# Un SubViewport del tamano dado (en px de la vista) que dibuja el control a todo su tamano; devuelve su imagen.
func _etapa(tamano: Vector2, contenido: Control) -> Texture2D:
	var vista: SubViewport = SubViewport.new()
	vista.disable_3d = true
	vista.transparent_bg = false
	vista.render_target_update_mode = SubViewport.UPDATE_ONCE
	vista.size = Vector2i(maxi(1, roundi(tamano.x)), maxi(1, roundi(tamano.y)))
	contenido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	contenido.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vista.add_child(contenido)
	_borroso.add_child(vista)
	return vista.get_texture()


# Una imagen que llena su padre con la textura, filtro lineal y el material dado (o ninguno).
func _imagen(textura: Texture2D, material_imagen: ShaderMaterial) -> TextureRect:
	var imagen: TextureRect = TextureRect.new()
	imagen.texture = textura
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_SCALE
	imagen.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	imagen.material = material_imagen
	imagen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return imagen
