extends DatosComportamiento
# Ajustes del comportamiento de la Cucaracha: cuando se entierra, cuanto dura cada estado y con que margen busca
# el suelo para salir. Van en un recurso y no en constantes para ajustarlos por ficha o por ejemplar.
# El comportamiento solo lee este recurso; no lo modifica durante la ejecucion.

## Distancia al jugador, en px, a la que deja de caminar y se entierra.
@export var radio_alerta: float = 280.0
## Ticks enterrada (invisible, sin danar ni recibir golpes) antes del aviso.
@export var ticks_enterrada: int = 30
## Ticks del aviso de polvo antes de salir; es el tiempo que tiene el jugador para esquivar.
@export var ticks_aviso: int = 60
## Ticks quieta despues de salir, antes de volver a caminar.
@export var ticks_recuperacion: int = 120
## Pausa ante una pared o una orilla antes de voltearse, igual que el caminante.
@export var ticks_giro: int = 18
## Px sobre el punto de salida desde donde bajan y suben los rayos que buscan suelo y espacio; evita empezar
## dentro del suelo.
@export var margen_suelo: float = 8.0
