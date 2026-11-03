class_name FichaAmuleto
extends Resource
# Un amuleto del juego, como dato: nombre, descripcion, costo en carga (como las muescas de Hollow Knight) e icono.
# Su efecto es un campo por efecto, neutro por omision: el jugador y el enemigo leen la suma de los puestos
# (Partida.efectos_amuletos). Vive en el catalogo (CatalogoEquipo); de solo lectura al correr, como toda ficha.

## Id estable: es lo que se guarda en la partida y lo que nombran la tienda, los NPC y los retos.
@export var id: StringName = &""
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
## Carga que ocupa puesto (1 a 3, como las muescas de Hollow Knight).
@export_range(1, 3) var costo: int = 1
## Su dibujo para la pagina Amuletos; sin el, la forma de gis de IconoArticulo.
@export var icono: Texture2D = null

@export_group("Efectos")
## Multiplica la rapidez al caminar del jugador (1: sin efecto).
@export var velocidad_factor: float = 1.0
## Ticks de invulnerabilidad que suma tras recibir dano (0: sin efecto).
@export var invulnerable_extra: int = 0
## Inspiracion que suma a cada golpe a un enemigo (0: sin efecto).
@export var inspiracion_extra: int = 0
## Multiplica las PejeCoins del botin de los enemigos (1: sin efecto).
@export var botin_factor: float = 1.0
