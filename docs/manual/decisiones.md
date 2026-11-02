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

## Del juego

| Fecha | Decisión | Por qué, o qué implica |
|---|---|---|
| 28-oct-2026 | Umbral de 0,5 ms por cuadro; tope de texturas por sala en Recursos bajo, unos 48 MB | Más de 0,5 ms (3 % de 16,7 ms) justifica arreglar un costo; menos, no |
| 28-oct-2026 | El salto largo se enseña en la sala 1, y entrar por una puerta con un pizarrón con patas | Lo que tiene colisión lleva arte jugable propio |
| 28-oct-2026 | El atlas del jugador lo rehace quien tiene las hojas originales | Ver [continuar.md](continuar.md) |
| 29-oct-2026 | Hasta terminar el juego no se conservan las partidas viejas | Inferido: evita migraciones mientras el formato cambia |
| 29-oct-2026 | El coleccionable es Azulito, a unos 64 px; su animación sigue pendiente | |
| 29-oct-2026 | El parry suena; falta el archivo (`FichaSonidos.parry` ya lo toca) | |
| 29-oct-2026 | Las espinas de la sala 4 pasan a Las Raíces | Faltaba un uso claro en el tiro |
| 29-oct-2026 | Los guiones `celda_*` se reducen a uno de ruta por sala, más los de `docs/errores/` | Inferido: menos guiones que mantener, sin perder los fallos ya vistos |
| 30-oct-2026 | Barra de Inspiración sin cambios; el pizarrón de curar va en Las Raíces, antes del primer enemigo | Las salas previas ocultan el botón de curar con `botones_ocultos` |
| 1-nov-2026 | La Celda es silenciosa, salvo junto al banco | Es intencional, no un fallo de audio |
| 1-nov-2026 | Las aspas empujan y no devuelven a un punto seguro | Son golpe normal, no peligro |
| 1-nov-2026 | Patas de Cucaracha cuesta 1 y da 1,25 | Ver `contenido/equipo.tres` |
| 1-nov-2026 | 5 útiles con 4 cupos, solo poner o quitar; Gato de la Suerte pasa de amuleto a útil | Siempre sobra uno. Sin construir: el código tiene 1 ranura |
| 1-nov-2026 | La primera zona jugable no lleva jefes; el mapa sube hacia ESCOM | La zona todavía enseña a jugar |
| 2-nov-2026 | El diseño del juego es público, con el manual en `docs/manual/` | Con licencia y aviso propios en `diseno.md` y `recorrido.md` |
| 2-nov-2026 | Plan de Las Raíces aprobado por partes: estructura, #18, #19 y #22 | #20, #21, #25 y #26 siguen condicionadas |
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
| 2-nov-2026 | Máscara en el arranque del motor, sin construir | Unos 12 s en negro no dicen que carga |
| 2-nov-2026 | En La Celda no hay banco donde está el Eterno | Se queda así; el único banco de la zona está en `celda_1` |

## Decisiones abiertas

Conservan su número de registro, por eso la numeración tiene huecos. El resto del manual las cita como «pendiente, decisión N».

| # | Tema | Qué bloquea |
|---|---|---|
| 10 | Texto del Eterno en Las Raíces | Cerrar el banco con el Eterno |
| 13 | Texto de la pantalla de cierre | Última sala de la zona |
