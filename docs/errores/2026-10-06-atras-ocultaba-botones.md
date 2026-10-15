# El botón Atrás ocultaba los botones táctiles

- **Síntoma**: en el teléfono, después de abrir y cerrar la pausa con Atrás, los botones táctiles desaparecían.
- **Causa**: Android manda Atrás como una tecla (`KEY_BACK`). Los controles táctiles se ocultaban con cualquier
  `InputEventKey`, porque así detectaban un teclado conectado. Las teclas de volumen habrían hecho lo mismo.
- **Arreglo**: `nucleo/controles_tactiles.gd` solo se oculta con una tecla o un control que dispara una acción del
  juego (`_es_de_juego`).
- **Guion que lo cubre**: `herramientas/guiones/nucleo/controles_tactiles.guion`, caso «el boton Atras de Android
  no oculta los controles». Comprobado además en el teléfono con `adb shell input keyevent KEYCODE_BACK`.
