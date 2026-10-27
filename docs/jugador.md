# Jugador

Movimiento, combate, curar y habilidades del jugador: lo que el contenido y los guiones pueden dar por hecho.
Es parte de `docs/contrato.md` (mismas reglas: se actualiza en el mismo cambio que el código) y se separó por
largo. Los componentes que usa el contenido (`Golpeable`, `DanoContacto`, `Cortable`…) siguen en el contrato.

`nucleo/jugador.tscn` (`class_name Jugador`, `CharacterBody2D`): camina y salta con toda su lógica en
`_physics_process`. Reglas del salto, como en Hollow Knight.
Todos los valores son propiedades exportadas del jugador y se ajustan en la zona de pruebas; las cuatro de la cámara
(`temblor_fraccion_x`, `suavizado_camara_x`, `adelanto_camara` y `tiempo_camara_y`) son del script de su nodo `Camara`
(`nucleo/camara_jugador.gd`, `class_name CamaraJugador`):

| Propiedad | Inicial | Qué es |
|---|---|---|
| `velocidad` | 360 px/s | Velocidad al caminar, sin aceleración |
| `gravedad` | 2400 px/s² | Gravedad |
| `altura_salto` | 230 px | Altura máxima manteniendo `saltar`; el impulso se calcula a partir de ella |
| `corte_salto` | 0,4 | Factor de la velocidad vertical al soltar `saltar` mientras sube |
| `ticks_minimos_salto` | 4 | Ticks de subida antes de que soltar corte el salto |
| `ticks_coyote` | 4 | Ticks después de salir de una orilla en que `saltar` todavía funciona. Silksong da 4 pasos (~0,08 s, 5 ticks; Hollow Knight 2); en 5 se sintió fácil (S21, 15-oct-2026) |
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
| `ticks_hit_stop` | 10 | Ticks de congelado común al recibir daño, antes del retroceso (ver `Congelado`) |
| `ticks_invulnerable_parry`, `ticks_congelado_parry` | 15, 20 | Parry: ticks sin daño de enemigos y de congelado común (ver «Enemigos» en `docs/contrato.md`). 20 = 0,33 s: Hollow Knight 0,36 s (`NailClashEffect`), Silksong 0,2-0,3 s (medido en video) |
| `ticks_retroceso_parry`, `velocidad_retroceso_parry` | 8, 600 px/s | Parry: empuje del jugador hacia atrás, lejos del ataque, después del congelado |
| `ticks_rebote_al_golpear` | 4 | Ticks en que el jugador sale empujado hacia atrás al golpear algo |
| `velocidad_rebote_al_golpear` | 240 px/s | Velocidad de ese empuje |
| `costo_curacion` | 33 | Inspiración que cuesta curar una vida |
| `ticks_curacion` | 60 | Ticks de curación para recuperar una vida, contados desde `ticks_mantener_poder` |
| `ticks_devolver_curacion` | 27 | Soltar `curar` antes de estos ticks de curación devuelve toda la Inspiración gastada |
| `inspiracion_por_golpe` | 11 (`Partida.INSPIRACION_POR_GOLPE`, que también mide los bloques del HUD) | Inspiración que gana cada golpe del ataque a un enemigo (`Golpeable` con `es_enemigo`) |
| `ticks_mantener_poder` | 10 | Ticks manteniendo `curar` a partir de los cuales es mantener (curar) y no un toque (poder) |
| `costo_poder` | 33 | Inspiración que cuesta cada poder |
| `salida_proyectil` | (60, −90) px | Dónde sale la bola, relativo a los pies del jugador mirando a la derecha |
| `ticks_recarga_bola` | 18 | Ticks desde que sale una bola hasta poder lanzar otra (un amuleto podría reducirlo) |
| `velocidad_impulso` | 1200 px/s | Velocidad horizontal del impulso |
| `ticks_impulso` | 10 | Ticks que dura el impulso, sin gravedad (200 px) |
| `ticks_recarga_impulso` | 36 | Ticks desde que empieza un impulso hasta poder hacer otro |
| `velocidad_carrera` | 756 px/s | Carrera (sprint), 2,1 veces `velocidad` (Silksong: «112 % más rápido»). Sin fuente para el valor exacto |
| `ticks_giro_carrera` | 8 | Giro en carrera: la velocidad pasa de un sentido al otro, por 0, sin apagarla |
| `ticks_soltar_carrera` | 4 | Ticks sin dirección que la carrera aguanta a velocidad completa: cruzar el centro del joystick (zona muerta 0,2) al girar no es soltar. Valor nuestro, en el rango de 4 a 6 |
| `velocidad_ataque_carrera` | 2000 px/s | Ataque en carrera: empuje hacia adelante mientras dura el ataque, por encima de `velocidad_impulso` (1200): la persona la pidió más larga cuatro veces tras probarla en el S50 (12-oct-2026). Provisional |
| `ticks_entre_ataques_carrera` | 42 ticks | Desde un ataque en carrera hasta poder hacer otro sin dejar de correr; lo pedido antes se pierde. Provisional (Silksong: uno cada 0,65-0,85 s, video del 12-oct-2026) |
| `altura_voltereta`, `velocidad_voltereta` | 160 px, 480 px/s | Voltereta tras un ataque en carrera que golpea: altura del salto y velocidad hacia adelante (o hacia el joystick). Provisional |
| `ticks_rebote_pared`, `velocidad_rebote_pared`, `altura_rebote_pared` | 8, 300 px/s, 30 px | Chocar corriendo con una pared: rebote hacia atrás y saltito. Provisional |
| `velocidad_deslizar_pared` | 150 px/s | Caída máxima sostenido en una pared |
| `velocidad_despegue_pared` | 420 px/s | Velocidad horizontal con que el salto en pared despega de ella |
| `ticks_despegue_pared` | 8 | Ticks tras el salto en pared en que la entrada horizontal no manda |
| `ticks_coyote_pared` | 3 | Ticks después de dejar la pared en que `saltar` todavía es un salto en pared |
| `altura_agarre_pared` | 0 | Fracción de la altura del cuerpo, desde los pies, a la que tiene que haber pared para sostenerse y saltar de ella (un rayo a esa altura). En 0 basta cualquier contacto, aunque el 70 % del cuerpo quede por encima de la esquina; la dificultad de la esquina se queda así (decisión del 14-oct-2026). En 0,5 deja de agarrarse con más de medio cuerpo por encima. Hollow Knight (código decompilado) cuenta la pared con un rayo desde el centro o desde los pies: con los pies en la pared sigue agarrado, como aquí en 0. Silksong sube sola a la cornisa al llegar al borde |
| `velocidad_picada` | 1800 px/s | Velocidad de la caída en picada, sin el tope de `velocidad_caida_max` |
| `dano_picada` | 3 | Daño de la onda al aterrizar de la picada a cada `Golpeable` que toca |
| `onda_picada` | (320, 120) px | Tamaño de esa onda, centrada a lo ancho en los pies |
| `ticks_invulnerable_picada` | 24 | Ticks sin recibir daño después de aterrizar de la picada |
| `altura_saltito_picada` | 40 px | Picada desde el suelo: altura del saltito |
| `ticks_carga_picada` | 15 | Picada desde el suelo: ticks quieto en la cima del saltito antes de bajar |
| `ticks_caida_dura` | 18 | Aterrizaje duro, como en Hollow Knight: aterrizar tras 18 ticks seguidos (0,3 s) cayendo a `velocidad_caida_max` (unos 794 px; 650 con `distancia_caida_inicial` en 0). Pared, pogo, impulso o retroceso reinician la cuenta. La picada tiembla siempre al aterrizar (no al romper un `SueloFragil`). Sin fuente |
| `temblor_px` | 20 px | Amplitud vertical inicial del temblor del aterrizaje duro y de la picada: el `offset` de la cámara, signo alterno cada 2 ticks, baja en línea recta a 0; aterrizar otra vez lo reinicia (salvo que el que queda sea más fuerte, ver `temblar`). `temblor_y` y `temblor_x` (públicas) son los valores de cada tick aunque el ajuste esté apagado. Provisional, sin fuente |
| `temblor_fraccion_x` | 1/3 | En `CamaraJugador`. Amplitud horizontal en fracción de `temblor_px`, signo alterno cada 3 ticks: con periodos distintos no da vueltas en círculo |
| `temblor_ticks` | 18 | Ticks que dura el temblor (0,3 s). Provisional, sin fuente |
| `ticks_aterrizaje_duro` | 21 | Ticks sin control tras un aterrizaje duro (0,35 s; no tras la picada). Sin fuente: el de Hollow Knight está en sus recursos |
| `suavizado_camara_x` | 8 | En `CamaraJugador`. Seguimiento horizontal de la cámara: fracción por segundo de lo que le falta (el cálculo de `position_smoothing_speed`) |
| `adelanto_camara` | 43 px | En `CamaraJugador`. La cámara se adelanta hacia donde mira el jugador; `suavizado_camara_x` hace el paso al voltear |
| `tiempo_camara_y` | 0,15 s | En `CamaraJugador`. Seguimiento vertical de la cámara, amortiguado crítico (como `SmoothDamp`): cayendo a 1200 px/s va 180 px por detrás. Con menos de 0,15 s el frenado en el límite inferior se siente como un jalón (medido el 07-oct-2026) |

Combate:

- Sin la habilidad `pluma` (el arma) `atacar` no hace nada; el botón táctil Atacar tampoco se dibuja.
- El ataque es el área `Ataque` del jugador, hacia donde mira (el último lado al que caminó); con `mover_arriba`
  mantenida, encima de la cabeza (`posicion_ataque_arriba`, sin rebote hacia atrás). Golpea una sola vez a cada
  `Golpeable` que toca durante un ataque y corta cada `Cortable` que toca.
- `recibir_dano(dano: int, origen_x: float, peligro := false)` es lo único que quita vidas. Durante la
  invulnerabilidad y la caída en picada (con su saltito y su carga) un golpe no quita vidas; un peligro, sí. Emite `jugador_danado` con las vidas que quedan y, al llegar a 0,
  deja la mochila (`Partida.dejar_mochila`) y emite `jugador_muerto`.
- Golpe normal (enemigo, cuerpo dañino): retroceso e invulnerabilidad. Durante el retroceso el jugador no camina
  ni salta: ni el tiempo coyote ni el salto en cola valen hasta que termina.
- Peligro (pinchos, ácido, fosas): quita una vida aunque el jugador sea invulnerable (como Hollow Knight) y el
  jugador vuelve a su punto seguro, sin retroceso, quieto `ticks_reaparicion_peligro` e invulnerable. Antes, como en
  Hollow Knight, se queda quieto donde lo tocó mientras la pantalla funde a negro y pasa al punto en el tick en que el
  negro tapa todo; la imagen aclara con el jugador ya quieto en el punto (duraciones en la viñeta «Fundido a negro» de «Sala», en `docs/contrato.md`). Durante el fundido nada lo daña. La salida por abajo se revisa antes de mover al
  jugador, como un `DanoContacto`, para contar los ticks a la par del fundido. Mientras está quieto tras reaparecer, ningún peligro cuenta (el contacto de un `DanoContacto` se revisa con la lista del tick
  anterior). Anti-bucle (como Silksong): si otro peligro lo toca antes de `ticks_anti_bucle` ticks con control (30 =
  0,5 s), vuelve al punto por el que entró a la sala (puerta, banco o `Entrada`) sin perder vida; ese punto pasa a
  ser su punto seguro y el siguiente peligro ya quita vida. El punto seguro es una posición con `ticks_suelo_firme` ticks seguidos en el suelo fuera de la
  invulnerabilidad, tomada `ticks_atras_punto_seguro` posiciones atrás. `ultimo_punto_seguro()` lo da (la posición
  si todavía no hay ninguno): ahí deja `Partida` la mochila al morir (`docs/contrato.md`, «Estado de la partida»).
- Salir por abajo de `limites` (los pies a más de `margen_fuera_de_sala` del borde) es un peligro igual que un
  pincho: `recibir_dano(1, x, true)`. Solo por abajo; por los lados y por arriba una sala se cierra con paredes
  o puertas. Sin sala, los límites son enormes y no ocurre.
- Muerto (`muerto = true`), el jugador hace la animación `muerte` (ver «Dibujo») y ya no responde a la entrada. 90 ticks (1,5 s) después, la
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
- Hablar: `empezar_a_hablar()` (lo llama un `Npc`) corta el impulso, la curación a medias y el retroceso, y deja al
  jugador quieto con gravedad (`hablando`) hasta `dejar_de_hablar()`. El tick siguiente también queda quieto: la
  pulsación que cerró la caja no salta ni ataca. Un golpe, un peligro o morir lo cortan. Mientras habla, el banco no
  sienta y la entrega de recompensas no responde.
- Cerrar un menú con A: si la pausa se quita fuera del tick de física (A acepta un `Button` de un menú, como Continuar
  de la pausa o No del cobro, y A también es `saltar`), el jugador recibe `NOTIFICATION_UNPAUSED` y en su tick
  siguiente esa pulsación no cuenta como `saltar`: no salta, no queda en la cola
  del salto, no usa el coyote y no lo levanta del banco. Solo ese tick: una pulsación nueva en el siguiente sí salta.
  Un menú que se cierra leyendo una acción en su `_physics_process` ya va después del jugador («Marco de menús» en
  `docs/contrato.md`) y no pasa por aquí.
- Temblor pedido desde fuera: `temblar(ticks, px)` (lo llaman `MuroRompible` y `Palanca`) arranca un temblor con la
  misma forma que el del aterrizaje. Si ya hay uno que en ese tick es más fuerte que `px`, se queda el que hay; el
  aterrizaje y la picada usan el mismo camino. El jugador lo pasa a su `CamaraJugador`, que lleva el temblor en curso.
- `vidas`, `muerto`, `toques_poder`, `rebotes_pogo`, `en_picada`, `golpes_onda`, `descansando`, `hablando`, `temblor_x`, `temblor_y`, `aterrizando`, `atacando`, `paradas`, `corriendo`, `atacando_en_carrera`, `volteando`, `girando`, `invulnerable` y `puede_interactuar` (`aterrizando`, `atacando`, `girando`, `invulnerable` y `puede_interactuar`, de solo
  lectura) son propiedades públicas: los guiones las leen con `valor Jugador vidas`. `temblor_x` y `temblor_y` también son de
  solo lectura: las calcula la `CamaraJugador` y el jugador las lee de ella. `puede_interactuar` es la regla
  única del banco, el `Npc`, el reto y la entrega: en el suelo, vivo, de pie, sin aterrizaje duro ni conversación.
  Los cuatro la consultan con `Jugador.encima_de(area)`, que da el jugador encima del área que cumple la regla, o
  `null`.

Curar y sensación del golpe:

- Botón de poderes: soltar `curar` antes de `ticks_mantener_poder` ticks es un toque (suma uno a `toques_poder`,
  propiedad pública, y lanza el poder); mantenerlo hasta ese tick intenta curar. Una pulsación que empieza durante
  el impulso o el retroceso no cuenta, y un golpe o volver al punto seguro pierden la que va a medias.
- Curar: al llegar a `ticks_mantener_poder`, si el jugador está en el suelo, con vidas por llenar, fuera del
  retroceso y del impulso, y con `Partida.inspiracion >= costo_curacion`, corta un ataque a medias (y el que estaba en
  cola), se queda quieto y gasta la Inspiración
  poco a poco mientras mantiene `curar`. A los `ticks_curacion` ticks recupera una vida y emite `jugador_curado`. Soltar, dejar el suelo o recibir daño antes lo
  corta y lo gastado se pierde, salvo al soltar antes de `ticks_devolver_curacion`: la Inspiración vuelve al valor
  de antes de empezar, nunca a más. Cada golpe a un `Golpeable` con `es_enemigo` da `inspiracion_por_golpe` (tope 99); a un muro o una palanca, nada.
- Sensación: al golpear, el jugador sale empujado hacia atrás y lo golpeado hacia el otro lado
  (`Golpeable.velocidad_retroceso`, `ticks_retroceso`). Al recibir daño (no de un peligro), el jugador se detiene
  `ticks_hit_stop` ticks antes del retroceso.
- Congelado común (`nucleo/congelado.gd`, `class_name Congelado`, estático), como `FreezeMoment` de Hollow Knight:
  `Congelado.pedir(ticks)` detiene unos ticks al jugador, a los `Golpeable` empujados, a los proyectiles y a la
  planta y la niebla, que preguntan `Congelado.activo()` al empezar su tick o su cuadro (sin `Engine.time_scale`: los guiones cuentan ticks). Lo piden
  el daño al jugador (`ticks_hit_stop`), un enemigo vencido (`Congelado.TICKS_AL_VENCER`, 4) y el parry. La sala lo reinicia
  al entrar.

Habilidades (solo si `Partida.tiene(<id>)`; los ids son las constantes de `nucleo/habilidades.gd`, `class_name Habilidades`):

| Id | Qué hace |
|---|---|
| `pluma` | El arma: sin ella `atacar` no hace nada y el botón táctil de atacar no se dibuja |
| `pluma_mapa` | Al descansar en un banco, dibuja en el mapa las salas visitadas de las zonas cuyo mapa se tiene (como la Pluma de Hollow Knight) |
| `impulso` | La acción `impulso` lanza al jugador hacia donde mira, sin gravedad, `ticks_impulso` ticks; recarga `ticks_recarga_impulso`. En el aire, uno hasta tocar el suelo o una pared. Nunca hacia abajo ni solo con el joystick. Corta la voltereta y un rebote a medias. Si al terminar hay dirección, empieza la carrera (`corriendo`) a `velocidad_carrera` hacia ella, en el suelo o en el aire: sigue hasta soltar la dirección más de `ticks_soltar_carrera` ticks, chocar con una pared (con un rebote corto hacia atrás y un saltito), curarse, recibir daño, la picada, sentarse en un banco o el aterrizaje duro; saltar la conserva (salto largo); pedir el otro lado la gira (`girando`, `ticks_giro_carrera`) sin apagarla, y un impulso, despegue o rebote a mitad del giro lo cancela (al volver, si la dirección se opone, empieza otro); en carrera el impulso sale hacia el joystick; atacar al frente en carrera (no durante el giro) es un ataque en carrera (`atacando_en_carrera`): empuja a `velocidad_ataque_carrera`, se dibuja como una estocada y no rebota al golpear; otro ataque al frente pedido en carrera antes de `ticks_entre_ataques_carrera` se pierde (ni estocada ni ataque normal) y la carrera sigue; hacia arriba, el pogo y el pedido durante el giro salen como siempre, y la voltereta reinicia esa recarga. Si golpea un `Golpeable`, corta la carrera y empieza la voltereta (`volteando`, como Silksong con el blasón de cazadora): sale hacia arriba `altura_voltereta` y hacia adelante a `velocidad_voltereta` (el joystick la dirige), con el doble salto y el impulso en el aire de vuelta, como el pogo; el golpe corta un impulso en curso y el siguiente ataque sale en cuanto termina el actual, sin esperar `ticks_entre_ataques` (Silksong: el ataque en carrera reinicia la recarga); acaba al tocar el suelo (camina: la carrera vuelve solo con otro impulso), al atacar, con un impulso, un daño o una pared |
| `salto_en_pared` | En el aire, cayendo y empujando hacia una pared, el jugador se sostiene y desliza a `velocidad_deslizar_pared` (`en_pared`). Tocándola y empujando hacia ella, suba o baje (y hasta `ticks_coyote_pared` después), `saltar` da un salto completo y lo despega hacia el lado contrario: así se sube por una sola pared o de una pared a la otra. Recupera el impulso y el doble salto |
| `doble_salto` | `saltar` recién presionada en el aire, fuera del tiempo coyote, da un segundo salto con las mismas reglas; se recupera al tocar el suelo o sostenerse en una pared |
| `caida_en_picada` | `curar` recién presionada con `mover_abajo`, con `Partida.inspiracion >= costo_poder`, gasta ese costo en el mismo tick (sin esperar a saber si es un toque). En el aire, el jugador cae enseguida recto a `velocidad_picada`, sin control, hasta tocar el suelo (`en_picada`, propiedad pública). En el suelo, primero un saltito de `altura_saltito_picada` y `ticks_carga_picada` quieto en su cima, y después la caída. Un `SueloFragil` que toca se rompe y la caída sigue. Corta un ataque a medias. No recibe daño desde que empieza hasta `ticks_invulnerable_picada` después de aterrizar (un peligro sí quita vida y lo devuelve al punto seguro). Al aterrizar, una onda de `onda_picada` golpea con `dano_picada` a cada `Golpeable` que toca, sin dar Inspiración |
| `proyectil` | Un toque del botón de poderes, con `Partida.inspiracion >= costo_poder` y pasados `ticks_recarga_bola` desde la anterior, gasta ese costo y lanza la bola (`nucleo/proyectil.tscn`) hacia donde mira, en el suelo o en el aire. Nombre técnico neutro |

- `nucleo/objeto_habilidad.tscn` (`class_name ObjetoHabilidad`): al tocarlo, llama a `Partida.obtener_habilidad` con su
  `habilidad` (suma, emite `Eventos.habilidad_obtenida` y rechaza un id fuera de `Habilidades.TODAS`) y desaparece; si
  la partida ya la tiene, no aparece.
- Prioridad del movimiento horizontal: retroceso del golpe recibido, impulso, despegue de la pared, rebote (al
  golpear, al parar o contra la pared), voltereta, carrera y por último la entrada.

## Dibujo

El cuerpo es el nodo `Dibujo` (`AnimatedSprite2D`) de `nucleo/jugador.tscn`, con el `SpriteFrames`
`nucleo/arte/jugador_hombre/jugador_hombre.tres` (atlas e importación: «Recursos» en `docs/contrato.md`). El dibujo
solo lee al jugador: la física, el control y las áreas no dependen de él.

- `Dibujo` está en (0, −80), el centro del cuerpo, que es también el pivote del giro de la voltereta; `centered`
  apagado y `offset` fijo (−158, −98), que pone el eje del cuerpo del lienzo común (316 × 182, pies en la fila 178)
  sobre la x del jugador y los pies en su y. El lienzo lo mide el script que arma el atlas: si cambia, cambia el
  `offset` (pasó de 180 a 182 el 24-oct-2026, al corregir la escala del ataque vertical). Lleva `show_behind_parent`: los hijos del jugador que no lo llevan (el trazo, el frente del aura de curar) quedan encima.
- Cada golpe deja un trazo blanco (`Trazo`, un `TrazoAtaque` hijo del jugador, ver «Enemigos» en
  `docs/contrato.md`): `_iniciar_ataque` lo dispara sobre el área de golpe ya colocada (de lado, `posicion_ataque_arriba`
  o `posicion_pogo`), así sigue al área si esta cambia. Se ve desde el cuarto tick del golpe (guion
  `nucleo/trazo_jugador`).
- Al final de `_physics_process`, tras mover y tras la cámara, `_animar()` llena un `AnimacionJugador.Estado` y
  `AnimacionJugador.elegir()` (`nucleo/animacion_jugador.gd`, funciones puras) da la animación. Gana la primera fila
  que se cumple, en el orden de `HeroAnimationController.UpdateAnimation` de Hollow Knight:

  | # | Estado | Animación |
  |---|---|---|
  | 1 | `muerto` | `muerte`: dura `Sala.TICKS_PARA_REAPARECER` (90 ticks) y no se repite |
  | 2 | Fundido de un peligro | `dano`, primer cuadro fijo |
  | 3 | `descansando` | `sentarse` una vez y después `dormir` en bucle |
  | 4 | Retroceso de un golpe | `dano`, repartido en `ticks_retroceso` |
  | 5 | `aterrizando` | `aterrizaje_duro`, repartido en `ticks_aterrizaje_duro` |
  | 6 | Carga de la picada / `en_picada` | `picada_carga` / `picada` |
  | 7 | `curando` | `curar`: el inicio los primeros 10 ticks curados y después el sostenido |
  | 8 | `curar` presionado que todavía puede ser un toque / recarga de la bola | `bola`: el primer cuadro / los otros dos, repartidos en `ticks_recarga_bola` |
  | 9 | `atacando_en_carrera` | `estocada`, repartida en `ticks_ataque` |
  | 10 | Ataque (el golpe y su cola hasta `ticks_entre_ataques`) | `ataque_abajo`, `ataque_arriba` o `ataque_lado`, repartidos en `ticks_entre_ataques`. La cola (después del golpe) se corta y no vuelve si la interrumpe una fila de más prioridad, hablar o la pausa tras un peligro (`AnimacionJugador.actualizar_cola_ataque`): `_ticks_hasta_ataque` solo baja mientras el jugador puede atacar. Pegado a una pared, `ataque_lado` hacia donde mira, que es donde sale el área (decidido el 21-oct-2026) |
  | 11 | `volteando` | `voltereta`: dos cuadros y el sprite gira una vuelta cada `TICKS_VUELTA` ticks hacia donde mira |
  | 12 | Impulso | `impulso`: arranque 2 ticks, dos cuadros alternados, final 2 ticks |
  | 13 | Despegue de la pared / `en_pared` | `saltar_pared` / `pared` (bucle) |
  | 14 | En el aire (en la pausa tras un peligro cuenta como en el suelo: lo pone ahí sin `move_and_slide` y `is_on_floor()` sigue con el valor de la caída) | `aire`: el despegue los primeros 4 ticks del salto y después el cuadro según `velocity.y` (sube, cima, empieza a caer, cae) |
  | 15 | `corriendo` | `carrera`, bucle a 15 cuadros por segundo |
  | 16 | En el suelo, moviéndose y sin rebote | `correr`, bucle a 12 |
  | 17 | Lo demás | `quieto`: 1-2-3-2 a 400 ms por cuadro (`LOOP_PINGPONG`) |

  El giro en carrera no es una fila: `AnimacionJugador.con_giro()` lo pone después de elegir, solo en el suelo y
  solo sobre `carrera`, `correr` o `quieto` (como el `Turn` de Hollow Knight), repartido en `ticks_giro_carrera`.
- Los clips con tiempo propio toman el cuadro de los contadores de ticks del jugador (`set_frame_and_progress`), con
  las duraciones del `SpriteFrames` como proporción, leídas una vez en `_ready`; los bucles, `muerte` y `sentarse` los
  corre el sprite (`play`). Un bucle que no corre (el de la escena al aparecer) arranca; `muerte` y `sentarse` se
  quedan en su último cuadro.
  Con la interpolación de física apagada, el cuadro va a la par del tick. En el congelado común, `speed_scale` 0.
- Volteo con `Dibujo.scale.x` igual a hacia dónde mira, no con `flip_h` (`AnimacionJugador.volteo`). Pegado a la
  pared (`pared`) va al revés: mira hacia afuera, con la pared a la espalda como en la hoja, aunque «mirar» apunte a
  la pared (decidido el 21-oct-2026). Como la mano y los pies de esa hoja sobresalen 90 px por detrás del eje, el
  `Dibujo` se aparta de la pared lo que sobra sobre medio ancho del jugador (`AnimacionJugador.separacion_pared`, de
  los márgenes de los `AtlasTexture`: 50 px), para que toquen su borde sin meterse. Invulnerable: el alfa del `modulate` baja a
  `PARPADEO` (0,35) 4 ticks de cada 8, como el `InvulnerablePulse` de Hollow Knight.
- Destello en blanco solo en el parry: `TICKS_DESTELLO_PARRY` (6) ticks, 0,1 s, contados también durante el congelado
  (no muerto; antes duraba todo el congelado y 8 ticks más: en la maqueta aprobada el 25-oct-2026 no tapa al personaje).
  El congelado de un golpe recibido o dado no aclara el cuerpo: el golpe recibido se lee por el parpadeo, como en
  Hollow Knight y Silksong, que no aclaran al héroe en el parry ni durante el congelado (decidido el 21-oct-2026). Es un
  `ShaderMaterial` con `nucleo/arte/destello.gdshader` (`mix` del color con blanco según el uniforme `cantidad`). Un
  `modulate` mayor que 1 no aclara: Compatibility satura el color en 1 (`tutorials/rendering/renderers.rst:352,377`).
  El valor se cambia solo cuando cambia.
- El golpe (normal, arriba, abajo y la estocada) se ve solo con su trazo blanco (`TrazoAtaque`); el área se ve con
  «Ver hitbox» (decidido por la persona el 25-oct-2026). Desviar un disparo no aclara el cuerpo ni congela (contrato,
  «Enemigos»).
- Efectos (elegidos por la persona el 25-oct-2026 en maquetas animadas): hojas de cuadros que se reproducen con
  `EfectoCuadros` (contrato, «Enemigos»), dibujadas una vez pixel por pixel por `herramientas/generar_efectos.gd` en
  tres capas encajadas (azul, celeste, blanca), para que se vean de una sola pieza; en el juego son un sprite por
  efecto. Sin luz: la oscuridad de la sala no los apaga.
  - Parry: destello de luz (`efecto_parry.png`, 4 cuadros de 352x208, 0,2 s, aditivo) que corre durante el congelado,
    hijo de la sala (queda fijo aunque el jugador salga empujado). De lado va en la punta de la espada del cuadro que
    golpea (`PUNTA_ESPADA_LADO`, (122, −117) desde los pies, medida en el atlas); arriba y abajo, entre el área de golpe
    y el ataque parado, porque la espada del dibujo no llega ahí. El parry llega en la preparación del golpe y el
    congelado la sostendría con la espada atrás: el clip salta ya a su cuadro de golpe (`CUADRO_GOLPE`). La chispa de
    un disparo desviado es el mismo destello a la mitad (`ESCALA_CHISPA`), sin correr en el congelado.
  - Bola: bola de fuego en capas (`efecto_bola.png`, 6 cuadros de 224x160 en bucle; opacidad 80 % el centro, 65 % y
    50 % las de fuera), espejada con `sentido`. La segunda fila no lleva las gotas sueltas: sale los primeros 3
    cuadros, cuando asomarían sobre la cabeza del jugador. La forma de golpe (60x40) no cambió.
  - Curar: el aura (`efecto_curar.png`, 6 cuadros de 320x420: picos filosos, 11, 10 y 9 por lado según la capa, y
    gotas y chispas que nacen en el piso; opacidad 45, 35 y 25 %) detrás del cuerpo, sus rayas y chispas
    (`efecto_curar_frente.png`) delante, y una luz falsa: el halo de `LuzSala` (aditivo, sin `Light2D`) de 660 px que
    crece con lo curado (0,35 + t / 0,6, como el aura del HTML de diseño) y titila. Se ven solo mientras `curando`.
    El aura va detrás con `show_behind_parent` y como primer hijo, no con `z_index` negativo, que la dejaba bajo el
    fondo de la sala.
