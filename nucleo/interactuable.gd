class_name Interactuable
extends Area2D
# Base de lo que se usa con interactuar estando encima (Npc, reto, mochila, tienda, estacion, banco, entrega,
# puerta): la capa, si el jugador esta cerca, el disparador en el tick (la misma regla para todos: Jugador.encima_de y
# sin congelado), la caja de dialogo que se corta con un golpe y el dibujo provisional con su triangulo de aviso. Cada
# clase pone lo suyo en los ganchos.

const COLOR_AVISO: Color = Color(1.0, 1.0, 1.0, 0.9)

## Si el jugador puede interactuar ahora (y se ve el aviso) y la caja abierta; publicas para las pruebas.
var cerca: bool = false
var caja: CajaDialogo = null
## Apagado: no sigue cerca ni dibuja aviso; solo mira encima_de al pulsar interactuar.
var con_aviso: bool = true

var _jugador: Jugador = null


func _ready() -> void:
	Capas.poner(self, Capas.INTERACCION, Capas.JUGADOR)


func _physics_process(_delta: float) -> void:
	if caja != null:
		if not is_instance_valid(_jugador) or not _jugador.hablando or _jugador.muerto:
			_cerrar_caja()
		return
	if not _puede_interactuar():
		return
	if not con_aviso:
		if Input.is_action_just_pressed(&"interactuar") and not Congelado.activo():
			var encima: Jugador = Jugador.encima_de(self)
			if encima != null:
				_al_interactuar(encima)
		return
	var jugador: Jugador = Jugador.encima_de(self)
	if (jugador != null) != cerca:
		cerca = jugador != null
		queue_redraw()
	if jugador != null and Input.is_action_just_pressed(&"interactuar") and not Congelado.activo():
		_al_interactuar(jugador)


## Verdadero si no hay ningun CanvasItem hijo (fuera de las formas): el arte que lo reemplaza apaga lo provisional.
func sin_arte() -> bool:
	for hijo: Node in get_children():
		if hijo is CanvasItem and not hijo is CollisionShape2D:
			return false
	return true


## El rectangulo provisional (ancho x alto, con los pies en el origen) si no hay arte.
func dibujar_provisional(ancho: float, alto: float, color: Color) -> void:
	if sin_arte():
		draw_rect(Rect2(-ancho / 2.0, -alto, ancho, alto), color)


## El triangulo de aviso con la punta altura px arriba del origen, si el jugador esta cerca (con arte o sin el).
func dibujar_aviso(altura: float) -> void:
	if cerca:
		var punta: Vector2 = Vector2(0.0, -altura)
		draw_colored_polygon(PackedVector2Array([punta + Vector2(-20.0, -28.0), punta + Vector2(20.0, -28.0), punta]), COLOR_AVISO)


# Gancho: el jugador encima pulso interactuar.
func _al_interactuar(_jugador_encima: Jugador) -> void:
	pass


# Gancho: falso mientras no se puede interactuar (ya usado, un menu abierto); corre despues de vigilar la caja.
func _puede_interactuar() -> bool:
	return true


# Gancho: la caja termino (contar: llego al final o a FIN).
func _al_terminar(_contar: bool) -> void:
	_cerrar_caja()


# La forma de colision para quien no la trae en su escena: una caja con los pies en el origen.
func _crear_forma(ancho: float, alto: float) -> void:
	var forma: CollisionShape2D = CollisionShape2D.new()
	var caja_forma: RectangleShape2D = RectangleShape2D.new()
	caja_forma.size = Vector2(ancho, alto)
	forma.shape = caja_forma
	forma.position = Vector2(0.0, -alto / 2.0)
	add_child(forma)


# Deja al jugador quieto y abre una CajaDialogo (nodo Caja) con la ficha; al_elegir recibe opcion_elegida.
func _abrir_caja(jugador: Jugador, ficha: FichaDialogo, al_elegir: Callable = Callable()) -> void:
	_jugador = jugador
	jugador.empezar_a_hablar()
	cerca = false
	queue_redraw()
	caja = CajaDialogo.new()
	caja.name = "Caja"
	caja.ficha = ficha
	if al_elegir.is_valid():
		caja.opcion_elegida.connect(al_elegir)
	caja.terminada.connect(_al_terminar)
	add_child(caja)


# Suelta al jugador y libera la caja. Tambien la corta: un golpe, un peligro o morir.
func _cerrar_caja() -> void:
	if is_instance_valid(_jugador):
		_jugador.dejar_de_hablar()
	_jugador = null
	if caja != null:
		# Sin ficha, la caja ya no procesa: liberada en este tick, todavia correria despues de este nodo y una
		# pulsacion del mismo tick terminaria contando la conversacion que el golpe corto.
		caja.ficha = null
		caja.queue_free()
		caja = null
