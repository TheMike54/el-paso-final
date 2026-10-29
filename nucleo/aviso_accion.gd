class_name AvisoAccion
extends Area2D
# Pizarron que ensena una accion, como los avisos de King's Pass: con el jugador dentro de su zona, tras una espera,
# se dibuja en gis el boton de cada accion con su palabra (IconoBoton con el control o la tecla; en tactil el boton de
# la pantalla, que ademas late) y una nota opcional. Cuando vuelve lo dice su modo (una vez en la partida, en cada
# visita o siempre). El pizarron es arte de la sala: sin un CanvasItem hijo se dibuja una caja gris oscura.

## UNA_VEZ: hecha la accion se va y no vuelve en la partida (King's Pass; su id se marca con Partida.marcar).
## POR_VISITA: hecha se va, y vuelve al entrar otra vez a la sala (sin id). SIEMPRE: el pizarron sale cada vez que el
## jugador entra a su zona, aunque ya la haya hecho; el boton de la pantalla late solo hasta hacerla, y con id eso se
## recuerda en la partida (los pizarrones de La Celda, decision del 26-oct-2026).
enum Modo { UNA_VEZ, POR_VISITA, SIEMPRE }

## Ticks en que el dibujo aparece al entrar y se va al salir.
const TICKS_APARECER: int = 12
## Ticks dentro de la zona antes de aparecer: si en ese rato se hace la accion, no sale (Silksong espera 2 s).
const TICKS_ESPERA: int = 30
## Ticks que el dibujo sigue a la vista, contados desde que aparece, aunque la accion ya se haya hecho (King's Pass: 1 s).
const TICKS_MINIMO: int = 60
## Medida de la caja gris que marca el pizarron sin arte.
const PIZARRON: Vector2 = Vector2(240.0, 160.0)
const COLOR_PIZARRON: Color = Color(0.12, 0.16, 0.14, 1.0)
const COLOR_GIS: Color = Color(0.93, 0.93, 0.95, 1.0)
## Escala del dibujo de IconoBoton (mide el alto de la letra de los menus) sobre el pizarron.
const ESCALA_ICONOS: float = 2.0
## Radio del boton y del aro del joystick dibujados en tactil, en px.
const RADIO_TACTIL: float = 44.0
const TAMANO_LETRA_TACTIL: int = 20
## Letra de la palabra bajo el joystick y de la nota, en px.
const TAMANO_LETRA_NOTA: int = 22
## Hacia donde va la perilla del joystick dibujado para cada accion de moverse (interactuar es arriba, como el
## joystick).
const PERILLAS: Dictionary[StringName, Vector2] = {&"mover_izquierda": Vector2.LEFT, &"mover_derecha": Vector2.RIGHT, &"mover_arriba": Vector2.UP, &"mover_abajo": Vector2.DOWN, &"interactuar": Vector2.UP}
## Mas de dos acciones no caben en un pizarron.
const MAXIMO_ACCIONES: int = 2

## Acciones del InputMap que ensena, una o dos (abajo + atacar es el golpe hacia abajo).
@export var acciones: Array[StringName] = []
## Cuando vuelve a salir (ver Modo).
@export var modo: Modo = Modo.UNA_VEZ
## Id unico entre los objetos que se recuerdan en la sala: con el se marca hecha. Lo exige UNA_VEZ; POR_VISITA no lo
## lleva; en SIEMPRE es opcional (sin el, el boton vuelve a latir en cada visita).
@export var id: String = ""
## Palabra junto al boton; vacia, la etiqueta del boton de la pantalla de la ultima accion.
@export var texto: String = ""
## Linea bajo el boton (de donde sale la Inspiracion para curar); vacia, nada.
@export var nota: String = ""
## false: sin la caja gris, para el aviso que va sobre un objeto (el banco).
@export var pizarron: bool = true
## Zona que lo activa, apoyada en el suelo y centrada en el aviso.
@export var tamano: Vector2 = Vector2(480.0, 320.0)
## Centro del pizarron, relativo al aviso.
@export var punto: Vector2 = Vector2(0.0, -240.0)

## El jugador esta dentro, la opacidad del dibujo y si la accion ya se hizo; publicos para la prueba.
var dentro: bool = false
var alfa: float = 0.0
var hecha: bool = false

var _dibujo: Node2D = null
var _iconos: HBoxContainer = null
var _tactil: bool = false
var _resalto: bool = false
var _ticks_dentro: int = 0
var _ticks_visible: int = 0
var _curo: bool = false
# Hubo una conversacion este tick o el anterior: la pulsacion que la cierra no cuenta.
var _hablaba: bool = false


func _ready() -> void:
	Capas.poner(self, Capas.INTERACCION, Capas.JUGADOR)
	hecha = _recordada() and Partida.estado_de(Sala.clave_de(self), id) != null
	var forma: CollisionShape2D = CollisionShape2D.new()
	var caja: RectangleShape2D = RectangleShape2D.new()
	caja.size = tamano
	forma.shape = caja
	forma.position = Vector2(0.0, -tamano.y / 2.0)
	add_child(forma)
	_dibujo = Node2D.new()
	_dibujo.position = punto
	_dibujo.visible = false
	_dibujo.draw.connect(_dibujar)
	add_child(_dibujo)
	_iconos = HBoxContainer.new()
	_iconos.scale = Vector2(ESCALA_ICONOS, ESCALA_ICONOS)
	_iconos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_iconos.add_theme_constant_override(&"separation", int(Tema.SEPARACION_FILAS))
	_dibujo.add_child(_iconos)
	for i: int in acciones.size():
		var icono: IconoBoton = IconoBoton.new()
		icono.accion = acciones[i]
		if i == acciones.size() - 1:
			icono.texto = palabra()
		_iconos.add_child(icono)
	_iconos.resized.connect(_centrar_iconos)
	Eventos.jugador_curado.connect(_al_curar)
	body_entered.connect(_al_entrar_cuerpo)


func _exit_tree() -> void:
	_soltar_resalto()


func _physics_process(_delta: float) -> void:
	var jugador: Jugador = _jugador_dentro()
	dentro = jugador != null
	_ticks_dentro = _ticks_dentro + 1 if dentro else 0
	var hablando: bool = ControlesTactiles.hablando or _hablaba
	_hablaba = ControlesTactiles.hablando
	if not hecha and not hablando and _accion_hecha():
		hecha = true
		if _recordada():
			Partida.marcar(Sala.clave_de(self), id)
		_ensenar_botones()
	_curo = false
	# Hecha con el dibujo a la vista, sigue hasta TICKS_MINIMO; hecha antes de aparecer, no sale (salvo en SIEMPRE).
	# No sale si el jugador no puede atender: sentado, hablando o muerto. No con Jugador.puede_interactuar, que exige
	# el suelo y apagaria el de saltar a medio salto.
	var mostrar: bool = (dentro and _ticks_dentro > TICKS_ESPERA and _atiende(jugador)
			and (modo == Modo.SIEMPRE or not hecha or (alfa > 0.0 and _ticks_visible < TICKS_MINIMO)))
	if mostrar and alfa == 0.0:
		_ensenar_botones()
	alfa = clampf(alfa + (1.0 if mostrar else -1.0) / TICKS_APARECER, 0.0, 1.0)
	_ticks_visible = _ticks_visible + 1 if alfa > 0.0 else 0
	_dibujo.visible = alfa > 0.0
	_dibujo.modulate = Color(1.0, 1.0, 1.0, alfa)
	var tactil: bool = not UltimaEntrada.con_control()
	if tactil != _tactil:
		_tactil = tactil
		_dibujo.queue_redraw()
	if mostrar and not hecha and _tactil:
		var boton: StringName = _boton_de_pantalla()
		if boton != &"":
			ControlesTactiles.resaltada = boton
			_resalto = true
	else:
		_soltar_resalto()
	# Hecha, invisible, sin el jugador dentro ni resalto que soltar: no queda nada que hacer hasta que alguien entre
	# (body_entered). Dentro de la zona sigue, para que dentro se mantenga al dia.
	if hecha and alfa == 0.0 and not dentro and not _resalto:
		set_physics_process(false)


## La palabra que acompana al boton: texto o, vacio, la etiqueta del boton de la pantalla de la ultima accion.
func palabra() -> String:
	if not texto.is_empty() or acciones.is_empty():
		return texto
	return _etiqueta_de(acciones[acciones.size() - 1])


# Etiqueta del boton de la pantalla de una accion; vacia si va con el joystick.
func _etiqueta_de(accion: StringName) -> String:
	var indice: int = ControlesTactiles.ACCIONES.find(accion)
	return ControlesTactiles.ETIQUETAS[indice] if indice >= 0 else ""


## La primera accion que tiene boton en la pantalla; vacio si todas van con el joystick.
func _boton_de_pantalla() -> StringName:
	for accion: StringName in acciones:
		if ControlesTactiles.ACCIONES.has(accion):
			return accion
	return &""


# Curar se mantiene y un toque no cura: cuenta al recuperar una vida. Las demas, al pulsar la ultima accion con las
# otras mantenidas (abajo + atacar). Avanzar una conversacion con saltar o atacar no cuenta (lo filtra quien llama).
func _accion_hecha() -> bool:
	if acciones.is_empty():
		return false
	if acciones.has(&"curar"):
		return _curo
	var ultima: StringName = acciones[acciones.size() - 1]
	if not Input.is_action_just_pressed(ultima):
		return false
	for accion: StringName in acciones:
		if not Input.is_action_pressed(accion):
			return false
	return true


# Los botones de la pantalla de sus acciones quedan ensenados (Sala.botones_por_ensenar): al aparecer o al hacerse.
func _ensenar_botones() -> void:
	for accion: StringName in acciones:
		if ControlesTactiles.ACCIONES.has(accion):
			Partida.ensenar_boton(accion)


func _al_curar(_vidas: int) -> void:
	_curo = true


# Alguien entra a la zona: si el proceso se apago (hecha e invisible), vuelve a mirar.
func _al_entrar_cuerpo(_cuerpo: Node2D) -> void:
	set_physics_process(true)


# El jugador dentro de la zona, o null: un solo recorrido por tick.
func _jugador_dentro() -> Jugador:
	for cuerpo: Node2D in get_overlapping_bodies():
		var jugador: Jugador = cuerpo as Jugador
		if jugador != null:
			return jugador
	return null


func _atiende(jugador: Jugador) -> bool:
	return jugador != null and not (jugador.descansando or jugador.hablando or jugador.muerto)


# Si hecha se recuerda en la partida: con id, salvo en POR_VISITA.
func _recordada() -> bool:
	return modo != Modo.POR_VISITA and not id.is_empty()


func _soltar_resalto() -> void:
	if _resalto and ControlesTactiles.resaltada == _boton_de_pantalla():
		ControlesTactiles.resaltada = &""
	_resalto = false


func _centrar_iconos() -> void:
	_iconos.position = -_iconos.size * ESCALA_ICONOS / 2.0


# En tactil, cada accion como su boton de la pantalla (aro y etiqueta) o, si es de moverse, el aro del joystick con
# la perilla hacia donde va y la palabra debajo. En los dos modos, la nota al pie.
func _dibujar() -> void:
	if acciones.is_empty():
		return
	var fuente: Font = ThemeDB.fallback_font
	var abajo: float = RADIO_TACTIL + TAMANO_LETRA_NOTA * 1.4
	if _tactil:
		var paso: float = RADIO_TACTIL * 2.5
		var x: float = -paso * (acciones.size() - 1) / 2.0
		for accion: StringName in acciones:
			var centro: Vector2 = Vector2(x, 0.0)
			_dibujo.draw_arc(centro, RADIO_TACTIL, 0.0, TAU, ControlesTactiles.SEGMENTOS_ARCO, COLOR_GIS, 3.0)
			var indice: int = ControlesTactiles.ACCIONES.find(accion)
			if indice >= 0:
				Tema.texto_centrado(_dibujo, fuente, ControlesTactiles.ETIQUETAS[indice], centro + Vector2(0.0, TAMANO_LETRA_TACTIL * 0.35), TAMANO_LETRA_TACTIL, COLOR_GIS)
			elif PERILLAS.has(accion):
				_dibujo.draw_circle(centro + PERILLAS[accion] * RADIO_TACTIL * 0.5, RADIO_TACTIL * 0.35, COLOR_GIS)
			x += paso
		# La etiqueta del boton de la pantalla ya va dentro del aro: la palabra va debajo si es otra (o es del joystick).
		if not palabra().is_empty() and palabra() != _etiqueta_de(acciones[acciones.size() - 1]):
			Tema.texto_centrado(_dibujo, fuente, palabra(), Vector2(0.0, abajo), TAMANO_LETRA_NOTA, COLOR_GIS)
			abajo += TAMANO_LETRA_NOTA * 1.3
	if not nota.is_empty():
		Tema.texto_centrado(_dibujo, fuente, nota, Vector2(0.0, abajo), TAMANO_LETRA_NOTA, COLOR_GIS)


func _draw() -> void:
	if not pizarron:
		return
	for hijo: Node in get_children():
		if hijo is CanvasItem and hijo != _dibujo and not hijo is CollisionShape2D:
			return
	draw_rect(Rect2(punto - PIZARRON / 2.0, PIZARRON), COLOR_PIZARRON)
