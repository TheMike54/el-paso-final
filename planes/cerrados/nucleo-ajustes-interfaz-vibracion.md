CERRADO

# Núcleo: ajustes tras la prueba en el teléfono, vibración e interfaz mínima

Pedido por la persona el 06-oct-2026, después de probar el núcleo en el Galaxy S20. Todo en gris. Tres partes:
ajustes al jugador y a las salas para que se parezcan más a Hollow Knight, una entrada nueva de vibración
(aprobada) y el bloque `interfaz/` con sus entradas (aprobadas). Los ajustes cambian funcionalidades que ya
pasan: sus entradas de `nucleo/funciones.json` no se reescriben; las reglas nuevas quedan aquí, en
`docs/contrato.md` y en sus guiones. Revisor al final: física del jugador, bus de eventos, contrato.

## Fuentes

Lo que se encontró de Hollow Knight tiene poca fuente: casi todo son descripciones de la wiki de la comunidad
(hollowknight.wiki) y ningún valor extraído del juego. Donde no hay fuente manda la descripción de la persona y
el valor es una propiedad exportada que se afina en el teléfono.

## Decisiones (con su porqué)

1. **Caída en dos tramos.** La persona: «al principio caes más lento y después de cierta distancia más rápido».
   Misma gravedad y dos topes: los primeros `distancia_caida_inicial` px de cada caída (240, desde la cima del
   salto o desde la orilla) tienen el tope `velocidad_caida_inicial` (700 px/s); después, `velocidad_caida_max`
   (1200). La subida no cambia, así que la altura del salto tampoco; un salto normal (200 px) cae con el tope
   inicial. Sin fuente de los valores de Hollow Knight.
2. **Salto en pared entre dos paredes.** La wiki: el salto en pared se repite sin límite y permite trepar una sola
   pared. Hoy solo se puede saltar de una pared cayendo (`velocity.y >= 0`), así que al llegar subiendo a la
   pared de enfrente hay que esperar a caer. Ahora el salto sale tocando la pared y empujando hacia ella, suba o
   baje; deslizarse sigue siendo solo al caer.
3. **Recarga de la bola.** La wiki: sin cooldown explícito, la limita el SOUL. La persona pidió que no salgan dos
   seguidas: `ticks_recarga_bola` (exportado, para que un amuleto lo reduzca). Alcance sin cambio (1 s), sin
   fuente.
4. **Caída en picada.** La wiki: daño al aterrizar (onda de choque), invulnerabilidad y se puede desde el suelo.
   Al aterrizar, una onda de `ancho_onda_picada` daña con `dano_picada` a cada `Golpeable` que toca. Invulnerable
   desde que empieza hasta `ticks_invulnerable_picada` después de aterrizar (un peligro igual lo devuelve al
   punto seguro). Desde el suelo, abajo + curar da un saltito (`altura_saltito_picada`), espera
   `ticks_carga_picada` sin gravedad y baja sola (descripción de la persona). En el aire sigue saliendo en el
   tick de la pulsación.
5. **Banco.** Al descansar, el jugador se acomoda sobre el banco (misma x), se dibuja sentado y queda quieto; la
   interfaz muestra «Partida guardada» cuando el guardado salió bien (señal nueva `partida_guardada`). Se levanta
   con cualquier movimiento, saltar o atacar (sin fuente de cómo es en Hollow Knight).
6. **Pausa al perder el foco.** Al salir de la app o cambiar de ventana, la pausa se abre sola
   (`NOTIFICATION_APPLICATION_FOCUS_OUT` y `NOTIFICATION_APPLICATION_PAUSED`). Sin fuente de que Hollow Knight lo
   haga; lo pidió la persona.
7. **Enemigos fuertes al morir.** Sin fuente: no cambia (solo descansar los hace volver). Queda abierta.
8. **Sala de enemigos con el banco aparte.** El banco pasa a una sala nueva conectada por la puerta derecha
   (`sala_enemigos_banco.tscn`): entrar, vencer, salir, volver (solo el débil), ir al banco, descansar, volver
   (los dos).
9. **Dedo perdido al cambiar de sala** (fallo, `docs/errores/2026-10-06-dedo-perdido-al-cambiar-de-sala.md`): los
   controles táctiles recuerdan sus dedos en variables estáticas.
10. **Vibración** (entrada `vibracion`): `nucleo/vibracion.gd`, que crea cada sala, escucha el bus y vibra al
    pegar (`enemigo_golpeado`), al recibir daño (`jugador_danado`), al curarse (señal nueva `jugador_curado`) y al
    descansar (`descanso_en_banco`), cada una con su duración y su fuerza (`Input.vibrate_handheld`). Entre una
    vibración y la siguiente, al menos `ticks_entre_vibraciones`. Se apaga con el ajuste `vibracion`.
11. **Ajustes** (`nucleo/ajustes.gd`, funciones estáticas como `Guardado`): archivo propio `user://ajustes.json`,
    fuera de la partida, para no cambiar la versión del guardado. Hoy solo `vibracion`, activada por omisión. Sin
    pantalla de Opciones todavía: un interruptor en la pausa.
12. **Interfaz** (bloque `interfaz/`): `interfaz/interfaz.tscn` con corazones y barra de bloques de Inspiración
    arriba a la izquierda (centro en 17 %, 12 % de una pantalla 16:9, anclado a esa esquina y medido en el lado
    corto, como los botones). Se actualiza con señales nuevas del bus, `vidas_cambiadas(vidas, maximas)` e
    `inspiracion_cambiada(inspiracion, maxima)`, que emite `Partida` al cambiar el valor; al entrar a la sala lee
    `Partida` una vez para el primer cuadro. Nunca lee al jugador. Un bloque son 11 de Inspiración (lo que da un
    golpe): 9 bloques con el máximo de hoy (99).
13. **Cómo entra la interfaz a la sala.** `Sala` la carga con `load()` si su escena existe, como el arranque con
    las herramientas: así el núcleo no depende del bloque `interfaz/` para correr.

## Hitos

1. `controles_tactiles.guion` con los casos nuevos (26) en verde y en rojo sin el arreglo.
2. Guiones de los ajustes del jugador: caída, pared, bola, picada (onda, invulnerable, desde el suelo), banco,
   foco; los `.esperado` que cambian por la caída, uno por uno.
3. `enemigo_base` y `enemigo_descanso` con la sala del banco aparte.
4. `vibracion` y los casos de ajustes en `guardado.guion`.
5. Interfaz: guion con corazones y bloques tras un golpe, una curación y un descanso.
6. `validar.ps1`, todos los guiones, revisor, APK en el teléfono.

## Cierre (06-oct-2026)

- `validar.ps1`: `OK  VALIDACION archivos=71 fallos=0`; 62 de 62 guiones `GUION OK`. Cada guion nuevo falla con
  su regla quitada.
- Revisor en contexto nuevo: cuatro fallos menores, corregidos (este plan describía dos gravedades y el código usa
  dos topes; faltaba un guion de la invulnerabilidad tras aterrizar, `habilidad_caida_en_picada_invulnerable`; un
  comentario de `habilidad_caida_en_picada_onda.esperado`; `controles-tactiles` vuelve a `false` hasta probar el
  arreglo de los dedos en el teléfono). También se arreglaron tres casos que señaló sin poder reproducir: sentarse
  justo tras un golpe ya no deja un retroceso pendiente, el joystick en diagonal ya no levanta al jugador en el
  mismo tick en que se sienta, y volver al punto seguro borra el coyote de pared.
- Queda por proponer a la persona: la excepción de `Sala` que carga la interfaz, en `nucleo/CLAUDE.md`.
