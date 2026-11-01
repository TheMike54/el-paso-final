# Contrato del proyecto

Lo que un bloque puede dar por hecho de los demás: la configuración del proyecto, el ciclo de vida, el guardado, los autoloads, el bus de eventos y la forma de una sala. Si un cambio altera algo de aquí, este documento se actualiza en el mismo cambio. Las señales del bus de eventos, la forma de una sala, la ficha de una entidad y el esquema del guardado entran a este documento en el mismo cambio que los implementa, con su plan aprobado antes.

El contrato se parte por tema para leer solo lo que la tarea toca. Este archivo es el núcleo; los demás son parte del contrato y se leen cuando la tarea toca su tema:

| Archivo | Qué trae | Cuándo leerlo |
|---|---|---|
| `docs/contrato.md` (este) | Configuración, ciclo de vida, guardado, estado de la partida, autoloads, bus de eventos, sala (forma, cambio de sala, bancos, uid), fichas de amuletos y útiles, grupos, capas de física y de dibujo, paquete de publicación | Antes de crear contenido, un autoload o tocar el guardado |
| `docs/componentes.md` | Las piezas del núcleo que una sala instancia: golpeables, recogibles, NPC, tienda, estaciones, plataformas, peligros | Al armar una sala o una pieza |
| `docs/enemigos.md` | Ficha de enemigo, comportamientos, datos, botín, ataques, parry y ganchos | Al crear o tocar un enemigo |
| `docs/audio.md` | Buses, `Sonido`, `Musica` y `Vibracion` | Al tocar sonido, música o vibración |
| `docs/ajustes-y-entrada.md` | El archivo de ajustes, `Mando`, brillo, las acciones de entrada, los controles táctiles y su editor | Al agregar un ajuste o una acción, o al tocar los controles |
| `docs/interfaz.md` | HUD, mapa, marco de menús, pantallas de amuletos y útiles, menú principal, `Tema`, pausa y piezas de menú | Al tocar un menú, el HUD o el mapa |
| `docs/arte-y-rendimiento.md` | Modo de recursos, presupuesto por sala, importación del arte, arte de zona y las mediciones que sostienen las reglas | Antes de agregar arte, luces, partículas o una sala |
| `docs/validador.md` | Lo que revisa `herramientas/validar.gd` en salas y fichas | Al agregar una regla del validador o ante un fallo que no se entiende |

`docs/jugador.md` (propiedades, combate, curar, habilidades y prioridad del movimiento del jugador) y `docs/guiones.md` (formato, comando y condiciones de fallo de los guiones) también son parte del contrato.

Mantenimiento: aquí no se anotan fechas de decisión ni el historial de las mediciones (la fecha vive en git, en el plan o en `docs/errores/`; la medición, en `docs/pruebas.md` o en `docs/arte-y-rendimiento.md`), y una cifra que ya es un `@export` o una `const` no se copia: se cita el archivo y el nombre.

## Configuración del proyecto

Valores de `project.godot`. No se cambian sin actualizar esta tabla.

| Tema | Valor | Por qué |
|---|---|---|
| Motor | Godot 4.7.2 estable, edición estándar | Un proyecto guardado con una versión más nueva no abre en una anterior |
| Renderer | Compatibility en `rendering_method` y en `rendering_method.mobile` | Teléfonos de gama baja |
| Resolución base | 1280×720 | Proporción 16:9; el arte se mide contra esta base |
| Estiramiento | `canvas_items` con aspecto `expand`, limitado al ejecutar a proporciones de 4:3 a 22:9 (`nucleo/vista.gd`, que aplica `Arranque`; el mismo rango en escritorio, teléfono y tableta) | Dentro del rango la base se escala y se ve más escenario, sin barras; fuera, la vista se recorta a 1760×720 o 1280×960 y el motor pone barras negras. Sin pantalla (guiones) no se aplica. El color de borrado es negro (`Arranque`): fuera de una sala no se ve gris |
| Escala | Cuadro de 40 px; el personaje mide 160 px de alto | Medida común para salas, colisiones y arte |
| Orientación | Horizontal con giro (`window/handheld/orientation=4`, `SCREEN_SENSOR_LANDSCAPE`) | Se juega acostado, hacia cualquiera de los dos lados |
| Botón Atrás | `quit_on_go_back=false` | Atrás no cierra la app: en el juego abre la pausa (con el marco de menús o Configuración abiertos, los cierra o vuelve un nivel) y en el menú pide confirmación |
| Tipado | `untyped_declaration`, `unsafe_property_access`, `unsafe_method_access` y `unsafe_call_argument` como error | Un error de tipos se ve al validar, no al jugar |
| Texturas | Ninguna de más de 2048 px por lado (lo revisa el validador) | Memoria en gama baja |
| Solo 2D | `Arranque` pone `disable_3d` en la vista raíz | La vista no prepara nada de 3D; un nodo 3D no se vería |
| Compresión de texturas | `textures/vram_compression/import_etc2_astc=true` | Godot no exporta a Android sin ella |
| Filtro de texturas | `textures/canvas_textures/default_texture_filter=2` (lineal con mipmaps) | La vista de 1280×720 se encoge en pantallas más chicas; el arte del mundo lleva mipmaps (ver `docs/arte-y-rendimiento.md`, «Recursos») |
| Interpolación de física | Apagada (`physics/common/physics_interpolation`, por omisión) | En el S21 a 120 FPS no hay saltos sin ella, y suma retraso a la entrada (parry, salto en cola) |
| Capas de física | `layer_names/2d_physics/layer_1` a `layer_7` | Nombres en el editor; la tabla, en «Capas de física» |
| Id del paquete Android | `com.themike54.elpasofinal` | Identidad estable de la app instalada |
| Ícono | `config/icon` = `res://nucleo/arte/icono/icono_192.png`; en los dos presets, `launcher_icons/*`: el de 192 y los adaptativos de 432 (frente, fondo y monocromo), en `nucleo/arte/icono/` | El ícono aprobado en el lanzador y en el editor (`tutorials/export/exporting_for_android.rst:119-127`) |
| Idioma | Solo español en la v1; cada texto se escribe completo, sin frases armadas a pedazos | Decisión cerrada |
| Exportación | APK directo; una sola máquina exporta las versiones; la clave de publicación la genera la persona y se guarda fuera del repo | Decisión cerrada (ver también `CLAUDE.md`, «Decisiones cerradas») |

## Ciclo de vida

- Arranque: Godot carga los autoloads y después la escena principal (`application/run/main_scene`).
- La lógica del juego corre en `_physics_process`, a 60 ticks por segundo. `_process` queda para lo visual.
- La acción `pausa` no guarda. La partida se guarda al descansar en un banco y se autoguarda (lo obtenido, nunca la
  posición: al continuar se aparece en el último banco) en los momentos que lista `autoguardar()` en «Estado de la
  partida».
- Pausa: `nucleo/pausa.tscn` (`class_name Pausa`), que crea cada sala. La acción `pausa` o el botón Atrás de Android la abren y la cierran (`get_tree().paused`); con ella abierta, `volver` (B / Círculo) hace lo mismo que `pausa`, y con la pausa cerrada no se lee, porque en la partida B es `curar`. Sus botones, la Configuración que abre y cuándo se abre sola: `docs/interfaz.md`, «Pausa».
- El guardado se escribe en un archivo temporal y después se renombra: un cierre a la mitad no daña la partida.
  Lo hace `Archivo` (`escribir_atomico(ruta, texto)` y `copiar_atomico(desde, hacia)`, con el temporal
  `<destino>.tmp`), que usan la partida, su copia y los ajustes: todo archivo nuevo de `user://` pasa por ella.
  Única excepción: las copias de video de `ReproductorVideo` (`user://video/`), porque `DirAccess.copy_absolute` no
  abre un archivo del paquete del APK (probado en el S50); una copia cortada se vuelve a copiar, porque
  su tamaño no coincide.
- Los ajustes del jugador van en su propio archivo, no en la partida (ver `docs/ajustes-y-entrada.md`, «Ajustes»).
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
| `Guardado.ruta_ranura(numero) -> String` | `user://partida_<numero>.json`, de 1 a `RANURAS` |
| `Guardado.entero(valor, por_omision) -> int` | Un número leído de una partida como `int` (truncado), aunque el JSON lo haya vuelto `float`; si no es número, `por_omision`. Lo usan `Partida.estado_entero` y `Partida.monto_mochila` |
| `Guardado.migrar(desde, hacia) -> Error` | Renombra `desde` a `hacia` si `desde` existe y `hacia` no; si no, nada (nunca pisa una partida) |
| `Guardado.respaldar(ruta) -> Error` | Copia una partida `VALIDA` a `<ruta>.bak.tmp` y la renombra a `<ruta>.bak`; una que no es válida no se copia y la copia anterior sigue |
| `Guardado.restaurar(ruta) -> Error`, `Guardado.tiene_respaldo(ruta) -> bool` | Copia `<ruta>.bak` a `<ruta>.tmp` y lo renombra a `<ruta>`; solo cuenta una copia `VALIDA` (una cortada o dañada no): sin ella, `ERR_FILE_NOT_FOUND` y `tiene_respaldo` da `false` |

| `Guardado.Estado` | Cuándo |
|---|---|
| `VALIDA` | El archivo es JSON, su `version` es `VERSION` y `partida` tiene todos los campos del esquema con su tipo; los de `NUEVOS` que faltan se rellenan con su valor por omisión |
| `VACIA` | No hay archivo: partida nueva. Un `.tmp` sobrante de un cierre a la mitad no cuenta |
| `DANADA` | No es JSON, no es un objeto, falta `version` o no es número, `partida` no es un objeto, o le falta un campo o tiene otro tipo (un campo de `NUEVOS` con otro tipo también) |
| `INCOMPATIBLE` | `version` es más nueva que `VERSION` (el juego no la sabe leer) o más vieja (hoy no hay ninguna función de conversión). Ver «Partidas viejas» abajo |


- Cuatro ranuras: `user://partida_1.json` a `partida_4.json`. `RUTA` (`user://partida.json`) es la partida de antes de las ranuras: el menú la pasa a la ranura 1 al abrir (`migrar`), y `Banco` la usa como centinela.
- Esquema: `Guardado.ESQUEMA` tiene los campos base y `Guardado.NUEVOS` los que se agregaron después sin subir `VERSION`; se copió de Hollow Knight y Silksong (lo del jugador como listas de ids; lo de cada sala con clave sala + objeto). Un campo nuevo va a `NUEVOS` con su valor por omisión en forma de JSON (`0.0`, `Array` sin tipo) y no sube `VERSION`: al cargar, `Guardado.completar` lo rellena en una partida que no lo tiene. `VERSION` sube solo cuando cambia la forma o el contenido de un campo que ya existe; si la versión anterior se conserva, en el mismo cambio se escribe la función que la convierte.
- Partidas viejas: hasta terminar el juego no se conserva ninguna versión vieja y no existe código de conversión; una partida de otra versión es `INCOMPATIBLE` y no se abre (decisión de la persona, D5 del plan `nucleo-base-auditoria-codigo`). Cuando haya una partida que conservar, cada cambio de forma trae una tabla de conversiones por versión en `Guardado.cargar()` y una prueba que cargue una partida de la versión vieja y compruebe el resultado.

| Campo | Tipo | Qué guarda |
|---|---|---|
| `banco` | objeto | `{sala, id}`: clave de la sala y id del último banco; `{}` si no se ha descansado. Si no está vacío y le falta `sala` o `id` (texto), la partida es `DANADA` |
| `vidas_maximas` | número | Vidas máximas |
| `habilidades`, `jefes`, `amuletos_tenidos`, `amuletos_equipados` | listas | Ids |
| `monedas` | número | PejeCoins |
| `mochila` | objeto | Lo perdido al morir, `{sala, x, y, monto}`, o `{}` |
| `mapas` | lista | Zonas cuyo mapa se tiene |
| `salas_visitadas`, `salas_mapeadas` | listas | Claves de sala (id, o ruta en una sala de prueba suelta) |
| `estaciones` | lista | Ids de las estaciones del viaje rápido abiertas. Campo de `NUEVOS`: una partida sin él carga con `[]` |
| `botones_ensenados` | lista | Acciones cuyo botón de la pantalla ya enseñó un pizarrón (`Sala.botones_por_ensenar`). Campo de `NUEVOS`: una partida sin él carga con `[]` |
| `carga_maxima` | número | Carga para amuletos, de `Partida.CARGA_INICIAL` a `Partida.CARGA_TOPE`. Campo de `NUEVOS` |
| `inspiracion_maxima` | número | Capacidad de la barra, de `Partida.INSPIRACION_INICIAL` a `Partida.INSPIRACION_TOPE`. Campo de `NUEVOS`: si falta, carga con `Partida.INSPIRACION_INICIAL` |
| `utiles_tenidos`, `utiles_equipados` | listas | Ids de los útiles (la brújula). Campos de `NUEVOS`: una partida sin ellos carga con `[]` |
| `salas` | objeto | Estado por sala: `{clave de la sala: {id del objeto: true o número}}` |
| `personaje`, `nombre` | texto | Elegidos en Nueva partida; vacíos si no se eligieron |
| `tiempo_jugado` | número | Segundos con el juego corriendo dentro de una sala |

- Lo que reaparece (enemigos) no se escribe. Sin cifrado ni suma de control.
- Al leer, los números vuelven como `float`: `var vidas: int = partida["vidas_maximas"] as int`.
- Lo que se guarda sale del estado de la partida: `Partida.guardar(ruta: String) -> Error` (sin ruta por omisión:
  quien llama dice el archivo) escribe `Partida.a_diccionario()` y, si salió
  bien, emite `Eventos.partida_guardada`; entrar a una ranura ocupada carga el resultado con
  `Partida.desde_diccionario()` (con las vidas llenas) y lleva al jugador a su banco.

## Estado de la partida

Autoload `Partida` (`nucleo/partida.gd`): lo que sobrevive al cambio de sala. Una sala nueva no reinicia nada.

| Propiedad o función | Qué es |
|---|---|
| `vidas`, `vidas_maximas` | Vidas actuales y máximas (4 al empezar). `Jugador.vidas` lee y escribe `Partida.vidas`. Cada cambio emite `vidas_cambiadas` |
| `banco`, `sala` | Id del último banco donde se descansó y la clave de su sala (`Sala.clave()`); vacíos si no se ha descansado |
| `jefes`, `amuletos_tenidos`, `amuletos_equipados`, `carga_maxima`, `utiles_tenidos`, `utiles_equipados`, `mochila`, `mapas`, `personaje`, `nombre`, `tiempo_jugado` | Los campos del guardado del mismo nombre |
| `monedas` | PejeCoins; cada cambio emite `monedas_cambiadas` |
| `gastar_monedas(cantidad)` | Cobra (la `Tienda`): devuelve `false` y no cambia nada si no alcanzan o si `cantidad` es negativa |
| `estaciones`, `abrir_estacion(id)`, `estacion_abierta(id)` | Ids de las estaciones del viaje rápido ya pagadas. `abrir_estacion` no repite un id ni guarda: guarda la `Estacion` |
| `botones_ensenados`, `ensenar_boton(accion)` | Acciones cuyo botón de la pantalla ya enseñó un `AvisoAccion`. `ensenar_boton` no repite ni guarda |
| `dejar_mochila(sala, punto)`, `monto_mochila()`, `punto_de_mochila()`, `recuperar_mochila()`, `perder_mochila()` | Lo perdido al morir, como el capullo de Silksong. El jugador, al morir y antes de emitir `jugador_muerto`, llama `dejar_mochila` con la clave de su sala y su `ultimo_punto_seguro()`, así el autoguardado de la muerte ya la lleva: con PejeCoins, `mochila = {sala, x, y, monto}` y `monedas` en 0, y una mochila anterior se pierde; sin PejeCoins no cambia nada. `monto_mochila()` y `punto_de_mochila()` leen el JSON aunque haya vuelto `float` (un eje que no es número, 0). `recuperar_mochila()` suma el monto, la vacía, emite `mochila_recuperada` y autoguarda; `perder_mochila()` (perder el reto) la vacía sin devolver nada y autoguarda |
| `salas_visitadas`, `visitar(clave)` | Claves de las salas visitadas; la sala se anota al entrar |
| `salas_mapeadas` | Al oír `descanso_en_banco`, con la habilidad `pluma_mapa`, pasan aquí las visitadas cuya zona está en `mapas` (como la Pluma de Hollow Knight y Silksong) |
| `salas`, `estado_de(sala, objeto)`, `estado_entero(sala, objeto, por_omision)`, `marcar(sala, objeto, valor := true)` | Estado por sala. `estado_de` da `null` si no hay nada; `estado_entero` da un número aunque el JSON lo haya vuelto `float`, o `por_omision`. Lo usan `SueloFragil`, `MuroRompible`, `Palanca`, `Porton`, `Coleccionable`, `Tienda`, `AvisoAccion`, `EntregaRecompensas`, `Npc` y `RetoPreguntas` (`<id>`, `<id>_indice` y `<id>_aciertos`) con su `id` y la clave de su sala (`Sala.clave_de(nodo)`) |
| `total_coleccionables()`, `contar_coleccionables(salas)` | Marcas de todas las salas cuyo id empieza con `PREFIJO_COLECCIONABLE` (`coleccionable`); la segunda cuenta un estado de salas leído de un archivo (la ficha de una ranura) e ignora lo que no es diccionario |
| `obtener_habilidad(id)`, `obtener_amuleto(id)`, `obtener_mapa(zona)` | Suman y emiten `habilidad_obtenida`, `amuleto_obtenido` o `mapa_obtenido` (si ya estaba, nada). Nada escribe `mapas` directo: el `ObjetoMapa` y `dar_recompensa` pasan por `obtener_mapa` |
| `CARGA_INICIAL`, `CARGA_TOPE`, `carga_maxima`, `carga_usada()`, `puede_equipar(id)`, `equipar(id)`, `desequipar(id)`, `esta_equipado(id)` | Poner un amuleto exige que esté en el catálogo (`CatalogoEquipo.amuleto`, ver «Amuletos y útiles»), tenerlo, que no esté puesto y que su `costo` quepa en la carga que queda: `carga_usada()` suma los costos de los puestos y no pasa de `carga_maxima` (de `CARGA_INICIAL` a `CARGA_TOPE`, como las muescas de Hollow Knight). La recompensa `CARGA` suma su `monto` en muescas y se recorta al tope; las mejoras de una muesca crecen de una en una. La capacidad se guarda y al reiniciar vuelve a `CARGA_INICIAL`. `equipar` y `desequipar` devuelven `false` si no pueden y, si cambian algo, emiten `equipo_cambiado` y autoguardan. Dónde se puede (sentado en un banco) lo decide la pantalla de los amuletos: `Partida` no conoce al jugador. Nada escribe `amuletos_equipados` directo |
| `efectos_amuletos()` | Lo que hacen juntos los amuletos puestos, como una `FichaAmuleto` nueva: factores multiplicados y extras sumados; sin amuletos, neutra. Se calcula al llamarla: quien la lee cada tick la guarda y la renueva al oír `equipo_cambiado` |
| `utiles_tenidos`, `utiles_equipados`, `MAX_UTILES`, `obtener_util(id)`, `util_equipado(id)`, `puede_equipar_util(id)`, `equipar_util(id)`, `desequipar_util(id)` | Los útiles (la brújula), como las herramientas de Silksong: aparte de los amuletos, sin carga y con `MAX_UTILES` puestos a la vez. Mismas reglas que los amuletos (catálogo, tenerlo, no repetir); `obtener_util` emite `util_obtenido`, que autoguarda, y poner o quitar emite `equipo_cambiado` y autoguarda. Nada escribe `utiles_equipados` directo |
| `dar_recompensa(recompensa)` | Entrega una `Recompensa` (PejeCoins, vida máxima, amuleto, habilidad, el mapa de una zona, con `obtener_mapa`, un útil, con `obtener_util`, capacidad de Inspiración (`INSPIRACION_MAXIMA`, puntos) o carga (`CARGA`, muescas)). Las dos mejoras de capacidad se recortan a sus topes y autoguardan; la de carga emite `equipo_cambiado` |
| `ruta_guardado` | Archivo del banco y del autoguardado: `RUTA_PRUEBAS` (`user://prueba_partida.json`) por omisión, para que guiones y zona de pruebas no pisen la partida real; entrar a una ranura lo cambia a la ruta de esa ranura |
| `autoguardar()`, `autoguardados` | Guarda en `ruta_guardado` sin tocar el banco y emite `partida_guardada`; `autoguardados` los cuenta. Dos formas: por el bus, para lo que tiene evento (`Partida` escucha en `_ready` `habilidad_obtenida`, `amuleto_obtenido`, `util_obtenido`, `mapa_obtenido`, `coleccionable_obtenido`, `jefe_vencido` —que además anota el jefe— y `jugador_muerto`), y por llamada directa (`Partida.autoguardar()`, o `guardar(ruta)` en el banco), para lo que `Partida` no escucha; un cambio nuevo usa la que le corresponda. Además se autoguarda en: «Salir al menú» de la pausa; la entrega de recompensas; poner o quitar un amuleto o un útil; terminar contando una conversación de un `Npc`; cada respuesta de un `RetoPreguntas`; recuperar o perder la mochila; comprar en una `Tienda`; abrir una `Estacion` (también la gratis); y `NOTIFICATION_APPLICATION_PAUSED` o `NOTIFICATION_APPLICATION_FOCUS_OUT` con una sala abierta. Lo demás se escribe en el siguiente guardado: las marcas de `MuroRompible`, `Palanca`, `Porton`, `SueloFragil`, `AvisoAccion` y `MonedasSueltas` (con sus PejeCoins), `salas_visitadas` y `botones_ensenados` |
| `habilidades`, `tiene(id)` | `Array[StringName]` con las habilidades obtenidas, y si una está. Los ids están en `nucleo/habilidades.gd` (`class_name Habilidades`, una constante por habilidad y `TODAS`); el código usa las constantes, no el texto. `obtener_habilidad` con un id que no está en `TODAS` imprime un `ERROR:` y no lo suma (el validador revisa los de objetos, recompensas y `habilidades_de_prueba`: `docs/validador.md`). Los ids no se renombran: los guarda la partida. Amuletos y útiles llevan su id en su ficha (ver «Amuletos y útiles»); los jefes, cuando exista el primero |
| `enemigos_vencidos`, `vencer(clave)`, `fue_vencido(clave)` | Claves (`"<clave de la sala>#<id>"`) de los enemigos fuertes vencidos desde el último descanso o la última muerte. Se borra al oír `descanso_en_banco` o `jugador_muerto` y en `reiniciar()`; no se guarda |
| `inspiracion`, `inspiracion_maxima`, `ganar_inspiracion(n)` | Recurso de curación recortado entre 0 e `inspiracion_maxima`, incluso al asignarlo. La capacidad empieza en `INSPIRACION_INICIAL`, crece con `Recompensa.Tipo.INSPIRACION_MAXIMA` hasta `INSPIRACION_TOPE` y se guarda; un Módulo de RAM suma tres bloques (`monto` en puntos). La Inspiración actual no se guarda: se reinicia con la partida y se vacía al oír `jugador_muerto`. Cada cambio del valor o de la capacidad emite `inspiracion_cambiada` con el máximo actual, aunque la barra esté vacía |
| `reiniciar()` | Partida nueva: la llaman una ranura vacía y la zona de pruebas |
| `llenar_vidas()` | Vidas al máximo: al reaparecer después de morir |
| `a_diccionario()` / `desde_diccionario(partida)` | Hacia y desde los campos de `Guardado.ESQUEMA` y `Guardado.NUEVOS`. Al cargar, lo que no se guarda empieza de cero: Inspiración 0 y sin enemigos vencidos |

## Autoloads

| Nombre | Script | Qué hace |
|---|---|---|
| `Eventos` | `nucleo/eventos.gd` | Bus de eventos: solo declara las señales de «Bus de eventos». Va antes de `Arranque` para existir cuando arranca todo lo demás |
| `Partida` | `nucleo/partida.gd` | Estado de la partida (ver «Estado de la partida»). Va después de `Eventos` y antes de `Arranque` |
| `Arranque` | `nucleo/arranque.gd` | Pone el color de borrado en negro, carga los ajustes y, con pantalla, aplica el rango de la vista al arrancar y, diferido al final del cuadro, al cambiar el tamaño de la ventana (`proporcion_minima` y `proporcion_maxima`, exportadas). Imprime `ARRANQUE depuracion=<bool> puerto=<bool>` y, solo en un build de depuración y si el archivo viaja en el paquete, carga con `load()` el puerto de depuración como hijo suyo (`PuertoDepuracion`). También crea `Sonido` y `Musica` (ver `docs/audio.md`; los guarda con su tipo en `sonido` y `musica`) y `UltimaEntrada` (ver `docs/interfaz.md`, «Menú», párrafo «Tamaños y aspecto»), con o sin pantalla |

- Un autoload nuevo se agrega a esta tabla en el mismo cambio.
- Nada de `herramientas/` es autoload ni se carga con `preload`: el juego debe arrancar sin esa carpeta.
- Lo que el núcleo carga de otro bloque o de `herramientas/` pasa por `Cargar.si_existe(ruta)` (`nucleo/cargar.gd`,
  estático): el recurso, o `null` si no existe; quien lo llama lo convierte con `as`. Si solo hay que saber si existe,
  `ResourceLoader.exists`.

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
| `inspiracion_cambiada` | `inspiracion: int`, `maxima: int` | `Partida`, cada vez que cambia la Inspiración o su capacidad máxima |
| `descanso_en_banco` | `banco: StringName` (id del banco) | El banco, al descansar |
| `partida_guardada` | — | `Partida.guardar(ruta)` (banco y autoguardado), cuando el guardado salió bien |
| `enemigo_golpeado` | `enemigo: Node` | Un `Golpeable` con `es_enemigo`, al recibir un golpe del ataque, la bola o la onda (solo el ataque llena la Inspiración) |
| `objeto_golpeado` | `objeto: Node` | Un `Golpeable` sin `es_enemigo` (muro rompible, palanca), al recibir un golpe, y el jugador al desviar un disparo (`objeto` es el disparo); no da Inspiración. Lo oyen `Sonido` y `Vibracion` como un golpe |
| `muro_roto` | `muro: StringName` (su id) | El `MuroRompible`, al romperse. Lo oye `Sonido` |
| `porton_abierto` | `porton: StringName` (su id) | El `Porton`, al empezar a abrirse. Lo oye `Sonido` |
| `enemigo_vencido` | `enemigo: StringName` (id de su ficha) | El enemigo, al quedarse sin vida. El botín no lo escucha: lo suelta `Enemigo` (`docs/enemigos.md`, «Enemigos», viñeta «Botín») |
| `parry` | — | El jugador, al parar un `AtaqueEnemigo` |
| `habilidad_obtenida` | `habilidad: StringName` | `Partida.obtener_habilidad()` (el objeto de habilidad, una recompensa; en el juego, los jefes). Autoguarda |
| `amuleto_obtenido` | `amuleto: StringName` | `Partida.obtener_amuleto()`. Autoguarda |
| `util_obtenido` | `util: StringName` | `Partida.obtener_util()`. Autoguarda |
| `equipo_cambiado` | — | `Partida`, al poner o quitar un amuleto o un útil, al recibir una recompensa `CARGA`, en `reiniciar()` y en `desde_diccionario()`. Lo oye quien guarde `efectos_amuletos()` |
| `mapa_obtenido` | `zona: String` (la del mapa) | `Partida.obtener_mapa()` (el `ObjetoMapa`, una recompensa). Autoguarda |
| `coleccionable_obtenido` | `coleccionable: StringName` (su id) | El `Coleccionable` al tomarlo. Autoguarda |
| `monedas_cambiadas` | `monedas: int` | `Partida`, cada vez que cambian las PejeCoins |
| `jefe_vencido` | `jefe: StringName` (id del jefe) | El jefe. `Partida` lo anota en `jefes` y autoguarda. Tiene oyente (`Partida`) y ningún emisor en el juego hasta que exista el primer jefe: hoy solo lo emite una prueba |
| `cambio_de_sala` | `sala: String` (`Sala.clave()`: id, o ruta en una sala de prueba suelta), `puerta: StringName` (por la que llegó) | La sala, ya con el jugador puesto, cuando se llega por una puerta. Solo sale al llegar por una puerta, no por estación, banco ni muerte |
| `jugador_aterrizo` | `velocidad: float` (px/s de caída del último tick en el aire), `duro: bool` (empezó un aterrizaje duro), `picada: bool` (aterrizó de la picada) | El jugador vivo, una vez en cada aterrizaje con caída (aparecer en una sala no cuenta); el de la picada, antes de la onda, para que su vibración gane a la del golpe. `Vibracion` vibra solo con `duro` o `picada`; `Sonido` toca picada, o aterrizaje si es duro o cae a `velocidad_aterrizaje_min` o más |
| `jugador_salto` | — | El jugador al despegar en cada salto: en el suelo, coyote, en la pared y doble salto. Lo oye `Sonido` |
| `jugador_paso` | — | El jugador, al entrar a un cuadro de pasos (metadato `pasos` de su `SpriteFrames`) caminando o en carrera, en el suelo y fuera de un cruce de puerta. Lo oye `Sonido` |
| `jugador_impulso` | — | El jugador, al empezar un impulso. Lo oye `Sonido` |
| `jugador_ataco` | — | El jugador, al empezar cada ataque (de lado, arriba, abajo o en carrera), pegue o no. `Sonido` toca `ataque_jugador`; si pega, el golpe suena aparte |
| `curacion_empezada` | — | El jugador, al empezar a curar. `Sonido` toca `curar` |
| `curacion_cortada` | — | El jugador, si la curación no llega a terminar (soltar, dejar el suelo, un golpe, un peligro, morir, cruzar una puerta o dejar la sala). `Sonido` calla `curar`; terminar emite `jugador_curado` |
| `fundido_pedido` | `ticks_oscurecer: int`, `ticks_en_negro: int`, `ticks_aclarar: int` (0: se queda en negro) | El jugador al tocar un peligro y el `Fundido` al empezar un cambio de sala (puerta, estación o muerte); la escucha el `Fundido` de la sala |
| `mochila_recuperada` | `monto: int` (las PejeCoins devueltas) | `Partida.recuperar_mochila()`, al ganar el reto de la `Mochila` o al interactuar con ella sin bolsa. Autoguarda |
| `articulo_comprado` | `articulo: ArticuloTienda` | `Tienda.comprar()`, tras cobrar, marcar y entregar; después autoguarda |
| `tienda_abierta` | — | El `MenuTienda`, al final de su `_ready`, ya con el árbol detenido. La escucha el `Hud`: deja las PejeCoins fijas a la vista y corre en pausa |
| `tienda_cerrada` | — | El `MenuTienda` al cerrarse (`cerrar()`, una vez), ya quitada la pausa. La escucha el `Hud`: el contador vuelve a su ciclo |
| `viaje_hecho` | `estacion: String` (el id de la estación de llegada) | La `Estacion` de salida, en negro, justo antes de cambiar a la sala de la otra (si ese cambio falla, el `Fundido` emite después `cambio_fallido`). No guarda |
| `dispositivo_cambiado` | `dispositivo: int` (el nuevo `Mando.Dispositivo`) | `UltimaEntrada`, solo cuando `dispositivo` cambia de verdad (un toque tras otro no la emite). Al arrancar con un control conectado sale antes del primer cuadro. La escucha `IconoBoton` |
| `ajuste_cambiado` | `clave: StringName` (la de `Ajustes`) | La Configuración, al cambiar cualquier ajuste de sí o no (`Ajustes.CLAVES_SI_NO`), también desde la pausa; se aplican al momento `luces_avanzadas`, `niebla`, `mostrar_fps`, `panel_pruebas`, `ver_hitbox` y `modo_desarrollador` (`Ajustes.MODO_DESARROLLADOR`); `vibracion` y `temblor` no tienen quien la escuche. La escuchan las piezas que dependen de él (`ContadorFps`, `LuzSala`, `Niebla`, el panel de pruebas y ver hitbox). `recursos` no: vale desde la sala siguiente (ver `docs/arte-y-rendimiento.md`, «Recursos») |
| `mando_cambiado` | — | `Mando`, una vez al final de `asignar`, `aplicar` o `por_omision` si puso algún botón, aunque sea el mismo que ya tenía (no por cada botón; un botón inválido no la emite). Una emisión de más solo cuesta un refresco del ícono. La escucha `IconoBoton` |

Ganchos a propósito: `enemigo_vencido`, `cambio_de_sala`, `mochila_recuperada`, `articulo_comprado` y `viaje_hecho` no tienen oyente en el juego (solo pruebas y guiones) y no se borran, por decisión de la auditoría del código; `jefe_vencido` lo emite `ArenaJefe` y lo anota `Partida`. Dejar de emitir una señal lo decide la persona.

## Sala

Una sala es una escena cuya raíz es un `Node2D` con `nucleo/sala.gd` (`class_name Sala`).

| Pieza | Qué es |
|---|---|
| Propiedad `id` (`String`, exportada) | `<zona>_<número>` (`celda_1`), igual al nombre del archivo. Es lo que guardan la partida y el mapa. Vacío solo en las salas de prueba sueltas de `herramientas/salas/`, que se nombran por su ruta |
| Nodo `Entrada` (`Marker2D`, hijo de la raíz) | Donde aparece el jugador. Sin él, aparece en el origen de la sala |
| Propiedad `limites` (`Rect2`, exportada) | Rectángulo de la sala en sus coordenadas; en una sala con id empieza en `(0, 0)` (lo exige el validador): el índice coloca su rectángulo en `ficha_zona.origen_mapa + posicion_mapa + limites.position` (sin ficha, el origen de zona es cero) y la mochila en la esquina de ese rectángulo más su `x, y`, así que con otro origen de límites se dibujaría corrida esa cantidad. La cámara del jugador (`CamaraJugador`) sigue al jugador y no muestra nada fuera de él en cada eje donde la sala es al menos tan grande como la vista |
| El jugador | No va dentro de la escena: la sala instancia `nucleo/jugador.tscn` en su `_ready` y le pasa `limites` |
| Suelos y plataformas | `StaticBody2D` sólidos por todos lados. Por qué: en las escenas de Hollow Knight y Silksong no se encontró ninguna plataforma de una vía (un indicio fuerte, no una prueba); sin ellas no hay descenso que mantener, y una escalera se resuelve en sólido con huecos entre escalones (los de `sala_camara`, separados 160 px, guion `nucleo/camara_escalera`). Única excepción: una pieza que cuelga o se ve delgada en una ruta escondida, donde cruzarla caminando y subirse de un salto es parte de descubrirla, es una instancia de `nucleo/piezas/plataforma_delgada.tscn` (`PlataformaDelgada`, o una escena heredada de ella con su dibujo), nunca la única salida de un lugar y nunca sobre algo que se mueve (medido: una de una vía que baja hasta el suelo pasa a través del jugador parado). El validador falla con cualquier otra forma de una vía escrita en una escena (`one_way_collision` en una `CollisionShape2D` o `CollisionPolygon2D`) y con una `PlataformaDelgada` dentro de algo que se mueve (`Vaiven.movil_de`); que no sea la única salida no se ve sin geometría: lo comprueba un guion de bajada por cada ruta. Lo que se pisa no se marca con una orilla aparte. Lo que se mueve y lleva al jugador es sólido (un `AnimatableBody2D` con `Vaiven`) |
| Controles, pausa, marco de menús, vibración, brillo, fundido, interfaz y mapa | También los crea la sala en su `_ready`: `ControlesTactiles`, `Pausa`, `Marco` (`MarcoMenus`), `Inventario` (`PaginaInventario`), `Amuletos` (`PantallaAmuletos`), `Utiles` (`PantallaUtiles`), `Vibracion`, `Fundido`, `Brillo` (`CanvasModulate`, ver `docs/ajustes-y-entrada.md`, «Ajustes»), `ContadorFps` (`nucleo/contador_fps.gd`, capa 24: el contador y el límite de 60 en menús), `PanelPruebas` y `VerHitbox` (ver `docs/arte-y-rendimiento.md`, «Recursos») y, si existen, `interfaz/interfaz.tscn` y `mapa/pantalla_mapa.tscn` (con `load()`, para que el núcleo no dependa de esos bloques; ver `docs/interfaz.md`, «Interfaz» y «Mapa») |
| Propiedades `tema_musica` (`AudioStream`) y `volumen_musica_db` (`float`) | La sala los pide a `Musica` en su `_ready` (se aplican en el tick siguiente: si el jugador aparece dentro de una `RegionMusica`, la región pide después y gana). Es el `MusicCue` de Hollow Knight: un tema que ya suena sigue sin empezar de nuevo, así que las salas de una zona comparten el mismo recurso, puesto en la base de la zona. Vacío no toca la música (sigue la que suena); `Musica.SILENCIO` la calla. `volumen_musica_db` es el volumen de región al entrar (`Musica.DB_SILENCIO`: callado hasta llegar a una `RegionMusica`). La Celda: `SILENCIO` hasta tener tema propio, salvo la `RegionMusica` `MusicaBanco` junto al banco de `celda_1` (tema del menú) |
| Propiedad `sonidos` (`FichaSonidos`, vacía) | Efectos propios de la sala o de su zona, puestos en la base de zona. Al entrar asigna `Arranque.sonido.ficha_sala`, también si está vacía para borrar la anterior. Un campo vacío usa el global; la ficha propia del enemigo tiene prioridad |
| Propiedad `oscuridad` (`float`, 0 a 1) | La aplica el `Brillo` de la sala: su color es el brillo por `1 - oscuridad`, sin dibujar nada encima (`Brillo.color_para(valor, oscuridad)`). La Celda: 0,58 |
| Propiedad `posicion_mapa` (`Vector2`) | Esquina de la sala en px desde `ficha_zona.origen_mapa` (sin ficha, desde `(0, 0)`). Las salas de una zona se acomodan como se recorren. Todas las zonas comparten el plano, cada una en su franja: una zona nueva fija su origen en la siguiente franja libre hacia abajo que imprime el generador (`docs/guias/armar-una-sala.md`). El validador falla si dos salas se enciman en el mapa, de zonas distintas o de la misma (tocarse por un borde no cuenta, `classes/class_rect2.rst:470`). Se escribe a mano y no se deriva de las puertas: cada escena se ubica sola (`tutorials/best_practices/scene_organization.rst:37`). Cambiarla obliga a regenerar el índice del mapa |
| Propiedad `ficha_zona` (`FichaZona`, exportada) | Recurso compartido, puesto una vez en la base de la zona: `nucleo/ficha_zona.gd` (`Resource`) con `nombre` visible, `color` de relleno en el mapa alejado y `origen_mapa`, esquina de la franja en el mundo. El índice copia el nombre y el color y suma el origen a las posiciones de sus salas. La Celda usa `contenido/zonas/celda/zona_celda.tres`, con origen `(0, 0)`. Una sala con id en `contenido/` necesita ficha; dos salas de una misma zona no pueden usar fichas con distinto `resource_path`. Las salas de prueba pueden dejarla vacía |
| Propiedad `botones_por_ensenar` (`Array[StringName]`) | Acciones cuyo botón de la pantalla no se ve en esta sala hasta que un `AvisoAccion` lo enseña (la sala Pizarrones empieza sin saltar, atacar ni curar; pausa y mapa se ven siempre). El validador exige que cada una sea un botón de la pantalla (`ControlesTactiles.ACCIONES`) y que algún aviso de la sala la enseñe |
| Propiedad `botones_ocultos` (`Array[StringName]`) | Igual, pero el aviso que lo enseña está en una sala posterior, que puede ser de otra zona: va en la base de la zona (La Celda esconde `curar`). El validador solo exige que cada una sea un botón de la pantalla |
| Propiedad `habilidades_de_prueba` (`Array[StringName]`) | Solo salas de prueba: habilidades que la sala da en silencio al entrar (sin aviso ni autoguardado). Las de `herramientas/salas/` dan `pluma`, salvo la de combate chico (donde se recoge), la del diálogo y la del reto. El validador la exige vacía en `contenido/` |
| Propiedad `inspiracion_maxima_de_prueba` (`int`) | Solo salas de prueba: capacidad de Inspiración con la que se prueba, subida en silencio al entrar (0: la de la partida). La usa la sala de la bola, que necesita dos bolas. El validador la exige en 0 en `contenido/` |
| Puertas (opcionales) | Instancias de `nucleo/puerta.tscn` (`class_name Puerta`, `Interactuable`) o de una escena heredada de ella con su arte (`contenido/objetos/<zona>/`, `docs/arte-y-rendimiento.md`, «Arte de zona»), hijas directas de la raíz. Sin hijos que dibujen, la puerta pinta un rectángulo provisional de 40 × 160 (`Interactuable.dibujar_provisional`); lo apaga cualquier hijo `CanvasItem` que no sea forma: el arte, o un `Marker2D` en una puerta sin dibujo propio (la `Boca` de los huecos de La Celda, cuyo arte es el de la sala). Ver abajo |
| Capas de fondo y de frente (opcionales) | Nodos `Parallax2D` hijos de la raíz, o de un `FondoTapado` hijo de la raíz (ver `docs/arte-y-rendimiento.md`, «Recursos»). `scroll_scale` menor que 1 para el fondo (más lejos, más lento) y mayor que 1 para el frente; `z_index` negativo para el fondo y positivo para el frente |

- Dónde vive cada sala: las del juego en `contenido/salas/<zona>/<id>.tscn`; las de las zonas de prueba en
  `herramientas/salas/zonas/<zona>/<id>.tscn`. La zona es lo que va antes del primer guion bajo del id: una palabra
  sin guion bajo (`celda`, `raices`).
- `Sala._ready` consume y limpia las estáticas de llegada `puerta_llegada`, `llegada_a_banco` y
  `estacion_llegada`. `cambio_pedido_ms` se conserva hasta el primer tick de física de la sala nueva para medir
  la carga y entonces se limpia a `-1`, también fuera de depuración.
- Al entrar, la sala se anota en `Partida.salas_visitadas`. `Sala.clave_de(nodo)` (estática) da la clave de la sala a
  la que pertenece un nodo: su `owner` si es la `Sala` y, si no, la primera `Sala` entre sus ancestros. Así un objeto
  que se recuerda puede ir dentro de una pieza instanciada (allí su `owner` es la raíz de la pieza) y se guarda en la sala.
- `Sala.ruta_de(id)` (estática) da la escena de un id (primero `contenido/`, después la zona de prueba si existe);
  una ruta `res://` pasa tal cual. `Sala.zona_de(id)` da su zona. `Sala.nombre_de(id_o_ruta)` da el nombre
  visible de la zona desde `nombres_zona` del índice opcional del mapa (cacheado una vez); sin nombre usa el id
  con `capitalize()`, y para una ruta usa el nombre del archivo sin extensión con `capitalize()`. `clave()` es el id de la sala o, si no tiene, su
  ruta: lo que guardan `Partida.sala`, la clave de los enemigos fuertes y `cambio_de_sala`.
- Los ids de sala no se renumeran nunca, aunque una sala se quite: los guardan la partida y el mapa. Una sala nueva
  toma el siguiente número libre de su zona.
- Convenciones de ids: puertas por su lado (`izquierda`, `derecha`, `arriba`, `abajo`; dos del mismo lado,
  `derecha_2`); banco `banco_<id de la sala>`; objetos que se recuerdan, un nombre corto único dentro de la sala.
- Cómo se escribe una sala: Claude escribe cada sala completa como `.tscn` (formas, puertas, objetos y decoración); la persona la revisa en el editor si quiere. Con tres condiciones: ningún generador de escenas fuera del repo (dos fuentes de verdad); se conservan el `uid` y los ids de `ext_resource` de lo que ya existe; y cada `ext_resource` lleva su uid, que el validador exige (viñeta «uid», más abajo).
- El validador revisa cada sala con id y cada escena y ficha del juego; la lista completa de lo que revisa está en `docs/validador.md`. Lo de recursos, presupuesto e importación está en `docs/arte-y-rendimiento.md`, «Recursos», y el mapa, en `posicion_mapa`. Una regla nueva del validador entra a `docs/validador.md` y a su entrada de `herramientas/funciones.json` en el mismo cambio.
- uid: en `contenido/`, `nucleo/`, `mapa/` e `interfaz/` (`CARPETAS_CON_UID` de `herramientas/validar.gd`) cada
  `.tscn` y `.tres` lleva `uid` en su cabecera, y cada línea `[ext_resource` lleva el `uid=` de su destino: el del
  `.uid` de un script o shader, el de la línea `uid=` del `.import` de una imagen o un sonido, o el de la cabecera de
  otra escena o recurso. Con él, la referencia sigue aunque el archivo se mueva o se renombre
  (`classes/class_resourceuid.rst:22`). Falla una línea sin `uid=`, con uno que no es el de su destino o que nombra un
  `.tscn`/`.tres` sin uid propio. Una escena escrita a mano toma los uid del disco (si un recurso nuevo aún no lo
  tiene, se importa primero); nunca se inventa uno. `herramientas/` queda fuera (escenas de prueba que se nombran por
  ruta). Fuera del editor `ResourceSaver.save` no escribe esos uid (comprobado): los generadores
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
  pasan el máximo de capas translúcidas (`docs/arte-y-rendimiento.md`, «Recursos»). Un aviso se resuelve o se explica en el plan; no se deja crecer.
- Una capa se desplaza en proporción a la cámara: su posición es el borde de la cámara por `1 - scroll_scale`
  (medido en un guion). Para que no queden huecos, el contenido de una capa cubre, en cada eje,
  desde 0 hasta `(tamaño de la sala - tamaño de la pantalla) × scroll_scale + tamaño de la pantalla`. Con
  `aspect=expand` la pantalla puede ser más ancha que 1280: la sala de prueba deja 2560 px de margen de cada lado.
- Cámara, como en Hollow Knight: el nodo `Camara` del jugador (`nucleo/camara_jugador.gd`, `class_name CamaraJugador`)
  se mueve a mano y recorta su objetivo a `limites` antes de suavizar, así se frena sola al acercarse al borde. No
  tiene tick propio: el jugador la llama en su `_physics_process` (seguir al final de cada tick, también congelado; el
  temblor al revisar el aterrizaje; colocarla al entrar a la sala y al reaparecer). Bajo el suelo basta el margen de siempre (40 px): sin jalón al caer
  (`camara_caida.guion`); las salas de caída larga dejan 120 px (16,7 % de 720 de suelo a la vista).
  El margen casi no cambia el jalón (89,8 px/s por tick con 40 px, 93,1 con 120; umbral 100); las salas de 720 de
  alto no crecen, porque su cámara empezaría a moverse en vertical al saltar. Si la vista es mayor que la sala en un eje, la cámara se centra en ese eje y
  lo que sobra se ve por igual a los dos lados, como ya hacía `Camera2D` (`camara_centrada.guion`); sus `limit_*` quedan como seguro.
  Una `ZonaCamara` (ver `docs/componentes.md`, «Componentes») recorta además esos límites mientras el jugador está en ella.
- Fondo extendido: si la sala tiene un nodo `Fondo` (`ColorRect`) visible, al entrar crea detrás de todo
  `FondoExtendido`, de su color y `MARGEN_FONDO` más grande por lado: cubre el rango de la vista en una sala
  mínima de 1280×720 (240) más el temblor de la cámara. Sin `Fondo` visible no crea nada y lo de fuera se ve negro, el color de borrado.
- Fundido a negro (`nucleo/fundido.gd`, `class_name Fundido`, `CanvasLayer` capa 15: encima del juego, los controles y
  la interfaz, que se oscurecen con él, y debajo de la pausa y el editor de botones): la sala lo crea en negro y aclara
  en `TICKS_ACLARAR` ticks, o en `TICKS_ACLARAR_PUERTA` si se llegó por una puerta. Ante un
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
  (`Fundido.ticks_de`; las cifras son constantes de `nucleo/fundido.gd`): `PUERTA` (los de Hollow Knight), `ESTACION` y `MUERTE` (sin tiempo en negro, al final de los 90 ticks oscuro, con las vidas llenadas en `en_negro`).
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

## Amuletos y útiles

Las pantallas del marco para ponerlos y quitarlos (`PantallaAmuletos`, `PantallaUtiles`) están en `docs/interfaz.md`, «Pantallas de amuletos y útiles».

### Fichas y catálogo

- `nucleo/ficha_amuleto.gd` (`class_name FichaAmuleto`, `Resource`): `id`, `nombre`, `descripcion`, `costo` (1 a 3,
  como los amuletos de Hollow Knight), `icono` (`Texture2D`, opcional, para cuando tenga arte) y, en
  el grupo «Efectos», `velocidad_factor` (1), `invulnerable_extra` (ticks, 0), `inspiracion_extra` (por golpe, 0) y
  `botin_factor` (1). Los valores por omisión no hacen nada.
- `nucleo/ficha_util.gd` (`class_name FichaUtil`, `Resource`): `id`, `nombre`, `descripcion` e `icono`. Un útil no
  tiene números: lo que hace lo lee quien lo necesita con `Partida.util_equipado(id)` (la brújula, la pantalla del
  mapa), como las herramientas de Silksong (`compassTool.IsEquipped` en `GameMap`).
- `nucleo/catalogo_equipo.gd` (`class_name CatalogoEquipo`, `Resource`): la lista oficial, `amuletos` y `utiles`.
  Hay dos: el del juego (`contenido/equipo.tres`, `RUTA_JUEGO`) y el de la zona de pruebas
  (`herramientas/salas/fichas/equipo_prueba.tres`, `RUTA_PRUEBAS`). `CatalogoEquipo.amuleto(id)` y `util(id)` buscan
  primero en el del juego y dan `null` si el id no está en ninguno; un id fuera del catálogo no se puede poner. Cargan
  cada vez con `Cargar.si_existe` (la copia que ya tiene el motor), sin caché estática, y leen el catálogo como
  `Resource`, sin nombrar su propia clase: que el script se nombre a sí mismo dejaba recursos sin liberar al salir
  (`docs/errores/2026-10-29-fuga-catalogo-equipo.md`).
- Un amuleto o un útil nuevo es una entrada en un catálogo; su id no se renombra (lo guarda la partida).
- Quién aplica cada efecto: el `Jugador` guarda `Partida.efectos_amuletos()` al aparecer y lo renueva con
  `equipo_cambiado`; multiplica la velocidad al caminar (no la carrera, el impulso ni la caminata de una puerta), suma
  `invulnerable_extra` a los ticks sin daño tras recibir un golpe (no tras el parry ni la picada) y `inspiracion_extra`
  a cada golpe que da Inspiración (el del ataque y el del parry al enemigo; no un golpe bloqueado). El `Enemigo`, al
  soltar su botín, lo multiplica por `botin_factor` (redondeado). Prueba: `herramientas/guiones/nucleo/efectos_amuletos`.
- El validador falla una `Recompensa` de tipo `AMULETO` o `UTIL` (de una entrega, un reto, una tienda o una ficha de
  diálogo) cuyo id no esté en un catálogo, y fuera de `herramientas/` uno que solo esté en el de pruebas, que no viaja en el paquete de publicación (`validador-equipo`).

## Grupos

| Grupo | Quién lo lleva | Quién lo usa |
|---|---|---|
| `jugador` | El cuerpo que controla la persona: el `Jugador` que crea la sala | El puerto de depuración (posición y si está en el suelo), `ComportamientoEnemigo.jugador()`, `MuroRompible` (el rebote del jugador), los controles táctiles, el marco de menús, la pantalla de amuletos, la del mapa y, en pruebas, `herramientas/salas/medidor_camara.gd` y `herramientas/pruebas/prueba_peligro_anti_bucle.gd` |
| `pantalla_encima` | Una pantalla abierta sobre el juego (hoy, `MarcoMenus`, `MenuTienda`, `MenuEstaciones` y `CobroEstacion`) con `bloquea_pausa() -> bool` | La `Pausa`: no se abre (con `pausa`, Atrás ni al perder el foco) mientras una diga que bloquea, ni en el tick en que se cerró |
| `pagina_marco` | Las páginas del marco de menús, que extienden `PaginaMarco` (la base las pone en el grupo): `PaginaInventario`, `PantallaAmuletos`, `PantallaUtiles` y `PantallaMapa` | `MarcoMenus`, que las ordena y las muestra (ver `docs/interfaz.md`, «Marco de menús») |

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
| 20 | `Pausa`, las páginas del marco, los menús de la tienda y de las estaciones y el cobro de una estación (nunca hay dos abiertos a la vez) | `nucleo/modal_pausa.gd` (`ModalPausa.CAPA`, la fuente; `nucleo/pausa.tscn` repite el número), `nucleo/pagina_marco.gd` (`PaginaMarco.CAPA`, la de `nucleo/pagina_inventario.gd`, `nucleo/pantalla_amuletos.gd`, `nucleo/pantalla_utiles.gd` y `mapa/pantalla_mapa.gd`), `nucleo/menu_tienda.gd`, `nucleo/menu_estaciones.gd`, `nucleo/cobro_estacion.gd` |
| 21 | La barra del marco de menús (`MarcoMenus`) | `nucleo/marco_menus.gd` |
| 22 | Configuración abierta desde la pausa (`Pausa.CAPA_CONFIGURACION`) | `nucleo/pausa.gd` |
| 23 | `EditorControles`, encima de Configuración | `nucleo/editor_controles.tscn` |
| 24 | `ContadorFps`, encima de todo: se lee también con un menú abierto | `nucleo/contador_fps.gd` |

Una capa nueva entra a esta tabla en el mismo cambio.

## Paquete de publicación

El núcleo no depende de `herramientas/`: las únicas referencias son la carga condicional de `Arranque` (el puerto,
solo en un build de depuración), `Sala.ruta_de` (busca una sala en `Sala.CARPETA_PRUEBAS` si no está en
`contenido/salas/`), la tabla de estaciones de prueba, que `Estacion.tabla_de` carga solo para una sala de la zona de pruebas y solo si
existe (`herramientas/salas/zonas/estaciones_prueba.tres`), el catálogo de amuletos y útiles de prueba, que
`CatalogoEquipo` carga solo si existe (`herramientas/salas/fichas/equipo_prueba.tres`, ver «Amuletos y útiles»), y el botón «Zona de pruebas» del menú principal, que aparece con el modo
desarrollador encendido si `herramientas/salas/zona_pruebas.tscn` existe (`ResourceLoader.exists`, sin `preload`),
en depuración y en publicación. Que la zona viaje en el paquete de publicación lo decide el `exclude_filter` del
preset «Publicacion» de `export_presets.cfg`:

- Viajan la zona de pruebas y sus salas jugables: `herramientas/salas/` completa, con `zonas/`, `fichas/`,
  `comportamientos/` y `arte/`.
- No viajan: `*funciones.json`, `herramientas/pruebas/*` (las pruebas de código: `sala_*.tscn`
  sin jugador, sus `prueba_*.gd` y `prueba_base.gd`), `herramientas/validar.*`, `herramientas/generar_mapa.*`,
  `herramientas/generar_sprites.*` (genera el `SpriteFrames` del jugador),
  `herramientas/generar_trazo.*` (genera la textura de `TrazoAtaque`),
  `herramientas/generar_efectos.*` (genera las hojas de `EfectoCuadros` del jugador, el ruido de la niebla y el montón de `MonedasSueltas`) y
  `herramientas/puerto_depuracion.*`. Los patrones van separados por coma, sin `res://`, y `*` cruza `/`. Los
  guiones (`.guion`, `.esperado`) no son recursos y no se exportan.
- Por eso nada fuera de `herramientas/pruebas/` nombra una ruta `res://herramientas/pruebas/`: lo revisa el
  validador (`validador-pruebas-aparte`).
- Los videos `.mp4` (`nucleo/video/`, `contenido/cinematicas/`) no los importa Godot: los dos presets los llevan con
  `include_filter="*.mp4"` (ver `ReproductorVideo` en `docs/interfaz.md`, «Componentes de menú»). Los `.ogv` no pasan por el
  importador (llevan solo su `.uid`) y los dos presets los dejan fuera con `exclude_filter` (son 12,4 MB que en el teléfono no se usan; si H.264 falla, el respaldo es la imagen `.jpg`). En la PC y en los guiones
  sí están.
- El preset «Desarrollo» lleva todo lo demás (su `exclude_filter` es solo `*.ogv`) y arranca con `--print-fps`; los dos exportan para
  `armeabi-v7a` y `arm64-v8a`.
- Se comprueba con `--export-pack "Publicacion" <archivo>.zip` y la lista de entradas bajo `herramientas/`: los
  scripts salen como `.gdc` y las escenas como `.remap`.
