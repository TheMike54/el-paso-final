# Enemigos

Parte del contrato (`docs/contrato.md`): la ficha de un enemigo, su comportamiento y datos, el botín, los ataques, el parry y los ganchos para mecánicas nuevas. El jugador (golpe, curar, parry visto desde él) está en `docs/jugador.md`.

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
| `botin` (0) | PejeCoins que suelta al vencerlo; 0, nada. Cada ejemplar las da una sola vez (ver viñeta «Botín») |
| `sonidos` (`FichaSonidos`, vacía) | Efectos propios de este tipo de enemigo; un campo vacío usa el de la sala o el global. El golpe usa `golpe`, la muerte `vencido` y el comportamiento pide efectos con `sonar(evento)`, como `sonar(&"ataque")` |
| `datos` (`DatosComportamiento`, vacío) | Números del comportamiento para este tipo; vacío, los que trae la clase de datos del comportamiento (ver viñeta «Datos del comportamiento») |

- El enemigo es un cuerpo en la capa `cuerpo_enemigo` que mira `escenario`: choca con suelos y paredes y el jugador
  lo atraviesa (lo daña su `DanoContacto`). Su forma de cuerpo, hija directa, se crea con `tamano`. `mirando` (-1 o 1)
  es pública.
- **Arte (opcional):** `animacion` es un `AnimatedSprite2D` hijo; con él no se dibuja la caja gris. Como el `Npc`, el
  dibujo mira a la derecha sin voltear y se refleja con `scale.x` sobre los pies cada vez que cambia `mirando`. Al
  aparecer toca `quieto` (`ANIM_QUIETO`) si su `SpriteFrames` la tiene; las demás las pide el comportamiento con
  `enemigo.animar(nombre)`, que no hace nada si no existe o si ya corre. Durante el congelado el dibujo se detiene
  (`speed_scale` 0). El tipo de enemigo con arte es una escena heredada de `nucleo/enemigo.tscn` con su ficha y su
  dibujo; la sala la instancia y solo pone el `id` (modelo: `herramientas/salas/fichas/enemigo_debil_arte.tscn`).
- **Datos del comportamiento**: los números que se ajustan (radios, tiempos, rapideces) no son
  `const` del comportamiento sino `@export` de un recurso que hereda de `DatosComportamiento`
  (`nucleo/datos_comportamiento.gd`), uno por comportamiento (`datos_volador.gd` junto a `volador.gd`, sin
  `class_name` en `herramientas/`). El comportamiento lo devuelve vacío en `datos_por_omision()` y lo lee de su var
  `datos`, que el `Enemigo` fija antes de agregarlo: los del ejemplar (`Enemigo.datos`, recurso propio en la escena de
  la sala), si no los de la ficha (`FichaEnemigo.datos`), si no los por omisión. Se elige el recurso entero, no cada
  número: unos datos del ejemplar con solo el radio cambiado traen los demás números por omisión, no los de la
  ficha. Por eso los datos de un tipo van en su propio `.tres` y el ejemplar parte de una copia de ese (*Make Unique*
  en el inspector, `tutorials/physics/troubleshooting_physics_issues.rst:71`); campo por campo haría falta un valor
  «vacío» que un `@export` tipado no tiene. Unos datos de otra clase que la del
  comportamiento se descartan con un `ERROR` y se usa el siguiente. Son de solo lectura en ejecución: la misma copia
  la comparten todos los que la nombran (`tutorials/scripting/resources.rst:30`), así que no hace falta
  `resource_local_to_scene`. El estado que cambia al correr (contadores, a quién persigue) sigue en variables del
  comportamiento. Modelo: `herramientas/salas/comportamientos/volador.gd`; guion `enemigo_datos`.

- El enemigo lleva un `Golpeable` (recibe los golpes; público como `golpeable`) y un `DanoContacto` (su cuerpo, que
  daña al jugador y nunca se para). A vida 0 emite `Eventos.enemigo_vencido(ficha.id)`, pide el congelado común,
  suelta su botín y desaparece.
- **Botín**: con `botin` mayor que 0, al vencerlo
  aparece un `MonedasSueltas` hijo de la sala, con `id` y nombre `botin_<id del ejemplar>` y `cantidad` = `botin`, que
  sube 60 px desde el centro del enemigo y cae al suelo que tenga debajo (rayo a `escenario` de hasta 2000 px; sin
  suelo, a sus pies), con un `Tween` de la sala atado al montón, en ticks de física. Se agrega con `call_deferred`
  (aparece en el tick siguiente): el golpe de la bola llega dentro de una señal de física, donde no se puede agregar un
  `Area2D`. El salto no se detiene en el congelado al vencer (4 ticks). El prefijo `botin_` queda reservado: el
  validador falla un objeto que se recuerda en una sala con un id que empieza así. Tomarlo lo marca en el estado de la sala
  como cualquier `MonedasSueltas`; con esa marca, el mismo ejemplar ya no suelta botín. Si no se toma y el jugador sale,
  se pierde y el ejemplar lo vuelve a soltar la próxima vez. Hollow Knight lanza geo en cada muerte, sin marca
  (`HealthManager.Die`); aquí, una vez por ejemplar, como pide el plan.
- `nucleo/comportamiento_enemigo.gd` (`class_name ComportamientoEnemigo`, `Node`): hijo del enemigo, con `enemigo`
  fijado. Cada tick fuera del congelado llama `actuar()`, que cada comportamiento sobrescribe. Ofrece `jugador()`,
  `atacar(rectangulo, ticks, dano, se_puede_parar)` (un `AtaqueEnemigo` hijo del enemigo, relativo a sus pies) y
  `disparar(desplazamiento, direccion, dano, se_puede_parar)` (un `ProyectilEnemigo` en la sala). Para moverse:
  `caer()` (la gravedad de la ficha con su tope), `mover()` (`move_and_slide`), `en_suelo()`, `pared_delante(sentido)`
  y `orilla_delante(sentido)` (rayos contra `escenario`: el de la pared sale del centro y llega 12 px más allá del
  cuerpo; el de la orilla sale 2 px fuera del cuerpo y 4 px sobre la posición del enemigo, y baja 16 px),
  `ve_al_jugador(radio)` (distancia entre centros y ningún sólido en medio), `centro()` y `girar()`.
  `lanzar_en_arco(desplazamiento, objetivo, grados, gravedad, tope, dano, se_puede_parar)`: un `ProyectilEnemigo` en
  arco que cae en `objetivo`.
- El empuje de su `Golpeable` no saca de una orilla a un enemigo que camina y está en el suelo.
- **Ganchos para mecánicas nuevas**:
  - `bloquea_golpe(atacante) -> bool` (sobrescribible; por omisión `false`): el enemigo la pasa a su `Golpeable`
    (`Golpeable.bloqueo`). Un golpe bloqueado (escudo de frente, caparazón cerrado), como el `Invincible` de
    `HealthManager` de Hollow Knight: no resta vida, no empuja, no cuenta en `golpes`, emite `bloqueado` y
    `Eventos.objeto_golpeado` (suena y vibra como un objeto), y `recibir_golpe` devuelve `false`, así que el ataque del
    jugador no da Inspiración; el jugador rebota igual. El golpe que devuelve un parry pasa por el mismo bloqueo: el
    parry cuenta, pero si el escudo lo bloquea no da la Inspiración del golpe.
  - `lado_de(nodo)`: -1, 1 o 0 según dónde está el nodo respecto del enemigo (un escudo de frente es
    `lado_de(atacante) == enemigo.mirando`). `jugador_lo_mira()`: si el jugador mira hacia el enemigo (lee
    `Jugador.mirando`, pública y de solo lectura).
  - `flotar(si)`: apaga la gravedad (trepar, enterrarse): `Enemigo.flotando` pone `MOTION_MODE_FLOATING` y `caer()` no
    hace nada; con `false` vuelve al modo de la ficha.
- `nucleo/ataque_enemigo.gd` (`class_name AtaqueEnemigo`, hereda de `DanoContacto`): el ataque, separado del cuerpo;
  daña mientras dura (`ticks`; 0, hasta que lo quiten) y no corre durante el congelado. No se dibuja (su área se
  ve con «Ver hitbox»). Con `se_puede_parar` al empezar deja el mismo trazo
  blanco que el golpe del jugador
  (`TrazoAtaque`, hijo `Trazo`, de lado y hacia donde está su forma; un `ProyectilEnemigo` no, `con_trazo`). `parado` es pública.
- `nucleo/trazo_ataque.gd` (`class_name TrazoAtaque`, `Sprite2D`): la media luna blanca de un golpe (`nucleo/arte/trazo_ataque.png`, que genera `herramientas/generar_trazo.gd`). `mostrar(centro_area, direccion, mirando)` la coloca con `TrazoAtaque.pose()` (función pura: `DESDE_AREA` girado hacia donde pega, espejado a la izquierda; arriba −90° y abajo +90°); sus tiempos y su escala son constantes del script. Cuenta ticks de física (quieta en la pausa y el congelado) y va sin luz (`LIGHT_MODE_UNSHADED`, el material compartido de `EfectoCuadros.material_sin_luz()`): ni la oscuridad de la sala ni el brillo la apagan.
- `nucleo/efecto_cuadros.gd` (`class_name EfectoCuadros`, `Sprite2D`): un efecto dibujado como hoja de cuadros (`nucleo/arte/efecto_*.png`, las genera `herramientas/generar_efectos.gd`). `EfectoCuadros.crear(textura, cuadros, filas, aditivo, una_vez, corre_congelado)`; avanza un cuadro cada `TICKS_POR_CUADRO` ticks de física, en bucle o una vez y se libera; `fila` elige la fila de la hoja y `reiniciar()` vuelve al primer cuadro. Sin luz; con `aditivo`, mezcla aditiva (`LuzSala.material_aditivo()`, el mismo de los halos). Quieto en el congelado salvo con `corre_congelado`. Lo usan el destello del parry, la bola y el aura de curar (`docs/jugador.md`, «Dibujo»); un enemigo con parry lo usa igual.
- `nucleo/proyectil_enemigo.gd` (`class_name ProyectilEnemigo`, hereda de `AtaqueEnemigo`): `crear_disparo` avanza
  recto a `velocidad`; `crear_arco(velocidad_inicial, gravedad, ...)` cae con su propia `gravedad`. Los
  dos, hasta un sólido (rayo que cubre el paso del tick) o 180 ticks. `velocidad_para(objetivo, grados, gravedad,
  tope)` da la velocidad inicial con ángulo fijo y rapidez calculada (como Silksong), sin pasar de `tope`.
- Parry: el ataque normal del jugador (en cualquier dirección) que toca un `AtaqueEnemigo` con `se_puede_parar` lo para: el ataque desaparece sin dañar, el jugador queda `ticks_invulnerable_parry` ticks sin daño de enemigos (los peligros sí dañan), congelado común de `ticks_congelado_parry` con un destello de luz en la punta de la espada (`docs/jugador.md`, «Dibujo»), después el jugador sale empujado hacia atrás (`ticks_retroceso_parry`) y su carrera o voltereta se corta, el enemigo dueño del ataque recibe el golpe (su `Golpeable` lo empuja) (con su Inspiración) y se emite `parry`. Lo resuelve quien se procese primero: el jugador en su ataque o el `AtaqueEnemigo` antes de dañar (`Jugador.intentar_parar`). `paradas` del jugador las cuenta.
- Un `ProyectilEnemigo` con `se_puede_parar` no se para: se desvía (como la
  versión ligera del choque de Silksong, `noClashFreeze`). Desaparece con una chispa (el destello del parry a la mitad, `ESCALA_CHISPA`), sin
  congelado, cuerpo en blanco, retroceso, invulnerabilidad ni Inspiración, y se emite `objeto_golpeado` (suena y vibra como
  pegarle a un objeto), no `parry`. `desviados` del jugador los cuenta.
- Débil: reaparece solo, porque la sala se instancia de nuevo cada vez que se entra. Fuerte: al vencerlo,
  `Partida.vencer(clave())` lo anota y, mientras siga anotado, no aparece al entrar a su sala. La lista se borra
  al descansar en un banco y al morir el jugador (como los semipersistentes de Hollow Knight).
- Enemigos nuevos: con estas mismas piezas (`Golpeable`, `DanoContacto`, comportamiento en
  la ficha); sus estados, con un `enum` mientras sean pocos; las zonas de golpe, formas invisibles aparte del dibujo;
  la animación, con `AnimatedSprite2D`.

## Jefes

El modelo es la `BattleScene` de Hollow Knight: una `ArenaJefe` despierta al enemigo al entrar el jugador y cierra
sus `Porton`. Se usa el mismo `Enemigo`, sin otra base de jefe. La ficha lleva `jefe = true` y
`umbrales_fase: Array[int]`, vidas de mayor a menor; vacío significa una sola fase.

- `Enemigo.fase` empieza en 0. Después de cada golpe, al llegar a un umbral o quedar por debajo, avanza una fase,
  llama a `ComportamientoEnemigo.al_cambiar_fase(fase)` (gancho vacío por omisión) y emite
  `fase_cambiada(fase)`. Un golpe que cruza dos umbrales llama al gancho y emite una vez por cada fase, en orden;
  los golpes siguientes no repiten las fases. También se recorren los umbrales de un golpe letal.
- Todo enemigo emite `vencido()` una vez, antes de `queue_free()`, además de `Eventos.enemigo_vencido(ficha.id)`.
  El jefe usa el botín normal de su ficha, sin otro botín propio. No participa en las marcas temporales de enemigos
  fuertes que se borran al descansar: su victoria es permanente y la recuerda su arena.
- `nucleo/arena_jefe.gd` (`class_name ArenaJefe`, `Area2D`) exporta `jefe: Enemigo`,
  `id_jefe: StringName`, `portones: Array[Porton]` y `recompensa: Recompensa`. Lleva una `CollisionShape2D` hija
  directa con forma y encendida. Usa `Capas.INTERACCION` y mira `Capas.JUGADOR`, como `ZonaCamara`.
  El validador exige `id_jefe`, `jefe` y esa forma, y revisa los ids de su recompensa como los de otras entregas.
- Antes de entrar, solo duerme el hijo `Comportamiento` del jefe con `set_physics_process(false)`: el enemigo
  sigue recibiendo golpes. Al entrar un jugador vivo, cierra los portones y activa ese hijo. Los portones de la
  sala llevan `abierto_al_empezar = true`; conviene situar la detección un poco después del portón de entrada.
- Al recibir `vencido`, la arena abre sus portones, entrega con `Partida.dar_recompensa(recompensa)` y emite
  `Eventos.jefe_vencido(id_jefe)` una sola vez. El oyente existente de `Partida` lo anota y autoguarda.
  Para dar impulso, la recompensa tiene `tipo = HABILIDAD` e `id = &"impulso"`.
- `id_jefe` es la identidad persistente del combate, independiente del id del tipo (`FichaEnemigo.id`) y del
  ejemplar (`Enemigo.id`): no se renombra una vez publicado. Al cargar, `Partida.jefes.has(id_jefe)` hace que
  la arena libere al jefe y deje los portones abiertos, sin repetir el premio. No vuelve al descansar ni al morir.
- Morir sin vencer no entrega nada ni marca la victoria, incluso si un golpe pendiente vence al jefe durante
  el fundido de muerte. `Sala` conserva su reaparición habitual: al banco o recargando la sala; el siguiente
  intento carga el jefe con toda la vida, fase 0 y portones abiertos.

Modelo jugable: `herramientas/salas/sala_jefe.tscn`, categoría Partida → Jefe, con caja gris de 12 de vida,
umbral 6, dos portones y premio impulso. `herramientas/salas/comportamientos/jefe_prueba.gd` camina en fase 0; en fase 1 acelera y
alterna caminar, parar como aviso y embestir hacia el jugador. Sus tiempos y rapideces están en
`datos_jefe_prueba.gd`, de solo lectura. El guion `herramientas/guiones/nucleo/sala_jefe.guion` recorre la sala real,
el salto de dos umbrales y morir sin premio; la sensación se comprueba en la fila Jefe de `docs/pruebas.md`.
