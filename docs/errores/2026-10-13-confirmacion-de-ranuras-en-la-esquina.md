# La confirmación de las ranuras salía en la esquina de arriba

- **Síntoma:** en el S50, al tocar «Borrar» de una ranura, la pantalla no se oscurecía y solo se veía un botón
  «Cancelar» encima de «Volver», arriba a la izquierda; la pregunta y el botón «Borrar» quedaban fuera de la pantalla.
  Las fichas se veían bien, y las pruebas pasaban porque solo miraban que la confirmación estuviera visible.
- **Causa:** `Ranuras` (y después `NuevaPartida`) se ponía a pantalla completa con `set_anchors_preset`, que cambia
  las anclas pero conserva el tamaño que tenía el nodo al crearse: 0×0. Las fichas no lo notaban porque su marco se
  coloca a mano con el área útil; la confirmación, anclada a `Ranuras`, medía 0×0 y su caja se centraba en la esquina.
- **Arreglo:** `set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)` en `Ranuras`, en su confirmación y en
  `NuevaPartida`.
- **Lo cubre:** `herramientas/guiones/nucleo/ranuras.guion`, caso «la confirmacion cubre la pantalla y su Si se ve
  entero» (falla con el código de antes).
