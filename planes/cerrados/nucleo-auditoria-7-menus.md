CERRADO

# Auditoría, paso 7: menús (T5) con `nucleo-tienda-gis` y el menú de pausa

Paso 7 de `nucleo-auditoria-codigo.md`. Ids del anexo: M1, M3-M7, M10, M15. Junto con el plan aprobado
`nucleo-tienda-gis.md` (tienda, confirmación compartida, viaje rápido y el menú de pausa como Silksong).

Lo que cambia a la vista es solo lo aprobado: la tienda, el cobro de la estación, el viaje rápido y el menú de
pausa de `nucleo-tienda-gis`. Lo de T5 no cambia el juego.

## Qué se hace

1. **Consulta:** que los hallazgos de T5 sigan vigentes, cómo encajan con `nucleo-tienda-gis` y en qué orden van
   las piezas.
2. **Piezas, una por agente,** en el orden que salga de la consulta.

## Hitos

1. `validar.ps1` → `fallos=0`; `correr-guiones.ps1` → `MALOS=0`. Los `.esperado` cambian solo en lo aprobado de
   `nucleo-tienda-gis`, y cada cambio lleva su porqué.
2. Capturas a 1280×720 y 1600×720 de cada pantalla que cambia, tomadas con ventana en la PC.
3. Lo que se comprueba con el dedo, en el teléfono, en el paso 11.
4. Revisor, porque toca el contrato («Componentes»).

## Consulta (18-oct, agente investigador) y decisiones de la sesión principal

Los ocho ids de T5 siguen vigentes, con las líneas movidas. M4 está a medias: `Tema.encabezado` existe pero sin
ícono. Una estación de la zona de pruebas sí tiene rectángulo en `mapa/indice_salas.tres` (`prueba_1` a
`prueba_4`); el único caso sin mapa es cuando falta el bloque `mapa/`.

Decisiones, tomadas con la consulta y el advisor (la persona autorizó la tanda autónoma el 18-oct):

| Decisión | Elegido | Por qué |
|---|---|---|
| Título «Pausa» | Se queda, centrado arriba del adorno ancho | No está entre lo que el plan cambia, y lo que no está aprobado no cambia. Quitarlo es una línea |
| Velo de la pausa | Se queda el nodo `Panel` (el `ColorRect` al 0,7) | «Sin panel» quiere decir sin caja alrededor de las opciones. El juego sigue oscurecido detrás, y `prueba_marco` lee `Panel/Opciones/...` |
| Dónde vive la confirmación de la estación | Un menú que pausa el árbol, como la tienda: su `CanvasLayer`, `PRIORIDAD_FISICA` y filas en «Grupos» y «Capas de dibujo» | Un solo mecanismo, que es el objetivo de M1. Con E5, los botones táctiles se apagan solo con el árbol pausado: si el cobro no pausa, se podría saltar durante el cobro. Cambio visible dentro de lo aprobado: el cobro de la estación ahora pausa |
| PejeCoins con la tienda abierta | El contador del HUD (arriba a la izquierda, `interfaz/hud.gd:3`) a la vista mientras la tienda está abierta. El velo cubre solo la mitad derecha; la capa del HUD no cambia | Las monedas quedan en la mitad que no tapa el panel. Subir el HUD de capa lo pondría sobre la pausa y el marco |
| Viaje rápido y `mapa/` | `ResourceLoader.exists` y `get()` sin nombrar `IndiceSalas`; excepción nueva en `nucleo/CLAUDE.md` y en el contrato | Es el mismo patrón con que la sala carga `pantalla_mapa.tscn` |
| Líneas entre estaciones | En el orden de la tabla de estaciones | Es reproducible y lo controla quien escribe el contenido. Va en la fila `MenuEstaciones` del contrato |
| M5, M6/M7 | Un solo intento. Si el revisor o la corrida completa fallan, se descarta con su porqué | No cambian nada a la vista, y M6/M7 rehace 700 líneas contra la prueba más grande (94 casos) |

Orden:
1. M15, junto con la forma nueva de `EstiloGis`.
2. M1 en ranuras y Salir.
3. M1 en tienda y estación, con revisor.
4. Pausa.
5. Tienda.
6. Viaje rápido, con revisor.
7. M3 y M4.
8. M10.
9. M5.
10. M6 y M7.
11. Revisor del paso.

Capturas: `scratchpad\capturas.ps1`, arreglado para el enum del paso 6. La salida va a `scratchpad\capturas\`; las de
antes del paso, a `capturas\antes\`.

## Avance

- 18-oct, pieza 1 (M15 y forma de gis), hecha por un agente.
  - **Variaciones nuevas en `Tema`:**
    - de Label: `TITULO_JUEGO`, `TITULO_PAUSA`, `DESTACADA`, `PREGUNTA`, `QUIEN` y `TENUE`;
    - de Button: `OPCION_CHICA` y `OPCION_CENTRADA`, con foco `LADOS`, una flechita a cada lado y sin subrayado;
    - adornos `ADORNO_ANCHO` y `ADORNO_CHICO`, que son `PanelContainer` con la forma `ADORNO` de `EstiloGis`.
  - **Overrides cambiados por variaciones:** los 10 de la lista. Los de `toques.gd`, `caja_gris.tscn` y
    `editor_controles.tscn` no coinciden con ninguna variación y se quedan.
  - **Capturas:** las 10 a 1280×720, idénticas píxel por píxel a las de `antes\`. Repetir la toma sin cambios también
    da 0 diferencias, así que la comparación es reproducible. Lo que ninguna captura muestra se midió por propiedades:
    solo la fila del inventario cambia de forma (`modulate` → color con alfa), con el mismo color final.
  - La sesión principal revisó `capturas\forma_foco_lados.png`: flechitas a los lados, adornos ancho y chico.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=248 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`. Ningún `.esperado` cambió.
  - **Para la confirmación compartida:**
    - Sí y No con ancho mínimo de 300 px dejan las flechitas lejos del texto: quitar ese mínimo;
    - la pregunta mide 40 en ranuras y 36 en la tienda: se queda cada una como está.
- 18-oct, pieza 2 (M1 en ranuras y Salir), hecha por un agente.
  - **`Confirmacion`** (`nucleo/confirmacion.gd`): armada en código, a pantalla completa, con `abrir(pregunta, si, no,
    foco)` y las señales `confirmada` (una vez por `abrir`; no cierra) y `cancelada`.
    - El aspecto se fija antes de entrar al árbol: `alfa_velo`, `separacion`, `ancho_pregunta`,
      `variacion_pregunta` y `variacion_boton`.
    - Con `variacion_boton` vacía, los botones conservan los 300 px de hoy.
    - Quien la abre llama a `cancelar()` desde su Atrás.
  - **Ranuras y Salir** la usan. `menu.tscn` pierde el subárbol `Confirmar`.
  - **Pruebas:** `prueba_ranuras` pasa de 57 a 64 casos. Las cuatro mutaciones fallan.
  - **Capturas:** las 20 de antes y después (Borrar, Restaurar, Salir y la vuelta, a 1280×720 y 1600×720) son
    idénticas.
  - **Fallo que atrapó el guion y no las capturas:** una etiqueta con ajuste de línea que recibe su ancho después de
    entrar al árbol se infla hasta 1847 px de alto. Se arregló armando la pieza en `_ready`.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=249 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`.
  - **Decisión de la sesión principal:** los ajustes de aspecto distintos de ranuras (0,8 / 32 / 800 / PREGUNTA) y de
    Salir (0,7 / 24 / una línea / TITULO) no se unifican.
    - Por qué: igualarlos cambia cómo se ven, y eso no está aprobado.
    - La tienda y la estación sí toman el aspecto de Silksong, que está aprobado.
  - **Para proponer a la persona:** la trampa de la etiqueta con ajuste de línea, como una línea de la skill
    `ui-tactil`.
- 18-oct, pieza 3 (M1 en tienda y estación), hecha por un agente. Cambio a la vista, aprobado.
  - **`Confirmacion`:** gana una línea opcional de cantidad, «50 PejeCoins» en `TITULO`. Ranuras y Salir no la usan
    y sus 20 capturas siguen idénticas.
  - **Tienda:** usa `Confirmacion` con `OPCION_CENTRADA` y el foco en Sí. La pregunta queda en «¿Comprar X?» y el
    precio va en la línea de cantidad.
  - **`CobroEstacion` (nuevo):** capa 20, pausa el árbol, `PRIORIDAD_FISICA`, grupo `pantalla_encima`. Volver, pausa
    y Atrás cancelan. El jugador ya no queda en `hablando`. El resultado («Estación abierta…», «No te alcanza.») se
    sigue diciendo en la caja de diálogo, como antes.
  - **Pruebas:**
    - `tienda` pasa de 31 a 32 casos y `estaciones` de 23 a 30: entran B sin curar, pausa sin abrir la pausa y el
      orden en la física;
    - las 7 mutaciones fallan.
  - **Capturas** en `capturas\tienda-confirmar-despues\`, a 960, 1280, 1600 y 1760 de ancho. La sesión principal
    revisó la del cobro a 1280×720: la pregunta, el costo, y Sí con flechitas.
  - **Moneda como texto «PejeCoins»:** el círculo de la moneda vive en `interfaz/hud.gd` y el núcleo no depende de
    `interfaz/`.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=250 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`.
  - **Riesgo para el revisor:** que confirmar con A, que también es saltar, no haga saltar al cerrar.
- **18-oct, revisor de la pieza 3: aprobado.** `validar` → `fallos=0`; `correr-guiones` → `151 OK`. Una sonda con
  eventos reales lo comprobó: A y Espacio en Sí, No y Volver cierran sin saltar ni atacar, y Sí cobra una vez.
  - **Hallazgo nuevo, de antes de este paso (también en Continuar de la pausa):** si A se pulsa y se suelta dentro
    del mismo cuadro (unos 16 ms), el `Button` emite al soltar y quita la pausa. Entonces el jugador lee `saltar`
    recién pulsado y salta.
  - No se arregla en este paso: el arreglo toca la pausa y el jugador. Va al reporte como decisión de la persona,
    con un arreglo propuesto: que el jugador ignore `just_pressed` en el primer tick después de quitarse la pausa.
- 18-oct, pieza 4 (la pausa como Silksong), hecha por un agente. Cambio a la vista, aprobado.
  - **Acomodo:** `Opciones` anclada al centro. De arriba abajo: el título «Pausa», el adorno ancho, las tres opciones
    con `OPCION_CENTRADA` y el adorno chico. El velo `Panel` y todas las rutas de nodos se quedan.
  - **Fuera:** `margen_columna` ya no se usa en la pausa.
  - **Capturas:** config, mando, marco y zona salen idénticas a las de `antes\`; solo cambia la pausa. La sesión
    principal revisó la de 1280×720: queda centrada, con los dos adornos y flechitas a los lados de Continuar, junto a
    su ícono B.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=250 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`. Los `.esperado` de la pausa no cambian.
  - **Texto viejo que no se toca:** el `que` de la entrada `menus-gis` y `nucleo-menus-gis.md:63` dicen «pausa a la
    izquierda». Se quedan como registro de lo que se hizo entonces.
- 18-oct, pieza 5 (la tienda en el panel derecho), hecha por un agente. Cambio a la vista, aprobado.
  - **`MenuTienda`, acomodo:**
    - el fondo es transparente a pantalla completa y detiene los toques;
    - el velo cubre solo la mitad derecha;
    - la lista va a la izquierda del panel, con ícono, moneda y precio;
    - el detalle (nombre y descripción) va a la derecha, o abajo si quedan menos de 240 px;
    - la franja de gis marca la fila elegida;
    - sale el encabezado «Tienes N PejeCoins».
  - **Piezas nuevas o cambiadas:**
    - `IconoArticulo` (nuevo): íconos de gis en código para moneda, vida, amuleto, habilidad y mapa;
    - `ListaElegir` gana opciones (`cuerpo`, `variacion_fila`, `con_franja`); sin ellas se ve igual, y las capturas
      de estaciones salen idénticas.
  - **PejeCoins:** el bus gana `tienda_abierta` y `tienda_cerrada`. El HUD las escucha y mantiene el contador fijo,
    corriendo con el árbol pausado, mientras la tienda está abierta. El núcleo no depende de `interfaz/`.
  - **Decisión del agente: no hay franja fija con la lista corriendo por debajo.** Desplazar la lista al dar el foco
    movería la fila bajo el dedo, así que queda `follow_focus`.
  - **Pruebas:**
    - `tienda` pasa de 32 a 38 casos y `monedas_hud` de 13 a 18;
    - `tienda.guion` va con `fin` 1000 y `monedas_conteo.guion` con 2400;
    - `bus_eventos` cuenta 30 señales;
    - las 9 mutaciones fallan.
  - **Capturas** en `capturas\tienda-despues\`, a 960, 1280, 1600 y 1760 de ancho. La sesión principal revisó la de
    1280×720: el HUD muestra 300, la franja está en «Pluma del mapa», el detalle va a la derecha y las filas grises
    son lo que no alcanza. El nombre de la tienda baja a dos líneas junto a Volver.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=251 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`. Lleva revisor, porque toca el bus.
- **18-oct, revisor de la pieza 5: aprobado.** Una sonda con eventos reales comprobó varias cosas:
  - las señales salen en pareja en todos los cierres, y `cerrar()` dos veces emite una sola vez;
  - el HUD vuelve a `INHERIT`;
  - los toques en la mitad izquierda no hacen nada, y las filas, No y Volver responden;
  - `ListaElegir` sin las opciones nuevas se porta igual.

  Hallazgos:
  - **Latente:** si `MenuTienda` (lo mismo `MenuEstaciones` y `CobroEstacion`) se libera sin `cerrar()`, quedan
    `paused` y el HUD en ALWAYS. Hoy nada lo dispara, porque con el árbol detenido no corren la muerte ni las puertas.
    Va al paso 13 como caso por cubrir.
  - **Desviación de `nucleo-tienda-gis` (H2):** no hay franja fija con la lista corriendo por debajo. Va al reporte
    para que la persona la acepte o la pida.
- 18-oct, pieza 6 (el viaje rápido con mapa de gis), hecha por un agente. Cambio a la vista, aprobado.
  - **`MapaEstaciones` (nuevo):** se dibuja con `_draw`.
    - Pone un círculo por estación abierta en el centro de su sala.
    - Une cada estación con la siguiente con una línea, en el orden de la tabla.
    - La estación con foco lleva un anillo. La actual va en gris, con un punto y «Aquí» debajo.
  - **Lectura del índice:** `MenuEstaciones` lo lee con `ResourceLoader.exists`, `load()` y `get(&"rectangulos")`.
    - Queda la lista sola si falta el índice, si falta el rectángulo de alguna estación o si al mapa le quedan menos
      de 240 px.
    - Ayudas nuevas abajo: Viajar y Cancelar.
  - **Pruebas:** `estaciones` pasa de 30 a 35 casos y las 6 mutaciones fallan. `mapa/` sí viaja en el paquete
    (`export_presets.cfg:11`).
  - **Capturas** en `capturas\estaciones-despues\`. La sesión principal revisó la de 1280×720 con el foco en la otra
    estación: lista, mapa y ayudas se ven bien.
    - Volver se monta sobre los corazones del HUD en la barra de arriba, pero eso ya pasaba antes del cambio (captura
      de `antes\`). No es de esta pieza.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=252 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`.
  - **Instrucciones de Claude que tocó el agente sin mostrárselas antes a la persona:**
    - en `nucleo/CLAUDE.md`, la excepción nueva de `indice_salas.tres`; la exige el mismo archivo («una excepción
      nueva va aquí»);
    - en `mapa/CLAUDE.md`, una nota en la fila de `indice_salas.tres`.

    Se dejan y van al reporte para que la persona las apruebe o las quite.
  - **Decisión del agente:** las ayudas también salen en el modo «lista sola», en lugar del pie vacío de antes.
- **18-oct, revisor de la pieza 6: aprobado.** Lo que comprobó:
  - `validar` → `fallos=0`, `correr-guiones` → `151 OK` y `estaciones` → 35/0;
  - `nucleo/` no nombra clases de `mapa/`;
  - una ruta que no existe deja la lista sola, sin `ERROR:`;
  - elegir, pagar, viajar y cerrar con B se portan como antes;
  - la excepción dice lo mismo en el código, `nucleo/CLAUDE.md` y el contrato.
- 18-oct, pieza 7 (M3 y M4), hecha por un agente. No cambia nada a la vista.
  - **`PaginaMarco`** (`nucleo/pagina_marco.gd`, una `CanvasLayer`): capa 20, `abierta`, `id_pagina()`,
    `titulo_pagina()`, `mostrar_en_marco()` y `ocultar_de_marco()`.
    - La extienden `PaginaInventario`, `PantallaAmuletos` y `PantallaMapa`.
    - `MarcoMenus` usa `Array[PaginaMarco]` sin ningún `call()`.
    - `bloquea_pausa` sigue con `call` en `pausa.gd`, porque los del grupo `pantalla_encima` no son páginas.
  - **`Tema.encabezado(arriba, icono = &"volver")`** pone el ícono sin duplicarlo. Se quitaron los íconos puestos a
    mano en Configuración, la zona de pruebas y el marco.
  - **Capturas** (`capturas-m3m4.ps1`, con audio, créditos, brillo, ranuras, nueva partida, amuletos y mapa):
    - 24 de 24 idénticas antes y después;
    - tienda, 7 de 7;
    - estaciones, 1 de 1;
    - las 10 de siempre, 10 de 10.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=253 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`. Ningún `.esperado` cambió.
  - **Incidente en el scratchpad:** tres capturas de referencia de `capturas\antes\` (`tienda_confirmar`,
    `tienda_tras_cancelar` y `estacion_cobro`, PlayStation, 1280) se sobrescribieron con el estado de antes de la
    pieza 7. Ninguna comparación posterior las usa. Las de antes de la pieza 3 se perdieron.
  - **El revisor de M3** (contrato «Marco de menús») va con el del cierre del paso.
- 18-oct, pieza 8 (M10), hecha por un agente.
  - **Cambio:** la lista de amuletos va en un `ScrollContainer` llamado `Desplazable`, que sigue el foco, como en
    `ranuras`. Con lo que cabe se ve igual.
  - **Capturas:**
    - 24 de 24 idénticas;
    - con 3 y con 4 amuletos, también idénticas;
    - con 12 se desplaza, y desde 5 aparece la barra vertical del tema, de 8 px a la derecha.
  - **Pruebas:** `amuletos` pasa de 14 a 16 casos y las 2 mutaciones fallan.
  - **Resultados:** `validar` → `OK  VALIDACION archivos=253 fallos=0`; `correr-guiones` → `RESUMEN total=151 OK=151
    MALOS=0`.
  - **Decisión del agente: el aviso se desplaza junto con la lista.** Fijarlo cambiaría el centrado de hoy.
  - **Pendiente:** arrastrar con el dedo una lista de 5 amuletos o más. Hoy solo se consigue la brújula, así que hace
    falta un APK con más amuletos.
- **18-oct, pieza 9 (M5): descartada tras leer el código; no se tocó nada.**
  - **La cuenta ya está en un solo lugar:** `Tema.area_menu(vista, reservado_abajo)`. Lo que se repite son unas
    6 líneas de conexión en `ranuras` y `nueva_partida`.
  - **Una franja como parámetro de `Tema.ajustar` no funciona:** la franja llega después de `_ready`
    (`menu.gd:86-88`).
  - **`NuevaPartida` tampoco puede usar `ajustar`:** reacomodaría la pantalla con el teclado del teléfono abierto.
  - **Configuración** usa un espaciador que da otro resultado, así que cambiarlo mueve píxeles.
  - **Son 2 casos** y la regla del proyecto pide 3 para generalizar.
  - **Posible fallo visible, para que decida la persona (no comprobado):** con el aviso de pocos toques, Audio,
    Mando, Créditos y Brillo no reservan la franja de abajo.
- 18-oct, pieza 10 (M6 y M7), hecha por un agente, que salió al primer intento. `configuracion.gd` pasa de 709 a 440
  líneas.
  - **Partes nuevas:**
    - `PanelAudio` (nuevo, script del nodo que ya existía);
    - `PantallaBrillo` (nueva, creada en código con el nombre `PanelBrillo`).
  - **Señales hacia `Configuracion`,** que sigue siendo la única que guarda.
  - **`enum Seccion`,** con un solo «panel actual». Se llama `Seccion` y no `Panel` porque `Panel` es una clase de
    Godot.
  - **API y nodos:** la API pública y las rutas de nodos se conservan.
  - **Capturas:** las de `m6-antes` y `m6-despues` son idénticas, 24 de 24.
  - **Resultados:**
    - `validar` → `OK  VALIDACION archivos=255 fallos=0`;
    - `correr-guiones` → `RESUMEN total=151 OK=151 MALOS=0`;
    - `menu_configuracion`, 94/0.
- **18-oct, revisor del cierre del paso: dos fallos menores, ya corregidos por la sesión principal.**
  - El `que` de `configuracion-partida` decía que la API pública no cambiaba, pero 8 constantes que solo se usaban por
    dentro se mudaron. Se corrigió el texto.
  - La cabecera de `confirmacion.gd` tenía 5 líneas y quedó en 4.
  - Después de corregir: `validar` → `OK  VALIDACION archivos=255 fallos=0`; `ranuras`, `tienda` y `menu` → `OK=3`.
  - Lo demás quedó comprobado sin hallazgos: contrato y código, `call()`, uids de los `.tscn`, rutas de la pausa,
    las 9 entradas, cabeceras, `:=` y `.uid`.
  - **De antes de este paso, para el paso 13 o la persona:**
    - la página Mapa no asigna el tema a su fondo y sus botones + y − llevan un override de letra;
    - `zona_pruebas.tscn:42` repite `font_size = 48`.
