# Crea el destello y el aura del jugador, y muestra el avance de la curacion.
# Guarda los nodos y las texturas para separar lo visual del movimiento.
# Renueva la foto de los amuletos solo cuando lo pide el jugador o cambia el equipo.
class_name EfectosJugador
extends RefCounted

const HOJA_PARRY: Texture2D = preload("res://nucleo/arte/efecto_parry.png")
const CUADROS_PARRY: int = 4
const HOJA_CURAR: Texture2D = preload("res://nucleo/arte/efecto_curar.png")
const HOJA_CURAR_FRENTE: Texture2D = preload("res://nucleo/arte/efecto_curar_frente.png")
const CUADROS_CURAR: int = 6
const AURA_SOBRE_PIES: Vector2 = Vector2(0.0, -185.0)
const LUZ_CURAR_SOBRE_PIES: Vector2 = Vector2(0.0, -110.0)
const LUZ_CURAR_LADO: float = 660.0
const LUZ_CURAR_TINTE: Color = Color(0.75, 0.85, 1.0, 0.0)

var jugador: Jugador
var amuletos: FichaAmuleto
var _aura: EfectoCuadros = null
var _aura_frente: EfectoCuadros = null
var _luz_curar: Sprite2D = null


func _init(cuerpo: Jugador) -> void:
	jugador = cuerpo


func _soltar_destello(punto: Vector2, escala: float, corre_congelado: bool) -> void:
	var efecto: EfectoCuadros = EfectoCuadros.crear(HOJA_PARRY, CUADROS_PARRY, 1, true, true, corre_congelado)
	efecto.scale = Vector2.ONE * escala
	efecto.z_index = jugador.z_index + 1
	jugador.get_parent().add_child(efecto)
	efecto.global_position = punto


func _crear_aura() -> void:
	_aura = EfectoCuadros.crear(HOJA_CURAR, CUADROS_CURAR, 1, false, false, false)
	_aura.name = &"Aura"
	_aura.show_behind_parent = true
	_aura_frente = EfectoCuadros.crear(HOJA_CURAR_FRENTE, CUADROS_CURAR, 1, false, false, false)
	_aura_frente.name = &"AuraFrente"
	_luz_curar = Sprite2D.new()
	_luz_curar.name = &"LuzCurar"
	_luz_curar.texture = LuzSala.textura()
	_luz_curar.material = LuzSala.material_aditivo()
	_luz_curar.scale = Vector2.ONE * (LUZ_CURAR_LADO / LuzSala.LADO)
	_luz_curar.position = LUZ_CURAR_SOBRE_PIES
	_luz_curar.modulate = LUZ_CURAR_TINTE
	for nodo: Node2D in [_aura, _aura_frente]:
		nodo.position = AURA_SOBRE_PIES
	for nodo: Node2D in [_aura, _aura_frente, _luz_curar]:
		nodo.visible = false
		nodo.set_physics_process(false)
		jugador.add_child(nodo)
	jugador.move_child(_aura, 0)


func _mostrar_curacion() -> void:
	if jugador.curando != _aura.visible:
		for nodo: Node2D in [_aura, _aura_frente, _luz_curar]:
			nodo.visible = jugador.curando
		for efecto: EfectoCuadros in [_aura, _aura_frente]:
			efecto.set_physics_process(jugador.curando)
			efecto.reiniciar()
	if jugador.curando:
		# Segundos curados, a 60 ticks por segundo.
		var t: float = float(jugador.ticks_curados) / 60.0
		_luz_curar.modulate.a = minf(1.0, 0.35 + t / 0.6) * (0.32 + 0.04 * sin(t * 30.0))


func _renovar_efectos() -> void:
	amuletos = Partida.efectos_amuletos()
