class_name ControlesTactiles
extends Control
# Controles tactiles: traducen cada toque a las mismas acciones del InputMap que el teclado,
# con Input.action_press y action_release, para que la logica nunca lea el toque. Joystick
# invisible abajo a la izquierda y botones en la distribucion inicial del diseno, anclados a
# su esquina. Se ocultan al usar teclado o control y reaparecen al tocar la pantalla. Un boton
# que pide una habilidad solo se dibuja y responde mientras Partida la tiene. Donde va cada boton y su
# tamano los da Ajustes.disposicion, que cambia el editor de controles de Configuracion. El boton del mapa
# tiene doble uso: de pie dice Mapa y manda mapa; sentado en un banco dice Inventario y manda inventario.

const ACCIONES: Array[StringName] = [&"saltar", &"atacar", &"curar", &"impulso", &"pausa", &"mapa"]
const ETIQUETAS: PackedStringArray = ["Saltar", "Atacar", "Curar", "Impulso", "Pausa", "Mapa"]
## Lo que manda y dice el boton del mapa con el jugador sentado en un banco (Jugador.descansando).
const ACCION_SENTADO: StringName = &"inventario"
const ETIQUETA_SENTADO: String = "Inventario"
## Botones que siguen tomando un dedo nuevo con un menu abierto: cierran su menu (Pausa, en Configuracion, vuelve un
## nivel). Va por boton, no por accion: el del mapa sentado manda inventario, que tambien cierra el marco.
const BOTONES_DE_MENU: Array[StringName] = [&"pausa", &"mapa"]
## Centro de cada boton en la distribucion inicial: fraccion de una pantalla 16:9. De aqui salen los
## valores por omision de DisposicionControles; en juego manda Ajustes.disposicion.
const CENTROS: PackedVector2Array = [
	Vector2(0.91, 0.81), Vector2(0.81, 0.81), Vector2(0.82, 0.63), Vector2(0.91, 0.60),
	Vector2(0.94, 0.09), Vector2(0.94, 0.21),
]
## Esquina a la que se ancla cada boton: (1, 1) abajo a la derecha, (1, 0) arriba a la derecha.
const ANCLAS: PackedVector2Array = [
	Vector2(1, 1), Vector2(1, 1), Vector2(1, 1), Vector2(1, 1), Vector2(1, 0), Vector2(1, 0),
]
## Radio de cada boton, en fraccion del lado corto de la pantalla. Con los centros del diseno,
## Atacar y Saltar quedan a 0,18 del lado corto: sus radios suman menos para no encimarse.
const RADIOS: PackedFloat32Array = [0.085, 0.07, 0.07, 0.07, 0.05, 0.05]
## El toque cuenta un poco fuera del circulo dibujado: es mas facil acertar con el pulgar.
const HOLGURA: float = 1.25
## Zona del joystick: fraccion de la pantalla desde la esquina de arriba a la izquierda.
const ZONA_JOYSTICK: Rect2 = Rect2(0.0, 0.3, 0.45, 0.7)
## Radio del joystick y zona muerta, en fraccion del lado corto y del radio.
const RADIO_JOYSTICK: float = 0.12
const ZONA_MUERTA: float = 0.2
const COLOR_BOTON: Color = Color(1.0, 1.0, 1.0, 0.5)
const COLOR_PRESIONADO: Color = Color(1.0, 1.0, 1.0, 0.25)
## Botones que solo existen con una habilidad: accion -> habilidad de Partida. Sin ella no se
## dibujan ni responden, y los demas no se mueven.
const HABILIDAD_DE_BOTON: Dictionary[StringName, StringName] = {&"impulso": Habilidades.IMPULSO, &"atacar": Habilidades.PLUMA}
## Segmentos de cada aro y tamano unico de las etiquetas: en el S50 el dibujo de los controles costaba
## ~3,5 FPS jugando (medido el 12-oct-2026), sobre todo por intercalar aros y letras de tres tamanos.
const SEGMENTOS_ARCO: int = 24
const TAMANO_LETRA: int = 16

## Cuadros entre que se van los controles de una sala y llegan los de la siguiente: con mas, ya
## no es un cambio de sala (se paso por el menu) y lo que quedo presionado se suelta.
const CUADROS_CAMBIO_DE_SALA: int = 5

# Los dedos se recuerdan en variables estaticas: cada sala crea sus propios controles, y un dedo
# que sigue en la pantalla al cambiar de sala (o al reaparecer tras morir) lo suelta en los
# controles nuevos. Sin esto, su accion quedaba presionada sin nadie que la soltara.
# Dedo -> indice del boton que presiona.
static var _dedos_en_botones: Dictionary[int, int] = {}
# Dedo -> accion que presiono su boton: la del mapa depende de si el jugador estaba sentado al tocarlo.
static var _acciones_de_dedos: Dictionary[int, StringName] = {}
static var _dedo_joystick: int = -1
static var _origen_joystick: Vector2 = Vector2.ZERO
static var _palanca: Vector2 = Vector2.ZERO
# Acciones de movimiento que presiono el joystick: solo esas se sueltan, para no soltar una
# que sostiene el teclado o el control.
static var _movimientos_propios: Array[StringName] = []
# Cuadro en que salieron del arbol los ultimos controles; -1 si no hay dedos por heredar.
static var _cuadro_salida: int = -1
## Mientras el editor de controles esta abierto, los toques no presionan acciones y los botones no se dibujan.
static var editando: bool = false
## Mientras hay una conversacion (CajaDialogo) solo Pausa se dibuja y responde: el resto de la pantalla es de la caja.
static var hablando: bool = false
## Accion cuyo boton late para senalarlo (la pone un AvisoAccion con el jugador dentro); vacia: ninguno.
static var resaltada: StringName = &""

# Que botones estaban disponibles en la ultima revision, para redibujar solo si cambia.
var _disponibles: Array[bool] = []
# Sala de la que cuelgan los controles, para sus botones_por_ensenar.
var _sala: Sala = null
# La disposicion de Ajustes metida en el area segura de esta pantalla, y de cual salio, para notar
# cuando el editor la reemplaza.
var _disposicion: DisposicionControles = DisposicionControles.por_omision()
var _disposicion_origen: DisposicionControles = null
var _radio_minimo: float = 0.0
var _editando_visto: bool = false
var _menu_visto: bool = false
var _sentado_visto: bool = false
# La palanca son dos nodos que se dibujan una vez y se mueven con position: mover el joystick no
# vuelve a dibujar los botones.
var _base_palanca: Node2D = null
var _perilla: Node2D = null
## El boton de resaltada se esta dibujando latiendo; publico para la prueba.
var latiendo: bool = false
# El latido es un nodo propio que se redibuja cada cuadro mientras late: no redibuja los demas botones.
var _latido: Node2D = null


func _ready() -> void:
	_sala = _sala_de_arriba()
	_crear_palanca()
	_latido = Node2D.new()
	_latido.visible = false
	_latido.draw.connect(_dibujar_latido)
	add_child(_latido)
	# Al entrar a una sala no hay evento: se decide con lo ultimo que anoto UltimaEntrada. No suelta dedos
	# al nacer ocultos: el dedo heredado de la sala anterior lo sueltan los controles nuevos al levantarse.
	visible = deben_verse(DisplayServer.is_touchscreen_available(), UltimaEntrada.con_control())
	if _cuadro_salida >= 0 and Engine.get_process_frames() - _cuadro_salida > CUADROS_CAMBIO_DE_SALA:
		_soltar_todo()
	_cuadro_salida = -1
	Ajustes.cargar_una_vez()
	aplicar_disposicion()
	resized.connect(aplicar_disposicion)
	_revisar_habilidades()


func _exit_tree() -> void:
	_cuadro_salida = Engine.get_process_frames()


# Al perder el foco la ventana o la app, o al pausarla Android, no llega el soltar de los dedos que estaban en la
# pantalla: se suelta todo para que ninguna accion quede presionada al volver (classes/class_node.rst:1001-1005,
# :1151-1155, :1173-1177).
func _notification(que: int) -> void:
	if (que == NOTIFICATION_WM_WINDOW_FOCUS_OUT or que == NOTIFICATION_APPLICATION_FOCUS_OUT
			or que == NOTIFICATION_APPLICATION_PAUSED):
		_soltar_todo()


# Cada cuadro, porque la habilidad llega al tomar el objeto y Partida.reiniciar() la borra sin
# avisar: asi el boton aparece y desaparece sin recargar la sala.
func _process(_delta: float) -> void:
	_revisar_habilidades()
	if Ajustes.disposicion != _disposicion_origen:
		aplicar_disposicion()
	if _sentado() != _sentado_visto:
		_sentado_visto = not _sentado_visto
		queue_redraw()
	if editando != _editando_visto:
		_editando_visto = editando
		if editando:
			_soltar_todo()
		queue_redraw()
	# Al abrirse un menu (el arbol se detiene) se suelta lo que habia, tambien el dedo con que se toco Pausa o Mapa: los
	# menus solo leen is_action_just_pressed, asi que soltar su accion no abre ni cierra nada, y como el dedo se borra,
	# al levantarlo _soltar no hace nada. Los botones se siguen dibujando.
	if _hay_menu() != _menu_visto:
		_menu_visto = not _menu_visto
		if _menu_visto:
			_soltar_todo()
	# El joystick con que se empezo a hablar (arriba tambien es interactuar) se suelta al abrir la caja.
	if hablando and _dedo_joystick != -1:
		_soltar(_dedo_joystick)
	var indice: int = ACCIONES.find(resaltada)
	latiendo = indice >= 0 and _disponibles[indice] and not editando and not hablando
	_latido.visible = latiendo
	if latiendo:
		_latido.queue_redraw()


## Toma Ajustes.disposicion y la ajusta al tamano y al area segura de esta pantalla.
func aplicar_disposicion() -> void:
	_disposicion_origen = Ajustes.disposicion
	_disposicion = Ajustes.disposicion.copia()
	_radio_minimo = DisposicionControles.radio_minimo(size)
	_disposicion.ajustar(size, DisposicionControles.area_segura(size), _radio_minimo)
	queue_redraw()
	# El radio del joystick sale del tamano de la pantalla.
	_base_palanca.queue_redraw()
	_perilla.queue_redraw()
	_actualizar_palanca()


func _input(evento: InputEvent) -> void:
	procesar(evento)


## Traduce un evento de entrada. Publico para que la prueba le pase toques sin pantalla. No redibuja:
## lo pide solo lo que cambia algo que se ve.
func procesar(evento: InputEvent) -> void:
	# Android repite cada toque como evento de raton: aqui no sirve (el editor lee el suyo).
	if editando or evento is InputEventMouse:
		return
	var toque: InputEventScreenTouch = evento as InputEventScreenTouch
	var arrastre: InputEventScreenDrag = evento as InputEventScreenDrag
	if toque != null:
		# Un toque prueba que hay pantalla tactil (real o emulada) y que lo ultimo fue el dedo, tambien al levantarlo:
		# clasificar da TOQUE al apoyar y SIN_CAMBIO al levantar, y los dos muestran. Se clasifica aqui porque este
		# _input corre antes que el de UltimaEntrada, que todavia no lo anoto.
		if not visible and deben_verse(true, not _es_dedo(UltimaEntrada.clasificar(toque))):
			visible = true
			queue_redraw()
		# Un toque cancelado (el sistema se quedo con el gesto) suelta como levantar el dedo
		# (classes/class_inputeventscreentouch.rst:60-71). En 4.7.2 canceled ya deja pressed en false: la
		# comprobacion es por si otra version los manda juntos.
		if toque.pressed and not toque.canceled:
			# Con un menu abierto, _tocar solo deja Pausa y Mapa; soltar y arrastrar siguen siempre.
			_tocar(toque.index, toque.position)
		else:
			_soltar(toque.index)
	elif arrastre != null:
		if arrastre.index == _dedo_joystick:
			_mover_joystick(arrastre.position)
	elif UltimaEntrada.es_de_juego(evento):
		# Una tecla o un control nunca clasifican como TOQUE: ocultan siempre, aunque el evento no cambie lo anotado.
		if visible and not deben_verse(true, UltimaEntrada.clasificar(evento) != Mando.Dispositivo.TOQUE):
			_soltar_todo()
			visible = false


## La regla de cuando se ven los controles: con pantalla tactil y con el dedo como ultimo uso (con_control false).
## La usan el arranque en cada sala (con UltimaEntrada.con_control()) y procesar al cambiar de entrada jugando.
static func deben_verse(tactil: bool, con_control: bool) -> bool:
	return tactil and not con_control


## Centro de un boton en la pantalla actual. Para la prueba y para dibujar.
func centro(accion: StringName) -> Vector2:
	return _disposicion.centro(ACCIONES.find(accion), size)


func _radio(i: int) -> float:
	return _disposicion.radio(i, size, _radio_minimo)


func _radio_joystick() -> float:
	return RADIO_JOYSTICK * minf(size.x, size.y)


func _disponible(i: int) -> bool:
	if hablando and ACCIONES[i] != &"pausa":
		return false
	if por_ensenar(ACCIONES[i]):
		return false
	var habilidad: StringName = HABILIDAD_DE_BOTON.get(ACCIONES[i], &"")
	return habilidad.is_empty() or Partida.tiene(habilidad)


## true si la sala esconde el boton de esa accion hasta que un pizarron lo ensene y todavia no lo enseno.
func por_ensenar(accion: StringName) -> bool:
	return (_sala != null and _sala.botones_por_ensenar.has(accion)
			and not Partida.botones_ensenados.has(accion))


# La sala de la que cuelgan los controles (estan dentro de su CanvasLayer); null fuera de una sala.
func _sala_de_arriba() -> Sala:
	var nodo: Node = get_parent()
	while nodo != null and not nodo is Sala:
		nodo = nodo.get_parent()
	return nodo as Sala


# Hay un menu abierto si el arbol esta detenido: solo lo detienen la pausa, el marco de menus, la tienda, las
# estaciones y su cobro. Cualquier pausa nueva del arbol tambien deja sin responder los botones de juego y el joystick
# (docs/contrato.md, Entrada).
func _hay_menu() -> bool:
	return get_tree().paused


# Un boton que deja de estar disponible (habilidad que falta, boton por ensenar o un dialogo en curso) con un dedo
# encima suelta su accion, como al levantar el dedo.
# Compara en el mismo arreglo: corre cada cuadro, tambien en pausa. La primera vez siempre cuenta como cambio.
func _revisar_habilidades() -> void:
	var cambio: bool = _disponibles.size() != ACCIONES.size()
	if cambio:
		_disponibles.resize(ACCIONES.size())
	for i: int in range(ACCIONES.size()):
		var ahora: bool = _disponible(i)
		if _disponibles[i] != ahora:
			_disponibles[i] = ahora
			cambio = true
	if not cambio:
		return
	for dedo: int in _dedos_en_botones.keys():
		if not _disponibles[_dedos_en_botones[dedo]]:
			_soltar(dedo)
	queue_redraw()


func _tocar(dedo: int, posicion: Vector2) -> void:
	# Un dedo que vuelve a llegar sin haberse soltado (se perdio su soltar) suelta antes lo que tenia: si no, su
	# boton quedaba presionado para siempre o el joystick seguia con el origen viejo.
	_soltar(dedo)
	_revisar_habilidades()
	# Con un menu abierto solo Pausa y Mapa toman el dedo: un boton de juego o el joystick no hacen nada encima del menu.
	var menu: bool = _hay_menu()
	for i: int in range(ACCIONES.size()):
		if not _disponibles[i]:
			continue
		if menu and not BOTONES_DE_MENU.has(ACCIONES[i]):
			continue
		if posicion.distance_to(centro(ACCIONES[i])) <= _radio(i) * HOLGURA:
			_dedos_en_botones[dedo] = i
			_acciones_de_dedos[dedo] = _accion(i)
			Input.action_press(_acciones_de_dedos[dedo])
			queue_redraw()
			return
	var zona: Rect2 = Rect2(ZONA_JOYSTICK.position * size, ZONA_JOYSTICK.size * size)
	if _dedo_joystick == -1 and zona.has_point(posicion) and not hablando and not menu:
		_dedo_joystick = dedo
		_origen_joystick = posicion
		_palanca = Vector2.ZERO
		_actualizar_palanca()


func _soltar(dedo: int) -> void:
	if dedo == _dedo_joystick:
		_dedo_joystick = -1
		_palanca = Vector2.ZERO
		_aplicar_palanca()
		_actualizar_palanca()
	elif _dedos_en_botones.has(dedo):
		var accion: StringName = _acciones_de_dedos[dedo]
		_dedos_en_botones.erase(dedo)
		_acciones_de_dedos.erase(dedo)
		# Otro dedo puede seguir sobre el mismo boton.
		if not _acciones_de_dedos.values().has(accion):
			Input.action_release(accion)
		queue_redraw()


func _soltar_todo() -> void:
	if not _dedos_en_botones.is_empty():
		queue_redraw()
	for accion: StringName in _acciones_de_dedos.values():
		Input.action_release(accion)
	_dedos_en_botones.clear()
	_acciones_de_dedos.clear()
	_dedo_joystick = -1
	_palanca = Vector2.ZERO
	_aplicar_palanca()
	_actualizar_palanca()


# La accion que manda el boton i ahora: la del mapa cambia a inventario con el jugador sentado.
func _accion(i: int) -> StringName:
	if ACCIONES[i] == &"mapa" and _sentado():
		return ACCION_SENTADO
	return ACCIONES[i]


func _etiqueta(i: int) -> String:
	if ACCIONES[i] == &"mapa" and _sentado():
		return ETIQUETA_SENTADO
	return ETIQUETAS[i]


func _sentado() -> bool:
	return Jugador.sentado(get_tree())


func _mover_joystick(posicion: Vector2) -> void:
	var radio: float = _radio_joystick()
	_palanca = ((posicion - _origen_joystick) / radio).limit_length(1.0)
	_aplicar_palanca()
	_perilla.position = _palanca * radio


func _aplicar_palanca() -> void:
	_aplicar_eje(_palanca.x, &"mover_izquierda", &"mover_derecha")
	_aplicar_eje(_palanca.y, &"mover_arriba", &"mover_abajo")
	# Como la flecha arriba y el stick arriba, el joystick arriba tambien es interactuar.
	if _palanca.y <= -ZONA_MUERTA:
		_presionar_movimiento(&"interactuar", -_palanca.y)
	else:
		_soltar_movimiento(&"interactuar")


# Un eje del joystick a dos acciones con fuerza: la logica las lee con Input.get_axis.
func _aplicar_eje(valor: float, negativa: StringName, positiva: StringName) -> void:
	if valor <= -ZONA_MUERTA:
		_presionar_movimiento(negativa, -valor)
		_soltar_movimiento(positiva)
	elif valor >= ZONA_MUERTA:
		_presionar_movimiento(positiva, valor)
		_soltar_movimiento(negativa)
	else:
		_soltar_movimiento(negativa)
		_soltar_movimiento(positiva)


func _presionar_movimiento(accion: StringName, fuerza: float) -> void:
	Input.action_press(accion, fuerza)
	if not _movimientos_propios.has(accion):
		_movimientos_propios.append(accion)


func _soltar_movimiento(accion: StringName) -> void:
	if _movimientos_propios.has(accion):
		_movimientos_propios.erase(accion)
		Input.action_release(accion)


# Lo que clasifica un toque: TOQUE al apoyar el dedo, SIN_CAMBIO al levantarlo o cancelarlo; los dos son el dedo.
func _es_dedo(clase: int) -> bool:
	return clase == Mando.Dispositivo.TOQUE or clase == UltimaEntrada.SIN_CAMBIO


func _crear_palanca() -> void:
	_base_palanca = Node2D.new()
	_base_palanca.visible = false
	_base_palanca.draw.connect(_dibujar_base)
	add_child(_base_palanca)
	_perilla = Node2D.new()
	_perilla.draw.connect(_dibujar_perilla)
	_base_palanca.add_child(_perilla)


# Muestra la palanca donde empezo el dedo del joystick, o la oculta si no hay dedo.
func _actualizar_palanca() -> void:
	if _base_palanca == null:
		return
	var mostrar: bool = _dedo_joystick != -1
	if mostrar and not _base_palanca.visible:
		# Un redibujo pedido estando oculta no se hace: se pide al aparecer (solo al poner el dedo).
		_base_palanca.queue_redraw()
		_perilla.queue_redraw()
	_base_palanca.visible = mostrar
	_base_palanca.position = _origen_joystick
	_perilla.position = _palanca * _radio_joystick()


func _dibujar_base() -> void:
	_base_palanca.draw_arc(Vector2.ZERO, _radio_joystick(), 0.0, TAU, SEGMENTOS_ARCO, COLOR_BOTON, 2.0)


# Un aro grueso alrededor del boton resaltado que crece y se aclara una vez por segundo.
func _dibujar_latido() -> void:
	var indice: int = ACCIONES.find(resaltada)
	if indice < 0:
		return
	var fase: float = fmod(float(Engine.get_physics_frames()) / 60.0, 1.0)
	var color: Color = Color(COLOR_BOTON, (1.0 - fase) * 0.9)
	_latido.draw_arc(centro(resaltada), _radio(indice) * (1.0 + 0.3 * fase), 0.0, TAU, SEGMENTOS_ARCO, color, 4.0)


func _dibujar_perilla() -> void:
	_perilla.draw_circle(Vector2.ZERO, _radio_joystick() * 0.4, COLOR_PRESIONADO)


# Agrupado: primero los circulos de los presionados, luego todos los aros y al final todas las
# etiquetas, con un solo tamano de letra, para que el renderer junte las llamadas de dibujo.
func _draw() -> void:
	if editando:
		return
	var color_boton: Color = Color(COLOR_BOTON, COLOR_BOTON.a * _disposicion.opacidad)
	var color_presionado: Color = Color(COLOR_PRESIONADO, COLOR_PRESIONADO.a * _disposicion.opacidad)
	var presionados: Array = _dedos_en_botones.values()
	for i: int in range(ACCIONES.size()):
		# Una vez por boton aunque tenga dos dedos encima.
		if _disponibles[i] and presionados.has(i):
			draw_circle(centro(ACCIONES[i]), _radio(i), color_presionado)
	for i: int in range(ACCIONES.size()):
		if _disponibles[i]:
			draw_arc(centro(ACCIONES[i]), _radio(i), 0.0, TAU, SEGMENTOS_ARCO, color_boton, 2.0)
	var fuente: Font = ThemeDB.fallback_font
	for i: int in range(ACCIONES.size()):
		if _disponibles[i]:
			var etiqueta: String = _etiqueta(i)
			Tema.texto_centrado(self, fuente, etiqueta, centro(ACCIONES[i]) + Vector2(0.0, TAMANO_LETRA * 0.35), TAMANO_LETRA, color_boton)
