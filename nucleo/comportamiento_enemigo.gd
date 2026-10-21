class_name ComportamientoEnemigo
extends Node
# Base del comportamiento de un enemigo: el script que su ficha referencia (FichaEnemigo.comportamiento) y
# que nucleo/enemigo.gd agrega como hijo sin saber cual es. Cada tipo hereda de aqui (los del juego en
# contenido/enemigos/, los de prueba en herramientas/) y escribe su logica en actuar(), que no corre durante
# el congelado comun. El cuerpo sigue danando por contacto; los ataques van aparte (atacar, disparar). Las
# ayudas de movimiento (caer, mover, pared_delante, orilla_delante, ve_al_jugador) dejan la fisica aqui y no en
# cada comportamiento.

## Largo de los rayos de pared y de orilla, mas alla del borde del cuerpo, en px.
const ALCANCE_RAYO: float = 12.0

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
	return get_tree().get_first_node_in_group(Jugador.GRUPO) as Jugador


## Suma la gravedad de la ficha a la velocidad, con su tope. Sin gravedad (vuela), no hace nada.
func caer() -> void:
	if enemigo.ficha.gravedad <= 0.0:
		return
	var delta: float = get_physics_process_delta_time()
	enemigo.velocity.y = minf(enemigo.velocity.y + enemigo.ficha.gravedad * delta, enemigo.ficha.caida_maxima)


## Mueve al enemigo con su velocity contra el escenario (move_and_slide).
func mover() -> void:
	enemigo.move_and_slide()


## Si esta apoyado en el suelo (solo el que camina: el que vuela no tiene suelo).
func en_suelo() -> bool:
	return enemigo.is_on_floor()


## Si hay un solido justo delante, a media altura, hacia sentido (-1 o 1).
func pared_delante(sentido: float) -> bool:
	var mitad: float = enemigo.ficha.tamano.x / 2.0
	var centro: Vector2 = enemigo.global_position + Vector2(0.0, -enemigo.ficha.tamano.y / 2.0)
	return _choca(centro, centro + Vector2(sentido * (mitad + ALCANCE_RAYO), 0.0))


## Si delante, hacia sentido, se acaba el suelo: el rayo baja desde la punta del pie de ese lado.
func orilla_delante(sentido: float) -> bool:
	var punta: Vector2 = enemigo.global_position + Vector2(sentido * (enemigo.ficha.tamano.x / 2.0 + 2.0), -4.0)
	return not _choca(punta, punta + Vector2(0.0, ALCANCE_RAYO + 4.0))


## Si el jugador vivo esta a menos de radio px de su centro y ningun solido tapa la vista entre los dos centros.
func ve_al_jugador(radio: float) -> bool:
	var objetivo: Jugador = jugador()
	if objetivo == null or objetivo.muerto:
		return false
	var desde: Vector2 = centro()
	var hasta: Vector2 = objetivo.global_position + Vector2(0.0, -80.0)
	return desde.distance_to(hasta) <= radio and not _choca(desde, hasta)


## Centro del cuerpo del enemigo, en coordenadas globales.
func centro() -> Vector2:
	return enemigo.global_position + Vector2(0.0, -enemigo.ficha.tamano.y / 2.0)


## Voltea hacia donde mira el enemigo.
func girar() -> void:
	enemigo.mirando = -enemigo.mirando
	enemigo.queue_redraw()


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


## Disparo en arco desde desplazamiento (relativo a sus pies) para caer en objetivo (global): sale a grados sobre
## la horizontal, con la rapidez que hace falta hasta tope px/s, y cae con gravedad_propia px/s^2. Va a la sala.
func lanzar_en_arco(desplazamiento: Vector2, objetivo: Vector2, grados: float, gravedad_propia: float, tope: float,
		dano: int, se_puede_parar: bool) -> ProyectilEnemigo:
	var salida: Vector2 = enemigo.position + desplazamiento
	var relativo: Vector2 = objetivo - (enemigo.global_position + desplazamiento)
	var inicial: Vector2 = ProyectilEnemigo.velocidad_para(relativo, grados, gravedad_propia, tope)
	var disparo: ProyectilEnemigo = ProyectilEnemigo.crear_arco(inicial, gravedad_propia, dano, se_puede_parar)
	disparo.position = salida
	enemigo.get_parent().add_child(disparo)
	return disparo


# Rayo contra el escenario: lo usan pared, orilla y vista. Solo dentro del tick (lo llama actuar).
func _choca(desde: Vector2, hasta: Vector2) -> bool:
	return not Capas.rayo_a_escenario(enemigo, desde, hasta).is_empty()
