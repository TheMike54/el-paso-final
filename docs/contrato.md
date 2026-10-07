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
| Estiramiento | `canvas_items` con aspecto `expand` | La base se escala a la pantalla; en pantallas más anchas se ve más escenario, sin barras |
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
- Pausar no guarda. La partida se guarda solo en los bancos.
- Pausa: `nucleo/pausa.tscn` (`class_name Pausa`), que crea cada sala. La acción `pausa` o el botón Atrás de
  Android la abren y la cierran (`get_tree().paused`); tiene Continuar, los interruptores de vibración y de temblor de
  cámara (mientras no haya Opciones) y «Salir al menú». Se abre sola al perder el foco (`NOTIFICATION_APPLICATION_FOCUS_OUT` o
  `NOTIFICATION_APPLICATION_PAUSED`: apps recientes, otra ventana) y no se cierra sola al volver. Corre con
  `PROCESS_MODE_ALWAYS`, igual que los controles táctiles. Su propiedad `abierta` dice si está abierta. La pausa
  lee la acción, no el evento: la abren igual la tecla, el botón táctil y un guion.
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

| `Guardado.Estado` | Cuándo |
|---|---|
| `VALIDA` | El archivo es JSON, su `version` es `VERSION` y `partida` tiene todos los campos del esquema con su tipo |
| `VACIA` | No hay archivo: partida nueva. Un `.tmp` sobrante de un cierre a la mitad no cuenta |
| `DANADA` | No es JSON, no es un objeto, falta `version` o no es número, `partida` no es un objeto, o le falta un campo o tiene otro tipo |
| `INCOMPATIBLE` | `version` es un número distinto de `VERSION`, más nuevo o más viejo. No hay migración |

- `RUTA` es `user://partida.json`; `VERSION` es 2 (la 1 no tenía `sala`).
- Esquema de la versión 2 (`Guardado.ESQUEMA`): `banco` (texto, id del último banco), `sala` (texto, escena de la sala
  de ese banco), `vidas_maximas` (número) y `habilidades` (lista). Un campo nuevo cambia el esquema y `VERSION` en el mismo cambio.
- Al leer, los números vuelven como `float`: `var vidas: int = partida["vidas_maximas"] as int`.
- Lo que se guarda sale del estado de la partida: `Partida.guardar()` escribe `Partida.a_diccionario()` y, si salió
  bien, emite `Eventos.partida_guardada`; Continuar carga el resultado con `Partida.desde_diccionario()` (con las
  vidas llenas) y lleva al jugador a su banco.

## Ajustes y vibración

`nucleo/ajustes.gd` (`class_name Ajustes`): funciones estáticas, como `Guardado`. Archivo `user://ajustes.json`
(`{"version": 1, "ajustes": {...}}`), escrito a un temporal y renombrado. Son del teléfono y no de la partida:
agregar un ajuste no cambia `Guardado.VERSION`. Un archivo que falta, dañado o de otra versión deja los valores
por omisión (`Ajustes.POR_OMISION`).

| Ajuste | Por omisión | Qué es |
|---|---|---|
| `vibracion` | `true` | Vibrar al pegar, al recibir daño, al curarse, al descansar y al aterrizar duro |
| `temblor` | `true` | Temblor de la cámara al aterrizar de una caída (se apaga por mareo). Un archivo sin la clave la deja encendida |

- `Ajustes.cargar_una_vez()` lo llaman la vibración, la pausa y el jugador al crearse; `Ajustes.guardar()`, los interruptores de la
  pausa.
- `nucleo/vibracion.gd` (`class_name Vibracion`, `Node`), que crea cada sala con el nombre `Vibracion`: escucha el
  bus y llama a `Input.vibrate_handheld(ms, fuerza)` con un patrón por evento (propiedades exportadas):

| Evento | Señal | Duración | Fuerza (0 a 1) |
|---|---|---|---|
| Pegarle a algo (ataque, pogo, bola, onda) | `enemigo_golpeado` | 25 ms | 0,35 |
| Recibir daño | `jugador_danado` | 60 ms | 0,8 |
| Curarse | `jugador_curado` | 40 ms | 0,45 |
| Descansar | `descanso_en_banco` | 70 ms | 0,5 |
| Aterrizaje duro y aterrizaje de la picada | `jugador_aterrizo` | 80 ms | 0,9 |

- Entre una vibración y la siguiente pasan al menos `ticks_entre_vibraciones` (4); recibir daño no espera. Nada más
  vibra: ni moverse, ni saltar, ni los menús. Cuenta en `pedidas` (con el ajuste encendido o no) y `enviadas`, y la
  última en `ultima`: los guiones las leen con `valor Vibracion`.
- En Android, `vibrate_handheld` necesita el permiso `VIBRATE` en el preset de exportación; sin él no vibra. Un
  teléfono sin control de fuerza solo respeta la duración.

## Estado de la partida

Autoload `Partida` (`nucleo/partida.gd`): lo que sobrevive al cambio de sala. Una sala nueva no reinicia nada.

| Propiedad o función | Qué es |
|---|---|
| `vidas`, `vidas_maximas` | Vidas actuales y máximas (4 al empezar). `Jugador.vidas` lee y escribe `Partida.vidas`. Cada cambio emite `vidas_cambiadas` |
| `banco`, `sala` | Id del último banco donde se descansó y la escena de su sala; vacíos si no se ha descansado |
| `habilidades`, `tiene(id)` | `Array[StringName]` con las habilidades obtenidas, y si una está |
| `enemigos_vencidos`, `vencer(clave)`, `fue_vencido(clave)` | Claves (`"<escena de la sala>#<id>"`) de los enemigos fuertes vencidos desde el último descanso. Se borra al oír `descanso_en_banco` y en `reiniciar()`; no se guarda |
| `inspiracion`, `ganar_inspiracion(n)` | Recurso de curación (0 a `INSPIRACION_MAXIMA`, 99); no se guarda, se reinicia con la partida. Cada cambio emite `inspiracion_cambiada` |
| `reiniciar()` | Partida nueva: la llaman Nueva partida y cada sala de la zona de pruebas |
| `llenar_vidas()` | Vidas al máximo: al reaparecer después de morir |
| `a_diccionario()` / `desde_diccionario(partida)` | Hacia y desde los campos de `Guardado.ESQUEMA`. Al cargar, lo que no se guarda empieza de cero: Inspiración 0 y sin enemigos vencidos |

## Autoloads

| Nombre | Script | Qué hace |
|---|---|---|
| `Eventos` | `nucleo/eventos.gd` | Bus de eventos: solo declara las señales de «Bus de eventos». Va antes de `Arranque` para existir cuando arranca todo lo demás |
| `Partida` | `nucleo/partida.gd` | Estado de la partida (ver «Estado de la partida»). Va después de `Eventos` y antes de `Arranque` |
| `Arranque` | `nucleo/arranque.gd` | Imprime `ARRANQUE depuracion=<bool> puerto=<bool>` y, solo en un build de depuración y si el archivo viaja en el paquete, carga con `load()` el puerto de depuración como hijo suyo (`PuertoDepuracion`) |

- Un autoload nuevo se agrega a esta tabla en el mismo cambio.
- Nada de `herramientas/` es autoload ni se carga con `preload`: el preset de publicación excluye esa carpeta y el
  juego publicado debe arrancar sin ella.

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
| `partida_guardada` | — | `Partida.guardar()`, cuando el guardado salió bien |
| `enemigo_golpeado` | `enemigo: Node` | Lo golpeable, al recibir un golpe del ataque o de la bola (solo el ataque llena la Inspiración) |
| `enemigo_vencido` | `enemigo: StringName` (id de su ficha) | El enemigo, al quedarse sin vida |
| `habilidad_obtenida` | `habilidad: StringName` | El objeto de habilidad al tocarlo (en el juego, lo darán los jefes) |
| `jefe_vencido` | `jefe: StringName` (id del jefe) | El jefe (todavía no existe) |
| `cambio_de_sala` | `sala: String` (ruta de la escena), `puerta: StringName` (por la que llegó) | La sala, ya con el jugador puesto, cuando se llega por una puerta |
| `jugador_aterrizo` | `velocidad: float` (px/s al tocar el suelo) | El jugador vivo, en un aterrizaje duro y al aterrizar de la picada (antes de la onda, para que su vibración gane a la del golpe) |

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
  distribución inicial; Impulso solo mientras `Partida.tiene(&"impulso")` (sin la habilidad no se dibuja ni responde,
  y un dedo encima se suelta al perderla; la tabla `HABILIDAD_DE_BOTON` dice qué botón pide qué habilidad). Anclados a su esquina y medidos en proporción del lado corto. Se ocultan con una tecla o
  el control y reaparecen al tocar la pantalla. Los dedos se recuerdan entre salas (variables estáticas): un dedo
  que sigue en la pantalla al cruzar una puerta o al reaparecer lo sueltan los controles de la sala nueva; si
  entre una sala y otra pasan más de `CUADROS_CAMBIO_DE_SALA` cuadros (el menú), al llegar se suelta todo. Mover y
  cambiar el tamaño de los botones entra después.
- Control (Xbox / PlayStation): un evento del InputMap junto a cada tecla, para cualquier control (`device` -1).
  El stick usa la zona muerta de cada acción (0,2); RT es un eje que cuenta como presionado pasada esa zona.
  `interactuar` comparte el stick arriba con `mover_arriba`, igual que la tecla. RB y LT quedan libres.

## Jugador

`nucleo/jugador.tscn` (`class_name Jugador`, `CharacterBody2D`): camina y salta con toda su lógica en
`_physics_process`. Reglas del salto, como en Hollow Knight; la caja gris de la escena principal no las lleva.
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
| `dano_ataque` | 1 | Daño de cada golpe del ataque a un `Golpeable` |
| `posicion_pogo` | (0, 50) px | Centro del área de ataque hacia abajo (pogo), relativo a los pies |
| `altura_pogo` | 120 px | Altura del rebote del pogo |
| `ticks_invulnerable` | 60 | Ticks sin recibir daño después de un golpe |
| `ticks_retroceso` | 10 | Ticks en que el retroceso manda sobre el movimiento horizontal |
| `retroceso` | (420, 420) px/s | Velocidad del retroceso: `x` alejándose del origen del daño, `y` hacia arriba |
| `ticks_suelo_firme` | 6 | Ticks seguidos en el suelo para que una posición cuente como punto seguro |
| `ticks_atras_punto_seguro` | 15 | Cuántas posiciones firmes atrás se reaparece tras un peligro: lejos de la orilla |
| `ticks_reaparicion_peligro` | 20 | Ticks quieto tras volver al punto seguro |
| `ticks_hit_stop` | 4 | Ticks que el jugador se detiene al recibir daño, antes del retroceso (contador propio, no `Engine.time_scale`) |
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

- El ataque es el área `Ataque` del jugador, hacia donde mira (el último lado al que caminó). Golpea una sola vez
  a cada `Golpeable` que toca durante un ataque.
- `recibir_dano(dano: int, origen_x: float, peligro := false)` es lo único que quita vidas. Durante la
  invulnerabilidad y la caída en picada (con su saltito y su carga) no quita vidas. Emite `jugador_danado` con las vidas que quedan y, al llegar a 0,
  `jugador_muerto`.
- Golpe normal (enemigo, cuerpo dañino): retroceso e invulnerabilidad. Durante el retroceso el jugador no camina
  ni salta: ni el tiempo coyote ni el salto en cola valen hasta que termina.
- Peligro (pinchos, ácido, fosas): quita una vida y el jugador vuelve a su punto seguro, sin retroceso, quieto
  `ticks_reaparicion_peligro` e invulnerable. Invulnerable no pierde vida, pero un peligro igual lo regresa al
  punto seguro. El punto seguro es una posición con `ticks_suelo_firme` ticks seguidos en el suelo fuera de la
  invulnerabilidad, tomada `ticks_atras_punto_seguro` posiciones atrás.
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
- `vidas`, `muerto`, `toques_poder`, `rebotes_pogo`, `en_picada`, `golpes_onda`, `descansando`, `temblor_x`, `temblor_y`, `aterrizando` e `invulnerable` (solo lectura) son propiedades
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
  `ticks_hit_stop` ticks antes del retroceso; el resto del juego sigue.

Habilidades (solo si `Partida.tiene(&"<id>")`):

| Id | Qué hace |
|---|---|
| `impulso` | La acción `impulso` lanza al jugador hacia donde mira, sin gravedad, `ticks_impulso` ticks; recarga `ticks_recarga_impulso`. En el aire, uno hasta tocar el suelo o una pared |
| `salto_en_pared` | En el aire, cayendo y empujando hacia una pared, el jugador se sostiene y desliza a `velocidad_deslizar_pared` (`en_pared`). Tocándola y empujando hacia ella, suba o baje (y hasta `ticks_coyote_pared` después), `saltar` da un salto completo y lo despega hacia el lado contrario: así se sube por una sola pared o de una pared a la otra. Recupera el impulso y el doble salto |
| `doble_salto` | `saltar` recién presionada en el aire, fuera del tiempo coyote, da un segundo salto con las mismas reglas; se recupera al tocar el suelo o sostenerse en una pared |
| `caida_en_picada` | `curar` recién presionada con `mover_abajo`, con `Partida.inspiracion >= costo_poder`, gasta ese costo en el mismo tick (sin esperar a saber si es un toque). En el aire, el jugador cae enseguida recto a `velocidad_picada`, sin control, hasta tocar el suelo (`en_picada`, propiedad pública). En el suelo, primero un saltito de `altura_saltito_picada` y `ticks_carga_picada` quieto en su cima, y después la caída. Un `SueloFragil` que toca se rompe y la caída sigue. Corta un ataque a medias. No recibe daño desde que empieza hasta `ticks_invulnerable_picada` después de aterrizar (un peligro igual lo devuelve al punto seguro). Al aterrizar, una onda de `onda_picada` golpea con `dano_picada` a cada `Golpeable` que toca, sin dar Inspiración |
| `proyectil` | Un toque del botón de poderes, con `Partida.inspiracion >= costo_poder` y pasados `ticks_recarga_bola` desde la anterior, gasta ese costo y lanza la bola (`nucleo/proyectil.tscn`) hacia donde mira, en el suelo o en el aire. Nombre técnico neutro: qué es en el mundo y dónde se obtiene está por decidir |

- `nucleo/objeto_habilidad.tscn` (`class_name ObjetoHabilidad`): al tocarlo, suma su `habilidad` a `Partida.habilidades`,
  emite `Eventos.habilidad_obtenida` y desaparece; si la partida ya la tiene, no aparece. Lo usan las salas de
  prueba; en el juego lo darán los jefes.
- Prioridad del movimiento horizontal: retroceso del golpe recibido, impulso, despegue de la pared, rebote al
  golpear y por último la entrada.

| Componente | Qué es |
|---|---|
| `nucleo/golpeable.gd` (`class_name Golpeable`, `Area2D`) | Hijo de lo que el ataque o la bola pueden golpear, con su forma. `recibir_golpe(atacante, dano := 1)` cuenta `golpes` y `dano_recibido`, empuja a su padre lejos del atacante (`velocidad_retroceso` 240 px/s, `ticks_retroceso` 6; 0 para que no se mueva; golpeado justo desde arriba no se empuja), emite su señal `golpeado(atacante, dano)` y `Eventos.enemigo_golpeado` con su padre |
| `nucleo/suelo_fragil.gd` (`class_name SueloFragil`, `StaticBody2D`) | Sólido que se pisa como cualquier otro y que rompe la caída en picada (`romper()`: `roto` y desaparece). Va en la sala con su forma y su dibujo. Que siga roto al volver a la sala todavía no se guarda |
| `nucleo/proyectil.tscn` (`class_name Proyectil`, `Area2D`) | La bola: avanza recto y sin gravedad (`velocidad` 900 px/s, `ticks_vida` 60) y golpea una vez, con su `dano` (2), a cada `Golpeable` que toca, sin detenerse. Desaparece contra un sólido, que busca con un rayo porque un `Area2D` no detecta un `StaticBody2D`. Si el jugador está pegado a una pared, no llega a salir (se cobra igual). No da Inspiración |
| `nucleo/dano_contacto.gd` (`class_name DanoContacto`, `Area2D`) | Daña al jugador mientras lo toca (`dano`, 1 por omisión). Con `peligro = true` es un peligro (punto seguro); si no, un golpe normal (retroceso). Revisa el contacto cada tick: quien sigue dentro vuelve a recibir daño al acabarse la invulnerabilidad. No es sólido |

| Regla | Qué hace |
|---|---|
| Salto variable | Mientras `saltar` sigue presionada, el jugador sube hasta una altura máxima. Al soltarla antes, la velocidad vertical se corta y el salto queda más bajo. Hay un mínimo de cuadros de subida: un toque corto da un salto bajo, no nulo |
| Tiempo coyote | `saltar` todavía funciona unos ticks después de salir caminando de una orilla |
| Salto en cola | `saltar` presionada unos ticks antes de aterrizar hace que el jugador salte al tocar el suelo |

- El tiempo coyote y el salto en cola son cortos: de 2 a 3 ticks, a 60 por segundo.
- Comprobación del salto variable: dos guiones revisan la altura en el mismo cuadro.
  `jugador_movimiento.guion` mantiene `saltar` y `jugador_salto_corto.guion` la suelta enseguida; el segundo
  debe quedar más bajo. `jugador_coyote.guion` y `jugador_salto_en_cola.guion` comprueban las otras dos reglas.

## Sala

Una sala es una escena cuya raíz es un `Node2D` con `nucleo/sala.gd` (`class_name Sala`).

| Pieza | Qué es |
|---|---|
| Nodo `Entrada` (`Marker2D`, hijo de la raíz) | Donde aparece el jugador. Sin él, aparece en el origen de la sala |
| Propiedad `limites` (`Rect2`, exportada) | Rectángulo de la sala en sus coordenadas. La cámara del jugador sigue al jugador y no muestra nada fuera de él en cada eje donde la sala es al menos tan grande como la vista |
| El jugador | No va dentro de la escena: la sala instancia `nucleo/jugador.tscn` en su `_ready` y le pasa `limites` |
| Controles, pausa, vibración e interfaz | También los crea la sala en su `_ready`: `ControlesTactiles`, `Pausa`, `Vibracion` y, si existe, `interfaz/interfaz.tscn` (con `load()`, para que el núcleo no dependa del bloque `interfaz/`; ver «Interfaz») |
| Puertas (opcionales) | Instancias de `nucleo/puerta.tscn` (`class_name Puerta`, `Area2D`), hijas directas de la raíz. Ver abajo |
| Capas de fondo y de frente (opcionales) | Nodos `Parallax2D` hijos de la raíz. `scroll_scale` menor que 1 para el fondo (más lejos, más lento) y mayor que 1 para el frente; `z_index` negativo para el fondo y positivo para el frente |

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

Cambio de sala:

| Propiedad de `Puerta` | Qué es |
|---|---|
| `id` | Texto único dentro de su sala |
| `sala_destino` | Ruta `res://` de la escena de la sala a la que lleva |
| `puerta_destino` | `id` de la puerta de la sala destino donde aparece el jugador |
| `llegada` | Dónde aparece el jugador al llegar por esta puerta, relativo a ella; fuera de su área para no rebotar |

- Cuando el jugador entra al área de una puerta, la puerta guarda `puerta_destino` en `Sala.puerta_llegada` (variable
  estática) y cambia de escena en diferido. La sala nueva pone al jugador en `llegada` de esa puerta. Si no la
  encuentra, imprime un `ERROR:` y lo pone en `Entrada`. Ese error ocurre al correr: lo atrapa un guion que cruza
  la puerta, no `validar.ps1`.
- Lo que sobrevive al cambio de sala vive en `Partida` (ver «Estado de la partida»).

Bancos:

- `nucleo/banco.tscn` (`class_name Banco`, `Area2D`), hijo directo de la raíz de una sala. Con el jugador encima,
  en el suelo y vivo, la acción `interactuar` lo hace descansar: sienta al jugador sobre el banco (`sentarse(x)`:
  queda en la x del banco, quieto y dibujado más bajo, `descansando`), llena las vidas, guarda en `Partida.banco` su
  `id` y en `Partida.sala` la escena de la sala, guarda la partida (`Partida.guardar(ruta_guardado)`) y emite
  `Eventos.descanso_en_banco(id)`. Sentado, `interactuar` no vuelve a descansar. Se levanta con `mover_izquierda`,
  `mover_derecha`, `mover_abajo`, `saltar` o `atacar` recién presionadas, sin saltar ni atacar; un golpe también lo
  levanta.
- `id` es único en todo el juego. `ruta_guardado` es `Guardado.RUTA`; las salas de prueba usan otro archivo para no
  tocar la partida real.
- `Sala.llegada_a_banco` (estática): la sala nueva pone al jugador en el banco `Partida.banco`. La usan la
  reaparición y Continuar. Sin ese banco en la sala, imprime un `ERROR:` y usa `Entrada`.
- Descansar hace reaparecer a los enemigos fuertes (ver «Enemigos»).
- El aviso «Partida guardada» lo muestra la interfaz al oír `partida_guardada`.

Las salas de prueba viven en `herramientas/salas/` y no viajan en el paquete de publicación.

## Enemigos

Un enemigo es una instancia de `nucleo/enemigo.tscn` (`class_name Enemigo`, `Node2D`), hija directa de la raíz de
una sala, con su ficha y un `id` único dentro de la sala. Lo que lo distingue es la ficha: un enemigo nuevo es
una ficha `.tres`, no código.

| Campo de `FichaEnemigo` (`nucleo/ficha_enemigo.gd`, `Resource`) | Qué es |
|---|---|
| `id` (`StringName`) | Id estable del tipo de enemigo; es lo que emite `enemigo_vencido` |
| `vida` (2) | Vida al aparecer; cada golpe le resta su daño (ataque 1, bola 2) |
| `dano_contacto` (1) | Vidas que le quita al jugador al tocarlo (golpe normal, con retroceso) |
| `tamano` ((80, 80) px) | Su cuerpo, con los pies en el origen; las formas del golpe y del contacto se crean con él |
| `color` | Color de la caja gris mientras no hay arte |
| `reaparicion` | `AL_VOLVER_A_ENTRAR` (débil) o `AL_DESCANSAR` (fuerte) |

- El enemigo lleva un `Golpeable` (recibe los golpes) y un `DanoContacto` (daña al jugador). A vida 0 emite
  `Eventos.enemigo_vencido(ficha.id)` y desaparece. Por ahora no se mueve.
- Débil: reaparece solo, porque la sala se instancia de nuevo cada vez que se entra. Fuerte: al vencerlo,
  `Partida.vencer(clave())` lo anota y, mientras siga anotado, no aparece al entrar a su sala. La lista se borra
  al descansar en un banco. Morir no la borra.

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
- «Partida guardada» bajo la barra durante 2 s después de `partida_guardada`.
- `vidas`, `vidas_maximas`, `inspiracion`, `inspiracion_maxima`, `bloques_llenos` y `aviso_visible` son públicas: los
  guiones las leen con `valor Interfaz/Hud`.

## Grupos

| Grupo | Quién lo lleva | Quién lo usa |
|---|---|---|
| `jugador` | El cuerpo que controla la persona: el `Jugador` que crea la sala, o la caja gris en la escena principal | El puerto de depuración lee de su primer nodo la posición y si está en el suelo |

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

El preset «Publicacion» de `export_presets.cfg` deja fuera `herramientas/` con su `exclude_filter`. El núcleo no
depende de `herramientas/`: las únicas referencias son la carga condicional de `Arranque` y el botón «Zona de
pruebas» del menú, que solo aparece si el build es de depuración y `herramientas/salas/zona_pruebas.tscn` existe
(`ResourceLoader.exists`, sin `preload`).

## Menú

`nucleo/menu.tscn` es la escena principal. Nueva partida (`Partida.reiniciar()`) y Continuar (carga el guardado en
`Partida`) llevan a la escena de su propiedad `sala_inicial` (por ahora la caja gris, hasta que exista la primera
sala del juego; la caja gris tiene un botón «Volver al menú», porque no es una sala y no tiene pausa); Continuar con un banco guardado lleva a la sala de ese banco y pone al jugador en él. Continuar se habilita solo si el guardado es `VALIDA`; con `VACIA`, `DANADA` o
`INCOMPATIBLE`, el menú dice por qué. Atrás o la acción `pausa` en el menú piden confirmación antes de cerrar la
app.
