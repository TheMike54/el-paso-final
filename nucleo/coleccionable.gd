class_name Coleccionable
extends Area2D
# Coleccionable repartido por las salas, como las larvas de Hollow Knight o las pulgas de Silksong: al
# tocarlo se marca en el estado de su sala, se emite Eventos.coleccionable_obtenido (Partida autoguarda)
# y desaparece; si ya esta marcado, no aparece. El total se cuenta con Partida.total_coleccionables().
# Generico y gris: el arte y el tema se deciden despues.
const TAMANO: Vector2 = Vector2(48.0, 48.0)
const COLOR: Color = Color(0.95, 0.8, 0.3)

## Id unico dentro de la sala; empieza con "coleccionable" (coleccionable, coleccionable_2...): asi se cuentan.
@export var id: String = "coleccionable"


func _ready() -> void:
	if not id.begins_with(Partida.PREFIJO_COLECCIONABLE):
		push_error("Coleccionable %s: el id debe empezar con '%s'" % [name, Partida.PREFIJO_COLECCIONABLE])
	if Partida.estado_de(Sala.clave_de(self), id) != null:
		queue_free()
		return
	body_entered.connect(_al_entrar)


func _al_entrar(cuerpo: Node2D) -> void:
	if not cuerpo is Jugador:
		return
	var jugador: Jugador = cuerpo as Jugador
	if jugador.muerto:
		return
	Partida.marcar(Sala.clave_de(self), id)
	Eventos.coleccionable_obtenido.emit(StringName(id))
	queue_free()


func _draw() -> void:
	draw_circle(Vector2(0.0, -TAMANO.y / 2.0), TAMANO.x / 2.0, COLOR)
