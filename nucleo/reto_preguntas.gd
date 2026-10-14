class_name RetoPreguntas
extends Area2D
# Reto de preguntas: con el jugador encima y en el suelo, interactuar abre una CajaDialogo con las preguntas que
# faltan de la ronda, cada una seguida de si acerto. Cada respuesta cuenta y autoguarda; al acabar la ronda con
# meta aciertos se gana (la recompensa, una sola vez) y si no, la ronda empieza otra vez. El estado son numeros en
# el estado de su sala (sin cambiar el guardado). Va como hijo directo de una sala.

signal respondida(acerto: bool)
signal ganado

const ANCHO: float = 160.0
const ALTO: float = 100.0
const COLOR: Color = Color(0.7, 0.55, 0.3, 1.0)
const COLOR_AVISO: Color = Color(1.0, 1.0, 1.0, 0.9)
## Punta del aviso: arriba del jugador, que es mas alto que el atril (con 100 px quedaba tapado).
const ALTURA_AVISO: float = 184.0

## Id unico en la sala: su estado se guarda como <id>, <id>_indice y <id>_aciertos. No empieza con "coleccionable"
## ni "entregado_".
@export var id: String = ""
## Quien habla en la caja.
@export var quien: String = ""
## En el orden en que se preguntan.
@export var preguntas: Array[FichaPregunta] = []
## Aciertos de una ronda para ganar (de 1 al numero de preguntas).
@export var meta: int = 1
## Se entrega al ganar, una sola vez; puede faltar.
@export var recompensa: Recompensa = null
## Lo que dice al acertar una pregunta.
@export var texto_correcto: String = "¡Correcto!"
## %s es la respuesta correcta.
@export var texto_incorrecto: String = "No. Era: %s."
## Lo que dice al llegar a la meta; la recompensa ya se entrego al responder.
@export var texto_ganaste: String = "¡Lo lograste! Toma."
## %d: aciertos, preguntas y meta.
@export var texto_otra_vez: String = "Acertaste %d de %d; hacen falta %d. Empieza otra vez."
## Lo que dice si se vuelve a hablar despues de ganar.
@export var texto_ganado: String = "Ya respondiste todo."

## Pregunta de la ronda que sigue, aciertos de la ronda y si ya se gano; publicas para las pruebas y los guiones.
var indice: int = 0
var aciertos: int = 0
var gano: bool = false
var cerca: bool = false
var caja: CajaDialogo = null

var _jugador: Jugador = null
var _ficha: FichaDialogo = null
# Aciertos con que acabo la ultima ronda (al perderla, aciertos ya volvio a 0).
var _aciertos_al_acabar: int = 0


func _ready() -> void:
	Capas.poner(self, Capas.INTERACCION, Capas.JUGADOR)
	var clave: String = Sala.clave_de(self)
	gano = Partida.estado_de(clave, id) == true
	indice = Partida.estado_entero(clave, id + "_indice", 0)
	aciertos = Partida.estado_entero(clave, id + "_aciertos", 0)
	# Si cambiaron las preguntas y lo guardado ya no cabe, la ronda empieza otra vez.
	if indice < 0 or indice >= preguntas.size() or aciertos < 0 or aciertos > indice:
		indice = 0
		aciertos = 0


func _physics_process(_delta: float) -> void:
	if caja != null:
		if not is_instance_valid(_jugador) or not _jugador.hablando or _jugador.muerto:
			_cerrar()
		return
	var jugador: Jugador = Jugador.encima_de(self)
	if (jugador != null) != cerca:
		cerca = jugador != null
		queue_redraw()
	if jugador != null and Input.is_action_just_pressed(&"interactuar") and not Congelado.activo():
		_empezar(jugador)


## La pregunta que toca; null si ya se gano o no hay preguntas.
func pregunta_actual() -> FichaPregunta:
	if gano or indice >= preguntas.size():
		return null
	return preguntas[indice]


## Responde la pregunta que toca, cuenta, autoguarda y, al acabar la ronda, gana o la empieza otra vez. Devuelve si
## acerto. Publica para la prueba; en el juego la llama la caja al elegir una opcion.
func responder(opcion: int) -> bool:
	var pregunta: FichaPregunta = pregunta_actual()
	if pregunta == null:
		return false
	var acerto: bool = opcion == pregunta.correcta
	indice += 1
	if acerto:
		aciertos += 1
	var ronda_acabada: bool = indice >= preguntas.size()
	var gano_ahora: bool = ronda_acabada and aciertos >= meta
	var clave: String = Sala.clave_de(self)
	if ronda_acabada:
		_aciertos_al_acabar = aciertos
	if gano_ahora:
		gano = true
		Partida.marcar(clave, id, true)
	elif ronda_acabada:
		indice = 0
		aciertos = 0
	Partida.marcar(clave, id + "_indice", indice)
	Partida.marcar(clave, id + "_aciertos", aciertos)
	if gano_ahora and recompensa != null:
		Partida.dar_recompensa(recompensa)
	Partida.autoguardar()
	respondida.emit(acerto)
	if gano_ahora:
		ganado.emit()
	return acerto


func _empezar(jugador: Jugador) -> void:
	_ficha = _armar_ficha()
	if _ficha.lineas.is_empty():
		return
	_jugador = jugador
	jugador.empezar_a_hablar()
	cerca = false
	queue_redraw()
	caja = CajaDialogo.new()
	caja.name = "Caja"
	caja.ficha = _ficha
	caja.opcion_elegida.connect(_al_elegir)
	caja.terminada.connect(_al_terminar)
	add_child(caja)


# Por cada pregunta que falta, su linea y una de respuesta (se escribe al elegir); al final, una para el resultado.
# Ya ganado, solo texto_ganado. Es una ficha nueva cada vez: cambiarle el texto no toca ningun .tres.
func _armar_ficha() -> FichaDialogo:
	var ficha: FichaDialogo = FichaDialogo.new()
	if gano:
		ficha.lineas.append(_linea(texto_ganado))
		return ficha
	for k: int in range(indice, preguntas.size()):
		var pregunta: FichaPregunta = preguntas[k]
		var linea: LineaDialogo = _linea(pregunta.pregunta)
		linea.opciones = pregunta.opciones.duplicate()
		var respuesta: int = ficha.lineas.size() + 1
		for i: int in range(pregunta.opciones.size()):
			linea.destinos.append(respuesta)
		ficha.lineas.append(linea)
		ficha.lineas.append(_linea(""))
	ficha.lineas.append(_linea(""))
	return ficha


func _linea(texto: String) -> LineaDialogo:
	var linea: LineaDialogo = LineaDialogo.new()
	linea.quien = quien
	linea.texto = texto
	return linea


# Antes de que la caja pase a la linea de respuesta: cuenta y escribe que salio.
func _al_elegir(linea: int, opcion: int) -> void:
	var pregunta: FichaPregunta = pregunta_actual()
	if pregunta == null:
		return
	var acerto: bool = responder(opcion)
	var texto: String = texto_correcto if acerto else texto_incorrecto % pregunta.opciones[pregunta.correcta]
	_ficha.lineas[linea + 1].texto = texto
	if indice == 0 or gano:
		var resultado: String = texto_ganaste if gano else texto_otra_vez % [_aciertos_al_acabar, preguntas.size(), meta]
		_ficha.lineas[_ficha.lineas.size() - 1].texto = resultado


func _al_terminar(_contar: bool) -> void:
	_cerrar()


func _cerrar() -> void:
	if is_instance_valid(_jugador):
		_jugador.dejar_de_hablar()
	_jugador = null
	if caja != null:
		# Sin ficha, la caja ya no procesa: liberada en este tick, todavia correria despues de este nodo y una
		# pulsacion del mismo tick terminaria contando la conversacion que el golpe corto.
		caja.ficha = null
		caja.queue_free()
		caja = null


# Forma provisional: un atril y, si se puede hablar, un triangulo encima.
func _draw() -> void:
	draw_rect(Rect2(-ANCHO / 2.0, -ALTO, ANCHO, ALTO), COLOR)
	if cerca:
		var punta: Vector2 = Vector2(0.0, -ALTURA_AVISO)
		draw_colored_polygon(PackedVector2Array([punta + Vector2(-20.0, -28.0), punta + Vector2(20.0, -28.0), punta]), COLOR_AVISO)
