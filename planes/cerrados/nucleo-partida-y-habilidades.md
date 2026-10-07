CERRADO

# Núcleo: estado de la partida, muerte, peligros, banco y habilidades

Rama `feature/nucleo-movimiento-camara-sala`, sigue al plan cerrado `nucleo-movimiento-camara-sala.md`. Órdenes de
la persona del 06-oct-2026 (aprobadas): sesión autónoma, todo en gris (cajas y hitboxes de colores, sin arte ni
sonido), el teléfono de prueba (Galaxy S20) conectado para instalar, tocar y capturar. Revisor en lo crítico,
errores a `docs/errores/`, decisiones aquí, bloques de commit al final, nada a GitHub.

## Trabajo, en orden

| # | Qué | Se comprueba con |
|---|---|---|
| 1 | Muerte: el jugador se pinta oscuro 1,5 s y reaparece en `Entrada` con las vidas llenas (con bancos: en el último banco) | `jugador_reaparecer.guion` |
| 2 | Peligros: pinchos, ácido, fosas quitan una vida y devuelven al último punto seguro en suelo firme, no al inicio de la sala ni encima del peligro | `jugador_peligro.guion`, que falla sin el arreglo |
| 3 | `entrada-acciones`: el texto nombra a `controles_tactiles.gd` como la única excepción | `validar.ps1` |
| 4 | `estado-partida`: autoload `Partida` con vidas y habilidades, que se conservan al cambiar de sala; el guardado guarda y carga desde ahí | `estado_partida.guion` |
| 5 | Documentos de las decisiones aceptadas, `nucleo/CLAUDE.md`, `docs/errores/`, el `CLAUDE.md` raíz y el teléfono de prueba | Lectura |
| 6 | `banco` y `puerto-guion-salas` | `banco.guion`; guiones existentes |
| 7 | `jugador-curar`, `jugador-golpe-sensacion`, `habilidad-impulso`, `habilidad-salto-en-pared`, `habilidad-doble-salto`, cada una con su sala de prueba | Un guion cada una |

Fuera: caída en picada y pogo (falta decidir cómo conviven).

## Decisiones

1. **Reaparecer al morir**: lo hace la sala, que escucha `Eventos.jugador_muerto`, espera 90 ticks y recarga la
   escena con `Partida.llenar_vidas()`. Con bancos, irá al último banco (decisión de la persona).
2. **Punto seguro**: el jugador guarda su posición cuando lleva `ticks_suelo_firme` (6) ticks seguidos en el suelo
   y no está invulnerable (así no cuenta un suelo con pinchos que pisó sin recibir daño). Un peligro quita una vida,
   lo lleva ahí, lo deja quieto `ticks_reaparicion_peligro` (20) ticks e invulnerable; invulnerable no pierde vida
   pero igual vuelve al punto seguro. Si el golpe lo mata, muere y reaparece como en 1. Hollow Knight lo hace con
   puntos de reaparición que colocan los diseñadores, según la memoria del investigador, pero eso no se comprobó
   (la wiki no abrió): se siguió la orden de la persona, «última posición segura en suelo firme».
   **Para que Miguel confirme**: puntos colocados a mano en vez del cálculo automático.
3. **`DanoContacto.peligro`**: el mismo componente sirve para enemigos (retroceso) y peligros (punto seguro).
4. **`Partida`** (autoload antes de `Arranque`): `vidas`, `vidas_maximas`, `banco`, `sala`, `habilidades` e
   `inspiracion` (esta no se guarda). `Jugador.vidas` lee y
   escribe ahí. Nueva partida y la zona de pruebas llaman `Partida.reiniciar()`; Continuar carga el guardado en
   `Partida`. `Partida.a_diccionario()` da los campos del esquema del guardado.

## Avance

- Puntos 1, 2 y 4 programados el 06-oct-2026: `jugador_reaparecer`, `jugador_peligro` y `estado_partida` en verde;
  cada uno falla con su regla quitada. Revisor: un fallo de código (una pulsación de `saltar` justo antes del
  peligro hacía saltar al reaparecer), corregido y cubierto por `jugador_peligro.guion` en el cuadro 158; y
  fallos de documento, corregidos. Se quitó el `llenar_vidas()` de `Jugador._ready`, que nunca se ejecutaba y
  tapaba una falla de la sala.
- Punto 3: el texto de `entrada-acciones` nombra a `controles_tactiles.gd` como la única excepción.
- Punto 5: `docs/errores/` con seis archivos, el `CLAUDE.md` raíz (puntos 8 y 9 de la persona) y
  `nucleo/CLAUDE.md` aplicados; teléfono de prueba corregido a S20 en las notas privadas.
- Punto 6, `banco`: `nucleo/banco.gd`; para reaparecer en el último banco hace falta su sala, así que el guardado
  pasa a la versión 2 con el campo `sala` (una partida de la versión 1 se lee como incompatible). Las salas de
  prueba guardan en `user://prueba_banco.json`, no en la partida real. En el teléfono no había cómo mandar
  `interactuar`: el joystick hacia arriba también lo manda, como la flecha arriba y el stick arriba.
  `puerto-guion-salas`: entrada nueva en `herramientas/funciones.json`; su comprobación usa las tres claves.
- Punto 7, decisiones (para que Miguel confirme los valores, todos exportados):
  - Curar: solo en el suelo, quieto, 33 de Inspiración por vida en 60 ticks (1 s; la wiki de Hollow Knight da
    unos 1,14 s y 33 de Alma); cada golpe da 11. La Inspiración se gasta poco a poco: soltar o un golpe pierden lo
    gastado. Sin barra en pantalla (interfaz). No se puede empezar a curar durante un impulso.
  - Sensación: el jugador retrocede 16 px al golpear y el golpeado 24; hit-stop de 4 ticks solo del jugador al
    recibir daño (no en peligros ni al morir). Sin fuente con duraciones de Hollow Knight.
  - Impulso: 200 px en 10 ticks sin gravedad, recarga 36 ticks, uno en el aire hasta tocar suelo o pared. Si
    `saltar` e `impulso` llegan en el mismo tick en el suelo, el impulso anula el salto y no gasta el impulso del
    aire: se deja así (caso raro, sin efecto malo); para que Miguel confirme.
  - Salto en pared: desliza a 150 px/s empujando hacia la pared; el salto despega 8 ticks hacia el otro lado.
  - Doble salto: un segundo salto en el aire, que se recupera en el suelo o en la pared.
  - Las salas de prueba de habilidades dan la habilidad con `ObjetoHabilidad` (la zona de pruebas reinicia la
    partida al entrar); en el juego la darán los jefes.
- Revisor de los puntos 6 y 7: un fallo de código (curar congelaba el impulso y el rebote, que seguían al
  terminar), corregido con `jugador_curar_tras_impulso.guion`, y fallos de documento, corregidos. En el teléfono
  se vio que la zona de pruebas ya no cabía: ahora es una cuadrícula de tres columnas.
- Cerrado el 06-oct-2026: los siete puntos hechos. `estado-partida`, `banco`, `jugador-curar`,
  `jugador-golpe-sensacion` y las tres habilidades tienen `"pasa": true` con su guion (31 guiones en verde);
  `puerto-guion-salas` también. Lo que pide pantalla o pulgares sigue en `docs/pruebas.md`.
