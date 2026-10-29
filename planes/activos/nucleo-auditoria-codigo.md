ACTIVO

# Auditoría del código (17-oct-2026) y tandas de arreglos

Pedido por la persona el 17-oct-2026: auditar el código de la base del juego (buenas prácticas de Godot 4.7,
redundancia, código muerto y lo técnico que conviene optimizar) antes de seguir construyendo encima. Este documento
junta lo encontrado y propone los arreglos en tandas del tamaño de un PR; nada se programa sin su aprobación.

## Alcance y decisiones de la persona (17-oct)

- Se auditó el árbol de trabajo de `feature/nucleo-enemigos-moviles` del 17-oct-2026, sin commits todavía. Los
  números de línea son de ese árbol y se moverán con el rebase del domingo 18-oct: por eso cada hallazgo nombra
  también la función, la constante o la señal.
- Dimensiones: buenas prácticas de Godot 4.7 (las de las skills `gdscript4`, `fisica-2d`, `ui-tactil` y
  `rendimiento-gama-baja`), arquitectura y contrato, redundancia, código muerto, tamaño y complejidad, rendimiento en
  gama baja, robustez, escenas y recursos, y consistencia.
- Fuera del alcance: arte, diseño del juego, documentación y la configuración de Claude.
- `herramientas/` se auditó solo en redundancia, código muerto y cobertura.
- Los arreglos van en una rama aparte, `chore/auditoria-codigo`, después de fusionar el PR del domingo.
- Método:
  1. Medición automática de solo lectura: funciones largas, símbolos y señales sin uso, bloques repetidos, números
     repetidos y dependencias entre bloques.
  2. Seis revisiones de solo lectura, una tras otra:
     - jugador y física;
     - menús;
     - entrada, HUD y mapa;
     - partida y servicios;
     - sala y mundo;
     - herramientas.
  3. Verificación en la sesión principal. Los tres fallos de abajo se reprodujeron con una prueba escrita para la
     auditoría, corrida en una copia del proyecto; otros siete hallazgos se releyeron en el código.

## Resultado

Hay unos 210 hallazgos:
- 3 fallos reales confirmados;
- 1 dependencia frágil;
- unos 90 de gravedad media;
- unos 120 menores.

No hay código muerto a nivel de archivo: cada escena, script y guion tiene uso. Sí hay símbolos sueltos sin uso.
El código ya cumple lo básico de las skills:
- tipado completo y ningún `:=`;
- ningún `load()` ni `get_node` en el tick;
- capas puestas con `Capas.poner`;
- foco dado solo con `Tema.dar_foco`;
- guardado con temporal y renombrado;
- `static var` reiniciados.

Lo que más pesa:
- piezas repetidas que piden una base común:
  - los objetos con los que se habla (cinco casos);
  - la confirmación Sí / No (cuatro);
  - el fondo de los menús (siete);
  - el rayo contra el escenario (siete);
- dos archivos que hacen demasiado: `jugador.gd` (1,394 líneas, con la cámara dentro) y `configuracion.gd` (713);
- huecos de cobertura: las pruebas pulsan una acción cuando un botón real dispara dos, y los guiones solo leen el
  estado del último cuadro.

### Fallos confirmados

1. **Cerrar la tienda con B también cuenta como `curar`.**
   - Causa: B es `volver` y `curar` a la vez (`button_index` 1 en `project.godot`). El menú (`MenuTienda`, hijo de
     `Tienda`) se procesa antes que el jugador: la `Tienda` viene en el `.tscn` de la sala y el `Jugador` lo agrega
     `Sala._ready` al final. `MenuTienda.cerrar()` quita la pausa y, en ese mismo tick, `Jugador._boton_poderes` ve
     `curar` recién pulsado.
   - Reproducción: en `sala_tienda`, abrir la tienda; pulsar `volver` y `curar` en el mismo tick, dos ticks, y
     soltar. `toques_poder` pasó de 0 a 1. Con la bola, se lanzaría.
   - La estación (`MenuEstaciones`, hijo de `Estacion`) tiene la misma posición en el árbol: es el mismo fallo, pero
     no se reprodujo.
   - Lo mismo con la pausa y el marco: hoy no falla, porque se agregan después del jugador. Es una dependencia
     frágil del orden de `add_child` en `Sala._ready` que no está escrita en ningún lado.
   - El plan `nucleo-tienda-gis` rehace la interfaz de la tienda, no su cierre: no lo cubre.
2. **Atacar mientras se mantiene `curar` deja el golpe activo durante toda la curación.**
   - Causa: `_empezar_curacion` no corta el ataque, y `_mover` sale por `_boton_poderes` antes de llegar a
     `_atacar()`, así que `_ticks_atacando` y `Ataque.monitoring` quedan congelados. `intentar_parar` sigue
     aceptando parry y `_draw` sigue dibujando el golpe.
   - Reproducción: en `sala_curar`, con una vida menos e Inspiración; mantener `curar`, atacar al tercer tick y
     seguir manteniendo. A los 10 y a los 30 ticks: `curando` true, `monitoring` true, `_ticks_atacando` 1.
   - Causa de fondo: seis listas a mano de «qué se corta» (aterrizaje duro, picada, daño, peligro, sentarse,
     hablar), y cada una omite algo distinto.
3. **Romper un muro y abrir un portón nunca suenan.**
   - `Sonido` escucha `muro_roto` y `porton_abierto` y llama `tocar(&"muro_roto")` y `tocar(&"porton")`, pero
     `FichaSonidos` no tiene esos campos. `efecto()` usa `get()`, que devuelve `null` sin avisar.
   - Aunque se agregue el archivo de sonido, no hay dónde ponerlo. `docs/contrato.md` («Ajustes y vibración», la
     línea de `Sonido`) dice que sí suenan.
   - Comprobado leyendo `ficha_sonidos.gd` y `nucleo/sonidos/sonidos_prueba.tres`.

Cuando se arregle cada uno se escribe su `docs/errores/AAAA-MM-DD-tema.md`, en el mismo cambio (regla del
`CLAUDE.md` raíz).

## Tandas propuestas (ordenadas por riesgo)

Cada tanda es un PR de `chore/auditoria-codigo` o va en su propia rama si crece. Los ids son los del anexo. Lo que
toca `jugador.gd`, el guardado, el contrato o los autoloads es punto crítico: lleva `revisor` y la corrida de todos
los guiones.

| Tanda | Qué | Ids | Riesgo | Se comprueba con |
|---|---|---|---|---|
| T1 · Fallos y su cobertura | 1. `_presionar_boton(boton)` en `prueba_base.gd`, que pulse todas las acciones del InputMap que comparten el botón (la tabla ya está en `prueba_control.gd`). 2. Cierre de menús sin depender del orden: `process_priority` en los menús, `Pausa` y `Marco`, o un aviso de «cerré este tick» que el jugador respete. 3. `_cortar_ataque()` y `_cortar_empujes()` en el jugador, y que las seis listas los llamen. 4. `FichaSonidos` con todos los eventos de `Sonido` (`Sonido.EVENTOS`), y una prueba que exija un efecto para cada uno. 5. Los botones táctiles no reaparecen al entrar a una sala si se usa un control (E3). | G1, J1, J8, P1, H1-H3, E3 | Bajo; crítico por el jugador | Guiones nuevos: cerrar tienda y estación con B, con `toques_poder` igual; `jugador_curar_atacar`, con `Ataque.monitoring` false; prueba de `Sonido` en verde. `validar.ps1`, todos los guiones y `revisor` |
| T2 · Piezas comunes de bajo riesgo | `Capas.rayo_a_escenario` (J10), `Tema.fondo_menu` y `Tema.VELO` (M2), `Tema.texto_centrado` (E14), `Partida.punto_de_mochila` (E15), `Guardado.entero` (P14), `_velocidad_de_salto` y `_recuperar_aire` (J5, J6), y `LineaDialogo.nueva` con `FichaPregunta.lineas_para` (W6) | J5, J6, J10, M2, E14, E15, P14, W6 | Bajo | `validar.ps1` y todos los guiones sin cambiar ningún `.esperado`; `git diff --stat` con menos líneas |
| T3 · Guardado y bus | Prueba que compare `a_diccionario().keys()` con el esquema (P5). Gancho `_convertir(partida, desde)` antes de la primera subida de `VERSION` (P6). Respaldo también al descansar (P7). `guardar()` sin la ruta antigua por omisión (P2). Una sola forma de autoguardar (P3). Señales `amuletos_cambiados` y `boton_ensenado` en lugar del sondeo (P4) | P2-P7 | Medio; crítico (guardado y bus) | Prueba nueva de esquema; guiones `guardado`, `ranuras` y `estado_partida`; `revisor` |
| T4 · Base `Interactuable` | Base común para `Npc`, `RetoPreguntas`, `Mochila`, `Banco` y `EntregaRecompensas`; `Tienda` y `Estacion`, cuando cierre `nucleo-tienda-gis`. Arregla de paso la regla de congelado que falta en el banco y la entrega (W4) y la caja gris doble del NPC y el reto (W5). Conserva los nombres que leen los guiones (`cerca`, `caja`, `menu`, `etapa`, `indice`, `sorteadas`, `destino`, `bolsa`) | W4, W5, W7, m1, m3 | Medio | Guiones de diálogo, reto, mochila, banco, entrega, tienda y estaciones sin cambios; `git diff --stat` |
| T5 · Menús | La pieza Sí / No, con el foco inicial como parámetro (M1, junto con el plan `nucleo-tienda-gis`). `PaginaMarco` como base en lugar del `call` dinámico (M3). `Tema.encabezado` con el ícono (M4). Partir `configuracion.gd` en `PantallaBrillo`, `PanelAudio` y `enum Panel` (M6, M7). Lista de amuletos con desplazamiento (M10). Variaciones del tema en lugar de overrides (M15) | M1, M3-M7, M10, M15 | Medio | `menu_configuracion`, `marco`, `ranuras`, `pausa_foco`; capturas a 1280×720 y 1600×720; prueba en el teléfono de la persona |
| T6 · Entrada | Un solo origen de «qué dispositivo se usa» (`enum` y `con_control()`), una sola tabla de nombres de botón en `Mando` y la señal `dispositivo_cambiado` en lugar del `_process` de cada `IconoBoton` (E7-E11). Soltar todos los dedos al perder el foco de la app y al reutilizarse un dedo (E1, E2). Decidir si los botones táctiles siguen activos bajo un menú (E5) | E1, E2, E5, E7-E11 | Medio | `controles_tactiles`, `controles_configurables`, `entrada_control`, guiones de íconos; prueba en el teléfono: soltar el dedo con la app en segundo plano |
| T7 · Jugador por dentro | Partir `_mover` y `_atacar` sin cambiar el orden de las ramas (J3, J4). Sacar la cámara a un script del nodo `Camara` (`_seguir_con_camara`, `_colocar_camara`, `_objetivo_camara`, `_amortiguar_y` y el temblor), con `Jugador.temblar()` como delegado. No se propone una máquina de estados: las prioridades ya están ordenadas y hay estados que conviven | J2-J4, J7, J16-J19, J22 | Medio-alto; crítico | Todos los guiones `jugador_*`, `carrera_*`, `camara_*` y `parry*`; `revisor` |
| T8 · Herramientas | Validador en dos piezas: el recorrido, y reglas puras que se prueban con nodos rotos en memoria (H5-H10). `_aislar_partida` y `_restaurar_partida` en la base (H16). Partir los `_ready` largos (H17, H18). Línea opcional `en <cuadro> valor ...` en el `.esperado` (H4). CI, `validar.ps1` y hook revisan lo mismo (H12-H14). Toda `prueba_*` en `OCULTAS` (H15) | H4-H18, H22 | Medio | `validar.ps1` en verde antes y después; mutaciones del validador; todos los guiones |
| T9 · Limpieza | Código muerto: `ComportamientoEnemigo.hacia_donde_mira`, `Cortable.cortado`, `Tema.FOCO`, `Configuracion._volver_brillo`, `Ranuras._volver`, las señales sin oyente `portones_abiertos`, `abierto`, `se_rompio` y `respondida`, y los tres estilos iguales de `BotonValor`, cada uno con su línea del contrato. Cabeceras de más de 4 líneas, `uid` que faltan en `cortable.tscn`, `pantalla_mapa.tscn`, `objeto_mapa.tscn` y `editor_controles.tscn`, comentarios que ya no dicen lo que hace el código, números sueltos a constantes | J13-J15, J33, M17-M19, M43, E43, W10, m13, m14 y los menores | Bajo | `validar.ps1` y todos los guiones |
| T10 · Rendimiento (medir antes) | Solo con una medida en el S50 antes y otra después (`rendimiento-gama-baja`). Candidatos: el pasto y otros nodos que procesan sin trabajo (J11, m7); `get_overlapping_bodies()` por tick (J12); el `_process` de los controles táctiles y de los íconos (E4, E11); el redibujo de las monedas del HUD (E12); el shader de Brillo que se recompila (M8); la captura de pantalla en cada pausa (M9); el `_draw` de `EstiloGis` (M14); las plantas fuera de pantalla (P30) | J11, J12, E4, E11-E13, M8, M9, M14, P30 | Bajo | FPS en el S50 con el APK de desarrollo (`docs/pruebas.md`, «Rendimiento en el teléfono») |

Orden sugerido: T1 → T2 → T9 → T3 → T4 → T5 → T6 → T8 → T7, con T10 cuando haya medida. T1 es lo único con fallos
que ya se ven en el juego.

## Hitos

1. H1 · T1 aprobada y programada:
   - los dos guiones nuevos y la prueba de `Sonido` fallaban antes y pasan después;
   - `validar.ps1` → `OK  VALIDACION ... fallos=0` y todos los guiones en verde;
   - `revisor` aprobado;
   - un `docs/errores/` por cada fallo.
2. H2 · Cada tanda siguiente: el mismo ciclo (plan corto, código, `validar.ps1`, guiones y, si es crítico, `revisor`).
   Ningún `.esperado` cambia en T2 ni en T9.
3. H3 · Cerrar este plan cuando T1 a T9 estén hechas o descartadas por la persona; lo descartado queda anotado aquí
   con su porqué.

## Decidido el 17-oct-2026 (la persona)

- Orden de ejecución en 12 pasos:
  1. T1, los tres fallos;
  2. la red de pruebas (parte de T8, más la auditoría de pruebas con mutaciones);
  3. código muerto;
  4. T2;
  5. T3;
  6. T6;
  7. `nucleo-tienda-gis` con T5;
  8. T4;
  9. T7;
  10. el resto de T8;
  11. T10;
  12. cierre, con el revisor de la rama y una auditoría de comprobación.
- Lo cosmético se arregla en cada paso, en los archivos que ese paso ya toca.
- Este documento queda como índice. Cada paso tiene su plan corto en `planes/activos/`: lo escribe y lo ejecuta Claude
  sin pedir otra aprobación, porque el orden aprobado cuenta como aprobación.
- Sin PR el 18-oct: un solo PR para todo y los commits al final.
- Las pruebas en el teléfono las corre Claude por `adb`: FPS y lo que se pueda medir. La sensación al tocar se le pide
  a la persona al final.
- El plan `nucleo-tienda-gis` queda aprobado, con lo recomendado en sus tres puntos: íconos de gis por tipo, el HUD
  sobre la tienda y la lista sola cuando no hay mapa.
- El cierre con B se protege con `process_priority`.
- La bola corta el pasto.
- Los botones táctiles quedan inactivos mientras hay un menú abierto.
- `hacia_donde_mira`: lo decide Claude con el mejor criterio técnico, tras consultar a un agente. La recomendación es
  que el ataque se refleje solo según `mirando`.
- Señales sin oyente: se quitan `Cortable.cortado`, `Palanca.portones_abiertos` y `RetoPreguntas.respondida`. Se
  quedan `Porton.abierto` y `MuroRompible.se_rompio`, cada una con un guion que la use.
- El APK de publicación sigue llevando las salas jugables de la zona de pruebas. Que salgan las pruebas de código
  (H25) se replanteó el mismo día: ver «Por decidir».
- El jugador se refactoriza (T7). La prueba de sensación se hace después.
- Ni máquina de estados para el jugador ni partir `Partida`: J2 y la propuesta de partir `Partida` quedan
  descartados.
- Regla de todos los pasos: el juego debe seguir haciendo exactamente lo mismo. Solo cambia lo aprobado:
  - los tres fallos;
  - los botones táctiles con control conectado (E3);
  - la bola corta el pasto;
  - los botones táctiles inactivos bajo un menú.
- Cómo se trabaja:
  - Cada cosa la hace un agente, uno a la vez y nunca en paralelo.
  - Antes de tomar una decisión de diseño, Claude consulta a otro agente cómo la ve.
  - La sesión principal valida con `validar.ps1`, los guiones y, en lo crítico, el `revisor`.
  - Commits: uno solo al final, en esta rama (reemplaza al bloque 12).
- Paso 13, nuevo, después de todos los arreglos: auditoría de la utilidad de las pruebas.
  - Se rompe el código a propósito en una copia del proyecto (unas 60 mutaciones del núcleo) y se anota qué prueba
    atrapa cada una.
  - Se borran las pruebas que no atrapan nada ni cubren lógica que pueda romperse, y se agregan las que falten.
  - Cada fallo de una prueba durante el trabajo se anota en el plan de su paso.

## Avance de los pasos

| Paso | Plan | Estado | Ids cerrados |
|---|---|---|---|
| 1 | `planes/cerrados/nucleo-auditoria-1-fallos.md` | Cerrado el 17-oct, con el revisor aprobado, `validar` sin fallos y 151 de 151 guiones en verde | G1, J1, P1, H1, H2, H3, E3; J8 en parte; y un cuarto fallo, LB, que abría el mapa rápido |
| 2 | `planes/cerrados/nucleo-auditoria-2-pruebas.md` | Cerrado el 17-oct, con el revisor aprobado, `validar` sin fallos y 151 de 151 guiones en verde. Falta abrir la zona de pruebas en el teléfono, que pasa al paso 11 | H4, H14, H15, H16, H20, H25 |
| 3 | `planes/cerrados/nucleo-auditoria-3-muerto.md` | Cerrado el 17-oct: `validar` sin fallos y 151 de 151 guiones en verde; sin revisor, porque no toca puntos críticos | J13, M17, M18, W10, más `MuroRompible.golpeado` y `PantallaMapa._mas` |
| 4 | `planes/cerrados/nucleo-auditoria-4-piezas-comunes.md` | Cerrado el 18-oct, con el revisor aprobado y 151 de 151 guiones en verde | J5, J6, J10, M2, E14, E15, P14, W6 |
| 5 | `planes/cerrados/nucleo-auditoria-5-guardado.md` | Cerrado el 18-oct, con el revisor aprobado. La persona descartó P3, P4 y P6 y dejó P7 como está, y un agente aparte lo comprobó. Falta ver en Android que `rename_absolute` reemplace el destino, que pasa al paso 11 | P2, P5; P3, P4, P6 y P7 descartados |
| 6 | `planes/cerrados/nucleo-auditoria-6-entrada.md` | Cerrado el 18-oct, con el revisor aprobado tras corregir un texto, `validar` sin fallos y 151 de 151 guiones en verde. Quedan abiertos para la persona: unificar E10, y el dedo apoyado que se suelta al abrir un menú | E1, E2, E5, E7, E8, E9, E10 (extraída), E11 |
| 7 | `planes/cerrados/nucleo-auditoria-7-menus.md` | Cerrado el 18-oct. Lo hecho: `nucleo-tienda-gis` hasta H4 (confirmación compartida, cobro, tienda, viaje rápido) y la pausa como Silksong. Revisor aprobado en las piezas 3, 5 y 6 y en el cierre. `validar` sin fallos y 151 de 151 guiones en verde. Falta H5, la prueba con el dedo en el teléfono | M1, M3, M4, M6, M7, M10, M15; M5 descartado con su porqué |
| 8 | `planes/cerrados/nucleo-auditoria-8-interactuable.md` | Cerrado el 18-oct, con el revisor aprobado, `validar` sin fallos y 151 de 151 guiones en verde. Los siete objetos con interacción heredan de `Interactuable`. W4 se arregló como fallo, con su `docs/errores/` y un caso que falla con el código viejo | W4, W5, W7, m1, m3 |
| 9 | `planes/cerrados/nucleo-auditoria-9-jugador.md` | Cerrado el 18-oct, con el revisor aprobado, `validar` sin fallos y 151 de 151 guiones en verde. Un trazador del scratchpad comparó cuadro a cuadro 36 guiones contra el código de antes, y salieron idénticos. La cámara pasó a `CamaraJugador` | J3, J4, J7, J17, J18, J19, J22, la cámara; J16 descartado con su porqué |
| 10 | `planes/cerrados/herramientas-auditoria-10-validador.md` | Cerrado el 18-oct, con el revisor aprobado, `validar` sin fallos y 152 de 152 guiones en verde. Hay una prueba nueva del validador, con 52 casos en memoria. En una copia con 13 roturas, el validador da los mismos 25 fallos antes y después. El CI pasa por el hook `commit-msg` y exige un solo resumen | H5 en parte, H6-H13. H21 y H22 descartados. H23 llega con `chore/android-export`; H24, al paso 11 y a la persona; H17-H19, al final del paso 13 |
| 11 | — | Medido el 18-oct en el S50 (el S20 no estaba conectado), con un APK de medición armado en una copia del scratchpad que entra a cada sala con un guion. En el menú, las salas de recursos, enemigos y combate, el mapa rápido, la caja gris y la zona de pruebas: media de 59,5 a 59,7 FPS y p5 de 58 a 59, con 137-141 MB de PSS. Ningún candidato baja de la regla (media ≥ 59 y p5 ≥ 55): no se cambió nada. Lo único que baja es Brillo abierto desde la pausa (media 56-57, mínimo 40). Por decisión de la persona del 18-oct, M8 y M9 quedan pendientes, solo medidos. Por adb: `rename_absolute` reemplaza el destino en Android sin dejar `.tmp` (`RENAME casos=9 fallos=0`); la zona de pruebas abre en el APK de desarrollo; el joystick no queda pegado tras ir a segundo plano. Queda instalado el APK de desarrollo del estado actual | J11, J12, E4, E13 y M14 medidos y sin cambio. E11 ya está resuelto por el paso 6. E12 sin medida directa. M8 y M9, pendientes de la persona |

Paso 12, revisor de cierre del 18-oct. Corrió `validar` sin fallos y 152 de 152 guiones en verde. Encontró cinco
fallos:
1. **La bola no cortaba el pasto.** Estaba aprobado el 17-oct y ningún paso lo hizo. Hecho el 18-oct.
   - **El cambio:** `proyectil.gd` llama a `cortar()`, igual que el ataque, y la bola sigue su camino. Las máscaras no
     cambian: la bola ya veía el pasto.
   - **La sala:** `sala_bola` tiene dos pastos flotando, uno en el camino de la bola y otro detrás de la pared.
   - **La prueba:** el guion nuevo `poder_bola_pasto`. Con el código viejo falla (`esta_cortado obtenido=false`).
   - **Resultados:** `validar` sin fallos y 153 de 153 guiones en verde.
   - **Para que decida la persona:** de pie, la bola sale de 70 a 110 px sobre los pies y el pasto mide 48. No toca un
     pasto que esté en el mismo suelo que el jugador, así que solo corta el que está en una repisa o el que queda
     abajo de donde se lanza. Arreglarlo es otra decisión: bajar la salida de la bola o subir el pasto.
   - **`_morir`:** no se cambió por `_cortar_ataque()`, porque sus líneas no son las mismas. No pone en falso
     `_atacando_abajo` ni `_atacando_arriba`, y no reinicia `_ticks_desde_atacar`.
2. **Instrucciones de Claude editadas sin aprobación escrita.** Son líneas de `CLAUDE.md`, `herramientas/CLAUDE.md`,
   `nucleo/CLAUDE.md`, `mapa/CLAUDE.md`, `.claude/agents/Explore.md` y cuatro skills. Casi todas son de sesiones
   anteriores a esta auditoría. No se revierten: van al reporte para que la persona las apruebe o las quite.
3. **Dos entradas existentes reescritas en `nucleo/funciones.json`.** Son `configuracion-tactil` y
   `marco-menus-telefono`: «pastilla» pasó a «óvalo de gis». También van al reporte.
4. **`ESTADO.md` desactualizado.** Se reescribe al final de la tanda.
5. **Cabeceras de más de 4 líneas** en `.gd` nuevos de la rama. Hecho el 18-oct.
   - **Cuántos:** 14 archivos, de 5 a 8 líneas cada uno, quedaron en 3 o 4. Lo útil que había en la cabecera pasó a un
     comentario junto a su miembro.
   - **`validar.gd` y `controles_tactiles.gd`** volvieron al largo que tienen en HEAD.
   - **Sin cambios de código:** solo se tocaron comentarios.
   - **Ruta corregida:** la ruta vieja de `docs/errores/2026-10-13-toque-en-la-caja-elegia-la-opcion.md`.
   - **Resultados:** `validar` sin fallos y 153 de 153 guiones en verde.

Los cambios que el juego tiene y que la persona aún no decidió quedan en el reporte:
- el cobro pausa el juego;
- la tienda no tiene la franja fija;
- las ayudas del viaje rápido salen también con la lista sola;
- el dedo apoyado se suelta al abrir un menú;
- A pulsado y soltado en el mismo cuadro hace saltar al cerrar un menú.

Decidido por la persona el 20-oct, sobre las decisiones abiertas del reporte de la tanda:
- **Se quedan como están:**
  - la bola y el pasto;
  - el cobro que pausa;
  - el dedo que se suelta al abrir un menú;
  - Brillo desde la pausa (M8, M9).
- **Se hacen como se recomendó:**
  - el texto del mapa rápido vacío ocupa el ancho de la pantalla (`mapa/lienzo_mapa.gd`);
  - el aviso de `ofl.txt` se queda tal cual;
  - el tema en el fondo de la página Mapa, sin el override de letra en +/−, y sin el `font_size` repetido de
    `zona_pruebas.tscn`.
- **Después de la explicación:**
  - Hechos el 20-oct:
    - el texto del mapa vacío ya sale completo;
    - la página Mapa tiene el tema;
    - los botones +/− llevan la variación nueva `Tema.SIMBOLO` (Cabin Sketch a 96, caja de gis). El «+» pasa de
      19 a 35 px y el botón de 108 a 113 px de alto. Cabin Sketch no trae «−» (U+2212), así que se usa «–» (U+2013);
    - el `font_size` repetido de la zona se quitó, y su captura sale idéntica.
    - Resultados: `validar` sin fallos y 153 de 153 guiones en verde.
  - El salto al cerrar un menú con A: primero se dejó como estaba. Después, con la recomendación de arreglarlo, la
    persona pidió arreglarlo. Se hace como fallo, con su `docs/errores/`, un guion que falle con el código de antes y
    el revisor, porque toca el jugador.
  - La tienda se queda sin la franja fija: la fila sigue al foco.
  - Las ayudas del viaje rápido siguen saliendo también con la lista sola.
  - E10: solo ocultan los botones táctiles los botones y las teclas que hacen algo en el juego. El volumen, Atrás,
    Enter, LT y el stick derecho sin acción no los ocultan. Es lo que hace el código hoy: no se cambia nada.

Paso 13: queda pendiente por decisión de la persona del 18-oct. Se hará después, en otra tanda, con agentes pagados
con los créditos de la API, cuando el trabajo esté commiteado (los agentes de créditos solo leen y solo ven lo
commiteado). Lo que se tenía para este paso:
- las mutaciones;
- H17-H19, partir los `_ready` largos de las pruebas;
- la lista de abajo.

Pendiente para el paso 13 (cobertura):
- un guion `doble_salto_recupera`: hoy solo el pogo detecta que `_recuperar_aire` deje de devolver el doble salto;
- el borrado de `user://prueba_partida.json` en cada corrida, que hacen cinco pruebas;
- `nucleo/sala_puerta_b_pared` no terminó una vez antes de `--quit-after`, en una corrida completa del 18-oct. Pasó
  en las 4 corridas siguientes. Hay que ver si es intermitente.
- un caso que cambie el dispositivo con el árbol pausado y compruebe que el `IconoBoton` de un menú se pone al día
  (paso 6, revisor);
- si `MenuTienda`, `MenuEstaciones` o `CobroEstacion` se liberan sin `cerrar()`, quedan `paused` y el HUD en
  ALWAYS. Hoy nada lo dispara; una salida en `_exit_tree` lo cerraría (paso 7, revisor de la pieza 5).

La persona aprobó el 18-oct dos textos de instrucciones de Claude, y ya están escritos:
- la fila de los guiones en `herramientas/CLAUDE.md`, con las líneas `en <cuadro>`;
- los ejemplos de rayo de `.claude/skills/fisica-2d`, que ahora citan `Capas.rayo_a_escenario`.

Lo que el juego cambia, además de lo aprobado: cerrar un menú con `mapa_rapido` sostenido ya no muestra el mapa
rápido. Es el cuarto fallo, de la misma clase que el de B.

## Por decidir (la persona; lo recomendado va primero)

- **T1 antes o después del PR del domingo.** Recomendado: después, en `chore/auditoria-codigo`; son tres arreglos
  chicos de tipo `fix:`. La otra opción es meterlos en el PR del domingo.
- **Cómo se protege el cierre con B.**
  - Recomendado: `process_priority`, para que los menús y la pausa se procesen después del jugador sin importar
    dónde cuelguen.
  - La otra opción es un aviso de «cerré este tick» que el jugador lee.
- **`hacia_donde_mira`.**
  - Recomendado: que `ComportamientoEnemigo.atacar()` refleje el golpe con `enemigo.mirando`, antes del primer
    enemigo de `contenido/`.
  - La otra opción es borrarlo.
- **Señales sin oyente** (`Cortable.cortado`, `Palanca.portones_abiertos`, `Porton.abierto`,
  `MuroRompible.se_rompio`, `RetoPreguntas.respondida`).
  - Recomendado: quitarlas, salvo `Porton.abierto` y `se_rompio`, que un guion puede esperar en una instancia
    concreta.
- **¿La bola corta el pasto?** Hoy lo atraviesa sin cortarlo (J32). Es decisión de diseño.
- **¿Los botones táctiles de Pausa y Mapa siguen activos bajo un menú?** (E5). Hoy sí; tocar el de Pausa encima de
  Configuración la cierra.
- **Lo que viaja en el APK de publicación** (H25). Replanteado por la persona el 17-oct-2026: fuera las pruebas de
  código, dentro las salas jugables de la zona de pruebas. Medido en `build/el-paso-final-desarrollo-5d377b4.apk`
  (61.943 KB): los `.guion` y `.esperado` ya no viajan (`all_resources` solo exporta recursos); los `prueba_*` y el
  validador suman unos 103 KB comprimidos, el 0,2 %. Aprobado por la persona el 17-oct-2026, frente a dejarlas en el
APK ocultas, porque separa juego de prueba; va en el paso 2 (infraestructura de pruebas), para que las pruebas
nuevas nazcan ya en su carpeta:
  - las 32 escenas de prueba de código (`sala_*.tscn` con `prueba_*.gd`) y sus scripts pasan a
    `herramientas/pruebas/`, movidas en el editor; las salas de `GRUPOS` se quedan en `herramientas/salas/`;
  - el preset «Publicacion» excluye `herramientas/pruebas/*`, `validar.*`, `generar_mapa.*` y
    `puerto_depuracion.*`; «Desarrollo» sigue llevando todo;
  - `validar.gd` falla si algo fuera de `herramientas/pruebas/` la nombra;
  - el motivo es el orden y que en publicación no salgan en «Otras» (H15), no el peso;
  - cambia la decisión cerrada del `CLAUDE.md` raíz y «Paquete de publicación» del contrato: el texto nuevo del
    `CLAUDE.md` se le muestra antes de escribirlo.
- **Base `Interactuable`** (T4).
  - Recomendado: empezar con los cinco objetos que el plan `nucleo-tienda-gis` no toca, y sumar la tienda y la
    estación al cerrar ese plan.

## Aviso al plan `nucleo-tienda-gis`

- Su H1 pide la confirmación con el foco en Sí. Borrar, Restaurar y Salir deben seguir con el foco en No
  (`docs/errores/2026-10-13-foco-detras-de-la-confirmacion-de-ranuras.md`). La pieza compartida necesita el foco
  inicial como parámetro, y puede absorber también la de `Ranuras` y el «Salir» del menú (M1).
- El cierre con B de la tienda y de la estación lo arregla T1, no ese plan.

## Lo que no se comprobó

- Todo lo marcado «inferido» en el anexo; en particular:
  - lo de Android al perder el foco con un dedo apoyado (E1);
  - el área segura del HUD (E17);
  - el costo real de cada candidato de T10;
  - el peso de `herramientas/` en el APK;
  - que el puerto de depuración no responda en publicación (`paquete-publicacion` sigue en `"pasa": false`).
- La estación con B (fallo 1) no se reprodujo: se infiere por la misma posición en el árbol.
- Las citas de la documentación de Godot que dan los hallazgos son de la copia local de 4.7; no se abrieron todas
  de nuevo.

---

# Anexo: hallazgos por parte

Resumen de cada revisión, con sus ids. «Comprobado» quiere decir que se leyó en el código; «inferido», que sale del
código, pero no se ejecutó.

## R1 — jugador, combate y física (agente 1, 17-oct)

### Grave
- J1 jugador.gd:902-912, :471-475, :941-1005 — `_empezar_curacion` no corta el ataque y `_mover` sale por `_boton_poderes` antes de `_atacar()`: si se ataca en los 10 ticks antes de curar, `_ticks_atacando` y `_ataque.monitoring` quedan congelados hasta 60 ticks; `intentar_parar` (:1040) sigue aceptando parry y `_draw` (:1375) sigue dibujando el golpe. Propuesta: cortar el ataque al empezar a curar; guion nuevo. Reproducido en la auditoría (fallo 2).

### Medio
- J2 jugador.gd:221-365 — ~23 bool + ~30 contadores _ticks_*; las prioridades ya son una FSM con if/return (_mover :401-474, _mover_en_horizontal :587-619). No pasar a enum/clases.
- J3 _mover (97 l.) mezcla fundido, congelado, bloqueantes, envejecer contadores (:445-460) y choque corriendo (:482-490): sacar `_avanzar_contadores`, `_chocar_corriendo`.
- J4 _atacar (69 l., 6 niveles): `_iniciar_ataque()` + `_golpear(area)`.
- J5 `-sqrt(2*gravedad*altura)` en 5 sitios (:488,700,784,1027,1080) -> `_velocidad_de_salto(altura)`.
- J6 restaurar impulso/doble salto en 4 sitios (:459,670,1030,1083) + salidas de pogo/voltereta -> `_recuperar_aire()`.
- J7 `mini(x+1, NUNCA)` x5 -> helper opcional.
- J8 seis listas manuales de "qué se corta" (aterrizaje duro :532, picada :813, daño :1106, peligro :1189, sentarse :1231, hablar :1246); recibir_dano no usa el helper. Causa de J1. Partir `_cortar_lo_que_empuja` en `_cortar_empujes()` y `_cortar_ataque()`.
- J9 jugador.gd:1067-1070 `_parar` hace `ataque.get_parent() as Enemigo` -> acoplamiento; AtaqueEnemigo debería guardar su dueño Golpeable. Toca contrato :583.
- J10 rayo a escenario (PhysicsRayQueryParameters2D + mask ESCENARIO + intersect_ray) en 7 sitios: golpeable:70,87; proyectil:36; proyectil_enemigo:65; comportamiento_enemigo:123; jugador:872,889 -> `Capas.rayo_a_escenario(...)`.
- J11 cortable.gd:61-63 `_physics_process` con return temprano por tick en el pasto (muchas instancias) -> set_physics_process(false) (skill rendimiento :69).
- J12 get_overlapping_bodies() por tick: dano_contacto:18, ataque_enemigo:48/:52 (dos veces), jugador.gd:1222 encima_de (npc, reto) -> guarda con has_overlapping_bodies(), un bucle.
- J13 comportamiento_enemigo.gd:86 `hacia_donde_mira` sin llamadores; contrato :571 lo nombra. Mejor: que atacar() refleje con enemigo.mirando.
- J14 cortable.gd:8,52 señal `cortado` sin escuchar; contrato :413.
- J15 vaiven.gd:3-4 cabecera dice "plataformas": un StaticBody2D movido por position no arrastra al jugador (class_staticbody2d.rst:26: AnimatableBody2D). Único uso hoy: sierra.
- J16 TAMANO duplicado en .gd y sub_resource del .tscn (jugador.gd:8-9,37 / jugador.tscn:5-6; proyectil.gd:8 / proyectil.tscn:5-6) -> fijar size desde la constante en _ready.

### Menor
- J17 jugador.gd:1273 literal de acciones creado cada tick sentado -> const.
- J18 Input.get_axis leído dos veces (:476, :729).
- J19 "aire y mover_abajo" calculado dos veces (:947, :959).
- J20 jugador.gd:123 preload de partida.gd para una constante (autoload sin class_name): aceptable.
- J22 orden del script: @onready entre vars, _process/_draw al final (:278-281, :1282, :1345).
- J23 públicas sin ## (jugador:1282, golpeable:31, suelo_fragil:21, proyectil_enemigo:19).
- J24 golpeable `_forma()`/`_sala()` y ataque_enemigo `centro()`/_draw buscan hijos por tick -> cachear.
- J25 proyectil_enemigo.gd:53 `180` mágico -> TICKS_VIDA.
- J26 @export en clases creadas solo con new() (proyectil_enemigo:12-13, ataque_enemigo:12,14) — inferido.
- J27 super(delta) repite la revisión de parado/Congelado (proyectil_enemigo:60,71).
- J28 comportamiento_enemigo.gd:82 queue_redraw en girar() inútil (dibujo simétrico).
- J29 comportamiento_enemigo jugador() búsqueda de grupo por tick (ve_al_jugador) -> cachear; Vector2(0,-80) = Jugador.TAMANO.y/2.
- J30 enemigo.gd:63-79 tres RectangleShape2D del mismo tamaño -> compartir.
- J31 Eventos.enemigo_vencido sin escuchar (gancho documentado).
- J32 la bola no corta el pasto (decisión de diseño, preguntar).
- J33 cortable.tscn sin uid.
- J34 cortable.gd:47 get_node_or_null repetido -> cachear.
- J35 vista.gd:11,18 BASE.x/BASE.y repetido; cabecera cita un plan cerrado.
- J36 golpeable:47, vaiven:26 return temprano por tick (pocas instancias).

### Bien
Capas.poner en _ready en todo; set_deferred/call_deferred bien; rayos en el tick con máscara; Congelado static coherente; redibujo del jugador permitido; empuje de Golpeable decidido.

### Estructura propuesta (orden)
1 J1+J8 (bajo) · 2 partir _mover/_atacar sin cambiar orden (bajo-medio) · 3 helpers J5-J7 · 4 sacar la cámara del jugador a un script del nodo Camara (exports :211-219, :362-365, _seguir/_colocar/_objetivo/_amortiguar :1295-1342, _temblar :517-563; Jugador.temblar delega) (medio) · 5 rayo compartido J10 · 6 decidir J13/J14. Todo lo del jugador: revisor + todos los guiones.

## R2 — menús, tema, diálogo y pantallas (agente 2, 17-oct)
Falsos positivos de la medición: editor_pedido sí se emite (configuracion.gd:131 conecta editor_pedido.emit); grab_focus de tema.gd:144 es Tema.dar_foco. Tema.FOCO sí muerta.

### Grave: ninguno.

### Medio
- M1 Caja Sí/No 4 veces: ranuras.gd:313-343, menu_tienda.gd:129-159, menu.tscn:77-116 (Salir), estación (CajaDialogo). Foco en No en las tres (ranuras:116, tienda:115, menu:224). Plan H1 dice "foco en Sí" -> para Borrar/Restaurar/Salir debe seguir en No (docs/errores/2026-10-13-foco-detras-de-la-confirmacion-de-ranuras.md): parámetro. Extender la pieza a ranuras y Salir. Tienda/estación: lo cubre el plan.
- M2 "fondo oscuro + Tema.crear() + full rect" armado 7 veces (pausa.gd:115, pagina_inventario:23, pantalla_amuletos:22, ranuras:314, menu_tienda:29, menu_estaciones:25, mapa/pantalla_mapa:33); opacidades 0.7/0.8/0.85/0.9 -> Tema.VELO + Tema.fondo_menu().
- M3 marco_menus.gd:143,177,178,212,217; pausa.gd:62: contrato de página por call() dinámico; validar no lo ve; 3 páginas repiten process_mode/capa/grupo/abierta/mostrar/ocultar -> base PaginaMarco extends CanvasLayer.
- M4 encabezado aplicado a mano en 4 sitios (tema.gd:174,192; configuracion:129,151; marco_menus:48-73; zona_pruebas:101); MarcoMenus._boton repite Tema.boton -> Tema.encabezado pone también el ícono.
- M5 Ranuras y NuevaPartida mismo armazón (ready, size_changed, exit_tree, reservado_abajo, _marco, area_menu); en Configuración reservado_abajo solo en la lista: Audio/Mando/Créditos/Brillo no reservan franja (consecuencia inferida) -> Tema.ajustar(control, reservado) o base PantallaMenu.
- M6 configuracion.gd 713 l.: lista+audio+brillo con foto/shader+reasignar+guardado; _armar_brillo 87 l. corre en _ready siempre (~20 nodos, 2 EscenaMuestra) -> extraer PantallaBrillo (:26-41, :477-631) y PanelAudio (:363-474).
- M7 configuracion.gd:231-276 panel abierto en 5 .visible; atras() repite -> enum Panel.
- M8 configuracion.gd:599-603 Shader.new()+code en cada apertura de Brillo -> .gdshader/static (medir).
- M9 pausa.gd:90-92 captura get_image() de la vista en cada apertura de pausa (~3.7 MB, lectura GPU síncrona), solo sirve si se abre Brillo -> capturar al abrir Configuración/Brillo; medir.
- M10 pantalla_amuletos.gd:32-42 lista sin ScrollContainer; con ~4+ amuletos no cabe (inferido); páginas no usan Tema.area_util.
- M11 menu_tienda.gd:91-94 cerrar() sin guard is_queued_for_deletion (estaciones sí) -> doble cerrado. Lo cubre el plan.
- M12 volver y curar = mismo botón B (project.godot:76-80, :121-125); tienda/estaciones/pausa/marco cierran y quitan pausa en el mismo tick; el jugador puede ver curar recién pulsado -> set_deferred paused o tick de gracia. Resuelto en la auditoría: es el fallo 1 (tienda) y G1 de R5; pausa y marco hoy no fallan (R3).
- M13 set_anchors_preset sin offsets en pagina_inventario:25,29; pantalla_amuletos:24,28; pausa:118; marco:39; fundido:42; configuracion:483,489,494,516,572 (funciona porque va antes de add_child) -> set_anchors_and_offsets_preset (regla de la skill).
- M14 EstiloGis._draw no es por cuadro, pero cada redibujo crea RNG, PackedVector2Array y PackedColorArray por trazo (estilo_gis:39-80; tema:204; boton_valor:75) -> RNG estático; medir.
- M15 aspecto por override y no variación: caja_dialogo:208 (Quien dorado), ranuras:278,328, menu_tienda:144, pagina_inventario:76, menu.tscn:46,71, pausa.tscn:30, configuracion.tscn:33,140,201,239 (font_size 48 redundante con TITULO) -> variaciones QUIEN, PREGUNTA, TENUE.
- M16 menu_tienda/menu_estaciones casi idénticos; bloquea_pausa() con 3 implementadores. Lo cubre el plan (que nombre base común).

### Menor
- M17 tema.gd:50-51 FOCO muerta. M18 _volver_brillo (configuracion:119,504) y Ranuras._volver (:39,233) asignadas y nunca leídas.
- M19 boton_valor Estilo SI/NO/NEUTRO se dibujan igual -> bool enlace (cambia prueba_menu_configuracion:184,186).
- M20 setters de BotonValor redibujan sin comparar. M21 fundido.gd tres bool = enum Fase. M22 nueva_partida _process siempre. M23 configuracion _input siempre -> set_process_input.
- M24 menu.gd:103,129 Guardado.cargar dos veces. M25 abrir_editor duplicado menu/pausa (2 casos). M26 doble toque en Empezar/ficha emite dos veces (inferido).
- M27 tres formas de desconectar size_changed (inferido). M28 ranuras rastro hasta 96 ColorRect -> _draw.
- M29 lista_elegir:59-92 queue_free + add_child con mismo nombre; enfocada emitida dos veces (inferido).
- M30 estilo de señales. M31 literal "pantalla_encima" en vez de MarcoMenus.GRUPO; has_method redundante; String(str()). M32 _indice_de dos veces.
- M33 números/colores sueltos (Color(0.92,0.92,0.94)≈GIS, -24=MARGEN_DERECHO, CELDA.x*2+SEPARACION dos veces, 800/300/32/64...).
- M34 preload de ogg/wav de prueba en configuracion (y pausa precarga configuracion.tscn) -> load a demanda (inferido).
- M35 tema._circulo 5184 set_pixel una vez (medir). M36 BORDE_BOTON mal nombrado; Tema.boton sin ##.
- M37 _desplazable_audio() busca nodo cada vez. M38 caja_dialogo revisa ficha==null tarde. M39 vitrina división entera. M40 escena_muestra arreglo en _draw. M41 cita inexacta en estilo_gis:6.
- M42 capa 20 en 6 sitios -> MarcoMenus.CAPA_PAGINAS. M43 cabeceras de 5-10 líneas (regla 3-4) en ~11 archivos.

### Bien
dar_foco único; tema cacheado por raíz; acciones en el tick; Brillo como CanvasModulate; CajaDialogo con lógica en tick; Tema.ajustar/columnas.

### Estructura
1 pieza Sí/No (con foco_inicial_en_no) · 2 Tema.fondo_menu · 3 PaginaMarco · 4 PantallaMenu · 5 partir configuracion (Brillo, Audio, enum Panel; prueba_menu_configuracion busca por nombre: riesgo medio).

## R3 — entrada, controles táctiles, HUD y mapa (agente 3, 17-oct)
B = volver y curar: hoy no falla porque sala.gd:106 agrega el Jugador antes que Pausa (:110), Marco (:112) y menús; en el tick de cierre el jugador ya se saltó por la pausa y luego just_pressed es falso. Frágil: depende del orden de add_child (inferido, no ejecutado). La auditoría lo resolvió: falla la tienda (fallo 1); pausa y marco dependen del orden.

### Medio
- E1 controles_tactiles.gd:112-113,153-180 sin _notification de APPLICATION_FOCUS_OUT/PAUSED/WM_WINDOW_FOCUS_OUT: si el dedo se suelta en segundo plano queda presionado joystick o botón (estado estático) -> _soltar_todo(). Inferido.
- E2 controles_tactiles.gd:237-247 _tocar no suelta lo anterior si el dedo ya estaba registrado -> acción colgada. Comprobado código; disparador inferido.
- E3 controles_tactiles.gd:102 visible = touchscreen ignora UltimaEntrada.con_control: con control conectado los botones reaparecen en cada sala. Comprobado.
- E4 controles_tactiles.gd:118-137,299 _process cada cuadro, también oculto/en pausa: 6 _disponible, get_first_node_in_group en _sentado, find -> señales (Partida.reiniciar no avisa) o guarda visible.
- E5 controles_tactiles.gd:153 + .tscn:6 process ALWAYS, _input no mira pausa: con menús abiertos tocar Pausa/Mapa dispara acciones; círculo de Pausa sobre controles de Configuración. Inferido; decidir.
- E6 mapa/pantalla_mapa.gd:33-62 y nucleo/editor_controles.tscn sin Tema.crear(): tema por omisión del motor y overrides (regla ui-tactil:20). Comprobar glifo − en Cabin Sketch.
- E7 mando.gd:13 NOMBRES vs icono_boton.gd:18-21 tablas por índice duplicadas -> una tabla en Mando.
- E8 ultima_entrada.gd:14,17 con_control y dispositivo redundantes; valores partidos entre UltimaEntrada y Mando comparados como String -> enum + con_control().
- E9 ultima_entrada.gd:77-90 cada JoypadMotion >=0.5 llama get_joy_name/guid y Mando.familia (strings) -> cachear por device.
- E10 dos clasificadores de "es control/teclado" que no coinciden (ultima_entrada:69-72 vs controles_tactiles:345-359): teclas de volumen marcan TECLADO -> función común.
- E11 icono_boton.gd:72-74 _process ALWAYS por icono, sondeo -> señal Eventos.dispositivo_cambiado o set_process(visible).
- E12 interfaz/hud.gd:163-164 queue_redraw de monedas cada tick, ~150 de ~210 innecesarios -> guarda.
- E13 mapa/pantalla_mapa.gd:67-74,113-124 mapa rápido: get_first_node_in_group + get_parent + has por tick -> cachear.
- E14 "texto centrado" repetido en 4 sitios (controles_tactiles:424, editor_controles:179, icono_boton:229, aviso_accion:209) -> Tema.texto_centrado.
- E15 conversión mochila x/y a Vector2 duplicada (sala.gd:165, pantalla_mapa:154, pagina_inventario:85) -> Partida.punto_de_mochila().
- E16 mando.gd:95,109 locales `cambios` ocultan static `cambios`.
- E17 hud.gd:197,207,214 no usa el área segura (inferido).
- E18 disposicion_controles.gd:131-137 sin guarda si safe area vacía; area_segura/radio_minimo usados por Tema.area_util -> mover a Vista.

### Menor
E19 _es_de_juego antes de visible · E20 release de toque vuelve a mostrar controles · E21 redibujos de palanca oculta · E22 latido redibuja en _process con fase de física · E23 _draw mide 6 etiquetas cada vez (cachear) · E24 flags estáticos mutables (a futuro) · E25 cabeceras largas · E26 editando=false duplicado · E27 editor get_parent().queue_free() frágil · E28 SEGMENTOS 48 vs 24, estilo de señal · E29 barra del editor oculta si se pierde el release (inferido) · E30 icono_boton _dibujo Dictionary con claves string -> enum · E31 StyleBoxFlat.new() en cada _draw (icono_boton:201) · E32 ultima_entrada hace 3 cosas; no avisa desconexión · E33 toques.gd cabecera inexacta, pocos() público, overrides de aspecto · E34 hud división entera y bloques_llenos dos veces · E35 hud números mágicos repetidos · E36 hud _physics_process siempre · E37 pantalla_mapa set_anchors_preset · E38 _botones.position sin área útil · E39 lienzo_mapa.dibujar 8 parámetros · E40 lienzo números/colores sueltos · E41 indice_salas construir/iguales son de herramienta y viajan en el juego -> mover a herramientas/ · E42 objeto_mapa owner as Sala null silencioso · E43 pantalla_mapa.tscn, objeto_mapa.tscn, editor_controles.tscn sin uid · E44 contrato:342 dice que ControlesTactiles es el único que lee toques; UltimaEntrada también.

### Bien
Acciones con nombre; guardas de redibujo en los botones; multitouch central bien; coordenadas de vista; DisposicionControles valida; HUD por Eventos; interfaz/mapa respetan el contrato.

### Estructura
1 una fuente de verdad de dispositivo y nombres de botón + señal (medio) · 2 estado de dedos en un RefCounted, después de E1/E2/E5 · 3 Tema.texto_centrado · 4 Partida.punto_de_mochila.

## R4 — autoloads, guardado, ajustes, sonido, decoración (agente 4, 17-oct)
Guardado sin fallo real: JSON.new().parse, temporal + renombrar, int desde float, duplicate(true).

### Medio
- P1 sonido.gd:45-46,83-88 + ficha_sonidos.gd: Sonido escucha muro_roto y porton_abierto y llama tocar(&"muro_roto"/&"porton"), pero FichaSonidos no tiene esos campos; efecto() usa get() -> null sin aviso: esos dos sonidos nunca suenan; prueba_sonido no los cubre; contrato:171 dice que suenan. Comprobado. (confirmado: fallo 3)
- P2 partida.gd:420 guardar(ruta := Guardado.RUTA) por omisión es la ruta antigua migrada; Banco.ruta_guardado la usa de centinela. Nadie llama sin argumento hoy.
- P3 dos formas de autoguardar: Partida escucha su propio bus (habilidad, amuleto, mapa, coleccionable, jefe) y otros 6 llaman autoguardar() directo; tienda.gd:87-88 hace las dos. Elegir una.
- P4 equipar/desequipar/ensenar_boton no emiten: pantalla_mapa sondea BRUJULA por tick, controles_tactiles por_ensenar por cuadro -> señales amuletos_cambiados, boton_ensenado.
- P5 cada campo persistente en 4 sitios (ESQUEMA/NUEVOS, reiniciar, a_diccionario, desde_diccionario); ninguna prueba compara keys -> prueba barata.
- P6 guardado.gd:123: subir VERSION deja todo INCOMPATIBLE, sin gancho de conversión -> _convertir(partida, desde) antes de la primera subida.
- P7 .bak solo al entrar a la ranura (menu.gd:142): un archivo dañado pierde la sesión entera -> respaldar también en el banco.
- P8 archivo.gd: rename atómico en Android (POSIX); Windows no garantizado; sin fsync (límite del motor) -> documentar. Inferido.
- P9 menu.tscn:14 sala_inicial = caja_gris.tscn, que no es Sala: sin HUD, pausa, tiempo, autoguardado. Ya anotado como pendiente en ESTADO; anotarlo provisional en el contrato. **Resuelto el 25-oct-2026:** la caja gris se quitó; la partida nueva va a la cinemática y a La Celda.
- P10 sala.gd:97 habilidades.append directo salta obtener_habilidad (a propósito) -> Partida.dar_de_prueba().
- P11 enemigo.gd:89 Partida.vencer directo vs jefe por bus: dos idiomas.

### Menor
P12 enemigo_vencido y otras sí se usan en guiones (no muertas); jefe_vencido solo desde pruebas -> anotar en contrato · P13 26 @warning_ignore -> @warning_ignore_start · P14 conversión a int en 3 sitios -> Guardado.entero · P15 archivo.gd ignora retorno de store_string · P16 archivo bloqueado reportado DANADA · P17 sin validación de rango (inferido) · P18 ranura parseada 2-3 veces en el menú · P19 PAUSED y FOCUS_OUT guardan dos veces (inferido) · P20 Partida._physics_process siempre · P21 ajustes dañados ignorados sin aviso · P22 ajuste nuevo toca 5 sitios · P23 Ajustes.cargar_una_vez en 6 sitios, 5 redundantes · P24 120 repetido · P25 @export sin efecto en Arranque/Sonido/Vibracion (creados con new); Vector2(ms,fuerza) · P26 Vibracion por sala vs Sonido en Arranque -> mover a Arranque · P27 ficha de sonidos de prueba sin ubicación definitiva · P28 rueda de 4 voces (medir polifonía) · P29 niebla/planta rama _quieta imposible · P30 plantas fuera de pantalla (medir VisibleOnScreenEnabler2D) · P31 Prescindible guarda insuficiente (inferido) · P32 nombres sala/salas confusos, tipos de listas mezclados · P33 setters sin límites · P34 fallo de autoguardado solo push_error · P35 valor por omisión duplicado.

### Bien
JSON seguro; Archivo central; NUEVOS/completar; static var reiniciados; sin _process inútil en sonido/vibración; coleccionable marca antes de emitir.

### Estructura
No partir Partida (160 usos en 32 archivos): prueba P5, unificar autoguardado P3. Guardado.entero. Gancho de migración antes de subir VERSION. Vibracion a Arranque.

## R5 — sala y objetos del mundo (agente 5, 17-oct)

### Grave
- G1 Cerrar Tienda/Estación con B (volver y curar comparten button_index 1): sus menús son hijos de Tienda/Estacion, que están en el .tscn antes del Jugador (agregado en Sala._ready), así que el menú procesa antes, quita la pausa y el jugador lee curar recién pulsado. Pausa y Marco sí quedan después del jugador. El plan nucleo-tienda-gis NO lo cubre.
  Reproducido en la auditoría: tienda idx 5, jugador idx 6; tras B: cerrada, sin pausa, toques_poder 0->1. FALLO real.
  Propuesta: process_priority en menús/Pausa/Marco, o "cerré este tick" que el jugador respete; casos en prueba_tienda y prueba_estaciones.

### Medio
- W1 sala.gd:99-135 orden de _ready implícito (jugador antes de Pausa/Marco; HUD/mapa lo buscan por grupo; fijar_limites tras add_child; Fundido) -> comentar y anotar en contrato.
- W2 sala.gd:112-130 seis veces X.new(), name, add_child -> _agregar().
- W3 sala.gd:23-31,102-105,189-222 cuatro estáticas de llegada; prioridad banco>estación>puerta escrita dos veces; borrado duplicado -> un valor Llegada.
- W4 Banco (banco.gd:18-23) y EntregaRecompensas (:22-26) no exigen not Congelado.activo(); los otros 5 sí; contrato:395 dice "la misma regla del Npc".
- W5 Npc (npc.gd:99) y RetoPreguntas (:190) dibujan la caja gris siempre; Estacion/Mochila/Tienda/Porton/AvisoAccion solo sin CanvasItem hijo -> al ponerles arte se dibuja doble.
- W6 _linea(texto) 3 veces y armado de pregunta igual en mochila:136-156 y reto:135-157; "¡Correcto!" y "No. Era: %s." duplicados -> LineaDialogo.nueva, FichaPregunta.lineas_para.
- W7 base Interactuable para npc, estacion, mochila, reto_preguntas, tienda (+banco, entrega): ~120 líneas menos, arregla W4/W5/m1; conservar nombres que leen los guiones (cerca, caja, menu, etapa, indice, sorteadas, destino, bolsa). Hacer Npc/Reto/Mochila/Banco/Entrega primero; Tienda/Estacion tras el plan.
- W8 fundido + esperar + change_scene en 3 sitios (puerta:32-47, estacion:138-152, sala:185-200) -> Sala.cambiar_a(ruta, llegada).
- W9 recompensa.gd:15-22 mezcla dos usos (cantidad solo EntregaRecompensas; monto/id cambian de sentido) -> subclase. Riesgo .tres.
- W10 señales sin oyente: palanca portones_abiertos, porton abierto, muro se_rompio, reto respondida (duplican el bus). Quitar o probar.
- W11 muro_rompible.gd:218-239 _soltar_escombros 10 números mágicos.
- W12 porton.gd estado en 4 variables -> enum (conservar nombres públicos).

### Menor
m1 cuatro _cerrar casi iguales, diferencias en limpiar _jugador/_ficha · m2 tres estilos de conexión · m3 triángulo de aviso idéntico 5 veces -> dibujar_aviso · m4 tres colores "gis" (aviso_accion:17, icono_boton:11, Tema.GIS distintos) · m5 aviso_accion 4 bool = fases · m6 Golpeable sin enemigo armado igual en muro y palanca (2 casos) · m7 cinco nodos con _physics_process que casi siempre salen (medir) · m8 Sala._physics_process toda la vida para imprimir una vez · m9 entrega_recompensas sin null-check de recompensa · m10 banco.gd:31 reimplementa Sala.clave_de · m11 puerta _cruzada no se rearma si el destino no existe; muerto sin is_instance_valid (inferido) · m12 mochila tres queue_free y dos banderas · m13 cabecera "golpes golpes" · m14 jugador.gd:1244,1255 comentarios "lo llama el Npc" desactualizados · m15 viaje_hecho y articulo_comprado solo con oyentes de prueba · m16 formato.

### Bien
Sin trabajo pesado por tick; señales en puerta/coleccionable; dato y lógica separados con fallos() validados; orden de cierre de Npc razonado; persistencia ordenada; validador cubre ids.

## R6 — herramientas y pruebas (agente 6, 17-oct)
Sin código muerto a nivel de archivo: cada sala y script tiene uso; los 150 .guion tienen su .esperado.

### Grave (cobertura)
- H1 Ninguna prueba aprieta B como el control (volver + curar): prueba_tienda:106, prueba_marco:21 (jugador desactivado), prueba_menu_configuracion:157,177, prueba_estaciones:119 -> `_presionar_boton(boton)` en prueba_base que pulse todas las acciones del botón (la tabla ya está en prueba_control.gd:14-22) y guion con toques_poder.
- H2 Nadie ataca entre curar press y ticks_mantener_poder (jugador_curar_golpe.guion:7-15); solo un .esperado mira monitoring -> guion jugador_curar_atacar.
- H3 prueba_sonido no recorre los 8 eventos que Sonido conecta; efecto() con get() calla un nombre mal escrito -> const EVENTOS en Sonido y caso que exija efecto != null, o regla del validador.
- H4 El .esperado solo lee el estado en el cuadro `fin` (docs/guiones.md:38, puerto_depuracion:179-211): ningún guion ve un estado intermedio -> línea opcional `en <cuadro> valor ...`.

### Medio
- H5 28 de 32 reglas del validador tienen evidencia "manual: en una copia" -> reglas por escena en clase pura + prueba_validador con nodos rotos en memoria.
- H6 validar.gd:505-506 _revisar_tiendas/_revisar_avisos llamadas dentro de _revisar_npcs (ocultas).
- H7 validar.gd:105-146 if/elif con 4 ramas iguales de fallos() -> lista de reglas.
- H8 prefijos reservados 3 veces (validar:476,492,520). H9 _id_recordado 8 bloques iguales. H10 find_children + raíz 4 veces.
- H11 validar.gd:347 con pasa:true exige el .guion pero no su .esperado.
- H12 ci.yml:33 rechaza coautor solo claude/anthropic; commit-msg:3 también copilot/codex/gemini/cursor. Releído en el código.
- H13 CI sin pipefail ignora código de salida y acepta N resúmenes; validar.ps1 exige 1.
- H14 no hay script local para correr los 150 guiones; solo el bucle del CI. Resuelto: `herramientas/correr-guiones.ps1`.
- H15 zona_pruebas: escena no listada sale en «Otras» en el APK -> regla: todo prueba_* en OCULTAS.
- H16 ciclo aislar/restaurar partida copiado en 6 pruebas con variantes (dialogo/reto no borran .tmp) -> _aislar_partida/_restaurar_partida en la base.
- H17 prueba_menu_configuracion _ready 399 l. -> partir por tema (cortes ya comentados). H18 prueba_guardado 215 l. -> 4 funciones. H19 otros _ready de 90-140 l.
- H20 pruebas que leen internos con _ (prueba_aterrizaje 21 accesos, menu_configuracion, recursos, combate_chico, guardado, mapa, muros) -> se rompen con cualquier refactor; métodos públicos de prueba o guiones.
- H21 rutas de nodo largas en pruebas -> %Nombre único donde se toque.
- H22 prueba_control y prueba_vista reimplementan la base -> heredar.
- H23 export_presets.cfg solo tiene «Publicacion»; «Desarrollo» vive en chore/android-export (CLAUDE.md lo describe). Resuelto el 25-oct-2026 en `feature/contenido-celda`: los dos presets se pusieron a mano (decisión 1b de la persona).
- H24 paquete-publicacion pasa:false: puerto en release sin comprobar.
- H25 con all_resources, prueba_*.gd, validar, generar_mapa y 12 PNG de herramientas viajan al APK de publicación (peso no medido) -> exclude_filter; es decisión cerrada, preguntar.

### Menor
H26 _tocar y _cerrar duplicados; preload de jugador.tscn en 5 pruebas · H27 presionar/soltar a mano en vez de _presionar · H28 constantes a mitad de validar.gd · H29 cabecera de validar.gd incompleta · H30 tabulaciones en validar:308 · H31 doble recorrido y RegEx por sala · H32 `valor . casos N` obliga a editar el .esperado por caso (inferido) · H33 puerto vivo sin guion; arranque no revisa load null; print en release · H34 validar.tscn falso positivo de la medición.

### Bien
Sin huérfanos; puerto con fallos claros y cargado como dice el contrato; prueba_base junta lo de 3+; validador mide sin árbol; prueba_control documenta botones compartidos.
