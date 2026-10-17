extends "res://herramientas/salas/prueba_base.gd"
# Prueba de los botones del control en la interfaz: la familia del control por nombre y GUID, el dibujo de cada accion
# para Xbox, PlayStation y el teclado (con lo reasignado), lo que anota UltimaEntrada y que un IconoBoton se esconda
# tras un toque y se vea con el teclado. Su guion lee "valor . casos" y "valor . fallos".


func _ready() -> void:
	# Familia: el GUID de SDL con el fabricante Sony (054c) o el nombre; lo demas, Xbox.
	_caso("GUID de Sony es PlayStation", Mando.familia("", "030000004c050000c405000000010000") == Mando.PLAYSTATION)
	_caso("PS4 Controller es PlayStation", Mando.familia("PS4 Controller", "") == Mando.PLAYSTATION)
	_caso("DualSense por nombre es PlayStation", Mando.familia("DualSense Wireless Controller", "") == Mando.PLAYSTATION)
	_caso("Xbox Wireless Controller es Xbox", Mando.familia("Xbox Wireless Controller", "030000005e040000e002000000000000") == Mando.XBOX)
	_caso("un control sin nombre es Xbox", Mando.familia("", "") == Mando.XBOX)

	# Dibujo por accion y familia.
	Mando.por_omision()
	_caso("saltar con Xbox es el disco A", IconoBoton.dibujo(&"saltar", Mando.XBOX) == {"forma": IconoBoton.DISCO, "texto": "A", "simbolo": ""})
	_caso("saltar con PlayStation es la cruz", (IconoBoton.dibujo(&"saltar", Mando.PLAYSTATION)["simbolo"] as String) == "cruz")
	_caso("volver con PlayStation es el circulo", (IconoBoton.dibujo(&"volver", Mando.PLAYSTATION)["simbolo"] as String) == "circulo")
	_caso("pagina_anterior es la pastilla L1 o LB", (IconoBoton.dibujo(&"pagina_anterior", Mando.PLAYSTATION)["texto"] as String) == "L1" and (IconoBoton.dibujo(&"pagina_anterior", Mando.XBOX)["texto"] as String) == "LB")
	_caso("impulso (eje) es R2 o RT", (IconoBoton.dibujo(&"impulso", Mando.PLAYSTATION)["texto"] as String) == "R2" and (IconoBoton.dibujo(&"impulso", Mando.XBOX)["texto"] as String) == "RT")
	_caso("con el teclado, saltar es la tecla W", IconoBoton.dibujo(&"saltar", UltimaEntrada.TECLADO) == {"forma": IconoBoton.PASTILLA, "texto": "W", "simbolo": ""})
	_caso("tras un toque no se dibuja nada", IconoBoton.dibujo(&"saltar", UltimaEntrada.TOQUE).is_empty())
	_caso("volver no tiene tecla: con el teclado no se dibuja", IconoBoton.dibujo(&"volver", UltimaEntrada.TECLADO).is_empty())
	var antes: int = Mando.cambios
	Mando.asignar(&"saltar", JOY_BUTTON_X)
	_caso("reasignar saltar a X cambia su dibujo al cuadrado y sube Mando.cambios", (IconoBoton.dibujo(&"saltar", Mando.PLAYSTATION)["simbolo"] as String) == "cuadrado" and Mando.cambios > antes)
	Mando.por_omision()

	# UltimaEntrada anota que se uso.
	var tecla: InputEventKey = InputEventKey.new()
	tecla.pressed = true
	UltimaEntrada.anotar(tecla)
	_caso("una tecla deja el teclado", UltimaEntrada.dispositivo == UltimaEntrada.TECLADO)
	var boton: InputEventJoypadButton = InputEventJoypadButton.new()
	boton.pressed = true
	UltimaEntrada.anotar(boton)
	# La del control 0: sin control conectado (CI) no hay nombre ni GUID y cuenta como Xbox.
	_caso("un boton del control deja su familia", UltimaEntrada.dispositivo == Mando.familia(Input.get_joy_name(0), Input.get_joy_guid(0)))
	var toque: InputEventScreenTouch = InputEventScreenTouch.new()
	toque.pressed = true
	UltimaEntrada.anotar(toque)
	_caso("un toque deja TOQUE", UltimaEntrada.dispositivo == UltimaEntrada.TOQUE)

	# El nodo: escondido tras el toque, visible con su medida al usar el teclado, y se pone al dia solo.
	var icono: IconoBoton = IconoBoton.new()
	icono.theme = Tema.crear()
	icono.accion = &"saltar"
	icono.texto = "Saltar"
	add_child(icono)
	await _esperar(1)
	_caso("tras un toque el icono no se ve", not icono.visible)
	UltimaEntrada.anotar(tecla)
	# process_frame sale antes de los _process de ese cuadro: se esperan dos.
	await get_tree().process_frame
	await get_tree().process_frame
	_caso("con el teclado el icono se ve y mide el boton y el texto", icono.visible and icono.custom_minimum_size.x > Tema.ALTO_LETRA and is_equal_approx(icono.custom_minimum_size.y, Tema.ALTO_LETRA))
	UltimaEntrada.anotar(toque)
	await get_tree().process_frame
	await get_tree().process_frame
	_caso("al volver a tocar se esconde otra vez", not icono.visible)
	_resumen()
