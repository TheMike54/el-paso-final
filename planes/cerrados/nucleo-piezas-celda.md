CERRADO (29-oct-2026, con el PR de `feature/contenido-celda`. Escrito el 27-oct-2026; aprobado por la persona el 27-oct-2026)

# Núcleo: piezas nuevas de La Celda, hechas limpias

La copia de pruebas probó en el S50 lo que piden las salas 2 a 5 de La Celda: puertas con acción, plataformas que
se mueven, monedas sueltas, zona de cámara, plafón que se rompe desde abajo, música por sala y los sonidos del
jugador. Funcionó, pero el código repite lo que el núcleo ya resolvía y trae fallos escondidos. Este plan lo
reconstruye en el núcleo con la forma que recomienda Godot 4.7. Lo mismo va en `feature/contenido-celda`, en el
mismo PR que el plan `contenido-celda-salas` (decisión de la persona, 27-oct-2026). De la copia de pruebas no se
copia código: se toma como referencia.

## Principios
1. Lo medido manda. En el S50, en bajo, las salas 2 y 4 pasan de 37-40 a 59,7 FPS solo con dejar de redibujar las
   monedas vectoriales en cada cuadro. Los draw calls no deciden los FPS.
2. Se generaliza con tres casos (regla cerrada). `Recogible` los tiene (Coleccionable, MonedasSueltas, ObjetoHabilidad),
   y `Puerta extends Interactuable` también. `FichaZona` no: la zona es una escena base heredada.
3. Una regla, un solo lugar que la hace cumplir: lo que se puede revisar sin ejecutar lo revisa `validar.gd`. En
   ejecución nada corrige en silencio.
4. En el mundo no se dibuja en `_process` (`classes/class_canvasitem.rst:24`, `:1686`). Lo vectorial queda para el HUD
   y el mapa.
5. Sin autoloads nuevos y sin tocar `project.godot` ni `export_presets.cfg`.

## Bloques (cada uno compila solo y pasa `validar.ps1`)
| # | Qué | Comprobación | Revisor |
|---|---|---|---|
| N1 | `Ajustes.sin_ventana()` en lugar de las cuatro comprobaciones de «sin pantalla»; `sin_luz.tres` y `aditivo.tres` cargados con `preload` por `LuzSala.material_aditivo()` y `EfectoCuadros.material_sin_luz()` (cumple el plan `nucleo-efectos-jugador`); `nucleo/piezas/niebla.tscn` con el ruido horneado en PNG; `luces_avanzadas` apagado por omisión; limpieza de comentarios y orden de código | `validar.ps1`; guiones de niebla y luz | no |
| N2 | `Recogible extends Area2D` (id exportado, sale si ya se recogió, `_al_recoger`); Coleccionable con halo `LuzSala` PULSO, sin `_draw`; brillo como `@export`; `MonedasSueltas` como `Sprite2D` sin `_draw`, con la forma centrada en el dibujo; ObjetoHabilidad sobre la base; validador: `Recogible` entre los recordados con id único y prefijo | guion nuevo `nucleo/monedas_sueltas` (se toman una vez y no vuelven al recargar); `prueba_validador` | sí (guardado) |
| N3 | `Vaiven` y `Giro` en ticks (`ticks_ida`, `ticks_espera`, `desfase_ticks`), con la pausa también al arrancar; la pieza que carga al jugador es ella misma el `AnimatableBody2D` y fija su capa con `Capas.poner`; sin el forzado de `peligro`. Punto seguro: una función estática de «lo que se mueve», compartida por el jugador y el validador (Vaiven, Giro, AnimatableBody2D, Portón, PathFollow2D); al volver, rayo hacia abajo y, sin suelo, el `punto_seguro` de la puerta, la `Entrada` o el banco. `platform_on_leave = ADD_UPWARD_VELOCITY` en `jugador.tscn` (`class_characterbody2d.rst:182-184`). Validador: Giro en la regla del peligro | sala de prueba con una plataforma sobre un peligro y un guion de aplastamiento; `docs/errores/` de los dos fallos de la copia de pruebas | sí (física) |
| N4 | `Puerta extends Interactuable` con `tipo` {LADO, PUERTA, ARRIBA, ABAJO} y `punto_seguro`; solo `PUERTA` pide la acción. `Fundido` es el único dueño del cambio de sala (puerta, estación, muerte, cinemática, entrega de un objeto): recibe ruta, llegada y perfil de tiempos, emite `en_negro`, aborta si el jugador murió y registra el `Error` de `change_scene_to_packed`. Jugador: `enum Transicion` en lugar de tres contadores, inmune a daño y peligros durante el cruce, salida con `move_and_slide()` y tope de ticks. Las animaciones `entrar_puerta` y `salir_puerta` las genera `generar_sprites.gd`: la tira de la puerta se agrega a la entrada del atlas del hombre y el `.tres` se regenera, en lugar de tocarlo a mano; la mujer queda sin ellas mientras `ELEGIR_PERSONAJE = false` | `cambio_de_sala` y `fundido_puerta` comparan estados, no decimales; `enemigo_base` y `bus_eventos` con holgura; guion nuevo de puerta con acción en `sala_puerta_a`; guion de inmunidad en el cruce | sí (jugador, contrato) |
| N5 | `ZonaCamara` con `@export var limites: Rect2` (lo visible, igual que `Sala.limites`) y una `CollisionShape2D` hija; la cámara recorta con `intersection`; sin `_physics_process`, sin −1 ni INF | `prueba_zona_camara.gd`: topes, zonas encimadas, entrar al instante | no |
| N6 | `MuroRompible.tapas` y `descubre` como `@export Array[CanvasItem]`; lo escondido queda encerrado físicamente, no solo invisible. `LuzSala.corte_arriba` y radio exportado. `AvisoAccion.modo` {UNA_VEZ, POR_VISITA, SIEMPRE}. `Npc` con `AnimatedSprite2D` opcional, se orienta al jugador; sin `etapa_terminada` (se usa `conversacion_terminada`) y sin sala de muestra: ver «Decidido en la tanda», N6. `Sala.clave_de` sube hasta la primera `Sala` (piezas anidadas). Validador: todo export de nodo resuelve | `prueba_muros` con `descubre`; `prueba_npc` y guion `nucleo/npc` | no |
| N7 | Una sola señal: `jugador_aterrizo(velocidad, picada)` en todo aterrizaje (se borra `jugador_toco_suelo`); Vibración filtra por umbral. Pasos con `frame_changed`. `Sonido` con un `AudioStreamPlayer` y `AudioStreamPolyphonic` en el bus de efectos, `AudioStreamRandomizer` en paso, aterrizaje y golpe, una conexión por señal. Solo los WAV elegidos, con nombre semántico, en `nucleo/sonidos/jugador/` y `sonidos_jugador.tres` | `nucleo/sonido` (un portón y cinco pasos: el portón sigue sonando); comprobar que `play_stream` toque un Randomizer | sí (bus de eventos) |
| N8 | `Musica` y `RegionMusica` como hijas de `Arranque` con acceso tipado; el pedido se aplica en el tick siguiente y gana el último; un tema que ya suena no se reasigna ni reinicia; «vacío» (no tocar) separado de «silencio»; el panel de audio pide el tema a `Musica`. El tema del menú se queda (menú y banco de La Celda) | `nucleo/musica`: reaparecer dentro de una región no reinicia el tema (posición de reproducción) | sí (autoload) |
| N9 | Validador: `ext_resource` sin `uid` en `contenido/` y `nucleo/`; toda forma de una vía en `contenido/` y `herramientas/salas/` tiene que ser una instancia de `plataforma_delgada` y nunca ir en algo que se mueve; `limites.position == (0,0)`; sin encime en el mapa entre salas de la misma zona; `FondoTapado` que nunca se ve; avisos de imagen sin uso, `queue_redraw` en `_process`, escala no uniforme, nodo oculto o colisión desactivada, tema sin bucle; halos de `LuzSala` (`LuzSala.caja_halo`/`area_halo`) en las capas translúcidas, en el canal de avisos (viene de N6) | `prueba_validador` con un caso por regla | no |
| N10 | `docs/contrato.md` (Sala, componentes, bus, audio, música por sala, «Arte de zona»), `docs/jugador.md` (transición y animaciones de puerta), `docs/pruebas.md`, `docs/errores/`; entradas nuevas en `funciones.json` de `nucleo` y `herramientas` con `"pasa": false`, que aprueba la persona | suite completa | no |

## Decisiones de la persona que aplican (27-oct-2026)
- Plataformas de una vía (27-oct-2026): se cambia la regla del 07-oct por una excepción acotada. Solo piezas que
  cuelgan o se ven delgadas, sobre todo en rutas escondidas, donde atravesarlas caminando y subirse de un salto es
  parte de descubrirlas (la lámpara de la sala 2; la caja, el estante, la lámpara baja y el ducto de la ruta al nicho de la
  sala 3, como funcionan hoy). Llevan una sola escena, `plataforma_delgada` (forma de una vía y margen fijos), y
  nunca son la única salida de un lugar. Una vía sobre algo que se mueve se decide midiendo. Lo que se pisa no se marca con una orilla
  aparte: descubrirlo es intencional. La regla y su porqué van al contrato; el validador la hace cumplir.
- El tipo de cada puerta lo decide su arte.
- `luces_avanzadas` apagado por omisión; medir el S20 en alto con y sin luces antes de quitar la rama `PointLight2D`.
- Música por sala, puesta en la base de la zona.
- Las `.tscn` las sigue escribiendo Claude como texto, sin generadores fuera del repo y conservando los `uid`.
- Ni atlas ni `TileMapLayer` por ahora.

## Medición
Una herramienta de medición en `herramientas/pruebas/`. El preset de Publicación ya la excluye y el de Desarrollo la
lleva. Recorre cada sala sola y escribe FPS, peor cuadro y memoria de textura en el log, para comparar antes y
después en el S50 y el S20 sin tocar la pantalla. Nada fuera de `herramientas/pruebas/` la nombra.

Hecha en N1: `herramientas/pruebas/medicion.tscn` y `medicion.gd`. La forma estable de correrla está en
`docs/pruebas.md`, «Medición de rendimiento»; lo de abajo es el registro del bloque. Carga cada sala como el juego (sin puerta de
llegada), apaga el tick del jugador (así la cámara no lo sigue), pone la cámara en cada posición, calienta, cuenta
cuadros sin tope de FPS y escribe:
- `SALA <id> carga_ms=<n> recursos=… luces=… niebla=…` por carga (la primera es una carga en frío que no se mide);
- `MEDICION_DATO sala=<id> x= y= recursos= luces= niebla= fps= peor_ms= draw_calls= objetos= primitivas= tex_mb= video_mb= nodos=`
  por posición y variante: `fps` es el promedio de la muestra, `peor_ms` el cuadro más largo, `draw_calls`, `objetos`
  y `primitivas` el máximo de un cuadro, y memoria y nodos al final (`classes/class_performance.rst:149-195`);
- `MEDICION inicio …` (sistema, 32 bits, ventana, modo de V-Sync) y `MEDICION FIN`.

Argumentos, después de `--`: `--salas=celda_1,celda_2` (por omisión `celda_1`), `--recursos=bajo,alto`,
`--luces=no,si` y `--niebla=no,si` (cada lista es un eje del A/B; por omisión `no`), `--calentar=2` y `--muestra=5`
(segundos) y `--puntos=640:360;1700:360` (sin él, una rejilla de centros de cámara a 0,9 vistas sobre `limites`).

**En la PC**, desde la raíz del repo:
`& $env:GODOT_PATH --path . --quit-after 50000000 res://herramientas/pruebas/medicion.tscn -- --salas=celda_1 --recursos=bajo,alto --luces=no,si`.
`--quit-after` cuenta cuadros, no segundos: sin tope de FPS, 3000 cortaron la corrida a los 2 s (27-oct-2026). La
herramienta pide V-Sync apagado (`classes/class_displayserver.rst:7553`) e imprime el modo que quedó. Sin ventana
(`--headless`) corre igual, pero sus FPS no valen. Probada en la PC el 27-oct-2026 con `celda_1`, las 8 variantes.

**APK de medición** (no hecho todavía), como el de la auditoría, desde una copia en el scratchpad, nunca en el repo:
1. Copiar el repo sin `.godot/` ni `build/` e importar la copia (`--headless --path <copia> --import`).
2. En la copia, `project.godot`: `run/main_scene.medicion="res://herramientas/pruebas/medicion.tscn"` (override por
   etiqueta, `tutorials/export/feature_tags.rst:175`). En `export_presets.cfg`, el preset «Desarrollo» (lleva
   `herramientas/pruebas/`): `custom_features="medicion"`, `package/unique_name="com.themike54.elpasofinal.medicion"`
   (otro id: no pisa el juego ni su guardado), `package/name="EPF Medicion"`, y los argumentos en
   `command_line/extra_args="--print-fps -- --salas=… --recursos=…"` (que lleguen así: no comprobado; si no, se cambian
   los valores por omisión en la copia).
3. `& $env:GODOT_PATH --headless --path <copia> --export-debug "Desarrollo" <scratchpad>\medicion.apk`; `adb -s <serie>
   install -r`; abrirlo y leer `adb logcat -s godot` filtrando `MEDICION` y `SALA`. En Android el V-Sync puede seguir
   encendido (lo dice la línea de inicio): entonces los FPS se topan en el refresco, que basta para la meta de 60.
4. Al terminar, desinstalar `com.themike54.elpasofinal.medicion` y dejar el juego abierto en los teléfonos.

**Medido en C3 (27-oct-2026)**, APK de medición desde una copia del scratchpad (los argumentos de `extra_args` sí
llegan en Android), rejilla por omisión, calentar 2 s y muestra 5 s:
- S50 en bajo (`--salas=celda_1,celda_2,celda_5 --recursos=bajo`): `celda_1` x 2775 y 3842, 59,7 FPS (peor cuadro
  22-25 ms, 43-44 draw calls); `celda_2`, las 8 posiciones (x 640 a 3680, y 360 y 574), 59,5-59,8 FPS, peor cuadro
  22,7-30,1 ms, 34-47 draw calls, ~850 primitivas, 34,8 MB de texturas, 251 nodos; `celda_5`, 59,6-59,7 FPS, peor
  cuadro 24-26 ms, 31-35 draw calls, 29,4 MB. Las líneas de inicio y las x 640 y 1707 de `celda_1` se perdieron del
  búfer de `logcat` del S50 (C2 ya las midió: 59,7). Meta de 60 cumplida en las tres salas.
- S20 en alto (`--recursos=alto --luces=no,si`, 2400×1080, V-Sync 1, 64 bits): con luces 2D en «No», las tres salas a
  60,1-60,2 FPS en todas las posiciones (peor cuadro 19,5-24,9 ms). Con luces en «Sí»: `celda_1` 60,2 salvo x 3842
  (57,4); `celda_2` 60,2 en x 640 y 1653, pero 52,2/55,9 en x 2667 y 49,1/51,1 en x 3680 (y 360/574), donde se juntan
  los tubos, la luz de los cables y la de la SALIDA; `celda_5` 60,2 (no tiene luces de tubo).
- D14 · Recomendación (para la persona; C3 solo mide y no quita nada): con las luces 2D el S20, un teléfono de gama
  media-alta, baja a 49 FPS en la sala 2, y sin ellas está a 60 en todo; dejar `luces_avanzadas` apagado por omisión
  (ya lo está) y quitar la rama `PointLight2D` de `LuzSala`, o dejarla solo como opción de «Avanzado» sabiendo que
  baja la sala 2 a ~50 FPS en alto. Las demás salas de La Celda se miden al pasarlas (C4, C5).

**Medido en C4 (28-oct-2026)**, APK de medición desde una copia del scratchpad, `--salas=celda_3 --recursos=alto
--luces=no,si`, rejilla por omisión (x 640, 1520 y 2400; y 360 y 880), calentar 2 s y muestra 5 s. Solo estaba
conectado el S20; el S50 no, así que `celda_3` en bajo queda sin medir.
- S20 en alto (2400×1080, V-Sync 1, 64 bits): luces 2D en «No», 60,0-60,2 FPS en las 6 posiciones (peor cuadro
  20,5-23,5 ms, 29-40 draw calls, 816-846 primitivas, 49,3 MB de texturas, 214 nodos); en «Sí», 60,2-60,3 (peor
  cuadro 20,3-26,7 ms, 30-42 draw calls, 49,5 MB, 218 nodos). Con tres tubos separados la sala 3 no baja como la 2.
- En Android la actividad de otra app quedó al frente en el primer intento (como en C3): sirvió forzar el cierre del
  APK de medición y abrirlo con `am start -W` con el teléfono en el inicio.

**Medido en C5 (28-oct-2026)**, igual que en C4 con `--salas=celda_4` (2720 × 1440: rejilla x 640, 1360 y 2080; y
360, 720 y 1080). Solo estaba conectado el S20; el S50 no, así que `celda_4` en bajo queda sin medir (nunca medida).
- S20 en alto (2400×1080, V-Sync 1, 64 bits): luces 2D en «No», 60,0-60,3 FPS en las 9 posiciones (peor cuadro
  20,9-35,9 ms, el de 35,9 en x 1360 y 1080; 23-37 draw calls, 768-812 primitivas, 61,7 MB de texturas, 179 nodos);
  en «Sí», 60,0-60,2 (peor cuadro 20,1-31,7 ms, 23-37 draw calls, 62,0 MB, 183 nodos). Las dos luces de los hongos
  (`LuzSala` de pulso) no bajan la sala como la 2.
- `am start` ya no abre el APK (la actividad no está exportada: `SecurityException`); se abrió por el lanzador con
  `adb shell monkey -p <id> -c android.intent.category.LAUNCHER 1` y corrió al primer intento.

## Decidido en la tanda
- N1 · `Ajustes.sin_ventana()` es la única comprobación de «sin pantalla»: se fueron las 8 copias de
  `DisplayServer.get_name() == "headless"` (ajustes, arranque, configuración, pausa, panel de audio, sonido,
  `medidor_camara` y `ReproductorVideo.sin_ventana()`, que se borró). Sonido y panel de audio entran ya porque existen
  en el juego; Ajustes y no ReproductorVideo para no atar el audio al video.
- N1 · Materiales: `nucleo/arte/sin_luz.tres` (`light_mode` sin sombreado) y `nucleo/arte/aditivo.tres` (suma, sin
  sombreado: es lo que usaban el halo y los destellos), guardados con `ResourceSaver` y con uid
  (`uid://cbonitpbsi8a6` y `uid://bi0s26tb0wqda`). `LuzSala.material_aditivo()` y `EfectoCuadros.material_sin_luz()`
  devuelven una constante con su `preload`. La sala de arte usaba un aditivo propio con sombreado: ahora usa el común
  (un material aditivo en todo el juego; la sala de arte es de prueba). `celda_1.tscn` sigue con sus `sub_resource`
  hasta C2, que la rehace usando estos dos `.tres` como `ext_resource`.
- N1 · Niebla: `nucleo/piezas/niebla.tscn` (raíz `Parallax2D`, hijo `Deriva` con `Niebla`, nieto `Banda`). Ruido
  horneado en `nucleo/arte/niebla_ruido.png` con los parámetros del `NoiseTexture2D` de `celda_1` (semilla 7,
  frecuencia 0,012, 160 de alto, sin costura con borde 0,1, normalizado, blanco con alfa del ruido) pero 592 de ancho:
  a escala 3 mide 1776 ≥ 1760, y `repeat_size.x` y `recorrido` valen 1776 para que la vuelta no tenga costura;
  `repeat_times = 2`: con 1 (el valor por omisión) se abría un hueco del tamaño del avance, medido con ventana
  (`docs/errores/2026-10-27-hueco-niebla.md`). Importado Lossless sin mipmaps: no es arte del mundo y se dibuja
  ampliado. La sala solo toca la raíz de la instancia (sin hijos editables): altura con `scroll_offset.y` (no la pisa el
  desplazamiento, `classes/class_parallax2d.rst:221-223`; `position` sí, `:24`), tinte y alfa con `modulate` y capa con
  `z_index`. Sigue apagada por omisión. Vista dibujada en la PC (27-oct-2026, con ventana, la pieza sola sobre negro,
  cámara en seis posiciones y avance de 0 a 1775 px): sin hueco con `repeat_times = 2`.
- N1 · `luces_avanzadas` en `false` por omisión. Cambió a propósito un caso de `prueba_guardado.gd` (un archivo viejo
  ahora deja las luces apagadas, y el de ida y vuelta guarda `true`), la fila del contrato y el texto de
  `ajustes-avanzados` en `nucleo/funciones.json`.
- N1 · Limpieza: sin «demo» en el código (`menu.gd`, `fondo_tapado.gd`, `luz_sala.gd`, `reproductor_video.gd`,
  `validar.gd`, `video_desenfoque.gdshader`; queda el dato y la fecha) ni en `contenido/funciones.json`
  (`sala-celda-1-telefono`: «como el arte aprobado»). Orden de la guía de estilo donde estaba roto: `sala.gd`,
  `icono_boton.gd`, `nueva_partida.gd`, `configuracion.gd`, `toques.gd`, `luz_sala.gd` y `generar_efectos.gd`.
  `celda_1.gd` (variables después de `@onready`) se deja: C2 la rehace. La primera revisión solo había mirado el orden
  antes de la primera función; un barrido de declaraciones de nivel superior después de una función encontró además
  constantes y variables sueltas entre funciones en `validar.gd` y `generar_efectos.gd`: se subieron a la cabecera con
  su comentario (`gdscript_styleguide.rst:794-800`), y el comentario que explica cada regla se quedó sobre su función.
  Tras eso, el barrido da 0 en todos los `.gd` del repo salvo `celda_1.gd`. De A2-13, `zona_camara.gd` no existe en el
  juego y `camara_jugador.gd`, `puerta.gd` y `jugador.gd` ya están en orden y sin el comentario huérfano.
- N1 · Convención de áreas (para el contrato en N10): un `Area2D` cuya zona se ajusta a ojo (cámara, música, avisos,
  recogibles) lleva su forma como `CollisionShape2D` hija, editada en el editor, y el validador exige que exista. La
  forma se crea en código solo cuando su tamaño sale de otro dato (el pizarrón de un `AvisoAccion`, una `Estacion`), y
  entonces con un solo helper estático común, sacado de `Interactuable._crear_forma`. No se refactoriza ninguna área
  todavía.
- N1 · El ruido de la niebla tiene su generador en el repo (D17): `hornear_niebla()` en
  `herramientas/generar_efectos.gd` (ya excluido del paquete; `export_presets.cfg` sin tocar), con `FastNoiseLite`,
  semilla 7, frecuencia 0,012 y `get_seamless_image(592, 160, false, false, 0.1, true)`
  (`classes/class_noise.rst:159`), blanco con el alfa del ruido. Horneado a una ruta aparte y comparado con el PNG del
  repo: 0 píxeles distintos, así que el PNG no se reescribió. Es el mismo ruido que el `NoiseTexture2D` de `celda_1`,
  pero el mosaico mide 592 y no 512, así que el dibujo no es idéntico: se compara a ojo en C2.
- N1 · `EfectoCuadros._SIN_LUZ` y `LuzSala._ADITIVO` son privadas: desde el código los materiales se piden solo con
  `material_sin_luz()` y `material_aditivo()` (una entrada por material).
- N1 · «Demo» fuera también de `docs/` (dos menciones en `contrato.md`, «Recursos», cambiadas por La Celda medida en
  el S50 el 25-oct-2026). Grep de `demo|copia de pruebas|Miguel` en todo el repo: solo quedan `ESTADO.md`, `LICENSE`
  (autores) y los planes, que la regla permite.
- N1 · Adelantado de N10 porque cambió con N1: la fila «La Celda» de `docs/pruebas.md` pide alto con Luces 2D en «Sí»
  y en «No»; el «cómo se corre» de la herramienta de medición pasó a `docs/pruebas.md`, «Medición de rendimiento» (la
  cabecera de `medicion.gd` apunta ahí, porque este plan se cierra), y `herramientas/funciones.json` tiene la entrada
  `medicion-rendimiento` con `"pasa": false`. Queda para N10, porque es un `CLAUDE.md` y se muestra antes a la persona:
  la fila `pruebas/` de `herramientas/CLAUDE.md` (hoy dice que solo lleva `sala_*` con su `prueba_*`).
- N1 · La niebla no usa `Parallax2D.autoscroll` (`classes/class_parallax2d.rst:78`): no se detiene con Congelado ni
  con Recursos bajo. Por eso existe `Niebla`, que mueve `Deriva`, y por eso hace falta `repeat_times = 2`.
- N1 · Medición: en la PC, la primera variante de algunas corridas dio 150-170 draw calls contra unos 33 (`celda_1`).
  No se encontró la causa; por eso hay una carga previa que no se mide.
- N1 · Sala de arte: sus partículas ahora usan el aditivo común sin sombreado, así que la oscuridad ya no las apaga. En
  la QA final hay que mirar si brillan de más; si es así, se baja su color o su alfa, sin crear otro material.
- N2 · `Recogible` (`nucleo/recogible.gd`): `id`, `ya_recogido()` y `recordado_por_id()` públicos (el validador llama al
  segundo sin correr `_ready`), `_al_recoger(jugador)` virtual. Al tocarlo, primero la marca y después el efecto: el
  coleccionable autoguarda al emitir `coleccionable_obtenido` y el archivo ya debe llevar la marca. Una bandera evita el
  doble efecto si entran dos cuerpos antes del `queue_free`. Heredan Coleccionable, MonedasSueltas, ObjetoHabilidad y
  también `ObjetoMapa` (`mapa/`): era una cuarta copia del mismo esqueleto. ObjetoHabilidad y ObjetoMapa no usan id
  (los recuerdan `Partida.habilidades` y `Partida.mapas`) y ahora tampoco los toma un jugador muerto.
- N2 · Validador: `Recogible` reemplaza a `Coleccionable` en `_recordados_con_id` (cubre las subclases) y
  `_id_recordado` salta los que no se recuerdan por id; no se usó un grupo «recordado»: el validador no corre `_ready`, así que
  un grupo puesto en código no se ve, y uno persistente en el `.tscn` (`classes/class_node.rst:1794`) depende de que cada
  escena lo traiga; `is_instance_of(Recogible)` cubre cualquier subclase sin tocar escenas. La regla del prefijo pasó
  del `_ready` del Coleccionable (`push_error` al correr) a `_revisar_recogibles`, en cualquier escena: el coleccionable
  empieza con `coleccionable` y ningún otro recogible usa `coleccionable` ni `entregado_`. Solo para recogibles: Npc,
  RetoPreguntas y AvisoAccion ya tienen su propia regla de prefijo.
- N2 · Coleccionable: una escena para todo el juego con el arte de la credencial en `nucleo/arte/coleccionable.png`
  (aprobada el 26-oct-2026; `Sprite2D` `Arte`, material `sin_luz.tres`) y un hijo `LuzSala` `PULSO` ámbar dentro del arte
  con `show_behind_parent`, así flota con él y queda detrás (radio 116: el halo visible mide 64, el de la copia de
  pruebas; latido de 1,6 s). Sin `_draw` ni destello en cruz: el destello era otro dibujo por cuadro (A7-07: «un sprite
  chico o desaparece»), y el halo que late ya marca el premio. `brillo` exportado y en 1,0 por omisión: el 1,3 compensaba
  el `CanvasModulate` que el arte ya no recibe (B5-08); se decide en el S50. La flotación queda en `_process` con
  `Congelado.activo()`, como `Planta`: solo mueve una posición. `COLOR` se queda para la vitrina.
- N2 · MonedasSueltas: escena `nucleo/monedas_sueltas.tscn` con el montón horneado en una sola imagen (un nodo, un
  draw call), `Sprite2D` sin sombreado a escala 0,5 (horneado a 2x, con mipmaps) y forma de 72×40 centrada en el dibujo
  (el montón va de x −36 a 36 y de y −38 a 0). El brillo que subía el color a 1,35 se cambió por un `LuzSala` `PULSO`
  dorado chico detrás (radio 70): suma, así que sí aclara en Compatibility, y no regraba geometría. No autoguarda al
  tomarlas: la marca y las monedas viajan juntas en el siguiente guardado, como las marcas de muros y palancas.
- N2 · PejeCoin horneada por `hornear_monedas()` en `herramientas/generar_efectos.gd` (ya excluido del paquete): rasteriza
  en la CPU los polígonos de `FigurasVector` (nueva `FigurasVector.piezas()`, pública) y la P con los contornos del glifo
  de la misma fuente del HUD (`TextServer.font_get_glyph_contours`, `classes/class_textserver.rst:2007-2029`), a 4×4
  muestras por píxel. Corre sin ventana: un `SubViewport` no dibuja con `--headless`. `--solo=<nombre>` escribe una sola
  imagen, para no reescribir los `efecto_*.png`. Resultado: 144×78 px.
- N2 · Guardado sin migración: los ids no cambian (`coleccionable…` en las salas de prueba, `monedas` es nuevo en el juego) y
  la forma de `salas` tampoco; ObjetoHabilidad y ObjetoMapa siguen en `habilidades` y `mapas`.
- N2 · uid: `coleccionable.tscn` no tenía `uid` (ni su `ext_resource`); ahora lleva `uid://cktp3d3amsb88`, y `prueba_2` y
  `prueba_3` lo nombran con él. Escenas nuevas con uid generado por `ResourceUID.create_id()`.
- N2 · `prueba_capas_fisica` instancia el coleccionable desde su escena (el script toma el `Arte` de ella) y suma las
  monedas: 31 → 32 casos. `prueba_validador`: 52 → 61 casos.
- N2 · Revisión: `ObjetoMapa` sin zona (sin `Sala` dueña o id sin `_`) no se consume: su `_al_entrar` sale antes de la
  base. Se conserva lo de antes de heredar de `Recogible` porque un mapa que se queda y no da nada se nota al probar la
  sala; uno que desaparece sin entregar nada esconde el error. Caso nuevo en `nucleo/monedas_sueltas` (11 → 12).
- N2 · Revisión: el comentario de `Coleccionable.brillo` citaba `upgrading_to_godot_4.rst` para decir que un modulate
  mayor que 1 aclara; ese pasaje (líneas 70-71) dice lo contrario: sin HDR 2D un modulate «overbright» no tiene efecto
  visible. Ahora dice eso y que el aclarado real en el teléfono no está comprobado; lo decide la persona en el S50.
- N2 · Revisión: la flotación del coleccionable no se apaga fuera de pantalla (`VisibleOnScreenEnabler2D`,
  `classes/class_visibleonscreenenabler2d.rst:20-22`): mover una posición no regraba comandos de dibujo y un notificador
  sumaría un nodo por recogible. Se mide en el S50 si una sala llega a tener varios.
- N2 · Revisión: la regla que proponía A7-01 para la skill `rendimiento-gama-baja` y el `revisor` queda para N10, porque
  es configuración de Claude y se muestra antes a la persona. Texto propuesto: «En el mundo no se dibuja con
  `FigurasVector` ni con `_draw` lo que se repite: se hornea a PNG con `herramientas/generar_efectos.gd`. Ningún
  `queue_redraw()` en `_process` sin una guarda que lo haga solo cuando algo cambió». Hoy la regla vive solo en
  `docs/contrato.md` (fila de `MonedasSueltas`). También para N10: la fila `validador-recogibles` en la tabla de
  `herramientas/CLAUDE.md` y la mención de `fisica-2d/SKILL.md:50` (ejemplo de `Capas.poner`, ahora en `recogible.gd`).
- N2 · Revisión: `prueba_validador` suma el caso «el objeto de mapa da vacío» en `_id_recordado` y arma el coleccionable
  desde su escena, como en el juego (61 → 62 casos).
- N3 · `Vaiven`: ciclo espera en el origen → ida → espera en el extremo → vuelta, con `desfase_ticks` (uno solo, en
  lugar de bool más desfase: cubre empezar en el extremo y desfasar piezas iguales). Con `ticks_espera = 0` el ciclo es
  idéntico al de antes (`peligro_movil` sin cambiar). Se fue el forzado de `peligro = false` en `_ready`: la regla vive
  solo en el validador. El cast a `CollisionObject2D` pasa por `Object` (un `Node2D` no compila a ese tipo).
- N3 · `Vaiven.movil_de(nodo)` (estática, en `Vaiven` y no en `Capas`: `Capas` es de capas) es la única lista de lo que
  se mueve: `Vaiven`, `Giro`, `AnimatableBody2D` (el `Porton` incluido: sobre un portón cerrado el punto seguro quedaría
  en el aire al abrirse, A2-17 refutado), `CharacterBody2D`, `RigidBody2D`, `PathFollow2D`. La usan el validador
  (peligros) y el jugador (punto seguro). Por clase y no por grupo: el validador no corre `_ready`. No se creó una capa
  `SUELO_INESTABLE` (alternativa del verificador): tocaría `project.godot`, la tabla de capas y los rayos de proyectil y
  enemigos.
- N3 · Suelo fijo = tres rayos hacia abajo (8 px arriba, 40 abajo) en el centro de los pies y a 1 px de cada orilla
  del cuerpo; basta uno que encuentre un sólido no móvil. No los choques de `move_and_slide`: así quieto en la pausa
  del elevador no cuenta (caso medido) y no hay un `0.7` a mano (A4-05). Con un solo rayo en el centro, parado en una
  orilla con el centro sobre el vacío dejaba de contar y el punto seguro quedaba 36 px más atrás: fallaron 6 guiones
  (`jugador_peligro`, `jugador_salida_abajo`, los tres `fundido_*` y `contenido/celda_grieta`). Con las orillas el punto
  queda donde estaba y ningún `.esperado` cambia.
- N3 · Cadena al volver (`ultimo_punto_seguro()`, también la mochila): punto seguro más viejo con suelo → llegada →
  `Sala.puntos_de_respaldo()` (`Entrada`, bancos) → suelo bajo la llegada (rayo largo). El anti-bucle usa la misma
  llegada comprobada. El `punto_seguro` propio de la puerta es N4 (`Puerta.punto_seguro`): entra en la cadena antes de
  la llegada cuando exista.
- N3 · Medido en headless (`nucleo/plataformas`), una vía sobre algo que se mueve: una raíz de una vía que baja hasta
  el suelo pasa a través del jugador parado (`y` máx. 680,0) y lo sube igual (380); la misma sólida lo hunde hasta 88 px
  en el suelo (768,3) y lo saca encima, sin daño, y lo sube igual. El elevador sólido de la sala de prueba: hasta 91 px
  (771,2), sin daño, sale caminando. Decisión: **una vía nunca sobre algo que se mueve** (D1 aprobada: raíz y elevador
  sólidos, criterio de la persona «plataforma y elevador sólidos»); no queda atrapado. Regla escrita en el contrato
  (fila de `Vaiven`): bajo una pieza sólida que baja hasta el suelo, el suelo mide al menos 100 px de grueso (el de la
  sala de prueba medía 80 y el jugador llegó a 771, 11 px bajo su cara de abajo; tras la revisión mide 120). La regla del validador «nunca en algo
  que se mueve» sigue en N9. C5 mide la raíz en su sala.
- N3 · `PlataformaDelgada` se hizo aquí (no en N9): sus dos mediciones son de física. Script con `@export var ancho` y
  forma creada en `_ready` con su propio `RectangleShape2D` (lámpara de 150 y ducto de 80 no caben en una forma fija);
  grosor 20 y margen fijos en constantes; escena `nucleo/piezas/plataforma_delgada.tscn` para instanciar con su dibujo
  hijo. Margen **1 px**: en 30 fases, ni la caída a 20 px por tick ni la picada a 30 la atravesaron (60 de 60, medido aparte; el guion `nucleo/plataformas` repite 10 fases, 20 corridas); con 32
  px, caminar subía encima de una cara a 30 px del suelo (a 33, no), y con 4 px, a 2 px. El rayo del punto seguro sí la
  ve: sobre ella se toma punto seguro (es fija). La regla del validador (toda una vía es `PlataformaDelgada`) queda en N9.
- N3 · `platform_on_leave = ADD_UPWARD_VELOCITY` en `jugador.tscn` (no en `_ready`: es configuración del nodo). Medido:
  desde el elevador que baja sube 233,6 px, desde el suelo 238,9; con `ADD_VELOCITY`, 170,2. No cambia ningún valor de
  `docs/jugador.md`; se agregó la línea con su cita.
- N3 · Validador: regla nueva `_revisar_cuerpos_moviles`, más amplia que «AnimatableBody2D hijo de Vaiven»: ningún
  `PhysicsBody2D` dentro de un `Vaiven` o un `Giro` salvo el nodo mismo. La línea con tabuladores se fue con la
  reescritura de `_revisar_peligros`. `prueba_validador`: 62 → 66 casos (Giro suelto con peligro, cuerpo dentro de un
  Vaiven, Vaiven y Giro con áreas sanos, Vaiven en el cuerpo sano).
- N3 · Sala de prueba nueva `herramientas/salas/sala_plataformas.tscn` en «Mundo» (la ven la persona y el teléfono) y
  la prueba `herramientas/pruebas/prueba_plataformas.gd` (29 casos, unos 3610 ticks) que arma en código lo que no va en
  una sala jugable. No se tocó `sala_peligro_movil` (su guion sigue igual). `prueba_capas_fisica` no se tocó: la capa
  de la plataforma y de la delgada la comprueba `plataformas`.
- N3 · Errores: `docs/errores/2026-10-26-punto-seguro-sobre-plataforma.md` y `2026-10-26-plataforma-hija-de-vaiven.md`
  (fecha del hallazgo; la causa del segundo se midió el 27-oct: el cuerpo hijo avanzó 150 px y el jugador 0).
- N3 · `ultimo_punto_seguro()` lanza rayos: todos los que la llaman (`DanoContacto._physics_process`, la salida por
  abajo, `_morir`, el anti-bucle y las pruebas tras `physics_frame`) corren dentro del tick (Grep, 27-oct-2026). Fuera
  del tick devuelve el punto sin comprobar (`Engine.is_in_physics_frame()`), por si un botón lo llama algún día
  (`tutorials/physics/ray-casting.rst:42`). El caso sólido de `plataformas` exige solo lo que el juego necesita (sin
  daño, encima y sube); cuánto lo hunde el motor (88 px) queda como medición aquí, no como requisito.
- N3 · Queda para N10, por ser configuración de Claude o `CLAUDE.md`: la fila `validador-cuerpos-moviles` en la tabla
  de `herramientas/CLAUDE.md`, y en la skill `fisica-2d` el `Vaiven`, la `PlataformaDelgada` y el `SueloFragil` como
  ejemplos de `Capas.poner`. La fila de QA de Plataformas en `docs/pruebas.md` no es configuración de Claude: entró en la
  revisión de N3.
- N3 · Revisión: la sala Plataformas cumple la regla del contrato (suelo de 120 px, cara de arriba igual en y=680) en vez
  de acotar la regla: la sala es la referencia de la regla y una excepción en ella la contradiría.
- N3 · Revisión: `_llegada_con_suelo`, último eslabón: el rayo largo arranca `RAYO_SUELO_ARRIBA` px sobre la llegada y
  se repite excluyendo cada pieza que `Vaiven.movil_de` da por móvil (`_suelo_fijo_bajo`, `Capas.rayo_a_escenario` con
  `excluir`, `classes/class_physicsrayqueryparameters2d.rst:131`); solo sin ningún sólido fijo bajo la llegada devuelve
  la llegada tal cual (el comentario y `docs/jugador.md` lo dicen). Puede caer en el suelo bajo unos pinchos: es el
  último recurso, después de `Entrada` y bancos.
- N3 · Revisión: `_hay_suelo_fijo` sigue mirando solo el primer choque, a propósito: atravesar lo móvil daría por firme
  un punto sobre una plataforma que pasa a menos de 40 px del suelo bajo los pinchos. El costo (un elevador posado en
  el suelo descarta ese punto y se usa uno más viejo) queda escrito en `docs/jugador.md`.
- N3 · Revisión: una sola regla de capas: toda pieza de `escenario` con script llama a `Capas.poner(self, ESCENARIO, 0)`;
  `SueloFragil` ahora también (caso nuevo en `capas_fisica`, 32 → 33) y la fila de la capa 1 del contrato los nombra a
  todos. `RAYOS_SUELO_X` se deriva de `TAMANO`. Las pruebas usan la clase `Vaiven` y no su ruta.

- N4 · Tiempos de una `PUERTA` y de `LADO`: los de Hollow Knight (oscurecer 20, negro 10, aclarar 30; caminar al llegar
  20 ticks), aprobados en el análisis común. La estación conserva 9, 6 y 15 (`Perfil.ESTACION`, el tiempo de las
  puertas hasta hoy: no se cambia sin decidirlo) y la muerte 9 y 0 (`Perfil.MUERTE`); las vidas se llenan en `en_negro`
  y no 9 ticks antes. Los perfiles viven solo en `Fundido.ticks_de`.
- N4 · El Fundido es el dueño del cambio (alternativa del verificador de A3-05): sin autoload ni nodo nuevo. Las
  estáticas de `Sala` (`puerta_llegada`, `estacion_llegada`, `llegada_a_banco`) se quedan como transporte entre
  escenas: las escriben también el menú, la medición y las pruebas; solo `Fundido.ir_a_sala` las escribe en un cambio
  de sala. `menu.gd`, `pausa.gd`, `zona_pruebas.gd` y la medición no pasan por el Fundido: no son cambios de sala del
  mundo (van al menú o a una sala elegida en una lista). La cinemática usa `Fundido.ir_a_sala` sin fundido (el video ya
  acaba en negro). La entrega de un objeto que cambia de sala (X-06) no existe todavía en el repo: la sala que la
  traiga en C usa `cambiar_sala` del Fundido.
- N4 · Error del cambio: `ResourceLoader.exists` + `load` + `change_scene_to_packed` dentro de un método propio
  diferido, con `push_error` del código (`classes/class_scenetree.rst:609`; diferido porque cambiar saca la escena del
  árbol en el acto, `:584-588`). El tope del jugador (`Fundido.ticks_hasta_cambio` + `Puerta.MARGEN_TOPE`, 30) queda
  como defensa. Carga en segundo plano (`load_threaded_request`) no: se mide antes `carga_ms` en el S50.
- N4 · Salida `LADO` con `move_and_slide` contra la pared de detrás (`stopWalkingOut` de Hollow Knight, alternativa del
  verificador de A3-02): sin cambiar el validador, el contrato de la pared ni las capas. Cómo se ve chocar a media
  pantalla bajo el fundido lo mira la persona en el S50; si se ve mal, la opción es la del dintel.
- N4 · `ARRIBA` y `ABAJO`: al salir sigue la velocidad vertical que llevaba, sin gravedad ni avance; al llegar, con el
  control (no hay arte de esos cruces). La puerta `ABAJO` de ida sola (el tiro de la sala 4) choca con la regla del
  validador de ida y vuelta: se resuelve en C5 o N9 con la sala real.
- N4 · `punto_seguro` en `(0, 0)` = no tiene (un `Vector2` exportado no puede ser nulo). `mirar_al_llegar` 0 = hacia
  el centro de la sala (lo que hacía la sala) y -1 o 1 lo fija, como `alwaysEnterLeft/Right` (A3-09).
- N4 · La tira de la puerta, aprobada por delegación el 26-oct, se agregó a la entrada del atlas del hombre y el atlas
  se reempaquetó con su script: 67 cuadros, el lienzo común sigue en 316 × 182 y los cuadros de antes salen idénticos
  (medido). `jugador_hombre.tres` lo regenera `generar_sprites` (`animaciones=24 cuadros=70 error=0`). El largo de cada
  clip y el giro (`CUADROS_GIRO_PUERTA = 3`) se leen del `SpriteFrames` (A3-07); la prueba exige que `entrar_puerta`
  dure al menos giro + oscurecer + negro (hoy 48 = 18 + 20 + 10).
- N4 · A3-10: se mantienen los 48 ticks del cruce por una `PUERTA` (giro antes del fundido). Si la persona quiere el
  ritmo de Hollow Knight, el fundido empieza con el giro (retraso 0 en `_al_interactuar`).
- N4 · X-07: la mujer queda sin clips de puerta mientras `ELEGIR_PERSONAJE = false`; no tiene arte. Cuando lo tenga,
  su entrada del atlas lleva la misma tira y la prueba de animación recorre sus `SpriteFrames`.
- N4 · Guion de la puerta con acción en una sala nueva, `sala_puerta_c` (dos `PUERTA` en la misma sala), y no en
  `sala_puerta_a`: su puerta `LADO` la usan `cambio_de_sala`, `fundido_puerta`, `bus_eventos`, `puerta_salto_*` y
  `sala_puerta_*_pared`.
- N4 · A9-03: `bus_eventos` solo cuenta lo de su ruta (`cambio_de_sala` 2, `fundido_pedido` 2, `jugador_danado` 0) y ya
  no dice «las treinta»; no se agregó una lista de señales en código (la del verificador: sería otra lista a mano).
- N4 · A9-11: la regla del validador usa el cuerpo del jugador (`Jugador.TAMANO`, pies en la llegada), no el punto; una
  `PUERTA` solo exige la llegada dentro de `limites` (no `(0, 0)`). Ninguna sala del repo falló al agregarla.
- N4 · Queda para N10 (es `CLAUDE.md` o configuración de Claude): la fila `validador-llegada-puertas` en la tabla de
  `herramientas/CLAUDE.md`. `revisor` pendiente (jugador, contrato y bus); `"pasa"` de las entradas nuevas en `false`
  hasta entonces. X-02 (interactuar con el joystick hacia arriba): prueba manual en el S50 escrita en `docs/pruebas.md`.
- N4 (revisión) · `Puerta._cruzar` pide primero `Fundido.cambiar_sala` y solo si lo acepta pone al jugador a salir y
  se marca cruzada; `_al_entrar` rechaza a un jugador `en_transicion`: dos puertas vecinas no cambian el rumbo a media
  salida ni dejan una puerta cruzada para siempre.
- N4 (revisión) · Cambio fallido: `en_negro` se sigue emitiendo antes del cambio diferido (la muerte llena las vidas
  ahí y la prueba de transición lo cuenta); el fallo se avisa después con la señal nueva `Fundido.cambio_fallido`, que
  escuchan la `Estacion` (limpia `destino`, `dejar_de_hablar`) y la `Puerta` (vuelve a servir). `viaje_hecho` puede
  haber salido para un viaje que falló: se acepta porque solo lo oye la prueba y el caso no ocurre con salas que
  existen. `ir_a_sala` escribe las estáticas solo tras cargar la escena y las limpia si el cambio da error.
- N4 (revisión) · El retraso del Fundido (giro de una `PUERTA`) ya no congela un aclarado en curso: la fase anterior
  sigue avanzando y el cambio empieza desde esa opacidad. Se conserva el `return` del tick en que acaba el retraso
  para no mover un tick los tiempos que fija `fundido_puerta`.
- N4 (revisión) · Cita de `set_physics_process(false)` en las puertas sin acción: `classes/class_node.rst:1605` (la
  de `idle_and_physics_processing.rst:21` hablaba de `set_process`).
- N4 (revisión) · `puertas-telefono` (`nucleo/funciones.json`) es una entrada nueva de este bloque, sin commit: se
  reescribió su `que` para X-02 (joystick hacia arriba, correr con el pulgar inclinado, atacar hacia arriba), como el
  caso manual de `docs/pruebas.md`.
- N4 (revisión) · `jugador_hombre.tres` lleva su `ext_resource` de `atlas_0.png` sin `uid=` porque así lo escribe
  `generar_sprites` (ya pasaba en `HEAD`): queda para N9 (regla de uid del validador), que `generar_sprites` lo
  escriba con el uid del `.import`.
- N5 · `ZonaCamara.limites` es un `Rect2` con lo visible, en coordenadas de la sala como `Sala.limites`; la `position`
  del nodo solo coloca la forma. Por omisión `Rect2()` sin área: una zona sin llenar la rechaza el validador en vez de
  centrar la cámara en silencio. Un eje sin tope se escribe igual al de la sala; el validador exige que la zona quepa
  en la sala (`classes/class_rect2.rst:281`, `encloses`), así el recorte con `intersection` (`:437`) nunca queda vacío.
- N5 · La pila y el «al instante» viven en `CamaraJugador`: guarda los últimos pies y dirección que le pasa el
  `Jugador` en `seguir` y `colocar`, y cuenta ticks desde `colocar`. La zona solo llama `entrar_zona(self)` y
  `salir_zona(self)` por `Jugador.camara()` (único acceso nuevo de `Jugador`). `limites_vista()` es pública: es lo que
  la cámara puede mostrar y lo lee la prueba. Una zona liberada con el jugador dentro deja de mandar (se descarta al
  leer la pila), como el `OnDisable` de Hollow Knight.
- N5 · «Al instante» dura 30 ticks tras `colocar` (llegar a la sala, reaparecer), el `startLockedTimer` de 0,5 s de
  Hollow Knight, y no los 2 de la copia de pruebas: la llegada por una puerta camina 20 ticks bajo un aclarado de 30,
  y una zona junto a la puerta se tocaría a media llegada. Colocar por una zona no reinicia la cuenta: una zona tocada
  después de esos 30 ticks ya no salta. Matiz: una zona tocada en los ticks 20 a 29 salta con la pantalla ya casi
  clara; se decide en C5 viéndolo en la sala 4.
- N5 · Seguimiento lento al entrar o salir de una zona: se conserva (lo probado en el teléfono) como constantes nuevas,
  sin tocar `suavizado_camara_x`, `tiempo_camara_y` ni `adelanto_camara`: 30 ticks con 2/s en x y 0,5 s en y
  (`dampTimeSlow` 0,5 y `slowTime` 0,5 de Hollow Knight). No se copió la bajada gradual de Hollow Knight (0,007 por
  cuadro, depende de los FPS) ni la excepción de entrar por el borde de la escena: se decide al verla en la sala 4.
- N5 · Para C5: la zona de arriba de la sala 4 (área de 1760 × 720 en (880, 360) y el centro topado en y ≤ 360) se
  escribe `limites = Rect2(80, 0, 2720, 720)` si la sala sigue con `limites = Rect2(80, 0, 2720, 2160)` (con D19, las x
  se recorren con la sala): con 720 de alto la cámara se centra en y = 360, igual que antes. Su forma, una
  `CollisionShape2D` hija de 1760 × 720.
- N5 · Sin `docs/errores/`: el centinela −1 contra las coordenadas negativas solo existía en la copia de pruebas; aquí
  no hubo fallo que arreglar. Lo cubre el caso «tope de abajo en y negativas» de `zona_camara`.
- N5 · Queda para N10 (es `CLAUDE.md`): la fila `validador-zona-camara` en la tabla de `herramientas/CLAUDE.md`.
- N5 (revisión) · Salir de una zona usa la misma regla que entrar: dentro de los 30 ticks tras `colocar` salta a la
  vista nueva. Al reaparecer fuera de una zona, `colocar` todavía recorta con ella (`body_exited` llega un tick
  después) y sin el salto la cámara se deslizaba desde el tope. Caso «salir de una zona recien colocada».
- N5 (revisión) · El seguimiento lento solo arranca si cambia la zona que manda: salir de una que no manda o volver a
  entrar a la que ya manda no cambia `limites_vista()` y no debe frenar medio segundo el seguimiento. Tres casos.
- N5 (revisión) · El salto se omite con la cámara fuera del árbol: al liberar la sala la zona avisa la salida ya fuera
  de él y `get_viewport_rect` daba error (lo atrapó `zona_camara` antes de entregar; no es fallo del código previo,
  sin `docs/errores/`).
- N5 · La pila de zonas de `CamaraJugador` solo descarta las zonas liberadas cuando quedan arriba. Se acepta porque
  ninguna sala libera una zona a mitad de la partida y la cámara se recrea con cada sala; si alguna lo hace, hay que
  filtrar con `is_instance_valid` en toda la pila.

- N6 · `MuroRompible.tapas` y `descubre` son `@export Array[CanvasItem]` (`gdscript_exports.rst:321`), y
  `Palanca.portones` es `Array[Porton]` (lo pedía A2-05). Formato medido guardando una escena con `ResourceSaver`: cabecera
  `node_paths=PackedStringArray("tapas", "descubre")` y `tapas = [NodePath("../Tapa")]`; `sala_secretos.tscn` se editó a
  mano así. Una ruta rota deja `null` en el arreglo **sin ninguna línea de error**; una ruta a un nodo de otro tipo sí
  imprime `ERROR:` (lo atrapa `validar.ps1` por su filtro). Medido el 27-oct-2026 con un script en el scratchpad.
- N6 · Lo escondido queda encerrado, no oculto: `descubre` es solo para dibujos (`visible` no apaga un área ni su
  proceso, `classes/class_canvasitem.rst:803`). No se agregó el contenedor `Hueco` ni el cambio de `process_mode` de
  A2-05: con el validador que falla si lo descubierto tiene física, no hacen falta. `sala_secretos` suma una orilla en
  `descubre` y 10 PejeCoins dentro del cuarto: la prueba comprueba que caminando contra el muro entero no se toman y roto
  sí. Esa es la parte «descubre» de A2-04 y del guion de recogibles que dejó N2.
- N6 · Validador, regla genérica (mejor alternativa de A1-12): `_revisar_rutas_de_nodos` compara cada `NodePath` (o
  arreglo de ellas) que la escena guarda para una variable de script (`PROPERTY_USAGE_SCRIPT_VARIABLE`) en su
  `SceneState` (`classes/class_scenestate.rst:384`) con lo instanciado; un export en null a propósito no guarda ruta y no
  cuenta. Cubre `tapas`, `descubre`, `portones`, `encendida`, `destello` y lo que venga sin tocar el validador. Corre en
  toda escena, no solo en `contenido/`: ninguna escena del repo falló al agregarla. Los casos de rutas rotas escriben el
  `.tscn` en `user://` (uno roto en el repo haría fallar al propio validador). Las reglas del muro (fuera del muro, no en
  las dos listas, sin física) también pasan de las salas con id a toda escena: `sala_secretos` no es sala con id.
- N6 · `Sala.clave_de` (X-05): el `owner` si es la `Sala` y, si no, sube por los padres hasta la primera `Sala`
  (`classes/class_node.rst:38`). `_revisar_sala` recorre ahora también los nodos que no son de la sala (`owned` en
  falso), así un id repetido dentro de una pieza instanciada falla; ninguna sala del repo falló. Caso en `estado_sala` con
  una pieza armada con `PackedScene.pack` (con el `clave_de` de antes fallan 2). Sin `docs/errores/`: hoy ninguna pieza
  lleva un recordado dentro; no hubo fallo en el juego.
- N6 · `LuzSala`: `halo_radio` exportado (por omisión `HALO_RADIO` 0,55: ninguna luz del repo cambia de tamaño) y
  `corte_arriba` con `region_rect` + `offset` (`classes/class_sprite2d.rst:287`), negativo sin corte. La `PointLight2D` no
  se corta: se acepta la fuga y se escribe en el contrato (las luces avanzadas están apagadas por omisión desde N1), en
  vez de un `LightOccluder2D` que pide `shadow_enabled`. El 102,4 repetido de los tubos no se vuelve constante ni preset:
  lo lleva una sola vez la pieza `luz_tubo.tscn` de C1.
- N6 · Halos en el presupuesto de capas translúcidas: **no se cuentan todavía**. `LuzSala.caja_halo()` (estática) y
  `area_halo()` ya dan el área desde los exports, sin `_ready`. Contados como fallo, `celda_1` (4 tubos de radio 470 sin
  corte, 267 289 px² cada uno, más que los 230 400 de una capa grande) rompería `fallos=0`, y la regla cuenta por sala,
  no por pantalla (los tubos están a 1270 px entre sí). `00-comun` §3.9 los pone entre los avisos, que el validador no
  tiene: van en N9 con el canal de avisos. Bajar `halo_radio` de los tubos se decide midiendo en el S50 (A7-04).
- N6 · `AvisoAccion.modo` {`UNA_VEZ`, `POR_VISITA`, `SIEMPRE`}, por omisión `UNA_VEZ` (lo que hacían los pizarrones con id).
  `SIEMPRE` es lo pedido el 26-oct-2026 para La Celda: el pizarrón sale cada vez y el botón deja de latir al hacerla (con
  id, eso se recuerda). Un solo `_jugador_dentro() -> Jugador` por tick y la regla general «el jugador puede atender»
  (`not (descansando or hablando or muerto)`), no `Jugador.puede_interactuar`, que exige el suelo. Validador: `UNA_VEZ`
  sin id y `POR_VISITA` con id fallan. Ningún aviso del repo cambió de comportamiento. `aviso_accion.guion` pasa de
  `fin 600` a `fin 1000`: los 5 casos nuevos no cabían.
- N6 · `Npc`: `animacion` (`AnimatedSprite2D` hijo, opcional) con nombres fijos `quieto`, `hablar` y `entregar`, tocadas
  solo si el `SpriteFrames` las tiene (`classes/class_spriteframes.rst:280`); `entregar` vuelve a `quieto` con
  `animation_finished` (`classes/class_animatedsprite2d.rst:112`) y el validador falla si va en bucle. Se voltea con
  `scale.x` sobre los pies y no con `flip_h` + `offset` calculado (lo de la copia de pruebas): así el pivote lo pone el
  dibujo del NPC (C4) y el núcleo no conoce el tamaño del cuadro. Zona muerta de 4 px, no de medio ancho: hablando, el
  jugador está encima del NPC y con medio ancho nunca se voltearía. **No se agregó `etapa_terminada`:**
  `conversacion_terminada(etapa)` ya se emite justo al terminar contando una etapa (la usan `prueba_dialogo` y el
  contrato); es la señal que conecta la sala. La espera de la entrega antes de la cinemática (45 ticks en la copia de
  pruebas) la decide C4 (por ejemplo, esperar `animation_finished` del dibujo); el `Npc` no conoce cinemáticas.
- N6 · `muro_rompible.guion` pasa de `fin 420` a `fin 700`: con los casos de caminar contra el muro la prueba no
  terminaba (contaba 28 de 29 sin fallos). Casos: `muro_rompible` 22 → 29, `aviso_accion` 27 → 32, `estado_sala` 30 →
  32, `piezas_sala` 28 → 31, `herramientas/validador` 80 → 92, `npc` nuevo con 10. Comprobado quitando cada arreglo:
  sin mostrar lo descubierto al romper falla 1 de `muro_rompible`; sin la regla de atender, 1 de `aviso_accion`; con el
  `clave_de` de antes, 2 de `estado_sala`.
- N6 · Sala de muestra: no se hizo una sala nueva. Lo de N6 que se juega ya se ve en Secretos (la orilla que aparece al
  romper el muro A y las monedas encerradas detrás); `SIEMPRE` y `corte_arriba` se ven con sus datos reales en los
  pizarrones y tubos de La Celda (C2 a C4), y el `Npc` animado necesita el arte del Eterno (C4). Una `LuzSala` cortada en
  Secretos casi no se notaría: la sala no tiene oscuridad.
- N6 · Revisión: la regla del muro en el validador se llama `_revisar_muro(ruta, muro: MuroRompible)` (antes
  `_revisar_rutas_de_secretos`): las rutas ya las revisa `_revisar_rutas_de_nodos` y quien la llama ya filtra por tipo.
  Sus casos en `prueba_validador` se llaman `muro: ...`; el conteo no cambia (92).
- N6 · Entradas nuevas con `"pasa": false`: `muro-descubre-y-luz-corte`, `aviso-accion-modo`, `npc-animado` y
  `clave-de-piezas` (`nucleo/funciones.json`); `validador-rutas-de-nodos`, `validador-descubre` y
  `validador-avisos-modo` (`herramientas/funciones.json`). Tras la revisión, `validador-avisos-modo` queda solo para
  el aviso y se parte en `validador-npc-entregar` y `validador-ids-en-piezas`: son tres reglas distintas y cada una se
  busca por su id; las tres con `"pasa": false` y la misma comprobación. Queda para N10 (es `CLAUDE.md`): sus filas en la tabla de
  `herramientas/CLAUDE.md`.
- N6 · La fila «NPC | `npc/<id>/`» de `contenido/CLAUDE.md` (A10-16), que ya pide el contrato, va en N10 con los
  demás cambios de `CLAUDE.md`, que se le muestran antes a la persona.

- N7 · Señal de aterrizaje: `jugador_aterrizo(velocidad: float, duro: bool, picada: bool)`, y no solo
  `(velocidad, picada)` como decía la fila de N7. Motivo: `Vibracion` no puede filtrar el duro por un umbral de
  velocidad (una caída que toca el tope 1200 px/s unos ticks cae igual de rápido que una dura de 18 ticks a tope; con
  gravedad 2400 eso es cualquier caída de más de unos 300 px), y la persona decidió el 07-oct-2026 que solo vibre el
  aterrizaje duro (`planes/cerrados/nucleo-auditoria-hollow-knight.md`, fila 7). Es la corrección del verificador de
  A3-11 y el `duro` de A10-07. `jugador_toco_suelo` nunca existió en este repo (era de la copia de pruebas): la única
  señal es `jugador_aterrizo`, que ahora sale en todo aterrizaje con caída. `velocidad` es la de caída del último
  tick en el aire (`_velocidad_caida`; `move_and_slide` la deja en 0 al tocar el suelo). Si la persona prefiere las
  dos claves exactas, quitar `duro` es tocar `eventos.gd`, `jugador.gd`, `vibracion.gd`, `sonido.gd`, la prueba y el
  contrato.
- N7 · Aparecer no es aterrizar: `is_on_floor()` da `false` hasta el primer `move_and_slide`, así que al entrar a cada
  sala salía un aterrizaje (lo mostraron `vibracion_aterrizaje` y las dos `camara_temblor_picada_*`, que contaron 2).
  Regla: sin velocidad de caída (`_velocidad_caida > 0`) no hay aviso, salvo el duro. Caso nuevo en `sonido`.
- N7 · La picada sigue avisando en `_seguir_picada` (antes de la onda: la vibración del aterrizaje gana a la del
  golpe) y pone `_en_suelo_antes = true`: es el estado real tras su `move_and_slide`, no un parche; sin eso el
  `_aterrizar` del tick siguiente vería otro aterrizaje. Lo comprueban las `camara_temblor_picada_*` (una sola señal).
- N7 · Pasos con `frame_changed` (`classes/class_animatedsprite2d.rst:138-140`) y `animation_changed` (`:100-102`): los
  bucles de caminar y carrera los avanza el sprite y, al empezar a caminar, `play()` puede dejar el mismo índice de
  cuadro. Un paso por pareja clip y cuadro (no cuenta dos veces el mismo). Determinista en los guiones (headless con
  `--fixed-fps 60`): caminar un segundo dio entre 3 y 5 pasos. Sin pasos en un cruce de puerta (`en_transicion`).
- N7 · Cuadros de paso como dato del personaje (A2-20): metadato `pasos` del `SpriteFrames`
  (`jugador_hombre.tres`: `correr` y `carrera`, cuadros 0 y 3, los de la copia de pruebas), no constante de
  `Jugador`. `generar_sprites.gd` copia los metadatos del `.tres` anterior (`META_CONSERVADOS`) porque el atlas no los
  trae: regenerado con el `atlas.json` del proyecto de arte, el `.tres` sale idéntico (0 líneas de `diff`). No se
  tocó `atlas.py`.
- N7 · `jugador_paso` y `jugador_impulso` entran al bus: Sonido central por ahora (decisión menor A6-13). Son las
  señales que la copia de pruebas agregó y que los WAV elegidos necesitan.
- N7 · Sonido: un `AudioStreamPlayer` hijo (`Voces`) con `AudioStreamPolyphonic` de 8 voces (A6-02); `tocar()`
  devuelve el id de la voz y cuenta `descartados` cuando `play_stream` da `INVALID_ID`; `sonando(voz)` para la
  prueba. Se fueron `EVENTOS`, los `_al_*`, `campos_de_efecto()`, `tonos`, `variacion_tono`, `tono()`, `_azar` y la
  prueba con `RegEx` (A6-04, A6-16); `sin_espera` es `@export` de `Sonido` (comportamiento, no dato de sonido).
  `FichaSonidos.tiene_campo()` reemplaza a la lista para el aviso de evento sin campo. `_exit_tree` calla las voces:
  con efectos sonando al cerrar, la corrida con ventana daba `ERROR: 3 resources still in use at exit`.
- N7 · `play_stream` toca un `AudioStreamRandomizer`: comprobado con ventana en la PC (27-oct-2026, caso de
  `sonido` con pantalla). Sin pantalla `Sonido` está mudo y esa ruta no corre: los tres casos de sonido real solo
  salen con ventana (18 casos contra 16 del CI; comando en `docs/pruebas.md`).
- N7 · WAV elegidos: los diez de la ficha elegida por la persona el 26-oct-2026 (golpe B, daño A, curar D, banco A,
  muro roto B, portón A, paso A, aterrizaje A, picada B desde el impacto, impulso C), copiados uno a uno y
  renombrados sin sufijo (`golpe.wav`, `dano.wav`…) en `nucleo/sonidos/jugador/`, con `.import` nuevo (los parámetros
  eran los de omisión: QOA). Origen comprobado: sintetizados con numpy por un script escrito con Claude Code, sin
  muestras ajenas (README del proyecto de sonido); fila «Sonidos» de `docs/uso-de-ia.md`. Ninguno sin origen.
  Randomizer de un WAV con `random_pitch` 1,06 solo en paso, aterrizaje y golpe (decisión menor A6-03); los demás,
  WAV directo. Los Randomizer van como `sub_resource` de la ficha: sin un `.tres` por efecto.
- N7 · El daño sí suena (`dano.wav`): es uno de los diez elegidos por la persona, no un sonido nuevo. `sonidos-telefono`
  sigue con `"pasa": false` hasta que la persona lo oiga en el teléfono; la fila «Efectos de los eventos» de
  `docs/pruebas.md` se reescribió para la ficha nueva. Parry y salto mudos (D9 y la elección del 26-oct-2026).
- N7 · Ficha en `nucleo/sonidos/sonidos_jugador.tres` (la ruta de A6-06), escrita con `ResourceSaver` y uid
  (`uid://c0xq1ebb0yprj`); a sus `ext_resource` se les agregó el `uid=` de cada `.import` y del `.gd.uid`. Se borraron
  `sonidos_prueba.tres`, `efecto_golpe.wav` y `efecto_salto.wav` (con sus `.import`; están en `HEAD`): la prueba arma
  su ficha en código. El panel de audio prueba con `jugador/golpe.wav`. `musica_prueba.ogg` queda para N8 (A6-11).
- N7 · `docs/errores/2026-10-27-sonido-corta-voces.md` (la rueda de cuatro voces cortaba efectos largos) y el «Lo
  cubre» de `2026-10-17-sonidos-sin-campo.md` al día. Entrada nueva `sonidos-jugador` con `"pasa": false`; reescritas
  (sin cambiar `pasa`) `vibracion-al-aterrizar`, `sonidos-eventos` y `sonidos-muro-y-porton`, porque su texto
  nombraba la ficha de prueba, `Sonido.EVENTOS` y el aviso solo en el duro. Quedan para que la persona las confirme al
  aprobar el bloque; si prefiere no tocar entradas viejas, se revierten esos tres `que` y va una entrada nueva.
- N7 (revisión) · Umbral del aterrizaje en `Sonido`, no en la señal: `@export velocidad_aterrizaje_min` = 200 px/s
  (una caída de unos 8 px; con gravedad 2400 cada tick en el aire suma unos 40 px/s). Bajar un escalón o la unión de
  dos piezas de suelo emitía `jugador_aterrizo` con muy poca velocidad y sonaba. El duro y la picada suenan siempre.
  La señal sigue saliendo en todo aterrizaje con caída: `Vibracion`, la cámara y los guiones no cambian. Caso nuevo
  en `sonido`.
- N7 (revisión) · `sonido` pasa de 16 a 19 casos sin pantalla (21 con ventana): aterrizaje lento callado y picada lenta
  sí; un aterrizaje común no vibra (`Vibracion.pedidas` no sube); entrar caminando por una puerta no da pasos. Los
  tres se comprobaron rompiendo a propósito el código que protegen (cada uno falló) y se restauró. Lo de la puerta va
  en la prueba y no como `senal ... jugador_paso 0` en `cambio_de_sala`: `senal` cuenta desde el cuadro 1
  (`docs/guiones.md:37`) e incluye la caminata hasta la puerta.
- N7 (revisión) · `sonidos-jugador`: su `que` separa lo que comprueba el CI de lo que solo se comprueba con ventana, en
  vez de una ruta `manual:` en `comprobacion` (el validador trata `manual:` solo como prefijo de toda la cadena,
  `herramientas/validar.gd:414`).
- N7 (revisión) · Parry: en `docs/contrato.md` y `docs/pruebas.md` queda como mudo por ahora (decisión abierta D9 de
  `ESTADO.md`) y el salto, mudo por elección. Comentarios de `vibracion.gd`, `sonido.gd` y `prueba_sonido.gd` sin
  historia ni referencia a una persona (la historia está en `docs/errores/2026-10-27-sonido-corta-voces.md`).
- N7 · `jugador_paso` sale de `frame_changed` del sprite, no del tick: el paso es audio atado al dibujo, y el contrato
  deja lo visual en `_process`; solo lee `is_on_floor()` y `en_transicion`, sin mover nada. Por eso no rompe la regla de
  lógica a 60 ticks.
- N7 · Las tres reescrituras del «que» de `vibracion-al-aterrizar`, `sonidos-eventos` y `sonidos-muro-y-porton` usan la
  autorización de la persona para editar `funciones.json` (27-oct): el texto viejo nombraba la señal y las constantes
  que ya no existen. `pasa` no cambió.
- N7 · `_exit_tree` de `Sonido` quitó el `ERROR: 3 resources still in use at exit` en 13 de 14 corridas con ventana; la
  primera, en frío, volvió a darlo junto con objetos sin liberar al salir. Solo pasa al cerrar con ventana; el CI no lo
  ve. Sin causa encontrada.
- N7 · El `revisor` sí revisó N7 (bus de eventos) en las dos rondas y lo aprobó; el pendiente que dice lo contrario es
  de un agente que no vio esa revisión.

- N8 · El tema del menú no estaba en el juego: se trajo `nucleo/sonidos/musica_menu.ogg` con su `.import` (uid
  `uid://b24kxuyaqcquj`, `loop=true`), idéntico byte a byte a la versión A elegida el 25-oct-2026; lo aprueba la
  decisión de la persona del 27-oct-2026 (el tema del menú se queda: menú y banco de La Celda). Fila nueva «Música»
  en `docs/uso-de-ia.md` (Google Flow Music, Lyria 3.5). Se fue `musica_prueba.ogg` con su `.import` y el reproductor
  propio del panel (A6-11, mejor alternativa del verificador); la fila «Sonidos» ya no la nombra.
- N8 · Acceso tipado: `Arranque.musica` y `Arranque.sonido` (`var` con su tipo, asignadas en `_ready`). Compila sin el
  aviso de acceso inseguro (`validar.ps1` `fallos=0`), así que no hizo falta `static var`. `prueba_sonido` también lo
  usa desde la revisión (ver abajo).
- N8 · «Vacío» y «silencio» separados: `tema` `null` no toca el tema y `Musica.SILENCIO` (`nucleo/sonidos/silencio.tres`,
  `AudioStreamWAV` vacío guardado con `ResourceSaver`, `uid://cxnwd8q11ot44`) lo calla; se compara por identidad y
  nunca se reproduce. Con «vacío = no tocar», «Continuar» desde el menú hasta `celda_1` dejaba sonando el tema del
  menú: `celda_1.tscn` lleva `tema_musica = SILENCIO` (como la sala callada que era). **Para C1:** la base
  `sala_celda.tscn` lleva `tema_musica = SILENCIO` (no hay tema propio de La Celda en el juego) y las salas la heredan;
  **para C4:** `celda_3` deja la sala callada y pone una `RegionMusica` con `musica_menu.ogg` sobre el banco y el
  Eterno, como la sala de prueba Música. Cuando exista un tema de La Celda, se cambia solo en la base.
- N8 · La zona de pruebas pide `SILENCIO` al abrir su lista: sus salas dejan el tema vacío y sin eso el tema del menú
  seguiría en todas (antes de la música las salas de prueba eran calladas). Una sala de prueba que quiera tema lo pide
  ella (la sala Música).
- N8 · Un solo punto de entrada `poner(tema, volumen_db, segundos)` (A6-10): se fueron `a_volumen` y las dos llamadas
  por pedido. Gana el último **por campo**: un pedido sin tema no borra el tema que otro dejó pendiente en el mismo
  tick (la región que solo baja el volumen no deshace el tema de la sala); el volumen lo reemplaza cada pedido. El
  pedido se aplica en el tick de física siguiente al del pedido (`Engine.get_physics_frames()`), sin tick cuando no
  hay pedido.
- N8 · Medido en `nucleo/musica` (la sala instanciada desde la prueba, no el cambio de escena del `Fundido`): al
  reaparecer o cargar en el banco, el pedido de la sala y el de la región llegan antes de que `Musica` aplique, así que
  el pendiente los junta. En el cambio real de escena ese orden no se midió: el `body_entered` podría llegar un tick
  después del primer aplicado, y entonces lo salva subir el reproductor que todavía tiene el tema. Con cualquiera de las dos defensas basta (pendiente, o
  subir el reproductor que todavía tiene el tema): quitando el pendiente fallan 2 casos (los de un mismo tick) y
  quitando las dos, 7, entre ellos «reaparecer en el banco dentro de la región no reinicia el tema». Se dejan las dos.
- N8 · A6-08: un tween por reproductor, cada uno desde la mezcla que lleva; un tema que se está yendo se sube sin
  reasignar el `stream`; un tema nuevo va al reproductor más callado. Un tercer tema distinto dentro de un fundido
  corta el que se iba (el más callado): se acepta, sin tercer reproductor.
- N8 · `RegionMusica`: liberar la sala con el jugador dentro emite `body_exited` con la región todavía en el árbol y
  **antes** del `tree_exiting` del jugador (medido con trazas: la forma de la región sale primero), así que ni
  `is_inside_tree()` ni `tree_exiting` lo distinguían y la música quedaba pedida a -60 dB. El pedido de salida va
  diferido y solo sale si la región sigue en el árbol al final del cuadro. Lo cubre el caso «liberar la sala con el
  jugador en la región no baja la música». Sin `docs/errores/`: era código nuevo de este bloque y se atrapó antes de
  entregarlo (como N5).
- N8 · Constantes `FUNDIDO` (2 s: sala y omisión) y `FUNDIDO_CORTO` (1 s: menú, cinemática, zona de pruebas y panel);
  la región conserva sus segundos exportados (Dirtmouth: 3 y 6). `se_oye()` con `DB_SILENCIO` en lugar del -40 suelto.
- N8 · La prueba mide «no se reinicia» con `Musica.arranques` (público): sin pantalla no se reproduce nada y la
  posición de reproducción queda en 0 (A9-15). Con ventana suma un caso con la posición; en la PC (27-oct-2026):
  `PRUEBAS musica casos=20 fallos=0`, sin `ERROR` al salir. Los casos de lógica usan temas vacíos con `mudo` forzado y
  se devuelve al terminarlos.
- N8 · Sala de prueba jugable `herramientas/salas/sala_musica.tscn` en «Mundo» («Música», «Tema de una región»):
  callada, con una `RegionMusica` del tema del menú sobre su banco y una franja opaca que la marca. La usa la prueba
  (se instancia con la llegada en el banco, que es lo que hace el Fundido al reaparecer) y la persona para oírlo.
- N8 · Diferidos (después, midiendo u oyendo en el S50): tema de salida de `RegionMusica` y pausar el tema callado a
  -60 dB (A6-09: medir antes si cuesta CPU); recodificar el Ogg a 44,1 kHz y ~96 kbps (A6-15: medir
  `AudioServer.get_mix_rate()` y FPS); bajar la música en la pausa (A6-18: con un factor propio, sin pisar el volumen
  del usuario); curva de las barras de volumen (A6-19).
- N8 · Para N9: la regla «tema sin bucle» revisa `Sala.tema_musica`, `RegionMusica.tema` y `Musica.TEMA_MENU`, y se
  salta `Musica.SILENCIO`; y la forma hija de `RegionMusica` (convención de áreas de N1). Para N10: nada de
  `CLAUDE.md` cambió con N8.
- N8 · `revisor` pendiente (toca `arranque.gd`, el autoload): `musica-por-sala` y `musica-telefono` con `"pasa": false`.
  Reescritos sin cambiar `pasa` (autorización del 27-oct-2026): `audio-y-brillo` (el panel pide el tema a `Musica`; su
  comprobación suma `nucleo/musica`), `audio-y-brillo-telefono` («la música» en lugar de «la música de prueba») y la
  entrada histórica de `PanelAudio`.
- N8 · Revisión (27-oct-2026), grave: `Musica` multiplicaba dos tweens (mezcla del reproductor y volumen de región) y
  callar un tema a -60 dB lo subía a -12 dB por el camino (`docs/errores/2026-10-27-musica-sube-al-callar.md`). Ahora
  hay un solo tween por reproductor sobre su volumen final, en línea recta, y se fue la propiedad pública `region`.
  Porqué: cualquier «fijar la región de golpe» rompía otro caso (saltaba de -60 a 0 el que se iba, o el que entraba
  llegaba a 0 dB antes de bajar). Si cambia el tema, todos los reproductores se rehacen con los segundos del tema
  (también el que ya se iba: así se comportaba antes y la prueba con ventana lo necesita); si no, solo el que suena,
  con los segundos del volumen. Dos casos nuevos en `prueba_musica.gd` leen `volume_db` tick a tick (fallaban los dos
  con el código anterior): `musica.esperado` pasa de 19 a 21 casos (22 con ventana).
- N8 · `prueba_sonido.gd` lee `Arranque.sonido` en vez de la ruta absoluta y sin las ramas de `null`, igual que
  `prueba_musica.gd` (un autoload siempre está cargado); los casos no cambian.
- N8 · La evidencia de `audio-y-brillo-telefono` (`pasa: true`, 13-oct-2026) es anterior al cambio del panel: entonces
  sonaba su reproductor propio. Se deja en `true` porque las barras y los buses no cambiaron; lo que cambió (el panel
  pide el tema a `Musica` en la pausa lejos de un tema y lo calla al cerrar) se suma a `musica-telefono`, que es una
  entrada nueva de este mismo bloque, sin confirmar: por eso se amplió su `que`. También pide escuchar si hay una
  bajada de un instante al reaparecer o cargar en el banco (orden de la región frente a la sala en un cambio de escena
  real, no medido); si se oye, el pedido de la sala se aplaza a 2 ticks.
- N8 · `nucleo/configuracion.gd`: de N8 son solo comentarios (el panel ya no tiene «música de prueba»). El orden de las
  variables sobre los `@onready` y `Ajustes.sin_ventana()` son de N1 (limpieza del orden de la guía de estilo y la
  única comprobación de «sin pantalla»), sin confirmar todavía.
- N8 · Al salir del menú (`Menu._ir`) se pide `Musica.SILENCIO`: una sala sin tema no toca la música, así que sin esto
  el tema del menú seguía sonando al cargar una partida en una sala sin tema (salas de prueba). La sala que pide tema
  lo pone en el mismo tick y gana el último pedido.
- N8 · `prueba_musica` sigue contando los dos reproductores de `Musica`: es el dato que permite leer el volumen de cada
  uno tick a tick para los casos de picos; por eso A9-15 queda parcial.

- N9 · Canal de avisos: `validar.gd` imprime `AVISO …` y una línea `AVISOS total=N` antes del resumen, que no cambia
  (`validar.ps1` y `ci.yml` lo casan con un regex estricto); los avisos no cuentan en `fallos`. `validar.ps1` muestra la
  cuenta tras el `OK`; el CI no cambia (no los busca). Hoy: 23 avisos, todos de `celda_1` (22 escalas no uniformes de
  arte que C2 rehace y los 4 halos de tubos).
- N9 · uid: alcance `contenido/`, `nucleo/`, `mapa/` e `interfaz/` (los bloques del juego; la fila decía `contenido/` y
  `nucleo/`, y `mapa/` entra porque sus tres escenas viajan en el paquete y eran arreglos de una línea). Fuera:
  `herramientas/` (unas 70 escenas y fichas de prueba sin uid; se nombran por ruta y no se mueven); se amplía cuando se
  quiera con `con_uids`. Falla una línea `[ext_resource` sin `uid=`, con un uid que no es el de su destino, o que nombra
  un `.tscn`/`.tres` sin uid en su cabecera (`ResourceLoader.get_resource_uid` da -1, `classes/class_resourceloader.rst:266`).
  Tras la revisión (27-oct-2026) también falla un `.tscn`/`.tres` de esas carpetas sin uid en su propia cabecera: si
  no, la primera sala que instanciara `npc.tscn`, `cortable.tscn` o `reto_preguntas.tscn` (C2 a C5) fallaría sin que
  `con_uids` pudiera arreglarlo. Las ocho escenas sin él (`cinematica_celda`, `celda_1`, `objeto_mapa`,
  `pantalla_mapa`, `cortable`, `editor_controles`, `npc`, `reto_preguntas`) recibieron uno nuevo con
  `ResourceUID.create_id` desde un script del scratchpad (solo la línea 1; se comprobó que ninguno se repite).
- N9 · Medido el 27-oct-2026: fuera del editor `ResourceSaver.save` no escribe el uid de los `ext_resource` ni el de la
  cabecera, y `ResourceSaver.set_uid` devuelve `OK` sin escribir nada. Por eso `validar.gd` tiene tres estáticas
  públicas (`uid_de`, `con_uids`, `guardar_con_uids`): la regla y su arreglo en un solo archivo, que ya está fuera del
  paquete. `generar_sprites` y `generar_mapa` guardan con `guardar_con_uids` (conserva el uid de cabecera que ya
  tenía el archivo o crea uno con `ResourceUID.create_id`, `classes/class_resourceuid.rst:106`). `jugador_hombre.tres`
  se regeneró con la herramienta y el `atlas.json` del proyecto de arte: el diff son solo dos líneas (cabecera con
  `uid://d3pkeh7d51kjj` y el uid del atlas). Las otras ocho escenas (`cinematica_celda`, `objeto_mapa`, `pantalla_mapa`,
  `cortable`, `editor_controles`, `jugador`, `npc`, `reto_preguntas`) se arreglaron con `con_uids` desde un script del
  scratchpad: una línea cada una, el uid leído del `.uid`/`.import`, no generado. `indice_salas.tres` lo reescribió
  `generar_mapa` (cabecera nueva y uid del script).
- N9 · Una vía: como `PlataformaDelgada` crea su forma en `_ready` y el validador no lo corre, toda forma con
  `one_way_collision` escrita en una escena falla, en cualquier carpeta (no solo `contenido/` y `herramientas/salas/`:
  es más simple y nada del repo la usa). La `PlataformaDelgada` se reconoce por clase, no por `scene_file_path`: una
  pieza de zona que herede de su escena (lámpara con dibujo) sigue siendo válida, y la forma y el margen los fija la
  clase. Dentro de algo que se mueve (`Vaiven.movil_de` de su padre) falla (medición de N3). La regla «nunca la única
  salida» y «no tapa un hueco de paso» no se pueden ver sin geometría: las cubre un guion de bajada por ruta (C3, C4).
  `TileMapLayer` no se usa; si entra, su una vía por polígono se suma a esta regla.
- N9 · Puerta `ABAJO` de ida sola: la regla de ida y vuelta se queda para todas menos `ABAJO`, a la que basta que la
  sala de destino tenga la puerta de llegada (la sala la usa como punto, `Sala._puerta_con_id`). Porqué: exigir la
  vuelta obligaría a poner en la sala de abajo una puerta `ARRIBA` a la que no se llega, con su llegada sobre el hueco,
  que devolvería al jugador a la caída; y la provisional del tiro de la sala 4 (decisión de la persona: lleva a la sala
  3 hasta que exista Las Raíces) puede llegar a una puerta que ya existe en la sala 3 sin un nodo de mentira. Solo
  `ABAJO`: una subida de ida sola no tiene caso.
- N9 · Tema sin bucle es **fallo**, no aviso (la fila lo ponía entre los avisos; `00-comun` §3.9 lo pone aparte): un
  tema que se apaga deja la sala callada sin que nadie lo pida y no tiene excepción legítima. Se revisan
  `Sala.tema_musica`, `RegionMusica.tema` y `Musica.TEMA_MENU`; se salta `Musica.SILENCIO` por identidad y `null`. Bucle
  por tipo (Ogg y MP3 `loop`, WAV `loop_mode`); otro tipo de stream falla para que nada pase sin revisar.
- N9 · `RegionMusica` con su `CollisionShape2D` hija: el mismo helper `_con_forma_hija` que `ZonaCamara`.
- N9 · `FondoTapado`: falla con `fin_pared` (en coordenadas de la sala) en `limites.end.x` o más allá: la vista nunca
  pasa ese borde y solo se vería la costura de `MARGEN` (2 px).
- N9 · Encime en el mapa: ahora falla también entre salas de la misma zona (tocarse por un borde no cuenta,
  `classes/class_rect2.rst:464`). Ninguna sala del repo falló. `limites.position == (0, 0)` en toda sala con id:
  tampoco falló ninguna (D19 opción 1, aprobada).
- N9 · Avisos: halos de `LuzSala` (área de `area_halo()` por la escala de sus padres ≥ la de una capa grande) sumados a
  las capas translúcidas; si las capas solas pasan el máximo sigue siendo fallo, y si solo con los halos lo pasan, aviso.
  Nodo oculto, forma apagada y escala no uniforme solo en `contenido/` y solo en los nodos de la escena misma (lo de
  dentro de una pieza se revisa en la pieza). `queue_redraw(` a un tabulador dentro de `_process` en `nucleo/` y
  `contenido/`, salvo en un script que llama a `set_process(` (esa es su guarda: `VerHitbox` solo procesa mientras se
  ve). Imagen de `contenido/` que ningún `.gd`, `.tscn` ni `.tres` nombra por ruta o uid. Tras la revisión: un `return`
  antes del `queue_redraw()` en el mismo `_process` (salida temprana) cuenta como guarda; los huecos que quedan (no
  sigue llamadas; un `set_process(` en cualquier parte salta el script) están escritos en el comentario: es un aviso,
  no un fallo, y seguir llamadas pediría un analizador.
- N9 · Revisión (27-oct-2026): los comentarios de `validar.gd` ya no citan IDs de la auditoría (A7-04, A7-03, BZ-13,
  B1-08, A10-21, C-08), sino su porqué técnico; los IDs se quedan en este plan. `_es_capa_translucida_grande` usa
  `_escala_visible` para la escala y la visibilidad (su bucle solo multiplica el alfa) y `_revisar_fondos_tapados` usa
  `_de_tipo`. Mismo resultado: 23 avisos, el de halos de `celda_1` igual.
- N9 · No hechos, con su porqué: textura con alfa intermedio contada como capa (A7-08 (1)): `Image.detect_alpha` da
  `ALPHA_BLEND` en cualquier recorte con borde suavizado, así que avisaría de casi todo el arte; hace falta medir qué
  fracción semitransparente cuesta antes de escribir la regla. Presupuesto de textura por sala (C-11): no hay tope
  medido en el S50. Regla de CRLF (A9-13): no se agrega, `.gitattributes` ya normaliza.
- N9 · La frase «en el S50 el límite es el relleno» se cambió en `validar.gd` y `fondo_tapado.gd` por «se mide A/B»;
  en `docs/contrato.md` (líneas ~308 y ~334), en `planes/activos/contenido-celda.md` (línea 15) y en la skill
  `rendimiento-gama-baja` queda para N10.
- N9 · `_avisar_redibujo` cuenta como guarda cualquier `return` previo dentro de `_process`, aunque esté en un `if`
  ajeno al redibujo. Es un aviso, no un fallo; afinarlo pediría analizar el flujo del script.
- N9 · Para N10 (son `CLAUDE.md` o contrato y se muestran a la persona): filas en la tabla de `herramientas/CLAUDE.md`
  para `validador-uid-ext-resource`, `generadores-con-uid`, `validador-una-via`, `validador-limites-origen`,
  `validador-mapa-misma-zona`, `validador-puerta-abajo`, `validador-fondo-tapado`, `validador-musica` y
  `validador-canal-avisos`; la fila de `validar.ps1` (cuenta de avisos) y en `docs/contrato.md` la regla de uid, la
  puerta `ABAJO` de ida sola y el tema en bucle.
- N10 · Los cambios a `CLAUDE.md`, skills y `revisor` se escribieron como propuesta exacta (texto actual, nuevo y
  porqué) en un documento del equipo fuera del repo; juntan todo lo dejado «para
  N10» por N1 a N9, más A7-01 y A10-16. La persona aprobó cinco por nombre (27-oct-2026) y se **aplicaron** con el
  texto exacto: `herramientas/CLAUDE.md` (fila `pruebas/`, fila `validar.ps1` con `AVISOS total=N`, fila del encime y
  13 filas de reglas del validador), `contenido/CLAUDE.md` (fila NPC), skill `fisica-2d` (ejemplos de `Capas.poner` y
  `recogible.gd`), skill `rendimiento-gama-baja` (medir A/B, materiales comunes, regla de `_draw`/`queue_redraw`) y
  `.claude/agents/revisor.md` (dibujo que se repite, uid y `capas_fisica`). La aprobación del texto exacto cuenta como
  haberlo mostrado. **Sin aplicar, pendientes de aprobación:** `mapa/CLAUDE.md` (encime en la misma zona) y la línea
  opcional del `CLAUDE.md` raíz sobre el uid, que la aprobación no nombra.
- N10 · El contrato recoge lo que N1 a N9 dejaron para él: convención de áreas (forma hija para lo que se ajusta a ojo;
  en código solo si el tamaño sale de otro dato), niebla como pieza, materiales comunes, regla de `uid`, puerta `ABAJO`
  de ida sola, tema en bucle, `limites` en (0, 0), encime en la misma zona, `FondoTapado`, avisos del validador,
  `Ajustes.sin_ventana()`, porqué de la regla sólida y la sección «Arte de zona». «El límite es el relleno» pasa a
  «se mide A/B» en el contrato y en `contenido-celda.md` (líneas 15 y 24), porque en La Celda bajar la resolución no
  subió los FPS (25-oct-2026).
- N10 · `prueba_capas_fisica` suma `PlataformaDelgada`, un `AnimatableBody2D` con `Vaiven`, `ZonaCamara` y
  `RegionMusica` (33 → 37 casos): el contrato («Capas de física») pide cada pieza que detecta o es detectada en esa
  prueba, y las cuatro de N3, N5 y N8 faltaban. Es un cambio a propósito del `.esperado`.
- N10 · A10-09: casi todas las entradas nuevas ya las sumaron N1 a N9 con `"pasa": false`. En N10 solo se corrigieron
  textos de `nucleo/funciones.json` que el código ya no cumple (`animacion-cuerpo-jugador` nombra `entrar_puerta` y
  `salir_puerta`; `musica-por-sala`, el panel de audio pide el tema del menú a `Musica`). En la corrección de N10, con la suite en
  verde (`MALOS=0`), pasan a `"pasa": true` las 25 entradas cuya comprobación son solo guiones que pasan y no esperan
  `revisor`: en `nucleo/`, `recogibles`, `puertas-tipo`, `fundido-cambio-sala`, `transicion-jugador`, `zona-camara`,
  `muro-descubre-y-luz-corte`, `aviso-accion-modo`, `npc-animado` y `clave-de-piezas`; en `herramientas/`,
  `generar-sprites-puerta`, `generadores-con-uid` y los `validador-*` de N2, N4, N5, N6 y N9 salvo `validador-una-via`
  y `validador-musica`. Siguen en `false` las de N3 (`plataformas-moviles`, `plataforma-delgada`,
  `validador-cuerpos-moviles`, `validador-una-via`), N7 (`sonidos-jugador`) y N8 (`musica-por-sala`,
  `validador-musica`) hasta su `revisor`, y las manuales y de teléfono. Las de
  contenido (salas 2 a 5, cinemática de la pluma, `salas-celda-telefono`) y la corrección de `sala-celda-1` y su
  `celda_banco` van con C2 a C6, que es donde cambia esa sala.
- N10 · A10-10/A9-14: filas nuevas en `docs/pruebas.md` para `monedas_sueltas` y `zona_camara`; la fila manual de las
  salas 2 a 5 y la de recogibles en la sala oscura de La Celda van con C6 (no hay salas que probar todavía).
- N10 · A10-12: no se escribe `docs/errores/` para `descubre`, `corte_arriba` ni `ticks_espera`: en esta rama son
  funcionalidades nuevas, no arreglos; los fallos reales de la tanda ya tienen su archivo (N3, N4, N7, N8).
- N10 · A10-01 no aplica: la persona decidió un solo PR el 27-oct (`ESTADO.md`). A10-03: `project.godot` y
  `export_presets.cfg` sin cambios (`git diff --stat HEAD`). A10-15 y A10-17 son de los documentos de diseño, no del
  repo: el material del peligro de la sala 2 lo decide la persona y, si solo cambia el arte, ni el contrato ni los
  guiones cambian. Lo general (lo que lastima tiene puntas y es cálido) quedó en «Arte de zona» del contrato.
- N10 · X-03 (la sala vacía `Partida.banco` si la sala ya no tiene banco) no está hecho: `celda_1` todavía lleva
  `banco_celda_1`. Va con C4, cuando la sala pierda el banco.

- N10 · Corrección: de los nueve cambios de la propuesta se aplican siete (los cinco archivos que la aprobación nombra)
  y no los de `mapa/CLAUDE.md` ni el raíz, porque la aprobación no los nombra y son configuración de Claude.
- N10 · Corrección: `docs/uso-de-ia.md` nombra carpetas, no archivos (coleccionable, mochila, montón de PejeCoins y
  tema del menú), porque el archivo y el `CLAUDE.md` raíz piden registrar por herramienta, no por archivo.
- N10 · Corrección: las filas manuales «Música» y «Puertas con interactuar» de `docs/pruebas.md` quedan con la
  evidencia vacía; el pendiente vive en `funciones.json` (`musica-telefono`, `puertas-telefono`) y en `ESTADO.md`,
  porque fuera de esos archivos y los planes no se suben avisos de trabajo sin terminar.
- N10 · Corrección: la fila de `herramientas/guiones/herramientas/validador.guion` en `docs/pruebas.md` pasa de 92 a
  141 casos y nombra las funciones de N2 a N9 que prueba.
- Cierre del núcleo · `"pasa": true` también en `plataformas-moviles`, `plataforma-delgada`, `validador-cuerpos-moviles`,
  `validador-una-via` y `validador-musica`: el `revisor` sí aprobó N3 y N8, y sus guiones pasan (suite 173/173).
  Siguen en `false` `sonidos-jugador` (parte de su comprobación solo corre con ventana) y `musica-por-sala` (su guion
  no ejercita al menú ni a la cinemática). Vuelven a `false` `aviso-accion-modo` (ningún caso con el jugador muerto) y
  `puertas-tipo` (ningún guion cruza una puerta `ABAJO`; C5 lo agrega con el tiro de la sala 4).
- Cierre del núcleo · `celda_1.tscn` declaraba sus dos `CanvasItemMaterial` como `sub_resource` (lo vio el `revisor` de
  los cambios a skills): ahora nombra `sin_luz.tres` y `aditivo.tres` como `ext_resource`, con los mismos valores.
  `validar.ps1` sin fallos y los cinco guiones de La Celda `MALOS=0`.
- Cierre del PR (28-oct) · `revisor` de toda la rama, con `Puerta` y `Banco` primero: aprobado, sin fallos graves.
  Arreglado: morir durante el retraso de un cambio con jugador dejaba la pantalla en negro (`Sala` reintenta
  reaparecer; `docs/errores/2026-10-28-muerte-durante-retraso.md`, caso nuevo en `prueba_transicion`, 26 casos);
  `Fundido.cambiar_sala` rechaza una ruta vacía; el contrato dice qué apaga el provisional de una puerta y el orden
  real del banco (emite y después guarda). Queda para la persona: `transicion-jugador` afirma «recupera el control por
  un tope si la sala no cambia» sin un caso que lo ejercite (el tope imprime `ERROR:`, que hace fallar un guion), y
  las entradas de `funciones.json` anteriores a la tanda cuyo `que` se reescribió (lista en el cierre). Sin cambio:
  durante el retraso de un cambio, un `fundido_pedido` de un peligro se ignora (inalcanzable hoy, como el anterior).
  `validar.ps1` `archivos=352 fallos=0`; suite `RESUMEN total=193 OK=193 MALOS=0`.

## Hecho
| Bloque | Resultado | Evidencia |
|---|---|---|
| N1 | `Ajustes.sin_ventana()`; `sin_luz.tres` y `aditivo.tres`; `nucleo/piezas/niebla.tscn` con el ruido horneado; `luces_avanzadas` apagado; herramienta de medición; limpieza (ver «Decidido en la tanda») | `validar.ps1` `archivos=293 fallos=0`; `correr-guiones.ps1` `RESUMEN total=166 OK=166 MALOS=0` (27-oct-2026). `piezas_sala.esperado` pasa de 26 a 28 casos (niebla y materiales). Medición probada en la PC con `celda_1`. Tras la revisión (27-oct-2026): `validar.ps1` `archivos=293 fallos=0`; guiones `nucleo/piezas_sala`, `brillo_sala`, `menu_configuracion`, `video`, `guardado`, `herramientas/validador` y los 14 de parry, bola y curar, `MALOS=0`; niebla dibujada sin hueco; `hornear_niebla()` reproduce el PNG con 0 píxeles distintos. Al cerrar N1, suite completa `RESUMEN total=166 OK=166 MALOS=0` |
| N2 | `Recogible` base de Coleccionable, MonedasSueltas, ObjetoHabilidad y ObjetoMapa; coleccionable único con la credencial, halo `LuzSala` y sin `_draw`; montón de PejeCoins horneado sin `_draw`; validador con `Recogible` y la regla de prefijo | `validar.ps1` `archivos=298 fallos=0`; guiones `nucleo/monedas_sueltas` (nuevo, 11 casos), `herramientas/validador` (61), `nucleo/guardado`, `nucleo/estado_sala`, `nucleo/capas_fisica` (32), `contenido/zona_prueba_coleccionable`, `zona_prueba_vitrina` y los de habilidades, mapa y tienda: `MALOS=0` (27-oct-2026). Suite completa `RESUMEN total=167 OK=167 MALOS=0`. Captura con ventana en la PC: arte sin sombreado y halo detrás. Tras la revisión (27-oct-2026): `validar.ps1 -SinImportar` `archivos=298 fallos=0`; `monedas_sueltas` (12), `herramientas/validador` (62) y 15 guiones más de recogibles, guardado, habilidades, mapa y tienda `RESUMEN total=17 OK=17 MALOS=0`; suite completa `RESUMEN total=167 OK=167 MALOS=0`. Falta lo del teléfono (`recogibles-telefono`) |
| N3 | `Vaiven` en ticks con espera al empezar y desfase, capa por `Capas.poner`, sin forzar `peligro`; `Giro` nuevo en ticks; `Vaiven.movil_de` compartida por jugador y validador; punto seguro sobre suelo fijo (tres rayos) y comprobado al usarlo con respaldo en llegada, `Entrada` y bancos; `platform_on_leave = ADD_UPWARD_VELOCITY`; `PlataformaDelgada` (margen 1 px); validador: Giro en los peligros y ningún cuerpo dentro de un `Vaiven` o `Giro`; sala `sala_plataformas`; dos `docs/errores/` | `validar.ps1` `archivos=304 fallos=0`; guion nuevo `nucleo/plataformas` (29 casos); `herramientas/validador` 62 → 66; suite completa `RESUMEN total=168 OK=168 MALOS=0` (27-oct-2026). Tras la revisión (27-oct-2026): `validar.ps1 -SinImportar` `archivos=304 fallos=0`; suite completa `RESUMEN total=168 OK=168 MALOS=0`; después del último caso, `plataformas` (30), `capas_fisica` (33), `herramientas/validador` y 10 de peligro, picada y `celda_grieta` `RESUMEN total=13 OK=13 MALOS=0`. Falta: `revisor` (física) y lo del teléfono (`plataformas-telefono`) |
| N4 | `Puerta extends Interactuable` con `tipo`, `punto_seguro` y `mirar_al_llegar`; `Fundido` único dueño del cambio de sala (perfiles, `en_negro`, aborto con el jugador muerto, `Error` del cambio); `Jugador.Transicion` (inmune, sin controles, `move_and_slide`, tope); clips `entrar_puerta` y `salir_puerta` desde el atlas regenerado; la sala resuelve la puerta de llegada una vez; validador de la llegada de las puertas; sala `sala_puerta_c`; dos `docs/errores/` | `validar.ps1` `archivos=307 fallos=0`; suite completa `RESUMEN total=170 OK=170 MALOS=0` (27-oct-2026), con `cambio_de_sala`, `fundido_puerta`, `enemigo_base` y `bus_eventos` reescritos por estados y los nuevos `puerta_accion` y `transicion` (22 casos; sin el `en_transicion` de `recibir_dano` fallan 3); `herramientas/validador` 66 → 71. El `revisor` lo aprobó (27-oct-2026, dos rondas, sin fallos graves); al cerrar N4, `validar.ps1` `archivos=307 fallos=0` y suite completa `RESUMEN total=170 OK=170 MALOS=0`. Falta lo del teléfono (`puertas-telefono`) |
| N5 | `ZonaCamara` (`Area2D` sin tick, `limites: Rect2`, forma hija); pila, «al instante» (30 ticks) y seguimiento lento en `CamaraJugador`, que recorta con `intersection` (`limites_vista()`); `Jugador.camara()`; validador: forma hija y límites con área dentro de la sala | `validar.ps1` `archivos=310 fallos=0`; guion nuevo `nucleo/zona_camara` (19 casos; quitando el recorte fallan 13 y sin el «al instante», 1); `herramientas/validador` 71 → 80 (también una escena cuya raíz es la zona); los 11 `camara_*`: `RESUMEN total=13 OK=13 MALOS=0` (27-oct-2026). Tras la revisión (27-oct-2026): salida al instante recién colocada y lento solo si cambia la zona que manda; `validar.ps1 -SinImportar` `archivos=310 fallos=0`; `zona_camara` 19 → 23 casos (con las dos correcciones revertidas fallan 3), los 11 `camara_*` y `herramientas/validador` `RESUMEN total=13 OK=13 MALOS=0`. Sala 4 (C5, 28-oct): la zona quedó en el pasillo y contiene la única llegada, así que el caso de los ticks 20 a 29 no ocurre; bajada gradual y entrada por el borde, sin cambio (porqué en `contenido-celda-salas`, «Decidido», C5). Cómo se ve en el teléfono queda en `sala-celda-4-telefono` |
| N6 | `MuroRompible.tapas`/`descubre` y `Palanca.portones` como nodos exportados; lo escondido encerrado (validador: lo descubierto sin física, fuera del muro, no en las dos listas); `LuzSala.halo_radio`, `corte_arriba`, `caja_halo()`/`area_halo()`; `AvisoAccion.modo` y la regla «puede atender»; `Npc` con `AnimatedSprite2D` opcional que se voltea; `Sala.clave_de` sube a la primera `Sala`; validador: toda ruta de nodo guardada resuelve, avisos por modo, `entregar` sin bucle, ids dentro de piezas | `validar.ps1` `archivos=312 fallos=0`; `muro_rompible` (29), `aviso_accion` (32), `estado_sala` (32), `piezas_sala` (31), `herramientas/validador` (92), `npc` nuevo (10), `muro_rompible_caminando`, `brillo_sala` y los cuatro `dialogo*`: `MALOS=0`; suite completa `RESUMEN total=172 OK=172 MALOS=0` (27-oct-2026). Falta: el conteo de halos en el presupuesto (N9) y ver el NPC animado con su arte (C4) |
| N7 | `jugador_aterrizo(velocidad, duro, picada)` en todo aterrizaje con caída (aparecer no cuenta); `Vibracion` solo con duro o picada; `jugador_paso` por `frame_changed`/`animation_changed` con los cuadros en el metadato `pasos` del `SpriteFrames` (conservado por `generar_sprites`); `jugador_impulso`; `Sonido` con un `AudioStreamPlayer` y `AudioStreamPolyphonic` de 8 voces, bus `Efectos` explícito, una conexión por señal, `sin_espera`, `descartados`; `FichaSonidos` sin tonos; los diez WAV elegidos en `nucleo/sonidos/jugador/` y `sonidos_jugador.tres` con `AudioStreamRandomizer` en paso, aterrizaje y golpe; salto y parry mudos; fuera la ficha y los WAV de prueba; un `docs/errores/` | `validar.ps1` `archivos=312 fallos=0`; `sonido` 11 → 16 casos sin pantalla (18 con ventana, 0 fallos: `play_stream` toca un Randomizer, el portón no se corta con cinco pasos, con las voces llenas se descarta el nuevo); `habilidad_impulso` cuenta `jugador_impulso`; `vibracion_aterrizaje` y las `camara_temblor_picada_*` con una sola señal; suite completa `RESUMEN total=172 OK=172 MALOS=0` (27-oct-2026). Tras la revisión (27-oct-2026): `velocidad_aterrizaje_min` en `Sonido`; `sonido` 19 casos sin pantalla (21 con ventana, 0 fallos); `validar.ps1 -SinImportar` `archivos=312 fallos=0`; 25 guiones de sonido, bus, vibración, aterrizaje, picada, impulso y puertas `RESUMEN total=25 OK=25 MALOS=0`; suite completa `RESUMEN total=172 OK=172 MALOS=0`. Falta: `revisor` (bus de eventos) y oírlo en el teléfono (`sonidos-telefono`, `sonidos-jugador`) |
| N8 | `Musica` hija de `Arranque` con acceso tipado (`Arranque.musica`, también `Arranque.sonido`): un punto de entrada `poner(tema, volumen_db, segundos)`, pedido aplicado en el tick siguiente con «gana el último» por campo, un tema que suena o se va no se reasigna ni reinicia, `SILENCIO` separado de «vacío», `se_oye()` y `probar()`; `RegionMusica` con la salida diferida; `Sala.tema_musica` y `volumen_musica_db`; el menú pone `TEMA_MENU`, la cinemática y la zona de pruebas callan, `celda_1` en `SILENCIO`; el panel de audio sin reproductor propio; `musica_menu.ogg` en el juego, `musica_prueba.ogg` fuera; sala de prueba Música | `validar.ps1` `archivos=318 fallos=0`; guion nuevo `nucleo/musica` (19 casos sin pantalla, 20 con ventana; sin el pendiente fallaban 2 y sin las dos defensas 7, medido antes de la revisión); `musica`, `menu`, `menu_configuracion`, `video`, los cuatro `banco*`, los cuatro `pausa*`, `ranuras`, `guardado`, `zona_pruebas_categorias`, `zona_pruebas_volver`, `sonido`, `marco` y `cambio_de_sala` `RESUMEN total=19 OK=19 MALOS=0` (27-oct-2026); suite completa `RESUMEN total=173 OK=173 MALOS=0`. Tras la revisión (27-oct-2026; un tween por reproductor, `docs/errores/2026-10-27-musica-sube-al-callar.md`): los 2 casos nuevos de picos fallaban antes del arreglo (-12 dB) y pasan; `validar.ps1` `archivos=318 fallos=0`; `nucleo/musica` 21 casos sin pantalla y 22/0 con ventana; los 20 guiones de música, menú, banco, pausa, configuración, video, sonido, ranuras, guardado, zona de pruebas, marco y cambio de sala `RESUMEN total=20 OK=20 MALOS=0`; suite completa `RESUMEN total=173 OK=173 MALOS=0`. Falta: `revisor` (autoload) y oírlo en el teléfono (`musica-telefono`) |
| N9 | Validador: uid de cada `ext_resource` en `contenido/`, `nucleo/`, `mapa/` e `interfaz/` (más `uid_de`, `con_uids` y `guardar_con_uids`, que usan `generar_sprites` y `generar_mapa`); una vía solo como `PlataformaDelgada` fija; `limites` en (0, 0); sin encime en el mapa en la misma zona; `FondoTapado` que nunca se ve; `RegionMusica` con forma hija; tema en bucle (también el del menú); puerta `ABAJO` de ida sola; canal de avisos (`AVISO`, `AVISOS total=N`): imagen sin uso, `queue_redraw` sin guarda, oculto, forma apagada, escala no uniforme y halos de `LuzSala` en las capas. `jugador_hombre.tres` regenerado con uid; ocho escenas y el índice del mapa con sus uid | `validar.ps1` `archivos=318 fallos=0` (`AVISOS total=23`, todos de `celda_1`); `herramientas/validador` 92 → 138 casos, 0 fallos; suite completa `RESUMEN total=173 OK=173 MALOS=0` (27-oct-2026). Tras la revisión (27-oct-2026): uid en la cabecera de cada escena de esas carpetas (8 escenas regularizadas), salida temprana como guarda del redibujo, comentarios sin IDs de auditoría; `validar.ps1` `archivos=318 fallos=0` (23 avisos), `herramientas/validador` 138 → 141, suite completa `RESUMEN total=173 OK=173 MALOS=0` |
| N10 | `docs/contrato.md` al día con N1 a N9 (áreas, niebla, materiales comunes, uid, `ABAJO` de ida sola, tema en bucle, `limites` en (0, 0), encime en la misma zona, avisos del validador, `Ajustes.sin_ventana()`, porqué de la regla sólida, «Arte de zona», medir A/B en vez de «el límite es el relleno»); `docs/jugador.md` (cruce de puerta en la prioridad horizontal, zona de cámara); `docs/pruebas.md` (filas `monedas_sueltas` y `zona_camara`, `capas_fisica` a 37); `docs/uso-de-ia.md` (Imágenes y Video por herramienta); `contenido-celda.md` líneas 15 y 24; textos de dos entradas de `nucleo/funciones.json`; `prueba_capas_fisica` con `PlataformaDelgada`, plataforma con `Vaiven`, `ZonaCamara` y `RegionMusica`; propuesta de cambios a `CLAUDE.md`, skills y `revisor`. Tras la revisión (27-oct-2026): **aplicados** los cambios aprobados a `herramientas/CLAUDE.md`, `contenido/CLAUDE.md`, las skills `fisica-2d` y `rendimiento-gama-baja` y `revisor.md` (`mapa/CLAUDE.md` y el raíz, pendientes de aprobación); `"pasa": true` en 25 entradas que solo dependen de guiones (9 de `nucleo/`, 16 de `herramientas/`); `docs/pruebas.md` con el validador a 141 casos y sin avisos de pendiente; `docs/uso-de-ia.md` sin nombres de archivo | `validar.ps1 -SinImportar` `archivos=318 fallos=0` (`AVISOS total=23`); `nucleo/capas_fisica` 33 → 37 casos `RESUMEN total=1 OK=1 MALOS=0`; suite completa `RESUMEN total=173 OK=173 MALOS=0` (27-oct-2026). Contrato contra código revisado: `Recogible`, `PlataformaDelgada` (`GROSOR` 20, `MARGEN` 1), `Giro`, `ZonaCamara`, `Puerta.Tipo`, `Fundido.cambio_fallido`, `Musica.poner`, `RegionMusica`, `jugador_aterrizo(velocidad, duro, picada)`, `jugador_paso`, `jugador_impulso`, `Ajustes.sin_ventana()`, `material_sin_luz()`, `material_aditivo()`. Tras la revisión: `validar.ps1 -SinImportar` `archivos=318 fallos=0` (`AVISOS total=23`); `herramientas/validador` (141) `RESUMEN total=1 OK=1 MALOS=0`; suite completa `RESUMEN total=173 OK=173 MALOS=0` (27-oct-2026). Falta: aprobar `mapa/CLAUDE.md` y el raíz; los `revisor` pendientes de N3, N7 y N8 (y el de `.claude/`, que el raíz pide) |
