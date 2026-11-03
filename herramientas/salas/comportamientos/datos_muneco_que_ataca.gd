extends DatosComportamiento
# Ajustes del comportamiento muneco_que_ataca de pruebas, editables por ficha o por ejemplar.
# Conserva los valores por omision para que las salas sin datos sigan funcionando igual.
# El comportamiento solo lee este recurso; no lo modifica durante la ejecucion.

@export var ciclo: int = 120
@export var aviso: int = 30
@export var golpe: int = 12
## Golpe relativo a los pies del muneco, mirando a la izquierda.
@export var rectangulo_golpe: Rect2 = Rect2(-140.0, -100.0, 100.0, 80.0)
@export var salida_disparo: Vector2 = Vector2(-60.0, -60.0)
