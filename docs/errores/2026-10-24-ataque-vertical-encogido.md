# Al atacar arriba o abajo el cuerpo se encogía

- **Síntoma:** al atacar hacia arriba o hacia abajo, el cuerpo entero, cabeza incluida, se veía más chico que de pie.
  Lo vio el QA del #6 (issue #8, Galaxy A55 5G, fila 1.2) y lo confirmaron dos capturas de la persona en el S21 el
  24-oct-2026.
- **Causa:** el script que arma el atlas (fuera del repo) escala cada hoja para que la máscara blanca de la cara
  mida lo mismo que en la vista de referencia. En la hoja del ataque vertical, en los cuadros 0 a 3 la búsqueda de lo
  blanco tomaba también la katana y el tajo: una caja de 164-248 px de alto y unos 395 de ancho, contra 114-122 ×
  36-50 de la máscara real. El alto medio salía 163 en vez de unos 115 y la hoja quedaba al 71 %: 97-126 px de alto en
  el juego, contra 150-165 de las demás. El código del juego no escala el cuerpo (solo voltea `scale.x`).
- **Arreglo:** la escala de esa hoja sale solo de los cuadros 4 y 5, y los cuadros 0 a 3 se alinean por los pies.
  Las otras 12 hojas se revisaron con la misma cuenta y su escala sale bien. Con el atlas nuevo el lienzo común pasó
  de 316 × 180 a 316 × 182 (los pies en la fila 178) y el `offset` del `Dibujo` de (−158, −96) a (−158, −98). No
  cuesta rendimiento: el mismo número de cuadros y de dibujos, y la página pasó de 1976 × 636 a 2020 × 668.
- **Lo cubre:** el caso «ataque arriba: el cuerpo no se encoge» de `herramientas/pruebas/prueba_animacion_jugador.gd`
  (guion `herramientas/guiones/nucleo/animacion_jugador.guion`): el cuadro más alto del ataque arriba mide al menos
  lo que el de `quieto`. Con el atlas anterior falla (126 contra 163 px).
