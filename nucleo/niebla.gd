class_name Niebla
extends Node2D
# Niebla que se desliza: sus hijos (franjas translucidas) avanzan en x a velocidad px/s con tiempo propio y
# vuelven al llegar a recorrido, asi se queda quieta en la pausa y en el congelado comun. En modo bajo de
# recursos no se mueve. No colisiona ni tapa avisos de peligro: va en una capa de fondo o de frente con z_index.
# Solo se ve con el ajuste niebla (apagado por omision: cuesta 2 a 4 FPS en el S50) y lo obedece al momento. Una
# franja con material nucleo/arte/niebla_banda.gdshader se desvanece arriba y abajo: banda sin orillas.

## Grupo de las nieblas de la sala: el panel de pruebas las apaga juntas.
const GRUPO: StringName = &"nieblas_sala"

## Velocidad de las franjas, en px/s.
@export var velocidad: float = 20.0
## Distancia, en px, tras la que cada franja vuelve a su lugar.
@export var recorrido: float = 400.0

var _quieta: bool = false
var _avance: float = 0.0
var _inicio: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group(GRUPO)
	_quieta = Recursos.bajos()
	_inicio = position
	_aplicar()
	Eventos.ajuste_grafico_cambiado.connect(_al_cambiar_ajuste)


func _process(delta: float) -> void:
	if _quieta or recorrido <= 0.0 or Congelado.activo():
		return
	_avance = fmod(_avance + velocidad * delta, recorrido)
	position = _inicio + Vector2(_avance, 0.0)


# Oculta no se pinta; quieta u oculta no hace nada cada cuadro: ni se llama a _process.
func _aplicar() -> void:
	visible = Ajustes.niebla
	set_process(visible and not _quieta)


func _al_cambiar_ajuste(clave: StringName) -> void:
	if clave == Ajustes.NIEBLA:
		_aplicar()
