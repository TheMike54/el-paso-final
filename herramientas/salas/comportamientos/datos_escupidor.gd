extends DatosComportamiento
# Ajustes del comportamiento escupidor de pruebas, editables por ficha o por ejemplar.
# Conserva los valores por omision para que las salas sin datos sigan funcionando igual.
# El comportamiento solo lee este recurso; no lo modifica durante la ejecucion.

@export var radio: float = 900.0
@export var aviso: int = 30
## Ticks entre un tiro y el siguiente aviso: una bola cada 1,25 s (con 90, cada 2 s, se esquivaba muy facil en el
## telefono).
@export var espera: int = 45
## Angulo de salida sobre la horizontal.
@export var grados: float = 50.0
## Gravedad de la bola: 0,7 de la de Hollow Knight (60 u/s^2 a 43 px/u).
@export var gravedad_bola: float = 1800.0
@export var tope: float = 1300.0
@export var salida: Vector2 = Vector2(0.0, -70.0)
