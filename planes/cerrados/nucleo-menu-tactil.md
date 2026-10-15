CERRADO

# Núcleo: menús cómodos con el dedo en un teléfono chico

Sale de la prueba en el Senwa S50 del 12-oct-2026: algunos botones cuestan con el dedo y el interruptor del modo
desarrollador no se nota. Propuesta revisada por la persona en una maqueta el 12-oct-2026 («me gusta lo que veo»),
con una condición: los botones no van pegados a las orillas, sino alineados y centrados con margen. Aprobado el
12-oct-2026 con las reglas del advisor de abajo; la persona tomó las recomendaciones (zona de pruebas al menú de
inicio, sin grupo «Habilidades») y decidió hacerlo antes del PR. Rama `feature/nucleo-menu-tactil`, sobre el commit
de `docs/limpieza-auditoria`.

## Medida de partida

- Vista 1280×720 (`canvas_items`, `expand`). En el S50 (480×960, densidad 240, leída con `adb shell wm density`) un
  px de la vista son 2/3 de px del teléfono: 48 dp de Android = 72 px del teléfono = **108 px de la vista**.
- Hoy: menú y pausa 72 px (32 dp), Configuración 64 px (28 dp), botones del control 52 px (23 dp, 6 px entre
  ellos), barras del editor de botones 48 px, zona de pruebas 64 px.

## Decisiones (12-oct-2026)

1. Todo lo que se toca mide al menos 108 px de alto (48 dp en el S50, el peor caso medido). El tema se arma en código
   (`nucleo/tema.gd`, `Tema.crear()`) y se asigna solo a las raíces de los menús (`Menu`, que lo hereda
   Configuración, `Pausa` y `ZonaPruebas`), no en `project.godot`: así no toca la interfaz del juego ni los
   controles táctiles (cambio del 12-oct-2026, con el advisor). La altura sale de los márgenes del `StyleBox`.
   Margen de 64 px a los lados y 16 arriba y abajo dentro del área segura (`Tema.area_util`): las cuadrículas se
   centran y no tocan las orillas.
2. Configuración en celdas de 420×108 (16 px entre columnas, 12 entre filas; 24 cortaba la columna izquierda en el
   S50, captura del 12-oct-2026): con letra de 36 el texto no cabía en
   360. Vibración, Temblor y Modo desarrollador siguen siendo `CheckButton` (toda la fila ya responde), con fondo
   visible y el estado en el texto: «Vibración: sí», «Temblor: no», «Desarrollador: sí».
3. Zona de pruebas: el interruptor se queda en Configuración, pero con el modo encendido la entrada aparece en el
   **menú de inicio** y sale de Configuración. Reabre la decisión del 11-oct-2026
   (`planes/cerrados/nucleo-modo-desarrollador.md`), cuyo motivo era no dejar el interruptor suelto en el menú: el
   interruptor no se mueve. «Volver» de la zona regresa al menú.
4. «Botones del control» siempre visible, con un aviso «Conecta un control…» que se actualiza con
   `Input.joy_connection_changed`; un botón de 420×108 por acción con su botón adentro («Saltar: A / Cruz»). Ocultarlo descartado: mueve
   la cuadrícula y pierde el foco al desconectar.
5. Menú y pausa a 480×108; confirmaciones (Salir, Borrar) a 300×108 con 64 px entre los dos botones.

## Reglas para todas las pantallas (revisión de UI/UX con el advisor, 12-oct-2026)

La maqueta ilustra la vista de 1280; la especificación son estas reglas, no posiciones en px. La vista mide de
1280 (4:3 y 16:9; en 4:3 crece a 960 de alto) a 1760 (22:9) de ancho (S50 1440, S20 1600).

1. Toque: todo lo que se toca mide al menos 108 px de alto (48 dp en el S50, el peor caso medido), también los
   elementos de la lista desplegable de Recursos (`PopupMenu` en el tema).
2. Texto: botones de al menos 36 px de la vista (16 dp en el S50); etiquetas de al menos 33
   (14 dp). La maqueta usaba 30 y 24: quedaban en 13 y 11 dp.
3. Columnas según el ancho útil (`Configuracion.columnas_para`): 2 en la vista de 1280 y 3 desde el S50 (1440); si
   no caben las filas, el contenedor se desplaza (en 16:9 la Configuración tiene 5 filas y se desplaza). Medido el
   12-oct-2026 en ventana: con `expand`, una pantalla 4:3 da una vista de 1280×960 (crece el alto), no 960×720;
   la vista mide de 1280 a 1760 de ancho. La fila de categorías de la zona, igual: se desplaza en
   horizontal o pasa a lista vertical si no cabe.
4. Margen: el del área segura de la pantalla (`get_display_safe_area` pasada a la vista, como los botones táctiles
   configurables), más un mínimo fijo; nada pegado a las orillas ni bajo la cámara.
5. «Volver» siempre en el mismo sitio en todas las pantallas (arriba a la izquierda, como la zona de pruebas), y
   Atrás hace lo mismo. «Borrar partida» lejos de «Volver».
6. Orden de Configuración por uso: Volumen, Vibración y Temblor primero; Borrar partida y Créditos al final.
   Volumen con «−» y «+» a los lados de la barra.

- «Por omisión» del panel del control pasa a decir «Restablecer» (texto; el nodo sigue siendo `PorOmision`): la
  persona no entendió qué hacía (prueba en el S50, 12-oct-2026), y lo aprobó.

- Fuera de esta fase, pendiente de decidir: el editor de botones táctiles. Su barra tapa el juego que se edita y a
  108 px por fila taparía más.

## Comprobación

- En ventana, la persona: `& $env:GODOT_PATH --path . --resolution <ancho>x720` con 960, 1280, 1440, 1600 y 1760:
  nada se sale, nada se encima, las columnas cambian y «Volver» sigue en su esquina. `--resolution` no cambia la
  vista en headless (medido el 12-oct-2026: sigue en 1280), así que el guion comprueba las columnas con la función
  pura `Configuracion.columnas_para`. Capturas en ventana del 12-oct-2026 en los cinco anchos: se corrigieron una
  cuadrícula que se salía por la derecha en 1280 (el `ScrollContainer` sin desplazamiento horizontal pasaba hacia
  arriba el ancho de la cuadrícula), el panel del control alto de más (1298 px) y el dorado del encendido, que se
  confundía con el foco.

- `menu_configuracion.guion`: cambian a propósito los casos de la zona de pruebas (ahora en el menú) y se agrega el
  del aviso del control; `menu.guion` se queda igual salvo el comentario.
- `validar.ps1` y todos los guiones (12-oct-2026: `fallos=0` y 119 guiones en verde). Pasa por el `revisor` antes
  del PR.
- En el S50 (la persona): cada botón con el pulgar, sin tocar el vecino, nada pegado a las orillas; el aviso del
  control al conectar y desconectar uno por Bluetooth (que Android avise del cambio no está comprobado).
- Documentos: `docs/contrato.md` («Menú», «Paquete de publicación»), `nucleo/CLAUDE.md`, `herramientas/CLAUDE.md`,
  filas de `docs/pruebas.md`; la `comprobacion` de `menu-desarrollo` solo cambia con aprobación de la persona.

## Cierre (12-oct-2026)

- Hecho: `nucleo/tema.gd`, menú, Configuración, pausa y zona de pruebas a 108 px; la zona en el menú de inicio;
  aviso del control; «Restablecer». `validar` 148/0, 119 guiones en verde y `menu_configuracion` con 49 casos.
  `revisor` en dos pasadas: sin fallos de código; sus seis de documentos y prueba, corregidos.
- Probado por la persona en el S50 con el dedo (APK de las 22:50 y 23:05): pasa. La columna izquierda cortada se
  arregló con la separación de 16 (`docs/errores/2026-10-12-menus-fuera-de-pantalla.md`).
- Abierto, fuera de este plan: todo con control (lo prueban los otros dos integrantes) y el editor de botones
  táctiles a 108 px.
