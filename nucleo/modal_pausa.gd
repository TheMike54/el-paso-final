# Base de tienda, cobro y estaciones: capa y entrada comunes mientras el juego espera.
# Conserva el orden de configuracion para que cerrar no adelante la entrada del jugador.
# Cada modal conserva su contenido y los pasos propios antes de quitar la pausa.
class_name ModalPausa
extends CanvasLayer

signal cerrado

## Encima del juego; compartida con PaginaMarco y con la escena de Pausa.
const CAPA: int = 20


func _ready() -> void:
	layer = CAPA
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_physics_priority = MarcoMenus.PRIORIDAD_FISICA
	add_to_group(MarcoMenus.GRUPO)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"volver") or Input.is_action_just_pressed(&"pausa"):
		atras()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		atras()


## Sigue bloqueando la pausa hasta salir del arbol, tambien en el tick de cerrar.
func bloquea_pausa() -> bool:
	return true


func atras() -> void:
	cerrar()


func cerrar() -> void:
	if is_queued_for_deletion():
		return
	_antes_de_cerrar()
	get_tree().paused = false
	_avisar_cierre()
	cerrado.emit()
	queue_free()


# Cobro cierra primero la confirmacion; los otros modales no tienen ese paso.
func _antes_de_cerrar() -> void:
	pass


# Tienda avisa al HUD despues de quitar la pausa y antes de emitir cerrado.
func _avisar_cierre() -> void:
	pass


# Misma configuracion en tienda y cobro; las conexiones y el alta quedan en cada modal.
func _crear_confirmacion() -> Confirmacion:
	var nueva: Confirmacion = Confirmacion.new()
	nueva.name = "Confirmacion"
	nueva.alfa_velo = 0.0
	nueva.variacion_pregunta = Tema.DESTACADA
	nueva.variacion_boton = Tema.OPCION_CENTRADA
	return nueva
