class_name FichaSonidos
extends Resource
# Que efecto suena con cada evento del bus: datos, no codigo. Sonido toca lo que diga; hoy usa la de prueba de
# nucleo/sonidos/ (donde vivira la del juego esta por decidir). Un evento sin efecto no suena. Efectos en WAV: se
# tocan sin decodificar, lo barato para la gama baja.

## Efecto al saltar.
@export var salto: AudioStream = null
## Efecto al pegarle a algo.
@export var golpe: AudioStream = null
## Efecto al recibir dano.
@export var dano: AudioStream = null
## Efecto al parar un ataque.
@export var parry: AudioStream = null
## Efecto al curarse.
@export var curar: AudioStream = null
## Efecto al sentarse en un banco.
@export var banco: AudioStream = null
## Efecto al romperse un muro rompible. Vacio mientras no haya archivo.
@export var muro_roto: AudioStream = null
## Efecto al empezar a abrirse un porton. Vacio mientras no haya archivo.
@export var porton: AudioStream = null
## Tono de cada evento (1 = el del archivo); con dos sonidos de prueba, el tono los distingue.
@export var tonos: Dictionary[StringName, float] = {}
## El tono de cada vez sale entre tono - variacion_tono y tono + variacion_tono: repetido no suena igual.
@export_range(0.0, 0.3) var variacion_tono: float = 0.06


func efecto(evento: StringName) -> AudioStream:
	return get(evento) as AudioStream


## Nombres de los campos de efecto (los AudioStream): los eventos que esta ficha puede tener.
func campos_de_efecto() -> Array[StringName]:
	var campos: Array[StringName] = []
	for propiedad: Dictionary in get_property_list():
		var clase: String = propiedad["class_name"]
		if clase == "AudioStream":
			var nombre: String = propiedad["name"]
			campos.append(StringName(nombre))
	return campos


func tono(evento: StringName) -> float:
	return tonos.get(evento, 1.0)
