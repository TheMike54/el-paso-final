class_name DatosComportamiento
extends Resource
# Base de los numeros de un comportamiento de enemigo (radio, tiempos, rapidez): cada comportamiento hereda de aqui
# una clase con sus @export y los lee de ella, no de constantes. Los trae la ficha (los del tipo) o el Enemigo de la
# sala (los de ese ejemplar), asi dos enemigos del mismo tipo pueden ser distintos. Solo lectura en ejecucion: la
# misma copia la comparten todos los que la nombran (tutorials/scripting/resources.rst:30).
