extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba del AvisoAccion sobre la sala Pizarrones: fuera no se ve; dentro espera TICKS_ESPERA y aparece en
# TICKS_APARECER; con el control, el IconoBoton y, tras un toque, el boton de la pantalla, que late. Hecha la accion se
# va tras TICKS_MINIMO, se marca y no vuelve; hecha antes no sale; curar cuenta al curar. ControlesTactiles: late solo
# el resaltado, nunca sin su habilidad ni hablando. Su guion lee "valor . casos" y "valor . fallos".
const SALA: String = "res://herramientas/salas/sala_pizarrones.tscn"


func _ready() -> void:
	Partida.reiniciar()
	var sala: Sala = await _abrir_sala()
	var jugador: Jugador = sala.get_node(^"Jugador") as Jugador
	var saltar: AvisoAccion = sala.get_node(^"AvisoSaltar") as AvisoAccion
	var controles: ControlesTactiles = sala.find_children("*", "ControlesTactiles", true, false)[0] as ControlesTactiles
	_caso("la sala empieza con una vida menos, para poder curar", Partida.vidas == Partida.vidas_maximas - 1)
	_caso("se empieza sin los botones de saltar, atacar ni curar", controles.por_ensenar(&"saltar")
			and controles.por_ensenar(&"atacar") and controles.por_ensenar(&"curar") and not controles.por_ensenar(&"pausa"))
	_poner(jugador, Vector2(700.0, 680.0))
	await _esperar(AvisoAccion.TICKS_APARECER + 2)
	_caso("fuera de su zona no se ve", not saltar.dentro and saltar.alfa == 0.0)

	# Con el control: espera y despues el boton de su accion con su palabra.
	await _usar(true)
	# Un cuerpo puesto a mano entra en la lista de un area unos 3 ticks despues.
	_poner(jugador, Vector2(1000.0, 680.0))
	await _esperar(4)
	_caso("dentro no aparece antes de TICKS_ESPERA", saltar.dentro and saltar.alfa == 0.0)
	await _esperar(AvisoAccion.TICKS_ESPERA)
	_caso("tras la espera empieza a aparecer", saltar.alfa > 0.0 and saltar.alfa < 1.0)
	_caso("al aparecer ensena su boton y curar sigue oculto", not controles.por_ensenar(&"saltar")
			and controles.por_ensenar(&"curar") and Partida.botones_ensenados == [&"saltar"])
	await _esperar(AvisoAccion.TICKS_APARECER)
	var iconos: Array[IconoBoton] = _iconos(saltar)
	_caso("aparece entero en TICKS_APARECER", saltar.alfa == 1.0)
	_caso("con el control dibuja el boton con su palabra", iconos.size() == 1 and iconos[0].accion == &"saltar"
			and iconos[0].texto == "Saltar" and _iconos_en(iconos, true))
	_caso("con el control no late ningun boton de la pantalla", ControlesTactiles.resaltada == &"" and not controles.latiendo)

	# Tras un toque: el boton de la pantalla, que late.
	await _usar(false)
	await _esperar(2)
	_caso("tras un toque se ocultan los iconos del control", not _iconos_en(iconos, true))
	_caso("tras un toque late el boton de su accion", ControlesTactiles.resaltada == &"saltar" and controles.latiendo)

	# Al salir se va y deja de latir.
	_poner(jugador, Vector2(700.0, 680.0))
	await _esperar(AvisoAccion.TICKS_APARECER + 2)
	_caso("al salir se va y deja de latir", saltar.alfa == 0.0 and ControlesTactiles.resaltada == &"" and not controles.latiendo)

	# Hacer la accion con el dibujo a la vista: sigue hasta TICKS_MINIMO, se va aunque siga dentro y deja la marca.
	_poner(jugador, Vector2(1000.0, 680.0))
	await _esperar(4 + AvisoAccion.TICKS_ESPERA + AvisoAccion.TICKS_APARECER)
	await _presionar(&"saltar")
	_caso("saltar lo da por hecho y lo marca", saltar.hecha and Partida.estado_de(sala.clave(), "aviso_saltar") != null)
	_caso("hecho sigue a la vista y deja de latir", saltar.alfa == 1.0 and ControlesTactiles.resaltada == &"")
	await _esperar(AvisoAccion.TICKS_MINIMO + AvisoAccion.TICKS_APARECER)
	_caso("hecho se va tras TICKS_MINIMO aunque siga dentro", saltar.dentro and saltar.alfa == 0.0)

	# Hecho antes de entrar: atacar lejos de su pizarron y no sale.
	var atacar: AvisoAccion = sala.get_node(^"AvisoAtacar") as AvisoAccion
	_poner(jugador, Vector2(700.0, 680.0))
	await _esperar(2)
	await _presionar(&"atacar")
	_poner(jugador, Vector2(1600.0, 680.0))
	await _esperar(4 + AvisoAccion.TICKS_ESPERA + AvisoAccion.TICKS_APARECER)
	_caso("hecho antes de entrar no aparece", atacar.dentro and atacar.hecha and atacar.alfa == 0.0)

	# Pulsar con una conversacion abierta (la avanza o la cierra) no cuenta: interactuar no da por hecho Sentarse.
	var sentarse: AvisoAccion = sala.get_node(^"AvisoSentarse") as AvisoAccion
	ControlesTactiles.hablando = true
	await _presionar(&"interactuar")
	ControlesTactiles.hablando = false
	_caso("avanzar una conversacion no cuenta como la accion", not sentarse.hecha)

	# Curar: un toque no cura y no lo apaga; curar una vida si. La nota va con el boton.
	var curar: AvisoAccion = sala.get_node(^"AvisoCurar") as AvisoAccion
	_poner(jugador, Vector2(2850.0, 680.0))
	await _esperar(4 + AvisoAccion.TICKS_ESPERA + AvisoAccion.TICKS_APARECER)
	_caso("al aparecer su pizarron el boton de curar ya se ve", not controles.por_ensenar(&"curar"))
	await _presionar(&"curar")
	_caso("un toque de curar no lo apaga", curar.alfa == 1.0 and not curar.hecha)
	Partida.vidas = Partida.vidas_maximas - 1
	Partida.inspiracion = jugador.costo_curacion
	Input.action_press(&"curar")
	await _esperar(jugador.ticks_mantener_poder + jugador.ticks_curacion + 4)
	Input.action_release(&"curar")
	await _esperar(1)
	_caso("curar una vida lo da por hecho", curar.hecha and Partida.vidas == Partida.vidas_maximas)

	# Sentarse va con el joystick arriba: se ve, sin caja ni latido, y la palabra es la suya.
	_poner(jugador, Vector2(3200.0, 680.0))
	await _esperar(4 + AvisoAccion.TICKS_ESPERA + AvisoAccion.TICKS_APARECER)
	_caso("sentarse se ve con su palabra y no hace latir ningun boton", sentarse.alfa == 1.0
			and sentarse.palabra() == "Sentarse" and ControlesTactiles.resaltada == &"" and not controles.latiendo)

	# ControlesTactiles: un boton sin su habilidad (impulso) no late, ni hablando.
	ControlesTactiles.resaltada = &"impulso"
	await _esperar(2)
	_caso("un boton sin su habilidad no late", not controles.latiendo)
	ControlesTactiles.resaltada = &"atacar"
	await _esperar(2)
	_caso("con la pluma el de atacar si late", controles.latiendo)
	ControlesTactiles.hablando = true
	await _esperar(2)
	_caso("hablando no late", not controles.latiendo)
	# Pausa sigue disponible hablando: no late por la condicion propia del latido.
	ControlesTactiles.resaltada = &"pausa"
	await _esperar(2)
	_caso("hablando no late ni la pausa", not controles.latiendo)
	ControlesTactiles.hablando = false
	ControlesTactiles.resaltada = &""

	# Con la marca, al volver a la sala no aparece.
	sala.free()
	sala = await _abrir_sala()
	jugador = sala.get_node(^"Jugador") as Jugador
	saltar = sala.get_node(^"AvisoSaltar") as AvisoAccion
	_poner(jugador, Vector2(1000.0, 680.0))
	await _esperar(4 + AvisoAccion.TICKS_ESPERA + AvisoAccion.TICKS_APARECER)
	_caso("con la marca, al volver no aparece", saltar.hecha and saltar.dentro and saltar.alfa == 0.0)

	# Al salir del arbol con el jugador dentro, el aviso suelta el resalto.
	sala.free()
	Partida.reiniciar()
	sala = await _abrir_sala()
	jugador = sala.get_node(^"Jugador") as Jugador
	_poner(jugador, Vector2(1000.0, 680.0))
	await _esperar(4 + AvisoAccion.TICKS_ESPERA + AvisoAccion.TICKS_APARECER)
	var resaltaba: bool = ControlesTactiles.resaltada == &"saltar"
	sala.free()
	_caso("al quitar la sala se suelta el resalto", resaltaba and ControlesTactiles.resaltada == &"")
	Partida.reiniciar()
	_resumen()


func _abrir_sala() -> Sala:
	var sala: Sala = (load(SALA) as PackedScene).instantiate() as Sala
	add_child(sala)
	await _esperar(3)
	return sala


func _poner(jugador: Jugador, punto: Vector2) -> void:
	jugador.global_position = punto
	jugador.velocity = Vector2.ZERO
