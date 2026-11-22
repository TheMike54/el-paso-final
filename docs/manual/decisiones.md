# Decisiones

Lo que ya se decidió y por qué, para no volver a discutirlo sin una razón nueva, y lo que sigue abierto. Sale de `CLAUDE.md`, «Decisiones cerradas», y de `ESTADO.md`, «Decidido». Si se cambia una, se anota aquí con su fecha y su porqué. Lo marcado «inferido» es una lectura de este manual: la razón no quedó escrita en el repositorio.

## Motor y plataforma

| Decisión | Por qué |
|---|---|
| Godot, y no GameMaker ni Kotlin puro | Escenas, recursos y código son texto y se corre por línea de comandos; Kotlin puro obliga a programar el motor |
| Godot exactamente 4.7.2 en todos los equipos | Un proyecto guardado con una versión más nueva no abre en una anterior |
| Renderer Compatibility en PC y en móvil | Es el más compatible con teléfonos de gama baja |
| Ninguna textura de más de 2048 px | En gama baja el límite real ronda los 2048 px; lo revisa el validador |
| Android de 32 y 64 bits (`armeabi-v7a`, `arm64-v8a`) | El teléfono de referencia de gama baja es de 32 bits |
| Video `.mp4` en el teléfono, `.ogv` solo en PC y guiones | En Android se usa el decodificador del teléfono, sin plugin, a 1080; los `.ogv` son 12,4 MB que allá no se usan |
| Dos presets: «Publicacion» sin herramientas y «Desarrollo» con todo y `--print-fps` | Inferido: publicar lo mínimo y medir con lo necesario |

## Arquitectura

| Decisión | Por qué |
|---|---|
| Núcleo común y contenido como datos (fichas `Resource`) | Agregar una zona no debe tocar el código del núcleo |
| No se generaliza hasta tener tres casos | Inferido: evitar abstracciones que adivinan el siguiente caso |
| La lógica lee acciones con nombre, nunca el toque ni la tecla | Táctil, teclado, control y guiones usan el mismo camino |
| Lógica en `_physics_process` a 60 ticks | El juego corre igual a 60, 90 o 120 Hz |
| Todo lo persistente tiene un ID de texto estable | Inferido: el guardado no depende de la ruta de un nodo |
| Guardado JSON con versión y detección de dañado | Una partida rota se informa y no se pisa |
| Colisión con formas invisibles; el arte no colisiona | El arte se puede rehacer sin mover la física |
| Fichas `.tres` de solo lectura en ejecución | Un recurso cargado es la misma copia para todos |
| Bus de eventos con lista corta y escrita | Quien emite no conoce a quien escucha |
| El núcleo carga `herramientas/` solo con `Cargar.si_existe()` | Un paquete sin herramientas debe arrancar igual |
| La zona de pruebas viaja en el paquete publicado, oculta tras el modo desarrollador | Cambio del 7-oct-2026; el resto de `herramientas/` no viaja |

## Pruebas y entrega

| Decisión | Por qué |
|---|---|
| Pruebas solo en guardado, cuentas, reglas, validador y un guion corto por sala | Es donde la lógica se puede romper sin que se vea |
| Pruebas, guiones y validador imprimen el resumen y los fallos | Una salida corta se lee |
| CI con `validar` como check exigido | Una rama no entra a `main` sin pasar el validador |
| Rama por PR y Squash and merge | El título del PR es el mensaje que queda en `main` |
| `.gitattributes` con `eol=lf` | Hooks y CI corren en Linux |
| `LICENSE` solo MIT; el arte queda fuera | Ver [permisos.md](permisos.md) |
| Ningún asistente de IA hace commits ni los firma | Cada cambio lo sube quien responde por él |
| `herramientas/instalar-apk.ps1` no borra partidas por omisión; solo con `-BorrarPartidas` | Cambio del 3-nov-2026. Inferido: quien corre el script a mano no pierde partidas sin pedirlo |
| `herramientas/capturar.ps1` captura por omisión a 1280×720, 1920×1080 y 2560×1440; la de 2560×1440 la prueba la persona en su monitor | Cambio del 3-nov-2026. Son las de los monitores de 10" a 27"; en uno de 2560×1440 la ventana puede no caber y la captura falla (ver el encabezado de `herramientas/capturar.ps1`) |

## Del juego

| Fecha | Decisión | Por qué, o qué implica |
|---|---|---|
| 28-oct-2026 | Umbral de 0,5 ms por cuadro; tope de texturas por sala en Recursos bajo, unos 48 MB | Más de 0,5 ms (3 % de 16,7 ms) justifica arreglar un costo; menos, no |
| 28-oct-2026 | El salto largo se enseña en la sala 1, y entrar por una puerta con un pizarrón con patas | Lo que tiene colisión lleva arte jugable propio |
| 28-oct-2026 | El atlas del jugador lo rehace quien tiene las hojas originales | Ver [continuar.md](continuar.md) |
| 29-oct-2026 | Hasta terminar el juego no se conservan las partidas viejas | Inferido: evita migraciones mientras el formato cambia |
| 29-oct-2026 | El coleccionable es Azulito, a unos 64 px | |
| 29-oct-2026 | El parry suena; falta el archivo (`FichaSonidos.parry` ya lo toca) | |
| 29-oct-2026 | Las espinas de la sala 4 pasan a Las Raíces | Faltaba un uso claro en el tiro |
| 29-oct-2026 | Los guiones `celda_*` se reducen a un guion de recorrido por sala (de ruta o de puertas, según la sala), más los de `docs/errores/` | Inferido: menos guiones que mantener, sin perder los fallos ya vistos |
| 29-oct-2026 | Aprobadas D1, D2, D3, D4 y D8; D10 no entra | |
| 29-oct-2026 | El color del foco va con el pulido de las páginas | |
| 30-oct-2026 | Barra de Inspiración sin cambios; el pizarrón de curar va en Las Raíces, antes del primer enemigo | Las salas previas ocultan el botón de curar con `botones_ocultos` |
| 1-nov-2026 | La Celda es silenciosa, salvo junto al banco | Es intencional, no un fallo de audio |
| 1-nov-2026 | Las aspas empujan y no devuelven a un punto seguro | Son golpe normal, no peligro |
| 1-nov-2026 | Patas de Cucaracha cuesta 1 y da 1,25 | Ver `contenido/equipo.tres` |
| 1-nov-2026 | 5 útiles con 4 cupos, solo poner o quitar; Gato de la Suerte pasa de amuleto a útil | Siempre sobra uno. Los 4 cupos y las 5 fichas ya están (`utiles-cuatro-cupos`) |
| 1-nov-2026 | La primera zona jugable no lleva jefes; el mapa sube hacia ESCOM | La zona todavía enseña a jugar |
| 2-nov-2026 | El diseño del juego es público, con el manual en `docs/manual/` | Con licencia y aviso propios en `diseno.md` y `recorrido.md` |
| 2-nov-2026 | La política de privacidad y su botón fueron directo a `main`, sin PR | Decisión de la persona |
| 2-nov-2026 | Créditos nombra al equipo por sus usuarios de GitHub | |
| 2-nov-2026 | Plan de Las Raíces aprobado por partes: estructura, #18, #19 y #22 | #20, #21, #25 y #26 se aprobaron el 3-nov-2026 |
| 2-nov-2026 | Los 7 íconos de amuleto entran como PNG sueltos; decide quien los genera, con criterios escritos. Caché no se pinta | Cada ficha llega con su efecto |
| 2-nov-2026 | Caída a Las Raíces sin repisa: unos 816 px, aterrizaje duro a propósito | No quita vida; lo fija un guion |
| 2-nov-2026 | Sin regreso a La Celda en la primera versión | Se construye cuando exista el salto en pared |
| 2-nov-2026 | Tienda sí, con la brújula a 30 PejeCoins; estación no | Da uso a las monedas |
| 2-nov-2026 | En Las Raíces se consiguen 2 amuletos: Patas de Cucaracha (`raices_4`) y Caparazón de Cucaracha (oculto de `raices_6`) | Caché queda fuera de la primera versión |
| 2-nov-2026 | Caparazón de Cucaracha cuesta 2 y da `invulnerable_extra` 30; su ficha entra con la tarjeta #25 | Valores para probar; se ajustan jugando |
| 2-nov-2026 | El coleccionable de la zona oculta de `raices_6` se queda junto a Caparazón de Cucaracha | |
| 2-nov-2026 | Suela Antiderrapante, Log de Errores y Cartera de Emergencia no se consiguen en la primera versión | Se definen después de publicar |
| 2-nov-2026 | La imagen de la katana queda aprobada | Puede entrar al repo |
| 2-nov-2026 | 12 preguntas de la mochila | Tarjeta #28 |
| 2-nov-2026 | Las Raíces cierra con una pantalla propia | Los Drenajes no entran en la primera versión |
| 2-nov-2026 | Sin fragmentos de vida en la primera versión; 1 coleccionable tras el segundo hueco | La proporción se aplaza |
| 2-nov-2026 | Las espinas de Las Raíces son azul turquesa | Decisión firme; no se reabre |
| 2-nov-2026 | `raices_7`: hueco sin fondo. `raices_8`: el piso de abajo sigue bajo el hueco | Sin caso especial de caída sin daño |
| 2-nov-2026 | `raices_7` se construye antes que `raices_6` y `raices_8` | `raices_7` no se puede recortar |
| 2-nov-2026 | En La Celda no hay banco donde está el Eterno | Se queda así; el único banco de la zona está en `celda_1` |
| 3-nov-2026 | Texto de la pantalla de cierre de Las Raíces: «Continuará» y, en chico, «Fin de la primera versión» | Era la decisión abierta 13 |
| 12-nov-2026 | Cucaracha: el punto de salida se lee al aparecer el polvo, no al enterrarse | Si no, sería muy fácil esquivarla |
| 13-nov-2026 | Cucaracha: quieto sobre ella mientras se recupera, el contacto sigue dañando cada vez que acaba la invulnerabilidad, sin límite por salida | Decisión de la persona al probarla |
| 3-nov-2026 | Los peligros no tienen un color fijo | La regla «lo que lastima es cálido» no fue una decisión; el color lo da el arte de cada zona |
| 3-nov-2026 | Sin máscara en el arranque y sin sesión de arte: se quitan del pendiente | |
| 3-nov-2026 | Las piezas jugables no llevan un color ni un contorno fijos | Quien hace el arte comprueba que la parte principal no se mezcle con el fondo |
| 3-nov-2026 | Línea del Eterno en `raices_3`: «Ese mapa lo empecé cuando llegué. Con la pluma ya puedes terminarlo tú.» | Era la decisión abierta 10; la ficha entrega el mapa `raices` y `pluma_mapa` |
| 3-nov-2026 | Plan de los menús de pausa aprobado; se construye después de la entrega del 9-nov | Toca el núcleo; no se mezcla con la actualización en Play |
| 16-nov-2026 | Los menús de pausa entran a `main` con el PR #37 | Plan: `planes/cerrados/nucleo-menus-pausa.md` |
| 21-nov-2026 | La Polilla de la primera versión zumba en su sitio y persigue por el aire, como el volador de pruebas; no se queda quieta ni embiste como dice el diseño | Lo decidió la persona al revisar el PR de la primera mitad de Las Raíces; la Polilla ya está hecha y la cubre un guion. Plan: `planes/cerrados/contenido-raices-primera-mitad.md` |
| 21-nov-2026 | La zona oculta de `raices_4` es una repisa tras un techo rompible, como la de `raices_6`, y no el cuarto tras un muro que pedía el #21 | La persona la aceptó al fusionar el PR #42 |
| 21-nov-2026 | El validador falla con una sala de `contenido/` sin guion y con un banco del juego sin `Silla` o con `mirando` 0; la ficha de pruebas del volador usa el comportamiento de la Polilla | Plan: `planes/cerrados/contenido-auditoria-21-nov.md` |

Planes cerrados con decisiones: `planes/cerrados/nucleo-piezas-celda.md` y `contenido-celda-salas.md` (27-oct); `nucleo-cierre-auditoria.md`, apartado «Tras las pruebas en el S50» (30-oct); `nucleo-auditoria-final.md` (1-nov); `contenido-auditoria-21-nov.md` (21-nov).

## Decisiones abiertas

Ninguna desde el 3-nov-2026. Una nueva se agrega aquí con un número de registro nuevo; el resto del manual la cita como «pendiente, decisión N».
