---
name: ui-tactil
description: Reglas de interfaz táctil de este proyecto (Godot 4.7.2). Usar antes de crear o cambiar un menú, una página del marco, el HUD, Tema, ControlesTactiles, una capa CanvasLayer o cualquier Control dibujado a mano o armado en código.
---

# Interfaz táctil en este proyecto

Citas a `$env:GODOT_DOCS` como `archivo:línea`; «Cómo se comprueba» dice cómo revisar la regla. Lo demás se busca
con Grep ahí (rutas `tutorials/...`) y se cita igual. Los números (alto de toque, letras, márgenes, capas) no se
repiten aquí: viven en `nucleo/tema.gd` y en `docs/contrato.md` («Menú», «Marco de menús», «Capas de dibujo»).

Como `validar.ps1` no ejecuta `_ready` (`CLAUDE.md` raíz, «Entorno y trampas»), el acomodo, el foco, las capas y el
toque los comprueba un guion o una prueba manual en el teléfono.

## Tema y variaciones

| Regla | Doc | Cómo se comprueba |
|---|---|---|
| El tema de los menús es `Tema.crear()` (un solo objeto) y va en el primer `Control` de cada rama de UI (`pausa.gd` `_panel`, `marco_menus.gd` `barra`, `pagina_inventario.gd` `fondo`), nunca en el `CanvasLayer` (un nodo que no es `Control` corta la búsqueda del tema) ni en `project.godot`; el HUD queda fuera a propósito (cabecera de `nucleo/tema.gd`) | `tutorials/ui/gui_skinning.rst:203`, `:230` | Guiones `marco`, `pausa_foco`, `menu_configuracion`; Grep de `theme` en `project.godot`: sin resultados |
| Un aspecto que comparten varios controles es una variación de tipo del tema, no un override repetido en cada nodo; ejemplo vivo: `Tema.BARRA_ANCHA` | `tutorials/ui/gui_theme_type_variations.rst:14` | Guion `menu_configuracion` |
| La variación se registra con `tema.set_type_variation(NOMBRE, &"Clase")`, define solo lo que cambia y su nombre va en una constante `StringName` de `Tema` | `tutorials/ui/gui_theme_type_variations.rst:28`, `:52`, `:72` | Grep de `set_type_variation` en `nucleo/tema.gd` |
| Se aplica con `control.theme_type_variation = Tema.NOMBRE` (vacía = solo el tipo base) | `tutorials/ui/gui_theme_type_variations.rst:66` | Grep de `theme_type_variation`; guion `menu_configuracion` |
| `add_theme_*_override` solo para acomodo (separaciones, márgenes); el aspecto sale del tema | `tutorials/ui/gui_skinning.rst:172`, `tutorials/ui/gui_containers.rst:98` | Grep de `add_theme_` en el archivo cambiado: solo separaciones y márgenes |
| Un `Control` propio bajo una raíz de menú lee fuente, tamaño y stylebox con `get_theme_*` (ejemplo: `nucleo/boton_valor.gd`, `_draw`) | `tutorials/ui/gui_skinning.rst:36` | Guion `menu_configuracion` |
| El stylebox `focus` es la marca de gis (`EstiloGis`, `nucleo/estilo_gis.gd`, un `StyleBox` con `_draw`): flechita y subrayado, en las barras una caja; se dibuja encima de `normal` o `pressed`, que no tienen caja. Un `StyleBox` no conoce el texto del botón: el subrayado cruza el contenido, así que en una columna el botón mide lo que su texto (`size_flags_horizontal` = 0). El foco se da con `Tema.dar_foco(control)`, nunca con `grab_focus()` directo: se dibuja solo si lo último que se usó fue un control o el teclado (`UltimaEntrada.con_control()`); tras un toque se da oculto. Colores y marcas del foco: contrato, «Menú»; lo lleno de las barras usa `Tema.ENCENDIDO`. Un botón con contenido propio (ficha, caja de diálogo) usa la variación `Tema.TARJETA`, o queda un hueco sin caja | `tutorials/ui/gui_skinning.rst:92` | Guiones `pausa_foco`, `menu_configuracion`; prueba manual con teclado o control |
| Un `Control` propio que puede tomar el foco muestra un indicador; el que no debe tomarlo lleva `focus_mode = Control.FOCUS_NONE` (`nucleo/caja_dialogo.gd`) | `tutorials/ui/custom_gui_controls.rst:41` | Guiones `pausa_foco`, `dialogo` |
| El tamaño de letra va en el tema o en el nodo (`Tema.LETRA`, `Tema.LETRA_CHICA`, `Tema.LETRA_TITULO`), no en un recurso de fuente por tamaño. La fuente de los menús es Cabin Sketch (`Tema.RUTA_FUENTE`, gruesa en `Tema.TITULO`), cargada con `load()` al armar el tema: un `preload` hace fallar la primera importación de un clon limpio. Las medidas de `Tema` (`ALTO_LETRA`) son de esa fuente: al cambiarla se vuelven a medir con `get_height` | `tutorials/ui/gui_using_fonts.rst:20` | Prueba manual en el teléfono |

## Tamaño, anclas y contenedores

- Todo lo que se toca mide al menos `Tema.ALTO_TOQUE` de alto (`custom_minimum_size`); las cuadrículas usan
  `Tema.CELDA`, `Tema.SEPARACION` y `Tema.columnas()`. Un mínimo evita que el contenedor lo aplaste.
  — `tutorials/ui/custom_gui_controls.rst:78`. Guiones `menu_configuracion`, `ranuras`, `marco`.
- No mover ni dimensionar a mano un hijo de un `Container`: se pierde en el siguiente acomodo. `position` y
  `size` solo en controles cuyo padre no es contenedor (`nucleo/caja_dialogo.gd`, `Tema.ajustar`).
  — `tutorials/ui/gui_containers.rst:25`. Guion `dialogo`.
- Repartir el espacio con size flags (`SIZE_EXPAND_FILL`) y contenedores anidados, no con tamaños fijos.
  — `tutorials/ui/gui_containers.rst:35`, `:49`. Guion `ranuras`.
- Contenido que puede no caber en alto va en un `ScrollContainer` con `follow_focus = true` (`nucleo/ranuras.gd`);
  el arrastre táctil ya funciona. — `tutorials/ui/gui_containers.rst:161`. Guiones `ranuras`, `menu_configuracion`.
- Pantalla completa: `set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)`. `set_anchors_preset` solo
  cambia las anclas y deja el tamaño de creación (0×0): `docs/errores/2026-10-13-confirmacion-de-ranuras-en-la-esquina.md`.
  — `tutorials/ui/size_and_anchors.rst:55`. Guion `ranuras`.
- La interfaz se adapta a cada proporción con anclas o contenedores, no solo escalando; se prueba en ventanas
  4:3, 16:9 y 22:9. — `tutorials/rendering/multiple_resolutions.rst:615`, `tutorials/ui/size_and_anchors.rst:14`.
  Prueba manual.
- En el `_draw()` de un `Control` propio todo se mide contra `size` (`nucleo/boton_valor.gd`, `interfaz/hud.gd`);
  lo último que se dibuja queda encima. — `tutorials/ui/custom_gui_controls.rst:31`,
  `tutorials/2d/custom_drawing_in_2d.rst:492`. Guiones `controles_tactiles`, `vidas_e_inspiracion`.
- `Default Theme Scale` no se toca: el tamaño de los menús lo da `Tema`, y ese ajuste no cambia en ejecución.
  — `tutorials/rendering/multiple_resolutions.rst:304`. Grep de `default_theme_scale` en `project.godot`.
- No desactivar el oversampling de fuentes: mantiene el texto nítido con el estiramiento `canvas_items`.
  — `tutorials/rendering/multiple_resolutions.rst:562`. Grep de `gui/fonts` en `project.godot`.

## Área segura y coordenadas

- Un menú de pantalla completa se acomoda con `Tema.ajustar(control)` (una vez, en su `_ready`) o mide con
  `Tema.area_util(vista)`; nada pegado a las orillas ni al recorte de la cámara. — `tutorials/ui/creating_applications.rst:749`.
  Guiones `marco`, `menu_configuracion`; prueba manual en el teléfono.
- No leer `DisplayServer.get_display_safe_area()` directo: `DisposicionControles.area_segura(vista)` ya la pasa a
  coordenadas de la vista. Cambiar el modo inmersivo o «Edge to Edge» del preset cambia esa área.
  — `tutorials/ui/creating_applications.rst:751`. Guion `controles_tactiles`.
- Trabajar en coordenadas de la vista (`evento.position`, `get_viewport_rect().size`), no de pantalla.
  — `tutorials/2d/2d_transforms.rst:103`, `tutorials/inputs/mouse_and_input_coordinates.rst:24`. Guion `controles_tactiles`.

## Capas y pausa

- Todo lo que va fijo en pantalla (HUD, menús, controles táctiles) cuelga de un `CanvasLayer`; el número mayor
  queda encima. La capa sale de la tabla «Capas de dibujo» de `docs/contrato.md` y la constante `CAPA` del
  script; una capa nueva entra a esa tabla en el mismo cambio. Una página del marco va en la capa de las páginas,
  en el grupo `MarcoMenus.GRUPO_PAGINAS`, y deja libre la franja de `MarcoMenus.ALTO_BARRA` (contrato, «Marco de
  menús»). — `tutorials/2d/canvas_layers.rst:44`, `:46`. Grep de `CAPA` y `layer =` cotejado con la tabla del
  contrato; guion `marco`.
- Un menú que funciona con el juego detenido fija `process_mode` en su raíz y los hijos lo heredan. Aquí es
  `PROCESS_MODE_ALWAYS` (`nucleo/pausa.gd`, `nucleo/marco_menus.gd`): escuchan la acción que los abre con el
  juego andando. — `tutorials/scripting/pausing_games.rst:97`. Guiones `pausa`, `marco`.

## Entrada en la GUI

- Un `Control` que consume un evento llama a `accept_event()` en `_gui_input` o en la señal `gui_input`
  (`nucleo/configuracion.gd`, barras). — `tutorials/inputs/inputevent.rst:90-91`. Guion `menu_configuracion`.
- `mouse_filter` decide quién recibe el toque: fondos, etiquetas y decorados van en `MOUSE_FILTER_IGNORE`; un
  `Control` a pantalla completa en `STOP` se come los toques de los demás. — `tutorials/inputs/inputevent.rst:92`.
  Guiones `dialogo`, `controles_tactiles`.
- El teclado y el control solo llegan al `Control` con foco y no suben por el árbol: por eso cada pantalla hace
  `Tema.dar_foco()` en su primera opción y los menús leen acciones con `Input.is_action_just_pressed` en el tick
  (`nucleo/pausa.gd`, `nucleo/marco_menus.gd`). — `tutorials/inputs/inputevent.rst:136`. Guiones `pausa_foco`,
  `controles_configurables`.

## Texto

- El texto que puede crecer envuelve (`AUTOWRAP_WORD_SMART`) o se recorta con elipsis (`OVERRUN_TRIM_ELLIPSIS`);
  un teléfono angosto lo alarga igual que otro idioma. — `tutorials/i18n/internationalizing_games.rst:248`.
  Prueba manual en el teléfono.
- Sin emoji en los textos mientras ninguna fuente del proyecto los tenga: salen como cuadros. — `tutorials/ui/gui_using_fonts.rst:412`.
  Grep de emoji en `.gd` y `.tres`.
- Una fuente nueva se revisa en pantalla con acentos, ñ, ¿¡ y «»: la fuente por omisión solo cubre parte de
  Latin-1. — `tutorials/i18n/internationalizing_games.rst:142`. Prueba manual en el teléfono.

## Escena o código

- Lo que aparece durante el juego (proyectiles, enemigos, efectos) es una escena instanciada
  (`nucleo/jugador.gd`, `ESCENA_PROYECTIL`); los menús de piezas iguales se arman en código y lo dicen en su
  cabecera (`nucleo/ranuras.gd`, `nucleo/nueva_partida.gd`). — `tutorials/best_practices/scenes_versus_scripts.rst:192`, `:205`.
  Grep de `preload(` e `instantiate(` en el archivo nuevo; `validar.ps1`.
- Si un menú armado en código tarda en abrir: medir en el S50 antes de cambiarlo a escena.
