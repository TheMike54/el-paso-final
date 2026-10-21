CERRADO

# Enemigos que caminan, vuelan y escupen

Pedido por la persona el 17-oct-2026 («enemigos que se mueven y que vuelan»), después de revisar cómo lo hacen
Hollow Knight y Silksong. Aprobado por la persona el 17-oct-2026, con lo recomendado en las cuatro decisiones:
cuerpo `CharacterBody2D`, el caminante no se voltea al recibir un golpe, el Gruzzer después y el arco se puede
parar. El núcleo pone las piezas de movimiento; cada enemigo del juego será
una ficha y un comportamiento en `contenido/enemigos/`. Aquí solo van tres comportamientos de prueba en
`herramientas/salas/comportamientos/`. Encaja con la v1 de `docs/idea.md`: tres enemigos por zona.

## Referencia: Hollow Knight y Silksong

Lectura del 17-oct-2026 de las máquinas de estados y el código de los dos juegos, hecha por un subagente.
Conversión: 1 u ≈ 43 px. Sale de `RUN_SPEED` 8,3 u/s frente a los 360 px/s del jugador, y es una inferencia. Los
dos juegos corren a 50 Hz; aquí, 60 ticks.

| Pieza | Juego | Qué hace | Valores (u → px) |
|---|---|---|---|
| Caminante | Crawlid (HK, `WalkLeftRight`); `Crawler` (Silksong) | Va y viene sin caerse. Tres rayos: pared delante, orilla delante y suelo debajo. Al girar se queda quieto un momento | 4 u/s → 175 px/s; pausa al girar 1 s → 60 ticks |
| Volador | Vengefly (HK, `ChaseObject` + `IdleBuzz`) | Zumba en su sitio. Despierta si el jugador está cerca **y a la vista**, lo persigue acelerando con tope por eje y lo olvida tras un rato sin verlo | Aceleración 2,25 u/s² → 98 px/s²; tope 5 u/s → 217 px/s; alerta 7,6 u → 330 px; olvida a los 10 s → 600 ticks |
| Volador recto | Gruzzer (HK) | Vuela recto y rebota en las paredes con un ángulo al azar | 5,2 u/s → 226 px/s |
| Escupidor | Spitting Zombie (HK); `CalculateProjectileVelocity` (Silksong) | Lanza una bola con gravedad propia. Silksong fija el ángulo y calcula la rapidez para caer donde está el jugador | HK: vx 1,5 a 8 y vy 15 a 20 u/s, `gravityScale` 0,7. El disparo del Aspid es casi recto: 15 u/s y `gravityScale` 0,05 |
| Retroceso | Los dos | El golpe empuja con un barrido contra el terreno: nunca lo mete en la pared | 15 u/s × 0,15 a 0,25 s. El nuestro ya hace lo mismo: 600 px/s × 6 ticks |

Cuál se sigue:
- **Caminante:** el `Crawler` de Silksong, porque sus tres rayos son lo más seguro.
- **Volador:** el Vengefly.
- **Escupidor:** la cuenta de Silksong, con ángulo fijo, porque siempre cae cerca del jugador sin afinar valores.
- No se encontró un enemigo que se entierre: queda fuera.

## Qué se hace

- **El enemigo pasa a ser un cuerpo** (decisión 1). `nucleo/enemigo.tscn` cambia su raíz de `Node2D` a
  `CharacterBody2D`, en la capa `cuerpo_enemigo` (7, ya reservada para esto en el contrato) y con máscara
  `escenario`.
  - Su forma de cuerpo, un `CollisionShape2D` hijo directo, se crea en código con `ficha.tamano`, como las del
    golpe y del contacto (`_poner_forma`), y no a mano en el `.tscn`.
  - Modo de movimiento por ficha: el que camina, `MOTION_MODE_GROUNDED` (el de omisión); el que vuela,
    `MOTION_MODE_FLOATING`. Con este modo no hay suelo que lo pegue al piso cuando persigue bajo, y todo choque
    cuenta como pared (`classes/class_characterbody2d.rst:156-158`).
  - El jugador no lo mira (su máscara sigue en `escenario`): lo atraviesa y se daña por contacto, como hoy.
  - Lo que existe sigue igual: `CharacterBody2D` hereda de `Node2D` y un enemigo quieto no llama a
    `move_and_slide()`.
- **Ayudas nuevas en `ComportamientoEnemigo`**, para que un comportamiento no escriba física:
  - `mover(velocidad)`: `move_and_slide()` del enemigo.
  - `caer(gravedad, delta)`: gravedad con tope.
  - `en_suelo()`.
  - `pared_delante(sentido)` y `orilla_delante(sentido)`: los dos rayos del `Crawler`, contra `escenario`.
  - `ve_al_jugador(radio)`: distancia más un rayo de línea de vista contra `escenario`, para que una pared tape.
  - `mirando` (-1 o 1) y `girar()`: voltean el dibujo y las zonas de ataque.
- **`FichaEnemigo`**: campos nuevos con valor por omisión, para que las fichas de hoy no cambien.
  - `velocidad` (0: quieto).
  - `gravedad` (0: vuela).
  - Lo que se ajusta por tipo de enemigo va en la ficha. El comportamiento se crea con `.new()` desde el script de
    la ficha, sin datos por ejemplar, así que sus valores fijos son `const`. Si un valor necesita cambiar entre dos
    enemigos del mismo comportamiento, pasa a la ficha.
- **`ProyectilEnemigo` con arco**:
  - `gravedad` (0 por omisión: recto, como hoy) y velocidad inicial como `Vector2`.
  - Ayuda `lanzar_en_arco(desplazamiento, objetivo, grados, dano, se_puede_parar)` en `ComportamientoEnemigo`, con
    la cuenta de Silksong: dado el ángulo, la rapidez para caer en el objetivo, con un tope. Si no hay solución,
    lanza con el tope.
  - El rayo contra sólidos sigue cubriendo el paso del tick.
- **Tres comportamientos de prueba** (`herramientas/salas/comportamientos/`), con su ficha `.tres`:
  - `caminante.gd`: va y viene; ante pared u orilla se queda 60 ticks quieto y gira; nunca cae de una plataforma.
  - `volador.gd`:
    - zumba en su sitio;
    - con el jugador a 330 px y a la vista, lo persigue: 98 px/s², tope de 217 px/s por eje;
    - choca con las paredes, porque es cuerpo;
    - tras 600 ticks sin verlo, vuelve a zumbar.
  - `escupidor.gd`:
    - quieto en el suelo;
    - con el jugador a la vista: aviso de 30 ticks (se aclara, como `muneco_que_ataca`);
    - lanza en arco hacia donde está el jugador;
    - espera 90 ticks antes del siguiente.
- **Sala de prueba «Enemigos Moviles»**, en la categoría Enemigos de la zona de pruebas, con su fila en
  `docs/salas-de-prueba.md`. Lleva:
  - una plataforma con orillas y paredes para el caminante;
  - un cuarto con pilares para el volador, donde una pared tapa la vista;
  - el escupidor sobre una repisa.
- **Contrato**: «Enemigos» (cuerpo, ayudas, campos nuevos, arco) y «Capas de física» (la capa 7 deja de estar
  reservada), más `prueba_capas_fisica.gd`.

## Hitos

1. H1 · El enemigo como cuerpo, más `mover`, `caer` y `en_suelo`. Todos los guiones de enemigos, parry, combate,
   picada y guardado siguen pasando. `capas_fisica` con el cuerpo del enemigo.
2. H2 · Caminante. Casos en `prueba_enemigos_moviles.gd`:
   - en 20 s no cae de su plataforma;
   - gira en la pared y en la orilla;
   - se queda quieto la pausa al girar;
   - el golpe lo empuja sin sacarlo de la plataforma ni meterlo en la pared.
3. H3 · Volador. Casos:
   - quieto con el jugador lejos;
   - quieto con el jugador cerca pero tras una pared;
   - despierta y se acerca;
   - no atraviesa una pared persiguiendo;
   - respeta el tope de velocidad;
   - olvida tras 600 ticks.
4. H4 · Arco. Casos:
   - `lanzar_en_arco` cae a menos de 40 px del objetivo en tres distancias;
   - se detiene contra una pared;
   - un arco con `se_puede_parar` se para con el ataque;
   - `gravedad` 0 sigue recto (los guiones de hoy del disparo).
5. H5 · `validar.ps1`, todos los guiones y el revisor: el enemigo y la física son puntos críticos.
6. H6 · Prueba manual en un teléfono, en la sala nueva. Qué observar:
   - si el caminante se lee;
   - si el volador da tiempo de reaccionar;
   - si el arco del escupidor se ve venir;
   - los FPS en el S50 con los tres a la vez.

## Decisiones (para la persona)

1. **Cuerpo del enemigo:**
   - `CharacterBody2D` (recomendado: la capa ya estaba reservada; Godot resuelve paredes y suelo y no se escribe
     física a mano);
   - o seguir como `Node2D`, moviéndolo con consultas de forma (más código propio que probar).
2. **El caminante al recibir un golpe:**
   - sigue igual (recomendado: así es el Crawlid y se lee fácil);
   - o se voltea hacia el jugador.
3. **Volador recto que rebota (Gruzzer):**
   - después, con la segunda zona (recomendado: dos voladores en la primera zona se parecen);
   - o dentro de este plan.
4. **El arco del escupidor se puede parar:**
   - sí, como el disparo de hoy (recomendado: el parry ya existe y le da respuesta al jugador);
   - o no.

## Avance (17-oct-2026)

- 17-oct-2026, primera prueba en el S50 (APK de desarrollo, 120 s en la sala):
  - FPS: promedio 58,2 y mínimo 46. Dos segundos sueltos bajaron de 50 (48 y 46) y la persona no sintió tirones.
  - El volador se sintió lento. Decisión de la persona: solo cambia la aceleración, de 98 a 217 px/s², para que
    llegue al tope en 1 s; el tope y el radio se quedan. Que se arrastre pegado a la pared se queda así.
  - Con el cambio, `validar.ps1` y `enemigos_moviles` (17 casos, 0 fallos) pasan.
  - El escupidor no se alcanzaba: el pilar de x 2000 mide 480 px, llega al suelo, y la sala solo da `pluma`.
    Arreglo: dos escalones a la izquierda del pilar (x 1575 con la cara de arriba en y 860, y x 1760 en y 680). El
    pilar no se movió porque un hueco abajo dejaría ver al volador y rompería el caso «tras el pilar no lo ve».
    Un guion de prueba en el scratchpad cruza el pilar con tres saltos y llega a x 2470 sin perder vidas. De vuelta
    no se sube: para salir, la pausa.
- 17-oct-2026, segunda prueba en el S50: la persona aprueba el volador con 217 px/s² y ya no se le cambia nada. El
  escupidor se esquiva muy fácil.
  - Decisión de la persona: más cadencia, no más puntería. La espera entre tiros baja de 90 a 45 ticks, así que
    sale una bola cada 1,25 s y no cada 2 s. El aviso de 30 ticks y el arco de 50° se quedan.
  - Con el cambio, `validar.ps1`, `enemigos_moviles` (17/0) y `moviles_cruzar_pilar` pasan.
- 17-oct-2026, tercera prueba en el S50: la persona aprueba el escupidor. Los tres enemigos se leen y dan tiempo de
  reaccionar. FPS: dos segundos sueltos en 48 y 46, sin tirones a la vista. La persona da por bueno el criterio
  por el promedio (58,2) y `enemigos-moviles-telefono` pasa. Plan cerrado.

- H1 a H4 programados en `feature/nucleo-enemigos-moviles`. `validar.ps1` en verde. `enemigos_moviles` da 17 casos
  y 0 fallos. Con una copia, seis mutaciones hacen fallar al menos un caso cada una: sin orilla del caminante, sin
  línea de vista, sin orilla del empuje, sin tope, sin olvido y sin gravedad del arco.
- Cambios frente a lo planeado:
  - El `Golpeable` no empuja fuera de una orilla a un cuerpo que camina y está en el suelo: un rayo hacia abajo en
    la punta, como el barrido de Hollow Knight. Sin esto, un golpe tiraba al caminante de su plataforma.
  - `ProyectilEnemigo` guarda una `velocidad_actual` (`Vector2`) en lugar de la dirección: el disparo recto sale
    igual.
  - El caso del parry del arco llamaba `parar()` directo y no podía fallar, porque `parar()` borra el nodo (lo
    marcó el revisor). Ahora es un parry de verdad con el ataque del jugador. Si el arco no se puede parar, falla.
  - `girar()` solo invierte `mirando` y redibuja. Para voltear sus zonas de ataque, cada comportamiento usa
    `hacia_donde_mira`, porque las crea él mismo.
  - El caso del tope primero no comprobaba nada (en 60 ticks no se llega a 217 px/s); ahora acelera en un tramo
    abierto.
- H5, 17-oct:
  - los 144 guiones pasan;
  - el revisor dio 2 fallos y ninguno en el código del juego;
  - el caso del parry quedó corregido;
  - la skill `fisica-2d` contradecía lo aprobado (`motion_mode`, radio de visión); se corrigió con el OK de la
    persona el 17-oct.
- Falta H6 (prueba en el teléfono).

## Riesgos

- Cambiar la raíz del enemigo toca `enemigo.tscn` (un `.tscn` del editor): se edita a mano conservando `uid` e
  ids, o se hace en el editor. Lo cuidan `validar.ps1` y los guiones de enemigos.
- El `Golpeable` empuja a su padre por `position` con un rayo. Con un cuerpo sigue sirviendo, pero el empuje
  podría pelear con `move_and_slide()`. Si pasa, el empuje se hace con la velocidad del cuerpo: un guion lo atrapa.
- Rendimiento: un `CharacterBody2D` y dos o tres rayos por enemigo. Se mide en el S50 (H6) con los tres a la vez.
