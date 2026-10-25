# La barra del marco de menús se salía por la derecha

- **Síntoma:** con los botones del control en la barra (L1 en «Anterior», R1 en «Siguiente»), en la vista de 1280
  el botón «Siguiente» quedaba cortado en la orilla derecha. Sin control no se notaba.
- **Causa:** la barra ya pedía más de lo que cabe antes de los íconos: 1338 px de mínimo contra 1152 útiles. El
  título tenía un mínimo fijo de 360 px y, al final, un contrapeso del ancho de Volver (240 px) para centrarlo. Ese
  contrapeso quedaba fuera de la pantalla sin que se viera. Con los íconos, la barra subió a 1506 px y lo que salió
  de la pantalla fue «Siguiente».
- **Arreglo:** el título mide lo que su texto. El contrapeso toma solo lo que sobra, hasta el ancho de Volver
  (`MarcoMenus._acomodar_contrapeso`, al cambiar el mínimo de la barra o la vista). En la vista de 1280 el grupo
  del centro queda centrado en el espacio que deja Volver. Si sobra el ancho de Volver (pantallas más anchas que
16:9), queda al centro de la pantalla, como antes.
- **Lo cubre:** `herramientas/guiones/nucleo/marco.guion`, caso «con el control la barra cabe: Siguiente no pasa del
  margen derecho», en la página Mapa, la de vecinas más largas (falla con el código de antes).
