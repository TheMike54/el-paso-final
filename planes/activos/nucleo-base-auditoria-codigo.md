ACTIVO (escrito el 28-oct-2026; aprobado por la persona el 28-oct-2026: la división entre este PR y los siguientes, y
D5, D7 y D9 como los recomienda Claude. Las demás decisiones, al empezar su PR)

# Núcleo como base: arreglos y sistemas que dejó la auditoría de código

Dos auditorías del 28-oct-2026 (la de la base y la de código) dejaron 108 hallazgos sin repetir (`F-001` a `F-108`,
lista completa fuera del repo). Veredicto: la base sirve, con condiciones. Decisión de la persona (28-oct): se atiende
todo, dividido entre el PR de La Celda y PRs siguientes (abajo, «Qué entra en este PR»). Los modelos que no son de
Anthropic (Gemini 3.8 Flash, GPT-OSS 120B) solo leen y revisan, sobre una copia en el scratchpad; el código lo escribe
Claude.

## Qué entra en este PR (`feature/contenido-celda`) y qué no
- **Entra:** fases 0, 1 y 2. Son arreglos que no cambian el contrato, más medidas que solo deciden; dejan la base
  limpia sin agrandar la revisión con sistemas nuevos. Del contrato solo entra texto que corrige o anota lo que ya
  hay: F-001 (cifra del atlas), F-010 (la política de guardado, escrita; sin código de conversión), F-033, F-034 y
  F-035 (ganchos sin oyente, anotados). Decisiones que hacen falta para esto: D5 (solo la política), D7 y D9.
- **No entra:** fases 3 y 4, en PRs propios después de este, cada uno con su plan:
  1. `feature/nucleo-enemigos`: F-091, F-085, F-092, F-093, F-040 (si no entró aquí) y D8. Decisiones D1 y D2.
  2. `feature/nucleo-amuletos`: F-087 y F-042. Decisiones D1 y D3.
  3. `feature/nucleo-jefes`: F-086. Decisiones D1 y D4. Va después de enemigos.
  4. `feature/nucleo-arquitectura`: el resto de la fase 3, con lo que haya decidido la medida de la fase 2 (D10).
  5. `feature/mapa-zonas`: F-094, F-095, F-096 y F-073, antes de la segunda zona.
  - D6 (elección de personaje) espera al arte de la mujer. F-047 (CI en matriz) espera a que el CI pase de 10 min.
- La guía que hoy se contradice con la `pluma` (F-076) dice en este PR cómo se prueba hoy un enemigo (en
  `herramientas/salas/`); la instrucción nueva de guion (D8) llega con el PR de enemigos.

«Atender todo» no es cambiar todo: 12 hallazgos concluyen que no hay nada que arreglar (fase 0). Lo demás se hace por
fases; cada fase cierra con `validar.ps1`, `correr-guiones.ps1` completo y, si toca un punto crítico, el `revisor`.

## Decisiones de la persona (antes de empezar)
| # | Pregunta | Recomendación de Claude |
|---|---|---|
| D1 | Botín, amuletos y jefes se construyen sin ningún caso real en el juego (La Celda no tiene enemigos ni jefe). Es una excepción a «no se generaliza hasta tener tres casos» | Aceptarla para estos tres sistemas, con la versión mínima y probada en `herramientas/salas/` |
| D2 | Botín: ¿el enemigo suelta PejeCoins que saltan y se recogen (como el geo de Hollow Knight) o se suman directo? | Que salten: usa `MonedasSueltas`, que ya existe, y se ve el premio |
| D3 | Amuletos: carga máxima, cuántos equipados y qué efectos entran ahora | La ficha y el menú para todos; efectos solo de los que tocan sistemas que ya existen (velocidad, invulnerabilidad, alcance, Inspiración, curar, PejeCoins de enemigos, brújula). Los de impulso o revivir, con su sistema |
| D4 | Jefes: un sistema genérico (vida por fases, arena que cierra un `Porton`, entrega de habilidad, `jefe_vencido`) probado con un jefe de caja gris en una arena de la zona de pruebas | Sí; el primer jefe real va con su zona |
| D5 | Guardado: hoy cambiar `VERSION` deja inservibles las partidas viejas (F-010) | Campos nuevos por `Guardado.NUEVOS` (no suben `VERSION`) y una tabla de conversión por versión con su prueba, para el primer cambio de forma |
| D6 | Elección de personaje (F-088): está oculta hasta que la mujer tenga arte | Dejar fuera de este PR: sin arte no se prueba. Solo la `FichaPersonaje` si se quiere |
| D7 | Accesores y señales que solo usan pruebas y guiones (F-031, F-032) | No borrar: marcarlos «para pruebas»; borrar obliga a reescribir `.esperado` sin ganar nada |
| D8 | Cómo prueba un guion de `contenido/` a un enemigo si atacar exige la `pluma` (F-076) | Que el guion pueda dar habilidades (una instrucción nueva en `docs/guiones.md`), sin tocar la escena |
| D9 | `contenido/objetos/celda/puerta_salon_b.tscn` no la usa nada (F-036) | Borrarla desde el editor si no es trabajo en curso |
| D10 | Jugador e interfaz persistentes entre salas (F-097) | Solo si la medida de la fase 2 pasa de 0,5 s por puerta; si no, se queda como está |

## Fase 0. Sin nada que cambiar (se cierran con su porqué)
F-007, F-019, F-026, F-027, F-028, F-030, F-037, F-062, F-066, F-069, F-070, F-108 y la mitad de F-009 (ya dicho en
`nucleo/CLAUDE.md`): su propio hallazgo concluye «ninguno» o «a la tercera vez». Se anotan como cerrados.

## Fase 1. Arreglos sin cambio de contrato
| Grupo | Hallazgos | Qué |
|---|---|---|
| Comentarios y documentos | F-001, F-002, F-003, F-004, F-005, F-006, F-008, F-011 (sin la señal del bus), F-012 | Corregir contra el código; F-012 lo decide la persona (dónde vive el script del atlas) |
| Repetición | F-013, F-014, F-017, F-020, F-021, F-022, F-029 | Helper de carga opcional, constantes de `Tema`, `Jugador.actual()`/`sentado()`, centro del jugador desde su forma |
| Validador | F-038, F-039 (primero aviso), F-040, F-041, F-043, F-044, F-045, F-046 | Reglas nuevas con su caso en `prueba_validador.gd` y su entrada en `herramientas/funciones.json` |
| Costo sin medida necesaria | F-057, F-058 | Apagar procesos que ya no hacen nada |
| Piezas | F-067 (foso genérico), F-068 (colgantes), F-071 (base de zona neutra), F-072 (`FondoTapado` con lado), F-107 (retroceso con `move_and_collide`) | Las escenas nuevas como texto con su `uid`; los movimientos de carpeta (F-063, F-064, F-065) los hace la persona en el editor |
| Guías | F-074 a F-084 | Ejemplos mínimos pegados, base heredada, franja del mapa, comando de `uid`, glosario y comandos de git |
| Física del jugador | F-018 (`_quedar_quieto`) | Con `revisor` y prueba manual en el teléfono |
- Gemini 3.8 Flash relee el código muerto (la parte de la auditoría que quedó sin Gemini); antes se comprueba que
  encuentre los 15 ya confirmados.

## Fase 2. Medidas en el S50 (deciden, no cambian)
APK de Desarrollo por `adb`, herramienta `medicion` y `SALA <id> carga_ms`: F-048, F-049, F-050, F-051, F-053, F-054,
F-055, F-056, F-059, F-060, F-061, F-097, F-098; F-090 y F-018 son de sensación (prueba manual). Cada medida decide
su hallazgo: si no sube los FPS o no pasa del umbral, se cierra sin cambio. Lo que sí pese, se arregla en la fase 3.

## Fase 3. Contrato y arquitectura (cada fila, actual → nuevo, aprobada por la persona)
F-010 (política de guardado, D5), F-011 (renombrar `ajuste_grafico_cambiado`), F-015 (`Sala.nombre_de`), F-016
(clase base de los tres modales), F-023, F-024 (páginas del marco en una lista), F-025 (recorrido de un premio nuevo, anotado), F-033, F-034, F-035 (ganchos sin
oyente anotados en el contrato), F-089 (`sala_entrada`), F-095, F-099 (sacar de `jugador.gd` punto seguro,
transición y efectos), F-100, F-101 (puertas y bancos por grupo), F-102, F-103, F-104, F-105, F-106, F-073 (inicio del juego como ficha de `contenido/`), y lo que la fase
2 haya decidido cambiar (F-097, F-098, F-090). La tabla se presenta antes de esta fase.

## Fase 4. Sistemas nuevos (cada uno con su contrato en el mismo cambio)
| Sistema | Hallazgos | Prueba |
|---|---|---|
| Enemigo con arte: `AnimatedSprite2D` opcional que apaga la caja (también `Palanca`) | F-091 | `sala_enemigos` con un enemigo con arte provisional |
| Botín en `FichaEnemigo` | F-085 | Guion: vencer da las PejeCoins una vez |
| Datos por ejemplar del enemigo | F-092 | Dos enemigos del mismo tipo con radio distinto |
| `FichaAmuleto`, `Amuletos.TODOS` en el validador, efectos como datos | F-087, F-042 | Guiones de equipar y de cada efecto que entre (D3) |
| Jefes: fases, arena, `jefe_vencido`, entrega | F-086, F-035 | Arena de jefes en la zona de pruebas con un jefe de caja gris |
| Sonidos por ficha de quien los produce | F-093 | Guion de evento de enemigo |
| Nombre visible y color de zona en el mapa | F-094 | `mapa_cuentas` |
| Formato de estaciones y bolsa de preguntas reales | F-096 | Guion que cruza una estación de `contenido/` |
| CI en matriz por bloque cuando pase de 10 min | F-047 | Tiempo del CI |

## Cómo se ejecuta en este PR
- Sesión autónoma (modo `auto`), en el orden 0 → 1 → 2. Cada grupo de la fase 1 en su propio bloque de commit.
- D9: la sesión no borra `puerta_salon_b.tscn`; comprueba que nada la nombre (ruta ni uid) y la deja en la lista para
  borrarla desde el editor.
- Fase 2: si el S50 no está conectado (`adb devices`), la fase queda pendiente y se anota; no se inventan cifras.
  F-018 y F-090 se piden a la persona como prueba manual.
- Gemini 3.8 Flash (`gemini-3.8-flash-high`) y GPT-OSS 120B (`gpt-oss-120b-medium`) por `agy`, en modo `plan` con
  `--sandbox`, sobre una copia del repo en el scratchpad: solo leen; cada hallazgo suyo se verifica contra el archivo.

## Cierre
- `revisor` sobre todo (toca núcleo, contrato, guardado y física). GPT-OSS 120B como segundo lector del diff.
- Prueba en el teléfono de lo que cambió a la vista o al tacto.
- Bloques de commit por fase. El PR declara Claude, Gemini (Argon y Flash) y GPT-OSS y qué parte hizo cada uno.

## Hecho

### Resumen (tanda autónoma del 28-oct-2026, fases 0, 1 y 2 de este PR)
- **Verificado por la sesión** (corrido, con la salida a la vista): `validar.ps1` `OK  VALIDACION archivos=357 fallos=0`
  (antes de empezar: 352), 0 avisos; `correr-guiones.ps1` completo `RESUMEN total=193 OK=193 MALOS=0` (tras el
  grupo 3 y tras los grupos 4 a 6). `validar.ps1 -SinImportar` tarda 4,6 s.
- **Hecho:** fase 0 y fase 1 en seis grupos (abajo). Fase 0, cerrados sin cambio porque su propio hallazgo concluye
  «ninguno» o «a la tercera vez»: F-007, F-019, F-026, F-027, F-028, F-030, F-037, F-062, F-066, F-069, F-070, F-108 y la
  mitad de F-009 (ya dicho en `nucleo/CLAUDE.md`, líneas 3-4).
- **Cerrado sin cambio, con porqué:** F-017 (depende de la clase base de modales, F-016, que es de la fase 3), F-020
  (un helper `_fallo` sin migrar los 72 sitios sería código muerto, y migrarlos es riesgo sin ganancia; el
  hallazgo mismo dice «prioridad mínima»), F-029 (el dueño de una `LuzSala` puede ser una pieza y no la `Sala`;
  leer `Sala.oscuridad` obligaría a buscarla), F-044 (el validador entero tarda 4,6 s: instanciar cada sala dos
  veces no cuesta nada medible), F-071 (extraer una base neutra cambia la base de las cinco salas sin un segundo
  consumidor que pruebe que es neutra: va con la segunda zona).
- **F-012, cerrado el 28-oct-2026 por decisión de la persona:** el script del atlas usa las hojas originales, que no
  entran al repo, así que no se mueve; `docs/contrato.md` («Recursos», atlas del jugador) dice que desde un clon no se
  rehace el atlas y que un cambio en las animaciones pasa por el responsable del arte.
- **Pasó a la fase 3 o espera a la persona:**
  de los diez colgantes de F-068 quedan cuatro armados a mano (los tres `Medio` de `celda_1`, sin `use_parent_material` y uno con `flip_h`, y el de `Juego`, con otra
  escala: no encajan en la pieza).
- **Fase 2: hecha el 28-oct-2026 con el S50 y el S20 conectados** (resultados abajo). De los 13 hallazgos medidos, 11
  se cierran sin cambio por estar bajo el umbral; F-098 se confirma (pasa de 0,5 s por sala en el S50) y pasa a la
  fase 3; F-097 se decide: no persistir jugador e interfaz. F-090 y F-018 siguen siendo pruebas de sensación tuyas.
- **Gemini 3.8 Flash y GPT-OSS 120B:** ver «Segundos lectores» abajo.

### Qué mide o prueba la persona en el teléfono
Hecho: el 28-oct-2026 la persona probó en el S50 las pruebas de sensación 2 a 4 y F-090 y dice que todo funciona
bien. La carga al cruzar puertas (1) ya está medida en la fase 2 (F-098, a la fase 3).
1. Con el APK de Desarrollo ya instalado en los dos teléfonos: cruzar puertas en La Celda y leer `SALA <clave> carga_ms`
   en `adb logcat -s godot` (la fase 2 midió con la herramienta `medicion`, sin el fundido de la puerta del juego).
2. F-018 (`_quedar_quieto`): sentarse a mitad de un ataque, hablar con un NPC en pleno impulso y cruzar una puerta
   en un golpe: el jugador queda quieto y sin nada a medias, como antes.
3. F-107 (retroceso con `move_and_collide`): golpear a un enemigo que camina junto a un saliente o una pared:
   retrocede y no se mete en el sólido.
4. F-057 (aviso que apaga su proceso): pasar por un pizarrón ya hecho y volver: no reaparece; uno de modo SIEMPRE
   sigue apareciendo al entrar.

### Qué borra o mueve la persona en el editor
- `contenido/objetos/celda/puerta_salon_b.tscn` y su `puerta_salon_b.png` (D9): comprobado que ningún archivo
  nombra la escena (ni su ruta ni su uid `uid://blp5mqcf355ki`); sin versionar. Solo desde el panel FileSystem.
- F-063, F-064, F-065 (carpetas comunes): se hacen con la segunda zona, como dicen los hallazgos.

### Fase 2: medidas en el S50 y el S20 (28-oct-2026)
**Cómo:** APK de medición armado en una copia del repo en el scratchpad (nunca en el repo; id `...elpasofinal.medicion`, ya
desinstalado de los dos), con la herramienta `medicion` más, solo en la copia: un eje `--quitar=` que apaga una pieza
(panel, fondos, luces, solapes, táctil, sondeos, material), un micro-benchmark `--bench=N` que llama N veces el callback de
cada nodo de cada clase sospechosa y mide microsegundos por cuadro, y tiempos dentro de `Sala._ready`. El benchmark era
necesario: con V-Sync encendido (lo dice la línea `MEDICION inicio vsync=1`) los FPS se topan en 59-60 y no distinguen
nada por debajo de un cuadro. `TIME_PROCESS` mide el cuadro entero con la espera del V-Sync: no sirve. Equipos: Senwa S50
(32 bits, Recursos bajo, 960 × 480) y Galaxy S20 (SM-G980F). **Umbral de decisión** (lo elegí yo, es una decisión mía
anotada): más de 0,5 ms por cuadro (3 % de 16,7 ms), o un cambio de llamadas de dibujo o de FPS, justifica arreglar. Los
microsegundos incluyen el costo de la llamada (`call`), así que son un techo. Las cifras son del S50 salvo que diga S20.

| Hallazgo | Medida | Decisión |
|---|---|---|
| F-048 panel y hitbox | Sin ellos: 19 nodos menos (237 → 218 en celda_1; 174 → 156 en celda_4); `Sala._ready` 109-122 → 94-98 ms (celda_1), ~105-150 → 95-97 (celda_4); FPS igual. Es un 1-2 % de la carga | Cerrado sin cambio |
| F-049 `FondoTapado` | `_process` 18-27 µs por cuadro; sin él, llamadas de dibujo iguales (37 y 30) y FPS iguales | Cerrado sin cambio |
| F-050 táctil y mapa | `ControlesTactiles._process` 193-258 µs (1,2 % del cuadro), `PantallaMapa` 11-18 µs | Cerrado sin cambio. Es el mayor de los sondeos, por si algún día pesa |
| F-051 sondeos | `ContadorFps` 15-30 µs, `Pausa` 9-11, `MarcoMenus` 11-16, `Hud` 9-17: ~60 µs en total | Cerrado sin cambio |
| F-053 material del jugador | Con y sin el material: las mismas llamadas de dibujo en los dos teléfonos (37 / 30 / 31) y los mismos FPS | Cerrado sin cambio |
| F-054 hojas de efectos | Sus medidas: 8,9 MB de RGBA sin comprimir; con mipmaps serían ~3 MB más. El teléfono no deja leer la memoria de gráficos (S50: `Graphics: 0`) | Sin cambio de importación; exención escrita en `docs/contrato.md` («Recursos») |
| F-055 `LuzSala` | 42-59 µs por luz: 7 luces de celda_1 = 0,30-0,33 ms; 4 luces = 0,17-0,21 ms | Cerrado sin cambio |
| F-056 solapamientos | `Interactuable` 10-43 µs por nodo, `DanoContacto` 12-14, `AvisoAccion` 75-91 (en el banco de pruebas, que lo llama aunque duerma): total por sala ≤ 0,25 ms | Cerrado sin cambio |
| F-059 rayos | Un rayo nuevo cuesta 55-79 µs y uno reutilizado 14-23 µs (S20: 11 y 2). La sala de enemigos móviles hace 2,8 rayos por tick con 4 enemigos: se ahorrarían ~0,11 ms por tick | Cerrado sin cambio |
| F-060 video | Menú con video: 55-58 FPS en el S50 (60 en el S20); una sala sin video: 59,6 en el S50. ~1 ms más por cuadro solo en pantallas de video del S50; no se aisló la llamada a Java | Cerrado sin cambio: no toca el juego |
| F-061 peso del arte | Texturas por sala (S50, bajo): celda_1 32,8 MB, celda_2 35,1, celda_3 34,9, celda_4 45,7, celda_5 29,8 (S20: 46-62). PSS con celda_4: S50 146 MB, S20 376 MB (186 de gráficos). APK de Desarrollo: 115 MB | Cifras entregadas: el presupuesto por sala lo decide la persona (la sala más pesada ya está en 45,7 MB) |
| F-097 jugador e interfaz | `Sala._ready`: jugador 6-8 ms, interfaz 87-115 ms: ~110 ms de 830-1820 ms de carga | **D10: no persistirlos**; ahorrarían ≤ 13 % y no resuelven la carga |
| F-098 carga de sala | Con la sala ya vista antes, S50: celda_1 374-892 ms, celda_2 780-940, celda_3 803-971, celda_4 1547-1822, celda_5 622. Primera carga en frío de celda_1: 2270-2750 ms (`Sala._ready` tarda 788-1004 ms esa vez). S20: 61-254 ms | **Pasa a la fase 3**: carga en segundo plano (`load_threaded_request`) al empezar a oscurecer; en el S50 todas las salas pasan de 0,5 s |

**Fuera de la lista de hallazgos:** los cuatro comportamientos de la sala de enemigos móviles cuestan 1,88 ms por tick en el
S50 (0,47 ms por enemigo; S20: 0,15 ms en total), dominado por algo distinto de los rayos (el movimiento). Con diez
enemigos serían ~4,7 ms, el 28 % del cuadro. Es una cifra de un banco que llama el tick 300 veces seguidas, no de una
partida: se confirma con enemigos reales cuando haya. **No medido:** FPS jugando con movimiento (no hay joystick
simulado en esta tanda), la primera partida de la persona con el APK de Desarrollo, y el APK sin el cambio de esta rama
(no se comparó contra `main`).

### Grupos de la fase 1 (decisión, porqué y medida)
**1. Comentarios y documentos** (F-001 a F-006, F-008, F-011 sin la señal del bus): cifras y comentarios corregidos
contra el código (atlas 2020 × 668, `Guardado.NUEVOS`, «respira» y no «girar», `EntregaRecompensas` fuera de la lista
del validador, ruta del plan de M6, `Ver hitbox` apagado al medir FPS). F-011: sin renombrar nada; comentarios en
`eventos.gd`, `controles_tactiles.gd`, `estacion.gd`, `jugador.gd` y `mando.gd`. Contrato (solo texto): F-001, F-010
(política de partidas viejas, sin código de conversión: D5), F-033, F-034 y F-035 (ganchos sin oyente anotados).
Guías F-074 a F-084: ejemplos pegados de archivos reales, base heredada y lo que arrastra, franja del mapa (La Celda
llega a y 3814: celda_4 en y 2374 más 1440 de alto, calculado de los `.tscn`), medidas de puerta y pared, salida de
`generar_mapa`, glosario en el índice, comandos de git y por qué un enemigo se prueba hoy en `herramientas/salas/` (D8
llega con el PR de enemigos).
**2. Repetición** (F-013, F-014, F-021, F-022): `Cargar.si_existe` (`nucleo/cargar.gd`) en los seis sitios;
`Tema.SEPARACION_FILAS` y `Tema.SEPARACION`; `Jugador.actual()`, `Jugador.sentado()` y `Jugador.centro()` (la forma
del jugador y no el literal −80); `muro_rompible` usaba el literal `&"jugador"`.
**3. Validador** (F-038, F-039, F-040, F-041, F-043, F-045, F-046): `queue_redraw()` sin guarda también en
`_physics_process`; aviso de sala de `contenido/` sin guion con su `escena`; regla `_revisar_enemigos` y `Enemigo` en
las piezas con id; la prueba de sonido compara los campos de `FichaSonidos` con su tabla de señales (reveló que la tabla
no tenía `dano`: agregado); la prueba táctil compara el tamaño de los arreglos de botones; un solo conjunto de rutas
citadas para las imágenes sin uso; `herramientas/arreglar-uids.ps1` (usado de verdad sobre las escenas nuevas). Casos:
`validador` 141 → 155, `sonido` 19 → 20, `controles_tactiles` 54 → 55, `piezas_sala` 31 → 33. F-039 queda como aviso.
**4. Costo sin medida** (F-057, F-058): `AvisoAccion` apaga su proceso cuando está hecho, invisible y sin nadie dentro
(`body_entered` lo prende; dentro de la zona sigue, para que `dentro` siga al día); `MuroRompible` no redibuja si tiene
dibujo propio. Sin cifra de FPS (no hay teléfono): decidido por lógica, a confirmar en la fase 2.
**5. Piezas** (F-067, F-068, F-072, F-107): `nucleo/piezas/foso.tscn` y `foso_varillas.tscn` hereda de ella (el nodo
`Varillas` se llama ahora `Peligro`: nada lo nombraba); `contenido/objetos/celda/colgante_frente.tscn` y nueve
colgantes de `celda_1`, `celda_2`, `celda_4` y `celda_5` ahora la instancian; `FondoTapado.lado` con su regla del
validador y casos; el retroceso de `Golpeable` usa `move_and_collide` cuando el padre es un cuerpo.
**6. Física del jugador** (F-018): `_quedar_quieto()` en `sentarse`, `empezar_a_hablar` y `_empezar_transicion`; el
aterrizaje duro y la picada quedan como estaban. Guiones de núcleo en verde.

### Segundos lectores
- **Gemini 3.8 Flash (código muerto):** no se obtuvo resultado. `agy` en modo `plan` con `--sandbox` niega cualquier
  comando (no puede leer la copia del código) y, por stdin, el mensaje llega truncado (~140 KB de 1,4 MB); su único
  intento útil dijo que solo recibió dos archivos. No se usó `--dangerously-skip-permissions` porque el plan no lo
  autoriza. Tampoco se comprobó que encuentre los 15 ya confirmados. La relectura del código muerto queda abierta.
- **GPT-OSS 120B (segundo lector del diff):** no entregó hallazgos: en modo `plan` solo devolvió un plan de revisión
  (sin leer nada). No hay segundo lector externo; queda abierto para la persona si lo quiere repetir con una
  autorización distinta.
- **`revisor` (28-oct-2026, 980 s):** corrió `validar.ps1` (`archivos=357 fallos=0`) y `correr-guiones.ps1`
  (`total=193 OK=193 MALOS=0`) y no encontró regresiones de código (física del jugador, aviso dormido, retroceso,
  regex de citas y escenas heredadas comparadas contra la copia anterior). Marcó tres documentos desactualizados
  (glosario de `FondoTapado`, avisos del validador en `_physics_process`, `foso.tscn` sin fila en el contrato) y cuatro
  imprecisiones menores: todas corregidas después; `validar.ps1` y el guion `validador` en verde de nuevo. No pudo
  comprobar que `arreglar-uids.ps1` se corriera sobre las escenas nuevas (sí su efecto: uids presentes y validados).
