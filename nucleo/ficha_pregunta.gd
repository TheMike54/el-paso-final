class_name FichaPregunta
extends Resource
# Una pregunta de opcion multiple de un RetoPreguntas: el texto, sus opciones y cual es la correcta. Es dato: se
# escribe sin tocar el nucleo. Caben 3 opciones porque se muestran en la fila de opciones de CajaDialogo.

const MIN_OPCIONES: int = 2
## Lo que se dice tras acertar y tras fallar (%s es la respuesta correcta), si quien pregunta no pone otro.
const TEXTO_CORRECTO: String = "¡Correcto!"
const TEXTO_INCORRECTO: String = "No. Era: %s."

## El texto de la pregunta.
@export_multiline var pregunta: String = ""
## Entre MIN_OPCIONES y 3 respuestas, en el orden en que se muestran.
@export var opciones: Array[String] = []
## Indice de la opcion correcta dentro de opciones.
@export var correcta: int = 0


## Las dos lineas de esta pregunta en una FichaDialogo, con la pregunta en el indice en: la pregunta con sus opciones,
## todas hacia la siguiente, y la de la respuesta, vacia (se escribe al elegir, con respuesta()).
func lineas_para(quien: String, en: int) -> Array[LineaDialogo]:
	var linea: LineaDialogo = LineaDialogo.nueva(quien, pregunta)
	linea.opciones = opciones.duplicate()
	for i: int in range(opciones.size()):
		linea.destinos.append(en + 1)
	var lineas: Array[LineaDialogo] = [linea, LineaDialogo.nueva(quien, "")]
	return lineas


## El texto de la linea de respuesta: correcto si acerto; si no, incorrecto con la opcion correcta.
func respuesta(acerto: bool, correcto: String = TEXTO_CORRECTO, incorrecto: String = TEXTO_INCORRECTO) -> String:
	return correcto if acerto else incorrecto % opciones[correcta]


## Fallos de forma de la ficha (vacio si esta bien); lo usan el validador y la prueba.
func fallos() -> PackedStringArray:
	var lista: PackedStringArray = []
	if pregunta.strip_edges().is_empty():
		lista.append("pregunta sin texto")
	if opciones.size() < MIN_OPCIONES or opciones.size() > LineaDialogo.MAX_OPCIONES:
		lista.append("%d opciones (van de %d a %d)" % [opciones.size(), MIN_OPCIONES, LineaDialogo.MAX_OPCIONES])
	for i: int in range(opciones.size()):
		if opciones[i].strip_edges().is_empty():
			lista.append("opcion %d sin texto" % i)
	if correcta < 0 or correcta >= opciones.size():
		lista.append("correcta %d fuera de las opciones" % correcta)
	return lista
