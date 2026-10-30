# Arte y rendimiento

Parte del contrato (`docs/contrato.md`): el modo de recursos y las piezas que cambian con él, el presupuesto por sala, el tamaño e importación del arte, el criterio del arte de una zona y, al final, las mediciones en el teléfono que sostienen esas reglas. Cómo medir: `docs/pruebas.md`, «Medición de rendimiento».

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
| `nucleo/niebla.gd` (`class_name Niebla`, `Node2D`) | Quieta | Avanza `velocidad` px/s y vuelve tras `recorrido`, con tiempo propio: quieta en la pausa y en el congelado común. En los dos modos solo se ve con el ajuste `niebla` (apagado por omisión) y lo obedece al momento; una franja con `nucleo/arte/niebla_banda.gdshader` se desvanece arriba y abajo. La pieza es `nucleo/piezas/niebla.tscn`: raíz `Parallax2D` con `repeat_times` 2, hijo `Deriva` con este script y nieto `Banda` con el ruido horneado en `nucleo/arte/niebla_ruido.png` (que escribe `hornear_niebla()` de `herramientas/generar_efectos.gd`, Lossless sin mipmaps; su ancho por la escala debe ser al menos 1760, sin costura). Una sala la instancia y solo toca la raíz: altura con `scroll_offset.y` (el desplazamiento no la pisa, `classes/class_parallax2d.rst:221-223`), tinte y alfa con `modulate`, capa con `z_index`; nada de un `NoiseTexture2D` por sala. Con `repeat_times` 1 se abría un hueco del ancho del avance (`docs/errores/2026-10-27-hueco-niebla.md`). No usa `Parallax2D.autoscroll`: no se detendría con el congelado ni con Recursos bajo |
| `nucleo/luz_sala.gd` (`class_name LuzSala`, `Node2D`) | Solo el halo aditivo chico | El halo y, con el ajuste `luces_avanzadas`, una `PointLight2D` creada en código (al momento, por `ajuste_cambiado`). Tipos `FIJA`, `PARPADEO`, `PULSO` y `DESTELLO` (`destellar()`), con tiempo propio; `intensidad` (0 a 1) es su fuerza máxima; `encendida` (opcional) es la imagen de la pieza encendida, que la sigue. El halo va sin sombreado: la oscuridad de la sala no lo apaga. Su lado es `2 × radio × halo_radio` (`halo_radio`, por omisión `HALO_RADIO` 0,55, se cambia por pieza); `corte_arriba` (px sobre la luz, negativo sin corte) lo recorta con `region_rect` a esa altura, para que la luz de un tubo no se vea en el piso de arriba ni en un nicho tapado. La `PointLight2D` de las luces avanzadas no se corta: se acepta la fuga porque están apagadas por omisión. `LuzSala.caja_halo(radio, halo_radio, corte_arriba)` (estática) y `area_halo()` dan lo que cubre el halo sin correr `_ready`, para contarlo entre las capas translúcidas |
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
  los cuerpos y amarillo las demás áreas. La oscuridad de la sala es `Sala.oscuridad` (ver `docs/contrato.md`, «Sala»).

- Materiales comunes: uno de cada tipo en todo el juego, como recurso compartido (`tutorials/scripting/resources.rst:30-32`;
  las piezas con el mismo material se dibujan juntas, `tutorials/performance/gpu_optimization.rst:44-52`).
  `nucleo/arte/sin_luz.tres` (`CanvasItemMaterial` con `LIGHT_MODE_UNSHADED`: la oscuridad de la sala no lo apaga) y
  `nucleo/arte/aditivo.tres` (mezcla aditiva, sin sombreado: halos, destellos y partículas que suman luz). Desde el
  código se piden con `EfectoCuadros.material_sin_luz()` y `LuzSala.material_aditivo()`, que devuelven la constante
  cargada con `preload` (las constantes `_SIN_LUZ` y `_ADITIVO` son privadas: una sola entrada por material); una
  escena los nombra como `ext_resource` con su uid, nunca como un `sub_resource` propio ni con `Material.new()`.

- Presupuesto por sala (lo revisa el validador en toda escena cuya raíz es una `Sala`; las cifras son las constantes `MAXIMO_EMISORES`, `MAXIMO_PARTICULAS`, `MAXIMO_PLANTAS` y `MAXIMO_CAPAS_TRANSLUCIDAS` de `herramientas/validar.gd`): emisores de partículas y partículas entre todos, plantas, ninguna luz 2D en la escena (las de `LuzSala` se crean en código solo con su ajuste) y un máximo de capas translúcidas grandes: un `Sprite2D`, `TextureRect`, `ColorRect`, `NinePatchRect` o `Polygon2D` visible con alfa efectivo menor que 1 (el de su color en `ColorRect` y `Polygon2D`, por su `self_modulate` y el `modulate` de él y de sus padres; dentro de un `CanvasLayer` oculto no cuenta) que cubre al menos un cuarto de 1280×720 con la escala de sus padres y sus anclas. Los halos de `LuzSala` (sumados, aclaran) cuentan aparte: cada uno cubre `area_halo()` (con `LuzSala.caja_halo()`, sin correr `_ready`) por la escala de sus padres, y el que cubre al menos lo de una capa grande se suma a las capas; si las capas solas pasan el máximo es un fallo, y si lo pasan solo con los halos, un aviso del validador (`docs/contrato.md`, «Avisos del validador»), porque la cuenta es por sala y no por pantalla. Nunca se marca como prescindible un aviso de peligro ni algo cuya colisión importe.
  Excepción: la sala de arte (`herramientas/salas/sala_arte.gd`) arma su decoración en `_ready` y pasa del presupuesto a propósito (hasta 12 emisores y ~500 partículas en alto): es la sala para medir el rendimiento.
- `herramientas/salas/sala_recursos.tscn` llena el presupuesto (2 nieblas, 30 plantas, 3 emisores, 6 cortables;
  prescindibles una niebla, dos emisores y cuatro cortables) para medir los FPS en bajo y en alto.
- Un `Fondo` opaco (con el `FondoExtendido` que crea, ver «Fondo extendido» en `docs/contrato.md`, «Sala») cuesta en el S50 (medición en «Mediciones», más abajo). Una sala cuyo fondo puede ser negro va sin `Fondo`; el núcleo no tiene otra forma de dar un color de fondo. El validador no lo revisa.
- Tamaño del arte: se pinta al tamaño en que se ve en la vista de 1280×720 (1x; el personaje mide 160 px) y no se encoge en la escena. Ninguna imagen pasa de 2048 px por lado.
- Importación del arte del mundo (`contenido/` y `herramientas/salas/arte/`; lo revisa el validador leyendo cada `.import`): Mipmaps > Generate encendido, porque la vista se encoge en las pantallas más chicas (`tutorials/assets_pipeline/importing_images.rst:373-393`). Compresión Lossless por omisión; VRAM Compressed solo en una imagen sin transparencia, como los fondos opacos grandes (`importing_images.rst:185-189`: en 2D deja artefactos). Excepción: `fondo1`, `fondo2`, `lejana1` y `suelo` de la sala de arte, con transparencia, van en VRAM (`ALFA_EN_VRAM` en `herramientas/validar.gd`). El HUD y los menús van sin mipmaps.
- Receta del arte de una sala (La Celda): la imagen entra ya procesada, en `contenido/salas/<zona>/arte/`, en snake_case. Las capas de fondo se exportan reducidas (la capa media a ½, las lejanas a ¼, el profundo a ⅛) y el frente a ½, con la escala compensada en la escena para que midan lo mismo en pantalla: baja la memoria de video y el APK, aunque en el S50 no subió los FPS. Una capa con mucha transparencia va como malla (`Polygon2D` con la textura, solo donde no es transparente, como «Convertir a Polygon2D» del editor), no como `Sprite2D`. La imagen encendida de una luz se recorta a su zona usada. Las capas que una pared opaca tapa van dentro de un `FondoTapado`. Una tira que se repite con `region` lleva unas filas transparentes al pie, o el filtro lineal pinta una línea en su orilla de arriba. Las piezas encendidas y las siluetas del frente van con un material sin sombreado (`LIGHT_MODE_UNSHADED`), para que la oscuridad no las apague.
- Qué limita los FPS de una sala no se supone: lo que se optimiza se mide combinado, y se mide A/B en el teléfono, con y sin la pieza sospechosa (herramienta en `docs/pruebas.md`, «Medición de rendimiento»; cifras en «Mediciones», más abajo). En el mundo no se dibuja con `_draw` lo que se repite: se hornea a PNG (`herramientas/generar_efectos.gd`), y ningún `queue_redraw()` en `_process` va sin una guarda que lo haga solo cuando algo cambió (lo avisa el validador). Una capa lejana con mucha transparencia lleva `Prescindible` y `repeat_times = 1`.
- Filtro por omisión del lienzo: lineal con mipmaps (`rendering/textures/canvas_textures/default_texture_filter` = 2 en `project.godot`).
- Hojas de efectos del núcleo (`nucleo/arte/efecto_*.png`: curar, curar al frente, bola y parry): van sin mipmaps y fuera de `CARPETAS_ARTE_MUNDO` a propósito; son efectos de pantalla, no arte de sala. No se cambia su importación.
- Atlas del jugador: `nucleo/arte/jugador_hombre/atlas_0.png`, una página con los cuadros del hombre a 1x y 8 px entre ellos, Lossless y «Fix Alpha Border» encendido (las hojas de origen llegaron en JPG, `importing_images.rst:423-433`). Cada cuadro es un `AtlasTexture` con `region` justa, `filter_clip` y el lienzo común de 316 × 182 en `margin` (`margin.position` lo coloca; `margin.size` completa el lienzo, así todos miden lo mismo, `classes/class_atlastexture.rst:102`). El `SpriteFrames` (`jugador_hombre.tres`) lo escribe `herramientas/generar_sprites.tscn` con `guardar_con_uids` de `herramientas/validar.gd` (fuera del editor `ResourceSaver` no escribe los uid; ver `docs/contrato.md`, «Sala», uid), tras reimportar el atlas (comando en su cabecera), y conserva los metadatos del anterior que el atlas no trae (`pasos`: por animación, los cuadros en que un pie toca el suelo). La página y el JSON que lee `generar_sprites` salen de un script que vive fuera del repo con las hojas originales, que no entran: desde un clon no se rehace el atlas, y un cambio en las animaciones del jugador pasa por el responsable del arte (decisión del 28-oct-2026). Va sin mipmaps y fuera de `CARPETAS_ARTE_MUNDO`.

## Arte de zona

Criterio para el arte de las salas de una zona (decidido el 27-oct-2026). Lo mecánico (tamaños, importación,
presupuesto, uid, escala no uniforme, imágenes sin uso) lo revisa el validador («Recursos» y `docs/contrato.md`, «Sala»); aquí queda lo
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
  Y − `scroll_scale.y` · T (la regla de desplazamiento de `docs/contrato.md`, «Sala»), así que una silueta del frente se coloca en la Y que la apoya en el piso
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
- Lo que se pisa no se marca con una orilla aparte (`docs/contrato.md`, «Sala», «Suelos y plataformas»): la superficie la dice el dibujo,
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


## Mediciones

Cifras medidas en el Senwa S50 (y en el equipo indicado) que sostienen las reglas de arriba. Al medir de nuevo, se anota aquí o en `docs/pruebas.md`.

- Presupuesto de partículas: se subió el 25-oct-2026 desde 3 emisores y 60 partículas a los actuales; en La Celda, 13 emisores y ~100 partículas costaron menos de 1 FPS en el S50, medido A/B quitándolas.
- `Fondo` opaco (13-oct-2026): dos salas de pruebas bajaban de 60 a ~50 FPS con él (detalle en `docs/pruebas.md`, «Medir antes de optimizar»; no se separó cuánto es de cada rectángulo).
- Mipmaps del arte del mundo (13-oct-2026, sala de arte): 34,1 → 34,3 FPS y el APK +1,8 MB. Excepción de VRAM: decidida el 13-oct-2026.
- Receta del arte de una sala (La Celda, 25-oct-2026): las capas reducidas no subieron los FPS (bajan la memoria de video y el APK); las nueve optimizaciones solas casi no se notaban y juntas llevaron la sala de 19 a 52,6 FPS.
- Medido en bajo (26-oct-2026): las PejeCoins sueltas redibujadas en vector cada cuadro bajaban las salas con PejeCoins de 59,7 a 37-40 FPS; la capa lejana translúcida costaba unos 7-10 FPS donde se veía; ni los draw calls ni el tamaño de las texturas decidían los FPS.
- Hojas de efectos del núcleo (28-oct-2026): suman 8,9 MB de RGBA sin comprimir (cálculo de sus medidas) y los mipmaps agregarían unos 3 MB.
- Atlas del jugador (21-oct-2026; rehecho el 24-oct con el ataque vertical a su escala y la muerte apoyada en el suelo): una página de 2020 × 668 con los 61 cuadros. Medido en el S50 (APK de desarrollo, 60 s por escena tras 5 s): sin mipmaps, 59,6 FPS de media en la sala de recursos, en la zona de pruebas y en la de movimiento (mínimo 58-59), con 146,7, 141,9 y 146,0 MB de PSS; con mipmaps, las mismas medias y mínimos, con 146,9, 141,2 y 147,0 MB, y el APK +0,27 MB. Antes del cambio (18-oct-2026), recursos y zona daban 59,6 con 144,0 y 142,1 MB.
