class_name FichaZona
extends Resource
# Datos comunes de una zona para el mapa: nombre visible, color y origen de sus salas en el mapa.
# Se asigna en la base de zona para que todas sus salas compartan el mismo recurso.
# El indice copia estos datos: el mapa no necesita cargar el contenido de la zona.

@export var nombre: String = ""
@export var color: Color = Color(0.45, 0.55, 0.65)
@export var origen_mapa: Vector2 = Vector2.ZERO
