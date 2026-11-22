class_name Utiles
extends RefCounted
# Los ids de los utiles, en un solo lugar, como Habilidades: el codigo que lee un util (el mapa, el jugador, los
# enemigos, la partida) usa estas constantes y no el texto escrito a mano. Son ids que se guardan en la partida: no
# se renombran. Nombre, descripcion e icono viven en la ficha de cada uno (FichaUtil, en contenido/equipo.tres).

## Con ella puesta, el mapa marca donde esta el jugador.
const BRUJULA: StringName = &"brujula"
## Los enemigos sueltan mas PejeCoins.
const GATO_SUERTE: StringName = &"gato_suerte"
## Cada golpe de un enemigo da Inspiracion; los peligros no.
const LOG_ERRORES: StringName = &"log_errores"
## Al morir se conserva la mitad de las PejeCoins.
const CARTERA_EMERGENCIA: StringName = &"cartera_emergencia"
## Los golpes empujan la mitad.
const SUELA_ANTIDERRAPANTE: StringName = &"suela_antiderrapante"

## Gato de la Suerte: multiplica el botin de los enemigos (Enemigo._soltar_botin, redondeado).
const FACTOR_BOTIN_GATO: float = 1.5
## Suela Antiderrapante: multiplica el retroceso de un golpe recibido (Jugador.recibir_dano).
const FACTOR_EMPUJE_SUELA: float = 0.5

## Todos, en el orden del catalogo del juego (contenido/equipo.tres). La pagina Utiles lista en el orden en que se
## obtuvieron (Partida.utiles_tenidos); esta lista la usan las pruebas y la guia de amuletos y utiles.
const TODOS: Array[StringName] = [BRUJULA, GATO_SUERTE, LOG_ERRORES, CARTERA_EMERGENCIA, SUELA_ANTIDERRAPANTE]
