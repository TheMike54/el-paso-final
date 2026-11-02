ACTIVO (escrito el 29-oct-2026; aprobado por la persona el 29-oct-2026 con D1, D2 y D8 como los recomienda Claude.
Las demás decisiones, al empezar su grupo)

# Cierre de la auditoría de código: base de enemigos, amuletos, jefes, mapa por zonas y arquitectura

Toma las fases 3 y 4 de `nucleo-base-auditoria-codigo` (lo que no entró en el PR de La Celda) y las reparte en cinco
grupos, cada uno con su issue, en una sola rama y un solo PR («Ramas y PRs»). `nucleo-base-auditoria-codigo` queda `REEMPLAZADO POR
nucleo-cierre-auditoria.md` y pasa a `planes/cerrados/` en el primer commit del grupo 1 (29-oct-2026). La lista completa de hallazgos, con cada
archivo:línea y el arreglo propuesto, está fuera del repo; los `F-xxx` de abajo son sus ids.

Cambio de método respecto del plan anterior (pedido por la persona el 29-oct-2026): Codex (`gpt-6.1-sol`) también
escribe código, siempre bajo `validar.ps1`, los guiones completos y el `revisor` (en Opus desde el 29-oct). Gemini ya no
se usa; las lecturas largas las hace Claude Haiku. Quién construye y quién revisa cada tarea va en su fila; cómo se reparte el trabajo entre modelos está en la
metodología de la persona, fuera del repo. El PR declara cada herramienta y su parte, y `docs/uso-de-ia.md`, fila
«Código y documentación», suma Codex en el primer PR que lleve código suyo.

## Decisiones de la persona (antes de su grupo)
Del plan anterior quedaron aprobadas D5, D7 y D9. D1, D2, D3, D4 y D8 están aprobadas; D10 no entra.
La tabla conserva las preguntas y recomendaciones; el alcance de D3 figura en el grupo 2.

| # | Grupo | Pregunta | Recomendación |
|---|---|---|---|
| D1 | 1, 2, 3 | Botín, amuletos y jefes se construyen sin caso real en el juego: excepción a «no se generaliza hasta tener tres casos» | Aceptarla, con la versión mínima probada en `herramientas/salas/` |
| D2 | 1 | Botín: PejeCoins que saltan y se recogen, o sumadas directo | Que salten, con `MonedasSueltas` |
| D3 | 2 | Amuletos: carga máxima, cuántos equipados y qué efectos entran | Ficha y menú para todos; efectos solo de lo que ya existe (velocidad, invulnerabilidad, alcance, Inspiración, curar, PejeCoins de enemigos, brújula) |
| D4 | 3 | Jefes: sistema genérico (fases, arena con `Porton`, entrega, `jefe_vencido`) con un jefe de caja gris | Sí; el primer jefe real va con su zona. **Aprobada** (29-oct) |
| D8 | 1 | Cómo prueba un guion a un enemigo si atacar exige la `pluma` | Instrucción nueva de guion que da habilidades, sin tocar la escena |
| D10 | 4 | Jugador e interfaz persistentes entre salas (F-097) | La fase 2 midió 0,6-1,8 s de carga en el S50, por encima del umbral de 0,5 s: entra, junto con la carga en segundo plano (F-098). **No entra** (29-oct): la carga entre salas se queda como está; F-097 y F-098 salen del grupo 4 |

## Ramas y PRs
- Orden de trabajo: 1 → 2 → 6 → 3 → 5 → 4 (el 6, agregado el 29-oct-2026, antes de que los demás grupos sigan
  creciendo el contrato). Decisión de la persona (29-oct-2026): los grupos van en una sola rama y
  un solo PR, para cerrar la auditoría antes de preparar la publicación en la Play Store. Lo que el QA del #11
  encuentre se arregla en este mismo PR y se cita en su issue.
- Rama: `feature/nucleo-cierre-auditoria` (antes `feature/nucleo-enemigos-base`). Sale de `feature/contenido-celda`
  (`9f67615`); al fusionarse el #11 (Squash and merge), la persona la mueve encima de `main`:
  `git rebase --onto main 9f67615 feature/nucleo-cierre-auditoria`.
- Un commit por grupo y un issue de prueba por grupo con lo que se prueba en el teléfono. El PR se abre al terminar
  el grupo 4, con los cinco issues (`Closes #n`): un push nuevo quita la aprobación.
- Consecuencia aceptada: la base de enemigos no llega a `main` hasta cerrar los cinco grupos.

## Cómo se ejecuta cada grupo
- Claude (Opus) define primero las interfaces que tocan el contrato: firmas, señales, campos de ficha. Codex construye
  lo que cuelga de ellas (comportamientos, salas de prueba, guiones, pruebas) en un worktree aparte, sincronizado con el
  árbol de trabajo antes de cada tarea; Claude integra su diff en el árbol principal. Un archivo tiene un solo escritor
  a la vez.
- Cada tarea cierra con `validar.ps1` (`fallos=0`); cada grupo, con `correr-guiones.ps1` completo (`MALOS=0`), el
  `revisor` y una segunda lectura del diff por otro modelo. Lo que solo se ve en el teléfono se pide a la persona.
- Un bloque de commit por grupo, numerado en el archivo que indica `CLAUDE.local.md`. Los grupos 1 y 2 van en uno
  (29-oct-2026): comparten archivos sin commit y separarlos pediría elegir línea por línea.

## Grupo 1 · Base de enemigos
Deja todo lo que necesita una mecánica de enemigo nueva sin tocar el núcleo después: arte, botín, datos por ejemplar,
sonidos propios, guiones que dan habilidades y la categoría «Enemigos» que se llena sola. Referencia de Hollow Knight
para el botín (geo que salta) y la reaparición (ya en `FichaEnemigo.reaparicion`).

| # | Tarea | Hallazgo | Construye | Revisa | Archivos | Comprobación |
|---|---|---|---|---|---|---|
| 1.1 | Arte: un `AnimatedSprite2D` hijo apaga la caja gris en `Enemigo` y en `Palanca`, como ya hacen `Puerta` y `MuroRompible` | F-091 | Claude | `revisor` | `nucleo/enemigo.gd`, `nucleo/palanca.gd`, `docs/contrato.md` | `sala_enemigos` con un enemigo con arte provisional; guion |
| 1.2 | Botín: campo en `FichaEnemigo`; al vencer salta `MonedasSueltas` una sola vez por ejemplar | F-085, D2 | Claude | `revisor` | `nucleo/ficha_enemigo.gd`, `nucleo/enemigo.gd`, contrato | Guion: vencer da las PejeCoins una vez y no al volver a entrar |
| 1.3 | Datos por ejemplar: el comportamiento lee sus números de un recurso exportado por enemigo, no de constantes | F-092 | Claude (interfaz), Codex (pasar los 4 comportamientos de prueba) | Terra + `revisor` | `nucleo/comportamiento_enemigo.gd`, `nucleo/enemigo.gd`, `herramientas/salas/comportamientos/*` | Dos enemigos del mismo tipo con radio distinto; guiones de enemigos sin cambio de `.esperado` |
| 1.4 | Puntos de enganche para las mecánicas: ignorar un golpe (escudo, cerrarse), apagar la gravedad (trepar, enterrarse), saber hacia dónde mira el jugador | Nuevo | Claude | `revisor` | `nucleo/enemigo.gd`, `nucleo/comportamiento_enemigo.gd`, contrato | Prueba de código por enganche |
| 1.5 | Sonidos por ficha: una ficha de enemigo o de zona trae sus sonidos sin tocar la ficha global | F-093 | Codex | Terra + `revisor` | `nucleo/sonido.gd`, `nucleo/ficha_sonidos.gd`, `nucleo/ficha_enemigo.gd` | Guion de evento de enemigo |
| 1.6 | Guion que da habilidades | D8 | Codex | `revisor` | `herramientas/puerto_depuracion.gd`, `docs/guiones.md` | Un guion de enemigo que ataca sin la `pluma` |
| 1.7 | La categoría «Enemigos» de la zona de pruebas lista sola las salas de su carpeta, y cada comportamiento de prueba tiene su propia sala (pedido por la persona el 29-oct-2026: probar cada enemigo por separado) | Nuevo | Codex | Terra | `herramientas/salas/zona_pruebas.gd`, `herramientas/salas/enemigos/sala_<comportamiento>.tscn` nuevas (las salas de enemigos que ya existen no se mueven: renombrar es en el editor) | `prueba_zona_pruebas`; un guion corto por sala nueva |
| 1.8 | Guía corta «cómo se hace un comportamiento de enemigo» con un ejemplo | Nuevo | Claude | Haiku (lee) | `docs/guias/` | Que el ejemplo pase `validar` |

Avance del 29-oct-2026 (sesión autónoma): las ocho tareas hechas (la 1.3, en la tarde).
La 1.5 la aprobó el `revisor` (sin Terra, por tiempo). Ahora, el `revisor` del grupo completo y la prueba en el S50
de la sala de enemigos con arte y botín.
- 1.2: botín una vez por ejemplar, como pide la fila. Hollow Knight lanza geo en cada muerte, sin marca
  (`HealthManager.Die`): si la persona lo prefiere así, se quita la marca. Un montón que salta con `Tween`, no el
  geo con física de Hollow Knight; no se congela en los 4 ticks del congelado al vencer.
- 1.4: el golpe bloqueado sigue a `HealthManager.Invincible` de Hollow Knight: sin daño ni alma, el jugador rebota.
- 1.5: prioridad por campo: ficha del enemigo, luego la de la sala, luego la global; un campo vacío cae al siguiente.
  `ficha_sala` no se limpia al volver al menú (no es una `Sala`); no se encontró un evento de sonido que suene ahí. Sin
  comprobar corriendo.
- 1.3: los datos del ejemplar reemplazan enteros a los de la ficha, no campo por campo: un `@export` tipado no tiene
  valor «vacío» y un centinela o un `Variant` chocan con el tipado estricto. Para cambiar un número en una sala se
  parte de una copia del `.tres` de la ficha (*Make Unique*). Sin `resource_local_to_scene`: los datos son de solo
  lectura. Las clases de datos de `herramientas/` van sin `class_name` (se cargan con `preload`), como el resto de
  esa carpeta, que no viaja en el paquete de publicación. Codex pasó los 4 comportamientos; Claude hizo la interfaz y
  la prueba.
- 1.3, 1.5, 1.6 y 1.7: el código lo escribió Codex (`gpt-6.1-sol`) en un worktree; Claude lo integró y validó.

1.1: Sigue el patrón del `Npc` (`animacion` exportado, no un hijo detectado solo):
el tipo de enemigo con arte es una escena heredada con su ficha y su dibujo; la palanca, sin animaciones propias,
solo refleja el dibujo. Guiones `enemigo_base` y `muro_rompible`. Consecuencia para el arte (va en la guía de la
1.8): el dibujo de un enemigo se hace mirando a la derecha y el de una palanca inclinado a la derecha, como el jugador
y el Eterno; al revés se ve de espaldas y ningún guion lo detecta.

Cierre: `revisor` (toca contrato y física de enemigos), segunda lectura de Terra, APK de desarrollo y prueba en el S50 de
la sala de enemigos con arte y botín.

## Grupo 2 · Amuletos
- F-087: `FichaAmuleto` (nombre, descripción, costo, efecto como dato); el menú y el inventario la leen; el efecto de la
  brújula sale del mapa.
- F-042: lista oficial de amuletos y regla del validador para ids mal escritos en tienda, NPC y retos.
- D3: los efectos que entran. Cada efecto con su guion de equipar.
- D3 decidida por la persona (29-oct-2026): límite por carga, como Hollow Knight: cada ficha trae su costo (1 a 3) y
  la carga empieza en 3 (`PlayerData.cs:7416`, `:7426-7466` de la referencia). Efectos: velocidad al caminar,
  invulnerabilidad más larga, Inspiración por golpe y PejeCoins de enemigos (botín). Alcance del ataque y curar más
  rápido, después (necesitan arte y prueba de sensación). La brújula no es un amuleto: es un «útil», como la
  herramienta de Silksong (`GameMap.cs:1316-1317`: el mapa la pide equipada), con su categoría y su ranura propias y
  sin gastar carga. «Útiles» y no «herramientas» para no confundirlo con la carpeta `herramientas/`.

| # | Qué | Hallazgo | Construye | Revisa | Archivos | Comprobación |
|---|---|---|---|---|---|---|
| 2.1 | `FichaAmuleto` (id, nombre, descripción, costo 1-3, `icono` opcional para el arte que llegue: sin él, la forma de gis de `IconoArticulo`, y un campo por efecto: `velocidad_factor`, `invulnerable_extra`, `inspiracion_extra`, `botin_factor`) y el catálogo `CatalogoEquipo` (`contenido/equipo.tres`, más `herramientas/salas/fichas/equipo_prueba.tres` para la zona de pruebas) que el núcleo carga con `Cargar.si_existe`. Carga: `Partida.carga_maxima` (empieza en 3, se guarda) y `puede_equipar` suma costos | F-087 | Claude | `revisor` (guardado) | `nucleo/ficha_amuleto.gd`, `nucleo/partida.gd`, `nucleo/guardado.gd`, contrato | Prueba de carga: entra lo que cabe, no lo que no; guardar y cargar la conserva |
| 2.2 | Los cuatro efectos: el jugador y el botín leen la suma de los amuletos puestos | F-087, D3 | Codex | Terra + `revisor` (física del jugador) | `nucleo/jugador.gd`, `nucleo/enemigo.gd` | Un guion de equipar por efecto |
| 2.3 | Página Amuletos con nombre, costo, descripción y carga usada de la máxima | F-087 | Codex | Terra | `nucleo/pantalla_amuletos.gd` | `prueba_amuletos` ampliada |
| 2.4 | Útiles: `FichaUtil` (con `icono` opcional, como el amuleto), `Partida.utiles_tenidos` y `utiles_equipados` (una ranura por ahora), página «Útiles» en el marco y la brújula como el primero. Cambia el contenido de `amuletos_tenidos` y `amuletos_equipados`: `Guardado.VERSION` pasa de 3 a 4 **sin conversión** (decisión de la persona, 29-oct-2026: hasta terminar el juego las partidas viejas no se conservan; una de versión 3 se trata como de otra versión) | Nuevo | Claude (interfaz y guardado), Codex (página) | `revisor` (guardado) | `nucleo/ficha_util.gd`, `nucleo/partida.gd`, `nucleo/guardado.gd`, `nucleo/marco_menus.gd`, `mapa/pantalla_mapa.gd` | Guion del mapa con la brújula como útil; `guardado` con la versión 4 (una de versión 3 da «otra versión») |
| 2.5 | Lista oficial: el validador falla un id de amuleto o de útil que no esté en su catálogo (tienda, NPC, retos) | F-042 | Codex | `revisor` (validador) | `herramientas/validar.gd`, `prueba_validador.gd` | Casos nuevos del validador |
| 2.6 | Contrato y guía «agregar un amuleto o un útil» para el equipo | Nuevo | Claude | Haiku | `docs/` | — |

Avance del 29-oct-2026: hechas la 2.1 y la parte de interfaz y guardado de la 2.4 (Claude); el contrato, en
«Amuletos y útiles». Un catálogo para amuletos y útiles (`CatalogoEquipo`) en vez de uno por tipo: los dos se
buscan igual y viven en el mismo archivo. Los amuletos de prueba (uno por efecto) van en el catálogo de pruebas; el del
juego solo tiene la brújula hasta que haya amuletos reales. El catálogo se lee como `Resource`: nombrándose a sí mismo
dejaba recursos sin liberar al salir (`docs/errores/2026-10-29-fuga-catalogo-equipo.md`).
- Después, el mismo día: 2.2 a 2.5 (Codex, integradas y validadas en el árbol principal), la guía y una 2.7 que no
  estaba en la tabla: la sala «Equipo» de la zona de pruebas (Partida), que da los cinco amuletos de prueba y la
  brújula, para probar los efectos en el teléfono (antes solo se conseguía `amuleto_prueba`).
- 2.2: el jugador guarda los efectos y los renueva con `equipo_cambiado`; la velocidad solo al caminar (no carrera,
  impulso ni puerta), la invulnerabilidad solo tras recibir daño y la Inspiración también en el golpe del parry. Tres
  mutaciones (sin el factor de velocidad, sin renovar, sin el factor del botín) hacen fallar `efectos_amuletos`.
- 2.3: la descripción va al lado de la lista (Amuletos) y bajo el aviso (Útiles): dos páginas, no una clase común
  (no hay tres casos). De pie el aviso también dice la carga o las ranuras (segunda lectura de Terra).
- Sin cambiar, para la prueba en el teléfono: con control, una fila deshabilitada (de pie, o que no cabe) quizá no
  recibe el foco y su descripción no se lee; ya pasaba antes de este grupo y la QA del 24-oct con control pasó.
- Cierre del grupo 2 (29-oct-2026): `validar` 391 archivos sin fugas, batería completa 205/205, `revisor` de cierre
  con 2 fallos de documentos arreglados. Por su observación sobre F-042 («lista oficial»), fuera de `herramientas/`
  el validador rechaza un id que solo está en el catálogo de pruebas. La prueba en el teléfono
  (`equipo-telefono`), hecha el mismo día en el S50, pasa.
- La entrega de la sala «Equipo» es una variante de prueba: la `EntregaRecompensas` del núcleo da una recompensa por
  cada número de coleccionables, no un lote.

## Grupo 2b · Inspiración y carga que crecen
Decidido por la persona el 29-oct-2026, tras cotejar el diseño con el juego: la barra de Inspiración empieza con 3
bloques y llega a 9 con los Módulos de RAM (+3 cada uno), y la carga empieza en 3 y sube de 1 en 1 hasta 11, como las
muescas de Hollow Knight. Hoy la barra es fija de 9 y nada sube la carga. Lo construye Codex (`gpt-6.1-sol`) en un
worktree; Claude valida e integra.

- 2b.1 `Partida`: `inspiracion_maxima` (variable, empieza en `INSPIRACION_INICIAL` = 33 y no pasa de
  `INSPIRACION_TOPE` = 99), en `Guardado.NUEVOS`; `inspiracion` y `ganar_inspiracion` se recortan a ella;
  `inspiracion_cambiada` emite la variable. `carga_maxima` no pasa de `CARGA_TOPE` = 11.
- 2b.2 `Recompensa.Tipo`: `INSPIRACION_MAXIMA` (`monto` en puntos: un módulo es 33) y `CARGA` (`monto` en muescas), al
  final del enum; `Partida.dar_recompensa` los aplica recortados al tope y autoguarda. Ícono en `IconoArticulo`
  para la tienda.
- 2b.3 HUD e inventario leen el máximo de `Partida`, no la constante: con 33 se dibujan 3 bloques.
- 2b.4 Pruebas: un guion nuevo (subir a tope y no pasarse, guardar y cargar, una partida sin el campo empieza en 33)
  y los guiones que ya leían 99 (`vidas_e_inspiracion`, `amuletos`, `utiles`) al día.
- Nota de diseño: curar y los poderes cuestan 33 (`costo_curacion`, `costo_poder`). Con 3 bloques al empezar cabe una
  curación por barra llena; en Hollow Knight caben tres. Los números quedan en constantes para ajustarlos al probar.
- Avance (29-oct-2026): hecho por Codex e integrado. `validar` 393 archivos sin fallos; `crecer` (30 casos) y los
  guiones vecinos 8/8, con `vidas_e_inspiracion` (99 → 33) y la partida de `prueba_guardado` al día. `revisor`:
  aprobado. Los dos íconos nuevos de la tienda pasan en la prueba de los siete grupos en el S50
  registrada en «Tras las pruebas en el S50».

## Grupo 3 · Jefes
- F-086 y F-035: vida por fases, arena que cierra un `Porton`, entrega de habilidad y `jefe_vencido` con emisor, probado
  con un jefe de caja gris en una arena de la zona de pruebas (D4).
- Modelo: la `BattleScene` de Hollow Knight. Al entrar el jugador, la arena cierra sus `BattleGate` y despierta al
  jefe; su vida cruza umbrales que cambian de fase; vencido, se anota en la partida (`defeated<Jefe>`), se abren las
  puertas y no vuelve. Lo construye Codex (`gpt-6.1-sol`) en su worktree, en paralelo al 2b: no toca `partida.gd`,
  `recompensa.gd`, `guardado.gd` ni `docs/contrato.md`.
- 3.1 `FichaEnemigo`: `umbrales_fase` (vidas a las que cambia de fase, de mayor a menor; vacío, una sola fase) y
  `jefe` (bool). `Enemigo`: `fase` (0 al empezar), señal `fase_cambiada(fase)` y señal `vencido`; un jefe ya en
  `Partida.jefes` no aparece. `ComportamientoEnemigo`: gancho `al_cambiar_fase(fase)`.
- 3.2 `ArenaJefe` (`nucleo/arena_jefe.gd`, `Area2D`): `jefe` (el `Enemigo`), `id_jefe`, `portones` y `recompensa`.
  El jefe duerme (su comportamiento sin tick) hasta que el jugador entra; entonces cierra los portones y lo despierta.
  Vencido: abre los portones, da la recompensa, emite `jefe_vencido(id_jefe)` (lo anota `Partida`, que autoguarda).
  Ya vencido al entrar a la sala: portones abiertos, sin jefe, sin recompensa. Morir dentro recarga la sala como
  siempre.
- 3.3 Sala «Jefe» en la zona de pruebas: un jefe de caja gris con un comportamiento de prueba de dos fases (camina; en
  la segunda, más rápido y embiste), dos portones y la habilidad impulso como recompensa.
- 3.4 Prueba y guion: los umbrales, cerrar al entrar, abrir al vencer, `jefe_vencido` una vez, la recompensa una vez y
  la sala vuelta a entrar sin jefe.
- 3.5 Documentos: «Jefes» en `docs/enemigos.md`, la guía de enemigos, `docs/salas-de-prueba.md`, `docs/pruebas.md` y
  sus entradas en `nucleo/funciones.json`.
- Avance (29-oct-2026): hecho por Codex en paralelo al 2b e integrado (uids con `arreglar-uids.ps1`). Terra, segunda
  lectura: dos fallos arreglados (una fase repetida o saltada si el gancho de fase provoca otro golpe; un jefe ya
  vencido que existía hasta su `queue_free`: ahora se apaga de inmediato). La barra de 33 dejó a `poder_bola_recarga`
  sin sus dos bolas: las salas de prueba tienen `inspiracion_maxima_de_prueba` (el validador la exige en 0 en
  `contenido/`; `validador` 181 casos). `validar` 399 archivos sin fallos; batería completa 207/207.
  `jefe-telefono` pasa según la fila «Jefe» de `docs/pruebas.md`.

## Grupo 5 · Mapa por zonas
- F-094 (nombre visible y color de zona como dato), F-095 (franja de la zona calculada), F-100 (la zona deja de ser el
  prefijo del id), F-102 (índice del mapa sin conflictos al fusionar), F-096 (tabla de estaciones y bolsa de preguntas
  reales en `contenido/`), F-073 (el inicio del juego como ficha de `contenido/`).

Decisiones (sesión autónoma pedida por la persona el 29-oct-2026; cada una con su porqué):
- F-094 y F-095 entran juntos, con un dato por zona: `FichaZona` (`nombre`, `color`, `origen_mapa`), puesta una vez
  en la base de la zona (`sala_celda.tscn`) como ya se hace con la música y los sonidos. El generador del mapa la
  copia al índice (el mapa no lee `contenido/`, solo el índice, que viaja en el paquete); `posicion_mapa` pasa a
  contarse desde el `origen_mapa` de su zona. Por qué: el mapa decía «Celda» sin artículo ni tildes y repetía cuatro
  colores; mover una zona entera obligaba a editar cada sala. La Celda queda con origen `(0, 0)`: ningún rectángulo
  del índice cambia. El generador imprime además la siguiente franja libre, para no calcularla a mano.
- F-100 no cambia: el validador ya exige ids `<zona>_<n>` de una palabra y el nombre bonito lo da la ficha. Cambiar
  `zona_de` tocaría ids y partidas sin ganar nada para la v1.
- F-102 no cambia: el validador falla si el índice no está al día y regenerarlo es un comando; se anota en
  `mapa/CLAUDE.md` que tras fusionar ramas con salas nuevas se regenera. Partirlo por zona no vale la pena sin un
  conflicto medido.
- F-096 no crea archivos: La Celda no tiene estaciones ni la mochila necesita preguntas para funcionar (sin bolsa
  recupera enseguida), y las preguntas reales son contenido del equipo, no algo que Claude invente. Se crean con la
  primera estación de Las Raíces, con un guion que la cruce (anotado en la guía de salas).
- F-073 no cambia: el comienzo del juego cambia una vez y ya es dato (`@export_file` en `menu.tscn`); el comentario
  de `menu.gd` se escribe sin nombrar La Celda.

| # | Tarea | Hallazgo | Construye | Revisa | Archivos | Comprobación |
|---|---|---|---|---|---|---|
| 5.1 | `FichaZona` y `Sala.ficha_zona`; `zona_celda.tres` en la base de La Celda | F-094, F-095 | Codex (sol) | Terra + `revisor` | `nucleo/ficha_zona.gd`, `nucleo/sala.gd`, `contenido/zonas/celda/` | `validar` |
| 5.2 | Índice con nombre, color y origen por zona; el generador imprime la franja libre | F-094, F-095 | Codex (sol) | Terra | `mapa/indice_salas.gd`, `herramientas/generar_mapa.gd`, `mapa/indice_salas.tres` | Índice regenerado sin cambio de rectángulos |
| 5.3 | El mapa dibuja nombre y color de la ficha (sin ficha, como hoy) | F-094 | Codex (sol) | Terra | `mapa/datos_mapa.gd`, `mapa/lienzo_mapa.gd`, `prueba_mapa.gd` | `mapa_cuentas` |
| 5.4 | Validador: sala de `contenido/` sin ficha de zona, o dos fichas en una zona, fallan | F-094 | Codex (sol) | Terra | `herramientas/validar.gd`, `prueba_validador.gd` | `validador` |
| 5.5 | Documentos: contrato («Sala»), interfaz («Mapa»), validador, guía de salas, `mapa/CLAUDE.md`, comentario de `menu.gd` | F-094 a F-102, F-073 | Codex (sol) | Claude | `docs/`, `mapa/CLAUDE.md`, `nucleo/menu.gd` | Lectura |

Avance (29-oct-2026): 5.1 a 5.5 hechas por Codex e integradas. El marcador del jugador (brújula) también toma la
esquina de su sala del índice, con el origen de zona sumado. Índice regenerado: los rectángulos no cambian, entran
`nombres_zona` y `colores_zona` de La Celda; el generador da `franja_libre_y=3814`, la misma cifra que la guía
calculaba a mano. Validador 187 casos, `mapa_cuentas` 39. Terra: sin fallos. Batería completa 207/207 con el grupo
4a ya integrado. En el teléfono: el mapa alejado dice «La Celda».

## Grupo 4 · Arquitectura
- F-099 y F-103 (partir `jugador.gd` y los archivos largos), F-097 y F-098 (D10), F-016, F-024, F-101, F-104, F-105,
  F-106, F-015, F-011, F-023, F-089, F-090.
- Como pedía el plan anterior: antes de empezar, la tabla «actual → nuevo» de cada fila, aprobada por la persona. Cada
  pieza con el `revisor` y prueba en el S50; la física del jugador, con prueba de sensación.
- La persona pidió el 29-oct-2026 hacer los grupos 5 y 4 en sesión autónoma y probar después: la tabla la decide
  Claude con el criterio de cada hallazgo y queda aquí para que la persona la revise con la prueba. Regla usada: se
  cambia lo que quita una duplicación o un paso a mano que ya existe; lo que el hallazgo deja «para cuando haga
  falta» se deja escrito y no se construye (núcleo común, no se generaliza hasta tener tres casos).

| # | Actual | Nuevo | Hallazgo | Construye | Revisa | Comprobación |
|---|---|---|---|---|---|---|
| 4.1 | `jugador.gd` (1790 líneas) mezcla el punto seguro (recordar, buscar suelo, reaparecer) y los efectos (destello, aura, curación) con el movimiento | Dos `RefCounted` con una referencia al jugador: `PuntoSeguroJugador` y `EfectosJugador`. Movimiento, salto, ataque, daño y transición se quedan (el hallazgo lo pide así: están entrelazados con el tick). `docs/jugador.md` toma el doble salto como modelo de habilidad nueva | F-099 | Codex (sol) | Terra + `revisor` | Batería completa sin cambio de `.esperado`; sensación en el S50 (caer a espinas, reaparecer, curar) |
| 4.2 | `tema.gd` (518) construye los estilos junto al tema | Constructores de `StyleBox` a `tema_estilos.gd` (funciones estáticas, sin estado). `configuracion.gd`, `controles_tactiles.gd` y `sala.gd` no se parten: lo táctil no se comprueba sin el teléfono y el hallazgo los deja para cuando se toquen | F-103 | Codex (sol) | Terra | `validar`, guiones de interfaz |
| 4.3 | Tienda, cobro y estaciones repiten capa 20, `process_mode`, prioridad, grupo, Atrás y `cerrar()` | Clase base `ModalPausa` (`CanvasLayer`) con una sola `CAPA`, que también leen `PaginaMarco` y `pausa.tscn`; mismo orden de prioridad y grupo | F-016 | Codex (sol) | Terra + `revisor` | Guiones de tienda, cobro, estaciones y marco |
| 4.4 | La sala crea Inventario, Amuletos y Útiles uno por uno y Mapa por otra lista; `ORDEN` aparte | Una constante `PAGINAS` en `MarcoMenus` (id, escena o clase) que la sala recorre con el mismo patrón; el orden sale de ella | F-024 | Codex (sol) | Terra | `marco.guion`, `amuletos`, `utiles`, `mapa_cuentas` |
| 4.5 | «id o ruta» y el nombre de la sala decididos en `ranuras.gd`, `sala.gd` y `validar.gd` con dos formas de `capitalize` | `Sala.nombre_de(id_o_ruta)`: nombre de la zona del índice del mapa si existe (como la ranura de Hollow Knight, que muestra el área), si no el id con mayúscula. La ranura dice «La Celda» | F-015 | Codex (sol) | Terra | `prueba_guardado` o `ranuras`, caso nuevo |
| 4.6 | `ajuste_grafico_cambiado` también avisa de vibración y temblor; comentarios que no dicen lo que hacen | Señal `ajuste_cambiado` (bus); comentarios de `_revisar_habilidades`, `empezar_a_hablar` en la estación y `Mando.Dispositivo` | F-011 | Codex (sol) | Terra | `validar`, batería |
| 4.7 | Puertas, bancos y estaciones solo como hijos directos; `cambio_de_sala` parece de toda llegada; `puerta.gd:10` ambiguo; estáticas de transición | Solo documentos: la regla de hijas directas en `contenido/CLAUDE.md`, `cambio_de_sala` «solo por puerta» en el bus, el comentario de `puerta.gd`, y que `Sala._ready` limpia las estáticas | F-101, F-089, F-090, F-104 | Codex (sol) | Claude | Lectura; F-090, prueba en el S50 `celda_2` ↔ `celda_5` |
| — | Estáticas de `ControlesTactiles` (F-105), proyectil acoplado a `MuroRompible` (F-106), campo persistente en 4 sitios (F-023) | Sin cambio: cada hallazgo propone esperar (otra pieza rompible, el tercer olvido real, cambiar la persistencia de la interfaz, que D10 dejó fuera) | F-105, F-106, F-023 | — | — | — |

Avance (29-oct-2026): 4.1 a 4.7 hechas por Codex en dos tandas e integradas.
- 4.1: `jugador.gd` 1785 → 1713 líneas. `_reaparecer` y `_colocar_tras_peligro` se quedan en el jugador: coordinan
  movimiento, combate, entrada y cámara. `docs/jugador.md` tiene «Agregar una habilidad» con el doble salto de modelo.
- 4.3: `pausa.tscn` conserva `layer = 20` escrito (una escena no lee una `const`); lo anotan `pausa.gd` y la tabla
  de capas del contrato.
- 4.4: `MarcoMenus.PAGINAS` con los scripts por `preload` (el nombre de una clase global no es una expresión
  constante: la primera versión no compiló) y la página Mapa por ruta, cargada solo si existe.
- 4.5: la ranura dice el nombre de la zona («La Celda»); `ranuras` 67 casos.
- 4.6: los tres comentarios ya estaban corregidos desde el 29-oct; solo se renombró la señal.
- 4.7: `cambio_pedido_ms` lo limpia el primer tick, no `_ready`: el contrato dice lo que hace el código.
- Ningún `.esperado` cambió salvo `ranuras`. `validar` 405 archivos sin fallos; batería completa 207/207; Terra sin
  fallos en 5 y 4a; `revisor` aprobado (5 y 4). Las pruebas de sensación en el S50 (caer a espinas,
  reaparecer, curar; ir y volver por el hueco `celda_2` ↔ `celda_5`, F-090) pasan según
  «Tras las pruebas en el S50» y la fila «Cierre de la auditoría en el S50» de `docs/pruebas.md`.

## Grupo 6 · Contrato más corto
Pedido por la persona el 29-oct-2026: `docs/contrato.md` tiene 1412 líneas (196 KB) y cuesta leerlo antes de cada
cambio. Claude Sonnet lo audita sin editar y propone qué queda, qué se resume, qué pasa a un archivo propio de `docs/`
y qué se borra porque ya lo dicen el código u otro documento, con un mapa sección por sección para comprobar que no se
pierde ninguna regla y la lista de quién cita cada sección. La persona aprueba la propuesta; después se aplica cuando
nadie más edite el contrato (al cerrar el grupo 2) y el `revisor` compara regla por regla. Va en el mismo PR.

Avance (29-oct-2026):
- Aplicado: `docs/contrato.md` queda en el núcleo (configuración, ciclo de vida, guardado, estado de la partida, bus,
  sala, capas, paquete) con una tabla de los siete archivos por tema: `componentes`, `enemigos`, `audio`,
  `ajustes-y-entrada`, `interfaz`, `arte-y-rendimiento` y `validador`. 1414 → 478 líneas en el núcleo; el total
  baja poco (una segunda pasada que cambió cifras por la cita a su `const` quitó un 8 % de interfaz y componentes):
  lo que queda son reglas.
- Citas actualizadas en `docs/`, comentarios de `.gd`, `funciones.json`, los `CLAUDE.md` de bloque, tres skills,
  `funcionalidad` y el `revisor` (con aprobación de la persona). Las de `planes/cerrados/` se quedan: son historia.
- `revisor`: 7 fallos (dos reglas de `Interactuable` cambiadas de sentido, una cita sin archivo, cuatro recortes sin
  registrar, fechas y cifras de `const` que contradecían la regla de mantenimiento, el alcance de la conversión de
  partidas): arreglados devolviendo el texto del contrato viejo. `validar` 391 archivos, batería completa 205/205.

## Tras las pruebas en el S50 (30-oct-2026)

La persona probó los siete grupos en el S50 sin fallos (filas «Cierre de la auditoría en el S50» y «Jefe» de
`docs/pruebas.md`). De esa prueba salieron cuatro cambios, en el bloque de commit 56:

| Cambio | Decisión y porqué |
|---|---|
| El ataque suena siempre | `jugador_ataco` y `ataque_jugador`, con el WAV del golpe (pedido por la persona). Antes solo sonaba pegarle a algo. Pegar suena doble; la persona lo oyó y lo aprueba |
| Sonido de curar | `curar.wav` sube 1,9 s con el pico a los 1,2 s y se tocaba al terminar los 60 ticks: el pico llegaba unos 2,2 s después de apretar. Ahora empieza con la curación y `curacion_cortada` lo calla (`docs/errores/2026-10-30-sonido-curar-tarde.md`) |
| Botón de curar | Lo enseña un pizarrón de Las Raíces justo antes del primer enemigo: en La Celda no hay a quién pegarle. `Sala.botones_ocultos` en la base de la zona. `botones_por_ensenar` no servía: exige el aviso en la misma sala. Cuando exista Las Raíces, sus salas anteriores al pizarrón lo llevan también |
| El Eterno | Segunda conversación de una línea, para no repetir la entrega |

La barra de Inspiración se queda como está: 3 bloques repartidos en el ancho fijo, más grandes que los 9 (la persona lo
vio y lo aprueba).

## Aplastar (1-nov-2026)

El QA de la issue #10 (3.3) reportó que el elevador deja encima al que aplasta. La persona pidió resolverlo como Silksong.

| Tema | Decisión y porqué |
|---|---|
| Referencia | Leído en los datos: de 744 escenas y prefabs, solo `Bone_16` asigna `heroSquasherLeft/Right`. Son zonas fijas en los extremos del recorrido, peligro de tipo SPIKES, activas solo mientras la pieza se mueve y está cerca. `LiftControl` y `RuinsLift` no tienen nada de daño: lo demás se evita con el diseño de la sala |
| Forma | `DanoContacto.aplastador` y `Vaiven.aplasta`, sin clase nueva. La zona es fija, así que sigue la regla de que lo que se mueve no lleva peligro y el validador la acepta |
| Dirección y lado | La pieza debe venir hacia la zona y el jugador estar delante de su origen: el elevador de prueba llega al nivel del suelo y quien va encima pisa la zona |
| Solo en el suelo | Sin esto, quien cae por el boquete de `celda_4` bajo la raíz recibía el golpe sin estar aplastado |
| Ancho | El de la pieza. En `celda_4` la zona cruza el boquete: el cuerpo (80 px) cabe bajo la raíz desde los dos pisos |
| Salas | Sala Plataformas y `celda_4` la llevan. `celda_2` no: quedan 240 px bajo el elevador |
| Reaparecer | En la zona no se recuerda punto seguro (`Jugador.no_recordar_punto_seguro`, reinicia los ticks de suelo firme: no depende del orden de los nodos). El `revisor` midió por qué: con el punto bajo la pieza, la física lo dejaba encima (la misma queja de la 3.3), hasta 59 px dentro del piso o fuera de la sala por `PuertaAbajo`. Silksong no lo sufre porque reaparece en marcas fijas |
## Fuera de este plan
Decidido por la persona el 29-oct-2026, tras probar las páginas en el S50 (funcionan; el diseño se rehace): el
pulido visual de las páginas del marco (Amuletos y Útiles; Mapa e Inventario) va a los otros dos integrantes, uno
cada par, con un mockup en HTML hecho en otra sesión a partir de lo que ya existe, en su issue con capturas a
1280×720. Solo tocan la presentación; los guiones `amuletos`, `utiles`, `marco` y `mapa_cuentas` cuidan las reglas.
Empiezan con este PR ya en `main` (el grupo 4 cambia cómo la sala crea las páginas).

F-088 (espera el arte de la mujer), F-047 (cuando el CI pase de 10 min), la tabla de conversión de F-010 (cuando las
partidas se conserven, al terminar el juego) y F-063 a F-065 (con la segunda zona).
