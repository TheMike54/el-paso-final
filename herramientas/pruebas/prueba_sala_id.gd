extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de los ids de sala: Sala.ruta_de, Sala.zona_de y que una sala con id avise cambio_de_sala con su
# id. Corre los casos al entrar y deja la cuenta en "casos" y "fallos", que sala_id.guion lee con la
# clave valor. Imprime el resumen y solo los que fallan.
const PRUEBA_2: String = "res://herramientas/salas/zonas/prueba/prueba_2.tscn"

var _sala_avisada: String = ""


func _ready() -> void:
	_caso("ruta_de de un id de la zona de prueba da su escena", Sala.ruta_de("prueba_1") == "res://herramientas/salas/zonas/prueba/prueba_1.tscn")
	_caso("ruta_de de un id del juego da contenido/salas/<zona>/<id>.tscn", Sala.ruta_de("celda_1") == "res://contenido/salas/celda/celda_1.tscn")
	_caso("ruta_de deja pasar una ruta res://", Sala.ruta_de("res://herramientas/salas/sala_banco.tscn") == "res://herramientas/salas/sala_banco.tscn")
	_caso("zona_de da lo que va antes del primer guion bajo", Sala.zona_de("raices_12") == "raices")
	_caso("zona_de de una ruta es vacia", Sala.zona_de("res://herramientas/salas/sala_banco.tscn") == "")
	# Una sala con id que recibe al jugador por una puerta avisa cambio_de_sala con su id, no con su ruta.
	Eventos.cambio_de_sala.connect(_al_cambiar_de_sala)
	Sala.puerta_llegada = &"izquierda"
	var sala: Sala = (load(PRUEBA_2) as PackedScene).instantiate() as Sala
	add_child(sala)
	_caso("cambio_de_sala lleva el id de la sala", _sala_avisada == "prueba_2")
	_caso("clave() de una sala con id es su id", sala.clave() == "prueba_2")
	Eventos.cambio_de_sala.disconnect(_al_cambiar_de_sala)
	sala.free()
	_resumen()


func _al_cambiar_de_sala(sala: String, _puerta: StringName) -> void:
	_sala_avisada = sala
