extends Button
# Boton «Volver al menu» de la caja gris: la caja no es una sala y no tiene pausa, asi que sin
# el boton solo se salia cerrando la app. Sin foco, para que Espacio o Enter no lo activen
# mientras se juega con el teclado; solo responde al toque o al clic.


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	pressed.connect(_volver_al_menu)


func _volver_al_menu() -> void:
	get_tree().change_scene_to_file(MenuPrincipal.RUTA)
