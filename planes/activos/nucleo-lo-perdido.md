ACTIVO

# Lo perdido al morir y el reto para recuperarlo

Pedido por la persona el 17-oct-2026 («vamos a cerrar lo de lo perdido al morir, el reto de preguntas para
recuperar lo perdido»). Está en la v1 (`docs/idea.md`, «Sistemas»). Aprobado por la persona el 17-oct-2026 con lo recomendado en las
cuatro decisiones: el último punto seguro, reintentar con preguntas nuevas, una sola bolsa y un ícono en el mapa.

Hoy, al morir, `Partida._al_morir()` (`nucleo/partida.gd:268`) solo borra la Inspiración y los enemigos vencidos y
autoguarda. Las PejeCoins no se pierden. El campo `mochila` (`{sala, x, y, monto}`, guardado v3) existe y el
inventario lo muestra, pero nadie lo llena. Decisión ya tomada (13-oct): morir otra vez sin recuperar lo perdido lo
pierde.

## Referencia: Hollow Knight y Silksong

Lectura del 17-oct-2026, hecha por un subagente.

- **Hollow Knight: la Sombra.**
  - **Qué se pierde y cómo se guarda:**
    - al morir, todo el Geo pasa a `geoPool` y `geo` queda en 0 (`Hero Death.prefab:8222-8301`);
    - se guarda la sala (`shadeScene`) y la posición;
    - el alma máxima baja de 99 a 66 hasta recuperarla (`StartSoulLimiter`, `PlayerData.cs:5022-5032`).
  - **Dónde aparece:** en el «Shade Marker» más cercano al punto de muerte, no donde murió (`Hero Death.prefab:3019-3063`).
  - **Cómo se recupera:** la sombra es un enemigo que se vence a golpes; al vencerla devuelve el Geo y quita el
    límite de alma (`Hollow Shade Death.prefab:793-823`).
  - **Morir otra vez:** se reescribe la sombra y la anterior se pierde (inferencia).
  - **Mapa:** se marca (`GameMap.cs:1084-1097`).
  - **Casos especiales:** arenas con sala fija para la sombra (Coliseo, jefe final).
- **Silksong: el capullo.**
  - **Qué se pierde:** todos los rosarios y la seda. Un amuleto conserva una parte.
  - **Dónde aparece:** en el `HeroCorpseMarker` activo más cercano o, si no hay, en el punto de muerte
    (`HeroController.cs:9409-9423`).
  - **Guardado:** guarda la partida al morir (`GameManager.cs:954-977`).
  - **Cómo se recupera:** se rompe el capullo y devuelve el dinero (`HeroController.cs:11940-11955`).
  - **Morir otra vez:** sobrescribe el capullo; solo hay uno a la vez (`:9412`, `:9442`).
  - **Mapa:** muestra su ícono (`GameMap.cs:1350-1364`).
  - **Casos especiales:** un peligro con vida restante no mata y no deja capullo.
- **Cuál se sigue:** Silksong, más simple: un solo depósito, dinero completo, se guarda al morir (aquí ya se
  autoguarda) y se ve en el mapa. El límite de alma de Hollow Knight no entra: la Inspiración ya se pierde toda.
  En lugar de vencer una sombra o romper un capullo, aquí se recupera con el reto de preguntas, la idea propia del
  juego.

## Qué se hace

- **Al morir** (`Partida._al_morir`):
  - si hay monedas, `mochila = {sala: clave de la sala, x, y, monto: monedas}` y `monedas = 0`;
  - si ya había una mochila, la nueva la reemplaza: la vieja se pierde (decisión del 13-oct);
  - sin monedas, no deja mochila y la vieja sigue donde estaba;
  - autoguarda, como hoy.
- **Dónde queda:** en el último punto seguro del jugador (decisión 1), el que ya usa la vuelta tras un peligro
  (`Jugador._puntos_seguros`). Así nunca queda sobre pinchos ni en el aire. El jugador la expone como
  `ultimo_punto_seguro()`.
- **`Mochila`** (`nucleo/mochila.gd`, `Area2D` en la capa `interaccion`). La crea `Sala._ready` si
  `Partida.mochila.sala == clave()`, en `x, y`. No usa el estado por sala (`marcar`): vive en `Partida.mochila`.
  - Caja gris de 80×80 px hasta que tenga arte (deja de dibujarse con un `CanvasItem` hijo, como el portón).
  - Con el jugador encima y `Jugador.puede_interactuar`, `interactuar` abre el reto: una `CajaDialogo` con
    `preguntas_por_reto` (3) preguntas al azar de la bolsa, que se responden como en `RetoPreguntas`.
  - **Gana** con `meta` (2) aciertos o más: suma `monto` a las monedas (`Eventos.monedas_cambiadas`), vacía
    `mochila`, emite `Eventos.mochila_recuperada(monto)`, autoguarda y desaparece.
  - **Pierde:** la mochila se queda y se puede intentar otra vez con preguntas nuevas (decisión 2).
  - Un golpe, un peligro o morir cortan el reto sin contar, como en el `Npc`.
- **Bolsa de preguntas** (`contenido/preguntas_mochila.tres`, una lista de `FichaPregunta`; decisión 3).
  - El núcleo la carga con `load()` solo si existe.
  - Las de prueba van en `herramientas/salas/preguntas_mochila_prueba.tres`.
  - Sin bolsa, la mochila se recupera con solo tocarla, para que el juego nunca se trabe.
- **Mapa** (bloque `mapa/`, decisión 4): un ícono donde está la mochila si su sala ya está en el mapa, como los
  dos juegos.
- **Validador:** la bolsa, si existe, tiene al menos `preguntas_por_reto` preguntas y todas sin fallos
  (`FichaPregunta.fallos()`).
- **Contrato:**
  - «Guardado»: `mochila` ya existe y no sube la versión;
  - «Componentes» (`Mochila`), «Eventos» (`mochila_recuperada`) y «Capas de física» (la `Mochila` en
    `interaccion`), más `prueba_capas_fisica.gd`;
  - `docs/jugador.md` (`ultimo_punto_seguro`).
- **Sala de prueba «Lo Perdido»** en la categoría Salas: monedas al entrar, un pincho para morir y la bolsa de
  prueba. Su fila va a `docs/salas-de-prueba.md`.

## Hitos

1. H1 · Morir deja la mochila. Casos en `prueba_lo_perdido.gd`:
   - con monedas: mochila en el último punto seguro, monedas en 0;
   - sin monedas: no la toca;
   - morir otra vez la reemplaza;
   - el guardado la lleva.
2. H2 · `Mochila` y reto. Casos:
   - aparece solo en su sala;
   - ganar devuelve el monto exacto y la quita;
   - perder la deja y el segundo intento usa otras preguntas;
   - sin bolsa se recupera al tocarla;
   - un golpe corta el reto.
3. H3 · Ícono en el mapa (entrada en `mapa/funciones.json`).
4. H4 · Validador (bolsa), contrato y documentos; `validar.ps1`, todos los guiones y el revisor, porque toca el
   guardado y la muerte.
5. H5 · Prueba manual en un teléfono. Qué observar:
   - si se entiende que hay que volver;
   - si se encuentra la mochila;
   - si el reto se lee con el pulgar.

## Decisiones (para la persona)

1. **Dónde queda la mochila:**
   - el último punto seguro (recomendado: nunca en pinchos ni en el aire, sin trabajo extra en cada sala);
   - el punto exacto de la muerte;
   - o marcadores puestos a mano en cada sala, como Hollow Knight (más control y más trabajo de diseño).
2. **Perder el reto:**
   - se reintenta con preguntas nuevas (recomendado: el reto es para aprender, no para castigar);
   - se pierde la mochila;
   - o hay que salir de la sala y volver.
3. **Bolsa de preguntas:**
   - una sola para todo el juego (recomendado mientras haya dos zonas);
   - o una por zona.
4. **Ícono en el mapa:**
   - sí (recomendado: los dos juegos lo hacen y evita perderla);
   - o no.

## Riesgos

- Toca la muerte y el guardado: lo cuidan los guiones `guardado`, `estado_partida` y los de reaparición.
- Si la sala de la mochila deja de existir (una sala quitada), la mochila no aparece nunca: el inventario sigue
  mostrando «Lo perdido». Se acepta, porque los ids de sala no se quitan.
