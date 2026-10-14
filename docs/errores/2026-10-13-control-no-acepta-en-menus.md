# El control no pulsaba los botones de los menús

- **Síntoma:** en la prueba manual «Control conectado» (13-oct-2026, Samsung A55 5G con DUALSHOCK 4 por Bluetooth,
  APK de `114908b`), en el menú de pausa el stick movía el foco, pero Cruz (A en Xbox) no pulsaba el botón. Lo mismo
  vale para cualquier menú: el control solo navegaba.
- **Causa:** un `Button` con foco se pulsa con la acción `ui_accept`, y en Godot 4.7.2 `ui_accept` trae solo Enter,
  Enter del teclado numérico y Espacio, ningún botón del control (comprobado imprimiendo
  `InputMap.action_get_events(&"ui_accept")`). `project.godot` no la redefinía. La prueba del mapeo
  (`prueba_control.gd`) saltaba las acciones `ui_*` y en la PC no hubo un control para probarlo a mano.
- **Arreglo:** `project.godot` redefine `ui_accept` con sus tres teclas y A / Cruz (botón 0). Ningún código del
  juego lee `ui_accept`: solo los menús. En una copia del repo, un `Button` con foco que recibe el botón 0 como
  evento real no se pulsaba antes del arreglo y sí después.
- **Lo cubre:** `herramientas/guiones/nucleo/entrada_control.guion`, caso «A acepta en los menús» de
  `prueba_control.gd` (falla sin el arreglo). La pulsación con un control real sigue siendo la prueba manual
  «Control conectado» de `docs/pruebas.md`.
