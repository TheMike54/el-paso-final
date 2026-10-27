# Contenido

Lo que se juega: salas, enemigos y objetos de cada zona. Se arma con las piezas del núcleo sin tocar `nucleo/`.

## Primero
Leer `funciones.json` de esta carpeta (una entrada por sala, más otra para lo que se prueba en el teléfono) y la sección «Sala» de `docs/contrato.md`, que fija
los ids, las puertas, los bancos y lo que revisa el validador.

## Dónde va cada cosa
| Qué | Dónde |
|---|---|
| Sala | `salas/<zona>/<id>.tscn`, con `id` igual al nombre del archivo (`celda_1`) |
| Enemigo | `enemigos/<id>/`: ficha `.tres` y script de comportamiento; en la sala va una instancia de `nucleo/enemigo.tscn` con esa ficha («Enemigos» de `docs/contrato.md`) |
| Objeto propio de una zona | `objetos/` |
| Cinemática | `cinematicas/cinematica_<nombre>.tscn` (raíz `Cinematica`, con `video` y `sala_destino`) junto a su `<nombre>.mp4` y `<nombre>.ogv` |

## Cómo se comprueba
- `.\herramientas\validar.ps1`: las reglas de sala de `docs/contrato.md`, «Sala» (lista completa ahí); propia de
  este bloque, `habilidades_de_prueba` vacío.
- Un guion por sala en `herramientas/guiones/contenido/`: entra por cada puerta, cruza cada puerta y descansa en
  el banco si hay.
