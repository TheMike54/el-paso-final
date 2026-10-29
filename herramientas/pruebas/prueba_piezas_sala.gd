extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de las piezas de sala reutilizables: el recorte de FondoTapado, la oscuridad del Brillo, el parpadeo, el
# pulso y el destello de LuzSala con su luz 2D que aparece y se va al momento y su halo cortado arriba, el resorte de
# Colgante, la Niebla que obedece su ajuste y su pieza sin costura, los materiales comunes, la rafaga de
# EmisorRafaga, el panel de pruebas y ver hitbox. Deja casos y fallos para piezas_sala.guion.


func _ready() -> void:
	Ajustes.cargar_una_vez()
	var luces: bool = Ajustes.luces_avanzadas
	var niebla_real: bool = Ajustes.niebla
	var recursos: String = Ajustes.recursos

	# FondoTapado: oculto mientras la vista no pasa del fin de la pared; sus hijos se dibujan donde estaban.
	_caso("vista dentro de la pared: tapado", FondoTapado.tapado(Rect2(0.0, 0.0, 1280.0, 720.0), 2480.0))
	_caso("vista que cruza el fin de la pared: se ve", not FondoTapado.tapado(Rect2(1500.0, 0.0, 1280.0, 720.0), 2480.0))
	_caso("pared a la derecha: vista dentro de ella, tapado", FondoTapado.tapado(Rect2(3000.0, 0.0, 1280.0, 720.0), 2480.0, true))
	_caso("pared a la derecha: vista que cruza su inicio, se ve", not FondoTapado.tapado(Rect2(2000.0, 0.0, 1280.0, 720.0), 2480.0, true))
	var tapado: FondoTapado = FondoTapado.new()
	tapado.fin_pared = 2480.0
	var capa: Node2D = Node2D.new()
	capa.position = Vector2(300.0, 40.0)
	tapado.add_child(capa)
	add_child(tapado)
	_caso("el recorte empieza en el fin de la pared y la capa no se mueve", tapado.clip_contents
		and is_equal_approx(tapado.position.x, 2480.0 - FondoTapado.MARGEN)
		and capa.global_position.is_equal_approx(Vector2(300.0, 40.0)) and capa.get_parent() != tapado)

	# Oscuridad de la sala por el Brillo: multiplica, sin capa encima.
	_caso("oscuridad 0,58 con brillo 1 deja gris 0,42", Brillo.color_para(1.0, 0.58).is_equal_approx(Color(0.42, 0.42, 0.42)))
	_caso("la oscuridad se recorta de 0 a 1", Brillo.color_para(1.0, 2.0).is_equal_approx(Color.BLACK) and Brillo.color_para(1.0, -1.0).is_equal_approx(Color.WHITE))

	# LuzSala: pulso, destello y parpadeo con tiempo propio.
	Ajustes.recursos = Recursos.BAJO
	var pulso: LuzSala = _luz(LuzSala.Tipo.PULSO)
	pulso.avanzar(1.0)
	_caso("el pulso sigue medio + amplitud * sen(t * velocidad)", is_equal_approx(pulso.fuerza, 0.75 + 0.15 * sin(1.7)))
	var destello: LuzSala = _luz(LuzSala.Tipo.DESTELLO)
	_caso("el destello empieza apagado", destello.fuerza == 0.0)
	destello.destellar()
	var encendido: bool = destello.fuerza == 1.0
	destello.avanzar(LuzSala.DURACION_DESTELLO)
	_caso("el destello enciende y se apaga en su duracion", encendido and is_zero_approx(destello.fuerza))
	var parpadeo: LuzSala = _luz(LuzSala.Tipo.PARPADEO)
	var vio_apagada: bool = false
	var solo_cero_o_uno: bool = true
	for i: int in range(60 * 30):
		parpadeo.avanzar(1.0 / 60.0)
		vio_apagada = vio_apagada or parpadeo.fuerza == 0.0
		solo_cero_o_uno = solo_cero_o_uno and (parpadeo.fuerza == 0.0 or parpadeo.fuerza == 1.0)
	_caso("el parpadeo apaga y enciende, sin medias", vio_apagada and solo_cero_o_uno)
	var fuerza_antes: float = pulso.fuerza
	Congelado.pedir(20)
	await get_tree().process_frame
	_caso("en el congelado la luz no avanza", pulso.fuerza == fuerza_antes)
	Congelado.reiniciar()

	# La luz 2D: solo con luces avanzadas y Recursos en alto; aparece y se va al momento con la senal del bus.
	_caso("en bajo no hay luz 2D", pulso.get_node_or_null(^"Luz") == null)
	Ajustes.luces_avanzadas = true
	Ajustes.recursos = Recursos.ALTO
	Eventos.ajuste_grafico_cambiado.emit(Ajustes.LUCES_AVANZADAS)
	_caso("en alto con luces avanzadas aparece la luz 2D", pulso.get_node_or_null(^"Luz") is PointLight2D)
	# Como en una sala: la luz fija entra antes que el Brillo (la Sala lo crea en su _ready, despues de sus hijos).
	var fija: LuzSala = _luz(LuzSala.Tipo.FIJA)
	var brillo: Brillo = Brillo.new()
	brillo.oscuridad = 0.58
	add_child(brillo)
	await get_tree().process_frame
	var luz_fija: PointLight2D = fija.get_node_or_null(^"Luz") as PointLight2D
	_caso("la luz fija toma la oscuridad del Brillo aunque este llegue despues", luz_fija != null
		and is_equal_approx(luz_fija.energy, 0.58 * LuzSala.FUERZA_LUZ))
	brillo.queue_free()
	Ajustes.luces_avanzadas = false
	Eventos.ajuste_grafico_cambiado.emit(Ajustes.LUCES_AVANZADAS)
	await get_tree().process_frame
	_caso("al apagar las luces avanzadas la luz 2D se va", pulso.get_node_or_null(^"Luz") == null)

	# corte_arriba: el halo se ve solo desde esa altura sobre la luz hasta su pie; halo_radio cambia su lado.
	var tubo: LuzSala = LuzSala.new()
	tubo.radio = 470.0
	tubo.corte_arriba = 102.4
	add_child(tubo)
	var halo: Sprite2D = tubo.get_node(^"Halo") as Sprite2D
	var lado: float = 2.0 * 470.0 * LuzSala.HALO_RADIO
	var techo: float = (halo.offset.y - halo.region_rect.size.y / 2.0) * halo.scale.y
	var pie: float = (halo.offset.y + halo.region_rect.size.y / 2.0) * halo.scale.y
	_caso("con corte_arriba el halo va de esa altura sobre la luz a su pie", halo.region_enabled
			and absf(techo + 102.4) < 0.01 and absf(pie - lado / 2.0) < 0.01)
	_caso("el area del halo cortado es su ancho por lo que queda", absf(tubo.area_halo() - lado * (lado / 2.0 + 102.4)) < 1.0)
	var chico: LuzSala = LuzSala.new()
	chico.radio = 470.0
	chico.halo_radio = 0.4
	add_child(chico)
	var halo_chico: Sprite2D = chico.get_node(^"Halo") as Sprite2D
	_caso("sin corte el halo va entero y halo_radio fija su lado", not halo_chico.region_enabled
			and absf(halo_chico.scale.x * LuzSala.LADO - 376.0) < 0.01 and absf(chico.area_halo() - 376.0 * 376.0) < 1.0)
	tubo.queue_free()
	chico.queue_free()

	# Colgante: el empuje lo saca del reposo y el freno lo devuelve.
	var colgante: Colgante = Colgante.new()
	colgante.vaiven = 0.0
	add_child(colgante)
	colgante.avanzar(1.0 / 60.0, colgante.fuerza)
	var empujado: bool = colgante.rotation > 0.0
	for i: int in range(60 * 20):
		colgante.avanzar(1.0 / 60.0, 0.0)
	_caso("el colgante empujado se mece y vuelve al reposo", empujado and absf(colgante.rotation) < 0.001)

	# Niebla: oculta y sin proceso con el ajuste apagado; se ve y avanza al encenderlo, al momento.
	Ajustes.niebla = false
	var niebla: Niebla = Niebla.new()
	add_child(niebla)
	_caso("con la niebla apagada no se ve ni avanza", not niebla.visible and not niebla.is_processing())
	Ajustes.niebla = true
	Eventos.ajuste_grafico_cambiado.emit(Ajustes.NIEBLA)
	_caso("al encender la niebla se ve y avanza", niebla.visible and niebla.is_processing())
	# La pieza nucleo/piezas/niebla.tscn: ruido horneado (nada que generar al cargar) y una vuelta sin costura: la
	# banda mide lo que repite el Parallax2D y lo que avanza la Niebla antes de volver, y cubre 1760 px (22:9). Con
	# repeat_times 1 el motor deja una sola copia a la derecha y la Deriva abre un hueco a la izquierda del tamano de su
	# avance (docs/errores/2026-10-27-hueco-niebla.md): hacen falta 2.
	Ajustes.niebla = false
	var pieza: Parallax2D = (load("res://nucleo/piezas/niebla.tscn") as PackedScene).instantiate() as Parallax2D
	add_child(pieza)
	var deriva: Niebla = pieza.get_node(^"Deriva") as Niebla
	var banda: Sprite2D = pieza.get_node(^"Deriva/Banda") as Sprite2D
	var ancho_banda: float = banda.texture.get_width() * banda.scale.x
	_caso("la pieza de niebla nace oculta, con el ruido horneado y sin costura", not deriva.visible
		and not deriva.is_processing() and banda.texture is CompressedTexture2D
		and is_equal_approx(pieza.repeat_size.x, ancho_banda) and is_equal_approx(deriva.recorrido, ancho_banda)
		and ancho_banda >= 1760.0 and pieza.repeat_times >= 2)
	pieza.free()
	# Un solo material de cada tipo: el de las funciones es el .tres que nombran las escenas.
	var aditivo: CanvasItemMaterial = LuzSala.material_aditivo()
	var sin_luz: CanvasItemMaterial = EfectoCuadros.material_sin_luz()
	_caso("los materiales comunes son los .tres de nucleo/arte", aditivo.resource_path == "res://nucleo/arte/aditivo.tres"
		and aditivo.blend_mode == CanvasItemMaterial.BLEND_MODE_ADD
		and aditivo.light_mode == CanvasItemMaterial.LIGHT_MODE_UNSHADED
		and sin_luz.resource_path == "res://nucleo/arte/sin_luz.tres"
		and sin_luz.blend_mode == CanvasItemMaterial.BLEND_MODE_MIX
		and sin_luz.light_mode == CanvasItemMaterial.LIGHT_MODE_UNSHADED)
	Ajustes.niebla = true

	# EmisorRafaga: disparo unico, apagado hasta la rafaga; la rafaga enciende su destello.
	var emisor: EmisorRafaga = EmisorRafaga.new()
	var luz_emisor: LuzSala = _luz(LuzSala.Tipo.DESTELLO)
	emisor.destello = luz_emisor
	add_child(emisor)
	var quieto: bool = emisor.one_shot and not emisor.emitting and emisor.explosiveness == 1.0
	emisor.disparar()
	_caso("el emisor espera apagado y la rafaga emite y destella", quieto and emisor.emitting and luz_emisor.fuerza == 1.0)

	Ajustes.luces_avanzadas = luces
	# Panel de pruebas: arma un boton por grupo que la sala tiene y cada uno apaga y enciende sus nodos.
	var modo: bool = Ajustes.modo_desarrollador
	var panel_real: bool = Ajustes.panel_pruebas
	Ajustes.modo_desarrollador = false
	Ajustes.panel_pruebas = true
	# Sin fondo tapado en el arbol: el panel no debe ofrecer Fondos.
	tapado.free()
	var sala: Node2D = Node2D.new()
	add_child(sala)
	var particulas: CPUParticles2D = CPUParticles2D.new()
	sala.add_child(particulas)
	var panel: PanelPruebas = PanelPruebas.new()
	sala.add_child(panel)
	await get_tree().process_frame
	var filas: Node = panel.find_child("Filas", true, false)
	_caso("sin el modo desarrollador el panel no se ve", not panel.visible)
	Ajustes.modo_desarrollador = true
	Eventos.ajuste_grafico_cambiado.emit(Ajustes.MODO_DESARROLLADOR)
	_caso("con el modo y el ajuste se ve, cerrado en la pestana", panel.visible and not (panel.find_child("Tarjeta", true, false) as Control).visible)
	_caso("un boton por grupo presente (luces y particulas), ninguno de lo que no hay", filas.get_node_or_null(^"Luces") != null
		and filas.get_node_or_null(^"Partículas") != null and filas.get_node_or_null(^"Fondos") == null)
	(filas.get_node(^"Luces") as Button).pressed.emit()
	_caso("apagar Luces oculta y detiene cada luz", not pulso.visible and pulso.process_mode == Node.PROCESS_MODE_DISABLED
		and (filas.get_node(^"Luces") as Button).text.begins_with("·"))
	(filas.get_node(^"Luces") as Button).pressed.emit()
	panel.apagar("Partículas", true)
	_caso("encenderlas las devuelve y Partículas toma los emisores de la sala", pulso.visible and pulso.process_mode == Node.PROCESS_MODE_INHERIT and not particulas.visible)
	# Encender un grupo lo deja como estaba, no visible: la niebla con su ajuste apagado sigue oculta.
	Ajustes.niebla = false
	Eventos.ajuste_grafico_cambiado.emit(Ajustes.NIEBLA)
	panel.apagar("Niebla", true)
	panel.apagar("Niebla", false)
	_caso("encender Niebla con su ajuste apagado la deja oculta", not niebla.visible and niebla.process_mode == Node.PROCESS_MODE_INHERIT)

	# Ver hitbox: color por dueno y solo con el modo desarrollador y su ajuste.
	var duenos: Array[Node] = [DanoContacto.new(), StaticBody2D.new(), CharacterBody2D.new()]
	_caso("ver hitbox: rojo lo que dana, verde el escenario, azul los cuerpos", VerHitbox.color_de(duenos[0]) == VerHitbox.DANINO
		and VerHitbox.color_de(duenos[1]) == VerHitbox.ESCENARIO and VerHitbox.color_de(duenos[2]) == VerHitbox.CUERPO)
	for dueno: Node in duenos:
		dueno.free()
	var ver_real: bool = Ajustes.ver_hitbox
	Ajustes.ver_hitbox = false
	var hitbox: VerHitbox = VerHitbox.new()
	sala.add_child(hitbox)
	var oculto: bool = not hitbox.visible and not hitbox.is_processing()
	Ajustes.ver_hitbox = true
	Eventos.ajuste_grafico_cambiado.emit(Ajustes.VER_HITBOX)
	_caso("ver hitbox se enciende al momento con su ajuste", oculto and hitbox.visible and hitbox.is_processing())

	Ajustes.ver_hitbox = ver_real
	Ajustes.modo_desarrollador = modo
	Ajustes.panel_pruebas = panel_real
	Ajustes.niebla = niebla_real
	Ajustes.recursos = recursos
	_resumen()


func _luz(tipo: LuzSala.Tipo) -> LuzSala:
	var luz: LuzSala = LuzSala.new()
	luz.tipo = tipo
	luz.semilla = 7
	add_child(luz)
	return luz
