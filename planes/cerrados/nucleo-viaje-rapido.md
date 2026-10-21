CERRADO

# Viaje rápido entre estaciones

Pedido por la persona el 17-oct-2026 («lo que yo creo que hay que programar es la parte de transporte rápido»).
Aprobado por la persona el 17-oct-2026, con lo recomendado: se paga una vez en PejeCoins, se interactúa y se viaja
enseguida, y al llegar no cura ni cambia el banco. La decisión 1 se precisó el mismo día: el núcleo se programa
entero (después de enemigos, lo perdido y la tienda) y eso es la preparación. Las zonas 1 y 2 llevan estación
solo si alcanza el tiempo de contenido, así que `docs/idea.md` lo deja en «Qué se aplaza a propósito» con esa
nota.

## Referencia: Hollow Knight y Silksong

Lectura del 17-oct-2026 del código y de las FSM de los dos juegos, hecha por un subagente. Las notas de
referencia no cubrían el tema: todo es lectura nueva.

- **Hollow Knight: Estaciones del Ciervo.**
  - **Abrir una estación** (FSM de la campana, `Crossroads_47.unity`):
    - se toca su campana y se paga una vez, de 50 a 300 Geo según la estación (`EN_Prices.txt`, `STAGWAY_*`);
    - eso pone en true un bool por estación (`openedCrossroads`, …) y suma `stationsOpened`;
    - `stagPosition` guarda dónde quedó el ciervo.
  - **Llamarlo y elegir destino:**
    - con la estación ya abierta, la campana lo llama: si no está ahí, llega tras una espera (de cerca de 1 s,
      según lectura del hex);
    - el menú (`Stag Map.prefab`) solo muestra las estaciones abiertas;
    - viajar es gratis (inferencia).
  - **Al viajar:**
    - pasa un video y carga la sala destino;
    - el jugador aparece en la puerta fija de la estación (`door_stagExit`);
    - guarda el estado de la sala;
    - no se encontró que cure, que guarde la partida ni que fije el punto de reaparición.
- **Silksong: la Bellway.**
  - **Abrir una estación:**
    - un bool por estación (`Unlocked*Station`), más `UnlockedFastTravel`;
    - se paga una vez un peaje en Rosarios en la estación (40, 60 o 80 según la región);
    - viajar no cobra.
  - **Llamarla y elegir destino:**
    - la bestia se llama con el instrumento;
    - el menú arranca marcando la estación actual (`OpenFastTravelUI`).
  - **Al viajar:**
    - un diccionario de destino a escena (`FastTravelScenes`);
    - el jugador aparece en `door_fastTravelExit`;
    - tampoco cura ni guarda.
- **Cuál se sigue:**
  - El flujo de Hollow Knight, más simple: pagar una vez, la estación queda abierta, lista de abiertas, sala y
    punto fijo.
  - Los datos, como Silksong: una tabla de estaciones (id → sala).

## Qué se hace

- **`Estacion`** (`nucleo/estacion.gd`, `Area2D` en la capa `interaccion`), hija de una sala con id.
  - Campos:
    - `id` (`estacion_<id de la sala>`, como el banco);
    - `nombre` (el que sale en el menú);
    - `costo` en PejeCoins;
    - `llegada` (dónde aparece el jugador, relativo a ella).
  - Con el jugador encima y `Jugador.puede_interactuar`, `interactuar`:
    - **cerrada:** una `CajaDialogo` pregunta si paga el `costo`. Con «Sí» y monedas suficientes, la abre
      (`Partida.abrir_estacion(id)`) y autoguarda; sin monedas, lo dice.
    - **abierta:** abre el menú de destinos.
  - Dibujo provisional: una caja gris de 240×200 px apoyada en el suelo, la medida que tiene que cubrir el arte.
    Como en `Porton` y `MuroRompible`, deja de dibujarse en cuanto la estación lleva un `CanvasItem` hijo: el arte
    entra sin tocar código.
- **Tabla de estaciones** (`contenido/estaciones.tres`, `FichaEstaciones`): id, nombre y sala de cada estación
  del juego. Las de prueba van en `herramientas/salas/zonas/estaciones_prueba.tres`. El núcleo las carga con
  `load()` solo si el archivo existe, porque no depende de `contenido/` (`nucleo/CLAUDE.md`).
- **`Partida`**:
  - campo nuevo `estaciones` (lista de ids abiertas, vacía por omisión: un guardado viejo se carga igual);
  - `abrir_estacion(id)` y `estacion_abierta(id)`;
  - en `docs/contrato.md`, «Guardado», sin subir la versión, porque es un campo nuevo con valor por omisión
    (decisión del 14-oct).
- **Menú de destinos** (`nucleo/menu_estaciones.gd`, `CanvasLayer`, con el juego en pausa como el mapa):
  - una lista con las estaciones abiertas en el orden de la tabla;
  - el foco empieza en la actual (como Silksong) y la actual no se puede elegir;
  - Volver o Círculo / B la cierran.
  - Con `Tema`, alto de toque y área segura (skill `ui-tactil`).
- **Viajar:**
  - se cierra el menú y funde a negro con `Fundido`, como una puerta;
  - `Sala.estacion_llegada = id` y se cambia a la sala de esa estación;
  - `Sala._punto_de_llegada()` busca la `Estacion` con ese id y pone al jugador en su `llegada`;
  - emite `Eventos.viaje_hecho(estacion)`.
  - No cura, no guarda la partida y no cambia el banco de reaparición (como los dos juegos; decisión 4).
- **Validador:**
  - cada `Estacion` en una sala con id;
  - cada id es único y está en la tabla, y la tabla dice la sala donde de verdad está;
  - `costo` ≥ 0.
- **Zona de pruebas:** dos estaciones en salas de la zona «prueba» (`herramientas/salas/zonas/`), una gratis y
  una de 50 PejeCoins, para probar pagar, viajar y volver. Su fila va a `docs/salas-de-prueba.md`.

## Hitos

1. H1 · `Partida.estaciones`. Casos en `prueba_estaciones.gd`:
   - abrir y guardar;
   - cargar un guardado sin el campo (queda vacío);
   - un id repetido no se agrega dos veces.
2. H2 · `Estacion`. Casos:
   - sin monedas no abre;
   - con monedas cobra una vez y abre;
   - abierta no vuelve a cobrar.
3. H3 · Menú y viaje. Casos:
   - solo salen las abiertas;
   - el foco empieza en la actual;
   - elegir otra cambia de sala y deja al jugador en su `llegada`;
   - las vidas y el banco no cambian.

   Guion de punta a punta en la zona de pruebas: pagar, viajar y volver.
4. H4 · Validador, con una copia en el scratchpad que rompa cada regla. Además, `docs/contrato.md` («Guardado»,
   «Sala», «Componentes», «Eventos» y «Capas de física», donde la `Estacion` entra en `interaccion`),
   `prueba_capas_fisica.gd` y `docs/pruebas.md`.
5. H5 · `validar.ps1`, todos los guiones y el revisor: toca el guardado.
6. H6 · Prueba manual en un teléfono. Qué observar:
   - si se entiende pagar;
   - si el menú se usa con el dedo y con el control;
   - si el fundido se siente bien.

## Decisiones (para la persona)

1. **¿Entra en la v1?** Sí, y `docs/idea.md` lo pasa a «Qué entra», o se queda para después. Con solo dos zonas
   en la v1 sirve sobre todo para volver a un banco o a un secreto. Recomendado: programarlo ahora, porque el
   núcleo queda listo para las zonas que vienen, pero después del plan de enemigos.
2. **Costo:**
   - pagar una vez en PejeCoins, como los dos juegos (recomendado: le da uso a las monedas);
   - o gratis.
3. **Cómo se llama:**
   - interactuar con la estación y viajar enseguida (recomendado: menos espera en ratos cortos);
   - o una campana con una espera de unos 60 ticks, como el ciervo.
4. **Al llegar:**
   - no cura ni cambia el banco, como los dos juegos (recomendado);
   - o autoguarda en la estación.

## Riesgos

- Toca el guardado: un campo nuevo con valor por omisión. Lo cuida el guion `guardado`, con un archivo viejo.
- Dos maneras de llegar a una sala (puerta y estación) en `_punto_de_llegada`. Si las dos llegan a la vez, manda la
  estación; un caso lo prueba.
- Que el menú se abra con el juego en pausa y el viaje use el fundido de la sala: lo cubre el guion de punta a
  punta.

## Avance

- 17-oct-2026, revisor: sin fallos de código, con 3 fallos, corregidos; 2 mutaciones nuevas fallan como deben:
  - abrir una estación faltaba en la lista de autoguardados del contrato;
  - el validador no exigía una sola estación por sala;
  - si mandaba la estación, la sala emitía igual `cambio_de_sala` con la puerta.
- 17-oct-2026, con el OK de la persona: `Estacion.tabla_de` y la bolsa de la `Mochila` entran en las cargas
  condicionales de `nucleo/CLAUDE.md`, y la `Estacion` en las reglas del validador de `herramientas/CLAUDE.md`.
- 17-oct-2026: H1 a H5 programados.
  - `estaciones.guion` da 20 casos y 0 fallos, con un viaje de verdad. La sala pasa a ser la escena actual,
    `change_scene_to_file` la cambia y la prueba, que se queda en la raíz, revisa la llegada.
  - `validar.ps1` y los 147 guiones pasan. En una copia, 15 mutaciones hacen fallar la prueba o el validador (5 del
    validador y 10 de la lógica).
- Precisiones al programar:
  - **Nombre:** la `Estacion` no lleva `nombre`; el nombre vive en la tabla (`DatoEstacion`). El menú lista
    estaciones de salas que no están cargadas, así que habría dos fuentes del mismo dato.
  - **Tablas:** hay dos, la del juego (`contenido/estaciones.tres`, todavía sin crear) y la de prueba. Cada estación
    usa la de la carpeta de su sala (`Estacion.tabla_de`). Así el menú del juego nunca muestra las de prueba, el
    mismo riesgo que tuvo la bolsa de la mochila.
  - **Gratis:** una estación gratis se abre sola al interactuar y abre el menú, sin la caja de pagar.
  - **Aviso:** `viaje_hecho` se emite en negro, justo antes del cambio de sala, con el id de la estación de llegada.
  - **Estaciones de prueba:** la gratis en `prueba_1`, x 1100; la de 50 en `prueba_4`, x 800. La entrega de
    `prueba_4` da 100 PejeCoins por el primer coleccionable.
- 17-oct-2026, prueba en el S50 con el dedo. Pasa:
  - se entiende el pago y No no cobra;
  - la estación gratis se abre sola;
  - el menú se usa bien con el dedo;
  - el fundido se siente bien y se aparece junto a la estación;
  - de vuelta ya no cobra.
  - Para después, pedido de la persona: una animación sencilla al viajar, como en Hollow Knight y Silksong.
- Falta H6 con un control (`estaciones-telefono`).

- 17-oct-2026: plan cerrado por decisión de la persona. El código y la prueba con el dedo están; la prueba con un control la harán compañeros del equipo y sigue como entrada `manual` con `"pasa": false` en `funciones.json`.
- El menú de estaciones y el pago se rehacen en el mismo plan que la tienda.
