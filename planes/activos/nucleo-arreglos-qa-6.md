ACTIVO

# Arreglos del QA del #6

Pedido por la persona el 24-oct-2026: el #6 se fusionó con dos fallos menores y varias observaciones del QA
(issue #7, Galaxy Tab S9 FE con control Xbox; issue #8, Galaxy A55 5G con DUALSHOCK 4). Todo pasa a este PR, en
`feature/contenido-celda`, junto con la tanda de arte. Aprobado por la persona el 24-oct-2026 (ver «Decidido por la
persona»).

[H] es un hecho comprobado en el código o en la documentación; [I] es una inferencia.

## Fallos

### F1 · L1/R1 deja marcadas varias categorías (#8, 7.4)

- **Causa [H]:** `_mostrar()` marca la pestaña nueva con `set_pressed_no_signal(true)`
  (`herramientas/salas/zona_pruebas.gd:191`), y ese método no desmarca a las demás del `ButtonGroup`
  (`classes/class_basebutton.rst:466`). Con el dedo no pasa: el toque pasa por el grupo, que sí las desmarca.
- **Por qué no lo atrapó la prueba [H]:** `prueba_zona_pruebas.gd:36` solo comprueba que la pestaña nueva quede
  marcada, no que la anterior se desmarque.
- **Arreglo:** recorrer `_botones_categoria` y dejar marcada solo la elegida, con `set_pressed_no_signal`, para no
  volver a llamar a `_mostrar`.
- **Comprobación:** un caso nuevo en `prueba_zona_pruebas.gd`: tras `cambiar(1)` y `cambiar(-1)`, una sola pestaña
  marcada, la de `categoria()`. Antes del arreglo debe fallar.
- **Documentos:** `docs/errores/2026-10-24-varias-categorias-marcadas.md`.

### F2 · Z y C en vez de LB/RB con el control de Xbox (#7, fila 7)

- **Qué se sabe [H]:**
  - Z y C son las teclas de `pagina_anterior` y `pagina_siguiente`. `IconoBoton` las dibuja cuando
    `UltimaEntrada.dispositivo` es `TECLADO` (`nucleo/icono_boton.gd:91-97`).
  - Cualquier tecla pulsada marca `TECLADO`, también el volumen y Atrás, a propósito
    (`nucleo/ultima_entrada.gd:101-106`). Lo fija un caso de `prueba_icono_boton.gd:73-84`.
  - Entrar a la zona de pruebas no toca el dispositivo (`nucleo/menu.gd:64-67`, `zona_pruebas.gd:150`).
- **Causa probable [I]:** la captura de pantalla de la Tab S9 se toma con encendido + bajar volumen. En Android, Godot
  entrega el volumen como `InputEventKey`, porque no viene de un control (`GodotInputHandler.java`, rama 4.5, leído
  por resumen; la 4.7.2 no se comprobó). En la tienda y la pausa el ícono volvió a ser de Xbox con el siguiente botón
  del control; en la zona se capturó justo después.
- **Antes de cambiar código:** que Vic repita la fila 7 con el APK de este PR, sin capturar: en la zona, pulsar LB o
  RB y ver si junto a «Categoría» aparece LB/RB.
- **Arreglo propuesto (decisión D1):** que las teclas de volumen (`KEY_VOLUMEUP`, `KEY_VOLUMEDOWN`, `KEY_VOLUMEMUTE`,
  `classes/class_@globalscope.rst:1466-1482`) no cambien el dispositivo. Atrás sigue marcando `TECLADO`. Aunque la
  causa de Vic fuera otra, subir el volumen con el control en la mano no debería cambiar los íconos a teclado.
- **Comprobación:** cambiar el caso de `prueba_icono_boton.gd:79` a «el volumen no cambia el dispositivo».

## Observaciones de Ian (#8)

| # | Qué vio | Causa | Qué se propone |
|---|---|---|---|
| O1 (1.1) | Caminar no tiene animación propia: es la carrera en cámara lenta | [H] No hay hoja de caminar entre las 13 aprobadas. En el suelo se usa `correr` a 12 fps (`nucleo/animacion_jugador.gd:130-131`, `docs/jugador.md:206`), y `speed_scale` solo vale 0 o 1 (`nucleo/jugador.gd:457`) | D2 |
| O2 (1.1) | En el salto en pared los pies parecen atravesarla | [H] Ya arreglado el 21-oct (`docs/errores/2026-10-21-pared-al-reves.md`); su APK no lo traía | Que Ian lo vea con el APK nuevo |
| O3 (1.2) | Al atacar arriba o abajo el cuerpo se aplasta | [H] Se encoge entero, cabeza incluida: lo confirman dos capturas de la persona en el S21 (24-oct). El código no escala el cuerpo (`nucleo/jugador.gd:458` solo cambia `scale.x`). La causa está en el armado del atlas: la escala de cada hoja sale del alto de la máscara blanca de la cara. En `ataque-vertical`, en los cuadros 0 a 3 la búsqueda de lo blanco toma también la katana y el tajo: caja de 164-248 px de alto y ~395 de ancho, contra 114-122 × 36-50 de la máscara real (cuadros 4 y 5, y `quieto`). El promedio sale 163 en vez de ~115, y la hoja queda a ~71 %: 97-126 px de alto contra 150-165 de las demás | Calcular la escala de esa hoja solo con los cuadros 4 y 5, y revisar si la alineación por máscara de los cuadros 0 a 3 también se corrió; regenerar el `SpriteFrames` y comparar con una captura |
| O4 (1.2) | El rectángulo amarillo del ataque se ve | [H] Es el dibujo provisional del golpe (`nucleo/jugador.gd:428`); los efectos van en la segunda vuelta de la animación | Nada en este PR, salvo que la tanda de arte traiga el tajo |
| O5 (1.3) | Muerto queda un hueco entre el cuerpo y el suelo | [H] El último cuadro de `muerte` termina en la fila 172 del lienzo; el suelo está en la 176 y `quieto` pisa en la 180. Son 4 px sobre el suelo y 8 sobre donde pisa de pie | Bajar 8 px los cuadros tendidos de `muerte` al armar el atlas y regenerar el `SpriteFrames`. Un caso en `prueba_animacion_jugador.gd`, como el de la pared: el último cuadro de `muerte` termina en la fila 180 |
| O6 (3.1) | No se ve cuántas monedas tiene | [H] Es el diseño, como Silksong: el contador aparece al ganar, gastar o descansar y se desvanece; el total está en el inventario (`interfaz/hud.gd:3-6`, `nucleo/pagina_inventario.gd:50`). En Lo perdido las 120 se ponen antes de crear el HUD (`sala_lo_perdido.gd:12-13`), sin evento, así que no aparecen | D4 |
| O7 (8.3) | El premio del techo no cae | [H] Es un `ColorRect` sin script ni colisión (`sala_secretos.tscn:221-227`, y de 800 a 860) que solo marca que hay algo arriba; no cae ni se recoge, como los demás premios de la sala. El techo va de y 860 a 900 y el suelo empieza en 1160: con un salto de 230 px (`docs/jugador.md:17`) la cabeza sube a 770, así que, roto el techo, el cuerpo llega a la altura del premio sin doble salto (revisado el 24-oct; la primera lectura comparaba los pies) | Sin cambio de código: la lista del QA dice que el premio es un marcador que se ve arriba al romper el techo |
| O8 (8.5) | Al salir y volver, todo está como al principio | [H] La persistencia funciona: el muro guarda su marca (`nucleo/muro_rompible.gd:146-147`) y `prueba_muros.gd:108-118` comprueba que al recrear la sala sigue roto. Pero `sala_secretos` no tiene puertas, y volver desde el menú pasa por `Partida.reiniciar()` (`zona_pruebas.gd:214`), que borra todo a propósito. La prueba no se podía hacer como estaba escrita | D5 |
| O9 (9.2) | Bajó una vez a 34 FPS tras un parry al disparo del escupidor | [H] El parry no pausa el árbol ni cambia `time_scale` (`nucleo/congelado.gd:6`), no lanza partículas y el shader del destello ya está en el jugador desde que entra. En Compatibility no hay precompilación de shaders (`tutorials/performance/pipeline_compilations.rst:8-17`). [I] Sin causa: puede ser un pico del teléfono. `--print-fps` promedia un segundo: un tirón de 0,4 s ya da una lectura baja | Medir antes de tocar nada (M1) |
| O10 (9.3) | 358 MB de PSS en el A55 | [I] No se compara con el S50 (137-141 MB en Recursos bajo) ni con el S20 (235 MB en la caja gris): otro teléfono, otro Android, otra sala y otro nivel de Recursos. Una pantalla de 2340×1080 y el driver de la GPU suben la fila Graphics | Medir que no crezca de sala en sala (M2) |

## Mediciones (antes de arreglar O9 y O10)

- **M1:** en el S50 con `adb logcat -s godot`, sala Enemigos móviles: varios parry al disparo, anotando el segundo
  de cada uno; comparar el primero tras abrir la app con los siguientes. Si solo el primero cae, se calienta lo que
  dispara el parry al cargar la sala, como pide `pipeline_compilations.rst:15`. Si no se reproduce, se anota como
  visto una vez en el A55.
- **M2:** en el S50 y el S20 con `adb shell dumpsys meminfo com.themike54.elpasofinal`: filas Graphics y Native
  Heap en La Celda (la caja gris se quitó el 25-oct-2026), en Recursos bajo y alto, y otra vez tras recorrer cinco salas y volver. Si no crece, no hay
  problema.

## Decidido por la persona (24-oct-2026)

- 1.3 (O5) y 7.4 (F1) son fallos reales y se arreglan.
- 1.2 (O3): se encoge, no se aplasta; se arregla (ver O3).
- D2: caminar se queda como está, sin hoja nueva ni cambio de fps.
- D3: no aplica; el ataque vertical es el tajo con la katana hacia arriba y hacia abajo, y lo que se arregla es O3.
- D4: las monedas se quedan como están (diseño de Silksong); no se agrega nada en Lo perdido.
- D5: la persistencia se queda como está, sin sala nueva; el paso de «salir y volver» sale de la lista del QA.
- D1 (a): el volumen no cuenta como teclado; Atrás sigue contando.
- O3: el arreglo va en el armado del atlas, no en el juego (escalar el `Dibujo` en ejecución agrandaría una imagen ya
  reducida y la vería borrosa, y sumaría código por animación). Plan aprobado; ejecutarlo, revisar redundancias y
  poner al día la documentación.

## Avance (24-oct-2026)

- F1: `_mostrar()` deja marcada solo la pestaña elegida, con el mismo bucle que `caja_dialogo.gd` y
  `nueva_partida.gd`. Caso nuevo en `prueba_zona_pruebas.gd` (17 casos); con el código anterior, 1 fallo.
- F2 (D1): `UltimaEntrada.TECLAS_DE_VOLUMEN` y `marca_teclado` las ignora, por `keycode` o por `physical_keycode`.
  `prueba_icono_boton.gd`: el caso del volumen cambia y se suma «bajar el volumen no cambia nada en clasificar»
  (69 casos).
- O3 y O5: el script del atlas (fuera del repo) toma la escala de `ataque-vertical` solo de los cuadros 4 y 5, alinea
  0 a 3 por los pies y apoya en el suelo los tres cuadros de la muerte. Dos casos nuevos en
  `prueba_animacion_jugador.gd` (52 casos); con el atlas anterior, 2 fallos (126 px contra 163, y la muerte a 3, 6 y
  8 px del suelo).
  Atlas nuevo: 2036 × 656 (antes 1976 × 636), los mismos 61 cuadros; el ataque arriba mide 144-179 px (antes
  102-126) y la muerte termina en el borde del lienzo. El lienzo pasó a 316 × 182 con los pies en la fila 178, y el
  `offset` del `Dibujo` a (−158, −98). Revisado con una tira de los cuadros: el ataque arriba y abajo a la altura de
  `quieto`.
- O7: sin cambio de código (ver la tabla).
- `validar.ps1` → `OK  VALIDACION archivos=267 fallos=0`; `correr-guiones.ps1` → `RESUMEN total=157 OK=157
  MALOS=0`. APK de desarrollo instalado en el S50.
- 25-oct-2026, A5:
  - M1: la persona en el S50, sin tirón en el primer disparo desviado tras abrir la app. No se calienta nada.
  - M2: Claude con `adb`, dos vueltas de cinco salas. La memoria sube en la primera y no crece en la segunda (S50
    155,6 → 155,9 MB; S21 383,1 → 384,2 MB de PSS): no hay fuga. Números en `docs/pruebas.md`, «Rendimiento en el
    teléfono».
  - Se midió en el S21, no en el S20: es el que estaba conectado.

## Decisiones (para la persona; lo recomendado va primero)

1. **D1, el volumen:** (a) que el volumen no cambie los íconos ni el foco, recomendado; (b) dejarlo como está y
   solo pedir a Vic la prueba sin captura.
2. **D2, caminar:** (a) una hoja de caminar en la tanda de arte, recomendado si la vas a hacer; (b) subir los fps de
   `correr` para que el paso vaya con los 360 px/s, una línea al armar el atlas, y probarlo en el teléfono;
   (c) dejarlo así.
3. **D3, el ataque vertical:** (a) que lo veas en la hoja: si es una pose agachada que no te gusta, rehacerla en la
   tanda de arte; (b) dejarlo como pose de ataque.
4. **D4, las monedas:** (a) dejar el diseño de Silksong y que, en Lo perdido, el contador aparezca al entrar con las
   120, recomendado; (b) un contador siempre visible, como Hollow Knight, que cambia una decisión ya tomada.
5. **D5, la persistencia:** (a) una puerta en `sala_secretos` a una sala chica de regreso, oculta en la zona como
   Puerta B, para que el QA pueda salir y volver, recomendado; (b) dejar la sala así y quitar ese paso del QA, porque
   ya lo cubre `prueba_muros.gd`.

## Pasos

| Paso | Qué | Se comprueba con |
|---|---|---|
| A1 | F1 con su caso y su nota de error | El caso falla antes y pasa después; `validar.ps1`; guion de la zona |
| A2 | F2 según D1 | `prueba_icono_boton.gd`; `validar.ps1` |
| A3 | O5 y, si se decide, D2 (b) | El caso nuevo de `prueba_animacion_jugador.gd`; captura de la muerte |
| A4 | O7, D4 y D5 | El guion de la sala de secretos; si hay sala nueva, el validador de puertas |
| A5 | M1 y M2 en el S50 y el S20 | Los números en `docs/pruebas.md` |
| A6 | `correr-guiones.ps1` y el revisor (toca la entrada) | `RESUMEN ... MALOS=0` |
| A7 | Lista de QA para el siguiente PR, con lo que falló y lo que cambió: F1, F2, O2, O5 y lo que se decida | Issues nuevos, con el texto corregido (el blanco solo en el parry, el premio del techo, cómo salir y volver) |

## Riesgos

- F2 solo es seguro si la prueba de Vic sin captura sale bien. Si con LB/RB siguen las letras, la causa es otra y
  este plan se actualiza.
- O3 y O5 tocan el armado del atlas, que vive fuera del repo: el `SpriteFrames` se regenera y se revisa con capturas.
