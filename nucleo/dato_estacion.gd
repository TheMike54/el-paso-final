class_name DatoEstacion
extends Resource
# Una fila de la tabla de estaciones del viaje rapido (FichaEstaciones): el id de la estacion, el nombre que sale en
# el menu de destinos y el id de la sala donde esta. Es dato: el menu lista estaciones de salas que no estan cargadas,
# asi que el nombre y la sala viven aqui y no en la Estacion.

## estacion_<id de la sala>, como el banco.
@export var id: String = ""
@export var nombre: String = ""
## Id de la sala (prueba_1), nunca una ruta.
@export var sala: String = ""
