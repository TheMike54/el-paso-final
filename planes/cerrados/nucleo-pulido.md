CERRADO

# Pulido antes de la primera sala: capas de física, agarre a la pared, puertas por id, guardado, ids y arte

Autorizado por la persona el 14-oct-2026 para escribirlo y ejecutarlo en la tanda de la noche, sin leer antes esta
lista de hitos (la lee el 15-oct-2026), junto con las decisiones técnicas A-F y 6-12 de ese día (abajo, en H8). Rama nueva `feature/nucleo-pulido`, creada de
`chore/limpieza-codigo` después de sus dos commits (la segunda limpieza, `planes/cerrados/nucleo-limpieza-2.md`).
Se hace en una copia de trabajo aparte y se entrega como parche, porque el árbol principal tiene el #5 sin commit.
Lo del #5 de esa noche (paredes detrás de las puertas, foco por último dispositivo) no está en esta base: lo que
dependa de ello se anota como pendiente para después de fusionar.

Punto crítico (física y movimiento del jugador, guardado, contrato, `project.godot`, validador): `revisor` al final.
Cada hito se comprueba con `validar.ps1` y los guiones; los casos nuevos fallan sin el cambio.

## H1. Capas de física con nombre

Hoy ningún archivo fija `collision_layer` ni `collision_mask`: todo vive en la capa 1 y mira la capa 1, y cada
pieza descarta por tipo lo que no le toca. Funciona, pero cada enemigo, ataque o recogible nuevo ve todo lo demás.
La documentación propone nombrar las capas y poner a cada tipo en la suya
(`tutorials/physics/physics_introduction.rst:115-155`).

| Capa | Nombre | Quién está en ella | Quién la mira (máscara) |
|---|---|---|---|
| 1 | `escenario` | Todo `StaticBody2D`: suelos, paredes, `SueloFragil`, paredes tras puertas. Es la capa por omisión: las 92 formas de las salas no cambian | Jugador (cuerpo); los rayos de proyectiles, del `Golpeable` y de salida de la bola |
| 2 | `jugador` | El cuerpo del `Jugador` y de la caja gris | Daño por contacto, puertas, banco, recogibles, NPC, reto, entregas, cortables (sacudida) |
| 3 | `golpeable` | `Golpeable` (enemigos y muñecos) y `Cortable` | Ataque del jugador, su bola, la onda de la picada |
| 4 | `danino` | `DanoContacto` y lo que hereda de él: pinchos, enemigos, `AtaqueEnemigo`, `ProyectilEnemigo` | Ataque del jugador (parry y pogo) |
| 5 | `interaccion` | Puerta, banco, coleccionable, objeto de habilidad, objeto de mapa, NPC, reto, entrega, interruptor | Nadie: solo miran al jugador |
| 6 | `ataque_jugador` | El `Ataque` del jugador y su bola | Nadie |
| 7 | `cuerpo_enemigo` | Reservada: el primer enemigo que camine con física (`CharacterBody2D`) | Ese enemigo mira `escenario` |

- Las capas y máscaras las pone el script de cada pieza en `_ready` con constantes de `nucleo/capas.gd`
  (`class_name Capas`), no cada `.tscn`: los pinchos y muñecos están puestos a mano en muchas salas con el script
  encima, y así ninguna sala puede olvidarlas. `project.godot` nombra las 7 capas (`layer_names/2d_physics/`) para
  que el editor las muestre.
- Rayos y consultas con `collision_mask` explícita: el `Golpeable`, la bola y su rayo de salida, y el
  `ProyectilEnemigo` miran `escenario`; la onda de la picada, `golpeable`.
- Comprobación: prueba nueva `prueba_capas_fisica.gd` que instancia cada pieza y lee su capa y su máscara contra la tabla;
  los 128 guiones sin cambios (las reglas de juego no cambian: lo que antes se descartaba por tipo ahora no se ve).

## H2. Agarre a la pared: preparado, sin cambiar el comportamiento

Observación de la persona en la sala de pared (14-oct-2026): en la esquina de arriba de una pared se sigue
agarrando y saltando con el 70 % del cuerpo ya por encima. Causa: el agarre usa `is_on_wall()`
(`nucleo/jugador.gd`, «Contra la pared»), que es verdadero con cualquier contacto. Hollow Knight y Silksong: no se
encontró cómo lo resuelven (no comprobado). Celeste, lo único verificado, hace lo mismo que hoy aquí (cualquier
contacto del hitbox) y al llegar arriba da un saltito a la cornisa (`Player.cs`, `ClimbHop`).

- Cambiarlo haría más difícil justo la esquina de arriba, que dos personas de la QA ya encuentran difícil con el
  dedo, y la persona decidió el mismo día que la dificultad se queda: es una decisión suya.
- Se deja preparado: `altura_agarre_pared` (exportada; 0 = cualquier contacto, como hoy). Con un valor mayor, el
  agarre pide además la pared a esa fracción de la altura del cuerpo, con un rayo hacia ella (máscara
  `escenario`). Por omisión 0: nada cambia.
- Comprobación: un caso de prueba con el valor en 0,5 (deja de agarrarse con medio cuerpo fuera) y los guiones de
  pared actuales sin cambios con el valor en 0.

## H3. Puertas por id de sala (decisión D)

- `Puerta.sala_destino` deja de ser una ruta: es el id de la sala (`prueba_2`), o la ruta `res://` solo en una sala
  de prueba suelta sin id. La puerta cambia de escena con `Sala.ruta_de(sala_destino)`.
- Las puertas de las salas con id pasan a id. El validador falla si una puerta lleva la ruta de una sala que tiene
  id, y sigue revisando que el destino exista y que la puerta de vuelta coincida.
- Los ids de sala no se renumeran nunca; una sala nueva toma el siguiente número libre (regla en el contrato).

## H4. Guardado: campos nuevos con valor por omisión (decisión E)

- `Guardado.NUEVOS`: los campos agregados después de la versión 3, cada uno con su valor por omisión; hoy vacío. Al
  cargar, un campo de `NUEVOS` que falta se rellena con su valor; si está con otro tipo, la partida es `DANADA`.
- `VERSION` sube solo cuando cambia la forma de algo que ya existe; entonces se escribe la función que convierte la
  partida de la versión anterior. Una partida de una versión más nueva que el juego es `INCOMPATIBLE`.
- Cambia «No hay migración» del contrato.
- Comprobación: casos nuevos en la prueba del guardado con una lista de nuevos de prueba (falta → se rellena;
  tipo distinto → dañada; versión mayor → incompatible). Una versión menor sigue siendo `INCOMPATIBLE` mientras
  no exista su función de conversión (hoy no hay ninguna: la 3 es la primera que llegó a la QA).
- Los valores por omisión van con forma de JSON (`0.0`, `Array` sin tipo), como quedan al leer el archivo.

## H5. Ids de habilidades en una lista (decisión F)

- `nucleo/habilidades.gd` (`class_name Habilidades`): una constante por habilidad y `TODAS`. El código usa las
  constantes en lugar de `&"pluma"` escrito a mano.
- `Partida.obtener_habilidad` con un id que no está en `TODAS`: `push_error` (lo atrapa el guion que lo haga).
- El validador revisa que cada `habilidad` de un `ObjetoHabilidad` o una `Recompensa` y cada
  `habilidades_de_prueba` de una sala esté en `TODAS`.
- Amuletos y jefes: su id en su ficha cuando exista el primero (regla en el contrato; nada que cambiar hoy).

## H6. Arte e importación (decisiones A y B)

- Regla: el arte se pinta al tamaño en que se ve en 1280×720 (1x, personaje de 160 px) y no se encoge en la escena.
- Importación: «Lossless» por omisión; «VRAM Compressed» solo en fondos opacos grandes
  (`tutorials/assets_pipeline/importing_images.rst:185-189`). Mipmaps en el arte del mundo, no en el HUD; filtro
  «Linear Mipmap» por omisión en `project.godot` (`tutorials/rendering/multiple_resolutions.rst:596-604`); una
  textura sin mipmaps se sigue viendo lineal.
- El validador revisa los `.import` del arte del mundo (`contenido/` y la sala de arte): mipmaps encendidos y VRAM
  solo en una imagen sin transparencia.
- La sala de arte se reimporta con mipmaps: medido el 13-oct-2026 en el S50, 34,1 → 34,3 FPS, APK +1,8 MB.
- Si la persona, al ver en el S50 capas translúcidas comprimidas, las prefiere así, la excepción se anota por
  archivo en el contrato y el validador la acepta.

## H7. Tiempo de carga de cada sala en el APK de desarrollo (decisión 10)

- En un build de depuración, la sala imprime `SALA <clave> carga_ms=<n>`: desde que la puerta pide el cambio hasta
  el primer tick de la sala nueva. No se carga en segundo plano; se reconsidera si una puerta pasa de ~0,5 s en el
  S50 con salas reales.

## H8. Reglas escritas (decisiones A-F y 6-12)

En `docs/contrato.md` (y en `docs/idea.md` lo que es de alcance), sin código:
- C. Claude escribe cada sala completa como `.tscn`; la persona la revisa en el editor si quiere.
- 6. Enemigos: las piezas actuales (`Golpeable`, `DanoContacto`, comportamiento); estados con un `enum` mientras sean
  pocos; zonas de golpe invisibles aparte del dibujo; animación con `AnimatedSprite2D`.
- 8. Jefes: sin base común hasta el segundo; la arena se cierra con una pared que se quita al vencerlo; morir en la
  arena lleva al banco, abre la arena y el jefe empieza de nuevo.
- 9. Audio: efectos en WAV, música en Ogg; cada zona dice su música en su ficha; la toca un nodo fuera de las salas.
- 11. Exportación: APK directo; una sola máquina exporta; la clave de publicación la genera la persona y se guarda
  fuera del repo.
- 12. Idioma: solo español en la v1; textos completos, sin frases armadas a pedazos.

## Fuera (después de fusionar el #5)

- Que el validador exija la pared detrás de cada puerta en el borde: la regla y las paredes están en el #5, que esta
  base no tiene.

## Avance

- 14-oct-2026: plan escrito y revisado con el advisor (H2 pasa a preparado sin cambio; H4 deja explícita la
  versión menor).
- 14-oct-2026, noche: H1 a H8 hechos. `validar.ps1` 197/0 y 130 guiones (dos nuevos: `capas_fisica`, 25 casos, y
  `agarre_pared`, 3 casos); `guardado` pasa de 49 a 53 casos. El validador, probado con errores puestos a propósito:
  puerta con la ruta de una sala con id, con un texto que no es id, con un id que no existe y desde una sala suelta;
  habilidad mal escrita en un objeto y en `habilidades_de_prueba`; arte sin mipmaps; imagen con transparencia en
  VRAM. Cada uno falla con su mensaje y vuelve a 0 al quitarlo.
- Notas de H1: la bola deja de excluir al jugador por su RID (`lanzador` se quitó): su rayo ya no ve al jugador por
  la máscara. El rayo del `Golpeable` quedó en una sola consulta por la misma razón.
- Notas de H6: el filtro lineal con mipmaps por omisión no se vio en pantalla; que una textura sin mipmaps se vea
  igual queda por comprobar en el teléfono.
- Queda abierto hasta que la persona lea los hitos y se cierre con el `revisor`.
- 14-oct-2026: video del S20 (sala de pared): en la esquina de arriba se agarra con ~62 % del cuerpo por encima
  (medido a ojo en un cuadro). Hollow Knight, en su `HeroController` decompilado (repo de terceros, no comprobado
  contra la versión actual): la pared cuenta si le da el rayo del centro del cuerpo o el de los pies; el de la
  cabeza no se usa. Con los pies en la pared sigue agarrado, como aquí con 0; solo cambia que la cabeza sola no
  basta. Silksong: Hornet sube sola a la cornisa al llegar al borde (guía de IGN, «Differences and New Features»);
  no se encontró cómo decide el agarre. El valor de `altura_agarre_pared` y una subida a la cornisa los decide la
  persona.
- Decisión de la persona (14-oct-2026): `altura_agarre_pared` se queda en 0, como Hollow Knight.
- Cierre (14-oct-2026): H1-H8 hechos. La persona leyó el reporte de la noche y aprobó las skills y las entradas;
  `revisor` con 5 fallos de redacción, corregidos. No hay rama `feature/nucleo-pulido`: va en el PR #5 con las dos
  limpiezas (decisión de la persona). Entradas nuevas
  en `funciones.json`: `capas-fisica`, `agarre-pared-altura`, `puertas-por-id`, `guardado-campos-nuevos`,
  `validador-habilidades` y `validador-importacion`.
