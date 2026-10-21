class_name Mochila
extends Interactuable
# Lo perdido al morir (Partida.mochila), en el ultimo punto seguro de su sala: la crea la Sala al entrar si la
# mochila es suya. Con el jugador encima, interactuar abre un reto con preguntas al azar de la bolsa: es una sola
# oportunidad. Con la meta devuelve las PejeCoins; sin ella se pierden. En los dos casos desaparece. Sin bolsa basta
# interactuar. Caja gris hasta que tenga arte: un CanvasItem hijo la deja de dibujar, como el Porton.

const ANCHO: float = 80.0
const ALTO: float = 80.0
const COLOR: Color = Color(0.55, 0.45, 0.3, 1.0)
const ALTURA_AVISO: float = 184.0
## La bolsa del juego; si no existe, sin reto. La sala de prueba Lo Perdido le pone la suya al crearla.
const BOLSA_JUEGO: String = "res://contenido/preguntas_mochila.tres"
const QUIEN: String = "Lo perdido"
const TEXTO_EMPEZAR: String = "Tu mochila, con %d PejeCoins. Para recuperarla, responde."
## %d: el monto.
const TEXTO_GANASTE: String = "Recuperaste %d PejeCoins."
## %d: aciertos, preguntas y meta.
const TEXTO_PERDISTE: String = "Acertaste %d de %d; hacían falta %d. Lo perdido se fue."

## De donde se sortean las preguntas; null: se recupera al interactuar. Publica para la prueba.
var bolsa: BolsaPreguntas = null
## Indices en la bolsa de las preguntas del intento en curso (o del ultimo), y aciertos del intento.
var sorteadas: Array[int] = []
var aciertos: int = 0
## Respondidas del intento en curso.
var respondidas: int = 0
var recuperada: bool = false
## Se perdio el reto: lo perdido se fue y la mochila desaparece al cerrar la caja.
var perdida: bool = false

var _ficha: FichaDialogo = null
var _azar: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	super()
	_crear_forma(ANCHO, ALTO)
	_azar.randomize()
	if ResourceLoader.exists(BOLSA_JUEGO):
		bolsa = load(BOLSA_JUEGO) as BolsaPreguntas


func _puede_interactuar() -> bool:
	return not (recuperada or perdida)


func _al_interactuar(jugador: Jugador) -> void:
	empezar(jugador)


## Empieza un intento: sin bolsa (o sin preguntas que alcancen), recupera enseguida; si no, sortea y abre la caja.
## Publica para la prueba; en el juego la llama interactuar.
func empezar(jugador: Jugador) -> void:
	if bolsa == null or not bolsa.fallos().is_empty():
		_recuperar()
		return
	sortear()
	_ficha = _armar_ficha()
	_abrir_caja(jugador, _ficha, _al_elegir)


## Sortea las preguntas del intento. Si la bolsa tiene al menos el doble de preguntas_por_reto, no repite ninguna del
## intento anterior (el que corto un golpe); con menos, puede repetir.
func sortear() -> void:
	var candidatas: Array[int] = []
	var sin_repetir: bool = bolsa.preguntas.size() >= bolsa.preguntas_por_reto * 2
	for i: int in range(bolsa.preguntas.size()):
		if not (sin_repetir and sorteadas.has(i)):
			candidatas.append(i)
	sorteadas.clear()
	for _k: int in range(bolsa.preguntas_por_reto):
		var elegida: int = _azar.randi_range(0, candidatas.size() - 1)
		sorteadas.append(candidatas[elegida])
		candidatas.remove_at(elegida)
	aciertos = 0
	respondidas = 0


## La pregunta que toca del intento; null si ya se respondieron todas.
func pregunta_actual() -> FichaPregunta:
	if bolsa == null or respondidas >= sorteadas.size():
		return null
	return bolsa.preguntas[sorteadas[respondidas]]


## Responde la pregunta que toca y, con la ultima, recupera si llego a la meta o la pierde si no. Devuelve si acerto.
## Publica para la prueba; en el juego la llama la caja al elegir una opcion.
func responder(opcion: int) -> bool:
	var pregunta: FichaPregunta = pregunta_actual()
	if pregunta == null:
		return false
	var acerto: bool = opcion == pregunta.correcta
	respondidas += 1
	if acerto:
		aciertos += 1
	if respondidas >= sorteadas.size():
		if aciertos >= bolsa.meta:
			_recuperar()
		else:
			_perder()
	return acerto


# Una linea de entrada, cada pregunta con su linea de respuesta (se escribe al elegir) y una al final para el resultado.
func _armar_ficha() -> FichaDialogo:
	var ficha: FichaDialogo = FichaDialogo.new()
	ficha.lineas.append(LineaDialogo.nueva(QUIEN, TEXTO_EMPEZAR % Partida.monto_mochila()))
	for indice: int in sorteadas:
		ficha.lineas.append_array(bolsa.preguntas[indice].lineas_para(QUIEN, ficha.lineas.size()))
	ficha.lineas.append(LineaDialogo.nueva(QUIEN, ""))
	return ficha


# Antes de que la caja pase a la linea de respuesta: cuenta y escribe que salio; con la ultima, el resultado.
func _al_elegir(linea: int, opcion: int) -> void:
	var pregunta: FichaPregunta = pregunta_actual()
	if pregunta == null:
		return
	var monto: int = Partida.monto_mochila()
	var acerto: bool = responder(opcion)
	_ficha.lineas[linea + 1].texto = pregunta.respuesta(acerto)
	if respondidas >= sorteadas.size():
		var resultado: String = TEXTO_GANASTE % monto if recuperada else TEXTO_PERDISTE % [aciertos, sorteadas.size(), bolsa.meta]
		_ficha.lineas[_ficha.lineas.size() - 1].texto = resultado


func _perder() -> void:
	perdida = true
	Partida.perder_mochila()
	queue_redraw()


func _recuperar() -> void:
	recuperada = true
	cerca = false
	Partida.recuperar_mochila()
	queue_redraw()
	if caja == null:
		queue_free()


# Al terminar o al cortarse (un golpe, un peligro o morir cortan el intento: lo respondido no cuenta y el siguiente
# sortea otra vez). Recuperada o perdida, ademas desaparece.
func _cerrar_caja() -> void:
	super()
	if recuperada or perdida:
		queue_free()


func _draw() -> void:
	if recuperada or perdida:
		return
	dibujar_provisional(ANCHO, ALTO, COLOR)
	dibujar_aviso(ALTURA_AVISO)
