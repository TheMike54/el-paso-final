extends ComportamientoEnemigo
# Caminante de pruebas, como el Crawler de Silksong (Crawlid en Hollow Knight): va y viene a la velocidad de su
# ficha con gravedad y nunca cae de su plataforma. Ante una pared o una orilla se queda ticks_giro ticks quieto y
# se voltea. Un golpe no lo voltea (decision del plan nucleo-enemigos-que-se-mueven).

const DatosCaminante = preload("datos_caminante.gd")

## Veces que se volteo; publico para los guiones.
var giros: int = 0

var _ticks_quieto: int = 0
var _d: DatosCaminante = null


func _ready() -> void:
	_d = datos as DatosCaminante


func datos_por_omision() -> DatosComportamiento:
	return DatosCaminante.new()


func actuar() -> void:
	caer()
	if not en_suelo():
		enemigo.velocity.x = 0.0
	elif _ticks_quieto > 0:
		enemigo.velocity.x = 0.0
		_ticks_quieto -= 1
		if _ticks_quieto == 0:
			girar()
			giros += 1
	elif pared_delante(enemigo.mirando) or orilla_delante(enemigo.mirando):
		enemigo.velocity.x = 0.0
		_ticks_quieto = _d.ticks_giro
	else:
		enemigo.velocity.x = enemigo.mirando * enemigo.ficha.velocidad
	mover()


## Si esta en la pausa antes de voltearse.
func esta_quieto() -> bool:
	return _ticks_quieto > 0
