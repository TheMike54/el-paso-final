# El retroceso de un golpe dejaba saltar completo

- **Síntoma**: presionar `saltar` justo después de recibir un golpe daba un salto completo en vez del empuje
  hacia arriba del retroceso.
- **Causa**: el golpe llega desde la física de `DanoContacto`, antes del `move_and_slide` del jugador. En el tick
  siguiente el jugador todavía cuenta como en el suelo (`is_on_floor()` del movimiento anterior), así que el
  contador del tiempo coyote vuelve a 0 y la condición del salto se cumple. Cerrar el contador en `recibir_dano`
  no bastaba por esa misma razón.
- **Arreglo**: `nucleo/jugador.gd` no deja saltar mientras dura el retroceso (`_ticks_retrocediendo == 0` en la
  condición del salto). `docs/jugador.md` lo dice en «Combate».
- **Guion que lo cubre**: `herramientas/guiones/nucleo/jugador_retroceso.guion`. Sin la regla da
  `velocity:y obtenido=-699.80`.
