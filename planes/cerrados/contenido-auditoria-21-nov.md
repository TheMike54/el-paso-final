CERRADO (21-nov-2026: entró a `main` con el PR #42, `677a829`. Escrito y aprobado por la persona el 21-nov-2026)

# Auditoría del 21-nov-2026: documentación al día, código muerto y banco de raices_3

Tres revisiones de solo lectura (documentación técnica, manual con los CLAUDE.md, y código muerto y redundancia en lo
que entró desde el 15-nov) encontraron un fallo del juego, unos 35 puntos de documentación desactualizada y código
sin uso. Este plan los corrige en la rama del PR #42 y, al terminar, pide una auditoría nueva sin contexto.

## Alcance
1. Banco de `raices_3` sin mesa con sillas ni `mirando = 1` (el mismo fallo de `docs/errores/2026-11-17-banco-sin-mesa.md`):
   se le pone como en `raices_7`, con su archivo en `docs/errores/` y un guion que lo cubra.
2. Volador de pruebas y Polilla son el mismo enemigo: la zona de pruebas usa la Polilla y se quita el volador.
3. Código muerto: `despertar()` del volador copiado en la Polilla, `PantallaMapa.acercar()`, `Jugador._hay_suelo_fijo()`
   y el caso repetido de `prueba_utiles.gd`; comentarios viejos de los guiones `raices_2_puertas`, `raices_3_puertas` y
   `raices_4_puertas`; el comentario de
   `Utiles.TODOS`.
4. `PantallaCierre` lee las acciones en `_physics_process`; `SalidaCierre` usa las constantes de `Puerta`.
5. La entrada `sala-raices-1-ruta` de `contenido/funciones.json` deja de hablar del hueco hacia `celda_3`.
6. El aviso «sala sin guion» del validador pasa a fallo: las 13 salas del juego ya tienen guion.
7. Documentación: lo que las dos auditorías marcaron en `docs/` y `docs/manual/`, y `ESTADO.md`.
8. El plan `nucleo-menus-pausa` pasa a `planes/cerrados/` (sus partes entraron con el #37).
9. Al terminar: `validar.ps1`, la suite, `revisor`, y una auditoría nueva sin contexto de documentación y código.

## Fuera de alcance
- Mover las fichas de `contenido/npc/guia_raices/` a `contenido/npc/eterno/`: se hace en el panel FileSystem del editor;
  lo hace la persona cuando abra el editor.

## Decidido
- 21-nov-2026 20:45: todo va en el PR #42, sin abrir uno nuevo, y al terminar se audita otra vez sin contexto. «Sí, tomo
  todas tus recomendaciones y una vez terminado esto, manda a que se audite otra vez nuevamente, pero sin contexto» y
  «van a ir en el PR que ya estamos a punto de fusionar. No vamos a abrir uno nuevo».
- 21-nov-2026 20:45, punto por punto de «tomo todas tus recomendaciones»:
  - Banco de `raices_3`: se arregla en este cambio.
  - Volador y Polilla: unificar (recomendación 1).
  - Entrada `sala-raices-1-ruta`: corregir su texto (recomendación 2).
  - Aviso «sala sin guion»: pasa a fallo, con `revisor` (recomendación 3).
  - Fichas de `guia_raices`: las mueve la persona desde el editor, o se quedan (recomendación 4).
  - Documentación, código muerto, `PantallaCierre`, `SalidaCierre` y cierre del plan de menús: se hacen.
- 21-nov-2026 21:01, decisiones de Claude al hacerlo, con su porqué y lo medido:
  - Banco de `raices_3`: `Silla` y `mirando = 1` copiados de `raices_7`. `raices_3_banco` comprueba las dos cosas; con la
    escena de antes falla («no existe el nodo 'Banco/Silla'», `mirando` 0) y con la nueva pasa.
  - Volador: `volador.tres` usa `contenido/enemigos/polilla/polilla.gd` y `prueba_enemigo_datos.gd` lee
    `datos_polilla.gd`; se borran `volador.gd` y `datos_volador.gd`. La sala «Volador» se queda: la zona de pruebas lista
    sola la carpeta de enemigos, `prueba_zona_pruebas.gd` exige una sala por comportamiento y borrar una escena se hace
    desde el editor. Con eso `despertar()` de la Polilla deja de estar muerta (la llama `prueba_moviles.gd`).
  - `PantallaMapa.acercar()` se queda, documentada como pública para la prueba del mapa: quitarla obligaría a la prueba a
    llamar a una función privada.
  - El caso «los cupos ocupados impiden poner una candidata valida» de `prueba_utiles.gd` se queda: es el único que mide
    el límite con un estado cargado cuyos cupos tienen ids ajenos al catálogo; el otro usa los útiles reales.
  - `Jugador._hay_suelo_fijo()` se borra; su comentario pasa a `PuntoSeguroJugador.hay_suelo_fijo()`, la que se usa.
  - `SalidaCierre` usa `Puerta.COLOR_PROVISIONAL` y `Puerta.ALTURA_AVISO`. Su dibujo provisional (120×200) no se cambia
    a la forma de colisión (40×160): es un cambio visual sin pedir.
  - Validador: `_avisar_salas_sin_guion` pasa a `_revisar_salas_sin_guion` y anota un fallo; con `validar.ps1` da
    `fallos=0` (las 13 salas tienen guion). Con la regla devuelta a aviso, `validador.guion` falla («una sala de contenido
    sin guion falla; obtenido: []»).
  - Entradas nuevas al final de `funciones.json`: `banco-raices-3-arte` (contenido) y `validador-sala-sin-guion-falla`
    (herramientas).
- 21-nov-2026 21:17, hallazgos de la auditoría sin contexto. «arrela todos lo q tu recomiendez, analiza cual seria lo mejhor
  para resolverlo, adelante». Punto por punto:
  - A (documentación, comentarios, código sin uso, comprobación de vida de `polilla_vence`, monto de la mochila,
    cálculo repetido del marco): se hace.
  - Regla del validador que exige `Silla` y `mirando` en los bancos de `contenido/`: se hace, con `revisor`.
  - Entradas de `funciones.json` que prometen más de lo que comprueban o citan una ruta vieja: se corrigen.
  - Guion `raices_6_oculta_una_vez`: se hace.
  - Unir `_al_accion` de Amuletos y Útiles: no se hace ahora (recomendación: no tocar los menús con el PR por fusionarse).
  - Diálogo del Eterno «El banco está más allá» y sala de pruebas «Volador»: los decide Claude («analiza cual seria lo
    mejor»).
- 21-nov-2026 21:24, decisiones de Claude sobre la auditoría sin contexto, con su porqué y lo medido:
  - Diálogo del Eterno «Sigue adelante. El banco está más allá»: se queda. El banco (x=700) está más adelante que el
    Eterno (x=350) en el sentido de la marcha: no es un error.
  - Sala de pruebas «Volador»: se queda. Borrarla exige el editor y quita una sala de la zona sin ganar nada; el caso
    de `prueba_zona_pruebas.gd` pasa a decir «las cuatro salas de enemigos de prueba».
  - Regla del banco: en `_revisar_sala`, solo para rutas de `contenido/`, falla si el banco no tiene un hijo `Silla`
    `Sprite2D` con textura o si `mirando` es 0. Cuatro casos nuevos en `prueba_validador.gd` (192 a 196): sin Silla falla,
    con Silla y `mirando` 0 falla, con las dos no falla, y una sala de prueba sin Silla no falla.
  - `raices_6_oculta_una_vez`: sale por la puerta derecha a `raices_7` y vuelve (en `raices_6` no hay otra salida
    cercana). Con el coleccionable sin memoria falla («coleccionable_obtenido esperado=1 obtenido=2»); con el amuleto
    sin memoria pasa, porque `Partida.obtener_amuleto` no da dos veces un amuleto tenido: queda dicho en su comentario.
  - `polilla_vence`: vida 2 en el cuadro 58, 1 en el 88 y vencida en el 118 (medido); antes pasaba con vida de 1 a 6.
  - `Jugador._suelo_fijo_bajo` se borra: `prueba_plataformas.gd` llama a `jugador._punto_seguro.suelo_fijo_bajo`.
  - `PaginaInventario.perdido` usa `Guardado.entero`, como `Partida.monto_mochila`: con un monto entero no cambia nada.
  - Entradas corregidas de `funciones.json` (aprobadas): `sala-raices-1-ruta` suma `celda_4_tiro`;
    `sala-raices-2-puertas` suma `raices_1_puertas` y deja de hablar del hueco; `sala-raices-6-oculta` suma el guion
    nuevo; `auditoria-final-documentos` apunta a `planes/cerrados/`. Nueva: `validador-banco-con-silla`.
- 21-nov-2026 22:03: el PR #42 entra a `main` (`677a829`) con la repisa de `raices_4` tras un techo rompible en lugar del
  cuarto tras un muro que pedía el #21, y el plan se cierra. «ya quedó merge, cierra el plan».
