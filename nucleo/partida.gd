extends Node
# Estado de la partida (autoload Partida): lo que sobrevive al cambio de sala, como las vidas y
# las habilidades. El jugador lee y escribe sus vidas aqui, y el guardado guarda y carga este
# estado, asi que una sala nueva nunca reinicia nada. Va antes de Arranque en los autoloads.

const VIDAS_MAXIMAS_INICIALES: int = 4
const INSPIRACION_MAXIMA: int = 99

# Cada cambio de vidas o de Inspiracion se avisa por el bus (vidas_cambiadas, inspiracion_cambiada):
# asi la interfaz se actualiza sin leer al jugador.
var vidas_maximas: int = VIDAS_MAXIMAS_INICIALES:
	set(valor):
		if valor != vidas_maximas:
			vidas_maximas = valor
			Eventos.vidas_cambiadas.emit(vidas, vidas_maximas)
var vidas: int = VIDAS_MAXIMAS_INICIALES:
	set(valor):
		if valor != vidas:
			vidas = valor
			Eventos.vidas_cambiadas.emit(vidas, vidas_maximas)
## Recurso de curacion: se llena golpeando y se gasta al curar. No se guarda.
var inspiracion: int = 0:
	set(valor):
		if valor != inspiracion:
			inspiracion = valor
			Eventos.inspiracion_cambiada.emit(inspiracion, INSPIRACION_MAXIMA)
## Id del ultimo banco donde se descanso y escena de su sala; vacios si no se ha descansado.
var banco: String = ""
var sala: String = ""
var habilidades: Array[StringName] = []
## Enemigos fuertes vencidos desde el ultimo descanso, por su clave ("<escena de la sala>#<id>"):
## no reaparecen hasta descansar en un banco. No se guarda: continuar empieza en un banco.
var enemigos_vencidos: Array[String] = []


func _ready() -> void:
	Eventos.descanso_en_banco.connect(_al_descansar)


## Partida nueva: vidas llenas, sin habilidades ni banco.
func reiniciar() -> void:
	vidas_maximas = VIDAS_MAXIMAS_INICIALES
	vidas = vidas_maximas
	inspiracion = 0
	banco = ""
	sala = ""
	habilidades.clear()
	enemigos_vencidos.clear()


func ganar_inspiracion(cantidad: int) -> void:
	inspiracion = clampi(inspiracion + cantidad, 0, INSPIRACION_MAXIMA)


func tiene(habilidad: StringName) -> bool:
	return habilidades.has(habilidad)


func llenar_vidas() -> void:
	vidas = vidas_maximas


func vencer(clave: String) -> void:
	if not enemigos_vencidos.has(clave):
		enemigos_vencidos.append(clave)


func fue_vencido(clave: String) -> bool:
	return enemigos_vencidos.has(clave)


# Descansar en un banco hace reaparecer a los enemigos fuertes.
func _al_descansar(_banco: StringName) -> void:
	enemigos_vencidos.clear()


## Lo que se guarda, con los campos de Guardado.ESQUEMA.
func a_diccionario() -> Dictionary:
	var lista: Array[String] = []
	for habilidad: StringName in habilidades:
		lista.append(String(habilidad))
	return {"banco": banco, "sala": sala, "vidas_maximas": vidas_maximas, "habilidades": lista}


## Toma una partida que Guardado.cargar() dio por VALIDA. Se continua con las vidas llenas, sin
## Inspiracion y con todos los enemigos.
func desde_diccionario(partida: Dictionary) -> void:
	# Lo que no se guarda empieza de cero: se continua en un banco, como despues de descansar.
	inspiracion = 0
	enemigos_vencidos.clear()
	banco = partida["banco"] as String
	sala = partida["sala"] as String
	vidas_maximas = partida["vidas_maximas"] as int
	vidas = vidas_maximas
	habilidades.clear()
	var lista: Array = partida["habilidades"]
	for habilidad: Variant in lista:
		habilidades.append(StringName(str(habilidad)))


## Guarda la partida; si salio bien, lo avisa con Eventos.partida_guardada.
func guardar(ruta: String = Guardado.RUTA) -> Error:
	var error: Error = Guardado.guardar(a_diccionario(), ruta)
	if error == OK:
		Eventos.partida_guardada.emit()
	return error
