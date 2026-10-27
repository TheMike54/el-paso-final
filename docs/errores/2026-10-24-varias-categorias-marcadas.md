# Con L1 / R1 quedaban marcadas varias categorías de la zona de pruebas

- **Síntoma:** en la zona de pruebas, al cambiar de categoría con L1 / R1 (DUALSHOCK 4), la raya de la categoría
  anterior no se quitaba y quedaban varias marcadas: no se veía en cuál se estaba. Con el dedo no pasaba. Lo vio el
  QA del #6 (issue #8, Galaxy A55 5G, fila 7.4).
- **Causa:** `_mostrar()` de `herramientas/salas/zona_pruebas.gd` marcaba la pestaña nueva con
  `set_pressed_no_signal(true)`, y ese método no desmarca a las demás del `ButtonGroup`
  (`classes/class_basebutton.rst:466`). El toque sí pasa por el grupo, que las desmarca.
- **Arreglo:** `_mostrar()` recorre las pestañas y deja marcada solo la elegida, con `set_pressed_no_signal`, como
  `nucleo/caja_dialogo.gd` y `nucleo/nueva_partida.gd`.
- **Lo cubre:** el caso «y solo su boton queda marcado» de `herramientas/pruebas/prueba_zona_pruebas.gd` (guion
  `herramientas/guiones/nucleo/zona_pruebas_categorias.guion`). Antes solo se comprobaba que la nueva quedara marcada.
