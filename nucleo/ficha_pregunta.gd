class_name FichaPregunta
extends Resource
# Una pregunta de opcion multiple de un RetoPreguntas: el texto, sus opciones y cual es la correcta. Es dato: se
# escribe sin tocar el nucleo. Caben 3 opciones porque se muestran en la fila de opciones de CajaDialogo.

const MIN_OPCIONES: int = 2

@export_multiline var pregunta: String = ""
@export var opciones: Array[String] = []
## Indice de la opcion correcta dentro de opciones.
@export var correcta: int = 0


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
