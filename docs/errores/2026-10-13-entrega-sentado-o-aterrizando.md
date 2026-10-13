# La entrega de recompensas respondía sentado en un banco o al aterrizar duro

- **Síntoma:** encontrado en la auditoría de código, sin verse en juego. `EntregaRecompensas` aceptaba `interactuar`
  con el jugador sentado en un banco o en el aterrizaje duro; el banco, el `Npc` y el reto no.
- **Causa:** cada uno de los cuatro objetos repetía su propia condición para interactuar, y la de la entrega solo
  pedía suelo, vida y no estar hablando.
- **Arreglo:** una sola regla, `Jugador.puede_interactuar` (en el suelo, vivo, de pie, sin aterrizaje duro ni
  conversación), que usan el banco, el `Npc`, el reto y la entrega.
- **Lo cubre:** `herramientas/guiones/nucleo/estado_sala.guion`, caso «de pie en el suelo se puede interactuar y
  sentado en un banco no» (falla si la regla olvida `descansando`). Prueba la regla, no que cada objeto la use.
