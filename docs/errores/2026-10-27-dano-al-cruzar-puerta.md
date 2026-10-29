# El jugador podia recibir dano y moverse mientras cruzaba una puerta

- **Síntoma:** desde que el jugador tocaba una puerta hasta que cambiaba la sala (el fundido, 15 ticks entonces), seguía
  con el control y sin ninguna protección: podía caminar de vuelta, atacar, curarse y recibir un golpe o un peligro.
  Un peligro en ese tiempo pedía su propio fundido y lo devolvía al punto seguro con la sala ya por cambiar. Lo
  encontró una auditoría leyendo el código; con las puertas que salen caminando (más largas) se habría visto.
- **Causa:** no había un estado de transición en el jugador: la puerta solo pedía el fundido y el cambio, y el jugador
  seguía leyendo los controles y `recibir_dano` no sabía que la sala se iba.
- **Arreglo:** `Jugador.Transicion` (como `HeroTransitionState` de Hollow Knight). La puerta llama a `salir_de_sala`;
  mientras `en_transicion`, el jugador no lee los controles, `invulnerable` es verdadero, `recibir_dano` vuelve sin
  hacer nada (también ante un peligro) y `puede_interactuar` es falso. Se mueve con `move_and_slide` y tiene un tope
  de ticks para no quedarse así si el cambio falla. Morir o reaparecer cortan la transición.
- **Lo cubre:** `herramientas/guiones/nucleo/transicion.guion` (`prueba_transicion.gd`: sin el `en_transicion` de
  `recibir_dano`, fallan 3 casos) y `nucleo/bus_eventos.guion` (`jugador_danado` 0 en la ida y vuelta).
