class_name CobroEstacion
extends ModalPausa
# Cobro de una Estacion cerrada, como el de un asiento de Silksong: la Confirmacion compartida con la pregunta, el costo
# en su linea y Si y No centrados, el foco en Si, con el juego detenido como el menu de la tienda (un solo mecanismo:
# con el arbol en pausa los botones tactiles de juego no responden). Volver, Circulo / B, pausa y Atras de Android
# cancelan; mientras existe, la pausa no se abre (grupo pantalla_encima). Lo crea la Estacion y se libera al cerrarse.

## Se eligio Si (una vez): la Estacion cobra. El cobro ya se cerro.
signal pagar_pedido()


## Lo que se pregunta y lo que cuesta; los pone la Estacion antes de agregarlo.
var texto_pregunta: String = ""
var texto_cantidad: String = ""
## Publica para las pruebas.
var confirmacion: Confirmacion = null


func _ready() -> void:
	super()
	var fondo: ColorRect = Tema.fondo_menu()
	add_child(fondo)
	confirmacion = _crear_confirmacion()
	confirmacion.confirmada.connect(_al_si)
	confirmacion.cancelada.connect(cerrar)
	fondo.add_child(confirmacion)
	get_tree().paused = true
	confirmacion.abrir(texto_pregunta, "Sí", "No", Confirmacion.Foco.SI, texto_cantidad)


## Como No: cierra sin cobrar.
func atras() -> void:
	if confirmacion.visible:
		confirmacion.cancelar()
	else:
		cerrar()


func _al_si() -> void:
	cerrar()
	pagar_pedido.emit()


func _antes_de_cerrar() -> void:
	confirmacion.cerrar()
