class_name RegionMusica
extends Area2D
# Zona de una sala donde cambia la musica, como MusicRegion de Hollow Knight: con el jugador dentro pide su tema (si
# tiene) y lleva la musica a volumen_entrar_db; al salir, a volumen_salir_db, sin cambiar el tema. Los valores por
# omision son los de Dirtmouth: sube en 3 s al entrar al pueblo y se apaga en 6 s al salir. La forma es una
# CollisionShape2D hija, ajustada en el editor.

## Tema de la region; vacio, sigue el que suena y solo cambia el volumen.
@export var tema: AudioStream = null
@export var volumen_entrar_db: float = Musica.DB_NORMAL
@export var segundos_entrar: float = 3.0
@export var volumen_salir_db: float = Musica.DB_SILENCIO
@export var segundos_salir: float = 6.0

## El jugador esta dentro. Publico para los guiones.
var dentro: bool = false


func _ready() -> void:
	Capas.poner(self, Capas.INTERACCION, Capas.JUGADOR)
	body_entered.connect(_al_entrar)
	body_exited.connect(_al_salir)


func _al_entrar(cuerpo: Node2D) -> void:
	if not cuerpo is Jugador:
		return
	dentro = true
	Arranque.musica.poner(tema, volumen_entrar_db, segundos_entrar)


func _al_salir(cuerpo: Node2D) -> void:
	if not cuerpo is Jugador:
		return
	dentro = false
	_pedir_salida.call_deferred()


# Al liberar la sala (cruzar una puerta, reaparecer) el area avisa la salida del jugador al quitar su forma, todavia
# dentro del arbol (medido: el aviso llega antes que el tree_exiting del jugador). Eso no es salir de la region y la
# musica la decide la sala siguiente: diferido, el pedido solo sale si la region sigue en el arbol al final del cuadro
# (liberada, la llamada diferida ya no corre).
func _pedir_salida() -> void:
	if is_inside_tree() and not dentro:
		Arranque.musica.poner(null, volumen_salir_db, segundos_salir)
