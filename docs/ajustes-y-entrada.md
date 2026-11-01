# Ajustes y entrada

Parte del contrato (`docs/contrato.md`): el archivo de ajustes del jugador, el brillo, la reasignación de botones del control (`Mando`), las acciones de entrada y los controles táctiles con su editor. El audio y la vibración están en `docs/audio.md`.

## Ajustes

`nucleo/ajustes.gd` (`class_name Ajustes`): funciones estáticas, como `Guardado`. Archivo `user://ajustes.json`
(`{"version": 1, "ajustes": {...}}`), escrito a un temporal y renombrado. Son del teléfono y no de la partida:
agregar un ajuste no cambia `Guardado.VERSION`. Un archivo que falta, dañado o de otra versión deja los valores
por omisión: los de sí o no en `Ajustes.POR_OMISION` (se cargan, leen y guardan en un bucle sobre
`Ajustes.CLAVES_SI_NO`: uno nuevo se agrega ahí, a `POR_OMISION` y a `si_no`/`poner_si_no`); la disposición de los botones en
`DisposicionControles.por_omision()`.

| Ajuste | Por omisión | Qué es |
|---|---|---|
| `vibracion` | `true` | Vibrar al pegar, al recibir daño, al parar, al curarse, al descansar y al aterrizar duro |
| `temblor` | `true` | Temblor de la cámara al aterrizar de una caída (se apaga por mareo). Un archivo sin la clave la deja encendida |
| `modo_desarrollador` | `false` | Muestra en el menú principal la entrada a la zona de pruebas y, en Avanzado, Pruebas y Ver hitbox |
| `luces_avanzadas` | `false` | Luces 2D de la sala. Valen solo con Recursos en alto: `Ajustes.luces_activas()` (`luces_avanzadas_activas(valor, recursos_bajos)`). Apagadas por omisión: en alto, el S50 cae a 6-14 FPS con ellas en La Celda (medición del 27-oct-2026); el halo aditivo de `LuzSala` ya da el efecto |
| `niebla` | `false` | Banda de niebla de la sala |
| `mostrar_fps` | `false` | Contador de FPS arriba al centro (`ContadorFps`) |
| `panel_pruebas` | `false` | Panel de interruptores de la sala y el monitor junto al contador. Vale solo con el modo desarrollador (`Ajustes.desarrollo(clave)`) |
| `ver_hitbox` | `false` | Dibuja las formas de colisión. Vale solo con el modo desarrollador, como `panel_pruebas` |
| `volumen` | 1 | Volumen general (bus Master), de 0 a 1; en 0, silencio. Se aplica al cargar (`Ajustes.aplicar_volumen()`) |
| `volumen_musica` | 1 | Volumen del bus `Musica`, de 0 a 1, como el general. Un archivo sin la clave lo deja en 1 |
| `volumen_efectos` | 1 | Volumen del bus `Efectos`, de 0 a 1, como el general. Un archivo sin la clave lo deja en 1 |
| `brillo` | 1 | De 0,5 a 1,5: multiplica el color del mundo de la sala (debajo de 1 oscurece, encima aclara); el HUD, los controles y los menús no cambian. Se aplica al cargar (`Ajustes.aplicar_brillo()`) |
| `recursos` | `"auto"` | Modo de recursos: `auto` (decide la detección), `bajo` o `alto`. Otro valor vuelve a `auto` (ver `docs/arte-y-rendimiento.md`, «Recursos») |
| `fps` | 60 | 60 o 120; otro valor, o un archivo sin la clave, deja 60. `Ajustes.aplicar_fps()` (al cargar, al tocar FPS o Recursos) pone `Engine.max_fps` con `Ajustes.limite_fps()`: 0 (sin límite; con V-Sync, que en Compatibility siempre está, el refresco de la pantalla) solo con 120, Recursos en alto y una pantalla de `REFRESCO_RAPIDO` Hz o más (`DisplayServer.screen_get_refresh_rate()`, -1 si no se sabe); si no, 60. En un menú (árbol en pausa, o el menú principal) el límite es 60 siempre (`aplicar_fps(true)`): lo pone `ContadorFps`, que mira `get_tree().paused` en cada cuadro porque Godot no tiene señal de cambio de pausa. Sin pantalla (guiones, CI) no toca el límite. La física sigue a 60 ticks |
| `mando` | `{}` | Botones del control que difieren de `project.godot`: `{acción: índice de botón}`. Lo aplica `Mando.aplicar` al cargar |
| `controles` | La distribución inicial | `{"opacidad": n, "botones": {acción: {"ancla": [0|1, 0|1], "desplazamiento": [x, y], "escala": n}}}` (ver «Entrada»). Lo que falta o no es válido se queda en su valor por omisión, botón por botón; escala y opacidad fuera de rango se recortan |


- Un volumen o un brillo que no es número deja su valor por omisión y uno fuera de rango se recorta.
- Sin pantalla: `Ajustes.sin_ventana()` (verdadero con `--headless`: guiones, validador y CI) es la única
  comprobación de «nadie ve ni oye» del juego; la usan `Ajustes` (el límite de FPS), el arranque, la pausa, la
  Configuración, `Sonido`, `Musica`, `ReproductorVideo` y, en `herramientas/`, el medidor de cámara y la medición. Ningún otro script compara `DisplayServer.get_name()` por su cuenta.
- Brillo: `nucleo/brillo.gd` (`class_name Brillo`), un `CanvasModulate` con `Brillo.color_para(valor)` (gris `v`,
  alfa 1). Lo crea cada `Sala` como hijo, también en los guiones; `Brillo.instancia` es el de la sala viva, o null
  fuera de una sala, donde el brillo no se aplica. No dibuja nada encima de la pantalla: un rectángulo translúcido de
  pantalla completa costaba ~6 ms por cuadro en el Senwa S50 (`docs/pruebas.md`, «Sala de arte»). Una sala no lleva
  otro `CanvasModulate`: solo vale uno por canvas.

- `nucleo/mando.gd` (`class_name Mando`, estático): reasigna los botones del control de `Mando.REASIGNABLES` (`saltar`, `atacar`, `curar`, `mapa`, `mapa_rapido`, `inventario`, `pausa`); los ejes no: ni el movimiento ni `impulso` (RT) ni `interactuar` (stick arriba), que no tienen botón en `project.godot`; tampoco `volver`, `ui_accept` ni las acciones de página (ver «Entrada»). `asignar(acción, botón)` intercambia con la acción que ya tenía ese botón: ninguna se queda sin botón; un botón fuera de `0..JOY_BUTTON_SDL_MAX-1` se ignora. `aplicar` (al cargar) asigna lo guardado del mismo modo, así un archivo editado a mano no deja dos acciones en un botón. `por_omision()` vuelve a los de `project.godot`. El Start con que se acaba de asignar un botón no cuenta como Atrás en el menú (`Configuracion.acaba_de_asignar()`). `Mando.cambios` sube con cada cambio del InputMap (lo leen las pruebas); quien dibuja botones escucha `Eventos.mando_cambiado`. El nombre de cada botón sale de una sola tabla, `Mando.BOTONES` (una fila por índice de `JoyButton`; columnas neutro, Xbox y PlayStation); `Mando.familia(nombre, guid)` da `Mando.Dispositivo.PLAYSTATION` si el GUID SDL trae el fabricante Sony o el nombre dice PS3/PS4/PS5, PlayStation, DualShock, DualSense o Sony, y `Mando.Dispositivo.XBOX` en cualquier otro caso. Los nombres reales que dan Windows y Android no se han medido: en una build de depuración, `UltimaEntrada` imprime `CONTROL <n> nombre=... guid=... familia=...` por cada control conectado.

## Entrada

La lógica lee acciones con nombre (`Input.is_action_pressed(&"saltar")`), nunca la tecla ni el toque.

| Acción | Teclado inicial | Control (Xbox / PlayStation) |
|---|---|---|
| `mover_izquierda` | A | Stick izquierdo a la izquierda |
| `mover_derecha` | D | Stick izquierdo a la derecha |
| `mover_arriba` | Flecha arriba | Stick izquierdo arriba |
| `mover_abajo` | Flecha abajo | Stick izquierdo abajo |
| `saltar` | W | A / Cruz |
| `atacar` | Espacio | X / Cuadrado |
| `curar` | Q | B / Círculo |
| `impulso` | Flecha derecha | RT / R2 |
| `interactuar` | Flecha arriba | Stick izquierdo arriba |
| `mapa_rapido` | Tab | LB / L1 |
| `mapa` | M | Y / Triángulo |
| `inventario` | I | View / Select |
| `pagina_anterior` | Z | LB / L1 |
| `pagina_siguiente` | C | RB / R1 |
| `pausa` | Esc | Start |
| `volver` | — | B / Círculo |

Las teclas se guardan como tecla física (`physical_keycode`): valen por su posición en el teclado, no por la
letra de la distribución. Una acción nueva se agrega a `project.godot` y a esta tabla en el mismo cambio.

- `inventario` se llamaba `mochila` hasta el 13-oct-2026: `Mando.aplicar` da a `inventario` el botón que unos
  ajustes viejos guardaron como `mochila`. El campo `mochila` del guardado (lo perdido al morir) no cambió.
- LB es `mapa_rapido` y también `pagina_anterior`: el mapa rápido solo responde si `mapa_rapido` empezó a pulsarse
  con el juego andando (sostenido desde el marco o la pausa, al cerrarlos no se muestra hasta soltarlo), y las páginas
  solo con el marco de menús abierto, que lo detiene. Las dos acciones de página no se reasignan.
- B / Círculo también es `volver`: en los menús (menú principal, ranuras, Nueva partida, Configuración, la pausa
  abierta, el marco de menús y la zona de pruebas) vuelve un nivel, igual que `pausa`. En la partida no se lee y B
  cura. No se reasigna, igual que `ui_accept`: si el jugador mueve `curar` a otro botón, B sigue volviendo. No tiene
  tecla: Retroceso borraría el nombre en Nueva partida y a la vez volvería, porque una acción cuenta aunque el
  `LineEdit` se coma la tecla; en el teclado vuelve Esc. Al esperar un botón en «Botones del control», el B con
  que se asigna no vuelve (`Configuracion.acaba_de_asignar()`, como el Start).
- A / Cruz también es `ui_accept`, la acción con la que un menú pulsa el botón que tiene el foco: Godot 4.7.2 no
  le pone ningún botón del control, así que `project.godot` la redefine con sus tres teclas (Enter, Enter del
  teclado numérico y Espacio) y A. No se reasigna: si el jugador mueve `saltar` a otro botón, A sigue aceptando.

- `interactuar` y `mover_arriba` comparten tecla y las dos se activan juntas. Son acciones aparte para
  reasignarlas por separado; junto a algo con que interactuar, la lógica del jugador decide cuál vale.
- El pogo (`mover_abajo` + `atacar` en el aire), la caída en picada (`mover_abajo` + `curar` en el aire) y el salto
  en pared (empujar hacia la pared en el aire) son combinaciones de acciones, no acciones propias.
- `curar` es el botón de poderes, como en Hollow Knight: mantenerlo cura y tocarlo lanza el poder (ver `docs/jugador.md`).
- Controles táctiles: `nucleo/controles_tactiles.tscn` (`class_name ControlesTactiles`), que crea cada sala. Traducen el toque a estas mismas acciones con `Input.action_press` y `action_release`; es el único script que lee toques durante el juego (el Editor de controles lee el ratón emulado del toque, y la Configuración lee botones del control para reasignarlos). Lee en `_input` y no en el tick, a diferencia del resto de la entrada: el toque es un evento con dedo y posición que `Input` no guarda; lo que produce son acciones, y esas sí se leen en el tick. Por eso se excluye a mano mientras hay conversación o editor (`hablando`, `editando`).
- Distribución inicial: joystick invisible en la zona de abajo a la izquierda (aparece donde se pone el dedo; da fuerza de 0 a 1 a `mover_*`, con zona muerta de 0,2; hacia arriba también da `interactuar`, como la flecha arriba) y botones Saltar, Atacar, Curar, Impulso, Pausa y Mapa. No hay botón de inventario: el de Mapa tiene doble uso (de pie dice «Mapa» y da `mapa`; sentado en un banco —`Jugador.descansando`, leído del grupo `jugador`, `Jugador.GRUPO`— dice «Inventario» y da `inventario`; al soltar se suelta la acción que se presionó). Impulso solo mientras `Partida.tiene(&"impulso")` y Atacar mientras `Partida.tiene(&"pluma")`: sin la habilidad no se dibuja ni responde, y un dedo encima se suelta al perderla (la tabla `HABILIDAD_DE_BOTON` dice qué botón pide qué habilidad).
- Anclados a su esquina y medidos en proporción del lado corto. Dónde va cada botón y su tamaño los da `Ajustes.disposicion` (`nucleo/disposicion_controles.gd`, `class_name DisposicionControles`, sin nodos): por botón, la esquina de ancla, el desplazamiento desde ella en fracción del lado corto y la escala (de 0,5 a 2), más una opacidad para todos (de 0,2 a 1). La distribución inicial sale de `CENTROS`, `ANCLAS` y `RADIOS`. Al crearse, al cambiar de tamaño y cuando `Ajustes.disposicion` cambia, los controles meten cada botón dentro del área segura (`DisplayServer.get_display_safe_area()` pasada a coordenadas de la vista) y no dejan achicar un botón por debajo de su tamaño por omisión ni de un objetivo de 48 dp (contando la holgura del toque), el que sea menor: el mínimo no agranda la distribución inicial. Las dos cosas solo en el teléfono (`OS.has_feature("mobile")`): en la PC, toda la vista y sin mínimo. El joystick no se configura.
- Cuándo se ven: se ocultan con una tecla o el control y reaparecen al tocar la pantalla; los de una sala nueva nacen visibles solo con pantalla táctil y si lo último que se usó fue el dedo (`UltimaEntrada.con_control()` en false). Las dos cosas siguen una sola regla, `ControlesTactiles.deben_verse(tactil, con_control)`; jugando, `procesar` le pasa lo que dice `UltimaEntrada.clasificar` del evento, porque su `_input` corre antes de que `UltimaEntrada` lo anote (un toque, apoyado o levantado, es el dedo; una tecla o un botón con acción del juego, nunca). Hay dos reglas distintas sobre qué entrada cuenta, las dos estáticas en `UltimaEntrada`: `marca_teclado(evento)`, que usa `clasificar`, da verdadero con cualquier tecla pulsada, también Atrás del teléfono, y así un menú muestra el foco; el volumen no (`UltimaEntrada.TECLAS_DE_VOLUMEN`, desde el 24-oct-2026: si llega como tecla, subirlo o tomar una captura con el control en la mano pasaría los íconos a las teclas; que en Android llegue así no está comprobado en 4.7.2); `es_de_juego(evento)`, que usa `procesar` para ocultar los controles, pide además que una tecla, un botón o un eje del control dispare una acción del InputMap que no empiece por `ui_`. Con un eje, las dos piden la mitad (en `es_de_juego` la pone `is_pressed`, que en 4.7.2 da verdadero desde 0,5; la zona muerta de la acción no cuenta). Lo que cambia el dispositivo sin ocultar los controles: una tecla sin acción (Atrás, Enter), un botón sin acción (L3, R3, Guía) y un eje sin acción (LT, el stick derecho). Unificarlas cambiaría el juego (Atrás dejaría de mostrar el foco, o empezaría a ocultar los controles): es una decisión abierta de la persona.
- Dedos: se recuerdan entre salas (variables estáticas): un dedo que sigue en la pantalla al cruzar una puerta o al reaparecer lo sueltan los controles de la sala nueva; si entre una sala y otra pasan más de `CUADROS_CAMBIO_DE_SALA` cuadros (el menú), al llegar se suelta todo. También se suelta todo al perder el foco la ventana o la app y al pausarla Android (`_notification`); un dedo que vuelve a tocar con un índice ya registrado suelta antes lo que tenía, y un toque con `canceled` suelta.
- Con un menú abierto, es decir con el árbol detenido (`get_tree().paused`, que hoy ponen solo la pausa, el marco de menús, la tienda, las estaciones y su cobro), solo los botones de `BOTONES_DE_MENU` (Pausa y Mapa, que sentado manda `inventario`) toman un dedo nuevo, así que siguen cerrando su menú como el teclado y el control (Pausa, en Configuración, vuelve un nivel); un toque nuevo en Saltar, Atacar, Curar, Impulso (o cualquier botón fuera de `BOTONES_DE_MENU`) o en la zona del joystick no hace nada. Soltar y arrastrar siguen, y al detenerse el árbol se suelta todo, también el dedo con que se tocó Pausa o Mapa: los menús leen solo `is_action_just_pressed`, así que soltar su acción no abre ni cierra nada, y al levantarlo ya no hay qué soltar. Los botones se siguen dibujando. Toda pausa futura del árbol también dejará sin responder los botones de juego y el joystick.
- Editor de controles: `nucleo/editor_controles.tscn` (`class_name EditorControles` en su nodo `Lienzo`), que abren
  la pausa (`Pausa.abrir_editor()`) y la Configuración del menú principal (ver `docs/interfaz.md`, «Menú»). Tocar un botón lo selecciona y arrastrarlo lo mueve (al soltar, se ancla a la
  esquina más cercana y entra en el área segura); un deslizador cambia el tamaño del seleccionado y otro la opacidad
  de todos; «Restaurar» pide un segundo toque. Edita una copia: «Listo» la pone en `Ajustes.disposicion` y la
  guarda, «Cancelar» la descarta. Lee el ratón (en el teléfono, emulado desde el toque). Mientras está abierto,
  `ControlesTactiles.editando` es verdadero: los toques no accionan nada y los botones del juego no se dibujan.
- Conversación: mientras hay una `CajaDialogo`, `ControlesTactiles.hablando` es verdadero y solo Pausa se dibuja y
  responde; el joystick se suelta y no se toma. La caja se toca directamente.
- Resaltar: `ControlesTactiles.resaltada` (estática) es la acción cuyo botón late, un aro que crece y se aclara una
  vez por segundo en un nodo propio. La pone un `AvisoAccion` a la vista y sin hacer, en táctil, y la quita al salir o al hacer la acción.
  No late un botón sin su habilidad, ni con el editor abierto, ni hablando. `latiendo` es pública para las pruebas.
- Botones por enseñar: en una sala con `botones_por_ensenar`, el botón de esas acciones no se dibuja ni responde hasta
  que la acción está en `Partida.botones_ensenados` (`por_ensenar(accion)`, pública). Solo táctil: el control y el
  teclado no cambian. Los controles buscan su sala subiendo por el árbol al entrar. `botones_ocultos` esconde igual,
  pero el pizarrón que lo enseña está en una sala posterior: la base de La Celda esconde curar hasta Las Raíces, donde
  llegan los primeros enemigos. Una sala de Las Raíces anterior a ese pizarrón lleva también el suyo.
- Control (Xbox / PlayStation): un evento del InputMap junto a cada tecla, para cualquier control (`device` -1).
  El stick usa la zona muerta de cada acción (0,2); RT es un eje que cuenta como presionado pasada esa zona. LT queda libre.
