class_name Puerta
extends Area2D
# Puerta entre salas: cuando el jugador entra en su area, cambia a la sala destino y le dice
# a esa sala en que puerta debe aparecer. Va como hija directa de la raiz de una sala; la
# sala destino busca la puerta por su id y pone al jugador en su punto de llegada.

## Id de la puerta, unico dentro de su sala.
@export var id: StringName = &""
## Escena de la sala a la que lleva.
@export_file("*.tscn") var sala_destino: String = ""
## Id de la puerta de la sala destino donde aparece el jugador.
@export var puerta_destino: StringName = &""
## Donde aparece el jugador al llegar por esta puerta, relativo a ella. Fuera de su area, para no rebotar.
@export var llegada: Vector2 = Vector2(160.0, 0.0)

var _cruzada: bool = false


func _ready() -> void:
	body_entered.connect(_al_entrar)


func _al_entrar(cuerpo: Node2D) -> void:
	if _cruzada or not cuerpo is Jugador:
		return
	_cruzada = true
	Sala.puerta_llegada = puerta_destino
	# Diferido: no se cambia de escena dentro de una llamada de la fisica.
	get_tree().change_scene_to_file.call_deferred(sala_destino)
