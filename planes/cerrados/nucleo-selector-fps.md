CERRADO

# Elegir 60 o 120 FPS en Configuración

Aprobado por la persona el 16-oct-2026.

Idea de la persona del 15-oct-2026, con detalles decididos ese mismo día:

- solo con Recursos en alto;
- arranca en 60;
- se esconde si la pantalla es de 60 Hz.

Entradas propuestas, que se agregan a `nucleo/funciones.json` al aprobar este plan: `selector-fps` (guion) y
`selector-fps-telefono` (manual).

## Por qué

Hoy no hay límite de FPS (`Engine.max_fps` = 0, decisión del 15-oct). En el S21 a 120 Hz el juego corre a 120. Eso
gasta batería y calienta, y la física va igual a 60 ticks (`physics_ticks_per_second`), así que lo que se gana es
solo la suavidad de la imagen. Con la opción, el jugador decide, y arrancar en 60 cuida la batería.

## Lo que dice Godot (copia local 4.7)

- `Engine.max_fps`: 0 es sin límite y se cambia en ejecución (`classes/class_engine.rst:129-136`). Con V-Sync no
  pasa del refresco de la pantalla (`:136`). En Compatibility, V-Sync siempre es `ENABLED`
  (`classes/class_displayserver.rst:7555-7557`).
- `DisplayServer.screen_get_refresh_rate()` está implementado en Android. Devuelve el refresco actual, o `-1.0`
  si falla (`classes/class_displayserver.rst:6193-6207`). No hay forma de listar las frecuencias que la pantalla
  admite.
- En Android, Swappy puede bajar el límite por su cuenta en el modo por defecto
  (`classes/class_projectsettings.rst:4685-4699`).
- **Sin comprobar:**
  - si con `max_fps` = 60 el S21 se queda en 60 estables;
  - si al volver a 0 o a 120 sube otra vez sin reiniciar;
  - si `screen_get_refresh_rate()` en el S21 dice 120 o 60 cuando la pantalla está en modo adaptable.

## Qué se hace

- **Ajuste nuevo `fps`, 60 o 120, por omisión 60.**
  - Va en `nucleo/ajustes.gd`, en sus cuatro sitios: variable, valor por omisión, lectura validada y guardado.
  - Unos ajustes viejos sin el campo leen 60 (decisión del 14-oct: campos nuevos con valor por omisión).
- **Regla, en una función pura y probada:** `Ajustes.limite_fps(fps, recursos_altos, refresco) -> int`.
  - Devuelve 0 (sin límite, V-Sync manda) solo con Recursos en alto, el refresco en 90 o más y el ajuste en 120.
  - En los demás casos devuelve 60.
  - `refresco` = -1 cuenta como 60 Hz.
- **Dónde se aplica:** en `Arranque`, al cargar los ajustes, al tocar la opción y al cambiar Recursos desde el menú.
- **La opción en Configuración.**
  - Un `BotonValor` «FPS: 60 / 120», debajo de Recursos, con el mismo estilo; cada toque alterna y guarda.
  - Visible solo si el refresco es de 90 Hz o más y Recursos queda en alto, sea elegido o por el automático.
  - Desde la pausa sí se puede cambiar: a diferencia de Recursos, no recarga nada.
  - Cumple la skill `ui-tactil`.
- **Desarrollo:** el APK «Desarrollo» arranca con `--print-fps`, así que logcat da el FPS real en cada caso.

## Hitos

1. H1 · Ajuste, regla y su prueba en `prueba_guardado.gd`.
   - Casos: viejo sin campo da 60, valor inválido da 60, y la tabla de `limite_fps` con bajo, alto, 60 Hz, 120 Hz
     y -1.
2. H2 · La opción en Configuración y su prueba en `prueba_menu_configuracion.gd`.
   - Casos: escondida con 60 Hz o en bajo, visible con 120 Hz y alto, y el toque alterna y guarda. El refresco se
     inyecta en la prueba, porque sin pantalla no hay.
3. H3 · `validar.ps1`, guiones `guardado` y `menu_configuracion`. Después, el revisor: toca ajustes, `Arranque` y
   Configuración.
4. H4 · Teléfonos, con `adb` y el APK de desarrollo.
   - **S50 (60 Hz):** la opción no aparece y el FPS sigue en ~56-60 en la sala de arte en bajo, igual que antes.
   - **S21, o el S20 si es de 120 Hz** (se comprueba con `dumpsys display`):
     - en alto con 60, logcat a ~60 durante 2 min;
     - con 120, a ~120;
     - al cambiar en la pausa, el FPS cambia sin reiniciar.
   - Valores a `docs/pruebas.md`.
5. H5 · Prueba manual de la persona en el S21: con 60 y con 120, caminar y saltar en la sala de movimiento. A 120,
   ¿se ve más suave? A 60, ¿nada se ve a saltos?

## Riesgos

- Si Swappy no respeta 60 (se queda en 120 o baja a 30), se mide y se decide con la persona. Se puede cambiar
  `display/window/frame_pacing/android/swappy_mode` a `pipeline_forced_on`, que respeta `max_fps`
  (`class_projectsettings.rst:4693`), pero eso toca `project.godot` y lleva revisor.
- Si el S21 reporta 60 Hz en modo adaptable, la opción quedaría escondida justo donde sirve. En ese caso se mide y
  se decide si la regla usa otro dato.

## Avance (16-oct-2026)

- H1 y H2: el ajuste `fps`, `Ajustes.limite_fps` y `fps_disponible`, y la opción FPS en Configuración.
  - Sin pantalla (guiones), `aplicar_fps` no toca el límite: los guiones corren tan rápido como pueden.
  - 5 casos en `prueba_guardado.gd` y 5 en `prueba_menu_configuracion.gd`.
- H4, S50 con `adb`:
  - pantalla de un solo modo a 60 Hz;
  - con Recursos en alto, la opción no aparece;
  - el menú corre a 59-60 FPS.
- H4 en el S21 (17-oct-2026), medido con `adb`. Los valores están en `docs/pruebas.md`, fila «FPS en el teléfono».
  - El S21 tiene modos de 48, 60, 96 y 120 Hz.
  - Con Recursos en alto, la opción aparece en 60.
  - A 120: 119-120 FPS en la sala de arte durante 2 min.
  - Cambiada a 60 desde la pausa, sin reiniciar: 59-61 FPS durante 2 min.
  - Swappy respetó `max_fps`, así que no hizo falta tocar `swappy_mode`.
  - Riesgo descartado: el refresco del modo adaptable no escondió la opción.
  - `selector-fps-telefono` pasa.
- 17-oct-2026, la persona en el S21, sala de arte: a 120 el jugador se siente más fluido que a 60 (H5).
- 17-oct-2026, revisor: aprobado. Sin comprobar por guion, por diseño: que `Engine.max_fps` quede en 0 o 60 de
  verdad (lo cubre la medición del S21) y que un arranque con 120 guardado parta a 120 sin pasar por Configuración.
  Cerrado el 17-oct-2026.
