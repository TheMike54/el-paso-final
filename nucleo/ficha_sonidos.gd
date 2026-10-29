class_name FichaSonidos
extends Resource
# Que efecto suena con cada evento del bus: datos, no codigo. Sonido toca lo que diga; la del juego es
# nucleo/sonidos/sonidos_jugador.tres. Un evento sin efecto no suena. Efectos en WAV: se tocan sin decodificar, lo
# barato para la gama baja. La variacion de tono es dato del propio efecto: un AudioStreamRandomizer en lugar del WAV.

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
## Efecto al romperse un muro rompible.
@export var muro_roto: AudioStream = null
## Efecto al empezar a abrirse un porton.
@export var porton: AudioStream = null
## Efecto de cada paso al caminar o correr.
@export var paso: AudioStream = null
## Efecto al aterrizar, suave o duro.
@export var aterrizaje: AudioStream = null
## Efecto al aterrizar de la picada (en lugar del de aterrizaje).
@export var picada: AudioStream = null
## Efecto al empezar un impulso.
@export var impulso: AudioStream = null

# Nombres de los campos de efecto, iguales en toda ficha: de la clase y no de cada recurso.
static var _campos: Array[StringName] = []


## El efecto del evento, o null si no tiene o si el evento no es un campo de la ficha (Sonido avisa de eso).
func efecto(evento: StringName) -> AudioStream:
	return get(evento) as AudioStream


## Si el evento es un campo de efecto de la ficha. Los campos se leen una vez (Sonido lo pregunta en cada evento).
func tiene_campo(evento: StringName) -> bool:
	if _campos.is_empty():
		for propiedad: Dictionary in get_property_list():
			var clase: String = propiedad["class_name"]
			if clase == "AudioStream":
				var nombre: String = propiedad["name"]
				_campos.append(StringName(nombre))
	return _campos.has(evento)
