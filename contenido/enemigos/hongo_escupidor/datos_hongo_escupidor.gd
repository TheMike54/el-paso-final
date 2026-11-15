extends DatosComportamiento
# Ajustes del Hongo escupidor: a que distancia ve al jugador, cuanto dura el aviso, la pausa entre tiros y el
# cierre tras un golpe, y como sale la bola en arco. Van en un recurso y no en constantes para ajustarlos por ficha
# o por ejemplar. El comportamiento solo lee este recurso; no lo modifica durante la ejecucion.

## Distancia, en px, a la que ve al jugador (con vista libre de solidos).
@export var radio: float = 900.0
## Ticks del destello antes de cada tiro.
@export var aviso: int = 30
## Ticks entre un tiro y el siguiente aviso: con el aviso, una bola cada 1,25 s.
@export var espera: int = 45
## Ticks que queda cerrado tras un golpe que conto; mientras tanto los golpes rebotan.
@export var ticks_cerrado: int = 90
## Angulo de salida sobre la horizontal.
@export var grados: float = 50.0
## Gravedad de la bola, en px/s^2.
@export var gravedad_bola: float = 1800.0
## Rapidez maxima de la bola, en px/s.
@export var tope: float = 1300.0
## Desde donde sale la bola, relativo a sus pies.
@export var salida: Vector2 = Vector2(0.0, -70.0)
