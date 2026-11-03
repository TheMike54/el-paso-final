# Sala

Parte del contrato (`docs/contrato.md`): la forma de una sala, el cambio de sala, la llegada, la cámara y los bancos. Se lee al crear contenido y también al tocar la reaparición, la carga de una ranura, las transiciones o el viaje rápido. Lo que un `.tscn` escrito a mano debe cumplir (uid) y los avisos del validador están en `docs/validador.md`.

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
| Propiedad `posicion_mapa` (`Vector2`) | Esquina de la sala en px desde `ficha_zona.origen_mapa` (sin ficha, desde `(0, 0)`). Las salas de una zona se acomodan como se recorren. Todas las zonas comparten el plano y el mapa muestra la subida del juego: La Celda baja una vez a Las Raíces, el punto más bajo, y cada zona nueva va más arriba que la anterior, con su origen elegido a mano (`docs/guias/armar-una-sala.md`). El validador falla si dos salas se enciman en el mapa, de zonas distintas o de la misma (tocarse por un borde no cuenta, `classes/class_rect2.rst:470`). Se escribe a mano y no se deriva de las puertas: cada escena se ubica sola (`tutorials/best_practices/scene_organization.rst:37`). Cambiarla obliga a regenerar el índice del mapa |
| Propiedad `ficha_zona` (`FichaZona`, exportada) | Recurso compartido, puesto una vez en la base de la zona: `nucleo/ficha_zona.gd` (`Resource`) con `nombre` visible, `color` de relleno en el mapa alejado y `origen_mapa`, esquina de la zona en el mundo. El índice copia el nombre y el color y suma el origen a las posiciones de sus salas. La Celda usa `contenido/zonas/celda/zona_celda.tres`, con origen `(0, 0)`. Una sala con id en `contenido/` necesita ficha; dos salas de una misma zona no pueden usar fichas con distinto `resource_path`. Las salas de prueba pueden dejarla vacía |
| Propiedad `botones_por_ensenar` (`Array[StringName]`) | Acciones cuyo botón de la pantalla no se ve en esta sala hasta que un `AvisoAccion` lo enseña (la sala Pizarrones empieza sin saltar, atacar ni curar; pausa y mapa se ven siempre). El validador exige que cada una sea un botón de la pantalla (`ControlesTactiles.ACCIONES`) y que algún aviso de la sala la enseñe |
| Propiedad `botones_ocultos` (`Array[StringName]`) | Igual, pero el aviso que lo enseña está en una sala posterior, que puede ser de otra zona: va en la base de la zona (La Celda esconde `curar`). El validador solo exige que cada una sea un botón de la pantalla |
| Propiedad `habilidades_de_prueba` (`Array[StringName]`) | Solo salas de prueba: habilidades que la sala da en silencio al entrar (sin aviso ni autoguardado). Las de `herramientas/salas/` dan `pluma`, salvo la de combate chico (donde se recoge), la del diálogo, la del reto y la de música. El validador la exige vacía en `contenido/` |
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
  `Sala.recordado(nodo, objeto)` (estática) dice si `Partida` ya tiene ese objeto marcado en esa sala.
- `Sala.ruta_de(id)` (estática) da la escena de un id (primero `contenido/`, después la zona de prueba si existe);
  una ruta `res://` pasa tal cual. `Sala.zona_de(id)` da su zona. `Sala.nombre_de(id_o_ruta)` da el nombre
  visible de la zona desde `nombres_zona` del índice opcional del mapa (cacheado una vez); sin nombre usa el id
  con `capitalize()`, y para una ruta usa el nombre del archivo sin extensión con `capitalize()`. `clave()` es el id de la sala o, si no tiene, su
  ruta: lo que guardan `Partida.sala`, la clave de los enemigos fuertes y `cambio_de_sala`.
- Los ids de sala no se renumeran nunca, aunque una sala se quite: los guardan la partida y el mapa. Una sala nueva
  toma el siguiente número libre de su zona.
- Convenciones de ids: puertas por su lado (`izquierda`, `derecha`, `arriba`, `abajo`; dos del mismo lado,
  `derecha_2`); banco `banco_<id de la sala>`; objetos que se recuerdan, un nombre corto único dentro de la sala.
- Cómo se escribe una sala: Claude escribe cada sala completa como `.tscn` (formas, puertas, objetos y decoración); la persona la revisa en el editor si quiere. Con tres condiciones: ningún generador de escenas fuera del repo (dos fuentes de verdad); se conservan el `uid` y los ids de `ext_resource` de lo que ya existe; y cada `ext_resource` lleva su uid, que el validador exige (`docs/validador.md`, «uid de escenas y recursos»).
- El validador revisa cada sala con id y cada escena y ficha del juego; la lista completa de lo que revisa está en `docs/validador.md`. Lo de recursos, presupuesto e importación está en `docs/arte-y-rendimiento.md`, «Recursos», y el mapa, en `posicion_mapa`. Una regla nueva del validador entra a `docs/validador.md` y a su entrada de `herramientas/funciones.json` en el mismo cambio.
- Áreas: la de una pieza que se ajusta a ojo en la sala (`ZonaCamara`, `RegionMusica`, recogibles, `DanoContacto`)
  lleva su forma como `CollisionShape2D` hija, editada en el editor, donde se ve; el validador la exige en `ZonaCamara`
  y `RegionMusica`. La forma se crea en código solo cuando su tamaño sale de otro dato de la pieza: la de los
  `Interactuable` que no la traen en su escena (`Interactuable._crear_forma(ancho, alto)`: `Estacion`, `Tienda`,
  `Mochila`), la zona de un `AvisoAccion` (`tamano`), la de una `PlataformaDelgada` (`ancho`), el cuerpo y las áreas
  de un `Enemigo` (`tamano` de su ficha), un `AtaqueEnemigo` (su rectángulo) y el `Golpeable` de un `MuroRompible` o
  una `Palanca`.
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
- Lo que sobrevive al cambio de sala vive en `Partida` (`docs/contrato.md`, «Estado de la partida»).

Bancos:

- `nucleo/banco.tscn` (`class_name Banco`, `Interactuable` con `con_aviso` en falso: sin aviso), hija de la raíz de una sala o dentro de una
  pieza de ella. Sin hijos que dibujen pinta un rectángulo provisional de 120 × 40 (`dibujar_provisional`); el arte
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
`docs/contrato.md`, «Paquete de publicación»).
