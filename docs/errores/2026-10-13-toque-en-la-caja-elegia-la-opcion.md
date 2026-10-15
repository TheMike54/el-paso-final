# Tocar la caja de diálogo elegía la opción marcada

- **Síntoma:** en el S50, en el reto de preguntas, un toque sobre la caja para completar el texto de la pregunta
  contestó la primera opción sin que se tocara ninguna: salió «No. Era: 8.» y la respuesta contó.
- **Causa:** `nucleo/caja_dialogo.gd` trataba el toque en la caja igual que `interactuar`, `saltar` y `atacar`:
  completa la línea y, completa, pasa a la siguiente. En una línea con opciones, «pasar» es tomar la marcada, que
  empieza siendo la primera. Con el texto ya completo (las preguntas cortas se escriben en menos de un segundo), el
  primer toque ya elegía.
- **Arreglo:** con opciones a la vista, el toque en la caja ya no elige; se elige tocando la opción. Las acciones
  (teclado y control) siguen tomando la marcada.
- **Lo cubre:** `herramientas/guiones/nucleo/dialogo.guion`, caso «con opciones, tocar la caja no elige» de
  `herramientas/salas/prueba_dialogo.gd` (sin el arreglo, ese caso y los cinco siguientes fallan).
