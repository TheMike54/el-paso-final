extends "res://herramientas/salas/prueba_base.gd"
# Prueba del guardado (y de los ajustes y la vibracion, que tambien son datos del telefono): al
# entrar, corre los casos sobre archivos propios en user:// y deja en "casos" y "fallos" el
# resultado, que guardado.guion lee con la clave valor. Imprime el resumen y solo los que fallan.
const RUTA: String = "user://prueba_guardado.json"
const PARTIDA: Dictionary = {"banco": {"sala": "raices_1", "id": "banco_raices_1"}, "vidas_maximas": 4,
		"habilidades": ["impulso"], "jefes": [], "amuletos_tenidos": [], "amuletos_equipados": [], "monedas": 0,
		"mochila": {}, "mapas": ["raices"], "salas_visitadas": ["raices_1"], "salas_mapeadas": [],
		"salas": {"raices_1": {"examenes_1": true, "ascensor": 2}}, "personaje": "", "nombre": "", "tiempo_jugado": 12.5}


func _ready() -> void:
	_borrar()
	_caso("sin archivo da VACIA", Guardado.cargar(RUTA).estado == Guardado.Estado.VACIA)
	_escribir(RUTA + ".tmp", JSON.stringify({"version": Guardado.VERSION, "partida": PARTIDA}))
	_caso("un temporal sin partida da VACIA", Guardado.cargar(RUTA).estado == Guardado.Estado.VACIA)

	_caso("guardar devuelve OK", Guardado.guardar(PARTIDA, RUTA) == OK)
	var leida: Guardado.Resultado = Guardado.cargar(RUTA)
	_caso("lo guardado se carga VALIDA", leida.estado == Guardado.Estado.VALIDA)
	_caso("la partida cargada es la guardada", _igual(leida.partida, PARTIDA))
	_caso("no queda el archivo temporal", not FileAccess.file_exists(RUTA + ".tmp"))

	var segunda: Dictionary = PARTIDA.duplicate(true)
	segunda["banco"] = {"sala": "raices_2", "id": "banco_raices_2"}
	_caso("guardar sobre una partida existente devuelve OK", Guardado.guardar(segunda, RUTA) == OK)
	_caso("se carga la ultima partida guardada", _igual(Guardado.cargar(RUTA).partida, segunda))

	_escribir(RUTA + ".tmp", "{\"version\": 2, \"partida\": {\"ban")
	_caso("un temporal sobrante no afecta la carga", _igual(Guardado.cargar(RUTA).partida, segunda))
	_caso("guardar con un temporal sobrante devuelve OK", Guardado.guardar(PARTIDA, RUTA) == OK)

	var texto: String = FileAccess.get_file_as_string(RUTA)
	_danada("texto que no es JSON", "esto no es una partida")
	_danada("archivo cortado a la mitad", texto.substr(0, floori(texto.length() / 2.0)))
	_danada("archivo vacio", "")
	_danada("JSON que no es un objeto", "[1, 2, 3]")
	_danada("sin version", JSON.stringify({"partida": PARTIDA}))
	_danada("version que no es numero", JSON.stringify({"version": "2", "partida": PARTIDA}))
	_danada("partida que no es objeto", JSON.stringify({"version": Guardado.VERSION, "partida": "x"}))
	var sin_campo: Dictionary = PARTIDA.duplicate(true)
	sin_campo.erase("vidas_maximas")
	_danada("falta un campo", JSON.stringify({"version": Guardado.VERSION, "partida": sin_campo}))
	var otro_tipo: Dictionary = PARTIDA.duplicate(true)
	otro_tipo["habilidades"] = "impulso"
	_danada("campo con otro tipo", JSON.stringify({"version": Guardado.VERSION, "partida": otro_tipo}))

	_escribir(RUTA, JSON.stringify({"version": Guardado.VERSION + 1, "partida": PARTIDA}))
	_caso("version mas nueva da INCOMPATIBLE", Guardado.cargar(RUTA).estado == Guardado.Estado.INCOMPATIBLE)
	_escribir(RUTA, JSON.stringify({"version": 0, "partida": PARTIDA}))
	_caso("version mas vieja da INCOMPATIBLE", Guardado.cargar(RUTA).estado == Guardado.Estado.INCOMPATIBLE)
	_escribir(RUTA, JSON.stringify({"version": 2, "partida": {"banco": "raices_1", "sala": "res://x.tscn", "vidas_maximas": 4, "habilidades": []}}))
	_caso("una partida de la version 2 da INCOMPATIBLE (sin migracion)", Guardado.cargar(RUTA).estado == Guardado.Estado.INCOMPATIBLE)
	var sin_banco: Dictionary = PARTIDA.duplicate(true)
	sin_banco["banco"] = {}
	_escribir(RUTA, JSON.stringify({"version": Guardado.VERSION, "partida": sin_banco}))
	_caso("una partida sin banco (autoguardado antes de descansar) es VALIDA", Guardado.cargar(RUTA).estado == Guardado.Estado.VALIDA)
	var banco_roto: Dictionary = PARTIDA.duplicate(true)
	banco_roto["banco"] = {"sala": "raices_1"}
	_danada("banco sin id", JSON.stringify({"version": Guardado.VERSION, "partida": banco_roto}))

	# El estado de la partida se guarda y se carga entero.
	Partida.reiniciar()
	Partida.vidas_maximas = 5
	Partida.banco = "banco_raices_2"
	Partida.sala = "raices_2"
	Partida.habilidades.append(&"impulso")
	Partida.monedas = 150
	Partida.mapas.append("raices")
	Partida.marcar("raices_2", "coleccionable", true)
	Partida.marcar("raices_2", "ascensor", 3)
	_caso("Partida.guardar devuelve OK", Partida.guardar(RUTA) == OK)
	Partida.reiniciar()
	var de_vuelta: Guardado.Resultado = Guardado.cargar(RUTA)
	Partida.inspiracion = 50
	Partida.vencer("res://sala.tscn#fuerte")
	Partida.desde_diccionario(de_vuelta.partida)
	_caso("Partida vuelve con su banco, vidas maximas, vidas llenas y habilidades", de_vuelta.estado == Guardado.Estado.VALIDA and Partida.banco == "banco_raices_2" and Partida.sala == "raices_2" and Partida.vidas_maximas == 5 and Partida.vidas == 5 and Partida.habilidades == [&"impulso"])
	_caso("Partida vuelve con PejeCoins, mapas y el estado de sus salas", Partida.monedas == 150 and Partida.mapas.size() == 1 and Partida.mapas.has("raices") and _vale(Partida.estado_de("raices_2", "coleccionable"), true) and _vale(Partida.estado_de("raices_2", "ascensor"), 3))
	_caso("continuar empieza sin Inspiracion y sin enemigos vencidos", Partida.inspiracion == 0 and Partida.enemigos_vencidos.is_empty())
	Partida.reiniciar()

	# Un mapa, en el suelo o como recompensa, pasa por obtener_mapa: autoguarda una vez y queda guardado.
	var ruta_real: String = Partida.ruta_guardado
	Partida.ruta_guardado = RUTA
	var antes: int = Partida.autoguardados
	Partida.obtener_mapa("raices")
	_caso("obtener un mapa lo suma y autoguarda", Partida.mapas == ["raices"] and Partida.autoguardados == antes + 1)
	Partida.obtener_mapa("raices")
	var recompensa: Recompensa = Recompensa.new()
	recompensa.tipo = Recompensa.Tipo.MAPA
	recompensa.id = &"raices"
	Partida.dar_recompensa(recompensa)
	_caso("un mapa que ya se tiene, recogido o como recompensa, no hace nada", Partida.mapas.size() == 1 and Partida.autoguardados == antes + 1)
	Partida.reiniciar()
	Partida.desde_diccionario(Guardado.cargar(RUTA).partida)
	_caso("el mapa sigue al recargar", Partida.mapas == ["raices"])
	Partida.ruta_guardado = ruta_real
	Partida.reiniciar()

	# Ajustes: archivo propio, valores por omision si falta o esta danado.
	var ruta_ajustes: String = "user://prueba_ajustes.json"
	DirAccess.remove_absolute(ruta_ajustes)
	Ajustes.cargar(ruta_ajustes)
	_caso("sin archivo de ajustes la vibracion esta encendida", Ajustes.vibracion)
	Ajustes.vibracion = false
	_caso("guardar los ajustes devuelve OK", Ajustes.guardar(ruta_ajustes) == OK)
	Ajustes.vibracion = true
	Ajustes.cargar(ruta_ajustes)
	_caso("la vibracion apagada vuelve apagada", not Ajustes.vibracion)
	_escribir(ruta_ajustes, "{ no es json")
	Ajustes.cargar(ruta_ajustes)
	_caso("un archivo de ajustes danado deja los valores por omision", Ajustes.vibracion)
	DirAccess.remove_absolute(ruta_ajustes)
	Ajustes.cargar(ruta_ajustes)
	_caso("sin archivo de ajustes el temblor esta encendido", Ajustes.temblor)
	Ajustes.temblor = false
	_caso("guardar los ajustes con el temblor apagado devuelve OK", Ajustes.guardar(ruta_ajustes) == OK)
	Ajustes.temblor = true
	Ajustes.cargar(ruta_ajustes)
	_caso("el temblor apagado vuelve apagado", not Ajustes.temblor)
	_escribir(ruta_ajustes, '{"version": 1, "ajustes": {"vibracion": false}}')
	Ajustes.cargar(ruta_ajustes)
	_caso("un archivo de antes del temblor lo deja encendido y respeta la vibracion", Ajustes.temblor and not Ajustes.vibracion)
	_caso("un archivo de antes del audio deja musica, efectos y brillo en su valor por omision", is_equal_approx(Ajustes.volumen_musica, 1.0) and is_equal_approx(Ajustes.volumen_efectos, 1.0) and is_equal_approx(Ajustes.brillo, Ajustes.BRILLO_POR_OMISION))
	_escribir(ruta_ajustes, '{"version": 1, "ajustes": {"volumen_musica": 7, "volumen_efectos": -2, "brillo": 9}}')
	Ajustes.cargar(ruta_ajustes)
	_caso("volumenes y brillo fuera de rango se recortan", is_equal_approx(Ajustes.volumen_musica, 1.0) and is_equal_approx(Ajustes.volumen_efectos, 0.0) and is_equal_approx(Ajustes.brillo, Ajustes.BRILLO_MAXIMO))
	_escribir(ruta_ajustes, '{"version": 1, "ajustes": {"volumen_musica": "alto", "brillo": "x"}}')
	Ajustes.cargar(ruta_ajustes)
	_caso("un volumen o un brillo que no es numero deja el valor por omision", is_equal_approx(Ajustes.volumen_musica, 1.0) and is_equal_approx(Ajustes.brillo, Ajustes.BRILLO_POR_OMISION))
	Ajustes.volumen_musica = 0.3
	Ajustes.volumen_efectos = 0.6
	Ajustes.brillo = 0.8
	Ajustes.guardar(ruta_ajustes)
	Ajustes.volumen_musica = 1.0
	Ajustes.volumen_efectos = 1.0
	Ajustes.brillo = 1.0
	Ajustes.cargar(ruta_ajustes)
	_caso("musica, efectos y brillo vuelven como se guardaron", is_equal_approx(Ajustes.volumen_musica, 0.3) and is_equal_approx(Ajustes.volumen_efectos, 0.6) and is_equal_approx(Ajustes.brillo, 0.8))
	_caso("el volumen pasa a dB: 1 es 0 dB y 0,5 queda por debajo", is_equal_approx(Ajustes.db_de(1.0), 0.0) and Ajustes.db_de(0.5) < -5.0)
	_caso("el brillo bajo oscurece, el alto aclara con tope y 1 no tapa nada", is_equal_approx(Brillo.color_para(0.5).a, 0.5) and Brillo.color_para(0.5).r == 0.0 and Brillo.color_para(1.5).r == 1.0 and Brillo.color_para(1.5).a <= Brillo.ACLARADO_MAXIMO and is_zero_approx(Brillo.color_para(1.0).a))
	DirAccess.remove_absolute(ruta_ajustes)
	Ajustes.temblor = Ajustes.POR_OMISION["temblor"]
	Ajustes.volumen_musica = 1.0
	Ajustes.volumen_efectos = 1.0
	Ajustes.brillo = Ajustes.BRILLO_POR_OMISION
	Ajustes.aplicar_volumen()
	# El jugador carga los ajustes al entrar (lee user://ajustes.json, sin escribirlo), sin esperar a
	# que la pausa o la vibracion lo hagan antes.
	Ajustes._cargados = false
	var jugador: Node = (load("res://nucleo/jugador.tscn") as PackedScene).instantiate()
	add_child(jugador)
	_caso("el jugador carga los ajustes al entrar", Ajustes._cargados)
	jugador.free()
	Ajustes.vibracion = Ajustes.POR_OMISION["vibracion"]
	Ajustes.temblor = Ajustes.POR_OMISION["temblor"]

	# Vibracion: respeta el ajuste y no repite dentro de ticks_entre_vibraciones.
	var vibracion: Vibracion = Vibracion.new()
	add_child(vibracion)
	Ajustes.vibracion = false
	Eventos.jugador_danado.emit(3)
	_caso("con la vibracion apagada se pide pero no se envia", vibracion.pedidas == 1 and vibracion.enviadas == 0)
	Eventos.enemigo_golpeado.emit(self)
	_caso("dos vibraciones en el mismo tick: la segunda no sale", vibracion.pedidas == 1)
	Eventos.jugador_danado.emit(2)
	_caso("el dano vibra aunque la anterior sea reciente", vibracion.pedidas == 2)
	vibracion.free()
	Ajustes.vibracion = Ajustes.POR_OMISION["vibracion"]

	_borrar()
	_resumen()


func _danada(nombre: String, contenido: String) -> void:
	_escribir(RUTA, contenido)
	_caso(nombre + " da DANADA", Guardado.cargar(RUTA).estado == Guardado.Estado.DANADA)


# Compara como JSON con las claves ordenadas, pasando la esperada por el JSON: ahi los enteros vuelven
# como float (4 -> 4.0), tambien dentro de los diccionarios anidados.
func _igual(a: Dictionary, b: Dictionary) -> bool:
	var esperada: Variant = JSON.parse_string(JSON.stringify(b))
	return JSON.stringify(a, "", true) == JSON.stringify(esperada, "", true)


func _borrar() -> void:
	for ruta: String in [RUTA, RUTA + ".tmp"]:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ruta)


# Compara un Variant sin pasarlo directo a _caso (el tipado estricto no lo deja). 3.0 del JSON vale 3.
func _vale(valor: Variant, esperado: Variant) -> bool:
	var igual: bool = valor == esperado
	return igual
