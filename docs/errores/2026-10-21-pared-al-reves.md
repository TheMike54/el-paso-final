# El jugador pegado a la pared se veía al revés

- **Síntoma:** en el S50, sostenido en una pared (sala Pared), el cuerpo animado miraba hacia la pared, con la mano
  estirada hacia el aire y separado de ella unos 20 px. Lo vio la persona en la prueba «Cuerpo animado del jugador»
  del 21-oct-2026.
- **Causa:** `nucleo/jugador.gd` volteaba el `Dibujo` siempre con `_mirando`. En la pared `_mirando` apunta hacia
  ella, porque es hacia donde se empuja (y donde sale el ataque), pero los cuadros `pared` de la hoja están dibujados
  con la pared a la espalda: mirando afuera, con la mano y los pies del lado de la pared.
- **Arreglo:** `AnimacionJugador.volteo(nombre, mirando)` (`nucleo/animacion_jugador.gd`) da `-mirando` solo con la
  animación `pared`; `jugador.gd` lo usa para `Dibujo.scale.x`. `_mirando` no cambia: el ataque en la pared sigue
  saliendo hacia ella, como se decidió el 21-oct-2026. Volteado así, el cuerpo se metía en la pared: la mano y los
  pies sobresalen 90 px por detrás del eje del lienzo y el jugador mide 80 de ancho. Se aparta 50 px de ella
  (`AnimacionJugador.separacion_pared`, calculado de los márgenes de los cuadros).
- **Lo cubre:** los casos «volteo» y «pared: el cuerpo se aparta» de `herramientas/pruebas/prueba_animacion_jugador.gd` (guion
  `herramientas/guiones/nucleo/animacion_jugador.guion`). Que se vea bien pegado a la pared es dibujo: lo cubre la
  prueba manual «Cuerpo animado del jugador» de `docs/pruebas.md`.
