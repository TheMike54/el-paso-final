extends ComportamientoEnemigo
# Muneco de pruebas que ataca, para probar el parry: a mitad de cada ciclo avisa (se aclara aviso ticks) y da un
# golpe al frente que dura golpe ticks; al final del ciclo dispara hacia el mismo lado. Los golpes alternan: el de los
# ciclos impares se puede parar (trazo blanco) y el de los pares no (sin trazo; se ve con «Ver hitbox»). El disparo
# siempre se puede desviar (desaparece con una chispa, sin el congelado del parry).

const DatosMunecoQueAtaca = preload("datos_muneco_que_ataca.gd")

## Golpes dados desde que entro a la sala; publico para los guiones.
var golpes_dados: int = 0
var disparos: int = 0
## Ticks que actuo; se detiene durante el congelado comun.
var reloj: int = 0

var _d: DatosMunecoQueAtaca = null


func _ready() -> void:
	_d = datos as DatosMunecoQueAtaca


func datos_por_omision() -> DatosComportamiento:
	return DatosMunecoQueAtaca.new()


func actuar() -> void:
	reloj += 1
	var fase: int = reloj % _d.ciclo
	# Aviso: se aclara los aviso ticks antes del golpe.
	enemigo.modulate = Color(1.7, 1.7, 1.7) if fase > _d.ciclo / 2 - _d.aviso and fase < _d.ciclo / 2 else Color.WHITE
	if fase == _d.ciclo / 2:
		golpes_dados += 1
		atacar(_d.rectangulo_golpe, _d.golpe, 1, golpes_dados % 2 == 1)
	elif fase == 0:
		disparos += 1
		disparar(_d.salida_disparo, Vector2.LEFT, 1, true)
