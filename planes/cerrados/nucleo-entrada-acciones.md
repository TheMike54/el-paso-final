CERRADO

# Núcleo: acciones de entrada

Funcionalidad `entrada-acciones` de `nucleo/funciones.json`. Rama `feature/nucleo-entrada-acciones`, que sale de
`feature/herramientas-puerto-guion`. Plan aprobado el 06-oct-2026.

## Qué entra

Todas las acciones del juego en el `InputMap`, con su teclado inicial como tecla física (`physical_keycode`):

| Acción | Teclado inicial |
|---|---|
| `mover_izquierda` | A |
| `mover_derecha` | D |
| `mover_arriba` | Flecha arriba |
| `mover_abajo` | Flecha abajo |
| `saltar` | W |
| `atacar` | Espacio |
| `curar` | Q |
| `impulso` | Flecha derecha |
| `interactuar` | Flecha arriba |
| `mapa_rapido` | Tab |
| `mapa` | M |
| `mochila` | I |
| `pausa` | Esc |

## Decisiones

- `interactuar` es una acción aparte con la misma tecla que `mover_arriba`: se reasigna por separado y el
  táctil la emite desde el botón de atacar. Cuál de las dos vale junto a algo lo decide la lógica del jugador.
- La caída en picada (abajo + atacar en el aire) y el salto en pared (empujar hacia la pared en el aire) son
  combinaciones de acciones existentes, no acciones propias.
- El control (Xbox / PlayStation) queda fuera: va como funcionalidad aparte.
- Las flechas izquierda, Shift derecho, F, C, V, J y T quedan sin acción, reservadas para habilidades futuras.

## Hitos

1. `project.godot` y la sección «Entrada» de `docs/contrato.md` con la tabla de arriba.
   Comprobación: `.\herramientas\validar.ps1` imprime `OK  VALIDACION ... fallos=0`.
2. Godot carga cada acción con su tecla. Comprobación: un script headless que recorre `InputMap` e imprime cada
   acción con `OS.get_keycode_string` de su `physical_keycode`; la lista coincide con la tabla.
3. Ningún `.gd` de `nucleo/` lee teclas ni toques. Comprobación: búsqueda de `InputEventKey`,
   `InputEventScreenTouch`, `InputEventScreenDrag`, `is_key_pressed` y `is_physical_key_pressed` en `nucleo/`
   sin resultados.
4. Revisión del `revisor` (toca `project.godot`), `"pasa": true` y `ESTADO.md` al día.
