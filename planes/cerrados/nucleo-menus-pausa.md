CERRADO (21-nov-2026: las partes 1 a 8 entraron a `main` con el PR #37 el 16-nov-2026; las pruebas en el teléfono que
quedan pendientes están en `ESTADO.md`. Escrito el 1-nov-2026; aprobado por la persona el 3-nov-2026)

# Menús de pausa según los mockups aprobados

Lleva al juego Inventario, Amuletos, Útiles y el cambio de página de la propuesta D. Los mockups mandan en cómo se ve y
se comporta; su HTML no se copia. Sus 10 reglas de UX son criterio de aceptación de cada pantalla.

## Decisiones cerradas (la persona, 1-nov-2026)

1. Una flecha a cada lado, a media altura, con zona de toque de 108×240 desde el borde, dentro del área segura y con su
   botón del control. Arriba, el título y los nombres de las vecinas, sin «‹ ›» y tocables.
2. Inventario: La Pluma con su katana, Azulitos y 6 habilidades con símbolo y detalle. Nombres escritos, no sacados del id.
3. Los símbolos de las habilidades se dibujan con código, de gis, iguales a los de los mockups.
4. Amuletos y Útiles: tocar solo elige; poner o quitar va en su botón. El detalle siempre a la derecha, y explica por
   qué algo no se puede poner.
5. Útiles: 4 cupos, solo poner o quitar, sin colores ni tipos. La mochila se dibuja con código, en línea de gis y sin relleno.
6. Son 5 útiles: Brújula, Gato de la Suerte (deja de ser amuleto), Log de Errores, Cartera de Emergencia y Suela Antiderrapante.
7. Entran los íconos aprobados de los 5 útiles y de Caparazón de Cucaracha. Los otros 8 amuletos conservan la forma de gis;
   el arte de 7 lo hace un integrante del equipo, y Caché no se pinta.

## Decisiones cerradas (la persona, 2-nov-2026)

1. En Las Raíces se consiguen 2 amuletos: Patas de Cucaracha (`raices_4`) y Caparazón de Cucaracha (oculto de `raices_6`). Los
   otros 8 van en un plan aparte, después de publicar. Caché queda fuera de la v1.
2. La tienda de `raices_3` vende la Brújula.
3. Los menús tienen estado sin amuletos y con amuletos.
4. Ninguna mecánica nueva en este plan: casi todas dependen de zonas o jefes que no existen. Van en su propio plan.
5. La ficha de Caparazón entra con #25, no con este plan: costo 2 y `invulnerable_extra` 30 (0,5 s) para probar; se ajusta jugando.
6. Suela, Log de Errores y Cartera de Emergencia no se consiguen en la v1. Su efecto se implementa en este plan (`utiles-efectos`) y
   solo se prueba en la sala «Equipo». Su definición final y dónde se consiguen quedan para después de publicar.
7. La imagen de la katana está aprobada: puede entrar al repo.

## Decidido

- 15-nov-2026: se empieza el plan en la rama `feature/nucleo-menus-pausa`, desde `main` en `bfe55ad`, con su PR al
  final. «adelante con el #24».
- 15-nov-2026, noche: tanda autónoma de las partes 2 a 8, sin la persona; la 9 (cierre y APK) espera a la persona.
  «Te dejo en sesión autónoma, Claude, me voy a dormir. Entonces, pues tú continúa» y «Adelante». No arrancó: la
  sesión seguía en bypass de permisos, y la tanda autónoma solo corre en modo `auto`.
- 15-nov-2026, noche: la persona, ya avisada de que la sesión sigue en bypass, ordena arrancar igual; excepción a la
  regla de modo `auto` solo para esta tanda. «ADELANTE ADELANTE».
- 15-nov-2026, Claude, parte 1 `marco-flechas`:
  - El `IconoBoton` de la flecha va dentro de un `Control` intermedio. Con un `Button` de padre, el ícono le reserva
    el lugar como a un texto y se mueve de su sitio.
  - La flecha se aclara solo mientras se oprime, no al pasar el puntero: en táctil, el último toque la dejaría encendida.
  - Las páginas actuales solo se apartan de las flechas. La columna de equipo y la descripción de Amuletos quedan a 108
    del borde. Cuentan el recorte cuando las partes 5 a 7 las rehagan con `area_contenido`.
  - `marco.guion` pasa de `fin 120` a `fin 180`: los casos nuevos esperan cuadros, y con 120 se cortaba en el caso 38.
- 15-nov-2026, Claude, parte 2 `utiles-cuatro-cupos`:
  - Ids `gato_suerte`, `log_errores`, `cartera_emergencia` y `suela_antiderrapante`, cortos como `patas_cucaracha`.
    Se guardan: no se renombran después.
  - Un archivo con más de 4 útiles puestos se lee con los primeros 4 (`desde_diccionario`): así ninguna página
    tiene que dibujar un cupo de más. No sube `Guardado.VERSION`: la forma del campo no cambia.
  - Los íconos llenan los 112 px como Patas (recorte al contenido y escala), con mipmaps, y se revisaron a 56 px
    sobre fondo oscuro. El de Caparazón no entra aquí: llega con su ficha en #25.
  - Sin regla nueva del validador para `Utiles.TODOS`: el guion `utiles` compara el catálogo del juego con esa lista.
  - La página Útiles actual ya dice «cupos» en lugar de «ranuras» (la palabra se usa también para las partidas).
- 15-nov-2026, Claude, parte 3 `utiles-efectos`:
  - `DanoContacto.de_enemigo` es un `@export` apagado por omisión: lo encienden el `DanoContacto` de `enemigo.tscn` y
    `AtaqueEnemigo._init` (cubre los proyectiles). Así todo lo del escenario (aspas, cables, fosos y los dañinos de
    las salas de prueba) queda fuera sin tocar sus escenas.
  - Log de Errores: un bloque es `Partida.INSPIRACION_POR_GOLPE` (11, lo mismo que un golpe dado). No se da si el golpe
    mata (la muerte vacía la Inspiración) ni con un peligro.
  - Suela Antiderrapante: la mitad del retroceso en x y en y. No toca el rebote del parry ni del pogo, que no son golpes
    recibidos.
  - Los números de los útiles (`FACTOR_BOTIN_GATO` 1,5 y `FACTOR_EMPUJE_SUELA` 0,5) viven en `Utiles`, junto a sus
    ids: la ficha de un útil no lleva números (contrato).
  - Sale `amuleto_botin` del catálogo de pruebas y de la sala «Equipo»; entra `amuleto_pesado` (costo 2, sin efecto)
    para que `prueba_amuletos` siga probando un amuleto que no cabe. La entrada vieja `amuletos-efectos` de
    `funciones.json` nombra el botín y no se reescribe (regla del repo); la nueva `utiles-efectos` la reemplaza en eso.
- 16-nov-2026, Claude, partes 4 y 5 `detalle-de-menu` y `pagina-amuletos-d`:
  - El detalle es una clase propia (`DetalleMenu`) que llena quien la usa con `mostrar()`; el botón se esconde con
    un rótulo vacío. Así Útiles e Inventario lo reutilizan sin saber de amuletos.
  - La fila elegida queda encendida (caja de gis blanca, `toggle_mode`); lo que está en uso lleva una palomita de gis
    (`MarcaUso`). Así elegido y en uso se distinguen sin leer ni depender del color.
  - El costo de cada fila va solo en círculos, sin la palabra «costo»: no cabía junto a «En uso» en 220 px. El número
    sale en el motivo de «No cabe».
  - Texto de las filas en 28 con interlineado -6: con el de Cabin Sketch, tres líneas no cabían en 108 y la elipsis con
    el nombre en dos líneas cortaba a una sola (visto en la captura de 1920×1080). Se quitó la elipsis; el nombre
    queda en hasta 2 líneas.
  - El indicador de más abajo se apaga con el alfa, no con `visible`, para que la lista no brinque.
  - Uno fuera del catálogo se ve con su id con mayúsculas y sin motivo: no hay texto real que darle.
  - Capturas en 1280×720, 1440×1080 (4:3), 1760×720 (22:9) y 2560×1440; la de 1920×1080 se pasó del tiempo la segunda
    vez, y la primera mostró el corte de nombres que se arregló.
- 16-nov-2026, Miguel, partes 5 a 8 seguidas: «termina el trabajo para q podamos pobar todo termina de la 5 a la 8»;
  y en modo bypass: «ADELANTE NO PARES».
- 16-nov-2026, Claude, parte 6 `pagina-utiles-d`:
  - La mochila se dibuja en código (`DibujoMochila`) con trazos propios; el mockup guía, no se copia su SVG.
  - Un cupo vacío dice «vacío» y no se toca: no hay útil que elegir.
  - Barra de desplazamiento oculta y separación de 16: la barra tapaba las marcas y «Suela Antiderrapante» se cortaba
    (visto en la captura de 1440×1080). `MasAbajo` avisa que hay más.
- 16-nov-2026, Claude, parte 7 `pagina-inventario-d`:
  - La katana aprobada el 2-nov entra como `nucleo/arte/katana.png` (sin el croma, 512 px), en la carta y en el
    detalle; en `nucleo/` y no en `contenido/` porque el núcleo no depende de `contenido/`.
  - Azulitos no se muestran: no existen en `Partida` (serían un campo nuevo del guardado). Queda en «Fuera de este
    plan» y se le pregunta a Miguel; la decisión 2 del 1-nov los pedía.
  - Los nombres y textos de las habilidades viven en `SimboloHabilidad` (escritos, no sacados del id); la prueba usa
    «Caída en picada» porque «Impulso» saldría igual del id (una mutación sobrevivió hasta agregarla).
  - Sin arma, la carta queda plana y sin toque: solo lleva marco lo que se toca (visto en la captura de 1760×720).
  - Los mapas y lo perdido dicen el nombre de la zona con `Sala.nombre_de`.
- 16-nov-2026, Miguel, tras probar en el S50: «vamos a arreglar nosotros de una vez» (el botón del mapa y el detalle
  cortados). Arreglo en `docs/errores/2026-11-16-menus-cortados-s50.md`; las capturas de cada página se hacen también
  a 960×480 (el S50) con el texto más largo.
- 16-nov-2026, Miguel, orden de los PR: primero se revisa y fusiona el #36 de Vic, luego bloque 89, traer `main`,
  validar e instalar, y al final este PR: «va me gusta adelante».
- 16-nov-2026, Miguel, prueba en el S50 del arreglo (Útiles con cupos llenos y botón del mapa): «ya quedo ya se ve bien».
- 16-nov-2026, Claude, parte 8 `mapa-boton-vista`: el botón usa la variación `TARJETA` y el texto dice a qué vista pasa.
- 15-nov-2026, Claude, commits: cada parte toca `nucleo/funciones.json`, el plan y `docs/pruebas.md`, así que no se
  pueden separar por parte sin que la persona corra cada bloque antes de seguir. Mientras dure la tanda hay un solo
  bloque de commit para la rama, que crece con cada parte (regla de archivos compartidos del `CLAUDE.md` raíz).

## Choques con el código

1. **Bloques 59 y 60 ya corridos** (resuelto el 2-nov-2026). El 58 está en `790ea37`, la documentación del 59 en
   `e681fec` y el 60, que es de otro repo, en `afd4f1f`; ese bloqueo ya no existe. Rama propia:
   `feature/nucleo-menus-pausa`, con su propio PR.
2. **Log de Errores y las aspas.** `recibir_dano` no sabe de dónde viene el golpe, y las aspas son `DanoContacto` sin
   `peligro`: darían Inspiración. `DanoContacto` debe decir si viene de un enemigo.
3. **Gato de la Suerte.** `botin_factor` vive en `FichaAmuleto` y en `efectos_amuletos()`, y ningún amuleto del diseño lo usa.
   Se quita (ficha, suma, `amuleto_botin` de `equipo_prueba.tres`, sus pruebas y `docs/contrato.md`) y `enemigo.gd`
   multiplica por 1,5 con el útil puesto.
4. **Cartera de Emergencia.** Con 1 PejeCoin no hay mitades. La mochila se lleva el redondeo hacia arriba: siempre lleva
   algo, y `dejar_mochila` mantiene que un monto guardado sea mayor que 0. Morir sin monedas sigue sin crear mochila.
5. **Dos cosas llamadas mochila** (regla 6): la de los cupos y la que se pierde al morir, que también nombra la Cartera. En
   pantalla los útiles hablan de cupos («Cupos llenos: quita uno primero»), y la Cartera dice «la otra mitad se queda donde
   caíste». La clase nueva no puede llamarse `Mochila`: ya existe la pieza.
6. **En el juego no se consigue ningún útil ni amuleto.** Ni La Celda ni otra sala de `contenido/` los da; la Brújula tampoco
   se vende aún. Hasta que existan `raices_3`, `raices_4` y `raices_6`, las páginas solo se llenan en la sala «Equipo», que
   tendrá que dar los 5 útiles y los amuletos.
7. **Las filas dejan de estar `disabled`,** porque ahora se tocan para leer. Sale `_al_tocar`, y los guiones que pulsan una
   fila para poner un amuleto cambian a propósito: `prueba_amuletos`, `prueba_utiles`, `prueba_efectos_amuletos`,
   `prueba_sala_equipo`, `prueba_marco`, `prueba_mapa` y sus `.esperado`.
8. **Medidas.** `Tema.CELDA` mide 420 y las filas del mockup, unas 336. `MARGEN_LATERAL` (64) cae bajo la flecha: el contenido
   empieza en área segura + 108. El mockup no probó 4:3 ni más de 2:1: con `aspect="expand"` hay que probarlos aquí.
9. **El reporte quedó atrás.** El texto de «puesto» está hoy en `nucleo/pantalla_utiles.gd:98`, no en la 129.
   Fallo 1: `Sala.nombre_de` ya da el nombre de la zona.
10. **No hay sonido de toque en los menús.** Regla 8 y hallazgo 11: la respuesta es visual (la selección cambia en el acto).
    El sonido necesita un archivo y queda fuera.
11. **Íconos.** Los recortes miden de 849 a 991 px y pesan cerca de 1 MB. Entran reducidos a 112 px, el tamaño de Patas,
    con mipmaps, y se revisan a 56 px y en el detalle.

## Hallazgos del estudio de UX

| # | Resolución |
|---|---|
| 1 | Lo perdido, Mapas y Azulitos pierden el marco. Solo Arma y habilidades tienen marco y detalle; no hay que inventar textos |
| 2 | Un solo botón en el Mapa, con el nombre de lo que hace: «Ver todo» y «Ver zona» |
| 3 | Marca visible en la fila puesta, además del texto |
| 4 | Indicador fijo de que hay más abajo; filas con letra 28 y hasta 3 líneas |
| 5 | Inspiración siempre con número y bloques juntos, como en el mockup |
| 6 | El costo también en círculos |
| 7 | De pie, una línea fija: «Siéntate en un banco para cambiarlos» |
| 9 | Contorno oscuro en las flechas |
| 10 | El mensaje de cupos llenos dice que se toca un cupo para elegirlo |
| 8 y 12 | Sin cambios: 8 espera la prueba con personas; 12 no se salta la página vacía |

Con control: el foco elige, A en una fila lleva el foco a Poner o Quitar y A otra vez actúa. Las flechas no toman foco; las
manejan `pagina_anterior` y `pagina_siguiente`.

## Funcionalidades, en orden

Cada una entra al final de su `funciones.json`, con `validar.ps1`, su guion y su bloque de commit. Al cerrar, y antes del PR,
`correr-guiones.ps1` completo.

| # | Id | Qué | Archivos | Comprobación | `revisor` |
|---|---|---|---|---|---|
| 1 | `marco-flechas` | Flechas laterales, vecinas tocables, margen del contenido | `nucleo/marco_menus.gd`, `tema.gd` | `nucleo/marco`: toque, ciclo, área segura, sin pisar controles en 4 proporciones | No |
| 2 | `utiles-cuatro-cupos` | `MAX_UTILES` 4, clase `Utiles` con los ids, fichas e íconos, sala «Equipo» | `nucleo/partida.gd`, `ficha_util.gd`, `contenido/equipo.tres`, `herramientas/salas/`, `docs/uso-de-ia.md` | `nucleo/utiles`: el quinto no entra; se guarda y se lee | Sí, guardado |
| 3 | `utiles-efectos` | Gato, Log, Cartera y Suela; `DanoContacto` sabe si es de enemigo; sale `botin_factor` | `nucleo/enemigo.gd`, `jugador.gd`, `partida.gd`, `dano_contacto.gd`, `ficha_amuleto.gd` | Un caso por útil, con y sin él; aspas sin Inspiración; Cartera con 0, 1 y número impar | Sí, jugador y guardado |
| 4 | `detalle-de-menu` | Panel común: nombre, imagen, texto, motivo y botón. Tres páginas lo usan | Nuevo en `nucleo/`, `pagina_marco.gd` | Se prueba con las dos siguientes | No |
| 5 | `pagina-amuletos-d` | Lista en 2 columnas, carga en círculos, lo puesto arriba, elegir y actuar por separado | `nucleo/pantalla_amuletos.gd`, `contenido/equipo.tres` | `nucleo/amuletos`: sin amuletos y con amuletos; tocar no cambia nada; explica por qué no cabe | No |
| 6 | `pagina-utiles-d` | Mochila de gis con 4 cupos tocables y lista | `nucleo/pantalla_utiles.gd`, clase nueva | `nucleo/utiles`: llena, vacía, de pie, quitar desde un cupo | No |
| 7 | `pagina-inventario-d` | Estado, Arma, Lo perdido, 6 símbolos con detalle, Mapas y Azulitos. Nombres escritos; ficha de habilidad | `nucleo/pagina_inventario.gd`, clase de símbolos y datos nuevos | Guion nuevo: nombre de zona en Lo perdido, sin ids, inicio vacío | No |
| 8 | `mapa-boton-vista` | Un solo botón de vista | `mapa/pantalla_mapa.gd` | `mapa`: dice la vista y alterna | No |
| 9 | Cierre | Documentos (`docs/interfaz.md`, `docs/contrato.md`, guía de amuletos y útiles, `docs/pruebas.md`), `revisor` del conjunto, APK en el S50 | | Batería completa y pruebas manuales | Sí |

Pruebas que solo puede hacer la persona: leer letra 28 en el teléfono; flechas cómodas y sin toques por error; cómo se ven
mochila, Inventario y Mapa; todo con el dedo y con el control. El S21 no está disponible, así que el S50 es la referencia.


## Fuera de este plan

Los otros 8 amuletos, el arte de 7 de ellos (Caché no se pinta), las mecánicas nuevas, el sonido de toque, mover Volver
(hallazgo 8), dar útiles en salas de zonas que aún no existen y la carta de Azulitos del Inventario (falta el campo
en `Partida` y el guardado; pendiente de que Miguel lo confirme).

Esos 7 íconos entran antes que este plan como PNG sueltos, sin ficha: cada ficha llega con su efecto. Mientras tanto
`validar.ps1` da 7 `AVISO` de imagen sin uso, esperados y que no cuentan como fallos.

## Avance

- Parte 1 `marco-flechas` (15-nov-2026): hecha en la PC. `FlechaPagina` nueva; `MarcoMenus.rect_flecha` y
  `area_contenido`; la barra sin «‹ ›» ni botones del control en las vecinas. Falta la prueba en el teléfono: que las
  flechas sean cómodas y no se toquen por error.
- Parte 2 `utiles-cuatro-cupos` (15-nov-2026): `MAX_UTILES` 4, clase `Utiles`, las 5 fichas con ícono en
  `contenido/equipo.tres` y la sala «Equipo» da los 5. `utiles.guion` (30 casos) y `sala_equipo.guion` en verde;
  6 mutaciones muertas; `revisor`: dos fallos de documentos, corregidos.
- Parte 3 `utiles-efectos` (15-nov-2026): Gato, Log de Errores, Suela y Cartera con efecto; `DanoContacto.de_enemigo`;
  sale `botin_factor`. `efectos_utiles.guion` nuevo (24 casos), `validar.ps1` con 430 archivos y `fallos=0`, batería
  completa 214/214 y 10 mutaciones muertas. `revisor`: el código sin fallos; dos fallos de documentos (conteo de
  `sala_equipo` en `docs/pruebas.md` y el comentario de su guion), corregidos. Sin prueba: que el Log no dé
  Inspiración cuando el golpe mata (el código lo cumple; la entrada no lo pide).
- Partes 4 y 5 (16-nov-2026): `DetalleMenu`, `Circulos`, `MarcaUso` y la página Amuletos nueva. `amuletos.guion`
  (35 casos) y los guiones de marco, efectos, sala Equipo, útiles y pausa en verde; 2 mutaciones muertas. Falta en el
  teléfono: leer la letra 28 de las filas y que tocar elija sin poner.
- Partes 6, 7 y 8 (16-nov-2026): Útiles con mochila (`utiles.guion`, 34 casos, 2 mutaciones muertas), Inventario
  (`SimboloHabilidad`, `inventario.guion` nuevo, 11 casos, 2 mutaciones muertas) y el botón de vista del mapa
  (`mapa_cuentas`, 41 casos, 1 mutación muerta). Falta en el teléfono: cupos de la mochila, símbolos legibles y el botón.
