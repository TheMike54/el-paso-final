# Muerto, el cuerpo quedaba en el aire

- **Síntoma:** al morir, entre el cuerpo tendido y el suelo quedaba un hueco chico. Lo vio el QA del #6 (issue #8,
  Galaxy A55 5G, fila 1.3).
- **Causa:** el script que arma el atlas (fuera del repo) pone el borde de abajo de cada hoja 4 px bajo el suelo,
  como en la escena de referencia. Eso apoya bien a las figuras de pie, pero en la hoja de daño y muerte el cuerpo que
  cae y el tendido no llegan a ese borde: los tres cuadros de `muerte` terminaban 3, 6 y 8 px más arriba que los de
  `quieto`.
- **Arreglo:** esos tres cuadros se apoyan con su propio borde de abajo, 4 px bajo el suelo como los de pie.
- **Lo cubre:** el caso «muerte: el cuerpo toca el suelo» de `herramientas/pruebas/prueba_animacion_jugador.gd`
  (guion `herramientas/guiones/nucleo/animacion_jugador.guion`). Con el atlas anterior falla con los tres cuadros.
