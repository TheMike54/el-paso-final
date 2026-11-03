extends "res://herramientas/pruebas/prueba_base.gd"
# Comprueba que una cinematica cuya sala de destino no carga vuelve al menu en vez de dejar al jugador sin salida.
# Fundido avisa con push_error y correr-guiones.ps1 falla con cualquier ERROR: aqui ese error es el caso, asi que
# Engine.print_error_messages lo calla solo durante el cambio. La prueba cuelga de la raiz para sobrevivir al cambio
# de escena; al final vuelve a ser la escena actual, que es la que lee el guion.

const CINEMATICA: String = "res://contenido/cinematicas/cinematica_celda.tscn"
const TICKS_CAMBIO: int = 30


func _ready() -> void:
	_probar.call_deferred()


func _probar() -> void:
	var cinematica: Cinematica = (load(CINEMATICA) as PackedScene).instantiate() as Cinematica
	cinematica.sala_destino = "no_existe"
	get_tree().root.add_child(cinematica)
	get_tree().current_scene = cinematica
	Engine.print_error_messages = false
	cinematica.ir_a_la_sala()
	await _esperar(TICKS_CAMBIO)
	Engine.print_error_messages = true
	var escena: Node = get_tree().current_scene
	_caso("una sala que no carga vuelve al menu", escena != null and escena.scene_file_path == MenuPrincipal.RUTA)
	if escena != null:
		escena.free()
	get_tree().current_scene = self
	_resumen()
