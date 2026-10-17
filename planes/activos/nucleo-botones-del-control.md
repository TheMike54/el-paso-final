ACTIVO

# Botones del control en la interfaz

Aprobado por la persona el 16-oct-2026.

Idea de la persona del 14-oct-2026: con un control conectado, mostrar sus botones en la interfaz, como Hollow
Knight. Se analizó el video de referencia de Silksong el 15-oct; sus notas están fuera del repo.

Entradas propuestas, que se agregan a `nucleo/funciones.json` al aprobar este plan:

- `iconos-boton` (prueba de la lógica);
- `iconos-boton-pantallas` (guion de menús);
- `iconos-boton-telefono` (manual, con Xbox y DUALSHOCK 4).

## Referencia

- **Silksong.** Cada ícono sabe qué acción representa, no qué botón (`ActionButtonIconBase.Action`).
  - El dibujo sale del último dispositivo que se usó: si fue teclado, la tecla; si fue control, el botón según la
    familia (PS4, PS5, Switch o Xbox; `UIButtonSkins.cs:216-222` y `:338-513`).
  - Se redibuja al cambiar de dispositivo (`RefreshActiveControllerEvent`, `liveUpdate`).
  - Es lectura nueva del código descompilado: las notas de la referencia no lo traían.
- **El video.**
  - Íconos solo en los menús, como ayuda: «Zoom In ✕», «Volver ○». Ninguno en el juego.
  - Botones de la cara: disco blanco con el símbolo oscuro, ~20-22 px a 720p.
  - L1 / R1: pastillas de ~38×20 a los lados de la fila de pestañas.
  - «HOLD» encima, en chico, cuando hay que mantener.
  - Lo que no se puede usar, en gris.
- **Lo que no se ve en el video:** cómo cambian al conectar o desconectar el control.

## Qué se hace

- **`IconoBoton`** (`nucleo/icono_boton.gd`, un `Control`). Tiene una acción con nombre y un texto opcional
  («Volver»).
  - Dibuja con `_draw`, sin imágenes: arte propio, sin licencias, casi gratis en el S50. Solo redibuja al cambiar.
    - **PlayStation:** ✕ ○ □ △ trazados con líneas dentro del disco.
    - **Xbox:** A B X Y en letra.
    - **Gatillos y laterales** (L1, R1, LB, RB, L2, R2, LT, RT): pastilla con texto.
    - **Start / Options y Select / View:** pastilla con texto.
  - El botón sale de `Mando.boton_de(accion)`, así que respeta lo reasignado.
- **Cuándo se ve:**
  - con control (`UltimaEntrada.con_control` y la última entrada de un control): el botón;
  - con teclado: la tecla, en una pastilla con su nombre (`OS.get_keycode_string`), como Silksong;
  - tras un toque: no se dibuja, porque en táctil los botones son los de la pantalla.
- **Familia del control.**
  - `UltimaEntrada` recuerda el `device` del último evento de control.
  - `Mando.familia(nombre, guid) -> String` decide entre «playstation» y «xbox», que es la de por omisión. Es
    PlayStation si el GUID SDL trae el fabricante Sony (`4c05`) o el nombre contiene «PS», «DualShock»,
    «DualSense» o «Sony». La fuente es `Input.get_joy_name` y `get_joy_guid` (`classes/class_input.rst:794-796` y
    `:904`).
  - Los nombres reales que devuelven Android y Windows no están en la documentación. Se leen en el H1 con los dos
    controles y se anotan aquí.
- **Señal `UltimaEntrada.cambio`** cuando cambian `con_control` o la familia: cada `IconoBoton` vivo se redibuja.
- **Primeros lugares (v1):**
  1. La fila de categorías de la zona de pruebas: L1 a la izquierda y R1 a la derecha. Depende de
     `herramientas-zona-pruebas-l1-r1.md`.
  2. El marco de menús: L1 y R1 junto a «Anterior» y «Siguiente»; «Volver» con B / Círculo (depende de
     `nucleo-circulo-atras.md`).
  3. Los «Volver» de Configuración, de la pausa y de la zona de pruebas: el ícono de `volver`.
  4. «Botones del control» en Configuración: cada fila muestra el ícono del botón asignado, en lugar de solo el
     texto «A / Cruz».
- **Fuera de este plan:**
  - el dibujo completo del control (la pantalla «Controller» de Silksong);
  - el desvanecido de 0,15 s;
  - íconos en el mundo (bancos, NPC).

  Se proponen después si hacen falta.

## Hitos

1. H1 · Medir los nombres y GUID que da Godot.
   - En Windows con el control que tenga la persona, y en el S50 con `adb` si se le conecta uno por USB-OTG o
     Bluetooth.
   - Se imprime `get_joy_name` y `get_joy_guid` en una sala de prueba oculta y se anotan aquí.
2. H2 · `Mando.familia`, el `device` y la señal en `UltimaEntrada`, e `IconoBoton`.
   - Prueba de la lógica (`prueba_icono_boton.gd`):
     - familia por nombre y GUID, con los valores medidos;
     - el botón sale del InputMap reasignado;
     - con toque no se dibuja, y con teclado da la tecla;
     - la señal se emite solo al cambiar.
3. H3 · Los cuatro lugares.
   - Antes, la skill `ui-tactil` (tamaños, áreas seguras), y que la fila de la zona siga cabiendo en el S50 (hoy,
     1312 px).
   - El guion de menús comprueba que con control el ícono es visible y tras un toque no.
4. H4 · `validar.ps1`, los guiones de menú, configuración, marco y zona, y la revisión en 1280×720, 1920×1080 y
   2560×1440. Después, el revisor: es el cierre del tema e incluye la entrada.
5. H5 · Prueba manual de la persona:
   - en la tableta con Xbox y en un teléfono con DUALSHOCK 4: los íconos son los de cada control;
   - al tocar la pantalla desaparecen y vuelven al usar el control;
   - reasignar Saltar cambia el ícono.

## Riesgos

- Un control genérico sin «PS» en el nombre ni GUID de Sony sale como Xbox: se acepta.
- Si un DUALSHOCK 4 en Android da un nombre que no se reconoce, se agrega con lo que se mida en el H1 o en el H5.

## Avance (16-oct-2026)

- H1 sin hacer: no hubo control conectado en la sesión. `Mando.familia` usa el fabricante Sony del GUID y una lista
  de nombres; los valores reales se anotan aquí en el H5.
- H2 hecho, con dos cambios al programar:
  - en lugar de la señal `UltimaEntrada.cambio`, cada `IconoBoton` compara por cuadro `UltimaEntrada.dispositivo` y
    `Mando.cambios` (un texto y un número; con pocos íconos cuesta casi nada y no hay que conectar ni desconectar);
  - `UltimaEntrada.dispositivo` vale `toque`, `teclado` o la familia del control.
  - 20 casos en `prueba_icono_boton.gd` (guion `icono_boton`).
- H3 hecho en los cuatro lugares. L1 y R1 de la zona de pruebas van a la derecha de la barra de arriba, con
  «Categoría»: en la fila de categorías desbordaban a 1280×720. Casos de íconos en `prueba_menu_configuracion.gd`
  (Volver y la fila reasignada), `prueba_marco.gd` (barra y Continuar) y `prueba_zona_pruebas.gd`.
- H4: `validar.ps1` y todos los guiones pasan. Capturas a 1280×720, 1920×1080 y 2560×1440 con Xbox y PlayStation
  (zona, Configuración, Botones del control, pausa y marco).
  - La barra del marco se salía por la derecha con los íconos. Se arregló el contrapeso del título
    (`docs/errores/2026-10-16-barra-del-marco-desbordada.md`) y quedó un caso en `prueba_marco.gd`.
  - En las capturas de Configuración se ve el menú principal detrás. Es cosa de la escena de captura, que abre
    Configuración sin pasar por el menú: en el juego, el menú se esconde al abrirla.
  - Falta el revisor.
- Después del revisor (aprobado; el 16-oct-2026):
  - en depuración, `UltimaEntrada` imprime en el log una línea `CONTROL` con el nombre, el GUID y la familia de cada
    control. Android suele llamar al DUALSHOCK 4 «Wireless Controller», nombre que también usa Xbox y que por eso
    no está en la lista. Si su GUID no trae a Sony, saldría con letras de Xbox: esa línea dice qué agregar;
  - un caso más: tras un toque la fila de Saltar no dibuja botón.
- Falta el H5: la prueba manual con Xbox y con DUALSHOCK 4.
