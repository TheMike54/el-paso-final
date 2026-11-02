extends DatosComportamiento
# Ajustes del comportamiento volador de pruebas, editables por ficha o por ejemplar.
# Conserva los valores por omision para que las salas sin datos sigan funcionando igual.
# El comportamiento solo lee este recurso; no lo modifica durante la ejecucion.

## Distancia a la que despierta, en px (7,6 u de Hollow Knight).
@export var radio_alerta: float = 330.0
## Aceleracion por eje al perseguir, en px/s^2: llega al tope en 1 s (en Hollow Knight, 2,25 u/s^2 = 98 px/s^2,
## tardaba 2,2 s y en el telefono se sintio lento).
@export var aceleracion: float = 217.0
## Rapidez maxima por eje al perseguir, en px/s (5 u/s).
@export var tope: float = 217.0
## Ticks sin ver al jugador antes de olvidarlo (10 s).
@export var ticks_olvido: int = 600
## Zumbido en su sitio: aceleracion, tope y distancia a la que se queda dando vueltas.
@export var aceleracion_zumbido: float = 60.0
@export var tope_zumbido: float = 60.0
@export var radio_zumbido: float = 24.0
