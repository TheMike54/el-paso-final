# Contenido

Lo que se juega: salas, enemigos y objetos de cada zona. Se arma con las piezas del núcleo sin tocar `nucleo/`.

## Primero
Leer `funciones.json` de esta carpeta y la sección `docs/sala.md`, que fija
los ids, las puertas, los bancos y lo que revisa el validador.

## Dónde va cada cosa
| Qué | Dónde |
|---|---|
| Sala | `salas/<zona>/<id>.tscn`, con `id` igual al nombre del archivo (`celda_1`) |
| Enemigo | `enemigos/<id>/`: ficha `.tres` y script de comportamiento; en la sala va una instancia de `nucleo/enemigo.tscn` con esa ficha («Enemigos» de `docs/enemigos.md`) |
| NPC | `npc/<id>/`: su `FichaDialogo` y su `SpriteFrames`; en la sala va una instancia de `Npc` (`docs/sala.md`). Un NPC que aparece en varias zonas no va en `salas/<zona>/` |
| Base de zona | `zonas/<zona>/sala_<zona>.tscn`: grupos de capas, oscuridad, tinte y música comunes (la niebla va en cada sala); cada sala de la zona la hereda («Arte de zona» de `docs/arte-y-rendimiento.md`) |
| Objeto propio de una zona | `objetos/<zona>/`: piezas (puertas con arte, luces, peligros) heredadas de una escena del núcleo; la sala instancia la pieza, no sus partes |
| Amuletos y útiles | `equipo.tres`: una entrada por ficha («Amuletos y útiles» de `docs/contrato.md`) |
| Cinemática | `cinematicas/cinematica_<nombre>.tscn` (raíz `Cinematica`, con `video` y `sala_destino`) junto a su `<nombre>.mp4` y `<nombre>.ogv` |

## Piezas de la sala

Puertas y estaciones van como hijas directas de la raíz de la sala, sin un nodo intermedio: `Sala` las busca entre sus
hijos para la llegada. Un banco también puede ir dentro de una pieza (`nucleo/sala.gd`, `nucleo/banco.gd`).

## Cómo se comprueba
- `.\herramientas\validar.ps1`: las reglas de sala de `docs/sala.md` (lista completa en `docs/validador.md`); propia de
  este bloque, `habilidades_de_prueba` vacío.
- Un guion de ruta por sala en `herramientas/guiones/contenido/`, más los que pida `docs/errores/`: entra y cruza cada
  puerta y descansa en el banco si hay.
