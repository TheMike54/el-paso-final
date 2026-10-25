CERRADO

# Tienda de PejeCoins

Pedido por la persona el 17-oct-2026, con lo recomendado: pieza de tienda en el núcleo, sala de prueba y entra en
la v1 sin el minijuego de apuestas (`docs/idea.md` la pasa a «Qué entra»). Aprobado por la persona el
17-oct-2026, con lo recomendado en las cuatro decisiones: una sola `ListaElegir`, comprar autoguarda, gris lo que
no alcanza y confirmar con Sí / No.

## Referencia: Hollow Knight y Silksong

Lectura del 17-oct-2026, hecha por un subagente.

- **Hollow Knight** (`ShopItemStats`, `ShopMenuStock`). Cada artículo lleva:
  - un bool de partida que se enciende al comprarlo;
  - un requisito para aparecer;
  - su precio en Geo.

  Sobre la compra y la lista:
  - no hay contador de existencias: cada artículo se vende una vez (`ShopMenuStock.cs:110-135`);
  - lo comprado desaparece de la lista; sin dinero, el artículo sigue a la vista en gris y no se puede comprar
    (`ShopItemStats.cs:110-121`);
  - no se encontró que comprar guarde la partida.
- **Silksong** (`ShopItem`):
  - el artículo es un recurso con precio, moneda, requisitos para comprar y para aparecer, y lo que guarda;
  - lo comprado desaparece; los consumibles nunca se agotan;
  - sin dinero o sin requisito, gris (`ShopItemStats.cs:156-185`).
- **Cuál se sigue:** Silksong, porque el artículo es un recurso y encaja con «contenido como datos». Lo comprado
  desaparece y lo que no alcanza se ve en gris. Lo de los dos juegos que no se comprobó: la secuencia de
  confirmación del menú.

## Qué se hace

- **`ArticuloTienda`** (`nucleo/articulo_tienda.gd`, `Resource`):
  - `id`, `nombre`, `descripcion` y `precio` en PejeCoins;
  - `recompensa`, una `Recompensa` que ya existe: vida máxima, amuleto, habilidad o mapa;
  - `requisito` (vacío: siempre), una habilidad que hay que tener para que aparezca.

  Cada artículo se vende una vez: la v1 no tiene objetos de inventario que gastar.
- **`Tienda`** (`nucleo/tienda.gd`, `Area2D` en la capa `interaccion`), hija de una sala:
  - campos `id` y `articulos`;
  - se habla con ella como con un `Npc` (`Jugador.puede_interactuar`, `encima_de`) y abre el menú;
  - al comprar, marca `<id>_<artículo>` en el estado de su sala;
  - caja gris de 160×200 px hasta que tenga arte (deja de dibujarse con un `CanvasItem` hijo).
- **`ListaElegir`** (`nucleo/lista_elegir.gd`, `Control`): la lista con foco que comparten la tienda y el menú de
  estaciones del viaje rápido (decisión 1).
  - Filas con nombre y un dato a la derecha (el precio aquí, nada en estaciones) y una fila apagada en gris que no
    se elige.
  - Volver cierra la lista (señal `cerrada`) y Círculo / B cierra el menú que la usa. Señal `elegida(indice)`.
  - Con `Tema`, alto de toque y área segura.
- **Menú de la tienda** (`nucleo/menu_tienda.gd`, `CanvasLayer`, con el juego en pausa como el mapa):
  - arriba, las PejeCoins que tienes;
  - la `ListaElegir` con los artículos que no se han comprado y cuyo requisito se cumple;
  - en gris los que no alcanzas;
  - abajo, la descripción del que tiene el foco.
- **Comprar:**
  - elegir un artículo pide confirmar («¿Comprar <nombre> por <precio>?», Sí / No);
  - con «Sí»: cobra (`Partida.gastar_monedas(precio)`, que da `false` si no alcanza), entrega la `Recompensa` como
    `EntregaRecompensas` y marca el artículo;
  - emite `Eventos.articulo_comprado(articulo)` y autoguarda (decisión 2);
  - el artículo sale de la lista.
- **Validador:** cada `Tienda` en una sala con id lleva id; los ids de sus artículos son únicos, el precio es
  mayor que 0 y la `Recompensa` es válida (habilidad en `Habilidades.TODAS`).
- **Contrato:**
  - «Componentes» (`Tienda`, `ArticuloTienda`, `ListaElegir`);
  - «Eventos» (`articulo_comprado`);
  - «Capas de física» (la `Tienda` en `interaccion`), más `prueba_capas_fisica.gd`;
  - «Estado de la partida» (`gastar_monedas`).
- **Sala de prueba «Tienda»**, en la categoría Salas:
  - la sala da 300 PejeCoins al entrar;
  - una tienda con cuatro artículos: uno barato, uno caro (no alcanza), uno con requisito y un amuleto.

  Su fila va a `docs/salas-de-prueba.md`.

## Hitos

1. H1 · `Partida.gastar_monedas` y `ArticuloTienda`. Casos en `prueba_tienda.gd`:
   - gastar más de lo que hay no cambia nada;
   - gastar lo justo deja 0.
2. H2 · `ListaElegir`. Casos:
   - el foco empieza en la primera fila elegible;
   - una fila gris no se elige;
   - Volver cierra.
3. H3 · `Tienda` y menú. Casos:
   - lo que no alcanza sale en gris;
   - comprar cobra una vez, entrega y marca;
   - lo comprado ya no sale, tampoco al volver a crear la sala;
   - el requisito oculta el artículo;
   - autoguarda.

   Guion de punta a punta en la sala de prueba.
4. H4 · Validador, contrato y documentos; `validar.ps1`, todos los guiones y el revisor (toca el guardado).
5. H5 · Prueba manual en un teléfono. Qué observar:
   - si se lee el precio;
   - si se entiende lo gris;
   - si confirmar se hace con el pulgar y con el control.

## Decisiones (para la persona)

1. **Una lista para la tienda y las estaciones:**
   - una sola `ListaElegir` (recomendado: son dos casos con la misma forma, una lista con foco y Volver, y el
     viaje rápido se programa justo después);
   - o cada menú con la suya.
2. **Comprar autoguarda:**
   - sí (recomendado: es la regla del juego al obtener algo, aunque los dos juegos no lo hagan);
   - o no.
3. **Lo que no alcanzas:**
   - se ve en gris (recomendado, como los dos juegos);
   - o se oculta.
4. **Confirmar la compra:**
   - sí, con Sí / No (recomendado: en el teléfono un toque de más es fácil);
   - o se compra al elegir.

## Riesgos

- Toca las monedas y el guardado: lo cuida el guion `guardado`.
- La lista nueva se usa en el menú de estaciones: si cambia su forma, cambian los dos. Lo cuidan los guiones de
  los dos.

## Avance

- 17-oct-2026: H1 a H4 programados.
  - `tienda.guion` da 23 casos y 0 fallos. `validar.ps1` y todos los guiones pasan.
  - En una copia, 12 mutaciones hacen fallar la prueba o el validador: precio 0, id repetido, sin recompensa,
    requisito o habilidad desconocidos, tienda vacía, tienda sin id, sin marca, sin autoguardado, sin requisito, sin
    el número del encabezado y cantidades negativas.
  - El autoguardado de la tienda solo se ve con un artículo que no guarda por su cuenta: la habilidad ya guarda.
    Lo cubre el caso de la vida máxima.
- 17-oct-2026, revisor: el código cumple el plan, con 5 fallos de documentos, corregidos:
  - dos filas del contrato cortadas;
  - la fila de `tienda.guion` que faltaba en `docs/pruebas.md`;
  - la lista de reglas del validador en «Sala»;
  - lo que cierra la `ListaElegir`.
- 17-oct-2026, con el OK de la persona: la `Tienda` entra en las reglas del validador de `herramientas/CLAUDE.md`.
- 17-oct-2026, prueba en el S50 con el dedo:
  - pasa: el precio se lee, lo gris se entiende (no alcanza) y Sí / No es cómodo con el pulgar; No no cobra y Sí
    cobra y quita el artículo; el doble salto aparece solo con el impulso;
  - «lo comprado no vuelve» no se puede probar saliendo al menú, porque entrar a la zona de pruebas reinicia la
    partida; lo cubre `tienda.guion`, que vuelve a crear la sala en la misma partida;
  - falta probarlo con un control.
- Falta H5, la prueba en el teléfono (`tienda-telefono`), con un control.

- 17-oct-2026: plan cerrado por decisión de la persona. El código y la prueba con el dedo están; la prueba con un control la harán compañeros del equipo y sigue como entrada `manual` con `"pasa": false` en `funciones.json`.
- El menú se rehará con el estilo de los menús en gis y las referencias de Hollow Knight y Silksong, en un plan aparte.
