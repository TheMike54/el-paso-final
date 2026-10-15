# Recoger un mapa no autoguardaba

- **Síntoma:** encontrado leyendo el código (auditoría del 13-oct-2026), sin verse en el juego. Tomar un
  `ObjetoMapa` o recibir un mapa como recompensa de una `EntregaRecompensas` no autoguardaba ni lo avisaba por el
  bus: si el juego se cerraba antes del siguiente guardado, el mapa se perdía. Las habilidades y los amuletos sí
  autoguardan.
- **Causa:** `ObjetoMapa._al_entrar` y `Partida.dar_recompensa` (tipo `MAPA`) hacían `Partida.mapas.append` directo,
  sin pasar por una función que avisara, como `obtener_amuleto`. Solo la entrega de un `Npc` guardaba, porque
  autoguarda al terminar la conversación.
- **Arreglo:** `Partida.obtener_mapa(zona)` suma el mapa y emite `Eventos.mapa_obtenido`, que autoguarda; si ya se
  tenía, no hace nada. La usan `ObjetoMapa` y `dar_recompensa`; nada más escribe `mapas`.
- **Lo cubre:** `herramientas/guiones/nucleo/guardado.guion`, casos «obtener un mapa lo suma y autoguarda» (falla sin
  el arreglo), «un mapa que ya se tiene, recogido o como recompensa, no hace nada» y «el mapa sigue al recargar»; y
  `herramientas/guiones/nucleo/bus_eventos.guion`, que falla si `mapa_obtenido` no está en el bus.
