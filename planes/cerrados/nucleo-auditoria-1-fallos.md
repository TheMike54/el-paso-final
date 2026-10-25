CERRADO

# Auditoría, paso 1: los tres fallos y su cobertura

Paso 1 de `nucleo-auditoria-codigo.md`, aprobado con su orden el 17-oct-2026. Ids del anexo: G1 (R5), J1 y J8 (R1), P1
(R4), H1 a H3 (R6) y E3 (R3). Fuera de lo que se arregla aquí, el juego no cambia.

## Qué se hace (una pieza por agente, en este orden)

1. **Pruebas que fallan primero.** Las pruebas se escriben antes que los arreglos y deben fallar con el código de
   hoy.
   - `prueba_base.gd` gana `_presionar_boton(boton)`: pulsa juntas todas las acciones del InputMap que comparten
     ese botón del control. La tabla de botones compartidos ya está en `prueba_control.gd`.
   - Tres casos nuevos:
     1. cerrar la tienda y la estación con B (`volver` y `curar` en el mismo tick) no cambia
        `Jugador.toques_poder` ni empieza la curación;
     2. atacar mientras se mantiene `curar`, antes de que empiece la curación, deja `Ataque.monitoring` en false
        cuando empieza (guion `jugador_curar_atacar` o caso en una prueba);
     3. cada evento que `Sonido` toca existe como campo de `FichaSonidos`, con una lista `Sonido.EVENTOS` como
        fuente única.
2. **Cierre con B.** Los menús que quitan la pausa al cerrarse se procesan después del jugador, sin importar dónde
   cuelguen: `process_physics_priority` mayor que el del jugador, porque la lógica va en `_physics_process`
   (`classes/class_node.rst:1607`: el número más bajo corre primero). Aplica a `MenuTienda`, `MenuEstaciones`,
   `Pausa` y `MarcoMenus`, y a cualquier otro que quite la pausa. El valor va en una constante con nombre.
3. **Ataque durante la curación.** `_cortar_lo_que_empuja` se parte en `_cortar_empujes()` y `_cortar_ataque()`. Las
   seis listas a mano de «qué se corta» pasan a llamarlos: aterrizaje duro, picada, daño, peligro, sentarse y
   hablar. `_empezar_curacion` corta el ataque. Lo demás no cambia: el mismo orden y los mismos ticks.
4. **Sonidos del muro y del portón.**
   - `FichaSonidos` gana los campos `muro_roto` y `porton`, vacíos, porque todavía no hay archivo de sonido.
   - `Sonido.EVENTOS` lista los eventos que conecta.
   - `tocar()` avisa con `push_warning` si un evento no es campo de la ficha.
   - Se corrige el contrato si dice algo distinto.
5. **Botones táctiles con control conectado.** `ControlesTactiles` no vuelve a mostrarse al entrar a una sala si lo
   último que se usó fue un control (`UltimaEntrada.con_control`).

## Hitos

1. Las pruebas nuevas fallan con el código de hoy: se pega la salida.
2. Tras los arreglos, pasan:
   - `.\herramientas\validar.ps1` → `OK  VALIDACION ... fallos=0`;
   - los 150 guiones y los nuevos en verde;
   - ningún `.esperado` existente cambia, salvo que el arreglo lo exija, con el porqué escrito aquí.
3. Un `docs/errores/2026-10-17-<tema>.md` por cada fallo: cierre con B, ataque en la curación, sonidos sin campo.
4. `revisor` aprobado: toca el jugador y la pausa.
5. Entradas nuevas en el `funciones.json` de su bloque para los tres arreglos, con su comprobación.

## Riesgos

- `process_physics_priority` cambia el orden de los menús frente a todo lo demás, no solo frente al jugador. Hay que
  revisar que la caja de diálogo y el fundido no dependan de ir antes.
- Cortar el ataque en las seis salidas puede cambiar un caso que hoy funciona por casualidad. Los guiones de ataque,
  parry, picada y banco lo atrapan.

## Avance

- **17-oct, consulta del cierre con B** (agente investigador). Se eligió la prioridad de física (A), descartando
  otras tres opciones:
  - quitar la pausa en diferido rompe la regla «cerrado implica sin pausa»;
  - si algo vuelve a pausar en el mismo tick, ese cambio diferido lo deshace;
  - un parche en el jugador solo cubre las acciones que se programen ahí;
  - `Input.action_release` no está documentado para `just_pressed`.

  Cómo se aplica:
  - constante `MarcoMenus.PRIORIDAD_FISICA = 100`, positiva porque `puerto_depuracion.gd` ya usa -100;
  - se fija en el `_ready` de `MarcoMenus`, `MenuTienda`, `MenuEstaciones` y `Pausa`;
  - la propiedad no se hereda a los hijos (`classes/class_node.rst:1366-1373`).

  Pruebas que se suman:
  - una regla estructural: todo nodo de `pantalla_encima` y `Pausa` lleva una prioridad mayor que la del jugador;
  - B con la Pausa y el Marco abiertos, no solo con la tienda y la estación.

  Riesgo nuevo, sin comprobar: LB es `mapa_rapido` y `pagina_anterior` a la vez. Cerrar el marco con LB sostenido
  podría abrir el mapa rápido (`pantalla_mapa.gd:69`). Se suma a las pruebas que fallan primero: si falla, es un
  cuarto fallo y entra a este paso; si pasa, queda como cobertura.
- **17-oct, pieza 1 hecha** (pruebas que fallan primero). La sesión principal la verificó de nuevo:
  - `validar.ps1 -SinImportar` → `OK  VALIDACION archivos=248 fallos=0`;
  - todos los guiones: `RESUMEN total=151 OK=145 MALOS=6`. Los seis rojos son solo los casos nuevos:

  | Guion | Fallos | Qué mide |
  |---|---|---|
  | `tienda` | 3 | orden de proceso; B con un toque; B mantenido |
  | `estaciones` | 3 | lo mismo con el menú de estaciones |
  | `marco` | 2 | orden de proceso; LB sostenido abre el mapa rápido |
  | `sonido` | 1 | faltan `muro_roto` y `porton` |
  | `controles_tactiles` | 1 | E3 |
  | `jugador_curar_atacar` | 1 | `Ataque monitoring` en true al empezar la curación |

  - Con la Pausa y el Marco, B no falla hoy: los protege el orden de `add_child`. Queda cubierto por la regla de
    orden.
  - **Cuarto fallo confirmado: LB.** Cerrar el marco con LB sostenido muestra el mapa rápido.
    `pantalla_mapa.gd:69` lee `is_action_pressed(mapa_rapido) and not paused`. Entra como pieza 6; su diseño se
    consulta antes.
  - Cinco `.esperado` cambiaron, pero solo en la cuenta de `casos` (tienda 23→31, estaciones 20→23, marco 32→35,
    sonido 9→11, controles_tactiles 34→36). Es inevitable al sumar casos a una prueba que ya existía.
  - Ayudantes nuevos en `prueba_base.gd`: `_acciones_del_boton`, `_sostener_boton`, `_presionar_boton`,
    `_procesados_antes_que` y `_b_cierra`. `docs/guiones.md` no los lista todavía: la pieza 2 lo pone al día.
  - `prueba_tactil` usa `Input.emulate_touch_from_mouse`, porque en headless no hay pantalla táctil.
  - `prueba_sonido` lee `source_code` mientras no exista `Sonido.EVENTOS`; la pieza 4 la cambia.
- **17-oct, pieza 2 hecha** (cierre con B). Verificada de nuevo:
  - `validar` → `fallos=0`;
  - `tienda`, `estaciones` y `pausa` → OK;
  - `marco` → falla solo el caso de LB;
  - todos los guiones: `total=151 OK=147 MALOS=4`, sin cambiar ningún `.esperado`;
  - la entrada `cerrar-menu-con-b-no-cura` queda en `pasa` false hasta la pieza 6, porque su comprobación incluye
    `marco`.
- **17-oct, pieza 3 hecha** (ataque en la curación).
  - Funciones nuevas en el jugador: `_cortar_empujes()` y `_cortar_ataque()`.
  - Las listas a mano eran siete, no seis; la que faltaba es `_reaparecer`.
    - Cinco cortan todo y llaman a las dos funciones.
    - El daño y `_colocar_tras_peligro` nunca cortaron el ataque y llaman solo a `_cortar_empujes()`.
    - El resultado es el mismo en cada camino.
  - `_empezar_curacion` corta el ataque.
  - Verificado: `validar` → `fallos=0`; `jugador_curar_atacar`, `jugador_curar` y `parry` → OK. El agente corrió 67
    guiones relacionados → 67 OK, y todos → `total=151 OK=148 MALOS=3`.
  - Lo que el agente dejó abierto, decidido por la sesión principal:
    1. Un golpe no corta el ataque a medias: **se deja así**. Cambiarlo cambiaría el combate, y el juego no debe
       cambiar. Si se quiere como Hollow Knight, es una decisión aparte de la persona.
    2. La curación todavía tiene su propia lista de empujes.
    3. `_morir` corta el ataque con dos líneas sueltas.

    Los puntos 2 y 3 pasan al paso 9 (T7, refactor del jugador), donde se miden con guiones.
- **17-oct, pieza 4 hecha** (sonidos).
  - `FichaSonidos` gana `muro_roto`, `porton` y `campos_de_efecto()`.
  - `Sonido.EVENTOS` es la lista que lee la prueba. Las conexiones siguen a mano, porque cada señal trae argumentos
    distintos.
  - `tocar()` avisa con `push_warning`. El agente comprobó aparte que esa línea no hace fallar al validador.
  - La prueba compara en los dos sentidos los `tocar(&"...")` del código con `EVENTOS`.
  - Verificado: `validar` → `fallos=0`; `sonido` → 11 casos, 0 fallos. Todos los guiones, según el agente:
    `total=151 OK=149 MALOS=2`.
- **17-oct, pieza 5 hecha** (E3).
  - `ControlesTactiles.deben_verse(tactil, con_control)` es la única regla que decide si se ven; la usan `_ready` y
    `procesar`.
  - Verificado: `validar` → `fallos=0`; `controles_tactiles` → 36 casos, 0 fallos. Todos los guiones, según el
    agente: `total=151 OK=150 MALOS=1`; el que falla es `marco`, por LB.
  - Queda sin comprobar: `UltimaEntrada.anotar` cuenta como control cualquier tecla, incluido el volumen del teléfono
    si Android lo entrega como tecla. Si es así, tras subir el volumen la sala siguiente nacería sin botones hasta
    el primer toque. Se deja así, porque un toque los muestra. Se prueba en el teléfono con adb en el paso 11; si
    pasa, entra como arreglo.
- **17-oct, consulta y pieza 6 hechas** (LB y mapa rápido).
  - **Consulta.** El fallo es de `pantalla_mapa.gd`, no del jugador. El jugador ya inicia la curación por flanco:
    con `just_pressed` pone `_ticks_poder` en 0. Se descartaron dos opciones:
    - `Input.action_release`, sin documentar con el botón físico pulsado;
    - un mecanismo general de «acciones a soltar», que también se comería el movimiento sostenido.
  - **Arreglo.** `_armado` en `pantalla_mapa.gd`: solo se arma por flanco con el juego andando. En `_ready` se arma si
    la acción ya está sostenida, porque cada sala crea su `PantallaMapa` (`nucleo/sala.gd:131-134`). Así, cruzar una
    puerta con LB sostenido sigue mostrando el mapa.
  - **Casos nuevos en `marco`** (35 → 39):
    - abrir el marco en la página Mapa desde el mapa rápido;
    - cerrar la Pausa con `mapa_rapido` sostenido;
    - soltar y volver a pulsar;
    - una `PantallaMapa` nueva con la acción sostenida.

    Mutación del agente: con la línea vieja fallan 3 casos; sin el armado en `_ready`, 1.
  - **Efecto a propósito.** Cerrar la tienda o la estación con LB sostenido tampoco muestra ya el mapa. Es la misma
    clase de fallo.
- **17-oct, pasada de la sesión principal tras las seis piezas:** `validar.ps1` completo → `OK  VALIDACION
  archivos=248 fallos=0`; todos los guiones → `RESUMEN total=151 OK=151 MALOS=0`.
- **17-oct, revisor: aprobado.** Volvió a correr `validar` y diez guiones del paso: todos OK.
  - Pulsar `pausa` y `mapa_rapido` en el mismo tick muestra el mapa rápido un cuadro antes de la Pausa. Se acepta:
    hacen falta dos pulsaciones a la vez y dura un solo cuadro.
  - Corrección: `class_node.rst:1366-1373` no dice nada sobre herencia. Que la prioridad no pasa a los hijos sigue
    siendo cierto, porque de esas propiedades solo `process_mode` se propaga, pero esa cita no lo respalda.
- Paso cerrado el 17-oct-2026.
