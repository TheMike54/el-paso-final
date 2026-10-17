# Jugador

Movimiento, combate, curar y habilidades del jugador: lo que el contenido y los guiones pueden dar por hecho.
Es parte de `docs/contrato.md` (mismas reglas: se actualiza en el mismo cambio que el código) y se separó por
largo. Los componentes que usa el contenido (`Golpeable`, `DanoContacto`, `Cortable`…) siguen en el contrato.

`nucleo/jugador.tscn` (`class_name Jugador`, `CharacterBody2D`): camina y salta con toda su lógica en
`_physics_process`. Reglas del salto, como en Hollow Knight; la caja gris (`sala_inicial`) no las lleva.
Todos los valores son propiedades exportadas del jugador y se ajustan en la zona de pruebas:

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
| `temblor_fraccion_x` | 1/3 | Amplitud horizontal en fracción de `temblor_px`, signo alterno cada 3 ticks: con periodos distintos no da vueltas en círculo |
| `temblor_ticks` | 18 | Ticks que dura el temblor (0,3 s). Provisional, sin fuente |
| `ticks_aterrizaje_duro` | 21 | Ticks sin control tras un aterrizaje duro (0,35 s; no tras la picada). Sin fuente: el de Hollow Knight está en sus recursos |
| `suavizado_camara_x` | 8 | Seguimiento horizontal de la cámara: fracción por segundo de lo que le falta (el cálculo de `position_smoothing_speed`) |
| `adelanto_camara` | 43 px | La cámara se adelanta hacia donde mira el jugador; `suavizado_camara_x` hace el paso al voltear |
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
  negro tapa todo; la imagen aclara con el jugador ya quieto en el punto (duraciones en la viñeta «Fundido a negro» de «Sala», en `docs/contrato.md`). Durante el fundido nada lo daña. La salida por abajo se revisa antes de mover al
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
- Hablar: `empezar_a_hablar()` (lo llama un `Npc`) corta el impulso, la curación a medias y el retroceso, y deja al
  jugador quieto con gravedad (`hablando`) hasta `dejar_de_hablar()`. El tick siguiente también queda quieto: la
  pulsación que cerró la caja no salta ni ataca. Un golpe, un peligro o morir lo cortan. Mientras habla, el banco no
  sienta y la entrega de recompensas no responde.
- Temblor pedido desde fuera: `temblar(ticks, px)` (lo llaman `MuroRompible` y `Palanca`) arranca un temblor con la
  misma forma que el del aterrizaje. Si ya hay uno que en ese tick es más fuerte que `px`, se queda el que hay; el
  aterrizaje y la picada usan el mismo camino.
- `vidas`, `muerto`, `toques_poder`, `rebotes_pogo`, `en_picada`, `golpes_onda`, `descansando`, `hablando`, `temblor_x`, `temblor_y`, `aterrizando`, `paradas`, `corriendo`, `atacando_en_carrera`, `volteando`, `girando`, `invulnerable` y `puede_interactuar` (`aterrizando`, `girando`, `invulnerable` y `puede_interactuar`, de solo
  lectura) son propiedades públicas: los guiones las leen con `valor Jugador vidas`. `puede_interactuar` es la regla
  única del banco, el `Npc`, el reto y la entrega: en el suelo, vivo, de pie, sin aterrizaje duro ni conversación.
  Los cuatro la consultan con `Jugador.encima_de(area)`, que da el jugador encima del área que cumple la regla, o
  `null`.

Curar y sensación del golpe:

- Botón de poderes: soltar `curar` antes de `ticks_mantener_poder` ticks es un toque (suma uno a `toques_poder`,
  propiedad pública, y lanza el poder); mantenerlo hasta ese tick intenta curar. Una pulsación que empieza durante
  el impulso o el retroceso no cuenta, y un golpe o volver al punto seguro pierden la que va a medias.
- Curar: al llegar a `ticks_mantener_poder`, si el jugador está en el suelo, con vidas por llenar, fuera del
  retroceso y del impulso, y con `Partida.inspiracion >= costo_curacion`, se queda quieto y gasta la Inspiración
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
