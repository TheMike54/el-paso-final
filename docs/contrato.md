# Contrato del proyecto

Lo que un bloque puede dar por hecho de los demás: la configuración del proyecto, el ciclo de vida, el guardado, los autoloads, el bus de eventos y la forma de una sala. Si un cambio altera algo de aquí, este documento se actualiza en el mismo cambio. Las señales del bus de eventos, la forma de una sala, la ficha de una entidad y el esquema del guardado entran a este documento o a su archivo por tema en el mismo cambio que los implementa, con su plan aprobado antes.

El contrato se parte por tema para leer solo lo que la tarea toca. Este archivo es el núcleo; los demás son parte del contrato y se leen cuando la tarea toca su tema:

| Archivo | Qué trae | Cuándo leerlo |
|---|---|---|
| `docs/contrato.md` (este) | Configuración, ciclo de vida, guardado, estado de la partida, autoloads, bus de eventos, fichas de amuletos y útiles, grupos, capas de física y de dibujo, paquete de publicación | Antes de crear contenido, un autoload o tocar el guardado |
| `docs/sala.md` | Forma de una sala, cambio de sala y llegada, cámara, suelos y plataformas, fondo extendido y bancos | Al crear una sala, y al tocar la reaparición, la carga de una ranura, las transiciones o el viaje rápido |
| `docs/componentes.md` | Las piezas del núcleo que una sala instancia: golpeables, recogibles, NPC, tienda, estaciones, plataformas, peligros | Al armar una sala o una pieza |
| `docs/enemigos.md` | Ficha de enemigo, comportamientos, datos, botín, ataques, parry y ganchos | Al crear o tocar un enemigo |
| `docs/audio.md` | Buses, `Sonido`, `Musica` y `Vibracion` | Al tocar sonido, música o vibración |
| `docs/ajustes-y-entrada.md` | El archivo de ajustes, `Mando`, brillo, las acciones de entrada, los controles táctiles y su editor | Al agregar un ajuste o una acción, o al tocar los controles |
| `docs/interfaz.md` | HUD, mapa, marco de menús, pantallas de amuletos y útiles, menú principal, `Tema`, pausa y piezas de menú | Al tocar un menú, el HUD o el mapa |
| `docs/arte-y-rendimiento.md` | Modo de recursos, presupuesto por sala, importación del arte, arte de zona y las mediciones que sostienen las reglas | Antes de agregar arte, luces, partículas o una sala |
| `docs/validador.md` | Lo que revisa `herramientas/validar.gd` en salas y fichas, el uid de escenas y recursos y los avisos | Al agregar una regla del validador o ante un fallo que no se entiende |

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
| Arranque | `application/boot_splash/show_image` apagado y `bg_color` negro | Sin el logo de Godot: la pantalla queda en negro mientras carga, hasta el menú |
| Compresión de texturas | `textures/vram_compression/import_etc2_astc=true` | Godot no exporta a Android sin ella |
| Filtro de texturas | `textures/canvas_textures/default_texture_filter=2` (lineal con mipmaps) | La vista de 1280×720 se encoge en pantallas más chicas; el arte del mundo lleva mipmaps (ver `docs/arte-y-rendimiento.md`, «Recursos») |
| Interpolación de física | Apagada (`physics/common/physics_interpolation`, por omisión) | En el S21 a 120 FPS no hay saltos sin ella, y suma retraso a la entrada (parry, salto en cola) |
| Capas de física | `layer_names/2d_physics/layer_1` a `layer_7` | Nombres en el editor; la tabla, en «Capas de física» |
| Id del paquete Android | `com.themike54.elpasofinal` | Identidad estable de la app instalada |
| Ícono | `config/icon` = `res://nucleo/arte/icono/icono_192.png`; en los dos presets, `launcher_icons/*`: el de 192 y los adaptativos de 432 (frente, fondo y monocromo), en `nucleo/arte/icono/` | El ícono aprobado en el lanzador y en el editor (`tutorials/export/exporting_for_android.rst:119-127`) |
| Idioma | Solo español en la v1; cada texto se escribe completo, sin frases armadas a pedazos | Decisión cerrada |
| Exportación | «Publicacion» exporta AAB con plantilla Gradle; «Desarrollo», APK. Una sola máquina exporta las versiones; la clave de publicación la genera la persona y se guarda fuera del repo | Decisión cerrada (ver también `CLAUDE.md`, «Decisiones cerradas») |

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
- El guardado es JSON con número de versión. Al cargar se distinguen partida válida, archivo dañado, partida de
  una versión incompatible y archivo que no se pudo abrir, más el caso sin partida guardada (ver «Guardado»).
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
| `Guardado.respaldar(ruta) -> Error` | Copia una partida `VALIDA` a `<ruta>.bak.tmp` y la renombra a `<ruta>.bak`; una que no es válida no se copia y la copia anterior sigue. Si la copia falla, la anterior se queda: una vieja rescata más que ninguna |
| `Guardado.restaurar(ruta) -> Error`, `Guardado.tiene_respaldo(ruta) -> bool` | Copia `<ruta>.bak` a `<ruta>.tmp` y lo renombra a `<ruta>`; solo cuenta una copia `VALIDA` (una cortada o dañada no): sin ella, `ERR_FILE_NOT_FOUND` y `tiene_respaldo` da `false` |
| `Guardado.fingir_fallo(ruta, error)`, `Guardado.olvidar_fallos()` | Solo para las pruebas: `ruta` no se puede leer ni borrar |

| `Guardado.Estado` | Cuándo |
|---|---|
| `VALIDA` | El archivo es JSON, su `version` es `VERSION` y `partida` tiene todos los campos del esquema con su tipo; los de `NUEVOS` que faltan se rellenan con su valor por omisión |
| `VACIA` | No hay archivo: partida nueva. Un `.tmp` sobrante de un cierre a la mitad no cuenta |
| `DANADA` | No es JSON, no es un objeto, falta `version` o no es número, `partida` no es un objeto, le falta un campo o tiene otro tipo (un campo de `NUEVOS` con otro tipo también), un número está bajo su mínimo (`Guardado.MINIMOS`) o el `monto` de la mochila es negativo |
| `INCOMPATIBLE` | `version` es más nueva que `VERSION` (el juego no la sabe leer) o más vieja (hoy no hay ninguna función de conversión). Ver «Partidas viejas» abajo |
| `ILEGIBLE` | El archivo existe y no se pudo abrir (`FileAccess.get_open_error()`): nada dice que esté dañado, así que no se abre, no se borra ni se restaura. `Guardado.Resultado.cerrada()` agrupa `DANADA`, `INCOMPATIBLE` e `ILEGIBLE` |


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
| `ultimo_guardado_fallo`, `TEXTO_GUARDADO_FALLIDO` | Si el último `guardar()` falló, y el texto del aviso. Lo leen un `Hud` nuevo y el menú principal, para que el aviso no se pierda al cambiar de pantalla. No se guarda; un guardado bueno, `reiniciar()` y abrir una ranura lo apagan |
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
| `habilidades`, `tiene(id)` | `Array[StringName]` con las habilidades obtenidas, y si una está. Los ids están en `nucleo/habilidades.gd` (`class_name Habilidades`, una constante por habilidad y `TODAS`); el código usa las constantes, no el texto. `obtener_habilidad` con un id que no está en `TODAS` imprime un `ERROR:` y no lo suma (el validador revisa los de objetos, recompensas y `habilidades_de_prueba`: `docs/validador.md`). Los ids no se renombran: los guarda la partida. Amuletos y útiles llevan su id en su ficha (ver «Amuletos y útiles»); el `id_jefe` de `ArenaJefe` |
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
| `guardado_fallido` | `error: int` | `Partida.guardar(ruta)` (banco y autoguardado), cuando no se pudo guardar; el HUD lo dice en pantalla |
| `enemigo_golpeado` | `enemigo: Node` | Un `Golpeable` con `es_enemigo`, al recibir un golpe del ataque, la bola o la onda (solo el ataque llena la Inspiración) |
| `objeto_golpeado` | `objeto: Node` | Un `Golpeable` sin `es_enemigo` (muro rompible, palanca), al recibir un golpe, y el jugador al desviar un disparo (`objeto` es el disparo); no da Inspiración. Lo oyen `Sonido` y `Vibracion` como un golpe |
| `muro_roto` | `muro: StringName` (su id) | El `MuroRompible`, al romperse. Lo oye `Sonido` |
| `porton_abierto` | `porton: StringName` (su id) | El `Porton`, al empezar a abrirse. Lo oye `Sonido` |
| `enemigo_vencido` | `enemigo: StringName` (id de su ficha) | El enemigo, al quedarse sin vida. El botín no lo escucha: lo suelta `Enemigo` (`docs/enemigos.md`, «Enemigos», viñeta «Botín») |
| `parry` | — | El jugador, al parar un `AtaqueEnemigo`. Un `ProyectilEnemigo` no: se desvía y emite `objeto_golpeado` (`docs/enemigos.md`) |
| `habilidad_obtenida` | `habilidad: StringName` | `Partida.obtener_habilidad()` (el objeto de habilidad o una recompensa). Autoguarda |
| `amuleto_obtenido` | `amuleto: StringName` | `Partida.obtener_amuleto()`. Autoguarda |
| `util_obtenido` | `util: StringName` | `Partida.obtener_util()`. Autoguarda |
| `equipo_cambiado` | — | `Partida`, al poner o quitar un amuleto o un útil, al recibir una recompensa `CARGA`, en `reiniciar()` y en `desde_diccionario()`. Lo oye quien guarde `efectos_amuletos()` |
| `mapa_obtenido` | `zona: String` (la del mapa) | `Partida.obtener_mapa()` (el `ObjetoMapa`, una recompensa). Autoguarda |
| `coleccionable_obtenido` | `coleccionable: StringName` (su id) | El `Coleccionable` al tomarlo. Autoguarda |
| `monedas_cambiadas` | `monedas: int` | `Partida`, cada vez que cambian las PejeCoins |
| `jefe_vencido` | `jefe: StringName` (id del jefe) | `ArenaJefe` (`docs/enemigos.md`, «Jefes»). `Partida` lo anota en `jefes` y autoguarda |
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
  diálogo) o un `ObjetoAmuleto` cuyo id no esté en un catálogo, y fuera de `herramientas/` uno que solo esté en el de pruebas: el juego no depende de datos de prueba (`validador-equipo`, `validador-objeto-amuleto`).

## Grupos

| Grupo | Quién lo lleva | Quién lo usa |
|---|---|---|
| `jugador` | El cuerpo que controla la persona: el `Jugador` que crea la sala | El puerto de depuración (posición y si está en el suelo), `ComportamientoEnemigo.jugador()`, `MuroRompible` (el rebote del jugador), los controles táctiles, el marco de menús, la pantalla de amuletos, la del mapa y, en pruebas, `herramientas/salas/medidor_camara.gd` y `herramientas/pruebas/prueba_peligro_anti_bucle.gd` |
| `pantalla_encima` | Una pantalla abierta sobre el juego (hoy, `MarcoMenus`, `MenuTienda`, `MenuEstaciones` y `CobroEstacion`) con `bloquea_pausa() -> bool` | La `Pausa`: no se abre (con `pausa`, Atrás ni al perder el foco) mientras una diga que bloquea, ni en el tick en que se cerró |
| `pagina_marco` | Las páginas del marco de menús, que extienden `PaginaMarco` (la base las pone en el grupo): `PaginaInventario`, `PantallaAmuletos`, `PantallaUtiles` y `PantallaMapa` | `MarcoMenus`, que las ordena y las muestra (ver `docs/interfaz.md`, «Marco de menús») |
| `colgantes_sala`, `fondos_sala`, `luces_sala`, `nieblas_sala` | Los `Colgante`, `FondoTapado`, `LuzSala` y `Niebla` de la sala | `PanelPruebas`, que apaga cada capa para medir |

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
| 5 | `interaccion` | `Puerta`, `Banco`, `Coleccionable`, `MonedasSueltas`, `ObjetoHabilidad`, `ObjetoAmuleto`, `ObjetoMapa`, `Npc`, `RetoPreguntas`, `EntregaRecompensas`, `Mochila`, `Tienda`, `Estacion`, `AvisoAccion`, `ZonaCamara`, `RegionMusica` y el interruptor de la brújula | `jugador` |
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
  `herramientas/generar_efectos.*` (genera las hojas de `EfectoCuadros` del jugador, el ruido de la niebla y el montón de `MonedasSueltas`), `herramientas/arreglar_uids.*` y
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
