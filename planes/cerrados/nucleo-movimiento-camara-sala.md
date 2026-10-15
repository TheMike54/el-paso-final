CERRADO

# Núcleo: movimiento, cámara, sala, eventos, vida y guardado

Rama `feature/nucleo-movimiento-camara-sala`. Sigue `nucleo/funciones.json` en orden, desde `jugador-movimiento`
hasta donde alcance, más lo que `herramientas/` necesita para sus guiones. Aprobado por adelantado para esta
tanda (06-oct-2026) mientras siga `funciones.json`, `docs/contrato.md` y el diseño cerrado; lo que el diseño no
responde va marcado como **decisión para que Miguel confirme**.

## Extensión del formato de guiones (una sola vez)

Los guiones corren sobre la escena principal y el CI corre todos con la misma orden, así que una sala de prueba
necesita que el guion diga qué escena cargar. Se diseña ahora completa y cada clave entra con la funcionalidad
que la usa:

| Dónde | Línea | Qué hace | Entra con |
|---|---|---|---|
| `.guion` | `escena <ruta res://>` | Al empezar, el puerto cambia a esa escena. El cuadro 1 es el primer cuadro de física con la escena ya cargada | `jugador-movimiento` |
| `.esperado` | `valor <nodo> <propiedad> <valor> [tolerancia]` | Lee una propiedad de un nodo. `<nodo>` es una ruta relativa a la escena actual (`.` es su raíz) o absoluta (`/root/...`). Número: con tolerancia (0,5 por omisión); otro valor: se compara su texto | `jugador-ataque-y-vida` |
| `.esperado` | `senal <nodo> <señal> <veces>` | Cuántas veces se emitió la señal desde el cuadro 1. El puerto se conecta en el cuadro 1, no en su `_ready`, porque ahí el nodo puede no existir todavía | `bus-eventos` |

- Por qué no se cambia la escena principal: `caja.guion` revisa `escena res://nucleo/caja_gris.tscn` y sus dos
  entradas ya pasan. Cuando `menu-desarrollo` cambie la escena principal, `caja.guion` lleva `escena` en ese
  mismo bloque.
- Por qué el cambio se lanza en el primer cuadro y no en `_ready`: en el `_ready` del puerto la escena principal
  todavía no existe (el puerto nace dentro de un autoload). Los cuadros del guion no cuentan hasta que
  `current_scene.scene_file_path` es la ruta pedida, así el `.esperado` no depende de cuánto tarda en cargar.
- Una ruta inexistente o que no es escena hace fallar el guion.

## Decisiones

1. **Salas de prueba en `herramientas/salas/`** (decisión para que Miguel confirme). El preset de publicación ya
   excluye `herramientas/`, así que la zona de pruebas no viaja en el paquete sin tocar `export_presets.cfg`.
   El núcleo no las conoce. Es reversible: moverlas cambia solo rutas en los guiones.
2. **La sala crea al jugador.** `nucleo/sala.gd` (`class_name Sala`) instancia `nucleo/jugador.tscn` en la puerta
   de llegada o, si no hay, en su nodo `Entrada`. Así una sala nueva no copia al jugador y el cambio de sala no
   duplica nada. El estado que debe sobrevivir al cambio de sala (vidas) espera a un autoload de partida que
   todavía no existe (decisión para que Miguel confirme: hasta entonces las vidas se reinician al cambiar de
   sala).
3. **Salto** (`nucleo/jugador.gd`), todo `@export` para afinarlo en la zona de pruebas:
   - `altura_salto` en píxeles; el impulso sale de `sqrt(2 * gravedad * altura_salto)`, así la altura máxima es
     la que se escribe y no un efecto de dos números.
   - Soltar `saltar` mientras sube corta la velocidad vertical a `corte_salto` veces la actual, pero no antes de
     `ticks_minimos_salto`.
   - `ticks_coyote` y `ticks_salto_en_cola` = 3 (contrato: de 2 a 3).
   - Velocidad horizontal sin aceleración, como la caja gris; caída con tope `velocidad_caida_max`.
   - Valores iniciales (decisión para que Miguel confirme, la sensación la prueba él): altura 5 cuadros
     (200 px; un primer borrador decía 140, menos que el personaje de 160 px), gravedad 2400 px/s², corte 0,4,
     mínimo 4 ticks, velocidad 360 px/s.
4. **Cámara**: `Camera2D` hija del jugador con suavizado; la sala le pasa sus límites (`limites: Rect2` exportado)
   y la cámara no muestra nada fuera. Una sala más chica que la pantalla queda centrada por los límites del
   motor (sin comprobar en ventana).
5. **Capas de fondo**: nodos `Parallax2D` dentro de la sala, con `scroll_scale` < 1 para el fondo y > 1 para el
   frente. Para que no haya huecos, cada capa cubre la sala más el margen que su desplazamiento necesita.
6. **Puertas**: `nucleo/puerta.gd` (`Area2D`, `class_name Puerta`) con `id`, `sala_destino` (ruta) y
   `puerta_destino`. Al entrar el jugador, la sala guarda el id de llegada en una variable estática de `Sala` y
   cambia de escena. No hace falta autoload para esto (decisión para que Miguel confirme). El jugador aparece en
   el punto `llegada` de la puerta destino, fuera de su área, para no rebotar.
7. **Bus de eventos**: autoload `Eventos` (`nucleo/eventos.gd`) con las señales de la lista del diseño: jugador
   dañado, jugador muerto, descanso en banco, enemigo golpeado, habilidad obtenida, jefe vencido y cambio de
   sala. Va antes de `Arranque` en `[autoload]`.
8. **Ataque y vida**: ataque con un área delante del jugador unos ticks; lo golpeable lleva el componente
   `Golpeable` y el daño por contacto el componente `DanoContacto`. Cuatro vidas, invulnerabilidad breve y
   retroceso al recibir daño, y al llegar a cero el jugador emite `jugador_muerto` y deja de responder; volver al
   banco espera a los bancos.
9. **Guardado**: `nucleo/guardado.gd` (`class_name Guardado`, funciones estáticas, sin autoload). Un sobre
   `{"version": N, "partida": {...}}`; se escribe en `<ruta>.tmp` y se renombra. Al cargar: `VALIDA`, `DANADA`
   (no se lee, no es JSON, falta un campo o tiene otro tipo), `INCOMPATIBLE` (otra versión) o `VACIA` (no hay
   archivo). La sala de prueba `herramientas/salas/sala_guardado.tscn` corre los casos en `_ready` sobre
   `user://` y deja el número de fallos en una propiedad que el guion lee con `valor`.

## Hitos

| # | Funcionalidad | Se comprueba con |
|---|---|---|
| 1 | Directiva `escena` + `jugador-movimiento` | `validar.ps1`; `jugador_movimiento`, `jugador_salto_corto`, `jugador_coyote` y `jugador_salto_en_cola` en `GUION OK`, y cada uno falla con su regla apagada |
| 2 | `camara-sala` | `validar.ps1`; prueba manual en `docs/pruebas.md` |
| 3 | `capas-fondo` | `validar.ps1`; prueba manual en `docs/pruebas.md` |
| 4 | `cambio-de-sala` | `cambio_de_sala.guion` |
| 5 | `bus-eventos` | `bus_eventos.guion` (clave `senal`) |
| 6 | `jugador-ataque-y-vida` | `jugador_ataque_y_vida.guion` (claves `valor` y `senal`) |
| 7 | `guardado` | `guardado.guion` (clave `valor` sobre la sala de guardado) |
| 8 en adelante | `controles-tactiles`, `menu-desarrollo`, `pausa-y-atras`, `entrada-control` | Se programan y quedan con `"pasa": false` y su prueba manual |

`revisor` en los hitos 1, 5 y 7 (física del jugador; autoload, bus y `project.godot`; guardado) y antes de cerrar.

## Avance

- Hito 1 cerrado el 06-oct-2026: `validar.ps1` y los 5 guiones en verde; cada regla del salto apagada hace
  fallar su guion. Revisor: dos fallos de documentos (altura del plan, retraso de entradas del contrato),
  corregidos.
- Hito 2 (`camara-sala`) programado el 06-oct-2026: `Camara` en `jugador.tscn`, `Sala.limites`, sala
  `herramientas/salas/sala_camara.tscn` de 3200 × 1440. Los escalones de esa sala son atravesables desde abajo
  (`one_way_collision`): sin eso, la escalera en diagonal choca con la cabeza al saltar. Es solo de la sala de
  prueba; si el juego tendrá plataformas así es una decisión para que Miguel confirme. Comprobado sin ventana: la
  sala carga, el jugador se detiene contra el pedestal (x=2800) y sube al pedestal (y=1240) y al escalón 2
  (y=1080). `"pasa": false` hasta la prueba manual.
- Hito 3 (`capas-fondo`) programado el 06-oct-2026: `herramientas/salas/sala_capas.tscn` hereda la sala de la
  cámara y le pone tres `Parallax2D` con franjas dibujadas por `franjas.gd`. Las claves `valor` y `senal` del
  puerto entraron aquí y no en los hitos 5 y 6: `capas_fondo.guion` usa `valor` para comprobar sin ventana que
  cada capa se desplaza en proporción a su `scroll_scale`, y así el puerto se toca una sola vez. Medido: la
  posición de una capa es el borde de la cámara por `1 - scroll_scale`. `"pasa": false` hasta la prueba manual.
- Hito 4 (`cambio-de-sala`) cerrado el 06-oct-2026: `nucleo/puerta.gd` y `.tscn`, salas de prueba A y B,
  `cambio_de_sala.guion` en verde; falla con la puerta destino renombrada y con la puerta sin cambio de escena.
  Corregido de paso en el puerto: la espera de `escena` solo vale para la primera carga (antes, un cambio de
  sala dentro del guion habría detenido la cuenta de cuadros).
- Hito 5 (`bus-eventos`) cerrado el 06-oct-2026: autoload `Eventos` antes de `Arranque`, siete señales, la sala
  emite `cambio_de_sala` al llegar por una puerta. `bus_eventos.guion` en verde; falla sin la emisión y sin una
  señal. Revisor: un fallo de documento (el validador no atrapa una puerta mal escrita), corregido. De paso: el
  puerto ya no imprime `ERROR:` al conectar señales sin argumentos (`unbind(0)`).
- Hito 6 (`jugador-ataque-y-vida`) programado el 06-oct-2026: `jugador_ataque_y_vida.guion` y
  `jugador_invulnerable.guion` en verde, cada regla apagada los hace fallar. La sala de combate lleva una pared
  detrás de los pinchos: `DanoContacto` no es sólido y, sin pared, el jugador los atraviesa durante la
  invulnerabilidad. Revisor: el retroceso abría el tiempo coyote (el tick siguiente al golpe el jugador aún
  cuenta como en el suelo); ahora no se salta durante el retroceso, con `jugador_retroceso.guion`. Aprobado en la
  segunda pasada.
- Hito 7 (`guardado`) programado el 06-oct-2026: 20 casos en verde; falla sin renombrado, sin versión y sin
  esquema. Esquema v1 (`banco`, `vidas_maximas`, `habilidades`) y «otra versión = incompatible, sin migración»:
  decisiones para que Miguel confirme. Revisor: dos fallos de documento y un caso faltante, corregidos (21 casos).
- Hito 8 (`controles-tactiles`) programado el 06-oct-2026: `nucleo/controles_tactiles.tscn`, que crea cada sala;
  18 casos de toques simulados en verde (`controles_tactiles.guion`). Decisión para que Miguel confirme: es el
  único script de `nucleo/` que lee toques (la entrada `entrada-acciones` habla de la lógica). `"pasa": false`
  hasta la prueba en el teléfono.
- Hito 9 (`menu-desarrollo`) programado el 06-oct-2026: `nucleo/menu.tscn` es la escena principal; Nueva partida y
  Continuar van a `sala_inicial` (la caja gris por ahora: decisión para que Miguel confirme); Continuar solo con
  partida `VALIDA`; la zona de pruebas (`herramientas/salas/zona_pruebas.tscn`) lista las salas de su carpeta.
  `caja.guion` lleva ahora `escena`. `menu.guion` en verde. `"pasa": false` hasta la prueba manual.
- Hito 10 (`pausa-y-atras`) programado el 06-oct-2026: `nucleo/pausa.tscn`, que crea cada sala, lee la acción
  `pausa` en `_physics_process` (el puerto no genera eventos) y atiende `NOTIFICATION_WM_GO_BACK_REQUEST`. El
  puerto corre ahora con `PROCESS_MODE_ALWAYS`. `pausa.guion` y `pausa_cerrar.guion` en verde; falla si la pausa
  no detiene el árbol. `"pasa": false` hasta la prueba en el teléfono.
- Hito 11 (`entrada-control`) programado el 06-oct-2026: un evento de control junto a cada tecla en
  `project.godot`, según la tabla del contrato; `entrada_control.guion` coteja los 13 con el InputMap. `"pasa":
  false` hasta la prueba con un control conectado.
- Cerrado el 06-oct-2026: las 11 funcionalidades están programadas. Cinco tienen `"pasa": true` con su guion; las
  seis restantes esperan su prueba manual, que está en `docs/pruebas.md`, y siguen en `nucleo/funciones.json`.
