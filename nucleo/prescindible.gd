class_name Prescindible
extends Node
# Marca de decoracion prescindible: hijo de un emisor de particulas, una capa lejana, un cortable de mas o
# cualquier adorno. En modo bajo de recursos (Recursos.bajos) quita a su padre al entrar a la sala; en alto no
# hace nada. Nunca se pone en un aviso de peligro ni en algo con colision que importe.


func _ready() -> void:
	var padre: Node = get_parent()
	if Recursos.bajos() and padre != null and padre != get_tree().root:
		padre.queue_free()
