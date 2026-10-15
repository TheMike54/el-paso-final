CERRADO

# Núcleo: botón de poderes, bola, pogo, caída en picada y enemigo base

Cinco entradas nuevas de `nucleo/funciones.json`, aprobadas por la persona el 06-oct-2026 (en este orden):
`boton-poderes`, `poder-bola`, `jugador-pogo`, `habilidad-caida-en-picada`, `enemigo-base`. Todo en gris, con su
sala en `herramientas/salas/` y un guion que falla sin la regla. Revisor en lo crítico (física del jugador, bus de
eventos, `Partida`).

## Decisiones (con su porqué)

1. **Tocar o mantener `curar`.** Se cuenta cuánto se mantiene. Si se suelta antes de `ticks_mantener_poder`
   (10, 1/6 s), es un toque: lanza la bola. Si se mantiene hasta ese tick, empieza la curación de siempre
   (`ticks_curacion` 60). Curar completo tarda 70 ticks (1,17 s), cerca de los 1,3 s del diseño. Una pulsación
   que empieza durante el impulso o el retroceso no cuenta, ni como toque ni para curar: así sigue valiendo
   `jugador_curar_tras_impulso`.
2. **Bola**, id de habilidad `proyectil`. Nombre técnico neutro: qué es en el mundo está por decidir.
   `nucleo/proyectil.tscn` (`class_name Proyectil`): sale hacia donde mira el jugador, recto y sin gravedad, y
   golpea una vez a cada `Golpeable` que toca (lo atraviesa). Desaparece contra un sólido o al acabar su
   recorrido. Cuesta `costo_poder` (33, lo mismo que curar, como en Hollow Knight) y no da Inspiración. Se puede
   lanzar en el aire.
3. **Daño.** `Golpeable.recibir_golpe(atacante, dano := 1)` y la señal `golpeado(atacante, dano)`. El ataque
   quita `dano_ataque` (1) y la bola, su `dano` (2).
4. **Pogo**: `atacar` con `mover_abajo` mantenida en el aire. El área de ataque va debajo del jugador. Al tocar
   un `Golpeable` o un peligro (`DanoContacto` con `peligro`), rebota hacia arriba (`altura_pogo`, 120 px) y
   recupera el doble salto y el impulso en el aire. Sobre un `Golpeable` también da Inspiración. No hay rebote
   horizontal.
5. **Caída en picada**, id `caida_en_picada`: `curar` con `mover_abajo` en el aire. Empieza en el tick de la
   pulsación, sin esperar a saber si es un toque. Cuesta `costo_poder`. Cae recto a `velocidad_picada`
   (1800 px/s), sin control, hasta tocar el suelo. Un `SueloFragil` (`nucleo/suelo_fragil.gd`) que toca se rompe
   y sigue cayendo. Sin invulnerabilidad: un golpe la corta. Que un suelo roto siga roto al volver no se guarda
   todavía.
6. **Enemigo base**: `nucleo/enemigo.tscn` (`class_name Enemigo`, `Node2D`), quieto. Patrullar entra con el
   primer enemigo real. Su ficha es `FichaEnemigo` (`nucleo/ficha_enemigo.gd`, un `Resource`): `vida`,
   `dano_contacto`, `tamano`, `color` y `reaparicion` (`AL_VOLVER_A_ENTRAR` o `AL_DESCANSAR`). Lleva un
   `Golpeable` y un `DanoContacto` creados con su tamaño. A vida 0 emite `Eventos.enemigo_vencido(id)` (señal
   nueva, la decisión 7 de la tanda anterior) y desaparece.
7. **Reaparición de enemigos.** El débil reaparece solo, porque la sala se instancia de nuevo al entrar. El
   fuerte vencido se anota en `Partida.enemigos_vencidos` (`"<escena de la sala>#<id del enemigo>"`), y al
   entrar a la sala no aparece. `Partida` borra la lista al oír `descanso_en_banco` y en `reiniciar()`. La lista
   no se guarda y Continuar la vacía (también la Inspiración): se continúa en un banco. Morir no la borra (sin comprobar qué hace Hollow
   Knight al morir).

## Hitos (cada uno con su guion)

| Entrada | Sala | Guion |
|---|---|---|
| `boton-poderes` | `sala_curar` | `boton_poderes.guion`: un toque no gasta Inspiración y mantener cura igual; `boton_poderes_peligro.guion` (sala del pogo): una pulsación a medias no sobrevive al punto seguro |
| `poder-bola` | `sala_bola` | `poder_bola.guion`: golpea al muñeco lejano y no atraviesa la pared; `poder_bola_sin_habilidad.guion`; `poder_bola_pegado_a_pared.guion` |
| `jugador-pogo` | `sala_pogo` | `jugador_pogo.guion` (pinchos, sin daño); `jugador_pogo_recupera.guion` (muñeco, impulso recuperado) |
| `habilidad-caida-en-picada` | `sala_picada` | `habilidad_caida_en_picada.guion`: rompe el suelo frágil y cae al piso de abajo; `habilidad_caida_en_picada_sin_habilidad.guion`; `habilidad_caida_en_picada_ataque.guion`: la picada corta un ataque a medias |
| `enemigo-base` | `sala_enemigos` | `enemigo_base.guion` (salir y volver: el débil vuelve, el fuerte no); `enemigo_descanso.guion` (tras el banco, el fuerte vuelve) |

## Cierre

- Cerrado el 06-oct-2026: las cinco entradas en `"pasa": true` con 43 de 43 guiones en verde y `OK  VALIDACION archivos=62 fallos=0`.
  Cada guion nuevo falla con su regla quitada. El revisor encontró cinco fallos (bola pegada a la pared, pulsación
  que sobrevivía al punto seguro, picada que dejaba el ataque, Continuar con enemigos vencidos y un guion del plan
  que no existía), corregidos y con guion; cuatro están en `docs/errores/`. Después aprobó.
- Probado en el Galaxy S20 con `adb`: la zona de pruebas lista las 17 salas, la bola sale con un toque, las salas
  nuevas corren a 60 FPS. Lo que pide jugar con los pulgares queda en `docs/pruebas.md`.
