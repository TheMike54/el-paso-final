ACTIVO

# La Celda (`celda_1`): la primera sala con su arte — versión 2

Versión 1 aprobada por la persona el 21-oct-2026 (en git). Esta versión 2 (25-oct-2026) la reescribe con lo medido en
una demo de La Celda armada en una copia de pruebas del repo (23 al 25-oct, S50 y S21): arte, efectos, 9
optimizaciones, recorte de fondos y lo que no sirvió. Va en un solo PR junto con `nucleo-ajustes-avanzados`,
`nucleo-video-hardware` y `nucleo-trazo-ataque`. Aprobado por la persona el 25-oct-2026; lo ejecuta una tanda autónoma autorizada por
ella.

## Lo que cambió desde la versión 1

| Decisión v1 | v2 | Por qué |
|---|---|---|
| 1. Atlas propio con empaquetador | **Sin atlas por ahora**; piezas sueltas | En la demo los draw calls (~43-70) no eran el límite del S50: el límite es el relleno (px pintados). Un atlas no lo baja. Se mide de nuevo si una sala pasa de ~150 draw calls |
| 2. Luz: arte oscurecido + halos aditivos chicos | Se confirma, con la oscuridad como `CanvasModulate` (no una capa encima) y luces 2D opcionales en Recursos alto | Velo como capa: −2,2 FPS; halos chicos: dentro del ruido; luces 2D: 52 → 7-10 FPS en el S50, 60 en el S20 |
| 3. Mipmaps con 8 px de separación | Mipmaps sí; la separación ya no aplica (sin atlas) | — |
| 4. Columnas sin colisión | Se queda | — |
| 5. Borde derecho: pared provisional | Se queda | — |
| H3 empaquetador | Se quita | Ver decisión 1 |

## Lo medido que manda (S50, Mali-T820, Compatibility)

- El límite es el **relleno**: cada capa a pantalla completa se pinta entera. Partículas (13 emisores, ~100
  partículas) y draw calls no pesan (< 1 FPS).
- Las 9 optimizaciones juntas llevaron la sala de 19 a 52,6 FPS quieto; solas casi no se notan: se miden combinadas.
- **Recorte de fondos al borde de la pared** (25-oct): +7 FPS donde se ve el fin de la pared, +2,6 en el recorrido.
- Bajar la resolución de fondos o del frente: 0 FPS (no cambia los px pintados). Sí baja memoria de video y peso del
  APK si se exporta ya reducido.
- Niebla: −2 a −4 FPS donde se ve. Viñeta: −5 FPS (decidido sin viñeta).
- El mundo dibujado a 75 % en un `SubViewport`: +1,4 FPS sobre el recorte; descartado (pide sacar HUD y controles de
  la sala).

## Decidido por la persona (24 y 25-oct-2026)

- Arte, video del menú y cinemática aprobados. Sin viñeta. Hueco con varillas v2 (foso de ~190 px).
- Fondos (capa media, lejanas, profundo) a **baja** resolución: ½, ¼ y ⅛, exportados ya reducidos; no es una opción
  del jugador. Siluetas del frente también reducidas al exportar (casi negras, como el primer plano de Hollow Knight).
- Niebla apagada por omisión, como opción en Avanzado (`nucleo-ajustes-avanzados`).
- Luces 2D solo en Recursos alto, encendidas por omisión ahí; en bajo no se ofrecen.
- **Grieta con raíces como foso** (25-oct; el arte empieza en x ≈ 3350 y el foso va de 3685 a 3875, bajo la
  luz de los hongos): las raíces son arte y no dañan; caer al fondo es un peligro
  (quita una vida y devuelve al último suelo firme, como las varillas). Hay que saltarla.
- Cada pieza de sala se hace para que **las salas siguientes la usen sin código propio** (25-oct): los compañeros
  arman las demás salas.

## Piezas reutilizables (en `nucleo/`, cada una un nodo que se coloca en el editor)

La demo hizo todo en código en un archivo de 1102 líneas. Aquí cada efecto es un nodo con `@export`: una sala nueva
los coloca y ajusta en el editor, sin escribir código. Lo que solo tiene La Celda queda en su script.

| Pieza | Qué hace | Lo que configura la sala | Base en la documentación |
|---|---|---|---|
| `FondoTapado` (`Control` con `clip_contents`) | Sus hijos (las capas `Parallax2D` de atrás) se ocultan mientras la vista cae entera dentro de la pared opaca, y se recortan al borde de la pared cuando la vista lo cruza | `fin_pared`: dónde acaba la pared opaca (un solo tramo: hay un caso, La Celda; una lista de tramos sería generalizar antes de tiempo) | `classes/class_control.rst:1616` (clip de hijos al rectángulo) |
| `LuzSala` (`Node2D`) | Halo aditivo chico y sin sombreado (la oscuridad no lo apaga), la imagen «encendida» opcional y su hueco en la oscuridad; crea en código su `PointLight2D` solo con luces avanzadas; parpadeo, pulso o destello con tiempo propio (quieto en la pausa, como `Planta`) | radio, color, `intensidad`, tipo (fija, parpadeo, pulso, destello), imagen encendida | `tutorials/2d/2d_lights_and_shadows.rst:372-387` (sprites aditivos más rápidos que luces) |
| Oscuridad de la sala | Nuevo `@export var oscuridad` en `Sala`: el `CanvasModulate` de `Brillo` multiplica brillo × (1 − oscuridad); uno solo por canvas | `oscuridad` (La Celda: 0,58) | `classes/class_canvasmodulate.rst:25` |
| `Niebla` (ya existe) | Se le agrega el desvanecido arriba y abajo de la demo (banda sin orillas) y obedece la opción de niebla al momento | lo de hoy | — |
| `Colgante` (`Node2D`) | Cable o cadena que se mece como resorte; el jugador lo empuja al pasar debajo | fuerza, amortiguación, empujable | — |
| `EmisorRafaga` (`CPUParticles2D`) | Ráfagas cada N a M segundos (chispas, piedritas), con tiempo propio | intervalo, cantidad | `classes/class_cpuparticles2d.rst` (`restart`) |

- Las piezas leen `Recursos` y los ajustes al entrar y escuchan el cambio de un ajuste (señal del bus, en
  `nucleo-ajustes-avanzados`) para luces y niebla.
- `Colgante` y `EmisorRafaga` son genéricas por naturaleza (un nodo que se coloca), no un sistema; la regla «no se
  generaliza hasta tener tres casos» se respeta en lo demás: los papeles que vuelan al correr junto a una pila y
  las esporas quedan en el script de La Celda.
- El panel de desarrollo (`nucleo-ajustes-avanzados`) encuentra estas piezas por grupo: una sala nueva tiene sus
  interruptores sin código.

## Arte

- Entra ya procesado y aprobado, con su línea en `docs/uso-de-ia.md`. El script que recorta y hornea el arte vive con
  los originales, fuera del repo (lee material que no entra); en el repo queda la **receta** en `docs/contrato.md`
  «Recursos»: fondos a ½, ¼ y ⅛ con la escala compensada en la escena; luces recortadas a su zona útil con su
  desplazamiento; capas con mucha transparencia como malla hecha en el editor; frente a ½.
- En `contenido/salas/celda/arte/`, en snake_case. Ninguna textura de más de 2048 px. Mipmaps.
- La demo reducía, recortaba y armaba mallas al cargar: aquí nada de eso pasa en ejecución.

## Pasos

| Paso | Qué | Se comprueba con |
|---|---|---|
| C1 | Sala gris: `contenido/salas/celda/celda_1.tscn` con `Sala`, `Entrada`, `limites`, colisión invisible (suelo con el foso de las varillas y el de la grieta, pared izquierda, pared provisional derecha), los dos peligros, el banco | `validar.ps1`; guiones `celda_hueco`, `celda_salto` y uno nuevo de la grieta (cae, pierde una vida, vuelve al suelo firme; con salto la cruza) |
| C2 | Piezas: `FondoTapado`, `LuzSala`, oscuridad en `Sala`, banda de `Niebla`, `Colgante`, `EmisorRafaga` | Pruebas de lo que puede romperse: el cálculo del recorte (tramo, vista) y el parpadeo con tiempo propio |
| C3 | Fondos, frente y piezas del plano de juego con el arte procesado | Captura a 1280×720, 1920×1080 y 2560×1440 |
| C4 | Luces, partículas, cables y niebla de La Celda | FPS en el S50 (bajo) y el S21 (alto) con el panel de pruebas y `--print-fps` (el modo automático quedó diferido) |
| C5 | Validador: presupuesto nuevo y lo que la sala obliga | `validar.ps1` (ver «Validador») |
| C6 | Prueba de la persona: recorrer la sala en el S50 y el S20 | Manual |

## Validador y contrato (pasa por el `revisor`)

- Emisores: de 3 emisores y 60 partículas a **16 emisores y 200 partículas** por sala (la demo: 13 y ~100, < 1 FPS en el
  S50).
- Luces 2D: sigue «ninguna en la escena». `LuzSala` las crea en código solo con la opción; así una sala no puede
  traerlas encendidas en el S50.
- Capas translúcidas grandes: se queda en 2; la niebla en banda y los halos chicos no llegan al cuarto de pantalla
  (se comprueba con La Celda).
- `docs/contrato.md` «Recursos»: la receta de arte, el recorte y la regla «medir combinado en el S50».

## Hecho (tanda del 25-oct-2026)

| Paso | Resultado |
|---|---|
| C1 | `celda_1.tscn` con la geometría de la demo: suelo en y=560, foso de varillas 1571-1757, foso de la grieta 3685-3875, banco en x ≈ 2966. Guiones `contenido/celda_salto` (cruza los dos sin daño), `celda_hueco` y `celda_grieta` (cae, un golpe, vuelve al suelo firme antes de la orilla) y `celda_banco` (descansa y guarda `celda_1`). Índice del mapa regenerado |
| C2 | Las seis piezas en `nucleo/`; prueba `nucleo/piezas_sala` (25 casos desde el arreglo de la luz fija), probada con mutaciones. `Colgante` se mece en `_physics_process` (la demo, por cuadro, iba al doble a 120 FPS). `EmisorRafaga` gana la señal `disparado` |
| C3 | 40 PNG procesados fuera del repo con la receta del contrato; la escena la armó un generador de una sola vez, también fuera del repo (la escena queda como fuente y se edita en el editor). Capturas a las tres resoluciones: iguales a la demo. Una línea en la orilla de la capa media (la tira repetida mezclaba su fila de abajo con la de arriba) se arregló con filas transparentes al pie, y quedó como regla en la receta |
| C4 | 7 `LuzSala`, 6 `Colgante`, 3 `EmisorRafaga`, la niebla en banda; 13 emisores y ~101 partículas. APK de desarrollo: S50 con Recursos automático (bajo), media 59,4 FPS (mín. 58); S50 con Recursos en alto (luces 2D), ~10,8; S21 en alto a 120, media 119,8 (mín. 119) |
| C5 | Presupuesto 16 emisores / 200 partículas en el validador y el contrato |
| C6 | Pendiente: la persona |

- Lo propio de La Celda está en `celda_1.gd`: polvo de pies, papeles al pasar corriendo junto a una pila y el rebote
  de las piedritas.
- `contenido/funciones.json`: cuatro entradas (sala, cinemática y sus pruebas en el teléfono), aprobadas por la
  persona el 25-oct-2026. La partida nueva empieza en la cinemática y sigue a La Celda; continuar sin banco va a La
  Celda (como Hollow Knight; el archivo nace con el primer guardado). La caja gris se quitó. `posicion_mapa` de
  `celda_1` en (0, 1440), fuera de la franja de la zona de pruebas.

## Lo que solo la persona puede confirmar

- Cómo se ven en el S50 y el S20: fondos a baja, el recorte caminando, la grieta como foso, las luces 2D en alto.
- La sensación del salto sobre los dos fosos.
- Que en el S50 las luces 2D en alto (~10 FPS) sigan valiendo como opción: hoy Recursos en alto se elige a mano y avisa
  de gama baja.
