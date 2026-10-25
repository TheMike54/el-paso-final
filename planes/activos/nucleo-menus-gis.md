ACTIVO

# Menús en gis

Pedido por la persona el 17-oct-2026: pulir los menús (título, botones, Volver y zona de pruebas), con la experiencia
de uso primero. Se vieron dos páginas de propuestas y capturas de Godot con las fuentes y medidas reales. Aprobado
por la persona el 17-oct-2026, con lo recomendado en lo que estaba por confirmar.

## Decisiones de la persona (17-oct-2026)

1. **Estilo C, gis**, con **todas las letras en gis grueso**: Cabin Sketch, negrita en títulos y normal en lo demás.
2. **Opciones en una columna a la izquierda** (propuesta B2).
3. **Un solo Volver** para todas las pantallas, en el encabezado, junto al título (V1).
4. **Zona de pruebas reorganizada sin quitar nada**, en siete categorías:

   | Categoría | Salas |
   |---|---|
   | Movimiento | Igual que hoy |
   | Combate | Igual que hoy |
   | Enemigos | Igual que hoy |
   | Mundo | Banco, Puerta A, Cámara, Capas, Secretos, Pizarrones |
   | Partida | Diálogo, Reto, Lo Perdido, Tienda |
   | Rendimiento | Recursos, Arte |
   | Zonas | Igual que hoy |

   Además:
   - cada sala lleva una línea que dice para qué sirve;
   - Puerta B sale de la lista: se llega cruzando la puerta de Puerta A, y la escena sigue existiendo.
5. **El menú principal, por ahora sin imagen de fondo.**

## Confirmado el 17-oct-2026 (era lo recomendado)

- **Adornos por código** (flechita, subrayado, raya del encabezado, óvalo de lo elegido). Si después hay dibujos
  propios, se cambian sin tocar los menús. La otra opción es esperar las imágenes.
- **El HUD queda limpio**, con la letra de hoy y sin gis, para leerse en plena pelea.
- **Diálogos** (cajas de texto largo) en Cabin Sketch como todo lo demás. Se mide en el S50 si se lee de corrido; si
  no, se consulta.

## Qué se hace

**Fuentes:**
- `nucleo/fuentes/cabin_sketch.ttf` y `cabin_sketch_bold.ttf`, con su `OFL.txt`;
- su línea en «De terceros» de `docs/uso-de-ia.md`;
- `Tema.crear()` las pone como fuente de los menús (`default_font` y por tipo).
- `ALTO_LETRA` se vuelve a medir, porque el skill `ui-tactil` dice que las medidas de `Tema` son de la fuente por
  omisión.

**Tema:**
- botones sin caja: `normal`, `hover` y `pressed` vacíos;
- el texto, en gis gastado; con el foco, en gis blanco;
- **el foco es un `StyleBox` propio** (`nucleo/estilo_gis.gd`, `extends StyleBox`, con `_draw(to_canvas_item, rect)`,
  `classes/class_stylebox.rst:180`) que dibuja la flechita y el subrayado tembloroso. Así cualquier `Button` lo
  hereda sin cambiar cada menú;
- `Tema.dar_foco` no cambia: con el dedo, el foco sigue oculto;
- el alto de toque de 108 px no cambia: la fila entera se toca aunque no tenga caja.

**Pantallas:**
- **Encabezado único:** `Tema.barra_arriba` pasa a ser la flecha de gis, «Volver», el título en gis grueso y una raya
  debajo.
- **Dónde va el encabezado:**
  - lo usan Configuración (y sus paneles), ranuras, nueva partida y zona de pruebas;
  - el marco de menús conserva su franja de páginas con el mismo Volver.
- **Menú principal y pausa:** columna a la izquierda. En el principal, título «El Paso Final» grande con su adorno, y
  Zona de pruebas más chica, al final.
- **Valores Sí / No y Bajo / Alto** (`BotonValor`): se ven las dos opciones y la que vale va en un óvalo de gis.
- **Zona de pruebas:** `GRUPOS` con las siete categorías, un texto por sala, Puerta B en `OCULTAS`, y la fila de
  categorías con la elegida subrayada.

**Lo que no entra:**
- tienda, pago de estación y viaje rápido: van en su propio plan, con las capturas de referencia;
- el HUD;
- el fondo del menú principal.

## Hitos

1. H1 · Fuentes y tema.
   - `validar.ps1`;
   - `menu_configuracion`, `pausa_foco`, `marco`, `ranuras` y `zona_pruebas` (los guiones de menús) en verde.
   - Si un guion mide anchos, se revisa su cuenta antes de tocar el `.esperado`.
2. H2 · `EstiloGis` y el encabezado único:
   - un caso nuevo: con el control, el botón con foco dibuja la marca; tras un toque, no;
   - captura de Godot de cada pantalla, como las de la propuesta.
3. H3 · Menú principal, pausa y `BotonValor` con el óvalo: capturas.
4. H4 · Zona de pruebas en siete categorías:
   - el guion de la zona, con las categorías nuevas;
   - el validador sigue exigiendo que `GRUPOS` y `OCULTAS` nombren escenas que existen;
   - `docs/salas-de-prueba.md` por categoría.
5. H5 · Contrato («Menú», «Marco de menús»), `docs/pruebas.md`, todos los guiones y el revisor (toca el tema de todos
   los menús).
6. H6 · Prueba de la persona en el S50 y el S21 con el dedo:
   - si todo se lee, en especial Configuración, que con tres columnas ya iba justa (1308 de 1312 px en el S50);
   - si la fila sin caja se entiende como algo que se toca.

   Con un control, la prueba la hacen los compañeros.

## Riesgos

- **Anchos:** Cabin Sketch es más ancha que la fuente de hoy, y Configuración y la fila de categorías iban justas en
  el S50. Si no caben, menos columnas o letra más chica; se mide antes de decidir.
- **Una fila sin caja puede no parecer tocable.** Si en H6 no se entiende, se agrega una raya tenue bajo cada opción.
- **`StyleBox` propio en GDScript:** si `_draw` no se llama como dice la documentación, la marca se dibuja con un
  nodo encima del botón con foco. Se comprueba en H2 antes de seguir.

## Avance (17-oct-2026, sesión autónoma)

Primero en una copia del proyecto; después al repo.

**Medido (H1):**
- Cabin Sketch tiene todos los glifos de los menús: ñ, acentos, ¿¡, «», › y ·.
- Es más angosta que la fuente de antes («Configuración» a 36: 219 px contra 243). El riesgo de los anchos no se dio.
- El alto de una línea a 36 bajó de 50 a 43: `Tema.ALTO_LETRA` = 43. Con eso, `IconoBoton` (que mide ese alto) se
  dibuja un 14 % más chico, también en los pizarrones con el control.

**Decisiones con su porqué:**
- **Fuentes con `load()` y no con `preload`.** Con `preload`, la primera importación compiló `tema.gd` antes de
  importar las fuentes y `validar.ps1` falló. En un clon limpio, el CI fallaría igual. Se probó en la copia borrando
  la importación de las fuentes: con `load()` pasa.
- **Nombres en minúsculas:** `nucleo/fuentes/ofl.txt` y no `OFL.txt`, por la regla de rutas de `res://`.
- **El `StyleBox` propio funciona** (`EstiloGis`, `_draw`): no hizo falta el nodo encima del plan B.
  - Un `StyleBox` no conoce el texto del botón, así que el subrayado va de lado a lado del contenido.
  - En el menú principal y la pausa, cada botón mide lo que su texto (`size_flags_horizontal` = 0): ahí el
    subrayado queda justo bajo la palabra.
  - En las cuadrículas (Configuración, zona de pruebas) cruza la celda y se lee como marca de la fila.
  - Los trazos usan una semilla que sale del tamaño: no tiemblan al redibujar.
- **Tarjetas.** Un botón con contenido propio no puede quedar sin caja: quedaría un hueco. Llevan la variación
  `Tema.TARJETA`, caja de gis con relleno oscuro:
  - las fichas de las ranuras;
  - la caja de diálogo y sus opciones, que van sobre el juego.
- **Encabezado único:** `Tema.encabezado(arriba)`, para las barras armadas en código y para las de los `.tscn`
  (Configuración y sus tres paneles, zona de pruebas). El marco toma las mismas variaciones y la raya.
- **Pestañas:** las categorías de la zona usan `Tema.PESTANA`, sin el margen de la flechita, para que quepan las
  siete. En la vista de 1600 caben; en la de 1280 la fila se desplaza. Con el foco llevan una caja de gis, porque el
  subrayado ya marca la elegida.
- **Detalle de cada sala:** la tabla `SALAS` en `zona_pruebas.gd`, aparte de `GRUPOS`. Así `GRUPOS` conserva su
  forma, que leen el validador y `_leer_salas`. El nombre con acento sale de ahí («Caída», «Cámara»).
- **Barras de volumen y brillo:** el foco es una caja de gis. Una flechita a la izquierda tapaba la pista.
- **`BotonValor`:** se agregó `opciones`; `valor`, `estilo` y `poner_si_no` no cambian.
  - Sí / No y 60 / 120 muestran las dos opciones.
  - Recursos va solo en su óvalo: tiene tres valores, y en automático también dice lo que eligió la detección
    («Auto (alto)»). Las tres juntas no caben en la celda de 420 px.
- **La columna del menú y de la pausa** se separa del borde lo que da el área segura más 64 px, y al menos 128.
  Antes iba a 128 px fijos: con la cámara a la izquierda podía quedar debajo (revisor).
- **Revisor (17-oct-2026):** sin fallos en el código. Pidió poner al día cinco documentos (`docs/pruebas.md`,
  `herramientas/CLAUDE.md`, la comprobación de `zona-pruebas-siete-categorias`, este plan y unos comentarios), ya
  corregidos.
  - Queda para decidir de la persona: `nucleo/fuentes/ofl.txt` trae el correo del autor de la fuente. La licencia
    pide copiar el aviso tal cual, así que se dejó.

**Lo que no entró:**
- el subtítulo y la línea de partida del prototipo bajo el título;
- la fila de ayudas del control abajo.

No estaban en lo aprobado.

**Evidencia** (en la copia; se repite en el repo):
- `validar.ps1` en verde;
- `zona_pruebas_categorias`: 16 casos (6 nuevos: las siete categorías en orden, cada sala con detalle, Puerta B fuera,
  el foco del tema es `EstiloGis`, oculto tras un toque y visible con el control);
- capturas de Godot a 1280×720 y 1600×720 de cada pantalla: principal (con control y con el dedo), Configuración,
  ranuras, zona, pausa y diálogo.

**Falta:** H6, la prueba de la persona en el S50 y el S21.

