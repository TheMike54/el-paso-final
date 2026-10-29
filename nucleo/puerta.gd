class_name Puerta
extends Interactuable
# Puerta entre salas, como el TransitionPoint de Hollow Knight: lleva a la puerta puerta_destino de sala_destino. Su
# tipo lo decide el arte: un pasillo, hueco o boquete (LADO, ARRIBA, ABAJO) se cruza al entrar en su area; una puerta
# en la pared (PUERTA) se usa con interactuar estando enfrente, con el aviso y la regla de Interactuable. El cambio de
# sala lo hace el Fundido; la puerta solo pone al jugador a salir y se lo pide. Va como hija directa de una sala.

## Como se cruza (GatePosition de Hollow Knight). LADO: caminando, y el jugador sale caminando hacia afuera hasta la
## pared de detras mientras funde; PUERTA: con interactuar, voltea de espaldas y se mete; ARRIBA y ABAJO: un hueco del
## techo o del piso, se cruza al entrar y sigue con la velocidad que llevaba.
enum Tipo { LADO, PUERTA, ARRIBA, ABAJO }

## Altura de la punta del triangulo de aviso de una PUERTA sobre el piso: encima del marco.
const ALTURA_AVISO: float = 290.0
## Ticks de mas sobre el cruce antes de que el jugador deje de esperar el cambio de sala (si falla, Jugador.salir_de_sala).
const MARGEN_TOPE: int = 30
## Rectangulo provisional de una puerta sin arte; una pieza con arte (contenido/objetos/) lo apaga con sus hijos.
const COLOR_PROVISIONAL: Color = Color(0.6, 0.45, 0.2, 0.6)

## Id de la puerta, unico dentro de su sala.
@export var id: StringName = &""
## Sala a la que lleva: su id (prueba_2), o su ruta res:// solo si es una sala de prueba suelta sin id.
@export var sala_destino: String = ""
## Id de la puerta de la sala destino donde aparece el jugador.
@export var puerta_destino: StringName = &""
## Donde aparece el jugador al llegar por esta puerta, relativo a ella. Si no es PUERTA, fuera de su area (con el
## cuerpo del jugador), para no rebotar; dentro de los limites de la sala (lo revisa el validador).
@export var llegada: Vector2 = Vector2(160.0, 0.0)
## Como se cruza; lo decide su arte (docs/contrato.md, «Cambio de sala»).
@export var tipo: Tipo = Tipo.LADO
## Punto seguro de esta llegada, relativo a la puerta, para cuando la llegada no tiene suelo debajo (un hueco del techo):
## Jugador.ultimo_punto_seguro lo prueba antes que la llegada. (0, 0): no tiene, se usa la llegada.
@export var punto_seguro: Vector2 = Vector2.ZERO
## Hacia donde mira el jugador al salir de espaldas de una PUERTA: 1 derecha, -1 izquierda; 0, hacia el centro de la sala.
@export_range(-1, 1, 1) var mirar_al_llegar: int = 0

var _cruzada: bool = false


func _ready() -> void:
	super()
	if tipo != Tipo.PUERTA:
		body_entered.connect(_al_entrar)
		# Sin acciones que vigilar: el disparador y el aviso de la base no corren (classes/class_node.rst:1605).
		set_physics_process(false)


func _draw() -> void:
	dibujar_provisional(40.0, 160.0, COLOR_PROVISIONAL)
	dibujar_aviso(ALTURA_AVISO)


## Hacia donde entra el jugador al llegar por esta puerta: LADO, hacia donde apunta la llegada; PUERTA, mirar_al_llegar o,
## con 0, hacia el centro de la sala (centro_x); ARRIBA y ABAJO no lo mueven (0).
func lado_al_llegar(centro_x: float) -> float:
	match tipo:
		Tipo.LADO:
			return signf(llegada.x)
		Tipo.PUERTA:
			return float(mirar_al_llegar) if mirar_al_llegar != 0 else signf(centro_x - position.x)
	return 0.0


## El punto seguro de la puerta en coordenadas de la sala (su padre); Vector2.INF si no tiene.
func punto_seguro_en_sala() -> Vector2:
	return position + punto_seguro if punto_seguro != Vector2.ZERO else Vector2.INF


func _al_entrar(cuerpo: Node2D) -> void:
	var jugador: Jugador = cuerpo as Jugador
	# Ya saliendo por otra puerta vecina: el cruce en curso manda.
	if jugador != null and not _cruzada and not jugador.muerto and not jugador.en_transicion:
		_cruzar(jugador, 0)


# Solo una PUERTA (las demas apagan el proceso de la base): una vez y con el jugador enfrente.
func _puede_interactuar() -> bool:
	return tipo == Tipo.PUERTA and not _cruzada


func _al_interactuar(jugador: Jugador) -> void:
	cerca = false
	queue_redraw()
	# El fundido espera a que el jugador termine de voltearse de espaldas (los primeros cuadros de su clip).
	_cruzar(jugador, jugador.ticks_giro_puerta())


# El Fundido de la sala cambia de sala cuando la pantalla esta en negro. Primero se le pide: si ya hay un cambio en curso
# lo rechaza y el jugador no se pone a salir ni la puerta queda cruzada.
func _cruzar(jugador: Jugador, retraso: int) -> void:
	var fundido: Fundido = Fundido.de(self)
	if fundido == null:
		push_error("Puerta %s: no esta en una sala con Fundido" % id)
		return
	if not fundido.cambiar_sala(Sala.ruta_de(sala_destino), Fundido.Llegada.PUERTA, String(puerta_destino),
			Fundido.Perfil.PUERTA, retraso, jugador):
		return
	_cruzada = true
	if not fundido.cambio_fallido.is_connected(_al_fallar_cambio):
		fundido.cambio_fallido.connect(_al_fallar_cambio, CONNECT_ONE_SHOT)
	var tope: int = Fundido.ticks_hasta_cambio(Fundido.Perfil.PUERTA, retraso) + MARGEN_TOPE
	jugador.salir_de_sala(tipo, -signf(llegada.x), global_position.x, tope)


# La sala no cambio: la puerta vuelve a servir (el jugador recupera el control por su tope).
func _al_fallar_cambio() -> void:
	_cruzada = false
