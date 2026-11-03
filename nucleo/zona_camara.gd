class_name ZonaCamara
extends Area2D
# Zona de camara (la CameraLockArea de Hollow Knight): mientras el jugador esta dentro de su forma, la camara no muestra
# nada fuera de limites, ademas de los de la sala. Sirve para que un tramo de una sala grande se vea como una sala
# chica. La forma es una CollisionShape2D hija, editada en el editor; la pila de zonas y el «al instante» viven en la
# CamaraJugador, asi que esta pieza no tiene tick.

## Rectangulo que la camara puede mostrar mientras el jugador esta dentro, en coordenadas de la sala, igual que
## Sala.limites (la position del nodo solo coloca la forma). Va dentro de los limites de la sala; un eje que no se
## quiere topar se deja igual al de la sala. Sin area, el validador lo rechaza.
@export var limites: Rect2 = Rect2()


func _ready() -> void:
	Capas.poner(self, Capas.INTERACCION, Capas.JUGADOR)
	body_entered.connect(_al_entrar)
	body_exited.connect(_al_salir)


func _al_entrar(cuerpo: Node2D) -> void:
	var jugador: Jugador = cuerpo as Jugador
	if jugador != null:
		jugador.camara().entrar_zona(self)


func _al_salir(cuerpo: Node2D) -> void:
	var jugador: Jugador = cuerpo as Jugador
	if jugador != null:
		jugador.camara().salir_zona(self)
