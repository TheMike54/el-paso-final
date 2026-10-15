class_name Habilidades
extends RefCounted
# Los ids de las habilidades, en un solo lugar: el codigo usa estas constantes y no el texto escrito a mano, y el
# validador revisa que cada habilidad de una escena o una ficha este en TODAS. Son ids que se guardan en la
# partida: no se renombran. Un enum no sirve aqui, porque lo que se guarda es el texto.

## El arma: sin ella atacar no hace nada.
const PLUMA: StringName = &"pluma"
## Deja dibujar en el mapa las salas visitadas al descansar (como la Pluma de Hollow Knight).
const PLUMA_MAPA: StringName = &"pluma_mapa"
const IMPULSO: StringName = &"impulso"
const DOBLE_SALTO: StringName = &"doble_salto"
const SALTO_EN_PARED: StringName = &"salto_en_pared"
const CAIDA_EN_PICADA: StringName = &"caida_en_picada"
## La bola.
const PROYECTIL: StringName = &"proyectil"

## Todas, para el validador y para avisar de un id que no existe.
const TODAS: Array[StringName] = [PLUMA, PLUMA_MAPA, IMPULSO, DOBLE_SALTO, SALTO_EN_PARED, CAIDA_EN_PICADA, PROYECTIL]
