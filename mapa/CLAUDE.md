# Mapa

Pantalla del mapa: el mapa completo y el mapa rápido. No conoce ninguna zona: dibuja las salas del índice que la
partida tiene mapeadas. La sala lo carga con `load()` si existe; sin esta carpeta el juego corre igual.

## Primero
Leer `funciones.json` de esta carpeta y la sección «Mapa» de `docs/contrato.md`.

## Piezas: lo que no se deduce del código
| Pieza | Contrato |
|---|---|
| `pantalla_mapa.tscn` | La crea la sala. `mapa` abre el completo (detiene el juego); `mapa_rapido` mantenida lo muestra sin detenerlo |
| `indice_salas.tres` | Lo escribe `herramientas/generar_mapa.tscn`; no se edita a mano. El paquete exportado no lista escenas con fiabilidad: por eso existe |
| Dibujo de una sala | `<id>_mapa.png` junto a la escena de la sala; sin él se dibuja su rectángulo |

## Reglas
- Al agregar o mover una sala, o al cambiar sus límites, su `posicion_mapa` o su dibujo, regenerar el índice:
  `& $env:GODOT_PATH --headless --path . --quit-after 600 res://herramientas/generar_mapa.tscn`. El validador
  falla si no está al día.
- Nada del núcleo depende de esta carpeta: la pausa la respeta por el grupo `pantalla_encima`, no por su clase.

## Cómo se comprueba
- `herramientas/guiones/mapa/mapa_cuentas.guion`: las cuentas y la pantalla sobre la sala `mapa_1`.
- En el teléfono, la fila «Mapa» de `docs/pruebas.md`.
