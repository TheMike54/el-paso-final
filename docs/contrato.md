# Contrato del proyecto

Lo que un bloque puede dar por hecho de los demás: la configuración del proyecto, el ciclo de vida, los autoloads,
la entrada y la interfaz de los guiones. Si un cambio altera algo de aquí, este documento se actualiza en el
mismo cambio. Las señales del bus de eventos, la forma de una sala, la ficha de una entidad y el esquema del
guardado entran a este documento en el mismo cambio que los implementa, con su plan aprobado antes.

## Configuración del proyecto

Valores de `project.godot`. No se cambian sin actualizar esta tabla.

| Tema | Valor | Por qué |
|---|---|---|
| Motor | Godot 4.7.2 estable, edición estándar | Un proyecto guardado con una versión más nueva no abre en una anterior |
| Renderer | Compatibility en `rendering_method` y en `rendering_method.mobile` | Teléfonos de gama baja |
| Resolución base | 1280×720 | Proporción 16:9; el arte se mide contra esta base |
| Estiramiento | `canvas_items` con aspecto `expand`, limitado al ejecutar a proporciones de 4:3 a 22:9 (`nucleo/vista.gd`, aplicado por `Arranque`, el mismo rango en escritorio, teléfono y tableta) | Dentro del rango la base se escala y se ve más escenario, sin barras; fuera, la vista se recorta a 1760×720 o 1280×960 y el motor pone barras negras. Sin pantalla (guiones) no se aplica. El color de borrado es negro (`Arranque`): fuera de una sala no se ve gris |
| Escala | Cuadro de 40 px; el personaje mide 160 px de alto | Medida común para salas, colisiones y arte |
| Orientación | Horizontal con giro (`window/handheld/orientation=4`, `SCREEN_SENSOR_LANDSCAPE`) | Se juega acostado, hacia cualquiera de los dos lados |
| Botón Atrás | `quit_on_go_back=false` | Atrás no cierra la app: en el juego abre la pausa (con el marco de menús o Configuración abiertos, los cierra o vuelve un nivel) y en el menú pide confirmación |
| Tipado | `untyped_declaration`, `unsafe_property_access`, `unsafe_method_access` y `unsafe_call_argument` como error | Un error de tipos se ve al validar, no al jugar |
| Texturas | Ninguna de más de 2048 px por lado (lo revisa el validador) | Memoria en gama baja |
| Solo 2D | `Arranque` pone `disable_3d` en la vista raíz | La vista no prepara nada de 3D; un nodo 3D no se vería |
| Compresión de texturas | `textures/vram_compression/import_etc2_astc=true` | Godot no exporta a Android sin ella |
| Filtro de texturas | `textures/canvas_textures/default_texture_filter=2` (lineal con mipmaps) | La vista de 1280×720 se encoge en pantallas más chicas; el arte del mundo lleva mipmaps (ver «Recursos») |
| Interpolación de física | Apagada (`physics/common/physics_interpolation`, por omisión) | Decidido el 15-oct-2026: en el S21 a 120 FPS no hay saltos sin ella, y suma retraso a la entrada (parry, salto en cola) |
| Capas de física | `layer_names/2d_physics/layer_1` a `layer_7` | Nombres en el editor; la tabla, en «Capas de física» |
| Id del paquete Android | `com.themike54.elpasofinal` | Identidad estable de la app instalada |
| Ícono | `config/icon` = `res://nucleo/arte/icono/icono_192.png`; en los dos presets, `launcher_icons/*`: el de 192 y los adaptativos de 432 (frente, fondo y monocromo), en `nucleo/arte/icono/` | El ícono aprobado el 21-oct-2026 en el lanzador y en el editor (`tutorials/export/exporting_for_android.rst:119-127`) |

## Ciclo de vida

- Arranque: Godot carga los autoloads y después la escena principal (`application/run/main_scene`).
- La lógica del juego corre en `_physics_process`, a 60 ticks por segundo. `_process` queda para lo visual.
- La acción `pausa` no guarda. La partida se guarda al descansar en un banco y se autoguarda (lo obtenido, nunca la
  posición: al continuar se aparece en el último banco) en los momentos que lista `autoguardar()` en «Estado de la
  partida».
- Pausa: `nucleo/pausa.tscn` (`class_name Pausa`), que crea cada sala. La acción `pausa` o el botón Atrás de
  Android la abren y la cierran (`get_tree().paused`); tiene Continuar, «Configuración» (la misma del menú, en la capa
  22 encima de la pausa y con el juego detenido, con Recursos bloqueado; de ahí sale el editor de los botones táctiles;
  ver «Menú» y «Entrada») y «Salir al menú», como en Hollow Knight. Los amuletos, el inventario y el mapa están en el
  marco de menús (ver «Marco de menús»). Al abrirse guarda una copia de la pantalla para la pantalla de brillo (no en
  headless) y la suelta al cerrarse. Se abre sola al perder el foco (`NOTIFICATION_APPLICATION_FOCUS_OUT` o
  `NOTIFICATION_APPLICATION_PAUSED`: apps recientes, otra ventana) y no se cierra sola al volver. Corre con
  `PROCESS_MODE_ALWAYS`, igual que los controles táctiles. Su propiedad `abierta` dice si está abierta. La pausa
  lee la acción, no el evento: la abren igual la tecla, el botón táctil y un guion. Con el editor abierto (`editor`
  no es `null`), la acción `pausa` no hace nada y Atrás es Cancelar. Con Configuración abierta, `pausa` y Atrás
  vuelven un nivel en ella (`Configuracion.atras()`). Con la pausa abierta, `volver` (B / Círculo) hace lo mismo que
  `pausa`; con la pausa cerrada no se lee, porque en la partida B es `curar` y no la abre.
- El guardado se escribe en un archivo temporal y después se renombra: un cierre a la mitad no daña la partida.
  Lo hace `Archivo` (`escribir_atomico(ruta, texto)` y `copiar_atomico(desde, hacia)`, con el temporal
  `<destino>.tmp`), que usan la partida, su copia y los ajustes: todo archivo nuevo de `user://` pasa por ella.
  Única excepción: las copias de video de `ReproductorVideo` (`user://video/`), porque `DirAccess.copy_absolute` no
  abre un archivo del paquete del APK (probado en el S50, 25-oct-2026); una copia cortada se vuelve a copiar, porque
  su tamaño no coincide.
- Los ajustes del jugador van en su propio archivo, no en la partida (ver «Ajustes y vibración»).
- El guardado es JSON con número de versión. Al cargar se distinguen partida válida, archivo dañado y partida de
  una versión incompatible, más el caso sin partida guardada (ver «Guardado»).
- Todo lo persistente (puerta abierta, objeto recogido, jefe vencido) se identifica con un ID de texto estable.

## Guardado

`nucleo/guardado.gd` (`class_name Guardado`): funciones estáticas, sin autoload.

| Función | Qué hace |
|---|---|
| `Guardado.guardar(partida: Dictionary, ruta: String) -> Error` | Escribe `{"version": VERSION, "partida": partida}` en `<ruta>.tmp` y lo renombra a `<ruta>`. Devuelve `OK` o el error |
| `Guardado.cargar(ruta := Guardado.RUTA) -> Guardado.Resultado` | Devuelve `estado` y, si es `VALIDA`, `partida` |
| `Guardado.borrar(ruta := Guardado.RUTA) -> Error` | Borra `<ruta>`, `<ruta>.tmp`, `<ruta>.bak` y `<ruta>.bak.tmp` si existen (lo usa «Borrar» de una ranura); no toca los ajustes |
| `Guardado.ruta_ranura(numero) -> String` | `user://partida_<numero>.json`, de 1 a `RANURAS` (4) |
| `Guardado.entero(valor, por_omision) -> int` | Un número leído de una partida como `int` (truncado), aunque el JSON lo haya vuelto `float`; si no es número, `por_omision`. Lo usan `Partida.estado_entero` y `Partida.monto_mochila` |
| `Guardado.migrar(desde, hacia) -> Error` | Renombra `desde` a `hacia` si `desde` existe y `hacia` no; si no, nada (nunca pisa una partida) |
| `Guardado.respaldar(ruta) -> Error` | Copia una partida `VALIDA` a `<ruta>.bak.tmp` y la renombra a `<ruta>.bak`; una que no es válida no se copia y la copia anterior sigue |
| `Guardado.restaurar(ruta) -> Error`, `Guardado.tiene_respaldo(ruta) -> bool` | Copia `<ruta>.bak` a `<ruta>.tmp` y lo renombra a `<ruta>`; solo cuenta una copia `VALIDA` (una cortada o dañada no): sin ella, `ERR_FILE_NOT_FOUND` y `tiene_respaldo` da `false` |

| `Guardado.Estado` | Cuándo |
|---|---|
| `VALIDA` | El archivo es JSON, su `version` es `VERSION` y `partida` tiene todos los campos del esquema con su tipo; los de `NUEVOS` que faltan se rellenan con su valor por omisión |
| `VACIA` | No hay archivo: partida nueva. Un `.tmp` sobrante de un cierre a la mitad no cuenta |
| `DANADA` | No es JSON, no es un objeto, falta `version` o no es número, `partida` no es un objeto, o le falta un campo o tiene otro tipo (un campo de `NUEVOS` con otro tipo también) |
| `INCOMPATIBLE` | `version` es más nueva que `VERSION` (el juego no la sabe leer) o más vieja y sin su función de conversión (hoy no hay ninguna: la 3 es la primera que llegó a la QA). Política de partidas viejas abajo |

- Cuatro ranuras: `user://partida_1.json` a `partida_4.json`. `RUTA` (`user://partida.json`) es la partida de antes de
  las ranuras: el menú la pasa a la ranura 1 al abrir (`migrar`), y `Banco` la usa como centinela. `VERSION` es 3.
- Esquema de la versión 3 (`Guardado.ESQUEMA`), copiado de Hollow Knight y Silksong (lo del jugador como listas de
  ids; lo de cada sala con clave sala + objeto). Un campo nuevo va a `Guardado.NUEVOS` con su valor por
  omisión en forma de JSON (`0.0`, `Array` sin tipo): al cargar, `Guardado.completar` lo rellena en una partida que
  no lo tiene, sin subir `VERSION` (decisión del 14-oct-2026). `VERSION` sube solo cuando cambia la forma de un campo
  que ya existe, y en el mismo cambio se escribe la función que convierte la partida de la versión anterior.
- Política de partidas viejas (28-oct-2026, decisión D5 del plan `nucleo-base-auditoria-codigo`): hoy no existe ningún
  código de conversión. Mientras el juego esté en pruebas, subir `VERSION` deja las partidas de prueba anteriores
  como `INCOMPATIBLE` (no se abren) y el equipo lo avisa a quienes las tengan antes de unir el cambio; por eso un
  campo nuevo va a `NUEVOS` y no sube `VERSION`. Cuando haya una partida que conservar, el primer cambio de forma
  trae una tabla de conversiones por versión en `Guardado.cargar()` y una prueba que cargue una partida de la
  versión vieja y compruebe el resultado.

  | Campo | Tipo | Qué guarda |
  |---|---|---|
  | `banco` | objeto | `{sala, id}`: clave de la sala y id del último banco; `{}` si no se ha descansado. Si no está vacío y le falta `sala` o `id` (texto), la partida es `DANADA` |
  | `vidas_maximas` | número | Vidas máximas |
  | `habilidades`, `jefes`, `amuletos_tenidos`, `amuletos_equipados` | listas | Ids |
  | `monedas` | número | PejeCoins |
  | `mochila` | objeto | Lo perdido al morir, `{sala, x, y, monto}`, o `{}` |
  | `mapas` | lista | Zonas cuyo mapa se tiene |
  | `salas_visitadas`, `salas_mapeadas` | listas | Claves de sala (id, o ruta en una sala de prueba suelta) |
  | `estaciones` | lista | Ids de las estaciones del viaje rápido abiertas. Campo de `NUEVOS` (17-oct-2026): una partida sin él carga con `[]` |
  | `botones_ensenados` | lista | Acciones cuyo botón de la pantalla ya enseñó un pizarrón (`Sala.botones_por_ensenar`). Campo de `NUEVOS` (17-oct-2026): una partida sin él carga con `[]` |
  | `salas` | objeto | Estado por sala: `{clave de la sala: {id del objeto: true o número}}` |
  | `personaje`, `nombre` | texto | Elegidos en Nueva partida; vacíos si no se eligieron |
  | `tiempo_jugado` | número | Segundos con el juego corriendo dentro de una sala |

- Lo que reaparece (enemigos) no se escribe. Sin cifrado ni suma de control.
- Al leer, los números vuelven como `float`: `var vidas: int = partida["vidas_maximas"] as int`.
- Lo que se guarda sale del estado de la partida: `Partida.guardar(ruta: String) -> Error` (sin ruta por omisión:
  quien llama dice el archivo) escribe `Partida.a_diccionario()` y, si salió
  bien, emite `Eventos.partida_guardada`; entrar a una ranura ocupada carga el resultado con
  `Partida.desde_diccionario()` (con las vidas llenas) y lleva al jugador a su banco.

## Ajustes y vibración

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
| `luces_avanzadas` | `false` | Luces 2D de la sala. Valen solo con Recursos en alto: `Ajustes.luces_activas()` (`luces_avanzadas_activas(valor, recursos_bajos)`). Apagadas por omisión desde el 27-oct-2026: en alto, el S50 cae a 6-14 FPS con ellas en La Celda; el halo aditivo de `LuzSala` ya da el efecto |
| `niebla` | `false` | Banda de niebla de la sala |
| `mostrar_fps` | `false` | Contador de FPS arriba al centro (`ContadorFps`) |
| `panel_pruebas` | `false` | Panel de interruptores de la sala y el monitor junto al contador. Vale solo con el modo desarrollador (`Ajustes.desarrollo(clave)`) |
| `ver_hitbox` | `false` | Dibuja las formas de colisión. Vale solo con el modo desarrollador, como `panel_pruebas` |
| `volumen` | 1 | Volumen general (bus Master), de 0 a 1; en 0, silencio. Se aplica al cargar (`Ajustes.aplicar_volumen()`) |
| `volumen_musica` | 1 | Volumen del bus `Musica`, de 0 a 1, como el general. Un archivo sin la clave lo deja en 1 |
| `volumen_efectos` | 1 | Volumen del bus `Efectos`, de 0 a 1, como el general. Un archivo sin la clave lo deja en 1 |
| `brillo` | 1 | De 0,5 a 1,5: multiplica el color del mundo de la sala (debajo de 1 oscurece, encima aclara); el HUD, los controles y los menús no cambian. Se aplica al cargar (`Ajustes.aplicar_brillo()`) |
| `recursos` | `"auto"` | Modo de recursos: `auto` (decide la detección), `bajo` o `alto`. Otro valor vuelve a `auto` (ver «Recursos») |
| `fps` | 60 | 60 o 120; otro valor, o un archivo sin la clave, deja 60. `Ajustes.aplicar_fps()` (al cargar, al tocar FPS o Recursos) pone `Engine.max_fps` con `Ajustes.limite_fps()`: 0 (sin límite; con V-Sync, que en Compatibility siempre está, el refresco de la pantalla) solo con 120, Recursos en alto y una pantalla de `REFRESCO_RAPIDO` (90) Hz o más (`DisplayServer.screen_get_refresh_rate()`, -1 si no se sabe); si no, 60. En un menú (árbol en pausa, o el menú principal) el límite es 60 siempre (`aplicar_fps(true)`): lo pone `ContadorFps`, que mira `get_tree().paused` en cada cuadro porque Godot no tiene señal de cambio de pausa. Sin pantalla (guiones, CI) no toca el límite. La física sigue a 60 ticks |
| `mando` | `{}` | Botones del control que difieren de `project.godot`: `{acción: índice de botón}`. Lo aplica `Mando.aplicar` al cargar |
| `controles` | La distribución inicial | `{"opacidad": n, "botones": {acción: {"ancla": [0|1, 0|1], "desplazamiento": [x, y], "escala": n}}}` (ver «Entrada»). Lo que falta o no es válido se queda en su valor por omisión, botón por botón; escala y opacidad fuera de rango se recortan |

- Audio: `default_bus_layout.tres` (raíz) define los buses `Musica` y `Efectos`, que envían a `Master`;
  `Master` lleva un `AudioEffectHardLimiter` como último efecto, contra el recorte cuando suenan varios a la vez. La música se
  toca en `Ajustes.BUS_MUSICA` y los efectos en `Ajustes.BUS_EFECTOS`; nada suena directo en `Master`. Un volumen o
  un brillo que no es número deja su valor por omisión y uno fuera de rango se recorta.
- Sin pantalla: `Ajustes.sin_ventana()` (verdadero con `--headless`: guiones, validador y CI) es la única
  comprobación de «nadie ve ni oye» del juego; la usan `Ajustes` (el límite de FPS), el arranque, la pausa, la
  Configuración, `Sonido`, `Musica`, `ReproductorVideo` y, en `herramientas/`, el medidor de cámara y la medición. Ningún otro script compara `DisplayServer.get_name()` por su cuenta.
- Brillo: `nucleo/brillo.gd` (`class_name Brillo`), un `CanvasModulate` con `Brillo.color_para(valor)` (gris `v`,
  alfa 1). Lo crea cada `Sala` como hijo, también en los guiones; `Brillo.instancia` es el de la sala viva, o null
  fuera de una sala, donde el brillo no se aplica. No dibuja nada encima de la pantalla: un rectángulo translúcido de
  pantalla completa costaba ~6 ms por cuadro en el Senwa S50 (`docs/pruebas.md`, «Sala de arte»). Una sala no lleva
  otro `CanvasModulate`: solo vale uno por canvas.
- `Ajustes.cargar_una_vez()` lo llaman `Arranque` (así los botones del control y el volumen valen desde el principio),
  la vibración, el jugador, los controles táctiles, la Configuración y el editor de controles; `Ajustes.guardar()`,
  cada cambio de la Configuración (las barras de volumen y brillo, al soltarlas, con el altavoz, al cambiar de panel,
  al cerrar y al pasar la app al fondo) y «Listo» del editor de controles.
- `nucleo/mando.gd` (`class_name Mando`, estático): reasigna los botones del control de `Mando.REASIGNABLES`
  (`saltar`, `atacar`, `curar`, `mapa`, `mapa_rapido`, `inventario`, `pausa`; los ejes no: ni el movimiento ni
  `impulso` (RT) ni `interactuar` (stick arriba), que no tienen botón en `project.godot`). `asignar(acción, botón)`
  intercambia con la acción que ya tenía ese botón: ninguna se queda sin botón; un botón fuera de
  `0..JOY_BUTTON_SDL_MAX-1` se ignora. `aplicar` (al cargar) asigna lo guardado del mismo modo, así un archivo
  editado a mano no deja dos acciones en un botón. `por_omision()` vuelve a los de `project.godot`. El Start con que
  se acaba de asignar un botón no cuenta como Atrás en el menú (`Configuracion.acaba_de_asignar()`).
  `Mando.cambios` sube con cada cambio del InputMap (lo leen las pruebas); quien dibuja botones escucha
  `Eventos.mando_cambiado`. El nombre de cada botón sale de una sola tabla, `Mando.BOTONES`
  (una fila por índice de `JoyButton` 0..14, columnas neutro, Xbox y PlayStation; en los cuatro de la cara, `CARA`, la
  letra y el símbolo): `nombre_de(botón)` da el neutro de Configuración («—» sin botón), `nombre_en(botón, familia)` el
  que dibuja `IconoBoton` y `nombre_de_eje(eje, familia)` el de un gatillo o stick; fuera de la tabla, «Boton n».
  `Mando.familia(nombre, guid)` da `Mando.Dispositivo.PLAYSTATION` si el GUID
  SDL trae el fabricante Sony (`4c05`) o el nombre dice PS3/PS4/PS5, PlayStation, DualShock, DualSense o Sony, y
  `Mando.Dispositivo.XBOX` en cualquier otro caso. Los nombres reales que dan Windows y Android no se han medido. En una build de
  depuración, `UltimaEntrada` imprime `CONTROL <n> nombre=... guid=... familia=...` por cada control conectado.
- `nucleo/vibracion.gd` (`class_name Vibracion`, `Node`), que crea cada sala con el nombre `Vibracion`: escucha el
  bus y llama a `Input.vibrate_handheld(ms, fuerza)` con un patrón por evento (propiedades exportadas):

| Evento | Señal | Duración | Fuerza (0 a 1) |
|---|---|---|---|
| Pegarle a algo (ataque, pogo, bola, onda) | `enemigo_golpeado` y `objeto_golpeado` | 25 ms | 0,35 |
| Parar un ataque (parry) | `parry` | 45 ms | 0,6 |
| Recibir daño | `jugador_danado` | 60 ms | 0,8 |
| Curarse | `jugador_curado` | 40 ms | 0,45 |
| Descansar | `descanso_en_banco` | 70 ms | 0,5 |
| Aterrizaje duro y aterrizaje de la picada | `jugador_aterrizo` con `duro` o `picada` (el aterrizaje común no vibra) | 80 ms | 0,9 |

- Entre una vibración y la siguiente pasan al menos `ticks_entre_vibraciones` (4); recibir daño y el parry no esperan (el parry llega en el mismo tick que el golpe a su dueño). Nada más
  vibra: ni moverse, ni saltar, ni los menús. Cuenta en `pedidas` (con el ajuste encendido o no) y `enviadas`, y la
  última en `ultima`: los guiones las leen con `valor Vibracion`.
- Efectos: `nucleo/sonido.gd` (`class_name Sonido`, `Node`, en pausa también), que crea `Arranque` (`Arranque.sonido`):
  vive fuera de las salas, así nada se corta al cruzar una puerta o salir al menú. Una conexión por señal en su
  `_ready` (`Eventos.x.connect(tocar.bind(&"evento").unbind(n))`, `classes/class_callable.rst:520-530`):
  `jugador_salto` (salto), `enemigo_golpeado` y `objeto_golpeado` (golpe), `muro_roto`, `porton_abierto` (porton),
  `jugador_danado` (dano), `parry`, `jugador_curado` (curar), `descanso_en_banco` (banco), `jugador_paso` (paso),
  `jugador_impulso` (impulso) y `jugador_aterrizo` (picada si `picada`; si no, aterrizaje cuando es duro o cae a
  `velocidad_aterrizaje_min` (200 px/s) o más: bajar un escalón no suena). Toca, en el bus
  `Efectos`, el efecto de su `FichaSonidos` (`nucleo/ficha_sonidos.gd`: un `AudioStream` por evento). La del juego
  es `Sonido.FICHA`, `nucleo/sonidos/sonidos_jugador.tres`, con los WAV de `nucleo/sonidos/jugador/`; `salto`
  está vacío por elección (26-oct-2026) y `parry`, mudo por ahora (decisión abierta en `ESTADO.md`). La variación es dato del efecto: paso,
  aterrizaje y golpe son un `AudioStreamRandomizer` de un WAV con `random_pitch` 1,06
  (`classes/class_audiostreamrandomizer.rst:22`, `:155`); los demás, el WAV directo. Un evento sin archivo en la
  ficha no suena; uno que no es campo de la ficha hace que `tocar()` avise con `push_warning`. Un evento nuevo lleva
  su campo en `FichaSonidos` y su línea de conexión. Un solo `AudioStreamPlayer` (`Voces`) con un
  `AudioStreamPolyphonic` de `voces` (8): un efecto nuevo nunca corta a uno que suena; con todas ocupadas se
  descarta el nuevo (`descartados`, `classes/class_audiostreamplaybackpolyphonic.rst:94`). `play_stream` lleva el
  bus `Efectos` explícito (por omisión sería `Master`, `:86`). El mismo evento no suena dos veces en menos de
  `ticks_entre_iguales` (3), salvo los de `sin_espera` (daño y parry). Sin pantalla (`mudo`) cuenta pero no toca; al
  salir del árbol calla lo que suena. `pedidos`, `tocados`, `ultimo`, `descartados` y `mudo` son públicas; `tocar()`
  devuelve el id de la voz y `sonando(voz)` dice si sigue.
- Música: `nucleo/musica.gd` (`class_name Musica`, `Node`, en pausa también), que crea `Arranque` (`Arranque.musica`;
  un autoload siempre está cargado, `tutorials/scripting/singletons_autoload.rst:31`, así que nadie comprueba `null`),
  como el `AudioManager` de Hollow Knight: un tema a la vez en el bus `Musica`, con dos `AudioStreamPlayer` para el
  fundido cruzado y un volumen de región. Un solo punto de entrada, `poner(tema, volumen_db = DB_NORMAL,
  segundos = FUNDIDO)`: guarda el pedido y lo aplica en el tick de física siguiente; si llegan varios antes, gana el
  último por campo (un pedido con `tema` `null` no borra el tema que otro dejó pendiente; el volumen lo reemplaza
  cada uno). `tema` `null` no toca el tema; `Musica.SILENCIO` (`nucleo/sonidos/silencio.tres`, un `AudioStreamWAV`
  vacío que nunca se reproduce) lo funde a nada: el silencio es un tema, como el cue de Hollow Knight, y no `null`.
  Pedir el tema que ya suena no hace nada; pedir uno que todavía se está yendo (A, B y otra vez A dentro del fundido)
  lo sube desde el volumen que lleva, sin reasignarlo ni empezarlo de nuevo (asignar `stream` corta lo que suena,
  `classes/class_audiostreamplayer.rst:301`). Cada reproductor tiene un solo tween, en ticks de física
  (`classes/class_tween.rst:274`), sobre su volumen final (el del tema por el de región, en un solo valor): va en línea
  recta del que tiene al que le toca, así nunca suena más fuerte que el mayor de los dos (con dos tweens multiplicados,
  callar un tema a -60 dB lo subía a -12 dB, `docs/errores/2026-10-27-musica-sube-al-callar.md`). Si cambia el tema,
  todos los reproductores usan los segundos del tema; si no, solo el que suena va al volumen nuevo, con los segundos
  del volumen, y el que se estaba yendo sigue a su paso. Un tema nuevo va al reproductor más callado; un tercer tema dentro
  de un fundido corta el que se estaba yendo. Constantes: `TEMA_MENU` (`nucleo/sonidos/musica_menu.ogg`, Ogg con
  `loop` en su `.import`), `SILENCIO`, `DB_NORMAL` (0), `DB_SILENCIO` (-60, inaudible,
  `tutorials/audio/audio_buses.rst:40-42`), `FUNDIDO` (2 s, al entrar a una sala) y `FUNDIDO_CORTO` (1 s: menú,
  cinemática, zona de pruebas y panel de audio). `se_oye()`: hay tema, no es `SILENCIO` y el volumen está sobre
  `DB_SILENCIO`, contando el pedido pendiente. `probar(sonar)` es del panel de audio: si al abrirlo no se oye nada pone
  `TEMA_MENU` y al cerrarlo devuelve lo que había; si algo sonaba no lo toca. Sin pantalla (`mudo`) cuenta pero no
  reproduce; al salir del árbol para sus reproductores. `actual`, `volumen_db` (el volumen de región al que va),
  `arranques` (veces que un tema empezó desde el principio) y `mudo` son públicas. Quién pide: cada `Sala` en su
  `_ready` (`tema_musica` y `volumen_musica_db`, ver «Sala»), una `RegionMusica` (ver «Componentes»), el menú
  (`TEMA_MENU`), la cinemática (`SILENCIO`: el video trae su audio), la zona de pruebas (`SILENCIO`: sus salas dejan
  el tema vacío) y el panel de audio (`probar`). Prueba: `nucleo/musica`.
- En Android, `vibrate_handheld` necesita el permiso `VIBRATE` en el preset de exportación (presets de Android); sin él no vibra. Un
  teléfono sin control de fuerza solo respeta la duración.

## Estado de la partida

Autoload `Partida` (`nucleo/partida.gd`): lo que sobrevive al cambio de sala. Una sala nueva no reinicia nada.

| Propiedad o función | Qué es |
|---|---|
| `vidas`, `vidas_maximas` | Vidas actuales y máximas (4 al empezar). `Jugador.vidas` lee y escribe `Partida.vidas`. Cada cambio emite `vidas_cambiadas` |
| `banco`, `sala` | Id del último banco donde se descansó y la clave de su sala (`Sala.clave()`); vacíos si no se ha descansado |
| `jefes`, `amuletos_tenidos`, `amuletos_equipados`, `mochila`, `mapas`, `personaje`, `nombre`, `tiempo_jugado` | Los campos del guardado del mismo nombre |
| `monedas` | PejeCoins; cada cambio emite `monedas_cambiadas` |
| `gastar_monedas(cantidad)` | Cobra (la `Tienda`): devuelve `false` y no cambia nada si no alcanzan o si `cantidad` es negativa |
| `estaciones`, `abrir_estacion(id)`, `estacion_abierta(id)` | Ids de las estaciones del viaje rápido ya pagadas. `abrir_estacion` no repite un id ni guarda: guarda la `Estacion` |
| `botones_ensenados`, `ensenar_boton(accion)` | Acciones cuyo botón de la pantalla ya enseñó un `AvisoAccion`. `ensenar_boton` no repite ni guarda |
| `dejar_mochila(sala, punto)`, `monto_mochila()`, `punto_de_mochila()`, `recuperar_mochila()`, `perder_mochila()` | Lo perdido al morir, como el capullo de Silksong. El jugador, al morir y antes de emitir `jugador_muerto`, llama `dejar_mochila` con la clave de su sala y su `ultimo_punto_seguro()`, así el autoguardado de la muerte ya la lleva: con PejeCoins, `mochila = {sala, x, y, monto}` (coordenadas de la sala) y `monedas` en 0, y una mochila anterior se pierde; sin PejeCoins no cambia nada. `monto_mochila()` da el monto como número aunque el JSON lo haya vuelto `float`; `punto_de_mochila()`, su `x, y` como `Vector2` (un eje que no es número, 0), para la sala y el mapa. `recuperar_mochila()` suma el monto, vacía la mochila, emite `mochila_recuperada` y autoguarda. `perder_mochila()` (perder el reto) la vacía sin devolver nada y autoguarda |
| `salas_visitadas`, `visitar(clave)` | Claves de las salas visitadas; la sala se anota al entrar |
| `salas_mapeadas` | Al oír `descanso_en_banco`, con la habilidad `pluma_mapa`, pasan aquí las visitadas cuya zona está en `mapas` (como la Pluma de Hollow Knight y Silksong) |
| `salas`, `estado_de(sala, objeto)`, `estado_entero(sala, objeto, por_omision)`, `marcar(sala, objeto, valor := true)` | Estado por sala. `estado_de` da `null` si no hay nada; `estado_entero` da un número aunque el JSON lo haya vuelto `float`, o `por_omision`. Lo usan `SueloFragil`, `MuroRompible`, `Palanca`, `Porton`, `Coleccionable`, `Tienda` (lo vendido), `AvisoAccion` (hecho), `EntregaRecompensas` (lo entregado), `Npc` (su etapa, un número) y `RetoPreguntas` (`<id>`, `<id>_indice` y `<id>_aciertos`) con su `id` y la clave de su sala (`Sala.clave_de(nodo)`) |
| `total_coleccionables()`, `contar_coleccionables(salas)` | Marcas de todas las salas cuyo id empieza con `PREFIJO_COLECCIONABLE` (`coleccionable`); la segunda cuenta un estado de salas leído de un archivo (la ficha de una ranura) e ignora lo que no es diccionario |
| `obtener_habilidad(id)`, `obtener_amuleto(id)`, `obtener_mapa(zona)` | Suman y emiten `habilidad_obtenida`, `amuleto_obtenido` o `mapa_obtenido` (si ya estaba, nada). Nada escribe `mapas` directo: el `ObjetoMapa` y `dar_recompensa` pasan por `obtener_mapa` |
| `MAX_EQUIPADOS`, `puede_equipar(id)`, `equipar(id)`, `desequipar(id)`, `esta_equipado(id)` | Poner un amuleto exige tenerlo, que no esté puesto y que haya lugar (`MAX_EQUIPADOS`, 3, provisional hasta que haya carga). `equipar` y `desequipar` devuelven `false` si no pueden y, si cambian algo, autoguardan. Dónde se puede (sentado en un banco) lo decide la pantalla de los amuletos: `Partida` no conoce al jugador. Nada escribe `amuletos_equipados` directo |
| `dar_recompensa(recompensa)` | Entrega una `Recompensa` (PejeCoins, vida máxima, amuleto, habilidad o el mapa de una zona, con `obtener_mapa`) |
| `ruta_guardado` | Archivo del banco y del autoguardado: `RUTA_PRUEBAS` (`user://prueba_partida.json`) por omisión, para que guiones y zona de pruebas no pisen la partida real; entrar a una ranura lo cambia a la ruta de esa ranura |
| `autoguardar()`, `autoguardados` | Guarda en `ruta_guardado` sin tocar el banco y emite `partida_guardada`. Lo llaman los avisos `habilidad_obtenida`, `amuleto_obtenido`, `mapa_obtenido`, `coleccionable_obtenido`, `jefe_vencido` (que además anota el jefe) y `jugador_muerto`; «Salir al menú» de la pausa; la entrega de recompensas; poner o quitar un amuleto; terminar contando una conversación de un `Npc`; cada respuesta de un `RetoPreguntas`; recuperar o perder la mochila; comprar en una `Tienda`; abrir una `Estacion` (también la gratis); y `NOTIFICATION_APPLICATION_PAUSED` o `NOTIFICATION_APPLICATION_FOCUS_OUT` con una sala abierta. `autoguardados` los cuenta. Hay dos formas de autoguardar: por el bus, para lo que tiene evento (`Partida` escucha en `_ready` los avisos de arriba), y por llamada directa (`Partida.autoguardar()`, o `guardar(ruta)` en el banco), para lo que `Partida` no escucha (poner o quitar un amuleto, la mochila, la tienda, una estación); un cambio nuevo usa la que le corresponda. Lo demás se escribe en el siguiente guardado: las marcas de `MuroRompible`, `Palanca`, `Porton`, `SueloFragil`, `AvisoAccion` y `MonedasSueltas` (con sus PejeCoins), `salas_visitadas` y `botones_ensenados` |
| `habilidades`, `tiene(id)` | `Array[StringName]` con las habilidades obtenidas, y si una está. Los ids están en `nucleo/habilidades.gd` (`class_name Habilidades`, una constante por habilidad y `TODAS`); el código usa las constantes, no el texto. `obtener_habilidad` con un id que no está en `TODAS` imprime un `ERROR:` y no lo suma. El validador revisa que cada habilidad de un `ObjetoHabilidad`, de una `Recompensa` (de una entrega, un reto o una ficha de diálogo) y de `habilidades_de_prueba` esté en `TODAS`. Los ids no se renombran: los guarda la partida. Amuletos y jefes llevarán su id en su ficha cuando exista el primero |
| `enemigos_vencidos`, `vencer(clave)`, `fue_vencido(clave)` | Claves (`"<clave de la sala>#<id>"`) de los enemigos fuertes vencidos desde el último descanso o la última muerte. Se borra al oír `descanso_en_banco` o `jugador_muerto` y en `reiniciar()`; no se guarda |
| `inspiracion`, `ganar_inspiracion(n)` | Recurso de curación (0 a `INSPIRACION_MAXIMA`, 99); no se guarda, se reinicia con la partida y se vacía al oír `jugador_muerto`. Cada cambio emite `inspiracion_cambiada` |
| `reiniciar()` | Partida nueva: la llaman una ranura vacía y la zona de pruebas |
| `llenar_vidas()` | Vidas al máximo: al reaparecer después de morir |
| `a_diccionario()` / `desde_diccionario(partida)` | Hacia y desde los campos de `Guardado.ESQUEMA` y `Guardado.NUEVOS`. Al cargar, lo que no se guarda empieza de cero: Inspiración 0 y sin enemigos vencidos |

## Autoloads

| Nombre | Script | Qué hace |
|---|---|---|
| `Eventos` | `nucleo/eventos.gd` | Bus de eventos: solo declara las señales de «Bus de eventos». Va antes de `Arranque` para existir cuando arranca todo lo demás |
| `Partida` | `nucleo/partida.gd` | Estado de la partida (ver «Estado de la partida»). Va después de `Eventos` y antes de `Arranque` |
| `Arranque` | `nucleo/arranque.gd` | Pone el color de borrado en negro, carga los ajustes y, con pantalla, aplica el rango de la vista al arrancar y, diferido al final del cuadro, al cambiar el tamaño de la ventana (`proporcion_minima` y `proporcion_maxima`, exportadas). Imprime `ARRANQUE depuracion=<bool> puerto=<bool>` y, solo en un build de depuración y si el archivo viaja en el paquete, carga con `load()` el puerto de depuración como hijo suyo (`PuertoDepuracion`). También crea `Sonido` y `Musica` (ver «Ajustes y vibración»; los guarda con su tipo en `sonido` y `musica`) y `UltimaEntrada` (ver «Menú», párrafo «Tamaños»), con o sin pantalla |

- Un autoload nuevo se agrega a esta tabla en el mismo cambio.
- Nada de `herramientas/` es autoload ni se carga con `preload`: el juego debe arrancar sin esa carpeta.
- Lo que el núcleo carga de otro bloque o de `herramientas/` pasa por `Cargar.si_existe(ruta)` (`nucleo/cargar.gd`,
  estático): el recurso, o `null` si no existe; quien lo llama lo convierte con `as`. Si solo hay que saber si existe,
  `ResourceLoader.exists`.

## Recursos

`nucleo/recursos.gd` (`class_name Recursos`, estático). `Recursos.bajos()` dice si rige el modo bajo: el ajuste
`recursos`, o en `auto` la detección (`es_debil()`: un build de 32 bits, `OS.has_feature("32")`; menos de
`UMBRAL_MEMORIA`, 3 GB, de memoria; o un teléfono que Android marca de poca memoria,
`ActivityManager.isLowRamDevice()` por el plugin `AndroidRuntime`). La memoria sale de `OS.get_memory_info()["physical"]`;
en Android, donde Godot da -1, de `MemTotal` en `/proc/meminfo` (`OS.execute("cat", ...)`, porque `FileAccess` no
puede abrirlo), leída una vez. Las piezas lo leen al entrar a la sala: un cambio en
Configuración vale desde la sala siguiente. Elegir alto en un teléfono débil se permite y la Configuración avisa.

| Pieza | En modo bajo | En alto |
|---|---|---|
| `nucleo/prescindible.gd` (`class_name Prescindible`, `Node`), hijo de un adorno (emisor, capa lejana, cortable de más) | Quita a su padre al entrar | Nada |
| `nucleo/planta.gd` (`class_name Planta`, `Node2D`) | Quieta | Se mece (`grados`, `periodo`, `desfase`) con un tiempo propio en `_process`: quieta en la pausa y en el congelado común |
| `nucleo/niebla.gd` (`class_name Niebla`, `Node2D`) | Quieta | Avanza `velocidad` px/s y vuelve tras `recorrido`, con tiempo propio: quieta en la pausa y en el congelado común. En los dos modos solo se ve con el ajuste `niebla` (apagado por omisión) y lo obedece al momento; una franja con `nucleo/arte/niebla_banda.gdshader` se desvanece arriba y abajo. La pieza es `nucleo/piezas/niebla.tscn`: raíz `Parallax2D` (`repeat_size.x` 1776, `repeat_times` 2), hijo `Deriva` con este script (`recorrido` 1776) y nieto `Banda` con el ruido horneado en `nucleo/arte/niebla_ruido.png` (592 × 160 a escala 3: 1776 ≥ 1760, sin costura; lo escribe `hornear_niebla()` de `herramientas/generar_efectos.gd`, Lossless sin mipmaps). Una sala la instancia y solo toca la raíz: altura con `scroll_offset.y` (el desplazamiento no la pisa, `classes/class_parallax2d.rst:221-223`), tinte y alfa con `modulate`, capa con `z_index`; nada de un `NoiseTexture2D` por sala. Con `repeat_times` 1 se abría un hueco del ancho del avance (`docs/errores/2026-10-27-hueco-niebla.md`). No usa `Parallax2D.autoscroll`: no se detendría con el congelado ni con Recursos bajo |
| `nucleo/luz_sala.gd` (`class_name LuzSala`, `Node2D`) | Solo el halo aditivo chico | El halo y, con el ajuste `luces_avanzadas`, una `PointLight2D` creada en código (al momento, por `ajuste_grafico_cambiado`). Tipos `FIJA`, `PARPADEO`, `PULSO` y `DESTELLO` (`destellar()`), con tiempo propio; `intensidad` (0 a 1) es su fuerza máxima; `encendida` (opcional) es la imagen de la pieza encendida, que la sigue. El halo va sin sombreado: la oscuridad de la sala no lo apaga. Su lado es `2 × radio × halo_radio` (`halo_radio`, por omisión `HALO_RADIO` 0,55, se cambia por pieza); `corte_arriba` (px sobre la luz, negativo sin corte) lo recorta con `region_rect` a esa altura, para que la luz de un tubo no se vea en el piso de arriba ni en un nicho tapado. La `PointLight2D` de las luces avanzadas no se corta: se acepta la fuga porque están apagadas por omisión. `LuzSala.caja_halo(radio, halo_radio, corte_arriba)` (estática) y `area_halo()` dan lo que cubre el halo sin correr `_ready`, para contarlo entre las capas translúcidas |
| `nucleo/colgante.gd` (`class_name Colgante`, `Node2D`) | Quieto | Cable o cadena que se mece como resorte desde su origen, en `_physics_process`; si es `empujable`, el jugador lo empuja al pasar debajo |
| `nucleo/emisor_rafaga.gd` (`class_name EmisorRafaga`, `CPUParticles2D`) | Igual (si no lleva `Prescindible`) | Ráfagas de `amount` partículas cada `intervalo_min` a `intervalo_max` s, con tiempo propio; destella su `destello` (`LuzSala`) y emite `disparado` en cada ráfaga |
| `nucleo/fondo_tapado.gd` (`class_name FondoTapado`, `Control`) | Igual | Sus hijos (las capas `Parallax2D` de atrás) se recortan en `fin_pared` y se ocultan mientras la vista cae entera dentro de la pared opaca. Se coloca en (0, 0). `lado` (`IZQUIERDA` por omisión) dice de qué lado de lo visible está la pared: con `DERECHA`, `fin_pared` es donde empieza la pared y se recorta a su izquierda (el validador falla si empieza en el borde izquierdo de la sala o antes) |

- Cada pieza se agrega a su grupo (`LuzSala.GRUPO`, `Colgante.GRUPO`, `Niebla.GRUPO`, `FondoTapado.GRUPO`): el panel
  de pruebas (`nucleo/panel_pruebas.gd`, `class_name PanelPruebas`, lo crea cada sala) las encuentra sin código de la
  sala, y como «Partículas» toma todo `CPUParticles2D` de la sala. Solo con `Ajustes.desarrollo(PANEL_PRUEBAS)`: una
  pestaña «‹ Pruebas» a media altura a la derecha que abre una tarjeta con «Ocultar ›» y un botón por grupo presente;
  apagar un grupo oculta sus nodos y les quita el proceso, y encenderlo los deja como estaban (una niebla con su
  ajuste apagado sigue oculta). `VerHitbox` (`nucleo/ver_hitbox.gd`, también de cada sala,
  con `Ajustes.desarrollo(VER_HITBOX)`) dibuja encima cada forma de colisión: rojo lo que daña, verde el escenario, azul
  los cuerpos y amarillo las demás áreas. La oscuridad de la sala es `Sala.oscuridad` (ver «Sala»).

- Materiales comunes: uno de cada tipo en todo el juego, como recurso compartido (`tutorials/scripting/resources.rst:30-32`;
  las piezas con el mismo material se dibujan juntas, `tutorials/performance/gpu_optimization.rst:44-52`).
  `nucleo/arte/sin_luz.tres` (`CanvasItemMaterial` con `LIGHT_MODE_UNSHADED`: la oscuridad de la sala no lo apaga) y
  `nucleo/arte/aditivo.tres` (mezcla aditiva, sin sombreado: halos, destellos y partículas que suman luz). Desde el
  código se piden con `EfectoCuadros.material_sin_luz()` y `LuzSala.material_aditivo()`, que devuelven la constante
  cargada con `preload` (las constantes `_SIN_LUZ` y `_ADITIVO` son privadas: una sola entrada por material); una
  escena los nombra como `ext_resource` con su uid, nunca como un `sub_resource` propio ni con `Material.new()`.

- Presupuesto por sala (lo revisa el validador en toda escena cuya raíz es una `Sala`): a lo más 16 emisores de
  partículas con 200 partículas entre todos (subido el 25-oct-2026 desde 3 y 60: en La Celda, medido en el S50 el 25-oct-2026, 13 emisores
  y ~100 partículas costaron menos de 1 FPS en el S50, medido A/B quitándolas), 30 plantas, ninguna luz 2D en la
  escena (las de `LuzSala` se crean en código solo con su ajuste) y a lo más 2 capas translúcidas
  grandes: un `Sprite2D`, `TextureRect`, `ColorRect`, `NinePatchRect` o `Polygon2D` visible con alfa efectivo menor
  que 1 (el de su color en `ColorRect` y `Polygon2D`, por su `self_modulate` y el `modulate` de él y de sus padres;
  dentro de un `CanvasLayer` oculto no cuenta) que cubre al menos un
  cuarto de 1280×720 con la escala de sus padres y sus anclas. Los halos de `LuzSala` (sumados, aclaran) cuentan aparte: cada uno cubre `area_halo()` (con `LuzSala.caja_halo()`, sin correr `_ready`) por la escala de sus padres, y el que cubre al menos lo de una capa grande se suma a las capas; si las capas solas pasan el máximo es un fallo, y si lo pasan solo con los halos, un aviso del validador (abajo, «Avisos del validador»), porque la cuenta es por sala y no por pantalla. Nunca se marca como prescindible un aviso de peligro ni algo cuya colisión importe.
  Excepción: la sala de arte (`herramientas/salas/sala_arte.gd`) arma su decoración en `_ready` y pasa del
  presupuesto a propósito (hasta 12 emisores y ~500 partículas en alto): es la sala para medir el rendimiento.
- `herramientas/salas/sala_recursos.tscn` llena el presupuesto (2 nieblas, 30 plantas, 3 emisores, 6 cortables;
  prescindibles una niebla, dos emisores y cuatro cortables) para medir los FPS en bajo y en alto.
- Un `Fondo` opaco (con el `FondoExtendido` que crea, ver «Fondo extendido») cuesta en el S50: medido el
  13-oct-2026, dos salas de pruebas bajaban de 60 a ~50 FPS con él (detalle en `docs/pruebas.md`, «Medir antes de
  optimizar»; no se separó cuánto es de cada rectángulo). Una sala cuyo fondo puede ser negro va sin `Fondo`; el
  núcleo no tiene otra forma de dar un color de fondo. El validador no lo revisa.
- Tamaño del arte (decisión del 14-oct-2026): se pinta al tamaño en que se ve en la vista de 1280×720 (1x; el
  personaje mide 160 px) y no se encoge en la escena. Ninguna imagen pasa de 2048 px por lado.
- Importación del arte del mundo (`contenido/` y `herramientas/salas/arte/`; lo revisa el validador leyendo cada
  `.import`): Mipmaps > Generate encendido, porque la vista se encoge en las pantallas más chicas
  (`tutorials/assets_pipeline/importing_images.rst:373-393`; en la sala de arte, medido el 13-oct-2026 en el S50,
  34,1 → 34,3 FPS y el APK +1,8 MB). Compresión Lossless por omisión; VRAM Compressed solo en una imagen sin
  transparencia, como los fondos opacos grandes (`importing_images.rst:185-189`: en 2D deja artefactos). Excepción
  decidida el 13-oct-2026: `fondo1`, `fondo2`, `lejana1` y `suelo` de la sala de arte, con transparencia, van en
  VRAM (`ALFA_EN_VRAM` en `herramientas/validar.gd`). El HUD y los menús van sin mipmaps.
- Receta del arte de una sala (La Celda, 25-oct-2026): la imagen entra ya procesada, en
  `contenido/salas/<zona>/arte/`, en snake_case. Las capas de fondo se exportan reducidas (la capa media a ½, las
  lejanas a ¼, el profundo a ⅛) y el frente a ½, con la escala compensada en la escena para que midan lo mismo en
  pantalla: en el S50 no subió los FPS (medido en La Celda el 25-oct-2026) pero baja la memoria de video y el APK. Una capa con
  mucha transparencia va como malla (`Polygon2D` con la textura, solo donde no es transparente, como «Convertir a
  Polygon2D» del editor), no como `Sprite2D`. La imagen encendida de una luz se recorta a su zona usada. Las capas
  que una pared opaca tapa van dentro de un `FondoTapado`. Una tira que se repite con `region` lleva unas filas
  transparentes al pie, o el filtro lineal pinta una línea en su orilla de arriba. Las piezas encendidas y las siluetas
  del frente van con un material sin sombreado (`LIGHT_MODE_UNSHADED`), para que la oscuridad no las apague. Lo que
  se optimiza se mide combinado en el S50: en La Celda (medido en el S50, 25-oct-2026), las nueve optimizaciones solas casi no se notaban y juntas
  llevaron la sala de 19 a 52,6 FPS. Qué limita los FPS de una sala no se supone: se mide A/B en el teléfono, con y
  sin la pieza sospechosa (herramienta en `docs/pruebas.md`, «Medición de rendimiento»). Medido en el S50 en bajo
  (26-oct-2026): las PejeCoins sueltas redibujadas en vector cada cuadro bajaban las salas con PejeCoins de 59,7 a
  37-40 FPS, la capa lejana translúcida costaba unos 7-10 FPS donde se veía, y ni los draw calls ni el tamaño de las
  texturas decidían los FPS. En el mundo no se dibuja con `_draw` lo que se repite: se hornea a PNG
  (`herramientas/generar_efectos.gd`), y ningún `queue_redraw()` en `_process` va sin una guarda que lo haga solo
  cuando algo cambió (lo avisa el validador). Una capa lejana con mucha transparencia lleva `Prescindible` y
  `repeat_times = 1`.
- Filtro por omisión del lienzo: lineal con mipmaps (`rendering/textures/canvas_textures/default_texture_filter`
  = 2 en `project.godot`).
- Hojas de efectos del núcleo (`nucleo/arte/efecto_*.png`: curar, curar al frente, bola y parry): van sin mipmaps y fuera de
  `CARPETAS_ARTE_MUNDO` a propósito (28-oct-2026). Suman 8,9 MB de RGBA sin comprimir (cálculo de sus medidas) y los mipmaps
  agregarían unos 3 MB; son efectos de pantalla, no arte de sala. No se cambia su importación.
- Atlas del jugador (21-oct-2026; rehecho el 24-oct con el ataque vertical a su escala y la muerte apoyada en el
  suelo): `nucleo/arte/jugador_hombre/atlas_0.png`, una página de 2020 × 668 con los 61
  cuadros del hombre a 1x y 8 px entre ellos, Lossless y «Fix Alpha Border» encendido (las hojas de origen llegaron
  en JPG, `importing_images.rst:423-433`). Cada cuadro es un `AtlasTexture` con `region` justa, `filter_clip` y el
  lienzo común de 316 × 182 en `margin` (`margin.position` lo coloca; `margin.size` completa el lienzo, así todos
  miden lo mismo, `classes/class_atlastexture.rst:102`). El `SpriteFrames` (`jugador_hombre.tres`) lo escribe
  `herramientas/generar_sprites.tscn` con `guardar_con_uids` de `herramientas/validar.gd` (fuera del editor
  `ResourceSaver` no escribe los uid; ver «Sala», uid), tras reimportar el atlas (comando en su cabecera), y conserva
  los metadatos del anterior que el atlas no trae (`pasos`: por animación, los cuadros en que un pie toca el suelo). La
  página y el JSON que lee `generar_sprites` salen de un script que vive fuera del repo con las hojas originales, que
  no entran: desde un clon no se rehace el atlas, y un cambio en las animaciones del jugador pasa por el responsable
  del arte (decisión del 28-oct-2026). Va sin
  mipmaps y fuera de `CARPETAS_ARTE_MUNDO`. Medido en el S50 (APK de
  desarrollo, 60 s por escena tras 5 s): sin mipmaps, 59,6 FPS de media en la sala de recursos, en la zona de
  pruebas y en la de movimiento (mínimo 58-59), con 146,7, 141,9 y 146,0 MB de PSS; con mipmaps, las mismas medias y
  mínimos, con 146,9, 141,2 y 147,0 MB, y el APK +0,27 MB. Antes del cambio (18-oct-2026), recursos y zona daban 59,6
  con 144,0 y 142,1 MB.

## Bus de eventos

Un bloque avisa a otro solo emitiendo una señal de `Eventos` (`Eventos.jugador_muerto.emit()`); quien escucha se
conecta a ella (`Eventos.jugador_muerto.connect(...)`). Ningún bloque se conecta directamente a las señales ni
llama a los métodos de otro bloque. Una señal nueva se agrega a `nucleo/eventos.gd` y a esta tabla en el mismo
cambio.

| Señal | Argumentos | Quién la emite |
|---|---|---|
| `jugador_danado` | `vidas: int` (las que le quedan) | El jugador, al recibir daño |
| `jugador_muerto` | — | El jugador, al quedarse sin vidas |
| `jugador_curado` | `vidas: int` (las que tiene ya curado) | El jugador, al terminar una curación |
| `vidas_cambiadas` | `vidas: int`, `maximas: int` | `Partida`, cada vez que cambian las vidas o las vidas máximas (daño, curación, reaparición, banco) |
| `inspiracion_cambiada` | `inspiracion: int`, `maxima: int` | `Partida`, cada vez que cambia la Inspiración |
| `descanso_en_banco` | `banco: StringName` (id del banco) | El banco, al descansar |
| `partida_guardada` | — | `Partida.guardar(ruta)` (banco y autoguardado), cuando el guardado salió bien |
| `enemigo_golpeado` | `enemigo: Node` | Un `Golpeable` con `es_enemigo`, al recibir un golpe del ataque, la bola o la onda (solo el ataque llena la Inspiración) |
| `objeto_golpeado` | `objeto: Node` | Un `Golpeable` sin `es_enemigo` (muro rompible, palanca), al recibir un golpe, y el jugador al desviar un disparo (`objeto` es el disparo); no da Inspiración. Lo oyen `Sonido` y `Vibracion` como un golpe |
| `muro_roto` | `muro: StringName` (su id) | El `MuroRompible`, al romperse. Lo oye `Sonido` |
| `porton_abierto` | `porton: StringName` (su id) | El `Porton`, al empezar a abrirse. Lo oye `Sonido` |
| `enemigo_vencido` | `enemigo: StringName` (id de su ficha) | El enemigo, al quedarse sin vida Gancho sin oyente en el juego: solo lo oyen pruebas y guiones; no se borra (28-oct-2026). Un botín por ficha lo escucharía o lo entregaría `Enemigo` (plan `nucleo-base-auditoria-codigo`, fase 4). |
| `parry` | — | El jugador, al parar un `AtaqueEnemigo` |
| `habilidad_obtenida` | `habilidad: StringName` | `Partida.obtener_habilidad()` (el objeto de habilidad, una recompensa; en el juego, los jefes). Autoguarda |
| `amuleto_obtenido` | `amuleto: StringName` | `Partida.obtener_amuleto()`. Autoguarda |
| `mapa_obtenido` | `zona: String` (la del mapa) | `Partida.obtener_mapa()` (el `ObjetoMapa`, una recompensa). Autoguarda |
| `coleccionable_obtenido` | `coleccionable: StringName` (su id) | El `Coleccionable` al tomarlo. Autoguarda |
| `monedas_cambiadas` | `monedas: int` | `Partida`, cada vez que cambian las PejeCoins |
| `jefe_vencido` | `jefe: StringName` (id del jefe) | El jefe. `Partida` lo anota en `jefes` y autoguarda Tiene oyente (`Partida`) y ningún emisor en el juego hasta que exista el primer jefe: hoy solo lo emite una prueba (28-oct-2026). |
| `cambio_de_sala` | `sala: String` (`Sala.clave()`: id, o ruta en una sala de prueba suelta), `puerta: StringName` (por la que llegó) | La sala, ya con el jugador puesto, cuando se llega por una puerta Gancho sin oyente en el juego: solo lo oyen pruebas y guiones; no se borra (28-oct-2026). Solo sale al llegar por una puerta, no por estación, banco ni muerte. |
| `jugador_aterrizo` | `velocidad: float` (px/s de caída del último tick en el aire), `duro: bool` (empezó un aterrizaje duro), `picada: bool` (aterrizó de la picada) | El jugador vivo, una vez en cada aterrizaje con caída (aparecer en una sala no cuenta); el de la picada, antes de la onda, para que su vibración gane a la del golpe. `Vibracion` vibra solo con `duro` o `picada`; `Sonido` toca picada, o aterrizaje si es duro o cae a `velocidad_aterrizaje_min` o más |
| `jugador_salto` | — | El jugador al despegar en cada salto: en el suelo, coyote, en la pared y doble salto. Lo oye `Sonido` |
| `jugador_paso` | — | El jugador, al entrar a un cuadro de pasos (metadato `pasos` de su `SpriteFrames`) caminando o en carrera, en el suelo y fuera de un cruce de puerta. Lo oye `Sonido` |
| `jugador_impulso` | — | El jugador, al empezar un impulso. Lo oye `Sonido` |
| `fundido_pedido` | `ticks_oscurecer: int`, `ticks_en_negro: int`, `ticks_aclarar: int` (0: se queda en negro) | El jugador al tocar un peligro y el `Fundido` al empezar un cambio de sala (puerta, estación o muerte); la escucha el `Fundido` de la sala |
| `mochila_recuperada` | `monto: int` (las PejeCoins devueltas) | `Partida.recuperar_mochila()`, al ganar el reto de la `Mochila` o al interactuar con ella sin bolsa. Autoguarda Gancho sin oyente en el juego: solo lo oyen pruebas y guiones; no se borra (28-oct-2026). |
| `articulo_comprado` | `articulo: ArticuloTienda` | `Tienda.comprar()`, tras cobrar, marcar y entregar; después autoguarda Gancho sin oyente en el juego: solo lo oyen pruebas y guiones; no se borra (28-oct-2026). |
| `tienda_abierta` | — | El `MenuTienda`, al final de su `_ready`, ya con el árbol detenido. La escucha el `Hud`: deja las PejeCoins fijas a la vista y corre en pausa |
| `tienda_cerrada` | — | El `MenuTienda` al cerrarse (`cerrar()`, una vez), ya quitada la pausa. La escucha el `Hud`: el contador vuelve a su ciclo |
| `viaje_hecho` | `estacion: String` (el id de la estación de llegada) | La `Estacion` de salida, en negro, justo antes de cambiar a la sala de la otra (si ese cambio falla, el `Fundido` emite después `cambio_fallido`). No guarda Gancho sin oyente en el juego: solo lo oyen pruebas y guiones; no se borra (28-oct-2026). |
| `dispositivo_cambiado` | `dispositivo: int` (el nuevo `Mando.Dispositivo`) | `UltimaEntrada`, solo cuando `dispositivo` cambia de verdad (un toque tras otro no la emite). Al arrancar con un control conectado sale antes del primer cuadro. La escucha `IconoBoton` |
| `ajuste_grafico_cambiado` | `clave: StringName` (la de `Ajustes`) | La Configuración, al cambiar cualquier ajuste de sí o no (`Ajustes.CLAVES_SI_NO`), también desde la pausa; se aplican al momento `luces_avanzadas`, `niebla`, `mostrar_fps`, `panel_pruebas`, `ver_hitbox` y `modo_desarrollador` (`Ajustes.MODO_DESARROLLADOR`); `vibracion` y `temblor` no tienen quien la escuche. La escuchan las piezas que dependen de él (`ContadorFps`, `LuzSala`, `Niebla`, el panel de pruebas y ver hitbox). `recursos` no: vale desde la sala siguiente (ver «Recursos») |
| `mando_cambiado` | — | `Mando`, una vez al final de `asignar`, `aplicar` o `por_omision` si puso algún botón, aunque sea el mismo que ya tenía (no por cada botón; un botón inválido no la emite). Una emisión de más solo cuesta un refresco del ícono. La escucha `IconoBoton` |

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
- Controles táctiles: `nucleo/controles_tactiles.tscn` (`class_name ControlesTactiles`), que crea cada sala.
  Traducen el toque a estas mismas acciones con `Input.action_press` y `action_release`; es el único script que
  lee toques durante el juego (el Editor de controles lee el ratón emulado del toque, ver más abajo, y la
  Configuración lee botones del control para reasignarlos). Lee en `_input` y no en el tick, a diferencia del resto
  de la entrada: el toque es un evento con dedo y posición que `Input` no guarda; lo que produce son acciones, y
  esas sí se leen en el tick. Por eso se excluye a mano mientras hay conversación o editor (`hablando`,
  `editando`). Joystick invisible en la zona de abajo a la izquierda (aparece donde se pone el dedo; da fuerza de 0
  a 1 a `mover_*`, con zona muerta de 0,2; hacia arriba también da `interactuar`, como la flecha arriba) y botones Saltar, Atacar, Curar, Impulso, Pausa y Mapa en la
  distribución inicial (no hay botón de inventario: el de Mapa tiene doble uso, de pie dice «Mapa» y da `mapa`, y
  sentado en un banco (`Jugador.descansando`, leído del grupo `jugador`, `Jugador.GRUPO`) dice «Inventario» y da `inventario`; al
  soltar se suelta la acción que se presionó); Impulso solo mientras `Partida.tiene(&"impulso")` y Atacar mientras `Partida.tiene(&"pluma")` (sin la habilidad no se dibuja ni responde,
  y un dedo encima se suelta al perderla; la tabla `HABILIDAD_DE_BOTON` dice qué botón pide qué habilidad). Anclados a su esquina y medidos en proporción del lado corto. Se ocultan con una tecla o
  el control y reaparecen al tocar la pantalla; los de una sala nueva nacen visibles solo con pantalla táctil y si
  lo último que se usó fue el dedo (`UltimaEntrada.con_control()` en false). Las dos cosas siguen una sola regla,
  `ControlesTactiles.deben_verse(tactil, con_control)`; jugando, `procesar` le pasa lo que dice `UltimaEntrada.clasificar` del evento, porque su `_input` corre antes de que `UltimaEntrada` lo anote (un toque, apoyado o levantado, es el dedo; una tecla o un botón con acción del juego, nunca). Hay dos reglas distintas sobre qué entrada cuenta, las dos estáticas en `UltimaEntrada`:
  `marca_teclado(evento)`, que usa `clasificar`, da verdadero con cualquier tecla pulsada, también Atrás del teléfono,
  y así un menú muestra el foco; el volumen no (`UltimaEntrada.TECLAS_DE_VOLUMEN`, desde el 24-oct-2026: si llega como
  tecla, subirlo o tomar una captura con el control en la mano pasaría los íconos a las teclas; que en Android llegue
  así no está comprobado en 4.7.2); `es_de_juego(evento)`, que usa `procesar` para ocultar los controles,
  pide además que una tecla, un botón o un eje del control dispare una acción del InputMap que no empiece por `ui_`.
  Con un eje, las dos piden la mitad (en `es_de_juego` la pone `is_pressed`, que en 4.7.2 da verdadero desde 0,5; la
  zona muerta de la acción no cuenta). Lo que cambia el dispositivo sin ocultar los controles: una tecla sin acción
  (Atrás, Enter), un botón sin acción (L3, R3, Guía) y un eje sin acción (LT, el stick derecho).
  Unificarlas cambiaría el juego (Atrás dejaría de mostrar el foco, o empezaría a ocultar los controles): es una decisión abierta de la persona. Los dedos se recuerdan entre salas (variables estáticas): un dedo
  que sigue en la pantalla al cruzar una puerta o al reaparecer lo sueltan los controles de la sala nueva; si
  entre una sala y otra pasan más de `CUADROS_CAMBIO_DE_SALA` cuadros (el menú), al llegar se suelta todo. También
  se suelta todo al perder el foco la ventana o la app y al pausarla Android (`_notification`); un dedo que vuelve a
  tocar con un índice ya registrado suelta antes lo que tenía, y un toque con `canceled` suelta. Con un menú abierto,
  es decir con el árbol detenido (`get_tree().paused`, que hoy ponen solo la pausa, el marco de menús, la tienda,
  las estaciones y su cobro), solo los botones de `BOTONES_DE_MENU` (Pausa y Mapa, que sentado manda `inventario`) toman un
  dedo nuevo, así que siguen cerrando su menú como el teclado y el control (Pausa, en Configuración, vuelve un nivel);
  un toque nuevo en Saltar, Atacar, Curar, Impulso (o cualquier botón fuera de `BOTONES_DE_MENU`) o en la zona del joystick no hace nada. Soltar y arrastrar siguen, y
  al detenerse el árbol se suelta todo, también el dedo con que se tocó Pausa o Mapa: los menús leen solo
  `is_action_just_pressed`, así que soltar su acción no abre ni cierra nada, y al levantarlo ya no hay qué soltar. Los
  botones se siguen dibujando. Toda pausa futura del árbol también dejará sin responder los botones de juego y el
  joystick. Dónde va
  cada botón y su tamaño los da `Ajustes.disposicion` (`nucleo/disposicion_controles.gd`, `class_name
  DisposicionControles`, sin nodos): por botón, la esquina de ancla, el desplazamiento desde ella en fracción del lado
  corto y la escala (de 0,5 a 2), más una opacidad para todos (de 0,2 a 1). La distribución inicial sale de
  `CENTROS`, `ANCLAS` y `RADIOS`. Al crearse, al cambiar de tamaño y cuando `Ajustes.disposicion` cambia, los
  controles meten cada botón dentro del área segura (`DisplayServer.get_display_safe_area()` pasada a coordenadas de
  la vista) y no dejan achicar un botón por debajo de su tamaño por omisión ni de un objetivo de 48 dp (contando la holgura del
  toque), el que sea menor: el mínimo no agranda la distribución inicial. Las dos cosas solo en el teléfono (`OS.has_feature
  ("mobile")`): en la PC, toda la vista y sin mínimo. El joystick no se configura.
- Editor de controles: `nucleo/editor_controles.tscn` (`class_name EditorControles` en su nodo `Lienzo`), que abren
  la pausa (`Pausa.abrir_editor()`) y la Configuración del menú principal (ver «Menú»). Tocar un botón lo selecciona y arrastrarlo lo mueve (al soltar, se ancla a la
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
  teclado no cambian. Los controles buscan su sala subiendo por el árbol al entrar.
- Control (Xbox / PlayStation): un evento del InputMap junto a cada tecla, para cualquier control (`device` -1).
  El stick usa la zona muerta de cada acción (0,2); RT es un eje que cuenta como presionado pasada esa zona. LT queda libre.

## Jugador

El jugador (propiedades, combate, curar, habilidades y prioridad del movimiento) está en `docs/jugador.md`.

## Componentes

| Componente | Qué es |
|---|---|
| `nucleo/arte/destello.gdshader` (shader `canvas_item`) | Destello en blanco del cuerpo del jugador: mezcla el color con blanco según el uniforme `cantidad` (0 a 1), sin tocar el alfa, con la misma lectura de textura del sprite. Es el `ShaderMaterial` del nodo `Dibujo` de `nucleo/jugador.tscn`; lo mueve el `Jugador` (unos ticks tras un parry), no `AnimacionJugador`. Un `modulate` mayor que 1 no aclara en Compatibility. Detalle en `docs/jugador.md`, «Dibujo» |
| `nucleo/golpeable.gd` (`class_name Golpeable`, `Area2D`) | Hijo de lo que el ataque o la bola pueden golpear, con su forma. `recibir_golpe(atacante, dano := 1)` cuenta `golpes` y `dano_recibido`, empuja a su padre lejos del atacante (`velocidad_retroceso` 600 px/s, `ticks_retroceso` 6: 60 px; 0 para que no se mueva; golpeado justo desde arriba no se empuja) sin meter su forma en un `StaticBody2D` (lo busca con un rayo a media altura) ni sacarla de los `limites` de su `Sala`: al topar, el empuje se acaba, emite su señal `golpeado(atacante, dano)` y, con su padre, `Eventos.enemigo_golpeado` si `es_enemigo` (por omisión) o `Eventos.objeto_golpeado` si no. Solo el ataque a un `Golpeable` con `es_enemigo` llena la Inspiración; el rebote, el pogo y la voltereta son iguales para los dos |
| `nucleo/muro_rompible.gd` (`class_name MuroRompible`, `StaticBody2D`) | Pared, techo o suelo que se rompe a golpes (como el Breakable Wall de Hollow Knight): sólido como cualquier otro, con su forma y su dibujo en la sala. Crea su `Golpeable` (sin `es_enemigo`, sin retroceso, `MARGEN_GOLPE` 12 px más grande que su forma, público como `golpeable`). Aguanta `golpes` (4; `quedan`); el ataque, el pogo, la onda de la picada y la bola cuentan uno cada uno (la bola se detiene en el sólido y le pega desde su rayo). `solo_desde` (`CUALQUIERA`, `IZQUIERDA`, `DERECHA`, `ARRIBA`, `ABAJO`) limita de qué lado cuenta el golpe (`cuenta_desde(punto)`); del otro lado solo rebota al jugador. Cada golpe lo sacude y tiembla la cámara (`Jugador.temblar`); al romperse: `roto`, se marca con `id` (obligatorio en las salas con id) en el estado de su sala, suelta `escombros` partículas, emite `se_rompio` y `Eventos.muro_roto`, desvanece en `ticks_desvanecer` (20) cada nodo de `tapas` (`Array[CanvasItem]` exportado: los dibujos que tapan el cuarto escondido), muestra cada nodo de `descubre` (`Array[CanvasItem]`: lo que solo existe roto, como las orillas del hueco; oculto hasta romperse) y desaparece. Marcado, no aparece, sus tapas quedan ocultas y lo que descubre, a la vista. Lo escondido que se toma (un coleccionable, PejeCoins) no va en `descubre`: queda encerrado detrás del sólido, porque `visible` no apaga un área ni su proceso. Tapas y descubre van fuera del muro (se iría con ellos) y ninguno en las dos listas; lo revisa el validador `se_rompio` es un gancho sin oyente en el juego (solo pruebas y guiones). |
| `nucleo/palanca.gd` (`class_name Palanca`, `Node2D`) | Palanca que se mueve con un golpe del jugador (como la Lever de Silksong): crea su `Golpeable` (sin `es_enemigo`, 70×110). Solo un golpe cuyo atacante es el `Jugador` la activa (la bola no), una vez: queda inclinada hacia el otro lado, se marca con `id` en el estado de su sala, pide el congelado común (`ticks_congelado` 6) y temblor, emite `activada` y, `ticks_retraso` (45) después, llama `abrir()` en cada `Porton` de `portones` (`Array[Porton]` exportado). Marcada, aparece activada (`esta_activada`, `abrio`) `activada` es un gancho sin oyente en el juego (solo pruebas y guiones). |
| `nucleo/porton.gd` (`class_name Porton`, `AnimatableBody2D`) | Portón que se desliza `recorrido` (cero: su alto hacia arriba) en `ticks_apertura` (30), en el tick y quieto durante el congelado. `abrir()` se marca con `id` al empezar (salir a media apertura lo deja abierto), emite `Eventos.porton_abierto` y, al terminar, `abierto`. `cerrar()` lo regresa sin tocar lo guardado (arenas); `abierto_al_empezar` para el de una arena. Marcado, aparece abierto. `esta_abierto` y `abriendo` son públicas `abierto` es un gancho sin oyente en el juego (solo pruebas y guiones). |
| `nucleo/suelo_fragil.gd` (`class_name SueloFragil`, `StaticBody2D`) | Sólido que se pisa como cualquier otro y que rompe la caída en picada (`romper()`: `roto` y desaparece). Va en la sala con su forma y su dibujo. Con `id` (obligatorio en las salas con id) se marca en el estado de su sala al romperse y ya no aparece al entrar |
| `nucleo/recogible.gd` (`class_name Recogible`, `Area2D`) | Base de lo que se toma al tocarlo: `Coleccionable`, `MonedasSueltas`, `ObjetoHabilidad` y `ObjetoMapa` (`mapa/`). Pone su capa (`interaccion`, máscara `jugador`); si `ya_recogido()`, no aparece. Al entrar el jugador vivo, una sola vez: si `recordado_por_id()`, se marca con `id` en el estado de su sala; luego su efecto (`_al_recoger(jugador)`) y desaparece. Por omisión se recuerda por `id` (único en la sala; el validador lo exige); el que lo recuerda otra cosa de la partida (una habilidad, un mapa) cambia `ya_recogido()` y `recordado_por_id()`. Un recogible nuevo hereda de aquí: solo pone su efecto y su arte |
| `nucleo/zona_camara.gd` (`class_name ZonaCamara`, `Area2D`) | Tramo de una sala que la cámara debe mostrar como una sala más chica (la `CameraLockArea` de Hollow Knight). `limites` (`Rect2`) es lo que la cámara puede mostrar mientras el jugador está dentro, en coordenadas de la sala como `Sala.limites` (la `position` del nodo solo coloca la forma); un eje sin tope se deja igual al de la sala. La forma es una `CollisionShape2D` hija, editada en el editor. Pone su capa (`interaccion`, máscara `jugador`); al entrar y salir el jugador llama a `Jugador.camara().entrar_zona(self)` y `salir_zona(self)`. Sin tick. La pila vive en `CamaraJugador`: manda la última zona en que entró; al salir vuelve la anterior y, sin ninguna, la sala; la vista es `limites` de la sala recortado por los de la zona (`limites_vista()`, con `intersection`, sin centinelas). En los `TICKS_AL_INSTANTE` (30, medio segundo) tras colocar la cámara (llegar a la sala, reaparecer) la zona la coloca al instante; después, cuando cambia la zona que manda (entrar a otra o salir de la que manda) sigue lento `TICKS_LENTO` (30) ticks, con 2/s en x y 0,5 s en y (`dampTimeSlow` y `slowTime` de Hollow Knight). El validador exige la forma hija y, en una sala, `limites` con área dentro de los de la sala. Prueba: `nucleo/zona_camara` |
| `nucleo/region_musica.gd` (`class_name RegionMusica`, `Area2D`) | Tramo de una sala donde cambia la música (la `MusicRegion` de Hollow Knight): al entrar el jugador pide a `Musica` su `tema` (vacío: sigue el que suena) con `volumen_entrar_db` en `segundos_entrar`; al salir, solo el volumen, `volumen_salir_db` en `segundos_salir`. Por omisión, los de Dirtmouth (0 dB en 3 s al entrar, -60 dB en 6 s al salir). La forma es una `CollisionShape2D` hija, editada en el editor; pone su capa (`interaccion`, máscara `jugador`). Liberar la sala con el jugador dentro no es salir: el área avisa la salida al quitar su forma, todavía en el árbol, y por eso el pedido de salida va diferido y solo sale si la región sigue en el árbol al final del cuadro. Sin tema de salida ni pausa del tema callado: se agregan cuando una sala los necesite, midiendo en el S50. `dentro` es pública. Prueba: `nucleo/musica` (sala de prueba Música) |
| `nucleo/coleccionable.tscn` (`class_name Coleccionable`, `Recogible`) | El coleccionable del juego, uno solo como las larvas de Hollow Knight o las pulgas de Silksong: cada instancia lleva su `id`, que empieza con `coleccionable` (lo revisa el validador). Al tomarlo se marca, emite `coleccionable_obtenido` (autoguarda) y desaparece. Trae el arte (`nucleo/arte/coleccionable.png`, hoy la credencial; cambiar el arte es cambiar esa imagen) con el material sin sombreado, un halo `LuzSala` que late (`PULSO`) y flota con el arte, quieto en la pausa y el congelado. `brillo` aclara el arte con `self_modulate` (1: sin aclarar). Sin `_draw` |
| `nucleo/monedas_sueltas.tscn` (`class_name MonedasSueltas`, `Recogible`) | PejeCoins tiradas, premio a quien explora (el geo suelto de Hollow Knight): al tomarlas suma `cantidad` (10) a `Partida.monedas`, se marca con su `id` (por omisión `monedas`; dos montones en una sala, ids distintos) y desaparece; no autoguarda: la marca y las PejeCoins viajan juntas en el siguiente guardado. El montón es un `Sprite2D` con la PejeCoin horneada (`nucleo/arte/monedas_sueltas.png`, la genera `herramientas/generar_efectos.gd` desde `FigurasVector`), sin sombreado y con un halo `LuzSala` que late; la forma (72×40) va centrada en el dibujo. En el mundo no se dibuja con `FigurasVector`: redibujarla en vector cada cuadro bajaba el S50 de 59,7 a 37-40 FPS en las salas con PejeCoins |
| `nucleo/entrega_recompensas.gd` (`class_name EntregaRecompensas`, `Interactuable`) | Con el jugador encima y `Jugador.puede_interactuar`, `interactuar` recién pulsado y sin `Congelado.activo()` (la misma regla del `Npc`: es el disparador de la base, con `con_aviso` en falso, sin aviso ni dibujo propio) entrega cada `Recompensa` de su lista cuya `cantidad` ya se juntó y no se entregó (marca `PREFIJO_ENTREGADO` + cantidad, `entregado_<cantidad>`, en su sala) y autoguarda. `entregadas` las cuenta |
| `nucleo/recompensa.gd` (`class_name Recompensa`, `Resource`) | `cantidad`, `tipo` (`MONEDAS`, `VIDA_MAXIMA`, `AMULETO`, `HABILIDAD`, `MAPA`; el orden no cambia porque se guarda como número), `monto` e `id` (en `MAPA`, la zona) |
| `nucleo/interactuable.gd` (`class_name Interactuable`, `Area2D`) | Base de lo que se usa con `interactuar` estando encima: `Npc`, `RetoPreguntas`, `Mochila`, `Tienda`, `Estacion`, `Banco`, `EntregaRecompensas` y `Puerta` la extienden (`Banco` y `EntregaRecompensas` con `con_aviso` en falso, fijado en `_init`; `Puerta` solo usa el tick de la base en el tipo `PUERTA`: las demás apagan su `_physics_process` y se cruzan al entrar en el área). En `_ready` (las subclases llaman `super()`) se pone en `INTERACCION` con máscara `JUGADOR`. En el tick: con una `caja` (`CajaDialogo`) abierta, la cierra si el jugador ya no es válido, dejó de hablar o murió (`_cerrar_caja()`: suelta al jugador y pone `caja.ficha = null` antes de `queue_free()`), y no hace más; si no, con `_puede_interactuar()` (gancho, verdadero por omisión) sigue `cerca` (`Jugador.encima_de`, redibuja al cambiar) y, con `interactuar` recién pulsado y sin `Congelado.activo()`, llama al gancho `_al_interactuar(jugador)`. `con_aviso` en falso no sigue `cerca` ni dibuja aviso: solo mira `encima_de` al pulsar. `_abrir_caja(jugador, ficha, al_elegir)` deja al jugador hablando y abre la caja (nodo `Caja`); al terminar llama `_al_terminar(contar)`, que por omisión cierra. Dibujo: `dibujar_provisional(ancho, alto, color)`, el rectángulo con los pies en el origen, solo sin un `CanvasItem` hijo que no sea `CollisionShape2D` (`sin_arte()`; los `CanvasLayer`, como la caja, no cuentan), y `dibujar_aviso(altura)`, el triángulo `COLOR_AVISO` con la punta a esa altura, siempre que `cerca`, con arte o sin él. `_crear_forma(ancho, alto)` crea la forma para quien no la trae en su escena. `cerca` y `caja` son públicas |
| `nucleo/npc.tscn` (`class_name Npc`, `Interactuable`) | Personaje con quien se habla. Con el jugador encima, en el suelo y libre (sin morir, sentarse, aterrizar duro ni hablar ya), un triángulo encima avisa e `interactuar` abre una `CajaDialogo` con la conversación de su `etapa` y llama `Jugador.empezar_a_hablar()`. `conversaciones` tiene una `FichaDialogo` por etapa. Terminar contando sube la etapa, la marca en el estado de su sala (`id` único en la sala, que no empieza con `coleccionable` ni `entregado_`), entrega las recompensas de esa ficha una sola vez y autoguarda; terminada la última, se repite sin entregar. Sin contar (`CANCELAR`), un golpe, un peligro o morir la cierran sin cambiar nada. Emite `conversacion_terminada(etapa)` al terminar contando una etapa (es la señal de «etapa terminada» que conecta la sala, por ejemplo para pasar a una cinemática); `etapa`, `cerca` y `caja` son públicas. Forma provisional: un rectángulo, que se apaga con arte. **Dibujo animado (opcional):** `animacion` es un `AnimatedSprite2D` hijo; el `Npc` toca solo las animaciones que su `SpriteFrames` tenga: `quieto` (`ANIM_QUIETO`), `hablar` mientras la caja está abierta y `entregar` al terminar contando una etapa, que vuelve a `quieto` al acabar (sin bucle: lo exige el validador). Con `mirar_al_jugador` (por omisión) se voltea hacia el jugador reflejando el dibujo con `scale.x` sobre los pies (el dibujo mira a la derecha sin voltear), con una zona muerta de `ZONA_MUERTA` (4 px); `mira` (1 o -1) es pública. El NPC que sale en varias salas es una escena heredada de `npc.tscn` con su dibujo y sus fichas en `contenido/npc/<id>/`: ninguna sala lo anima con su propio script |
| `nucleo/aviso_accion.gd` (`class_name AvisoAccion`, `Area2D`) | Pizarrón que enseña una acción con su botón y una palabra, como los avisos de King's Pass. `acciones` (una o dos del InputMap; el validador lo exige), `modo` (`UNA_VEZ`, por omisión: hecha, no vuelve en la partida; `POR_VISITA`: hecha se va y vuelve al entrar otra vez a la sala; `SIEMPRE`: sale cada vez que el jugador entra, aunque ya la haya hecho, y el botón de la pantalla late solo hasta hacerla), `id` (lo exige `UNA_VEZ`, `POR_VISITA` no lo lleva y en `SIEMPRE` es opcional: con él, lo hecho se recuerda y el botón ya no late en otra visita; sin repetir entre los avisos de la escena ni, en una sala con id, con otro objeto que se recuerda, y sin prefijo reservado; el validador lo exige), `texto` (la palabra; vacía, la etiqueta del botón de la pantalla de la última acción), `nota` (una línea más, opcional), `pizarron` (false: sin caja gris, para el aviso sobre un objeto), `tamano` (la zona, apoyada en el suelo y centrada en el aviso, 480×320) y `punto` (centro del pizarrón, 0, −240). Con el jugador dentro y pudiendo atender (sin estar sentado, hablando ni muerto; no `Jugador.puede_interactuar`, que exige el suelo y apagaría el de saltar a medio salto) espera `TICKS_ESPERA` (30) y el dibujo aparece en `TICKS_APARECER` (12); al salir o al dejar de poder atender se va en los mismos. Con el control o el teclado, un `IconoBoton` por acción a escala 2, con la palabra en el último; tras un toque, el botón de la pantalla con su etiqueta (moverse o interactuar: el aro del joystick con su perilla), y la palabra debajo si es otra que la etiqueta, y además pone `ControlesTactiles.resaltada` para que ese botón lata, y la quita al salir, al hacer la acción o al dejar el árbol. **Hecha:** la última acción se pulsa con las demás mantenidas, en cualquier punto de la sala y sin una conversación abierta ese tick ni el anterior (`ControlesTactiles.hablando`: avanzar o cerrar una caja de diálogo con saltar o atacar no cuenta); curar cuenta al curar una vida (`Eventos.jugador_curado`). Al aparecer o al quedar hecho, enseña los botones de la pantalla de sus acciones (`Partida.ensenar_boton`). Hecha, con `id` (salvo en `POR_VISITA`) se marca en el estado de la sala (`Partida.marcar`); fuera de `SIEMPRE`, si estaba a la vista sigue hasta `TICKS_MINIMO` (60) desde que apareció y, si no había aparecido, ya no sale. Sin un `CanvasItem` hijo propio dibuja una caja gris oscura (`PIZARRON`); el arte del pizarrón lo pone la sala. `dentro`, `alfa`, `hecha` y `palabra()` son públicas |
| `nucleo/caja_dialogo.gd` (`class_name CajaDialogo`, `CanvasLayer` capa 12) | Caja abajo de la pantalla, dentro del área segura: quién habla y el texto letra por letra (`ticks_por_letra`, 2). `interactuar`, `saltar`, `atacar` o tocar la caja completan la línea y, completa, pasan a la siguiente; la pulsación que la abrió no cuenta. Las opciones de una pregunta van en fila encima de la caja: izquierda y derecha cambian la marcada y se toma con las mismas acciones o tocándola; con opciones a la vista, tocar la caja no elige. Emite `terminada(contar)` y, al tomar una opción, `opcion_elegida(linea, opcion)` antes de pasar a su destino. Corre con el juego: la pausa y el mapa la detienen. Mientras existe, `ControlesTactiles.hablando` es verdadero. `linea`, `letras_visibles`, `completa` y `elegida` son públicas |
| `nucleo/ficha_dialogo.gd` (`class_name FichaDialogo`, `Resource`) y `nucleo/linea_dialogo.gd` (`class_name LineaDialogo`) | Una conversación: `lineas` y `recompensas`. Cada línea lleva `quien`, `texto` y, si pregunta, hasta `MAX_OPCIONES` (3) `opciones` con un `destino` cada una: otra línea, `FIN` (termina contando) o `CANCELAR` (termina sin contar). Sin opciones, avanzar pasa a la siguiente; la última termina contando. `fallos()` da la lista de problemas de forma. `LineaDialogo.nueva(quien, texto)` arma una línea sin opciones |
| `nucleo/reto_preguntas.tscn` (`class_name RetoPreguntas`, `Interactuable`) | Reto de preguntas. Se habla como con un `Npc` (mismas condiciones, mismo `Jugador.empezar_a_hablar()`) y abre una `CajaDialogo` con las `preguntas` que faltan de la ronda, en orden, cada una seguida de `texto_correcto` o `texto_incorrecto` con la respuesta correcta. Cada respuesta (`responder(opcion)`) cuenta, se marca en el estado de su sala y autoguarda; un golpe corta la ronda donde iba. Al acabar la ronda con `meta` aciertos o más gana (`<id>` en `true`, `recompensa` una sola vez, señal `ganado`) y desde entonces solo dice `texto_ganado`; si no, la ronda vuelve a empezar en cero. Si lo guardado ya no cabe en la lista, empieza otra vez. `indice`, `aciertos`, `gano` y `caja` son públicas. Forma provisional: un atril `ganado` es un gancho sin oyente en el juego (solo pruebas y guiones). |
| `nucleo/ficha_pregunta.gd` (`class_name FichaPregunta`, `Resource`) | `pregunta`, de 2 a 3 `opciones` (las que caben en la fila de la caja) y `correcta`. `fallos()` da la lista de problemas de forma. `lineas_para(quien, en)` da sus dos líneas para una `FichaDialogo` (la pregunta en el índice `en`, con todas sus opciones hacia la siguiente, y la de la respuesta vacía) y `respuesta(acerto, correcto, incorrecto)` el texto de esa respuesta (por omisión `TEXTO_CORRECTO` y `TEXTO_INCORRECTO`, que también usa `RetoPreguntas`); los usan `RetoPreguntas` y `Mochila` |
| `nucleo/mochila.gd` (`class_name Mochila`, `Interactuable`) | Lo perdido al morir. La crea `Sala._ready` si `Partida.mochila` es de esa sala, en su `x, y`; no usa el estado por sala. Se habla como con un `Npc` y abre una `CajaDialogo` con una línea de entrada y `preguntas_por_reto` preguntas sorteadas de la bolsa (`sorteadas`, públicas), cada una seguida de si acertó. Es una sola oportunidad: con `meta` aciertos o más llama `Partida.recuperar_mochila()`, y si no, `Partida.perder_mochila()` (`perdida`, pública); en los dos casos desaparece al cerrar la caja. Un golpe, un peligro o morir cortan el intento sin contar, y el siguiente sortea otra vez sin repetir las del cortado cuando la bolsa tiene al menos el doble de `preguntas_por_reto`. Sin bolsa (o con una mal formada), `interactuar` la recupera enseguida. Se dibuja ella misma con `nucleo/arte/mochila_perdida.png` (la mochila abierta aprobada el 21-oct-2026, a 128 px y escalada a 64 px de alto, con mipmaps), flotando con un vaivén de seno (`FLOTA`, `AMPLITUD`, `PERIODO`) que mueve el dibujo y no el área de 80×80 px; al recuperarla o perderla el dibujo se apaga |
| `nucleo/bolsa_preguntas.gd` (`class_name BolsaPreguntas`, `Resource`) | La bolsa de la mochila: `preguntas`, `preguntas_por_reto` (3) y `meta` (2). Una sola para todo el juego, `contenido/preguntas_mochila.tres`, que la `Mochila` carga con `load()` solo si existe; si no, va sin reto. La de prueba (`herramientas/salas/preguntas_mochila_prueba.tres`) solo la pone la sala de prueba Lo Perdido, para que el paquete publicado nunca la muestre. `fallos()` da la lista de problemas de forma, y el validador la revisa en cada `.tres` |
| `nucleo/tienda.gd` (`class_name Tienda`, `Interactuable`) | Tienda de PejeCoins, hija directa de una sala: `id` (único en la sala; el validador lo exige en las salas con id), `nombre` y `articulos`. Con el jugador encima, `interactuar` abre su `MenuTienda` (`abrir()`; con el menú abierto no sigue `cerca` ni dispara); no usa la `caja` de la base. `a_la_venta()` da lo no comprado cuyo requisito se cumple. `comprar(articulo)` da `false` si ya se compró, no está a la vista o no alcanzan las PejeCoins; si no, cobra con `Partida.gastar_monedas`, marca `<id>_<articulo>` en el estado de su sala, entrega la `Recompensa`, emite `articulo_comprado` y autoguarda. Cada artículo se vende una vez. Caja gris de 160×200 px hasta que lleve un `CanvasItem` hijo |
| `nucleo/articulo_tienda.gd` (`class_name ArticuloTienda`, `Resource`) | `id` (único en su tienda), `nombre`, `descripcion`, `precio` (mayor que 0), `recompensa` (una `Recompensa`) y `requisito`: una habilidad que hay que tener para que aparezca (vacío: siempre). El validador revisa cada uno y que las habilidades estén en `Habilidades.TODAS` |
| `nucleo/icono_articulo.gd` (`class_name IconoArticulo`, `Control`) | Ícono de gis de una fila de la tienda, dibujado en código hasta tener arte: `forma` (`IconoArticulo.Forma`: `NINGUNA`, `MONEDA`, `VIDA`, `AMULETO`, `HABILIDAD`, `MAPA`) y `apagado` (en `Tema.GRIS_APAGADO`). `IconoArticulo.forma_de(articulo)` da la forma del tipo de su `Recompensa` (`MONEDAS` → `MONEDA`, `VIDA_MAXIMA` → `VIDA`, y las demás con su nombre; sin recompensa, `NINGUNA`). `IconoArticulo.crear(forma, lado, gris)` lo da sin agregar, sin toques ni foco. La moneda del precio es la forma `MONEDA`: el círculo del HUD vive en `interfaz/` |
| `nucleo/lista_elegir.gd` (`class_name ListaElegir`, `VBoxContainer`) | La lista con foco de la tienda y del menú de estaciones: Volver arriba, un encabezado, filas con nombre y un dato a la derecha dentro de un `ScrollContainer` (`desliza`, con `follow_focus`) que va en una `BoxContainer` (`cuerpo`, nodo `Cuerpo`), y un pie. `armar(nombres, datos, apagar, foco)`; una fila apagada (por omisión, variaciones `Tema.FILA_APAGADA` y `Tema.DATO_APAGADO`) toma el foco para leer su descripción pero no se elige. Señales `elegida(indice)`, `enfocada(indice)` y `cerrada` (Volver). Opcional, fijado antes de `armar` (sin tocarlo se ve como siempre): `variacion_fila` y `variacion_fila_apagada`; `con_franja`, que pone en cada fila un `Panel` `Franja` (`Tema.FRANJA`, detrás de la fila) visible solo en la última fila que tuvo el foco, también tras un toque, cuando el foco no se dibuja (`con_franja_en()` la da); y `cuerpo`, donde quien la usa agrega algo junto a las filas |
| `nucleo/confirmacion.gd` (`class_name Confirmacion`, `ColorRect`) | La confirmación Sí / No compartida, armada en código: un velo negro a pantalla completa (`set_anchors_and_offsets_preset(PRESET_FULL_RECT)`, detiene los toques) con la pregunta centrada, una línea opcional con la cantidad y Sí y No debajo, nodos `Caja/Pregunta`, `Caja/Cantidad` y `Caja/Botones/Si` y `No` (públicos como `pregunta`, `cantidad`, `si` y `no`). Empieza oculta. `abrir(pregunta, texto_si, texto_no, foco := Confirmacion.Foco.NO, texto_cantidad := "")` la muestra con el foco en Sí o en No (`Tema.dar_foco`); la línea de la cantidad (lo que cuesta, «50 PejeCoins») solo se ve si `texto_cantidad` no está vacío. Sí emite `confirmada` una vez por `abrir` y la deja a la vista: la cierra quien la abrió (`cerrar()`, sin señal). No y `cancelar()` la cierran y emiten `cancelada`; cerrada, no hacen nada. No lee la entrada: quien la abre llama a `cancelar()` desde su Atrás y pone el foco donde corresponde al recibir `cancelada`, y oculta lo de detrás mientras está abierta, para que el foco no se escape. El aspecto se fija antes de agregarla (se arma en `_ready`): `alfa_velo` (0,8), `separacion` entre pregunta y botones (32), `ancho_pregunta` (800, con ajuste de línea; 0, una línea), `variacion_pregunta` (`Tema.PREGUNTA`), `variacion_cantidad` (`Tema.TITULO`) y `variacion_boton` (vacía: el botón del tema con 300 px de ancho mínimo; otra, como `Tema.OPCION_CENTRADA`, sin ancho mínimo). La usan las ranuras (Borrar y Restaurar, con sus valores por omisión) y Salir del menú principal (velo 0,7, separación 24, una línea, `Tema.TITULO`), los dos con el nodo llamado `Confirmar` y el foco en No; y, con el aspecto del cobro de Silksong (sin velo propio: el `CobroEstacion` sobre `Tema.fondo_menu()` y el `MenuTienda` sobre su velo, que mientras pregunta cubre toda la pantalla; pregunta `Tema.DESTACADA`, el precio en la línea de la cantidad con el texto «PejeCoins», Sí y No con `Tema.OPCION_CENTRADA` y el foco en Sí), el `MenuTienda` y el `CobroEstacion`, con el nodo llamado `Confirmacion`. La moneda va en texto: el círculo del HUD se dibuja dentro de `interfaz/hud.gd` y el núcleo no depende de `interfaz/` |
| `nucleo/menu_tienda.gd` (`class_name MenuTienda`, `CanvasLayer`) | El menú de una `Tienda` como los de Hollow Knight y Silksong, con el juego detenido y a la vista a la izquierda. La raíz `Fondo` (`Tema.fondo_menu(0.0)`, pública como `fondo`) es transparente a pantalla completa y detiene los toques sobre el juego; su hijo `Velo` (público como `velo`, negro con `Tema.VELO`) va de `MARGEN_VELO` (32) px antes del panel a la orilla derecha. El panel es la `ListaElegir` (`Fondo/Area/Lista`) en la mitad derecha del área útil (`Area`, con `Tema.ajustar`): Volver y el nombre de la tienda (baja de línea si no cabe), sin encabezado ni pie; las filas (`Tema.FILA_TIENDA`, en gris `Tema.FILA_TIENDA_APAGADA` lo que no alcanza) llevan el `IconoArticulo` de su recompensa (`Icono`), la moneda (`Moneda`) y el precio como texto, en una columna de `ANCHO_FILAS` (260) px con la franja en la elegida (`con_franja`); a su derecha, en `cuerpo`, el `Detalle`: el nombre en `Tema.TITULO` y la descripción (públicos como `nombre` y `descripcion`), que siguen a la fila con el foco. Si al detalle le quedan menos de `ANCHO_MINIMO_DETALLE` (240) px va debajo de las filas (`cuerpo.vertical`); con la vista de 1280 de ancho (4:3 y 16:9) le quedan 284 y va al lado. La lista no se desplaza bajo una franja fija: con `follow_focus` la fila con foco se trae a la vista y la franja va en ella (desplazar la lista al dar el foco movería la fila bajo el dedo antes de soltar y el toque no la elegiría). Sin nada a la venta queda una fila gris sin ícono y el detalle dice «Ya no hay nada a la venta». Las PejeCoins no van en el panel: al abrir emite `tienda_abierta` y al cerrar `tienda_cerrada`, y el HUD las muestra fijas. Elegir oculta la lista, el velo pasa a toda la pantalla y pide confirmar con la `Confirmacion` (`Fondo/Confirmacion`, pública como `confirmacion`): «¿Comprar <nombre>?», el precio en la línea de la cantidad y el foco en Sí. Sí compra una vez (`confirmar()`) y vuelve a la lista; No, `volver`, `pausa` y Atrás vuelven un nivel: de la confirmación a la lista sin comprar (`Confirmacion.cancelar()`) y de la lista al juego. Está en el grupo `pantalla_encima` |
| `nucleo/estacion.gd` (`class_name Estacion`, `Interactuable`) | Estación del viaje rápido, hija directa de una sala con id: `id` (`estacion_<id de la sala>`), `costo` en PejeCoins (0, gratis) y `llegada` (dónde aparece el jugador, relativo a ella). Con el jugador encima (con el cobro o el menú abiertos no sigue `cerca` ni dispara; durante el fundido de un viaje no hace nada más), `interactuar(jugador)`, pública: cerrada, abre su `CobroEstacion` (público como `cobro`), que pregunta si paga con el juego detenido; con Sí, `pagar()` cobra una vez, la abre con `Partida.abrir_estacion` y autoguarda, y una `CajaDialogo` de una línea (pública como `caja`) dice «Estación abierta…» o «No te alcanza.»; gratis, se abre sola; abierta, abre el `MenuEstaciones`. `viajar(id)` le pide al `Fundido` el cambio a la sala de esa estación (él escribe `Sala.estacion_llegada`) y, en negro, emite `viaje_hecho`. No cura, no guarda ni cambia el banco. `Estacion.tabla_de(id de sala)` da la tabla de la carpeta de la sala: `contenido/estaciones.tres` o, para la zona de pruebas, `herramientas/salas/zonas/estaciones_prueba.tres`, cada una con `load()` solo si existe. Caja gris de 240×200 px hasta que lleve un `CanvasItem` hijo |
| `nucleo/cobro_estacion.gd` (`class_name CobroEstacion`, `CanvasLayer` capa 20) | El cobro de una `Estacion` cerrada, como el de un asiento de Silksong, con el juego detenido como el `MenuTienda`: sobre `Tema.fondo_menu()`, la `Confirmacion` (`Fondo/Confirmacion`, pública como `confirmacion`) con «¿Abrir esta estación? Tienes N PejeCoins.», el costo en la línea de la cantidad y el foco en Sí. Sí lo cierra y emite `pagar_pedido` (una vez); No, `volver`, `pausa` y Atrás lo cierran sin cobrar (`atras()`). Al cerrarse quita la pausa y emite `cerrado`. Corre en pausa, con `MarcoMenus.PRIORIDAD_FISICA`, y está en el grupo `pantalla_encima`. Lo crea la `Estacion` y se libera al cerrarse |
| `nucleo/ficha_estaciones.gd` (`class_name FichaEstaciones`, `Resource`) y `nucleo/dato_estacion.gd` (`class_name DatoEstacion`) | La tabla de estaciones: una fila por estación con `id`, `nombre` (el del menú) y `sala` (su id), en el orden del menú. `buscar(id)`; `fallos()` revisa ids sin repetir, `id` = `estacion_<sala>` y nombre, y el validador la corre en cada `.tres` |
| `nucleo/menu_estaciones.gd` (`class_name MenuEstaciones`, `CanvasLayer`) | El menú de destinos, con el juego detenido, como el del Ciervo de Hollow Knight: a la izquierda la `ListaElegir` (`Fondo/Lista`, título «Viajar») con las estaciones abiertas de la tabla, en su orden, con el foco en la actual («Aquí», en gris, no se elige); a la derecha, en su `cuerpo`, el `MapaEstaciones` (`mapa`, nodo `Mapa`); abajo a la derecha, en lugar del pie, las ayudas (`ayudas`, nodo `Ayudas`): dos `IconoBoton`, `ui_accept` «Viajar» y `volver` «Cancelar», que tras un toque no se ven (la fila guarda su alto). Las posiciones salen de `mapa/indice_salas.tres` (`RUTA_INDICE`; `ruta_indice` se fija antes de agregarlo): con `ResourceLoader.exists`, `load()` y `get(&"rectangulos")`, sin nombrar `IndiceSalas`, así que sin el bloque `mapa/` el núcleo sigue compilando y corriendo. Cada estación va en el centro del rectángulo de su sala (`centros_de(salas, rectangulos)`, vacío si a alguna le falta); sin índice o sin el rectángulo de alguna, `mapa` queda `null` y la lista va sola a lo ancho. Con mapa, la lista mide al menos `ANCHO_LISTA` (480) y el mapa `PROPORCION_MAPA` (1,2) veces la lista; si al mapa le quedan menos de `ANCHO_MINIMO_MAPA` (240) px se oculta y la lista va a lo ancho. Elegir otra cierra y la `Estacion` viaja; `volver`, `pausa` y Atrás lo cierran. Está en el grupo `pantalla_encima` |
| `nucleo/mapa_estaciones.gd` (`class_name MapaEstaciones`, `Control`) | El mapa de gis del viaje rápido, dibujado en un `_draw` medido contra `size`, sin imágenes, que no toma el foco ni los toques: un círculo de gis por estación; una línea de gis (`EstiloGis.puntos`, `Tema.GIS_TENUE`) de cada estación a la siguiente en el orden de la tabla (`tramos`: 0-1, 1-2…; lo controla quien escribe la tabla, no la posición); la marcada (la del foco de la lista, por `enfocada`) con un anillo en `Tema.GIS`; la actual en `Tema.GRIS_APAGADO` con un punto dentro y «Aquí» debajo (al abrir, con el foco en ella, lleva las dos marcas). `poner(centros, actual)` recibe los centros del mundo; `centros_en_pantalla()` los encaja con la misma escala en los dos ejes en `size` menos `MARGEN` (72), centrados, y un eje sin largo (todas en fila o una sola) queda en medio. `marcar(indice)` redibuja solo si cambia. `centros_mundo`, `tramos`, `marcada` y `actual` son públicas para las pruebas |
| `nucleo/vitrina_coleccionables.gd` (`class_name VitrinaColeccionables`, `Node2D`) | Dibuja `total_del_juego` lugares, llenos los `juntados` (leído al entrar): la sala donde se ven los coleccionables |
| `nucleo/cortable.tscn` (`class_name Cortable`, `Area2D`) | Decoración que cortan el ataque y la bola del jugador (pasto y lo que cada zona quiera). `cortar()` oculta el hijo `Entero`, muestra `Cortado` y suelta `trozos` partículas; no da Inspiración, no rebota al jugador ni cuenta como enemigo. Se sacude al pasar el jugador (`sacudidas`). No se guarda: vuelve al entrar otra vez a la sala. `esta_cortado` es pública. Para otra forma, se hereda la escena y se cambian `Entero` y `Cortado` |
| `nucleo/proyectil.tscn` (`class_name Proyectil`, `Area2D`) | La bola: avanza recto y sin gravedad (`velocidad` 900 px/s, `ticks_vida` 60) y golpea una vez, con su `dano` (2), a cada `Golpeable` que toca, sin detenerse. Corta cada `Cortable` que toca con su `cortar()`, como el ataque, y sigue: el pasto no la detiene. Desaparece contra un sólido, que busca con un rayo: movido por posición, no detectó los `StaticBody2D` de las salas (`docs/errores/2026-10-06-bola-atravesaba-paredes.md`); el rayo además cubre el paso de un tick. Si el jugador está pegado a una pared, no llega a salir (se cobra igual). No da Inspiración |
| `nucleo/dano_contacto.gd` (`class_name DanoContacto`, `Area2D`) | Daña al jugador mientras lo toca (`dano`, 1 por omisión). Con `peligro = true` es un peligro (punto seguro); si no, un golpe normal (retroceso). Regla, como Silksong: lo fijo (pinchos, ácido, lava, vacío) es peligro; lo que se mueve (sierras que viajan, trampas, lo que lanza un jefe) solo golpea, y el validador falla si un `DanoContacto` con `peligro` está dentro de algo que se mueve según `Vaiven.movil_de` (un `Vaiven`, un `Giro`, un `Enemigo`, un `PathFollow2D` o un cuerpo que se mueve). Revisa el contacto cada tick: quien sigue dentro vuelve a recibir daño al acabarse la invulnerabilidad. No es sólido |
| `nucleo/vaiven.gd` (`class_name Vaiven`, `Node2D`) | Pieza que va y viene en línea recta, en ticks: espera `ticks_espera` en el origen (también al empezar), recorre `recorrido` en `ticks_ida`, espera en el extremo, vuelve y repite; `desfase_ticks` la entra a media vuelta (desfasa piezas iguales). Quieta durante el congelado común. `avance_en(t)` da el avance (0 a 1) en un tick del ciclo. Una plataforma o un elevador que lleva al jugador es el `AnimatableBody2D` mismo con este script, y el `Vaiven` lo pone en `escenario` sin máscara; un cuerpo hijo de un `Vaiven` no lleva al jugador (`docs/errores/2026-10-26-plataforma-hija-de-vaiven.md`) y el validador lo rechaza. Lo que daña dentro solo golpea: lo exige el validador, no se corrige al correr. `Vaiven.movil_de(nodo)` (estática) da el primer nodo, de `nodo` hacia arriba, que se mueve (`Vaiven`, `Giro`, `AnimatableBody2D` con el `Porton`, `CharacterBody2D`, `RigidBody2D`, `PathFollow2D`): una sola lista para el validador (peligros) y el jugador (punto seguro). Medido en headless (27-oct-2026): un elevador sólido que baja sobre el jugador parado lo hunde hasta 91 px en el suelo y lo saca encima, sin daño; bajo una pieza sólida que baja hasta el suelo, el suelo mide al menos 100 px de grueso |
| `nucleo/giro.gd` (`class_name Giro`, `Node2D`) | Gira sobre su origen una vuelta cada `ticks_vuelta` ticks (negativo, al revés; 0, quieto), desde la rotación de la escena; `desfase_ticks` como en `Vaiven`. Quieto durante el congelado común. `angulo_en(t)` da la rotación en un tick. El dibujo y lo que daña son hijos; dentro de un `Vaiven` viaja y gira. Lo que daña dentro solo golpea |
| `nucleo/plataforma_delgada.gd` (`class_name PlataformaDelgada`, `StaticBody2D`) y `nucleo/piezas/plataforma_delgada.tscn` | La única plataforma de una vía (ver «Sala», «Suelos y plataformas»): crea su forma en `_ready`, `ancho` × `GROSOR` (20) con la cara de arriba en el origen, `one_way_collision` y margen `MARGEN` (1 px), en `escenario` sin máscara. Medido en headless (27-oct-2026): con 1 px no la atraviesan la caída a 20 px por tick ni la picada a 30, y caminando se cruza aunque la cara esté a 2 px del suelo; con 32 px de margen, caminar subía encima de una cara a 30 px. Se instancia la escena y se le pone su dibujo como hijo |
| `nucleo/figuras_vector.gd` (`class_name FigurasVector`, `RefCounted`, estático) | Las figuras en vector aprobadas el 21-oct-2026: `MASCARA` y `MOCHILA` (marcadores del mapa), `MONEDA` (PejeCoin del HUD, con su P: `dibujar_moneda`) y `DISQUETE` (ícono de guardado). `dibujar(lienzo, nombre, centro, alto, modulado, brillo)` dentro del `_draw` de cualquier `CanvasItem`. Cada figura mide 100 de alto con el centro en (0, 0) y lleva el contorno claro `CLARO` (el borde de las salas del mapa); sus polígonos se arman una vez con `Geometry2D.offset_polygon` y se dibujan escalados, con una línea suavizada de 1 px en cada orilla (`draw_colored_polygon` no suaviza). `piezas(nombre)` devuelve las piezas `[polígono, color]` de la figura a 100 de alto, para hornearla a imagen (`herramientas/generar_efectos.gd`, monedas sueltas). Una figura nueva es una función `_armar_<nombre>` con `pieza()` y `linea()` |
| `nucleo/reproductor_video.gd` (`class_name ReproductorVideo`, `AspectRatioContainer`) | Un video a pantalla completa sin deformar. `ReproductorVideo.crear(ruta_base, bucle, modo)` lo da sin agregar; `ruta_base` va sin extensión y cada video tiene `<ruta_base>.mp4` (H.264 a 1080, Android) y `<ruta_base>.ogv` (Theora a 480p, PC y guiones; no viaja en el APK, «Paquete de publicación»), y un video en bucle puede llevar `<ruta_base>.jpg`, la imagen de respaldo (el menú: su primer cuadro; importada con pérdida, 148 KB en el APK). `modo`: `STRETCH_COVER` llena recortando (menú), `STRETCH_WIDTH_CONTROLS_HEIGHT` ocupa el ancho (cinemática). En Android con `AndroidRuntime` (`usa_h264()`) copia el `.mp4` a `user://video/` (solo si falta o cambió de tamaño; sin `Archivo`, ver «Ciclo de vida») y lo reproduce con el decodificador del teléfono (`MediaPlayer` → `SurfaceTexture` → `ExternalTexture`, armado con `JavaClassWrapper`, sin plugin); si una llamada de Java falla (cada una se revisa con `get_exception`), si el id de la `ExternalTexture` no llega en `ESPERA_TEXTURA` (120) cuadros, si `MediaPlayer` avisa un error a mitad (`onError`, el mismo proxy que `onCompletion`), o sin `AndroidRuntime`, va al respaldo: Theora si está el `.ogv` (PC), si no la imagen; sin imagen, negro, y un video sin bucle termina al momento (la cinemática pasa a su sala; decidido por la persona el 25-oct-2026, para no cargar el APK con un segundo video). Sin ventana (`Ajustes.sin_ventana()`, la única comprobación de «sin pantalla» del juego: guiones) no reproduce nada y un video sin bucle termina a los `DURACION_SIN_VENTANA` (0,5 s). Un video sin bucle lleva un vigilante: lee la posición de `MediaPlayer` cada `REVISAR_CADA` (1 s) y, si no avanza en `SIN_AVANCE` (5 s) de reproducción (sin contar pausa ni segundo plano), termina igual: la cinemática no se queda sin salida. No se compara con la duración: medido en el S50 el 25-oct-2026, un margen fijo sobre `getDuration()` cortó el final. Un `detener()` o un `reproducir()` nuevo mientras otro espera la textura cancela al anterior (contador de generación), y con Configuración abierta arranca hasta que se cierra. `reproducir()`, `detener()`, `pausar(si)`, `desenfocar(si)` (sin video ni imagen no hace nada) (el desenfoque congelado de detrás de Configuración: lo dibuja una vez y pausa el video) y la señal `terminado` (solo sin bucle). Volumen: Theora va por el bus `Musica`; H.264 (`MediaPlayer` suena fuera de los buses) toma `volumen()`, `Master × Musica`, al empezar y al seguir tras una pausa. Al ir la app a segundo plano se pausa y al volver sigue, salvo un video sin bucle ya terminado. Plan `nucleo-video-hardware` |
| `nucleo/cinematica.gd` (`class_name Cinematica`, `Control`) | Cinemática antes de una sala: `video` (ruta sin extensión, la de `ReproductorVideo`) a lo ancho sobre negro y, al terminar, `ir_a_la_sala()` pasa a `sala_destino` (id; `Sala.ruta_de`) sin puerta de llegada. Con el modo desarrollador se salta con «Saltar» (abajo a la derecha), Atrás, `pausa`, `volver` o `ui_accept`; sin él se ve entera. Una cinemática es una escena con esta raíz y sus dos campos, en `contenido/cinematicas/` junto a su video (`cinematica_celda.tscn` → `celda_1`, `cinematica_eterno_pluma.tscn` → `celda_3`) |

## Sala

Una sala es una escena cuya raíz es un `Node2D` con `nucleo/sala.gd` (`class_name Sala`).

| Pieza | Qué es |
|---|---|
| Propiedad `id` (`String`, exportada) | `<zona>_<número>` (`celda_1`), igual al nombre del archivo. Es lo que guardan la partida y el mapa. Vacío solo en las salas de prueba sueltas de `herramientas/salas/`, que se nombran por su ruta |
| Nodo `Entrada` (`Marker2D`, hijo de la raíz) | Donde aparece el jugador. Sin él, aparece en el origen de la sala |
| Propiedad `limites` (`Rect2`, exportada) | Rectángulo de la sala en sus coordenadas; en una sala con id empieza en `(0, 0)` (lo exige el validador): el mapa pone la sala en `posicion_mapa + limites` y la mochila en la esquina de su rectángulo más su `x, y`, así que con otro origen se dibujaría corrida esa cantidad. La cámara del jugador (`CamaraJugador`) sigue al jugador y no muestra nada fuera de él en cada eje donde la sala es al menos tan grande como la vista |
| El jugador | No va dentro de la escena: la sala instancia `nucleo/jugador.tscn` en su `_ready` y le pasa `limites` |
| Suelos y plataformas | `StaticBody2D` sólidos por todos lados (decidido el 07-oct-2026, aplicado en `sala_camara` el 11-oct-2026). Por qué: en las escenas de Hollow Knight y Silksong no se encontró ninguna plataforma de una vía (un indicio fuerte, no una prueba); sin ellas no hay descenso que mantener, y una escalera se resuelve en sólido con huecos entre escalones (los de `sala_camara`, separados 160 px, guion `nucleo/camara_escalera`). Única excepción (27-oct-2026): una pieza que cuelga o se ve delgada en una ruta escondida, donde cruzarla caminando y subirse de un salto es parte de descubrirla, es una instancia de `nucleo/piezas/plataforma_delgada.tscn` (`PlataformaDelgada`, o una escena heredada de ella con su dibujo), nunca la única salida de un lugar y nunca sobre algo que se mueve (medido el 27-oct-2026: una de una vía que baja hasta el suelo pasa a través del jugador parado). El validador falla con cualquier otra forma de una vía escrita en una escena (`one_way_collision` en una `CollisionShape2D` o `CollisionPolygon2D`) y con una `PlataformaDelgada` dentro de algo que se mueve (`Vaiven.movil_de`); que no sea la única salida no se ve sin geometría: lo comprueba un guion de bajada por cada ruta. Lo que se pisa no se marca con una orilla aparte. Lo que se mueve y lleva al jugador es sólido (un `AnimatableBody2D` con `Vaiven`) |
| Controles, pausa, marco de menús, vibración, brillo, fundido, interfaz y mapa | También los crea la sala en su `_ready`: `ControlesTactiles`, `Pausa`, `Marco` (`MarcoMenus`), `Inventario` (`PaginaInventario`), `Amuletos` (`PantallaAmuletos`), `Vibracion`, `Fundido`, `Brillo` (`CanvasModulate`, ver «Ajustes y vibración»), `ContadorFps` (`nucleo/contador_fps.gd`, capa 24: el contador y el límite de 60 en menús), `PanelPruebas` y `VerHitbox` (ver «Recursos») y, si existen, `interfaz/interfaz.tscn` y `mapa/pantalla_mapa.tscn` (con `load()`, para que el núcleo no dependa de esos bloques; ver «Interfaz» y «Mapa») |
| Propiedades `tema_musica` (`AudioStream`) y `volumen_musica_db` (`float`) | La sala los pide a `Musica` en su `_ready` (se aplican en el tick siguiente: si el jugador aparece dentro de una `RegionMusica`, la región pide después y gana). Es el `MusicCue` de Hollow Knight: un tema que ya suena sigue sin empezar de nuevo, así que las salas de una zona comparten el mismo recurso, puesto en la base de la zona. Vacío no toca la música (sigue la que suena); `Musica.SILENCIO` la calla. `volumen_musica_db` es el volumen de región al entrar (`Musica.DB_SILENCIO`: callado hasta llegar a una `RegionMusica`). La Celda: `SILENCIO` hasta tener tema propio, salvo la `RegionMusica` `MusicaBanco` junto al banco de `celda_1` (tema del menú) |
| Propiedad `oscuridad` (`float`, 0 a 1) | La aplica el `Brillo` de la sala: su color es el brillo por `1 - oscuridad`, sin dibujar nada encima (`Brillo.color_para(valor, oscuridad)`). La Celda: 0,58 |
| Propiedad `posicion_mapa` (`Vector2`) | Esquina de la sala en el mapa del mundo, en px: el mapa la dibuja en `posicion_mapa + limites`. Las salas de una zona se acomodan como se recorren. Todas las zonas comparten el plano, cada una en su franja: la zona de pruebas en y de −720 a 720 (x desde 0), La Celda desde y 1440 (su sala más alta, `celda_5`, arriba; `celda_1` en (0, 2374), para que el pasillo de arriba de la sala 2 no caiga en la franja de pruebas); una zona nueva toma la siguiente franja libre hacia abajo. El validador falla si dos salas se enciman en el mapa: de zonas distintas desde el 25-oct-2026 y de la misma zona desde el 27-oct-2026 (tocarse por un borde no cuenta, `classes/class_rect2.rst:470`). Se escribe a mano y no se deriva de las puertas: cada escena se ubica sola (`tutorials/best_practices/scene_organization.rst:37`). Cambiarla obliga a regenerar el índice del mapa |
| Propiedad `botones_por_ensenar` (`Array[StringName]`) | Acciones cuyo botón de la pantalla no se ve en esta sala hasta que un `AvisoAccion` lo enseña (la sala Pizarrones empieza sin saltar, atacar ni curar; pausa y mapa se ven siempre). El validador exige que cada una sea un botón de la pantalla (`ControlesTactiles.ACCIONES`) y que algún aviso de la sala la enseñe |
| Propiedad `habilidades_de_prueba` (`Array[StringName]`) | Solo salas de prueba: habilidades que la sala da en silencio al entrar (sin aviso ni autoguardado). Las de `herramientas/salas/` dan `pluma`, salvo la de combate chico (donde se recoge), la del diálogo y la del reto. El validador la exige vacía en `contenido/` |
| Puertas (opcionales) | Instancias de `nucleo/puerta.tscn` (`class_name Puerta`, `Interactuable`) o de una escena heredada de ella con su arte (`contenido/objetos/<zona>/`, «Arte de zona»), hijas directas de la raíz. Sin hijos que dibujen, la puerta pinta un rectángulo provisional de 40 × 160 (`Interactuable.dibujar_provisional`); lo apaga cualquier hijo `CanvasItem` que no sea forma: el arte, o un `Marker2D` en una puerta sin dibujo propio (la `Boca` de los huecos de La Celda, cuyo arte es el de la sala). Ver abajo |
| Capas de fondo y de frente (opcionales) | Nodos `Parallax2D` hijos de la raíz, o de un `FondoTapado` hijo de la raíz (ver «Recursos»). `scroll_scale` menor que 1 para el fondo (más lejos, más lento) y mayor que 1 para el frente; `z_index` negativo para el fondo y positivo para el frente |

- Dónde vive cada sala: las del juego en `contenido/salas/<zona>/<id>.tscn`; las de las zonas de prueba en
  `herramientas/salas/zonas/<zona>/<id>.tscn`. La zona es lo que va antes del primer guion bajo del id: una palabra
  sin guion bajo (`celda`, `raices`).
- Al entrar, la sala se anota en `Partida.salas_visitadas`. `Sala.clave_de(nodo)` (estática) da la clave de la sala a
  la que pertenece un nodo: su `owner` si es la `Sala` y, si no, la primera `Sala` entre sus ancestros. Así un objeto
  que se recuerda puede ir dentro de una pieza instanciada (allí su `owner` es la raíz de la pieza) y se guarda en la sala.
- `Sala.ruta_de(id)` (estática) da la escena de un id (primero `contenido/`, después la zona de prueba si existe);
  una ruta `res://` pasa tal cual. `Sala.zona_de(id)` da su zona. `clave()` es el id de la sala o, si no tiene, su
  ruta: lo que guardan `Partida.sala`, la clave de los enemigos fuertes y `cambio_de_sala`.
- Los ids de sala no se renumeran nunca, aunque una sala se quite: los guardan la partida y el mapa. Una sala nueva
  toma el siguiente número libre de su zona.
- Convenciones de ids: puertas por su lado (`izquierda`, `derecha`, `arriba`, `abajo`; dos del mismo lado,
  `derecha_2`); banco `banco_<id de la sala>`; objetos que se recuerdan, un nombre corto único dentro de la sala.
- El validador revisa cada sala con id: id `<zona>_<número>` igual al archivo, en la carpeta de su zona y sin
  repetir; `limites` con área y que empieza en `(0, 0)`; `Entrada` dentro de `limites`; cada puerta con id único y destino existente, nombrado por id; puertas
  de ida y vuelta (si A lleva a la puerta P de B, P lleva de vuelta a la misma puerta de A), salvo una puerta `ABAJO`,
  que es de ida sola: basta que P exista en B (la sala de abajo la usa como llegada). Exigir la vuelta obligaría a poner
  abajo una puerta `ARRIBA` a la que no se llega, con su llegada sobre el hueco, que devolvería al jugador a la caída; y
  una puerta de caída provisional puede llegar a una puerta que ya existe sin un nodo de más; cada `FondoTapado` deja ver
  algo (`fin_pared`, en coordenadas de la sala, antes de `limites.end.x`); bancos con id
  `banco_<id>`; la raíz de cada escena de esas carpetas es una `Sala`; suelos frágiles, muros rompibles, palancas, portones,
  recogibles que se recuerdan por id (`Coleccionable`, `MonedasSueltas`), `Npc`, `RetoPreguntas` y `Tienda` con id (sin él, falla) único en la sala, también
  dentro de una pieza instanciada; en `contenido/`, `habilidades_de_prueba`
  vacío. En cualquier escena, toda ruta de nodo que la escena guarda para una variable de script resuelve (`tapas`, `descubre`,
  `portones`, `encendida`, `destello`; un export en null a propósito no guarda ruta); las `tapas` y lo que `descubre` un
  `MuroRompible` van fuera del muro y ninguno en las dos listas, y lo que descubre no tiene física (ni un
  `CollisionObject2D` dentro); la animación `entregar` de un `Npc` no va en bucle. En cualquier escena, además, el id de cada `Coleccionable` empieza con `coleccionable` y el de cualquier otro
  recogible no empieza con `coleccionable` ni `entregado_`; cada `Npc` tiene conversaciones, ninguna vacía, un id que no empieza con `coleccionable` ni
  `entregado_` y fichas sin fallos (`FichaDialogo.fallos()`, que también revisa cada `.tres` de ficha suelto); cada
  `RetoPreguntas`, un id igual de libre, `meta` entre 1 y el número de preguntas y preguntas sin fallos
  (`FichaPregunta.fallos()`, también en cada `.tres` suelto); cada puerta lleva a un id de sala o a una ruta `res://`
  que existen, y nunca a la ruta de una sala con id (una puerta en `contenido/` o en una zona de prueba nombra su
  destino por id, así una sala se puede mover de carpeta); cada `Tienda` vende algo y cada artículo tiene id sin repetir
  en su tienda, precio mayor que 0 y una `Recompensa`; cada `Estacion` va sola en su sala, es hija directa de una sala con id, se llama
  `estacion_<id de la sala>`, cuesta 0 o más y está en la tabla de su sala (`Estacion.tabla_de`) con esa sala, y cada
  `FichaEstaciones` no tiene ids repetidos ni mal nombrados (`FichaEstaciones.fallos()`); cada habilidad de un
  `ObjetoHabilidad`, de una recompensa, del requisito de un artículo y de `habilidades_de_prueba` está en
  `Habilidades.TODAS`; cada `AvisoAccion` enseña 1 o 2 acciones del InputMap, lleva id en `UNA_VEZ` y no lo lleva en `POR_VISITA`, y su id, si lo tiene, no se repite en la
  escena ni con otro objeto que se recuerda en la sala, ni usa un prefijo reservado; cada acción de
  `botones_por_ensenar` es un botón de la pantalla y algún aviso de la sala la enseña; cada puerta en el borde izquierdo
  o derecho de `limites` lleva detrás su pared, y la llegada de cada puerta cae dentro de `limites` y, salvo en una
  `PUERTA`, deja el cuerpo del jugador fuera de su área («Cambio de sala»). En cualquier escena, también: ninguna forma
  de una vía salvo la de una `PlataformaDelgada`, que no va dentro de algo que se mueve («Suelos y plataformas»);
  ningún cuerpo de física dentro de un `Vaiven` o un `Giro` salvo el nodo mismo, y ningún `DanoContacto` con `peligro`
  dentro de algo que se mueve («Componentes»); cada `ZonaCamara` y cada `RegionMusica` llevan su forma como
  `CollisionShape2D` hija directa, con forma y encendida, y una `ZonaCamara` en una sala tiene `limites` con área dentro
  de los de la sala; el tema de cada sala (`tema_musica`), el de cada `RegionMusica` y `Musica.TEMA_MENU` se repiten
  (Ogg o MP3 con `loop`, WAV con `loop_mode`; otro tipo falla; vacío y `Musica.SILENCIO` no se revisan): un tema que
  se apaga deja la sala callada sin que nadie lo pida. Esta es la lista completa de lo que revisa en las
  salas (`herramientas/validar.gd`); lo de recursos, presupuesto e importación está en «Recursos», y el mapa, en
  `posicion_mapa`.
- uid: en `contenido/`, `nucleo/`, `mapa/` e `interfaz/` (`CARPETAS_CON_UID` de `herramientas/validar.gd`) cada
  `.tscn` y `.tres` lleva `uid` en su cabecera, y cada línea `[ext_resource` lleva el `uid=` de su destino: el del
  `.uid` de un script o shader, el de la línea `uid=` del `.import` de una imagen o un sonido, o el de la cabecera de
  otra escena o recurso. Con él, la referencia sigue aunque el archivo se mueva o se renombre
  (`classes/class_resourceuid.rst:22`). Falla una línea sin `uid=`, con uno que no es el de su destino o que nombra un
  `.tscn`/`.tres` sin uid propio. Una escena escrita a mano toma los uid del disco (si un recurso nuevo aún no lo
  tiene, se importa primero); nunca se inventa uno. `herramientas/` queda fuera (escenas de prueba que se nombran por
  ruta). Fuera del editor `ResourceSaver.save` no escribe esos uid (medido el 27-oct-2026): los generadores
  (`generar_sprites`, `generar_mapa`) guardan con `guardar_con_uids` de `herramientas/validar.gd`, que conserva el uid
  de cabecera del archivo o crea uno con `ResourceUID.create_id` (`classes/class_resourceuid.rst:106`), y `con_uids`
  arregla el texto de una escena con los uid del disco.
- Áreas: la de una pieza que se ajusta a ojo en la sala (`ZonaCamara`, `RegionMusica`, recogibles, `DanoContacto`)
  lleva su forma como `CollisionShape2D` hija, editada en el editor, donde se ve; el validador la exige en `ZonaCamara`
  y `RegionMusica`. La forma se crea en código solo cuando su tamaño sale de otro dato de la pieza: la de los
  `Interactuable` que no la traen en su escena (`Interactuable._crear_forma(ancho, alto)`: `Estacion`, `Tienda`,
  `Mochila`), la zona de un `AvisoAccion` (`tamano`), la de una `PlataformaDelgada` (`ancho`), el cuerpo y las áreas
  de un `Enemigo` (`tamano` de su ficha), un `AtaqueEnemigo` (su rectángulo) y el `Golpeable` de un `MuroRompible` o
  una `Palanca`.
- Avisos del validador: además de los fallos, `validar.gd` imprime líneas `AVISO …` y una `AVISOS total=N` antes del
  resumen; no cuentan en `fallos` ni cambian la línea `VALIDACION` (`validar.ps1` muestra la cuenta tras el `OK`).
  Avisa de: una imagen de `contenido/` que ningún `.gd`, `.tscn` ni `.tres` nombra por ruta o por uid (viajaría en el
  APK sin usarse); `queue_redraw(` dentro de `_process` o `_physics_process` sin guarda en `nucleo/` y `contenido/` (cuenta como guarda un
  `return` antes en el mismo `_process` o `_physics_process`, y un script que llama a `set_process(` o
  `set_physics_process(`); una sala de `contenido/` sin un guion de `herramientas/guiones/` con una línea
  `escena <su ruta>` (por ahora solo aviso; pasará a fallo cuando todas las salas de La Celda estén al día); y, en
  `contenido/`, solo en los nodos
  de la escena misma, un nodo oculto, una forma apagada o una escala no uniforme; además, los halos de `LuzSala` que
  pasan el máximo de capas translúcidas («Recursos»). Un aviso se resuelve o se explica en el plan; no se deja crecer.
- Una capa se desplaza en proporción a la cámara: su posición es el borde de la cámara por `1 - scroll_scale`
  (medido en un guion el 06-oct-2026). Para que no queden huecos, el contenido de una capa cubre, en cada eje,
  desde 0 hasta `(tamaño de la sala - tamaño de la pantalla) × scroll_scale + tamaño de la pantalla`. Con
  `aspect=expand` la pantalla puede ser más ancha que 1280: la sala de prueba deja 2560 px de margen de cada lado.
- Cámara, como en Hollow Knight: el nodo `Camara` del jugador (`nucleo/camara_jugador.gd`, `class_name CamaraJugador`)
  se mueve a mano y recorta su objetivo a `limites` antes de suavizar, así se frena sola al acercarse al borde. No
  tiene tick propio: el jugador la llama en su `_physics_process` (seguir al final de cada tick, también congelado; el
  temblor al revisar el aterrizaje; colocarla al entrar a la sala y al reaparecer). Bajo el suelo basta el margen de siempre (40 px): sin jalón al caer
  (`camara_caida.guion`, 07-oct-2026); las salas de caída larga dejan 120 px (16,7 % de 720 de suelo a la vista).
  El margen casi no cambia el jalón (89,8 px/s por tick con 40 px, 93,1 con 120; umbral 100); las salas de 720 de
  alto no crecen, porque su cámara empezaría a moverse en vertical al saltar. Si la vista es mayor que la sala en un eje, la cámara se centra en ese eje y
  lo que sobra se ve por igual a los dos lados, como ya hacía `Camera2D` (`camara_centrada.guion`); sus `limit_*` quedan como seguro.
  Una `ZonaCamara` (ver «Componentes») recorta además esos límites mientras el jugador está en ella.
- Fondo extendido: si la sala tiene un nodo `Fondo` (`ColorRect`) visible, al entrar crea detrás de todo
  `FondoExtendido`, de su color y `MARGEN_FONDO` (280 px) más grande por lado: cubre el rango de la vista en una sala
  mínima de 1280×720 (240) más el temblor de la cámara. Sin `Fondo` visible no crea nada y lo de fuera se ve negro, el color de borrado.
- Fundido a negro (`nucleo/fundido.gd`, `class_name Fundido`, `CanvasLayer` capa 15: encima del juego, los controles y
  la interfaz, que se oscurecen con él, y debajo de la pausa y el editor de botones): la sala lo crea en negro y aclara
  en `TICKS_ACLARAR` ticks (0,25 s), o en `TICKS_ACLARAR_PUERTA` (0,5 s) si se llegó por una puerta. Ante un
  `fundido_pedido` (un peligro: `TICKS_OSCURECER`, 0,15 s, y `TICKS_EN_NEGRO_PELIGRO`, 0,3 s) oscurece, sigue en negro
  y aclara; cuenta ticks de física, así los guiones dan siempre lo mismo. Su `opacidad` (0 a 1) la leen los guiones
  (`fundido_peligro`, `fundido_peligro_sostenido`, `fundido_puerta`). Es además el único dueño del cambio de sala
  (abajo, «Cambio de sala»).

Cambio de sala:

| Propiedad de `Puerta` | Qué es |
|---|---|
| `id` | Texto único dentro de su sala |
| `sala_destino` | Id de la sala a la que lleva (`prueba_2`); la puerta cambia a `Sala.ruta_de(sala_destino)`. Una ruta `res://` solo para ir a una sala de prueba suelta, sin id |
| `puerta_destino` | `id` de la puerta de la sala destino donde aparece el jugador |
| `llegada` | Dónde aparece el jugador al llegar por esta puerta, relativo a ella; dentro de `limites` y, salvo en una `PUERTA`, con el cuerpo del jugador fuera de su área para no rebotar (lo revisa el validador) |
| `tipo` | `Puerta.Tipo`, lo decide el arte: `LADO` (pasillo, se cruza al entrar), `PUERTA` (puerta en la pared, se cruza con `interactuar` y su aviso), `ARRIBA` y `ABAJO` (hueco del techo o del piso, se cruzan al entrar) |
| `punto_seguro` | Punto seguro de esa llegada, relativo a la puerta, para una llegada sin suelo debajo (un hueco del techo). `(0, 0)`: no tiene |
| `mirar_al_llegar` | Solo `PUERTA`: hacia dónde mira el jugador al salir de espaldas (1, -1); 0, hacia el centro de la sala |

- Sala aparte o `ZonaCamara`: un tramo que se ve como otro espacio, o que se entra por un hueco del techo o del piso, es
  una sala aparte con puerta `ARRIBA`/`ABAJO` y fundido (`celda_5` sobre `celda_2`, como `top1`/`bot1` de Hollow
  Knight); un tramo del mismo espacio que la cámara no debe mostrar junto es una `ZonaCamara` dentro de la sala. El
  hueco es una pieza de zona heredada de `nucleo/puerta.tscn` con su forma y tipo (`hueco_techo`, `hueco_piso`), no
  una puerta con hijos abiertos.
- El `Fundido` de la sala es el único que cambia de sala (como `BeginSceneTransition` de Hollow Knight): la puerta, la
  `Estacion` y la muerte le piden `cambiar_sala(ruta, llegada, id_llegada, perfil, retraso, jugador)` y la cinemática,
  sin fundido propio, llama a `Fundido.ir_a_sala`. Uno a la vez: un segundo pedido devuelve `false`, y mientras hay uno
  en curso otro `fundido_pedido` no cambia la pantalla. Ya en negro emite `en_negro`; si el jugador que pidió murió
  mientras oscurecía, no cambia de sala (manda la muerte); si no, escribe la llegada en las estáticas de `Sala` y llama a
  `change_scene_to_packed` en diferido, y si no existe la escena o el cambio devuelve un error lo imprime (`ERROR:`),
  deja vacías las estáticas de llegada, aclara y emite `cambio_fallido`: la `Estacion` limpia su viaje y suelta al
  jugador (`dejar_de_hablar`) y la `Puerta` vuelve a servir (el jugador recupera el control por su tope). Mientras la
  puerta espera su `retraso`, una fase anterior del fundido (un aclarado) sigue avanzando. Perfiles
  (`Fundido.ticks_de`): `PUERTA` oscurece 20 ticks, negro 10 y la sala nueva aclara en 30 (los de Hollow Knight);
  `ESTACION` 9, 6 y 15; `MUERTE` 9 y 0, al final de los 90 ticks oscuro, con las vidas llenadas en `en_negro`.
- Al cruzar, la puerta pone al jugador en transición (`Jugador.salir_de_sala`, como `HeroTransitionState`): no recibe
  daño ni peligros, no interactúa y no lee los controles; se mueve siempre con `move_and_slide`. `LADO` sale caminando
  hasta la pared de detrás; `PUERTA` se pone en la x de la puerta, se voltea (los primeros `CUADROS_GIRO_PUERTA` cuadros
  de `entrar_puerta`, que la puerta pasa como `retraso`) y se mete; `ARRIBA` y `ABAJO` siguen con la velocidad vertical
  que llevaban. Si en `Fundido.ticks_hasta_cambio + Puerta.MARGEN_TOPE` ticks la sala no cambió, recupera el control
  con un `ERROR:`. Al llegar (`entrar_a_sala`): por `LADO` entra caminando 20 ticks; por `PUERTA` sale de espaldas
  (`salir_puerta`); por `ARRIBA` o `ABAJO`, con el control. El `punto_seguro` de la puerta va primero en el respaldo de
  `Jugador.ultimo_punto_seguro`, antes de la llegada.
- En un build de depuración, el primer tick de la sala nueva imprime
  `SALA <clave> carga_ms=<n>`: lo que pasó desde que el Fundido pidió el cambio (`Sala.cambio_pedido_ms`). Las salas no
  se cargan en segundo plano; se reconsidera si una puerta pasa de ~0,5 s en el S50 con salas reales. La sala nueva pone al jugador en `llegada` de esa puerta. Si no la
  encuentra, imprime un `ERROR:` y lo pone en `Entrada`. Ese error ocurre al correr: lo atrapa un guion que cruza
  la puerta, no `validar.ps1`.
- El viaje rápido llega igual que una puerta: la `Estacion` de salida le pasa al `Fundido` el id de la de llegada,
  que lo escribe en `Sala.estacion_llegada` (estática) al cargar la escena, y la sala nueva pone al jugador en `position + llegada` de la `Estacion` con
  ese id, sin emitir `cambio_de_sala`. Si una puerta y una estación piden a la vez, manda la estación; reaparecer en un banco manda sobre las dos.
  Las dos estáticas se vacían al entrar a la sala y al reaparecer.
- El área de la puerta mide 40×160 y el salto sube 230 px: una puerta en el borde de `limites` lleva detrás un
  `StaticBody2D` invisible, fuera de los límites y del alto de la sala (`ParedTrasPuerta`). Sin él, un salto la
  pasa por encima y el jugador cae fuera de la sala (`docs/errores/2026-10-14-salto-sobre-puerta.md`). El validador
  lo exige: una puerta cuya área toca el borde izquierdo o derecho de `limites` necesita un `StaticBody2D` pegado a
  ese borde por fuera, desde lo alto de `limites` hasta el pie del área.
- Lo que sobrevive al cambio de sala vive en `Partida` (ver «Estado de la partida»).

Bancos:

- `nucleo/banco.tscn` (`class_name Banco`, `Interactuable` con `con_aviso` en falso: sin aviso), hijo directo de la
  raíz de una sala. Sin hijos que dibujen pinta un rectángulo provisional de 120 × 40 (`dibujar_provisional`); el arte
  de la sala, colgado como hijo de la instancia (la silla de `celda_1`), lo apaga sin abrir la escena. Con el jugador encima, en el suelo y vivo, la acción `interactuar` recién
  pulsada y sin `Congelado.activo()` (el disparador de la base, como en el `Npc`) lo hace descansar: sienta al jugador sobre el banco (`sentarse(x, lado)`:
  queda en la x del banco, quieto y dibujado más bajo, `descansando`, mirando hacia `mirando` del banco: 1 derecha,
  -1 izquierda, 0 como llegó; el de La Celda mira a la derecha, como su silla), llena las vidas, guarda en `Partida.banco` su
  `id` y en `Partida.sala` la clave de la sala, emite `Eventos.descanso_en_banco(id)` y después guarda la partida
  (`Partida.guardar(ruta_guardado)`), para que lo que cambia al descansar entre al archivo. Sentado, `interactuar` no vuelve a descansar. Se levanta con `mover_izquierda`,
  `mover_derecha`, `mover_abajo`, `saltar` o `atacar` recién presionadas, sin saltar ni atacar; un golpe también lo
  levanta.
- `id` es único en todo el juego. Con `ruta_guardado` en `Guardado.RUTA` (por omisión) guarda en
  `Partida.ruta_guardado`; una sala de prueba puede fijar otro archivo.
- `Sala.llegada_a_banco` (estática): la sala nueva (`Sala.ruta_de(Partida.sala)`) pone al jugador en el banco `Partida.banco`. La usan la
  reaparición y entrar a una ranura con banco (`preparar_ranura` del menú). Sin ese banco en la sala, imprime un `ERROR:` y usa `Entrada`.

Las salas de prueba viven en `herramientas/salas/`, y las pruebas de código, en `herramientas/pruebas/` (ver
«Paquete de publicación»).

## Enemigos

Un enemigo es una instancia de `nucleo/enemigo.tscn` (`class_name Enemigo`, `CharacterBody2D`), hija directa de la raíz de
una sala, con su ficha y un `id` único dentro de la sala (el validador falla un `Enemigo` sin ficha, con ficha sin `id`
o con `vida` de 0 o menos, o con un `comportamiento` que no hereda de `ComportamientoEnemigo`, y repite el chequeo del
`id` de cada ejemplar como el de las demás piezas que se recuerdan; `validador-enemigos`). Un enemigo nuevo es una ficha `.tres`; cómo se mueve y
ataca es un script que la ficha referencia (`comportamiento`), en `contenido/enemigos/` (los de prueba, en
`herramientas/salas/comportamientos/`). El núcleo lo agrega sin saber cuál es; sin script, el enemigo se queda quieto.

| Campo de `FichaEnemigo` (`nucleo/ficha_enemigo.gd`, `Resource`) | Qué es |
|---|---|
| `id` (`StringName`) | Id estable del tipo de enemigo; es lo que emite `enemigo_vencido` |
| `vida` (2) | Vida al aparecer; cada golpe le resta su daño (ataque 1, bola 2) |
| `dano_contacto` (1) | Vidas que le quita al jugador al tocarlo (golpe normal, con retroceso) |
| `tamano` ((80, 80) px) | Su cuerpo, con los pies en el origen; las formas del golpe y del contacto se crean con él |
| `color` | Color de la caja gris mientras no hay arte |
| `reaparicion` | `AL_VOLVER_A_ENTRAR` (débil) o `AL_DESCANSAR` (fuerte: vuelve al descansar y al morir el jugador) |
| `comportamiento` (`GDScript`) | Script que hereda de `ComportamientoEnemigo`; vacío, quieto |
| `velocidad` (0) | Rapidez al moverse, en px/s, para su comportamiento |
| `gravedad` (0) | En px/s²; 0: vuela (`MOTION_MODE_FLOATING`: sin suelo, todo choque cuenta como pared); con gravedad, `MOTION_MODE_GROUNDED` |
| `caida_maxima` (1200) | Rapidez máxima al caer, en px/s |

- El enemigo es un cuerpo en la capa `cuerpo_enemigo` que mira `escenario`: choca con suelos y paredes y el jugador
  lo atraviesa (lo daña su `DanoContacto`). Su forma de cuerpo, hija directa, se crea con `tamano`. `mirando` (-1 o 1)
  es pública.
- Lo que se ajusta por tipo de enemigo va en la ficha: el comportamiento se crea con `.new()` desde la ficha, sin
  datos por ejemplar, y sus valores fijos son `const`.

- El enemigo lleva un `Golpeable` (recibe los golpes; público como `golpeable`) y un `DanoContacto` (su cuerpo, que
  daña al jugador y nunca se para). A vida 0 emite `Eventos.enemigo_vencido(ficha.id)`, pide el congelado común y
  desaparece.
- `nucleo/comportamiento_enemigo.gd` (`class_name ComportamientoEnemigo`, `Node`): hijo del enemigo, con `enemigo`
  fijado. Cada tick fuera del congelado llama `actuar()`, que cada comportamiento sobrescribe. Ofrece `jugador()`,
  `atacar(rectangulo, ticks, dano, se_puede_parar)` (un `AtaqueEnemigo` hijo del enemigo, relativo a sus pies) y
  `disparar(desplazamiento, direccion, dano, se_puede_parar)` (un `ProyectilEnemigo` en la sala). Para moverse:
  `caer()` (la gravedad de la ficha con su tope), `mover()` (`move_and_slide`), `en_suelo()`, `pared_delante(sentido)`
  y `orilla_delante(sentido)` (rayos contra `escenario` a media altura y desde la punta del pie, 12 px más allá del
  cuerpo), `ve_al_jugador(radio)` (distancia entre centros y ningún sólido en medio), `centro()` y `girar()`.
  `lanzar_en_arco(desplazamiento, objetivo, grados, gravedad, tope, dano, se_puede_parar)`: un `ProyectilEnemigo` en
  arco que cae en `objetivo`.
- El empuje de su `Golpeable` no saca de una orilla a un enemigo que camina y está en el suelo.
- `nucleo/ataque_enemigo.gd` (`class_name AtaqueEnemigo`, hereda de `DanoContacto`): el ataque, separado del cuerpo;
  daña mientras dura (`ticks`; 0, hasta que lo quiten) y no corre durante el congelado. No se dibuja (su área se
  ve con «Ver hitbox»; decidido por la persona el 25-oct-2026). Con `se_puede_parar` al empezar deja el mismo trazo
  blanco que el golpe del jugador
  (`TrazoAtaque`, hijo `Trazo`, de lado y hacia donde está su forma; un `ProyectilEnemigo` no, `con_trazo`). `parado` es pública.
- `nucleo/trazo_ataque.gd` (`class_name TrazoAtaque`, `Sprite2D`): la media luna blanca de un golpe
  (`nucleo/arte/trazo_ataque.png`, 256 px, la genera `herramientas/generar_trazo.gd` con la cuenta del mockup).
  `mostrar(centro_area, direccion, mirando)` la coloca con `TrazoAtaque.pose()` (función pura: `DESDE_AREA` girado
  hacia donde pega, espejado a la izquierda; arriba −90° y abajo +90°); aparece a los `TICKS_RETRASO` (4) ticks,
  dura `TICKS_DURA` (8), crece de 0,9 a 1,05 de `LADO_PX` (190) y se desvanece con 0,95·(1−p²). Cuenta ticks de
  física (quieta en la pausa y el congelado) y va sin luz (`LIGHT_MODE_UNSHADED`, el material compartido de
  `EfectoCuadros.material_sin_luz()`): ni la oscuridad de la sala ni el brillo la apagan.
- `nucleo/efecto_cuadros.gd` (`class_name EfectoCuadros`, `Sprite2D`): un efecto dibujado como hoja de cuadros
  (`nucleo/arte/efecto_*.png`, las genera `herramientas/generar_efectos.gd`). `EfectoCuadros.crear(textura, cuadros,
  filas, aditivo, una_vez, corre_congelado)`; avanza un cuadro cada `TICKS_POR_CUADRO` (3) ticks de física (20
  cuadros/s), en bucle o una vez y se libera; `fila` elige la fila de la hoja y `reiniciar()` vuelve al primer cuadro.
  Sin luz; con `aditivo`, mezcla aditiva (`LuzSala.material_aditivo()`, el mismo de los halos). Quieto en el congelado
  salvo con `corre_congelado`. Lo usan el destello del parry, la bola y el aura de curar (`docs/jugador.md`,
  «Dibujo»); un enemigo con parry lo usa igual.
- `nucleo/proyectil_enemigo.gd` (`class_name ProyectilEnemigo`, hereda de `AtaqueEnemigo`): `crear_disparo` avanza
  recto a `velocidad` (480 px/s); `crear_arco(velocidad_inicial, gravedad, ...)` cae con su propia `gravedad`. Los
  dos, hasta un sólido (rayo que cubre el paso del tick) o 180 ticks. `velocidad_para(objetivo, grados, gravedad,
  tope)` da la velocidad inicial con ángulo fijo y rapidez calculada (como Silksong), sin pasar de `tope`.
- Parry: el ataque normal del jugador (en cualquier dirección) que toca un `AtaqueEnemigo` con `se_puede_parar` lo
  para: el ataque desaparece sin dañar, el jugador queda `ticks_invulnerable_parry` (15) ticks sin daño de enemigos
  (los peligros sí dañan), congelado común de `ticks_congelado_parry` (20) con un destello de luz en la punta de la espada (`docs/jugador.md`, «Dibujo»), después el jugador sale empujado hacia atrás (`ticks_retroceso_parry`) y su carrera o voltereta se corta, el enemigo dueño del ataque recibe el golpe (su `Golpeable` lo empuja)
  (con su Inspiración) y se emite `parry`. Lo resuelve quien se procese primero: el jugador en su ataque o el
  `AtaqueEnemigo` antes de dañar (`Jugador.intentar_parar`). `paradas` del jugador las cuenta.
- Un `ProyectilEnemigo` con `se_puede_parar` no se para: se desvía (decidido por la persona el 25-oct-2026, como la
  versión ligera del choque de Silksong, `noClashFreeze`). Desaparece con una chispa (el destello del parry a la mitad, `ESCALA_CHISPA`), sin
  congelado, cuerpo en blanco, retroceso, invulnerabilidad ni Inspiración, y se emite `objeto_golpeado` (suena y vibra como
  pegarle a un objeto), no `parry`. `desviados` del jugador los cuenta.
- Débil: reaparece solo, porque la sala se instancia de nuevo cada vez que se entra. Fuerte: al vencerlo,
  `Partida.vencer(clave())` lo anota y, mientras siga anotado, no aparece al entrar a su sala. La lista se borra
  al descansar en un banco y al morir el jugador (como los semipersistentes de Hollow Knight).
- Enemigos nuevos (decisión del 14-oct-2026): con estas mismas piezas (`Golpeable`, `DanoContacto`, comportamiento en
  la ficha); sus estados, con un `enum` mientras sean pocos; las zonas de golpe, formas invisibles aparte del dibujo;
  la animación, con `AnimatedSprite2D`.
- Jefes (misma fecha): sin base común hasta que exista el segundo. La arena se cierra con una pared que se quita al
  vencerlo; morir en la arena lleva al banco, abre la arena y el jefe empieza de nuevo.

## Contenido que viene

Decisiones del 14-oct-2026 para lo que aún no existe; cada una se vuelve código con su primer caso.

- Salas: Claude escribe cada sala completa como `.tscn` (formas, puertas, objetos y decoración); la persona la revisa
  en el editor si quiere. Confirmado el 27-oct-2026 con tres condiciones: ningún generador de escenas fuera del repo
  (dos fuentes de verdad); se conservan el `uid` y los ids de `ext_resource` de lo que ya existe; y cada
  `ext_resource` lleva su uid, que el validador exige («Sala», uid).
- Audio: efectos en WAV y música en Ogg Vorbis; cada sala dice su tema (`Sala.tema_musica`; el mismo recurso en las
  salas de una zona, puesto en su base) y lo toca `Musica`, hija de `Arranque`, sin cortarlo al cruzar una puerta;
  `RegionMusica` cambia el tema o el volumen dentro de una sala (27-oct-2026; reemplaza «cada zona dice su música en
  su ficha»: no hay ficha de zona hasta tener tres casos).
- Exportación: APK directo; una sola máquina exporta las versiones; la clave de publicación la genera la persona y
  se guarda fuera del repo.
- Idioma: solo español en la v1; cada texto se escribe completo, sin frases armadas a pedazos.

## Arte de zona

Criterio para el arte de las salas de una zona (decidido el 27-oct-2026). Lo mecánico (tamaños, importación,
presupuesto, uid, escala no uniforme, imágenes sin uso) lo revisa el validador («Recursos» y «Sala»); aquí queda lo
que se decide mirando.

- Capas: la misma escalera en todas las salas con fondo, `scroll_scale.x` y `z_index`: profundo 0,05 (−100), lejana
  0,18 (−90), media 0,5 (−80), el plano de juego a 1, la niebla 1,1 (15) y el frente 1,45 (20). Más lejos, más lento
  (`tutorials/2d/2d_parallax.rst:35-39`). En una sala con desplazamiento vertical (`celda_2` a `celda_4`), cada capa
  lleva `scroll_scale.y` igual a su x: el frente (1,45; 1,45), la niebla (1,1; 1,1) y los fondos con su valor en los
  dos ejes (`classes/class_parallax2d.rst:22`). Las capas de fondo se exportan reducidas («Recursos», receta del
  arte).
- Color: lo que lastima tiene puntas y es cálido; el turquesa queda para lo vivo (hongos, raíces que no dañan).
  Excepción (27-oct-2026): en la bajada hacia Las Raíces, los peligros toman el color de la zona a la que llevan: las
  espinas de la sala 4 de La Celda, cuando entren (hoy no tienen un uso claro y no están en la sala), llevan
  puntas turquesa (`#5fe0c8`, brillo `#b8fff0`), como sus hongos. Un
  peligro se distingue del fondo por valor y color, siempre tiene una señal que se ve entre una ráfaga y otra (una
  `LuzSala` chica o el dibujo encendido, no solo chispas), y su forma de daño sigue al
  dibujo, un poco más chica.
- Lo que se pisa o se salta (28-oct-2026, tras una prueba con jugadores en el S50): una pieza con colisión nunca
  reutiliza arte de decoración ni de fondo (en `celda_2` la columna que se salta era el pie de la columna de la pared
  y se leía como fondo). Lleva arte propio de pieza jugable: contorno más grueso, la cara de arriba iluminada y un
  acento cálido que la separa de la decoración. Se apoya en el piso con escombros o losa rota en la base, hundida unos
  px y dibujada delante del canto del suelo, para que no parezca pegada encima. Detrás de ella, el fondo no repite su
  forma ni su tono.
- Frente: las mismas piezas del kit teñidas de negro con un solo `modulate` casi negro en el nodo `Frente` y el
  material sin sombreado, como Hollow Knight. Lo que se apoya en el piso no asoma más de 40 px por encima de él (no
  tapa los pies del jugador); lo que cuelga del techo (cadenas, cables, raíces) baja desde arriba de la vista y no
  llega a la altura de la cabeza del jugador sobre el piso por donde se camina. El `modulate` se hereda a los hijos (`classes/class_canvasitem.rst:645`): lo que debe brillar
  delante (chispas) va en su propio nodo, fuera de `Frente`. Excepción (28-oct-2026): el frente de `celda_1` conserva
  sus siluetas propias (`s_*` y `frente_mesa`, a su escala), más altas que 40 px, por decisión de la persona.
- Escala de capa: exacta y uniforme, la que compensa su exportación (media ×2, lejana ×4, profundo ×8; el frente, la de la pieza del kit que repite); si
  una pieza no cubre el ancho, se repite (`repeat_size` o `region`), no se estira. Una sala de más de una pantalla de
  alto pone `scroll_scale.y` igual a `x` en sus capas, y recoloca lo que va apoyado en el piso de la capa: con la
  cámara con su borde de arriba en T, una pieza puesta en Y dentro de la capa se ve en pantalla en
  Y − `scroll_scale.y` · T (la regla de desplazamiento de «Sala»), así que una silueta del frente se coloca en la Y que la apoya en el piso
  visible desde la altura de cámara en que se ve.
- Bordes: todo borde de capa o de pared que la cámara alcanza a ver termina en una pieza de orilla o en negro con
  degradado, nunca en un corte recto; si no hay pieza, se recortan los `limites` a donde acaba el arte.
- Huecos y roturas (28-oct-2026, salas 2, 3 y 5 de La Celda, probado en el S50): un hueco en losa, techo o pared
  lleva a cada lado una pieza de orilla rota (concreto con varillas, `orilla_hueco.png`, con el lado que toca la losa
  fundido a transparente para que se funda con el techo o el piso de debajo), volteada con `flip_h` y `flip_v` según
  el lado y con un `modulate` medido para que su tono sea el de la losa en la captura. Si el hueco lo abre un
  `MuroRompible`, sus orillas van en `descubre` (ocultas hasta romperlo; el estado guardado las muestra al entrar) y
  van en el árbol después de la pared de fondo, para que el fondo no las tape. Por eso cada pared o losa que se rompe
  pide su arte de «estado roto»: la orilla y lo que se ve detrás.
- Lo que se ve por un hueco: la pared de fondo sigue por detrás de la losa, más oscura, y se apaga a negro con un
  degradado (no se corta en la cara de la losa); el negro lo pone una tira de degradado horizontalmente uniforme
  (`tiro_hueco.png`, repetida con `region` y `texture_repeat`, sin escalar), colocada para que su parte opaca tape la
  orilla de arriba de la pared que asoma. La misma tira, volteada (`flip_v`), apaga bajo el piso una pared que baja hasta
  el límite de la sala (`celda_5`, `BajoPiso`), en vez de un `ColorRect` negro con orilla recta.
- Lo que cuelga del techo (columnas, capiteles) se apoya en la cara de la losa, no en la orilla de abajo de las vigas:
  en `techo.png` la losa termina en la fila 74 y las vigas en la 111.
- Lo que se pisa no se marca con una orilla aparte («Sala», «Suelos y plataformas»): la superficie la dice el dibujo,
  y la forma de colisión coincide con su borde.
- Kit: una zona nueva se pide como kit desde el principio: tiras de pared, piso y techo que se repiten sin costura
  (con `region` y `texture_repeat`), piezas de orilla, de 10 a 20 calcomanías y pocas piezas únicas. La Celda se queda
  con su arte aprobado; su azulejo tiene un solo módulo, 38,5 px, en toda la zona.
- Atlas: ninguno por ahora. En La Celda los FPS no los decidían los draw calls (lo medido está en «Recursos»), y lo
  que se repite con `region` no puede ir en un atlas (`classes/class_atlastexture.rst:26`). Si una sala llega a ir
  bajo 60 FPS por draw calls, primero se juntan por `z_index` las piezas de la misma textura
  (`tutorials/performance/gpu_optimization.rst:44-52`); después, un atlas solo de adornos chicos, por zona y por capa,
  escrito por un script del repo.
- Compresión: Lossless por omisión («Recursos»). Una imagen grande sin un solo píxel transparente puede ir en VRAM
  Compressed (ETC2 en el teléfono, `importing_images.rst:290`) solo después de una captura en el S50 de la sala con y sin ella, a
  zoom 1 y 2, sin bloques visibles; el profundo de La Celda, escalado ×8, se queda en Lossless (cada bloque de 4 px se vería
  de 32). Si lo que pesa es el APK y no la memoria, Lossy (`importing_images.rst:180-183`).
- Base de la zona: `contenido/zonas/<zona>/sala_<zona>.tscn` (fuera de `contenido/salas/`: no es una sala con id).
  Raíz `Sala` con lo de toda la zona (`oscuridad`, `tema_musica`) y los grupos vacíos con su `z_index`: `Entrada`,
  `Juego` (−20), `SueloPintado` (−5), `Terreno` (los `StaticBody2D`), `Peligros`, `Encima` (11), `Luces` (13) y
  `Frente` (`Parallax2D` a 1,45 y z 20; la sala alta le pone 1,45 también en y, con el `modulate` casi negro y `sin_luz.tres`; cada hijo lleva
  `use_parent_material`). Cada sala es una escena heredada de la base y cambia solo lo suyo; lo que no tienen todas
  las salas (fondos, niebla) no va en la base, porque de una escena heredada no se quita un nodo.
- Piezas de la zona: `contenido/objetos/<zona>/`, una escena por pieza con sus valores dentro (la sala no repite
  literales): la luz de tubo (raíz `LuzSala`, con su imagen apagada en z −20 y la encendida en z 11, absolutas con
  `z_as_relative = false`), el polvo del tubo (raíz `CPUParticles2D` en z 12 absoluto, aparte de la luz para que
  el panel de pruebas apague por separado luces y partículas), las puertas con arte (escenas heredadas de `nucleo/puerta.tscn`: el arte como hijo
  apaga el rectángulo provisional), los peligros (raíz `DanoContacto` o el foso con su fondo sólido: `nucleo/piezas/foso.tscn` es la pieza genérica —`Dibujo` sin textura, `Peligro` y `Fondo`— y `contenido/objetos/celda/foso_varillas.tscn` hereda de ella con su textura), los colgantes del
  frente (`colgante_frente.tscn`, raíz `Colgante` con `use_parent_material`), los avisos con arte propio
  (`pizarron_patas.tscn`, raíz `AvisoAccion` con el dibujo como hijo `Sprite2D`, que apaga el pizarrón gris) y las capas de
  fondo (raíz `Parallax2D`: la sala les cuelga sus trozos y cambia solo la raíz). Una sala nunca abre los hijos de
  una pieza («Editable Children»): lo que cambia por sala es una propiedad de la raíz o una pieza aparte.

## Interfaz

Bloque `interfaz/`: lo que se dibuja encima del juego. `interfaz/interfaz.tscn` (`CanvasLayer` `Interfaz`, capa 10)
con un `Control` `Hud` (`interfaz/hud.gd`, `class_name Hud`). La sala lo carga con `load()` si la escena existe
(`Sala.INTERFAZ`).

- Se entera de todo por el bus (`vidas_cambiadas`, `inspiracion_cambiada`, `monedas_cambiadas`, `partida_guardada`,
  `descanso_en_banco`, `jugador_muerto`, `tienda_abierta`, `tienda_cerrada`) y lee `Partida` una
  sola vez al crearse, para el primer cuadro. Nunca lee al jugador.
- Corazones arriba a la izquierda, uno por vida máxima, llenos o vacíos; debajo, la barra de Inspiración en bloques
  de `Partida.INSPIRACION_POR_GOLPE` (11, lo que da un golpe por omisión) hasta `INSPIRACION_MAXIMA`, con el bloque
  a medias dibujado a medias. Centro del grupo en (17 %, 12 %) de una pantalla 16:9 (`Vista.PROPORCION_BASE`),
  anclado arriba a la izquierda y medido en el lado corto; una vida más crece hacia la derecha.
- PejeCoins bajo la barra, como el contador de Silksong: la PejeCoin bimetálica (`FigurasVector.dibujar_moneda`,
  `DIAMETRO_MONEDA` 1,04 del tamaño de letra: 26 px a 1280×720) y el número.
  - Al entrar a la sala están ocultas.
  - Con `monedas_cambiadas` aparecen en `TICKS_APARECER` (6) con el «+N» o «−N» al lado; las ganancias seguidas lo
    suman.
  - Esperan `TICKS_ESPERA_CONTEO` (60), y cada cambio reinicia la espera. Después cuentan hasta el valor nuevo en
    unos `PASOS_CONTEO` (34) ticks y quitan el «+N».
  - Con `jugador_muerto` y un «−N» pendiente, la espera baja a `TICKS_ESPERA_MUERTE` (20): el conteo llega a 0 antes
    de que la sala oscurezca para reaparecer.
  - Siguen `TICKS_A_LA_VISTA` (90) y se desvanecen en `TICKS_DESVANECER` (18).
  - `descanso_en_banco` las muestra sin contar.
  - Con una tienda abierta (`tienda_abierta`) aparecen y se quedan fijas (`monedas_fijas`), como en los dos juegos:
    el panel de la tienda va en la mitad derecha y el HUD queda a la vista en la izquierda, en su capa 10, debajo del
    menú. Mientras tanto el `Hud` corre con el árbol detenido (`process_mode` `PROCESS_MODE_ALWAYS`), así que lo que
    se compra cuenta y el ícono de guardado respira. Con `tienda_cerrada` vuelve a `PROCESS_MODE_INHERIT` y, si ya no
    cuenta, siguen `TICKS_A_LA_VISTA` y se desvanecen.
  - El total siempre está en el inventario.
  - Son un nodo propio, como el ícono de guardado: contar no redibuja corazones ni barra.
- Ícono de guardado: el disquete (`FigurasVector.DISQUETE`, 36 px a 1280×720) bajo las PejeCoins, alineado a la
  izquierda del grupo, durante 2 s después de `partida_guardada`. Respira: escala de 0,94 a 1,06 y un blanco de hasta
  0,18 encima, en un ciclo de `TICKS_RESPIRAR` (72) con curva de coseno. Es un nodo propio que se redibuja solo
  mientras se ve: no redibuja el resto de la interfaz. Los corazones y la barra se quedan en gris (decidido por la
  persona el 21-oct-2026).
- `vidas`, `vidas_maximas`, `inspiracion`, `inspiracion_maxima`, `bloques_llenos`, `monedas` (el valor real), `monedas_mostradas`, `monedas_pendientes`, `monedas_visibles`, `monedas_fijas` y `aviso_visible` son públicas: los
  guiones las leen con `valor Interfaz/Hud`.

## Mapa

Bloque `mapa/`: no conoce ninguna zona; dibuja lo que hay y, si no hay nada, no dibuja. La sala carga
`mapa/pantalla_mapa.tscn` con `load()` si existe (`Sala.MAPA`), y el `MenuEstaciones` del núcleo lee los
`rectangulos` de `mapa/indice_salas.tres` con `load()` si existe y `get()`, sin nombrar `IndiceSalas` (ver
«Componentes»): mover el índice o renombrar ese campo deja el viaje rápido sin mapa, con la lista sola. `mapa/` viaja
en el paquete de publicación (el `exclude_filter` de «Publicacion» no lo nombra).

- `PantallaMapa` (extiende `PaginaMarco`: capa 20, grupo `pagina_marco`, corre en pausa): la página Mapa del marco de menús
  (ver «Marco de menús»); la acción `mapa` abre el marco en ella. `mapa_rapido` mantenida muestra el mapa encima sin
  detener el juego (como en Hollow Knight y Silksong), solo si empezó a pulsarse con el juego andando; la pantalla
  nueva de la sala siguiente lo sigue mostrando si se sostiene al cruzar una puerta. Corre en la física antes que el
  marco y la pausa (prioridad 0 frente a `MarcoMenus.PRIORIDAD_FISICA`): en el tick en que cierran aún ve la pausa.
- Dos estados del mapa completo: acercado (las salas de la zona actual con borde, o su dibujo) y alejado (cada zona
  como la silueta rellena de sus salas, con su nombre); abre acercado, y los botones «–» y «+» cambian (raya corta U+2013: Cabin Sketch no tiene el signo menos). Si la zona
  actual no tiene nada dibujado, se ve alejado. El mapa rápido siempre va acercado.
- Se dibujan las salas de `Partida.salas_mapeadas` (las llena el banco: ver «Estado de la partida») que están en el
  índice, solo con la habilidad `pluma_mapa`. El jugador se marca solo con el amuleto `brujula` en
  `Partida.amuletos_equipados`, en `posicion_mapa + posición del jugador`, con la máscara
  (`FigurasVector.MASCARA`, 36 px), como la cabeza del Caballero en Hollow Knight.
- La mochila (lo perdido al morir) se marca con la mochila en vector (`FigurasVector.MOCHILA`, 38 px), sin amuleto, si su sala está entre las dibujadas, en la
  esquina del rectángulo de su sala más su `x, y` (todas las salas empiezan sus `limites` en `(0, 0)`), como el capullo
  de Silksong. `mochila_visible` y `mochila_en_pantalla` del lienzo son públicas.
- `mapa/objeto_mapa.tscn` (`class_name ObjetoMapa`, un `Recogible` del núcleo): al tocarlo, su `zona` (vacía: la de
  la sala) pasa por `Partida.obtener_mapa` (avisa con `mapa_obtenido` y autoguarda) y desaparece; si ya se tiene, no
  aparece. No usa `id`: lo recuerda `Partida.mapas`. Sin zona (fuera de una sala con id) no se consume: se queda a la
  vista y no entrega nada, como antes de heredar de `Recogible`.
- `mapa/indice_salas.tres` (`IndiceSalas`): por cada sala con id, su rectángulo en el mundo, su ruta y, si existe
  `<id>_mapa.png` junto a la sala, su dibujo (que reemplaza al rectángulo). Lo escribe
  `herramientas/generar_mapa.tscn` y el validador falla si no coincide con las salas: el paquete exportado no deja
  listar escenas con fiabilidad. No se edita a mano.
- El dibujo y las cuentas van aparte: `mapa/lienzo_mapa.gd` (`class_name LienzoMapa`, `Control`, el `lienzo` de la
  pantalla) recibe todo hecho y solo pinta los dos estados; `mapa/datos_mapa.gd` (`class_name DatosMapa`,
  `RefCounted`, estático, sin dibujo) agrupa las salas por zona (`por_zona`), da el rectángulo que las abarca
  (`abarca`), la transformación que lo encaja en la pantalla (`encajar`) y el nombre de cada zona
  (`nombre_de_zona`). No conoce ninguna zona: trabaja con lo que diga el índice.
- `abierta`, `rapido` y `acercado` de la pantalla, y `salas_dibujadas`, `zonas_dibujadas`, `marcador_visible`,
  `quedo_acercado` y `marcador_en_pantalla` de su `lienzo`, son públicas para las pruebas. Con el mapa rápido a la vista,
  cada tick solo se mueve el punto del jugador (un nodo aparte); el mapa se rehace al abrir, al cambiar de estado, al
  equipar o quitar la brújula y al descansar. Los dibujos de las salas se cargan al preparar la vista, no al dibujar.

## Marco de menús

- `nucleo/marco_menus.gd` (`class_name MarcoMenus`, `CanvasLayer` capa 21, grupo `pantalla_encima`, corre en pausa),
  creado por cada sala como `Marco`: páginas en ciclo, como el inventario de Hollow Knight, en el orden de
  `MarcoMenus.ORDEN` (Inventario, Amuletos y Mapa; sin el bloque `mapa/`, las dos primeras). Abierto detiene el juego
  (`get_tree().paused`); no se abre con el juego ya detenido (la pausa abierta).
- `mapa` lo abre en Mapa; `inventario`, de pie en Inventario y sentado en un banco en Amuletos. Abierto,
  `pagina_anterior` y `pagina_siguiente` (y tocar la vecina en la barra) cambian de página en ciclo; `pausa`, `mapa`,
  `inventario`, Atrás y «Volver» lo cierran sin abrir la pausa (`bloquea_pausa()`, también en el tick en que se cerró).
- Todo menú que quita la pausa (`MarcoMenus`, `Pausa`, `MenuTienda`, `MenuEstaciones`, `CobroEstacion` y cualquiera nuevo) lleva
  `process_physics_priority = MarcoMenus.PRIORIDAD_FISICA` en su `_ready`. Así corre en la física después del
  jugador (0) y de lo que cuelgue antes que él, y el botón que lo cierra no le llega al jugador en ese tick: B es
  `volver` y también `curar`, y la pausa se mira nodo por nodo. La prioridad no se hereda a los hijos. Positiva porque
  el puerto de depuración usa -100 para ir antes de todo.
- La prioridad no cubre un `Button` que quita la pausa al pulsarse (Continuar, No del cobro, Volver): `ui_accept` lo
  pulsa al despachar el evento, antes del tick, y A es también `saltar`. Eso lo resuelve el jugador: la pulsación de
  `saltar` con la que se quitó la pausa fuera del tick no cuenta en su tick siguiente (`docs/jugador.md`, «Cerrar un
  menú con A»). Para A/`saltar`, un menú nuevo que se cierra con un botón no necesita nada más. No cubre Espacio del
  teclado, que es `ui_accept` y `atacar`: el ataque con la pulsación que cerró el menú no se filtra (ya pasaba antes
  de este arreglo).
- Barra de arriba, de alto `MarcoMenus.ALTO_BARRA`: «Volver» a la izquierda y, al centro, «‹ anterior», el título y
  «siguiente ›», con el encabezado de los menús (`Tema.encabezado`: `Tema.VOLVER` con el botón de `volver`, `Tema.TITULO`
  y la raya de `Tema.raya_abajo`); Anterior y Siguiente llevan los de `pagina_anterior` y `pagina_siguiente`.
- Una página extiende `PaginaMarco` (`nucleo/pagina_marco.gd`, `CanvasLayer`). La base, en su `_ready`, la pone en la
  capa `PaginaMarco.CAPA` (20), en el grupo `pagina_marco` (`MarcoMenus.GRUPO_PAGINAS`), con `PROCESS_MODE_ALWAYS` y
  oculta; una página que define su `_ready` empieza con `super()`. Ofrece `abierta` (pública para las pruebas),
  `id_pagina() -> StringName` y `titulo_pagina() -> String`, que cada página da, y `mostrar_en_marco()` y
  `ocultar_de_marco()`, que por omisión ponen `abierta` y `visible` (Inventario y Amuletos llaman a `super()` y llenan;
  Mapa los reemplaza, porque el mapa rápido también la muestra). El marco busca las páginas por el grupo y les habla con
  llamadas tipadas a `PaginaMarco` (`Array[PaginaMarco]`); un nodo del grupo que no la extiende no cuenta. `PaginaMarco`
  vive en el núcleo: `mapa/` la extiende y el núcleo no nombra clases de `mapa/`. Una página deja libre la franja de la barra.
- `nucleo/pagina_inventario.gd` (`class_name PaginaInventario`, extiende `PaginaMarco`, creada como `Inventario`): solo para leer lo que ya
  existe en `Partida`: vida, Inspiración, PejeCoins, arma (la habilidad `pluma`), habilidades, mapas y lo perdido al
  morir (`PaginaInventario.perdido(mochila)`). Sin objetos: un inventario de objetos subiría el guardado a la versión 4.
- `abierta`, `pagina` e `ids()` del marco y `valores` del inventario son públicos para las pruebas.

## Amuletos

- `nucleo/pantalla_amuletos.gd` (`class_name PantallaAmuletos`, extiende `PaginaMarco`: capa 20, grupo `pagina_marco`,
  corre en pausa), creada por cada sala como `Amuletos`: la página Amuletos del marco de menús.
- Lista los amuletos de `Partida.amuletos_tenidos`, cada uno «puesto» o «guardado». Como en Hollow Knight, solo
  sentado en un banco (`Jugador.descansando` del `Jugador` de la sala) se ponen y se quitan (`alternar(id)`); de pie
  se ven, sin responder. El que no cabe tampoco responde.
- El aviso y la lista van centrados bajo la barra del marco dentro de un `ScrollContainer` (`Fondo/Desplazable`,
  `follow_focus`, sin desplazamiento horizontal): si no caben a lo alto (a 1280×720, desde 5 amuletos) se desplazan
  con el foco y con el dedo, y el aviso se va con la lista.
- Nombre en pantalla: el id con mayúsculas (`nombre_de`), hasta que los amuletos tengan ficha con nombre. No se llama
  «mochila»: `Partida.mochila` es lo que se pierde al morir. (Táctil: ver «Entrada».)
- `abierta` y `botones` son públicas para las pruebas.

## Grupos

| Grupo | Quién lo lleva | Quién lo usa |
|---|---|---|
| `jugador` | El cuerpo que controla la persona: el `Jugador` que crea la sala | El puerto de depuración (posición y si está en el suelo), `ComportamientoEnemigo.jugador()`, `MuroRompible` (el rebote del jugador), los controles táctiles, el marco de menús, la pantalla de amuletos, la del mapa y, en pruebas, `herramientas/salas/medidor_camara.gd` y `herramientas/pruebas/prueba_peligro_anti_bucle.gd` |
| `pantalla_encima` | Una pantalla abierta sobre el juego (hoy, `MarcoMenus`, `MenuTienda`, `MenuEstaciones` y `CobroEstacion`) con `bloquea_pausa() -> bool` | La `Pausa`: no se abre (con `pausa`, Atrás ni al perder el foco) mientras una diga que bloquea, ni en el tick en que se cerró |
| `pagina_marco` | Las páginas del marco de menús, que extienden `PaginaMarco` (la base las pone en el grupo): `PaginaInventario`, `PantallaAmuletos` y `PantallaMapa` | `MarcoMenus`, que las ordena y las muestra (ver «Marco de menús») |

## Capas de física

Nombradas en `project.godot` (`layer_names/2d_physics/`) y con sus constantes en `nucleo/capas.gd`
(`class_name Capas`). Cada pieza se pone en la suya y fija su máscara en `_ready` con `Capas.poner(self, capa,
mascara)`: no se fijan en los `.tscn`, así una sala no puede olvidarlas. Así lo propone
`tutorials/physics/physics_introduction.rst:115-155`.

| Capa | Nombre | Quién está en ella | Su máscara |
|---|---|---|---|
| 1 | `escenario` | Todo `StaticBody2D` (suelos, paredes, `SueloFragil`, `MuroRompible`, `PlataformaDelgada`), el `Porton` y el `AnimatableBody2D` con `Vaiven` (plataformas y elevadores). Toda pieza con script la fija con `Capas.poner`, máscara 0 (`Porton`, `Vaiven`, `PlataformaDelgada`, `MuroRompible`, `SueloFragil`). Es la capa por omisión: los suelos y paredes sin script de las salas no la fijan | — |
| 2 | `jugador` | El cuerpo del `Jugador` | `escenario` |
| 3 | `golpeable` | `Golpeable` y `Cortable` | `Golpeable`: ninguna; `Cortable`: `jugador` (se sacude al pasar) |
| 4 | `danino` | `DanoContacto` y lo que hereda de él (`AtaqueEnemigo`, `ProyectilEnemigo`) | `jugador` |
| 5 | `interaccion` | `Puerta`, `Banco`, `Coleccionable`, `MonedasSueltas`, `ObjetoHabilidad`, `ObjetoMapa`, `Npc`, `RetoPreguntas`, `EntregaRecompensas`, `Mochila`, `Tienda`, `Estacion`, `AvisoAccion`, `ZonaCamara`, `RegionMusica` y el interruptor de la brújula | `jugador` |
| 6 | `ataque_jugador` | El área `Ataque` del jugador y su `Proyectil` | `Ataque`: `golpeable` y `danino` (parry y pogo); `Proyectil`: `golpeable` |
| 7 | `cuerpo_enemigo` | El cuerpo de cada `Enemigo` (`CharacterBody2D`); nadie lo mira | `escenario` |

- Los rayos y consultas directas fijan su máscara: los del `Golpeable`, la bola, su salida desde el jugador, el
  agarre a la pared, el `ProyectilEnemigo` y los de `ComportamientoEnemigo` miran `escenario`, con
  `Capas.rayo_a_escenario(quien, desde, hasta)` (extremos globales, sin áreas; devuelve el `Dictionary` de
  `intersect_ray`, vacío si no choca; solo dentro del tick); la onda de la caída en picada, `golpeable`.
- Una pieza nueva que detecta o es detectada entra a esta tabla y a `herramientas/pruebas/prueba_capas_fisica.gd` en el mismo
  cambio.

## Capas de dibujo

| Capa | Qué | Dónde |
|---|---|---|
| 5 | `ControlesTactiles` | `nucleo/controles_tactiles.tscn` |
| 10 | `Interfaz` (con una tienda abierta queda a la vista en la mitad izquierda, que el velo del menú no tapa) | `interfaz/interfaz.tscn` |
| 11 | Botones «Frente» y «Anim» de la sala de arte (solo pruebas; los FPS los da `ContadorFps` y las partículas y la niebla, el panel de pruebas) | `herramientas/salas/sala_arte.gd` |
| 12 | `CajaDialogo` | `nucleo/caja_dialogo.gd` |
| 13 | `PanelPruebas`: la pestaña y la tarjeta del panel de pruebas (solo con el modo desarrollador) | `nucleo/panel_pruebas.gd` |
| 15 | `Fundido` | `nucleo/fundido.gd` |
| 20 | `Pausa`, las páginas del marco, los menús de la tienda y de las estaciones y el cobro de una estación (nunca hay dos abiertos a la vez) | `nucleo/pausa.tscn`, `nucleo/pagina_marco.gd` (`PaginaMarco.CAPA`, la de `nucleo/pagina_inventario.gd`, `nucleo/pantalla_amuletos.gd` y `mapa/pantalla_mapa.gd`), `nucleo/menu_tienda.gd`, `nucleo/menu_estaciones.gd`, `nucleo/cobro_estacion.gd` |
| 21 | La barra del marco de menús (`MarcoMenus`) | `nucleo/marco_menus.gd` |
| 22 | Configuración abierta desde la pausa (`Pausa.CAPA_CONFIGURACION`) | `nucleo/pausa.gd` |
| 23 | `EditorControles`, encima de Configuración | `nucleo/editor_controles.tscn` |
| 24 | `ContadorFps`, encima de todo: se lee también con un menú abierto | `nucleo/contador_fps.gd` |

Una capa nueva entra a esta tabla en el mismo cambio.

## Guiones de entrada

Formato, comando y condiciones de fallo: `docs/guiones.md`.

## Paquete de publicación

El núcleo no depende de `herramientas/`: las únicas referencias son la carga condicional de `Arranque` (el puerto,
solo en un build de depuración), `Sala.ruta_de` (busca una sala en `Sala.CARPETA_PRUEBAS` si no está en
`contenido/salas/`), la tabla de estaciones de prueba, que `Estacion.tabla_de` carga solo para una sala de la zona de pruebas y solo si
existe (`herramientas/salas/zonas/estaciones_prueba.tres`), y el botón «Zona de pruebas» del menú principal, que aparece con el modo
desarrollador encendido si `herramientas/salas/zona_pruebas.tscn` existe (`ResourceLoader.exists`, sin `preload`),
en depuración y en publicación. Que la zona viaje en el paquete de publicación lo decide el `exclude_filter` del
preset «Publicacion» de `export_presets.cfg`:

- Viajan la zona de pruebas y sus salas jugables: `herramientas/salas/` completa, con `zonas/`, `fichas/`,
  `comportamientos/` y `arte/`.
- No viajan (desde el 17-oct-2026): `*funciones.json`, `herramientas/pruebas/*` (las pruebas de código: `sala_*.tscn`
  sin jugador, sus `prueba_*.gd` y `prueba_base.gd`), `herramientas/validar.*`, `herramientas/generar_mapa.*`,
  `herramientas/generar_sprites.*` (desde el 21-oct-2026: genera el `SpriteFrames` del jugador, ver «Recursos»),
  `herramientas/generar_trazo.*` (desde el 25-oct-2026: genera la textura de `TrazoAtaque`),
  `herramientas/generar_efectos.*` (desde el 25-oct-2026: genera las hojas de `EfectoCuadros` del jugador, el ruido de la niebla y el montón de `MonedasSueltas`) y
  `herramientas/puerto_depuracion.*`. Los patrones van separados por coma, sin `res://`, y `*` cruza `/`. Los
  guiones (`.guion`, `.esperado`) no son recursos y no se exportan.
- Por eso nada fuera de `herramientas/pruebas/` nombra una ruta `res://herramientas/pruebas/`: lo revisa el
  validador (`validador-pruebas-aparte`).
- Los videos `.mp4` (`nucleo/video/`, `contenido/cinematicas/`) no los importa Godot: los dos presets los llevan con
  `include_filter="*.mp4"` (desde el 25-oct-2026, ver `ReproductorVideo` en «Componentes»). Los `.ogv` no pasan por el
  importador (llevan solo su `.uid`) y los dos presets los dejan fuera con `exclude_filter` (desde el 25-oct-2026:
  12,4 MB que en el teléfono no se usan; si H.264 falla, el respaldo es la imagen `.jpg`). En la PC y en los guiones
  sí están.
- El preset «Desarrollo» lleva todo lo demás (su `exclude_filter` es solo `*.ogv`) y arranca con `--print-fps`; los dos exportan para
  `armeabi-v7a` y `arm64-v8a`.
- Se comprueba con `--export-pack "Publicacion" <archivo>.zip` y la lista de entradas bajo `herramientas/`: los
  scripts salen como `.gdc` y las escenas como `.remap`.

## Menú

`nucleo/menu.tscn` es la escena principal. Su fondo es un video en bucle (`ReproductorVideo` con
`MenuPrincipal.VIDEO_FONDO`, `nucleo/video/menu`) encima de `Fondo`, bajo un velo negro (`ALFA_VELO`, 0,35) para que
el gis se lea; con Configuración abierta el video se desenfoca congelado y sigue al cerrarla. Al abrir pasa `Guardado.RUTA` a la ranura 1. «Jugar» abre las ranuras
(`nucleo/ranuras.gd`, `class_name Ranuras`, armada en código; `menu.ranuras`): una ficha por ranura, 4 en fila cuando
caben (desde la vista de 1280) y si no 2×2, arriba del aviso de pocos toques. La vacía dice «Nueva partida»
(`Partida.reiniciar()` con el personaje y el nombre, solo en memoria, y lleva a `inicio_partida_nueva`, la cinemática de
La Celda). El archivo nace con el primer guardado (banco, autoguardado, morir, salir al menú o segundo plano dentro de
una sala), como en Hollow Knight y Silksong: cerrar durante la cinemática deja la ranura vacía y la cinemática se
repite (decidido por la persona el 25-oct-2026). La `VALIDA` dice dónde se quedó (la sala del banco, si no
la última visitada, si no «Inicio»), las vidas máximas, el tiempo jugado y un cuadrito por habilidad, jefe y
coleccionable; al entrar se copia (`respaldar`), se carga y lleva a la sala de su banco (sin banco, a `sala_inicial`, La Celda, sin cinemática).
La `DANADA` y la `INCOMPATIBLE` no se abren. Entrar a una ranura fija `Partida.ruta_guardado` en ella
(`preparar_ranura`). Una vacía abre antes «Nueva partida» (`nucleo/nueva_partida.gd`, `class_name NuevaPartida`):
«Hombre» o «Mujer» (`Partida.personaje` = `hombre` o `mujer`), el nombre en un campo de texto y «Empezar», que no
responde sin personaje. Mientras solo el hombre tenga arte, `NuevaPartida.ELEGIR_PERSONAJE` es `false`: la fila de
personajes no se ve, la partida empieza con `hombre` y el foco va a «Empezar». `NuevaPartida.limpiar_nombre` deja letras, números y espacios simples, hasta 12; vacío,
«Alumno» o «Alumna». La ficha ocupada lleva el nombre (sin él, «Partida N»). «Borrar» (si no está vacía) y «Restaurar» (si hay copia: vuelve al inicio de la última sesión)
piden confirmación (`Confirmacion`, en «Componentes», con el foco en «Cancelar»). «Configuración» (`nucleo/configuracion.tscn`, `class_name Configuracion`,
instancia `Configuracion` del menú) reemplaza al panel central con, en orden de uso: «Audio» (`nucleo/panel_audio.gd`, `class_name PanelAudio`, el nodo `PanelAudio`: panel con el volumen general, de
música y de efectos; cada uno con su barra ancha, su porcentaje y un altavoz que lo silencia y, con otro toque, lo
devuelve al valor de antes, o a 50 si se bajó a 0 con la barra; mientras está abierto, si no se oye música, `Musica.probar`
pone el tema del menú y al cerrarlo devuelve lo que había (el panel no tiene reproductor de música propio), y «Probar efecto» toca uno en el de efectos), «Brillo» (su pantalla, `nucleo/pantalla_brillo.gd`, `class_name PantallaBrillo`, que Configuración crea en código, nodo `PanelBrillo`; como en Hollow Knight:
detrás la escena tenue; en una ventana la misma escena con un cuadro casi negro de calibración en la esquina; el texto
«Ajusta el brillo hasta que el cuadro de la esquina apenas se vea.» y la barra ancha, de 50 % a 150 % en pasos de 5.
La escena y el cuadro se modulan con el mismo color que la sala, porque el brillo no llega a las capas. La escena
es la copia que tomó la pausa, con un shader que divide entre el brillo con que se tomó, o, desde el menú o sin
copia, `EscenaMuestra` de `nucleo/escena_muestra.gd`, rectángulos de color), Vibración, Temblor, «Botones táctiles» (el mismo editor que la
pausa; ver «Entrada»), «Botones del control» (reasignación con `Mando`: tocar una acción y presionar el botón del
control; «Restablecer» los devuelve a los de `project.godot`; sin control conectado lo avisa, con `Input.joy_connection_changed`),
«Avanzado» y «Créditos». «Avanzado» (nodo `PanelAvanzado`, maqueta aprobada el 25-oct-2026, también desde la pausa)
lleva dos grupos con su título. Rendimiento: Recursos (cada toque pasa a automático, bajo o alto; ver «Recursos».
Abierta desde la pausa se ve apagado, con `BotonValor.bloqueado`, y tocarlo no lo cambia: dice «Para cambiar los
gráficos, sal al menú principal.», porque las salas leen el modo al entrar), FPS (60 o 120, ajuste `fps`; solo
aparece con Recursos en alto, elegido o por la detección, y una pantalla de 90 Hz o más, leída al abrir en
`Configuracion.refresco`; se cambia también desde la pausa, porque no recarga nada), Luces 2D (con Recursos en bajo
se ve bloqueado en «No» y al tocarlo avisa que piden Recursos en alto, `Configuracion.AVISO_LUCES`), Niebla y Mostrar
FPS. Desarrollo: Desarrollador (con él el menú muestra «Zona de pruebas»; también en la pausa, porque enciende el panel
de pruebas y ver hitbox al momento) y, solo con él, Pruebas y Ver hitbox. Los ajustes de Avanzado salvo Recursos y
FPS emiten `ajuste_grafico_cambiado` al tocarlos;
«Volver», arriba a la izquierda en cada pantalla. Cada opción es un `BotonValor` (`nucleo/boton_valor.gd`): el nombre
a la izquierda y el valor a la derecha, en gis: con dos opciones (Sí / No, y 60 / 120 en FPS, `opciones`) se ven las dos y la que vale va en un óvalo; Recursos va solo en su óvalo,
con la letra más chica si no cabe, y lo que abre otra pantalla, seguido de «›»; sin interruptores, y se toca el botón entero. Las barras anchas
(variación `Tema.BARRA_ANCHA` de `HSlider`) saltan al punto tocado y se arrastran; con teclado o control, izquierda y
derecha las mueven de 10 en 10. Cada
cambio se guarda al momento; las barras, al soltarlas.
Atrás y la acción `pausa` vuelven un nivel a la vez (`atras()` del menú y de la Configuración): cancelan el editor, la espera de un botón y la
confirmación, de un subpanel vuelven a la lista, de «Nueva partida» a las ranuras, de la lista o de las ranuras al menú, y en el menú piden
confirmación antes de cerrar la app (la misma `Confirmacion`, con el foco en «Seguir jugando»). La zona de pruebas es un nivel más: su «Volver», Atrás, `pausa` y `volver` (B) regresan al menú, y L1 / R1
(`pagina_anterior` y `pagina_siguiente`) cambian de categoría con la vuelta en los extremos; al regresar, el menú queda con
el foco en su entrada (`MenuPrincipal.volver_a_zona`, que el menú lee al entrar). Quien vuelve al menú (pausa, zona de
pruebas) usa `MenuPrincipal.RUTA`. Se maneja con toque, teclado y
control (el foco empieza en la primera opción de cada pantalla). Las opciones nuevas de configuración se agregan a
esa escena.

Tamaños y aspecto (`nucleo/tema.gd`, `class_name Tema`): el tema de los menús se arma en código (`Tema.crear()`) y se asigna
solo a sus raíces (menú, que lo hereda la Configuración, pausa, marco de menús y sus páginas, caja de diálogo, tienda, estaciones y zona de pruebas), no en `project.godot`; el HUD queda fuera.
Es de gis (plan `nucleo-menus-gis`, 17-oct-2026): letra Cabin Sketch (`nucleo/fuentes/`, licencia OFL), gruesa en los títulos (variación
`Tema.TITULO` de `Label`), que se carga con `load()` al armar el tema; opciones sin caja, en gis gastado (`Tema.GASTADO`) y en gis blanco (`Tema.GIS`) con el foco o presionadas;
lo presionado o elegido (la categoría, el personaje) va subrayado. Variaciones de `Button`: `Tema.VOLVER` (flecha de gis hacia atrás),
`Tema.TARJETA` (caja de gis con relleno oscuro: fichas de las ranuras, caja de diálogo y sus opciones), `Tema.PESTANA` (fila de categorías) y
`Tema.CON_DETALLE` (lugar para una línea debajo: salas de la zona de pruebas), `Tema.OPCION_CHICA` (letra de 33: Zona de
pruebas del menú principal), `Tema.SIMBOLO` (sale de `Tema.TARJETA`, con letra de 96, `LETRA_SIMBOLO`, y sin márgenes de arriba y abajo, `MARGEN_SIMBOLO`: botones de un solo símbolo, «–» y «+» del mapa, que caen encima de lo dibujado) y `Tema.OPCION_CENTRADA` (las opciones de la pausa y Sí y No de la confirmación de la tienda y del cobro de una estación; la `Confirmacion` la toma en `variacion_boton`: el mismo
margen a los dos lados, sin subrayado, y con el foco una flechita de gis a cada lado, `EstiloGis.Forma.LADOS`; las
flechitas van en las orillas del botón, así que el botón mide lo que su texto, sin ancho mínimo). Variaciones de
`Label`: `Tema.TITULO_JUEGO` (96) y `Tema.TITULO_PAUSA` (72), que salen de `Tema.TITULO`; `Tema.DESTACADA` (letra de
36: título de una ranura, pregunta de la tienda y del cobro de una estación), `Tema.PREGUNTA` (40: confirmación de las ranuras), `Tema.QUIEN`
(dorado: quien habla) y `Tema.TENUE` (gis al 0,7: nombres del inventario). Las filas de la tienda usan `Tema.FILA_TIENDA` (`Button`: a la izquierda el lugar del ícono y la
moneda, `LADO_ICONO_FILA` 56 y `LADO_MONEDA_FILA` 28 px con `SEPARACION_ICONO` 12, y el foco sin dibujo) y
`Tema.FILA_TIENDA_APAGADA` (de ella, en `GRIS_APAGADO`); la fila elegida lleva detrás un `Panel` `Tema.FRANJA`
(`EstiloGis.Forma.FRANJA`: relleno `RELLENO_FRANJA`, gis al 0,1, entre dos rayas a `ALTO_ORILLA_FRANJA` (20) px de las
orillas y un adorno chico centrado en cada raya, todo dentro de la fila). Adornos de gis para arriba y abajo de una
lista (la pausa): `Tema.adorno(Tema.ADORNO_ANCHO)` y `Tema.adorno(Tema.ADORNO_CHICO)` dan un
`PanelContainer` sin hijos, que mide lo que dicen `Tema.TAMANO_ADORNO_ANCHO` y `TAMANO_ADORNO_CHICO` (los márgenes de
su `EstiloGis.Forma.ADORNO`: raya con un rombo en medio y uno chico en cada punta) e ignora toques y foco. Un aspecto
nuevo es una variación de `Tema`, no un `add_theme_*_override`, que queda solo para separaciones y márgenes. Cada pantalla lleva el mismo encabezado,
`Tema.encabezado(arriba)`: «Volver» con su flecha y, dentro, el botón del control de `volver` (`IconoBoton`; otra acción con
`encabezado(arriba, accion)` y ninguna con `&""`; no pone un segundo si Volver ya tiene su `Icono`), el título en gis grueso y una raya debajo (`Tema.raya_abajo`); lo usan `Tema.barra_arriba`,
Configuración y sus paneles, ranuras, nueva partida, la tienda, las estaciones, la zona de pruebas y, con su barra de páginas, el marco. El menú principal
(título grande, sin imagen de fondo) va en una columna a la izquierda. La pausa, como la de Silksong, va en una columna
centrada en la pantalla (`Panel/Opciones`, centrada en las dos direcciones): el título «Pausa» (`Tema.TITULO_PAUSA`),
el adorno ancho, Continuar, Configuración y Salir al menú con `Tema.OPCION_CENTRADA` (cada botón mide lo que su texto;
Continuar, con el ícono de `volver`) y el adorno chico (los dos con `Tema.adorno`, agregados en `pausa.gd`). Sin caja alrededor de las opciones: detrás
solo queda el velo `Panel` (negro al 0,7), que deja ver el juego. Los botones siguen en
`Panel/Opciones/{Continuar,Configuracion,SalirAlMenu}`, en ese orden, y los adornos (`PanelContainer`) no son botones. Todo lo
que se toca mide al menos 108 px de alto (48 dp en el Senwa S50);
letra de 36 en botones y 33 en etiquetas (`Tema.ALTO_LETRA`, 43 px con Cabin Sketch, medido el 17-oct-2026). `Tema.ajustar(control)` pone un panel en el área segura menos 64 px a los
lados y 16 arriba y abajo, y lo reacomoda al cambiar la ventana. `Tema.fondo_menu(alfa := Tema.VELO)` da el fondo de un menú armado en código (negro con `VELO`, 0.85, a pantalla completa, llamado `Fondo` y con el tema): lo usan las estaciones, el inventario, los amuletos, la Configuración de la pausa (0.9) y la tienda (0, transparente: su velo cubre solo la mitad derecha). `Tema.texto_centrado(lienzo, fuente, cadena, base, letra, color)` dibuja un texto centrado a lo ancho sobre su línea base (botones táctiles, editor de botones, `IconoBoton`, `AvisoAccion`). Las cuadrículas de la Configuración toman 2 columnas
de 420 px en la vista de 1280 (4:3 y 16:9) y 3 desde 1440 (`Configuracion.columnas_para`), y se desplazan si no
caben en alto. El foco es un `StyleBox` propio, `EstiloGis` (`nucleo/estilo_gis.gd`, `_draw` de `StyleBox`): una flechita de gis a la izquierda y el
subrayado de lado a lado del contenido (un `StyleBox` no conoce el texto); en las barras, una caja de gis. Sus trazos tiemblan con una
semilla que sale del tamaño, así no cambian al redibujar. Los menús ponen el foco con
`Tema.dar_foco(control)`: si lo último que se usó fue el dedo o el ratón no se dibuja, aunque haya un control
conectado, y la primera flecha o el primer movimiento del control lo muestra; si fue un control o el teclado, se ve
desde que se abre el menú. Lo último que se usó lo anota `UltimaEntrada` (`nucleo/ultima_entrada.gd`, nodo que crea
`Arranque`, también en pausa): `UltimaEntrada.con_control()`, que al arrancar da `true` si ya hay un control
conectado. En Android, un clic de ratón real (el touchpad del DUALSHOCK 4; `UltimaEntrada.es_raton_real`: no trae
`InputEvent.DEVICE_ID_EMULATION`, que llevan los que Godot emula desde el dedo) no cuenta como toque. Además
`UltimaEntrada` esconde ahí el puntero del sistema (`Input.MOUSE_MODE_HIDDEN`) al arrancar y lo vuelve a pedir con
el primer evento de ratón real tras cada toque: Godot en Android solo lo aplica si lo último que vio fue un ratón y
no reintenta un modo ya pedido (código del motor, rama 4.5, `display_server_android.cpp` y `GodotInputHandler.java`;
pide API 26 o más).

`UltimaEntrada.dispositivo` dice qué se usó al último, con el `enum Mando.Dispositivo`: `TOQUE`, `TECLADO` o la
familia del control (`XBOX` o `PLAYSTATION`, que da `Mando.familia`); `con_control()` es `dispositivo != TOQUE`, no un
valor aparte. `UltimaEntrada.clasificar(evento, android)` dice qué dispositivo implica un evento sin anotarlo, o
`UltimaEntrada.SIN_CAMBIO` (-1) si no cambia nada (soltar, arrastrar, mover el ratón, un stick bajo la mitad, en
Android un clic de ratón real); `anotar` la usa. La familia de cada control (`device`) se calcula una vez y se guarda
hasta que se conecta o desconecta cualquier control (`Input.joy_connection_changed`, conectada siempre). Con eso `IconoBoton` (`nucleo/icono_boton.gd`, un `Control`) dibuja el botón de una
acción (`accion`, con lo reasignado): disco con el símbolo de PlayStation o la letra de Xbox, pastilla para laterales,
gatillos, Start y Select, o la tecla con el teclado; tras un toque no se ve. Se dibuja con `_draw`, sin imágenes, y
se recalcula con las señales del bus `dispositivo_cambiado` y `mando_cambiado`, no por cuadro: se conecta en
`_enter_tree`, se desconecta en `_exit_tree` y al volver al árbol se pone al día con lo que cambió mientras estaba
fuera. `Mando` y `UltimaEntrada` son estáticos: emiten con `Mando.bus()` (el nodo `Eventos`, o `null` si aún no
está en el árbol) y `emit_signal`, no con el identificador `Eventos`, así compilan y no dan error sin autoloads (un
`-s`); en el juego `Eventos` siempre está, porque es el primer autoload y los ajustes se cargan en `Arranque`, el
tercero. `IconoBoton.en_boton(boton, accion)` lo
pone dentro de un `Button` y le reserva su ancho con un ícono transparente. `dibujo_actual` (solo lectura, una copia)
dice lo que dibuja ahora, en la forma de `IconoBoton.dibujo()`. Lo llevan los Volver de los menús
(`volver`), Continuar de la pausa, Anterior y Siguiente del marco (`pagina_anterior` y `pagina_siguiente`), la
barra de la zona de pruebas, las filas de «Botones del control» y, en la partida, solo los pizarrones (`AvisoAccion`).

Los menús hechos de piezas repetidas (ranuras, nueva partida, marco y sus páginas, partes de Configuración como el
brillo) se arman en código y no en un `.tscn`: las fichas son iguales y su número sale de los datos. El resto es
escena (`menu.tscn`, `configuracion.tscn`, `pausa.tscn`). Fuera de la v1: accesibilidad para lector de pantalla
(`accessibility_name`); los menús se manejan con toque, teclado y control.

Aviso de pocos toques: `nucleo/toques.gd` (`class_name Toques`, estático) pregunta una vez a Android, con el singleton
`AndroidRuntime` y `PackageManager.hasSystemFeature`, si la pantalla declara 5 o más toques a la vez
(`android.hardware.touchscreen.multitouch.jazzhand`; Godot 4.7.2 entrega el boolean de Java como entero). Si no
(`Toques.pocos()`), el menú pone una línea discreta abajo (`AvisoToques`, de `Toques.crear_aviso()`), visible en el menú
y en la Configuración y tapada por la confirmación de salida. Fuera de Android o si la pregunta falla, no hay aviso. El
juego no cambia por esto. Las pruebas usan `Toques.forzar()` y `Toques.olvidar()`.
