extends "res://herramientas/pruebas/prueba_base.gd"
# Prueba de los botones del control en la interfaz: la familia del control por nombre y GUID, el dibujo de cada accion
# para Xbox, PlayStation y el teclado (con lo reasignado), lo que anota UltimaEntrada, que un IconoBoton se esconda tras
# un toque, se vea con el teclado y se ponga al dia por el bus y al volver al arbol, los nombres de Mando.BOTONES contra
# los de antes y las reglas UltimaEntrada.marca_teclado y es_de_juego. Su guion lee "valor . casos" y "valor . fallos".

# Cuantas veces salio cada senal del bus mientras se escuchaba (Eventos.mando_cambiado y dispositivo_cambiado).
var _avisos_mando: int = 0
var _avisos_dispositivo: Array[int] = []


func _ready() -> void:
	# Familia: el GUID de SDL con el fabricante Sony (054c) o el nombre; lo demas, Xbox.
	_caso("GUID de Sony es PlayStation", Mando.familia("", "030000004c050000c405000000010000") == Mando.Dispositivo.PLAYSTATION)
	_caso("PS4 Controller es PlayStation", Mando.familia("PS4 Controller", "") == Mando.Dispositivo.PLAYSTATION)
	_caso("DualSense por nombre es PlayStation", Mando.familia("DualSense Wireless Controller", "") == Mando.Dispositivo.PLAYSTATION)
	_caso("Xbox Wireless Controller es Xbox", Mando.familia("Xbox Wireless Controller", "030000005e040000e002000000000000") == Mando.Dispositivo.XBOX)
	_caso("un control sin nombre es Xbox", Mando.familia("", "") == Mando.Dispositivo.XBOX)

	# Dibujo por accion y familia.
	Mando.por_omision()
	_caso("saltar con Xbox es el disco A", IconoBoton.dibujo(&"saltar", Mando.Dispositivo.XBOX) == {"forma": IconoBoton.DISCO, "texto": "A", "simbolo": ""})
	_caso("saltar con PlayStation es la cruz", (IconoBoton.dibujo(&"saltar", Mando.Dispositivo.PLAYSTATION)["simbolo"] as String) == "cruz")
	_caso("volver con PlayStation es el circulo", (IconoBoton.dibujo(&"volver", Mando.Dispositivo.PLAYSTATION)["simbolo"] as String) == "circulo")
	_caso("pagina_anterior es la pastilla L1 o LB", (IconoBoton.dibujo(&"pagina_anterior", Mando.Dispositivo.PLAYSTATION)["texto"] as String) == "L1" and (IconoBoton.dibujo(&"pagina_anterior", Mando.Dispositivo.XBOX)["texto"] as String) == "LB")
	_caso("impulso (eje) es R2 o RT", (IconoBoton.dibujo(&"impulso", Mando.Dispositivo.PLAYSTATION)["texto"] as String) == "R2" and (IconoBoton.dibujo(&"impulso", Mando.Dispositivo.XBOX)["texto"] as String) == "RT")
	_caso("con el teclado, saltar es la tecla W", IconoBoton.dibujo(&"saltar", Mando.Dispositivo.TECLADO) == {"forma": IconoBoton.PASTILLA, "texto": "W", "simbolo": ""})
	_caso("tras un toque no se dibuja nada", IconoBoton.dibujo(&"saltar", Mando.Dispositivo.TOQUE).is_empty())
	_caso("volver no tiene tecla: con el teclado no se dibuja", IconoBoton.dibujo(&"volver", Mando.Dispositivo.TECLADO).is_empty())
	var antes: int = Mando.cambios
	Mando.asignar(&"saltar", JOY_BUTTON_X)
	_caso("reasignar saltar a X cambia su dibujo al cuadrado y sube Mando.cambios", (IconoBoton.dibujo(&"saltar", Mando.Dispositivo.PLAYSTATION)["simbolo"] as String) == "cuadrado" and Mando.cambios > antes)
	Mando.por_omision()

	# UltimaEntrada anota que se uso.
	var tecla: InputEventKey = InputEventKey.new()
	tecla.pressed = true
	UltimaEntrada.anotar(tecla)
	_caso("una tecla deja el teclado", UltimaEntrada.dispositivo == Mando.Dispositivo.TECLADO)
	var boton: InputEventJoypadButton = InputEventJoypadButton.new()
	boton.pressed = true
	UltimaEntrada.anotar(boton)
	# La del control 0: sin control conectado (CI) no hay nombre ni GUID y cuenta como Xbox.
	_caso("un boton del control deja su familia", UltimaEntrada.dispositivo == Mando.familia(Input.get_joy_name(0), Input.get_joy_guid(0)))
	var toque: InputEventScreenTouch = InputEventScreenTouch.new()
	toque.pressed = true
	UltimaEntrada.anotar(toque)
	_caso("un toque deja TOQUE", UltimaEntrada.dispositivo == Mando.Dispositivo.TOQUE)

	# clasificar: que dispositivo dice cada evento, sin anotarlo. El device 7 no es un control real (ni en el CI ni en
	# la PC): su familia es Xbox, la de un control sin nombre.
	var sin_nombre: Mando.Dispositivo = Mando.familia(Input.get_joy_name(7), Input.get_joy_guid(7))
	_caso("clasificar un toque apoyado da TOQUE", UltimaEntrada.clasificar(toque) == Mando.Dispositivo.TOQUE)
	var levantado: InputEventScreenTouch = InputEventScreenTouch.new()
	_caso("clasificar un toque levantado no cambia nada", UltimaEntrada.clasificar(levantado) == UltimaEntrada.SIN_CAMBIO)
	_caso("clasificar una tecla da TECLADO", UltimaEntrada.clasificar(tecla) == Mando.Dispositivo.TECLADO)
	var boton_7: InputEventJoypadButton = InputEventJoypadButton.new()
	boton_7.device = 7
	boton_7.pressed = true
	_caso("clasificar un boton del control da su familia", UltimaEntrada.clasificar(boton_7) == sin_nombre)
	var eje: InputEventJoypadMotion = InputEventJoypadMotion.new()
	eje.device = 7
	eje.axis_value = 0.4
	_caso("clasificar un stick bajo la mitad no cambia nada", UltimaEntrada.clasificar(eje) == UltimaEntrada.SIN_CAMBIO)
	eje.axis_value = -0.6
	_caso("clasificar un stick sobre la mitad da su familia", UltimaEntrada.clasificar(eje) == sin_nombre)
	var clic: InputEventMouseButton = InputEventMouseButton.new()
	clic.pressed = true
	_caso("clasificar un clic da TOQUE fuera de Android y nada en Android (raton real)", UltimaEntrada.clasificar(clic) == Mando.Dispositivo.TOQUE
			and UltimaEntrada.clasificar(clic, true) == UltimaEntrada.SIN_CAMBIO)
	_caso("clasificar no anota", UltimaEntrada.dispositivo == Mando.Dispositivo.TOQUE)

	# Las dos reglas de que entrada cuenta (marca_teclado y es_de_juego) no son la misma: Atras y el volumen marcan el
	# teclado pero no son del juego. W es saltar (Mando.por_omision arriba); Enter solo es ui_accept.
	var volumen: InputEventKey = InputEventKey.new()
	volumen.keycode = KEY_VOLUMEUP
	volumen.physical_keycode = KEY_VOLUMEUP
	volumen.pressed = true
	_caso("el volumen marca el teclado pero no es de juego", UltimaEntrada.marca_teclado(volumen) and not UltimaEntrada.es_de_juego(volumen))
	var atras: InputEventKey = InputEventKey.new()
	atras.keycode = KEY_BACK
	atras.physical_keycode = KEY_BACK
	atras.pressed = true
	_caso("Atras marca el teclado pero no es de juego", UltimaEntrada.marca_teclado(atras) and not UltimaEntrada.es_de_juego(atras))
	var w: InputEventKey = InputEventKey.new()
	w.physical_keycode = KEY_W
	w.pressed = true
	_caso("la tecla de saltar marca el teclado y es de juego", UltimaEntrada.marca_teclado(w) and UltimaEntrada.es_de_juego(w))
	var enter: InputEventKey = InputEventKey.new()
	enter.keycode = KEY_ENTER
	enter.pressed = true
	_caso("Enter (solo ui_accept) no es de juego", enter.is_action(&"ui_accept") and not UltimaEntrada.es_de_juego(enter))

	# La familia de cada control se guarda: se planta otra en la cache y el evento la usa; al conectar o desconectar un
	# control se vacia y se vuelve a calcular.
	UltimaEntrada._familias.clear()
	UltimaEntrada.anotar(eje)
	UltimaEntrada._familias[7] = Mando.Dispositivo.PLAYSTATION
	UltimaEntrada.anotar(eje)
	_caso("el segundo evento del mismo control usa la familia guardada", UltimaEntrada.dispositivo == Mando.Dispositivo.PLAYSTATION)
	Input.joy_connection_changed.emit(7, false)
	UltimaEntrada.anotar(eje)
	_caso("al conectar o desconectar un control la familia se vuelve a calcular", UltimaEntrada.dispositivo == sin_nombre)
	UltimaEntrada._familias.clear()
	UltimaEntrada.anotar(toque)

	# El nodo: escondido tras el toque, visible con su medida al usar el teclado, y se pone al dia solo.
	var icono: IconoBoton = IconoBoton.new()
	icono.theme = Tema.crear()
	icono.accion = &"saltar"
	icono.texto = "Saltar"
	add_child(icono)
	await _esperar(1)
	_caso("tras un toque el icono no se ve", not icono.visible)
	UltimaEntrada.anotar(tecla)
	# Los dos cuadros eran los que pedia el sondeo de antes; con el bus ya no hacen falta (los casos de abajo no esperan).
	await get_tree().process_frame
	await get_tree().process_frame
	_caso("con el teclado el icono se ve y mide el boton y el texto", icono.visible and icono.custom_minimum_size.x > Tema.ALTO_LETRA and is_equal_approx(icono.custom_minimum_size.y, Tema.ALTO_LETRA))
	UltimaEntrada.anotar(toque)
	await get_tree().process_frame
	await get_tree().process_frame
	_caso("al volver a tocar se esconde otra vez", not icono.visible)

	# Por el bus, sin esperar ningun cuadro: el icono cambia en cuanto cambia el dispositivo o un boton.
	UltimaEntrada.anotar(tecla)
	_caso("al cambiar el dispositivo el icono se pone al dia sin esperar", icono.visible and (icono.dibujo_actual.get("texto", "") as String) == "W")
	UltimaEntrada.dispositivo = Mando.Dispositivo.PLAYSTATION
	_caso("con PlayStation el icono es la cruz sin esperar", (icono.dibujo_actual.get("simbolo", "") as String) == "cruz")
	Mando.asignar(&"saltar", JOY_BUTTON_X)
	_caso("al asignar otro boton el icono cambia sin esperar", (icono.dibujo_actual.get("simbolo", "") as String) == "cuadrado")
	Mando.por_omision()
	_caso("al restablecer el icono vuelve a la cruz sin esperar", (icono.dibujo_actual.get("simbolo", "") as String) == "cruz")
	# Fuera del arbol no escucha; al volver se pone al dia con lo que cambio mientras.
	remove_child(icono)
	UltimaEntrada.anotar(toque)
	add_child(icono)
	_caso("sacado del arbol, al volver tras un toque se pone al dia y no se ve", not icono.visible and icono.dibujo_actual.is_empty())

	# mando_cambiado sale una vez por operacion, aunque aplicar restablezca y asigne varios botones, y nada si no cambio.
	Eventos.mando_cambiado.connect(_contar_mando)
	Mando.aplicar({"saltar": float(JOY_BUTTON_X), "atacar": float(JOY_BUTTON_Y)})
	_caso("aplicar con dos botones emite mando_cambiado una sola vez", _avisos_mando == 1)
	Mando.asignar(&"saltar", 999)
	_caso("asignar un boton invalido no emite mando_cambiado", _avisos_mando == 1)
	Mando.por_omision()
	_caso("por_omision emite mando_cambiado una vez", _avisos_mando == 2)
	Eventos.mando_cambiado.disconnect(_contar_mando)
	# dispositivo_cambiado sale solo si el valor cambia de verdad, con el nuevo.
	Eventos.dispositivo_cambiado.connect(_contar_dispositivo)
	UltimaEntrada.anotar(toque)
	UltimaEntrada.anotar(levantado)
	_caso("otro toque (o soltarlo) con TOQUE no emite dispositivo_cambiado", _avisos_dispositivo.is_empty())
	UltimaEntrada.anotar(tecla)
	UltimaEntrada.anotar(tecla)
	_caso("dos teclas emiten dispositivo_cambiado una vez, con TECLADO", _avisos_dispositivo.size() == 1 and _avisos_dispositivo[0] == Mando.Dispositivo.TECLADO)
	UltimaEntrada.anotar(toque)
	Eventos.dispositivo_cambiado.disconnect(_contar_dispositivo)

	# Una sola tabla de nombres (Mando.BOTONES): contra los textos que se veian antes de unificarla (18-oct-2026), por
	# indice: el neutro de Configuracion y los de Xbox y PlayStation de IconoBoton (en la cara, letra y simbolo).
	var esperados: Array[PackedStringArray] = [
		PackedStringArray(["A / Cruz", "A", "cruz"]),
		PackedStringArray(["B / Circulo", "B", "circulo"]),
		PackedStringArray(["X / Cuadrado", "X", "cuadrado"]),
		PackedStringArray(["Y / Triangulo", "Y", "triangulo"]),
		PackedStringArray(["Select", "View", "Share"]),
		PackedStringArray(["Guia", "Guia", "PS"]),
		PackedStringArray(["Start", "Menu", "Options"]),
		PackedStringArray(["Stick izq.", "LS", "L3"]),
		PackedStringArray(["Stick der.", "RS", "R3"]),
		PackedStringArray(["LB / L1", "LB", "L1"]),
		PackedStringArray(["RB / R1", "RB", "R1"]),
		PackedStringArray(["Arriba", "Arriba", "Arriba"]),
		PackedStringArray(["Abajo", "Abajo", "Abajo"]),
		PackedStringArray(["Izquierda", "Izq.", "Izq."]),
		PackedStringArray(["Derecha", "Der.", "Der."]),
	]
	_caso("Mando.BOTONES tiene una fila por boton 0..14", Mando.BOTONES.size() == esperados.size())
	for i: int in range(esperados.size()):
		var fila: PackedStringArray = esperados[i]
		var vistos: PackedStringArray = [Mando.nombre_de(i), Mando.nombre_en(i, Mando.Dispositivo.XBOX), Mando.nombre_en(i, Mando.Dispositivo.PLAYSTATION)]
		_caso("el boton %d se llama %s" % [i, " | ".join(fila)], vistos == fila)
	_caso("sin boton el nombre es la raya", Mando.nombre_de(-1) == "—")
	_caso("fuera de la tabla es Boton n en las tres columnas", Mando.nombre_de(15) == "Boton 15"
			and Mando.nombre_en(15, Mando.Dispositivo.XBOX) == "Boton 15" and Mando.nombre_en(15, Mando.Dispositivo.PLAYSTATION) == "Boton 15")
	var ejes: Array[PackedStringArray] = [
		PackedStringArray(["Stick izq.", "Stick izq."]),
		PackedStringArray(["Stick izq.", "Stick izq."]),
		PackedStringArray(["Stick der.", "Stick der."]),
		PackedStringArray(["Stick der.", "Stick der."]),
		PackedStringArray(["LT", "L2"]),
		PackedStringArray(["RT", "R2"]),
	]
	for i: int in range(ejes.size()):
		var nombres: PackedStringArray = ejes[i]
		var vistos: PackedStringArray = [Mando.nombre_de_eje(i as JoyAxis, Mando.Dispositivo.XBOX), Mando.nombre_de_eje(i as JoyAxis, Mando.Dispositivo.PLAYSTATION)]
		_caso("el eje %d se llama %s" % [i, " | ".join(nombres)], vistos == nombres)
	_resumen()


func _contar_mando() -> void:
	_avisos_mando += 1


func _contar_dispositivo(nuevo: int) -> void:
	_avisos_dispositivo.append(nuevo)
