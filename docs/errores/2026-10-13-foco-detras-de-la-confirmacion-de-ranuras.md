# Con la confirmación de las ranuras abierta, el foco se iba a las fichas de detrás

- **Síntoma:** encontrado leyendo el código (auditoría del 13-oct-2026). Con teclado o control, al pedir «Borrar» o
  «Restaurar», moverse con las flechas llevaba el foco a los botones de las fichas, tapadas por la confirmación.
- **Causa:** la confirmación solo cubría la pantalla; las fichas seguían visibles para la navegación de foco.
- **Arreglo:** mientras se confirma, las fichas se ocultan, como el menú en su confirmación de salida.
- **Lo cubre:** `herramientas/guiones/nucleo/ranuras.guion`, caso «con la confirmacion abierta el foco no sale de
  ella» (falla sin el arreglo).
