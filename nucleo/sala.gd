class_name Sala
extends Node2D
# Raiz de toda sala: al entrar crea al jugador (en la puerta por la que llega o en Entrada), le
# pasa los limites para la camara y pone los controles tactiles, la pausa, la vibracion y la
# interfaz. Si el jugador muere, lo hace reaparecer en el ultimo banco (o en Entrada) con las
# vidas llenas.
const ESCENA_JUGADOR: PackedScene = preload("res://nucleo/jugador.tscn")
const ESCENA_CONTROLES: PackedScene = preload("res://nucleo/controles_tactiles.tscn")
const ESCENA_PAUSA: PackedScene = preload("res://nucleo/pausa.tscn")
## La interfaz es de otro bloque: se carga con load() solo si existe, asi el nucleo corre sin ella.
const INTERFAZ: String = "res://interfaz/interfaz.tscn"
## Ticks que el jugador muerto se queda en pantalla (oscuro) antes de reaparecer: 1,5 s.
const TICKS_PARA_REAPARECER: int = 90

## Id de la puerta por la que llega el jugador a la proxima sala; vacio al empezar una partida.
## Es estatica porque sobrevive al cambio de escena sin necesitar un autoload.
static var puerta_llegada: StringName = &""
## Verdadero si el jugador debe aparecer en el banco Partida.banco de la proxima sala.
static var llegada_a_banco: bool = false

## Rectangulo de la sala en sus coordenadas: la camara no muestra nada fuera de el.
@export var limites: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)

var _ticks_para_reaparecer: int = 0


func _ready() -> void:
	var jugador: Jugador = ESCENA_JUGADOR.instantiate() as Jugador
	jugador.position = _punto_de_llegada()
	var puerta: StringName = puerta_llegada
	puerta_llegada = &""
	llegada_a_banco = false
	add_child(jugador)
	jugador.fijar_limites(limites)
	add_child(ESCENA_CONTROLES.instantiate())
	add_child(ESCENA_PAUSA.instantiate())
	var vibracion: Vibracion = Vibracion.new()
	vibracion.name = &"Vibracion"
	add_child(vibracion)
	if ResourceLoader.exists(INTERFAZ):
		var interfaz: PackedScene = load(INTERFAZ) as PackedScene
		add_child(interfaz.instantiate())
	Eventos.jugador_muerto.connect(_al_morir_el_jugador)
	if not puerta.is_empty():
		Eventos.cambio_de_sala.emit(scene_file_path, puerta)


# Se reaparece en el ultimo banco donde se descanso; si no hay, en la Entrada de esta sala.
func _al_morir_el_jugador() -> void:
	_ticks_para_reaparecer = TICKS_PARA_REAPARECER


func _physics_process(_delta: float) -> void:
	if _ticks_para_reaparecer == 0:
		return
	_ticks_para_reaparecer -= 1
	if _ticks_para_reaparecer == 0:
		Partida.llenar_vidas()
		puerta_llegada = &""
		if Partida.sala.is_empty():
			get_tree().reload_current_scene()
		else:
			llegada_a_banco = true
			get_tree().change_scene_to_file(Partida.sala)


func _punto_de_llegada() -> Vector2:
	if llegada_a_banco:
		for hijo: Node in get_children():
			var banco: Banco = hijo as Banco
			if banco != null and banco.id == Partida.banco:
				return banco.position
		push_error("Sala %s: no hay un banco con id '%s'" % [scene_file_path, Partida.banco])
	elif not puerta_llegada.is_empty():
		for hijo: Node in get_children():
			var puerta: Puerta = hijo as Puerta
			if puerta != null and puerta.id == puerta_llegada:
				return puerta.position + puerta.llegada
		push_error("Sala %s: no hay una puerta con id '%s'" % [scene_file_path, puerta_llegada])
	var entrada: Node2D = get_node_or_null(^"Entrada") as Node2D
	return entrada.position if entrada != null else Vector2.ZERO
