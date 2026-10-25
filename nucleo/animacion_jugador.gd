class_name AnimacionJugador
extends RefCounted
# Elige la animacion del cuerpo del jugador a partir de una foto de su estado (Estado), con la tabla de prioridades de
# HeroAnimationController.UpdateAnimation de Hollow Knight: gana la primera que se cumple. Funciones puras: el jugador
# llena el Estado al final de su tick, solo leyendo, y el dibujo nunca escribe estado. Tambien dice que cuadro toca en
# los clips con tiempo propio (por ticks); los bucles los corre el AnimatedSprite2D (cuadro -1).

## Nombres de las animaciones de nucleo/arte/jugador_hombre/jugador_hombre.tres.
const MUERTE: StringName = &"muerte"
const DANO: StringName = &"dano"
const SENTARSE: StringName = &"sentarse"
const DORMIR: StringName = &"dormir"
const ATERRIZAJE_DURO: StringName = &"aterrizaje_duro"
const PICADA_CARGA: StringName = &"picada_carga"
const PICADA: StringName = &"picada"
const CURAR: StringName = &"curar"
const BOLA: StringName = &"bola"
const ESTOCADA: StringName = &"estocada"
const ATAQUE_ABAJO: StringName = &"ataque_abajo"
const ATAQUE_ARRIBA: StringName = &"ataque_arriba"
const ATAQUE_LADO: StringName = &"ataque_lado"
const VOLTERETA: StringName = &"voltereta"
const IMPULSO: StringName = &"impulso"
const SALTAR_PARED: StringName = &"saltar_pared"
const PARED: StringName = &"pared"
const AIRE: StringName = &"aire"
const CARRERA: StringName = &"carrera"
const GIRO_CARRERA: StringName = &"giro_carrera"
const CORRER: StringName = &"correr"
const QUIETO: StringName = &"quieto"
## Todas, para la prueba que revisa que existan en el .tres.
const TODAS: Array[StringName] = [MUERTE, DANO, SENTARSE, DORMIR, ATERRIZAJE_DURO, PICADA_CARGA, PICADA, CURAR, BOLA,
		ESTOCADA, ATAQUE_ABAJO, ATAQUE_ARRIBA, ATAQUE_LADO, VOLTERETA, IMPULSO, SALTAR_PARED, PARED, AIRE, CARRERA,
		GIRO_CARRERA, CORRER, QUIETO]
## Ticks del cuadro de despegue del salto (60 ms) y del inicio de curar.
const TICKS_DESPEGUE: int = 4
const TICKS_INICIO_CURAR: int = 10
## Velocidad vertical (px/s) que separa los cuadros del salto: sube, cima, empieza a caer, cae (escena HTML).
const VY_SUBE: float = -350.0
const VY_CIMA: float = 150.0
const VY_EMPIEZA_A_CAER: float = 450.0


## Lo que el dibujo lee del jugador en un tick. Solo datos: el jugador lo llena y nadie lo guarda.
class Estado:
	extends RefCounted
	var muerto: bool = false
	var ticks_hasta_reaparecer: int = 0
	var descansando: bool = false
	var ticks_retrocediendo: int = 0
	var ticks_retroceso: int = 10
	var ticks_aterrizando: int = 0
	var ticks_aterrizaje_duro: int = 21
	var preparando_picada: bool = false
	var en_picada: bool = false
	var curando: bool = false
	var ticks_curados: int = 0
	var ticks_poder: int = -1
	var ticks_hasta_bola: int = 0
	var ticks_recarga_bola: int = 18
	var atacando_en_carrera: bool = false
	var ticks_atacando: int = 0
	var ticks_ataque: int = 8
	var ticks_hasta_ataque: int = 0
	var ticks_entre_ataques: int = 20
	var atacando_abajo: bool = false
	var atacando_arriba: bool = false
	var volteando: bool = false
	var ticks_voltereta: int = 0
	var ticks_vuelta: int = 24
	var ticks_impulsando: int = 0
	var ticks_impulso: int = 10
	var ticks_despegando: int = 0
	var en_pared: bool = false
	var en_suelo: bool = true
	var velocidad: Vector2 = Vector2.ZERO
	var subiendo: bool = false
	var ticks_subiendo: int = 0
	var corriendo: bool = false
	var ticks_girando: int = 0
	var ticks_giro_carrera: int = 8
	var ticks_rebote: int = 0
	var hablando: bool = false
	var ticks_congelado: int = 0
	## Memoria del propio dibujo entre ticks (no del jugador): ver actualizar_cola_ataque.
	var cola_ataque_cortada: bool = false


## La animacion que toca, sin el giro en carrera (ver con_giro). Gana la primera fila que se cumple.
static func elegir(e: Estado) -> StringName:
	if e.muerto:
		return MUERTE
	if e.ticks_hasta_reaparecer > 0:
		return DANO
	if e.descansando:
		return DORMIR
	if e.ticks_retrocediendo > 0:
		return DANO
	if e.ticks_aterrizando > 0:
		return ATERRIZAJE_DURO
	if e.preparando_picada:
		return PICADA_CARGA
	if e.en_picada:
		return PICADA
	if e.curando:
		return CURAR
	if e.ticks_poder >= 0 or e.ticks_hasta_bola > 0:
		return BOLA
	if e.atacando_en_carrera:
		return ESTOCADA
	if e.ticks_atacando > 0 or (e.ticks_hasta_ataque > 0 and not e.cola_ataque_cortada):
		# Pegado a la pared tambien sale al lado, hacia donde mira: ahi sale el area (decidido el 21-oct-2026).
		if e.atacando_abajo:
			return ATAQUE_ABAJO
		if e.atacando_arriba:
			return ATAQUE_ARRIBA
		return ATAQUE_LADO
	if e.volteando:
		return VOLTERETA
	if e.ticks_impulsando > 0:
		return IMPULSO
	if e.ticks_despegando > 0:
		return SALTAR_PARED
	if e.en_pared:
		return PARED
	if not e.en_suelo:
		return AIRE
	if e.corriendo:
		return CARRERA
	if e.velocidad.x != 0.0 and e.ticks_rebote == 0:
		return CORRER
	return QUIETO


## Antes de elegir, cada tick. El clip del ataque dura ticks_entre_ataques, mas que el golpe (ticks_ataque), y esa cola
## se lee de ticks_hasta_ataque, que solo baja mientras el jugador puede atacar: si una fila de mas prioridad, hablar o
## la pausa tras un peligro la interrumpe, la cola se corta y no vuelve despues. Un golpe nuevo la abre otra vez, salvo
## la estocada: su cola seguiria como ataque al lado sobre la carrera.
static func actualizar_cola_ataque(e: Estado) -> void:
	if e.ticks_atacando > 0 or e.ticks_hasta_ataque == 0:
		e.cola_ataque_cortada = e.ticks_atacando > 0 and e.atacando_en_carrera
		return
	if e.cola_ataque_cortada:
		return
	if e.hablando or e.ticks_congelado > 0:
		e.cola_ataque_cortada = true
		return
	var nombre: StringName = elegir(e)
	e.cola_ataque_cortada = nombre != ATAQUE_LADO and nombre != ATAQUE_ARRIBA and nombre != ATAQUE_ABAJO


## Capa del giro en carrera, como el Turn de Hollow Knight: solo en el suelo y solo sobre carrera, correr o quieto.
static func con_giro(nombre: StringName, e: Estado) -> StringName:
	if e.ticks_girando > 0 and e.en_suelo and (nombre == CARRERA or nombre == CORRER or nombre == QUIETO):
		return GIRO_CARRERA
	return nombre


## Volteo del cuerpo (Dibujo.scale.x). Pegado a la pared mira hacia afuera, con la pared a la espalda como en la hoja:
## mirando apunta hacia la pared, que es donde se empuja (y donde sale el ataque).
static func volteo(nombre: StringName, mirando: float) -> float:
	return -mirando if nombre == PARED else mirando


## Cuanto se aparta el cuerpo de la pared (hacia donde mira el dibujo) en la animacion pared: lo que la mano o los pies
## sobresalen por detras del eje del lienzo (eje) menos medio ancho del jugador, para que toquen el borde de la pared
## sin meterse. Sale de los margenes de los AtlasTexture: no cambia si el arte se vuelve a generar.
static func separacion_pared(cuadros: SpriteFrames, eje: float, medio_ancho: float) -> float:
	var atras: float = 0.0
	for i: int in range(cuadros.get_frame_count(PARED)):
		var cuadro: AtlasTexture = cuadros.get_frame_texture(PARED, i) as AtlasTexture
		if cuadro != null:
			atras = maxf(atras, eje - cuadro.margin.position.x)
	return maxf(atras - medio_ancho, 0.0)


## Cuadro de un clip con tiempo propio, o -1 si es un bucle que corre el sprite. duraciones: las relativas del clip en
## el SpriteFrames, para repartir los ticks del estado en la misma proporcion.
static func cuadro(nombre: StringName, e: Estado, duraciones: PackedFloat32Array) -> int:
	match nombre:
		DANO:
			if e.ticks_hasta_reaparecer > 0:
				return 0
			return repartir(e.ticks_retroceso - e.ticks_retrocediendo, e.ticks_retroceso, duraciones)
		ATERRIZAJE_DURO:
			return repartir(e.ticks_aterrizaje_duro - e.ticks_aterrizando, e.ticks_aterrizaje_duro, duraciones)
		CURAR:
			return 0 if e.ticks_curados < TICKS_INICIO_CURAR else 1
		BOLA:
			if e.ticks_hasta_bola <= 0:
				return 0
			# Cuadros 2 y 3 durante la recarga de la bola.
			return repartir(e.ticks_recarga_bola - e.ticks_hasta_bola, e.ticks_recarga_bola, duraciones, 1)
		ESTOCADA:
			return repartir(e.ticks_ataque - e.ticks_atacando, e.ticks_ataque, duraciones)
		ATAQUE_ABAJO, ATAQUE_ARRIBA, ATAQUE_LADO:
			return repartir(e.ticks_entre_ataques - e.ticks_hasta_ataque, e.ticks_entre_ataques, duraciones)
		VOLTERETA:
			return 0 if _cuarto_de_vuelta(e) else 1
		IMPULSO:
			var transcurridos: int = e.ticks_impulso - e.ticks_impulsando
			if transcurridos < 2:
				return 0
			if e.ticks_impulsando <= 2:
				return 3
			# 2 y 3 alternados cada 2 ticks.
			return 1 + (((transcurridos - 2) >> 1) & 1)
		AIRE:
			if e.subiendo and e.ticks_subiendo < TICKS_DESPEGUE:
				return 0
			if e.velocidad.y < VY_SUBE:
				return 1
			if e.velocidad.y < VY_CIMA:
				return 2
			if e.velocidad.y < VY_EMPIEZA_A_CAER:
				return 3
			return 4
		GIRO_CARRERA:
			return repartir(e.ticks_giro_carrera - e.ticks_girando, e.ticks_giro_carrera, duraciones)
		SALTAR_PARED, PICADA_CARGA, PICADA:
			return 0
	return -1


## Giro del sprite en la voltereta, en radianes, mirando a la derecha: una vuelta cada ticks_vuelta. El cuadro 5 de
## la hoja ya esta a un cuarto de vuelta y el 6 a media, asi que el giro les resta lo que ya traen (escena HTML).
static func giro_voltereta(e: Estado) -> float:
	var grados: float = fmod(360.0 * float(e.ticks_voltereta) / float(e.ticks_vuelta), 360.0)
	return deg_to_rad(grados - 90.0 if _cuarto_de_vuelta(e) else grados - 180.0)


## Cuadro (desde 0) en que cae el tick transcurrido de total, repartido como las duraciones relativas del clip. Con
## desde, reparte solo los cuadros desde ese (sin copiar el arreglo) y devuelve el indice en el clip entero.
static func repartir(transcurrido: int, total: int, duraciones: PackedFloat32Array, desde: int = 0) -> int:
	if duraciones.size() <= desde or total <= 0:
		return desde
	var suma: float = 0.0
	for i: int in range(desde, duraciones.size()):
		suma += duraciones[i]
	var posicion: float = clampf(float(transcurrido) / float(total), 0.0, 1.0) * suma
	var acumulado: float = 0.0
	for i: int in range(desde, duraciones.size()):
		acumulado += duraciones[i]
		if posicion < acumulado:
			return i
	return duraciones.size() - 1


static func _cuarto_de_vuelta(e: Estado) -> bool:
	var grados: float = fmod(360.0 * float(e.ticks_voltereta) / float(e.ticks_vuelta), 360.0)
	return (grados >= 45.0 and grados < 135.0) or (grados >= 225.0 and grados < 315.0)
