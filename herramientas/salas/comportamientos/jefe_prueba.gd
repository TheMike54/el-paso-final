# Jefe de caja gris para probar el ciclo de BattleScene sin una base de jefe nueva.
# Camina en fase 0; en fase 1 acelera, se detiene como aviso y embiste hacia el jugador.
# Usa las ayudas del caminante y datos compartidos; la arena controla cuando recibe ticks.
extends ComportamientoEnemigo

enum Estado { CAMINAR, AVISAR, EMBESTIR }

const DatosJefe = preload("datos_jefe_prueba.gd")

var cambios: Array[int] = []
var embestidas: int = 0
var _estado: Estado = Estado.CAMINAR
var _ticks: int = 0
var _d: DatosJefe = null


func _ready() -> void:
	_d = datos as DatosJefe
	_ticks = _d.ticks_entre_embestidas


func datos_por_omision() -> DatosComportamiento:
	return DatosJefe.new()


func al_cambiar_fase(fase: int) -> void:
	cambios.append(fase)
	_estado = Estado.CAMINAR
	_ticks = _d.ticks_entre_embestidas


func actuar() -> void:
	caer()
	if not en_suelo():
		enemigo.velocity.x = 0.0
		mover()
		return
	if pared_delante(enemigo.mirando) or orilla_delante(enemigo.mirando):
		girar()
		if _estado == Estado.EMBESTIR:
			_estado = Estado.CAMINAR
			_ticks = _d.ticks_entre_embestidas
	var rapidez: float = enemigo.ficha.velocidad
	if enemigo.fase > 0:
		rapidez *= _d.factor_segunda_fase
		_ticks -= 1
		if _ticks <= 0:
			match _estado:
				Estado.CAMINAR:
					_estado = Estado.AVISAR
					_ticks = _d.ticks_aviso
				Estado.AVISAR:
					var objetivo: Jugador = jugador()
					if objetivo != null and lado_de(objetivo) != 0.0:
						enemigo.mirando = lado_de(objetivo)
					_estado = Estado.EMBESTIR
					_ticks = _d.ticks_embestida
					embestidas += 1
				Estado.EMBESTIR:
					_estado = Estado.CAMINAR
					_ticks = _d.ticks_entre_embestidas
		if _estado == Estado.AVISAR:
			rapidez = 0.0
		elif _estado == Estado.EMBESTIR:
			rapidez = _d.velocidad_embestida
	enemigo.velocity.x = enemigo.mirando * rapidez
	mover()
