extends DatosComportamiento
# Ajustes del comportamiento caminante de pruebas, editables por ficha o por ejemplar.
# Conserva los valores por omision para que las salas sin datos sigan funcionando igual.
# El comportamiento solo lee este recurso; no lo modifica durante la ejecucion.

## Pausa al llegar a una pared o una orilla antes de voltearse (Hollow Knight: 1 s).
@export var ticks_giro: int = 60
