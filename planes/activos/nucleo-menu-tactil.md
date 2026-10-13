ACTIVO

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

1. Todo lo que se toca mide al menos 108 px de alto, con un tema común (`gui/theme/custom` en `project.godot`) en
   lugar de tamaños nodo por nodo. Margen lateral de al menos 68 px en la vista base (en el S50, que se ensancha
   a 1440, unos 148): las cuadrículas se centran y no tocan las orillas.
2. Configuración en 3 columnas de 360×108 (32 px entre columnas). Vibración, Temblor y Modo desarrollador siguen
   siendo `CheckButton` (toda la fila ya responde), con fondo visible y el texto «Encendido» o «Apagado».
3. Zona de pruebas: el interruptor se queda en Configuración, pero con el modo encendido la entrada aparece en el
   **menú de inicio** y sale de Configuración. Reabre la decisión del 11-oct-2026
   (`planes/cerrados/nucleo-modo-desarrollador.md`), cuyo motivo era no dejar el interruptor suelto en el menú: el
   interruptor no se mueve. «Volver» de la zona regresa al menú.
4. «Botones del control» siempre visible, con un aviso «Conecta un control…» que se actualiza con
   `Input.joy_connection_changed`; un botón de 360×108 por acción con su tecla adentro. Ocultarlo descartado: mueve
   la cuadrícula y pierde el foco al desconectar.
5. Menú y pausa a 480×108; confirmaciones (Salir, Borrar) a 300×108 con 64 px entre los dos botones.

## Reglas para todas las pantallas (revisión de UI/UX con el advisor, 12-oct-2026)

La maqueta ilustra la vista de 1280; la especificación son estas reglas, no posiciones en px. La vista mide 720 de
alto y de 960 (4:3) a 1760 (22:9) de ancho (S50 1440, S20 1600).

1. Toque: todo lo que se toca mide al menos 108 px de alto (48 dp en el S50, el peor caso medido), también los
   elementos de la lista desplegable de Recursos (`PopupMenu` en el tema).
2. Texto: botones de al menos 36 px de la vista (16 dp en el S50); etiquetas y «Encendido/Apagado» de al menos 33
   (14 dp). La maqueta usaba 30 y 24: quedaban en 13 y 11 dp.
3. Columnas según el ancho de la vista, como ya hace la zona de pruebas: mínimo 2 (en 4:3 no caben 3 de 360) y, si
   no caben las filas en 720, el contenedor se desplaza. La fila de categorías de la zona, igual: se desplaza en
   horizontal o pasa a lista vertical si no cabe.
4. Margen: el del área segura de la pantalla (`get_display_safe_area` pasada a la vista, como los botones táctiles
   configurables), más un mínimo fijo; nada pegado a las orillas ni bajo la cámara.
5. «Volver» siempre en el mismo sitio en todas las pantallas (arriba a la izquierda, como la zona de pruebas), y
   Atrás hace lo mismo. «Borrar partida» lejos de «Volver».
6. Orden de Configuración por uso: Volumen, Vibración y Temblor primero; Borrar partida y Créditos al final.
   Volumen con «−» y «+» a los lados de la barra.

## Comprobación

- En ventana, la persona: `& $env:GODOT_PATH --path . --resolution <ancho>x720` con 960, 1280, 1440, 1600 y 1760:
  nada se sale, nada se encima, las columnas cambian y «Volver» sigue en su esquina. Un guion que compruebe las
  columnas por ancho solo si `--resolution` funciona en headless (sin comprobar: probarlo antes).

- `menu_configuracion.guion`: cambian a propósito los casos de la zona de pruebas (ahora en el menú) y se agrega el
  del aviso del control; `menu.guion` se queda igual salvo el comentario.
- `validar.ps1` y todos los guiones. Pasa por el `revisor` (toca `project.godot`).
- En el S50 (la persona): cada botón con el pulgar, sin tocar el vecino, nada pegado a las orillas; el aviso del
  control al conectar y desconectar uno por Bluetooth (que Android avise del cambio no está comprobado).
- Documentos: `docs/contrato.md` («Menú», «Paquete de publicación»), `nucleo/CLAUDE.md`, `herramientas/CLAUDE.md`,
  filas de `docs/pruebas.md`; la `comprobacion` de `menu-desarrollo` solo cambia con aprobación de la persona.
