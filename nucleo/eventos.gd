extends Node
# Bus de eventos (autoload Eventos): la unica via por la que un bloque avisa a otro. Quien
# emite no sabe quien escucha; asi el mapa, el guardado o la interfaz se enganchan sin que el
# jugador ni las salas los conozcan. Solo declara senales: la lista esta en docs/contrato.md.

@warning_ignore("unused_signal")
signal jugador_danado(vidas: int)
@warning_ignore("unused_signal")
signal jugador_muerto()
@warning_ignore("unused_signal")
signal jugador_curado(vidas: int)
@warning_ignore("unused_signal")
signal vidas_cambiadas(vidas: int, maximas: int)
@warning_ignore("unused_signal")
signal inspiracion_cambiada(inspiracion: int, maxima: int)
@warning_ignore("unused_signal")
signal descanso_en_banco(banco: StringName)
@warning_ignore("unused_signal")
signal partida_guardada()
@warning_ignore("unused_signal")
signal enemigo_golpeado(enemigo: Node)
@warning_ignore("unused_signal")
signal enemigo_vencido(enemigo: StringName)
@warning_ignore("unused_signal")
signal habilidad_obtenida(habilidad: StringName)
@warning_ignore("unused_signal")
signal jefe_vencido(jefe: StringName)
@warning_ignore("unused_signal")
signal cambio_de_sala(sala: String, puerta: StringName)
