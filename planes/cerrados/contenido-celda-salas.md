CERRADO (29-oct-2026, con el PR de `feature/contenido-celda`; lo que quedó de «Pendiente de la persona» pasó a `ESTADO.md`. Escrito el 27-oct-2026; aprobado por la persona el 27-oct-2026)

# Contenido: salas 2 a 5 de La Celda sobre una base de zona

Rehace La Celda con las piezas del plan `nucleo-piezas-celda`, que va antes. El trazado de las salas lo probó la
persona en el S50 en una versión anterior: se toma como referencia, no se copia. Además, deja el molde para las zonas
siguientes: una sala se hace heredando la base de su zona e instanciando piezas, y se configura en vez de
reescribirse. Mismo PR que el plan del núcleo (decisión de la persona, 27-oct-2026). Sigue al plan `contenido-celda`
(v2), que hizo `celda_1`: C2 la rehace sobre la base. El estado de ese plan lo decide la persona al cerrar el PR.

## Receta de una sala
1. «Nueva escena heredada» de `contenido/zonas/celda/sala_celda.tscn`. La base lleva solo grupos vacíos (`Juego`,
   `SueloPintado`, `Terreno`, `Peligros`, `Frente`, `Encima`, `Luces`) y los valores de la zona en la raíz
   (`oscuridad`, `tema_musica`; el tinte espera a Las Raíces).
2. Se configura solo lo de la sala: `id`, `limites` desde (0,0), `posicion_mapa`, `Entrada` y las puertas, hijas de
   la raíz, con su `tipo` y su `punto_seguro`.
3. Terreno: `StaticBody2D` sólidos, uno por tramo continuo. La cara de la forma coincide con el borde dibujado.
   Peligros con la forma un poco más chica que el dibujo.
4. Arte con piezas de `contenido/objetos/celda/`. El piso es un `Sprite2D` con `region` y repetición anclada al mundo.
   Escala uniforme y exacta (2, 4 u 8) y posiciones enteras.
5. Frente: un solo `modulate` casi negro en el nodo `Frente` (las mismas piezas teñidas, como Hollow Knight); nada
   opaco del frente por encima del piso + 40 px.
6. Sin sobrantes: sin `.gd` de sala salvo un evento único, sin nodos ocultos ni colisiones apagadas, sin
   `editable children`.
7. Cada `ext_resource` lleva su `uid`, tomado del archivo que ya existe en disco: `*.gd.uid`, `*.gdshader.uid` y
   la línea `uid=` de cada `.import`. Se cuenta con Grep: cero `ext_resource` sin `uid=`. Abrir y guardar en el
   editor es una comprobación extra, no el mecanismo.
8. Antes de darla por pasada: `validar.ps1`, un guion de ruta (más uno por cada fallo real arreglado) y la medición
   en el S50: 60 FPS en bajo.

## Bloques
| # | Qué | Comprobación |
|---|---|---|
| C1 | Base `sala_celda.tscn`; piezas en `contenido/objetos/celda/` (luz de tubo, puertas con arte heredadas de `puerta.tscn`, cables pelados, foso de varillas, `fondo_celda`); materiales compartidos; Lejana como hija `Prescindible` con `repeat_times = 1`; las 8 imágenes opacas grandes como VRAM comprimida (ETC2), los mipmaps se quedan; al repo solo entra el arte que alguna escena usa; «Arte de zona» en `docs/contrato.md` | `validar.ps1`; peso del APK antes y después |
| C2 | `celda_1` rehecha sobre la base, a partir de la del juego: frente teñido, la grieta se lee como peligro, sin costuras en el piso, escalas uniformes | `celda_1` (guion de ruta) y FPS en el S50 |
| C3 | `celda_2` y `celda_5` juntas (comparten el hueco del techo): la lámpara como `plataforma_delgada`, la plataforma y el elevador sólidos; la ruta por arriba de los cables, el elevador; `celda_5` como sala aparte con puerta ARRIBA y ABAJO; corregido el encime de 214 px en el mapa; el letrero SALIDA horneado por script en `marco_salida.png` (lado de la sala 2) | `celda_2_puertas`, `celda_2_cables`, `celda_5_bajar`, `celda_5_aspas`; FPS en el S50 |
| C4 | `celda_3`: la ruta escondida al nicho (caja, estante, lámpara baja y ducto) con el mismo comportamiento que hoy, como `plataforma_delgada`; plafón con `descubre`; el Eterno en `contenido/npc/eterno/`; la cinemática de la Pluma pasa por `Fundido`; sin `FondosTapados` que nunca se ven | `celda_3_puertas`, `celda_3_nicho`, `celda_3_pluma`, `celda_banco` |
| C5 | `celda_4`: colisión del tiro igual a las paredes, la raíz móvil sólida, `ZonaCamara` en la cueva, sin ocultos ni la puerta provisional; el tiro termina sin salida mientras no exista Las Raíces (después, puerta ABAJO) | `celda_4_puertas`, aplastamiento sobre la raíz; FPS en el S50 (nunca medida antes) |
| C6 | `mapa/indice_salas.tres` regenerado; un guion de ruta por sala; `docs/pruebas.md` con la prueba manual de las salas 2 a 5; `docs/uso-de-ia.md`; entradas en `contenido/funciones.json` con `"pasa": false` | suite completa y `revisor` de cierre del PR |

## Pendiente de la persona
- Qué coleccionable es el del nicho: hoy la credencial, con `id` `coleccionable_nicho` (C4), fijo desde el primer APK
  compartido.
- Ver la cinemática de la Pluma: entró en C4 sin su visto bueno.
- Si el parry suena.
- Las espinas de la sala 4 esperan arte nuevo: hasta entonces no entran. C5 las revisó con el arte que hay
  (`raices_espinas`, `raices_espinas_puntas`) y tampoco entran: falta un uso claro (ver «Decidido», C5); se
  retoman con Las Raíces o con un rediseño del tiro.
- Sesión de arte, desde C5: una pieza que tape la junta en y ≈ 720 entre `pared_bajada_*` y `piso_bajada_*` (las
  raíces colgantes la cortan, pero entre ellas se sigue viendo); opcional, un borde de `boquete_raices_b` que cubra
  los ~40 px del azulejo viejo que asoman a su derecha en `celda_4`.
- Desde C6 (no se aplican en la tanda): el radio de daño de las aspas (55, B5-07); el id `coleccionable_pasillo` de
  `celda_5`, fijo desde el primer APK compartido; una máscara única de arte para las bocas de `hueco_techo` y
  `hueco_piso` (B2-07, B5-02); las filas propuestas para `contenido/CLAUDE.md` y cualquier cambio de un `CLAUDE.md` o
  de una skill; si entra un hueco que solo se cruce con impulso en la sala 2 (A10-19); la medición en el S50 de
  `celda_3` y `celda_4` en bajo, que la regla de 60 FPS (D13) pide antes de pasar la sala y que no se hizo porque el
  S50 no estuvo conectado en C4, C5 ni C6; y la prueba manual «La Celda, salas 2 a 5» de `docs/pruebas.md`. Si los
  guiones `celda_*` de regla de la sala (ver «Decidido», C6) se quedan o se reducen a uno de ruta por sala más los
  que tengan archivo en `docs/errores/`: la tanda los dejó todos.
- Cita de la skill `rendimiento-gama-baja` (revisión de C6, A10-20; cambio de skill, lo aplica la persona): en
  `SKILL.md:39`, el presupuesto por sala cita `tutorials/rendering/renderers.rst:184`, que es la fila «Rendering cost»
  de la tabla de renderers. Propuesta: citar ahí `docs/contrato.md`, «Recursos», y dejar `renderers.rst:184` solo en
  la línea 35 («costo base bajo, escala alto»).

## Decidido por la persona tras la tanda (28-oct-2026)
- Radio de daño de las aspas (B5-07): 65, término medio entre 55 (el filo no lastimaba) y ~75 (todo el dibujo): cubre
  el filo salvo la punta. Efecto medido: quieto en su recorrido tras el primer golpe, en `celda_5_aspas` recibía 1 golpe
  a 55 y recibe 3 a 65 (se infiere que a 55 pasaban sobre el jugador de pie sin tocarlo; el guion se reescribió).
  `celda_5_ruta` sigue en verde. Cómo se siente: en la prueba del teléfono.
- Los 24 guiones `celda_*` se quedan (10 de ruta y 14 de regla de la sala).
- Con la recomendación de Claude: las espinas de la sala 4 no entran hasta Las Raíces o un rediseño del tiro (el arte
  queda en la carpeta privada); no hay hueco que solo se cruce con impulso en la sala 2 hasta que exista el impulso
  (A10-19); la boca de hueco única va a la sesión de arte (B2-07, B5-02); las entradas de `funciones.json` anteriores
  a la tanda con el `que` reescrito se quedan así; `transicion-jugador` pierde «recupera el control por un tope si la
  sala no cambia», que ningún caso comprueba (el tope imprime `ERROR:` y haría fallar un guion).
- Prueba en el S50 (28-oct), observaciones de la persona: (1) corte arriba en `celda_2` al saltar junto a los
  lockers: el friso se desvanece en sus últimas filas (y 209-284) sobre nada, porque `FondosTapados` (`fin_pared`
  1800) recorta el fondo detrás de los lockers y la pared empezaba en y 244; arreglado subiendo `Pared` a y 200 con
  44 filas en espejo (`region_rect` y −44), comprobado en captura; (2) bloque negro en el hueco del techo de `celda_2`
  (`Relleno` casi negro de bordes rectos) y en el del piso de `celda_5`: va a la sesión de arte como una boca de
  hueco única para los dos (resuelve B2-07 y B5-02); (3) la grieta de `celda_1` cambió respecto del commit (astillas de
  `grieta_astillas`, luz más baja, frente nuevo). Decisión: vuelve a como estaba en el commit, «la de antes está
  perfecta». Sin `grieta_astillas` (archivo fuera del repo), `LuzGrieta` radio 300 en (3776,5, 619,25) sin
  `intensidad`, `GrietaLuz` sin alfa, esporas del rectángulo del centro, y las siluetas del frente del commit
  (`s_*` y `frente_mesa` restaurados de git, como `Frente*`, escala uniforme). Se quedan las puertas y columnas de C2
  (límites 4482, B1-07). Tras verla en el S50, también `grieta_raices.png` vuelve al del commit: el reprocesado
  de C2 aplanaba las orillas de la grieta; vuelve la costura de tono con el piso a los lados (B1-01), que la persona
  prefiere a perder el dibujo. Esto deshace B1-04 y, en la grieta, B1-01 de C2. Dos ajustes más para igualar la
  captura del commit: el `Suelo` continuo de C2 se asomaba por la abertura de la grieta como una raya: se parte en
  `Suelo` (−200 a 3352) y `Suelo2` (4201 a 4682), como en el commit; y `LuzGrieta` lleva `intensidad` 0,5: la captura
  del commit tenía las luces 2D encendidas (en el commit `luces_avanzadas` venía en `true`; desde N8 viene en
  `false`, D14), y con el halo a 0,5 se ve casi igual (comparado en captura).
- Cambios de `CLAUDE.md` y skill aprobados el 28-oct: `mapa/CLAUDE.md` (encime en la misma zona), `contenido/CLAUDE.md`
  (filas «Base de zona» y «Objeto propio de una zona»), la cita del presupuesto de `rendimiento-gama-baja` y el uid de
  cada `ext_resource` en el `CLAUDE.md` raíz. Aplicados con el texto mostrado.
- Ids `coleccionable_nicho` y `coleccionable_pasillo`: se quedan (nombran el lugar, no el objeto; qué objeto es cada
  uno se cambia sin tocar el id).
- Sesión de arte, con capturas del juego a la vista: (A) la junta y ≈ 720 de `celda_4` se resuelve con arte nuevo, una
  tira de borde irregular que se repite en horizontal (losa rota, varillas y raíces) y reemplaza las 7 `RaicesJunta`
  sueltas; pieza aparte y no pared y piso rehechos, porque se puede volver a usar en otras salas con la misma junta;
  (B) `boquete_raices_b` se regenera en Flow con la pared nueva adjunta; (C) una columna de ~600 px con capitel para
  `celda_3` (B3-04); (D) las sombras de contacto de los muebles (B3-14) no se hacen: se ve bien sin ellas.
- Medición en el S50 (28-oct, APK de desarrollo con los arreglos del cierre, Recursos en bajo, 960×480, V-Sync
  encendido, 2 s de calentar y 5 de muestra): `celda_1` 59,4-59,7 FPS (4 posiciones), `celda_2` 59,4-59,7 (8),
  `celda_3` 59,6-59,7 (6), `celda_4` 59,6-59,7 (9), `celda_5` 59,7 (2); peor cuadro 20,8-32,3 ms; 22-46 draw calls;
  29,4-45,5 MB de texturas (`celda_4` la mayor). Cumple la regla de 60 FPS (D13) en las cinco. Una corrida anterior dio
  56,2 FPS (cuadro de 65 ms) en `celda_4` (2080, 720) y no se repitió en la segunda (59,6, 25,8 ms): sin causa con
  dos muestras. Con V-Sync no se ve el margen sobre 60.
- Arte de cierre integrado (28-oct; cuatro piezas de Flow, todas a ×1 salvo la orilla del piso):
  - `junta_tira` (770 × 130, en repetición) reemplaza las 7 `RaicesJunta` de `celda_4`: `JuntaIzquierda` (x 0-1665)
    y `JuntaDerecha` (2275-2720), con el borde de arriba en y 690 (la raya de la losa cae en la fila ≈30, dentro del
    concreto) y `self_modulate` 0,75: medida en captura, la tira salía ~30 % más clara que el pie de la losa.
  - `boquete_raices_c` (mismo lienzo y agujero) reemplaza la textura de `boquete_raices_b.tscn`; la colisión no cambia.
  - `columna_capitel` (194 × 700, fuste en x 17-177) en `celda_2` y `celda_3`, con el fuste en el mismo x que la
    columna vieja. El capitel va 4 px detrás de la cara de abajo de la losa **entre vigas**, que es la fila 74 de
    `techo.png` (no la 112, que es el pie de las vigas: así quedaba volando, observación de la persona en el S50):
    y 70 en `celda_2` y 456 en `celda_3`. En `celda_2` las columnas pasan antes del `Techo`, como en `celda_3`, para
    que las vigas queden al frente. `ColumnaRota` y las salas 1, 4 y 5 siguen con `columna.png`.
  - `orilla_hueco` (110 × 180) en los dos huecos y en el plafón. Reemplaza los bordes pintados de `techo_hueco`
    (fuera del juego) y los de `pasillo_piso` (recortado en x 1450 y 1712); la persona la vio en el S50 y pidió lo mismo
    en el plafón. El lado de la losa se funde a transparente en 30 px (script de la carpeta de arte) para que no se vea
    su borde recto. Techo de `celda_2`: `flip_v`, `modulate` 0,78 (medido: la orilla quedaba al 80 % del techo de los
    dos lados), techo liso hasta x 3750 y desde 4136, el degradado `TiroHueco` en repetición de 410 px (sin escala
    no uniforme, que el validador avisa) y sin `Relleno` (quedaba debajo del degradado). Piso de `celda_5`: ×1,4 (el
    piso mide ~158 de grueso y la losa de la pieza 113). Plafón de `celda_3`: `OrillaPlafonIzquierda` y
    `OrillaPlafonDerecha` en `descubre` del `Plafon`, así que solo aparecen roto, como `BordePlafon`.
- Prueba en el S50 del arte de cierre (28-oct), observaciones de la persona: el boquete y la junta, bien; (1) columnas
  volando: arreglado arriba; (2) bajo el hueco de `celda_5` el negro se cortaba recto en el pie de la pared: la pared
  baja hasta el límite (`region_rect` de 706 en espejo) y `BajoPiso`, el degradado del tiro volteado a lo ancho de la
  sala, la apaga bajo el piso; sin `Relleno`; (3) el nicho de `celda_3` se cortaba pronto a negro: `nicho.png` pasa a
  1440 px (x 1460-2900) con la pared en mosaico y fundido a negro en 320 px hacia afuera (antes 90 hacia adentro),
  y la `Tapa` se ensancha igual. Comprobado en captura de la PC; falta verlo en el S50.
- Tercera prueba en el S50 (28-oct), observaciones de la persona: el degradado de `celda_5` y las columnas, bien;
  (1) por el hueco del techo de `celda_2` se veía la orilla de arriba del `Friso` en seco: `TiroHueco` baja 40 px
  (y −50) y su parte opaca la tapa; (2) por el hueco del plafón de `celda_3` la pared de azulejo se cortaba en la cara
  de la losa: `nicho.png` (1440 × 446) sigue la pared 60 px por debajo de la cara solo en las columnas del hueco y la
  apaga a negro, y las orillas del plafón van después del `Nicho` en el árbol. La manera de resolverlo queda en
  `docs/contrato.md`, «Arte de zona», viñetas «Huecos y roturas» y «Lo que se ve por un hueco». Comprobado en captura
  de la PC; la persona lo confirmó en el S50 el 28-oct.

## Decidido en la tanda
- C1: la base no lleva `tinte`: `Sala` no lo tiene y el tinte de zona espera a Las Raíces (BZ-11); lleva `oscuridad`
  0,58 y `tema_musica` = `SILENCIO`. **Desviación de la arquitectura objetivo** (fila `Sala` y «Tinte de zona → raíz
  de la base» de la tabla de bloques), que el cierre de la tanda reporta: agregar el `@export` a `Sala` y hacer que
  `Brillo` lo multiplique es un cambio de núcleo con `revisor`, y con La Celda sola (las cinco salas a 0,58, sin
  escalón de color decidido) no hay valor que darle. Suma `SueloPintado` (z −5) a los grupos de la receta: las piezas de piso
  pintado de las cinco salas van ahí.
- C1: `Frente` de la base lleva el `modulate` casi negro y `sin_luz.tres`; cada hijo que se le cuelgue pone
  `use_parent_material = true` (si no, el material no le llega, `classes/class_canvasitem.rst:757`).
- C1: el marcador de `nucleo/puerta.tscn` deja de ser un `ColorRect` hijo y lo dibuja `Puerta._draw` con
  `dibujar_provisional`: así una puerta heredada con arte lo apaga sin abrir los hijos ni ocultar nodos (A1-06).
  Toca el núcleo: falta la pasada del `revisor` (contrato de `Puerta`), que esta sesión no pudo lanzar.
- C1: lo mismo en `nucleo/banco.tscn`: fuera el `ColorRect` `Dibujo`, y `Banco._draw` pinta el provisional de
  120 × 40 (el tamaño del `ColorRect`, no el de la forma). En `celda_1` la silla (`banco.png`) pasa de `Juego` a hija
  de la instancia `Banco` (z −20, misma posición en el mundo), y se quitan el `visible = false` y el
  `[editable path="Banco"]`: la regla «una sala nunca abre los hijos de una pieza» ya se cumple en `celda_1`, y la
  sala 3 (C4) cuelga su silla igual. `ObjetoHabilidad` no cambia en C1: extiende `Recogible`, no `Interactuable`
  (no tiene `dibujar_provisional`), y ninguna escena de `contenido/` lo instancia; su `ColorRect` queda hasta que un
  objeto con arte lo necesite (los jefes).
- C1: los fondos son tres piezas cuya raíz es la capa (`fondo_profundo`, `fondo_lejana`, `fondo_medio`) más los
  trozos `lejana_0` y `lejana_1`, en vez de un `fondo_celda` único: cada sala cuelga sus trozos de la raíz de la
  pieza (lo propio de cada sala, sin editable children) y la sala 5, que no tiene fondo, no la instancia. El
  `FondoTapado` sigue siendo de cada sala, porque `fin_pared` es de cada una.
- C1: profundo a escala uniforme 11,25 (2880 × 720, `repeat_size` 2880) y no ×8: la imagen mide 256 × 64 y a ×8 no
  cubre los 720 px de alto; la ×8 exacta espera una reexportación a 360 × 90. Lejana a ×4 exacta (antes 3,9956):
  `repeat_size` 3648.
- C1: cero imágenes en VRAM en este bloque: las 7 paredes opacas grandes son de las salas 3 a 5 y entran con su
  sala (C3-C5), tras la captura en el S50 que pide el contrato; el profundo se queda Lossless (a ×11 se verían los
  bloques). Las 8 piezas que entraron tienen alfa: Lossless con mipmaps.
- C1: lado del letrero SALIDA de la puerta 2↔3: se aplica la respuesta por omisión del plan de la tanda. `puerta_salida`
  (con la luz verde) va del lado de la sala 2: se sale de los salones hacia la 3; `puerta_salida_b` (sin letrero ni
  luz) va del lado de la sala 3. El letrero no va como `Label`: se hornea por script en `marco_salida.png` (hoy en
  blanco) como tarea de C3, que es el bloque que coloca esa puerta en `celda_2`.
- C1: la forma de los cables pelados es 260 × 40 sobre el piso (la forma anterior, 540 × 50, cubría la losa entera): sigue al dibujo de los cables. C3 mide con su guion que el salto por arriba sigue igual de justo.
- C1: el aviso de los cables entre chispas es una `LuzSala` cálida en `PULSO` (radio 130) dentro de la pieza, sin
  emisor de más; los cables no se suben 20 px porque descuadra la losa del dibujo.
- C1 (cierre) · Para C2, con la primera sala que use `luz_tubo`: fijar `z_index` absoluto en su raíz `LuzSala`, como
  `cables_pelados` y `puerta_salida`, para que el halo no dependa del grupo donde cuelgue; y recortar `tubo_encendido`
  a la franja encendida (C-09 b). Guardar el profundo en RGB (C-09 f) va con su reexportación a 360 × 90.
- C1 (cierre) · El `revisor` sobre `nucleo/puerta.*` y `nucleo/banco.*` (el marcador pasó de `ColorRect` a `_draw`) lo
  lanza la sesión principal antes del PR.
- C2: la puerta 1↔2 (`puerta_salon`, tipo `PUERTA`, en x 4300) lleva a sí misma (`celda_1`/`derecha`) mientras no
  exista `celda_2`: una puerta a una sala que no existe hace fallar el validador y el `Fundido`. Precedente:
  `sala_puerta_c`. C3 cambia `sala_destino` a `celda_2`/`izquierda` y el `.esperado` de `celda_1_puertas`.
- C2: límites de 4838 a 4482 y las paredes invisibles con la cara en la cara de una columna dibujada (x 130 y 4420,
  columnas nuevas `ColumnaPuerta` en 4060 y 4420): la sala ya no termina a mitad de una columna (B1-07).
- C2: fuera del repo `borde_desnivel`, `frente_mesa` y las cinco `s_*` (con su `.import`): ninguna escena del juego
  los usa tras rehacer el frente; las salas 2 a 5 (C3 a C5) usarán las mismas piezas teñidas.
- C2: el frente usa solo piezas de contorno irregular (escombros y pila de exámenes rota) a ×3 exacta, en y 630-640:
  la cubeta y la caja a ×3 se leían como bloques negros, como fosos falsos. Las posiciones evitan, con el factor 1,45,
  quedar en pantalla sobre el foso de varillas o la grieta.
- C2: las chispas del primer plano van en un `Parallax2D` propio (`FrenteChispas`, z 21) y no dentro de `Frente`:
  el `modulate` casi negro de `Frente` las apagaría.
- C2: `grieta_astillas.png` (176×91, sin reprocesar) en `SueloPintado` en (3690, 588), centrada en la boca de la
  grieta; con 40 px más arriba tapaba el hongo encendido de la izquierda, con 52 no tapa ninguno. Queda debajo de
  `GrietaLuz` por grupo (z −5 contra z 11), así que el orden en el árbol no importa.
- C2: `LuzGrieta` baja a radio 220 (antes 300) e intensidad 0,55, y las esporas salen de 10 puntos en las orillas
  (`EMISSION_SHAPE_POINTS`) y no del centro: el centro de la grieta ya no brilla como un premio (B1-04).
- C2: `hueco_varillas.png` y `grieta_raices.png` reprocesados: en cada orilla se iguala la luminancia por fila a la
  del suelo de afuera (se apaga en 300 px) y se funden con alfa los últimos 36 px. Costuras medidas de 70,7→34,5 y
  36,9→44,5 niveles a menos de 1,2 (B1-01). El suelo es un solo `Sprite2D` continuo con la repetición anclada al
  mundo.
- C2: `tubo_encendido.png` recortado a la franja encendida (187×15) y `luz_tubo` con `z_index` 13 absoluto en su raíz
  (lo que C1 dejó para C2).
- C2: B1-05 no aplica: `celda_1` tiene un solo pizarrón. B1-09 (sombras de contacto y manchas en la pared) queda
  diferido: suma capas translúcidas sobre el piso y no está medido en el S50.
- C2 (corrección): `GrietaLuz` lleva `self_modulate` con alfa 0,65. `intensidad` de `LuzSala` baja el halo y la
  `PointLight2D`, pero a la imagen `encendida` le escribe `modulate.a = fuerza` sin ella (`nucleo/luz_sala.gd:174-178`);
  `self_modulate` no lo pisa la luz y se multiplica con su `modulate` (`classes/class_canvasitem.rst:645`, `:679`). El
  sprite turquesa queda en 0,39-0,59 de alfa en el pulso (antes 0,6-0,9) (B1-04).
- C2 (corrección): el polvo de los tubos es la pieza `contenido/objetos/celda/polvo_tubo.tscn` (raíz `CPUParticles2D`,
  z 12 absoluto, con su degradado dentro), cuatro instancias en `Encima` que solo cambian la posición; antes eran
  cuatro nodos con los mismos 14 literales. Va aparte y no como hija de `luz_tubo`: el botón «Luces» del panel de
  pruebas oculta los `LuzSala` y con ellos se apagaría también el polvo, que cuenta como «Partículas».
- C2 (corrección): `Escombros2` (Juego, z −19) termina en x 4202, antes del marco de `puerta_salon` en 4226, y la
  franja que pisa ya la tapa `ColumnaPuerta` (4060-4220, también z −19): el marco y la hoja quedan limpios (B1-06).
- C2: la niebla es la pieza `nucleo/piezas/niebla.tscn` con `scroll_offset` (0, 300), que es un desplazamiento que
  el `Parallax2D` no pisa; cambiar su posición sí se sobrescribe (`classes/class_parallax2d.rst:24`, `:221`).
- C2: los degradados repetidos de las partículas se unifican en un `sub_resource` cada uno; las piezas m_ del fondo
  medio van a ×2 exacta en posiciones enteras (B1-08).
- C2: el banco sigue en la sala 1 con `banco_celda_1` (X-03): moverlo a la sala 3 cambiaría un id guardado.
- C2 (cierre) · Pendientes no graves de la revisión, para C6: la viñeta «Frente» del contrato dice «ningún píxel opaco
  sobre piso + 40 px», pero los colgantes del frente (cadena y cable) bajan desde arriba: acotar la regla a lo que se
  apoya en el piso; el porqué de quitar `borde_desnivel` (era del suelo pintado, no del frente); medir la unión de la
  repetición de `suelo.png` (1366 px) bajo los fosos; juntar en piezas los emisores repetidos (`Papeles1/2`, chispas);
  renombrar `SEscombros*` y `SPilaExamenesRota` sin la «S» de las siluetas borradas.
- C2 (cierre) · `hueco_varillas.png` y `grieta_raices.png` se reprocesaron por script para quitar la costura con el
  suelo (B1-01, recomendación aprobada); no son piezas nuevas de la entrega. El script vive en la carpeta de arte.
- C3: `celda_2` conserva las x de la sala de la copia de pruebas y baja 214 px (límites (0, 0, 4320, 934), techo en 0,
  piso en 774); `celda_5` se corre (−2350, +734) y empieza en (0, 0): la vista ya no deja 26 px de negro arriba (B5-06).
  `Entrada` de `celda_2` en (260, 774), como la de la copia, para que los tiempos de sus guiones sigan valiendo.
- C3: mapa. Con `celda_5` encima de `celda_2` en la posición de antes, `celda_5` caía en la franja de la zona de pruebas
  (el validador la encimaba con `mapa_1` y `prueba_4`): La Celda baja entera, `celda_1` (0, 2374), `celda_2`
  (4482, 2160), `celda_5` (6832, 1440); la franja sigue empezando en y 1440 («Sala», `posicion_mapa`, del contrato).
  Sin encime entre `celda_2` y `celda_5` (se tocan por un borde) ni con `celda_1`.
- C3: la forma de los cables pelados pasa de 260 × 40 (C1) a 380 × 40, lo que miden los cables opacos del dibujo
  (columnas 64-467). Centrada en x 3213: entre la columna rota (2952) y los cables (3023) quedan 71 px y el cuerpo mide
  80, así que por el piso no se cruza y la ruta obligada es la de arriba; lo prueba `celda_2_cables_suelo` (B2-03).
  (Reemplazada el 28-oct: 350 × 40, ver la corrección de `cables_pelados.png` más abajo.)
- C3: los huecos son piezas de zona heredadas de `nucleo/puerta.tscn` con su tipo y su forma: `hueco_techo` (`ARRIBA`,
  366 × 50, la boca dibujada en `techo_hueco`, x 3760-4126) y `hueco_piso` (`ABAJO`, 238 × 40, el hueco de
  `pasillo_piso`, x 1469-1707). Llevan un `Marker2D` `Boca` solo para que `Interactuable.sin_arte()` dé falso y no se
  dibuje el rectángulo provisional en el juego (un `Marker2D` solo se ve como cruz en el editor,
  `classes/class_marker2d.rst:22`): el contrato prohíbe abrir los hijos de una pieza y cambiar `Puerta` es
  del núcleo, fuera de C3. Cada sala sigue su dibujo; las dos bocas no coinciden (B2-07, B5-02): queda para una máscara
  única de arte.
- C3: `celda_5` lleva el coleccionable del núcleo (`nucleo/coleccionable.tscn`, el dibujo de la credencial) con id
  `coleccionable_pasillo`; `credencial.png` de la copia no entra (un solo coleccionable, decisión del 27-oct). El id
  queda fijo desde el primer APK compartido: lo confirma la persona.
- C3: PejeCoins sueltas con la pieza `nucleo/monedas_sueltas.tscn`: `monedas` sobre la columna rota de `celda_2` y
  `monedas_repisa` en la repisa de `celda_5` tras el hueco, que así tiene razón de ser (B5-11, opción b).
- C3: frente de `celda_2` y `celda_5` con una sola escala por capa, ×2, para piso y colgantes (B2-04); `celda_1` sigue con
  la mezcla ×3/×2 de C2. En `celda_2` (más alta que la pantalla) `Frente` lleva `scroll_scale` (1,45, 1,45) como pide el
  contrato: las siluetas del piso (y 940-950) se ven con la cámara abajo y los colgantes (y 4) con la cámara arriba; es
  a propósito, para que nada tape la ruta de arriba. Las x se calcularon para que ninguna quede en pantalla sobre los
  fosos, los cables, el hueco ni las puertas.
- C3: fondos de `celda_2` con `scroll_scale.y` igual a la x y `scroll_offset` y 11, 39 y 107 (profundo, lejana, medio),
  niebla (1,1, 1,1) con 535: con la cámara abajo se ven igual que en la sala 1. Medio teñido (0,75, 0,8, 0,9) y lejana
  (0,65, 0,7, 0,8) para que el fondo no compita con la subida (B2-09); lejana con `repeat_size` 3840 y dos trozos
  nuevos (`lejana_computo_a`, `lejana_computo_b`).
- C3: paredes de un solo `Sprite2D` con `TEXTURE_REPEAT_MIRROR` (`classes/class_canvasitem.rst:403-405`): los lockers
  (B2-08) y la pared del pasillo (B5-04), que además se reprocesó por script (sin el fantasma de las columnas 0-80 y con
  el degradado de abajo levantado, B5-01). Columnas a ×1 sin estirar (B2-05); columna en cada extremo de `celda_5` con
  la pared invisible en su cara (B5-05).
- C3: la subida es un `StaticBody2D` con cuatro escalones y la columna rota, cada cara medida en el alfa de
  `escombros_alto` y de la columna (cara 524, B2-06); la caja junto a la SALIDA es un escalón de 86 × 51.
- C3: pizarrón del salto largo en (1190, 314), sobre los lockers entre columnas (B2-10); pupitre de perfil sin girar
  (B2-11). Puerta 1↔2 con `puerta_salon` a los dos lados (B2-12); `puerta_salida` del lado de la sala 2 con el letrero
  horneado y a sí misma hasta que exista `celda_3` (C4 la cambia).
- C3: aspas como pieza (`aspas.tscn`: `Vaiven` → `Giro` → dibujo y `DanoContacto` sin peligro), 20 px más arriba (eje
  en y 459) con un riel recortado de la pared del pasillo; el radio de daño se queda en 55: subirlo lo decide la
  persona (B5-07). Elevador de `celda_5` con las cadenas desde la polea (`polea_elevador.png` tal cual, luz normal),
  detrás del techo (B5-09).
- C3: no hay un hueco que solo se cruce con impulso en `celda_2` ni en `celda_5` (A10-19): queda para la persona si
  entra. El HUD sobre la franja clara (B5-10) es de `interfaz/`: no entra en C3.
- C3: entradas `sala-celda-2-ruta` y `sala-celda-5-ruta` en `contenido/funciones.json`, como hizo C2 con
  `sala-celda-1-ruta`, con `"pasa": true` por sus guiones.
- C3: C-06 y C2-03 (30-40 FPS de la sala 2 en la copia de pruebas): la sala rehecha va a 59,5-59,8 FPS en el S50 en
  bajo en las 8 posiciones, con 34-47 draw calls y ~850 primitivas (la copia tenía 12 800); no hace falta el A/B.
- C3 (corrección, 28-oct) · `suelo.png` sin la muesca de alfa del canto (columnas ~1316-1358): con la repetición
  anclada caía en el mundo cada 1366 px en `celda_1` y `celda_2` (B2-02). Se rellena con el canto de una baldosa antes
  (108 px, el paso de las juntas); la costura de la repetición queda igual (5,0 niveles). Recortar los últimos 46 px no
  sirve: esa costura subía a 11-12 niveles. Por script, en la carpeta de arte.
- C3 (corrección, 28-oct) · `cables_pelados.png` sin las rampas de losa semitransparente de los lados (el canto lo pone
  el `Suelo`) y con los cables de arriba más opacos (B2-03): lo visible queda en las columnas 83-449 (x 3030-3396). La
  forma pasa de 380 × 40 a 350 × 40 (x 3038-3388), 8 px dentro del dibujo por lado, como pide la receta («peligros
  con la forma un poco más chica que el dibujo»); reemplaza la de 380, que tras el recorte daba daño 7 px fuera del
  dibujo. La ruta sigue obligada por arriba: entre la columna y la forma quedan 86 px (el cuerpo cabe de pie), así
  que la obligación descansa en el alcance del salto. Desde el piso, sin la carrera (habilidad `impulso`), el salto
  recorre unos 315 px (cálculo con `altura_salto` 230, gravedad 2400 y 360 px/s; no medido) y hacen falta 430. Desde la
  orilla de la columna rota, medido con el guion nuevo `celda_2_cables_salto` (con la plataforma lejos): cae en los
  cables; con la plataforma cerca, el mismo salto cae en ella (sigue siendo la ruta de arriba, sin la lámpara).
  `celda_2_cables_suelo` y `celda_2_cables` pasan. Con la carrera (756 px/s) los cables se saltarían (cálculo, no
  medido): es una habilidad posterior.
- C3 (corrección, 28-oct) · `Polea` de `celda_5` en y 72 (antes 75): el PNG trae 3 px de margen transparente, así que
  su borde opaco queda pegado a la cara de abajo del techo (fila 74 de `techo.png` en x 1560-1640); las ruedas quedan
  en y ≈136 y las cadenas empiezan en 138.
- C3 (corrección, 28-oct) · El `ColorRect` detrás del hueco de `celda_5` se llama `Relleno` y no `Fondo`: `Sala`
  extiende un nodo `Fondo` a `limites` + 280 px (`nucleo/sala.gd`, `_extender_fondo`), y este solo tapa el hueco
  (x 1400-1800, y 540-720) bajo la pared opaca; un fondo de sala entero sería sobredibujo a pantalla completa (B5,
  hallazgo nuevo 2).
- C3 (corrección, 28-oct) · `escombros_alto.png` se queda: es el dibujo aprobado de la subida (el mismo PNG de las
  salas de arte), no la pieza nueva que la entrega de arte descartó. Lo único que esa pieza nueva arreglaba, la losa bajo
  `Escalon2`, se resolvió bajando el escalón: cara en 612, contra 601-627 del alfa del dibujo (mediana ≈610).
- C3 (revisión, 28-oct) · Los cables no se estiran hasta la orilla del foso (x 3474): entre 3396 y 3474 queda piso
  sin cables, a propósito; achicar la forma bastó para quitar el daño invisible. Cuando entre la habilidad `impulso`,
  un guion mide si los cables se saltan desde el piso con la carrera, y entonces se decide si se alargan el arte y la
  forma.
- C4 · El banco de La Celda se queda en `celda_1` (C2, `banco_celda_1`): la región del tema del menú (`MusicaBanco`,
  `RegionMusica` de 1100 × 400 sobre el banco) va ahí, y `celda_3` no lleva banco ni `banco.png` (sería un banco
  falso). X-03 no aplica: ninguna sala guardada pierde su banco en este cambio.
- C4 · Puertas de `celda_3`: izquierda `puerta_salida_b` (LADO, sin letrero: el SALIDA va horneado del lado de la
  sala 2, A7-05) hacia `celda_2`/`derecha`; derecha `boquete_raices` (LADO) a sí misma hasta que C5 haga `celda_4`,
  como las salas 2 y 5 antes de existir la siguiente. `celda_2`/`derecha` ya lleva a `celda_3`/`izquierda`
  (`celda_2_derecha.esperado` cambió a propósito: llega a `celda_3` x 344). La entrada `sala-celda-2-ruta` de
  `contenido/funciones.json` no se reescribió en C4; se reescribió en C5 (ver «Decidido», C5).
- C4 · Entrega de la Pluma: `celda_3.gd` es el único evento propio de la sala (receta). Al oír
  `Npc.conversacion_terminada` con etapa 1 pide `Fundido.cambiar_sala` a la cinemática, perfil `PUERTA`, con un
  retraso de 72 ticks (lo que dura `entregar`: 2 cuadros a 1,67/s) y el jugador, para que una muerte en el oscurecido
  gane. La cinemática vuelve a la `Entrada` (x 1340), junto al Eterno. Durante el retraso el jugador se puede mover;
  las puertas están a más de 1100 px. Medido con `celda_3_pluma`: cinemática en el cuadro 185, de vuelta antes del 215.
- C4 · El Eterno es `contenido/npc/eterno/eterno.tscn` (hereda `nucleo/npc.tscn`, `AnimatedSprite2D` con
  `eterno_cuadros.tres`, ancla en los pies (47, 194)), con `eterno_celda.tres` (5 líneas y la habilidad `pluma`). La
  tira estaba aprobada (21 y 25-oct); la cinemática de la Pluma no tiene aún el visto bueno de la persona: entra, y
  verla queda pendiente para el cierre.
- C4 · Cortables de la sala (raíces y dos pilas) como piezas propias (`contenido/objetos/celda/raices_cortables.tscn`,
  `pila_cortable.tscn`, raíz `Area2D` con `cortable.gd`): heredar `nucleo/cortable.tscn` no deja cambiar sus
  `Polygon2D` por `Sprite2D`, y el script toma `Entero`/`Cortado` por nombre.
- C4 · Ruta escondida: caja (86), estante (220), lámpara baja (300) y ducto (80) son instancias de
  `plataforma_delgada` con el comportamiento de hoy (decisión del 27-oct). A5-02 pedía caja y estante sólidos: manda la
  decisión de la persona; queda anotado que contradice el «cuelga o delgada» del contrato para muebles apoyados.
  Sin marca de lo que se pisa (B3-11, decisión del 27-oct).
- C4 · Plafón (B3-05, opción de escena): el techo sigue por los dos lados y solo queda un hueco de 170 px (x 2110-2280);
  el `Dibujo` del `MuroRompible` es la franja central de `plafon_entero.png` (region x 140, 170 px), así el resto del
  techo conserva su franja oxidada. `solo_desde` ABAJO, `tapas` = `Tapa`, `descubre` = `Ducto` y `BordePlafon`.
  Captura en ventana (1280 × 720, cerrado y roto): la grieta se lee, sin rectángulo; el `PlafonRoto` asoma solo en el
  hueco.
- C4 · Nicho (B3-10, BZ-12): `nicho.png` rehecho por script fuera del repo con la pared nueva (filas 130-470 a 0,5,
  techo a 0,55), sin muebles pintados y sin la luz cálida horneada: la única fuente cálida es el halo del coleccionable.
  Orillas por desvanecido a negro (sin tiras de columna: el contrato lo permite). Muebles como `Sprite2D` del kit
  oscurecidos (`self_modulate` 0,6): caja de archivo y pila; el estante no cabe en los 200 px a la derecha del hueco.
  El coleccionable es la instancia `coleccionable_nicho` de `nucleo/coleccionable.tscn`, en el piso libre (x 2030),
  dentro de `Juego` antes de la `Tapa`: en la captura con el plafón cerrado no se ve ni el halo.
- C4 · Azulejo (B3-01, B3-07): `pared_azulejo.png` (770 × 550, módulo 38,5) y `friso_azulejo.png` (770 × 168) nuevos,
  sin procesar, en lugar de los de 788; `pared_azulejo_b` no entra. La pared va en y 532 para que el rodapié (filas
  540-549) toque el piso. Las uniones con `marco_salida_b` y `boquete_raices` se vieron en captura y no chocan;
  `boquete_raices_b` no está en esta sala (se revisa en C5, en `celda_4`). Se quedan Lossless: la VRAM se decide con
  captura en el S50 (no estaba conectado).
- C4 · B3-03 y B3-12: el friso va desfasado medio periodo (region x 385); las piezas del kit (tablero, grieta alta,
  pupitre, cubeta, escombros) reparten el tercio izquierdo y caen sobre las repeticiones de la pared. Un solo pizarrón
  (el del aviso de atacar), como `Sprite2D` de `Juego` en (2150, 850) y último hijo (encima de la pared y la caja,
  como antes con z -20), y el `AvisoAtacar` con `pizarron = false`: así no pinta su caja gris (`aviso_accion.gd`,
  `_draw`) y el arte no cuelga de un nodo de lógica, que le heredaría la transformación
  (`class_canvasitem.rst:24`). `celda_2` sigue con el pizarrón hijo del aviso: se corrige en su bloque si se toca.
- C4 · B3-04: columnas a ×1 en y 550 (como las salas 1 y 4), detrás del techo en el árbol; entre el techo y el capitel
  quedan unos 50 px de friso. Una columna de ~600 px con capitel queda para la sesión de arte.
- C4 · B3-06: `pila_examenes.png` limpia de halo por script (fuera del repo, amarillos 650 → 74); `banco.png` no: su
  contorno es casi todo el dibujo y sus patas se borraban. B3-13 no aplica a `celda_3` (sin banco).
- C4 · B3-08 y B3-09: el tubo 3 pasa a x 2480, sobre el estante (la luz marca la subida, no la columna); los tubos no
  bajan (B3-11). Frente con el `modulate` casi negro de la base, solo escombros y pilas rotas ×2 con la base fuera de
  cuadro, sin lámparas colgantes. B3-14 (sombras de contacto): diferido, sin medir en el S50.
- C4 · Para C6 (revisión de cobertura, no grave): `TICKS_ENTREGA = 72` en `celda_3.gd` repite a mano la duración de
  la animación `entregar` de `eterno_cuadros.tres` (2 cuadros a 1,67 FPS); si cambia la tira, el fundido deja de
  coincidir y ningún guion lo detecta. Leerla de los `SpriteFrames` o que el guion compruebe el cuadro del fundido.
  También para C6: validador de `FondoTapado` con `fin_pared >= limites` (verificadores 3 y 7 de C4).

- C5 · La cueva no entra (B4-02, B4-14, BZ-07 y el corte en y = 1450 de B4-03): la persona decidió que la sala termina en el tiro y
  que caer por el boquete es la puerta a Las Raíces (las piezas de la cueva van con Las Raíces). Por eso `limites`
  mide 2720 × 1440 (donde acaba el arte: sin negro abajo ni el corte en y = 1450), sin pared del tiro de la cueva,
  sin suelo de cueva, sin hongos sueltos ni puerta provisional. La `ZonaCamara` que pedía el bloque para la cueva va
  en el pasillo de arriba (vista 0-720 mientras se camina sobre la masa izquierda, como las salas 1 a 3); al caer al
  tiro la cámara vuelve a los límites de la sala. Es una desviación del texto del bloque, por esa decisión.
- C5 · Puerta ABAJO: la pieza `hueco_piso` (la de `celda_5`, 238 px) en el boquete del piso (hueco 1927-2112), 26 px
  sobre el borde como en `celda_5`; lo que sobra a los lados queda dentro del piso sólido. Mientras no exista Las
  Raíces lleva a `celda_3`/`derecha` (el boquete hacia la sala 4): el jugador reaparece junto a la entrada de la sala
  que acaba de dejar y puede volver a bajar; la llegada provisional de antes caía en y −720, fuera de `limites`.
- C5 · Raíz móvil (A4-10): `AnimatableBody2D` con `Vaiven` como el elevador (recorrido 520 hacia arriba, 200 ticks
  de ida, 60 de espera), forma de 210 × 20. Baja hasta 100 px del piso de abajo, que mide 200 de grueso (regla N3).
  Medido: el jugador quieto bajo su orilla se hunde hasta 34 px en el piso y sale a un lado (x 1810), sin daño; no
  queda encima. Lo cubre `celda_4_raiz`.
- C5 · Espinas: no entran. En la pared izquierda del tiro una caída normal no las toca (adorno que se lee como
  peligro); bajo la cornisa de las PejeCoins castigarían la bajada natural; en una columna, a los dos lados, se leen
  sueltas. Ningún uso cumple «claro y visible» sin cambiar la ruta.
- C5 · B4-06: `self_modulate` (0,55; 0,58; 0,68) en `ParedBajadaB` (la pared detrás de la raíz) basta: en la
  captura la raíz se separa de la pared por su musgo y su tono. La pieza 12 (`raiz_movil` redibujada) no hace falta.
- C5 · Junta en y ≈ 720 (piezas 16-17): los escombros ×2 se veían claros y pegados; se cambiaron por 7 raíces
  colgantes (`frente_raices`, `frente_raices_b` a ×1, algunas volteadas) a lo largo de la junta. La línea se sigue
  viendo entre ellas: va como pieza para la sesión de arte («Pendiente de la persona»).
- C5 · Azulejo: la unión de `boquete_raices_b` con `pared_bajada_a` queda casi toda tapada por las raíces del
  boquete; a su derecha asoma una franja de ~40 px del azulejo viejo (pieza opcional para la sesión de arte).
  `pared_azulejo_b` no está en ninguna escena.
- C5 · B4-04, B4-08, B4-09, B4-10, A5-08, BZ-13: sin `FondosTapados`, sin disquete ni calculadora, sin la grieta alta
  y sin ocultos. B4-05: el frente lleva el tinte de la base y las siluetas (escombros y pilas rotas ×2) apoyadas en el
  corredor (y 630) y en la repisa de abajo (y 1674; con `scroll_scale` 1,45, y en pantalla = Y − 1,45 · T). B4-12:
  `Frente` con `scroll_scale` (1,45; 1,45), como las salas altas. B4-13: el boquete del piso es arte nuevo
  (`boquete_piso.png`), con dos `LuzSala` de pulso turquesa sobre sus hongos (excepción ya en `docs/contrato.md`).
- C5 · B4-11 y C-05: las paredes y pisos nuevos se quedan Lossless con mipmaps, como en C4: pasarlos a VRAM pide la
  captura en el S50, que no estaba conectado. B4-15: sin cambio.
- C5 · `puertas-tipo` (`nucleo/funciones.json`) pasa. Ya había una `ABAJO` cruzada en una sala real desde C3
  (`celda_5_bajar`, el hueco del piso de `celda_5` hacia `celda_2`) y una `ARRIBA` (`celda_2_subir`); lo que faltaba es
  que la `comprobacion` los nombrara: solo citaba `cambio_de_sala` (`LADO`) y `puerta_accion` (`PUERTA`). Se le suman
  `celda_2_subir`, `celda_5_bajar` y `celda_4_tiro` (corrección de la revisión de C5; el plan maestro de la tanda
  autoriza editar entradas con su porqué).
- C5 · B4-01 (colisión del tiro): cajas que siguen el borde dibujado, medido con alfa > 128 en los PNG.
  `MasaIzquierda`: `Masa` (x 0-1665, y 560-1480), `Saliente` (x 1665-1715, y 600-1010) y `PisoTiro` (x 1665-1927,
  piso en 1280); el dibujo va de x 1696-1740 entre y 600-1000 y de 1648-1689 entre y 1010-1280, y la orilla baja de 561
  a ~600 entre x 1660 y 1700 (de ahí el escalón de 40 px del `Saliente`). `MasaDerecha`: `Arriba` (x 2275-2720,
  y 560-1000; la cornisa), `Abajo` (x 2315-2720, y 1000-1480) y `PisoTiro` (x 2112-2315, piso en 1280); el dibujo va de
  2242-2313 entre y 560-950 y de 2309-2327 entre y 1000-1280. Se quedan las cajas con escalón y no el borde único
  (`MasaBajoElPiso` hasta ≈1760 y `OrillaDerecha` desde ≈2370) porque el arte aprobado tiene el escalón: el borde único
  dejaba de 25 a 50 px entre lo dibujado y la colisión y pedía repintar los riscos, que la decisión del 27-oct deja
  fuera. Los solapes de antes no se pasaron: no hay `SueloAbajo`, `SueloAbajoB` ni una `ParedDerecha` dentro de la masa
  (la `ParedDerecha` empieza en x 2720, donde acaba `MasaDerecha`). El alero (50 px a la izquierda en y 1010, 40 a la
  derecha en y 1000) no atora: saltando pegado a la pared bajo él, la cabeza pega y el jugador vuelve al piso (los
  pies no pasan de y 1172 y 1162; sin el alero llegarían a 1050). Lo cubren dos guiones nuevos, `celda_4_subir`
  (caída pegada a la pared izquierda, salto bajo el alero, raíz y salto al pasillo) y `celda_4_cornisa` (raíz, salto a
  la cornisa con las 10 PejeCoins, caída pegada a la pared derecha y salto bajo su alero sin caer por el boquete).
  Medido de paso: bajo el alero izquierdo el salto pega antes de pasar la cara de la raíz (y 1180), así que para
  montarla hay que apartarse de la pared unos 50 px; y el escalón de 40 px del `Saliente` deja un hueco en la orilla del
  pasillo del que se sale saltando (sigue el dibujo).
- C5 · `sala-celda-3-ruta` (`contenido/funciones.json`) se reescribe: el boquete de la sala 3 lleva a la puerta
  izquierda de `celda_4` (`LADO`, ida y vuelta), ya no «a sí misma hasta que exista celda_4». El plan maestro de la
  tanda autoriza reescribir entradas con su porqué; con la regla vieja quedaba falsa. Con la misma autorización se
  reescribe `sala-celda-2-ruta` (su SALIDA lleva a `celda_3`/`izquierda` desde C4, ida y vuelta), aunque no estaba en
  las revisiones de C5: el «a sí misma hasta que exista celda_3» ya era falso. Y `sala-celda-4-ruta` suma a su «que»
  la subida con la raíz al pasillo o a la cornisa y los aleros, para que diga lo que comprueban `celda_4_subir` y
  `celda_4_cornisa`.
- C5 · Lo que N4 y N5 dejaron para la sala 4 (`nucleo-piezas-celda`, «Decidido»):
  - `ABAJO` de ida sola contra la regla de ida y vuelta: ya lo resolvió N9 (la regla se queda para todas menos `ABAJO`,
    a la que basta que la sala de destino tenga la puerta de llegada). En la sala 4 el `ABAJO` lleva a `celda_3`/`derecha`, que es un `LADO` de vuelta
    a `celda_4`/`izquierda`: sin cambio, el validador lo acepta.
  - Zona tocada en los ticks 20 a 29 del «al instante»: no ocurre en la sala 4. La única llegada es la puerta izquierda
    (x 134, pies en y 560), dentro de la forma de `ZonaCamaraPasillo` (x 0-1665, y 0-560), que se toca al colocar al
    jugador; la sala no tiene banco, peligros ni otra llegada. Sin cambio (por la geometría; no se vio en pantalla).
  - Bajada gradual de Hollow Knight y la excepción de entrar por el borde de la escena: sin cambio. Al caer al tiro se
    sale de la zona con el seguimiento lento de N5 (0,5 s en y); la bajada gradual depende de los FPS y no se copia, y
    ninguna entrada de la sala 4 llega por un borde a una zona. Cómo se ve la caída al tiro en el teléfono es de
    `sala-celda-4-telefono`.
- C5 · B4-12 en el contrato: «Arte de zona» dice ahora que en las salas con desplazamiento vertical cada capa lleva
  `scroll_scale.y` igual a su x (frente 1,45; niebla 1,1) y cómo se coloca una pieza del frente (Y − `scroll_scale.y`
  · T), con `classes/class_parallax2d.rst:22`. La excepción de las espinas turquesa queda en condicional («cuando
  entren»).
- C5 · B4-12, colgantes del frente (revisión de cobertura): `FrenteRaicesColgante`, `FrenteCableColgante` y
  `FrenteRaicesBColgante` se quedan en y −10. En el pasillo la cámara no baja (`ZonaCamaraPasillo`, T = 0), así que
  cuelgan del techo como en las salas 2 y 3; al caer al tiro, el frente sube 1,45 veces más rápido que el techo y
  salen de cuadro por arriba. Cuánto se nota ese despegue durante la caída no se vio en pantalla: se mira en
  `sala-celda-4-telefono`, y si se nota, se sacan del frente.
- C5 · `celda_4_tiro.esperado` (revisión de cobertura): la x final en `celda_3` pasa de 2800 ± 120 a 2796 ± 8, la
  medida en la corrida del 28-oct, para que una llegada mal colocada de la puerta `ABAJO` haga fallar el guion.

- C6 · Guion de ruta por sala (A9-04, A10-22, opción A): ya había uno que cruza cada puerta en las salas 1 a 4 —
  sala 1 `celda_1_puertas`; sala 2 `celda_2_puertas` (1↔2), `celda_2_subir` (ARRIBA) y `celda_2_derecha` (SALIDA);
  sala 3 `celda_3_puertas`; sala 4 `celda_4_puertas` y `celda_4_tiro` (ABAJO)—. En la sala 5 la única puerta la
  cruzan `celda_2_subir` (llegada) y `celda_5_bajar` (salida), pero ningún guion llegaba a sus premios: se escribe
  `celda_5_ruta` (repisa con las PejeCoins y, saltando foso y aspas, el coleccionable), que empieza en la propia sala y
  no repite prefijos. Los demás guiones de La Celda se quedan porque cada uno cubre una regla de la sala (ver la
  línea siguiente). El salto de las aspas de `celda_5_ruta` se midió con una traza temporal por cuadro (fuera
  del repo): pasa con unos 30 px de margen a cada lado si se salta con las aspas ya volviendo a la derecha; con ellas
  quietas a la izquierda el margen baja a cero. Depende de la fase del `Vaiven` de las aspas, que empieza al cargar
  la sala (240 ticks por vuelta: 20 de espera, 100 de ida, 20 y 100 de vuelta), como las rutas de la sala 2 (A9-04):
  cambiar `ticks_ida`, `ticks_espera` o la `Entrada` de `celda_5` obliga a remedirlo.
- C6 · Los 24 guiones `celda_*`, por tipo (revisión de C6). **De ruta** (cruzan cada puerta o llegan a cada premio):
  `celda_1_puertas`, `celda_2_puertas`, `celda_2_subir`, `celda_2_derecha`, `celda_3_puertas`, `celda_3_nicho`
  (coleccionable del nicho), `celda_4_puertas`, `celda_4_tiro`, `celda_5_bajar` y `celda_5_ruta`. **De regla de la
  sala:** `celda_salto` (los dos fosos de la sala 1 con el salto normal, sin habilidades), `celda_hueco` y
  `celda_grieta` (el peligro devuelve al último suelo firme, no a la Entrada), `celda_banco` (guarda la sala por su id
  y suena el tema del menú), `celda_2_cables` (tras los cables reaparece en la lámpara, el último suelo firme que no se
  mueve), `celda_2_cables_salto` y `celda_2_cables_suelo` (los cables solo se cruzan por arriba), `celda_2_lampara_bajar`
  (de la ruta de arriba se vuelve), `celda_3_pluma` (entrega y cinemática de la Pluma), `celda_3_nicho_bajar` (el nicho
  no encierra), `celda_4_raiz` (la raíz aplasta sin daño), `celda_4_subir` y `celda_4_cornisa` (paredes del tiro y
  aleros sin atorarse) y `celda_5_aspas` (las aspas golpean con retroceso, no son peligro). Ninguno tiene archivo en
  `docs/errores/`: los fallos que algunos vigilan (cables, aleros, raíz) eran de la copia de pruebas o de versiones de
  esta rama sin commit, corregidas en las revisiones de la tanda, y no de un código del juego publicado; los fallos del
  núcleo que tocan estas rutas (`2026-10-26-punto-seguro-sobre-plataforma`, `2026-10-26-plataforma-hija-de-vaiven`) ya
  tienen su guion del núcleo. Reducirlos a solo los de ruta (lectura estricta de A9-04, opción A) queda para la persona
  («Pendiente de la persona»).
- C6 · `mapa/indice_salas.tres` regenerado con `generar_mapa` (`MAPA salas=11 error=0`); C6 no mueve salas ni límites, y los
  rectángulos de La Celda son los de C5.
  Los once rectángulos se comprobaron por par: ninguno se encima; `celda_1`-`celda_2`, `celda_2`-`celda_3`,
  `celda_2`-`celda_5`, `celda_3`-`celda_4` y `celda_3`-`celda_5` solo se tocan por un borde.
- C6 · `TICKS_ENTREGA` de `celda_3.gd` sale ahora de los `SpriteFrames` del Eterno: suma de las duraciones relativas
  de `entregar` / (fps de la animación · `speed_scale`) · ticks por segundo (`classes/class_spriteframes.rst:252-256`,
  `classes/class_animatedsprite2d.rst:305`), leída en `_ready`. Da 72, como antes: `celda_3_pluma` sigue en verde con
  la cinemática en el cuadro 185 (si la tira cambia, el fundido la sigue y el guion falla si se mueve el cuadro).
- C6 · Validador de `FondoTapado` con `fin_pared >= limites` (verificadores 3 y 7 de C4): ya lo cubría
  `validador-fondo-tapado` (N9): `herramientas/validar.gd`, `_revisar_fondos_tapados`, falla con `fin >=
  limites.end.x`, y `prueba_validador.gd`, `_probar_fondo_tapado`, prueba el borde exacto (1280), más allá (3000) y
  dentro (900). Sin cambio.
- C6 · `celda_2`: el pizarrón del salto largo deja de ser hijo de `AvisoSaltoLargo` y pasa a `Sprite2D` de `Juego`
  (último hijo, en (1190, 314), z −20 por el grupo, igual que antes), con `pizarron = false` en el aviso, como
  `celda_3` en C4.
- C6 · Frente (pendiente de C2): la viñeta de «Arte de zona» del contrato se acota: lo que se apoya en el piso no
  asoma más de 40 px; lo que cuelga baja desde arriba de la vista y no llega a la cabeza del jugador. Medido: los
  colgantes (cadena, cable, raíces ×2) acaban entre y 330 y 344, y la cabeza del jugador sobre el piso más alto que
  recorren (y 554-560) queda en y 394-400.
- C6 · `borde_desnivel` (pendiente de C2): salió del repo en C2 porque era una pieza de suelo pintado («suelo roto
  hacia abajo», se apoya) que la `celda_1` anterior ponía en `SueloPintado` en x 4250, donde acababa su piso; C2 llevó
  ese extremo a la puerta 1↔2 (x 4300) con su columna y los límites a 4482, así que el desnivel dejó de existir en el
  trazado y ninguna escena la nombra. No era del frente.
- C6 · Costura de la repetición de `suelo.png` (pendiente de C2): con la repetición anclada al mundo cae en x 0, 1366,
  2732 y 4098 en las salas 1 a 3. En 1366 la tapa el foso de varillas en las salas 1 (1242-2093) y 2 (1078-1929);
  en 2732 y 4098 queda en piso a la vista. Medida en el PNG (filas opacas): 2,2 niveles de luminancia media entre la
  última columna y la primera, contra 1,6 entre columnas vecinas: no se distingue del grano de la textura. Es otra
  medida que la de C3 (5,0 niveles): aquí, la media de |ΔL| entre la última y la primera columna; la diferencia de
  cifras no quiere decir que la costura cambiara. Sin cambio.
- C6 · Emisores repetidos (pendiente de C2): no se juntan. `Papeles1` y `Papeles2` los lee `celda_1.gd` por nombre y
  cada uno guarda su ráfaga; uno solo que salte de pila en pila cortaría con `restart()` la ráfaga anterior (dura 1,6 s
  y las pilas están a 177 px, unos 0,7 s corriendo): cambia lo que se ve. Como pieza seguirían siendo dos nodos.
  `Chispas` (con `destello` a una luz de la sala) y `ChispasFrente` (en su propio `Parallax2D`) tienen otro padre y
  otro uso. No baja ningún nodo.
- C6 · `SEscombros*` y `SPilaExamenesRota*` se renombran `FrenteEscombros*` y `FrentePilaExamenesRota*` en las cinco
  salas, como los demás hijos de `Frente` (`FrenteCadena`, `FrenteCable`); ningún script, guion ni documento los
  nombraba por ruta.
- C6 · `profundo.png` (pendiente de C1): reexportado por script (`procesar_celda_c6.py`, en la carpeta de arte, con
  su fila en el README) a 360 × 90 y en RGB, desde el mismo original que el de 256 × 64 (LANCZOS; el control da 0,08
  niveles de diferencia media al reducirlo a 256 × 64). `fondo_profundo.tscn` pasa de ×11,25 a ×8 exacta (2880 × 720,
  `repeat_size` igual) y se quita la excepción del contrato.
- C6 · `sala-celda-1` (`contenido/funciones.json`) no es falsa: el banco se quedó en `celda_1` (C2, C4) y la cuenta
  de partículas sigue (13 emisores, 100 partículas). Queda como está.
- C6 · Entradas nuevas `sala-celda-2-telefono` y `sala-celda-5-telefono` (`"pasa": false`); las de teléfono de las
  salas 3 y 4 y `recogibles-telefono` (`nucleo/funciones.json`) apuntan a la fila nueva «La Celda, salas 2 a 5» de
  `docs/pruebas.md`. `sala-celda-5-ruta` suma los premios y `celda_5_ruta`, y sigue en `true` (guion en verde).
  Es una reescritura de `comprobacion` (y del `que` de `sala-celda-5-ruta`), no solo marcar `"pasa"`: se hizo porque
  las cinco entradas se crearon en esta misma tanda y no están en ningún commit (`git show HEAD:` no las tiene), así
  que no se pierde nada aprobado; el motivo fue que apunten a la fila manual que sí existe y que la ruta de la sala 5
  nombre los premios que ya cubre `celda_5_ruta`.
- C6 · A10-08 (piezas del núcleo sin guion propio): lo cubrieron N2 a N6 (`nucleo/zona_camara`,
  `nucleo/monedas_sueltas`, `nucleo/puerta_accion`, `nucleo/muro_rompible`, `nucleo/peligro_movil`, entre otros).
  A10-20 (60 FPS en el S50): `celda_1`, `celda_2` y `celda_5` medidas a 59,5-59,8 en bajo; `celda_3` y `celda_4` sin
  medir en el S50 (no conectado): sin regla de FPS menor, queda para la persona.
- C6 · `docs/uso-de-ia.md`: la fila «Imágenes» ya nombra Google Flow (Nano Banana Pro) para las piezas de escenario
  de La Celda, recortadas, escaladas y ajustadas de tono por un script hecho con Claude Code, sin nombres de archivo
  ni carpeta de origen (la ruta que da es la de destino en el repo). Sin cambio.

## Tras la prueba con jugadores nuevos (28-oct-2026)
Decidido por la persona: el primer salto obligatorio es el foso de varillas de `celda_1`, así que el pizarrón del salto
(con «Mantén para llegar más lejos») pasa de `celda_2` a `celda_1`, junto al foso, y `celda_2` se queda sin pizarrón.
Varios jugadores no supieron cruzar la puerta 1↔2 (tipo `PUERTA`): antes de ella va un pizarrón que enseña
`interactuar` («Entrar»). Como ahí no hay pared, es una pieza nueva, `contenido/objetos/celda/pizarron_patas.tscn`,
con patas para ponerla en cualquier piso; mientras no tenga arte aprobado dibuja la caja gris de `AvisoAccion`. El
arte entra antes del PR.
- Hecho el 28-oct: `AvisoSaltoLargo` en `celda_1` (x 1180) con el pizarrón de pared movido a x 1250, delante del foso
  de x 1571; `celda_2` sin pizarrón ni aviso; `AvisoEntrar` (pieza `pizarron_patas`, x 4020) con su arte de Google
  Flow, 320 × 250 px, sin croma y con la pizarra a 166 px del piso (`punto`); su arte va en z −19, delante de la pared
  de la puerta (z −20), que en la primera prueba en el S50 tapaba la mitad derecha. `validar.ps1` `archivos=358 fallos=0`;
  suite `RESUMEN total=193 OK=193 MALOS=0` (antes del arte) y, con el arte, `celda_1_puertas`, `celda_hueco`,
  `celda_salto`, `celda_grieta`, `celda_2_puertas`, `nucleo/aviso_accion` y `herramientas/validador` 7/7. APK de
  Desarrollo instalado en el S50 y el S20. Sin ver en pantalla: posición y tamaño los aprueba la persona en el teléfono.
- Los obstáculos de `celda_2` se leían como fondo (un jugador en el S50): la columna rota era el pie de `columna.png`,
  la columna de la pared, y el montón no se separaba de los escombros de la capa media. Decidido por la persona:
  arte jugable nuevo para los dos (regla nueva en `docs/contrato.md`, «Arte de zona»). `columna_rota.png` (257 × 291)
  y `escombros_repisas.png` (462 × 259), de Google Flow en vista plana, con base de escombros, en z −4 absoluto
  (delante del canto del suelo, z −5) y hundidos 10 px. La columna va al ancho exacto de su forma (160) y su alto se
  ajusta a 250 (Flow la hizo más alta: queda al 0,89 de su proporción); sin `Escombros3` encima. Los escalones de la
  subida pasan a los saltos del dibujo (x 2354, 2423, 2481, 2573 y 2670; alturas sin cambio, el dibujo queda a 2 px
  o menos), así que los cinco guiones que suben por ellos sueltan `mover_derecha` en el cuadro 426 y no en el 436;
  ningún `.esperado` cambió. `validar.ps1` `archivos=358 fallos=0` con un aviso (`escombros_alto.png` sin uso: se
  borra desde el editor); suite `RESUMEN total=193 OK=193 MALOS=0`. APK de Desarrollo en el S50.

## Hecho
| Bloque | Resultado | Evidencia |
|---|---|---|
| C1 | Base `contenido/zonas/celda/sala_celda.tscn`; 14 piezas en `contenido/objetos/celda/` (luz de tubo, 6 puertas con arte heredadas de `puerta.tscn`, cables pelados, foso de varillas, 3 capas de fondo y 2 trozos de lejana); 8 imágenes de puertas y cables (Lossless con mipmaps, ninguna en VRAM: ver «Decidido»); marcador de `Puerta` dibujado; «Arte de zona» y «Sala» en `docs/contrato.md` | 27-oct: `validar.ps1` `archivos=333 fallos=0` (23 avisos, todos de `celda_1`); `correr-guiones.ps1` `RESUMEN total=173 OK=173 MALOS=0`; APK de desarrollo 102 520 782 → 103 402 685 bytes (+0,84 MiB). Corrección del 27-oct (marcador de `Banco` dibujado, silla de `celda_1` como hija, `boquete_raices_b` heredado, contrato y «Decidido»): `validar.ps1` `archivos=333 fallos=0` (23 avisos, los mismos); guiones `celda_*`, `cinematica_celda`, `herramientas/validador`, `nucleo/banco*` 8/8; suite `RESUMEN total=173 OK=173 MALOS=0` |
| C2 | `celda_1` heredada de `sala_celda.tscn` (id, `banco_celda_1` y guiones de antes intactos): piezas de `contenido/objetos/celda/`, niebla de `nucleo/piezas/`, frente teñido solo con piezas irregulares ×3, suelo continuo y fosos igualados, grieta con astillas cálidas y luz más baja, puerta 1↔2 tipo `PUERTA`, paredes en las caras de las columnas, límites 4482; `luz_tubo` con z 13 absoluto y tubo recortado; 7 imágenes sin uso fuera; `mapa/indice_salas.tres` regenerado; guion `celda_1_puertas` | 27-oct: `validar.ps1` `archivos=333 fallos=0`, cero avisos (antes 23 de `celda_1`); `celda_1_puertas`, `celda_banco`, `celda_grieta`, `celda_hueco`, `celda_salto`, `cinematica_celda`, `herramientas/validador` en verde; suite `RESUMEN total=174 OK=174 MALOS=0`. S50 en bajo (APK de medición, 960×480): 59,7 FPS en x 640, 1707, 2775 y 3842, peor cuadro 25-30 ms, 38-44 draw calls, 32,5 MB de texturas. El S20 no estaba conectado. Corrección del 27-oct (`GrietaLuz` con `self_modulate` 0,65, pieza `polvo_tubo`, B1-05 y B1-06 reescritos): `validar.ps1` `archivos=334 fallos=0`; los 7 guiones del bloque 7/7; suite `RESUMEN total=174 OK=174 MALOS=0` |
| C3 | `celda_2` y `celda_5` nuevas, heredadas de `sala_celda.tscn`: lámpara `lampara_plataforma` (hereda `plataforma_delgada`), plataforma y elevador sólidos (`Vaiven`), ruta obligada por arriba de los cables (forma 350 × 40 tras la corrección del 28-oct), huecos `hueco_techo`/`hueco_piso` (ARRIBA/ABAJO), aspas y foso del pasillo como piezas, PejeCoins con `monedas_sueltas`, coleccionable del núcleo; 21 imágenes de La Celda y `polea_elevador.png`; `marco_salida.png` con SALIDA horneado y `pasillo_pared.png` limpio por script; `celda_1` → `celda_2`/`izquierda`; La Celda bajada en el mapa (sin encimes) e índice regenerado; 8 guiones nuevos y `celda_1_puertas` cambiado | 27-oct: `validar.ps1` `archivos=343 fallos=0`, `AVISOS total=0`; suite `RESUMEN total=182 OK=182 MALOS=0` (antes 174; `celda_1_puertas.esperado` cambió a propósito: llega a `celda_2` x 300). S50 en bajo: `celda_2` 59,5-59,8 FPS en 8 posiciones, `celda_5` 59,6-59,7, `celda_1` 59,7. S20 en alto: 60,1-60,2 con luces 2D en «No»; con «Sí», `celda_2` baja a 49,1-55,9 en x 2667-3680 (registro y D14 en `nucleo-piezas-celda`, «Medición»). APK de desarrollo instalado y abierto en los dos teléfonos. Corrección del 28-oct (`suelo.png` sin la muesca, `cables_pelados.png` recortado y su forma a 350 × 40, polea pegada al techo, `Relleno` de `celda_5`, guion nuevo `celda_2_cables_salto`): `validar.ps1` `archivos=343 fallos=0`, `AVISOS total=0`; los 10 guiones de C3 y `celda_1_puertas` en verde; suite `RESUMEN total=183 OK=183 MALOS=0`. La medición en el S50 y el S20 y el APK de los teléfonos son anteriores a esta corrección; tras el apagón `adb devices` no ve ningún teléfono, así que no se remidió. Que no cambie los FPS es inferencia: no cambian tamaños de textura ni número de nodos. Más tarde apareció solo el S20: se le instaló el APK de desarrollo nuevo, pero el APK de medición no llegó a correr (la actividad de otra app quedó al frente, la pantalla en negro y sin una línea de Godot en `logcat`); se desinstaló y el juego no quedó abierto |
| C4 | `celda_3` nueva, heredada de `sala_celda.tscn`, con `celda_3.gd` (entrega de la Pluma por `Fundido`); el Eterno en `contenido/npc/eterno/` (escena, `SpriteFrames` y ficha de diálogo); `cinematica_eterno_pluma` con su `.mp4`/`.ogv`; ruta escondida con 4 `plataforma_delgada`, plafón `MuroRompible` (abajo, `tapas`/`descubre`), nicho rehecho sin muebles pintados y coleccionable `coleccionable_nicho`; raíces y pilas cortables como piezas; azulejo nuevo de 770 (pared y friso); `pila_examenes.png` sin halo; `celda_2`/`derecha` → `celda_3`; `MusicaBanco` (tema del menú) en el banco de `celda_1`; índice del mapa regenerado; 4 guiones nuevos (`celda_3_puertas`, `celda_3_pluma`, `celda_3_nicho`, `celda_3_nicho_bajar`), `celda_2_derecha` y `celda_banco` cambiados | 28-oct: `validar.ps1` `archivos=351 fallos=0`, cero avisos; suite `RESUMEN total=187 OK=187 MALOS=0` (antes 183; `celda_2_derecha.esperado` cambió a propósito: llega a `celda_3` x 344; `celda_banco.esperado` suma `MusicaBanco dentro`). Capturas en ventana 1280×720 (fuera del repo): piso, puertas, plafón cerrado y roto, nicho. S20 en alto: 60,0-60,3 FPS con luces 2D en «No» y en «Sí» (registro en `nucleo-piezas-celda`, «Medición»). El S50 no estaba conectado: `celda_3` en bajo sin medir. APK de desarrollo instalado y abierto en el S20; el de medición, desinstalado. Corrección del 28-oct (pizarrón como `Sprite2D` de `Juego` y `AvisoAtacar` con `pizarron = false`; comentarios de `celda_3_puertas` y `docs/pruebas.md` sin aludir a `celda_4`; `ext_resource` `38_ficha` al final): `validar.ps1` `archivos=351 fallos=0`, `AVISOS total=0`; `celda_3_*`, `celda_banco`, `celda_2_derecha`, `celda_2_cables_salto`, `celda_1_puertas`, `herramientas/validador` 9/9; suite `RESUMEN total=187 OK=187 MALOS=0`. Documentación de Godot del bloque: `region_rect` con `texture_repeat` (`class_sprite2d.rst:287`, `class_canvasitem.rst:732`), `filter_clip` (`class_atlastexture.rst:85`), `z_index` (`class_canvasitem.rst:863`), herencia de transformación (`class_canvasitem.rst:24`). El pizarrón movido no se vio en captura |
| C5 | `celda_4` nueva, heredada de `sala_celda.tscn` (2720 × 1440, sin cueva): masas de colisión iguales a las paredes pintadas (`pared_bajada_a/b/c`, `piso_bajada_izq/der`, `suelo_raices`), raíz móvil sólida (`AnimatableBody2D` con `Vaiven`), `ZonaCamara` del pasillo, boquete de raíces (`LADO`, ida y vuelta con `celda_3`/`derecha`) y boquete del piso (`hueco_piso`, `ABAJO`, a `celda_3`/`derecha` mientras no exista Las Raíces); `ParedBajadaB` oscurecida tras la raíz; 7 raíces colgantes en la junta; 10 imágenes nuevas de La Celda (con su `.import`, Lossless con mipmaps); sin espinas, ocultos, `FondosTapados` ni puerta provisional; `celda_3`/`derecha` → `celda_4`; índice del mapa regenerado (pegada a la derecha de `celda_3`, sin encimes); 3 guiones nuevos, `celda_3_puertas` cambiado; entradas `sala-celda-4-ruta` (pasa) y `sala-celda-4-telefono`; `puertas-tipo` pasa | 28-oct: `validar.ps1` `archivos=352 fallos=0`, `AVISOS total=0`; `celda_4_puertas`, `celda_4_tiro`, `celda_4_raiz` y `celda_3_puertas` en verde; suite `RESUMEN total=190 OK=190 MALOS=0` (antes 187; `celda_3_puertas.esperado` cambió a propósito: el boquete lleva a `celda_4`, x 368, y 560). `celda_4_tiro` cruza la puerta `ABAJO` en una sala real: evidencia de `puertas-tipo`. Trazas por cuadro (fuera del repo): la raíz aplasta al jugador hasta 34 px dentro del piso y lo saca a x 1810 sin daño. Capturas en ventana 1280×720 (fuera del repo): pared del tiro con `self_modulate`, junta con raíces, unión del boquete con el azulejo. S20 en alto: 60,0-60,3 FPS con luces 2D en «No» y en «Sí» (registro en `nucleo-piezas-celda`, «Medición»). El S50 no estaba conectado: `celda_4` en bajo sigue sin medir. APK de desarrollo instalado y abierto en el S20 (menú al frente); el de medición, desinstalado. Documentación de Godot: `AnimatableBody2D` (`class_animatablebody2d.rst:22`), `self_modulate` (`class_canvasitem.rst:679`), `scroll_scale` de `Parallax2D` (`class_parallax2d.rst:22`), límites de `Camera2D` (`class_camera2d.rst:504`). Corrección del 28-oct (revisión de C5): guiones nuevos `celda_4_subir` y `celda_4_cornisa` (subida por la raíz al pasillo y a la cornisa, caída pegada a cada pared y salto bajo cada alero sin atorarse); `puertas-tipo` nombra los guiones de `ARRIBA`/`ABAJO`; `sala-celda-3-ruta` reescrita; IDs de «Decidido» corregidos y línea propia de B4-01; N4/N5 cerrados para la sala 4; `scroll_scale.y` de las salas verticales en el contrato: `validar.ps1 -SinImportar` `archivos=352 fallos=0`; `celda_4_*` (5), `celda_3_*` (4), `celda_2_derecha`, `celda_2_subir`, `celda_5_bajar`, `herramientas/validador` y `mapa/mapa_cuentas` `RESUMEN total=14 OK=14 MALOS=0`; suite `RESUMEN total=192 OK=192 MALOS=0` (antes 190) |
| C6 | Índice del mapa regenerado y comprobado sin encimes; guion nuevo `celda_5_ruta` (los dos premios de la sala 5), con lo que cada sala de La Celda tiene su ruta; fila manual «La Celda, salas 2 a 5» en `docs/pruebas.md` y la de `celda_5_ruta`; `sala-celda-2-telefono` y `sala-celda-5-telefono` nuevas (`false`), las de teléfono de las salas 3 y 4 y `recogibles-telefono` apuntan a la fila nueva, `sala-celda-5-ruta` ampliada; `celda_3.gd` lee la duración de `entregar` de los `SpriteFrames`; pizarrón de `celda_2` como `Sprite2D` de `Juego` con `pizarron = false`; `FrenteEscombros*`/`FrentePilaExamenesRota*` en las cinco salas; `profundo.png` a 360 × 90 RGB y ×8 exacta; contrato: viñeta «Frente» acotada y sin la excepción del profundo; pendientes de C1-C5 resueltos o anotados en «Decidido» (validador de `FondoTapado`, costura del suelo, emisores, `borde_desnivel`, `uso-de-ia.md`) | 28-oct: `validar.ps1` `OK  VALIDACION archivos=352 fallos=0`; `celda_*` (24), `cinematica_celda`, `herramientas/validador` y `mapa/mapa_cuentas` `RESUMEN total=27 OK=27 MALOS=0`; suite `RESUMEN total=193 OK=193 MALOS=0` (antes 192: suma `celda_5_ruta`; ningún `.esperado` cambió). `generar_mapa`: `MAPA salas=11 error=0`, once rectángulos sin encime por par. APK de desarrollo (114 147 544 bytes) instalado en el Galaxy S20 y el juego abierto en él; el S50 no estaba conectado (`adb devices` solo ve el S20): `celda_3` y `celda_4` siguen sin medir en bajo y no se armó APK de medición. Documentación de Godot: `classes/class_spriteframes.rst:252-256` (duración absoluta de un cuadro), `classes/class_animatedsprite2d.rst:305` (`speed_scale`). El `revisor` de cierre del PR lo lanza la sesión principal. Corrección del 28-oct (revisión de C6, solo documentos: viñeta «Compresión» del contrato en ×8, `ESTADO.md` al cierre, guiones `celda_*` por tipo y entradas reescritas en «Decidido»): `validar.ps1 -SinImportar` `archivos=352 fallos=0`; `celda_*` (24), `cinematica_celda`, `herramientas/validador` y `mapa/mapa_cuentas` `RESUMEN total=27 OK=27 MALOS=0`; suite `RESUMEN total=193 OK=193 MALOS=0` |
