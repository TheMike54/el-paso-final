# Dormido en un banco sin arte, el jugador se apoyaba en el aire

- **Síntoma:** al descansar en el banco de `raices_7`, el jugador quedaba sentado con los brazos recargados en el aire
  sobre el rectángulo provisional del banco (issue #27). En `celda_1` se veía bien.
- **Causa:** no era la posición ni la animación. Las poses `sentarse` y `dormir` están dibujadas sobre el banco del
  juego, una mesa con sillas vista de perfil: el asiento queda a unos 41 px del suelo y la tapa de la mesa a 71 px. Solo
  el banco de `celda_1` llevaba ese dibujo como hijo (`Silla`); el de `raices_7` iba sin arte y con `mirando` en 0, así
  que además la pose podía quedar hacia el lado que no tiene mesa.
- **Arreglo:** el banco de `raices_7` lleva su `Silla` (`contenido/salas/raices/arte/banco.png`, la misma forma con la
  paleta de Las Raíces, 133 × 82 px, colocada igual que en `celda_1`) y `mirando = 1`. Un banco nuevo en cualquier sala
  del juego necesita las dos cosas; los de las salas de prueba siguen con el rectángulo provisional.
- **Lo cubre:** `herramientas/guiones/contenido/raices_7_ruta.guion` comprueba que `Banco/Silla` se ve y que el banco
  mira a la derecha. Que el jugador se vea sentado sobre la silla se revisa a ojo: `docs/pruebas.md`, «Banco de Las
  Raíces».
