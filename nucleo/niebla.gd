class_name Niebla
extends Node2D
# Desliza franjas hijas en x y las devuelve al completar recorrido; usa tiempo propio para parar con pausa y congelado.
# Queda inmovil en recursos bajos; el ajuste niebla responde al momento y empieza apagado por costar 2 a 4 FPS en S50.
# Va al fondo o al frente con z_index, sin colision ni tapar avisos de peligro.
# El material nucleo/arte/niebla_banda.gdshader desvanece arriba y abajo para evitar orillas visibles en la franja.

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
	Eventos.ajuste_cambiado.connect(_al_cambiar_ajuste)


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
