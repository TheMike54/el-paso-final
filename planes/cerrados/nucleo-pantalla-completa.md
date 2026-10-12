CERRADO

# Núcleo: pantalla completa, sin bordes grises, en cualquier teléfono o tableta

Pedido por la persona el 07-oct-2026: el juego debe verse bien en todas las pantallas Android, no solo en el S20
(no se sabe con qué equipo lo probará el profesor). Idea inicial de la persona: «un zoom» que llene la pantalla
recortando lo que sobre. Solo plan: no se programa hasta que la persona lo apruebe. La solución es una fórmula
calculada al ejecutar con el tamaño real de la pantalla, no una lista de equipos.

## 1. Lo que hay (leído el 07-oct-2026)

- `project.godot`: vista base 1280×720, `stretch/mode = canvas_items`, `aspect = expand`, horizontal (`orientation=4`).
  Con `expand`, la vista crece en el eje que sobra: alto 720 si la pantalla es más ancha que 16:9 (ancho = 720 ×
  proporción) y ancho 1280 si es más cuadrada (alto = 1280 / proporción).
- Cámara: desde el 07-oct-2026 el jugador la mueve a mano (`planes/cerrados/nucleo-auditoria-hollow-knight.md`). Si la
  vista es mayor que la sala en un eje, la centra; lo que sobra se ve por igual a los dos lados.
- Salas: `limites` de cada `.tscn`. Sin nodo `Fondo` (toda la sala se ve con el color de borrado gris de Godot):
  `sala_banco`, `sala_combate`, `sala_movimiento`, `sala_peligro`, `sala_puerta_a`. La caja gris tampoco tiene fondo.
- Interfaz: el menú y la pausa usan anclas de pantalla completa (`anchors_preset = 15`); la pausa centra su caja.
  Botones táctiles: centros en fracción de una pantalla 16:9 y radios en fracción del lado corto (Saltar 0,085;
  Atacar, Curar e Impulso 0,07; Pausa, Mapa y Mochila 0,05; joystick 0,12).

## 2. Visto en el S20 (07-oct-2026, APK de la noche anterior)

Pantalla 2400×1080 (20:9; ajuste de resolución del teléfono, la física es 3200×1440). Capturas en el scratchpad de
la sesión, no en el repo. El juego llena la pantalla de borde a borde: no hay barras negras ni del sistema.

| Pantalla | Qué se ve | Causa |
|---|---|---|
| Menú, zona de pruebas, pausa | Sin gris: el fondo cubre todo | — |
| Caja gris | Toda gris (es su diseño: no tiene fondo) | (d) color de borrado |
| `sala_pared`, `sala_puerta_b` (1280 de ancho) | Franjas grises de 240 px físicos a cada lado; Pausa, Mapa y Mochila quedan sobre la franja derecha | (a) fuera de los límites: vista 1600, sala 1280; (1600 − 1280) / 2 × 1,5 = 240 |
| `sala_combate` | Toda la sala gris, con una pared oscura | (d) sala sin `Fondo` |

Simulado con `wm size` en `sala_puerta_b` (restaurado a 1080×2400 al terminar):

| Proporción simulada | Cálculo | Visto |
|---|---|---|
| 16:10 (1728×1080) | vista 1280×800; (800 − 720) / 2 × 1,35 = 54 px arriba y abajo | 54 arriba; abajo lo tapa el dibujo del piso, que pasa del límite |
| 4:3 (1440×1080) | vista 1280×960; 120 × 1,125 = 135 px arriba y abajo | 135 arriba; abajo, piso y gris |
| 22:9 (2640×1080) | vista 1760×720; (1760 − 1280) / 2 × 1,5 = 360 px a cada lado | 360 a cada lado |
| 21:9 (2520×1080) | vista 1680×720; 200 × 1,5 = 300 px a cada lado | captura tomada, sin revisar a detalle |

Causas: (a) lo de fuera de los límites, (d) salas sin fondo. No se vieron (b) barras negras del estirado ni (c)
barras del sistema o recorte de cámara: el S20 tiene la cámara en un agujero centrado arriba (en horizontal, a un
lado) y el juego dibuja debajo; ningún botón quedó encima en las capturas, sin comprobarlo con el área segura.

## 3. Píxeles de vista fuera de la sala (gris), por sala y proporción

Vista: 16:9 → 1280×720 · 19,5:9 → 1560×720 · 20:9 → 1600×720 · 21:9 → 1680×720 · 22:9 → 1760×720 · 16:10 →
1280×800 · 3:2 → 1280×853 · 4:3 → 1280×960 · plegable abierto (≈ 1,2:1) → 1280×1067. «a» = a lo ancho (total de
los dos lados), «h» = a lo alto.

| Sala (`limites`) | 16:9 | 19,5:9 | 20:9 | 21:9 | 22:9 | 16:10 | 3:2 | 4:3 | 1,2:1 |
|---|---|---|---|---|---|---|---|---|---|
| `camara`, `capas` (3200×1440) | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `caida`, `picada` (1600×1200) | 0 | 0 | 0 | 80 a | 160 a | 0 | 0 | 0 | 0 |
| `impulso`, `peligro` (2400 o 2000 × 940) | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 20 h | 127 h |
| `movimiento` (2400×760) | 0 | 0 | 0 | 0 | 0 | 40 h | 93 h | 200 h | 307 h |
| `combate`, `enemigos`, `pogo`, `puerta_a` (≥ 2000×720) | 0 | 0 | 0 | 0 | 0 | 80 h | 133 h | 240 h | 347 h |
| `banco`, `bola`, `curar`, `doble_salto`, `enemigos_banco`, `golpe` (1600×720) | 0 | 0 | 0 | 80 a | 160 a | 80 h | 133 h | 240 h | 347 h |
| `pared` (1280×1440) | 0 | 280 a | 320 a | 400 a | 480 a | 0 | 0 | 0 | 0 |
| `puerta_b` (1280×720) | 0 | 280 a | 320 a | 400 a | 480 a | 80 h | 133 h | 240 h | 347 h |

Lo más difícil del rango: lo más cuadrado. Una tableta 4:3 o un plegable abierto piden salas de 960 a 1067 de
alto; hoy casi todas miden 720.

## 4. Familias de pantalla y rango que se soporta

| Familia | Ejemplo (fuente en la sección 9) | Resolución | Proporción en horizontal |
|---|---|---|---|
| Teléfono 16:9 | Galaxy J2 Core [1] (dato de un resumen de búsqueda, sin ficha leída) | 960×540 | 1,78 |
| Teléfono 19,5:9 | Xperia 1 VI [2] | 2340×1080 | 2,17 |
| Teléfono 20:9 | Galaxy S20 [3]; Pixel 9 Pro Fold cerrado [6] | 3200×1440; 2424×1080 | 2,22 |
| Teléfono 21:9 | Xperia 10 VI [4] | 2520×1080 | 2,33 |
| ≈ 22:9 | Z Fold6 cerrado [5] (proporción calculada, sin teléfono «normal» 22:9 confirmado) | 2376×968 | 2,45 |
| Plegable abierto | Z Fold6 [5]; Pixel 9 Pro Fold [6] | 2160×1856; 2152×2076 | 1,16; 1,04 |
| Tableta 16:10 | Galaxy Tab S9, 11" [7]; Tab S10 Ultra, 14,6" [8] (el ejemplo de la persona) | 2560×1600; 2960×1848 | 1,6 |
| Tableta 5:3, 8" | Galaxy Tab A9, 8,7" [9] | 1340×800 | 1,67 |
| Tableta 3:2 | Xiaomi Pad 7, 11,2" [10] (noticia, no ficha) | 3200×2136 | 1,5 |
| Tableta 4:3 | sin ficha confirmada de un Android actual | — | 1,33 |

Recortes de cámara: con targetSdk 35 o más, Android 15 dibuja la app de borde a borde y bajo el recorte, sin
poder excluirse con targetSdk 36 [11][12][13]; el S20 lo confirma (el juego llena 2400×1080).

Rango propuesto: de 4:3 (1,33) a 22:9 (2,45). Fuera de él (plegables abiertos, casi cuadrados) el juego no se rompe:
se ven más px del fondo extendido o, si se acaba, barras del color del fondo. Riesgo nuevo [12]: con targetSdk 36,
en pantallas de 600 dp o más Android 16 ignora la orientación fija, así que en una tableta o un plegable el juego
puede recibir una ventana vertical (proporción < 1). Hay una propiedad para posponerlo; sin comprobar en Godot.

## 5. Opciones

| Opción | Qué hace | Costo | Riesgo | Archivos |
|---|---|---|---|---|
| O1. Tamaño mínimo de sala | Toda sala mide al menos 1760 de ancho y 960 de alto (el rango de 22:9 a 4:3) | Bajo en código; alto en diseño: cada sala crece y, en las chicas, sobra espacio vacío | Una sala estrecha a propósito (un pozo) no puede existir | `docs/contrato.md` («Sala»), cada `.tscn`, el validador de contenido (regla nueva) |
| O2. Fondo más allá de los límites | Cada sala pinta su fondo (color o arte) varios cientos de px fuera de `limites`, y la cámara puede mostrarlo | Bajo: un `Fondo` más grande o un `ColorRect` en una capa | En una sala angosta se ve «fondo vacío» a los lados; si el arte es una pared, puede verse falso | `sala.gd` (crear el fondo extendido), contrato |
| O3. «Zoom» que llena recortando | Al ejecutar, `Camera2D.zoom = max(vista.x / sala.x, vista.y / sala.y, 1)` solo en las salas más chicas que la vista; o `aspect = keep_height` | Bajo en código | Con zoom, todo se ve más grande y se pierde campo visual; en 4:3 con una sala de 720 de alto, zoom 1,33: de una vista de 1280×960 se ve el equivalente a 960×720 (se pierde el 25 % del ancho que vería un 16:9). `keep_height` en 4:3 deja la vista en 960×720: misma pérdida, para todas las salas | `jugador.gd` (`_objetivo_camara`), `project.godot` si se cambia el estirado; los guiones que dependen de la vista sin pantalla (1280×1280) |
| O4. Área garantizada | Se diseña para 1280×720 (lo que se ve siempre); lo que sobra según la pantalla muestra más sala, nunca gris (O1 u O2) | Medio: una regla de diseño, no código | Nada importante (puertas, peligros) puede quedar solo fuera del área garantizada | contrato, `docs/pruebas.md` |
| O5. Combinación | Ver la recomendación | — | — | — |

Por clase de equipo, con `expand` y O2 + O4: un teléfono (19,5:9 a 22:9) ve más a lo ancho; una tableta 16:10 a
4:3 ve más a lo alto; un plegable abierto, aún más alto (fuera del rango: barras del color del fondo).

Interfaz y botones: hoy los radios son fracción del lado corto, así que en una tableta de 14" los botones miden
el triple que en el S20 y quedan lejos de los pulgares (los centros son fracción de la pantalla). Propuesta: radio
en milímetros físicos con un mínimo de 48 dp [18] (`DisplayServer.screen_get_dpi()`), centros a una distancia fija de
las esquinas, y la interfaz dentro del área segura (`DisplayServer.get_display_safe_area()` [14], en coordenadas de la pantalla física). Solo se puede razonar:
el S20 no simula otro DPI sin `wm density`, que no se usó.

## 6. Decisión y lo aplicado (07-oct-2026)

La persona eligió la alternativa D (sección 9): el mismo rango, de 4:3 a 22:9, en escritorio, teléfono y tableta.

| Qué | Estado | Medido |
|---|---|---|
| D: rango de la vista | Aplicado: `nucleo/vista.gd` (cuenta pura) y `nucleo/arranque.gd` (la aplica al arrancar y en `size_changed`, solo con pantalla) | En ventana: 20:9 y 22:9 sin barras; 32:9 → vista 1760×720 y 0,78:1 → 1280×960, con barras. Cambiar el tamaño en ejecución también recorta. Fuera del rango `size_changed` llega 3 veces y se detiene (sin bucle). Con la ventana real (maximizar, restaurar, ráfagas, con pausa), ajustar dentro de la señal dejaba la imagen con la vista anterior: ahora se ajusta diferido (`docs/errores/2026-10-07-vista-vieja-al-maximizar.md`) |
| Color de las barras | Medido: las barras del motor son negras siempre; el gris era el color de borrado | Captura de la pantalla real con `DisplayServer.screen_get_image` |
| Color de borrado negro | Aplicado en `Arranque` | El gris de fuera de las salas y el fondo de las salas sin `Fondo` pasan a negro; la caja gris y la sala de combate siguen legibles; la barra de Inspiración, oscura, se ve menos |
| O2/O4: fondo extendido | Aplicado en `nucleo/sala.gd` (`FondoExtendido`, 280 px: 240 del rango más el temblor, observación del `revisor`) | `sala_puerta_b` a 20:9, 22:9 y 4:3: sin borde fuera de la sala; `sala_capas` (Fondo oculto): el parallax intacto |
| Guiones | Sin cambios: 70 de 70 iguales; nuevo `vista.guion` | Sin pantalla la D no se aplica: la vista sigue en 1280×1280 y el medidor en 1600×720 |
| Botones en tamaño físico y área segura | Reemplazado (persona, 07-oct-2026) por los botones táctiles configurables, con su propio plan; el área segura pasa a ese plan (posiciones por omisión dentro de ella) | — |
| `min_size` de la ventana | No se hace: era opcional y la D ya evita la ventana ilegible por proporción | — |
| S20 | La persona confirmó el 07-oct-2026 en `sala_puerta_b` que el fondo llega a los bordes, sin gris | A mano |

Cerrado el 11-oct-2026: la persona maximizó, restauró y arrastró la ventana de la PC con el arreglo de `size_changed`
el 07-oct-2026 y pasa (caso «Ventana en la PC» de `docs/pruebas.md`). La prueba con `wm size` en el S20 (caso
«Pantalla completa en el teléfono») queda como opcional, fuera de este plan.

## 7. Cómo se comprueba

`vista.guion` prueba la cuenta. Lo que se ve (barras, fondo extendido, botones dentro de la imagen) es manual, en el
S20 con `wm size` y en la ventana de la PC (`docs/pruebas.md`). Solo en un equipo real: el recorte de cámara, las
esquinas redondeadas, el tamaño físico de los botones y la bisagra de un plegable.

## 9. Ventana de escritorio

Otra clase de pantalla: en Windows la ventana se redimensiona libre. Visto por la persona el 07-oct-2026 en dos
capturas: una ventana de ~0,78:1 en `sala_camara`, con gris arriba y abajo y los corazones sobre la banda gris
pegados al borde de la ventana (lo que vería una tableta en vertical si Android 16 ignora la orientación), y una de
~6,5:1, con franjas grises a cada lado y los corazones en la esquina, lejos de la zona de juego.

Medido en una copia del repo (Godot 4.7.2, `--windowed --resolution`, imagen de la vista), coincide con la sección 3:

| Ventana | Vista | `sala_curar` (1600×720) | `sala_camara` (3200×1440) |
|---|---|---|---|
| 4:3 (1024×768) | 1280×960 | 120 de vista arriba y abajo (96 px en pantalla) | 0 |
| 16:9 · 16:10 · 21:9 | 1280×720 · 1280×800 · 1680×720 | 0 · 40 arriba y abajo · 40 a cada lado | 0 |
| 32:9 (1920×540) | 2560×720 | 480 de vista a cada lado (360 px) | 0 (2560 < 3200) |
| 0,78:1 (780×1000) | 1280×1641 | 460 arriba y abajo | 100 arriba y abajo; el techo y el piso, del mismo gris, la hacen ver de 141 |

Mecanismos de Godot (documentación de `master` [19][20][21]; cada uno probado en la copia 4.7.2): no hay una opción
para limitar la proporción de la ventana. Sí funcionan, cambiados desde un script al ejecutar: `content_scale_aspect`
y `content_scale_size` de la ventana (fuera de un rango, con `KEEP` y el tamaño de la proporción límite: a 32:9 la vista
queda en 1760×720 y a 0,78:1 en 1280×960, con barras); `min_size` (limita el tamaño, no la proporción); asignar
`size` a la ventana desde la señal `size_changed` (1920×540 pasa a 1320×540). El override por plataforma también
funciona: `window/stretch/aspect.pc="keep"` deja la vista en 1280×720 en Windows. Sin probar: `max_size`, arrastrar el
borde con la corrección de tamaño activa, y el color de las barras (medido después: negras, sección 6).

| Alternativa | Qué hace | Costo y archivos | Riesgo |
|---|---|---|---|
| A. 16:9 fijo con barras | `aspect.pc="keep"` | Una línea en `project.godot` | Desperdicia pantalla en monitores anchos; distinta del teléfono |
| B. Rango de la ventana (propuesta de la persona) | Corregir el tamaño de la ventana para que su proporción quede en el rango | ~15 líneas en un autoload | Solo existe en escritorio (el teléfono no se redimensiona); maximizada o a pantalla completa no se puede imponer; el arrastre, sin probar |
| C. Ventana libre con fondo extendido o zoom | O2/O3 del plan | Ver la sección 5 | En 32:9 los corazones quedan lejos del juego; la vertical no se resuelve |
| D. Rango de la vista | Dentro de 4:3 a 22:9, `expand`; fuera, la vista se recorta a la proporción límite con barras | ~15 líneas en un autoload existente, sin tocar `project.godot` | Ninguno medido: las barras salen negras |

Recomendación, que la persona eligió el 07-oct-2026 (sección 6): **D**, con el mismo rango que el teléfono (4:3 a
22:9), y `min_size` opcional (p. ej. 640×360) para que la ventana no quede ilegible. Logra lo que busca la B (que esas dos capturas no se vean) con
una sola regla para escritorio, teléfono y tableta: también cubre la tableta que recibe una ventana vertical, y sigue
valiendo con la ventana maximizada en un monitor 32:9 o a pantalla completa. El 21:9 de la propuesta era un ejemplo;
si se elige B, su rango debe ser el mismo del plan.

Interfaz: los corazones y los botones se anclan a la vista. Con `expand` dentro del rango la vista es toda la ventana;
con D, fuera del rango, la vista es la zona recortada y las barras quedan fuera, así que la interfaz queda sobre el
juego en las dos clases de pantalla. Que en una sala angosta los corazones caigan sobre gris es de la sala (O2/O4).

Las barras resultaron negras (sección 6).

## 10. Fuentes (consultadas el 07-oct-2026; lo de Godot es de la documentación `latest` o de la rama 4.5, no de 4.7)

[1] https://m.gsmarena.com/samsung_galaxy_j2_core-9255.php · [2] https://gsmarena.com/sony_xperia_1_vi-review-2699.php ·
[3] https://www.gsmarena.com/samsung_galaxy_s20-10081.php · [4] https://m.gsmarena.com/sony_xperia_10_vi-13002.php ·
[5] https://m.gsmarena.com/samsung_galaxy_z_fold6-13147.php · [6] https://m.gsmarena.com/google_pixel_9_pro_fold-13220.php ·
[7] https://m.gsmarena.com/samsung_galaxy_tab_s9-12439.php · [8] https://m.gsmarena.com/samsung_galaxy_tab_s10_ultra-13362.php ·
[9] https://m.gsmarena.com/samsung_galaxy_tab_a9-12616.php ·
[10] https://m.gsmarena.com/xiaomi_pad_7_and_pad_7_pro_debut_with_112inch_144_hz_32k_display-amp-65126.php ·
[11] https://developer.android.com/about/versions/15/behavior-changes-15 ·
[12] https://developer.android.com/about/versions/16/behavior-changes-16 ·
[13] https://developer.android.com/develop/ui/views/layout/edge-to-edge ·
[14] https://docs.godotengine.org/en/latest/classes/class_displayserver.html (`get_display_safe_area`, `get_display_cutouts`: Android) ·
[15] https://docs.godotengine.org/en/latest/tutorials/rendering/multiple_resolutions.html (modos de estirado) ·
[16] https://docs.godotengine.org/en/latest/classes/class_camera2d.html (`zoom`) ·
[17] https://raw.githubusercontent.com/godotengine/godot/4.5/platform/android/export/export_plugin.cpp (`screen/immersive_mode` true y `screen/edge_to_edge` false por omisión) ·
[18] https://m3.material.io/foundations/designing/structure (48 dp mínimo; solo el extracto) ·
[19] https://raw.githubusercontent.com/godotengine/godot/master/doc/classes/Window.xml (`min_size`, `max_size`, `content_scale_*`) ·
[20] https://raw.githubusercontent.com/godotengine/godot-docs/master/tutorials/rendering/multiple_resolutions.rst (sin opción para limitar la proporción; `content_scale_*` cambia al ejecutar) ·
[21] https://raw.githubusercontent.com/godotengine/godot-docs/master/tutorials/export/feature_tags.rst (overrides `ajuste.tag`; tags `pc`, `mobile`, `windows`, `android`)

Sin confirmar: una tableta Android 4:3 actual; qué hace `screen/edge_to_edge` en 4.7 y si cambia el área segura;
cómo se comporta Godot con la orientación ignorada en 600 dp; las medidas físicas de la Tab S10 Ultra.
