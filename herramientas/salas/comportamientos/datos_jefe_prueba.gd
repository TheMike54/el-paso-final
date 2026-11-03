# Numeros del jefe de caja gris, editables por ficha o por ejemplar.
# Separa las esperas y velocidades de la logica para ajustar la pelea en el telefono.
# El recurso es compartido y de solo lectura, como los datos del caminante.
extends DatosComportamiento

@export var factor_segunda_fase: float = 1.6
@export var velocidad_embestida: float = 540.0
@export var ticks_entre_embestidas: int = 120
@export var ticks_aviso: int = 30
@export var ticks_embestida: int = 30
