ACTIVO

# Aviso de acción en los pizarrones

Pedido por la persona el 17-oct-2026: al pasar junto a un pizarrón de la sala se dibujan los controles de esa
acción. Es la pieza con la que la primera zona enseña a jugar sin texto en pantalla, con dibujos de gis como las
tablillas de Hollow Knight (decisión del diseño). La intro no entra ahora. La persona ya hace el arte de la primera sala, y la sala no se empieza hasta que el
núcleo esté pulido (17-oct-2026). Aprobado por la persona el 17-oct-2026 con lo recomendado en todas las decisiones.

## Referencia

Lectura nueva del 17-oct-2026 en el material crudo, hecha por un subagente; las notas no tenían el tema.

- **Hollow Knight, primera sala:**
  - las tablillas cuentan la historia, no enseñan botones (`EN_Lore Tablets.txt`, `TUT_TAB_01` a `03`, hecho);
  - los botones salen en avisos aparte: `EN_Prompts.txt` (`PROMPT_ATTACK`) y 3 `Prompt Marker` en la escena
    (hecho por nombre);
  - cuándo aparecen y cómo se ven no se leyó.
- **Silksong, primera sala:** `Prompt Marker`, `Enemy Msg` y `Tutorial Blocker` (solo nombres de objeto, sin leer
  la lógica).
- **Cuál se sigue:** el aviso de Hollow Knight, pero dibujado sobre el pizarrón y con el botón real del aparato en
  uso.

## Qué se hace

- **`AvisoAccion`** (`nucleo/aviso_accion.gd`, `Area2D` en la capa `interaccion`), hijo de una sala:
  - campos `acciones` (una o dos acciones del InputMap, p. ej. `saltar`, o `mover_izquierda` + `mover_derecha`),
    `tamano` (la zona que lo activa) y `punto` (dónde se dibuja, relativo a él: el centro del pizarrón).
- **Con el jugador dentro**, el dibujo aparece en 12 ticks y al salir se va en 12. No se interactúa: solo se pasa
  por ahí.
- **Qué dibuja**, según `UltimaEntrada`:
  - **con el control o el teclado:** el botón de cada acción como lo dibuja `IconoBoton` (Xbox, PlayStation o la
    tecla, con lo reasignado), en blanco gis;
  - **en táctil:** el círculo del botón de pantalla de esa acción con su etiqueta, y además ese botón de la pantalla
    late (`ControlesTactiles.resaltar(accion)`, nuevo) mientras el jugador está dentro;
  - **moverse en táctil:** el aro del joystick.
- **Arte:** el pizarrón es arte de la sala, que lo pone la persona. El aviso solo dibuja encima. Sin arte, una caja
  gris oscura de 240×160 px marca el pizarrón.
- **Validador:** cada `AvisoAccion` nombra acciones que existen en el InputMap y tiene al menos una.
- **Contrato:** «Componentes» (`AvisoAccion`), «Capas de física» (en `interaccion`), más `prueba_capas_fisica.gd`,
  y «Entrada» (`resaltar`).
- **Sala de prueba «Pizarrones»**, en la categoría Salas (hoy Mundo): un pizarrón por acción (moverse, saltar, atacar,
  interactuar con un banco y curar). Su fila va a `docs/salas-de-prueba.md`.

## Hitos

1. H1 · `AvisoAccion`. Casos en `prueba_aviso_accion.gd`:
   - fuera, oculto;
   - dentro, se ve en 12 ticks;
   - al salir se va;
   - con el control dibuja el botón de la acción, también reasignado;
   - tras un toque dibuja el de la pantalla y el botón real late.
2. H2 · `ControlesTactiles.resaltar`. Casos:
   - late solo el de esa acción;
   - deja de latir al salir;
   - un botón oculto por falta de habilidad no late.
3. H3 · Validador, contrato y sala de prueba; `validar.ps1`, todos los guiones y el revisor (toca la entrada
   táctil).
4. H4 · Prueba en el S50 con el dedo y con un control. Qué observar:
   - si se entiende qué botón es;
   - si el botón de la pantalla que late se nota;
   - si el dibujo encima del pizarrón se lee.

## Decisiones (para la persona)

1. **Texto junto al botón:**
   - ninguno, solo el botón, como pide el diseño (recomendado);
   - o una palabra («Saltar»).
2. **El botón de la pantalla late en táctil:** sí (recomendado: en el teléfono no hay otra forma de señalar cuál es)
   o no.
3. **Dos acciones en un pizarrón** (atacar hacia abajo = abajo + atacar): sí, hasta dos (recomendado) o una sola.

## Avance

- **H1 y H2 hechos (17-oct-2026)**, en una sola prueba: `prueba_aviso_accion.gd` sobre la sala Pizarrones, guion
  `herramientas/guiones/nucleo/aviso_accion.guion`, 14 casos.
  - En vez de una función `resaltar(accion)`, `ControlesTactiles.resaltada` es una `static var`, como `hablando` y
    `editando`. El aviso la pone y la quita, también al salir del árbol.
  - Un aviso con varias acciones resalta la primera que tiene botón en la pantalla. Moverse va con el joystick y
    no resalta nada.
  - «También reasignado» no tiene caso propio: el aviso usa el mismo `IconoBoton` de los menús, y lo reasignado ya
    lo cubre `menu_configuracion.guion`.
  - Medido: un cuerpo que se teletransporta aparece en la lista del área unos 3 ticks después. Por eso la prueba
    espera 4 ticks.
- **Mutaciones (17-oct-2026)**, en la copia del scratchpad, contra `aviso_accion.guion`. Se probaron 10 y una se
  quitó porque era la misma conducta:
  - la que dejaba los íconos del control visibles en táctil: cada `IconoBoton` ya se oculta solo tras un toque, así
    que se borró la línea redundante del aviso;
  - la que quitaba `not hablando` del latido no la atrapaba nadie, porque hablando los botones ya no están
    disponibles. La excepción es la pausa, y para ella se agregó el caso «hablando no late ni la pausa».
- **H3:**
  - el validador revisa en cada escena que todo `AvisoAccion` tenga 1 o 2 acciones del InputMap;
  - `AvisoAccion` está en la lista de interacción de `prueba_capas_fisica.gd` (32 casos);
  - el contrato tiene la fila de Componentes, la capa y «Resaltar»;
  - la sala «Pizarrones» está en la categoría Salas y en `docs/salas-de-prueba.md`.
- **Revisor (17-oct-2026): aprobado.** Su observación llevó a la entrada `validador-avisos` de
  `herramientas/funciones.json`.
- **Visto en el S21 con `adb` (17-oct-2026), con el dedo:**
  - el pizarrón de moverse dibuja los dos aros del joystick con la perilla a cada lado;
  - el de saltar dibuja «Saltar» y el botón Saltar de la pantalla late;
  - sin arte, se ve la caja gris del pizarrón.
- **H4 con el dedo, prueba de la persona (17-oct-2026):**
  - el dibujo se lee y el latido del botón se nota;
  - se entiende más o menos: el pizarrón del joystick hacia arriba (sentarse) y el último (abajo + atacar) no se
    entienden;
  - el primero (moverse) no le gusta: el joystick no se explica, es obvio;
  - saltar está bien, porque tiene un obstáculo delante;
  - atacar necesita algo a qué pegarle;
  - curar necesita que antes algo te quite vida y que golpear te dé Inspiración. Idea de la persona: junto a atacar
    aparece un enemigo que te golpea, al pegarle ganas Inspiración y en el pizarrón de curar ya puedes curarte;
  - pregunta si los pizarrones tendrán texto.
  - «Hay que pensarlo mejor»: el orden y el contenido de la sala se rediseñan antes de cerrar este plan.
- **Con control:** la prueba la harán compañeros del equipo.

## Rediseño tras H4 (aprobado por la persona el 17-oct-2026, con lo recomendado en todo)

**Referencia nueva** (King's Pass y `Tut_01` de Silksong, leídos por un subagente el 17-oct-2026 en las escenas
exportadas; las notas no lo tenían):
- los avisos de botón son una palabra y el ícono («Attack»), aparte de los carteles, que cuentan la historia;
- son tres (atacar antes del primer enemigo, saltar ante un desnivel, interactuar en el cartel) y moverse no se
  enseña;
- una zona invisible los muestra; se apagan al hacer la acción, con al menos 1 s a la vista, y no vuelven;
- Silksong espera 2 s dentro de la zona y, si ya hiciste la acción, no lo muestra (`ControlReminder.cs`);
- curar se enseña con texto, al leer el primer cartel («golpea enemigos para juntar alma»), sin daño forzado;
- el banco y el golpe hacia abajo no están en la primera zona.

**Decisiones:**
1. Palabra junto al botón (cambia la decisión 1 de arriba).
2. Una vez por partida: al hacer la acción se marca en el estado de la sala (`Partida.marcar`, con `id`); sin
   `id`, solo dura la visita. El formato del guardado no cambia.
3. Curar lleva su línea: «Golpea enemigos para ganar Inspiración».
4. Abajo + atacar sale de esta sala; va al primer foso con pinchos que lo pida.
5. Los pizarrones solo enseñan; sin frase de historia.

**Qué cambia en `AvisoAccion`:**
- campos nuevos `id`, `texto` (la palabra; vacío = la etiqueta de la acción) y `nota` (una línea más, opcional), y
  `pizarron` (false: sin caja gris, para el aviso pegado al banco);
- **hecha:** la acción se pulsa (con la otra mantenida, si son dos); curar cuenta al curar una vida
  (`Eventos.jugador_curado`), porque un toque de curar no cura;
- al entrar espera `TICKS_ESPERA` (30) antes de aparecer; si en ese rato o antes, en la misma sala, ya se hizo la
  acción, no sale;
- hecha con el dibujo a la vista: sigue al menos `TICKS_MINIMO` (60) visible desde que apareció y se va;
- hecho, ya no resalta ningún botón de la pantalla.

**Sala Pizarrones nueva** (izquierda a derecha): saltar ante el bloque; atacar ante un caminante que va y viene y
pega al tocarlo; curar pasado el caminante, con la nota; el aviso «Sentarse» sobre el banco, sin pizarrón.

## Hitos del rediseño

5. H5 · `AvisoAccion` y la sala nueva. Casos nuevos en `prueba_aviso_accion.gd`:
   - no aparece antes de `TICKS_ESPERA`;
   - saltar dentro lo apaga tras `TICKS_MINIMO` y deja la marca;
   - con la marca, al volver no aparece;
   - hecha antes de entrar, no aparece;
   - un toque de curar no lo apaga; curar una vida sí.
6. H6 · Validador (`id` sin repetir en la escena), contrato, `docs/salas-de-prueba.md`, `validar.ps1`, todos los
   guiones y el revisor (toca el estado guardado de la sala).
7. H7 · Prueba de la persona en el teléfono, en la sala Pizarrones (pendiente):
   - si se entiende cada aviso con la palabra;
   - si el caminante deja ganas de curarse;
   - si el aviso del banco se lee sobre el banco.

## Riesgos

- Toca `ControlesTactiles`: lo cuida `controles_tactiles.guion`.
- Si cambia el dibujo de `IconoBoton`, cambia el del aviso; lo cuida `menu_configuracion.guion`.

## Avance del rediseño

- **H5 y H6 hechos (17-oct-2026):**
  - `aviso_accion` da 22 casos y 0 fallos;
  - `validar.ps1` pasa y todos los guiones también (`MALOS=0`);
  - en una copia, el validador marca el id repetido y el reservado.
- **Revisor (17-oct-2026):** un fallo. El id del aviso no se cruzaba con los demás objetos que se recuerdan en una
  sala con id (un Npc con el mismo id lo daría por hecho). Ahora `_id_recordado` incluye el aviso, con id
  opcional. En una copia, un aviso con el id del coleccionable de `prueba_2` da «id coleccionable repetido en la
  sala».
- **Observaciones del revisor, para la persona:**
  - la caja de diálogo avanza con saltar y atacar: leer un cartel con atacar daría por hecho el aviso de atacar;
  - con un `texto` propio en una acción con botón en la pantalla, en táctil sale la etiqueta del botón y no el
    `texto`;
  - la ruta de dos acciones ya no tiene caso en la prueba.
- **H7, prueba de la persona en el S50 con el dedo (17-oct-2026):** «mucho, mucho mejor».
  - Saltar y atacar se entienden.
  - **Curar no se pudo probar:** el caminante no le pegó y llegó al pizarrón con la vida llena. La persona pide
    empezar con una vida menos o algo que lo asegure.
  - Volver a entrar desde la zona de pruebas muestra los avisos otra vez. Es lo esperado: la zona empieza una partida
    nueva y borra las marcas. La instrucción de la prueba estaba mal planteada; la marca la cubre el guion.
  - Saltar antes del primer pizarrón: el de saltar ya no sale, como se diseñó.
  - **Idea de la persona:** empezar la sala solo con el joystick; cada pizarrón hace aparecer su botón en la pantalla,
    y al final se tienen saltar, atacar y curar. Aprobada el 17-oct-2026 (abajo).

## Arreglos tras H7 y botones que aparecen (aprobado por la persona el 17-oct-2026, con lo recomendado en todo)

**Arreglos:**
- La sala Pizarrones empieza con una vida menos (`herramientas/salas/vida_menos_prueba.gd`), para poder curar aunque
  el caminante no pegue. La primera zona real se decide al diseñarla.
- Pulsar con una conversación abierta no cuenta como hacer la acción (`ControlesTactiles.hablando`, ese tick y el
  anterior).
- En táctil, una palabra propia distinta de la etiqueta del botón va debajo del aro.

**Botones que aparecen (idea de la persona):**
- `Sala.botones_por_ensenar`: en esa sala, los botones de la pantalla de esas acciones no se ven hasta que alguien los
  enseña. Es solo táctil; el control y el teclado no cambian.
- `Partida.botones_ensenados`: lo que ya se enseñó. Se guarda, con valor por omisión vacío y sin subir la versión,
  como `estaciones`.
- Un `AvisoAccion` enseña los botones de sus acciones al aparecer o al quedar hecho.
- El validador exige que cada botón por enseñar sea un botón de la pantalla y que algún aviso de la sala lo enseñe.
  Si no, el jugador se quedaría sin él.
- En la sala Pizarrones: saltar, atacar y curar.

## Hitos de lo que aparece

8. H8 · Casos nuevos:
   - en `prueba_aviso_accion.gd`, antes del pizarrón el botón de saltar no se ve; al aparecer el pizarrón, sí; curar
     sigue oculto hasta su pizarrón;
   - en `prueba_guardado.gd`, `botones_ensenados` va y vuelve del archivo, y una partida vieja sin el campo carga vacío.
9. H9 · Validador (en una copia, cada regla rota da su `FALLO`), contrato, `validar.ps1`, todos los guiones y el
   revisor (toca el guardado y la entrada táctil).
10. H10 · Prueba de la persona en el teléfono: recorrer la sala Pizarrones con el dedo y ver aparecer cada botón.

## Avance de lo que aparece

- H8 y H9 hechos (17-oct-2026): `aviso_accion` 27 casos, `guardado` 63, `controles_tactiles` 34; `validar.ps1` y los 150
  guiones en verde. Mutaciones en una copia: sin el filtro de diálogo, 2 fallos; sin la vida menos, 1; con
  `interactuar` e `impulso` en `botones_por_ensenar`, un `FALLO` por cada uno.
- Revisor (17-oct-2026): aprobado. Observó que el tramo «y el tick anterior» del filtro de diálogo no lo cubre ningún
  caso: hoy no hace falta, porque la caja de diálogo baja `hablando` al salir del árbol, después del tick. Se deja así.
- Falta H10.
