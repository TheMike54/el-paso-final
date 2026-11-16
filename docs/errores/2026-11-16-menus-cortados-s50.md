# Botón del mapa y detalle de los menús cortados en el S50

- **Síntoma:** en el S50 (pantalla 2:1, el juego a 1440×720), el botón «Ver todo» del mapa quedaba fuera de la
  pantalla (solo se veía un píxel abajo), y en Útiles, con los cupos llenos y un útil de texto largo elegido, el texto
  del detalle y el aviso de cupos llenos se salían por abajo.
- **Causa:**
  - `PantallaMapa` ponía al botón solo las anclas abajo a la derecha (`set_anchors_preset`) y después `position`; sin
    los bordes, el tamaño mínimo lo dejaba fuera del borde de abajo.
  - `DetalleMenu` apilaba nombre, imagen, texto, motivo y botón en una columna sin límite: un texto largo con el motivo
    pasaba del alto disponible. Las capturas de la PC usaban un útil de texto corto y no lo mostraban.
- **Arreglo:** el botón usa `set_anchors_and_offsets_preset(PRESET_BOTTOM_RIGHT, PRESET_MODE_MINSIZE, margen)`. En
  `DetalleMenu` el texto va en un `ScrollContainer` que ocupa lo que sobra, así el motivo y el botón quedan siempre
  abajo y a la vista. Capturas a 960×480 con los cupos llenos y un útil sin poner, y del mapa.
- **Lo cubre:** `herramientas/guiones/mapa/mapa_cuentas.guion`, caso «el boton de vista se ve completo en la
  pantalla» (mutación de la posición: muere). El detalle se revisa con capturas: el alto depende del texto y de la letra.
