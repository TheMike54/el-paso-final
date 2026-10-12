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
| Botón Atrás | `quit_on_go_back=false` | Atrás no cierra la app: en el juego abre la pausa y en el menú pide confirmación |
| Tipado | `untyped_declaration`, `unsafe_property_access`, `unsafe_method_access` y `unsafe_call_argument` como error | Un error de tipos se ve al validar, no al jugar |
| Texturas | Ninguna de más de 2048 px por lado | Memoria en gama baja |
| Compresión de texturas | `textures/vram_compression/import_etc2_astc=true` | Godot no exporta a Android sin ella |
| Id del paquete Android | `com.themike54.elpasofinal` | Identidad estable de la app instalada |

## Ciclo de vida

- Arranque: Godot carga los autoloads y después la escena principal (`application/run/main_scene`).
- La lógica del juego corre en `_physics_process`, a 60 ticks por segundo. `_process` queda para lo visual.
- La acción `pausa` no guarda. La partida se guarda al descansar en un banco y se autoguarda (lo obtenido, nunca la
  posición: al continuar se aparece en el último banco) al obtener una habilidad, vencer a un jefe, recoger un amuleto
  o un coleccionable, morir, salir al menú y pasar la app a segundo plano (ver «Estado de la partida»).
- Pausa: `nucleo/pausa.tscn` (`class_name Pausa`), que crea cada sala. La acción `pausa` o el botón Atrás de
  Android la abren y la cierran (`get_tree().paused`); tiene Continuar, «Controles» (abre el editor de los botones
  táctiles; ver «Entrada») y «Salir al menú». Vibración, temblor y lo demás están en la Configuración del menú. Se abre sola al perder el foco (`NOTIFICATION_APPLICATION_FOCUS_OUT` o
  `NOTIFICATION_APPLICATION_PAUSED`: apps recientes, otra ventana) y no se cierra sola al volver. Corre con
  `PROCESS_MODE_ALWAYS`, igual que los controles táctiles. Su propiedad `abierta` dice si está abierta. La pausa
  lee la acción, no el evento: la abren igual la tecla, el botón táctil y un guion. Con el editor abierto (`editor`
  no es `null`), la acción `pausa` no hace nada y Atrás es Cancelar.
- El guardado se escribe en un archivo temporal y después se renombra: un cierre a la mitad no daña la partida.
- Los ajustes del jugador van en su propio archivo, no en la partida (ver «Ajustes y vibración»).
- El guardado es JSON con número de versión. Al cargar se distinguen partida válida, archivo dañado y partida de
  una versión incompatible, más el caso sin partida guardada (ver «Guardado»).
- Todo lo persistente (puerta abierta, objeto recogido, jefe vencido) se identifica con un ID de texto estable.
- Las fichas `.tres` son de solo lectura en ejecución: un recurso cargado es la misma copia para todos.

## Guardado

`nucleo/guardado.gd` (`class_name Guardado`): funciones estáticas, sin autoload.

| Función | Qué hace |
|---|---|
| `Guardado.guardar(partida: Dictionary, ruta := Guardado.RUTA) -> Error` | Escribe `{"version": VERSION, "partida": partida}` en `<ruta>.tmp` y lo renombra a `<ruta>`. Devuelve `OK` o el error |
| `Guardado.cargar(ruta := Guardado.RUTA) -> Guardado.Resultado` | Devuelve `estado` y, si es `VALIDA`, `partida` |
| `Guardado.borrar(ruta := Guardado.RUTA) -> Error` | Borra `<ruta>` y `<ruta>.tmp` si existen (lo usa «Borrar partida»); no toca los ajustes |

| `Guardado.Estado` | Cuándo |
|---|---|
| `VALIDA` | El archivo es JSON, su `version` es `VERSION` y `partida` tiene todos los campos del esquema con su tipo |
| `VACIA` | No hay archivo: partida nueva. Un `.tmp` sobrante de un cierre a la mitad no cuenta |
| `DANADA` | No es JSON, no es un objeto, falta `version` o no es número, `partida` no es un objeto, o le falta un campo o tiene otro tipo |
| `INCOMPATIBLE` | `version` es un número distinto de `VERSION`, más nuevo o más viejo. No hay migración |

- `RUTA` es `user://partida.json`; `VERSION` es 3.
- Esquema de la versión 3 (`Guardado.ESQUEMA`), copiado de Hollow Knight y Silksong (lo del jugador como listas de
  ids; lo de cada sala con clave sala + objeto). Un campo nuevo cambia el esquema y `VERSION` en el mismo cambio.

  | Campo | Tipo | Qué guarda |
  |---|---|---|
  | `banco` | objeto | `{sala, id}`: clave de la sala y id del último banco; `{}` si no se ha descansado. Si no está vacío y le falta `sala` o `id` (texto), la partida es `DANADA` |
  | `vidas_maximas` | número | Vidas máximas |
  | `habilidades`, `jefes`, `amuletos_tenidos`, `amuletos_equipados` | listas | Ids |
  | `monedas` | número | PejeCoins |
  | `mochila` | objeto | Lo perdido al morir, `{sala, x, y, monto}`, o `{}` |
  | `mapas` | lista | Zonas cuyo mapa se tiene |
  | `salas_visitadas`, `salas_mapeadas` | listas | Claves de sala (id, o ruta en una sala de prueba suelta) |
  | `salas` | objeto | Estado por sala: `{clave de la sala: {id del objeto: true o número}}` |
  | `personaje`, `nombre` | texto | Elegidos en Nueva partida; vacíos si no se eligieron |
  | `tiempo_jugado` | número | Segundos con el juego corriendo dentro de una sala |

- Lo que reaparece (enemigos) no se escribe. Sin cifrado ni suma de control.
- Al leer, los números vuelven como `float`: `var vidas: int = partida["vidas_maximas"] as int`.
- Lo que se guarda sale del estado de la partida: `Partida.guardar()` escribe `Partida.a_diccionario()` y, si salió
  bien, emite `Eventos.partida_guardada`; Continuar carga el resultado con `Partida.desde_diccionario()` (con las
  vidas llenas) y lleva al jugador a su banco.

## Ajustes y vibración

`nucleo/ajustes.gd` (`class_name Ajustes`): funciones estáticas, como `Guardado`. Archivo `user://ajustes.json`
(`{"version": 1, "ajustes": {...}}`), escrito a un temporal y renombrado. Son del teléfono y no de la partida:
agregar un ajuste no cambia `Guardado.VERSION`. Un archivo que falta, dañado o de otra versión deja los valores
por omisión: los interruptores en `Ajustes.POR_OMISION`; la disposición de los botones en
`DisposicionControles.por_omision()`.

| Ajuste | Por omisión | Qué es |
|---|---|---|
| `vibracion` | `true` | Vibrar al pegar, al recibir daño, al parar, al curarse, al descansar y al aterrizar duro |
| `temblor` | `true` | Temblor de la cámara al aterrizar de una caída (se apaga por mareo). Un archivo sin la clave la deja encendida |
| `modo_desarrollador` | `false` | Muestra en Configuración la entrada a la zona de pruebas |
| `volumen` | 1 | Volumen general (bus Master), de 0 a 1; en 0, silencio. Se aplica al cargar (`Ajustes.aplicar_volumen()`) |
| `recursos` | `"auto"` | Modo de recursos: `auto` (decide la detección), `bajo` o `alto`. Otro valor vuelve a `auto` (ver «Recursos») |
| `mando` | `{}` | Botones del control que difieren de `project.godot`: `{acción: índice de botón}`. Lo aplica `Mando.aplicar` al cargar |
| `controles` | La distribución inicial | `{"opacidad": n, "botones": {acción: {"ancla": [0|1, 0|1], "desplazamiento": [x, y], "escala": n}}}` (ver «Entrada»). Lo que falta o no es válido se queda en su valor por omisión, botón por botón; escala y opacidad fuera de rango se recortan |

- `Ajustes.cargar_una_vez()` lo llaman `Arranque` (así los botones del control y el volumen valen desde el principio),
  la vibración, el jugador, los controles táctiles, la Configuración y el editor de controles; `Ajustes.guardar()`,
  cada cambio de la Configuración y «Listo» del editor de controles.
- `nucleo/mando.gd` (`class_name Mando`, estático): reasigna los botones del control de `Mando.REASIGNABLES`
  (`saltar`, `atacar`, `curar`, `mapa`, `mapa_rapido`, `mochila`, `pausa`; los ejes no: ni el movimiento ni
  `impulso` (RT) ni `interactuar` (stick arriba), que no tienen botón en `project.godot`). `asignar(acción, botón)`
  intercambia con la acción que ya tenía ese botón: ninguna se queda sin botón; un botón fuera de
  `0..JOY_BUTTON_SDL_MAX-1` se ignora. `aplicar` (al cargar) asigna lo guardado del mismo modo, así un archivo
  editado a mano no deja dos acciones en un botón. `por_omision()` vuelve a los de `project.godot`. El Start con que
  se acaba de asignar un botón no cuenta como Atrás en el menú (`Configuracion.acaba_de_asignar()`).
- `nucleo/vibracion.gd` (`class_name Vibracion`, `Node`), que crea cada sala con el nombre `Vibracion`: escucha el
  bus y llama a `Input.vibrate_handheld(ms, fuerza)` con un patrón por evento (propiedades exportadas):

| Evento | Señal | Duración | Fuerza (0 a 1) |
|---|---|---|---|
| Pegarle a algo (ataque, pogo, bola, onda) | `enemigo_golpeado` | 25 ms | 0,35 |
| Parar un ataque (parry) | `parry` | 45 ms | 0,6 |
| Recibir daño | `jugador_danado` | 60 ms | 0,8 |
| Curarse | `jugador_curado` | 40 ms | 0,45 |
| Descansar | `descanso_en_banco` | 70 ms | 0,5 |
| Aterrizaje duro y aterrizaje de la picada | `jugador_aterrizo` | 80 ms | 0,9 |

- Entre una vibración y la siguiente pasan al menos `ticks_entre_vibraciones` (4); recibir daño y el parry no esperan (el parry llega en el mismo tick que el golpe a su dueño). Nada más
  vibra: ni moverse, ni saltar, ni los menús. Cuenta en `pedidas` (con el ajuste encendido o no) y `enviadas`, y la
  última en `ultima`: los guiones las leen con `valor Vibracion`.
- En Android, `vibrate_handheld` necesita el permiso `VIBRATE` en el preset de exportación; sin él no vibra. Un
  teléfono sin control de fuerza solo respeta la duración.

## Estado de la partida

Autoload `Partida` (`nucleo/partida.gd`): lo que sobrevive al cambio de sala. Una sala nueva no reinicia nada.

| Propiedad o función | Qué es |
|---|---|
| `vidas`, `vidas_maximas` | Vidas actuales y máximas (4 al empezar). `Jugador.vidas` lee y escribe `Partida.vidas`. Cada cambio emite `vidas_cambiadas` |
| `banco`, `sala` | Id del último banco donde se descansó y la clave de su sala (`Sala.clave()`); vacíos si no se ha descansado |
| `jefes`, `amuletos_tenidos`, `amuletos_equipados`, `mochila`, `mapas`, `personaje`, `nombre`, `tiempo_jugado` | Los campos del guardado del mismo nombre |
| `monedas` | PejeCoins; cada cambio emite `monedas_cambiadas` |
| `salas_visitadas`, `visitar(clave)` | Claves de las salas visitadas; la sala se anota al entrar |
| `salas_mapeadas` | Al oír `descanso_en_banco`, con la habilidad `pluma_mapa`, pasan aquí las visitadas cuya zona está en `mapas` (como la Pluma de Hollow Knight y Silksong) |
| `salas`, `estado_de(sala, objeto)`, `marcar(sala, objeto, valor := true)` | Estado por sala. `estado_de` da `null` si no hay nada. Lo usan `SueloFragil` y `Coleccionable` con su `id` y la clave de su sala (`Sala.clave_de(nodo)`) |
| `total_coleccionables()` | Marcas de todas las salas cuyo id empieza con `PREFIJO_COLECCIONABLE` (`coleccionable`) |
| `obtener_habilidad(id)`, `obtener_amuleto(id)` | Suman y emiten `habilidad_obtenida` o `amuleto_obtenido` (si ya estaba, nada) |
| `dar_recompensa(recompensa)` | Entrega una `Recompensa` (PejeCoins, vida máxima, amuleto o habilidad) |
| `ruta_guardado` | Archivo del banco y del autoguardado: `RUTA_PRUEBAS` (`user://prueba_partida.json`) por omisión, para que guiones y zona de pruebas no pisen la partida real; Nueva partida y Continuar lo cambian a `Guardado.RUTA` |
| `autoguardar()`, `autoguardados` | Guarda en `ruta_guardado` sin tocar el banco y emite `partida_guardada`. Lo llaman los avisos `habilidad_obtenida`, `amuleto_obtenido`, `coleccionable_obtenido`, `jefe_vencido` (que además anota el jefe) y `jugador_muerto`; «Salir al menú» de la pausa; la entrega de recompensas; y `NOTIFICATION_APPLICATION_PAUSED` o `NOTIFICATION_APPLICATION_FOCUS_OUT` con una sala abierta. `autoguardados` los cuenta |
| `habilidades`, `tiene(id)` | `Array[StringName]` con las habilidades obtenidas, y si una está |
| `enemigos_vencidos`, `vencer(clave)`, `fue_vencido(clave)` | Claves (`"<clave de la sala>#<id>"`) de los enemigos fuertes vencidos desde el último descanso o la última muerte. Se borra al oír `descanso_en_banco` o `jugador_muerto` y en `reiniciar()`; no se guarda |
| `inspiracion`, `ganar_inspiracion(n)` | Recurso de curación (0 a `INSPIRACION_MAXIMA`, 99); no se guarda, se reinicia con la partida y se vacía al oír `jugador_muerto`. Cada cambio emite `inspiracion_cambiada` |
| `reiniciar()` | Partida nueva: la llaman Nueva partida y cada sala de la zona de pruebas |
| `llenar_vidas()` | Vidas al máximo: al reaparecer después de morir |
| `a_diccionario()` / `desde_diccionario(partida)` | Hacia y desde los campos de `Guardado.ESQUEMA`. Al cargar, lo que no se guarda empieza de cero: Inspiración 0 y sin enemigos vencidos |

## Autoloads

| Nombre | Script | Qué hace |
|---|---|---|
| `Eventos` | `nucleo/eventos.gd` | Bus de eventos: solo declara las señales de «Bus de eventos». Va antes de `Arranque` para existir cuando arranca todo lo demás |
| `Partida` | `nucleo/partida.gd` | Estado de la partida (ver «Estado de la partida»). Va después de `Eventos` y antes de `Arranque` |
| `Arranque` | `nucleo/arranque.gd` | Pone el color de borrado en negro, carga los ajustes y, con pantalla, aplica el rango de la vista al arrancar y, diferido al final del cuadro, al cambiar el tamaño de la ventana (`proporcion_minima` y `proporcion_maxima`, exportadas). Imprime `ARRANQUE depuracion=<bool> puerto=<bool>` y, solo en un build de depuración y si el archivo viaja en el paquete, carga con `load()` el puerto de depuración como hijo suyo (`PuertoDepuracion`) |

- Un autoload nuevo se agrega a esta tabla en el mismo cambio.
- Nada de `herramientas/` es autoload ni se carga con `preload`: el juego debe arrancar sin esa carpeta.

## Recursos

`nucleo/recursos.gd` (`class_name Recursos`, estático). `Recursos.bajos()` dice si rige el modo bajo: el ajuste
`recursos`, o en `auto` la detección (`es_debil()`: un build de 32 bits, `OS.has_feature("32")`, o menos de
`UMBRAL_MEMORIA`, 3 GB, en `OS.get_memory_info()["physical"]`). Las piezas lo leen al entrar a la sala: un cambio en
Configuración vale desde la sala siguiente. Elegir alto en un teléfono débil se permite y la Configuración avisa.

| Pieza | En modo bajo | En alto |
|---|---|---|
| `nucleo/prescindible.gd` (`class_name Prescindible`, `Node`), hijo de un adorno (emisor, capa lejana, cortable de más) | Quita a su padre al entrar | Nada |
| `nucleo/planta.gd` (`class_name Planta`, `Node2D`) | Quieta | Se mece (`grados`, `periodo`, `desfase`) con un tiempo propio en `_process`: quieta en la pausa |
| `nucleo/niebla.gd` (`class_name Niebla`, `Node2D`) | Quieta | Avanza `velocidad` px/s y vuelve tras `recorrido`, con tiempo propio |

- Presupuesto por sala (lo revisa el validador en toda escena cuya raíz es una `Sala`): a lo más 3 emisores de
  partículas con 60 partículas entre todos, 30 plantas y ninguna luz 2D. Las capas translúcidas grandes (a lo más
  2) no las revisa. Nunca se marca como prescindible un aviso de peligro ni algo cuya colisión importe.
- `herramientas/salas/sala_recursos.tscn` llena el presupuesto (2 nieblas, 30 plantas, 3 emisores, 6 cortables;
  prescindibles una niebla, dos emisores y cuatro cortables) para medir los FPS en bajo y en alto.

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
| `partida_guardada` | — | `Partida.guardar()` (banco y autoguardado), cuando el guardado salió bien |
| `enemigo_golpeado` | `enemigo: Node` | Lo golpeable, al recibir un golpe del ataque o de la bola (solo el ataque llena la Inspiración) |
| `enemigo_vencido` | `enemigo: StringName` (id de su ficha) | El enemigo, al quedarse sin vida |
| `parry` | — | El jugador, al parar un `AtaqueEnemigo` |
| `habilidad_obtenida` | `habilidad: StringName` | `Partida.obtener_habilidad()` (el objeto de habilidad, una recompensa; en el juego, los jefes). Autoguarda |
| `amuleto_obtenido` | `amuleto: StringName` | `Partida.obtener_amuleto()`. Autoguarda |
| `coleccionable_obtenido` | `coleccionable: StringName` (su id) | El `Coleccionable` al tomarlo. Autoguarda |
| `monedas_cambiadas` | `monedas: int` | `Partida`, cada vez que cambian las PejeCoins |
| `jefe_vencido` | `jefe: StringName` (id del jefe) | El jefe. `Partida` lo anota en `jefes` y autoguarda |
| `cambio_de_sala` | `sala: String` (`Sala.clave()`: id, o ruta en una sala de prueba suelta), `puerta: StringName` (por la que llegó) | La sala, ya con el jugador puesto, cuando se llega por una puerta |
| `jugador_aterrizo` | `velocidad: float` (px/s al tocar el suelo) | El jugador vivo, en un aterrizaje duro y al aterrizar de la picada (antes de la onda, para que su vibración gane a la del golpe) |
| `fundido_pedido` | `ticks_oscurecer: int`, `ticks_en_negro: int`, `ticks_aclarar: int` (0: se queda en negro) | El jugador al tocar un peligro, la sala al final de la muerte y la puerta al cruzarla; la escucha el `Fundido` de la sala |

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
| `mochila` | I | View / Select |
| `pausa` | Esc | Start |

Las teclas se guardan como tecla física (`physical_keycode`): valen por su posición en el teclado, no por la
letra de la distribución. Una acción nueva se agrega a `project.godot` y a esta tabla en el mismo cambio.

- `interactuar` y `mover_arriba` comparten tecla y las dos se activan juntas. Son acciones aparte para
  reasignarlas por separado; junto a algo con que interactuar, la lógica del jugador decide cuál vale.
- El pogo (`mover_abajo` + `atacar` en el aire), la caída en picada (`mover_abajo` + `curar` en el aire) y el salto
  en pared (empujar hacia la pared en el aire) son combinaciones de acciones, no acciones propias.
- `curar` es el botón de poderes, como en Hollow Knight: mantenerlo cura y tocarlo lanza el poder (ver «Jugador»).
- Controles táctiles: `nucleo/controles_tactiles.tscn` (`class_name ControlesTactiles`), que crea cada sala.
  Traducen el toque a estas mismas acciones con `Input.action_press` y `action_release`; es el único script que
  lee toques. Joystick invisible en la zona de abajo a la izquierda (aparece donde se pone el dedo; da fuerza de 0
  a 1 a `mover_*`, con zona muerta de 0,2; hacia arriba también da `interactuar`, como la flecha arriba) y botones Saltar, Atacar, Curar, Impulso, Pausa, Mapa y Mochila en la
  distribución inicial (Mochila está en la tabla, pero mientras siga en `BOTONES_SIN_USO` no se dibuja ni responde,
  ni en el editor, porque todavía no hace nada); Impulso solo mientras `Partida.tiene(&"impulso")` y Atacar mientras `Partida.tiene(&"pluma")` (sin la habilidad no se dibuja ni responde,
  y un dedo encima se suelta al perderla; la tabla `HABILIDAD_DE_BOTON` dice qué botón pide qué habilidad). Anclados a su esquina y medidos en proporción del lado corto. Se ocultan con una tecla o
  el control y reaparecen al tocar la pantalla. Los dedos se recuerdan entre salas (variables estáticas): un dedo
  que sigue en la pantalla al cruzar una puerta o al reaparecer lo sueltan los controles de la sala nueva; si
  entre una sala y otra pasan más de `CUADROS_CAMBIO_DE_SALA` cuadros (el menú), al llegar se suelta todo. Dónde va
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
- Control (Xbox / PlayStation): un evento del InputMap junto a cada tecla, para cualquier control (`device` -1).
  El stick usa la zona muerta de cada acción (0,2); RT es un eje que cuenta como presionado pasada esa zona. RB y LT quedan libres.

## Jugador

`nucleo/jugador.tscn` (`class_name Jugador`, `CharacterBody2D`): camina y salta con toda su lógica en
`_physics_process`. Reglas del salto, como en Hollow Knight; la caja gris (`sala_inicial`) no las lleva.
Todos los valores son propiedades exportadas del jugador y se ajustan en la zona de pruebas:

| Propiedad | Inicial | Qué es |
|---|---|---|
| `velocidad` | 360 px/s | Velocidad al caminar, sin aceleración |
| `gravedad` | 2400 px/s² | Gravedad |
| `altura_salto` | 200 px | Altura máxima manteniendo `saltar`; el impulso se calcula a partir de ella |
| `corte_salto` | 0,4 | Factor de la velocidad vertical al soltar `saltar` mientras sube |
| `ticks_minimos_salto` | 4 | Ticks de subida antes de que soltar corte el salto |
| `ticks_coyote` | 3 | Ticks después de salir de una orilla en que `saltar` todavía funciona |
| `ticks_salto_en_cola` | 3 | Ticks antes de aterrizar en que presionar `saltar` hace saltar al tocar el suelo |
| `velocidad_caida_max` | 1200 px/s | Tope de la velocidad de caída, pasados los primeros `distancia_caida_inicial` px |
| `velocidad_caida_inicial` | 700 px/s | Tope al empezar a caer: al principio se cae más lento |
| `distancia_caida_inicial` | 240 px | Caída (desde la cima del salto o desde la orilla) con el tope inicial |
| `ticks_ataque` | 8 | Ticks del ataque tras presionar `atacar`. El primero solo enciende el área: golpea en los 7 siguientes |
| `ticks_entre_ataques` | 20 | Ticks entre un ataque y el siguiente, contados desde que empieza |
| `ticks_ataque_en_cola` | 6 | Cola del ataque: `atacar` presionada hasta estos ticks antes de poder atacar otra vez ataca en cuanto se puede |
| `posicion_ataque_arriba` | (0, -210) px | Centro del área de ataque hacia arriba, relativo a los pies |
| `dano_ataque` | 1 | Daño de cada golpe del ataque a un `Golpeable` |
| `posicion_pogo` | (0, 50) px | Centro del área de ataque hacia abajo (pogo), relativo a los pies |
| `altura_pogo` | 120 px | Altura del rebote del pogo |
| `ticks_invulnerable` | 60 | Ticks sin recibir daño después de un golpe |
| `ticks_retroceso` | 10 | Ticks en que el retroceso manda sobre el movimiento horizontal |
| `retroceso` | (420, 420) px/s | Velocidad del retroceso: `x` alejándose del origen del daño, `y` hacia arriba |
| `ticks_suelo_firme` | 6 | Ticks seguidos en el suelo para que una posición cuente como punto seguro |
| `ticks_atras_punto_seguro` | 15 | Cuántas posiciones firmes atrás se reaparece tras un peligro: lejos de la orilla |
| `ticks_reaparicion_peligro` | 20 | Ticks quieto tras volver al punto seguro |
| `ticks_anti_bucle` | 30 | Ticks con control tras volver de un peligro durante los que otro peligro lleva al punto de llegada sin quitar vida |
| `margen_fuera_de_sala` | 160 px | Px que los pies pasan del borde de abajo de `limites` para que salir por abajo cuente como peligro (el alto del cuerpo) |
| `ticks_hit_stop` | 4 | Ticks de congelado común al recibir daño, antes del retroceso (ver `Congelado`) |
| `ticks_invulnerable_parry`, `ticks_congelado_parry` | 15, 3 | Parry: ticks sin daño de enemigos y de congelado común (ver «Enemigos») |
| `ticks_rebote_al_golpear` | 4 | Ticks en que el jugador sale empujado hacia atrás al golpear algo |
| `velocidad_rebote_al_golpear` | 240 px/s | Velocidad de ese empuje |
| `costo_curacion` | 33 | Inspiración que cuesta curar una vida |
| `ticks_curacion` | 60 | Ticks de curación para recuperar una vida, contados desde `ticks_mantener_poder` |
| `inspiracion_por_golpe` | 11 | Inspiración que gana cada golpe a algo golpeable |
| `ticks_mantener_poder` | 10 | Ticks manteniendo `curar` a partir de los cuales es mantener (curar) y no un toque (poder) |
| `costo_poder` | 33 | Inspiración que cuesta cada poder |
| `salida_proyectil` | (60, −90) px | Dónde sale la bola, relativo a los pies del jugador mirando a la derecha |
| `ticks_recarga_bola` | 18 | Ticks desde que sale una bola hasta poder lanzar otra (un amuleto podría reducirlo) |
| `velocidad_impulso` | 1200 px/s | Velocidad horizontal del impulso |
| `ticks_impulso` | 10 | Ticks que dura el impulso, sin gravedad (200 px) |
| `ticks_recarga_impulso` | 36 | Ticks desde que empieza un impulso hasta poder hacer otro |
| `velocidad_carrera` | 756 px/s | Carrera (sprint), 2,1 veces `velocidad` (Silksong: «112 % más rápido»). Sin fuente para el valor exacto |
| `ticks_giro_carrera` | 8 | Giro en carrera: la velocidad pasa de un sentido al otro, por 0, sin apagarla |
| `ticks_soltar_carrera` | 4 | Ticks sin dirección que la carrera aguanta a velocidad completa: cruzar el centro del joystick (zona muerta 0,2) al girar no es soltar. Valor nuestro |
| `velocidad_ataque_carrera` | 900 px/s | Ataque en carrera: empuje hacia adelante mientras dura el ataque |
| `velocidad_deslizar_pared` | 150 px/s | Caída máxima sostenido en una pared |
| `velocidad_despegue_pared` | 420 px/s | Velocidad horizontal con que el salto en pared despega de ella |
| `ticks_despegue_pared` | 8 | Ticks tras el salto en pared en que la entrada horizontal no manda |
| `ticks_coyote_pared` | 3 | Ticks después de dejar la pared en que `saltar` todavía es un salto en pared |
| `velocidad_picada` | 1800 px/s | Velocidad de la caída en picada, sin el tope de `velocidad_caida_max` |
| `dano_picada` | 3 | Daño de la onda al aterrizar de la picada a cada `Golpeable` que toca |
| `onda_picada` | (320, 120) px | Tamaño de esa onda, centrada a lo ancho en los pies |
| `ticks_invulnerable_picada` | 24 | Ticks sin recibir daño después de aterrizar de la picada |
| `altura_saltito_picada` | 40 px | Picada desde el suelo: altura del saltito |
| `ticks_carga_picada` | 15 | Picada desde el suelo: ticks quieto en la cima del saltito antes de bajar |
| `ticks_caida_dura` | 18 | Aterrizaje duro, como en Hollow Knight: aterrizar tras 18 ticks seguidos (0,3 s) cayendo a `velocidad_caida_max` (unos 794 px; 650 con `distancia_caida_inicial` en 0). Pared, pogo, impulso o retroceso reinician la cuenta. La picada tiembla siempre al aterrizar (no al romper un `SueloFragil`). Sin fuente |
| `temblor_px` | 20 px | Amplitud vertical inicial del temblor del aterrizaje duro y de la picada: el `offset` de la cámara, signo alterno cada 2 ticks, baja en línea recta a 0; aterrizar otra vez lo reinicia. `temblor_y` y `temblor_x` (públicas) son los valores de cada tick aunque el ajuste esté apagado. Provisional, sin fuente |
| `temblor_fraccion_x` | 1/3 | Amplitud horizontal en fracción de `temblor_px`, signo alterno cada 3 ticks: con periodos distintos no da vueltas en círculo |
| `temblor_ticks` | 18 | Ticks que dura el temblor (0,3 s). Provisional, sin fuente |
| `ticks_aterrizaje_duro` | 21 | Ticks sin control tras un aterrizaje duro (0,35 s; no tras la picada). Sin fuente: el de Hollow Knight está en sus recursos |
| `suavizado_camara_x` | 8 | Seguimiento horizontal de la cámara: fracción por segundo de lo que le falta (el cálculo de `position_smoothing_speed`) |
| `tiempo_camara_y` | 0,15 s | Seguimiento vertical de la cámara, amortiguado crítico (como `SmoothDamp`): cayendo a 1200 px/s va 180 px por detrás. Con menos de 0,15 s el frenado en el límite inferior se siente como un jalón (medido el 07-oct-2026) |

Combate:

- Sin la habilidad `pluma` (el arma) `atacar` no hace nada; el botón táctil Atacar tampoco se dibuja.
- El ataque es el área `Ataque` del jugador, hacia donde mira (el último lado al que caminó); con `mover_arriba`
  mantenida, encima de la cabeza (`posicion_ataque_arriba`, sin rebote hacia atrás). Golpea una sola vez a cada
  `Golpeable` que toca durante un ataque y corta cada `Cortable` que toca.
- `recibir_dano(dano: int, origen_x: float, peligro := false)` es lo único que quita vidas. Durante la
  invulnerabilidad y la caída en picada (con su saltito y su carga) un golpe no quita vidas; un peligro, sí. Emite `jugador_danado` con las vidas que quedan y, al llegar a 0,
  `jugador_muerto`.
- Golpe normal (enemigo, cuerpo dañino): retroceso e invulnerabilidad. Durante el retroceso el jugador no camina
  ni salta: ni el tiempo coyote ni el salto en cola valen hasta que termina.
- Peligro (pinchos, ácido, fosas): quita una vida aunque el jugador sea invulnerable (como Hollow Knight) y el
  jugador vuelve a su punto seguro, sin retroceso, quieto `ticks_reaparicion_peligro` e invulnerable. Antes, como en
  Hollow Knight, se queda quieto donde lo tocó mientras la pantalla funde a negro y pasa al punto en el tick en que el
  negro tapa todo; la imagen aclara con el jugador ya quieto en el punto (duraciones en «Fundido», más abajo). Durante el fundido nada lo daña. La salida por abajo se revisa antes de mover al
  jugador, como un `DanoContacto`, para contar los ticks a la par del fundido. Mientras está quieto tras reaparecer, ningún peligro cuenta (el contacto de un `DanoContacto` se revisa con la lista del tick
  anterior). Anti-bucle (como Silksong): si otro peligro lo toca antes de `ticks_anti_bucle` ticks con control (30 =
  0,5 s), vuelve al punto por el que entró a la sala (puerta, banco o `Entrada`) sin perder vida; ese punto pasa a
  ser su punto seguro y el siguiente peligro ya quita vida. El punto seguro es una posición con `ticks_suelo_firme` ticks seguidos en el suelo fuera de la
  invulnerabilidad, tomada `ticks_atras_punto_seguro` posiciones atrás.
- Salir por abajo de `limites` (los pies a más de `margen_fuera_de_sala` del borde) es un peligro igual que un
  pincho: `recibir_dano(1, x, true)`. Solo por abajo; por los lados y por arriba una sala se cierra con paredes
  o puertas. Sin sala, los límites son enormes y no ocurre.
- Muerto (`muerto = true`), el jugador se pinta oscuro y ya no responde a la entrada. 90 ticks (1,5 s) después, la
  sala llena las vidas (`Partida.llenar_vidas()`) y el jugador reaparece en el último banco donde descansó (cambia a
  `Partida.sala`); si no ha descansado, la sala recarga su escena y reaparece en su `Entrada`.
- Pogo: `atacar` con `mover_abajo` mantenida en el aire pone el área de ataque debajo del jugador (`posicion_pogo`).
  Si toca un `Golpeable` (que recibe el golpe y da Inspiración) o un peligro, el jugador rebota hacia arriba
  `altura_pogo` sin recibir daño, una vez por ataque, y recupera el doble salto y el impulso en el aire. Soltar
  `saltar` no corta el rebote, y no hay empuje horizontal. Cuenta en `rebotes_pogo`.
- Aterrizaje duro: corta el ataque, el impulso y la curación a medias y deja al jugador quieto `ticks_aterrizaje_duro`
  ticks; la gravedad y los golpes siguen. Las pulsaciones de saltar, atacar y curar hechas durante él se pierden; lo
  mantenido (caminar) cuenta al terminar. Lo cortan un golpe, un peligro (siempre: vuelve al punto seguro), morir y
  sentarse; el banco no sienta mientras dura. Emite `jugador_aterrizo`.
- `vidas`, `muerto`, `toques_poder`, `rebotes_pogo`, `en_picada`, `golpes_onda`, `descansando`, `temblor_x`, `temblor_y`, `aterrizando`, `paradas`, `corriendo`, `atacando_en_carrera`, `girando` e `invulnerable` (`aterrizando`, `girando` e `invulnerable`, de solo lectura) son propiedades
  públicas: los guiones las leen con `valor Jugador vidas`.

Curar y sensación del golpe:

- Botón de poderes: soltar `curar` antes de `ticks_mantener_poder` ticks es un toque (suma uno a `toques_poder`,
  propiedad pública, y lanza el poder); mantenerlo hasta ese tick intenta curar. Una pulsación que empieza durante
  el impulso o el retroceso no cuenta, y un golpe o volver al punto seguro pierden la que va a medias.
- Curar: al llegar a `ticks_mantener_poder`, si el jugador está en el suelo, con vidas por llenar, fuera del
  retroceso y del impulso, y con `Partida.inspiracion >= costo_curacion`, se queda quieto y gasta la Inspiración
  poco a poco mientras mantiene `curar`. A los `ticks_curacion` ticks recupera una vida y emite `jugador_curado`. Soltar, dejar el suelo o recibir daño antes lo
  corta y lo gastado se pierde. Cada golpe a un `Golpeable` da `inspiracion_por_golpe` (tope 99).
- Sensación: al golpear, el jugador sale empujado hacia atrás y lo golpeado hacia el otro lado
  (`Golpeable.velocidad_retroceso`, `ticks_retroceso`). Al recibir daño (no de un peligro), el jugador se detiene
  `ticks_hit_stop` ticks antes del retroceso.
- Congelado común (`nucleo/congelado.gd`, `class_name Congelado`, estático), como `FreezeMoment` de Hollow Knight:
  `Congelado.pedir(ticks)` detiene unos ticks al jugador, a los `Golpeable` empujados y a los proyectiles, que
  preguntan `Congelado.activo()` al empezar su tick (sin `Engine.time_scale`: los guiones cuentan ticks). Lo piden
  el daño al jugador (`ticks_hit_stop`), un enemigo vencido (`Congelado.TICKS_AL_VENCER`, 4) y el parry. La sala lo reinicia
  al entrar.

Habilidades (solo si `Partida.tiene(&"<id>")`):

| Id | Qué hace |
|---|---|
| `impulso` | La acción `impulso` lanza al jugador hacia donde mira, sin gravedad, `ticks_impulso` ticks; recarga `ticks_recarga_impulso`. En el aire, uno hasta tocar el suelo o una pared. Nunca hacia abajo ni solo con el joystick. Si al terminar hay dirección, empieza la carrera (`corriendo`) a `velocidad_carrera` hacia ella, en el suelo o en el aire: sigue hasta soltar la dirección más de `ticks_soltar_carrera` ticks, chocar con una pared, curarse, recibir daño, la picada, sentarse en un banco o el aterrizaje duro; saltar la conserva (salto largo); pedir el otro lado la gira (`girando`, `ticks_giro_carrera`) sin apagarla, y un impulso, despegue o rebote a mitad del giro lo cancela (al volver, si la dirección se opone, empieza otro); en carrera el impulso sale hacia el joystick; atacar al frente en carrera (no durante el giro) es un ataque en carrera (`atacando_en_carrera`): empuja a `velocidad_ataque_carrera` y no rebota al golpear |
| `salto_en_pared` | En el aire, cayendo y empujando hacia una pared, el jugador se sostiene y desliza a `velocidad_deslizar_pared` (`en_pared`). Tocándola y empujando hacia ella, suba o baje (y hasta `ticks_coyote_pared` después), `saltar` da un salto completo y lo despega hacia el lado contrario: así se sube por una sola pared o de una pared a la otra. Recupera el impulso y el doble salto |
| `doble_salto` | `saltar` recién presionada en el aire, fuera del tiempo coyote, da un segundo salto con las mismas reglas; se recupera al tocar el suelo o sostenerse en una pared |
| `caida_en_picada` | `curar` recién presionada con `mover_abajo`, con `Partida.inspiracion >= costo_poder`, gasta ese costo en el mismo tick (sin esperar a saber si es un toque). En el aire, el jugador cae enseguida recto a `velocidad_picada`, sin control, hasta tocar el suelo (`en_picada`, propiedad pública). En el suelo, primero un saltito de `altura_saltito_picada` y `ticks_carga_picada` quieto en su cima, y después la caída. Un `SueloFragil` que toca se rompe y la caída sigue. Corta un ataque a medias. No recibe daño desde que empieza hasta `ticks_invulnerable_picada` después de aterrizar (un peligro sí quita vida y lo devuelve al punto seguro). Al aterrizar, una onda de `onda_picada` golpea con `dano_picada` a cada `Golpeable` que toca, sin dar Inspiración |
| `proyectil` | Un toque del botón de poderes, con `Partida.inspiracion >= costo_poder` y pasados `ticks_recarga_bola` desde la anterior, gasta ese costo y lanza la bola (`nucleo/proyectil.tscn`) hacia donde mira, en el suelo o en el aire. Nombre técnico neutro |

- `nucleo/objeto_habilidad.tscn` (`class_name ObjetoHabilidad`): al tocarlo, suma su `habilidad` a `Partida.habilidades`,
  emite `Eventos.habilidad_obtenida` y desaparece; si la partida ya la tiene, no aparece.
- Prioridad del movimiento horizontal: retroceso del golpe recibido, impulso, despegue de la pared, rebote al
  golpear, carrera y por último la entrada.

| Componente | Qué es |
|---|---|
| `nucleo/golpeable.gd` (`class_name Golpeable`, `Area2D`) | Hijo de lo que el ataque o la bola pueden golpear, con su forma. `recibir_golpe(atacante, dano := 1)` cuenta `golpes` y `dano_recibido`, empuja a su padre lejos del atacante (`velocidad_retroceso` 240 px/s, `ticks_retroceso` 6; 0 para que no se mueva; golpeado justo desde arriba no se empuja), emite su señal `golpeado(atacante, dano)` y `Eventos.enemigo_golpeado` con su padre |
| `nucleo/suelo_fragil.gd` (`class_name SueloFragil`, `StaticBody2D`) | Sólido que se pisa como cualquier otro y que rompe la caída en picada (`romper()`: `roto` y desaparece). Va en la sala con su forma y su dibujo. Con `id` (obligatorio en las salas con id) se marca en el estado de su sala al romperse y ya no aparece al entrar |
| `nucleo/coleccionable.tscn` (`class_name Coleccionable`, `Area2D`) | Al tocarlo el jugador vivo: se marca en el estado de su sala, emite `coleccionable_obtenido` (autoguarda) y desaparece; marcado, no aparece. `id` único en la sala que empieza con `coleccionable`. Gris, sin tema |
| `nucleo/entrega_recompensas.gd` (`class_name EntregaRecompensas`, `Area2D`) | Con el jugador encima y en el suelo, `interactuar` entrega cada `Recompensa` de su lista cuya `cantidad` ya se juntó y no se entregó (marca `entregado_<cantidad>` en su sala) y autoguarda. `entregadas` las cuenta |
| `nucleo/recompensa.gd` (`class_name Recompensa`, `Resource`) | `cantidad`, `tipo` (`MONEDAS`, `VIDA_MAXIMA`, `AMULETO`, `HABILIDAD`), `monto` e `id` |
| `nucleo/vitrina_coleccionables.gd` (`class_name VitrinaColeccionables`, `Node2D`) | Dibuja `total_del_juego` lugares, llenos los `juntados` (leído al entrar): la sala donde se ven los coleccionables |
| `nucleo/cortable.tscn` (`class_name Cortable`, `Area2D`) | Decoración que corta el ataque (pasto y lo que cada zona quiera). `cortar()` oculta el hijo `Entero`, muestra `Cortado`, suelta `trozos` partículas y emite `cortado`; no da Inspiración, no rebota al jugador ni cuenta como enemigo. Se sacude al pasar el jugador (`sacudidas`). No se guarda: vuelve al entrar otra vez a la sala. `esta_cortado` es pública. Para otra forma, se hereda la escena y se cambian `Entero` y `Cortado` |
| `nucleo/proyectil.tscn` (`class_name Proyectil`, `Area2D`) | La bola: avanza recto y sin gravedad (`velocidad` 900 px/s, `ticks_vida` 60) y golpea una vez, con su `dano` (2), a cada `Golpeable` que toca, sin detenerse. Desaparece contra un sólido, que busca con un rayo porque un `Area2D` no detecta un `StaticBody2D`. Si el jugador está pegado a una pared, no llega a salir (se cobra igual). No da Inspiración |
| `nucleo/dano_contacto.gd` (`class_name DanoContacto`, `Area2D`) | Daña al jugador mientras lo toca (`dano`, 1 por omisión). Con `peligro = true` es un peligro (punto seguro); si no, un golpe normal (retroceso). Regla, como Silksong: lo fijo (pinchos, ácido, lava, vacío) es peligro; lo que se mueve (sierras que viajan, trampas, lo que lanza un jefe) solo golpea, y el validador falla si un `DanoContacto` con `peligro` está dentro de un `Vaiven`, un `Enemigo`, un `PathFollow2D` o un cuerpo que se mueve. Revisa el contacto cada tick: quien sigue dentro vuelve a recibir daño al acabarse la invulnerabilidad. No es sólido |
| `nucleo/vaiven.gd` (`class_name Vaiven`, `Node2D`) | Pieza que va y viene en línea recta: `recorrido` en `ticks_ida` ticks, vuelta y repite; quieta durante el congelado común. Al entrar fija `peligro = false` en cada `DanoContacto` que lleva |

## Sala

Una sala es una escena cuya raíz es un `Node2D` con `nucleo/sala.gd` (`class_name Sala`).

| Pieza | Qué es |
|---|---|
| Propiedad `id` (`String`, exportada) | `<zona>_<número>` (`celda_1`), igual al nombre del archivo. Es lo que guardan la partida y el mapa. Vacío solo en las salas de prueba sueltas de `herramientas/salas/`, que se nombran por su ruta |
| Nodo `Entrada` (`Marker2D`, hijo de la raíz) | Donde aparece el jugador. Sin él, aparece en el origen de la sala |
| Propiedad `limites` (`Rect2`, exportada) | Rectángulo de la sala en sus coordenadas. La cámara del jugador sigue al jugador y no muestra nada fuera de él en cada eje donde la sala es al menos tan grande como la vista |
| El jugador | No va dentro de la escena: la sala instancia `nucleo/jugador.tscn` en su `_ready` y le pasa `limites` |
| Suelos y plataformas | `StaticBody2D` sólidos por todos lados: el núcleo no ofrece plataformas atravesables desde abajo (`one_way_collision`), decidido el 07-oct-2026 |
| Controles, pausa, vibración, fundido, interfaz y mapa | También los crea la sala en su `_ready`: `ControlesTactiles`, `Pausa`, `Vibracion`, `Fundido` y, si existen, `interfaz/interfaz.tscn` y `mapa/pantalla_mapa.tscn` (con `load()`, para que el núcleo no dependa de esos bloques; ver «Interfaz» y «Mapa») |
| Propiedad `posicion_mapa` (`Vector2`) | Esquina de la sala en el mapa del mundo, en px: el mapa la dibuja en `posicion_mapa + limites`. Las salas de una zona se acomodan como se recorren. Cambiarla obliga a regenerar el índice del mapa |
| Propiedad `habilidades_de_prueba` (`Array[StringName]`) | Solo salas de prueba: habilidades que la sala da en silencio al entrar (sin aviso ni autoguardado). Las de `herramientas/salas/` dan `pluma`, salvo la de combate chico, donde se recoge. El validador la exige vacía en `contenido/` |
| Puertas (opcionales) | Instancias de `nucleo/puerta.tscn` (`class_name Puerta`, `Area2D`), hijas directas de la raíz. Ver abajo |
| Capas de fondo y de frente (opcionales) | Nodos `Parallax2D` hijos de la raíz. `scroll_scale` menor que 1 para el fondo (más lejos, más lento) y mayor que 1 para el frente; `z_index` negativo para el fondo y positivo para el frente |

- Dónde vive cada sala: las del juego en `contenido/salas/<zona>/<id>.tscn`; las de las zonas de prueba en
  `herramientas/salas/zonas/<zona>/<id>.tscn`. La zona es lo que va antes del primer guion bajo del id: una palabra
  sin guion bajo (`celda`, `raices`).
- Al entrar, la sala se anota en `Partida.salas_visitadas`. `Sala.clave_de(nodo)` (estática) da la clave de la sala a
  la que pertenece un nodo de su escena.
- `Sala.ruta_de(id)` (estática) da la escena de un id (primero `contenido/`, después la zona de prueba si existe);
  una ruta `res://` pasa tal cual. `Sala.zona_de(id)` da su zona. `clave()` es el id de la sala o, si no tiene, su
  ruta: lo que guardan `Partida.sala`, la clave de los enemigos fuertes y `cambio_de_sala`.
- Convenciones de ids: puertas por su lado (`izquierda`, `derecha`, `arriba`, `abajo`; dos del mismo lado,
  `derecha_2`); banco `banco_<id de la sala>`; objetos que se recuerdan, un nombre corto único dentro de la sala.
- El validador revisa cada sala con id: id `<zona>_<número>` igual al archivo, en la carpeta de su zona y sin
  repetir; `limites` con área; `Entrada` dentro de `limites`; cada puerta con id único y destino existente; puertas
  de ida y vuelta (si A lleva a la puerta P de B, P lleva de vuelta a la misma puerta de A); bancos con id
  `banco_<id>`; suelos frágiles y coleccionables con id único en la sala.
- Una capa se desplaza en proporción a la cámara: su posición es el borde de la cámara por `1 - scroll_scale`
  (medido en un guion el 06-oct-2026). Para que no queden huecos, el contenido de una capa cubre, en cada eje,
  desde 0 hasta `(tamaño de la sala - tamaño de la pantalla) × scroll_scale + tamaño de la pantalla`. Con
  `aspect=expand` la pantalla puede ser más ancha que 1280: la sala de prueba deja 2560 px de margen de cada lado.
- Cámara, como en Hollow Knight: el jugador la mueve a mano y recorta su objetivo a `limites` antes de suavizar, así
  se frena sola al acercarse al borde. Bajo el suelo basta el margen de siempre (40 px): sin jalón al caer
  (`camara_caida.guion`, 07-oct-2026); las salas de caída larga dejan 120 px (16,7 % de 720 de suelo a la vista).
  El margen casi no cambia el jalón (89,8 px/s por tick con 40 px, 93,1 con 120; umbral 100); las salas de 720 de
  alto no crecen, porque su cámara empezaría a moverse en vertical al saltar. Si la vista es mayor que la sala en un eje, la cámara se centra en ese eje y
  lo que sobra se ve por igual a los dos lados, como ya hacía `Camera2D` (`camara_centrada.guion`); sus `limit_*` quedan como seguro.
- Fondo extendido: si la sala tiene un nodo `Fondo` (`ColorRect`) visible, al entrar crea detrás de todo
  `FondoExtendido`, de su color y `MARGEN_FONDO` (280 px) más grande por lado: cubre el rango de la vista en una sala
  mínima de 1280×720 (240) más el temblor de la cámara. Sin `Fondo` visible no crea nada y lo de fuera se ve negro, el color de borrado.
- Fundido a negro (`nucleo/fundido.gd`, `class_name Fundido`, `CanvasLayer` capa 15: encima del juego, los controles y
  la interfaz, que se oscurecen con él, y debajo de la pausa y el editor de botones): la sala lo crea en negro y aclara
  en `TICKS_ACLARAR` ticks (0,25 s). Oscurece en `TICKS_OSCURECER` (0,15 s), sigue en negro los ticks que pida
  (`TICKS_EN_NEGRO_PELIGRO`, 0,3 s; `TICKS_EN_NEGRO_PUERTA`, 0,1 s) y aclara cuando alguien emite `fundido_pedido`;
  cuenta ticks de física, así los
  guiones dan siempre lo mismo. Su `opacidad` (0 a 1) la leen los guiones
  (`fundido_peligro`, `fundido_peligro_sostenido`, `fundido_puerta`). Muerte: en los últimos `TICKS_OSCURECER` de los 90 ticks oscuro, la sala
  funde a negro y la sala siguiente (o la misma, recargada) aclara.

Cambio de sala:

| Propiedad de `Puerta` | Qué es |
|---|---|
| `id` | Texto único dentro de su sala |
| `sala_destino` | Ruta `res://` de la escena de la sala a la que lleva |
| `puerta_destino` | `id` de la puerta de la sala destino donde aparece el jugador |
| `llegada` | Dónde aparece el jugador al llegar por esta puerta, relativo a ella; fuera de su área para no rebotar |

- Cuando el jugador entra al área de una puerta, la pantalla funde a negro (`Fundido.TICKS_OSCURECER` ticks, con el
  jugador todavía en la sala), sigue en negro `Fundido.TICKS_EN_NEGRO_PUERTA` ticks y después la puerta guarda `puerta_destino` en `Sala.puerta_llegada` (variable
  estática) y cambia de escena en diferido; la sala nueva empieza en negro y aclara. Si el jugador muere mientras
  funde, la puerta no cambia de sala: manda la muerte. La sala nueva pone al jugador en `llegada` de esa puerta. Si no la
  encuentra, imprime un `ERROR:` y lo pone en `Entrada`. Ese error ocurre al correr: lo atrapa un guion que cruza
  la puerta, no `validar.ps1`.
- Lo que sobrevive al cambio de sala vive en `Partida` (ver «Estado de la partida»).

Bancos:

- `nucleo/banco.tscn` (`class_name Banco`, `Area2D`), hijo directo de la raíz de una sala. Con el jugador encima,
  en el suelo y vivo, la acción `interactuar` lo hace descansar: sienta al jugador sobre el banco (`sentarse(x)`:
  queda en la x del banco, quieto y dibujado más bajo, `descansando`), llena las vidas, guarda en `Partida.banco` su
  `id` y en `Partida.sala` la clave de la sala, guarda la partida (`Partida.guardar(ruta_guardado)`) y emite
  `Eventos.descanso_en_banco(id)`. Sentado, `interactuar` no vuelve a descansar. Se levanta con `mover_izquierda`,
  `mover_derecha`, `mover_abajo`, `saltar` o `atacar` recién presionadas, sin saltar ni atacar; un golpe también lo
  levanta.
- `id` es único en todo el juego. Con `ruta_guardado` en `Guardado.RUTA` (por omisión) guarda en
  `Partida.ruta_guardado`; una sala de prueba puede fijar otro archivo.
- `Sala.llegada_a_banco` (estática): la sala nueva (`Sala.ruta_de(Partida.sala)`) pone al jugador en el banco `Partida.banco`. La usan la
  reaparición y Continuar. Sin ese banco en la sala, imprime un `ERROR:` y usa `Entrada`.

Las salas de prueba viven en `herramientas/salas/` (ver «Paquete de publicación»).

## Enemigos

Un enemigo es una instancia de `nucleo/enemigo.tscn` (`class_name Enemigo`, `Node2D`), hija directa de la raíz de
una sala, con su ficha y un `id` único dentro de la sala. Un enemigo nuevo es una ficha `.tres`; cómo se mueve y
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

- El enemigo lleva un `Golpeable` (recibe los golpes; público como `golpeable`) y un `DanoContacto` (su cuerpo, que
  daña al jugador y nunca se para). A vida 0 emite `Eventos.enemigo_vencido(ficha.id)`, pide el congelado común y
  desaparece.
- `nucleo/comportamiento_enemigo.gd` (`class_name ComportamientoEnemigo`, `Node`): hijo del enemigo, con `enemigo`
  fijado. Cada tick fuera del congelado llama `actuar()`, que cada comportamiento sobrescribe. Ofrece `jugador()`,
  `atacar(rectangulo, ticks, dano, se_puede_parar)` (un `AtaqueEnemigo` hijo del enemigo, relativo a sus pies) y
  `disparar(desplazamiento, direccion, dano, se_puede_parar)` (un `ProyectilEnemigo` en la sala).
- `nucleo/ataque_enemigo.gd` (`class_name AtaqueEnemigo`, hereda de `DanoContacto`): el ataque, separado del cuerpo;
  daña mientras dura (`ticks`; 0, hasta que lo quiten) y no corre durante el congelado. Con `se_puede_parar` se
  dibuja blanco (sin la marca, rojo). `parado` es pública.
- `nucleo/proyectil_enemigo.gd` (`class_name ProyectilEnemigo`, hereda de `AtaqueEnemigo`): avanza recto a
  `velocidad` (480 px/s) hasta un sólido o 180 ticks.
- Parry: el ataque normal del jugador (en cualquier dirección) que toca un `AtaqueEnemigo` con `se_puede_parar` lo
  para: el ataque desaparece sin dañar, el jugador queda `ticks_invulnerable_parry` (15) ticks sin daño de enemigos
  (los peligros sí dañan), congelado común de `ticks_congelado_parry` (3), el enemigo dueño del ataque recibe el golpe
  (con su Inspiración; un disparo no tiene dueño en la sala y nadie lo recibe) y se emite `parry`. Lo resuelve quien se procese primero: el jugador en su ataque o el
  `AtaqueEnemigo` antes de dañar (`Jugador.intentar_parar`). `paradas` del jugador las cuenta.
- Débil: reaparece solo, porque la sala se instancia de nuevo cada vez que se entra. Fuerte: al vencerlo,
  `Partida.vencer(clave())` lo anota y, mientras siga anotado, no aparece al entrar a su sala. La lista se borra
  al descansar en un banco y al morir el jugador (como los semipersistentes de Hollow Knight).

## Interfaz

Bloque `interfaz/`: lo que se dibuja encima del juego. `interfaz/interfaz.tscn` (`CanvasLayer` `Interfaz`, capa 10)
con un `Control` `Hud` (`interfaz/hud.gd`, `class_name Hud`). La sala lo carga con `load()` si la escena existe
(`Sala.INTERFAZ`).

- Se entera de todo por el bus (`vidas_cambiadas`, `inspiracion_cambiada`, `partida_guardada`) y lee `Partida` una
  sola vez al crearse, para el primer cuadro. Nunca lee al jugador.
- Corazones arriba a la izquierda, uno por vida máxima, llenos o vacíos; debajo, la barra de Inspiración en bloques
  de 11 (lo que da un golpe) hasta `INSPIRACION_MAXIMA`, con el bloque a medias dibujado a medias. Centro del grupo
  en (17 %, 12 %) de una pantalla 16:9, anclado arriba a la izquierda y medido en el lado corto; una vida más crece
  hacia la derecha.
- PejeCoins bajo la barra (`monedas_cambiadas`).
- Ícono de guardado provisional (un rombo que gira) bajo las PejeCoins, alineado a la izquierda del grupo, durante
  2 s después de `partida_guardada`. Es un nodo propio que gira con `rotation`: no redibuja el resto de la interfaz.
- `vidas`, `vidas_maximas`, `inspiracion`, `inspiracion_maxima`, `bloques_llenos`, `monedas` y `aviso_visible` son públicas: los
  guiones las leen con `valor Interfaz/Hud`.

## Mapa

Bloque `mapa/`: no conoce ninguna zona; dibuja lo que hay y, si no hay nada, no dibuja. La sala carga
`mapa/pantalla_mapa.tscn` con `load()` si existe (`Sala.MAPA`).

- `PantallaMapa` (`CanvasLayer`, capa 20, grupo `pantalla_encima`, corre en pausa): la acción `mapa` abre y cierra el
  mapa completo, que detiene el juego (`get_tree().paused`); `mapa_rapido` mantenida lo muestra encima sin detenerlo
  (como en Hollow Knight y Silksong). Con la pausa abierta el mapa no se abre. Abierto, `pausa` y Atrás lo cierran.
- Dos estados del mapa completo: acercado (las salas de la zona actual con borde, o su dibujo) y alejado (cada zona
  como la silueta rellena de sus salas, con su nombre); abre acercado, y los botones «−» y «+» cambian. Si la zona
  actual no tiene nada dibujado, se ve alejado. El mapa rápido siempre va acercado.
- Se dibujan las salas de `Partida.salas_mapeadas` (las llena el banco: ver «Estado de la partida») que están en el
  índice, solo con la habilidad `pluma_mapa`. El jugador se marca solo con el amuleto `brujula` en
  `Partida.amuletos_equipados`, en `posicion_mapa + posición del jugador`.
- `mapa/objeto_mapa.tscn` (`class_name ObjetoMapa`): al tocarlo, su `zona` (vacía: la de la sala) entra en
  `Partida.mapas` y desaparece; si ya se tiene, no aparece.
- `mapa/indice_salas.tres` (`IndiceSalas`): por cada sala con id, su rectángulo en el mundo, su ruta y, si existe
  `<id>_mapa.png` junto a la sala, su dibujo (que reemplaza al rectángulo). Lo escribe
  `herramientas/generar_mapa.tscn` y el validador falla si no coincide con las salas: el paquete exportado no deja
  listar escenas con fiabilidad. No se edita a mano.
- `abierta`, `rapido` y `acercado` de la pantalla, y `salas_dibujadas`, `zonas_dibujadas`, `marcador_visible`,
  `quedo_acercado` y `marcador_en_pantalla` de su `lienzo`, son públicas para las pruebas. Con el mapa rápido a la vista,
  cada tick solo se mueve el punto del jugador (un nodo aparte); el mapa se rehace al abrir, al cambiar de estado, al
  equipar o quitar la brújula y al descansar. Los dibujos de las salas se cargan al preparar la vista, no al dibujar.

## Grupos

| Grupo | Quién lo lleva | Quién lo usa |
|---|---|---|
| `jugador` | El cuerpo que controla la persona: el `Jugador` que crea la sala, o la caja gris (`sala_inicial`) | El puerto de depuración lee de su primer nodo la posición y si está en el suelo |
| `pantalla_encima` | Una pantalla de otro bloque abierta sobre el juego (hoy, `PantallaMapa`) con `bloquea_pausa() -> bool` | La `Pausa`: no se abre (con `pausa`, Atrás ni al perder el foco) mientras una diga que bloquea, ni en el tick en que se cerró |

## Guiones de entrada

Un guion reproduce entradas por cuadro de física y compara el estado con un archivo de valores esperados. Lo
corre el puerto de depuración (`herramientas/puerto_depuracion.gd`), en local y en el CI:

```powershell
& $env:GODOT_PATH --headless --path . --fixed-fps 60 --quit-after 7200 -- --guion=herramientas/guiones/<bloque>/<nombre>.guion
```

- `<nombre>.guion`: líneas `<cuadro> <acción> press|release` y una línea `fin <cuadro>`. Los cuadros de las
  entradas van de 1 a `fin` menos 1.
- Línea opcional `escena <ruta res://>`: el puerto cambia a esa escena al empezar y el cuadro 1 es el primer
  cuadro de física con ella ya cargada. Sin la línea, el guion corre sobre la escena principal. Una ruta que no
  existe hace fallar el guion.
- Medido el 06-oct-2026: una acción que el jugador lee como sostenida (caminar) se nota en el estado del cuadro
  N+1; una que lee como recién presionada (`saltar`), en el del cuadro N+2. Los cuadros de un guion se miden con
  una corrida, no se calculan.
- `<nombre>.esperado`, junto al guion: líneas `<clave> <valor> [tolerancia]`.

  | Clave | Valor | Se compara |
  |---|---|---|
  | `x`, `y` | Posición global del nodo del grupo `jugador`, en píxeles | Con tolerancia; 0,5 si no se indica |
  | `en_suelo` | `true` o `false` | Exacto |
  | `escena` | Ruta `res://` de la escena actual | Exacto |
  | `valor <nodo> <propiedad>` | Valor de una propiedad de un nodo; admite subpropiedades (`position:x`) | Un número, con tolerancia (0,5 si no se indica); otro valor, por su texto |
  | `senal <nodo> <señal>` | Cuántas veces se emitió la señal desde el cuadro 1 | Exacto |

  `<nodo>` es una ruta relativa a la escena actual (`.` es su raíz, `Jugador` el jugador que crea la sala) o
  absoluta (`/root/<autoload>`). El puerto se conecta a las señales en el cuadro 1: un nodo o una señal que no
  existen hacen fallar el guion. Como las líneas se parten por espacios, `valor` no compara valores cuyo texto
  lleva espacios (un `Rect2`, un `Vector2`): se usa una subpropiedad (`position:x`).

- En los dos archivos se ignoran las líneas vacías y las que empiezan con `#`.
- El estado se lee al empezar el cuadro `fin`. El puerto sigue contando cuadros con el juego en pausa.
- `Input.action_press` del puerto cambia el estado de la acción pero no genera un evento: lo que debe responder a
  un guion lee la acción (`Input.is_action_just_pressed`), no `_input` ni `_unhandled_input`.
- Resultado: una línea `GUION OK <ruta> cuadro=<n>` y salida 0, o `GUION FALLA <ruta>: <motivo>` y salida 1.
  Falla si el guion o su `.esperado` no existen, si una línea no es válida, si una acción no está en el
  `InputMap` o si el estado no coincide.
- Un guion comprueba lo que importa (llegó, está en el suelo, cambió de sala) con tolerancia; no todos los
  decimales.

## Paquete de publicación

El núcleo no depende de `herramientas/`: las únicas referencias son la carga condicional de `Arranque` (el puerto,
solo en un build de depuración) y el botón «Zona de pruebas» de la Configuración, que aparece con el modo
desarrollador encendido si `herramientas/salas/zona_pruebas.tscn` existe (`ResourceLoader.exists`, sin `preload`),
en depuración y en publicación. Que la zona viaje en el paquete de publicación lo decide el `exclude_filter` del
preset «Publicacion» de `export_presets.cfg`.

## Menú

`nucleo/menu.tscn` es la escena principal. Nueva partida (`Partida.reiniciar()`) y Continuar (carga el guardado en
`Partida`) llevan a la escena de su propiedad `sala_inicial` (hoy la caja gris, que tiene un botón «Volver al menú»
porque no es una sala y no tiene pausa); Continuar con un banco guardado lleva a la sala de ese banco y pone al jugador en él. Continuar se habilita solo si el guardado es `VALIDA`; con `VACIA`, `DANADA` o
`INCOMPATIBLE`, el menú dice por qué. «Configuración» (`nucleo/configuracion.tscn`, `class_name Configuracion`,
instancia `Configuracion` del menú) reemplaza al panel central con: «Botones táctiles» (el mismo editor que la pausa;
ver «Entrada»), «Botones del control» (reasignación con `Mando`: tocar una acción y presionar el botón del control;
«Por omisión»), Vibración, Temblor de cámara, Volumen, Modo desarrollador (con él aparece «Zona de pruebas»),
«Borrar partida» (con confirmación; `Guardado.borrar()`), «Créditos» y «Volver». Cada cambio se guarda al momento.
Atrás y la acción `pausa` vuelven un nivel a la vez (`atras()` del menú y de la Configuración): cancelan el editor, la
espera de un botón y la confirmación, de un subpanel vuelven a la lista, de la lista al menú, y en el menú piden
confirmación antes de cerrar la app. Se maneja con toque, teclado y control (el foco empieza en la primera opción de
cada pantalla). Las opciones nuevas de configuración se agregan a esa escena.
