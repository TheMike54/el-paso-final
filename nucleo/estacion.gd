class_name Estacion
extends Interactuable
# Estacion del viaje rapido, como las del Ciervo de Hollow Knight: se paga una vez (costo en PejeCoins, con el juego
# detenido en su CobroEstacion) y queda abierta en Partida.estaciones; abierta, interactuar abre el menu de destinos
# (MenuEstaciones) y elegir otra le pide al Fundido el cambio a su sala, donde el jugador aparece en su llegada. No
# cura, no guarda ni cambia el banco. Va como hija directa de una sala con id. Capa, cerca, disparador y caja: de
# Interactuable.

const PREFIJO: String = "estacion_"
# Caja gris de ANCHO x ALTO hasta que tenga arte (un CanvasItem hijo la apaga).
const ANCHO: float = 240.0
const ALTO: float = 200.0
const COLOR: Color = Color(0.4, 0.5, 0.45, 1.0)
const ALTURA_AVISO: float = 240.0
## La tabla de las estaciones del juego y la de la zona de pruebas: cada estacion usa la de la carpeta de su sala.
const TABLA_JUEGO: String = "res://contenido/estaciones.tres"
const TABLA_PRUEBAS: String = "res://herramientas/salas/zonas/estaciones_prueba.tres"
const QUIEN: String = "Estación"
## Lo que pregunta el cobro (%d: las monedas que se tienen) y su linea de cantidad (%d: el costo).
const TEXTO_PAGAR: String = "¿Abrir esta estación? Tienes %d PejeCoins."
const TEXTO_COSTO: String = "%d PejeCoins"
const TEXTO_ABIERTA: String = "Estación abierta. Interactúa otra vez para viajar."
const TEXTO_NO_ALCANZA: String = "No te alcanza."

## estacion_<id de la sala>; lo exige el validador, y la tabla dice su nombre y su sala.
@export var id: String = ""
## PejeCoins que se pagan una vez para abrirla; 0, gratis.
@export var costo: int = 0
## Donde aparece el jugador al llegar a esta estacion, relativo a ella.
@export var llegada: Vector2 = Vector2.ZERO

## Publicas para las pruebas (cerca y la caja que dice como salio el pago son de la base): el cobro (con el juego
## detenido), el menu y el destino en curso.
var cobro: CobroEstacion = null
var menu: MenuEstaciones = null
var destino: String = ""


func _ready() -> void:
	super()
	_crear_forma(ANCHO, ALTO)


## La tabla que usa una sala: la de pruebas si la sala esta en la zona de pruebas; si no, la del juego. null si no
## existe (el nucleo no depende de contenido/ ni de herramientas/).
static func tabla_de(id_sala: String) -> FichaEstaciones:
	var ruta: String = TABLA_PRUEBAS if Sala.ruta_de(id_sala).begins_with(Sala.CARPETA_PRUEBAS) else TABLA_JUEGO
	return Cargar.si_existe(ruta) as FichaEstaciones


# Con un viaje en curso no corre nada de la base (vigilar la caja, cerca y el disparador): el Fundido cambia de sala.
func _physics_process(delta: float) -> void:
	if not destino.is_empty():
		return
	super(delta)


## Abierta (o gratis, que se abre sola): el menu de destinos. Cerrada: el cobro (CobroEstacion), que pregunta si se
## paga con el juego detenido. Publica para las pruebas; en el juego la llama interactuar.
func interactuar(jugador: Jugador) -> void:
	_jugador = jugador
	if not Partida.estacion_abierta(id) and costo == 0:
		pagar()
	if Partida.estacion_abierta(id):
		abrir_menu()
		return
	if cobro != null:
		return
	cerca = false
	queue_redraw()
	cobro = CobroEstacion.new()
	cobro.name = "Cobro"
	cobro.texto_pregunta = TEXTO_PAGAR % Partida.monedas
	cobro.texto_cantidad = TEXTO_COSTO % costo
	cobro.cerrado.connect(func() -> void: cobro = null)
	cobro.pagar_pedido.connect(_al_pagar)
	add_child(cobro)


## Paga y la abre: false si ya estaba abierta o no alcanzan las monedas; si no, cobra, la abre y autoguarda.
func pagar() -> bool:
	if Partida.estacion_abierta(id) or not Partida.gastar_monedas(costo):
		return false
	Partida.abrir_estacion(id)
	Partida.autoguardar()
	return true


## El menu de destinos, con el juego detenido.
func abrir_menu() -> void:
	if menu != null:
		return
	menu = MenuEstaciones.new()
	menu.name = "Menu"
	menu.estacion = self
	menu.cerrado.connect(func() -> void: menu = null)
	add_child(menu)
	cerca = false
	queue_redraw()


## Viaja a otra estacion abierta de la misma tabla: funde a negro y, en negro, cambia a su sala. false si no se puede
## (es esta, no esta abierta, no esta en la tabla o ya hay un viaje en curso).
func viajar(id_destino: String) -> bool:
	var tabla: FichaEstaciones = tabla_de(Sala.clave_de(self))
	var dato: DatoEstacion = tabla.buscar(id_destino) if tabla != null else null
	if dato == null or id_destino == id or not Partida.estacion_abierta(id_destino) or not destino.is_empty():
		return false
	var fundido: Fundido = Fundido.de(self)
	if fundido == null:
		push_error("Estacion %s: no esta en una sala con Fundido" % id)
		return false
	_jugador = Jugador.encima_de(self) if not is_instance_valid(_jugador) else _jugador
	var jugador: Jugador = _jugador if is_instance_valid(_jugador) else null
	if not fundido.cambiar_sala(Sala.ruta_de(dato.sala), Fundido.Llegada.ESTACION, id_destino,
			Fundido.Perfil.ESTACION, 0, jugador):
		return false
	destino = id_destino
	if jugador != null:
		jugador.empezar_a_hablar()  # no hay conversacion: solo lo inmoviliza durante el viaje
	fundido.en_negro.connect(_al_llegar_al_negro, CONNECT_ONE_SHOT)
	return true


# Ya en negro: si el jugador murio mientras oscurecia, manda la muerte (el Fundido no cambia de sala) y la estacion
# vuelve a servir; si no, el viaje se hizo. El cambio va en diferido: si falla, el Fundido avisa despues con
# cambio_fallido.
func _al_llegar_al_negro() -> void:
	if is_instance_valid(_jugador) and _jugador.muerto:
		destino = ""
		return
	var fundido: Fundido = Fundido.de(self)
	if fundido != null and not fundido.cambio_fallido.is_connected(_al_fallar_viaje):
		fundido.cambio_fallido.connect(_al_fallar_viaje, CONNECT_ONE_SHOT)
	Eventos.viaje_hecho.emit(destino)


# La sala no cambio: el jugador deja de estar quieto (no tiene tope como el de las puertas) y la estacion vuelve a
# servir.
func _al_fallar_viaje() -> void:
	destino = ""
	if is_instance_valid(_jugador):
		_jugador.dejar_de_hablar()


# Si en el cobro (ya cerrado, con el juego andando): cobra y dice en la caja de dialogo si se abrio o no alcanzo, como
# lo decia antes la segunda linea de la caja que preguntaba; interactuar la cierra.
func _al_pagar() -> void:
	var texto: String = TEXTO_ABIERTA if pagar() else TEXTO_NO_ALCANZA
	if not is_instance_valid(_jugador) or _jugador.muerto:
		return
	var ficha: FichaDialogo = FichaDialogo.new()
	ficha.lineas.append(LineaDialogo.nueva(QUIEN, texto))
	_abrir_caja(_jugador, ficha)


func _al_interactuar(jugador: Jugador) -> void:
	interactuar(jugador)


# Con el cobro o el menu abiertos no sigue cerca ni dispara.
func _puede_interactuar() -> bool:
	return menu == null and cobro == null


# Como la de la base, pero sin soltar _jugador: viajar lo reutiliza.
func _cerrar_caja() -> void:
	if is_instance_valid(_jugador):
		_jugador.dejar_de_hablar()
	if caja != null:
		caja.ficha = null
		caja.queue_free()
		caja = null


func _draw() -> void:
	dibujar_provisional(ANCHO, ALTO, COLOR)
	dibujar_aviso(ALTURA_AVISO)
