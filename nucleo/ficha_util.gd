class_name FichaUtil
extends Resource
# Un util del juego, como dato: algo que se equipa en su propia ranura y no gasta la carga de los amuletos, como las
# herramientas de Silksong (la brujula: el mapa la pide equipada, GameMap.cs:1316-1317 de la referencia). Lo que hace
# cada util lo decide quien lo lee por su id (la brujula, mapa/pantalla_mapa.gd). Vive en el catalogo (CatalogoEquipo).

## Id estable: es lo que se guarda en la partida y lo que nombran la tienda, los NPC y los retos.
@export var id: StringName = &""
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
## Su dibujo para la pagina Utiles; sin el, la forma de gis de IconoArticulo.
@export var icono: Texture2D = null
