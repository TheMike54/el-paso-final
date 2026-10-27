extends SceneTree
# Genera las hojas de cuadros de los efectos del jugador en nucleo/arte/: el destello del parry, la bola de fuego y
# el aura de curar (detras y delante del jugador). Cada cuadro se calcula pixel por pixel como una sola mancha de luz
# y se difumina, para que las partes no se vean armadas por separado. Se corre una vez y despues se reimporta:
# & $env:GODOT_PATH --headless --path . --script res://herramientas/generar_efectos.gd

const SALIDA: String = "res://nucleo/arte/efecto_"
const CUADROS_BOLA: int = 6
const CUADROS_PARRY: int = 4
const CUADROS_CURAR: int = 6
const ORILLA: Color = Color(0.86, 0.92, 1.0)

# Bola: cuadro de 224x160, centro de la bola a 70 px de la orilla derecha.
const BOLA_ANCHO: int = 224
const BOLA_ALTO: int = 160
const BOLA_RADIO: float = 30.0

# Parry: cuadro de 352x208, destello al 40 % del de la segunda ronda de maquetas.
const PARRY_ANCHO: int = 352
const PARRY_ALTO: int = 208
const PARRY_TAMANO: float = 0.4
const PUNTAS: int = 14

enum Modo { LUZ, FUEGO, AURA }


func _initialize() -> void:
	# La bola lleva dos filas: con gotas sueltas (en vuelo) y sin ellas (al salir, cuando asomarian sobre la cabeza).
	_guardar("bola", BOLA_ANCHO, BOLA_ALTO, [_cuadro_bola.bind(true), _cuadro_bola.bind(false)], 1, CUADROS_BOLA,
		Modo.FUEGO)
	_guardar("parry", PARRY_ANCHO, PARRY_ALTO, [_cuadro_parry], 2, CUADROS_PARRY, Modo.LUZ)
	_guardar("curar", AURA_ANCHO, AURA_ALTO, [_cuadro_curar], 1, CUADROS_CURAR, Modo.AURA)
	_guardar("curar_frente", AURA_ANCHO, AURA_ALTO, [_cuadro_curar_frente], 0, CUADROS_CURAR, Modo.AURA)
	quit()


# Arma la hoja: los cuadros uno junto a otro y una fila por cada funcion de cuadro. El parry es luz (va con mezcla
# aditiva, el alfa es su brillo); la bola y el aura van con mezcla normal y su propia opacidad por capa, para que no
# se transparente el fondo.
func _guardar(nombre: String, ancho: int, alto: int, filas: Array, difuminado: int, cuadros: int, modo: Modo) -> void:
	var hoja: Image = Image.create_empty(ancho * cuadros, alto * filas.size(), false, Image.FORMAT_RGBA8)
	for fila: int in range(filas.size()):
		var cuadro: Callable = filas[fila] as Callable
		for f: int in range(cuadros):
			var alfa: PackedFloat32Array = _difuminar(cuadro.call(f, cuadros) as PackedFloat32Array, ancho, alto,
				difuminado)
			for y: int in range(alto):
				for x: int in range(ancho):
					var a: float = clampf(alfa[y * ancho + x], 0.0, 1.0)
					var color: Color = Color(ORILLA.lerp(Color.WHITE, clampf(a * 1.4 - 0.4, 0.0, 1.0)), a)
					if modo == Modo.FUEGO:
						color = Color(_tono_fuego(a), _opacidad_fuego(a))
					elif modo == Modo.AURA:
						color = Color(_tono_fuego(a), _opacidad_aura(a))
					hoja.set_pixel(f * ancho + x, fila * alto + y, color)
	var ruta: String = SALIDA + nombre + ".png"
	var error: Error = hoja.save_png(ruta)
	print("EFECTO %s error=%d" % [ruta, error])


# --- Bola de fuego, como se dibuja en 2D: una sola silueta (la bola con llamitas en toda su orilla, lenguas largas
# hacia atras y gotas de fuego sueltas) repetida en tres capas encajadas, cada una mas chica y corrida hacia el
# frente: azul por fuera, celeste en medio y blanca en el centro. Asi bola y llamas son la misma forma. Las llamitas
# corren hacia atras, las lenguas ondean y las gotas se alejan; el ultimo cuadro empalma con el primero ---
# Lenguas: [angulo en la bola (grados, 180 = atras), largo, grueso (por radio), onda, hacia donde va (0 = al centro,
# 1 = derecho, mas de 1 = hacia fuera)]. Las llamitas salen del frente y se doblan hacia atras pegadas a la orilla.
const LENGUAS: Array = [[125.0, 60.0, 0.42, 6.0, 0.35], [150.0, 105.0, 0.5, 9.0, 0.35], [180.0, 135.0, 0.55, 10.0, 0.35],
	[210.0, 100.0, 0.5, 9.0, 0.35], [235.0, 65.0, 0.42, 6.0, 0.35],
	[40.0, 28.0, 0.3, 2.0, 1.3], [75.0, 34.0, 0.3, 3.0, 1.2], [100.0, 44.0, 0.34, 4.0, 1.15],
	[320.0, 26.0, 0.3, 2.0, 1.3], [285.0, 32.0, 0.3, 3.0, 1.2], [260.0, 46.0, 0.34, 4.0, 1.15]]
# Capas de fuera hacia dentro: [escala, brillo]. Las usan la bola y el aura.
const CAPAS: Array = [[1.0, 0.42], [0.74, 0.68], [0.5, 1.0]]
const GOTAS: Array = [-24.0, 6.0, 22.0]


func _cuadro_bola(f: int, cuadros: int, con_gotas: bool) -> PackedFloat32Array:
	var fase: float = float(f) / float(cuadros)
	var centro: Vector2 = Vector2(float(BOLA_ANCHO) - 70.0, float(BOLA_ALTO) / 2.0)
	# Las capas de dentro se encogen hacia este punto, al frente de la bola: el centro caliente va adelante.
	var ancla: Vector2 = centro + Vector2(BOLA_RADIO * 0.2, 0.0)
	var alfa: PackedFloat32Array = PackedFloat32Array()
	alfa.resize(BOLA_ANCHO * BOLA_ALTO)
	for y: int in range(BOLA_ALTO):
		for x: int in range(BOLA_ANCHO):
			var p: Vector2 = Vector2(float(x) + 0.5, float(y) + 0.5)
			var d: float = p.distance_to(centro)
			var a: float = exp(-pow(d / (BOLA_RADIO * 1.4), 2.0)) * 0.3 * (1.0 - smoothstep(BOLA_RADIO * 1.2, 66.0, d))
			for k: int in range(CAPAS.size()):
				var capa: Array = CAPAS[k] as Array
				var q: Vector2 = ancla + (p - ancla) / (capa[0] as float)
				a = maxf(a, _silueta(q, centro, fase + float(k) * 0.33, con_gotas and k == 0) * (capa[1] as float))
			alfa[y * BOLA_ANCHO + x] = a
	return alfa


# La silueta del fuego (0 fuera, 1 dentro, con la orilla suavizada un pixel).
func _silueta(p: Vector2, centro: Vector2, fase: float, con_gotas: bool) -> float:
	var v: Vector2 = p - centro
	var d: float = v.length()
	# Orilla de la bola con llamitas: cortas al frente y mas altas hacia los lados y atras; corren hacia atras.
	var angulo: float = absf(atan2(v.y, v.x))
	var pico: float = pow(0.5 + 0.5 * sin(7.0 * angulo - TAU * fase), 3.0)
	var orilla: float = BOLA_RADIO * (1.0 + 0.11 * pico)
	var forma: float = 1.0 - smoothstep(orilla - 1.2, orilla + 0.6, d)
	for i: int in range(LENGUAS.size()):
		forma = maxf(forma, _lengua(p, centro, LENGUAS[i] as Array, fase, float(i)))
	if con_gotas:
		for i: int in range(GOTAS.size()):
			var lejos: float = fposmod(fase + float(i) / float(GOTAS.size()), 1.0)
			var gota: Vector2 = centro + Vector2(-(BOLA_RADIO + 85.0 + 60.0 * lejos), (GOTAS[i] as float) - 8.0 * lejos)
			var radios: Vector2 = Vector2(9.0, 3.5) * (1.0 - 0.6 * lejos)
			# Gota en punta hacia atras.
			if p.x < gota.x:
				radios.x *= 2.2
			var e: float = ((p - gota) / radios).length()
			forma = maxf(forma, 1.0 - smoothstep(0.8, 1.05, e))
	return forma


# Una lengua (datos como en LENGUAS): su linea central va hacia atras, se dobla segun su rumbo y ondea; el grueso
# se afila hasta la punta.
func _lengua(p: Vector2, centro: Vector2, datos: Array, fase: float, n: float) -> float:
	var angulo: float = deg_to_rad(datos[0] as float)
	var largo: float = (datos[1] as float) * (1.0 + 0.15 * sin(TAU * (fase + n * 0.37)))
	var grueso: float = (datos[2] as float) * BOLA_RADIO
	var onda: float = datos[3] as float
	var rumbo: float = datos[4] as float
	var base: Vector2 = centro + Vector2.RIGHT.rotated(angulo) * BOLA_RADIO * 0.8
	var s: float = (base.x - p.x) / largo
	if s < 0.0 or s > 1.0:
		return 0.0
	var linea: float = lerpf(base.y, centro.y + (base.y - centro.y) * rumbo, s) + onda * sin(TAU * (1.4 * s - fase) + n) * s
	var ancho: float = grueso * pow(1.0 - s, 1.2)
	if ancho < 0.3:
		return 0.0
	return 1.0 - smoothstep(ancho - 1.2, ancho + 0.6, absf(p.y - linea))


# --- Aura de curar: la silueta del aura del HTML de diseno (ancha abajo y en punta arriba) con su orilla de picos
# filosos que apuntan hacia arriba y hacia fuera. Tres capas encajadas que se encogen hacia los pies (azul, celeste,
# blanca), gotas, rayas y chispas que nacen en el piso, mas transparente que la bola. Los picos cambian en cada
# cuadro. La hoja curar_frente lleva solo las rayas y las chispas, para dibujarla delante del jugador ---
const AURA_ANCHO: int = 320
const AURA_ALTO: int = 420
const AURA_PIES: Vector2 = Vector2(160.0, 395.0)
const AURA_ALTURA: float = 300.0
# Picos por lado en cada capa, de fuera hacia dentro: distintos para que las capas no repitan los mismos picos.
const AURA_TRAMOS: Array[int] = [11, 10, 9]
const RAYAS_AURA: int = 10
const CHISPAS_AURA: Array = [-70.0, -20.0, 35.0, 80.0]
# Gotas por fuera de la orilla, como las de la bola: [lado, cuanto se abren al subir, desfase del ciclo].
const GOTAS_AURA: Array = [[-1.0, 0.3, 0.0], [1.0, 0.45, 0.17], [-1.0, 0.6, 0.33], [1.0, 0.25, 0.5],
	[-1.0, 0.8, 0.67], [1.0, 0.7, 0.83]]


func _cuadro_curar(f: int, cuadros: int) -> PackedFloat32Array:
	var fase: float = float(f) / float(cuadros)
	var contornos: Array[PackedVector2Array] = []
	for k: int in range(CAPAS.size()):
		contornos.append(_contorno_aura((CAPAS[k] as Array)[0] as float, float(f * 3 + k), AURA_TRAMOS[k]))
	var alfa: PackedFloat32Array = PackedFloat32Array()
	alfa.resize(AURA_ANCHO * AURA_ALTO)
	for y: int in range(AURA_ALTO):
		for x: int in range(AURA_ANCHO):
			var p: Vector2 = Vector2(float(x) + 0.5, float(y) + 0.5)
			var a: float = 0.0
			for k: int in range(CAPAS.size()):
				if Geometry2D.is_point_in_polygon(p, contornos[k]):
					a = maxf(a, (CAPAS[k] as Array)[1] as float)
			# Resplandor en el suelo, como el ovalo de 130x20 del HTML.
			var suelo: Vector2 = (p - AURA_PIES - Vector2(0.0, -4.0)) / Vector2(130.0, 20.0)
			a = maxf(a, (1.0 - smoothstep(0.3, 1.0, suelo.length())) * 0.68)
			a = maxf(a, _gotas_aura(p, fase))
			alfa[y * AURA_ANCHO + x] = maxf(a, _rayas_y_chispas(p, fase))
	return alfa


func _cuadro_curar_frente(f: int, cuadros: int) -> PackedFloat32Array:
	var fase: float = float(f) / float(cuadros)
	var alfa: PackedFloat32Array = PackedFloat32Array()
	alfa.resize(AURA_ANCHO * AURA_ALTO)
	for y: int in range(AURA_ALTO):
		for x: int in range(AURA_ANCHO):
			alfa[y * AURA_ANCHO + x] = _rayas_y_chispas(Vector2(float(x) + 0.5, float(y) + 0.5), fase)
	return alfa


# Medio ancho del aura a la altura u (0 los pies, 1 la punta), la cuenta del aura del HTML.
func _ancho_aura(u: float) -> float:
	return (92.0 + 25.0 * sin(minf(u, 0.35) / 0.35 * PI / 2.0)) * (1.0 - pow(u, 2.2))


# Contorno de una capa: entre cada tramo de la orilla sale un pico hacia fuera y hacia arriba (el HTML lo sube 1,3
# veces su largo; aqui 1,8 y mas largo, para que sea filoso). La semilla sortea el largo de cada pico.
func _contorno_aura(escala: float, semilla: float, tramos: int) -> PackedVector2Array:
	var alto: float = AURA_ALTURA * escala
	var izquierda: PackedVector2Array = PackedVector2Array()
	var derecha: PackedVector2Array = PackedVector2Array()
	for i: int in range(tramos + 1):
		var u: float = float(i) / float(tramos)
		var y: float = AURA_PIES.y - u * alto
		var w: float = _ancho_aura(u) * escala
		izquierda.append(Vector2(AURA_PIES.x - w, y))
		derecha.append(Vector2(AURA_PIES.x + w, y))
		if i < tramos:
			var um: float = (float(i) + 0.5) / float(tramos)
			var wm: float = _ancho_aura(um) * escala
			var ym: float = AURA_PIES.y - um * alto
			var largo_i: float = (16.0 + 40.0 * _azar(float(i), semilla)) * escala * (0.6 + 0.6 * um)
			var largo_d: float = (16.0 + 40.0 * _azar(float(i) + 50.0, semilla)) * escala * (0.6 + 0.6 * um)
			izquierda.append(Vector2(AURA_PIES.x - wm - largo_i * 0.7, ym - largo_i * 1.8))
			derecha.append(Vector2(AURA_PIES.x + wm + largo_d * 0.7, ym - largo_d * 1.8))
	# La punta de arriba: un pico alto.
	var punta: float = (40.0 + 50.0 * _azar(99.0, semilla)) * escala
	var contorno: PackedVector2Array = izquierda.duplicate()
	contorno.append(Vector2(AURA_PIES.x + (_azar(98.0, semilla) - 0.5) * 20.0, AURA_PIES.y - alto - punta))
	for i: int in range(derecha.size() - 1, -1, -1):
		contorno.append(derecha[i])
	return contorno


# Gotas que nacen en el piso, junto a la orilla, y suben pegadas a ella abriendose un poco; se achican al subir y
# terminan en punta hacia abajo (de donde vienen). Brillo de la capa celeste.
func _gotas_aura(p: Vector2, fase: float) -> float:
	var a: float = 0.0
	for datos: Array in GOTAS_AURA:
		var lado: float = datos[0] as float
		var subida: float = fposmod(fase + (datos[2] as float), 1.0)
		var u: float = 0.03 + 0.85 * subida
		var gota: Vector2 = AURA_PIES + Vector2(lado * (_ancho_aura(u) + 8.0 + 30.0 * subida * (datos[1] as float)),
			-u * AURA_ALTURA)
		var rumbo: Vector2 = Vector2(lado * 0.3, -1.0).normalized()
		var v: Vector2 = p - gota
		var local: Vector2 = Vector2(v.dot(rumbo.orthogonal()), v.dot(rumbo))
		var radios: Vector2 = Vector2(4.0, 9.0) * (1.0 - 0.55 * subida)
		if local.y < 0.0:
			radios.y *= 2.2
		var e: float = (local / radios).length()
		a = maxf(a, (1.0 - smoothstep(0.8, 1.05, e)) * 0.68)
	return a


# Rayas finas que suben por dentro del aura (las 10 del HTML) y chispas sueltas que nacen en el piso y suben.
func _rayas_y_chispas(p: Vector2, fase: float) -> float:
	var a: float = 0.0
	for n: int in range(RAYAS_AURA):
		var ciclo: float = fposmod(fase + float(n) * 0.29, 1.0)
		var u: float = ciclo * 0.85
		var x: float = AURA_PIES.x + sin(float(n) * 2.7) * 0.8 * _ancho_aura(u)
		var y: float = AURA_PIES.y - u * AURA_ALTURA
		var largo: float = 30.0 + 40.0 * float((n * 7) % 5) / 4.0
		if p.y <= y and p.y >= y - largo:
			var grueso: float = 1.6 * (1.0 - (y - p.y) / largo) + 0.5
			a = maxf(a, (1.0 - smoothstep(grueso - 0.8, grueso + 0.6, absf(p.x - x))) * sin(ciclo * PI))
	for i: int in range(CHISPAS_AURA.size()):
		var subida: float = fposmod(fase + float(i) / float(CHISPAS_AURA.size()), 1.0)
		var chispa: Vector2 = AURA_PIES + Vector2(CHISPAS_AURA[i] as float, -(AURA_ALTURA * (0.03 + 0.95 * subida)))
		var radios: Vector2 = Vector2(3.0, 7.0) * (1.0 - 0.6 * subida)
		if p.y > chispa.y:
			radios.y *= 2.2
		var e: float = ((p - chispa) / radios).length()
		a = maxf(a, (1.0 - smoothstep(0.8, 1.05, e)) * (1.0 - subida * 0.5))
	return a


# Opacidad del aura por capa: mas transparente que la bola, va detras del jugador (45 %, 35 % y 25 %).
func _opacidad_aura(a: float) -> float:
	if a < 0.42:
		return a / 0.42 * 0.25
	return lerpf(0.25, 0.45, (a - 0.42) / 0.58)


# Opacidad del fuego por capa: 80 % en el centro blanco, 65 % en la celeste y 50 % en la azul de fuera; por debajo
# de la capa de fuera (orilla suavizada y halo) baja hasta 0.
func _opacidad_fuego(a: float) -> float:
	if a < 0.42:
		return a / 0.42 * 0.5
	return lerpf(0.5, 0.8, (a - 0.42) / 0.58)


# Color del fuego por brillo: azul en las orillas, celeste en medio y blanco en lo mas caliente.
func _tono_fuego(a: float) -> Color:
	var frio: Color = Color(0.42, 0.58, 1.0)
	var tibio: Color = Color(0.78, 0.88, 1.0)
	if a < 0.6:
		return frio.lerp(tibio, smoothstep(0.15, 0.6, a))
	return tibio.lerp(Color.WHITE, smoothstep(0.6, 0.9, a))


# --- Parry: estrella de puntas desiguales con una linea de luz larga; crece rapido y se apaga en 0,2 s ---
func _cuadro_parry(f: int, cuadros: int) -> PackedFloat32Array:
	var t: float = (float(f) + 0.5) / float(cuadros) * 0.2
	var p: float = t / 0.2
	var escala: float = lerpf(0.5, 1.2, p / 0.25) if p < 0.25 else lerpf(1.2, 0.85, (p - 0.25) / 0.75)
	escala *= PARRY_TAMANO
	var brillo: float = 1.0 - smoothstep(0.45, 1.0, p)
	var centro: Vector2 = Vector2(float(PARRY_ANCHO), float(PARRY_ALTO)) / 2.0
	var angulos: PackedFloat32Array = PackedFloat32Array()
	var largos: PackedFloat32Array = PackedFloat32Array()
	for i: int in range(PUNTAS):
		var angulo: float = TAU * float(i) / float(PUNTAS) + (_azar(float(i), 1.0) - 0.5) * 0.3
		angulos.append(angulo)
		largos.append((60.0 + 120.0 * _azar(float(i), 2.0)) * (1.0 + 0.7 * absf(cos(angulo))) * escala)
	var alfa: PackedFloat32Array = PackedFloat32Array()
	alfa.resize(PARRY_ANCHO * PARRY_ALTO)
	for y: int in range(PARRY_ALTO):
		for x: int in range(PARRY_ANCHO):
			var v: Vector2 = Vector2(float(x) + 0.5, float(y) + 0.5) - centro
			var d: float = v.length()
			var a: float = exp(-pow(d / (65.0 * escala), 2.0)) * 0.55
			a = maxf(a, 1.0 - smoothstep(0.0, 16.0 * escala, d))
			for i: int in range(PUNTAS):
				a = maxf(a, _rayo(v, Vector2.RIGHT.rotated(angulos[i]), largos[i], 9.0 * escala))
			a = maxf(a, _rayo(v, Vector2.RIGHT, 330.0 * escala, 5.0 * escala))
			a = maxf(a, _rayo(v, Vector2.LEFT, 330.0 * escala, 5.0 * escala))
			a = maxf(a, 0.8 * _rayo(v, Vector2.UP, 140.0 * escala, 4.0 * escala))
			a = maxf(a, 0.8 * _rayo(v, Vector2.DOWN, 140.0 * escala, 4.0 * escala))
			alfa[y * PARRY_ANCHO + x] = a * brillo
	return alfa


# Un rayo que se afila hacia la punta y se apaga a lo largo.
func _rayo(v: Vector2, direccion: Vector2, largo: float, grueso: float) -> float:
	var a_lo_largo: float = v.dot(direccion)
	if a_lo_largo <= 0.0 or a_lo_largo >= largo:
		return 0.0
	var resto: float = 1.0 - a_lo_largo / largo
	var medio: float = maxf(grueso * resto, 0.6)
	var lejos: float = absf(v.dot(direccion.orthogonal()))
	return (1.0 - smoothstep(medio * 0.4, medio, lejos)) * resto


func _azar(n: float, semilla: float) -> float:
	var x: float = sin(n * 127.1 + semilla * 311.7) * 43758.5453
	return x - floorf(x)


# Caja de difuminado en dos pasadas (horizontal y vertical), para fundir las partes en una sola mancha.
func _difuminar(alfa: PackedFloat32Array, ancho: int, alto: int, radio: int) -> PackedFloat32Array:
	if radio == 0:
		return alfa
	var medio: PackedFloat32Array = PackedFloat32Array()
	medio.resize(alfa.size())
	var lado: float = float(radio * 2 + 1)
	for y: int in range(alto):
		for x: int in range(ancho):
			var suma: float = 0.0
			for k: int in range(-radio, radio + 1):
				suma += alfa[y * ancho + clampi(x + k, 0, ancho - 1)]
			medio[y * ancho + x] = suma / lado
	var final: PackedFloat32Array = PackedFloat32Array()
	final.resize(alfa.size())
	for y: int in range(alto):
		for x: int in range(ancho):
			var suma: float = 0.0
			for k: int in range(-radio, radio + 1):
				suma += medio[clampi(y + k, 0, alto - 1) * ancho + x]
			final[y * ancho + x] = suma / lado
	return final
