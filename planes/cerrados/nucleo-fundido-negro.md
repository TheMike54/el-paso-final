CERRADO

# Núcleo: fundido a negro al tocar un peligro, al morir y al cruzar una puerta

Pedido de la persona el 11-oct-2026, tras comprobar en Hollow Knight que caer sobre pinchos (con picada o sin ella)
pone la pantalla en negro y reaparece en el último punto seguro. Opción elegida: c (peligros, muerte y puertas).
Aprobado el 11-oct-2026, con su entrada. Rama `feature/nucleo-reglas-pendientes`; entra en el mismo commit que las
reglas pendientes.

## 1. Lo que hay (leído el 11-oct-2026)

- Peligro (`nucleo/jugador.gd`, `_reaparecer`): el jugador aparece de golpe en el punto seguro y se queda quieto
  `ticks_reaparicion_peligro` (20) ticks.
- Muerte (`_morir`): se pinta oscuro 1,5 s y reaparece en el banco o la `Entrada`; si el banco está en otra sala,
  `nucleo/sala.gd` cambia de escena.
- Puerta (`nucleo/puerta.gd`): cambia de escena en el acto (`change_scene_to_file` diferido).
- No hay ninguna capa de fundido.

## 2. Propuesta

| # | Qué | Cómo | Archivos |
|---|---|---|---|
| 1 | Capa de fundido | `nucleo/fundido.gd`: un `CanvasLayer` con un rectángulo negro sobre el juego, la interfaz y los botones, y debajo de la pausa (ajuste del 11-oct-2026; antes, debajo de la interfaz y los botones). Oscurece y aclara contando ticks de física, no con un `Tween` de tiempo real, para que los guiones den lo mismo siempre. La sala la crea, como crea la pausa y la interfaz | `nucleo/fundido.gd`, `nucleo/sala.gd` |
| 2 | Cada sala empieza en negro y aclara | Al entrar a una sala (por una puerta, al reaparecer en otra sala o desde el menú), la imagen aclara en 0,25 s | `nucleo/sala.gd` |
| 3 | Peligro | El jugador se queda quieto donde tocó el peligro; la pantalla oscurece en 0,15 s; ya en negro, pasa al punto seguro y la cámara salta sin suavizado; la imagen aclara en 0,25 s y recupera el control. Unos 0,5 s en total (hoy, 0,33 s). El anti-bucle y la vida no cambian | `nucleo/jugador.gd`, `nucleo/eventos.gd` |
| 4 | Muerte | Al final del 1,5 s oscuro, la pantalla oscurece en 0,15 s, el jugador reaparece (o cambia la sala) y la imagen aclara | `nucleo/jugador.gd`, `nucleo/sala.gd` |
| 5 | Puerta | Al cruzarla, oscurece en 0,15 s y después cambia de sala; la sala nueva aclara (punto 2) | `nucleo/puerta.gd` |

El jugador avisa con una señal nueva de `Eventos` (con los ticks de oscurecer y de aclarar) y el fundido la escucha:
cambia el contrato (`docs/contrato.md`, tabla del bus de eventos) en el mismo cambio. Las duraciones son
constantes de `nucleo/fundido.gd`, provisionales, para ajustarlas en el teléfono.

## 3. Cómo se comprueba

- Guion `fundido_peligro`: en la sala de peligro, caer al foso; a mitad del fundido la capa está en negro y el
  jugador ya en el punto seguro; al terminar, la capa transparente y el jugador con control.
- Guion `fundido_puerta`: cruzar una puerta; la sala nueva empieza en negro y aclara.
- Los guiones de peligro, muerte y puertas cambian de tiempos a propósito: se actualizan sus `.esperado` y se dice
  cuáles. `validar.ps1` en verde y todos los guiones.
- `revisor`: sí (física del jugador, bus de eventos y contrato).
- Manual, en el teléfono: pinchos de la sala del pogo, morir en la sala de combate y cruzar las puertas A y B. Ver
  que el negro también oscurezca los corazones y los botones y no la pausa, y anotar si se siente largo o corto.

Entrada nueva para `nucleo/funciones.json` (la aprueba la persona):

- `fundido-a-negro`: «Al tocar un peligro, al morir y al cruzar una puerta la pantalla funde a negro y vuelve con
  el jugador ya en su lugar» · comprobación: `herramientas/guiones/nucleo/fundido_peligro.guion`.

## Avance

- [x] Plan aprobado por la persona, con su entrada de `funciones.json` (11-oct-2026).
- [x] Programado: `nucleo/fundido.gd`, señal `fundido_pedido`, jugador (quieto 9 ticks donde toca el peligro y pasa
  al punto con la pantalla en negro; nada lo daña mientras), sala (crea el fundido en negro; funde al morir) y puerta.
  Guiones nuevos `fundido_peligro` y `fundido_puerta`; mutaciones: pasar al punto en el acto y la sala sin
  fundido inicial los hacen fallar. Cambiaron a propósito, por los 9 ticks del fundido: `cambio_de_sala` (x 292 a
  244), `enemigo_base` (x 1018 a 1042), `jugador_peligro` (fin 158 a 168), `jugador_peligro_anti_bucle_contacto`
  (fin 80 a 100) y las pruebas `aterrizaje` y `peligro_anti_bucle` (esperan el fundido). 81 de 81 guiones.
- [x] `revisor` (11-oct-2026): un fallo, la salida por abajo pasaba al punto un tick después del negro (se revisaba
  después de mover); ahora se revisa antes y lo cubre `fundido_salida_abajo` (con el orden viejo, capa a 0,93).
  Arreglado también: la puerta no cambia de sala si el jugador muere mientras funde; un pedido de fundido a media
  transición oscurece desde la opacidad que hay; al empezar el fundido de un peligro se cortan el ataque y el temblor.
  Guion nuevo `fundido_peligro_negro` (el tick del negro). 83 de 83 guiones.
- [x] `revisor`, segunda pasada sobre los arreglos: aprobado (11-oct-2026).
- [x] Prueba en el teléfono (persona, 11-oct-2026, S50): funciona. Pidió: más negro tras los pinchos, parecido al de la
  muerte; un poco más en las puertas, menos que en los pinchos; la muerte sin cambios; los corazones y los botones
  también se oscurecen, y la pausa se ve si se abre.
- [x] Ajuste: el fundido sigue en negro un tiempo antes de aclarar (`fundido_pedido` lleva `ticks_en_negro`):
  `TICKS_EN_NEGRO_PELIGRO` 18 (0,3 s; la muerte ya tenía la pausa de recargar la sala) y `TICKS_EN_NEGRO_PUERTA` 6
  (0,1 s), provisionales. Capa 4 → 15: encima de los controles (5) y la interfaz (10), debajo de la pausa (20) y el
  editor (21). Guion nuevo `fundido_peligro_sostenido` (con el negro en 0, capa en 0). Cambiaron a propósito:
  `fundido_puerta` (fin 74 a 80), `cambio_de_sala` (soltar en 76, fin 86), `enemigo_base` (x 1042 a 1078),
  `jugador_peligro` (fin 168 a 186), `jugador_peligro_anti_bucle_contacto` (fin 100 a 118) y
  `jugador_peligro_anti_bucle` (fin 400 a 500).
- [x] `revisor` sobre el ajuste: aprobado (11-oct-2026).
- [x] Segunda prueba en el teléfono (persona, 11-oct-2026, S50): pasa; las duraciones se quedan así.
