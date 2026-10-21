# Interactuar sobre un banco o una entrega durante el hit-stop

- **Síntoma:** si un golpe le llegaba al jugador parado sobre un `Banco` y pulsaba `interactuar` dentro del congelado
  común (el hit-stop, `ticks_hit_stop` = 10 ticks), se sentaba en ese tick: `sentarse()` cancelaba el retroceso del
  golpe y el descanso llenaba las vidas al instante. Sobre una `EntregaRecompensas` pasaba lo mismo: entregaba con
  todo el juego detenido. Lo encontró la auditoría del código (W4 del paso 8), no una partida.
- **Causa:** `Banco` y `EntregaRecompensas` tenían su propio `_physics_process`, que solo miraba `interactuar` recién
  pulsado y `Jugador.encima_de`. El `Npc`, el reto, la mochila, la tienda y la estación además exigen
  `not Congelado.activo()`, como todo lo que se detiene en el hit-stop; los dos se quedaron sin esa condición. El
  jugador, que sigue en el suelo durante el congelado, pasaba `Jugador.puede_interactuar`.
- **Arreglo:** los dos extienden `Interactuable` con `con_aviso` en falso (puesto en `_init`): el disparador de la base
  ya pide `interactuar` recién pulsado y sin `Congelado.activo()` antes de `Jugador.encima_de`, y llama al gancho
  `_al_interactuar`, que hace `descansar(jugador)` o `entregar()`. La pulsación hecha durante el congelado se pierde,
  como en el `Npc`. Nada cambia a la vista: sin aviso no siguen `cerca` ni dibujan nada propio. La regla quedó en
  `docs/contrato.md` («Bancos», `EntregaRecompensas` e `Interactuable`).
- **Lo cubre:** `herramientas/guiones/nucleo/estado_sala.guion` (`prueba_estado_sala.gd`): «en el congelado
  interactuar sobre un banco no descansa» (no cambia `Partida.banco`, no emite `descanso_en_banco` y el jugador no
  queda sentado), «en el congelado interactuar sobre la entrega no entrega» (`entregadas` en 0 y las monedas igual),
  y los dos de control fuera del congelado, que sí descansan y entregan. Con el código anterior fallan los dos
  primeros.
