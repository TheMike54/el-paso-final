class_name FichaDialogo
extends Resource
# Una conversacion completa y lo que se entrega la primera vez que se termina contando. Un Npc tiene una por etapa.
# Es dato: el validador revisa que las opciones y sus destinos coincidan.

## Las lineas en orden; una con opciones salta a la que diga cada opcion.
@export var lineas: Array[LineaDialogo] = []
## Se entregan con Partida.dar_recompensa; en un dialogo, Recompensa.cantidad no se usa.
@export var recompensas: Array[Recompensa] = []


## Fallos de forma de la ficha (vacio si esta bien); lo usan el validador y la prueba.
func fallos() -> PackedStringArray:
	var lista: PackedStringArray = []
	if lineas.is_empty():
		lista.append("sin lineas")
	for i: int in range(lineas.size()):
		var linea: LineaDialogo = lineas[i]
		if linea == null:
			lista.append("linea %d vacia" % i)
			continue
		if linea.texto.strip_edges().is_empty():
			lista.append("linea %d sin texto" % i)
		if linea.opciones.size() != linea.destinos.size():
			lista.append("linea %d: %d opciones y %d destinos" % [i, linea.opciones.size(), linea.destinos.size()])
		if linea.opciones.size() > LineaDialogo.MAX_OPCIONES:
			lista.append("linea %d: mas de %d opciones" % [i, LineaDialogo.MAX_OPCIONES])
		for destino: int in linea.destinos:
			if destino != LineaDialogo.FIN and destino != LineaDialogo.CANCELAR and (destino < 0 or destino >= lineas.size()):
				lista.append("linea %d: destino %d fuera de la conversacion" % [i, destino])
		for opcion: String in linea.opciones:
			if opcion.strip_edges().is_empty():
				lista.append("linea %d: opcion sin texto" % i)
	# Una recompensa vacia cortaba Npc.terminar a medias: la etapa subia y la caja quedaba abierta.
	for i: int in range(recompensas.size()):
		var recompensa: Recompensa = recompensas[i]
		if recompensa == null:
			lista.append("recompensa %d vacia" % i)
		elif recompensa.tipo in [Recompensa.Tipo.AMULETO, Recompensa.Tipo.HABILIDAD, Recompensa.Tipo.MAPA] and recompensa.id == &"":
			lista.append("recompensa %d sin id" % i)
		elif recompensa.tipo == Recompensa.Tipo.HABILIDAD and not Habilidades.TODAS.has(recompensa.id):
			lista.append("recompensa %d: %s no es una habilidad" % [i, recompensa.id])
	return lista
