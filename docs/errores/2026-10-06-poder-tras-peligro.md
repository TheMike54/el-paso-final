# Una pulsación de curar sobrevivía al regreso al punto seguro

- **Síntoma**: si el jugador, ya invulnerable, tocaba un peligro mientras mantenía `curar`, volvía al punto seguro
  y al soltar `curar` ahí, quieto, contaba como un toque del botón de poderes (y lanzaba la bola si la tenía).
- **Causa**: la rama de `recibir_dano` para un peligro durante la invulnerabilidad sale antes de borrar la
  pulsación, y `_volver_al_punto_seguro` limpiaba la pulsación de saltar pero no la de curar.
- **Arreglo**: `nucleo/jugador.gd` borra la pulsación de curar (`_ticks_poder = -1`) en `_volver_al_punto_seguro`.
- **Guion que lo cubre**: `herramientas/guiones/nucleo/boton_poderes_peligro.guion`. Sin el arreglo da
  `toques_poder obtenido=1.00`. Lo encontró el revisor.
