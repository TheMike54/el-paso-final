extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del guardado (y de los ajustes y la vibracion, que tambien son datos del telefono): al
# entrar, corre los casos sobre archivos propios en user:// y deja en "casos" y "fallos" el
# resultado, que guardado.guion lee con la clave valor. Imprime el resumen y solo los que fallan.
const RUTA: String = "user://prueba_guardado.json"
const PARTIDA: Dictionary = {"banco": {"sala": "raices_1", "id": "banco_raices_1"}, "vidas_maximas": 4,
		"habilidades": ["impulso"], "jefes": [], "amuletos_tenidos": [], "amuletos_equipados": [], "monedas": 0,
		"mochila": {}, "mapas": ["raices"], "salas_visitadas": ["raices_1"], "salas_mapeadas": [],
		"estaciones": ["estacion_raices_1"], "botones_ensenados": ["saltar"], "salas": {"raices_1": {"examenes_1": true, "ascensor": 2}}, "personaje": "", "nombre": "", "tiempo_jugado": 12.5,
		"carga_maxima": 3, "inspiracion_maxima": 33, "utiles_tenidos": [], "utiles_equipados": []}
# Carpeta que no existe: guardar ahi falla al abrir el temporal, sin depender de llenar el disco.
const RUTA_MALA: String = "user://carpeta_que_no_existe/partida.json"
# Valores de prueba de los campos objeto del recorrido completo: su contenido se lee por clave (banco, mochila,
# salas), asi que no hay un objeto generico que sirva para todos. Un campo objeto nuevo sin su forma aqui hace
# fallar el recorrido.
const FORMAS: Dictionary = {
	"banco": {"sala": "sala_prueba", "id": "banco_prueba"},
	"mochila": {"sala": "sala_prueba", "x": 3.0, "y": 4.0, "monto": 5.0},
	"salas": {"sala_prueba": {"coleccionable_prueba": true, "ascensor": 2.0}},
}


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
	# Botones ensenados (campo nuevo): una partida vieja sin el campo carga vacia, y Partida los lleva y los trae.
	var sin_botones: Dictionary = PARTIDA.duplicate(true)
	sin_botones.erase("botones_ensenados")
	Guardado.guardar(sin_botones, RUTA)
	var vieja: Guardado.Resultado = Guardado.cargar(RUTA)
	_caso("una partida sin botones_ensenados carga con la lista vacia", vieja.estado == Guardado.Estado.VALIDA
			and (vieja.partida["botones_ensenados"] as Array).is_empty())
	Partida.reiniciar()
	Partida.ensenar_boton(&"saltar")
	Partida.ensenar_boton(&"saltar")
	var de_partida: Dictionary = Partida.a_diccionario()
	Partida.reiniciar()
	Partida.desde_diccionario(de_partida)
	_caso("Partida guarda y recupera los botones ensenados, sin repetir", Partida.botones_ensenados == [&"saltar"])
	Partida.reiniciar()

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
	# La 3 tenia la brujula entre los amuletos: hasta terminar el juego no se convierte (ver Guardado.VERSION).
	_escribir(RUTA, JSON.stringify({"version": 3, "partida": PARTIDA}))
	_caso("una partida de la version 3 da INCOMPATIBLE (sin conversion)", Guardado.cargar(RUTA).estado == Guardado.Estado.INCOMPATIBLE)
	var sin_banco: Dictionary = PARTIDA.duplicate(true)
	sin_banco["banco"] = {}
	_escribir(RUTA, JSON.stringify({"version": Guardado.VERSION, "partida": sin_banco}))
	_caso("una partida sin banco (autoguardado antes de descansar) es VALIDA", Guardado.cargar(RUTA).estado == Guardado.Estado.VALIDA)
	var banco_roto: Dictionary = PARTIDA.duplicate(true)
	banco_roto["banco"] = {"sala": "raices_1"}
	_danada("banco sin id", JSON.stringify({"version": Guardado.VERSION, "partida": banco_roto}))
	_fuera_de_rango("vidas_maximas", 0)
	_fuera_de_rango("vidas_maximas", -2)
	_fuera_de_rango("monedas", -1)
	_fuera_de_rango("tiempo_jugado", -0.5)
	var mochila_negativa: Dictionary = PARTIDA.duplicate(true)
	mochila_negativa["mochila"] = {"sala": "raices_1", "x": 1.0, "y": 2.0, "monto": -5}
	_danada("mochila con monto negativo", JSON.stringify({"version": Guardado.VERSION, "partida": mochila_negativa}))
	mochila_negativa["mochila"]["monto"] = -0.5
	_danada("mochila con monto negativo menor que uno", JSON.stringify({"version": Guardado.VERSION, "partida": mochila_negativa}))

	# Un archivo que existe y no se abre no esta danado. El caso real (bloqueado por otro proceso) se probo a mano:
	# FileAccess da ERR_FILE_CANT_OPEN; aqui se finge porque no se monta igual en todos los sistemas.
	Guardado.guardar(PARTIDA, RUTA)
	Guardado.fingir_fallo(RUTA, ERR_FILE_CANT_OPEN)
	_caso("un archivo intacto que no se puede abrir da ILEGIBLE y no DANADA", Guardado.cargar(RUTA).estado == Guardado.Estado.ILEGIBLE)
	Guardado.olvidar_fallos()
	_caso("al volver a poder abrirse sigue VALIDA", Guardado.cargar(RUTA).estado == Guardado.Estado.VALIDA)
	var no_abre: FileAccess = FileAccess.open("user://carpeta_que_no_existe/nada.json", FileAccess.READ)
	_caso("un error de abrir otro archivo no vuelve ILEGIBLE una partida buena", no_abre == null and Guardado.cargar(RUTA).estado == Guardado.Estado.VALIDA)

	# Campos nuevos con valor por omision (Guardado.NUEVOS), con una lista de prueba.
	var nuevos: Dictionary[String, Variant] = {"cuenta": 0.0, "lista": []}
	var sin_nuevos: Dictionary = PARTIDA.duplicate(true)
	_caso("completar rellena los campos nuevos que faltan", Guardado.completar(sin_nuevos, nuevos) and _vale(sin_nuevos["cuenta"], 0.0) and _vale(sin_nuevos["lista"], []))
	(sin_nuevos["lista"] as Array).append("x")
	_caso("el valor rellenado es una copia, no el de la lista", (nuevos["lista"] as Array).is_empty())
	var con_nuevos: Dictionary = PARTIDA.duplicate(true)
	con_nuevos["cuenta"] = 7.0
	_caso("completar deja un campo nuevo que ya esta", Guardado.completar(con_nuevos, nuevos) and _vale(con_nuevos["cuenta"], 7.0))
	con_nuevos["lista"] = "x"
	_caso("un campo nuevo con otro tipo no completa (DANADA al cargar)", not Guardado.completar(con_nuevos, nuevos))

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

	# Un mapa, en el suelo o como recompensa, pasa por obtener_mapa: autoguarda una vez y queda guardado.
	_aislar_partida(RUTA)
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
	_restaurar_partida()

	# Lo que se guarda contra el esquema: las claves en los dos sentidos y un recorrido con cada campo cambiado.
	_claves_contra_esquema()
	_recorrido_completo()

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
	_escribir(ruta_ajustes, '{"version": 1, "ajustes": {"vibracion": false}}')
	Ajustes.cargar(ruta_ajustes)
	_caso("un archivo de antes de los FPS los deja en 60", Ajustes.fps == 60)
	_escribir(ruta_ajustes, '{"version": 1, "ajustes": {"fps": 90}}')
	Ajustes.cargar(ruta_ajustes)
	var fps_raro: bool = Ajustes.fps == 60
	_escribir(ruta_ajustes, '{"version": 1, "ajustes": {"fps": "120"}}')
	Ajustes.cargar(ruta_ajustes)
	_caso("unos FPS que no son 60 ni 120, o no son numero, dejan 60", fps_raro and Ajustes.fps == 60)
	Ajustes.fps = 120
	Ajustes.guardar(ruta_ajustes)
	Ajustes.fps = 60
	Ajustes.cargar(ruta_ajustes)
	_caso("120 FPS vuelven como se guardaron", Ajustes.fps == 120)
	Ajustes.fps = Ajustes.FPS_POR_OMISION
	_caso("sin limite (0) solo con 120, Recursos en alto y pantalla de 90 Hz o mas", Ajustes.limite_fps(120, true, 120.0) == 0 and Ajustes.limite_fps(120, true, 90.0) == 0)
	_caso("60 con 60 elegidos, con Recursos en bajo, con pantalla de 60 Hz o desconocida (-1)", Ajustes.limite_fps(60, true, 120.0) == 60 and Ajustes.limite_fps(120, false, 120.0) == 60 and Ajustes.limite_fps(120, true, 60.0) == 60 and Ajustes.limite_fps(120, true, -1.0) == 60)
	_caso("en un menu, 60 aunque se elijan 120 con todo a favor", Ajustes.limite_fps(120, true, 120.0, true) == 60)
	_caso("luces 2D: solo con el ajuste encendido y Recursos en alto", Ajustes.luces_avanzadas_activas(true, false) and not Ajustes.luces_avanzadas_activas(true, true) and not Ajustes.luces_avanzadas_activas(false, false))
	_escribir(ruta_ajustes, '{"version": 1, "ajustes": {"vibracion": false}}')
	Ajustes.cargar(ruta_ajustes)
	_caso("un archivo de antes de Avanzado deja luces, niebla y FPS en pantalla apagados", not Ajustes.luces_avanzadas and not Ajustes.niebla and not Ajustes.mostrar_fps)
	Ajustes.luces_avanzadas = true
	Ajustes.niebla = true
	Ajustes.mostrar_fps = true
	Ajustes.guardar(ruta_ajustes)
	Ajustes.cargar(ruta_ajustes)
	_caso("luces, niebla y FPS en pantalla vuelven como se guardaron", Ajustes.luces_avanzadas and Ajustes.niebla and Ajustes.mostrar_fps)
	_escribir(ruta_ajustes, '{"version": 1, "ajustes": {"niebla": "si", "mostrar_fps": 1}}')
	Ajustes.cargar(ruta_ajustes)
	_caso("una niebla o un mostrar FPS que no es si o no deja el valor por omision", not Ajustes.niebla and not Ajustes.mostrar_fps)
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
	_caso("el brillo bajo oscurece, el alto aclara, fuera de rango se recorta y 1 no cambia nada", Brillo.color_para(0.5).is_equal_approx(Color(0.5, 0.5, 0.5)) and Brillo.color_para(1.5).is_equal_approx(Color(1.5, 1.5, 1.5)) and Brillo.color_para(3.0).is_equal_approx(Color(1.5, 1.5, 1.5)) and Brillo.color_para(1.0).is_equal_approx(Color.WHITE))
	Ajustes.brillo = 0.8
	var modulado: Brillo = Brillo.new()
	add_child(modulado)
	_caso("el modulado de la sala toma el brillo al entrar", Brillo.instancia == modulado and modulado.color.is_equal_approx(Color(0.8, 0.8, 0.8)))
	Ajustes.brillo = 1.3
	Ajustes.aplicar_brillo()
	_caso("mover la barra cambia el modulado de la sala viva", modulado.color.is_equal_approx(Color(1.3, 1.3, 1.3)))
	modulado.free()
	_caso("al salir de la sala no queda modulado vivo", Brillo.instancia == null)
	DirAccess.remove_absolute(ruta_ajustes)
	Ajustes.temblor = Ajustes.POR_OMISION["temblor"]
	Ajustes.volumen_musica = 1.0
	Ajustes.volumen_efectos = 1.0
	Ajustes.brillo = Ajustes.BRILLO_POR_OMISION
	Ajustes.aplicar_volumen()
	# El jugador carga los ajustes al entrar (lee user://ajustes.json, sin escribirlo), sin esperar a
	# que la pausa o la vibracion lo hagan antes.
	# _cargados es la bandera de cargar_una_vez y no tiene reinicio publico: se pone a mano para ver que el
	# jugador la enciende; no vale la pena agregar uno solo para esta prueba.
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
	_guardado_fallido()
	_resumen()


# Quien juega se entera de que no se guardo: la senal sale una vez, el disquete de exito no, y el Hud muestra su texto
# hasta que un guardado sale bien. El disco lleno de verdad no se monta aqui: se probo con un tmpfs (docs/errores).
func _guardado_fallido() -> void:
	var hud: Hud = (load("res://interfaz/interfaz.tscn") as PackedScene).instantiate().find_child("Hud", true, false) as Hud
	var raiz: Node = hud.owner
	add_child(raiz)
	var fallidos: Array[int] = [0]
	var guardados: Array[int] = [0]
	var al_fallar: Callable = func(_error: int) -> void: fallidos[0] += 1
	var al_guardar: Callable = func() -> void: guardados[0] += 1
	Eventos.guardado_fallido.connect(al_fallar)
	Eventos.partida_guardada.connect(al_guardar)
	Partida.reiniciar()
	var ruta: String = Partida.ruta_guardado
	Partida.ruta_guardado = RUTA_MALA
	var antes: int = Partida.autoguardados
	_caso("autoguardar en una ruta imposible devuelve el error", Partida.autoguardar() != OK and Partida.autoguardados == antes)
	Partida.ruta_guardado = ruta
	_caso("guardar fallido avisa una vez y no avisa exito", fallidos[0] == 1 and guardados[0] == 0)
	_caso("el Hud muestra el fallo y no el disquete de exito", hud.aviso_fallo_visible and not hud.aviso_visible)
	_caso("un guardado bueno quita el aviso de fallo", Partida.guardar(RUTA) == OK and not hud.aviso_fallo_visible and hud.aviso_visible)
	# La marca de orden al inicio se escribe y al releer desaparece: es una forma fija de que lo escrito no sea lo
	# leido, como un temporal vacio por disco lleno. Con el archivo viejo esto renombraba y devolvia OK.
	_escribir(RUTA, "partida buena")
	_caso("si lo escrito no se relee igual, da error", Archivo.escribir_atomico(RUTA, char(0xFEFF) + "ab") != OK)
	_caso("y la partida anterior queda intacta, sin temporal", FileAccess.get_file_as_string(RUTA) == "partida buena" and not FileAccess.file_exists(RUTA + ".tmp"))
	var nuevo: Hud = (load("res://interfaz/interfaz.tscn") as PackedScene).instantiate().find_child("Hud", true, false) as Hud
	var raiz_nueva: Node = nuevo.owner
	Partida.ultimo_guardado_fallo = true
	add_child(raiz_nueva)
	_caso("un Hud nuevo repite el aviso de un guardado fallido", nuevo.aviso_fallo_visible)
	raiz_nueva.free()
	Partida.reiniciar()
	_caso("empezar partida olvida el guardado fallido", not Partida.ultimo_guardado_fallo)
	Eventos.guardado_fallido.disconnect(al_fallar)
	Eventos.partida_guardada.disconnect(al_guardar)
	raiz.free()
	Partida.reiniciar()
	_borrar()


# Campos que se guardan con su tipo despues del JSON: los de Guardado.ESQUEMA y los de Guardado.NUEVOS (el tipo de
# su valor por omision).
func _campos_guardados() -> Dictionary[String, int]:
	var campos: Dictionary[String, int] = {}
	for campo: String in Guardado.ESQUEMA:
		campos[campo] = Guardado.ESQUEMA[campo]
	for campo: String in Guardado.NUEVOS:
		campos[campo] = typeof(Guardado.NUEVOS[campo])
	return campos


# Las claves de Partida.a_diccionario() son exactamente las de ESQUEMA + NUEVOS: una que sobra no se valida al cargar
# y una que falta deja la partida DANADA. El nombre del caso dice cuales.
func _claves_contra_esquema() -> void:
	var campos: Dictionary[String, int] = _campos_guardados()
	Partida.reiniciar()
	var guardada: Dictionary = Partida.a_diccionario()
	var sobran: PackedStringArray = []
	for clave: Variant in guardada:
		if not campos.has(str(clave)):
			sobran.append(str(clave))
	var faltan: PackedStringArray = []
	for campo: String in campos:
		if not guardada.has(campo):
			faltan.append(campo)
	_caso("las claves de a_diccionario son las de ESQUEMA + NUEVOS (sobran: [%s]; faltan: [%s])" % [", ".join(sobran), ", ".join(faltan)],
			sobran.is_empty() and faltan.is_empty())


# Recorrido completo: cada campo guardado con un valor distinto del de reiniciar (sacado del esquema, asi un campo
# nuevo queda cubierto o hace fallar la prueba), a_diccionario -> guardar -> cargar -> reiniciar -> desde_diccionario,
# y cada campo debe volver igual. Atrapa "lo guarde pero no lo cargo".
func _recorrido_completo() -> void:
	var campos: Dictionary[String, int] = _campos_guardados()
	_aislar_partida(RUTA)
	var inicial: Dictionary = Partida.a_diccionario()
	var distinta: Dictionary = {}
	var sin_llenar: PackedStringArray = []
	for campo: String in campos:
		var valor: Variant = _valor_distinto(campo, campos[campo], inicial.get(campo))
		if valor == null:
			sin_llenar.append("%s (tipo %d)" % [campo, campos[campo]])
		else:
			distinta[campo] = valor
	Partida.desde_diccionario(distinta)
	var antes: Dictionary = Partida.a_diccionario()
	# Un campo que desde_diccionario no lee se queda como en reiniciar.
	var iguales: PackedStringArray = []
	for campo: String in campos:
		if _normalizado(antes.get(campo)) == _normalizado(inicial.get(campo)):
			iguales.append(campo)
	_caso("llenar Partida deja cada campo guardado distinto del de reiniciar (sin valor de prueba: [%s]; como en reiniciar: [%s])" % [", ".join(sin_llenar), ", ".join(iguales)],
			sin_llenar.is_empty() and iguales.is_empty())
	var escrito: Error = Guardado.guardar(antes, Partida.ruta_guardado)
	var leida: Guardado.Resultado = Guardado.cargar(Partida.ruta_guardado)
	Partida.reiniciar()
	var cambian: PackedStringArray = []
	if leida.estado == Guardado.Estado.VALIDA:
		Partida.desde_diccionario(leida.partida)
		var despues: Dictionary = Partida.a_diccionario()
		for campo: String in campos:
			if _normalizado(despues.get(campo)) != _normalizado(antes.get(campo)):
				cambian.append(campo)
	_caso("guardar, cargar y desde_diccionario devuelven cada campo como estaba (error %d, estado %d; cambian: [%s])" % [escrito, leida.estado, ", ".join(cambian)],
			escrito == OK and leida.estado == Guardado.Estado.VALIDA and cambian.is_empty())
	_restaurar_partida()


# Un valor de prueba distinto del de reiniciar, segun el tipo del campo tras el JSON; null si el tipo no se sabe
# llenar. Los numeros son enteros (vidas y monedas se leen con "as int"). Un objeto se lee por clave y su forma
# depende del campo: sale de FORMAS, y uno que no esta ahi da null.
func _valor_distinto(campo: String, tipo: int, inicial: Variant) -> Variant:
	match tipo:
		TYPE_FLOAT:
			return float(Guardado.entero(inicial, 0)) + 3.0
		TYPE_STRING:
			return "%s_prueba" % campo
		TYPE_ARRAY:
			return ["%s_prueba" % campo]
		TYPE_DICTIONARY:
			if FORMAS.has(campo):
				return (FORMAS[campo] as Dictionary).duplicate(true)
	return null


# Un valor como queda tras pasar por el JSON (enteros como float, tambien anidados), en texto con las claves ordenadas.
func _normalizado(valor: Variant) -> String:
	return JSON.stringify(JSON.parse_string(JSON.stringify(valor)), "", true)


func _fuera_de_rango(campo: String, valor: float) -> void:
	var partida: Dictionary = PARTIDA.duplicate(true)
	partida[campo] = valor
	_danada("%s en %s" % [campo, str(valor)], JSON.stringify({"version": Guardado.VERSION, "partida": partida}))


func _danada(nombre: String, contenido: String) -> void:
	_escribir(RUTA, contenido)
	_caso(nombre + " da DANADA", Guardado.cargar(RUTA).estado == Guardado.Estado.DANADA)


# Compara como JSON con las claves ordenadas, pasando la esperada por el JSON: ahi los enteros vuelven
# como float (4 -> 4.0), tambien dentro de los diccionarios anidados.
func _igual(a: Dictionary, b: Dictionary) -> bool:
	var esperada: Variant = JSON.parse_string(JSON.stringify(b))
	return JSON.stringify(a, "", true) == JSON.stringify(esperada, "", true)


func _borrar() -> void:
	_borrar_archivos(RUTA)


# Compara un Variant sin pasarlo directo a _caso (el tipado estricto no lo deja). 3.0 del JSON vale 3.
func _vale(valor: Variant, esperado: Variant) -> bool:
	var igual: bool = valor == esperado
	return igual
