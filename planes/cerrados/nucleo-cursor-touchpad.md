CERRADO

# Esconder en Android el cursor del touchpad del DUALSHOCK 4

Aprobado por la persona el 16-oct-2026.

Decidido por la persona el 15-oct-2026. Entrada `cursor-touchpad-oculto` de `nucleo/funciones.json`.

## Por qué

En el A55 con DUALSHOCK 4 (QA del 14-oct), el touchpad del control mueve un puntero del sistema que queda encima
del juego. Ese puntero manda eventos de ratón. Un clic del touchpad es un `InputEventMouseButton`, y
`UltimaEntrada.anotar` lo cuenta como un toque (`nucleo/ultima_entrada.gd:22-31`), así que el foco de los menús deja
de dibujarse aunque se esté jugando con el control.

## Lo que se sabe y lo que no

- **Hay con qué esconderlo.** `Input.mouse_mode = MOUSE_MODE_HIDDEN` esconde el cursor
  (`classes/class_input.rst:245-255`). Android tiene `FEATURE_MOUSE` (`classes/class_displayserver.rst:676-678`).
- **No se sabe si funciona en Android.** La documentación no dice nada de Android en estos modos. Hay issues de
  Godot en que `MOUSE_MODE_CAPTURED` no esconde el puntero de un ratón externo en Android (#60031, #103196).
  Ninguno trata `HIDDEN`, ni el touchpad de un control, ni la versión 4.7.2.
- Por eso el H1 es medir antes de programar.

## Qué se hace

1. **H1 · Medir en el S50 con `adb`.** Una sala de prueba pone `MOUSE_MODE_HIDDEN`.
   - Con `adb shell input mouse tap` y `input mouse` (eventos de ratón inyectados), se toma una captura
     (`screencap`) con y sin el modo, para ver si el puntero aparece.
   - En logcat, qué evento llega: botón y movimiento de ratón, y su `device`.
   - El resultado va a este plan. Si el puntero no sale en las capturas ni sin el modo, se dice: la prueba no
     sirve y se pasa al H3 con la duda anotada.
2. **H2 · Si `HIDDEN` sirve:**
   - `Arranque` lo pone en Android al iniciar (`OS.has_feature("android")`). En Windows no: el ratón sigue
     visible en la PC.
   - `UltimaEntrada` deja de contar en Android un `InputEventMouseButton` que no viene de la pantalla. El toque
     real sigue llegando como `InputEventScreenTouch`, y el ratón que emula a partir de él trae
     `device == InputEvent.DEVICE_ID_EMULATION`.
   - Prueba de la lógica en la prueba que ya cubre `UltimaEntrada`: un clic de ratón en Android no apaga el foco y
     un toque sí. Se cubre separando la regla en una función que recibe la plataforma.
3. **H3 · Prueba manual de la persona con un DUALSHOCK 4 en un teléfono:**
   - mover y tocar el touchpad: no aparece el puntero;
   - pulsar el touchpad en un menú: el foco sigue dibujado;
   - tocar la pantalla con el dedo: el foco se apaga, como antes.
4. **Si `HIDDEN` no sirve (plan B, decisión de la persona):**
   - un plugin de Android con `View.setPointerIcon(PointerIcon.TYPE_NULL)`. Es código Java y su propio preset de
     exportación: mucho más trabajo;
   - o se acepta el puntero y solo se arregla lo del foco (el H2 sin la primera parte).
5. **H4 · Revisor**, porque toca `Arranque` y la entrada.

## Avance (16-oct-2026)

- H1, en el S50:
  - `adb shell input mouse` no crea un ratón real: Android no dibuja puntero (`dumpsys input`: sin captura ni
    controlador de puntero) y la captura sale limpia. Con `adb` no se puede medir.
  - En su lugar se leyó el código de Godot (rama 4.5; la 4.7 no se leyó). En Android, `MOUSE_MODE_HIDDEN` pone
    `PointerIcon` nulo en la vista (`display_server_android.cpp`, `_mouse_update_mode`).
  - Solo lo aplica con API 26 o más y si lo último que vio fue un ratón o nada (`GodotInputHandler.canCapturePointer`).
    Si no, no reintenta un modo ya pedido.
- H2:
  - `UltimaEntrada` lo pide al arrancar en Android y, tras cada toque, lo vuelve a pedir (VISIBLE y luego HIDDEN) con
    el primer evento de ratón real.
  - En Android un clic de ratón real (sin `DEVICE_ID_EMULATION`) no apaga el foco.
  - 2 casos en `prueba_menu_configuracion.gd`.
  - En el S50, con el APK de este cambio, los toques siguen funcionando.
- Falta: H3 (la persona, con un DUALSHOCK 4) y H4 (revisor).

- 17-oct-2026: plan cerrado por decisión de la persona. El código y la prueba con el dedo están; la prueba con un control la harán compañeros del equipo y sigue como entrada `manual` con `"pasa": false` en `funciones.json`.
