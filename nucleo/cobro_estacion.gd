class_name CobroEstacion
extends CanvasLayer
# Cobro de una Estacion cerrada, como el de un asiento de Silksong: la Confirmacion compartida con la pregunta, el costo
# en su linea y Si y No centrados, el foco en Si, con el juego detenido como el menu de la tienda (un solo mecanismo:
# con el arbol en pausa los botones tactiles de juego no responden). Volver, Circulo / B, pausa y Atras de Android
# cancelan; mientras existe, la pausa no se abre (grupo pantalla_encima). Lo crea la Estacion y se libera al cerrarse.

## Se eligio Si (una vez): la Estacion cobra. El cobro ya se cerro.
signal pagar_pedido()
## Cerrado, con Si o sin pagar.
signal cerrado()

## La misma capa que la pausa, la tienda y el menu de estaciones: nunca hay dos abiertos a la vez.
const CAPA: int = 20

## Lo que se pregunta y lo que cuesta; los pone la Estacion antes de agregarlo.
var texto_pregunta: String = ""
var texto_cantidad: String = ""
## Publica para las pruebas.
var confirmacion: Confirmacion = null


func _ready() -> void:
	layer = CAPA
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_physics_priority = MarcoMenus.PRIORIDAD_FISICA
	add_to_group(MarcoMenus.GRUPO)
	var fondo: ColorRect = Tema.fondo_menu()
	add_child(fondo)
	confirmacion = Confirmacion.new()
	confirmacion.name = "Confirmacion"
	confirmacion.alfa_velo = 0.0
	confirmacion.variacion_pregunta = Tema.DESTACADA
	confirmacion.variacion_boton = Tema.OPCION_CENTRADA
	confirmacion.confirmada.connect(_al_si)
	confirmacion.cancelada.connect(cerrar)
	fondo.add_child(confirmacion)
	get_tree().paused = true
	confirmacion.abrir(texto_pregunta, "Sí", "No", Confirmacion.Foco.SI, texto_cantidad)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"volver") or Input.is_action_just_pressed(&"pausa"):
		atras()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_GO_BACK_REQUEST:
		atras()


## La pausa no se abre con el cobro a la vista (ni en el tick en que se cierra: sigue en el arbol).
func bloquea_pausa() -> bool:
	return true


## Como No: cierra sin cobrar.
func atras() -> void:
	if confirmacion.visible:
		confirmacion.cancelar()
	else:
		cerrar()


func cerrar() -> void:
	if is_queued_for_deletion():
		return
	confirmacion.cerrar()
	get_tree().paused = false
	cerrado.emit()
	queue_free()


func _al_si() -> void:
	cerrar()
	pagar_pedido.emit()
