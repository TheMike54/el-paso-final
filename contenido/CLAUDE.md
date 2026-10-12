# Contenido

Lo que se juega: salas, enemigos y objetos de cada zona. Se arma con las piezas del núcleo sin tocar `nucleo/`.

## Primero
Leer `funciones.json` de esta carpeta (una entrada por sala) y la sección «Sala» de `docs/contrato.md`, que fija
los ids, las puertas, los bancos y lo que revisa el validador.

## Dónde va cada cosa
| Qué | Dónde |
|---|---|
| Sala | `salas/<zona>/<id>.tscn`, con `id` igual al nombre del archivo (`celda_1`) |
| Enemigo | `enemigos/<id>/`: ficha `.tres`, script de comportamiento y escena |
| Objeto propio de una zona | `objetos/` |

## Cómo se comprueba
- `.\herramientas\validar.ps1`: ids, puertas de ida y vuelta, bancos y `Entrada` de cada sala.
- Un guion por sala en `herramientas/guiones/contenido/`: entra por cada puerta, cruza cada puerta y descansa en
  el banco si hay.
