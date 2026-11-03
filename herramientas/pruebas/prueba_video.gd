extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de las salidas de ReproductorVideo que no piden un telefono: un video sin bucle que no se puede reproducir
# (sin .ogv ni .jpg, o con un error de MediaPlayer) termina y la cinematica pasa a su sala; uno con bucle se queda;
# y un detener() antes del fin sin ventana no lo termina. Deja casos y fallos para
# video.guion.

const SIN_ARCHIVOS: String = "res://herramientas/pruebas/no_existe"

var _fines: int = 0


func _ready() -> void:
	var cinematica: ReproductorVideo = _crear(false)
	cinematica._pasar_a_respaldo()
	await _esperar(2)
	_caso("sin video ni imagen, uno sin bucle termina (la cinematica pasa a la sala)", _fines == 1)
	_caso("y no deja imagen de respaldo", cinematica.get_node_or_null(^"Respaldo") == null)

	_fines = 0
	var menu: ReproductorVideo = _crear(true)
	menu._pasar_a_respaldo()
	await _esperar(2)
	_caso("uno con bucle (el menu) no termina: queda en negro", _fines == 0)

	_fines = 0
	var trabado: ReproductorVideo = _crear(false)
	trabado._fallo(1, -1004)
	await _esperar(2)
	_caso("un error de MediaPlayer a mitad termina la cinematica", _fines == 1)

	_fines = 0
	var detenido: ReproductorVideo = _crear(false)
	detenido.reproducir()
	detenido.detener()
	await get_tree().create_timer(ReproductorVideo.DURACION_SIN_VENTANA + 0.2).timeout
	_caso("detenido antes de su fin sin ventana, no termina", _fines == 0)

	_fines = 0
	var dos_veces: ReproductorVideo = _crear(false)
	dos_veces.reproducir()
	dos_veces.reproducir()
	await get_tree().create_timer(ReproductorVideo.DURACION_SIN_VENTANA + 0.2).timeout
	_caso("reproducir dos veces termina una sola vez", _fines == 1)
	_resumen()


func _crear(bucle: bool) -> ReproductorVideo:
	var video: ReproductorVideo = ReproductorVideo.crear(SIN_ARCHIVOS, bucle, AspectRatioContainer.STRETCH_COVER)
	add_child(video)
	video.terminado.connect(func() -> void: _fines += 1)
	return video
