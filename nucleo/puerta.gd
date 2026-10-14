class_name Puerta
extends Area2D
# Puerta entre salas: cuando el jugador entra en su area, funde a negro, cambia a la sala destino y
# le dice a esa sala en que puerta debe aparecer. Va como hija directa de la raiz de una sala; la
# sala destino busca la puerta por su id y pone al jugador en su punto de llegada.

## Id de la puerta, unico dentro de su sala.
@export var id: StringName = &""
## Sala a la que lleva: su id (prueba_2), o su ruta res:// solo si es una sala de prueba suelta sin id.
@export var sala_destino: String = ""
## Id de la puerta de la sala destino donde aparece el jugador.
@export var puerta_destino: StringName = &""
## Donde aparece el jugador al llegar por esta puerta, relativo a ella. Fuera de su area, para no rebotar.
@export var llegada: Vector2 = Vector2(160.0, 0.0)

var _cruzada: bool = false
var _jugador: Jugador = null
# Ticks que faltan para cambiar de sala mientras la pantalla funde a negro y sigue en negro.
var _ticks_para_cambiar: int = 0


func _ready() -> void:
	Capas.poner(self, Capas.INTERACCION, Capas.JUGADOR)
	body_entered.connect(_al_entrar)


func _al_entrar(cuerpo: Node2D) -> void:
	if _cruzada or not cuerpo is Jugador:
		return
	_cruzada = true
	_jugador = cuerpo as Jugador
	_ticks_para_cambiar = Fundido.TICKS_OSCURECER + Fundido.TICKS_EN_NEGRO_PUERTA
	Eventos.fundido_pedido.emit(Fundido.TICKS_OSCURECER, Fundido.TICKS_EN_NEGRO_PUERTA, 0)


func _physics_process(_delta: float) -> void:
	if _ticks_para_cambiar == 0:
		return
	_ticks_para_cambiar -= 1
	if _ticks_para_cambiar == 0:
		# Si murio mientras fundia a negro, manda la muerte: la sala lo hace reaparecer.
		if _jugador.muerto:
			return
		Sala.puerta_llegada = puerta_destino
		Sala.cambio_pedido_ms = Time.get_ticks_msec()
		# Diferido: no se cambia de escena dentro de una llamada de la fisica.
		get_tree().change_scene_to_file.call_deferred(Sala.ruta_de(sala_destino))
