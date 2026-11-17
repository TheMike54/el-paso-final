extends DatosComportamiento
# Ajustes de la polilla, editables por ficha o por ejemplar. Parte de datos_volador.gd.
# Los valores son los del volador de pruebas; se ajustan jugando en su sala de prueba.
# El comportamiento solo lee este recurso; no lo modifica durante la ejecucion.

## Distancia a la que despierta, en px.
@export var radio_alerta: float = 330.0
## Aceleracion por eje al perseguir, en px/s^2: llega al tope en 1 s.
@export var aceleracion: float = 217.0
## Rapidez maxima por eje al perseguir, en px/s.
@export var tope: float = 217.0
## Ticks sin ver al jugador antes de olvidarlo (10 s).
@export var ticks_olvido: int = 600
## Zumbido en su sitio: aceleracion, tope y distancia a la que se queda dando vueltas.
@export var aceleracion_zumbido: float = 60.0
@export var tope_zumbido: float = 60.0
@export var radio_zumbido: float = 24.0
