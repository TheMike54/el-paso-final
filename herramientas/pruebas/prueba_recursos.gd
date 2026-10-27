extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del modo de recursos: la regla de la deteccion (32 bits o poca memoria), el modo en vigor segun el
# ajuste, que lo prescindible desaparezca solo en bajo, que plantas y niebla se queden quietas en bajo y en el
# congelado comun y se muevan en alto, y que el ajuste se guarde (un valor raro vuelve a auto). Deja casos y fallos para
# recursos_cuentas.guion. Imprime el resumen y los fallos.

const RUTA: String = "user://prueba_recursos.json"
const GB: int = 1024 * 1024 * 1024


func _ready() -> void:
	Ajustes.cargar_una_vez()
	var real: String = Ajustes.recursos
	# La niebla solo se ve y avanza con su ajuste (apagado por omision): aqui se mide su movimiento.
	Ajustes.niebla = true
	_caso("32 bits es debil aunque sobre memoria", Recursos.debil_segun(true, 8 * GB))
	_caso("2 GB de memoria es debil", Recursos.debil_segun(false, 2 * GB))
	_caso("64 bits y 8 GB no es debil", not Recursos.debil_segun(false, 8 * GB))
	_caso("memoria desconocida (0 o -1, lo que da el motor sin dato) no cuenta", not Recursos.debil_segun(false, 0) and not Recursos.debil_segun(false, -1))
	_caso("Android lo marca de poca memoria: debil aunque la memoria no se sepa o sobre", Recursos.debil_segun(false, 0, true) and Recursos.debil_segun(false, 8 * GB, true))
	_caso("MemTotal de /proc/meminfo en bytes (S50: 1978704 kB)", Recursos.memoria_de_meminfo("MemTotal:        1978704 kB\nMemFree:  208868 kB") == 1978704 * 1024)
	_caso("un meminfo sin MemTotal, vacio o con basura da 0", Recursos.memoria_de_meminfo("MemFree: 5 kB") == 0 and Recursos.memoria_de_meminfo("") == 0 and Recursos.memoria_de_meminfo("MemTotal: x kB") == 0)
	Ajustes.recursos = Recursos.BAJO
	_caso("alto en un telefono debil avisa", Recursos.avisar(Recursos.ALTO, true))
	_caso("bajo o auto en un telefono debil, o alto en uno fuerte, no avisan", not Recursos.avisar(Recursos.BAJO, true) and not Recursos.avisar(Recursos.AUTO, true) and not Recursos.avisar(Recursos.ALTO, false))
	_caso("con el ajuste en bajo, bajos", Recursos.bajos())
	Ajustes.recursos = Recursos.ALTO
	_caso("con el ajuste en alto, no", not Recursos.bajos())
	Ajustes.recursos = Recursos.AUTO
	_caso("en auto decide la deteccion", Recursos.bajos() == Recursos.es_debil())

	Ajustes.recursos = Recursos.BAJO
	var adorno: Node2D = _con_prescindible()
	_caso("en bajo, lo prescindible desaparece", adorno.is_queued_for_deletion())
	var planta: Planta = _planta()
	var niebla: Niebla = _niebla()
	# Un cuadro de _process para las dos. Tras un await, la prueba sigue en process_frame, antes del _process de
	# ese cuadro: entre dos await corre justo uno (con --fixed-fps 60, delta 1/60).
	await get_tree().process_frame
	_caso("en bajo, la planta no se mece y la niebla no avanza", planta.rotation == 0.0 and niebla.position == Vector2.ZERO)
	Ajustes.recursos = Recursos.ALTO
	adorno = _con_prescindible()
	_caso("en alto, lo prescindible se queda", not adorno.is_queued_for_deletion())
	planta = _planta()
	niebla = _niebla()
	await get_tree().process_frame
	_caso("en alto, la planta se mece y la niebla avanza", planta.rotation != 0.0 and niebla.position.x > 0.0)
	# El congelado del parry (20 ticks) las detiene; al terminar siguen. Terminarlo antes es reiniciar(), que
	# tambien deja limpia la estatica para lo que corra despues.
	var tiempo: float = planta.tiempo
	var posicion: Vector2 = niebla.position
	Congelado.pedir(20)
	await get_tree().process_frame
	_caso("en el congelado la planta y la niebla no avanzan", planta.tiempo == tiempo and niebla.position == posicion)
	Congelado.reiniciar()
	await get_tree().process_frame
	_caso("al terminar el congelado siguen", planta.tiempo > tiempo and niebla.position != posicion)

	Ajustes.recursos = Recursos.ALTO
	Ajustes.guardar(RUTA)
	Ajustes.cargar(RUTA)
	_caso("el ajuste se guarda y se lee", Ajustes.recursos == Recursos.ALTO)
	var archivo: FileAccess = FileAccess.open(RUTA, FileAccess.WRITE)
	archivo.store_string('{"version": 1, "ajustes": {"recursos": "maximo"}}')
	archivo.close()
	Ajustes.cargar(RUTA)
	_caso("un valor raro vuelve a auto", Ajustes.recursos == Recursos.AUTO)

	for ruta: String in [RUTA, RUTA + ".tmp"]:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ruta)
	Ajustes.cargar()
	Ajustes.recursos = real
	_resumen()


func _con_prescindible() -> Node2D:
	var adorno: Node2D = Node2D.new()
	adorno.add_child(Prescindible.new())
	add_child(adorno)
	return adorno


func _planta() -> Planta:
	var planta: Planta = Planta.new()
	add_child(planta)
	return planta


func _niebla() -> Niebla:
	var niebla: Niebla = Niebla.new()
	add_child(niebla)
	return niebla
