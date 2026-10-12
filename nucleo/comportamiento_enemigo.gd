class_name ComportamientoEnemigo
extends Node
# Base del comportamiento de un enemigo: el script que su ficha referencia (FichaEnemigo.comportamiento) y
# que nucleo/enemigo.gd agrega como hijo sin saber cual es. Cada tipo hereda de aqui (los del juego en
# contenido/enemigos/, los de prueba en herramientas/) y escribe su logica en actuar(), que no corre durante
# el congelado comun. El cuerpo sigue danando por contacto; los ataques van aparte (atacar, disparar).

## El enemigo que lo lleva; lo fija nucleo/enemigo.gd antes de agregarlo.
var enemigo: Enemigo = null


func _physics_process(_delta: float) -> void:
	if enemigo == null or Congelado.activo():
		return
	actuar()


## Un tick de logica del enemigo. La sobrescribe cada comportamiento.
func actuar() -> void:
	pass


## El jugador de la sala, o null.
func jugador() -> Jugador:
	return get_tree().get_first_node_in_group(&"jugador") as Jugador


## Ataque separado del cuerpo, hijo del enemigo: un rectangulo relativo a sus pies que dana durante ticks.
func atacar(rectangulo: Rect2, ticks: int, dano: int, se_puede_parar: bool) -> AtaqueEnemigo:
	var ataque: AtaqueEnemigo = AtaqueEnemigo.crear(rectangulo, ticks, dano, se_puede_parar)
	enemigo.add_child(ataque)
	return ataque


## Disparo que sale del enemigo (desde desplazamiento, relativo a sus pies) en la direccion dada. Va a la sala,
## no al enemigo: sigue su camino aunque el enemigo se mueva o lo venzan.
func disparar(desplazamiento: Vector2, direccion: Vector2, dano: int, se_puede_parar: bool) -> ProyectilEnemigo:
	var disparo: ProyectilEnemigo = ProyectilEnemigo.crear_disparo(direccion, dano, se_puede_parar)
	disparo.position = enemigo.position + desplazamiento
	enemigo.get_parent().add_child(disparo)
	return disparo
