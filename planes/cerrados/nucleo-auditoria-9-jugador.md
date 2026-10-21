CERRADO

# Auditoría, paso 9: el jugador por dentro (T7)

Paso 9 de `nucleo-auditoria-codigo.md`, tanda T7. Ids: J3, J4, J7, J16-J19, J22 y la cámara. J2, la máquina de
estados, quedó descartado por la persona el 17-oct.

Regla: el juego no cambia nada. Se conservan el orden de las ramas, el tick y los valores. Es un punto crítico, porque
toca la física y el movimiento del jugador: cada pieza lleva el revisor.

## Consulta (18-oct, agente investigador) y decisiones de la sesión principal

| Decisión | Elegido | Por qué |
|---|---|---|
| J7, J17, J18, J19, J22 | Se hacen, en una sola pieza | Son reordenamientos y helpers sin efecto. J18 pasa el eje a `_impulsar(eje)`: entre las dos lecturas nada cambia la entrada. J19 se calcula una vez: `is_on_floor()` no cambia sin un `move_and_slide` en medio |
| J3 (`_mover`) | Se hace: `_avanzar_contadores` y `_chocar_corriendo` | `_recordar_punto_seguro` queda fuera, porque lee `_ticks_sin_dano` antes de que el contador baje |
| J4 (`_atacar`) | Se hace: `_iniciar_ataque` y `_golpear(area)` | Los `continue` pasan a `return` dentro de `_golpear`, y el `elif` del pogo queda colgado del mismo `if` |
| J16 (`TAMANO` en el `.gd` y en el `.tscn`) | Se descarta | El `RectangleShape2D` del `.tscn` lo comparten todas las instancias (`resource_local_to_scene` es `false` por omisión, `classes/class_resource.rst:186-197`). Fijar `size` en `_ready` escribiría un recurso compartido en cada instancia, que es lo que prohíbe la regla de las fichas de solo lectura. El valor es el mismo y no arregla nada |
| Cámara | Se hace, como la última pieza: un script `CamaraJugador` en el nodo `Camara` | La cámara no tiene `_physics_process` ni `_ready` propios. El jugador la llama en los mismos puntos que hoy: seguir al final del tick, el temblor dentro de `_aterrizar` y colocarla al reaparecer. Un tick propio correría en otro orden y movería el temblor durante el congelado, y eso rompe los `.esperado` de `camara_temblor*` (tolerancia 0,05) |
| Lo que leen los guiones | `Jugador.temblor_x` y `temblor_y` quedan como propiedades con `get` que lee de la cámara. `temblar()` y `fijar_limites()` delegan, y `fijar_limites` sigue guardando `_limites` en el jugador | Los `.esperado` leen `Jugador temblor_y`. `_revisar_salida_por_abajo` usa `_limites`. `ticks_caida_dura`, `temblor_px` y `temblor_ticks` se quedan en el jugador, porque disparan el aterrizaje y los lee `prueba_aterrizaje` |
| Red de seguridad | Un trazador en el scratchpad que imprime por tick la posición, la velocidad, `Camara.global_position` y `offset` en varias salas con entradas fijas. Se compara byte a byte antes y después de cada pieza | Ningún guion comprueba el seguimiento horizontal ni `adelanto_camara`. Si la cámara no sale idéntica, se descarta sin tocar las otras piezas |

## Piezas, una por agente

1. El trazador y la línea base, tomada antes de tocar nada; después J7, J17, J18, J19 y J22.
2. J3.
3. J4.
4. La cámara, con `docs/jugador.md`, `docs/contrato.md` y la entrada de `nucleo/funciones.json` que nombra `temblor_x`.
5. El revisor del paso.

## Hitos

1. Después de cada pieza: `validar.ps1` → `fallos=0`; `correr-guiones.ps1` → `MALOS=0`, sin que cambie ningún
   `.esperado`; el trazador, idéntico a la línea base.
2. `nucleo/jugador.gd` con menos líneas y funciones más cortas.
3. El revisor aprueba.

## Avance

- 18-oct, pieza 1, hecha por un agente.
  - **Trazador:** `trazar-jugador.ps1`, en el scratchpad, sobre una copia del repo.
    - Traza 36 guiones del jugador y de la cámara.
    - Por tick guarda la posición y la velocidad del jugador, su ataque, y la cámara (posición, `offset`, centro de
      pantalla y temblor).
    - Dos corridas seguidas del mismo código dan lo mismo.
    - Detecta cambios: con `adelanto_camara` de 43 a 44, la traza sale distinta y ningún guion falla.
    - La línea base se tomó con el código de antes del paso.
  - **Cambios en el código:**
    - J7: `_envejecer(ticks)` en lugar de 5 `mini(x + 1, NUNCA)`.
    - J17: `ACCIONES_LEVANTARSE`, una `const`.
    - J18: el eje se lee una vez y pasa a `_impulsar(eje)`.
    - J19: `abajo_en_el_aire`, una sola vez.
    - J22: `@onready` tras las variables, `_process` antes de `_physics_process` y `_draw` después.
    - Las públicas que hay entre las privadas no se movieron: no entraba en J22.
  - **Tamaño:** de 1408 a 1417 líneas. Las 9 de más son el helper, la `const` y sus comentarios.
  - **Resultados:**
    - `validar` → `OK  VALIDACION archivos=256 fallos=0`;
    - `correr-guiones` → `RESUMEN total=151 OK=151 MALOS=0`;
    - trazador → `TRAZA IDENTICA n=36`.
- 18-oct, pieza 2 (J3), hecha por un agente.
  - **Funciones nuevas:**
    - `_avanzar_contadores(en_suelo)`: voltereta, `_ticks_sin_suelo`, las colas, los tres contadores que bajan y
      `_recuperar_aire`;
    - `_chocar_corriendo()`: el rebote y el fin de la voltereta contra una pared.
  - **Sin cambios:** los bloques se movieron tal cual. `_recordar_punto_seguro` se queda fuera y justo antes, y los
    `return` siguen en `_mover`.
  - **Tamaño:** `_mover` pasa de 90 a 61 líneas, y el archivo de 1417 a 1427.
  - **Resultados:**
    - `validar` → `OK  VALIDACION archivos=256 fallos=0`;
    - `correr-guiones` → `RESUMEN total=151 OK=151 MALOS=0`;
    - trazador → `TRAZA IDENTICA n=36`.
- 18-oct, pieza 3 (J4), hecha por un agente.
  - **Funciones nuevas:**
    - `_iniciar_ataque(abajo_en_el_aire)`: el cuerpo de `if pedido:`, movido sin cambios;
    - `_golpear(area)`: el cuerpo del `for`.
  - **Los `continue`:** los de Cortable y AtaqueEnemigo pasan a ser `return`. Eran lo último de su vuelta, así que el
    efecto es el mismo.
  - **Lo que se queda igual:**
    - el `elif` del pogo cuelga del mismo `if`;
    - `pedido` sigue en `_atacar`;
    - no había estado local que se acumulara de un área a otra: todo es estado del jugador.
  - **Tamaño:** `_atacar` pasa de 67 a 25 líneas, y el archivo de 1427 a 1437.
  - **Resultados:**
    - `validar` → `OK  VALIDACION archivos=256 fallos=0`;
    - `correr-guiones` → `RESUMEN total=151 OK=151 MALOS=0`;
    - trazador → `TRAZA IDENTICA n=36`.
- 18-oct, pieza 4 (cámara), hecha por un agente.
  - **`CamaraJugador`** (`nucleo/camara_jugador.gd`, 143 líneas) es el script del nodo `Camara` de `jugador.tscn`. No
    tiene tick ni `_ready` propios.
  - **Cuándo la llama el jugador:**
    - `iniciar` en su `_ready`;
    - `seguir` al final del tick;
    - `avanzar_temblor` en `_aterrizar`;
    - `detener_temblor` y `colocar` al reaparecer y tras un peligro.
  - **Delegan en la cámara:** `temblar`, `fijar_limites`, y las lecturas `temblor_x` y `temblor_y`.
  - **Lo que se mudó:** 4 exports (`suavizado_camara_x`, `tiempo_camara_y`, `adelanto_camara` y `temblor_fraccion_x`).
  - **Tamaño:** el jugador pasa de 1437 a 1334 líneas.
  - **Documentación:** se ajustaron `docs/jugador.md` y `docs/contrato.md`, y hay una entrada nueva,
    `camara-jugador-script-propio`.
  - **Diferencias que vio el propio agente:**
    - En `_colocar_tras_peligro`, el corte del temblor va ahora después de tres asignaciones de las que no depende.
    - `temblor_x` y `temblor_y`, leídas antes del `_ready`, fallarían. Ningún guion lo hace.
    - `_limites` queda copiado en el jugador y en la cámara, y `fijar_limites` pone los dos.
  - **Resultados:**
    - `validar` → `OK  VALIDACION archivos=257 fallos=0`;
    - `correr-guiones` → `RESUMEN total=151 OK=151 MALOS=0`;
    - trazador → `TRAZA IDENTICA n=36`.
- 18-oct, pieza 5: el revisor aprobó el paso sin fallos.
  - **Línea base:** trazó aparte el jugador de antes del paso y salió igual a la base y a la versión nueva, 36 de 36
    archivos.
  - **Observaciones**, que quedan como están:
    - los `get` de `temblor_x` y `temblor_y` fallan si se leen antes del `_ready`, y hoy nadie los lee antes;
    - `_limites` está en dos lugares;
    - la entrada vieja del temblor en `nucleo/funciones.json` dice que lo «calcula» el jugador, y ahora lo calcula su
      cámara. No se reescribe, por la regla de `funciones.json`.
  - **Entrada:** `camara-jugador-script-propio` pasa a `"pasa": true`.
  - **Resultados:**
    - `validar` → `OK  VALIDACION archivos=257 fallos=0`;
    - `correr-guiones` → `RESUMEN total=151 OK=151 MALOS=0`;
    - trazador → `TRAZA IDENTICA n=36`.
  - **Tamaño:** el jugador pasa de 1408 a 1334 líneas, y la cámara suma 143 en su propio script.
