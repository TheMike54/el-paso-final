extends Node
# Estado de la partida (autoload Partida): lo que sobrevive al cambio de sala, como las vidas y
# las habilidades. El jugador lee y escribe sus vidas aqui, y el guardado guarda y carga este
# estado, asi que una sala nueva nunca reinicia nada. Tambien autoguarda (como Silksong) al obtener
# algo, al morir y al pasar la app a segundo plano. Va antes de Arranque en los autoloads.

const VIDAS_MAXIMAS_INICIALES: int = 4
const INSPIRACION_MAXIMA: int = 99
## Inspiracion que da un golpe por omision y lo que vale un bloque de la barra del HUD.
const INSPIRACION_POR_GOLPE: int = 11
## Amuletos puestos a la vez. Provisional: la carga de cada amuleto llega cuando haya tres con efecto.
const MAX_EQUIPADOS: int = 3
## Los ids de los coleccionables empiezan asi: el total se cuenta con las marcas de las salas.
const PREFIJO_COLECCIONABLE: String = "coleccionable"
## Archivo donde se guarda fuera de una partida empezada en el menu (guiones, zona de pruebas): asi
## nada de eso pisa una partida real. Entrar a una ranura del menu cambia ruta_guardado a la de esa ranura.
const RUTA_PRUEBAS: String = "user://prueba_partida.json"

# Cada cambio de vidas, de Inspiracion o de PejeCoins se avisa por el bus: asi la interfaz se
# actualiza sin leer al jugador.
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
## PejeCoins.
var monedas: int = 0:
	set(valor):
		if valor != monedas:
			monedas = valor
			Eventos.monedas_cambiadas.emit(monedas)
## Id del ultimo banco donde se descanso y clave de su sala (Sala.clave()); vacios si no se ha descansado.
var banco: String = ""
var sala: String = ""
var habilidades: Array[StringName] = []
var jefes: Array[StringName] = []
var amuletos_tenidos: Array[StringName] = []
var amuletos_equipados: Array[StringName] = []
## Lo que se perdio al morir: {sala, x, y, monto}, o vacio. La mecanica todavia no existe.
var mochila: Dictionary = {}
## Zonas cuyo mapa se tiene, y salas visitadas y ya dibujadas en el mapa (por su clave).
var mapas: Array[String] = []
var salas_visitadas: Array[String] = []
var salas_mapeadas: Array[String] = []
## Estado por sala: {clave de la sala: {id del objeto: true o numero}}. Lo permanente de cada sala (un
## suelo roto, un coleccionable tomado); lo que reaparece no se escribe aqui.
var salas: Dictionary[String, Dictionary] = {}
var personaje: String = ""
var nombre: String = ""
## Segundos jugados con el juego corriendo dentro de una sala.
var tiempo_jugado: float = 0.0
## Archivo donde guardan el banco y el autoguardado (ver RUTA_PRUEBAS).
var ruta_guardado: String = RUTA_PRUEBAS
## Enemigos fuertes vencidos desde el ultimo descanso, por su clave ("<clave de la sala>#<id>"):
## no reaparecen hasta descansar en un banco o morir. No se guarda: continuar empieza en un banco.
var enemigos_vencidos: Array[String] = []
## Autoguardados hechos desde que arranco el juego; publico para los guiones.
var autoguardados: int = 0


func _ready() -> void:
	Eventos.descanso_en_banco.connect(_al_descansar)
	Eventos.jugador_muerto.connect(_al_morir)
	Eventos.habilidad_obtenida.connect(_al_obtener.unbind(1))
	Eventos.amuleto_obtenido.connect(_al_obtener.unbind(1))
	Eventos.mapa_obtenido.connect(_al_obtener.unbind(1))
	Eventos.coleccionable_obtenido.connect(_al_obtener.unbind(1))
	Eventos.jefe_vencido.connect(_al_vencer_jefe)


func _physics_process(delta: float) -> void:
	if get_tree().current_scene is Sala:
		tiempo_jugado += delta


# Pasar a segundo plano guarda lo obtenido (no la posicion), como salir al menu.
func _notification(que: int) -> void:
	if que == NOTIFICATION_APPLICATION_PAUSED or que == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if is_inside_tree() and get_tree().current_scene is Sala:
			autoguardar()


## Partida nueva: vidas llenas, sin habilidades ni banco.
func reiniciar() -> void:
	vidas_maximas = VIDAS_MAXIMAS_INICIALES
	vidas = vidas_maximas
	inspiracion = 0
	monedas = 0
	banco = ""
	sala = ""
	habilidades.clear()
	jefes.clear()
	amuletos_tenidos.clear()
	amuletos_equipados.clear()
	mochila = {}
	mapas.clear()
	salas_visitadas.clear()
	salas_mapeadas.clear()
	salas.clear()
	personaje = ""
	nombre = ""
	tiempo_jugado = 0.0
	enemigos_vencidos.clear()


func ganar_inspiracion(cantidad: int) -> void:
	inspiracion = clampi(inspiracion + cantidad, 0, INSPIRACION_MAXIMA)


func tiene(habilidad: StringName) -> bool:
	return habilidades.has(habilidad)


## Suma una habilidad y lo avisa (el aviso autoguarda). Si ya la tenia, no hace nada; un id que no esta en
## Habilidades.TODAS es un error de la sala o de la ficha y no se suma.
func obtener_habilidad(habilidad: StringName) -> void:
	if not Habilidades.TODAS.has(habilidad):
		push_error("Partida.obtener_habilidad: '%s' no es una habilidad (Habilidades.TODAS)" % habilidad)
		return
	if tiene(habilidad):
		return
	habilidades.append(habilidad)
	Eventos.habilidad_obtenida.emit(habilidad)


## Suma un amuleto y lo avisa (el aviso autoguarda). Si ya lo tenia, no hace nada.
func obtener_amuleto(amuleto: StringName) -> void:
	if amuletos_tenidos.has(amuleto):
		return
	amuletos_tenidos.append(amuleto)
	Eventos.amuleto_obtenido.emit(amuleto)


## Suma el mapa de una zona y lo avisa (el aviso autoguarda). Si ya lo tenia, no hace nada.
func obtener_mapa(zona: String) -> void:
	if zona.is_empty() or mapas.has(zona):
		return
	mapas.append(zona)
	Eventos.mapa_obtenido.emit(zona)


func esta_equipado(amuleto: StringName) -> bool:
	return amuletos_equipados.has(amuleto)


## Se puede poner si se tiene, no esta puesto y queda lugar. Donde se puede (sentado en un banco) lo decide quien
## llama: Partida no conoce al jugador.
func puede_equipar(amuleto: StringName) -> bool:
	return amuletos_tenidos.has(amuleto) and not esta_equipado(amuleto) and amuletos_equipados.size() < MAX_EQUIPADOS


## Pone un amuleto y autoguarda. Devuelve false si no se puede (ver puede_equipar).
func equipar(amuleto: StringName) -> bool:
	if not puede_equipar(amuleto):
		return false
	amuletos_equipados.append(amuleto)
	autoguardar()
	return true


## Quita un amuleto puesto y autoguarda. Devuelve false si no estaba puesto.
func desequipar(amuleto: StringName) -> bool:
	if not esta_equipado(amuleto):
		return false
	amuletos_equipados.erase(amuleto)
	autoguardar()
	return true


func llenar_vidas() -> void:
	vidas = vidas_maximas


func vencer(clave: String) -> void:
	if not enemigos_vencidos.has(clave):
		enemigos_vencidos.append(clave)


func fue_vencido(clave: String) -> bool:
	return enemigos_vencidos.has(clave)


## Valor guardado de un objeto de una sala, o null si no tiene.
func estado_de(clave_sala: String, objeto: String) -> Variant:
	var estado: Dictionary = salas.get(clave_sala, {})
	return estado.get(objeto)


## Un numero del estado de una sala, o por_omision si no hay nada o no es numero. El JSON devuelve los enteros
## como float: por eso no basta con "as int".
func estado_entero(clave_sala: String, objeto: String, por_omision: int) -> int:
	var valor: Variant = estado_de(clave_sala, objeto)
	return int(valor as float) if valor is int or valor is float else por_omision


## Recuerda un objeto de una sala (true o un numero). Se escribe en el siguiente guardado.
func marcar(clave_sala: String, objeto: String, valor: Variant = true) -> void:
	if clave_sala.is_empty():
		return
	if not salas.has(clave_sala):
		salas[clave_sala] = {}
	var estado: Dictionary = salas[clave_sala]
	estado[objeto] = valor


## Coleccionables juntados: las marcas de todas las salas cuyo id empieza con PREFIJO_COLECCIONABLE.
func total_coleccionables() -> int:
	return contar_coleccionables(salas)


## Lo mismo sobre un estado de salas leido de un archivo (la ficha de una ranura): ignora lo que no es diccionario.
func contar_coleccionables(salas_leidas: Dictionary) -> int:
	var total: int = 0
	for clave_sala: Variant in salas_leidas:
		var estado: Variant = salas_leidas[clave_sala]
		if estado is Dictionary:
			for objeto: Variant in estado as Dictionary:
				if str(objeto).begins_with(PREFIJO_COLECCIONABLE):
					total += 1
	return total


func dar_recompensa(recompensa: Recompensa) -> void:
	match recompensa.tipo:
		Recompensa.Tipo.MONEDAS:
			monedas += recompensa.monto
		Recompensa.Tipo.VIDA_MAXIMA:
			vidas_maximas += recompensa.monto
			llenar_vidas()
		Recompensa.Tipo.AMULETO:
			obtener_amuleto(recompensa.id)
		Recompensa.Tipo.HABILIDAD:
			obtener_habilidad(recompensa.id)
		Recompensa.Tipo.MAPA:
			obtener_mapa(String(recompensa.id))


## Al entrar a una sala: queda como visitada.
func visitar(clave_sala: String) -> void:
	if not clave_sala.is_empty() and not salas_visitadas.has(clave_sala):
		salas_visitadas.append(clave_sala)


# Descansar en un banco hace reaparecer a los enemigos fuertes y, con la pluma del mapa, dibuja en el
# mapa las salas visitadas de las zonas cuyo mapa se tiene (como la Pluma de Hollow Knight y Silksong).
func _al_descansar(_banco: StringName) -> void:
	enemigos_vencidos.clear()
	if not tiene(Habilidades.PLUMA_MAPA):
		return
	for visitada: String in salas_visitadas:
		if not salas_mapeadas.has(visitada) and mapas.has(Sala.zona_de(visitada)):
			salas_mapeadas.append(visitada)


# Morir tambien hace reaparecer a los fuertes, como los semipersistentes de Hollow Knight, vacia la
# Inspiracion y guarda (como GameManager.PlayerDead de Hollow Knight).
func _al_morir() -> void:
	enemigos_vencidos.clear()
	# La Inspiracion se pierde al morir, como el alma de Hollow Knight (que se queda en la sombra).
	inspiracion = 0
	autoguardar()


func _al_obtener() -> void:
	autoguardar()


func _al_vencer_jefe(jefe: StringName) -> void:
	if not jefes.has(jefe):
		jefes.append(jefe)
	autoguardar()


## Guarda lo obtenido sin cambiar el banco: al reabrir se aparece en el ultimo banco. Lo avisa con
## Eventos.partida_guardada, como el banco.
func autoguardar() -> Error:
	var error: Error = guardar(ruta_guardado)
	if error == OK:
		autoguardados += 1
	else:
		push_error("Partida: no se pudo autoguardar (error %d)" % error)
	return error


## Lo que se guarda, con los campos de Guardado.ESQUEMA.
func a_diccionario() -> Dictionary:
	return {
		"banco": {"sala": sala, "id": banco} if not banco.is_empty() else {},
		"vidas_maximas": vidas_maximas,
		"habilidades": _textos(habilidades),
		"jefes": _textos(jefes),
		"amuletos_tenidos": _textos(amuletos_tenidos),
		"amuletos_equipados": _textos(amuletos_equipados),
		"monedas": monedas,
		"mochila": mochila.duplicate(true),
		"mapas": mapas.duplicate(),
		"salas_visitadas": salas_visitadas.duplicate(),
		"salas_mapeadas": salas_mapeadas.duplicate(),
		"salas": salas.duplicate(true),
		"personaje": personaje,
		"nombre": nombre,
		"tiempo_jugado": tiempo_jugado,
	}


## Toma una partida que Guardado.cargar() dio por VALIDA. Se continua con las vidas llenas, sin
## Inspiracion y con todos los enemigos.
func desde_diccionario(partida: Dictionary) -> void:
	# Lo que no se guarda empieza de cero: se continua en un banco, como despues de descansar.
	inspiracion = 0
	enemigos_vencidos.clear()
	var lugar: Dictionary = partida["banco"]
	banco = str(lugar.get("id", ""))
	sala = str(lugar.get("sala", ""))
	vidas_maximas = partida["vidas_maximas"] as int
	vidas = vidas_maximas
	habilidades = _ids(partida["habilidades"] as Array)
	jefes = _ids(partida["jefes"] as Array)
	amuletos_tenidos = _ids(partida["amuletos_tenidos"] as Array)
	amuletos_equipados = _ids(partida["amuletos_equipados"] as Array)
	monedas = partida["monedas"] as int
	mochila = (partida["mochila"] as Dictionary).duplicate(true)
	mapas = _cadenas(partida["mapas"] as Array)
	salas_visitadas = _cadenas(partida["salas_visitadas"] as Array)
	salas_mapeadas = _cadenas(partida["salas_mapeadas"] as Array)
	salas.clear()
	var leidas: Dictionary = partida["salas"]
	for clave_sala: Variant in leidas:
		var estado: Variant = leidas[clave_sala]
		if estado is Dictionary:
			salas[str(clave_sala)] = (estado as Dictionary).duplicate(true)
	personaje = partida["personaje"] as String
	nombre = partida["nombre"] as String
	tiempo_jugado = partida["tiempo_jugado"] as float


## Guarda la partida; si salio bien, lo avisa con Eventos.partida_guardada.
func guardar(ruta: String = Guardado.RUTA) -> Error:
	var error: Error = Guardado.guardar(a_diccionario(), ruta)
	if error == OK:
		Eventos.partida_guardada.emit()
	return error


func _textos(lista: Array[StringName]) -> Array[String]:
	var textos: Array[String] = []
	for elemento: StringName in lista:
		textos.append(String(elemento))
	return textos


func _ids(lista: Array) -> Array[StringName]:
	var ids: Array[StringName] = []
	for elemento: Variant in lista:
		ids.append(StringName(str(elemento)))
	return ids


func _cadenas(lista: Array) -> Array[String]:
	var cadenas: Array[String] = []
	for elemento: Variant in lista:
		cadenas.append(str(elemento))
	return cadenas
