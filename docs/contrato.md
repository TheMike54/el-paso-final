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
| Id del paquete Android | `com.themike54.elpasofinal` | Identidad estable de la app instalada |

## Ciclo de vida

- Arranque: Godot carga los autoloads y después la escena principal (`application/run/main_scene`).
- La lógica del juego corre en `_physics_process`, a 60 ticks por segundo. `_process` queda para lo visual.
- La acción `pausa` no guarda. La partida se guarda al descansar en un banco y se autoguarda (lo obtenido, nunca la
  posición: al continuar se aparece en el último banco) en los momentos que lista `autoguardar()` en «Estado de la
  partida».
- Pausa: `nucleo/pausa.tscn` (`class_name Pausa`), que crea cada sala. La acción `pausa` o el botón Atrás de
  Android la abren y la cierran (`get_tree().paused`); tiene Continuar, «Configuración» (la misma del menú, en la capa
  22 encima de la pausa y con el juego detenido, sin «Desarrollador»; de ahí sale el editor de los botones táctiles;
  ver «Menú» y «Entrada») y «Salir al menú», como en Hollow Knight. Los amuletos, el inventario y el mapa están en el
  marco de menús (ver «Marco de menús»). Al abrirse guarda una copia de la pantalla para la pantalla de brillo (no en
  headless) y la suelta al cerrarse. Se abre sola al perder el foco (`NOTIFICATION_APPLICATION_FOCUS_OUT` o
  `NOTIFICATION_APPLICATION_PAUSED`: apps recientes, otra ventana) y no se cierra sola al volver. Corre con
  `PROCESS_MODE_ALWAYS`, igual que los controles táctiles. Su propiedad `abierta` dice si está abierta. La pausa
  lee la acción, no el evento: la abren igual la tecla, el botón táctil y un guion. Con el editor abierto (`editor`
  no es `null`), la acción `pausa` no hace nada y Atrás es Cancelar. Con Configuración abierta, `pausa` y Atrás
  vuelven un nivel en ella (`Configuracion.atras()`).
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
| `Guardado.borrar(ruta := Guardado.RUTA) -> Error` | Borra `<ruta>`, `<ruta>.tmp`, `<ruta>.bak` y `<ruta>.bak.tmp` si existen (lo usa «Borrar» de una ranura); no toca los ajustes |
| `Guardado.ruta_ranura(numero) -> String` | `user://partida_<numero>.json`, de 1 a `RANURAS` (4) |
| `Guardado.migrar(desde, hacia) -> Error` | Renombra `desde` a `hacia` si `desde` existe y `hacia` no; si no, nada (nunca pisa una partida) |
| `Guardado.respaldar(ruta) -> Error` | Copia una partida `VALIDA` a `<ruta>.bak.tmp` y la renombra a `<ruta>.bak`; una que no es válida no se copia y la copia anterior sigue |
| `Guardado.restaurar(ruta) -> Error`, `Guardado.tiene_respaldo(ruta) -> bool` | Copia `<ruta>.bak` a `<ruta>.tmp` y lo renombra a `<ruta>`; solo cuenta una copia `VALIDA` (una cortada o dañada no): sin ella, `ERR_FILE_NOT_FOUND` y `tiene_respaldo` da `false` |

| `Guardado.Estado` | Cuándo |
|---|---|
| `VALIDA` | El archivo es JSON, su `version` es `VERSION` y `partida` tiene todos los campos del esquema con su tipo |
| `VACIA` | No hay archivo: partida nueva. Un `.tmp` sobrante de un cierre a la mitad no cuenta |
| `DANADA` | No es JSON, no es un objeto, falta `version` o no es número, `partida` no es un objeto, o le falta un campo o tiene otro tipo |
| `INCOMPATIBLE` | `version` es un número distinto de `VERSION`, más nuevo o más viejo. No hay migración |

- Cuatro ranuras: `user://partida_1.json` a `partida_4.json`. `RUTA` (`user://partida.json`) es la partida de antes de
  las ranuras: el menú la pasa a la ranura 1 al abrir (`migrar`), y `Banco` la usa como centinela. `VERSION` es 3.
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
  bien, emite `Eventos.partida_guardada`; entrar a una ranura ocupada carga el resultado con
  `Partida.desde_diccionario()` (con las vidas llenas) y lleva al jugador a su banco.

## Ajustes y vibración

`nucleo/ajustes.gd` (`class_name Ajustes`): funciones estáticas, como `Guardado`. Archivo `user://ajustes.json`
(`{"version": 1, "ajustes": {...}}`), escrito a un temporal y renombrado. Son del teléfono y no de la partida:
agregar un ajuste no cambia `Guardado.VERSION`. Un archivo que falta, dañado o de otra versión deja los valores
por omisión: los de sí o no en `Ajustes.POR_OMISION`; la disposición de los botones en
`DisposicionControles.por_omision()`.

| Ajuste | Por omisión | Qué es |
|---|---|---|
| `vibracion` | `true` | Vibrar al pegar, al recibir daño, al parar, al curarse, al descansar y al aterrizar duro |
| `temblor` | `true` | Temblor de la cámara al aterrizar de una caída (se apaga por mareo). Un archivo sin la clave la deja encendida |
| `modo_desarrollador` | `false` | Muestra en el menú principal la entrada a la zona de pruebas |
| `volumen` | 1 | Volumen general (bus Master), de 0 a 1; en 0, silencio. Se aplica al cargar (`Ajustes.aplicar_volumen()`) |
| `volumen_musica` | 1 | Volumen del bus `Musica`, de 0 a 1, como el general. Un archivo sin la clave lo deja en 1 |
| `volumen_efectos` | 1 | Volumen del bus `Efectos`, de 0 a 1, como el general. Un archivo sin la clave lo deja en 1 |
| `brillo` | 1 | De 0,5 a 1,5: debajo de 1 oscurece y encima aclara (con tope) toda la pantalla. Se aplica al cargar (`Ajustes.aplicar_brillo()`) |
| `recursos` | `"auto"` | Modo de recursos: `auto` (decide la detección), `bajo` o `alto`. Otro valor vuelve a `auto` (ver «Recursos») |
| `mando` | `{}` | Botones del control que difieren de `project.godot`: `{acción: índice de botón}`. Lo aplica `Mando.aplicar` al cargar |
| `controles` | La distribución inicial | `{"opacidad": n, "botones": {acción: {"ancla": [0|1, 0|1], "desplazamiento": [x, y], "escala": n}}}` (ver «Entrada»). Lo que falta o no es válido se queda en su valor por omisión, botón por botón; escala y opacidad fuera de rango se recortan |

- Audio: `default_bus_layout.tres` (raíz) define los buses `Musica` y `Efectos`, que envían a `Master`;
  `Master` lleva un `AudioEffectHardLimiter` como último efecto, contra el recorte cuando suenan varios a la vez. La música se
  toca en `Ajustes.BUS_MUSICA` y los efectos en `Ajustes.BUS_EFECTOS`; nada suena directo en `Master`. Un volumen o
  un brillo que no es número deja su valor por omisión y uno fuera de rango se recorta.
- Brillo: `nucleo/brillo.gd` (`class_name Brillo`), una `CanvasLayer` en la capa 100 con un rectángulo que no recibe
  toques; la crea `Arranque` solo con pantalla (no en guiones ni en el validador). `Brillo.color_para(valor)`.
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
- Efectos: `nucleo/sonido.gd` (`class_name Sonido`, `Node`, en pausa también), que crea `Arranque` como `/root/Arranque/Sonido`:
  vive fuera de las salas, así nada se corta al cruzar una puerta o salir al menú. Escucha `jugador_salto`,
  `enemigo_golpeado`, `jugador_danado`, `parry`, `jugador_curado` y `descanso_en_banco` y toca, en el bus `Efectos`, el
  efecto de su `FichaSonidos` (`nucleo/ficha_sonidos.gd`: un `AudioStream` por evento, su tono y una variación al
  azar). Hoy la ficha es la de prueba, `nucleo/sonidos/sonidos_prueba.tres`; dónde vivirá la del juego está por
  decidir.
  `voces` (4) a la vez, cada nuevo en la voz siguiente; el mismo evento no suena dos veces en menos de
  `ticks_entre_iguales` (3), salvo daño y parry. Sin pantalla cuenta pero no toca. `pedidos`, `tocados` y `ultimo`
  son públicas. La música por zona todavía no existe.
- En Android, `vibrate_handheld` necesita el permiso `VIBRATE` en el preset de exportación (los presets de Android están en la rama
  `chore/android-export` hasta fusionarla); sin él no vibra. Un
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
| `salas`, `estado_de(sala, objeto)`, `marcar(sala, objeto, valor := true)` | Estado por sala. `estado_de` da `null` si no hay nada. Lo usan `SueloFragil`, `Coleccionable`, `Npc` (su etapa, un número) y `RetoPreguntas` (`<id>`, `<id>_indice` y `<id>_aciertos`) con su `id` y la clave de su sala (`Sala.clave_de(nodo)`) |
| `total_coleccionables()` | Marcas de todas las salas cuyo id empieza con `PREFIJO_COLECCIONABLE` (`coleccionable`) |
| `obtener_habilidad(id)`, `obtener_amuleto(id)` | Suman y emiten `habilidad_obtenida` o `amuleto_obtenido` (si ya estaba, nada) |
| `MAX_EQUIPADOS`, `puede_equipar(id)`, `equipar(id)`, `desequipar(id)`, `esta_equipado(id)` | Poner un amuleto exige tenerlo, que no esté puesto y que haya lugar (`MAX_EQUIPADOS`, 3, provisional hasta que haya carga). `equipar` y `desequipar` devuelven `false` si no pueden y, si cambian algo, autoguardan. Dónde se puede (sentado en un banco) lo decide la pantalla de los amuletos: `Partida` no conoce al jugador. Nada escribe `amuletos_equipados` directo |
| `dar_recompensa(recompensa)` | Entrega una `Recompensa` (PejeCoins, vida máxima, amuleto, habilidad o el mapa de una zona, que se suma a `mapas`) |
| `ruta_guardado` | Archivo del banco y del autoguardado: `RUTA_PRUEBAS` (`user://prueba_partida.json`) por omisión, para que guiones y zona de pruebas no pisen la partida real; entrar a una ranura lo cambia a la ruta de esa ranura |
| `autoguardar()`, `autoguardados` | Guarda en `ruta_guardado` sin tocar el banco y emite `partida_guardada`. Lo llaman los avisos `habilidad_obtenida`, `amuleto_obtenido`, `coleccionable_obtenido`, `jefe_vencido` (que además anota el jefe) y `jugador_muerto`; «Salir al menú» de la pausa; la entrega de recompensas; poner o quitar un amuleto; terminar contando una conversación de un `Npc`; cada respuesta de un `RetoPreguntas`; y `NOTIFICATION_APPLICATION_PAUSED` o `NOTIFICATION_APPLICATION_FOCUS_OUT` con una sala abierta. `autoguardados` los cuenta |
| `habilidades`, `tiene(id)` | `Array[StringName]` con las habilidades obtenidas, y si una está |
| `enemigos_vencidos`, `vencer(clave)`, `fue_vencido(clave)` | Claves (`"<clave de la sala>#<id>"`) de los enemigos fuertes vencidos desde el último descanso o la última muerte. Se borra al oír `descanso_en_banco` o `jugador_muerto` y en `reiniciar()`; no se guarda |
| `inspiracion`, `ganar_inspiracion(n)` | Recurso de curación (0 a `INSPIRACION_MAXIMA`, 99); no se guarda, se reinicia con la partida y se vacía al oír `jugador_muerto`. Cada cambio emite `inspiracion_cambiada` |
| `reiniciar()` | Partida nueva: la llaman una ranura vacía y la zona de pruebas |
| `llenar_vidas()` | Vidas al máximo: al reaparecer después de morir |
| `a_diccionario()` / `desde_diccionario(partida)` | Hacia y desde los campos de `Guardado.ESQUEMA`. Al cargar, lo que no se guarda empieza de cero: Inspiración 0 y sin enemigos vencidos |

## Autoloads

| Nombre | Script | Qué hace |
|---|---|---|
| `Eventos` | `nucleo/eventos.gd` | Bus de eventos: solo declara las señales de «Bus de eventos». Va antes de `Arranque` para existir cuando arranca todo lo demás |
| `Partida` | `nucleo/partida.gd` | Estado de la partida (ver «Estado de la partida»). Va después de `Eventos` y antes de `Arranque` |
| `Arranque` | `nucleo/arranque.gd` | Pone el color de borrado en negro, carga los ajustes y, con pantalla, crea la capa `Brillo` y aplica el rango de la vista al arrancar y, diferido al final del cuadro, al cambiar el tamaño de la ventana (`proporcion_minima` y `proporcion_maxima`, exportadas). Imprime `ARRANQUE depuracion=<bool> puerto=<bool>` y, solo en un build de depuración y si el archivo viaja en el paquete, carga con `load()` el puerto de depuración como hijo suyo (`PuertoDepuracion`). También crea `Sonido` (ver «Ajustes y vibración»), con o sin pantalla |

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
| `nucleo/planta.gd` (`class_name Planta`, `Node2D`) | Quieta | Se mece (`grados`, `periodo`, `desfase`) con un tiempo propio en `_process`: quieta en la pausa; sigue en el congelado |
| `nucleo/niebla.gd` (`class_name Niebla`, `Node2D`) | Quieta | Avanza `velocidad` px/s y vuelve tras `recorrido`, con tiempo propio; sigue en el congelado |

- Presupuesto por sala (lo revisa el validador en toda escena cuya raíz es una `Sala`): a lo más 3 emisores de
  partículas con 60 partículas entre todos, 30 plantas, ninguna luz 2D y a lo más 2 capas translúcidas
  grandes: un `Sprite2D`, `TextureRect`, `ColorRect`, `NinePatchRect` o `Polygon2D` visible con alfa efectivo menor
  que 1 (el de su color en `ColorRect` y `Polygon2D`, por su `self_modulate` y el `modulate` de él y de sus padres;
  dentro de un `CanvasLayer` oculto no cuenta) que cubre al menos un
  cuarto de 1280×720 con la escala de sus padres y sus anclas. Nunca se marca como prescindible un aviso de peligro ni algo cuya colisión importe.
  Excepción: la sala de arte (`herramientas/salas/sala_arte.gd`) arma su decoración en `_ready` y pasa del
  presupuesto a propósito (hasta 12 emisores y ~500 partículas en alto): es la sala para medir el rendimiento.
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
| `jugador_salto` | — | El jugador al despegar en cada salto: en el suelo, coyote, en la pared y doble salto. Lo oye `Sonido` |
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
| `inventario` | I | View / Select |
| `pagina_anterior` | Z | LB / L1 |
| `pagina_siguiente` | C | RB / R1 |
| `pausa` | Esc | Start |

Las teclas se guardan como tecla física (`physical_keycode`): valen por su posición en el teclado, no por la
letra de la distribución. Una acción nueva se agrega a `project.godot` y a esta tabla en el mismo cambio.

- `inventario` se llamaba `mochila` hasta el 13-oct-2026: `Mando.aplicar` da a `inventario` el botón que unos
  ajustes viejos guardaron como `mochila`. El campo `mochila` del guardado (lo perdido al morir) no cambió.
- LB es `mapa_rapido` y también `pagina_anterior`: el mapa rápido solo responde con el juego andando y las páginas
  solo con el marco de menús abierto, que lo detiene. Las dos acciones de página no se reasignan.

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
  sentado en un banco (`Jugador.descansando`, leído del grupo `jugador`) dice «Inventario» y da `inventario`; al
  soltar se suelta la acción que se presionó); Impulso solo mientras `Partida.tiene(&"impulso")` y Atacar mientras `Partida.tiene(&"pluma")` (sin la habilidad no se dibuja ni responde,
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
- Conversación: mientras hay una `CajaDialogo`, `ControlesTactiles.hablando` es verdadero y solo Pausa se dibuja y
  responde; el joystick se suelta y no se toma. La caja se toca directamente.
- Control (Xbox / PlayStation): un evento del InputMap junto a cada tecla, para cualquier control (`device` -1).
  El stick usa la zona muerta de cada acción (0,2); RT es un eje que cuenta como presionado pasada esa zona. LT queda libre.

## Jugador

El jugador (propiedades, combate, curar, habilidades y prioridad del movimiento) está en `docs/jugador.md`.

## Componentes

| Componente | Qué es |
|---|---|
| `nucleo/golpeable.gd` (`class_name Golpeable`, `Area2D`) | Hijo de lo que el ataque o la bola pueden golpear, con su forma. `recibir_golpe(atacante, dano := 1)` cuenta `golpes` y `dano_recibido`, empuja a su padre lejos del atacante (`velocidad_retroceso` 240 px/s, `ticks_retroceso` 6; 0 para que no se mueva; golpeado justo desde arriba no se empuja) sin meter su forma en un `StaticBody2D` (lo busca con un rayo a media altura) ni sacarla de los `limites` de su `Sala`: al topar, el empuje se acaba, emite su señal `golpeado(atacante, dano)` y `Eventos.enemigo_golpeado` con su padre |
| `nucleo/suelo_fragil.gd` (`class_name SueloFragil`, `StaticBody2D`) | Sólido que se pisa como cualquier otro y que rompe la caída en picada (`romper()`: `roto` y desaparece). Va en la sala con su forma y su dibujo. Con `id` (obligatorio en las salas con id) se marca en el estado de su sala al romperse y ya no aparece al entrar |
| `nucleo/coleccionable.tscn` (`class_name Coleccionable`, `Area2D`) | Al tocarlo el jugador vivo: se marca en el estado de su sala, emite `coleccionable_obtenido` (autoguarda) y desaparece; marcado, no aparece. `id` único en la sala que empieza con `coleccionable`. Gris, sin tema |
| `nucleo/entrega_recompensas.gd` (`class_name EntregaRecompensas`, `Area2D`) | Con el jugador encima y `Jugador.puede_interactuar` (la misma regla del `Npc`), `interactuar` entrega cada `Recompensa` de su lista cuya `cantidad` ya se juntó y no se entregó (marca `entregado_<cantidad>` en su sala) y autoguarda. `entregadas` las cuenta |
| `nucleo/recompensa.gd` (`class_name Recompensa`, `Resource`) | `cantidad`, `tipo` (`MONEDAS`, `VIDA_MAXIMA`, `AMULETO`, `HABILIDAD`, `MAPA`; el orden no cambia porque se guarda como número), `monto` e `id` (en `MAPA`, la zona) |
| `nucleo/npc.tscn` (`class_name Npc`, `Area2D`) | Personaje con quien se habla. Con el jugador encima, en el suelo y libre (sin morir, sentarse, aterrizar duro ni hablar ya), un triángulo encima avisa e `interactuar` abre una `CajaDialogo` con la conversación de su `etapa` y llama `Jugador.empezar_a_hablar()`. `conversaciones` tiene una `FichaDialogo` por etapa. Terminar contando sube la etapa, la marca en el estado de su sala (`id` único en la sala, que no empieza con `coleccionable` ni `entregado_`), entrega las recompensas de esa ficha una sola vez y autoguarda; terminada la última, se repite sin entregar. Sin contar (`CANCELAR`), un golpe, un peligro o morir la cierran sin cambiar nada. Emite `conversacion_terminada(etapa)`; `etapa`, `cerca` y `caja` son públicas. Forma provisional: un rectángulo |
| `nucleo/caja_dialogo.gd` (`class_name CajaDialogo`, `CanvasLayer` capa 12) | Caja abajo de la pantalla, dentro del área segura: quién habla y el texto letra por letra (`ticks_por_letra`, 2). `interactuar`, `saltar`, `atacar` o tocar la caja completan la línea y, completa, pasan a la siguiente; la pulsación que la abrió no cuenta. Las opciones de una pregunta van en fila encima de la caja: izquierda y derecha cambian la marcada y se toma con las mismas acciones o tocándola; con opciones a la vista, tocar la caja no elige. Emite `terminada(contar)` y, al tomar una opción, `opcion_elegida(linea, opcion)` antes de pasar a su destino. Corre con el juego: la pausa y el mapa la detienen. Mientras existe, `ControlesTactiles.hablando` es verdadero. `linea`, `letras_visibles`, `completa` y `elegida` son públicas |
| `nucleo/ficha_dialogo.gd` (`class_name FichaDialogo`, `Resource`) y `nucleo/linea_dialogo.gd` (`class_name LineaDialogo`) | Una conversación: `lineas` y `recompensas`. Cada línea lleva `quien`, `texto` y, si pregunta, hasta `MAX_OPCIONES` (3) `opciones` con un `destino` cada una: otra línea, `FIN` (termina contando) o `CANCELAR` (termina sin contar). Sin opciones, avanzar pasa a la siguiente; la última termina contando. `fallos()` da la lista de problemas de forma |
| `nucleo/reto_preguntas.tscn` (`class_name RetoPreguntas`, `Area2D`) | Reto de preguntas. Se habla como con un `Npc` (mismas condiciones, mismo `Jugador.empezar_a_hablar()`) y abre una `CajaDialogo` con las `preguntas` que faltan de la ronda, en orden, cada una seguida de `texto_correcto` o `texto_incorrecto` con la respuesta correcta. Cada respuesta (`responder(opcion)`) cuenta, se marca en el estado de su sala y autoguarda; un golpe corta la ronda donde iba. Al acabar la ronda con `meta` aciertos o más gana (`<id>` en `true`, `recompensa` una sola vez, señal `ganado`) y desde entonces solo dice `texto_ganado`; si no, la ronda vuelve a empezar en cero. Si lo guardado ya no cabe en la lista, empieza otra vez. `indice`, `aciertos`, `gano` y `caja` son públicas. Forma provisional: un atril |
| `nucleo/ficha_pregunta.gd` (`class_name FichaPregunta`, `Resource`) | `pregunta`, de 2 a 3 `opciones` (las que caben en la fila de la caja) y `correcta`. `fallos()` da la lista de problemas de forma |
| `nucleo/vitrina_coleccionables.gd` (`class_name VitrinaColeccionables`, `Node2D`) | Dibuja `total_del_juego` lugares, llenos los `juntados` (leído al entrar): la sala donde se ven los coleccionables |
| `nucleo/cortable.tscn` (`class_name Cortable`, `Area2D`) | Decoración que corta el ataque (pasto y lo que cada zona quiera). `cortar()` oculta el hijo `Entero`, muestra `Cortado`, suelta `trozos` partículas y emite `cortado`; no da Inspiración, no rebota al jugador ni cuenta como enemigo. Se sacude al pasar el jugador (`sacudidas`). No se guarda: vuelve al entrar otra vez a la sala. `esta_cortado` es pública. Para otra forma, se hereda la escena y se cambian `Entero` y `Cortado` |
| `nucleo/proyectil.tscn` (`class_name Proyectil`, `Area2D`) | La bola: avanza recto y sin gravedad (`velocidad` 900 px/s, `ticks_vida` 60) y golpea una vez, con su `dano` (2), a cada `Golpeable` que toca, sin detenerse. Desaparece contra un sólido, que busca con un rayo: movido por posición, no detectó los `StaticBody2D` de las salas (`docs/errores/2026-10-06-bola-atravesaba-paredes.md`); el rayo además cubre el paso de un tick. Si el jugador está pegado a una pared, no llega a salir (se cobra igual). No da Inspiración |
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
| Controles, pausa, marco de menús, vibración, fundido, interfaz y mapa | También los crea la sala en su `_ready`: `ControlesTactiles`, `Pausa`, `Marco` (`MarcoMenus`), `Inventario` (`PaginaInventario`), `Amuletos` (`PantallaAmuletos`), `Vibracion`, `Fundido` y, si existen, `interfaz/interfaz.tscn` y `mapa/pantalla_mapa.tscn` (con `load()`, para que el núcleo no dependa de esos bloques; ver «Interfaz» y «Mapa») |
| Propiedad `posicion_mapa` (`Vector2`) | Esquina de la sala en el mapa del mundo, en px: el mapa la dibuja en `posicion_mapa + limites`. Las salas de una zona se acomodan como se recorren. Cambiarla obliga a regenerar el índice del mapa |
| Propiedad `habilidades_de_prueba` (`Array[StringName]`) | Solo salas de prueba: habilidades que la sala da en silencio al entrar (sin aviso ni autoguardado). Las de `herramientas/salas/` dan `pluma`, salvo la de combate chico (donde se recoge), la de capas y la del diálogo. El validador la exige vacía en `contenido/` |
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
  `banco_<id>`; la raíz de cada escena de esas carpetas es una `Sala`; suelos frágiles, coleccionables, `Npc` y
  `RetoPreguntas` con id (sin él, falla) único en la sala; en `contenido/`, `habilidades_de_prueba`
  vacío. En cualquier escena, además, cada `Npc` tiene conversaciones, ninguna vacía, un id que no empieza con `coleccionable` ni
  `entregado_` y fichas sin fallos (`FichaDialogo.fallos()`, que también revisa cada `.tres` de ficha suelto); cada
  `RetoPreguntas`, un id igual de libre, `meta` entre 1 y el número de preguntas y preguntas sin fallos
  (`FichaPregunta.fallos()`, también en cada `.tres` suelto). Esta
  es la lista completa de lo que revisa en las salas (`herramientas/validar.gd`).
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
  reaparición y entrar a una ranura con banco (`preparar_ranura` del menú). Sin ese banco en la sala, imprime un `ERROR:` y usa `Entrada`.

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
  (los peligros sí dañan), congelado común de `ticks_congelado_parry` (20) con un estallido de rayos blancos en el punto del choque, después el jugador sale empujado hacia atrás (`ticks_retroceso_parry`) y su carrera o voltereta se corta, el enemigo dueño del ataque recibe el golpe (su `Golpeable` lo empuja)
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

- `PantallaMapa` (`CanvasLayer`, capa 20, grupo `pagina_marco`, corre en pausa): la página Mapa del marco de menús
  (ver «Marco de menús»); la acción `mapa` abre el marco en ella. `mapa_rapido` mantenida muestra el mapa encima sin
  detener el juego (como en Hollow Knight y Silksong), solo con el juego andando.
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

## Marco de menús

- `nucleo/marco_menus.gd` (`class_name MarcoMenus`, `CanvasLayer` capa 21, grupo `pantalla_encima`, corre en pausa),
  creado por cada sala como `Marco`: páginas en ciclo, como el inventario de Hollow Knight, en el orden de
  `MarcoMenus.ORDEN` (Inventario, Amuletos y Mapa; sin el bloque `mapa/`, las dos primeras). Abierto detiene el juego
  (`get_tree().paused`); no se abre con el juego ya detenido (la pausa abierta).
- `mapa` lo abre en Mapa; `inventario`, de pie en Inventario y sentado en un banco en Amuletos. Abierto,
  `pagina_anterior` y `pagina_siguiente` (y tocar la vecina en la barra) cambian de página en ciclo; `pausa`, `mapa`,
  `inventario`, Atrás y «Volver» lo cierran sin abrir la pausa (`bloquea_pausa()`, también en el tick en que se cerró).
- Barra de arriba, de alto `MarcoMenus.ALTO_BARRA`: «Volver» a la izquierda y, al centro, «‹ anterior», el título y
  «siguiente ›».
- Una página es un nodo del grupo `pagina_marco` (`MarcoMenus.GRUPO_PAGINAS`) con `id_pagina() -> StringName`,
  `titulo_pagina() -> String`, `mostrar_en_marco()` y `ocultar_de_marco()`. El marco las busca por el grupo, sin conocer
  sus clases: así el núcleo no depende de `mapa/`. Una página va en la capa 20 y deja libre la franja de la barra.
- `nucleo/pagina_inventario.gd` (`class_name PaginaInventario`, creada como `Inventario`): solo para leer lo que ya
  existe en `Partida`: vida, Inspiración, PejeCoins, arma (la habilidad `pluma`), habilidades, mapas y lo perdido al
  morir (`PaginaInventario.perdido(mochila)`). Sin objetos: un inventario de objetos subiría el guardado a la versión 4.
- `abierta`, `pagina` e `ids()` del marco y `valores` del inventario son públicos para las pruebas.

## Amuletos

- `nucleo/pantalla_amuletos.gd` (`class_name PantallaAmuletos`, `CanvasLayer` capa 20, grupo `pagina_marco`, corre en
  pausa), creada por cada sala como `Amuletos`: la página Amuletos del marco de menús.
- Lista los amuletos de `Partida.amuletos_tenidos`, cada uno «puesto» o «guardado». Como en Hollow Knight, solo
  sentado en un banco (`Jugador.descansando` del `Jugador` de la sala) se ponen y se quitan (`alternar(id)`); de pie
  se ven, sin responder. El que no cabe tampoco responde.
- Nombre en pantalla: el id con mayúsculas (`nombre_de`), hasta que los amuletos tengan ficha con nombre. No se llama
  «mochila»: `Partida.mochila` es lo que se pierde al morir. (Táctil: ver «Entrada».)
- `abierta` y `botones` son públicas para las pruebas.

## Grupos

| Grupo | Quién lo lleva | Quién lo usa |
|---|---|---|
| `jugador` | El cuerpo que controla la persona: el `Jugador` que crea la sala, o la caja gris (`sala_inicial`) | El puerto de depuración (posición y si está en el suelo), `ComportamientoEnemigo.jugador()` y, en pruebas, `medidor_camara.gd` y `prueba_peligro_anti_bucle.gd` |
| `pantalla_encima` | Una pantalla abierta sobre el juego (hoy, `MarcoMenus`) con `bloquea_pausa() -> bool` | La `Pausa`: no se abre (con `pausa`, Atrás ni al perder el foco) mientras una diga que bloquea, ni en el tick en que se cerró |
| `pagina_marco` | Las páginas del marco de menús: `PaginaInventario`, `PantallaAmuletos` y `PantallaMapa` | `MarcoMenus`, que las ordena y las muestra (ver «Marco de menús») |

## Capas de dibujo

| Capa | Qué | Dónde |
|---|---|---|
| 1 | `Interfaz` de la caja gris, con «Volver al menú» (capa por omisión) | `nucleo/caja_gris.tscn` |
| 5 | `ControlesTactiles` | `nucleo/controles_tactiles.tscn` |
| 10 | `Interfaz` | `interfaz/interfaz.tscn` |
| 11 | Medidor de FPS de la sala de arte (solo pruebas) | `herramientas/salas/sala_arte.gd` |
| 12 | `CajaDialogo` | `nucleo/caja_dialogo.gd` |
| 15 | `Fundido` | `nucleo/fundido.gd` |
| 20 | `Pausa` y las páginas del marco (la pausa y el marco nunca están abiertos a la vez) | `nucleo/pausa.tscn`, `nucleo/pagina_inventario.gd`, `nucleo/pantalla_amuletos.gd`, `mapa/pantalla_mapa.gd` |
| 21 | La barra del marco de menús (`MarcoMenus`) | `nucleo/marco_menus.gd` |
| 22 | Configuración abierta desde la pausa (`Pausa.CAPA_CONFIGURACION`) | `nucleo/pausa.gd` |
| 23 | `EditorControles`, encima de Configuración | `nucleo/editor_controles.tscn` |
| 100 | `Brillo` | `nucleo/brillo.gd` |

Una capa nueva entra a esta tabla en el mismo cambio.

## Guiones de entrada

Formato, comando y condiciones de fallo: `docs/guiones.md`.

## Paquete de publicación

El núcleo no depende de `herramientas/`: las únicas referencias son la carga condicional de `Arranque` (el puerto,
solo en un build de depuración), `Sala.ruta_de` (busca una sala en `Sala.CARPETA_PRUEBAS` si no está en
`contenido/salas/`) y el botón «Zona de pruebas» del menú principal, que aparece con el modo
desarrollador encendido si `herramientas/salas/zona_pruebas.tscn` existe (`ResourceLoader.exists`, sin `preload`),
en depuración y en publicación. Que la zona viaje en el paquete de publicación lo decide el `exclude_filter` del
preset «Publicacion» de `export_presets.cfg`.

## Menú

`nucleo/menu.tscn` es la escena principal. Al abrir pasa `Guardado.RUTA` a la ranura 1. «Jugar» abre las ranuras
(`nucleo/ranuras.gd`, `class_name Ranuras`, armada en código; `menu.ranuras`): una ficha por ranura, 4 en fila cuando
caben (desde la vista de 1280) y si no 2×2, arriba del aviso de pocos toques. La vacía dice «Nueva partida»
(`Partida.reiniciar()`, se escribe ya en su ranura y lleva a `sala_inicial`: hoy la caja gris, que tiene un botón
«Volver al menú» porque no es una sala y no tiene pausa). La `VALIDA` dice dónde se quedó (la sala del banco, si no
la última visitada, si no «Inicio»), las vidas máximas, el tiempo jugado y un cuadrito por habilidad, jefe y
coleccionable; al entrar se copia (`respaldar`), se carga y lleva a la sala de su banco (sin banco, a `sala_inicial`).
La `DANADA` y la `INCOMPATIBLE` no se abren. Entrar a una ranura fija `Partida.ruta_guardado` en ella
(`preparar_ranura`). Una vacía abre antes «Nueva partida» (`nucleo/nueva_partida.gd`, `class_name NuevaPartida`):
«Hombre» o «Mujer» (`Partida.personaje` = `hombre` o `mujer`), el nombre en un campo de texto y «Empezar», que no
responde sin personaje. `NuevaPartida.limpiar_nombre` deja letras, números y espacios simples, hasta 12; vacío,
«Alumno» o «Alumna». La ficha ocupada lleva el nombre (sin él, «Partida N»). «Borrar» (si no está vacía) y «Restaurar» (si hay copia: vuelve al inicio de la última sesión)
piden confirmación. «Configuración» (`nucleo/configuracion.tscn`, `class_name Configuracion`,
instancia `Configuracion` del menú) reemplaza al panel central con, en orden de uso: «Audio» (panel con el volumen general, de
música y de efectos; cada uno con su barra ancha, su porcentaje y un altavoz que lo silencia y, con otro toque, lo
devuelve al valor de antes, o a 50 si se bajó a 0 con la barra; mientras está abierto suena la música de prueba en su
bus, salvo sin pantalla, y «Probar efecto» toca uno en el de efectos), «Brillo» (su pantalla, como en Hollow Knight:
detrás la escena tenue; en una ventana la misma escena con un cuadro casi negro de calibración en la esquina; el texto
«Ajusta el brillo hasta que el cuadro de la esquina apenas se vea.» y la barra ancha, de 50 % a 150 % en pasos de 5.
La escena es la copia que tomó la pausa, con un shader que deshace el brillo con que se tomó, o, desde el menú o sin
copia, `EscenaMuestra` de `nucleo/escena_muestra.gd`, rectángulos de color), Vibración, Temblor, Recursos (cada toque
pasa a automático, bajo o alto; ver «Recursos»), «Botones táctiles» (el mismo editor que la
pausa; ver «Entrada»), «Botones del control» (reasignación con `Mando`: tocar una acción y presionar el botón del
control; «Restablecer» los devuelve a los de `project.godot`; sin control conectado lo avisa, con `Input.joy_connection_changed`), Modo desarrollador
(con él el menú muestra «Zona de pruebas»; no aparece abierta desde la pausa, `en_partida`) y «Créditos»;
«Volver», arriba a la izquierda en cada pantalla. Cada opción es un `BotonValor` (`nucleo/boton_valor.gd`): el nombre
a la izquierda y el valor a la derecha, en una pastilla («Sí» dorada, «No» gris, Recursos en azul, con la letra más
chica si no cabe) o «›» si abre otra pantalla; sin interruptores, y se toca el botón entero. Las barras anchas
(variación `Tema.BARRA_ANCHA` de `HSlider`) saltan al punto tocado y se arrastran; con teclado o control, izquierda y
derecha las mueven de 10 en 10. Desde la pausa, cambiar Recursos avisa que vale al entrar a la sala siguiente. Cada
cambio se guarda al momento; las barras, al soltarlas.
Atrás y la acción `pausa` vuelven un nivel a la vez (`atras()` del menú y de la Configuración): cancelan el editor, la espera de un botón y la
confirmación, de un subpanel vuelven a la lista, de «Nueva partida» a las ranuras, de la lista o de las ranuras al menú, y en el menú piden
confirmación antes de cerrar la app. La zona de pruebas es un nivel más: su «Volver», Atrás y `pausa` regresan al menú con
el foco en su entrada (`MenuPrincipal.volver_a_zona`, que el menú lee al entrar). Se maneja con toque, teclado y
control (el foco empieza en la primera opción de cada pantalla). Las opciones nuevas de configuración se agregan a
esa escena.

Tamaños (`nucleo/tema.gd`, `class_name Tema`): el tema de los menús se arma en código (`Tema.crear()`) y se asigna
solo a sus raíces (menú, que lo hereda la Configuración, pausa, marco de menús y sus páginas, caja de diálogo y zona de pruebas), no en `project.godot`. Todo lo
que se toca mide al menos 108 px de alto (48 dp en el Senwa S50);
letra de 36 en botones y 33 en etiquetas. `Tema.ajustar(control)` pone un panel en el área segura menos 64 px a los
lados y 16 arriba y abajo, y lo reacomoda al cambiar la ventana. Las cuadrículas de la Configuración toman 2 columnas
de 420 px en la vista de 1280 (4:3 y 16:9) y 3 desde 1440 (`Configuracion.columnas_para`), y se desplazan si no
caben en alto. El borde dorado marca solo el foco; presionado se ve más claro.

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
