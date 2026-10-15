# La bola lanzada pegado a una pared la atravesaba

- **Síntoma**: con el jugador pegado a una pared, un toque del botón de poderes lanzaba una bola que salía del otro
  lado de la pared y golpeaba lo que hubiera detrás.
- **Causa**: la bola nace 60 px delante del jugador. Pegado a la pared, ese punto queda dentro de ella, y el rayo
  que el proyectil lanza desde su centro no reporta un sólido en el que ya empieza (`hit_from_inside` en falso).
- **Arreglo**: `nucleo/jugador.gd` (`_lanzar_poder`) lanza antes un rayo desde el jugador hasta el frente de la
  bola; si toca un sólido, no la crea (la Inspiración ya se pagó: la bola se deshace en la pared).
- **Guion que lo cubre**: `herramientas/guiones/nucleo/poder_bola_pegado_a_pared.guion`. Sin el arreglo da
  `MunecoTras/Golpeable golpes obtenido=1.00`. Lo encontró el revisor.
