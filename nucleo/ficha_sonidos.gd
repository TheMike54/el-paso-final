class_name FichaSonidos
extends Resource
# Que efecto suena con cada evento del bus: datos, no codigo. Sonido toca lo que diga; hoy usa la de prueba de
# nucleo/sonidos/ (donde vivira la del juego esta por decidir). Un evento sin efecto no suena. Efectos en WAV: se
# tocan sin decodificar, lo barato para la gama baja.

@export var salto: AudioStream = null
@export var golpe: AudioStream = null
@export var dano: AudioStream = null
@export var parry: AudioStream = null
@export var curar: AudioStream = null
@export var banco: AudioStream = null
## Tono de cada evento (1 = el del archivo); con dos sonidos de prueba, el tono los distingue.
@export var tonos: Dictionary[StringName, float] = {}
## El tono de cada vez sale entre tono - variacion_tono y tono + variacion_tono: repetido no suena igual.
@export_range(0.0, 0.3) var variacion_tono: float = 0.06


func efecto(evento: StringName) -> AudioStream:
	return get(evento) as AudioStream


func tono(evento: StringName) -> float:
	return tonos.get(evento, 1.0)
