class_name BolsaPreguntas
extends Resource
# Bolsa de preguntas del reto de la mochila (lo perdido al morir): de aqui se sortean preguntas_por_reto en cada
# intento y se gana con meta aciertos. Es dato, una sola para todo el juego (decision del 17-oct-2026): la del juego
# va en contenido/ y el nucleo la carga solo si existe. El validador revisa su forma con fallos().

## Preguntas de donde se sortea; con el doble de preguntas_por_reto, un intento nuevo no repite las del anterior.
@export var preguntas: Array[FichaPregunta] = []
## Cuantas se preguntan en cada intento.
@export var preguntas_por_reto: int = 3
## Aciertos de un intento para recuperar la mochila (de 1 a preguntas_por_reto).
@export var meta: int = 2


## Fallos de forma de la bolsa (vacio si esta bien); lo usan el validador y la prueba.
func fallos() -> PackedStringArray:
	var lista: PackedStringArray = []
	if preguntas_por_reto < 1:
		lista.append("preguntas_por_reto %d (minimo 1)" % preguntas_por_reto)
	if preguntas.size() < preguntas_por_reto:
		lista.append("%d preguntas (hacen falta al menos %d)" % [preguntas.size(), preguntas_por_reto])
	if meta < 1 or meta > preguntas_por_reto:
		lista.append("meta %d fuera de 1 a %d" % [meta, preguntas_por_reto])
	for i: int in range(preguntas.size()):
		if preguntas[i] == null:
			lista.append("pregunta %d vacia" % i)
			continue
		for fallo: String in preguntas[i].fallos():
			lista.append("pregunta %d: %s" % [i, fallo])
	return lista
